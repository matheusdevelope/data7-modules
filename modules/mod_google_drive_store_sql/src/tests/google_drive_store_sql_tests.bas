Imports Collections
Imports mod_tobject
Imports TablesSql
Imports http_client
Imports http_mock
Imports google_auth
Imports google_auth_config
Imports google_auth_store
Imports google_auth_token_set
Imports google_auth_http
Imports google_auth_endpoints_v2
Imports google_auth_consent
Imports google_auth_code
Imports configuracao_google_drive
Imports google_drive_token_mapper
Imports google_drive_sql_stores

Namespace google_drive_store_sql_tests

   Class GoogleDriveSqlConsentFake
      Inherits GoogleConsentHandler

      Private _codeValue As String
      Private _stateOverride As String

      Sub New(pCodeValue As String, pStateOverride As String = "")
         MyBase.New()
         me._codeValue = pCodeValue
         me._stateOverride = Trim(pStateOverride)
      End Sub

      Overrides Function RequestCode(pAuthUrl As String) As GoogleAuthCode
         Dim parsed As GoogleAuthCode = GoogleAuthCode.ExtractFromUrl(pAuthUrl)
         Dim stateValue As String = parsed.State
         If me._stateOverride <> "" Then
            stateValue = me._stateOverride
         End If
         Dim result As New GoogleAuthCode(me._codeValue, stateValue)
         parsed.Free()
         RequestCode = result
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class GoogleDriveStoreSqlTests
      Inherits TTObject

      Passed As Integer
      Failed As Integer
      Private _failures As StringList
      Private _stash As TConfiguracaoGoogleDrive

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
      End Sub

      Shared Sub RunAll()
         Dim suite As New GoogleDriveStoreSqlTests()
         suite.Run()
         suite.Free()
      End Sub

      Sub Run()
         print("==== mod_google_drive_store_sql ====")
         Try
            GoogleDriveSqlStores.Migrate()
            me.StashCurrentRow()
            me.CleanupRows()
            me.TestMapperRoundtrip()
            me.TestJwtProfile()
            me.TestOpenWithoutRow()
            me.TestMigrateAndCrud()
            me.TestConfigOf()
            me.TestEncryptionAtRest()
            me.TestClearKeepsCadastro()
            me.TestAuthInjection()
            me.TestConnectReusesSqlStore()
            me.TestTwoKeysAndList()
            me.TestAddDoesNotReplace()
         Catch ex As Exception
            me.AssertTrue(False, "suite aborted: " & ex._GetMessage())
         End Try
         Try
            me.CleanupRows()
            me.RestoreStash()
         Catch cleanupEx As Exception
         End Try
         me.PrintSummary()
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            print("  OK    " & pMsg)
         Else
            me.Failed = me.Failed + 1
            me._failures.Add(pMsg)
            print("  FAIL  " & pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg & " (obtido=[" & pGot & "] esperado=[" & pWant & "])")
      End Sub

      Sub PrintSummary()
         print("----")
         print("Passed: " & CStr(me.Passed) & "  Failed: " & CStr(me.Failed))
         If me.Failed > 0 Then
            print(me._failures.Text)
         End If
      End Sub

      Function SampleConfig() As GoogleAuthConfig
         Dim cfg As New GoogleAuthConfig()
         cfg.Credentials.ClientId = "client.apps.googleusercontent.com"
         cfg.Credentials.ClientSecret = "secret"
         cfg.Scopes.Add("https://www.googleapis.com/auth/drive")
         cfg.RedirectUri = "http://localhost:8085/"
         cfg.CallbackPort = 8085
         SampleConfig = cfg
      End Function

      Function SampleTokenJson() As String
         Dim json As New TJSONObject()
         json.PutString("access_token", "ya29.access")
         json.PutInteger("expires_in", 3600)
         json.PutString("refresh_token", "1//refresh")
         json.PutString("scope", "https://www.googleapis.com/auth/drive")
         json.PutString("token_type", "Bearer")
         SampleTokenJson = json.ToString()
         json.Free()
      End Function

      Function SampleTokens() As GoogleTokenSet
         Dim tokens As New GoogleTokenSet()
         tokens.AccessToken = "ya29.access"
         tokens.RefreshToken = "1//refresh"
         tokens.IdToken = ""
         tokens.Scope = "https://www.googleapis.com/auth/drive"
         tokens.TokenType = "Bearer"
         tokens.CreatedAt = DateTime()
         tokens.ExpiresIn = 3600
         SampleTokens = tokens
      End Function

      Sub CopyRow(pFrom As TConfiguracaoGoogleDrive, pTo As TConfiguracaoGoogleDrive)
         pTo.Titulo = pFrom.Titulo
         pTo.Email = pFrom.Email
         pTo.Nome = pFrom.Nome
         pTo.Ativo = pFrom.Ativo
         pTo.ClientId = pFrom.ClientId
         pTo.ClientSecret = pFrom.ClientSecret
         pTo.Scopes = pFrom.Scopes
         pTo.CallbackPort = pFrom.CallbackPort
         pTo.StoreKey = pFrom.StoreKey
         pTo.AccessToken = pFrom.AccessToken
         pTo.RefreshToken = pFrom.RefreshToken
         pTo.IdToken = pFrom.IdToken
         pTo.TokenType = pFrom.TokenType
         pTo.ExpiresIn = pFrom.ExpiresIn
         pTo.CreatedAt = pFrom.CreatedAt
         pTo.ExpiresAt = pFrom.ExpiresAt
      End Sub

      Sub StashCurrentRow()
         Dim existing As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         If Not Assigned(existing) Then
            Exit Sub
         End If
         me._stash = New TConfiguracaoGoogleDrive()
         me.CopyRow(existing, me._stash)
         existing.Free()
      End Sub

      Sub RestoreStash()
         If Not Assigned(me._stash) Then
            Exit Sub
         End If
         me._stash.Insert()
         me._stash.Free()
         me._stash = Null
      End Sub

      Sub CleanupRows()
         Dim rows[] As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.Fetch("")
         Dim i As Integer
         For i = 0 To rows.Length - 1
            Dim row As TConfiguracaoGoogleDrive = rows.Take(i)
            row.Delete()
            row.Free()
         Next
         rows.OwnsObjects = False
         rows.Free()
      End Sub

      Sub TestMapperRoundtrip()
         print("-- mapper")
         Dim row As New TConfiguracaoGoogleDrive()
         row.Titulo = "Mapper"
         Dim tokens As GoogleTokenSet = me.SampleTokens()
         GoogleDriveTokenMapper.ApplyTokens(row, tokens)
         Dim loaded As GoogleTokenSet = GoogleDriveTokenMapper.ToTokens(row)
         me.AssertEq(loaded.AccessToken, "ya29.access", "mapper access")
         me.AssertEq(loaded.RefreshToken, "1//refresh", "mapper refresh")
         me.AssertEq(loaded.Scope, "https://www.googleapis.com/auth/drive", "mapper scope")
         me.AssertTrue(loaded.ExpiresIn = 3600, "mapper expires_in")
         GoogleDriveTokenMapper.ClearTokens(row)
         me.AssertEq(row.AccessToken, "", "clear access")
         me.AssertEq(row.RefreshToken, "", "clear refresh")
         loaded.Free()
         tokens.Free()
         row.Free()
      End Sub

      Sub TestJwtProfile()
         print("-- jwt profile")
         Dim payloadJson As String = "{""email"":""user@example.com"",""name"":""Ada""}"
         Dim b64 As String = payloadJson.ToBase64()
         b64 = b64.Replace("+", "-")
         b64 = b64.Replace("/", "_")
         b64 = b64.Replace("=", "")
         Dim jwt As String = "e30." & b64 & ".sig"
         Dim row As New TConfiguracaoGoogleDrive()
         GoogleDriveTokenMapper.ApplyJwtProfile(row, jwt)
         me.AssertEq(row.Email, "user@example.com", "jwt email")
         me.AssertEq(row.Nome, "Ada", "jwt name")
         row.Free()
      End Sub

      Sub TestOpenWithoutRow()
         print("-- open without row")
         GoogleDriveSqlStores.Migrate()
         Dim tokenStore As GoogleTokenStore
         Dim loaded As GoogleTokenSet
         tokenStore = GoogleDriveSqlStores.Open()
         loaded = tokenStore.Load("missing-key")
         me.AssertTrue(Not Assigned(loaded), "load unknown key is null")
         tokenStore.Free()
      End Sub

      Sub TestMigrateAndCrud()
         print("-- migrate and crud")
         Dim applied As Integer = GoogleDriveSqlStores.Migrate()
         me.AssertTrue(applied >= 0, "migrate ran")
         Dim again As Integer = GoogleDriveSqlStores.Migrate()
         me.AssertTrue(again = 0, "migrate is idempotent")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg, "CRUD connection")
         Dim tokens As GoogleTokenSet = me.SampleTokens()
         tokenStore.Save(cfg.StoreKey(), tokens)
         me.AssertTrue(tokenStore.Exists(cfg.StoreKey()), "exists after save")
         Dim loaded As GoogleTokenSet = tokenStore.Load(cfg.StoreKey())
         me.AssertEq(loaded.AccessToken, "ya29.access", "load access")
         me.AssertEq(loaded.RefreshToken, "1//refresh", "load refresh")
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         me.AssertTrue(Assigned(row), "row found")
         me.AssertEq(row.Titulo, "CRUD connection", "titulo")
         me.AssertEq(row.ClientId, cfg.Credentials.ClientId, "client id persisted")
         row.Free()
         loaded.Free()
         tokens.Free()
         tokenStore.Free()
         cfg.Free()
      End Sub

      Sub TestConfigOf()
         print("-- config of")
         GoogleDriveSqlStores.Migrate()
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg, "Config connection")
         tokenStore.Free()
         Dim rebuilt As GoogleAuthConfig = GoogleDriveSqlStores.ConfigOf()
         me.AssertEq(rebuilt.Credentials.ClientId, cfg.Credentials.ClientId, "rebuilt client id")
         me.AssertEq(rebuilt.Credentials.ClientSecret, "secret", "rebuilt client secret")
         me.AssertEq(rebuilt.AccountId, "", "rebuilt account id empty until email")
         me.AssertTrue(rebuilt.Scopes.Contains("https://www.googleapis.com/auth/drive"), "rebuilt scope")
         me.AssertTrue(rebuilt.CallbackPort = 8085, "rebuilt callback port")
         rebuilt.Free()
         cfg.Free()
      End Sub

      Sub TestEncryptionAtRest()
         print("-- encryption at rest")
         GoogleDriveSqlStores.Migrate()
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg, "Encrypted connection")
         Dim tokens As GoogleTokenSet = me.SampleTokens()
         tokenStore.Save(cfg.StoreKey(), tokens)
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         Dim sqlText As String = "SELECT " & sqlDialect.QuoteIdent("AccessToken") & ", " & sqlDialect.QuoteIdent("ClientSecret") & " FROM " & sqlDialect.QuoteTable("Customizado", "ConfiguracaoGoogleDrive")
         Dim query As SQL.Command = TSql.OpenQuery(sqlText)
         Dim rawAccess As String = ""
         Dim rawSecret As String = ""
         If Not query.Eof Then
            rawAccess = Trim(query.Field("AccessToken").AsString)
            rawSecret = Trim(query.Field("ClientSecret").AsString)
         End If
         query.Close()
         query.Free()
         me.AssertTrue((rawAccess <> "") And (rawAccess <> "ya29.access"), "access token encrypted in db")
         me.AssertTrue((rawSecret <> "") And (rawSecret <> "secret"), "client secret encrypted in db")
         Dim loaded As GoogleTokenSet = tokenStore.Load(cfg.StoreKey())
         me.AssertEq(loaded.AccessToken, "ya29.access", "decrypt on load")
         loaded.Free()
         tokens.Free()
         tokenStore.Free()
         cfg.Free()
      End Sub

      Sub TestClearKeepsCadastro()
         print("-- clear keeps cadastro")
         GoogleDriveSqlStores.Migrate()
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg, "Clear connection")
         Dim tokens As GoogleTokenSet = me.SampleTokens()
         tokenStore.Save(cfg.StoreKey(), tokens)
         tokenStore.Clear(cfg.StoreKey())
         me.AssertTrue(Not tokenStore.Exists(cfg.StoreKey()), "exists false after clear")
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         me.AssertTrue(Assigned(row), "row kept")
         me.AssertEq(row.Titulo, "Clear connection", "titulo kept")
         me.AssertEq(row.ClientId, cfg.Credentials.ClientId, "client id kept")
         me.AssertEq(row.AccessToken, "", "access cleared")
         me.AssertEq(row.RefreshToken, "", "refresh cleared")
         row.Free()
         tokens.Free()
         tokenStore.Free()
         cfg.Free()
      End Sub

      Sub TestConnectReusesSqlStore()
         print("-- connect sql store")
         GoogleDriveSqlStores.Migrate()
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg, "Connect connection")
         Dim tokens As GoogleTokenSet = me.SampleTokens()
         tokenStore.Save(cfg.StoreKey(), tokens)
         tokenStore.Free()
         Dim auth As GoogleAuthService = GoogleDriveSqlStores.Connect("Connect connection", False)
         me.AssertTrue(auth.IsAuthorized(), "connect authorized from sql")
         Dim connectedCfg As GoogleAuthConfig = auth.Config()
         auth.Free()
         GoogleDriveSqlStores.DropConfig(connectedCfg)
         tokens.Free()
         cfg.Free()
      End Sub

      Sub TestTwoKeysAndList()
         print("-- two keys and list")
         Dim cfgA As GoogleAuthConfig
         Dim cfgB As GoogleAuthConfig
         Dim tokenStoreA As GoogleTokenStore
         Dim tokenStoreB As GoogleTokenStore
         Dim unboundStore As GoogleTokenStore
         Dim tokensA As GoogleTokenSet
         Dim tokensB As GoogleTokenSet
         Dim loadedA As GoogleTokenSet
         Dim loadedB As GoogleTokenSet
         Dim listing[] As TConfiguracaoGoogleDrive
         Dim rowA As TConfiguracaoGoogleDrive
         Dim rowB As TConfiguracaoGoogleDrive
         Dim rebuilt As GoogleAuthConfig
         GoogleDriveSqlStores.Migrate()
         me.CleanupRows()
         cfgA = me.SampleConfig()
         cfgA.AccountId = "ada@example.com"
         cfgB = me.SampleConfig()
         cfgB.AccountId = "grace@example.com"
         tokenStoreA = GoogleDriveSqlStores.Open(cfgA, "Ada")
         tokensA = me.SampleTokens()
         tokensA.AccessToken = "ya29.ada"
         tokenStoreA.Save(cfgA.StoreKey(), tokensA)
         tokenStoreB = GoogleDriveSqlStores.Open(cfgB, "Grace")
         tokensB = me.SampleTokens()
         tokensB.AccessToken = "ya29.grace"
         tokenStoreB.Save(cfgB.StoreKey(), tokensB)
         loadedA = tokenStoreA.Load(cfgA.StoreKey())
         loadedB = tokenStoreB.Load(cfgB.StoreKey())
         me.AssertEq(loadedA.AccessToken, "ya29.ada", "load ada by key")
         me.AssertEq(loadedB.AccessToken, "ya29.grace", "load grace by key")
         loadedA.Free()
         unboundStore = GoogleDriveSqlStores.Open()
         loadedA = unboundStore.Load(cfgA.StoreKey())
         me.AssertEq(loadedA.AccessToken, "ya29.ada", "unbound store loads ada by key")
         rowA = TConfiguracaoGoogleDrive.FindByStoreKey(cfgA.StoreKey())
         rowB = TConfiguracaoGoogleDrive.FindByStoreKey(cfgB.StoreKey())
         me.AssertTrue(Assigned(rowA) And Assigned(rowB), "two rows")
         rebuilt = GoogleDriveSqlStores.ConfigOfKey(rowA.CodConfiguracaoGoogleDrive)
         me.AssertEq(rebuilt.Credentials.ClientId, cfgA.Credentials.ClientId, "config of ada key")
         me.AssertTrue(rowA.CodConfiguracaoGoogleDrive <> rowB.CodConfiguracaoGoogleDrive, "distinct pks")
         me.AssertEq(rowA.Titulo, "Ada", "ada titulo")
         me.AssertEq(rowB.Titulo, "Grace", "grace titulo")
         listing = GoogleDriveSqlStores.ListConnections()
         me.AssertTrue(listing.Length = 2, "list two connections")
         tokenStoreA.Clear(cfgA.StoreKey())
         me.AssertTrue(Not tokenStoreA.Exists(cfgA.StoreKey()), "ada cleared")
         me.AssertTrue(tokenStoreB.Exists(cfgB.StoreKey()), "grace kept after ada clear")
         listing.Free()
         rowA.Free()
         rowB.Free()
         rebuilt.Free()
         loadedA.Free()
         loadedB.Free()
         tokensA.Free()
         tokensB.Free()
         unboundStore.Free()
         tokenStoreA.Free()
         tokenStoreB.Free()
         cfgA.Free()
         cfgB.Free()
      End Sub

      Sub TestAddDoesNotReplace()
         print("-- add does not replace")
         Dim cfg As GoogleAuthConfig
         Dim firstStore As GoogleTokenStore
         Dim addedStore As GoogleTokenStore
         Dim tokens As GoogleTokenSet
         Dim listing[] As TConfiguracaoGoogleDrive
         Dim firstRow As TConfiguracaoGoogleDrive
         Dim firstKey As String
         GoogleDriveSqlStores.Migrate()
         me.CleanupRows()
         cfg = me.SampleConfig()
         cfg.AccountId = "first@example.com"
         firstKey = cfg.StoreKey()
         firstStore = GoogleDriveSqlStores.Open(cfg, "First")
         tokens = me.SampleTokens()
         tokens.AccessToken = "ya29.first"
         firstStore.Save(firstKey, tokens)
         cfg.AccountId = ""
         addedStore = GoogleDriveSqlStores.Open(cfg, "Second", True)
         firstRow = TConfiguracaoGoogleDrive.FindByStoreKey(firstKey)
         me.AssertEq(firstRow.AccessToken, "ya29.first", "first tokens kept")
         listing = GoogleDriveSqlStores.ListConnections()
         me.AssertTrue(listing.Length = 2, "add inserted second row")
         listing.Free()
         firstRow.Free()
         tokens.Free()
         addedStore.Free()
         firstStore.Free()
         cfg.Free()
      End Sub

      Sub TestAuthInjection()
         print("-- auth injection")
         GoogleDriveSqlStores.Migrate()
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg, "Auth connection")
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim mockClient As HttpClient = Http.Mock(200, me.SampleTokenJson())
         Dim httpLayer As New GoogleAuthHttp(mockClient, endpoints, True)
         Dim consent As New GoogleDriveSqlConsentFake("auth-code")
         Dim auth As New GoogleAuthService(cfg, tokenStore, httpLayer, consent, True, True, True)
         Dim tokens As GoogleTokenSet = auth.Authorize()
         me.AssertEq(tokens.AccessToken, "ya29.access", "authorize access")
         me.AssertTrue(auth.IsAuthorized(), "authorized")
         Dim persisted As GoogleTokenSet = tokenStore.Load(cfg.StoreKey())
         me.AssertEq(persisted.RefreshToken, "1//refresh", "authorize persisted refresh")
         GoogleDriveSqlStores.ApplyProfile("user@example.com", "Ada")
         Dim row As TConfiguracaoGoogleDrive = TConfiguracaoGoogleDrive.CurrentRow()
         me.AssertEq(row.Email, "user@example.com", "profile email")
         me.AssertEq(row.Nome, "Ada", "profile name")
         row.Free()
         persisted.Free()
         tokens.Free()
         auth.Free()
         endpoints.Free()
         cfg.Free()
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._stash) Then
            me._stash.Free()
            me._stash = Null
         End If
         If Assigned(me._failures) Then
            me._failures.Free()
            me._failures = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
