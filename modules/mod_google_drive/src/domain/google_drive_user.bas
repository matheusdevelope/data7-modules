Imports mod_tobject

Namespace google_drive_user

   Class GoogleDriveUser
      Inherits TTObject

      DisplayName As String
      EmailAddress As String
      PermissionId As String
      Kind As String

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As GoogleDriveUser
         Dim value As New GoogleDriveUser()
         If Not Assigned(pJson) Then
            FromJson = value
            Exit Function
         End If
         If pJson.Has("displayName") Then
            value.DisplayName = pJson.GetString("displayName")
         End If
         If pJson.Has("emailAddress") Then
            value.EmailAddress = pJson.GetString("emailAddress")
         End If
         If pJson.Has("permissionId") Then
            value.PermissionId = pJson.GetString("permissionId")
         End If
         If pJson.Has("kind") Then
            value.Kind = pJson.GetString("kind")
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         json.PutString("displayName", me.DisplayName)
         json.PutString("emailAddress", me.EmailAddress)
         json.PutString("permissionId", me.PermissionId)
         json.PutString("kind", me.Kind)
         ToJson = json
      End Function

      Sub Assign(pValue As GoogleDriveUser)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.DisplayName = pValue.DisplayName
         me.EmailAddress = pValue.EmailAddress
         me.PermissionId = pValue.PermissionId
         me.Kind = pValue.Kind
      End Sub

      Overrides Function Clone() As GoogleDriveUser
         Dim copy As New GoogleDriveUser()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDriveUser")
            .Prop("DisplayName", me.DisplayName)
            .Prop("EmailAddress", me.EmailAddress)
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
