# mod_camera

Opens a DirectShow capture window, lets the user pick a camera, and returns one still image as a file path or as Base64. It does **not** store the photo in a database, upload it, or decide a business filename — that stays in the consumer.

Version `1.0.0.0`. Dependency (`data7.json`): `mod_portable_exe` `1.0.0.0`. `TCamera` inherits `TPortableExe` and ships an embedded `cam_ds.exe` payload (`ExeFileName` = `mod_camera_cam_ds.exe`).

This file is the module contract. Do not open `.bas` files to use the API; open implementation only to confirm a detail that is not stated here.

## Quick Start (Minimal)

```basic
Imports mod_camera

Dim cam As New TCamera()
cam.Width = 1920                 ' preview/capture width passed to the helper when > 0
cam.Height = 1080                ' preview/capture height passed to the helper when > 0
cam.Quality = 100                ' JPEG quality passed to the helper when > 0
cam.Format = ".jpg"              ' extension used for the output file
cam.Mirror = True                ' start preview mirrored
' cam.OutputPath = "C:\Temp\foto.jpg"   ' optional fixed path; "" = temp file
' cam.OutputAsBase64 = True             ' class-level Base64; default is path

Dim foto As String = cam.Capture()
' Dim foto As String = cam.Capture(True)   ' Base64 for this call only

If foto <> "" Then
   ' path of the image, or Base64 with CR/LF stripped
Else
   ' user closed the form without capturing, or capture failed
End If
cam.Free()
```

## Namespace Map

| File | Namespace | Types |
| --- | --- | --- |
| `src/mod_camera.bas` | `mod_camera` | `TCamera`, `TFormCamera` |

`src/Principal.bas` has no namespace: it is the demo entrypoint (`TCamera.Capture`). There is no `TXxxTests.RunAll`.

Companion (not a Data7 unit): `lib/cam_ds.cpp` / `lib/cam_ds.exe` — native helper whose protocol `TFormCamera` drives. `lib/readme.txt` is the compile/UPX recipe for that helper.

## Capture API

### `TCamera`

Owns capture defaults, materializes the helper via `TPortableExe`, and shows `TFormCamera` until the user captures or closes.

Constructor sets the helper payload and filename, then the capture defaults below. `InstallFolder` is left `""`, so `EnsureExe` writes `AppDir\mod_camera_cam_ds.exe` (see `mod_portable_exe`).

#### Properties

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `Width` | `Integer` | `1920` | Added as `-w` on preview start only when `> 0`. |
| `Height` | `Integer` | `1080` | Added as `-h` on preview start only when `> 0`. |
| `Quality` | `Integer` | `100` | Added as `-q` on preview start only when `> 0`. JPEG encoder quality in the helper. |
| `Mirror` | `Boolean` | `False` | If `True` at preview start, adds `-mirror`. Toggled live by the **Inverter** button (`mirror 1` / `mirror 0`). |
| `Format` | `String` | `".jpg"` | Concatenated as the temp-file extension. Helper encodes by extension: `.jpg` / `.jpeg`, `.png`, `.bmp`. |
| `OutputAsBase64` | `Boolean` | `False` | When `True`, `Capture` returns Base64 instead of a path. Combined with the `Capture` argument via `Or`. |
| `OutputPath` | `String` | `""` | If non-empty, that path is the capture destination. If empty, a temp file is used. |

Inherited from `TPortableExe` and used by this module (full contract is in that dependency): `ExeBase64`, `ExeFileName`, `ExePath`, `EnsureExe`, `IsRunning`, `StartProcess`, `ExecReadLines`, `WriteLine`, `WaitForOutput`, `StopProcess`, `GetTempFilePath`. Constructor assigns `ExeBase64` (embedded PE) and `ExeFileName` = `"mod_camera_cam_ds.exe"`.

#### Methods

```basic
Function Capture(pOutputAsBase64 As Boolean = False) As String
   ' 1. EnsureExe()
   ' 2. New TFormCamera(me), Show() (blocks until the form closes), Free()
   ' 3. if ResultPath = "" → ""
   ' 4. if OutputAsBase64 Or pOutputAsBase64 → FileToBase64(path), strip Char(10) and Char(13);
   '    if OutputPath = "" and the file exists → File.Delete(path)
   ' 5. else → ResultPath
   ' out: file path, Base64 without CR/LF, or "" if cancelled / failed

Function ResolveOutputPath() As String
   ' out: OutputPath when <> ""; else GetTempFilePath("mod_camera_", Format)
   ' example temp: %TEMP%\mod_camera_<GetTempName>.jpg
```

`Capture` does not throw. Helper/IPC failures are `print`ed inside the form; the function still returns `""` if `ResultPath` was never set.

### `TFormCamera`

Modal capture UI used by `TCamera.Capture`. Consumers do not need to construct it.

Footer (left to right): camera combo, **Config**, **Inverter**, **Capturar**. Preview fills the remaining client area. Window caption: `"Captura de Câmera"` (`640`×`560`).

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `ResultPath` | `String` | `""` | Set to the save path only after stdout contains `captured:`. Stays `""` on cancel or error. |

```basic
Sub New(pConfig As TCamera)
   ' in: live TCamera (helper + Width/Height/Quality/Mirror/Format/OutputPath)
   ' ResultPath = ""

Function Show() As Boolean
   ' blocks on Forms.Form.Show
   ' out: always True after the form closes
```

On close, `StopProcess()` is called on `pConfig` (stdin `"exit"`).

## Capture flow

1. `Capture` → `EnsureExe` → if `AppDir\mod_camera_cam_ds.exe` is missing, write the embedded Base64 once (no overwrite if the file already exists).
2. Form `OnShow`: `ExecReadLines("-list")`. Non-empty lines fill the combo. Device index is the integer inside `[` `]` on the selected line; if missing, `0`.
3. List line contract from the helper: `"[%d] %s"` — example: `[0] USB Camera`.
4. Empty list: combo item `"Nenhuma câmera encontrada"`; preview is not started. Combo change is a no-op while that placeholder is item `0`.
5. Preview: `StartProcess("-hwnd {preview.Handle} -d {index}"` plus `-w` / `-h` / `-q` / `-mirror` as above`)`. If already `IsRunning`, stdin `change {index}` instead of a new process.
6. **Config** (running only): stdin `settings`. No-op if the helper is not running. Helper may answer `erro: Esta camera não possui painel nativo de ajustes.`
7. **Inverter** (running only): flips `TCamera.Mirror`, stdin `mirror 1` or `mirror 0`.
8. **Capturar** (running only): stdin `capture {ResolveOutputPath()}`, then `WaitForOutput("captured:", "erro:")`.
   - line contains `captured:` → `ResultPath` = save path, form closes.
   - line contains `erro:` → `print("Erro C++: " & line)`, button caption restored to `"Capturar"`.
   - not running / IPC exception / no matching line → `print("Erro ao tentar capturar o frame.")`.
9. User closing without a successful capture leaves `ResultPath` = `""` → `Capture` returns `""`.

Helper CLI used here: `-list`, `-hwnd`, `-d`, `-w`, `-h`, `-q`, `-mirror`. Stdin: `change`, `settings`, `mirror 1`/`0`, `capture <path>`, `exit`.

## Extending (Consumer Project)

Typical use is `New TCamera()` and `Capture` — no registration table.

```basic
Class TCameraLoja
   Inherits TCamera

   Sub New()
      MyBase.New()
      me.Format = ".png"
      me.OutputPath = "C:\Temp\foto_loja.png"
      me.OutputAsBase64 = False
   End Sub
End Class
```

To change how the helper is materialized, override `EnsureExe` on a `TCamera` subclass (`TPortableExe` hook: reuse existing `InstalledExePath`, otherwise `Base64ToFile`). This module does not override it.

Do not subclass `TFormCamera` unless you replace `Capture`; `TCamera` always constructs `TFormCamera` internally.

## Module Notes

- `Capture("")` sentinel is `""` for both cancel and failed grab; there is no separate error object.
- Base64 vs path: class flag `OutputAsBase64` **or** `Capture(True)`. Either one is enough. Default of both is path.
- Temp capture files (`OutputPath` = `""`) are deleted only when returning Base64. Path mode leaves the file on disk. A non-empty `OutputPath` is never deleted by this module.
- Base64 output is `FileToBase64` with `Char(10)` and `Char(13)` removed (single-line payload).
- `Width` / `Height` / `Quality` of `0` or less are omitted from the helper command line; the helper then uses its own defaults.
- Camera combo values must keep the `[index]` prefix; `_resolveCameraIndex` reads that integer. Lines without brackets become device `0`.
- The helper is reused from `AppDir\mod_camera_cam_ds.exe` after the first `EnsureExe`; changing the embedded payload in source does not rewrite an already-installed file.
- `Principal.bas` exercises path capture with Full HD / quality `100` / `.jpg` / `Mirror = True`. It does not run a test suite.
