Imports mod_tobject
Imports http_progress
Imports http_range
Imports http_transfer_control

Namespace http_download_options

   Class HttpDownloadOptions
      Inherits TTObject

      DestinationPath As String
      ChunkSizeBytes As Integer
      TotalBytes As Int64
      ResumePartial As Boolean
      OnProgress As HttpProgressDel
      TransferControl As HttpTransferControl

      Sub New()
         MyBase.New()
         me.ChunkSizeBytes = HttpRange.DefaultChunkBytes()
         me.TotalBytes = HttpRange.Zero64()
         me.ResumePartial = False
      End Sub

      Overrides Sub Dispose()
         me.OnProgress = Null
         me.TransferControl = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
