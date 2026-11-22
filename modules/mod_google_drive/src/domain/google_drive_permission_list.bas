Imports mod_tlist
Imports mod_tobject
Imports google_drive_permission

Namespace google_drive_permission_list

   Class GoogleDrivePermissionList
      Inherits TTObject

      Kind As String
      NextPageToken As String
      Permissions As TTList<GoogleDrivePermission>

      Sub New()
         MyBase.New()
         me.Permissions = New TTList<GoogleDrivePermission>()
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As GoogleDrivePermissionList
         Dim listing As New GoogleDrivePermissionList()
         If Not Assigned(pJson) Then
            FromJson = listing
            Exit Function
         End If
         If pJson.Has("kind") Then
            listing.Kind = pJson.GetString("kind")
         End If
         If pJson.Has("nextPageToken") Then
            listing.NextPageToken = pJson.GetString("nextPageToken")
         End If
         If pJson.Has("permissions") Then
            Dim arr As TJSONArray = pJson.GetArray("permissions")
            If Assigned(arr) Then
               Dim i As Integer
               Dim last As Integer = arr.Length() - 1
               For i = 0 To last
                  Dim itemJson As TJSONObject = arr.GetJSONObject(i)
                  listing.Permissions.Push(GoogleDrivePermission.FromJson(itemJson))
                  If Assigned(itemJson) Then
                     itemJson.Free()
                  End If
               Next
               arr.Free()
            End If
         End If
         FromJson = listing
      End Function

      Function HasMore() As Boolean
         HasMore = Trim(me.NextPageToken) <> ""
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDrivePermissionList")
            .Prop("Count", me.Permissions.Length)
            .Prop("NextPageToken", me.NextPageToken)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Permissions) Then
            me.Permissions.Free()
            me.Permissions = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
