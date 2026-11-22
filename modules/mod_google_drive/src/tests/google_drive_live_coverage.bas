Imports TFile
Imports TPath
Imports mod_tobject
Imports google_auth_client
Imports google_drive
Imports google_drive_config
Imports google_drive_file
Imports google_drive_file_list
Imports google_drive_files
Imports google_drive_list_options
Imports google_drive_query
Imports google_drive_upload_options
Imports google_drive_download_options
Imports google_drive_upload_control
Imports google_drive_permission
Imports google_drive_permission_list
Imports google_drive_mime
Imports google_drive_json
Imports google_drive_integrity
Imports google_drive_memory_stream

Namespace google_drive_live_coverage

   Class GoogleDriveLiveCoverage
      Inherits TTObject

      Private _haltGate As GoogleDriveUploadControl
      Private _pauseOnce As Boolean
      Private _lastPercent As Integer

      Shared Sub Run(pDrive As GoogleDriveService, pAuth As GoogleAuthClient, pFolder As GoogleDriveFile, pUploaded As GoogleDriveFile)
         Dim runner As New GoogleDriveLiveCoverage()
         runner.Execute(pDrive, pAuth, pFolder, pUploaded)
         runner.Free()
      End Sub

      Sub New()
         MyBase.New()
         me._lastPercent = -1
      End Sub

      Sub Execute(pDrive As GoogleDriveService, pAuth As GoogleAuthClient, pFolder As GoogleDriveFile, pUploaded As GoogleDriveFile)
         me.LogLine("==== cobertura live extra ====")
         me.RunList(pDrive, pFolder)
         me.RunCopyTrashDelete(pDrive, pFolder, pUploaded)
         me.RunPermissions(pDrive, pUploaded)
         me.RunEmptyUpload(pDrive, pFolder)
         me.RunExport(pDrive, pFolder)
         me.RunPauseResumeAndCancel(pAuth, pFolder)
         me.LogLine("Cobertura live extra: OK")
      End Sub

      Sub RunList(pDrive As GoogleDriveService, pFolder As GoogleDriveFile)
         Dim options As New GoogleDriveListOptions()
         Dim q As New GoogleDriveQuery()
         q.ParentsIn(pFolder.Id)
         q.Trashed(False)
         options.Query = q.AsString()
         options.PageSize = 10
         q.Free()
         Dim listing As GoogleDriveFileList = pDrive.Files().List(options)
         me.LogLine("Listagem da pasta: " & CStr(listing.Files.Length) & " item(ns)")
         listing.Free()
         options.Free()
      End Sub

      Sub RunCopyTrashDelete(pDrive As GoogleDriveService, pFolder As GoogleDriveFile, pUploaded As GoogleDriveFile)
         Dim copyName As String = "copy-" & pUploaded.Name
         Dim copied As GoogleDriveFile = pDrive.Files().Copy(pUploaded.Id, copyName, pFolder.Id)
         me.LogLine("Copia: " & copied.Id)
         Dim trashed As GoogleDriveFile = pDrive.Files().Trash(copied.Id)
         me.AssertTrue(trashed.Trashed, "live trash")
         pDrive.Files().Delete(copied.Id)
         me.LogLine("Copia lixo/delete: OK")
         copied.Free()
         trashed.Free()
      End Sub

      Sub RunPermissions(pDrive As GoogleDriveService, pUploaded As GoogleDriveFile)
         Dim listing As GoogleDrivePermissionList = pDrive.Permissions().List(pUploaded.Id)
         me.AssertTrue(listing.Permissions.Length > 0, "live permissions list")
         Dim firstId As String = listing.Permissions.Take(0).Id
         Dim fetched As GoogleDrivePermission = pDrive.Permissions().Gett(pUploaded.Id, firstId)
         me.LogLine("Permissao owner: " & fetched.Role & " " & fetched.TypeName)
         listing.Free()
         fetched.Free()
         me.LogLine("Permissao anyone: pulada (conta recusa share publico)")
      End Sub

      Sub RunEmptyUpload(pDrive As GoogleDriveService, pFolder As GoogleDriveFile)
         Dim source As New GoogleDriveMemoryStream("")
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "live-empty.txt"
         options.ParentId = pFolder.Id
         options.CheckQuota = False
         Dim uploaded As GoogleDriveFile = pDrive.Files().UploadSource(source, options)
         me.LogLine("Upload vazio: " & uploaded.Id)
         pDrive.Files().Delete(uploaded.Id)
         uploaded.Free()
         options.Free()
         source.Free()
      End Sub

      Sub RunExport(pDrive As GoogleDriveService, pFolder As GoogleDriveFile)
         Dim source As New GoogleDriveMemoryStream("")
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "live-export-doc"
         options.ParentId = pFolder.Id
         options.MimeType = GoogleDriveMime.NativeDocument()
         options.CheckQuota = False
         Dim docFile As GoogleDriveFile = pDrive.Files().UploadSource(source, options)
         me.LogLine("Doc nativo: " & docFile.Id)
         Dim dest As String = TPath.GetTempFileName()
         pDrive.Files().Export(docFile.Id, dest)
         me.AssertTrue(TFile.Exists(dest), "live export exists")
         me.LogLine("Export docx: OK")
         pDrive.Files().Delete(docFile.Id)
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         docFile.Free()
         source.Free()
         options.Free()
      End Sub

      Sub RunPauseResumeAndCancel(pAuth As GoogleAuthClient, pFolder As GoogleDriveFile)
         Dim smallCfg As New GoogleDriveConfig()
         smallCfg.AdaptiveChunkSize = False
         smallCfg.ChunkSizeBytes = GoogleDriveJson.MinChunkBytes()
         Dim smallDrive As GoogleDriveService = GoogleDriveService.Load(pAuth, smallCfg)
         Dim blobPath As String = me.MakeBlob(400000)
         Dim sessionPath As String = TPath.Combine(TPath.GetDirectoryName(blobPath), "live-pause-session.json")
         Dim gate As New GoogleDriveUploadControl()
         me._haltGate = gate
         me._pauseOnce = True
         me._lastPercent = -1
         Dim options As New GoogleDriveUploadOptions()
         options.Name = "live-pause.bin"
         options.ParentId = pFolder.Id
         options.SessionFile = sessionPath
         options.CheckQuota = False
         options.DownloadControl = gate
         options.OnProgress = me.RequestPauseOnProgress
         Dim paused As Boolean = False
         Try
            Dim skipped As GoogleDriveFile = smallDrive.Files().Upload(blobPath, options)
            skipped.Free()
         Catch ex As Exception
            paused = InStr(ex._GetMessage(), "paused") > 0
         End Try
         me.AssertTrue(paused, "live upload pause")
         me.AssertTrue(TFile.Exists(sessionPath), "live session kept")
         me.LogLine("Upload pause: OK")
         gate.Reset()
         me._pauseOnce = False
         me._lastPercent = -1
         Dim uploaded As GoogleDriveFile = smallDrive.Files().Upload(blobPath, options)
         smallDrive.Files().VerifyUpload(blobPath, uploaded)
         me.LogLine("Upload resume: OK " & uploaded.Id)
         Dim dest As String = TPath.GetTempFileName()
         Dim downGate As New GoogleDriveUploadControl()
         me._haltGate = downGate
         me._pauseOnce = True
         me._lastPercent = -1
         Dim downOptions As New GoogleDriveDownloadOptions()
         downOptions.DestinationPath = dest
         downOptions.ChunkSizeBytes = GoogleDriveJson.MinChunkBytes()
         downOptions.DownloadControl = downGate
         downOptions.OnProgress = me.RequestPauseOnProgress
         Dim downPaused As Boolean = False
         Try
            smallDrive.Files().DownloadFile(uploaded, downOptions)
         Catch ex As Exception
            downPaused = InStr(ex._GetMessage(), "paused") > 0
         End Try
         me.AssertTrue(downPaused, "live download pause")
         me.AssertTrue(TFile.Exists(dest), "live partial download kept")
         me.LogLine("Download pause: OK")
         downGate.Reset()
         me._pauseOnce = False
         downOptions.ResumePartial = True
         downOptions.OnProgress = me.ReportDownloadProgress
         smallDrive.Files().DownloadFile(uploaded, downOptions)
         me.AssertTrue(GoogleDriveIntegrity.HashesMatch(GoogleDriveIntegrity.HashLocal(dest), uploaded.Md5Checksum), "live pause download md5")
         me.LogLine("Download resume: OK")
         Dim cancelGate As New GoogleDriveUploadControl()
         cancelGate.RequestCancel()
         Dim cancelOptions As New GoogleDriveUploadOptions()
         cancelOptions.Name = "live-cancel.bin"
         cancelOptions.ParentId = pFolder.Id
         cancelOptions.SessionFile = TPath.Combine(TPath.GetDirectoryName(blobPath), "live-cancel-session.json")
         cancelOptions.CheckQuota = False
         cancelOptions.DownloadControl = cancelGate
         Dim cancelled As Boolean = False
         Try
            Dim skippedCancel As GoogleDriveFile = smallDrive.Files().Upload(blobPath, cancelOptions)
            skippedCancel.Free()
         Catch ex As Exception
            cancelled = InStr(ex._GetMessage(), "cancelled") > 0
         End Try
         me.AssertTrue(cancelled, "live upload cancel")
         me.AssertTrue(Not TFile.Exists(cancelOptions.SessionFile), "live cancel cleared session")
         me.LogLine("Upload cancel: OK")
         smallDrive.Files().Delete(uploaded.Id)
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         If TFile.Exists(blobPath) Then
            TFile.Delete(blobPath)
         End If
         If TFile.Exists(sessionPath) Then
            TFile.Delete(sessionPath)
         End If
         me._haltGate = Null
         uploaded.Free()
         options.Free()
         gate.Free()
         downOptions.Free()
         downGate.Free()
         cancelOptions.Free()
         cancelGate.Free()
         smallDrive.Free()
         smallCfg.Free()
      End Sub

      Function MakeBlob(pBytes As Integer) As String
         Dim path As String = TPath.GetTempFileName()
         Dim block As String = "0123456789abcdef"
         While Len(block) < pBytes
            block = block & block
         End While
         TFile.WriteAllText(path, Left(block, pBytes))
         MakeBlob = path
      End Function

      Sub RequestPauseOnProgress(pBytesSent As Int64, pTotalBytes As Int64)
         me.ReportTransferProgress("Transferindo", pBytesSent, pTotalBytes)
         If Assigned(me._haltGate) Then
            If me._pauseOnce Then
               me._haltGate.RequestPause()
               me._pauseOnce = False
            End If
         End If
      End Sub

      Sub ReportDownloadProgress(pBytesSent As Int64, pTotalBytes As Int64)
         me.ReportTransferProgress("Baixando", pBytesSent, pTotalBytes)
      End Sub

      Sub ReportTransferProgress(pVerb As String, pBytesSent As Int64, pTotalBytes As Int64)
         Dim sentText As String = GoogleDriveJson.Int64Text(pBytesSent)
         Dim totalText As String = GoogleDriveJson.Int64Text(pTotalBytes)
         Dim pct As Integer = 0
         If pTotalBytes > GoogleDriveJson.Zero64() Then
            pct = CInt((CDbl(sentText) * 100) / CDbl(totalText))
            If (pct >= 100) And (pBytesSent < pTotalBytes) Then
               pct = 99
            End If
            If pBytesSent = pTotalBytes Then
               pct = 100
            End If
         End If
         If pct = me._lastPercent Then
            Exit Sub
         End If
         me._lastPercent = pct
         me.LogLine(pVerb & ": " & CStr(pct) & "%")
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If Not pOk Then
            Throw New Exception("Live coverage failed: " & pMsg)
         End If
      End Sub

      Sub LogLine(pText As String)
         Dim stamp As TDateTime = DateTime()
         Dim line As String = pText
         line = line.Replace(CHAR(13), " ")
         line = line.Replace(CHAR(10), " ")
         print(stamp.ToString("hh:mm:ss.zzz") & "  " & line)
      End Sub

      Overrides Sub Dispose()
         me._haltGate = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
