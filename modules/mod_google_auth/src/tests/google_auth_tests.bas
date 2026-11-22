Imports Collections
Imports TFile
Imports TPath
Imports mod_tobject
Imports http_client
Imports http_response
Imports http_mock
Imports google_auth
Imports google_auth_config
Imports google_auth_enums
Imports google_auth_endpoints_v2
Imports google_auth_http
Imports google_auth_pkce
Imports google_auth_token_set
Imports google_auth_code
Imports google_auth_store
Imports google_auth_stores
Imports google_auth_store_memory
Imports google_auth_consent
Imports google_auth_grant_service
Imports google_auth_validation
Imports google_auth_session_result
Imports google_auth_connect

Namespace google_auth_tests

   Class GoogleAuthConsentFake
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

   Class GoogleAuthTests
      Inherits TTObject

      Passed As Integer
      Failed As Integer
      Private _failures As StringList

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
      End Sub

      Shared Sub RunAll()
         Dim suite As New GoogleAuthTests()
         suite.Run()
         suite.Free()
      End Sub

      Sub Run()
         print("==== mod_google_auth ====")
         me.TestEnums()
         me.TestAuthUrl()
         me.TestTokenParse()
         me.TestExpirySkew()
         me.TestPkceRfc()
         me.TestCodeExtract()
         me.TestMemoryStore()
         me.TestJsonStore()
         me.TestRefreshRotation()
         me.TestAuthorizeExchange()
         me.TestCompleteFromRedirectUrl()
         me.TestCustomStoreInjection()
         me.TestLoadRequiresStore()
         me.TestStateMismatch()
         me.TestServiceAccountBlocked()
         me.TestBearerInterceptor()
         me.TestSessionResult()
         me.TestConnectReusesStore()
         me.TestConnectRequiresStore()
         me.TestConnectRequiresCredentialsWhenSilent()
         me.PrintSummary()
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            print("  OK    " + pMsg)
         Else
            me.Failed = me.Failed + 1
            me._failures.Add(pMsg)
            print("  FAIL  " + pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=[" + pGot + "] esperado=[" + pWant + "])")
      End Sub

      Sub PrintSummary()
         print("----")
         print("Passed: " + CStr(me.Passed) + "  Failed: " + CStr(me.Failed))
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

      Function RotatedTokenJson() As String
         Dim json As New TJSONObject()
         json.PutString("access_token", "ya29.new")
         json.PutInteger("expires_in", 3600)
         json.PutString("refresh_token", "1//rotated")
         json.PutString("token_type", "Bearer")
         RotatedTokenJson = json.ToString()
         json.Free()
      End Function

      Sub TestEnums()
         print("-- enums")
         me.AssertEq(GoogleAuthApiVersion.V2().AsString, "V2", "ApiVersion.V2")
         me.AssertEq(GoogleAuthGrantType.AuthorizationCode().AsString, "authorization_code", "Grant.AuthorizationCode")
         me.AssertEq(GoogleAuthGrantType.RefreshToken().AsString, "refresh_token", "Grant.RefreshToken")
         me.AssertEq(GoogleAuthConsentKind.Loopback().AsString, "loopback", "Consent.Loopback")
         me.AssertEq(GoogleAuthTokenType.Bearer().AsString, "Bearer", "TokenType.Bearer")
         me.AssertEq(GoogleAuthUiMode.Headless().AsString, "headless", "UiMode.Headless")
         me.AssertEq(GoogleAuthUiMode.Locked().AsString, "locked", "UiMode.Locked")
         me.AssertEq(GoogleAuthUiMode.Editable().AsString, "editable", "UiMode.Editable")
      End Sub

      Sub TestAuthUrl()
         print("-- authorization url")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim pkce As GoogleAuthPkce = GoogleAuthPkce.FromVerifier("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim url As String = endpoints.BuildAuthorizationUrl(cfg, pkce, "xyz")
         me.AssertTrue(InStr(url, "https://accounts.google.com/o/oauth2/v2/auth") = 1, "auth host")
         me.AssertTrue(InStr(url, "client_id=") > 0, "client_id")
         me.AssertTrue(InStr(url, "code_challenge=") > 0, "pkce challenge")
         me.AssertTrue(InStr(url, "state=xyz") > 0, "state")
         me.AssertTrue(InStr(url, "access_type=offline") > 0, "access_type")
         me.AssertTrue(InStr(url, "scope=") > 0, "scope")
         endpoints.Free()
         pkce.Free()
         cfg.Free()
      End Sub

      Sub TestTokenParse()
         print("-- token parse")
         Dim json As TJSONObject = New TJSONObject(me.SampleTokenJson())
         Dim tokens As GoogleTokenSet = GoogleTokenSet.FromJson(json)
         me.AssertEq(tokens.AccessToken, "ya29.access", "access_token")
         me.AssertEq(tokens.RefreshToken, "1//refresh", "refresh_token")
         me.AssertEq(tokens.TokenType, "Bearer", "token_type")
         me.AssertTrue(tokens.ExpiresIn = 3600, "expires_in")
         me.AssertTrue(Not tokens.IsExpired(0), "not expired")
         json.Free()
         tokens.Free()
      End Sub

      Sub TestExpirySkew()
         print("-- expiry skew")
         Dim tokens As New GoogleTokenSet()
         tokens.AccessToken = "ya29.x"
         tokens.CreatedAt = DateTime()
         tokens.ExpiresIn = 30
         me.AssertTrue(tokens.IsExpired(60), "expired with 60s skew")
         me.AssertTrue(Not tokens.IsExpired(0), "not expired without skew")
         tokens.Free()
      End Sub

      Sub TestPkceRfc()
         print("-- pkce rfc 7636")
         Dim pkce As GoogleAuthPkce = GoogleAuthPkce.FromVerifier("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
         me.AssertEq(pkce.Challenge, "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM", "rfc challenge")
         me.AssertEq(pkce.Method, "S256", "method")
         Dim generated As GoogleAuthPkce = GoogleAuthPkce.Generate()
         me.AssertTrue(generated.Verifier.Length >= 43, "verifier length")
         me.AssertTrue(generated.Challenge <> generated.Verifier, "challenge differs")
         me.AssertTrue(InStr(generated.Challenge, "+") = 0, "no plus")
         me.AssertTrue(InStr(generated.Challenge, "/") = 0, "no slash")
         me.AssertTrue(InStr(generated.Challenge, "=") = 0, "no padding")
         generated.Free()
         pkce.Free()
      End Sub

      Sub TestCodeExtract()
         print("-- code extract")
         Dim fromUrl As GoogleAuthCode = GoogleAuthCode.ExtractFromUrl("http://localhost:8085/?code=4%2F0Aea&state=abc")
         me.AssertEq(fromUrl.Value, "4/0Aea", "decoded code")
         me.AssertEq(fromUrl.State, "abc", "state")
         Dim fromRaw As GoogleAuthCode = GoogleAuthCode.ExtractFromUrl("plain-code")
         me.AssertEq(fromRaw.Value, "plain-code", "raw code")
         Dim denied As GoogleAuthCode = GoogleAuthCode.ExtractFromUrl("http://localhost/?error=access_denied&state=abc")
         me.AssertTrue(denied.IsError(), "error flag")
         fromUrl.Free()
         fromRaw.Free()
         denied.Free()
      End Sub

      Sub TestMemoryStore()
         print("-- memory store")
         Dim store As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim tokens As New GoogleTokenSet()
         tokens.AccessToken = "a1"
         tokens.RefreshToken = "r1"
         store.Save("k1", tokens)
         me.AssertTrue(store.Exists("k1"), "exists")
         Dim loaded As GoogleTokenSet = store.Load("k1")
         me.AssertEq(loaded.AccessToken, "a1", "loaded access")
         store.Clear("k1")
         me.AssertTrue(Not store.Exists("k1"), "cleared")
         loaded.Free()
         tokens.Free()
         store.Free()
      End Sub

      Sub TestJsonStore()
         print("-- json store")
         Dim jsonStorePath As String = TPath.GetTempFileName()
         Dim store As GoogleTokenStore = GoogleTokenStores.Json(jsonStorePath)
         Dim tokens As New GoogleTokenSet()
         tokens.AccessToken = "json-access"
         tokens.RefreshToken = "json-refresh"
         store.Save("cid|acc", tokens)
         Dim loaded As GoogleTokenSet = store.Load("cid|acc")
         me.AssertEq(loaded.AccessToken, "json-access", "json access roundtrip")
         me.AssertEq(loaded.RefreshToken, "json-refresh", "json refresh roundtrip")
         loaded.Free()
         tokens.Free()
         store.Free()
         If TFile.Exists(jsonStorePath) Then
            TFile.Delete(jsonStorePath)
         End If
      End Sub

      Sub TestRefreshRotation()
         print("-- refresh rotation")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim mockClient As HttpClient = Http.Mock(200, me.RotatedTokenJson())
         Dim httpLayer As New GoogleAuthHttp(mockClient, endpoints, True)
         Dim store As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim seed As New GoogleTokenSet()
         seed.AccessToken = "ya29.old"
         seed.RefreshToken = "1//old"
         seed.CreatedAt = DateTime().AddSeconds(-4000)
         seed.ExpiresIn = 1
         store.Save(cfg.StoreKey(), seed)
         Dim consent As New GoogleAuthConsentFake("unused")
         Dim auth As New GoogleAuthService(cfg, store, httpLayer, consent, True, True, True)
         Dim access As String = auth.GetAccessToken()
         me.AssertEq(access, "ya29.new", "refreshed access")
         Dim stored As GoogleTokenSet = store.Load(cfg.StoreKey())
         me.AssertEq(stored.RefreshToken, "1//rotated", "rotated refresh persisted")
         stored.Free()
         seed.Free()
         auth.Free()
         endpoints.Free()
         cfg.Free()
      End Sub

      Sub TestAuthorizeExchange()
         print("-- authorize exchange")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim mockClient As HttpClient = Http.Mock(200, me.SampleTokenJson())
         Dim httpLayer As New GoogleAuthHttp(mockClient, endpoints, True)
         Dim store As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim consent As New GoogleAuthConsentFake("auth-code")
         Dim auth As New GoogleAuthService(cfg, store, httpLayer, consent, True, True, True)
         Dim tokens As GoogleTokenSet = auth.Authorize()
         me.AssertEq(tokens.AccessToken, "ya29.access", "exchanged access")
         me.AssertTrue(auth.IsAuthorized(), "authorized")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         me.AssertTrue(InStr(mockTr.LastBodyText, "grant_type=authorization_code") > 0, "grant in body")
         me.AssertTrue(InStr(mockTr.LastBodyText, "code=auth-code") > 0, "code in body")
         me.AssertTrue(InStr(mockTr.LastBodyText, "client_secret=secret") > 0, "client_secret in body")
         tokens.Free()
         auth.Free()
         endpoints.Free()
         cfg.Free()
      End Sub

      Sub TestCompleteFromRedirectUrl()
         print("-- complete from redirect url")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim mockClient As HttpClient = Http.Mock(200, me.SampleTokenJson())
         Dim httpLayer As New GoogleAuthHttp(mockClient, endpoints, True)
         Dim store As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim consent As New GoogleAuthConsentFake("unused")
         Dim auth As New GoogleAuthService(cfg, store, httpLayer, consent, True, True, True)
         Dim authUrl As String = auth.StartAuthorization()
         me.AssertTrue(auth.HasPendingAuthorization(), "pending after start")
         Dim parsed As GoogleAuthCode = GoogleAuthCode.ExtractFromUrl(authUrl)
         Dim redirect As String = "http://localhost:8085/?code=pasted-code&state=" & parsed.State
         Dim tokens As GoogleTokenSet = auth.CompleteFromRedirectUrl(redirect)
         me.AssertEq(tokens.AccessToken, "ya29.access", "exchanged from pasted url")
         me.AssertTrue(auth.IsAuthorized(), "authorized from pasted url")
         me.AssertTrue(Not auth.HasPendingAuthorization(), "pending cleared after extract")
         Dim mockTr As MockTransport = CType(mockClient.Transport, MockTransport)
         me.AssertTrue(InStr(mockTr.LastBodyText, "code=pasted-code") > 0, "pasted code in body")
         parsed.Free()
         tokens.Free()
         auth.Free()
         endpoints.Free()
         cfg.Free()
      End Sub

      Sub TestCustomStoreInjection()
         print("-- custom store injection")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim mockClient As HttpClient = Http.Mock(200, me.SampleTokenJson())
         Dim httpLayer As New GoogleAuthHttp(mockClient, endpoints, True)
         Dim customStore As New GoogleTokenStoreMemory()
         Dim consent As New GoogleAuthConsentFake("auth-code")
         Dim auth As New GoogleAuthService(cfg, customStore, httpLayer, consent, True, True, True)
         auth.Authorize()
         me.AssertTrue(customStore.Exists(cfg.StoreKey()), "custom store received tokens")
         auth.Free()
         endpoints.Free()
         cfg.Free()
      End Sub

      Sub TestLoadRequiresStore()
         print("-- load requires store")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim threw As Boolean = False
         Try
            Dim auth As GoogleAuthService = GoogleAuthService.Load(cfg, Null)
            auth.Free()
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "GoogleTokenStore") > 0
         End Try
         me.AssertTrue(threw, "null store throws")
         cfg.Free()
      End Sub

      Sub TestStateMismatch()
         print("-- state mismatch")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim mockClient As HttpClient = Http.Mock(200, me.SampleTokenJson())
         Dim httpLayer As New GoogleAuthHttp(mockClient, endpoints, True)
         Dim store As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim consent As New GoogleAuthConsentFake("auth-code", "wrong-state")
         Dim auth As New GoogleAuthService(cfg, store, httpLayer, consent, True, True, True)
         Dim threw As Boolean = False
         Try
            auth.Authorize()
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "state") > 0
         End Try
         me.AssertTrue(threw, "invalid state throws")
         auth.Free()
         endpoints.Free()
         cfg.Free()
      End Sub

      Sub TestServiceAccountBlocked()
         print("-- service account slot")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         cfg.GrantType = GoogleAuthGrantType.ServiceAccount()
         Dim threw As Boolean = False
         Try
            GoogleAuthValidator.Validate(cfg)
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "Service Account") > 0
         End Try
         me.AssertTrue(threw, "validator blocks service account")
         Dim grant As New GoogleAuthGrantServiceAccount()
         Dim grantThrew As Boolean = False
         Try
            grant.Exchange(Null, cfg, Null)
         Catch ex As Exception
            grantThrew = InStr(ex._GetMessage(), "Service Account") > 0
         End Try
         me.AssertTrue(grantThrew, "grant slot throws")
         grant.Free()
         cfg.Free()
      End Sub

      Sub TestConnectReusesStore()
         print("-- connect reuses store")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim tokenStore As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim seed As New GoogleTokenSet()
         seed.AccessToken = "ya29.live"
         seed.RefreshToken = "1//r"
         seed.ExpiresIn = 3600
         tokenStore.Save(cfg.StoreKey(), seed)
         Dim auth As GoogleAuthService = GoogleAuthConnect.Run(cfg, tokenStore, True, False)
         me.AssertTrue(auth.IsAuthorized(), "connect authorized from store")
         me.AssertEq(auth.GetAccessToken(), "ya29.live", "connect access from store")
         seed.Free()
         auth.Free()
         cfg.Free()
      End Sub

      Sub TestConnectRequiresStore()
         print("-- connect requires store")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim threw As Boolean = False
         Try
            Dim auth As GoogleAuthService = GoogleAuthConnect.Run(cfg, Null, True, False)
            auth.Free()
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "GoogleTokenStore") > 0
         End Try
         me.AssertTrue(threw, "connect null store throws")
         cfg.Free()
      End Sub

      Sub TestConnectRequiresCredentialsWhenSilent()
         print("-- connect silent needs credentials")
         Dim cfg As New GoogleAuthConfig()
         cfg.Scopes.Add("openid")
         Dim tokenStore As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim threw As Boolean = False
         Try
            Dim auth As GoogleAuthService = GoogleAuthConnect.Run(cfg, tokenStore, True, False)
            auth.Free()
         Catch ex As Exception
            threw = InStr(ex._GetMessage(), "Client ID") > 0
         End Try
         me.AssertTrue(threw, "connect silent without client id throws")
         me.AssertTrue(cfg.HasClientCredentials() = False, "empty config has no credentials")
         tokenStore.Free()
         cfg.Free()
      End Sub

      Sub TestSessionResult()
         print("-- session result")
         Dim sessionResult As New GoogleAuthSessionResult()
         me.AssertTrue(Not sessionResult.Succeeded, "default not succeeded")
         me.AssertTrue(Not sessionResult.HasTokens(), "default has no tokens")
         Dim seed As New GoogleTokenSet()
         seed.AccessToken = "ya29.access"
         seed.RefreshToken = "1//r"
         sessionResult.AttachTokens(seed)
         sessionResult.Succeeded = True
         sessionResult.Email = "user@example.com"
         me.AssertTrue(sessionResult.HasTokens(), "attached tokens")
         Dim copy As GoogleTokenSet = sessionResult.Tokens()
         me.AssertEq(copy.AccessToken, "ya29.access", "cloned access")
         me.AssertEq(sessionResult.Email, "user@example.com", "email kept")
         copy.Free()
         seed.Free()
         sessionResult.Free()
      End Sub

      Sub TestBearerInterceptor()
         print("-- bearer interceptor")
         Dim cfg As GoogleAuthConfig = me.SampleConfig()
         Dim endpoints As New GoogleOAuthEndpointsV2()
         Dim mockAuthClient As HttpClient = Http.Mock(200, me.SampleTokenJson())
         Dim httpLayer As New GoogleAuthHttp(mockAuthClient, endpoints, True)
         Dim store As GoogleTokenStore = GoogleTokenStores.Memory()
         Dim seed As New GoogleTokenSet()
         seed.AccessToken = "ya29.live"
         seed.RefreshToken = "1//r"
         seed.ExpiresIn = 3600
         store.Save(cfg.StoreKey(), seed)
         Dim consent As New GoogleAuthConsentFake("unused")
         Dim auth As New GoogleAuthService(cfg, store, httpLayer, consent, True, True, True)
         Dim apiClient As HttpClient = Http.Mock(200, "{""ok"":true}")
         apiClient.Use(auth.CreateBearerInterceptor())
         Dim res As HttpResponse = apiClient.Gett("https://www.googleapis.com/drive/v3/about")
         Dim mockTr As MockTransport = CType(apiClient.Transport, MockTransport)
         me.AssertTrue(InStr(mockTr.LastHeadersText, "Bearer ya29.live") > 0, "bearer header")
         res.Free()
         apiClient.Free()
         seed.Free()
         auth.Free()
         endpoints.Free()
         cfg.Free()
      End Sub

      Overrides Sub Dispose()
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
