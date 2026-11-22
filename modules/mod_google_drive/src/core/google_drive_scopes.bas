Imports mod_tobject

Namespace google_drive_scopes

   Class GoogleDriveScopes
      Inherits TTObject

      Shared Function Drive() As String
         Drive = "https://www.googleapis.com/auth/drive"
      End Function

      Shared Function DriveFile() As String
         DriveFile = "https://www.googleapis.com/auth/drive.file"
      End Function

      Shared Function DriveReadonly() As String
         DriveReadonly = "https://www.googleapis.com/auth/drive.readonly"
      End Function

      Shared Function DriveMetadata() As String
         DriveMetadata = "https://www.googleapis.com/auth/drive.metadata"
      End Function

      Shared Function DriveMetadataReadonly() As String
         DriveMetadataReadonly = "https://www.googleapis.com/auth/drive.metadata.readonly"
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
