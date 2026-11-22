Imports mod_tobject

Namespace google_drive_upload_control

   Class GoogleDriveUploadControl
      Inherits TTObject

      Private _pauseRequested As Boolean
      Private _cancelRequested As Boolean
      Private _paused As Boolean
      Private _cancelled As Boolean

      Sub New()
         MyBase.New()
         me.Reset()
      End Sub

      Sub RequestPause()
         me._pauseRequested = True
      End Sub

      Sub RequestCancel()
         me._cancelRequested = True
      End Sub

      Function PauseRequested() As Boolean
         If me._cancelRequested Then
            PauseRequested = False
            Exit Function
         End If
         PauseRequested = me._pauseRequested
      End Function

      Function CancelRequested() As Boolean
         CancelRequested = me._cancelRequested
      End Function

      Sub MarkPaused()
         me._paused = True
      End Sub

      Sub MarkCancelled()
         me._cancelled = True
      End Sub

      Function WasPaused() As Boolean
         WasPaused = me._paused
      End Function

      Function WasCancelled() As Boolean
         WasCancelled = me._cancelled
      End Function

      Sub Reset()
         me._pauseRequested = False
         me._cancelRequested = False
         me._paused = False
         me._cancelled = False
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
