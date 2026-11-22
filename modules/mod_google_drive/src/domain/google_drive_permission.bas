Imports mod_tobject
Imports google_drive_json

Namespace google_drive_permission

   Class GoogleDrivePermission
      Inherits TTObject

      Id As String
      TypeName As String
      Role As String
      EmailAddress As String
      Domain As String
      DisplayName As String
      AllowFileDiscovery As Boolean
      ExpirationTime As String
      Deleted As Boolean
      Kind As String

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function GetID() As String
         If Trim(me.Id) <> "" Then
            GetID = me.Id
            Exit Function
         End If
         GetID = MyBase.GetID()
      End Function

      Shared Function FromJson(pJson As TJSONObject) As GoogleDrivePermission
         Dim item As New GoogleDrivePermission()
         If Not Assigned(pJson) Then
            FromJson = item
            Exit Function
         End If
         If pJson.Has("id") Then
            item.Id = pJson.GetString("id")
         End If
         If pJson.Has("type") Then
            item.TypeName = pJson.GetString("type")
         End If
         If pJson.Has("role") Then
            item.Role = pJson.GetString("role")
         End If
         If pJson.Has("emailAddress") Then
            item.EmailAddress = pJson.GetString("emailAddress")
         End If
         If pJson.Has("domain") Then
            item.Domain = pJson.GetString("domain")
         End If
         If pJson.Has("displayName") Then
            item.DisplayName = pJson.GetString("displayName")
         End If
         If pJson.Has("allowFileDiscovery") Then
            item.AllowFileDiscovery = pJson.GetBoolean("allowFileDiscovery")
         End If
         If pJson.Has("expirationTime") Then
            item.ExpirationTime = pJson.GetString("expirationTime")
         End If
         If pJson.Has("deleted") Then
            item.Deleted = pJson.GetBoolean("deleted")
         End If
         If pJson.Has("kind") Then
            item.Kind = pJson.GetString("kind")
         End If
         FromJson = item
      End Function

      Function ToJson() As TJSONObject
         Dim jsonText As String = "{"
         Dim needComma As Boolean = False
         If Trim(me.TypeName) <> "" Then
            jsonText = jsonText & GoogleDriveJson.Quote("type") & ":" & GoogleDriveJson.Quote(me.TypeName)
            needComma = True
         End If
         If Trim(me.Role) <> "" Then
            If needComma Then
               jsonText = jsonText & ","
            End If
            jsonText = jsonText & GoogleDriveJson.Quote("role") & ":" & GoogleDriveJson.Quote(me.Role)
            needComma = True
         End If
         If Trim(me.EmailAddress) <> "" Then
            If needComma Then
               jsonText = jsonText & ","
            End If
            jsonText = jsonText & GoogleDriveJson.Quote("emailAddress") & ":" & GoogleDriveJson.Quote(me.EmailAddress)
            needComma = True
         End If
         If Trim(me.Domain) <> "" Then
            If needComma Then
               jsonText = jsonText & ","
            End If
            jsonText = jsonText & GoogleDriveJson.Quote("domain") & ":" & GoogleDriveJson.Quote(me.Domain)
            needComma = True
         End If
         If me.AllowFileDiscovery Then
            If needComma Then
               jsonText = jsonText & ","
            End If
            jsonText = jsonText & GoogleDriveJson.Quote("allowFileDiscovery") & ":true"
            needComma = True
         End If
         If Trim(me.ExpirationTime) <> "" Then
            If needComma Then
               jsonText = jsonText & ","
            End If
            jsonText = jsonText & GoogleDriveJson.Quote("expirationTime") & ":" & GoogleDriveJson.Quote(me.ExpirationTime)
         End If
         jsonText = jsonText & "}"
         ToJson = New TJSONObject(jsonText)
      End Function

      Sub Assign(pValue As GoogleDrivePermission)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Id = pValue.Id
         me.TypeName = pValue.TypeName
         me.Role = pValue.Role
         me.EmailAddress = pValue.EmailAddress
         me.Domain = pValue.Domain
         me.DisplayName = pValue.DisplayName
         me.AllowFileDiscovery = pValue.AllowFileDiscovery
         me.ExpirationTime = pValue.ExpirationTime
         me.Deleted = pValue.Deleted
         me.Kind = pValue.Kind
      End Sub

      Overrides Function Clone() As GoogleDrivePermission
         Dim copy As New GoogleDrivePermission()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDrivePermission")
            .Prop("Id", me.Id)
            .Prop("TypeName", me.TypeName)
            .Prop("Role", me.Role)
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
