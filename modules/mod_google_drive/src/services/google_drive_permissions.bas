Imports http_headers
Imports mod_tobject
Imports google_drive_http
Imports google_drive_permission
Imports google_drive_permission_list
Imports google_drive_errors

Namespace google_drive_permissions

   Class GoogleDrivePermissions
      Inherits TTObject

      Private _http As GoogleDriveHttp

      Sub New(pHttp As GoogleDriveHttp)
         MyBase.New()
         If Not Assigned(pHttp) Then
            Throw New Exception(GoogleDriveErrors.HttpRequired())
         End If
         me._http = pHttp
      End Sub

      Function List(pFileId As String, pPageToken As String = "") As GoogleDrivePermissionList
         me.RequireFileId(pFileId)
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().PermissionListFields())
         If Trim(pPageToken) <> "" Then
            query.Define("pageToken", Trim(pPageToken))
         End If
         me.ApplyDriveFlags(query)
         Dim json As TJSONObject = me._http.GetJson(me._http.Endpoints().PermissionsPath(pFileId), query)
         query.Free()
         Dim listing As GoogleDrivePermissionList = GoogleDrivePermissionList.FromJson(json)
         json.Free()
         List = listing
      End Function

      Function Gett(pFileId As String, pPermissionId As String) As GoogleDrivePermission
         me.RequireFileId(pFileId)
         If Trim(pPermissionId) = "" Then
            Throw New Exception(GoogleDriveErrors.PermissionIdRequired())
         End If
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().PermissionFields)
         me.ApplyDriveFlags(query)
         Dim json As TJSONObject = me._http.GetJson(me._http.Endpoints().PermissionPath(pFileId, pPermissionId), query)
         query.Free()
         Dim item As GoogleDrivePermission = GoogleDrivePermission.FromJson(json)
         json.Free()
         Gett = item
      End Function

      Function Add(pFileId As String, pPermission As GoogleDrivePermission) As GoogleDrivePermission
         me.RequireFileId(pFileId)
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().PermissionFields)
         If (Trim(pPermission.TypeName) <> "anyone") And (Trim(pPermission.TypeName) <> "domain") Then
            query.Define("sendNotificationEmail", "false")
         End If
         me.ApplyDriveFlags(query)
         Dim body As TJSONObject = pPermission.ToJson()
         Dim json As TJSONObject = me._http.PostJson(me._http.Endpoints().PermissionsPath(pFileId), query, body)
         query.Free()
         body.Free()
         Dim created As GoogleDrivePermission = GoogleDrivePermission.FromJson(json)
         json.Free()
         Add = created
      End Function

      Function Update(pFileId As String, pPermission As GoogleDrivePermission) As GoogleDrivePermission
         me.RequireFileId(pFileId)
         If Trim(pPermission.Id) = "" Then
            Throw New Exception(GoogleDriveErrors.PermissionIdRequired())
         End If
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().PermissionFields)
         me.ApplyDriveFlags(query)
         Dim body As TJSONObject = pPermission.ToJson()
         Dim json As TJSONObject = me._http.PatchJson(me._http.Endpoints().PermissionPath(pFileId, pPermission.Id), query, body)
         query.Free()
         body.Free()
         Dim updated As GoogleDrivePermission = GoogleDrivePermission.FromJson(json)
         json.Free()
         Update = updated
      End Function

      Sub Delete(pFileId As String, pPermissionId As String)
         me.RequireFileId(pFileId)
         If Trim(pPermissionId) = "" Then
            Throw New Exception(GoogleDriveErrors.PermissionIdRequired())
         End If
         Dim query As New HttpParams()
         me.ApplyDriveFlags(query)
         me._http.Delete(me._http.Endpoints().PermissionPath(pFileId, pPermissionId), query)
         query.Free()
      End Sub

      Sub RequireFileId(pFileId As String)
         If Trim(pFileId) = "" Then
            Throw New Exception(GoogleDriveErrors.FileIdRequired())
         End If
      End Sub

      Sub ApplyDriveFlags(pQuery As HttpParams)
         If me._http.Config().SupportsAllDrives Then
            pQuery.Define("supportsAllDrives", "true")
         End If
      End Sub

      Overrides Sub Dispose()
         me._http = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
