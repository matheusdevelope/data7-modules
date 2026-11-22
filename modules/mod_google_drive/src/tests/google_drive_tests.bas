Imports Collections
Imports TFile
Imports TPath
Imports mod_tobject
Imports http_client
Imports http_mock
Imports google_drive
Imports google_drive_config
Imports google_drive_enums
Imports google_drive_endpoints
Imports google_drive_endpoints_v3
Imports google_drive_http
Imports google_drive_file
Imports google_drive_file_list
Imports google_drive_about
Imports google_drive_permission
Imports google_drive_permission_list
Imports google_drive_query
Imports google_drive_scopes
Imports google_drive_mime
Imports google_drive_list_options
Imports google_drive_upload_options
Imports google_drive_upload_control
Imports google_drive_download_options
Imports google_drive_upload_session
Imports google_drive_memory_stream
Imports google_drive_file_stream
Imports http_file_io
Imports mod_data7_utils_file_stream
Imports google_drive_integrity
Imports google_drive_validation
Imports google_drive_json
Imports google_drive_errors
Imports google_drive_capabilities

Namespace google_drive_tests

   Class GoogleDriveTests
      Inherits TTObject

      Passed As Integer
      Failed As Integer
      Private _failures As StringList
      Private _haltGate As GoogleDriveUploadControl
      Private _progressTicks As Integer

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
      End Sub

      Shared Sub RunAll()
         Dim suite As New GoogleDriveTests()
         suite.Run()
         suite.Free()
      End Sub

      Sub Run()
         print("==== mod_google_drive ====")
         me.TestEnums()
         me.TestScopesAndMime()
         me.TestEndpointsCatalog()
         me.TestUnknownVersion()
         me.TestChunkSizeValidation()
         me.TestAdaptiveChunk()
         me.TestQueryBuilder()
         me.TestFileJson()
         me.TestAboutJsonAndQuota()
         me.TestPermissionJson()
         me.TestListFiles()
         me.TestCreateFolder()
         me.TestGetUpdateCopyTrashDelete()
         me.TestPermissionsCrud()
         me.TestAboutGet()
         me.TestResumableUpload()
         me.TestResumeSession()
         me.TestPauseKeepsSession()
         me.TestPauseAfterChunk()
         me.TestCancelClearsSession()
         me.TestMismatchedSessionStartsNew()
         me.TestQuotaRejected()
         me.TestRangeDownload()
         me.TestDownloadOnce()
         me.TestDownloadPauseAndCancel()
         me.TestDownloadResume()
         me.TestWorkspaceDownloadRejected()
         me.TestExportWorkspace()
         me.TestEmptyUpload()
         me.TestFileStreamChunk()
         me.TestListSharedDrive()
         me.TestIntegrityChecksums()
         me.TestVerifyUploadRefreshesMd5()
         me.TestUploadIntegrity()
         me.TestLoadRequiresAuth()
         me.TestCapabilitiesAndVersion()
         me.TestMimeAndQueryExtras()
         me.TestRangeAndElapsedHelpers()
         me.TestWantTextOnMedia()
         me.TestGoogleErrorBody()
         me.TestExportGuards()
         me.PrintSummary()
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            print("  OK    " + pMsg)
         Else
            me.Failed = me.Failed + 1
            me._failures.Add(pMsg)
            print("  FAIL  " + pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=[" + pGot + "] esperado=[" + pWant + "])")
      End Sub

      Sub PrintSummary()
         print("----")
         print("Passed: " + CStr(me.Passed) + "  Failed: " + CStr(me.Failed))
         If me.Failed > 0 Then
            print(me._failures.Text)
            Throw New Exception("google drive tests failed: " + CStr(me.Failed))
         End If
      End Sub

      Function SampleConfig() As GoogleDriveConfig
         Dim cfg As New GoogleDriveConfig()
         cfg.RetryCount = 0
         SampleConfig = cfg
      End Function

      Function FreshSessionPath() As String
         Dim sessionPath As String = TPath.GetTempFileName()
         If TFile.Exists(sessionPath) Then
            TFile.Delete(sessionPath)
         End If
         FreshSessionPath = sessionPath
      End Function

      Function SampleHttp(pStatus As Integer, pBody As String) As GoogleDriveHttp
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim mockClient As HttpClient = Http.Mock(pStatus, pBody)
         SampleHttp = New GoogleDriveHttp(mockClient, endpoints, cfg, True)
      End Function

      Function SampleService(pHttp As GoogleDriveHttp) As GoogleDriveService
         SampleService = GoogleDriveService.FromHttp(pHttp, pHttp.Config(), True)
      End Function

      Function FileJson(pId As String, pName As String) As String
         FileJson = "{""kind"":""drive#file"",""id"":""" & pId & """,""name"":""" & pName & """,""mimeType"":""application/zip"",""size"":""1024"",""md5Checksum"":""abc"",""trashed"":false,""parents"":[""root""],""createdTime"":""2024-01-01T00:00:00.000Z"",""modifiedTime"":""2024-01-02T00:00:00.000Z"",""webViewLink"":""https://drive.google.com/file/d/" & pId & """}"
      End Function

      Sub TestEnums()
         print("-- enums")
         me.AssertEq(GoogleDriveApiVersion.V3().AsString, "V3", "ApiVersion.V3")
      End Sub

      Sub TestScopesAndMime()
         print("-- scopes and mime")
         me.AssertEq(GoogleDriveScopes.Drive(), "https://www.googleapis.com/auth/drive", "drive scope")
         me.AssertEq(GoogleDriveMime.FolderType(), "application/vnd.google-apps.folder", "folder mime")
         me.AssertEq(GoogleDriveMime.FromPath("backup.zip"), "application/zip", "zip mime")
         me.AssertEq(GoogleDriveMime.FromPath("plan.xls"), GoogleDriveMime.ExcelXls(), "xls mime")
         me.AssertEq(GoogleDriveMime.FromPath("plan.xlsx"), GoogleDriveMime.ExcelXlsx(), "xlsx mime")
         me.AssertEq(GoogleDriveMime.FromPath("doc.docx"), GoogleDriveMime.WordDocx(), "docx mime")
         me.AssertEq(GoogleDriveMime.FromPath("slides.pptx"), GoogleDriveMime.PowerPointPptx(), "pptx mime")
         me.AssertTrue(GoogleDriveMime.IsWorkspace(GoogleDriveMime.NativeSpreadsheet()), "sheet is workspace")
         me.AssertTrue(Not GoogleDriveMime.IsWorkspace(GoogleDriveMime.FolderType()), "folder is not workspace")
         me.AssertEq(GoogleDriveMime.ExportMimeFor(GoogleDriveMime.NativeSpreadsheet()), GoogleDriveMime.ExcelXlsx(), "export sheet to xlsx")
      End Sub

      Sub TestEndpointsCatalog()
         print("-- endpoints v3")
         Dim endpoints As GoogleDriveEndpoints = GoogleDriveEndpointCatalog.Make(GoogleDriveApiVersion.V3())
         me.AssertEq(endpoints.BaseUrl(), "https://www.googleapis.com/drive/v3/", "base url")
         me.AssertEq(endpoints.ResumableUploadUrl(), "https://www.googleapis.com/resumable/upload/drive/v3/files", "resumable url")
         me.AssertEq(endpoints.FilePath("abc"), "files/abc", "file path")
         me.AssertEq(endpoints.FileExportPath("abc"), "files/abc/export", "export path")
         endpoints.Free()
      End Sub

      Sub TestUnknownVersion()
         print("-- unknown version")
         Dim threw As Boolean = False
         Try
            Dim endpoints As GoogleDriveEndpoints = GoogleDriveEndpointCatalog.MakeByName("V2")
            endpoints.Free()
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "Unknown Google Drive API version") > 0
         End Try
         me.AssertTrue(threw, "v2 catalog throws")
      End Sub

      Sub TestChunkSizeValidation()
         print("-- chunk size validation")
         Dim cfg As New GoogleDriveConfig()
         me.AssertEq(CStr(cfg.ChunkSizeBytes), CStr(GoogleDriveJson.DefaultChunkBytes()), "default 8 MiB")
         me.AssertTrue(Not cfg.AdaptiveChunkSize, "adaptive off by default")
         cfg.ChunkSizeBytes = 1000
         Dim threw As Boolean = False
         Try
            GoogleDriveValidator.Validate(cfg)
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "262144") > 0
         End Try
         me.AssertTrue(threw, "invalid chunk size throws")
         cfg.Free()
      End Sub

      Sub TestAdaptiveChunk()
         print("-- adaptive chunk")
         me.AssertEq(CStr(GoogleDriveJson.GrowChunkBytes(8388608, 268435456)), "16777216", "grow 8 MiB to 16")
         me.AssertEq(CStr(GoogleDriveJson.GrowChunkBytes(268435456, 268435456)), "268435456", "grow capped at max")
         me.AssertEq(CStr(GoogleDriveJson.ShrinkChunkBytes(268435456)), "134217728", "shrink 256 MiB to 128")
         me.AssertEq(CStr(GoogleDriveJson.ShrinkChunkBytes(262144)), "262144", "shrink floor 256 KiB")
         me.AssertEq(CStr(GoogleDriveJson.AlignChunkBytes(1000, 268435456)), "262144", "align up to unit")
         me.AssertEq(CStr(GoogleDriveJson.CapDownloadChunkBytes(268435456, 8388608)), "8388608", "cap honors ceiling")
         me.AssertEq(CStr(GoogleDriveJson.MaxDownloadChunkBytes()), "134217728", "download ceiling 128 MiB")
         me.AssertEq(CStr(GoogleDriveJson.CapDownloadChunkBytes(268435456, GoogleDriveJson.MaxDownloadChunkBytes())), "134217728", "download cap below upload ceiling")
         me.AssertEq(CStr(GoogleDriveJson.CapDownloadChunkBytes(5, 8388608)), "5", "small download ranges stay small")
         me.AssertTrue(GoogleDriveJson.IsMemoryError("Out of memory"), "memory error text")
      End Sub

      Sub TestQueryBuilder()
         print("-- query builder")
         Dim q As New GoogleDriveQuery()
         q.NameEquals("backup.zip")
         q.Trashed(False)
         q.ParentsIn("root")
         me.AssertEq(q.AsString(), "name = 'backup.zip' and trashed = false and 'root' in parents", "query text")
         Dim folderQ As New GoogleDriveQuery()
         folderQ.IsFolder()
         me.AssertTrue(InStr(folderQ.AsString(), "application/vnd.google-apps.folder") > 0, "folder query")
         Dim sharedQ As New GoogleDriveQuery()
         sharedQ.SharedWithMe()
         sharedQ.Starred()
         me.AssertEq(sharedQ.AsString(), "sharedWithMe = true and starred = true", "shared query")
         Dim ownedQ As New GoogleDriveQuery()
         ownedQ.OwnedByMe()
         me.AssertTrue(InStr(ownedQ.AsString(), "me") > 0, "owned query")
         q.Free()
         folderQ.Free()
         sharedQ.Free()
         ownedQ.Free()
      End Sub

      Sub TestFileJson()
         print("-- file json")
         Dim json As TJSONObject = New TJSONObject(me.FileJson("id1", "backup.zip"))
         Dim driveFile As GoogleDriveFile = GoogleDriveFile.FromJson(json)
         me.AssertEq(driveFile.Id, "id1", "file id")
         me.AssertEq(driveFile.Name, "backup.zip", "file name")
         me.AssertTrue(driveFile.SizeBytes = 1024, "file size")
         me.AssertEq(driveFile.Parents.Strings(0), "root", "parent")
         me.AssertEq(driveFile.Md5Checksum, "abc", "md5")
         me.AssertTrue(Not driveFile.IsWorkspace(), "zip is blob")
         json.Free()
         driveFile.Free()
      End Sub

      Sub TestAboutJsonAndQuota()
         print("-- about json and quota")
         Dim json As TJSONObject = New TJSONObject("{""kind"":""drive#about"",""maxUploadSize"":""1000"",""user"":{""displayName"":""Ada"",""emailAddress"":""ada@example.com""},""storageQuota"":{""limit"":""5000"",""usage"":""4000"",""usageInDrive"":""3000"",""usageInDriveTrash"":""100""}}")
         Dim info As GoogleDriveAbout = GoogleDriveAbout.FromJson(json)
         me.AssertEq(info.DriveUser.EmailAddress, "ada@example.com", "about email")
         me.AssertTrue(info.Quota.HasLimit, "has limit")
         me.AssertTrue(info.Quota.Available() = 1000, "available")
         Dim tooBig As Boolean = False
         Try
            info.EnsureCanUpload(2000)
         Catch ex As Exception
            tooBig = InStr(ex._GetMessage(), "exceeds") > 0
         End Try
         me.AssertTrue(tooBig, "max upload size rejects oversized file")
         info.MaxUploadSize = GoogleDriveJson.Zero64()
         Dim quotaBlocked As Boolean = False
         Try
            info.EnsureCanUpload(2000)
         Catch ex As Exception
            quotaBlocked = InStr(ex._GetMessage(), "quota") > 0
         End Try
         me.AssertTrue(quotaBlocked, "quota rejects when max upload size is unlimited")
         Dim hugeSize As Int64 = GoogleDriveJson.ParseInt64("5497558138880")
         me.AssertEq(GoogleDriveJson.Int64Text(hugeSize), "5497558138880", "int64 text")
         Dim hugeMsg As String = GoogleDriveErrors.FileTooLarge(hugeSize, GoogleDriveJson.FromInteger(1))
         me.AssertTrue(InStr(hugeMsg, "5497558138880") > 0, "file too large formats int64")
         json.Free()
         info.Free()
      End Sub

      Sub TestPermissionJson()
         print("-- permission json")
         Dim json As TJSONObject = New TJSONObject("{""id"":""perm1"",""type"":""user"",""role"":""writer"",""emailAddress"":""a@b.com""}")
         Dim item As GoogleDrivePermission = GoogleDrivePermission.FromJson(json)
         me.AssertEq(item.Id, "perm1", "perm id")
         me.AssertEq(item.TypeName, "user", "perm type")
         me.AssertEq(item.Role, "writer", "perm role")
         json.Free()
         item.Free()
      End Sub

      Sub TestListFiles()
         print("-- list files")
         Dim body As String = "{""kind"":""drive#fileList"",""nextPageToken"":""page-2"",""files"":[" & me.FileJson("id1", "a.zip") & "]}"
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(200, body)
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim options As New GoogleDriveListOptions()
         Dim q As New GoogleDriveQuery()
         q.Trashed(False)
         options.Query = q.AsString()
         q.Free()
         Dim listing As GoogleDriveFileList = drive.Files().List(options)
         me.AssertEq(CStr(listing.Files.Length), "1", "list count")
         me.AssertEq(listing.Files.Take(0).Name, "a.zip", "list name")
         me.AssertTrue(listing.HasMore(), "has next page")
         Dim mockTr As MockTransport = CType(httpLayer.Client().Transport, MockTransport)
         me.AssertTrue(InStr(mockTr.LastUrl, "files") > 0, "list url")
         me.AssertTrue(InStr(mockTr.LastUrl, "trashed") > 0, "list q")
         listing.Free()
         options.Free()
         drive.Free()
      End Sub

      Sub TestCreateFolder()
         print("-- create folder")
         Dim body As String = "{""id"":""folder1"",""name"":""Backups"",""mimeType"":""application/vnd.google-apps.folder""}"
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(200, body)
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim folder As GoogleDriveFile = drive.Files().CreateFolder("Backups", "root")
         me.AssertEq(folder.Id, "folder1", "folder id")
         me.AssertTrue(folder.IsFolder(), "is folder")
         Dim mockTr As MockTransport = CType(httpLayer.Client().Transport, MockTransport)
         me.AssertEq(mockTr.LastMethod, "POST", "folder post")
         me.AssertTrue(InStr(mockTr.LastBodyText, "Backups") > 0, "folder name in body")
         folder.Free()
         drive.Free()
      End Sub

      Sub TestGetUpdateCopyTrashDelete()
         print("-- file get/update/copy/trash/delete")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, me.FileJson("id1", "backup.zip"))
         mockTr.Enqueue(200, me.FileJson("id1", "backup2.zip"))
         mockTr.Enqueue(200, me.FileJson("id2", "backup-copy.zip"))
         mockTr.Enqueue(200, "{""id"":""id1"",""name"":""backup2.zip"",""trashed"":true}")
         mockTr.Enqueue(200, "{""id"":""id1"",""name"":""backup2.zip"",""trashed"":false}")
         mockTr.Enqueue(204, "")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim got As GoogleDriveFile = drive.Files().Gett("id1")
         me.AssertEq(got.Name, "backup.zip", "get name")
         got.Name = "backup2.zip"
         Dim updated As GoogleDriveFile = drive.Files().Update(got)
         me.AssertEq(updated.Name, "backup2.zip", "update name")
         Dim copied As GoogleDriveFile = drive.Files().Copy("id1", "backup-copy.zip")
         me.AssertEq(copied.Id, "id2", "copy id")
         Dim trashed As GoogleDriveFile = drive.Files().Trash("id1")
         me.AssertTrue(trashed.Trashed, "trashed")
         trashed.Trashed = False
         Dim restored As GoogleDriveFile = drive.Files().Update(trashed)
         me.AssertTrue(Not restored.Trashed, "restored")
         drive.Files().Delete("id1")
         me.AssertEq(mockTr.LastMethod, "DELETE", "delete method")
         got.Free()
         updated.Free()
         copied.Free()
         trashed.Free()
         restored.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestPermissionsCrud()
         print("-- permissions crud")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{""permissions"":[{""id"":""perm1"",""type"":""user"",""role"":""reader"",""emailAddress"":""a@b.com""}]}")
         mockTr.Enqueue(200, "{""id"":""perm1"",""type"":""user"",""role"":""reader"",""emailAddress"":""a@b.com""}")
         mockTr.Enqueue(200, "{""id"":""perm2"",""type"":""user"",""role"":""writer"",""emailAddress"":""c@d.com""}")
         mockTr.Enqueue(200, "{""id"":""perm2"",""type"":""user"",""role"":""reader""}")
         mockTr.Enqueue(204, "")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim listing As GoogleDrivePermissionList = drive.Permissions().List("id1")
         me.AssertEq(listing.Permissions.Take(0).Id, "perm1", "perm list")
         Dim fetched As GoogleDrivePermission = drive.Permissions().Gett("id1", "perm1")
         me.AssertEq(fetched.EmailAddress, "a@b.com", "perm get")
         Dim createBody As New GoogleDrivePermission()
         createBody.TypeName = "user"
         createBody.Role = "writer"
         createBody.EmailAddress = "c@d.com"
         Dim created As GoogleDrivePermission = drive.Permissions().Add("id1", createBody)
         me.AssertEq(created.Id, "perm2", "perm create")
         created.Role = "reader"
         Dim updated As GoogleDrivePermission = drive.Permissions().Update("id1", created)
         me.AssertEq(updated.Role, "reader", "perm update")
         drive.Permissions().Delete("id1", "perm2")
         me.AssertEq(mockTr.LastMethod, "DELETE", "perm delete")
         listing.Free()
         fetched.Free()
         createBody.Free()
         created.Free()
         updated.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestAboutGet()
         print("-- about get")
         Dim body As String = "{""maxUploadSize"":""5497558138880"",""user"":{""emailAddress"":""ada@example.com""},""storageQuota"":{""usage"":""10""}}"
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(200, body)
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim info As GoogleDriveAbout = drive.About().Gett()
         me.AssertEq(info.DriveUser.EmailAddress, "ada@example.com", "about get email")
         me.AssertTrue(Not info.Quota.HasLimit, "unlimited quota")
         me.AssertEq(GoogleDriveJson.Int64Text(info.MaxUploadSize), "5497558138880", "about max upload size")
         info.Free()
         drive.Free()
      End Sub

      Sub TestResumableUpload()
         print("-- resumable upload")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/1" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         mockTr.Enqueue(200, me.FileJson("up1", "mem.bin"))
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("hello-backup")
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "mem.bin"
         options.CheckQuota = False
         Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
         me.AssertEq(uploaded.Id, "up1", "uploaded id")
         me.AssertTrue(InStr(mockTr.LastUrl, "session/1") > 0, "chunk url is session")
         uploaded.Free()
         source.Free()
         options.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestResumeSession()
         print("-- resume session")
         Dim sessionPath As String = TPath.GetTempFileName()
         Dim seed As New GoogleDriveUploadSession()
         seed.SessionUri = "https://www.googleapis.com/upload/session/resume"
         seed.TotalBytes = GoogleDriveJson.FromInteger(12)
         seed.ToFile(sessionPath)
         seed.Free()
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(308, "", "Range: bytes=0-5" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         mockTr.Enqueue(200, me.FileJson("up2", "mem.bin"))
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("hello-backup")
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "mem.bin"
         options.CheckQuota = False
         options.SessionFile = sessionPath
         Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
         me.AssertEq(uploaded.Id, "up2", "resumed id")
         me.AssertTrue(Not TFile.Exists(sessionPath), "session file cleared")
         uploaded.Free()
         source.Free()
         options.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub RequestPauseOnProgress(pBytesSent As Int64, pTotalBytes As Int64)
         If Assigned(me._haltGate) Then
            me._haltGate.RequestPause()
         End If
      End Sub

      Sub TestPauseKeepsSession()
         print("-- pause keeps session")
         Dim sessionPath As String = me.FreshSessionPath()
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/pause" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("hello-backup")
         Dim gate As New GoogleDriveUploadControl()
         gate.RequestPause()
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "mem.bin"
         options.CheckQuota = False
         options.SessionFile = sessionPath
         options.DownloadControl = gate
         Dim threw As Boolean = False
         Dim haltMsg As String = ""
         Try
            Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
            uploaded.Free()
         Catch ex As Exception
            haltMsg = ex._GetMessage()
            threw = InStr(LCase(haltMsg), "paused") > 0
         End Try
         me.AssertTrue(threw, "pause throws [" & haltMsg & "]")
         me.AssertTrue(gate.WasPaused(), "was paused")
         me.AssertTrue(TFile.Exists(sessionPath), "session kept")
         If TFile.Exists(sessionPath) Then
            TFile.Delete(sessionPath)
         End If
         source.Free()
         options.Free()
         gate.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestPauseAfterChunk()
         print("-- pause after chunk")
         Dim sessionPath As String = me.FreshSessionPath()
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/mid" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         mockTr.Enqueue(308, "", "Range: bytes=0-5" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("hello-backup")
         Dim gate As New GoogleDriveUploadControl()
         me._haltGate = gate
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "mem.bin"
         options.CheckQuota = False
         options.SessionFile = sessionPath
         options.DownloadControl = gate
         options.OnProgress = me.RequestPauseOnProgress
         Dim threw As Boolean = False
         Dim haltMsg As String = ""
         Try
            Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
            uploaded.Free()
         Catch ex As Exception
            haltMsg = ex._GetMessage()
            threw = InStr(LCase(haltMsg), "paused") > 0
         End Try
         me._haltGate = Null
         me.AssertTrue(threw, "pause after 308 throws [" & haltMsg & "]")
         me.AssertTrue(gate.WasPaused(), "was paused after chunk")
         me.AssertTrue(TFile.Exists(sessionPath), "session kept after chunk")
         If TFile.Exists(sessionPath) Then
            TFile.Delete(sessionPath)
         End If
         source.Free()
         options.Free()
         gate.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestCancelClearsSession()
         print("-- cancel clears session")
         Dim sessionPath As String = me.FreshSessionPath()
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/cancel" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("hello-backup")
         Dim gate As New GoogleDriveUploadControl()
         gate.RequestCancel()
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "mem.bin"
         options.CheckQuota = False
         options.SessionFile = sessionPath
         options.DownloadControl = gate
         Dim threw As Boolean = False
         Dim haltMsg As String = ""
         Try
            Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
            uploaded.Free()
         Catch ex As Exception
            haltMsg = ex._GetMessage()
            threw = InStr(LCase(haltMsg), "cancelled") > 0
         End Try
         me.AssertTrue(threw, "cancel throws [" & haltMsg & "]")
         me.AssertTrue(gate.WasCancelled(), "was cancelled")
         me.AssertTrue(Not TFile.Exists(sessionPath), "session discarded")
         source.Free()
         options.Free()
         gate.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestMismatchedSessionStartsNew()
         print("-- mismatched session starts new")
         Dim sessionPath As String = TPath.GetTempFileName()
         Dim seed As New GoogleDriveUploadSession()
         seed.SessionUri = "https://www.googleapis.com/upload/session/old-rar"
         seed.FilePath = "C:\Se7e\Backups\old.rar"
         seed.TotalBytes = GoogleDriveJson.FromInteger(80000000)
         seed.ToFile(sessionPath)
         seed.Free()
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/fresh" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         mockTr.Enqueue(200, me.FileJson("up3", "mem.bin"))
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("hello-backup")
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "mem.bin"
         options.CheckQuota = False
         options.SessionFile = sessionPath
         Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
         me.AssertEq(uploaded.Id, "up3", "new session id")
         me.AssertTrue(InStr(mockTr.LastUrl, "session/fresh") > 0, "did not reuse rar session")
         uploaded.Free()
         source.Free()
         options.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestQuotaRejected()
         print("-- quota rejected on upload")
         Dim aboutBody As String = "{""maxUploadSize"":""100"",""storageQuota"":{""limit"":""100"",""usage"":""90""}}"
         Dim mockClient As HttpClient = Http.Mock(200, aboutBody)
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("0123456789ABCDEF")
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "big.bin"
         options.CheckQuota = True
         Dim threw As Boolean = False
         Try
            Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
            uploaded.Free()
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "quota") > 0
         End Try
         me.AssertTrue(threw, "upload blocked by quota")
         source.Free()
         options.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestRangeDownload()
         print("-- range download")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{""kind"":""drive#file"",""id"":""id1"",""name"":""a.bin"",""size"":""5""}")
         mockTr.Enqueue(206, "HELLO")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim dest As String = TPath.GetTempFileName()
         Dim saved As String = drive.Files().Download("id1", dest)
         me.AssertEq(saved, dest, "download path")
         me.AssertTrue(TFile.Exists(dest), "download exists")
         Dim text As String = TFile.ReadAllText(dest)
         me.AssertEq(text, "HELLO", "download body")
         me.AssertTrue(InStr(mockTr.LastHeadersText, "Range:") > 0 Or InStr(mockTr.LastUrl, "alt=media") > 0, "media request")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         drive.Free()
         endpoints.Free()
      End Sub

      Sub CountDownloadProgress(pBytesSent As Int64, pTotalBytes As Int64)
         me._progressTicks = me._progressTicks + 1
      End Sub

      Sub TestDownloadOnce()
         print("-- download once")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{""kind"":""drive#file"",""id"":""idz"",""name"":""empty.bin""}")
         mockTr.Enqueue(200, "Z")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim dest As String = TPath.GetTempFileName()
         Dim saved As String = drive.Files().Download("idz", dest)
         me.AssertEq(TFile.ReadAllText(saved), "Z", "download once body")
         me.AssertTrue(InStr(mockTr.LastUrl, "alt=media") > 0, "download once media")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestDownloadPauseAndCancel()
         print("-- download pause and cancel")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(206, "HELLO")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim dest As String = TPath.GetTempFileName()
         Dim driveFile As New GoogleDriveFile()
         driveFile.Id = "id1"
         driveFile.SizeText = "10"
         driveFile.SizeBytes = GoogleDriveJson.FromInteger(10)
         Dim gate As New GoogleDriveUploadControl()
         me._haltGate = gate
         me._progressTicks = 0
         Dim options As New GoogleDriveDownloadOptions()
         options.DestinationPath = dest
         options.ChunkSizeBytes = 5
         options.DownloadControl = gate
         options.OnProgress = me.RequestPauseOnProgress
         Dim paused As Boolean = False
         Try
            drive.Files().DownloadFile(driveFile, options)
         Catch ex As Exception
            paused = InStr(ex._GetMessage(), "paused") > 0
         End Try
         me._haltGate = Null
         me.AssertTrue(paused, "download pause throws")
         me.AssertTrue(gate.WasPaused(), "download was paused")
         me.AssertTrue(TFile.Exists(dest), "partial download kept")
         Dim cancelClient As HttpClient = Http.Mock(200, "{}")
         Dim cancelCfg As GoogleDriveConfig = me.SampleConfig()
         Dim cancelEndpoints As New GoogleDriveEndpointsV3()
         Dim cancelHttp As New GoogleDriveHttp(cancelClient, cancelEndpoints, cancelCfg, True)
         Dim cancelDrive As GoogleDriveService = GoogleDriveService.FromHttp(cancelHttp, cancelCfg, True)
         Dim cancelDest As String = TPath.GetTempFileName()
         TFile.WriteAllText(cancelDest, "partial")
         Dim cancelFile As New GoogleDriveFile()
         cancelFile.Id = "id2"
         cancelFile.SizeBytes = GoogleDriveJson.FromInteger(10)
         Dim cancelGate As New GoogleDriveUploadControl()
         cancelGate.RequestCancel()
         Dim cancelOptions As New GoogleDriveDownloadOptions()
         cancelOptions.DestinationPath = cancelDest
         cancelOptions.DownloadControl = cancelGate
         Dim cancelled As Boolean = False
         Try
            cancelDrive.Files().DownloadFile(cancelFile, cancelOptions)
         Catch ex As Exception
            cancelled = InStr(ex._GetMessage(), "cancelled") > 0
         End Try
         me.AssertTrue(cancelled, "download cancel throws")
         me.AssertTrue(Not TFile.Exists(cancelDest), "partial download discarded")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         options.Free()
         gate.Free()
         driveFile.Free()
         drive.Free()
         endpoints.Free()
         cancelOptions.Free()
         cancelGate.Free()
         cancelFile.Free()
         cancelDrive.Free()
         cancelEndpoints.Free()
      End Sub

      Sub TestDownloadResume()
         print("-- download resume")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(206, "WORLD")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim dest As String = TPath.GetTempFileName()
         Dim seedFile As TFileStream = HttpFileIo.OpenForWrite(dest, False)
         HttpFileIo.WritePayload(seedFile, "HELLO")
         HttpFileIo.Release(seedFile)
         Dim driveFile As New GoogleDriveFile()
         driveFile.Id = "id1"
         driveFile.SizeBytes = GoogleDriveJson.FromInteger(10)
         me._progressTicks = 0
         Dim options As New GoogleDriveDownloadOptions()
         options.DestinationPath = dest
         options.ChunkSizeBytes = 5
         options.ResumePartial = True
         options.OnProgress = me.CountDownloadProgress
         drive.Files().DownloadFile(driveFile, options)
         me.AssertEq(TFile.ReadAllText(dest), "HELLOWORLD", "resumed body")
         me.AssertTrue(me._progressTicks > 0, "download progress ticks")
         me.AssertTrue(InStr(mockTr.LastHeadersText, "Range:") > 0, "resume range")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         options.Free()
         driveFile.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestWorkspaceDownloadRejected()
         print("-- workspace download rejected")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{""id"":""doc1"",""name"":""Doc"",""mimeType"":""application/vnd.google-apps.document""}")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim dest As String = TPath.GetTempFileName()
         Dim threw As Boolean = False
         Try
            drive.Files().Download("doc1", dest)
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "Export") > 0
         End Try
         me.AssertTrue(threw, "native doc requires export")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestExportWorkspace()
         print("-- export workspace")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{""id"":""sheet1"",""name"":""Plan"",""mimeType"":""application/vnd.google-apps.spreadsheet""}")
         mockTr.Enqueue(200, "XLSX")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim dest As String = TPath.GetTempFileName()
         Dim saved As String = drive.Files().Export("sheet1", dest)
         me.AssertEq(TFile.ReadAllText(saved), "XLSX", "export body")
         me.AssertTrue(InStr(mockTr.LastUrl, "/export") > 0, "export url")
         me.AssertTrue(InStr(mockTr.LastUrl, "mimeType") > 0, "export mime")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestEmptyUpload()
         print("-- empty upload")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/empty" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         mockTr.Enqueue(200, me.FileJson("up0", "empty.bin"))
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim source As New GoogleDriveMemoryStream("")
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "empty.bin"
         options.CheckQuota = False
         Dim uploaded As GoogleDriveFile = drive.Files().UploadSource(source, options)
         me.AssertEq(uploaded.Id, "up0", "empty id")
         me.AssertEq(mockTr.LastMethod, "POST", "empty metadata post")
         uploaded.Free()
         source.Free()
         options.Free()
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestFileStreamChunk()
         print("-- file stream chunk")
         Dim path As String = TPath.GetTempFileName()
         Dim writer As TFileStream = HttpFileIo.OpenForWrite(path, False)
         HttpFileIo.WritePayload(writer, "HELLO")
         HttpFileIo.Release(writer)
         Dim source As New GoogleDriveFileStream(path)
         me.AssertEq(GoogleDriveJson.Int64Text(source.Size()), "5", "file stream size")
         Dim slice As Variant = source.ReadChunk(GoogleDriveJson.FromInteger(1), 3)
         Dim slicePath As String = TPath.GetTempFileName()
         Dim destFile As TFileStream = HttpFileIo.OpenForWrite(slicePath, False)
         HttpFileIo.WritePayload(destFile, slice)
         HttpFileIo.Release(destFile)
         me.AssertEq(TFile.ReadAllText(slicePath), "ELL", "file stream window")
         source.Free()
         If TFile.Exists(path) Then
            TFile.Delete(path)
         End If
         If TFile.Exists(slicePath) Then
            TFile.Delete(slicePath)
         End If
      End Sub

      Sub TestListSharedDrive()
         print("-- list shared drive")
         Dim body As String = "{""kind"":""drive#fileList"",""files"":[]}"
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(200, body)
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim options As New GoogleDriveListOptions()
         options.DriveId = "drv1"
         Dim listing As GoogleDriveFileList = drive.Files().List(options)
         Dim mockTr As MockTransport = CType(httpLayer.Client().Transport, MockTransport)
         me.AssertTrue(InStr(mockTr.LastUrl, "driveId=drv1") > 0, "drive id query")
         me.AssertTrue(InStr(mockTr.LastUrl, "corpora=drive") > 0, "corpora drive")
         listing.Free()
         options.Free()
         drive.Free()
      End Sub

      Sub TestIntegrityChecksums()
         print("-- integrity checksums")
         me.AssertEq(GoogleDriveIntegrity.Normalize("5D 41:40-2A"), "5d41402a", "normalize hex")
         me.AssertTrue(GoogleDriveIntegrity.HashesMatch("5D41402A", "5d41402a"), "same hash")
         me.AssertTrue(Not GoogleDriveIntegrity.HashesMatch("aa", "bb"), "different hash")
         Dim missing As New GoogleDriveFile()
         missing.Id = "native-1"
         missing.MimeType = "application/vnd.google-apps.spreadsheet"
         Dim unavailable As Boolean = False
         Try
            GoogleDriveIntegrity.Verify("C:\missing.txt", missing)
         Catch ex As Exception
            unavailable = InStr(ex._GetMessage(), "md5Checksum") > 0
         End Try
         me.AssertTrue(unavailable, "native file has no md5")
         missing.Free()
         Dim samplePath As String = TPath.GetTempFileName()
         TFile.WriteAllText(samplePath, "hello-backup")
         Dim localMd5 As String = GoogleDriveIntegrity.HashLocal(samplePath)
         me.AssertTrue(Len(localMd5) = 32, "local md5 length")
         Dim driveFile As New GoogleDriveFile()
         driveFile.Id = "blob-1"
         driveFile.Md5Checksum = localMd5
         Dim matched As Boolean = True
         Try
            GoogleDriveIntegrity.Verify(samplePath, driveFile)
         Catch ex As Exception
            matched = False
         End Try
         me.AssertTrue(matched, "local md5 matches drive")
         driveFile.Md5Checksum = "00000000000000000000000000000000"
         Dim mismatch As Boolean = False
         Try
            GoogleDriveIntegrity.Verify(samplePath, driveFile)
         Catch ex As Exception
            mismatch = InStr(ex._GetMessage(), "integrity check failed") > 0
         End Try
         me.AssertTrue(mismatch, "wrong md5 throws")
         driveFile.Free()
         If TFile.Exists(samplePath) Then
            TFile.Delete(samplePath)
         End If
      End Sub

      Sub TestVerifyUploadRefreshesMd5()
         print("-- verify upload refreshes md5")
         Dim samplePath As String = TPath.GetTempFileName()
         TFile.WriteAllText(samplePath, "hello-backup")
         Dim localMd5 As String = GoogleDriveIntegrity.HashLocal(samplePath)
         Dim body As String = "{""kind"":""drive#file"",""id"":""id-refresh"",""name"":""a.txt"",""md5Checksum"":""" & localMd5 & """}"
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(200, body)
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim driveFile As New GoogleDriveFile()
         driveFile.Id = "id-refresh"
         drive.Files().VerifyUpload(samplePath, driveFile)
         me.AssertEq(GoogleDriveIntegrity.Normalize(driveFile.Md5Checksum), localMd5, "refreshed md5")
         driveFile.Free()
         drive.Free()
         If TFile.Exists(samplePath) Then
            TFile.Delete(samplePath)
         End If
      End Sub

      Sub TestUploadIntegrity()
         print("-- verify after upload")
         Dim samplePath As String = TPath.GetTempFileName()
         TFile.WriteAllText(samplePath, "hello-backup")
         Dim localMd5 As String = GoogleDriveIntegrity.HashLocal(samplePath)
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/hash" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         mockTr.Enqueue(200, "{""kind"":""drive#file"",""id"":""up-hash"",""name"":""a.txt"",""md5Checksum"":""" & localMd5 & """}")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "a.txt"
         options.CheckQuota = False
         Dim uploaded As GoogleDriveFile = drive.Files().Upload(samplePath, options)
         drive.Files().VerifyUpload(samplePath, uploaded)
         me.AssertEq(uploaded.Id, "up-hash", "verified upload id")
         uploaded.Free()
         options.Free()
         Dim badClient As HttpClient = Http.Mock(200, "{}")
         Dim badTr As MockTransport = CType(badClient.Transport, MockTransport)
         badTr.Enqueue(200, "{}", "Location: https://www.googleapis.com/upload/session/bad" & CHAR(13) & CHAR(10) & "Content-Type: application/json")
         badTr.Enqueue(200, "{""kind"":""drive#file"",""id"":""up-bad"",""name"":""a.txt"",""md5Checksum"":""00000000000000000000000000000000""}")
         Dim badCfg As GoogleDriveConfig = me.SampleConfig()
         Dim badEndpoints As New GoogleDriveEndpointsV3()
         Dim badHttp As New GoogleDriveHttp(badClient, badEndpoints, badCfg, True)
         Dim badDrive As GoogleDriveService = GoogleDriveService.FromHttp(badHttp, badCfg, True)
         Dim badOptions As New GoogleDriveUploadOptions()
         badOptions.Name = "a.txt"
         badOptions.CheckQuota = False
         Dim mismatch As Boolean = False
         Try
            Dim badFile As GoogleDriveFile = badDrive.Files().Upload(samplePath, badOptions)
            badDrive.Files().VerifyUpload(samplePath, badFile)
            badFile.Free()
         Catch ex As Exception
            mismatch = InStr(ex._GetMessage(), "integrity check failed") > 0
         End Try
         me.AssertTrue(mismatch, "verify rejects wrong md5")
         badOptions.Free()
         badDrive.Free()
         badEndpoints.Free()
         drive.Free()
         endpoints.Free()
         If TFile.Exists(samplePath) Then
            TFile.Delete(samplePath)
         End If
      End Sub

      Sub TestLoadRequiresAuth()
         print("-- load requires auth")
         Dim threw As Boolean = False
         Try
            Dim drive As GoogleDriveService = GoogleDriveService.Load(Null)
            drive.Free()
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "GoogleAuthClient") > 0
         End Try
         me.AssertTrue(threw, "null auth throws")
      End Sub

      Sub TestCapabilitiesAndVersion()
         print("-- capabilities")
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(200, "{}")
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim caps As GoogleDriveCapabilities = drive.Capabilities()
         me.AssertEq(drive.ApiVersionName(), "V3", "api version name")
         me.AssertTrue(caps.CanFiles, "can files")
         me.AssertTrue(caps.CanPermissions, "can permissions")
         me.AssertTrue(caps.CanAbout, "can about")
         me.AssertTrue(caps.CanResumableUpload, "can resumable upload")
         me.AssertTrue(caps.CanRangeDownload, "can range download")
         caps.Free()
         drive.Free()
      End Sub

      Sub TestMimeAndQueryExtras()
         print("-- mime and query extras")
         me.AssertEq(GoogleDriveMime.FromPath("a.pdf"), GoogleDriveMime.Pdf(), "pdf mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.txt"), "text/plain", "txt mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.csv"), "text/csv", "csv mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.json"), "application/json", "json mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.jpg"), "image/jpeg", "jpg mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.png"), "image/png", "png mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.doc"), GoogleDriveMime.WordDoc(), "doc mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.ppt"), GoogleDriveMime.PowerPointPpt(), "ppt mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.7z"), "application/x-7z-compressed", "7z mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.gz"), "application/gzip", "gz mime")
         me.AssertEq(GoogleDriveMime.FromPath("a.bin"), GoogleDriveMime.OctetStream(), "unknown mime")
         me.AssertEq(GoogleDriveMime.ExportMimeFor(GoogleDriveMime.NativeDocument()), GoogleDriveMime.WordDocx(), "export doc")
         me.AssertEq(GoogleDriveMime.ExportMimeFor(GoogleDriveMime.NativePresentation()), GoogleDriveMime.PowerPointPptx(), "export slides")
         me.AssertEq(GoogleDriveMime.ExportMimeFor("application/vnd.google-apps.drawing"), GoogleDriveMime.Pdf(), "export other to pdf")
         me.AssertEq(GoogleDriveScopes.DriveFile(), "https://www.googleapis.com/auth/drive.file", "drive.file scope")
         me.AssertEq(GoogleDriveScopes.DriveReadonly(), "https://www.googleapis.com/auth/drive.readonly", "drive.readonly scope")
         Dim q As New GoogleDriveQuery()
         q.NameContains("erp")
         q.MimeTypeEquals("application/zip")
         q.Raw("modifiedTime > '2024-01-01T00:00:00'")
         me.AssertTrue(InStr(q.AsString(), "name contains") > 0, "name contains")
         me.AssertTrue(InStr(q.AsString(), "mimeType =") > 0, "mime equals")
         me.AssertTrue(InStr(q.AsString(), "modifiedTime") > 0, "raw term")
         q.Free()
      End Sub

      Sub TestRangeAndElapsedHelpers()
         print("-- range and elapsed helpers")
         Dim startOff As Int64 = GoogleDriveJson.Zero64()
         Dim endOff As Int64 = GoogleDriveJson.FromInteger(7)
         Dim total As Int64 = GoogleDriveJson.FromInteger(100)
         me.AssertEq(GoogleDriveJson.BuildDownloadRange(startOff, endOff), "bytes=0-7", "download range")
         me.AssertEq(GoogleDriveJson.BuildUploadRange(startOff, endOff, total), "bytes 0-7/100", "content range")
         me.AssertEq(GoogleDriveJson.BuildResumeRange(total), "bytes */100", "resume probe")
         me.AssertEq(GoogleDriveJson.Int64Text(GoogleDriveJson.ParseRangeEnd("bytes 0-4/10")), "4", "parse range end")
         Dim started As TDateTime = DateTime()
         Sleep(200)
         Dim elapsed As String = GoogleDriveJson.ElapsedText(started, DateTime())
         me.AssertTrue(elapsed <> "0.000s", "elapsed uses DateTime clock")
      End Sub

      Sub TestWantTextOnMedia()
         print("-- want text off for media")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         mockTr.Enqueue(200, "{""kind"":""drive#file"",""id"":""idz"",""name"":""empty.bin""}")
         mockTr.Enqueue(200, "Z")
         Dim cfg As GoogleDriveConfig = me.SampleConfig()
         Dim endpoints As New GoogleDriveEndpointsV3()
         Dim httpLayer As New GoogleDriveHttp(mockClient, endpoints, cfg, True)
         Dim drive As GoogleDriveService = GoogleDriveService.FromHttp(httpLayer, cfg, True)
         Dim dest As String = TPath.GetTempFileName()
         drive.Files().Download("idz", dest)
         me.AssertTrue(Not mockTr.LastWantText, "media WantText false")
         me.AssertTrue(httpLayer.Client().WantText, "session WantText restored")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         drive.Free()
         endpoints.Free()
      End Sub

      Sub TestGoogleErrorBody()
         print("-- google error json")
         Dim body As String = "{""error"":{""message"":""Forbidden"",""errors"":[{""reason"":""rateLimitExceeded""}]}}"
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(403, body)
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim threw As Boolean = False
         Dim detail As String = ""
         Try
            Dim driveFile As GoogleDriveFile = drive.Files().Gett("id1")
            driveFile.Free()
         Catch ex As Exception
            detail = ex._GetMessage()
            threw = (InStr(detail, "rateLimitExceeded") > 0) And (InStr(detail, "Forbidden") > 0)
         End Try
         me.AssertTrue(threw, "flattens google error json")
         drive.Free()
      End Sub

      Sub TestExportGuards()
         print("-- export guards")
         Dim httpLayer As GoogleDriveHttp = me.SampleHttp(200, "{}")
         Dim drive As GoogleDriveService = me.SampleService(httpLayer)
         Dim dest As String = TPath.GetTempFileName()
         Dim folder As New GoogleDriveFile()
         folder.Id = "folder1"
         folder.MimeType = GoogleDriveMime.FolderType()
         Dim folderThrew As Boolean = False
         Try
            drive.Files().ExportFile(folder, dest)
         Catch ex As Exception
            folderThrew = InStr(ex._GetMessage(), "Folders cannot be exported") > 0
         End Try
         me.AssertTrue(folderThrew, "folder export rejected")
         Dim blob As New GoogleDriveFile()
         blob.Id = "zip1"
         blob.MimeType = "application/zip"
         Dim blobThrew As Boolean = False
         Try
            drive.Files().ExportFile(blob, dest)
         Catch ex As Exception
            blobThrew = InStr(ex._GetMessage(), "cannot be exported") > 0
         End Try
         me.AssertTrue(blobThrew, "blob export rejected")
         folder.Free()
         blob.Free()
         drive.Free()
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._failures) Then
            me._failures.Free()
            me._failures = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
