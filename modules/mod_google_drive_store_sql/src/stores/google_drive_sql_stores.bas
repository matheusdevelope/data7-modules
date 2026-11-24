Imports TFile
Imports TPath
Imports TDirectory
Imports Collections
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

      Shared Function ListConnections() As TTList<TConfiguracaoGoogleDrive>
         GoogleDriveSqlStores.Migrate()
         ListConnections = TConfiguracaoGoogleDrive.Fetch("", "Titulo")
      End Function

      Shared Function Connect(pTitulo As String = "Google Drive", pInteractive As Boolean = True) As GoogleAuthService
         Dim cfg As GoogleAuthConfig
         cfg = GoogleDriveSqlStores.ResolveConfig()
         Connect = GoogleDriveSqlStores.RunConnect(cfg, pTitulo, pInteractive, False)
      End Function

      Shared Function ConnectKey(pCod As Integer, pTitulo As String = "", pInteractive As Boolean = True) As GoogleAuthService
         Dim cfg As GoogleAuthConfig
         Dim titleValue As String
         titleValue = Trim(pTitulo)
         cfg = GoogleDriveSqlStores.ConfigOfKey(pCod)
         If titleValue = "" Then
            titleValue = "Google Drive"
         End If
         ConnectKey = GoogleDriveSqlStores.RunConnect(cfg, titleValue, pInteractive, False)
      End Function

      Shared Function Add(pTitulo As String = "Google Drive", pInteractive As Boolean = True) As GoogleAuthService
         Dim cfg As GoogleAuthConfig
         cfg = GoogleDriveSqlStores.ResolveConfig()
         cfg.AccountId = ""
         Add = GoogleDriveSqlStores.RunConnect(cfg, pTitulo, pInteractive, True)
      End Function

      Shared Function Open(pConfig As GoogleAuthConfig = Null, pTitulo As String = "", pInsertNew As Boolean = False) As GoogleTokenStore
         Dim row As TConfiguracaoGoogleDrive
         Dim titleValue As String
         Dim boundCod As Integer
         boundCod = 0
         titleValue = Trim(pTitulo)
         If titleValue = "" Then
            titleValue = "Google Drive"
         End If
         If Assigned(pConfig) Then
            row = Null
            If Not pInsertNew Then
               row = TConfiguracaoGoogleDrive.FindByStoreKey(pConfig.StoreKey())
            End If
            If Not Assigned(row) Then
               row = New TConfiguracaoGoogleDrive()
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
            boundCod = row.CodConfiguracaoGoogleDrive
            row.Free()
         End If
         Open = New GoogleDriveTokenStoreSql(pConfig, boundCod)
      End Function

      Shared Function ConfigOf() As GoogleAuthConfig
         Dim row As TConfiguracaoGoogleDrive
         row = TConfiguracaoGoogleDrive.CurrentRow()
         ConfigOf = GoogleDriveSqlStores.ConfigFromRow(row, True)
      End Function

      Shared Function ConfigOfKey(pCod As Integer) As GoogleAuthConfig
         Dim row As TConfiguracaoGoogleDrive
         row = TConfiguracaoGoogleDrive.FindByKey(pCod)
         ConfigOfKey = GoogleDriveSqlStores.ConfigFromRow(row, True)
      End Function

      Shared Sub ApplyProfile(pEmail As String, pName As String, pCod As Integer = 0)
         Dim row As TConfiguracaoGoogleDrive
         row = Null
         If pCod > 0 Then
            row = TConfiguracaoGoogleDrive.FindByKey(pCod)
         End If
         If Not Assigned(row) Then
            If Trim(pEmail) <> "" Then
               row = TConfiguracaoGoogleDrive.FindByEmail(pEmail)
            End If
         End If
         If Not Assigned(row) Then
            row = TConfiguracaoGoogleDrive.CurrentRow()
         End If
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

      Shared Function ResolveConfig() As GoogleAuthConfig
         Dim row As TConfiguracaoGoogleDrive
         Dim fromRow As GoogleAuthConfig
         Dim fromFile As GoogleAuthConfig
         row = TConfiguracaoGoogleDrive.CurrentRow()
         If Assigned(row) Then
            If Trim(row.ClientId) <> "" Then
               fromRow = GoogleDriveTokenMapper.ToConfig(row)
               row.Free()
               ResolveConfig = fromRow
               Exit Function
            End If
            row.Free()
         End If
         fromFile = GoogleDriveSqlStores.LoadOauthFileIfComplete()
         If Assigned(fromFile) Then
            ResolveConfig = fromFile
            Exit Function
         End If
         ResolveConfig = New GoogleAuthConfig()
      End Function

      Shared Function LoadOauthFileIfComplete() As GoogleAuthConfig
         Dim cfgPath As String
         Dim loaded As GoogleAuthConfig
         cfgPath = GoogleDriveSqlStores.OauthFilePath()
         If Trim(cfgPath) = "" Then
            LoadOauthFileIfComplete = Null
            Exit Function
         End If
         loaded = GoogleAuthConfig.FromFile(cfgPath)
         If Not loaded.HasClientCredentials() Then
            GoogleDriveSqlStores.DropConfig(loaded)
            LoadOauthFileIfComplete = Null
            Exit Function
         End If
         LoadOauthFileIfComplete = loaded
      End Function

      Shared Function OauthFilePath() As String
         Dim folder As String
         Dim cfgPath As String
         folder = TDirectory.GetCurrentDirectory()
         cfgPath = "google-oauth.json"
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

      Shared Function RunConnect(pConfig As GoogleAuthConfig, pTitulo As String, pInteractive As Boolean, pInsertNew As Boolean) As GoogleAuthService
         Dim cfg As GoogleAuthConfig
         Dim titleValue As String
         Dim tokenStore As GoogleTokenStore
         Dim auth As GoogleAuthService
         cfg = pConfig
         GoogleDriveSqlStores.ApplyDriveScopes(cfg)
         titleValue = Trim(pTitulo)
         If titleValue = "" Then
            titleValue = "Google Drive"
         End If
         tokenStore = GoogleDriveSqlStores.Open(cfg, titleValue, pInsertNew)
         auth = Null
         Try
            auth = GoogleAuthConnect.Run(cfg, tokenStore, True, pInteractive, "Conexão Google Drive")
         Catch ex As Exception
            tokenStore.Free()
            GoogleDriveSqlStores.DropConfig(cfg)
            Throw New Exception(ex._GetMessage())
         End Try
         RunConnect = auth
      End Function

      Shared Sub ApplyDriveScopes(pConfig As GoogleAuthConfig)
         If Not Assigned(pConfig) Then
            Exit Sub
         End If
         pConfig.Scopes.Add("openid")
         pConfig.Scopes.Add("email")
         pConfig.Scopes.Add("profile")
         pConfig.Scopes.Add(GoogleDriveScopes.Drive())
         pConfig.Prompt = "consent"
         If pConfig.CallbackPort <= 0 Then
            pConfig.CallbackPort = 8085
         End If
         If Trim(pConfig.RedirectUri) = "" Then
            pConfig.RedirectUri = "http://localhost:8085/"
         End If
      End Sub

      Shared Function ConfigFromRow(pRow As TConfiguracaoGoogleDrive, pFreeRow As Boolean) As GoogleAuthConfig
         Dim cfg As GoogleAuthConfig
         If Not Assigned(pRow) Then
            Throw New Exception("Google Drive configuration not found.")
         End If
         If Trim(pRow.ClientId) = "" Then
            If pFreeRow Then
               pRow.Free()
            End If
            Throw New Exception("Google Drive configuration is missing OAuth client credentials.")
         End If
         cfg = GoogleDriveTokenMapper.ToConfig(pRow)
         If pFreeRow Then
            pRow.Free()
         End If
         ConfigFromRow = cfg
      End Function

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
