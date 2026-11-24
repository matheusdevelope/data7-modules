# mod_portable_exe

Materializes a Windows `.exe` next to the running script (`AppDir[\InstallFolder]\ExeFileName`), reuses it if already present, and runs it.

`TPortableExe` **inherits** `TWinProcess` (`mod_win_process`) and only adds payload install (base64 / `UsePath`). `TRemotePortableExe` / `TZipPortableExe` only change how the payload is obtained (HTTP / zip). Consumers supply the payload and the process protocol. This module does not choose which tool to ship, does not implement HTTP servers, and does not parse tool-specific CLI output.

Execute API (`Start`, `Run`, `CaptureLines`, `PullStdOut*`, `WriteLine`, `UseConsole`, `Visible`, `WorkingDir`, `RunAsAdmin`, …) is inherited. On `TPortableExe` those methods take **extra args only** (`BuildCommand` prefixes `ExePath.Quoted()`). For backends, live `\r` progress, UAC, and I/O semantics, read the **`mod_win_process` README**.

Version `1.0.0.0`. Dependencies (`data7.json`): `mod_io` `1.0.0.0`, `mod_win_process` `1.0.0.0`.

This file is the module contract. Do not open `.bas` files to use the API.

## Quick Start (Minimal)

```basic
Imports mod_portable_exe

Class TMeuRecurso
   Inherits TPortableExe

   Sub New()
      MyBase.New()
      me.ExeBase64 = "TVqQ..."          ' PE bytes as base64
      me.ExeFileName = "meu_recurso.exe" ' file name on disk
      me.InstallFolder = "meu_recurso"   ' subfolder under AppDir
   End Sub
End Class

Dim exe As New TMeuRecurso()
exe.EnsureExe()                          ' write once; later calls reuse the file
Dim linhas As StringList = exe.CaptureLines("-list")
' ... use linhas ...
linhas.Free()

exe.UseConsole = False                   ' pipes: stdin + line protocol (see mod_win_process)
If exe.Start() Then
   Dim ready As String = exe.WaitOutput("ready")
   exe.WriteLine("ping")
   Dim pong As String = exe.WaitOutput("pong")
   exe.StopProcess()
End If
exe.Free()
```

## Namespace Map

| File | Namespace | Types |
| --- | --- | --- |
| `src/mod_portable_exe.bas` | `mod_portable_exe` | `TPortableExe` |
| `src/mod_remote_exe.bas` | `mod_remote_exe` | `TRemotePortableExe` |
| `src/mod_zip_exe.bas` | `mod_zip_exe` | `TZipPortableExe` |
| `src/tests/mod_portable_exe_tests.bas` | `mod_portable_exe_tests` | `TPortableExeSuite` (plus test fixtures) |

Inheritance: `TWinProcess` (`mod_win_process`) → `TPortableExe` → `TRemotePortableExe` → `TZipPortableExe`.

## `TPortableExe`

Owns install path and optional base64 materialization. One instance, one child at a time. `Start` / `Run` / `CaptureLines` take **args**, not a full command line. `Run` / `CaptureLines` are not redeclared: they call `Start`, so they also get `EnsureExe` + quoted `ExePath`.

`Dispose` (via `Free`) is `TWinProcess.Dispose` (`StopProcess(True)`). Leaving a process running after `Free` is not supported.

### Properties

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `ExeBase64` | `String` | `""` | PE payload. Setter clears cached `ExePath`. |
| `ExeFileName` | `String` | `""` | Disk name. Empty → `"portable.exe"` in `InstalledExePath`. Setter clears cached `ExePath`. |
| `InstallFolder` | `String` | `""` | Single-segment subfolder of `AppDir`. Empty → file goes in `AppDir` itself. Setter clears cached `ExePath`. |
| `ExePath` | `String` | `""` | **Get** calls `EnsureExe()` then returns the resolved path. **Set** stores the path without ensuring. |

Inherited execute properties and methods: see `mod_win_process` (`UseConsole`, `Visible`, `WorkingDir`, `RunAsAdmin`, `PullStdOut*`, `ProcessId`, `LastError`, …).

### Path helpers

```basic
Function AppDir() As String
   ' in:  Data7.NomeArquivoExecutavel()
   ' out: directory of the running script (e.g. C:\Data7\bin)

Function InstalledExePath() As String
   ' out: TPath.Combine(AppDir, [InstallFolder], ExeFileName)
   '      ExeFileName "" → "portable.exe"
   ' example: C:\Data7\bin\ffmpeg\ffmpeg.exe

Sub UsePath(pPath As String)
   ' pin ExePath to an existing file (no base64/download/zip install)
   ' if pPath is not a file, SearchPathW on PATH (e.g. "dbbackup")
   ' later Get of ExePath skips EnsureExe materialize
```

### Materialize

```basic
Overridable Sub EnsureExe()
   ' 1. TryReuseExe: UsePath pin, or existing InstalledExePath → cache and return
   ' 2. EnsureDirectory(parent of target)
   ' 3. if ExeBase64 <> "" → Base64ToFile(ExeBase64, target)
   ' 4. cache ExePath even if the file still does not exist

Protected Function TryReuseExe() As Boolean
   ' True if UsePath pinned the path, or InstalledExePath already exists

Protected Sub CacheExePath(pPath As String)
   ' set _exePath without pinning (unlike Set of ExePath)

Protected Sub EnsureDirectory(pFolder As String)
   ' no-op if pFolder = ""
   ' CreateDirectory only if TDirectory.Exists is false (not recursive)
```

Does not throw when `ExeBase64` is empty. Does not overwrite an existing install.

### Command line

```basic
Function BuildCommand(pArgs As String = "") As String
   ' out: ExePath.Quoted() plus " " & pArgs when Trim(pArgs) <> ""
   ' Get of ExePath triggers EnsureExe
   ' example: "C:\Data7\bin\tool\tool.exe" -list

Overrides Function Start(pCommand As String = "") As Boolean
   ' MyBase.Start(BuildCommand(pCommand))
   ' pCommand is extra args, not a full command line
```

## `TRemotePortableExe`

Inherits `TPortableExe`. Downloads a file with WinHttp when the installed exe is missing.

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `DownloadUrl` | `String` | `""` | HTTP GET URL. Example: `"https://exemplo.com/ffmpeg.exe"` |
| `DownloadTimeoutMs` | `Integer` | `8000` | Passed to all four WinHttp timeouts (resolve, connect, send, receive). |

```basic
Overridable Function ResolveDownloadPath() As String
   ' out: InstalledExePath() unless overridden

Overridable Sub AfterDownload(pDownloaded As String, pTarget As String)
   ' copy pDownloaded → pTarget when LCase paths differ and source exists

Overrides Sub EnsureExe()
   ' 1. TryReuseExe (UsePath pin or existing install) → return
   ' 2. if DownloadUrl = "" → Throw "DownloadUrl is empty for " & ExeFileName
   ' 3. ResolveDownloadPath; EnsureDirectory for target and download dirs
   ' 4. DownloadTo(downloaded); AfterDownload(downloaded, target)
   ' 5. if target still missing → Throw "Executable not found after install: " & target
   ' 6. CacheExePath(target)

Protected Sub DownloadTo(pDest As String)
   ' WinHttp.WinHttpRequest.5.1 GET DownloadUrl (synchronous)
   ' Status <> 200 → Throw "Error downloading " & ExeFileName & ": " & Status
   ' ADODB.Stream Type=1 SaveToFile(pDest, 2)
```

## `TZipPortableExe`

Inherits `TRemotePortableExe`. Obtains a zip, unzips into the install folder, then locates `ExeFileName`.

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `ZipPath` | `String` | `""` | Existing zip on disk. Example: `"C:\Temp\ffmpeg.zip"` |
| `ZipBase64` | `String` | `""` | Zip bytes as base64. Example prefix: `"UEsD..."` |
| `ArchiveName` | `String` | `""` | File name (under `AppDir`) for a zip this instance creates. Example: `"ffmpeg.zip"` |
| `SearchRecursive` | `Boolean` | `True` | After unzip, search subfolders for `ExeFileName` if it is not at `InstalledExePath`. |
| `DeleteArchive` | `Boolean` | `True` | Delete the zip **only if this `EnsureExe` created it** (`ZipBase64` write or `DownloadUrl`). An existing `ZipPath` is never deleted. |

```basic
Function ResolveZipPath() As String
   ' if ZipPath <> "" → ZipPath
   ' else ResolveDownloadPath()   (AppDir\archive name)
```

`ResolveDownloadPath` archive name:

1. `ArchiveName` if not `""`. Example: `"ffmpeg.zip"` → `AppDir\ffmpeg.zip`
2. else if `InstallFolder` not `""` → `InstallFolder & ".zip"`. Example: `"ffmpeg"` → `AppDir\ffmpeg.zip`
3. else `ExeFileName` with trailing `.exe` replaced by `.zip`, or `& ".zip"`. Example: `"ffmpeg.exe"` → `AppDir\ffmpeg.zip`

```basic
Overrides Sub EnsureExe()
   ' 1. TryReuseExe (UsePath pin or existing install) → return
   ' 2. zipPath = ResolveZipPath(); mark not-created
   ' 3. if zipPath missing:
   '      EnsureDirectory(parent)
   '      ZipBase64 <> "" → Base64ToFile, mark created
   '      else DownloadUrl <> "" → DownloadTo, mark created
   '      else Throw "No zip source for " & ExeFileName & ": set ZipPath, ZipBase64 or DownloadUrl"
   ' 4. if zip still missing → Throw "Zip not found: " & zipPath
   ' 5. EnsureDirectory(parent of target); AfterDownload(zipPath, target)
   ' 6. if target missing → Throw "Executable not found after install: " & target
   ' 7. CacheExePath(target)

Overrides Sub AfterDownload(pDownloaded As String, pTarget As String)
   ' 1. Unzip pDownloaded into ExtractDir(pTarget) via IO.File.ZipFile.Unzip
   ' 2. if DeleteArchive And this run created the archive → IO.File.Delete(pDownloaded)
   ' 3. if pTarget exists → done
   ' 4. if not SearchRecursive → return (caller EnsureExe may still throw)
   ' 5. recursive FindFile(extractDir, ExeFileName) case-insensitive ExtractName
   ' 6. "" → Throw ExeFileName & " not found after extraction."
   ' 7. TFile.Copy(found, pTarget, True)
```

Source priority when the zip file is not already on disk: **`ZipBase64` then `DownloadUrl`**. If `ZipPath` points at a file that already exists, that file is used and is not deleted.

## Extending (Consumer Project)

Inherit the class that matches the payload, set properties in `Sub New`, then call `EnsureExe` / the inherited process APIs.

```basic
' Direct HTTP .exe
Imports mod_remote_exe
Class TFfmpeg
   Inherits TRemotePortableExe
   Sub New()
      MyBase.New()
      me.DownloadUrl = "https://exemplo.com/ffmpeg.exe"
      me.ExeFileName = "ffmpeg.exe"
      me.InstallFolder = "ffmpeg"
      me.DownloadTimeoutMs = 120000
   End Sub
End Class

' Zip from URL, local path, or base64
Imports mod_zip_exe
Class TFfmpegZip
   Inherits TZipPortableExe
   Sub New()
      MyBase.New()
      me.DownloadUrl = "https://exemplo.com/ffmpeg.zip"
      ' or me.ZipPath = "C:\Temp\ffmpeg.zip"
      ' or me.ZipBase64 = "UEsD..."
      me.ExeFileName = "ffmpeg.exe"
      me.InstallFolder = "ffmpeg"
      me.ArchiveName = "ffmpeg.zip"
   End Sub
End Class
```

Override `EnsureExe`, `ResolveDownloadPath`, or `AfterDownload` only when the default install/copy/unzip is not enough. `InstallFolder` must be a single path segment (`TDirectory.CreateDirectory` is not recursive).

No UI types in this module.

## Tests

`src/Principal.bas` runs `TPortableExeSuite.Run()`.

- **local:** migrate to `AppDir\_pex_local`, `BuildCommand`, `Run` / `CaptureLines` / `Start` + stdout, pipes IPC, inherited `ProcessId` / `CommandLine` / `ProcessKind`, `UsePath` (file and PATH), default `portable.exe`, empty `ExeBase64`, `InstallFolder` change, failed `Start` (`LastError`)
- **remote:** path helpers, empty `DownloadUrl` throw, cached install + IPC, `UsePath` skip-download
- **zip:** missing-source throw, `ZipPath` / `ZipBase64` / `DeleteArchive=False`, cached extract, `UsePath` skip-unzip, live `DownloadUrl` `https://curl.se/windows/latest.cgi?p=win64-mingw.zip` locating nested `curl.exe`

Does not click through UAC or open a visible window. Engine-only cases live in `mod_win_process`.

## Module Notes

- Install is sticky: if `InstalledExePath` already exists, `EnsureExe` does not rewrite, re-download, or re-unzip.
- Changing `ExeBase64`, `ExeFileName`, or `InstallFolder` clears the cached `ExePath`; the next Get / `EnsureExe` resolves again (still skip-if-exists).
- `InstallFolder` is one segment only (`"ffmpeg"`, `"_pex_local"`). Nested folders are not created.
- `CaptureLines` returns a new `StringList`; the caller must `Free` it. Blank lines are dropped.
- `DeleteArchive` applies only to a zip this instance created in the current `EnsureExe`. A pre-existing `ZipPath` stays on disk even when `DeleteArchive` is `True`.
- Zip obtain order: existing file at `ResolveZipPath` → else `ZipBase64` → else `DownloadUrl`.
- `DownloadTimeoutMs` default `8000` is often too low for multi-MB zips; consumers should raise it (tests use `120000` for curl.se).
- `TRemotePortableExe` / `TZipPortableExe` `EnsureExe` must call `TryReuseExe()` so `UsePath` is honored. Cache with `CacheExePath`, not `ExePath =` (that pins).
