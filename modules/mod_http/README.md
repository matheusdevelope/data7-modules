# mod_http

HTTP client library for Data7 with pluggable transports (`WinHttp`, `CURL`, native `THTTP`, `Mock`), request/response types, interceptors, multipart form bodies, and an optional localhost callback listener. It does **not** implement OAuth flows, retries, cookie jars, or proxy configuration — those belong to the consumer. Version **2.0** (`opcoes.versao` `2.0.0.0`). Dependencies: `mod_io` `1.0.0.0`, `mod_strings` `1.0.0.0`, `mod_portable_exe` `1.0.0.0`, `mod_curl` `1.0.0.0`, `mod_certificate` `1.0.0.0`.

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Open a `.bas` file only to confirm a detail that is not stated here.

## Quick Start (Minimal)

```basic
Imports http_client
Imports http_response
Imports http_body

' In-process transport; DefaultStatus/DefaultBody come from Http.Mock defaults unless overridden.
Dim client As HttpClient = Http.Mock(200, "{ok:true}")
' Session query string; encoded later by http_url.Build.
client.Params.Define("q", "demo")
' GET uses HttpMethod.Gett(); empty endpoint keeps BaseUrl (here "").
Dim res As HttpResponse = client.Gett("/health")
' 200..299
If res.IsSuccessful Then
   Dim jsonText As String = res.Body.AsText
End If
res.Free()
client.Free()

' One-shot GET with DefaultTransport (WinHttp unless project param is CURL).
Dim live As HttpResponse = Http.Gett("https://httpbin.org/get")
live.Free()
```

## Namespace Map

| File | Namespace | Types / members |
| --- | --- | --- |
| `src/lib/http_enums.bas` | `http_enums` | `HttpMethod`, `HttpClientKind` |
| `src/lib/http_url.bas` | `http_url` | `Encode`, `Decode`, `IsAbsolute`, `NormalizePath`, `Join`, `WithQuery`, `Build` |
| `src/lib/http_headers.bas` | `http_headers` | `HttpBaseList`, `HttpHeaders`, `HttpParams` |
| `src/lib/http_form.bas` | `http_form` | `FormDataPart`, `FormData` |
| `src/lib/http_body.bas` | `http_body` | `HttpBody` |
| `src/lib/http_request.bas` | `http_request` | `HttpRequest` |
| `src/lib/http_response.bas` | `http_response` | `HttpResponseData`, `HttpResponse` |
| `src/lib/http_transport.bas` | `http_transport` | `IHttpTransport` |
| `src/lib/http.bas` | `http_client` | `HttpClient`, `Http` |
| `src/lib/interceptors/http_interceptor.bas` | `http_interceptor` | `HttpInterceptor`, `BearerAuth`, `BasicAuth` |
| `src/lib/clients/winhttp_transport.bas` | `http_winhttp` | `WinHttpTransport` |
| `src/lib/clients/curl_transport.bas` | `http_curl` | `CurlTransport` |
| `src/lib/clients/data7_transport.bas` | `http_data7` | `Data7Transport` |
| `src/lib/clients/mock_transport.bas` | `http_mock` | `MockQueuedResponse`, `MockTransport` |
| `src/lib/callback/http_callback.bas` | `http_callback` | `HttpCallback` |
| `src/tests/http_test_harness.bas` | `tests` | `THttpTest` |
| `src/tests/http_live_tests.bas` | `tests_live` | `THttpLiveTest` |

Client certificates use `TCertificate` from `mod_certificate` (not defined in this module). CURL execution uses `Curl` / `CurlOutput` from `mod_curl` inside `CurlTransport` only.

## Enums

```basic
Enun HttpMethod
   Gett = "GET"
   Post = "POST"
   Put = "PUT"
   Patch = "PATCH"
   Delete = "DELETE"
   Head = "HEAD"
   Options = "OPTIONS"
End Enun

Enun HttpClientKind
   WinHttp = "WINHTTP"
   Curl = "CURL"
   DevStudio = "DevStudio"
   Mock = "MOCK"
End Enun
```

`HttpClient` has verb helpers for `Gett` / `Post` / `Put` / `Patch` / `Delete` only. `Head` and `Options` go through `Request(HttpMethod.Head(), endpoint)` / `Request(HttpMethod.Options(), endpoint)`.

## Client and facade

### `HttpClient`

Session that builds `HttpRequest`, runs interceptors, and delegates `Send` to an `IHttpTransport`.

| Member | Default | Notes |
| --- | --- | --- |
| `BaseUrl` | `""` (or factory argument) | Joined with the endpoint by `http_url.Build` |
| `Timeout` | `10000` | Milliseconds, copied onto each `HttpRequest` |
| `Headers` | empty `HttpHeaders` | Copied per request |
| `Params` | empty `HttpParams` | Merged into the URL query |
| `Certificate` | `New TCertificate()` | Shared onto every request; owned by the client |
| `Transport` | constructor arg | Read-only |
| `ContentType` | `"application/json"` | Also `Headers.Define("Content-Type", …)` |
| `Accept` | `"application/json"` | Also `Headers.Define("Accept", …)` |
| `UserAgent` | `"Data7/1.0"` | Also `Headers.Define("User-Agent", …)` |

```basic
Sub New(pTransport As IHttpTransport, pBaseUrl As String = "", pOwnsTransport As Boolean = True)
   ' pOwnsTransport True: Free() also frees Transport.

Function Use(pInterceptor As HttpInterceptor) As HttpClient
   ' Push interceptor; returns me for chaining.

Function Request(pMethod As HttpMethod, pEndpoint As String) As HttpResponse
   ' Empty HttpBody (kind "empty").

Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As String) As HttpResponse
   ' HttpBody.FromText(pBody, me.ContentType); body freed after Send.

Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As FormData) As HttpResponse
   ' HttpBody.FromForm(pBody) with pOwnsForm False; FormData stays with the caller.

Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As TJSONObject) As HttpResponse
   ' HttpBody.FromJson(pJson.ToString()).

Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As HttpBody) As HttpResponse
   ' Caller owns pBody. This is the Send path.

Function Gett(pEndpoint As String = "") As HttpResponse
Function Post(pEndpoint As String) As HttpResponse
Function Post(pEndpoint As String, pBody As HttpBody) As HttpResponse
Function Post(pEndpoint As String, pBody As String) As HttpResponse
Function Post(pEndpoint As String, pBody As FormData) As HttpResponse
Function Post(pEndpoint As String, pBody As TJSONObject) As HttpResponse
Function Put(pEndpoint As String) As HttpResponse
Function Put(pEndpoint As String, pBody As HttpBody) As HttpResponse
Function Put(pEndpoint As String, pBody As String) As HttpResponse
Function Put(pEndpoint As String, pBody As FormData) As HttpResponse
Function Patch(pEndpoint As String) As HttpResponse
Function Patch(pEndpoint As String, pBody As HttpBody) As HttpResponse
Function Patch(pEndpoint As String, pBody As String) As HttpResponse
Function Patch(pEndpoint As String, pBody As FormData) As HttpResponse
Function Delete(pEndpoint As String) As HttpResponse
Function Delete(pEndpoint As String, pBody As HttpBody) As HttpResponse
Function Delete(pEndpoint As String, pBody As String) As HttpResponse
Function Delete(pEndpoint As String, pBody As FormData) As HttpResponse
```

`Put` / `Patch` / `Delete` have no `TJSONObject` overload; wrap with `HttpBody.FromJson` or use `Request`.

**Overridable hooks**

- `OnRequest(pReq As HttpRequest)` — after `BuildRequest`, before interceptors. Default no-op.
- `AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse` — after `Transport.Send`, before interceptor `AfterRequest`. Default returns `pRes`.

**`Free`:** frees `Transport` when `_ownsTransport`, then interceptors, `Headers`, `Params`, `Certificate`. Does not free returned `HttpResponse` objects.

### Request pipeline

1. Copy session `Headers`. If body `IsForm`, set `Content-Type` to `body.ContentType`. Else if body is not empty and `body.ContentType <> ""`, set `Content-Type` to that. Empty GET/HEAD keeps the session `Content-Type` header if present.
2. `url = http_url.Build(BaseUrl, endpoint, Params)`.
3. `HttpRequest` shares the session `Certificate` and the same `HttpBody` instance (not cloned).
4. `HttpClient.OnRequest`.
5. Each interceptor `OnRequest` in insert order.
6. `Transport.Send`.
7. `HttpClient.AfterRequest` (may replace the response).
8. Each interceptor `AfterRequest` in insert order (may replace the response).
9. `HttpRequest.Free` (frees the **copied** headers only).

### `Http`

Static facade. Instantiating `Http` is unused by the factories.

```basic
Shared Function DefaultKind() As HttpClientKind
   ' Data7.Parametro("Customizado_Projeto_ClientePadraoModuloHttp")
   ' UCase = "CURL" -> HttpClientKind.Curl(); anything else -> WinHttp().

Shared Function DefaultTransport() As IHttpTransport
   ' CurlTransport or WinHttpTransport from DefaultKind.

Shared Function FromTransport(pTransport As IHttpTransport, pBaseUrl As String = "") As HttpClient
   ' New HttpClient(pTransport, pBaseUrl) — owns the transport.

Shared Function WinHttp(pBaseUrl As String = "") As HttpClient
Shared Function Curl(pBaseUrl As String = "") As HttpClient
Shared Function DevStudio(pBaseUrl As String = "") As HttpClient
   ' Data7Transport (native THTTP).

Shared Function Mock(pStatus As Integer = 200, pBody As String = "{}", pHeaders As String = "Content-Type: application/json") As HttpClient
   ' BaseUrl is always "".

Shared Function Gett(pUrl As String) As HttpResponse
   ' New client with DefaultTransport, Gett(pUrl), Free client, return response.
```

Project parameter literal: `Customizado_Projeto_ClientePadraoModuloHttp`. Value that selects CURL: `CURL` (compared after `UCase`).

## URL

Namespace functions (no class):

```basic
Function Encode(pValue As String) As String          ' encodeURIComponent via JScript
Function Decode(pValue As String) As String          ' decodeURIComponent via JScript
Function IsAbsolute(pUrl As String) As Boolean       ' Trim + ToLower starts with "http://" or "https://"
Function NormalizePath(pPath As String) As String    ' strip leading and trailing "/"
Function Join(pBaseUrl As String, pEndpoint As String) As String
Function WithQuery(pUrl As String, pParams As HttpParams) As String
Function Build(pBaseUrl As String, pEndpoint As String, pParams As HttpParams) As String
```

- `Join`: if `pEndpoint` is absolute, return it trimmed and ignore the base. Otherwise `base/endpoint` after `NormalizePath`. Empty side is omitted (no extra slash).
- `WithQuery`: `name=value` pairs encoded with `Encode`, joined by `&`. No params or empty list → URL unchanged. Always adds `?` when the query is non-empty (does not detect an existing `?` on `pUrl`).
- `Build`: `Join`, then split `?` on the result. Session `pParams` are copied first; query already on the URL is decoded and `Define`d on top (URL query wins on name clash). Then `WithQuery`.

## Headers and query params

### `HttpBaseList`

Name/value list. `HttpHeaders` separator `":"`. `HttpParams` separator `"="`.

```basic
Function Define(pName As String, pValue As Integer) As String   ' ToString then Define
Function Define(pName As String, pValue As String) As String    ' Remove(name) then append; returns the stored line
Function Remove(pName As String) As Boolean                     ' True if deleted
Function Take(pName As String) As String                        ' throws if missing
Function Take(pIndex As Integer) As String                      ' full line; throws if index invalid
Function Name(pIndex As Integer) As String
Function Value(pIndex As Integer) As String
Function Value(pName As String) As String                       ' throws if missing
Function Has(pName As String) As Boolean                        ' IndexOfName
Sub Join(pValues As HttpBaseList)                               ' Define each pair (overwrite by name)
Property Count As Integer
Property Separator As String
Property Item(pIndex As Integer) As String                      ' Take(index)
Sub Clear()
```

Throws: `"No value found for the provided name: " & pName`; `"Invalid index: " & pIndex`. `Load` / `AsText` on the base class throw `"Load must be implemented."` / `"AsText must be implemented."` — only subclasses are used.

Name lookup is `StringList.IndexOfName` (separator-aware, not documented as case-insensitive here).

### `HttpHeaders`

```basic
Sub New()
Sub New(pHeaders As StringList)    ' Load(pHeaders.Text)
Sub New(pHeaders As String)        ' e.g. "Content-Type: application/json" & CHAR(13) & CHAR(10) & "X-A: 1"
Function Load(pHeaders As String) As HttpHeaders   ' Clear; empty string stays empty
Function AsText() As String
Function Copy() As HttpHeaders     ' New HttpHeaders(AsText()); caller owns the copy
```

### `HttpParams`

```basic
Sub New()
Sub New(pQuery As String)
Function Load(pUrl As String) As HttpParams
   ' If the string contains "?", only the substring after "?" is parsed.
   ' "&" splits pairs; a segment is kept only when it Contains "=".
Function AsText() As String        ' pairs joined with "&"
Function Copy() As HttpParams
```

Example input: `"https://x/y?a=1&b=2"` or `"a=1&b=2"`. Segment `flag` without `=` is ignored.

## Body and multipart

### `HttpBody`

| Kind | Factory | `ContentType` default | `Raw()` | `AsText()` |
| --- | --- | --- | --- | --- |
| `"empty"` | `New HttpBody()` | `""` | `""` | `""` |
| `"text"` | `FromText(pText, pContentType)` | `"text/plain"` | text | text |
| `"json"` | `FromJson(String)` / `FromJson(TJSONObject)` | `"application/json"` | json text | json text |
| `"bytes"` | `FromBytes(pBytes, pContentType)` | `"application/octet-stream"` | byte payload | `""` |
| `"form"` | `FromForm(pForm, pOwnsForm)` | `pForm.ContentTypeHeader` | `Form.Data()` | `""` |

```basic
Shared Function FromText(pText As String, pContentType As String = "text/plain") As HttpBody
Shared Function FromJson(pJson As String) As HttpBody
Shared Function FromJson(pJson As TJSONObject) As HttpBody
Shared Function FromBytes(pBytes As Variant, pContentType As String = "application/octet-stream") As HttpBody
Shared Function FromForm(pForm As FormData, pOwnsForm As Boolean = False) As HttpBody
   ' pOwnsForm True: Dispose frees the FormData.

Function AsJson() As TJSONObject
   ' Throws "Body is not a valid JSON Object" when not IsJson.

Property IsJson As Boolean
   ' Kind "json", or IsText and trimmed text StartsWith "{" and EndsWith "}".
```

`FromForm` with `pOwnsForm False` (all `HttpClient.Request`/`Post` form overloads): the caller still owns the `FormData`.

### `FormDataPart`

| Field | Role |
| --- | --- |
| `Name` | Form field name |
| `Value` | Text value, or filesystem path when `IsFile` and `ValueRaw` is empty |
| `ValueRaw` | In-memory file bytes (`IsEmpty` → load `Value` from disk) |
| `ContentType` | Part content type |
| `CharSet` | Non-file parts only |
| `Filename` | File parts; if `""`, filename is the path after the last `\` |
| `IsFile` | File vs field |

### `FormData`

| Member | Default |
| --- | --- |
| `Boundary` | `Data7.Criptografar(GetHashCode.ToString())` |
| `Charset` | `"ascii"` (used by `StringToBytes`) |
| `ContentTypeHeader` | `"multipart/form-data; boundary=" & Boundary` |

```basic
Sub Append(pName As String, pValue As String, pContentType As String = "plain/text", pCharSet As String = "")
Sub AppendFile(pName As String, pValue As String, pContentType As String, pFilename As String = "")
   ' pValue = path on disk.
Sub AppendFile(pName As String, pValue As Variant, pContentType As String, pFilename As String)
   ' pValue = bytes (ValueRaw).
Sub Sett(...)     ' Delete(name) then Append
Sub SetFile(...)  ' Delete(name) then AppendFile
Function Gett(pName As String) As FormDataPart   ' NULL if missing
Function GetAll(pName As String) As StringList   ' new list; AddObject name -> part
Sub Delete(pName As String)                      ' all parts with that name
Function Has(pName As String) As Boolean         ' IndexOf on the stored name
Function Entries() As StringList                 ' internal list; do not Free
Function Keys() As StringList                    ' new list of names; caller owns
Function Count() As Integer
Function Data() As Variant                       ' multipart bytes
Function StringToBytes(pText As String) As Variant
```

`_parts.OwnsObjects = True`: `FormData.Free` frees parts. Duplicate names are allowed via `Append`; `Sett`/`SetFile` replace all with that name. Default field content type literal: `"plain/text"`.

## Request and response

### `HttpRequest`

Built by `HttpClient`; also constructible for a custom transport.

```basic
Sub New(pMethod As HttpMethod, pUrl As String, pHeaders As HttpHeaders, pBody As HttpBody, pCertificate As TCertificate, pTimeout As Integer)
```

| Member | Default / ownership |
| --- | --- |
| `Method` | constructor |
| `Url` | constructor |
| `Timeout` | `10000` if not set |
| `Headers` | constructor; **freed** on `Dispose` |
| `Body` | constructor; **not** freed |
| `Certificate` | constructor; **not** freed |
| `Verb` | `Method.AsString`, or `"GET"` if `Method` is unassigned |

### `HttpResponse`

```basic
Sub New(pStatus As Integer, pStatusText As String, pHeaders As String, pBodyText As String, pBodyData As Variant)
   ' Headers parsed as HttpHeaders(pHeaders).
   ' ContentType from header "Content-Type" when present.
   ' ContentLength from header "Content-Length" when present, else pBodyText.Length.
```

| Member | Meaning |
| --- | --- |
| `Status` | HTTP status |
| `StatusText` | Reason phrase |
| `IsSuccessful` | `Status >= 200 And Status < 300` |
| `Headers` | Parsed response headers |
| `ContentType` | From `Content-Type` header (may be `""`) |
| `Body` | `HttpResponseData` |
| `Data` | Same object as `Body` |

`Dispose` frees headers and body data.

### `HttpResponseData`

| Member | Behavior |
| --- | --- |
| `ContentType` / `ContentLength` | Copied from the response |
| `IsJson` | Trimmed text `{…}` |
| `IsArray` | Trimmed text `[…]` |
| `AsText` | Body text |
| `AsJson` | `New TJSONObject(_text)`; throws `"Response is not a valid JSON Object"` |
| `AsArray` | `New TJSONArray(_text)`; throws `"Response is not a valid JSON Array"` |
| `Raw()` | Original payload (`Variant`; string or bytes depending on transport) |

```basic
Function SaveToFile(pPath As String, pOverWrite As Boolean = True) As String
   ' String payload: UTF-8 text stream. Else binary ADODB.Stream.
   ' pOverWrite True -> SaveToFile mode 2; False -> mode 1 (fail if exists).
   ' Returns pPath. Throws "Failed to save response to file: …".
```

## Transports

### `IHttpTransport`

```basic
Overridable Function Send(pReq As HttpRequest) As HttpResponse
   ' Base implementation throws "Send must be implemented by the transport."
```

### `WinHttpTransport`

`WinHttp.WinHttpRequest.5.1`, synchronous `Open`. Timeouts: all four WinHttp slots = `pReq.Timeout`.

Client certificate:

1. If `Certificate.Use` and `Path <> ""`, call `Certificate.Install()`.
2. After `Open`, try each string from `Certificate.WinHttpLocators()` via `SetClientCertificate`.
3. If none succeed and (`Path <> ""` or `Locator` is non-blank), throw `"Não foi possível selecionar o certificado do cliente no WinHttp. Locator=" & Locator & " Name=" & Name`.
4. If `Use` is False, or no path/locator, certificate setup is a no-op.

Send: `Body.Raw()` — non-empty `Array` or non-blank `String` is passed to `Send`; otherwise `Send()` with no payload. Failures wrap as `"Request failed: " & message & CHAR(13) & "URL: " & url`.

### `CurlTransport`

Builds a `mod_curl.Curl` per `Send`: `Method = Verb`, `Url`, `TimeoutMs = Timeout`. If `Certificate.Use` and `Path <> ""`, `UsePfx(Path, Pass)`.

- Multipart: does not forward the request `Content-Type` header (curl sets the multipart boundary).
- Form files: path from `Value`, or a temp file from `ValueRaw` (tracked on the curl helper).
- Bytes: temp file + `AddDataBinaryFile`.
- Text/json: `AddBody` when trimmed text is non-empty.

Same `"Request failed: …"` wrapper. Temp files are released with the curl helper.

### `Data7Transport`

Native `THTTP`. Throws before send when:

- Verb is not `GET` / `POST` / `PUT` (message includes the verb; `"Use WinHttp or Curl."`).
- Body `IsBytes` or `IsForm`.
- `Certificate.Use` and (`Locator` or `Path` is non-empty).

Maps `Accept` and `Content-Type` onto `THTTP`; other headers via `AddCustomHeader("Name: value")`. Response headers exposed here are only `Content-Type` when native `ContentType <> ""`. `StatusText` is `"OK"` for 200..299, else `"Error"`. Body prefers `native.ResponseText` when non-empty, else the Get/Post/Put return value.

### `MockTransport`

| Field | Default |
| --- | --- |
| `DefaultStatus` | `200` |
| `DefaultStatusText` | `"OK"` |
| `DefaultHeaders` | `"Content-Type: application/json"` |
| `DefaultBody` | `"{}"` |
| `CallCount` | `0` |
| `LastMethod` / `LastUrl` / `LastHeadersText` / `LastBodyText` / `LastTimeout` | last `Send` |

```basic
Sub Enqueue(pStatus As Integer, pBody As String, pHeaders As String = "Content-Type: application/json", pStatusText As String = "OK")
```

`Send`: increment `CallCount`, record verb/url/headers/`Body.AsText()` (empty for form/bytes)/timeout. If the queue is non-empty, dequeue FIFO; else use defaults. Response `pBodyData` is the same string as `pBody`. Never throws.

`LastBodyText` for multipart/bytes is `""` because `HttpBody.AsText` returns `""` for those kinds.

## Interceptors

### `HttpInterceptor`

```basic
Overridable Sub OnRequest(pReq As HttpRequest)                          ' default no-op
Overridable Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
   ' default returns pRes
```

### `BearerAuth`

```basic
Sub New(pToken As String)
' OnRequest: Headers.Define("Authorization", "Bearer " & token)
```

### `BasicAuth`

```basic
Sub New(pUser As String, pPass As String)
' OnRequest: Headers.Define("Authorization", "Basic " & (user & ":" & pass).ToBase64())
```

## Client certificates (this module)

`HttpClient.Certificate` is a `TCertificate` (`mod_certificate`). This module does not define that class. Transports use:

| Member | Used by |
| --- | --- |
| `Use` (default `True` on a new `TCertificate`) | all three live transports |
| `Path`, `Pass` | WinHttp install + Curl `UsePfx` |
| `Install()` | `WinHttpTransport` before `Open` |
| `WinHttpLocators()` | `WinHttpTransport` `SetClientCertificate` |
| `Locator`, `Name` | WinHttp error text; Data7 reject |

Set `Certificate.Use = False` to skip client certs while leaving a loaded PFX on the session. `HttpClient.Free` frees the session certificate (`CleanOnFree` is a `mod_certificate` concern).

```basic
client.Certificate.Load("C:\certs\client.pfx", "secret")
' WinHttp: Install + locators. Curl: PFX file + password. DevStudio: throws if Use and Path/Locator set.
```

## Callback listener

### `HttpCallback`

One-shot `HttpListener` on `http://localhost:{port}/` via PowerShell. Not an HTTP client.

| Member | Meaning |
| --- | --- |
| `Active` | True while the sync process is running |
| `Output` | JSON captured from PowerShell stdout |
| `OutputAsJson` | `New TJSONObject(Output)` |
| `OnFinish` | `TNotifyEvent`; invoked with `me` after a sync listen |

```basic
Sub Start(pPort As Integer, pAsync As Boolean)
   ' False: block (ProcessMessages + Sleep 10) until one request, then OnFinish, then Stopp.
   ' True: Forms.Timer 50ms then the same sync Start.

Sub Stopp()
   ' If Active, Terminate the process.

Shared Function Listen(pPort As Integer, pAsync As Boolean) As HttpCallback
Shared Function Listen(pPort As Integer, pAsync As Boolean, pOnFinish As TNotifyEvent) As HttpCallback
```

`Output` JSON object keys (literals): `method`, `url`, `path`, `query`, `headers`, `body`. The listener answers the browser with HTML `"Processo concluído com sucesso!"` and then stops.

`Free` calls `Stopp`.

## Extending (Consumer Project)

```basic
' Custom transport
Class TMyTransport
   Inherits IHttpTransport
   Overrides Function Send(pReq As HttpRequest) As HttpResponse
      Send = New HttpResponse(200, "OK", "Content-Type: text/plain", "ok", "ok")
   End Function
End Class

Dim client As HttpClient = Http.FromTransport(New TMyTransport(), "https://api.example.com")

' Interceptor
Class TAddHeader
   Inherits HttpInterceptor
   Overrides Sub OnRequest(pReq As HttpRequest)
      pReq.Headers.Define("X-App", "1")
   End Sub
   Overrides Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
      AfterRequest = pRes
   End Function
End Class
client.Use(New TAddHeader())

' Client hooks
Class THookedClient
   Inherits HttpClient
   Overrides Sub OnRequest(pReq As HttpRequest)
      pReq.Headers.Define("X-Hook", "on")
   End Sub
   Overrides Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
      AfterRequest = pRes
   End Function
End Class
```

No UI types are registered by this module. `HttpCallback` is the only Forms-related helper (`Forms.Timer` when `pAsync` is True).

## Tests

- `tests.THttpTest.RunAll()` — enums, URL join/encode, headers/params, body, form, `TCertificate` defaults, curl dump-header parse (redirect uses last status), `HttpResponse`, mock GET/POST/queue/last-request, Bearer/Basic, interceptor 401 replace, subclass hooks, factories (`Http.Mock`, `Http.FromTransport`).
- `tests_live.THttpLiveTest.RunAll()` — optional network: `Http.WinHttp` and `Http.Curl` GET `https://httpbin.org/get`. Not part of `THttpTest.RunAll`.

## Module Notes

- `HttpClient` owns `Headers`, `Params`, `Certificate`, interceptor list, and `Transport` when `pOwnsTransport` is True (all facade factories).
- `HttpRequest.Dispose` frees only the header copy. `Body` and `Certificate` stay with the caller / client.
- `HttpBody.FromForm(..., False)` (client overloads) does not take ownership of `FormData`.
- `FormData.Entries()` is the live internal `StringList`; `Keys()` / `GetAll()` allocate new lists.
- `MockTransport` records `LastBodyText` from `AsText()`, so form/bytes look empty in that field; queue is FIFO then defaults.
- `Http.DefaultKind` reads `Customizado_Projeto_ClientePadraoModuloHttp`; only `CURL` selects CURL, otherwise WinHttp.
- `Data7Transport` supports GET/POST/PUT text only and rejects client certificates; `WinHttpTransport` / `CurlTransport` are the mTLS paths.
- `HttpCallback` listens for a **single** request on `http://localhost:{port}/` and then stops.
