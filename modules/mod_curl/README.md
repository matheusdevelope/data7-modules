# mod_curl

HTTP client that shells out to a portable `curl.exe`. It builds the argv, runs curl, and returns a parsed `CurlOutput`. It does not interpret HTTP status as success or failure, does not parse JSON/XML, and does not decide retry, proxy, or TLS policy — that stays in the consumer.

Version: `1.0.0.0`. Dependencies (`data7.json`): `mod_portable_exe` `1.0.0.0` (transitively `mod_io`).

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## Quick Start (Minimal)

```bas
Imports mod_curl

Dim _curl As New Curl()                          ' first Exec() installs curl.exe if missing
_curl.Url = "https://example.com/api"            ' --url
_curl.Method = "POST"                            ' -X POST
_curl.AddHeader("Content-Type", "application/json")
_curl.AddHeader("Accept", "application/json")
_curl.AddBody("{""ok"":true}")                   ' UTF-8 body via --data-binary @temp

Dim _out As CurlOutput = _curl.Exec()            ' throws only if curl.exe exit <> 0
print(_out.StatusCode)                           ' last hop, e.g. 200 — HTTP 4xx/5xx still succeed
print(_out.ResponseText)
_out.Free()
_curl.Free()
```

`Exec` does not throw on HTTP 404/500. `TimeoutMs = 0` means no `--max-time`. `Output = ""` means a temp body file that `Exec` deletes after parse.

---

## Namespace map

| File | Namespace | Types |
|---|---|---|
| `src/mod_curl.bas` | `mod_curl` | `Curl`, `CurlOutput` |

`src/Principal.bas` declares no namespace: it is the demo entrypoint (`New Curl()`, `ToString()`, `Free()`; `Exec` is commented out). There is no `TXxxTests.RunAll`.

---

## HTTP client (`Curl`)

Builds a curl command line, ensures a portable `curl.exe` (inherited zip installer), runs it synchronously, and returns `CurlOutput`. Inherits `TZipPortableExe`.

Constructor defaults (this class plus the values it writes onto the base):

| Member | Default |
|---|---|
| `Method` | `""` (no `-X`; curl chooses GET, or POST if a body/`-F` is present) |
| `Url` | `""` (no `--url`) |
| `Cert` / `CertType` / `Key` / `Pass` | `""` |
| `Output` | `""` (temp `curlo*.bin`, deleted after parse) |
| `TimeoutMs` | `0` (no `--max-time` / `--connect-timeout`) |
| `FollowRedirects` | `True` (`-L --max-redirs 10`) |
| `Insecure` | `False` (no `-k`) |
| `DownloadUrl` | `https://curl.se/windows/latest.cgi?p=win64-mingw.zip` |
| `DownloadTimeoutMs` | `120000` |
| `InstallFolder` | `curl` |
| `ExeFileName` | `curl.exe` |
| `ArchiveName` | `curl.zip` |
| `SearchRecursive` | `True` |

Installed exe path: `{AppDir}\curl\curl.exe`.

### Properties

| Property | Type | Role |
|---|---|---|
| `Method` | `String` | Verb for `-X`. Empty = omitted. |
| `Url` | `String` | Target for `--url`. Empty = omitted. |
| `Cert` | `String` | Path for `--cert`. Empty = omitted. |
| `CertType` | `String` | Only `"P12"` (any case, trimmed) emits `--cert-type P12`. |
| `Key` | `String` | Path for `--key`. Empty = omitted. |
| `Pass` | `String` | Written to a temp curl config as `pass = "..."`, passed via `--config`. Empty = omitted. |
| `Output` | `String` | Body destination for `--output`. Empty = temp file owned by `Curl`. Non-empty = consumer path, not deleted. |
| `TimeoutMs` | `Integer` | Milliseconds. `> 0` → `Int(TimeoutMs / 1000)` seconds, minimum `1`, applied to both `--max-time` and `--connect-timeout`. |
| `FollowRedirects` | `Boolean` | `True` adds `-L --max-redirs 10`. |
| `Insecure` | `Boolean` | `True` adds `-k`. |

### Methods

```bas
Sub UsePfx(pPath As String, pPass As String)
   ' sets Cert=pPath, CertType="P12", Key="", Pass=pPass
End Sub

Sub AddHeader(pName As String, pValue As String)
   ' stores Trim(pName) & ": " & Trim(pValue), later -H "Name: Value"
   ' example: AddHeader("Authorization", "Bearer token")
End Sub

Sub AddBody(pText As String)
   ' writes pText as UTF-8 without BOM to a temp curlb*.bin
   ' tracks that temp; sets the --data-binary @file
   ' last AddBody / AddDataBinaryFile wins
End Sub

Sub AddFormPart(pValue As String)
   ' one -F token, unprocessed
   ' examples: "field=value"   "file=@C:\tmp\photo.png"
End Sub

Sub AddOption(pValue As String)
   ' extra argv fragment, not quoted by this module
   ' examples: "--http1.1"   "--compressed"   "--proxy http://127.0.0.1:8080"
End Sub

Sub AddDataBinaryFile(pPath As String)
   ' --data-binary @pPath; pPath is not tracked as a temp
End Sub

Sub TrackTemp(pPath As String)
   ' no-op if pPath = ""
   ' otherwise deleted by CleanTemps after a successful Exec, or by Dispose
End Sub

Function Exec() As CurlOutput
   ' out: always a CurlOutput on curl.exe exit 0; never NULL
   ' 1. temp dump-header curlh*.txt and stderr curle*.txt (always tracked)
   ' 2. body = Output if set, else temp curlo*.bin (tracked only when Output = "")
   ' 3. RunWait(built argv); exit <> 0 → Throw before parse / before CleanTemps
   ' 4. New CurlOutput(headerFile, bodyFile)
   ' 5. delete owned temps (body file kept when Output was set)
End Function
```

`ToString` is a debug dump of `Method`, `Url`, `Cert`, `CertType`, `TimeoutMs`, `FollowRedirects` (not the argv, not `Pass`). `Dispose` deletes owned temps, frees the internal lists, and clears `Pass` before the base dispose.

### Argv `Exec` always sends

Always present: `-sS --globoff`, `--dump-header`, `--output`, `--stderr`.

Conditional:

| Condition | Flags |
|---|---|
| `FollowRedirects` | `-L --max-redirs 10` |
| `Insecure` | `-k` |
| `TimeoutMs > 0` | `--max-time N --connect-timeout N` (`N` seconds, min 1) |
| `Method <> ""` | `-X "Method"` |
| `Url <> ""` | `--url "Url"` |
| each header | `-H "Name: Value"` |
| body file or any form part | `-H "Expect:"` (empty Expect, disables 100-continue) |
| body file set | `--data-binary "@path"` |
| each form part | `-F "token"` |
| `CertType` is `P12` | `--cert-type P12` |
| `Cert <> ""` | `--cert "path"` |
| `Key <> ""` | `--key "path"` |
| `Pass <> ""` | `--config` pointing at a temp `curlc*.cfg` containing `pass = "..."` |
| each `AddOption` | token as given, then dump-header / output / stderr |

`AddBody` and `AddFormPart` can both be set; both `-F` and `--data-binary` are emitted.

### What throws / NULL / no-op

| Situation | Result |
|---|---|
| `Exec`, curl.exe exit `<> 0` | `Exception("curl failed (N): " & stderrText)` — temps are **not** cleaned until `Dispose`/`Free` |
| `Exec`, HTTP 4xx/5xx with curl exit 0 | returns `CurlOutput`; consumer reads `StatusCode` |
| `Exec` | never returns `NULL` |
| `Url = ""` / `Method = ""` | those flags omitted; curl still runs (usually fails with a non-zero exit if there is no URL) |
| `TrackTemp("")` | no-op |
| `TimeoutMs = 0`, `Insecure = False`, empty cert/key/pass/headers/forms/options | corresponding flags omitted |
| first `Exec` when `{AppDir}\curl\curl.exe` is missing | inherited installer: download zip from `DownloadUrl`, extract, locate `curl.exe` |

Inherited installer throws (via `RunWait` → `EnsureExe`) when there is no zip source, the zip is missing, the download is not HTTP 200, or `curl.exe` is not found after extract.

---

## Response (`CurlOutput`)

Snapshot of the last HTTP hop after `--dump-header` and `--output`. Constructed by `Curl.Exec`; consumers may also `New CurlOutput(headersFile, bodyFile)` from existing files.

| Field | Type | Default / meaning |
|---|---|---|
| `StatusCode` | `Integer` | `0` until a status line parses; last `HTTP/` line wins |
| `StatusText` | `String` | reason phrase; `""` if the status line has only a code |
| `HttpVersion` | `String` | first token, e.g. `HTTP/1.1` |
| `ContentType` | `String` | raw `Content-Type` value, or `""` |
| `Charset` | `String` | substring after `charset=` in `Content-Type`, quotes stripped, cut at `;`, or `""` |
| `ContentLength` | `Long` | parsed `Content-Length`, or `0` if missing/invalid |
| `Headers` | `StringList` | owned by this object — `Name: Value` lines of the **last** hop |
| `ResponseData` | `Variant` | raw bytes from the body file (`ADODB.Stream`); unset if the file is missing |
| `ResponseText` | `String` | body loaded as text; `""` if the file is missing |

```bas
Sub New(headersFile As String, bodyFile As String)
   ' 1. parse headersFile (required)
   ' 2. load bodyFile as bytes (ResponseData)
   ' 3. load bodyFile as text (ResponseText)
End Sub
```

`Free` zeros the numeric/string fields, frees `Headers`, clears `ResponseData` / `ResponseText`, then the base free. Do not `Free` `Headers` separately.

### Header detection

1. Load `headersFile` as lines. Missing file → `Exception("Header file not found.")`. Zero lines → `Exception("Header file is empty.")`.
2. Trim each line.
3. A line whose first five characters are `HTTP/` (case-insensitive) is a status line: parse it and **`Headers.Clear()`** (redirect hops: only the last block is kept).
4. Other non-empty lines are appended to `Headers`. Empty lines are ignored.
5. Read `Content-Type` and `Content-Length` from the remaining list (first match, name compared trimmed/uppercased before `:`).

Status line:

1. Split on the first space → `HttpVersion`.
2. Rest: if another space, `StatusCode` = integer before it, `StatusText` = the remainder; else the whole rest is the code and `StatusText = ""`.
3. Integer parse failure → `StatusCode = 0`, `StatusText` = the rest (does not throw).
4. No space at all → `HttpVersion` = the whole line; code/text unchanged.

Missing `bodyFile` is a no-op for both body loaders (no throw). `ContentLength` parse failure is `0`, not a throw.

`Exec` never returns `NULL`. `CurlOutput.New` never returns `NULL`.

---

## Extending (Consumer Project)

There is no `Add` / `Make` / `MakeByName` catalog and no UI.

Instantiate `Curl` and call `Exec`. To pin a binary or change install layout, set the inherited installer properties before the first `Exec`:

```bas
Class TPinnedCurl
   Inherits Curl

   Sub New()
      MyBase.New()
      me.DownloadUrl = "https://example.com/curl-8.x-win64.zip"   ' override latest.cgi
      me.InstallFolder = "curl"
      me.ExeFileName = "curl.exe"
      me.ArchiveName = "curl.zip"
   End Sub
End Class
```

Inherited overridables (from `TZipPortableExe` / `TRemotePortableExe` / `TPortableExe`) if the consumer subclasses `Curl`:

| Hook | Purpose |
|---|---|
| `EnsureExe` | resolve or install `curl.exe` before `RunWait` |
| `ResolveDownloadPath` | zip destination (this module uses `ArchiveName` under `AppDir`) |
| `AfterDownload` | unzip, optional archive delete, recursive search for `ExeFileName` |

TLS, retries, JSON mapping, and treating `StatusCode >= 400` as an error stay in the consumer.

---

## Module notes

- `Curl` owns `_headers`, `_formParts`, `_extraOptions`, and `_ownedTemps`. `CurlOutput` owns `Headers`. The `CurlOutput` returned by `Exec` is owned by the consumer.
- Temps (`curlb`, `curlh`, `curle`, `curlo`, `curlc`) are deleted after a **successful** `Exec`. A thrown `curl failed` leaves them until `Dispose`/`Free`. A consumer `Output` path is never tracked.
- `AddBody` UTF-8 files have the BOM stripped. `AddDataBinaryFile` does not copy or take ownership of `pPath`.
- `Pass` is not placed on the argv; it goes through a temp `--config` line `pass = "..."`. `Dispose` clears `Pass`.
- `TimeoutMs` is ms in the API and seconds on the argv (`Int` division, min 1 when `TimeoutMs > 0`).
- Redirects: `-L` with max 10; parsed headers/status are the last `HTTP/` block only.
- HTTP error statuses are success for this module. Only a non-zero curl.exe exit throws.
- Canonical demo: `src/Principal.bas`. There is no `TXxxTests.RunAll` suite.
