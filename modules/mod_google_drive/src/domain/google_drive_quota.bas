Imports mod_tobject
Imports google_drive_json

Namespace google_drive_quota

   Class GoogleDriveQuota
      Inherits TTObject

      Limit As Int64
      Usage As Int64
      UsageInDrive As Int64
      UsageInDriveTrash As Int64
      HasLimit As Boolean

      Sub New()
         MyBase.New()
         me.Limit = GoogleDriveJson.Zero64()
         me.Usage = GoogleDriveJson.Zero64()
         me.UsageInDrive = GoogleDriveJson.Zero64()
         me.UsageInDriveTrash = GoogleDriveJson.Zero64()
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As GoogleDriveQuota
         Dim value As New GoogleDriveQuota()
         If Not Assigned(pJson) Then
            FromJson = value
            Exit Function
         End If
         If pJson.Has("limit") Then
            value.HasLimit = True
            value.Limit = GoogleDriveJson.ParseInt64(pJson.GetString("limit"))
         End If
         If pJson.Has("usage") Then
            value.Usage = GoogleDriveJson.ParseInt64(pJson.GetString("usage"))
         End If
         If pJson.Has("usageInDrive") Then
            value.UsageInDrive = GoogleDriveJson.ParseInt64(pJson.GetString("usageInDrive"))
         End If
         If pJson.Has("usageInDriveTrash") Then
            value.UsageInDriveTrash = GoogleDriveJson.ParseInt64(pJson.GetString("usageInDriveTrash"))
         End If
         FromJson = value
      End Function

      Function Available() As Int64
         If Not me.HasLimit Then
            Available = GoogleDriveJson.Zero64()
            Exit Function
         End If
         If me.Limit <= me.Usage Then
            Available = GoogleDriveJson.Zero64()
            Exit Function
         End If
         Available = me.Limit - me.Usage
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         If me.HasLimit Then
            json.PutString("limit", GoogleDriveJson.Int64Text(me.Limit))
         End If
         json.PutString("usage", GoogleDriveJson.Int64Text(me.Usage))
         json.PutString("usageInDrive", GoogleDriveJson.Int64Text(me.UsageInDrive))
         json.PutString("usageInDriveTrash", GoogleDriveJson.Int64Text(me.UsageInDriveTrash))
         ToJson = json
      End Function

      Sub Assign(pValue As GoogleDriveQuota)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Limit = pValue.Limit
         me.Usage = pValue.Usage
         me.UsageInDrive = pValue.UsageInDrive
         me.UsageInDriveTrash = pValue.UsageInDriveTrash
         me.HasLimit = pValue.HasLimit
      End Sub

      Overrides Function Clone() As GoogleDriveQuota
         Dim copy As New GoogleDriveQuota()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDriveQuota")
            .PropStr("Limit", GoogleDriveJson.Int64Text(me.Limit))
            .PropStr("Usage", GoogleDriveJson.Int64Text(me.Usage))
            .Prop("HasLimit", me.HasLimit)
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
