Imports mod_tobject

Namespace google_drive_client

   MustInherit Class GoogleDriveClient
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function ApiVersionName() As String
         Throw New Exception("ApiVersionName must be implemented.")
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
