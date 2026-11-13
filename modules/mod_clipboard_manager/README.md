# mod_clipboard_manager

Windows clipboard façade for Data7: Unicode text, `CF_BITMAP` images, and Explorer file lists (`CF_HDROP`). It does **not** watch clipboard changes, keep history, pick which path or image to copy, or own a form — that stays in the consumer.

Version: `1.0.0.0`. Dependencies (`data7.json`): none.

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to confirm a detail that is not stated here.

---

## Quick Start (Minimal)

```bas
Imports mod_clipboard_manager
Imports Collections

ClipboardManager.Clear()                                    ' wipe every format currently on the clipboard

If ClipboardManager.SetText("Olá, Data7! ÁÉÍÓÚ çÇ") Then    ' write CF_UNICODETEXT (replaces all other formats)
   Print(ClipboardManager.GetText())                        ' read CF_UNICODETEXT; "" if that format is missing
End If

Dim files As New StringList()
files.Add("C:\temp\Data7_Teste1.txt")                       ' absolute path the Explorer paste target will receive
files.Add("C:\temp\Data7_Teste2.txt")
If ClipboardManager.SetFiles(files) Then                    ' write CF_HDROP (Unicode DROPFILES)
   Dim copied As StringList = ClipboardManager.GetFiles()   ' always a list; consumer owns it
   Print(copied.Count)
   copied.Free()
End If
files.Free()

If ClipboardManager.SetImageFromFile("C:\temp\logo.jpg") Then  ' GDI+ load → CF_BITMAP (white background)
   If ClipboardManager.HasImage() Then
      ClipboardManager.GetImageAsFile("C:\temp\logo-out.png")  ' encoder from path: .jpg/.jpeg, .bmp, else PNG
      Dim b64 As String = ClipboardManager.GetImageAsBase64()  ' PNG temp → Base64 with CR/LF stripped
      ClipboardManager.SetImageFromBase64(b64)                 ' Base64 → temp .png → CF_BITMAP
   End If
End If
```

`Set*` Boolean `False` = clipboard was not updated. `GetText` / `GetImageAsBase64` miss sentinel is `""`. `GetFiles` miss is an empty `StringList`, never `NULL`.

---

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_clipboard_manager.bas` | `mod_clipboard_manager` | `ClipboardManager` |

`src/Principal.bas` declares no namespace: smoke of `Clear` / `SetText` / `GetText`, `SetImageFromFile` / `HasImage` / `GetImageAsFile` / `GetImageAsBase64` / `SetImageFromBase64`, and `SetFiles` / `HasFiles` / `GetFiles`. There is no `TXxxTests.RunAll`. Image smoke is skipped when the hardcoded source file is missing.

The unit `Imports Collections` because `SetFiles` / `GetFiles` use `StringList`.

---

## Façade (`ClipboardManager`)

Shared Win32 clipboard helpers. Do not instantiate `ClipboardManager` for these calls.

Every `Set*` opens the clipboard with owner HWND `0`, calls `EmptyClipboard` (all previous formats are discarded), then writes one or two formats. `Clear` is the same wipe without a following write.

Formats used (not exported as public constants):

| Format | Win32 | Used by |
|---|---|---|
| Unicode text | `CF_UNICODETEXT` (13) | `HasText`, `SetText`, `GetText` |
| ANSI text | `CF_TEXT` (1) | `HasText` only — `GetText` does **not** read it |
| Bitmap | `CF_BITMAP` (2) | `HasImage`, `SetImageFromFile`, `SetImageFromBase64`, `SetImageAndFile`, `GetImageAsFile`, `GetImageAsBase64` |
| File drop | `CF_HDROP` (15) | `HasFiles`, `GetFiles`, `SetFiles`, `SetImageAndFile` |

Does not throw. Does not return `NULL`. Failed `OpenClipboard` / alloc / `SetClipboardData` → `False` or `""` / empty list.

---

## Text

`HasText` is true if **either** Unicode or ANSI text is on the clipboard. `GetText` reads **only** Unicode.

```bas
Shared Function HasText() As Boolean
   ' out: True if CF_UNICODETEXT or CF_TEXT is available
End Function

Shared Function SetText(pText As String) As Boolean
   ' in: any string, including "" (still writes a Unicode buffer with a null terminator)
   ' 1. GlobalAlloc Unicode bytes (Len+1)*2, GMEM_MOVEABLE
   ' 2. EmptyClipboard
   ' 3. SetClipboardData CF_UNICODETEXT
   ' out: True iff SetClipboardData succeeded
End Function

Shared Function GetText() As String
   ' 1. require CF_UNICODETEXT (CF_TEXT-only clipboard → "")
   ' 2. lock handle, copy, cut at first Chr(0)
   ' out: clipboard Unicode text, or ""
End Function
```

---

## Files (`CF_HDROP`)

Explorer-style file list. Paths are Unicode (`DROPFILES.fWide = 1`). `SetFiles` `Trim`s each entry and skips `""` after trim.

```bas
Shared Function HasFiles() As Boolean
   ' out: True if CF_HDROP is available
End Function

Shared Function GetFiles() As StringList
   ' out: always a new StringList (empty if format missing, open fails, or handle is 0)
   ' 1. DragQueryFileW(hDrop, -1) → count
   ' 2. each path: buffer Space(512), cch=512; add Left(buffer, pathLen) when pathLen > 0
   ' consumer owns the list (Free it)
End Function

Shared Function SetFiles(pFiles As StringList) As Boolean
   ' in: list of absolute paths, e.g. "C:\temp\Data7_Teste1.txt"
   ' False immediately if Not Assigned(pFiles) or pFiles.Count = 0
   ' 1. size DROPFILES (20 bytes) + Unicode paths + double-null terminator
   ' 2. EmptyClipboard
   ' 3. SetClipboardData CF_HDROP
   ' out: True iff SetClipboardData succeeded
End Function
```

`GetFiles` path buffer is 512 characters. Longer Explorer paths are truncated by that buffer.

---

## Images (`CF_BITMAP`)

GDI+ load/save. Bitmap conversion uses background `-1` (white) so the alpha channel does not break paste into MS Paint. `CopyImage` is used to purify the HBITMAP before `SetClipboardData`.

```bas
Shared Function HasImage() As Boolean
   ' out: True if CF_BITMAP is available
End Function

Shared Function SetImageFromFile(pFilePath As String) As Boolean
   ' in: path GDI+ can load (e.g. "C:\temp\logo.jpg")
   ' no File.Exists check — load failure → False
   ' 1. GdiplusStartup / GdipLoadImageFromFile
   ' 2. HBITMAP with white background (-1), CopyImage
   ' 3. EmptyClipboard, SetClipboardData CF_BITMAP
   ' out: True iff SetClipboardData succeeded
End Function

Shared Function GetImageAsFile(pFilePath As String) As Boolean
   ' in: destination path; encoder is chosen from LCase(pFilePath) via InStr (not a parsed extension)
   '   ".jpg" or ".jpeg" → JPEG encoder
   '   else ".bmp" → BMP encoder
   '   else → PNG encoder (".png" and any other string, including no extension)
   ' 1. require CF_BITMAP
   ' 2. GdipCreateBitmapFromHBITMAP, GdipSaveImageToFile
   ' out: True iff save returned 0
End Function

Shared Function SetImageFromBase64(pBase64 As String) As Boolean
   ' 1. Base64ToFile into a temp *.png under the Windows temp folder
   ' 2. SetImageFromFile(temp)
   ' 3. IO.File.Delete(temp)
   ' out: SetImageFromFile result
End Function

Shared Function GetImageAsBase64() As String
   ' 1. GetImageAsFile(temp *.png) → PNG encoder (temp name always ends with ".png")
   ' 2. if the temp file exists → FileToBase64, strip Chr(10) and Chr(13)
   ' 3. IO.File.Delete(temp)
   ' out: single-line Base64, or "" if save failed
End Function
```

Encoder detection is a substring of the **full** lowercased path, in this order:

```text
C:\temp\logo.jpg          → JPEG
C:\temp\logo.jpeg         → JPEG
C:\temp\logo.bmp          → BMP
C:\temp\logo.png          → PNG
C:\temp\logo-out          → PNG (default)
C:\photos.jpg\file.png    → JPEG (".jpg" matches first)
```

Temp files for Base64 helpers: `Scripting.FileSystemObject` `GetSpecialFolder(2)` + `\` + `GetTempName` + `.png` (Windows temp folder, always `.png`).

---

## Image and file together

Puts the same disk path on the clipboard as both a bitmap (when GDI+ can load it) and a one-entry file drop, so paste targets can take pixels **or** the file.

```bas
Shared Function SetImageAndFile(pFilePath As String) As Boolean
   ' in: existing file path (Trim); "" or missing file → False (IO.File.Exists)
   ' 1. try GDI+ → CF_BITMAP (same white-background / CopyImage path as SetImageFromFile)
   ' 2. always build CF_HDROP for that single path
   ' 3. EmptyClipboard; set bitmap if loaded; set HDROP if alloc succeeded
   ' out: True if at least one of the two SetClipboardData calls succeeded
End Function
```

GDI+ failure with an existing file can still return `True` (HDROP only). Bitmap-only success is also `True`.

---

## Clear

```bas
Shared Sub Clear()
   ' OpenClipboard(0) → EmptyClipboard → CloseClipboard
   ' no-op if OpenClipboard fails
End Sub
```

---

## Extending (Consumer Project)

There is no `Add` / `Make` / `MakeByName` catalog and no overridable hooks. Call `ClipboardManager.*` as Shared methods.

This module has no Data7 forms. Choosing paths, Base64 payloads, and when to `Clear` stays in the consuming project. Subclassing `ClipboardManager` does not replace the Shared entry points.

```bas
Imports mod_clipboard_manager
Imports Collections

' Typical consumer: import and call. No registration.
ClipboardManager.SetText("pedido 123")
```

---

## Module Notes

- Useful APIs are Shared; `New ClipboardManager` is unnecessary. `GetFiles` always allocates a `StringList` — the consumer `Free`s it.
- Every `Set*` empties the clipboard first. Writing text drops a previous bitmap/file list, and vice versa. Only `SetImageAndFile` plants two formats in one call (`CF_BITMAP` + `CF_HDROP`).
- `HasText` can be `True` for ANSI-only (`CF_TEXT`) content while `GetText` returns `""` (Unicode-only reader).
- `GetText` / `GetImageAsBase64` miss = `""`. `GetFiles` miss = empty list. `Set*` / `GetImageAsFile` miss = `False`. Nothing in this module returns `NULL` or raises a typed exception.
- Image Base64 is always round-tripped through a temp `.png` (PNG encoder on get). CR/LF are stripped from `GetImageAsBase64`.
- `SetFiles` rejects `NULL`/unassigned lists and `Count = 0`; blank trimmed paths inside a non-empty list are skipped. `SetImageAndFile` rejects `""` and missing files; `SetImageFromFile` does not pre-check existence.
- Canonical smoke: `src/Principal.bas` (`TestTextAndImage`, `TestFiles`). There is no `TXxxTests.RunAll` suite.
