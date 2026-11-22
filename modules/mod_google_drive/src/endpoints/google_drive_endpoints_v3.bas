Imports mod_tobject
Imports google_drive_endpoints
Imports google_drive_enums
Imports google_drive_errors

Namespace google_drive_endpoints_v3

   Class GoogleDriveEndpointsV3
      Inherits GoogleDriveEndpoints

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function RootUrl() As String
         RootUrl = "https://www.googleapis.com/"
      End Function

      Overrides Function ServicePath() As String
         ServicePath = "drive/v3/"
      End Function

      Overrides Function SimpleUploadPath() As String
         SimpleUploadPath = "/upload/drive/v3/files"
      End Function

      Overrides Function ResumableUploadPath() As String
         ResumableUploadPath = "/resumable/upload/drive/v3/files"
      End Function

      Function ResumableUpdatePath(pFileId As String) As String
         ResumableUpdatePath = "/resumable/upload/drive/v3/files/" & Trim(pFileId)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class GoogleDriveEndpointCatalog
      Inherits TTObject

      Shared Function Make(pVersion As GoogleDriveApiVersion) As GoogleDriveEndpoints
         If Not Assigned(pVersion) Then
            Make = New GoogleDriveEndpointsV3()
            Exit Function
         End If
         Make = GoogleDriveEndpointCatalog.MakeByName(pVersion.AsString)
      End Function

      Shared Function MakeByName(pName As String) As GoogleDriveEndpoints
         Dim versionName As String = UCase(Trim(pName))
         If (versionName = "") Or (versionName = "V3") Then
            MakeByName = New GoogleDriveEndpointsV3()
            Exit Function
         End If
         Throw New Exception(GoogleDriveErrors.UnknownApiVersion(pName))
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
