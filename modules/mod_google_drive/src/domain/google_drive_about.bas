Imports mod_tobject
Imports google_drive_user
Imports google_drive_quota
Imports google_drive_json
Imports google_drive_errors

Namespace google_drive_about

   Class GoogleDriveAbout
      Inherits TTObject

      Kind As String
      MaxUploadSize As Int64
      DriveUser As GoogleDriveUser
      Quota As GoogleDriveQuota

      Sub New()
         MyBase.New()
         me.DriveUser = New GoogleDriveUser()
         me.Quota = New GoogleDriveQuota()
         me.MaxUploadSize = GoogleDriveJson.Zero64()
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As GoogleDriveAbout
         Dim value As New GoogleDriveAbout()
         If Not Assigned(pJson) Then
            FromJson = value
            Exit Function
         End If
         If pJson.Has("kind") Then
            value.Kind = pJson.GetString("kind")
         End If
         If pJson.Has("maxUploadSize") Then
            value.MaxUploadSize = GoogleDriveJson.ParseInt64(pJson.GetString("maxUploadSize"))
         End If
         If pJson.Has("user") Then
            Dim userJson As TJSONObject = pJson.GetJSONObject("user")
            If Assigned(value.DriveUser) Then
               value.DriveUser.Free()
            End If
            value.DriveUser = GoogleDriveUser.FromJson(userJson)
            If Assigned(userJson) Then
               userJson.Free()
            End If
         End If
         If pJson.Has("storageQuota") Then
            Dim quotaJson As TJSONObject = pJson.GetJSONObject("storageQuota")
            If Assigned(value.Quota) Then
               value.Quota.Free()
            End If
            value.Quota = GoogleDriveQuota.FromJson(quotaJson)
            If Assigned(quotaJson) Then
               quotaJson.Free()
            End If
         End If
         FromJson = value
      End Function

      Sub EnsureCanUpload(pSize As Integer)
         ' data7:disable-next-line type-mismatch
         me.EnsureCanUpload(GoogleDriveJson.FromInteger(pSize))
      End Sub

      Sub EnsureCanUpload(pSize As Int64)
         If (me.MaxUploadSize > GoogleDriveJson.Zero64()) And (pSize > me.MaxUploadSize) Then
            Throw New Exception(GoogleDriveErrors.FileTooLarge(pSize, me.MaxUploadSize))
         End If
         If Assigned(me.Quota) Then
            If me.Quota.HasLimit Then
               Dim available As Int64 = me.Quota.Available()
               If pSize > available Then
                  Throw New Exception(GoogleDriveErrors.InsufficientQuota(pSize, available))
               End If
            End If
         End If
      End Sub

      Sub Assign(pValue As GoogleDriveAbout)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Kind = pValue.Kind
         me.MaxUploadSize = pValue.MaxUploadSize
         If Assigned(me.DriveUser) Then
            me.DriveUser.Free()
         End If
         If Assigned(pValue.DriveUser) Then
            me.DriveUser = pValue.DriveUser.Clone()
         Else
            me.DriveUser = New GoogleDriveUser()
         End If
         If Assigned(me.Quota) Then
            me.Quota.Free()
         End If
         If Assigned(pValue.Quota) Then
            me.Quota = pValue.Quota.Clone()
         Else
            me.Quota = New GoogleDriveQuota()
         End If
      End Sub

      Overrides Function Clone() As GoogleDriveAbout
         Dim copy As New GoogleDriveAbout()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDriveAbout")
            .PropStr("MaxUploadSize", GoogleDriveJson.Int64Text(me.MaxUploadSize))
            If Assigned(me.Quota) Then
               .PropStr("Usage", GoogleDriveJson.Int64Text(me.Quota.Usage))
            End If
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.DriveUser) Then
            me.DriveUser.Free()
            me.DriveUser = Null
         End If
         If Assigned(me.Quota) Then
            me.Quota.Free()
            me.Quota = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
