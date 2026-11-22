Imports google_auth_store
Imports google_auth_token_set
Imports google_auth_config
Imports configuracao_google_drive
Imports google_drive_token_mapper

Namespace google_drive_token_store_sql

   Class GoogleDriveTokenStoreSql
      Inherits GoogleTokenStore

      Private _config As GoogleAuthConfig

      Sub New(pConfig As GoogleAuthConfig = Null)
         MyBase.New()
         me._config = pConfig
      End Sub

      Overrides Function Load(pKey As String) As GoogleTokenSet
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         If Not Assigned(row) Then
            Load = Null
            Exit Function
         End If
         Dim tokens As GoogleTokenSet = GoogleDriveTokenMapper.ToTokens(row)
         row.Free()
         If Not Assigned(tokens) Then
            Load = Null
            Exit Function
         End If
         If tokens.HasAccessToken() Or tokens.HasRefreshToken() Then
            Load = tokens
         Else
            tokens.Free()
            Load = Null
         End If
      End Function

      Overrides Sub Save(pKey As String, pTokens As GoogleTokenSet)
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         Dim created As Boolean = False
         If Not Assigned(row) Then
            row = New TConfiguracaoGoogleDrive()
            row.Titulo = "Google Drive"
            row.Ativo = True
            created = True
         End If
         If Assigned(pTokens) Then
            GoogleDriveTokenMapper.ApplyTokens(row, pTokens)
         Else
            GoogleDriveTokenMapper.ClearTokens(row)
         End If
         row.StoreKey = Trim(pKey)
         If Assigned(me._config) Then
            If Trim(row.ClientId) = "" Then
               GoogleDriveTokenMapper.ApplyConfig(row, me._config)
            End If
         End If
         If created Then
            row.Insert()
         Else
            row.Update()
         End If
         row.Free()
      End Sub

      Overrides Sub Clear(pKey As String)
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         If Not Assigned(row) Then
            Exit Sub
         End If
         GoogleDriveTokenMapper.ClearTokens(row)
         row.Update()
         row.Free()
      End Sub

      Sub ApplyProfile(pEmail As String, pName As String)
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         If Not Assigned(row) Then
            Throw New Exception("Google Drive configuration not found.")
         End If
         If Trim(pEmail) <> "" Then
            row.Email = Trim(pEmail)
         End If
         If Trim(pName) <> "" Then
            row.Nome = Trim(pName)
         End If
         row.Update()
         row.Free()
      End Sub

      Overrides Sub Dispose()
         me._config = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
