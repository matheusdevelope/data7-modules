Imports mod_tobject
Imports google_drive_progress
Imports google_drive_upload_control

Namespace google_drive_upload_options

   Class GoogleDriveUploadOptions
      Inherits TTObject

      Name As String
      ParentId As String
      MimeType As String
      DriveFileId As String
      SessionFile As String
      SessionUri As String
      CheckQuota As Boolean
      OnProgress As GoogleDriveProgressDel
      DownloadControl As GoogleDriveUploadControl

      Sub New()
         MyBase.New()
         me.CheckQuota = True
         me.DownloadControl = Null
      End Sub

      Overrides Sub Dispose()
         me.OnProgress = Null
         me.DownloadControl = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
