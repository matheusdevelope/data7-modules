Imports TFile
Imports TPath
Imports TDirectory
Imports mod_tobject
Imports google_auth
Imports google_auth_config
Imports google_auth_store
Imports google_auth_connect
Imports google_drive_scopes
Imports configuracao_google_drive
Imports google_drive_token_mapper
Imports google_drive_token_store_sql
Imports google_drive_sql_migrations

Namespace google_drive_sql_stores

   Class GoogleDriveSqlStores
      Inherits TTObject

      Shared Function Migrate() As Integer
         Dim applied As Integer
         applied = GoogleDriveSqlMigrations.Execute()
         Migrate = applied
      End Function

      Shared Function Connect(pTitulo As String = "Google Drive", pInteractive As Boolean = True) As GoogleAuthService
         Dim cfg As GoogleAuthConfig = GoogleDriveSqlStores.ResolveConfig()
         cfg.Scopes.Add("openid")
         cfg.Scopes.Add("email")
         cfg.Scopes.Add("profile")
         cfg.Scopes.Add(GoogleDriveScopes.Drive())
         cfg.Prompt = "consent"
         If cfg.CallbackPort <= 0 Then
            cfg.CallbackPort = 8085
         End If
         If Trim(cfg.RedirectUri) = "" Then
            cfg.RedirectUri = "http://localhost:8085/"
         End If
         Dim titleValue As String = Trim(pTitulo)
         If titleValue = "" Then
            titleValue = "Google Drive"
         End If
         Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg, titleValue)
         Dim auth As GoogleAuthService = Null
         Try
            auth = GoogleAuthConnect.Run(cfg, tokenStore, True, pInteractive, "Conexão Google Drive")
         Catch ex As Exception
            tokenStore.Free()
            GoogleDriveSqlStores.DropConfig(cfg)
            Throw New Exception(ex._GetMessage())
         End Try
         Connect = auth
      End Function

      Shared Function Open(pConfig As GoogleAuthConfig = Null, pTitulo As String = "") As GoogleTokenStore
         If Assigned(pConfig) Then
            Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
            If Not Assigned(row) Then
               row = New TConfiguracaoGoogleDrive()
               Dim titleValue As String = Trim(pTitulo)
               If titleValue = "" Then
                  titleValue = "Google Drive"
               End If
               row.Titulo = titleValue
               row.Ativo = True
               GoogleDriveTokenMapper.ApplyConfig(row, pConfig)
               row.Insert()
            Else
               If Trim(pTitulo) <> "" Then
                  row.Titulo = Trim(pTitulo)
               End If
               GoogleDriveTokenMapper.ApplyConfig(row, pConfig)
               row.Update()
            End If
            row.Free()
         Else
            If Not TConfiguracaoGoogleDrive.HasRow() Then
               Throw New Exception("Google Drive configuration not found.")
            End If
         End If
         Open = New GoogleDriveTokenStoreSql(pConfig)
      End Function

      Shared Function ConfigOf() As GoogleAuthConfig
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         If Not Assigned(row) Then
            Throw New Exception("Google Drive configuration not found.")
         End If
         If Trim(row.ClientId) = "" Then
            row.Free()
            Throw New Exception("Google Drive configuration is missing OAuth client credentials.")
         End If
         Dim cfg As GoogleAuthConfig = GoogleDriveTokenMapper.ToConfig(row)
         row.Free()
         ConfigOf = cfg
      End Function

      Shared Sub ApplyProfile(pEmail As String, pName As String)
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

      Shared Function ResolveConfig() As GoogleAuthConfig
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         If Assigned(row) Then
            If Trim(row.ClientId) <> "" Then
               Dim fromRow As GoogleAuthConfig = GoogleDriveTokenMapper.ToConfig(row)
               row.Free()
               ResolveConfig = fromRow
               Exit Function
            End If
            row.Free()
         End If
         Dim fromFile As GoogleAuthConfig = GoogleDriveSqlStores.LoadOauthFileIfComplete()
         If Assigned(fromFile) Then
            ResolveConfig = fromFile
            Exit Function
         End If
         ResolveConfig = New GoogleAuthConfig()
      End Function

      Shared Function LoadOauthFileIfComplete() As GoogleAuthConfig
         Dim cfgPath As String = GoogleDriveSqlStores.OauthFilePath()
         If Trim(cfgPath) = "" Then
            LoadOauthFileIfComplete = Null
            Exit Function
         End If
         Dim loaded As GoogleAuthConfig = GoogleAuthConfig.FromFile(cfgPath)
         If Not loaded.HasClientCredentials() Then
            GoogleDriveSqlStores.DropConfig(loaded)
            LoadOauthFileIfComplete = Null
            Exit Function
         End If
         LoadOauthFileIfComplete = loaded
      End Function

      Shared Function OauthFilePath() As String
         Dim folder As String = TDirectory.GetCurrentDirectory()
         Dim cfgPath As String = "google-oauth.json"
         If Trim(folder) <> "" Then
            cfgPath = TPath.Combine(folder, "google-oauth.json")
         End If
         If TFile.Exists(cfgPath) Then
            OauthFilePath = cfgPath
            Exit Function
         End If
         If TFile.Exists("google-oauth.json") Then
            OauthFilePath = "google-oauth.json"
            Exit Function
         End If
         OauthFilePath = ""
      End Function

      Shared Sub DropConfig(pCfg As GoogleAuthConfig)
         If Not Assigned(pCfg) Then
            Exit Sub
         End If
         pCfg.ApiVersion = Null
         pCfg.GrantType = Null
         pCfg.ConsentKind = Null
         pCfg.Free()
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
