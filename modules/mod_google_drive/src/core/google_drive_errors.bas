Imports mod_tobject
Imports google_drive_json

Namespace google_drive_errors

   Class GoogleDriveErrors
      Inherits TTObject

      Shared Function AuthRequired() As String
         AuthRequired = "GoogleDriveService requires a GoogleAuthClient."
      End Function

      Shared Function ConfigRequired() As String
         ConfigRequired = "GoogleDriveService requires a GoogleDriveConfig."
      End Function

      Shared Function HttpRequired() As String
         HttpRequired = "GoogleDriveHttp requires an HttpClient."
      End Function

      Shared Function EndpointsRequired() As String
         EndpointsRequired = "GoogleDriveHttp requires GoogleDriveEndpoints."
      End Function

      Shared Function UnknownApiVersion(pName As String) As String
         UnknownApiVersion = "Unknown Google Drive API version: " & pName
      End Function

      Shared Function FileIdRequired() As String
         FileIdRequired = "Drive file id is required."
      End Function

      Shared Function PermissionIdRequired() As String
         PermissionIdRequired = "Drive permission id is required."
      End Function

      Shared Function PathRequired() As String
         PathRequired = "Local file path is required."
      End Function

      Shared Function FileNotFound(pPath As String) As String
         FileNotFound = "Local file not found: " & pPath
      End Function

      Shared Function FileOpenFailed(pPath As String) As String
         FileOpenFailed = "Failed to open local file: " & pPath
      End Function

      Shared Function ChunkSourceRequired() As String
         ChunkSourceRequired = "Upload requires a GoogleDriveChunkSource."
      End Function

      Shared Function InvalidChunkSize(pSize As Integer) As String
         InvalidChunkSize = "Chunk size must be a positive multiple of 262144 bytes. Got: " & CStr(pSize)
      End Function

      Shared Function InvalidTimeout() As String
         InvalidTimeout = "HTTP timeout must be greater than zero."
      End Function

      Shared Function RequestFailed(pStatus As Integer, pDetail As String) As String
         RequestFailed = "Google Drive request failed (" & CStr(pStatus) & "). " & pDetail
      End Function

      Shared Function LocationMissing() As String
         LocationMissing = "Resumable upload did not return a Location session URI."
      End Function

      Shared Function UploadIncomplete() As String
         UploadIncomplete = "Resumable upload finished without a Drive file resource."
      End Function

      Shared Function UploadPaused() As String
         UploadPaused = "Resumable upload paused. Session was kept; call Upload again to resume."
      End Function

      Shared Function UploadCancelled() As String
         UploadCancelled = "Resumable upload cancelled. Session was discarded."
      End Function

      Shared Function InsufficientQuota(pNeeded As Int64, pAvailable As Int64) As String
         InsufficientQuota = "Drive storage quota is insufficient. Needed=" & GoogleDriveJson.Int64Text(pNeeded) & " available=" & GoogleDriveJson.Int64Text(pAvailable)
      End Function

      Shared Function FileTooLarge(pSize As Int64, pMax As Int64) As String
         FileTooLarge = "File size " & GoogleDriveJson.Int64Text(pSize) & " exceeds Drive maxUploadSize " & GoogleDriveJson.Int64Text(pMax)
      End Function

      Shared Function DownloadPathRequired() As String
         DownloadPathRequired = "Download destination path is required."
      End Function

      Shared Function DownloadPaused() As String
         DownloadPaused = "Download paused. Partial file was kept; call Download again with ResumePartial=True to continue."
      End Function

      Shared Function DownloadCancelled() As String
         DownloadCancelled = "Download cancelled. Partial file was discarded."
      End Function

      Shared Function WorkspaceExportRequired(pMime As String) As String
         WorkspaceExportRequired = "Native Google file cannot be downloaded with alt=media. Use Export. mime=" & Trim(pMime)
      End Function

      Shared Function NotExportable(pMime As String) As String
         NotExportable = "File mime is not a Google Workspace type and cannot be exported: " & Trim(pMime)
      End Function

      Shared Function CannotExportFolder() As String
         CannotExportFolder = "Folders cannot be exported. List children and download each file."
      End Function

      Shared Function ExportMimeRequired() As String
         ExportMimeRequired = "Export mimeType is required."
      End Function

      Shared Function FolderNameRequired() As String
         FolderNameRequired = "Folder name is required."
      End Function

      Shared Function DriveFileRequired() As String
         DriveFileRequired = "Drive file resource is required."
      End Function

      Shared Function LocalChecksumEmpty(pPath As String) As String
         LocalChecksumEmpty = "Could not compute local MD5 for: " & pPath
      End Function

      Shared Function ChecksumUnavailable(pFileId As String, pMime As String = "") As String
         Dim detail As String = Trim(pFileId)
         If Trim(pMime) <> "" Then
            If detail <> "" Then
               detail = detail & " mime=" & Trim(pMime)
            Else
               detail = "mime=" & Trim(pMime)
            End If
         End If
         If detail = "" Then
            ChecksumUnavailable = "Drive did not return md5Checksum. Native Google Docs/Sheets cannot be verified this way."
            Exit Function
         End If
         ChecksumUnavailable = "Drive did not return md5Checksum for " & detail & ". Native Google Docs/Sheets cannot be verified this way."
      End Function

      Shared Function ChecksumMismatch(pLocal As String, pRemote As String) As String
         ChecksumMismatch = "Upload integrity check failed. Local MD5=" & pLocal & " Drive MD5=" & pRemote
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
