# mod_data7_utils

Registration-free COM bridge from Data7 Basic to a .NET Framework 4.8 DLL (`Data7Utils`). Use it for capabilities the Data7 runtime does not expose well: **seekable .NET streams** and **Socket.IO**. It does not replace disk I/O, path helpers, or native file dialogs — those belong in `mod_io` (`TFile`, `TPath`, `TDirectory`, `TDialogs`).

Version: `1.0.0.1`. Dependencies (`data7.json`): none. Stream enums are `Enun` types (`Imports mod_tenum` from bundled `core_modules`).

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## How to use (minimum)

```bas
Imports mod_data7_utils_memory_stream
Imports mod_data7_utils_stream_enums

Dim mem As TMemoryStream = New TMemoryStream()
mem.StreamKind = TUtilsStreamKind.Text
mem.Charset = TUtilsCharset.UTF8
mem.Open()
mem.WriteText("hello")
Dim text As String = mem.ReadTextAll()
mem.Free()
```

The first COM wrapper constructor extracts `Data7Utils.dll` + `Data7Utils.dll.manifest` into `{exeDir}\data7utils\{fileVersion}\`, copies both files next to the host executable when the host stamp (`Data7Utils.version`) is missing or older (the CLR only probes the application directory), and instantiates the ProgId through `Microsoft.Windows.ActCtx` (no `regasm`). If the host DLL is locked from a previous version, close Data7 DevStudio and run again.

---

## Namespace map

| File | Namespace | Types |
|---|---|---|
| `src/lib/runtime/mod_data7_utils_runtime.bas` | `mod_data7_utils_runtime` | `TComRuntime` |
| `src/lib/runtime/mod_data7_utils_payload.bas` | `mod_data7_utils_payload` | `PayloadVersion`, `ZipBase64` (generated) |
| `src/lib/stream/mod_data7_utils_stream.bas` | `mod_data7_utils_stream` | `TStream` |
| `src/lib/stream/mod_data7_utils_file_stream.bas` | `mod_data7_utils_file_stream` | `TFileStream` |
| `src/lib/stream/mod_data7_utils_memory_stream.bas` | `mod_data7_utils_memory_stream` | `TMemoryStream` |
| `src/lib/stream/mod_data7_utils_stream_enums.bas` | `mod_data7_utils_stream_enums` | `TUtilsStreamKind`, `TUtilsCharset`, `TUtilsFileMode`, `TUtilsFileAccess`, `TUtilsSeekOrigin` |
| `src/lib/stream/mod_data7_utils_int64.bas` | `mod_data7_utils_int64` | `UtilsZero64`, `UtilsFromInteger`, `UtilsParseInt64`, `UtilsInt64Text` |
| `src/lib/socket/mod_data7_utils_socket.bas` | `mod_data7_utils_socket` | `TSocketClient`, connect/event delegates |
| `src/lib/socket/mod_data7_utils_socket_event.bas` | `mod_data7_utils_socket_event` | `TSocketEvent` |
| `src/tests/mod_data7_utils_tests.bas` | `mod_data7_utils_tests` | `TData7UtilsTests.RunAll` |
| `src/tests/mod_data7_utils_tests_large_stream.bas` | `mod_data7_utils_tests_large_stream` | `TLargeStreamTests` |
| `src/Principal.bas` | (none) | test entrypoint |

`src/Helpers/mod_console.bas` is a local print helper, not part of the public contract.

---

## Runtime (`TComRuntime`)

Every wrapper inherits `TComRuntime`. Construction calls `EnsureExtracted` once per process, then `ActCtx.CreateObject(progId)`. If side-by-side activation fails, it falls back to `CreateObject(progId)` (registered COM).

```bas
Function RuntimeDir() As String
   ' {exeDir}\data7utils\{PayloadVersion}
End Function

Function ManifestPath() As String
   ' RuntimeDir() & "\Data7Utils.dll.manifest"
End Function
```

Do not call `CreateObject("Data7Utils.FileStream")` from consumer code. Always go through the wrappers so the payload is extracted.

---

## Streams

`TStream` is the shared COM façade (`Data7Utils.FileStream` / `Data7Utils.MemoryStream`). Text operations require `StreamKind = TUtilsStreamKind.Text` first.

```bas
Property Position As Int64
Property EOF As Boolean
Property Size As Int64
Property StreamKind As TUtilsStreamKind     ' Binary=1, Text=2
Property Charset As TUtilsCharset           ' UTF8=1, ASCII=2, Utf16=3, Latin1=4, Base64=5

Sub Seek(pOffset As Int64, pOrigin As TUtilsSeekOrigin)
Function Read(pSize As Integer) As Variant   ' chunk size; keep well under 2 GiB
Function ReadAll() As Variant                ' throws if remaining > 2 GiB
Function ReadText(pSize As Integer) As String
Function ReadTextAll() As String
Sub Write(pData As Variant)
Sub WriteText(pText As String)
Sub Flush()
Sub Close()
Sub CopyTo(pStream As TStream, pChunkSize As Integer = -1)  ' does not rewind

```

### `TFileStream`

```bas
Sub Open(pPath As String)                                              ' Open + Read
Sub Open(pPath As String, pMode As TUtilsFileMode)
Sub Open(pPath As String, pMode As TUtilsFileMode, pAccess As TUtilsFileAccess)
```

Stream enums are `Enun` singletons (`TEnum`): `.AsInteger` is the COM value, `.AsString` is the same digit, `.Load(Integer)` / `.Load(String)` round-trip from COM. `Create`/`Open` are reserved, so file modes use `TUtilsFileMode.CreateFile` (2) and `TUtilsFileMode.OpenFile` (3). 1-based COM enums include `Unspecified = 0` so the cache ordinal matches the DLL. Do not `Free()` an `Enun` instance.

### `TMemoryStream`

```bas
Sub Open()
Sub Open(pData As Variant)
Sub LoadFromFile(pPath As String)
Sub LoadFromFile(pPath As String, pMode As TUtilsFileMode, pAccess As TUtilsFileAccess)
Sub SaveToFile(pPath As String)
Function ToArray() As Variant
```

`LoadFromFile` binds the memory wrapper to an underlying file stream; `SaveToFile` is only valid for a true in-memory buffer.

### Large files (HTTP upload/download)

Use **`TFileStream`** and a fixed chunk size. Do **not** use `TMemoryStream`, `ReadAll`, `ReadTextAll`, or `ToArray` for the payload — those load the whole file (the `ADODB.Stream` problem).

```bas
' download: write each incoming chunk to disk
Dim dest As TFileStream = New TFileStream()
dest.Open(path, TUtilsFileMode.CreateFile, TUtilsFileAccess.Write)
dest.Write(chunk)
dest.Flush()
dest.Free()

' upload: read the file in chunks
Dim src As TFileStream = New TFileStream()
Dim chunk As Variant
src.Open(path)
While Not src.EOF
   chunk = src.Read(65536)
End While
src.Free()
```

File-to-file spool: `src.CopyTo(dest, 65536)` (8 KiB default). `CopyTo` only keeps one buffer and **does not** seek back to 0.

Data7 `Long` is 32-bit and overflows at 2 GiB. Use `Size`/`Position`/`Seek` as **`Int64`** (helpers in `mod_data7_utils_int64`, same pattern as `mod_http` `HttpRange`). HTTP `Content-Length` and `Range` must use `UtilsInt64Text(stream.Size)` / `UtilsInt64Text(stream.Position)`, never `CStr` of a `Long`. Never use `ReadAll`/`ReadTextAll`/`ToArray` on a payload that can exceed 2 GiB. `TSocketClient.EmitFile` still loads the whole file (`File.ReadAllBytes`) — do not use it for multi-gigabyte payloads.

---

## Socket.IO (`TSocketClient`)

ProgId `Data7Utils.SocketClient`. Events are polled on a 10 ms `Forms.Timer` (the Data7 host cannot consume .NET callbacks directly).

```bas
Delegate Sub TSocketClient_OnConnect(pSender As TObject, pSocketID As String)
Delegate Sub TSocketClient_OnDisconnect(pSender As TObject, pReason As String)
Delegate Sub TSocketClient_OnError(pSender As TObject, pError As String)
Delegate Sub TSocketClient_OnEvent(pSender As TObject, pEvent As TSocketEvent)

Sub Connect(pHost As String, pNamespace As String, pToken As String = "", ...)
Sub Disconnect()
Function Subscribe(pName As String) As String
Function Unsubscribe(pRequestId As String, pName As String) As Boolean
Sub Emit(pName As String, pJsonPayload As String)
Sub EmitFile(pName As String, pFilePath As String, pMetadataJson As String)
```

`TSocketEvent`: `Name`, `HasData`, `IsText`, `AsText`, `IsJson`, `AsJson`, `SaveToFile`.

Live `Connect` is **not** part of `TData7UtilsTests.RunAll`. The suite only constructs the client and checks the idle queue.

---

## Refreshing the embedded COM payload

After changing C# under `Data7Utils/Data7Utils/`:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/Update-ComPayload.ps1
```

The script restores NuGet packages, builds **Release|x86**, writes a SxS manifest from `[ProgId]`/`[Guid]` attributes, zips `Data7Utils.dll` + `Data7Utils.dll.manifest`, and regenerates `src/lib/runtime/mod_data7_utils_payload.bas` as a single Base64 string. That file is generated — do not edit it by hand. Commit it so consumers do not need MSBuild.

---

## Tests

```bas
TData7UtilsTests.RunAll()
```

`src/Principal.bas` only runs the suite. Coverage: payload extract, MemoryStream, FileStream, CopyTo, idle Socket client, a **32 MiB** chunked FileStream path, and a **3 GiB** stress path (1 MiB binary chunks, file-to-file `CopyTo`, working-set samples). The 3 GiB test writes ~6 GiB to `%TEMP%` and fails if `Size` is not `Int64` (3 GiB overflows a 32-bit `Long`) or if the host working set grows by 128 MiB or more. Large-file tests never call `ReadAll`, `ReadTextAll`, or `ToArray` on the payload. No UI dialogs and no live Socket.IO server.
