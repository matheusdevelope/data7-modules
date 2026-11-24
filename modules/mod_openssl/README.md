# mod_openssl

Windows helper that installs a portable `openssl.exe` from a zip and runs PKCS#12 export plus raw OpenSSL CLI. It does not generate certificates, parse PEM/CRT/KEY contents, choose a PFX password policy, or keep auto-created export files after `Dispose` — that stays in the consumer.

Version: `1.0.0.0`. Dependencies (`data7.json`): `mod_portable_exe` `2.0.0.0`, `mod_win_process` `1.0.0.0` (`TZipPortableExe` / `TRemotePortableExe` / `TPortableExe` inherit `TWinProcess`; transitively `mod_io`).

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## Quick Start (Minimal)

```bas
Imports mod_openssl

Dim _ossl As New OpenSSL()
' constructor: DownloadUrl = GitHub openssl.zip, timeout 120000 ms,
' InstallFolder = "openssl", ExeFileName = "openssl.exe", ArchiveName = "OpenSSL.zip", SearchRecursive = True

Dim _crt As String = _ossl.ExportCrt("cert.pfx", "123456", "cert.crt")
' PKCS#12 → certificate only (-clcerts -nokeys); writes cert.crt; returns that path

Dim _key As String = _ossl.ExportKey("cert.pfx", "123456", "cert.key")
' PKCS#12 → unencrypted key (-nocerts -nodes); writes cert.key; returns that path

print(_ossl.Version())
' first Path/Execute/Version/Export* access installs openssl.exe if missing, then runs: openssl version

_ossl.Free()
' Dispose deletes TrackTemp files (auto outputs when pOutput was "")
```

Empty `pOutput` (`""` after `Trim`) writes a temp file and tracks it for `Dispose`. An explicit path is owned by the consumer and is not deleted.

---

## Namespace map

| File | Namespace | Types |
|---|---|---|
| `src/mod_openssl.bas` | `mod_openssl` | `OpenSSL` |

`src/Principal.bas` declares no namespace: it is the demo entrypoint (`New OpenSSL` → `ToString` → `Free`). There is no `TXxxxTests.RunAll` in this module. Vendored `data7_modules/` are dependencies, not this module's public surface.

`OpenSSL` inherits `TZipPortableExe` → `TRemotePortableExe` → `TPortableExe` → `TWinProcess`. CLI capture used by `Execute` is a composed `TWinProcess` (`CaptureLines` + `BuildCommand`), not `me.CaptureLines`.

---

## OpenSSL (portable CLI + PKCS#12)

Installs `openssl.exe` next to the Data7 executable, then wraps `pkcs12` export and arbitrary OpenSSL arguments. Combined non-blank stdout+stderr of the last CLI run is `LastOutput`.

### Constructor defaults

| Member | Default |
|---|---|
| `DownloadUrl` | `https://github.com/matheusdevelope/openssl/releases/download/main/openssl.zip` |
| `DownloadTimeoutMs` | `120000` |
| `InstallFolder` | `openssl` |
| `ExeFileName` | `openssl.exe` |
| `ArchiveName` | `OpenSSL.zip` |
| `SearchRecursive` | `True` |
| `DeleteArchive` | `True` (from `TZipPortableExe`) |
| `ZipPath` | `""` |
| `ZipBase64` | `""` |
| `LastOutput` | `""` until a CLI run |

Install path: `TPath.Combine(AppDir(), "openssl", "openssl.exe")`. Archive download path when `ZipPath` is `""`: `TPath.Combine(AppDir(), "OpenSSL.zip")`.

### Own members

| Member | In / out |
|---|---|
| `Path` | get-only alias of `ExePath` (triggers `EnsureExe`) |
| `LastOutput` | get-only; last CLI stdout+stderr joined by `StringList.Text` (`""` before any run / failed start) |

```bas
Function Version() As String
   ' out: Trim(Execute("version"))
End Function

Function ExportCrt(pPfx As String, pPass As String, pOutput As String = "") As String
   ' in: existing PFX; password written to a temp passin file (not argv)
   ' in: pOutput "" / blank → temp "*.crt" and TrackTemp
   ' out: output path
   ' flags: -clcerts -nokeys
End Function

Function ExportKey(pPfx As String, pPass As String, pOutput As String = "") As String
   ' in: same PFX/password/output rules as ExportCrt
   ' in: pOutput "" / blank → temp "*.key" and TrackTemp
   ' out: output path
   ' flags: -nocerts -nodes
End Function

Function Execute(pArgs As String) As String
   ' in: raw openssl argv after the exe (e.g. "version", "pkcs12 -help")
   ' out: LastOutput
   ' throws if process exit code <> 0
End Function

Sub TrackTemp(pPath As String)
   ' in: extra file for Dispose cleanup; "" is a no-op
End Sub
```

`ToString` (special): `BuildLogger("OpenSSL")` with `Path` = `InstalledExePath()` — does **not** call `EnsureExe`, so it can report a path that is not installed yet. `Dispose` (special): `CleanTemps` then parent `Dispose` (`TWinProcess.StopProcess(True)`). `Free` has no extra semantics.

Does not return `NULL`. `Path` / `LastOutput` / export results are strings.

### PKCS#12 phase order

1. `TFile.Exists(pPfx)` — else throw `Exception("PFX not found: " & pPfx)`.
2. `Trim(pOutput)`; if `""`, temp path + `autoOut`.
3. Write `pPass` to a temp secret file (`TPath.GetTempFileName` renamed with prefix `ossp` and `.tmp`) via `Scripting.FileSystemObject.CreateTextFile` (overwrite).
4. `pkcs12 -in "<pfx>" <flags> -passin "file:<secret>" -out "<out>"` (paths via `ArgQuote`: wrap in `"` and double embedded `"`).
5. If exit code `<> 0`, retry the same command with ` -legacy`.
6. Always delete the secret file (including after a caught exception; the original message is rethrown).
7. Exit code still `<> 0` → throw `Exception("openssl pkcs12 failed: " & LastOutput)`.
8. Output file missing → throw `Exception("openssl pkcs12 did not write: " & outPath)`.
9. If `autoOut`, `TrackTemp(outPath)`.
10. Return `outPath`.

`Execute` does **not** retry `-legacy`. It throws `Exception("openssl failed (" & CStr(code) & "): " & LastOutput)`.

CLI capture:

1. `BuildCommand(Trim(pArgs))` → `ExePath.Quoted()` plus args (`EnsureExe` on get of `ExePath`).
2. `TWinProcess.CaptureLines` (pipes, `UseConsole=False` for the spawn).
3. `LastOutput` = `StringList.Text` (blank lines dropped).
4. Exit code = `TWinProcess.ExitCode()`; if `< 0` (start failed / unknown) treat as `1`.

Temp export paths: `TPath.GetTempFileName()` creates a real `TMP*.tmp`, then rename to `pPrefix & nameWithoutExt & pExt` (examples: `crtTMP1234.crt`, `keyTMP1234.key`). Empty `GetTempFileName` → throw `Exception("Could not create temp file")`.

### Install / zip resolution (first `Path` / CLI)

`EnsureExe` (`TZipPortableExe`):

1. `TryReuseExe`: `UsePath` / `ExePath` Set pin, or existing `InstalledExePath` → cache and stop.
2. Zip = `ZipPath` if `<> ""`, else `ResolveDownloadPath()` (`TPath.Combine(AppDir(), ArchiveName)`, here `OpenSSL.zip`).
3. If the zip is missing: write `ZipBase64`, else `DownloadTo` `DownloadUrl`, else throw `Exception("No zip source for openssl.exe: set ZipPath, ZipBase64 or DownloadUrl")`.
4. Zip still missing → `Exception("Zip not found: " & zipPath)`.
5. `AfterDownload`: unzip into the install folder; if `DeleteArchive` and this run created the archive, delete the zip.
6. If `openssl.exe` is not at the target and `SearchRecursive` is `True`, find `openssl.exe` by name (case-insensitive) under the extract tree and `TFile.Copy` onto the target. `SearchRecursive = False` skips the search.
7. Target still missing → `Exception("Executable not found after install: " & target)` or `Exception("openssl.exe not found after extraction.")`.
8. `CacheExePath(target)` (does not pin; unlike Set of `ExePath`).

HTTP download (`WinHttp.WinHttpRequest.5.1`): `GET`, all four timeouts = `DownloadTimeoutMs`. Status `<> 200` → `Exception("Error downloading openssl.exe: " & Status)`. File overwrite mode `2`.

`ResolveDownloadPath` fallback if `ArchiveName` were `""`: `InstallFolder & ".zip"`, else `TPath.ChangeExtension(ExeFileName, ".zip")`.

### Inherited properties (consumer may override)

| Member | Role |
|---|---|
| `ZipPath` | local zip; wins over URL/base64 when the file exists |
| `ZipBase64` | used only if the zip file is missing |
| `ArchiveName` | zip file name under `AppDir()` when `ZipPath` is `""` |
| `SearchRecursive` | look for `ExeFileName` after unzip |
| `DeleteArchive` | delete zip only when this run created it (`ZipBase64` or download) |
| `DownloadUrl` | zip URL |
| `DownloadTimeoutMs` | WinHTTP timeouts (ms) |
| `ExeFileName` / `InstallFolder` | `InstalledExePath`; Set clears cached `ExePath` and the `UsePath` pin |
| `ExeBase64` | unused by zip `EnsureExe` (plain `TPortableExe` only) |
| `ExePath` | get runs `EnsureExe`; set **pins** the path (`TryReuseExe` skips download) |

### Inherited helpers on the instance

```bas
Function AppDir() As String
   ' out: TPath.GetDirectoryName(Data7.NomeArquivoExecutavel())
End Function

Function InstalledExePath() As String
   ' out: TPath.Combine(AppDir, [InstallFolder], ExeFileName)
   '      empty ExeFileName → "portable.exe"
End Function

Sub UsePath(pPath As String)
   ' pin ExePath to an existing file, or SearchPathW on PATH (e.g. "openssl")
   ' "" clears the pin
End Sub

Sub EnsureExe()
   ' zip install if not reused / pinned
End Sub

Function BuildCommand(pArgs As String = "") As String
   ' out: ExePath.Quoted() [& " " & pArgs]
End Function

Overrides Function Start(pCommand As String = "") As Boolean
   ' in: extra openssl args, not a full command line
   ' MyBase.Start(BuildCommand(pCommand))
End Function
```

Live process I/O (`Run`, `CaptureLines`, `PullStdOut*`, `WriteLine`, `WaitOutput`, `UseConsole`, `Visible`, `WorkingDir`, `RunAsAdmin`, `ProcessId`, `LastError`, `StopProcess(pKill As Boolean = True)`) is `TWinProcess`. Prefer `Execute` / `Version` / `ExportCrt` / `ExportKey` for this module. For backends and UAC, read the `mod_win_process` contract.

There is no `GetTempFilePath`, `QuoteArg`, `RunWait`, `StartProcess`, or `ExecReadLines` on `TPortableExe` 2.x.

### Throws / NULL / no-op

| Situation | Behavior |
|---|---|
| Missing PFX | throw `PFX not found: …` |
| `pkcs12` non-zero after `-legacy` | throw `openssl pkcs12 failed: ` + `LastOutput` |
| `pkcs12` did not create the out file | throw `openssl pkcs12 did not write: …` |
| `Execute` non-zero | throw `openssl failed (N): ` + `LastOutput` |
| Temp name API failed | throw `Could not create temp file` |
| No zip source | throw `No zip source for openssl.exe: set ZipPath, ZipBase64 or DownloadUrl` |
| HTTP not 200 | throw `Error downloading openssl.exe: ` + status |
| `TrackTemp("")` | no-op |
| `LastOutput` before any CLI / failed start | `""` |
| `ToString` before install | no throw; path may not exist yet |

---

## Extending (Consumer Project)

No UI. Inherit `OpenSSL` and change install sources in the constructor. There is no `Add` / `Make` / `MakeByName` catalog.

```bas
Imports mod_openssl

Class TPinnedOpenSSL
   Inherits OpenSSL

   Sub New()
      MyBase.New()
      me.ZipPath = "C:\Tools\OpenSSL.zip"   ' local zip; skip GitHub
      me.DeleteArchive = False
   End Sub
End Class
```

To use an already-installed binary instead of the zip:

```bas
_ossl.UsePath("openssl")    ' PATH search
' or _ossl.UsePath("C:\Program Files\OpenSSL-Win64\bin\openssl.exe")
```

Overridable hooks (no bodies here):

| Hook | Purpose |
|---|---|
| `EnsureExe` | install `openssl.exe` if not reused / pinned |
| `ResolveDownloadPath` | zip (or download) destination when `ZipPath` is `""` |
| `AfterDownload` | unzip, optional recursive find, optional zip delete |
| `Start` | prefix extra args with quoted `ExePath` |
| `ToString` | logger line with `InstalledExePath` |
| `Dispose` | delete `TrackTemp` files, then `StopProcess(True)` |

---

## Module Notes

- Constructor pins the GitHub zip URL, `120000` ms timeout, folder `openssl`, exe `openssl.exe`, archive `OpenSSL.zip`, `SearchRecursive = True`.
- First `Path` / `Execute` / `Version` / `Export*` get runs zip `EnsureExe`; `ToString` does not. `UsePath` / Set of `ExePath` pins and skips zip install.
- PKCS#12 password is a `file:` passin temp (FSO text, not UTF-8 `TFile.WriteAllText`), never `-passin pass:`; the file is deleted even on failure.
- Failed `pkcs12` is retried once with ` -legacy`; `Execute` is not.
- `pOutput = ""` → temp + `TrackTemp`; an explicit output path is never deleted by this module.
- `Execute` runs a fresh `TWinProcess.CaptureLines(BuildCommand(...))`; blank lines are dropped from `LastOutput`. `Version` trims it, `Execute` does not. Failed start (`ExitCode < 0`) is reported as `1`.
- `Dispose`/`Free` deletes tracked temps then parent `StopProcess(True)`; passin temps are deleted immediately, not at `Dispose`.
- PKCS#12 paths use `ArgQuote` (double embedded `"`). The exe path in `BuildCommand` uses `String.Quoted()`.
