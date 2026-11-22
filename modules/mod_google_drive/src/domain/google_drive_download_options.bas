Imports mod_tobject
Imports google_drive_progress
Imports google_drive_json
Imports google_drive_upload_control

Namespace google_drive_download_options

   Class GoogleDriveDownloadOptions
      Inherits TTObject

      DestinationPath As String
      ChunkSizeBytes As Integer
      ResumePartial As Boolean
      OnProgress As GoogleDriveProgressDel
      DownloadControl As GoogleDriveUploadControl

      Sub New()
         MyBase.New()
         me.ChunkSizeBytes = GoogleDriveJson.DefaultChunkBytes()
         me.ResumePartial = False
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
