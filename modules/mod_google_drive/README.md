# mod_google_drive

Google Drive API v3 core engine for Data7: files/folders CRUD, resumable uploads of large backups, ranged downloads, permissions, and about/quota. It does **not** implement OAuth, UI forms, comments, shared-drive admin, revisions, changes/watch, or Discovery-JSON code generation.

Version **1.0.0.0**. Dependencies (`data7.json`): `mod_http` `2.1.3.0`, `mod_google_auth` `1.0.0.0`, `mod_certificate` `1.0.0.0` (local MD5 via `certutil`; `mod_io` and `mod_data7_utils` come transitively with `mod_http`).

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Open a `.bas` file only to confirm a detail that is not stated here. Never edit files under `data7_modules/`.

The Discovery documents in `docs/api-v3-drive-rest.json` and `docs/api-v2-drive-rest.json` are offline reference only. They are **not** loaded at runtime. The engine speaks **v3 on the wire**. v2 stays as historical reference. A future v4 is a new endpoints subclass plus a catalog branch.

## Quick Start (Minimal)

```basic
Imports google_auth
Imports google_auth_config
Imports google_auth_store
Imports google_auth_stores
Imports google_drive
Imports google_drive_scopes
Imports google_drive_upload_options

Dim cfg As GoogleAuthConfig = GoogleAuthConfig.FromFile("google-oauth.json")
cfg.Scopes.Add(GoogleDriveScopes.Drive())

Dim store As GoogleTokenStore = GoogleTokenStores.Json("google-tokens.json")
Dim auth As GoogleAuthService = GoogleAuthService.Load(cfg, store)

Dim drive As GoogleDriveService = GoogleDriveService.Load(auth)
Dim options As New GoogleDriveUploadOptions()
options.Name = "erp-backup.zip"
options.ParentId = folderId
options.SessionFile = "google-drive-upload-session.json"
Dim uploaded As GoogleDriveFile = drive.Files().Upload("C:\Backups\erp-backup.zip", options)
drive.Files().VerifyUpload("C:\Backups\erp-backup.zip", uploaded)
```

`Load` throws if `pAuth` is unassigned. It creates a **separate** Drive `HttpClient` with **WinHTTP** (do not reuse `GoogleAuthHttp`). Binary PUT uses `HttpBody.FromStreamWindow` on a typed `TFileStream` so each chunk is one ADODB `IStream` (not the whole backup, not a Data7 `String`, not a temp file). It sets `FollowRedirects = False` so `308 Resume Incomplete` is a status, copies `RetryCount` / `RetryBaseDelayMs` onto the client (http retries 429/5xx, never 308), and attaches `GoogleBearerInterceptor`. Per-request headers go on the request copy (`HttpClient.Request(..., extra)`); session `Headers` are not mutated. Media GET/export calls `WantText = False` so WinHTTP skips `ResponseText`. Range helpers use `HttpRange`. Pause/cancel stay in Drive — do not use `HttpDownload.ToFile`.

Tests and custom transports use `GoogleDriveService.FromHttp(httpLayer, config)`.

## Namespace Map

| File | Namespace | Types |
| --- | --- | --- |
| `src/core/google_drive_enums.bas` | `google_drive_enums` | `GoogleDriveApiVersion` |
| `src/core/google_drive_errors.bas` | `google_drive_errors` | `GoogleDriveErrors` |
| `src/core/google_drive_client.bas` | `google_drive_client` | `GoogleDriveClient` |
| `src/core/google_drive_capabilities.bas` | `google_drive_capabilities` | `GoogleDriveCapabilities` |
| `src/core/google_drive_scopes.bas` | `google_drive_scopes` | `GoogleDriveScopes` |
| `src/core/google_drive_mime.bas` | `google_drive_mime` | `GoogleDriveMime` |
| `src/core/google_drive_progress.bas` | `google_drive_progress` | `GoogleDriveProgressDel` |
| `src/config/google_drive_config.bas` | `google_drive_config` | `GoogleDriveConfig` |
| `src/endpoints/google_drive_endpoints.bas` | `google_drive_endpoints` | `GoogleDriveEndpoints` |
| `src/endpoints/google_drive_endpoints_v3.bas` | `google_drive_endpoints_v3` | `GoogleDriveEndpointsV3`, `GoogleDriveEndpointCatalog` |
| `src/validation/google_drive_validation.bas` | `google_drive_validation` | `GoogleDriveValidator` |
| `src/http/google_drive_json.bas` | `google_drive_json` | `GoogleDriveJson` |
| `src/http/google_drive_http.bas` | `google_drive_http` | `GoogleDriveHttp` |
| `src/domain/google_drive_user.bas` | `google_drive_user` | `GoogleDriveUser` |
| `src/domain/google_drive_quota.bas` | `google_drive_quota` | `GoogleDriveQuota` |
| `src/domain/google_drive_about.bas` | `google_drive_about` | `GoogleDriveAbout` |
| `src/domain/google_drive_file.bas` | `google_drive_file` | `GoogleDriveFile` |
| `src/domain/google_drive_file_list.bas` | `google_drive_file_list` | `GoogleDriveFileList` |
| `src/domain/google_drive_permission.bas` | `google_drive_permission` | `GoogleDrivePermission` |
| `src/domain/google_drive_permission_list.bas` | `google_drive_permission_list` | `GoogleDrivePermissionList` |
| `src/domain/google_drive_list_options.bas` | `google_drive_list_options` | `GoogleDriveListOptions` |
| `src/domain/google_drive_upload_options.bas` | `google_drive_upload_options` | `GoogleDriveUploadOptions` |
| `src/domain/google_drive_upload_control.bas` | `google_drive_upload_control` | `GoogleDriveUploadControl` |
| `src/domain/google_drive_download_options.bas` | `google_drive_download_options` | `GoogleDriveDownloadOptions` |
| `src/domain/google_drive_upload_session.bas` | `google_drive_upload_session` | `GoogleDriveUploadSession` |
| `src/query/google_drive_query.bas` | `google_drive_query` | `GoogleDriveQuery` |
| `src/media/google_drive_chunk_source.bas` | `google_drive_chunk_source` | `GoogleDriveChunkSource` |
| `src/media/google_drive_file_stream.bas` | `google_drive_file_stream` | `GoogleDriveFileStream` |
| `src/media/google_drive_memory_stream.bas` | `google_drive_memory_stream` | `GoogleDriveMemoryStream` |
| `src/media/google_drive_uploader.bas` | `google_drive_uploader` | `GoogleDriveUploader` |
| `src/media/google_drive_integrity.bas` | `google_drive_integrity` | `GoogleDriveIntegrity` |
| `src/media/google_drive_downloader.bas` | `google_drive_downloader` | `GoogleDriveDownloader` |
| `src/services/google_drive_files.bas` | `google_drive_files` | `GoogleDriveFiles` |
| `src/services/google_drive_permissions.bas` | `google_drive_permissions` | `GoogleDrivePermissions` |
| `src/services/google_drive_about_resource.bas` | `google_drive_about_resource` | `GoogleDriveAboutResource` |
| `src/runtime/google_drive.bas` | `google_drive` | `GoogleDriveService` |
| `src/tests/google_drive_tests.bas` | `google_drive_tests` | `GoogleDriveTests` |
| `src/tests/google_drive_live.bas` | `google_drive_live` | `GoogleDriveLive` |
| `src/tests/google_drive_live_coverage.bas` | `google_drive_live_coverage` | `GoogleDriveLiveCoverage` |

## Enums and scopes

```basic
Enun GoogleDriveApiVersion
   V3 = "V3"
End Enun

GoogleDriveScopes.Drive()                  ' https://www.googleapis.com/auth/drive
GoogleDriveScopes.DriveFile()
GoogleDriveScopes.DriveReadonly()
GoogleDriveMime.FolderType()               ' application/vnd.google-apps.folder
```

Catalog: `GoogleDriveEndpointCatalog.Make(GoogleDriveApiVersion.V3())` / `MakeByName("V3")`. Any other name throws `GoogleDriveErrors.UnknownApiVersion`.

## Facade (`GoogleDriveService`)

```basic
Shared Function Load(pAuth As GoogleAuthClient, pConfig As GoogleDriveConfig = Null) As GoogleDriveService
Shared Function FromHttp(pHttp As GoogleDriveHttp, pConfig As GoogleDriveConfig, pOwnsHttp As Boolean = True) As GoogleDriveService
```

| Method | Behavior |
| --- | --- |
| `Files()` | `GoogleDriveFiles` — list/get/folder/update/copy/trash/delete/upload/verify/download/export |
| `Permissions()` | `GoogleDrivePermissions` — list/get/add/update/delete |
| `About()` | `GoogleDriveAboutResource.Gett()` and `EnsureCanUpload` |
| `ApiVersionName()` | `"V3"` |
| `Capabilities()` | Core backup flags |

**Ownership:** `Free()` frees HTTP when owned, plus files/permissions/about/uploader/downloader. It does **not** free the `GoogleAuthClient` passed to `Load`. Default `GoogleDriveConfig` created inside `Load` is owned.

Do not name variables `file` or `http` (Data7 identifiers are case-insensitive). Use `driveFile`, `httpLayer`.

## Config

| Field | Default | Notes |
| --- | --- | --- |
| `ApiVersion` | `V3` | Catalog key |
| `Timeout` | `300000` | Milliseconds; `mod_http` default 10s is too low for backups |
| `RetryCount` | `3` | Copied to `HttpClient.RetryCount`. Extra tries on 429/500/502/503/504. `308` is not retried. |
| `RetryBaseDelayMs` | `1000` | Copied to `HttpClient.RetryBaseDelayMs`. Exponential; `Retry-After` wins when present. |
| `ChunkSizeBytes` | `8388608` (8 MiB) | PUT size (and ceiling if adaptive). Must be a multiple of 256 KiB. rclone Drive / S3 / GCS default. Raise it for fat pipes. Download GETs ignore this ceiling and stay at 8 MiB — WinHTTP buffers each response in memory. |
| `AdaptiveChunkSize` | `False` | When True, after each `308` the next chunk doubles if the PUT finished in under 5s, or halves if it took more than 20s (still capped by `ChunkSizeBytes`). A failed PUT also halves (floor 256 KiB). Off by default: modern clients keep a constant size. |
| `FileFields` | id,name,mimeType,parents,size,md5Checksum,trashed,createdTime,modifiedTime,webViewLink | Always sent |
| `SupportsAllDrives` | `True` | Query flag on file/permission calls |

## Files

```basic
Function List(pOptions As GoogleDriveListOptions) As GoogleDriveFileList
Function Gett(pFileId As String) As GoogleDriveFile
Function CreateFolder(pName As String, pParentId As String = "") As GoogleDriveFile
Function Update(pDriveFile As GoogleDriveFile, pAddParents As String = "", pRemoveParents As String = "") As GoogleDriveFile
Function Copy(pFileId As String, pName As String, pParentId As String = "") As GoogleDriveFile
Function Trash(pFileId As String) As GoogleDriveFile
Sub Delete(pFileId As String)
Function Upload(pPath As String, pOptions As GoogleDriveUploadOptions) As GoogleDriveFile
Function VerifyUpload(pPath As String, pDriveFile As GoogleDriveFile) As GoogleDriveFile
Function Download(pFileId As String, pDestPath As String) As String
Function DownloadFile(pDriveFile As GoogleDriveFile, pOptions As GoogleDriveDownloadOptions) As String
Function Export(pFileId As String, pDestPath As String, pExportMime As String = "") As String
Function ExportFile(pDriveFile As GoogleDriveFile, pDestPath As String, pExportMime As String = "", pOptions As GoogleDriveDownloadOptions = Null) As String
```

Query helper:

```basic
Dim q As New GoogleDriveQuery()
q.NameEquals("backup.zip")
q.Trashed(False)
q.ParentsIn(folderId)
options.Query = q.AsString()

Dim sharedQ As New GoogleDriveQuery()
sharedQ.SharedWithMe()
sharedQ.Starred()
listOptions.Query = sharedQ.AsString()
listOptions.DriveId = sharedDriveId   ' sets corpora=drive when Corpora is empty
```

## Upload (resumable)

Binary files always use the v3 resumable protocol (`uploadType=resumable`). Folders stay a JSON `files.create`.

1. POST session (`X-Upload-Content-Type`, `X-Upload-Content-Length`) and reads `Location`
2. PUT chunks with `Content-Range: bytes start-end/total` (inclusive end, 256 KiB multiples). Disk sources keep a typed `TFileStream` and send each PUT as `HttpBody.FromStreamWindow` (one chunk copied into an ADODB `IStream` — peak RAM is the chunk, not the backup). In-memory test sources use `HttpBody.FromBytes` of that chunk. Default chunk is **8 MiB** and **constant**. Set `GoogleDriveConfig.ChunkSizeBytes` to raise it. Set `AdaptiveChunkSize = True` to start at 8 MiB and grow/shrink up to that ceiling (fast `308` doubles, slow `308` or send failure halves; resume from the session `Range`). `GoogleDriveLive` turns adaptive on with a 256 MiB ceiling.
3. Treats `308 Resume Incomplete` + `Range` as progress (`HttpClient.FollowRedirects = False`)
4. Optionally writes `GoogleDriveUploadSession` JSON (`SessionFile`) so an interrupted backup can resume. Resume only if `session_uri`, `file_path`, and `total_bytes` match the current file; a leftover session from another file is discarded. Missing, empty, or invalid JSON starts a new session — `TPath.GetTempFileName()` creates an empty file, so delete it first or point at a path that does not exist yet.
5. Calls `About.EnsureCanUpload` when `CheckQuota` is True (default)
6. Invokes `GoogleDriveUploadOptions.OnProgress(bytesSent, totalBytes)` after each chunk (`GoogleDriveProgressDel`). Consumers can show a percent bar; sizes are `Int64` — do not `CStr` them.
7. Cooperative **pause** / **cancel** via `GoogleDriveUploadOptions.DownloadControl` (`GoogleDriveUploadControl`) — the same field name as download. Do not name it `UploadControl` or `HaltGate`: Data7 resolves those as a cast to `GoogleDriveUploadControl` (AV at `00000004`). The current PUT always finishes (`Send` is blocking). Between chunks the uploader honors flags already set, then calls `Forms.ProcessMessages()` (ignored if there is no UI) and checks again: **pause** persists `SessionFile` and throws `GoogleDriveErrors.UploadPaused()`; **cancel** wins if both are set, deletes `SessionFile`, and throws `GoogleDriveErrors.UploadCancelled()`. Call `Upload` again with the same `SessionFile` to resume a pause. `RequestPause` / `RequestCancel` are safe from a button or from `OnProgress`. The caller owns the control (options do not `Free` it).

`Upload` does **not** hash the local file. Drive returns `md5Checksum` on the completed blob; the consumer compares when it needs a guarantee:

```basic
Imports google_drive_integrity

Dim uploaded As GoogleDriveFile = drive.Files().Upload(path, options)
drive.Files().VerifyUpload(path, uploaded)

Dim localMd5 As String = GoogleDriveIntegrity.HashLocal(path)
GoogleDriveIntegrity.Verify(path, uploaded)
```

`.txt`, `.xls`, `.zip` and other binary blobs all work. Native Google Docs/Sheets have no `md5Checksum` and throw `ChecksumUnavailable`. `VerifyUpload` `Gett`s metadata when `Md5Checksum` is empty. This is a second full-file read (`certutil -hashfile MD5`); skip it when the extra I/O is not worth it.

```basic
Dim gate As New GoogleDriveUploadControl()
options.SessionFile = "google-drive-upload-session.json"
options.DownloadControl = gate
options.OnProgress = me.ReportUploadProgress
Try
   uploaded = drive.Files().Upload(path, options)
Catch ex As Exception
   If gate.WasPaused() Then
      ' keep SessionFile; later Upload resumes from Drive Range
   ElseIf gate.WasCancelled() Then
      ' session discarded
   Else
      Throw ex
   End If
End Try

Sub OnPauseClick()
   gate.RequestPause()
End Sub

Sub OnCancelClick()
   gate.RequestCancel()
End Sub
```

```basic
options.OnProgress = me.ReportUploadProgress

Sub ReportUploadProgress(pBytesSent As Int64, pTotalBytes As Int64)
End Sub
```

`GoogleDriveFileStream` opens the path with `TFileStream` (`HttpFileIo.OpenForRead`) so size is `Int64` and the backup is never `ADODB.LoadFromFile`. Each PUT is `FromStreamWindow` on that typed stream. Tests can inject `GoogleDriveMemoryStream`. `Load` uses WinHTTP. Do not `FromFile` a multi-GB backup on WinHTTP (the whole PUT body would buffer; throws above 2 GiB). Data7Transport rejects bytes/files/streams. CURL remains available via `Http.Curl` if a consumer injects it with `FromHttp`.

Zero-byte files are created as metadata-only JSON.

## Download and export

`GET files/{id}?alt=media` for **binary blobs**. When `size` is known and greater than zero, the downloader issues `Range: bytes=start-end`. Default is a **constant** chunk of `min(ChunkSizeBytes, 128 MiB)`. WinHTTP `ResponseBody` holds the **entire GET** in process RAM (Data7 is 32-bit). Adaptive download starts at 8 MiB and doubles after a GET under 5s (or halves if over 20s), capped at **128 MiB**. Live 256 MiB GETs throw `Out of memory` (the downloader shrinks and retries); 128 MiB GETs complete (`mod_http` 2.1.3 drops the `WinHttpRequest` after each media GET). Upload may still grow to 256 MiB. `GoogleDriveDownloadOptions.ChunkSizeBytes` below 256 KiB stays as-is (mock/live pause tests). Each media GET uses `WantText = False`. Each range is **appended with `TFileStream`**. Peak RAM is a few copies of **one GET**, not the file. Do not use `HttpDownload.ToFile`.

Cooperative **pause** / **cancel** uses the same `GoogleDriveUploadControl` on `GoogleDriveDownloadOptions.DownloadControl`. Pause keeps the partial file; cancel deletes it. Call `DownloadFile` again with `ResumePartial = True` to continue from the bytes already on disk. Native Google Docs/Sheets/Slides **cannot** use `alt=media` — `Download` throws `WorkspaceExportRequired`. Use `Export` (`GET files/{id}/export?mimeType=`). Default export: spreadsheet → xlsx, document → docx, presentation → pptx, otherwise PDF.

`.xls` / `.xlsx` / `.doc` / `.docx` / `.ppt` / `.pptx` / `.csv` map to Office MIME on upload (`GoogleDriveMime.FromPath`). They stay blobs and keep `md5Checksum`.

## About and permissions

- `About.Gett()` maps `user`, `storageQuota`, `maxUploadSize`
- Byte sizes (`SizeBytes`, quota, `maxUploadSize`, Content-Range) are Data7 `Int64`. Do not use `Long`/`Integer`/`CStr` for them: `Long` is 32-bit. `HttpHeaders.Define` accepts `Int64` (`mod_http` 2.1).
- Unlimited quota: `storageQuota.limit` absent → `HasLimit = False` → no usage gate
- Permissions: `type` is stored as `TypeName` (avoid colliding with the `Type` keyword). `ToJson` omits `allowFileDiscovery` unless it is `True` — sending `false` on create is `fieldNotWritable`.

## Errors

Shared string factories on `GoogleDriveErrors`, thrown as `Throw New Exception(...)`. Google JSON `{ "error": { "message", "errors": [{ "reason" }] } }` is flattened into a **single-line** message (`RequestFailed` does not embed `CHAR(13)` — CR in `Exception`/`print` is an OLE `EOleException`).

## Tests

`GoogleDriveTests.RunAll()` uses `Http.Mock` only. No live Google network. It covers list/query (including shared-drive `driveId`, `NameContains`/`Raw`), MIME map, capabilities, endpoints, folder create, get/update/copy/trash/restore/delete, permissions CRUD, about/quota, Google error JSON, resumable upload, pause/cancel/resume, empty upload, `TFileStream` window read, range download, `WantText=False` on media, download pause/cancel/resume, native-file export and export guards, integrity (`TCertUtil.HashFile`), `HttpRange` wrappers, `DateTime()` elapsed text, and `Load` auth. Failed mocks throw so live does not run. Integrity tests still do not call Google.

`src/Principal.bas` runs `GoogleDriveTests.RunAll()` and then `GoogleDriveLive.Run()`. Live signs in with `google-oauth.json` / `google-tokens.json`, finds or creates the Drive folder `mod_google_drive`, and uploads a local file. It first asks whether to pick a test file (`TDialogs.OpenFile`); if you decline, it uses `source_path` from `google-drive-live.json` or writes `live-upload-sample.txt`. Chunked uploads print `Enviando: N%` via `OnProgress`. After `Upload` it calls `VerifyUpload`, then **downloads** the same file with `OnProgress` in 8 MiB ranges and compares MD5. `GoogleDriveLiveCoverage` then hits list, copy/trash/delete, permissions list/get (anyone create is skipped: this Google account returns `403 fieldNotWritable`, and catching that live `Exception` is an uncatchable Data7 `EOleException`), empty upload, Workspace export, and pause/resume/cancel on a 400 KiB blob with 256 KiB chunks. Live log lines are prefixed with `TDateTime.ToString("hh:mm:ss.zzz")`. Upload/download totals use `GoogleDriveJson.ElapsedText` with `DateTime()` (not `Now()`, which is date-only, and not `SecondSpan`). Optional `google-drive-live.json` can set `folder_id`, `folder_name`, and `source_path`. Credentials stay gitignored.

## Out of scope (next)

comments, replies, revisions, changes, channels, drives/teamdrives, apps, labels, accessproposals, approvals, `files.download` long-running operations, Service Account auth (blocked in `mod_google_auth`).
