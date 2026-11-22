Imports TPath
Imports http_headers
Imports mod_tobject
Imports google_drive_http
Imports google_drive_file
Imports google_drive_file_list
Imports google_drive_list_options
Imports google_drive_upload_options
Imports google_drive_download_options
Imports google_drive_chunk_source
Imports google_drive_file_stream
Imports google_drive_uploader
Imports google_drive_downloader
Imports google_drive_about_resource
Imports google_drive_integrity
Imports google_drive_errors
Imports google_drive_mime

Namespace google_drive_files

   Class GoogleDriveFiles
      Inherits TTObject

      Private _http As GoogleDriveHttp
      Private _uploader As GoogleDriveUploader
      Private _downloader As GoogleDriveDownloader
      Private _about As GoogleDriveAboutResource

      Sub New(pHttp As GoogleDriveHttp, pUploader As GoogleDriveUploader, pDownloader As GoogleDriveDownloader, pAbout As GoogleDriveAboutResource)
         MyBase.New()
         If Not Assigned(pHttp) Then
            Throw New Exception(GoogleDriveErrors.HttpRequired())
         End If
         me._http = pHttp
         me._uploader = pUploader
         me._downloader = pDownloader
         me._about = pAbout
      End Sub

      Function List(pOptions As GoogleDriveListOptions) As GoogleDriveFileList
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().ListFields())
         If Assigned(pOptions) Then
            If Trim(pOptions.Query) <> "" Then
               query.Define("q", pOptions.Query)
            End If
            If pOptions.PageSize > 0 Then
               query.Define("pageSize", pOptions.PageSize)
            End If
            If Trim(pOptions.PageToken) <> "" Then
               query.Define("pageToken", Trim(pOptions.PageToken))
            End If
            If Trim(pOptions.OrderBy) <> "" Then
               query.Define("orderBy", Trim(pOptions.OrderBy))
            End If
            If Trim(pOptions.Fields) <> "" Then
               query.Define("fields", Trim(pOptions.Fields))
            End If
            If Trim(pOptions.DriveId) <> "" Then
               query.Define("driveId", Trim(pOptions.DriveId))
               If Trim(pOptions.Corpora) = "" Then
                  query.Define("corpora", "drive")
               End If
            End If
            If Trim(pOptions.Corpora) <> "" Then
               query.Define("corpora", Trim(pOptions.Corpora))
            End If
         End If
         me.ApplyListFlags(query)
         Dim json As TJSONObject = me._http.GetJson(me._http.Endpoints().FilesPath(), query)
         query.Free()
         Dim listing As GoogleDriveFileList = GoogleDriveFileList.FromJson(json)
         json.Free()
         List = listing
      End Function

      Function Gett(pFileId As String) As GoogleDriveFile
         me.RequireFileId(pFileId)
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().FileFields)
         me.ApplyDriveFlags(query)
         Dim json As TJSONObject = me._http.GetJson(me._http.Endpoints().FilePath(pFileId), query)
         query.Free()
         Dim driveFile As GoogleDriveFile = GoogleDriveFile.FromJson(json)
         json.Free()
         Gett = driveFile
      End Function

      Function CreateFolder(pName As String, pParentId As String = "") As GoogleDriveFile
         If Trim(pName) = "" Then
            Throw New Exception(GoogleDriveErrors.FolderNameRequired())
         End If
         Dim meta As New GoogleDriveFile()
         meta.Name = Trim(pName)
         meta.MimeType = GoogleDriveMime.FolderType()
         If Trim(pParentId) <> "" Then
            meta.Parents.Add(Trim(pParentId))
         End If
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().FileFields)
         me.ApplyDriveFlags(query)
         Dim body As TJSONObject = meta.ToJson()
         Dim json As TJSONObject = me._http.PostJson(me._http.Endpoints().FilesPath(), query, body)
         query.Free()
         body.Free()
         meta.Free()
         Dim created As GoogleDriveFile = GoogleDriveFile.FromJson(json)
         json.Free()
         CreateFolder = created
      End Function

      Function Update(pDriveFile As GoogleDriveFile, pAddParents As String = "", pRemoveParents As String = "") As GoogleDriveFile
         If Not Assigned(pDriveFile) Then
            Throw New Exception(GoogleDriveErrors.FileIdRequired())
         End If
         me.RequireFileId(pDriveFile.Id)
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().FileFields)
         If Trim(pAddParents) <> "" Then
            query.Define("addParents", Trim(pAddParents))
         End If
         If Trim(pRemoveParents) <> "" Then
            query.Define("removeParents", Trim(pRemoveParents))
         End If
         me.ApplyDriveFlags(query)
         Dim body As TJSONObject = pDriveFile.ToJson()
         Dim json As TJSONObject = me._http.PatchJson(me._http.Endpoints().FilePath(pDriveFile.Id), query, body)
         query.Free()
         body.Free()
         Dim updated As GoogleDriveFile = GoogleDriveFile.FromJson(json)
         json.Free()
         Update = updated
      End Function

      Function Copy(pFileId As String, pName As String, pParentId As String = "") As GoogleDriveFile
         me.RequireFileId(pFileId)
         Dim meta As New GoogleDriveFile()
         meta.Name = Trim(pName)
         If Trim(pParentId) <> "" Then
            meta.Parents.Add(Trim(pParentId))
         End If
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().FileFields)
         me.ApplyDriveFlags(query)
         Dim body As TJSONObject = meta.ToJson()
         Dim json As TJSONObject = me._http.PostJson(me._http.Endpoints().FileCopyPath(pFileId), query, body)
         query.Free()
         body.Free()
         meta.Free()
         Dim copied As GoogleDriveFile = GoogleDriveFile.FromJson(json)
         json.Free()
         Copy = copied
      End Function

      Function Trash(pFileId As String) As GoogleDriveFile
         me.RequireFileId(pFileId)
         Dim meta As New GoogleDriveFile()
         meta.Id = Trim(pFileId)
         meta.Trashed = True
         Dim result As GoogleDriveFile = me.Update(meta)
         meta.Free()
         Trash = result
      End Function

      Sub Delete(pFileId As String)
         me.RequireFileId(pFileId)
         Dim query As New HttpParams()
         me.ApplyDriveFlags(query)
         me._http.Delete(me._http.Endpoints().FilePath(pFileId), query)
         query.Free()
      End Sub

      Function Upload(pPath As String, pOptions As GoogleDriveUploadOptions) As GoogleDriveFile
         Dim source As GoogleDriveFileStream = New GoogleDriveFileStream(pPath)
         Dim options As GoogleDriveUploadOptions = pOptions
         Dim ownsOptions As Boolean = False
         If Not Assigned(options) Then
            options = New GoogleDriveUploadOptions()
            ownsOptions = True
         End If
         If Trim(options.Name) = "" Then
            options.Name = TPath.GetFileName(pPath)
         End If
         If options.CheckQuota And Assigned(me._about) Then
            ' data7:disable-next-line type-mismatch
            me._about.EnsureCanUpload(source.Size())
         End If
         Dim uploaded As GoogleDriveFile = me._uploader.Upload(source, options)
         source.Free()
         If ownsOptions Then
            options.Free()
         End If
         Upload = uploaded
      End Function

      Function UploadSource(pSource As GoogleDriveChunkSource, pOptions As GoogleDriveUploadOptions) As GoogleDriveFile
         If Assigned(pOptions) Then
            If pOptions.CheckQuota And Assigned(me._about) Then
               ' data7:disable-next-line type-mismatch
               me._about.EnsureCanUpload(pSource.Size())
            End If
         End If
         UploadSource = me._uploader.Upload(pSource, pOptions)
      End Function

      Function VerifyUpload(pPath As String, pDriveFile As GoogleDriveFile) As GoogleDriveFile
         If Not Assigned(pDriveFile) Then
            Throw New Exception(GoogleDriveErrors.DriveFileRequired())
         End If
         If Trim(pDriveFile.Md5Checksum) = "" Then
            If Trim(pDriveFile.Id) <> "" Then
               Dim fresh As GoogleDriveFile = me.Gett(pDriveFile.Id)
               pDriveFile.Assign(fresh)
               fresh.Free()
            End If
         End If
         GoogleDriveIntegrity.Verify(pPath, pDriveFile)
         VerifyUpload = pDriveFile
      End Function

      Function Download(pFileId As String, pDestPath As String) As String
         Dim driveFile As GoogleDriveFile = me.Gett(pFileId)
         Dim options As New GoogleDriveDownloadOptions()
         options.DestinationPath = pDestPath
         Dim saved As String = me.DownloadFile(driveFile, options)
         options.Free()
         driveFile.Free()
         Download = saved
      End Function

      Function DownloadFile(pDriveFile As GoogleDriveFile, pOptions As GoogleDriveDownloadOptions) As String
         If Assigned(pDriveFile) Then
            If pDriveFile.IsFolder() Then
               Throw New Exception(GoogleDriveErrors.CannotExportFolder())
            End If
            If pDriveFile.IsWorkspace() Then
               Throw New Exception(GoogleDriveErrors.WorkspaceExportRequired(pDriveFile.MimeType))
            End If
         End If
         DownloadFile = me._downloader.Download(pDriveFile, pOptions)
      End Function

      Function Export(pFileId As String, pDestPath As String, pExportMime As String = "") As String
         Dim driveFile As GoogleDriveFile = me.Gett(pFileId)
         Dim saved As String = me.ExportFile(driveFile, pDestPath, pExportMime, Null)
         driveFile.Free()
         Export = saved
      End Function

      Function ExportFile(pDriveFile As GoogleDriveFile, pDestPath As String, pExportMime As String = "", pOptions As GoogleDriveDownloadOptions = Null) As String
         If Not Assigned(pDriveFile) Then
            Throw New Exception(GoogleDriveErrors.DriveFileRequired())
         End If
         If pDriveFile.IsFolder() Then
            Throw New Exception(GoogleDriveErrors.CannotExportFolder())
         End If
         If Not pDriveFile.IsWorkspace() Then
            Throw New Exception(GoogleDriveErrors.NotExportable(pDriveFile.MimeType))
         End If
         Dim exportMime As String = Trim(pExportMime)
         If exportMime = "" Then
            exportMime = GoogleDriveMime.ExportMimeFor(pDriveFile.MimeType)
         End If
         Dim dest As String = Trim(pDestPath)
         If Assigned(pOptions) Then
            If Trim(pOptions.DestinationPath) <> "" Then
               dest = Trim(pOptions.DestinationPath)
            End If
         End If
         ExportFile = me._downloader.Export(pDriveFile.Id, dest, exportMime, pOptions)
      End Function

      Sub RequireFileId(pFileId As String)
         If Trim(pFileId) = "" Then
            Throw New Exception(GoogleDriveErrors.FileIdRequired())
         End If
      End Sub

      Sub ApplyDriveFlags(pQuery As HttpParams)
         If me._http.Config().SupportsAllDrives Then
            pQuery.Define("supportsAllDrives", "true")
         End If
      End Sub

      Sub ApplyListFlags(pQuery As HttpParams)
         me.ApplyDriveFlags(pQuery)
         If me._http.Config().IncludeItemsFromAllDrives Then
            pQuery.Define("includeItemsFromAllDrives", "true")
         End If
      End Sub

      Overrides Sub Dispose()
         me._http = Null
         me._uploader = Null
         me._downloader = Null
         me._about = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
