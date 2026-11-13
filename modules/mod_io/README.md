# mod_io

Windows disk I/O and native dialogs for Data7: paths, files, directories, and file/folder pickers. It does not validate business rules, create directory trees, list recursively, or pick an encoding — that stays in the consumer.

Version: `1.0.0.0`. Dependencies (`data7.json`): none.

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## How to use (minimum)

```bas
Dim _initDir As String = TDirectory.GetCurrentDirectory()   ' process current directory
Dim _filter As String = "Text Files (*.txt)|*.txt"          ' dialog description|mask
Dim _file As String = TDialogs.OpenFile("Select a File", _filter, _initDir)
If _file <> "" Then                                         ' "" = cancelled
    Dim _content As String = TFile.ReadAllText(_file)       ' UTF-8
    TFile.WriteAllText(_file, _content)                     ' overwrite the same file
End If

Dim _path As String = TDialogs.SaveFile("Select a File", _filter, _initDir, "*.txt")
If _path <> "" Then                                         ' "" = cancelled
    TFile.WriteAllText(_path, "Hello, World!")
End If
```

Cancel sentinel for single-file/folder dialogs: `""`. `OpenFiles` returns an empty list, not `""`.

---

## Namespace map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_tdialogs.bas` | `TDialogs` | functions (no class) |
| `src/lib/mod_tfile.bas` | `TFile` | functions (no class) |
| `src/lib/mod_tpath.bas` | `TPath` | functions (no class) |
| `src/lib/mod_tdirectory.bas` | `TDirectory` | functions (no class) |

`src/Principal.bas` declares no namespace: it is the demo entrypoint (open → read/write UTF-8; save → write text). There is no `TXxxTests.RunAll`.

---

## Dialogs (`TDialogs`)

Win32/Shell pickers, no owner window (`hwndOwner = 0`). An empty filter (`""`) sends no mask. The active filter index is always `1` (first description/mask pair).

`Filter` contract:

```text
Text Files (*.txt)|*.txt
Text (*.txt)|*.txt|All (*.*)|*.*
```

The module replaces each `|` with a null and double-null-terminates the list.

```bas
Function OpenFile(Title As String, Filter As String, InitialDir As String) As String
   ' in: title, filter, initial folder
   ' out: single path, or "" if cancelled
   ' requires existing file and folder; hides "read-only"
End Function

Function OpenFiles(Title As String, Filter As String, InitialDir As String) As Collections.StringList
   ' in: same as OpenFile
   ' out: always a list (empty if cancelled) — the consumer owns it
   ' 1. multi-select dialog (Explorer)
   ' 2. a single token → add the full path
   ' 3. several null tokens: 1st = folder, rest = names; join folder + "\" + name
   '    then strip every "\\" (drive root "C:\" and UNC break)
   ' 4. if the name list is empty, add the folder itself
End Function

Function SaveFile(Title As String, Filter As String, InitialDir As String, DefExt As String, DefaultFileName As String = "") As String
   ' in: DefExt is the dialog default extension (e.g. "*.txt" in Principal)
   ' in: DefaultFileName "" = empty buffer; otherwise pre-fills the name
   ' out: chosen path, or "" if cancelled
   ' prompts on overwrite; requires an existing folder
End Function

Function SelectFolder(Title As String, pInitialDir As String = "") As String
   ' in: Title = BrowseForFolder text; pInitialDir default ""
   ' out: folder.Self.Path, or "" if cancelled / failed
End Function
```

Does not return `NULL`. `OpenFiles` never returns a null list.

---

## File (`TFile`)

Operations on a single file. Text I/O is UTF-8 (`ADODB.Stream`, charset `utf-8`). Writes overwrite (`SaveToFile` mode `2`). `Exists` / `Delete` delegate to `IO.File`. Other Win32 mutations ignore the API `Boolean` — failure is silent unless the runtime raises.

Three useful sentinels:

| Situation | Value |
|---|---|
| `GetAttributes` on a missing file | `-1` |
| `ReadAllLines` | throws `Exception("Not implemented")` |
| `CreateText` | `Path` is unused; the returned `Variant` is not assigned |

```bas
Function Delete(Path As String) As Boolean
   ' out: IO.File.Delete result
End Function

Sub Copy(Source As String, Dest As String, Overwrite As Boolean)
   ' Overwrite=True allows replacing Dest; False fails if Dest already exists
End Sub

Sub Move(Source As String, Dest As String)
End Sub

Function Exists(Path As String) As Boolean
   ' file (not folder). Folder: TDirectory.Exists; any object: TPath.Exists
End Function

Function GetAttributes(Path As String) As Integer
   ' raw Win32 bits; -1 = invalid / not found
End Function

Sub SetAttributes(Path As String, Attributes As Integer)
   ' in: the same raw integer from GetAttributes
End Sub

Function FileAttributesToInteger(Attributes As Integer) As Integer
   ' identity: returns Attributes
End Function

Function IntegerToFileAttributes(Attributes As Integer) As Integer
   ' identity: returns Attributes
End Function

Function ReadAllText(Path As String) As String
   ' in: Path must exist (LoadFromFile)
   ' out: full UTF-8 contents
End Function

Sub WriteAllText(Path As String, Contents As String)
   ' create or overwrite UTF-8
End Sub

Sub AppendAllText(Path As String, Contents As String)
   ' ReadAllText + concatenate + WriteAllText — Path must already exist
End Sub

Function ReadAllLines(Path As String) As Variant
   ' always throws Exception("Not implemented")
End Function

Sub WriteAllLines(Path As String, Contents As Variant)
   ' Join(Contents, Chr(13)+Chr(10)) then WriteAllText
End Sub

Function ReadAllBytes(Path As String) As Variant
   ' out: raw bytes from ADODB.Stream
End Function

Sub WriteAllBytes(Path As String, Bytes As Variant)
   ' overwrite binary
End Sub

Function CreateText(Path As String) As Variant
   ' opens an in-memory UTF-8 stream; does not write Path and does not return the stream
End Function

Function OpenRead(Path As String) As Variant
   ' out: loaded binary ADODB.Stream, Position=0. Consumer closes it.
End Function

Function OpenWrite(Path As String) As Variant
   ' out: binary ADODB.Stream; if Path exists, loads the file. Consumer closes it.
End Function

Sub Replace(SourceFileName As String, DestinationFileName As String, DestinationBackupFileName As String)
   ' Destination is the file being replaced; Source is the replacement; backup is the third path
End Sub

Function CreateSymLink(Link As String, Target As String) As Boolean
   ' file symlink (not directory). out: API Boolean
End Function

Sub Encrypt(Path As String)
   ' EFS on Path
End Sub

Sub Decrypt(Path As String)
   ' reverse of Encrypt
End Sub

Function GetCreationTime(Path As String) As Variant
Function GetLastAccessTime(Path As String) As Variant
Function GetLastWriteTime(Path As String) As Variant
   ' in: existing file (FSO.GetFile)
   ' out: DateCreated / DateLastAccessed / DateLastModified
End Function
```

### Extension from signature

Reads up to 16 bytes (file) or Base64 (string) and returns the extension **with a dot**. Fallback: `.bin`.

```bas
Function GetExtensionByMagicBytes(Path As String) As String
   ' in: existing Path; reads 16 binary bytes
End Function

Function GetExtensionByBase64(Base64String As String) As String
   ' if there is a ",", uses the chunk after the comma (data URL)
   ' truncates to 32 characters when the chunk is longer
End Function

Function GetExtensionFromHexSignature(hexSignature As String) As String
   ' in: hex already uppercased (the two methods above call UCase)
End Function
```

| Prefix / pattern (hex) | Extension |
|---|---|
| `FFD8` | `.jpg` |
| `89504E470D0A1A0A` | `.png` |
| `47494638` | `.gif` |
| `52494646` + `57454250` (offset 8) | `.webp` |
| `66747970` (offset 4) + `68656963` or `6D696631` | `.heic` |
| `66747970` + `61766966` | `.avif` |
| `424D` | `.bmp` |
| `49492A00` or `4D4D002A` | `.tiff` |
| `00000100` | `.ico` |
| `00000200` | `.cur` |
| `38425053` | `.psd` |
| `3C737667` | `.svg` |
| `52494646` + `41564920` | `.avi` |
| `52494646` + `57415645` | `.wav` |
| `66747970` + `69736F6D` or `6D703432` | `.mp4` |
| `494433` or `FFFB` | `.mp3` |
| `4F676753` | `.ogg` |
| `504B0304` | `.zip` (also Office OpenXML) |
| `526172211A0700` / `526172211A070100` | `.rar` |
| `377ABCAF271C` | `.7z` |
| `1F8B08` | `.gz` |
| `25504446` | `.pdf` |
| `7B5C727466` | `.rtf` |
| `4D5A` | `.exe` |
| `3C3F786D` | `.xml` |
| `EFBBBF` | `.txt` |
| anything else | `.bin` |

---

## Path (`TPath`)

Path-string helpers and special folders. `/` is normalized to `\` in functions that split. Does not read file contents, except `Exists` / `DriveExists` / `GetTempFileName`.

```bas
Function Exists(Path As String) As Boolean
   ' GetFileAttributesW <> -1 — file or folder
End Function

Function DriveExists(Path As String) As Boolean
   ' Exists(GetPathRoot(Path)); root "" → False
End Function

Function GetFileName(Path As String) As String
   ' after the last "\"; no slash returns Path as-is
End Function

Function GetDirectoryName(Path As String) As String
   ' parent folder; "C:\file" → "C:\"; no slash → ""
End Function

Function GetExtension(Path As String) As String
   ' includes the dot (".txt"); no dot → ""
End Function

Function GetFileNameWithoutExtension(Path As String) As String
   ' name without the last extension; no dot → the name itself
End Function

Function ChangeExtension(Path As String, Extension As String) As String
   ' Extension "" strips the suffix; if it does not start with ".", prefix "."
End Function

Function HasExtension(Path As String) As Boolean
   ' GetExtension(Path) <> ""
End Function

Function GetPathRoot(Path As String) As String
   ' 1. ":" as the second letter → Left 3 ("C:\")
   ' 2. starts with "\\" → "\\server" (first "\" after the host; does not include the share)
   ' 3. otherwise ""
End Function

Function Combine(Path1 As String, Path2 As String) As String
   ' "" + the other = the other; strip "\" at the join points and concatenate with "\"
   ' an absolute Path2 does not replace Path1
End Function

Function GetTempPath() As String
   ' Windows temp folder, or "" if the API fails
End Function

Function GetTempFileName() As String
   ' creates a real file with prefix "TMP" under GetTempPath(); "" on failure
End Function

Function GetDesktopPath() As String
Function GetDocumentsPath() As String
Function GetPicturesPath() As String
Function GetMusicPath() As String
Function GetMoviesPath() As String
Function GetAppPath() As String          ' Application Data
   ' out: special-folder path, or "" if SHGetFolderPath fails
End Function

Function GetInvalidFileNameChars() As String
   ' out: quote + <>|:*?\ + /   (Chr(34) + "<>|:*?\" + "/")
End Function

Function IsValidFileNameChar(AChar As String) As Boolean
   ' True if AChar does not occur in GetInvalidFileNameChars
End Function

Function IsDriveRooted(Path As String) As Boolean
   ' True if InStr(Path, ":") = 2  ("C:\...")
End Function

Function MatchesPattern(FileName As String, Pattern As String) As Boolean
   ' FileName or Pattern "" → False
   ' otherwise PathMatchSpecW (Windows wildcards: "*.txt")
End Function
```

---

## Directory (`TDirectory`)

Folders and **non-recursive** listings (immediate children). `GetFiles` / `GetDirectories` / `GetFileSystemEntries` use `Shell.Application` on the absolute path; a missing folder returns an empty `StringList` (never `NULL`). The consumer owns the list.

```bas
Sub CreateDirectory(Path As String)
   ' one level; missing parents are not created; API return ignored
End Sub

Function Exists(Path As String) As Boolean
   ' FSO.FolderExists
End Function

Sub Delete(Path As String, Recursive As Boolean)
   ' no-op if the folder does not exist
   ' Recursive is passed as the 2nd argument of FSO.DeleteFolder (force)
End Sub

Sub Copy(SourceDirName As String, DestDirName As String, Overwrite As Boolean)
Sub Move(SourceDirName As String, DestDirName As String)
   ' FSO CopyFolder / MoveFolder — no existence guard in this module
End Sub

Function IsEmpty(Path As String) As Boolean
   ' True if the folder does not exist OR Files.Count=0 and SubFolders.Count=0
End Function

Function GetCurrentDirectory() As String
   ' out: cwd, or "" if the API fails
End Function

Sub SetCurrentDirectory(Path As String)
   ' API return ignored
End Sub

Function GetAttributes(Path As String) As Integer
Sub SetAttributes(Path As String, Attributes As Integer)
   ' raw Win32 integer; GetAttributes on missing path → -1
End Function

Function GetLogicalDrives() As Collections.StringList
   ' items such as "C:\"; empty list if the API returns nothing
End Function

Function GetFiles(Path As String) As Collections.StringList
   ' children that are not folders
End Function

Function GetDirectories(Path As String) As Collections.StringList
   ' children that are folders
End Function

Function GetFileSystemEntries(Path As String) As Collections.StringList
   ' all children (file and folder)
End Function

Function GetCreationTime(Path As String) As String
Function GetLastAccessTime(Path As String) As String
Function GetLastWriteTime(Path As String) As String
   ' in: existing folder (FSO.GetFolder); out: date as String
End Function

Function GetParent(Path As String) As String
   ' FSO.GetParentFolderName
End Function

Function GetDirectoryRoot(Path As String) As String
   ' only "X:\" (":" as the second letter); UNC / relative → ""
End Function
```

---

## Extension (consumer project)

There are no public classes to inherit and no `Add` / `Make` / `MakeByName` catalog. The consumer calls `TDialogs.*`, `TFile.*`, `TPath.*`, and `TDirectory.*`.

`TDialogs` is already this module's UI (Open/Save/Folder). There are no Data7 forms here. Recursion, mkdir of parents, encoding other than UTF-8, `ReadAllLines`, and business path validation stay in the consuming project.

---

## Module notes

- `TFile.Exists` is files only, `TDirectory.Exists` folders only, `TPath.Exists` any object (`attributes <> -1`).
- Lists (`OpenFiles`, `GetFiles`, `GetDirectories`, `GetFileSystemEntries`, `GetLogicalDrives`) come back as new `Collections.StringList` instances; the consumer owns them.
- Text is UTF-8; `WriteAllText` / `WriteAllBytes` / `WriteAllLines` overwrite. `AppendAllText` requires the file to already exist.
- `ReadAllLines` throws. `CreateText` does not return a stream and ignores `Path`.
- `GetTempFileName` creates the file on disk (prefix `TMP`).
- `CreateDirectory` does not create intermediates. `IsEmpty` is `True` for a missing folder.
- `GetExtensionByMagicBytes` / `GetExtensionByBase64` do not distinguish `.docx`/`.xlsx` from `.zip`.
- Canonical demo: `src/Principal.bas` (filter `"Arquivos de Texto (*.txt)|*.txt"`). There is no `TXxxTests.RunAll` suite.
