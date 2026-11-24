Imports google_auth_store
Imports google_auth_token_set
Imports google_auth_config
Imports configuracao_google_drive
Imports google_drive_token_mapper

Namespace google_drive_token_store_sql

   Class GoogleDriveTokenStoreSql
      Inherits GoogleTokenStore

      Private _config As GoogleAuthConfig
      Private _boundCod As Integer

      Sub New(pConfig As GoogleAuthConfig = Null, pBoundCod As Integer = 0)
         MyBase.New()
         me._config = pConfig
         me._boundCod = pBoundCod
      End Sub

      Function BoundCod() As Integer
         BoundCod = me._boundCod
      End Function

      Overrides Function Load(pKey As String) As GoogleTokenSet
         Dim row As TConfiguracaoGoogleDrive
         Dim tokens As GoogleTokenSet
         row = me.RowForKey(pKey)
         If Not Assigned(row) Then
            Load = Null
            Exit Function
         End If
         tokens = GoogleDriveTokenMapper.ToTokens(row)
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
         Dim row As TConfiguracaoGoogleDrive
         Dim created As Boolean
         Dim titleValue As String
         created = False
         row = me.RowForKey(pKey)
         If Not Assigned(row) Then
            row = New TConfiguracaoGoogleDrive()
            titleValue = "Google Drive"
            If Assigned(me._config) Then
               If Trim(me._config.AccountId) <> "" Then
                  titleValue = Trim(me._config.AccountId)
               End If
            End If
            row.Titulo = titleValue
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
            If Trim(pKey) <> "" Then
               row.StoreKey = Trim(pKey)
            End If
         End If
         If created Then
            row.Insert()
            me._boundCod = row.CodConfiguracaoGoogleDrive
         Else
            row.Update()
            If me._boundCod <= 0 Then
               me._boundCod = row.CodConfiguracaoGoogleDrive
            End If
         End If
         row.Free()
      End Sub

      Overrides Sub Clear(pKey As String)
         Dim row As TConfiguracaoGoogleDrive
         row = me.RowForKey(pKey)
         If Not Assigned(row) Then
            Exit Sub
         End If
         GoogleDriveTokenMapper.ClearTokens(row)
         row.Update()
         row.Free()
      End Sub

      Sub ApplyProfile(pEmail As String, pName As String, pKey As String = "")
         Dim row As TConfiguracaoGoogleDrive
         row = me.RowForKey(pKey)
         If Not Assigned(row) Then
            Throw New Exception("Google Drive configuration not found.")
         End If
         If Trim(pEmail) <> "" Then
            row.Email = Trim(pEmail)
         End If
         If Trim(pName) <> "" Then
            row.Nome = Trim(pName)
         End If
         If (Trim(row.ClientId) <> "") And (Trim(row.Email) <> "") Then
            row.StoreKey = Trim(row.ClientId) & "|" & Trim(row.Email)
         End If
         row.Update()
         row.Free()
      End Sub

      Private Function RowForKey(pKey As String) As TConfiguracaoGoogleDrive
         Dim row As TConfiguracaoGoogleDrive
         row = Null
         If me._boundCod > 0 Then
            row = TConfiguracaoGoogleDrive.FindByKey(me._boundCod)
            If Assigned(row) Then
               RowForKey = row
               Exit Function
            End If
         End If
         RowForKey = TConfiguracaoGoogleDrive.FindByStoreKey(pKey)
      End Function

      Overrides Sub Dispose()
         me._config = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
