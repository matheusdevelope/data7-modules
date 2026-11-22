Imports mod_tobject
Imports google_drive_config
Imports google_drive_errors

Namespace google_drive_validation

   Class GoogleDriveValidator
      Inherits TTObject

      Shared Sub Validate(pConfig As GoogleDriveConfig)
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleDriveErrors.ConfigRequired())
         End If
         If pConfig.Timeout <= 0 Then
            Throw New Exception(GoogleDriveErrors.InvalidTimeout())
         End If
         If (pConfig.ChunkSizeBytes <= 0) Or ((pConfig.ChunkSizeBytes Mod 262144) <> 0) Then
            Throw New Exception(GoogleDriveErrors.InvalidChunkSize(pConfig.ChunkSizeBytes))
         End If
      End Sub

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
