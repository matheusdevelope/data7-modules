# mod_portable_exe

Materializes a Windows `.exe` next to the running script (`AppDir[\InstallFolder]\ExeFileName`), reuses it if already present, and runs it (wait, capture stdout, or stdin/stdout IPC). Consumers supply the payload (`ExeBase64`, `DownloadUrl`, `ZipPath` / `ZipBase64`) and the process protocol. This module does not choose which tool to ship, does not implement HTTP servers, and does not parse tool-specific CLI output.

Version `1.0.0.0`. Dependency: `mod_io` `1.0.0.0` (`data7.json`).

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
Dim linhas As StringList = exe.ExecReadLines("-list")  ' run, capture non-empty stdout lines
' ... use linhas ...
linhas.Free()
If exe.StartProcess() Then               ' WScript.Exec, stdin/stdout IPC
   Dim ready As String = exe.WaitForOutput("ready")
   exe.WriteLine("ping")
   Dim pong As String = exe.WaitForOutput("pong")
   exe.StopProcess()                     ' default stdin line: "exit"
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

Inheritance: `TPortableExe` → `TRemotePortableExe` → `TZipPortableExe`.

## Local exe (base64 + process)

### `TPortableExe`

Owns install path, optional base64 materialization, and process I/O.

#### Properties

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `ExeBase64` | `String` | `""` | PE payload. Setter clears cached `ExePath`. |
| `ExeFileName` | `String` | `""` | Disk name. Empty → `"portable.exe"` in `InstalledExePath`. Setter clears cached `ExePath`. |
| `InstallFolder` | `String` | `""` | Single-segment subfolder of `AppDir`. Empty → file goes in `AppDir` itself. Setter clears cached `ExePath`. |
| `ExePath` | `String` | `""` | **Get** calls `EnsureExe()` then returns the resolved path. **Set** stores the path without ensuring. |

#### Path helpers

```basic
Function AppDir() As String
   ' in:  Data7.NomeArquivoExecutavel()
   ' out: directory of the running script (e.g. C:\Data7\bin)

Function InstalledExePath() As String
   ' out: AppDir[\InstallFolder]\ExeFileName
   '      ExeFileName "" → "portable.exe"
   ' example: C:\Data7\bin\ffmpeg\ffmpeg.exe

Function GetTempFolder() As String
   ' out: Windows user temp (Scripting.FileSystemObject special folder 2)
   ' not used as the portable-exe install location

Function GetTempFilePath(pPrefix As String = "", pExtension As String = "") As String
   ' out: tempFolder\pPrefix + GetTempName + pExtension
   ' example: GetTempFilePath("pex_test_", ".zip")
```

#### Materialize

```basic
Overridable Sub EnsureExe()
   ' 1. target = InstalledExePath()
   ' 2. if file exists → cache ExePath and return (no rewrite)
   ' 3. EnsureDirectory(parent of target)
   ' 4. if ExeBase64 <> "" → Base64ToFile(ExeBase64, target)
   ' 5. cache ExePath even if the file still does not exist

Protected Sub EnsureDirectory(pFolder As String)
   ' no-op if pFolder = ""
   ' CreateDirectory only if TDirectory.Exists is false (not recursive)
```

Does not throw when `ExeBase64` is empty. Does not overwrite an existing install.

#### Command line

```basic
Function QuoteArg(pValue As String) As String
   ' out: "pValue"  (always wrapped in ASCII 34)
   ' example: QuoteArg("ab") → "ab" with quotes

Function BuildCommand(pArgs As String = "") As String
   ' out: QuoteArg(ExePath) plus " " & pArgs when Trim(pArgs) <> ""
   ' Get of ExePath triggers EnsureExe
   ' example: "C:\Data7\bin\tool\tool.exe" -list
```

#### Run (no IPC)

```basic
Function RunWait(pArgs As String = "") As Integer
   ' EnsureExe, then WScript.Shell.Run(BuildCommand(pArgs), 0, True)
   ' out: process exit code

Function ExecReadLines(pArgs As String = "") As StringList
   ' EnsureExe; run via cmd.exe /s /c "BuildCommand > temp.txt 2>&1"
   ' skip Trim="" lines; delete temp file
   ' out: new StringList — caller Free()s it
```

#### IPC (stdin / stdout)

`IsRunning` is `False` when no process is held; otherwise `WScript.Exec.Status = 0` (running).

```basic
Function StartProcess(pArgs As String = "") As Boolean
   ' EnsureExe; WScript.Shell.Exec(BuildCommand(pArgs))
   ' out: IsRunning()

Function WriteLine(pCommand As String) As Boolean
   ' out: False if not running; else StdIn.WriteLine, True

Function ReadLine() As String
   ' out: "" if not running or StdOut.AtEndOfStream; else one line

Function WaitForOutput(pSuccessToken As String, pErrorToken As String = "") As String
   ' blocking read of StdOut until a line contains pSuccessToken
   ' if pErrorToken <> "", a line containing it also returns
   ' out: matching line, or "" if not running / stream ends with no match
   ' example tokens used by the bundled test exe: "ready", "pong", "echo:"

Sub StopProcess(pExitCommand As String = "exit")
   ' no-op if no process
   ' if pExitCommand <> "" writes it to StdIn (errors swallowed)
   ' drops the process reference (does not wait for exit)
```

`Dispose` (via `Free`) calls `StopProcess()` with default `"exit"` and releases the shell. Special: leaving a process running after `Free` is not supported.

## Remote download

### `TRemotePortableExe`

Inherits `TPortableExe`. Downloads a file with WinHttp when the installed exe is missing.

#### Properties

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `DownloadUrl` | `String` | `""` | HTTP GET URL. Example: `"https://exemplo.com/ffmpeg.exe"` |
| `DownloadTimeoutMs` | `Integer` | `8000` | Passed to all four WinHttp timeouts (resolve, connect, send, receive). |

Inherited: `ExeFileName`, `InstallFolder`, `ExePath`, process APIs.

#### Overridable hooks

| Hook | Purpose |
| --- | --- |
| `ResolveDownloadPath()` | Destination of the HTTP body. Default: `InstalledExePath()`. |
| `AfterDownload(pDownloaded, pTarget)` | Post-download. Default: `TFile.Copy` when paths differ (case-insensitive) and `pDownloaded` exists. |
| `EnsureExe()` | Install-or-reuse (see flow). |

```basic
Overridable Function ResolveDownloadPath() As String
   ' out: InstalledExePath() unless overridden

Overridable Sub AfterDownload(pDownloaded As String, pTarget As String)
   ' copy pDownloaded → pTarget when LCase paths differ and source exists

Overrides Sub EnsureExe()
   ' 1. if InstalledExePath exists → ExePath = target, return
   ' 2. if DownloadUrl = "" → Throw "DownloadUrl is empty for " & ExeFileName
   ' 3. ResolveDownloadPath; EnsureDirectory for target and download dirs
   ' 4. DownloadTo(downloaded); AfterDownload(downloaded, target)
   ' 5. if target still missing → Throw "Executable not found after install: " & target
   ' 6. ExePath = target

Protected Sub DownloadTo(pDest As String)
   ' WinHttp.WinHttpRequest.5.1 GET DownloadUrl (synchronous)
   ' Status <> 200 → Throw "Error downloading " & ExeFileName & ": " & Status
   ' ADODB.Stream Type=1 SaveToFile(pDest, 2)
```

## Zip extract

### `TZipPortableExe`

Inherits `TRemotePortableExe`. Obtains a zip, unzips into the install folder, then locates `ExeFileName`.

#### Properties

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `ZipPath` | `String` | `""` | Existing zip on disk. Example: `"C:\Temp\ffmpeg.zip"` |
| `ZipBase64` | `String` | `""` | Zip bytes as base64. Example prefix: `"UEsD..."` |
| `ArchiveName` | `String` | `""` | File name (under `AppDir`) for a zip this instance creates. Example: `"ffmpeg.zip"` |
| `SearchRecursive` | `Boolean` | `True` | After unzip, search subfolders for `ExeFileName` if it is not at `InstalledExePath`. |
| `DeleteArchive` | `Boolean` | `True` | Delete the zip **only if this `EnsureExe` created it** (`ZipBase64` write or `DownloadUrl`). An existing `ZipPath` is never deleted. |

Inherited: `DownloadUrl`, `DownloadTimeoutMs`, `ExeFileName`, `InstallFolder`, process APIs.

#### Zip location

```basic
Function ResolveZipPath() As String
   ' if ZipPath <> "" → ZipPath
   ' else ResolveDownloadPath()   (AppDir\archive name)
```

`ResolveDownloadPath` (override) archive name:

1. `ArchiveName` if not `""`. Example: `"ffmpeg.zip"` → `AppDir\ffmpeg.zip`
2. else if `InstallFolder` not `""` → `InstallFolder & ".zip"`. Example: `"ffmpeg"` → `AppDir\ffmpeg.zip`
3. else `ExeFileName` with trailing `.exe` replaced by `.zip`, or `& ".zip"`. Example: `"ffmpeg.exe"` → `AppDir\ffmpeg.zip`

#### Install flow

```basic
Overrides Sub EnsureExe()
   ' 1. if InstalledExePath exists → ExePath = target, return
   ' 2. zipPath = ResolveZipPath(); mark not-created
   ' 3. if zipPath missing:
   '      EnsureDirectory(parent)
   '      ZipBase64 <> "" → Base64ToFile, mark created
   '      else DownloadUrl <> "" → DownloadTo, mark created
   '      else Throw "No zip source for " & ExeFileName & ": set ZipPath, ZipBase64 or DownloadUrl"
   ' 4. if zip still missing → Throw "Zip not found: " & zipPath
   ' 5. EnsureDirectory(parent of target); AfterDownload(zipPath, target)
   ' 6. if target missing → Throw "Executable not found after install: " & target
   ' 7. ExePath = target

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

Inherit the class that matches the payload, set properties in `Sub New`, then call `EnsureExe` / process APIs.

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

`src/Principal.bas` constructs `TPortableExeSuite` and calls `Run()`.

`TPortableExeSuite.Run()` covers: local migrate to `AppDir\_pex_local`, `QuoteArg` / `BuildCommand`, `RunWait("-list")`, `ExecReadLines("-list")`, IPC (`ready` / `ping` / `echo`), `IsRunning` after stop; remote path helpers, empty `DownloadUrl` throw, cached install + IPC; zip missing-source throw, `ZipPath` extract (archive kept), `ZipBase64` extract (generated zip deleted), `DeleteArchive=False` + `ArchiveName`, cached extract, live `DownloadUrl` `https://curl.se/windows/latest.cgi?p=win64-mingw.zip` locating nested `curl.exe`.

## Module Notes

- Install is sticky: if `InstalledExePath` already exists, `EnsureExe` does not rewrite, re-download, or re-unzip.
- Changing `ExeBase64`, `ExeFileName`, or `InstallFolder` clears the cached `ExePath`; the next Get / `EnsureExe` resolves again (still skip-if-exists).
- `InstallFolder` is one segment only (`"ffmpeg"`, `"_pex_local"`). Nested folders are not created.
- `ExecReadLines` returns a new `StringList`; the caller must `Free` it. Blank lines are dropped.
- `DeleteArchive` applies only to a zip this instance created in the current `EnsureExe`. A pre-existing `ZipPath` stays on disk even when `DeleteArchive` is `True`.
- Zip obtain order: existing file at `ResolveZipPath` → else `ZipBase64` → else `DownloadUrl`.
- `DownloadTimeoutMs` default `8000` is often too low for multi-MB zips; consumers should raise it (tests use `120000` for curl.se).
- `StopProcess` does not wait for the child to exit; `IsRunning` becomes `False` as soon as the `Exec` object is dropped.
