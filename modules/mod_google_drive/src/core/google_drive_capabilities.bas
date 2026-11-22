Imports mod_tobject

Namespace google_drive_capabilities

   Class GoogleDriveCapabilities
      Inherits TTObject

      CanFiles As Boolean
      CanPermissions As Boolean
      CanAbout As Boolean
      CanResumableUpload As Boolean
      CanRangeDownload As Boolean

      Sub New()
         MyBase.New()
      End Sub

      Shared Function CoreBackup() As GoogleDriveCapabilities
         Dim caps As New GoogleDriveCapabilities()
         caps.CanFiles = True
         caps.CanPermissions = True
         caps.CanAbout = True
         caps.CanResumableUpload = True
         caps.CanRangeDownload = True
         CoreBackup = caps
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDriveCapabilities")
            .Prop("CanFiles", me.CanFiles)
            .Prop("CanPermissions", me.CanPermissions)
            .Prop("CanAbout", me.CanAbout)
            .Prop("CanResumableUpload", me.CanResumableUpload)
            .Prop("CanRangeDownload", me.CanRangeDownload)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
