Imports http_url
Imports http_headers
Imports mod_tobject

Namespace google_drive_endpoints

   MustInherit Class GoogleDriveEndpoints
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function RootUrl() As String
         Throw New Exception("RootUrl must be implemented.")
      End Function

      Overridable Function ServicePath() As String
         Throw New Exception("ServicePath must be implemented.")
      End Function

      Overridable Function BaseUrl() As String
         BaseUrl = me.RootUrl() & me.ServicePath()
      End Function

      Overridable Function SimpleUploadPath() As String
         Throw New Exception("SimpleUploadPath must be implemented.")
      End Function

      Overridable Function ResumableUploadPath() As String
         Throw New Exception("ResumableUploadPath must be implemented.")
      End Function

      Function SimpleUploadUrl() As String
         SimpleUploadUrl = me.RootUrl() & Mid(me.SimpleUploadPath(), 2)
      End Function

      Function ResumableUploadUrl() As String
         ResumableUploadUrl = me.RootUrl() & Mid(me.ResumableUploadPath(), 2)
      End Function

      Function FilesPath() As String
         FilesPath = "files"
      End Function

      Function FilePath(pFileId As String) As String
         FilePath = "files/" & http_url.Encode(Trim(pFileId))
      End Function

      Function FileCopyPath(pFileId As String) As String
         FileCopyPath = me.FilePath(pFileId) & "/copy"
      End Function

      Function FileExportPath(pFileId As String) As String
         FileExportPath = me.FilePath(pFileId) & "/export"
      End Function

      Function AboutPath() As String
         AboutPath = "about"
      End Function

      Function PermissionsPath(pFileId As String) As String
         PermissionsPath = me.FilePath(pFileId) & "/permissions"
      End Function

      Function PermissionPath(pFileId As String, pPermissionId As String) As String
         PermissionPath = me.PermissionsPath(pFileId) & "/" & http_url.Encode(Trim(pPermissionId))
      End Function

      Function WithQuery(pPath As String, pQuery As HttpParams) As String
         If Not Assigned(pQuery) Then
            WithQuery = pPath
            Exit Function
         End If
         WithQuery = http_url.WithQuery(pPath, pQuery)
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
