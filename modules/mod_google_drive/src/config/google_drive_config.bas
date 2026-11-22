Imports mod_tobject
Imports google_drive_enums
Imports google_drive_json

Namespace google_drive_config

   Class GoogleDriveConfig
      Inherits TTObject

      ApiVersion As GoogleDriveApiVersion
      Timeout As Integer
      RetryCount As Integer
      RetryBaseDelayMs As Integer
      ChunkSizeBytes As Integer
      AdaptiveChunkSize As Boolean
      SimpleUploadMaxBytes As Int64
      FileFields As String
      AboutFields As String
      PermissionFields As String
      SupportsAllDrives As Boolean
      IncludeItemsFromAllDrives As Boolean

      Sub New()
         MyBase.New()
         me.ApiVersion = GoogleDriveApiVersion.V3()
         me.Timeout = 300000
         me.RetryCount = 3
         me.RetryBaseDelayMs = 1000
         me.ChunkSizeBytes = GoogleDriveJson.DefaultChunkBytes()
         me.AdaptiveChunkSize = False
         me.SimpleUploadMaxBytes = GoogleDriveJson.FromInteger(5242880)
         me.FileFields = "id,name,mimeType,parents,size,md5Checksum,trashed,createdTime,modifiedTime,webViewLink"
         me.AboutFields = "user,storageQuota,maxUploadSize"
         me.PermissionFields = "id,type,role,emailAddress,domain,displayName,allowFileDiscovery,expirationTime,deleted"
         me.SupportsAllDrives = True
         me.IncludeItemsFromAllDrives = True
      End Sub

      Function ListFields() As String
         ListFields = "nextPageToken,incompleteSearch,files(" & me.FileFields & ")"
      End Function

      Function PermissionListFields() As String
         PermissionListFields = "nextPageToken,permissions(" & me.PermissionFields & ")"
      End Function

      Sub Assign(pValue As GoogleDriveConfig)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.ApiVersion = pValue.ApiVersion
         me.Timeout = pValue.Timeout
         me.RetryCount = pValue.RetryCount
         me.RetryBaseDelayMs = pValue.RetryBaseDelayMs
         me.ChunkSizeBytes = pValue.ChunkSizeBytes
         me.AdaptiveChunkSize = pValue.AdaptiveChunkSize
         me.SimpleUploadMaxBytes = pValue.SimpleUploadMaxBytes
         me.FileFields = pValue.FileFields
         me.AboutFields = pValue.AboutFields
         me.PermissionFields = pValue.PermissionFields
         me.SupportsAllDrives = pValue.SupportsAllDrives
         me.IncludeItemsFromAllDrives = pValue.IncludeItemsFromAllDrives
      End Sub

      Overrides Function Clone() As GoogleDriveConfig
         Dim copy As New GoogleDriveConfig()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDriveConfig")
            .Prop("ApiVersion", me.ApiVersion.AsString)
            .Prop("Timeout", me.Timeout)
            .Prop("ChunkSizeBytes", me.ChunkSizeBytes)
            .Prop("AdaptiveChunkSize", me.AdaptiveChunkSize)
            .Prop("FileFields", me.FileFields)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         me.ApiVersion = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
