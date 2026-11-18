Imports http_interceptor
Imports google_auth_client
Imports google_auth_config
Imports google_auth_validation
Imports google_auth_store
Imports google_auth_consent
Imports google_auth_consent_loopback
Imports google_auth_consent_manual
Imports google_auth_http
Imports google_auth_endpoints
Imports google_auth_endpoints_v2
Imports google_auth_token_set
Imports google_auth_pkce
Imports google_auth_state
Imports google_auth_grant
Imports google_auth_grant_code
Imports google_auth_grant_refresh
Imports google_auth_code
Imports google_auth_bearer
Imports google_auth_errors
Imports google_auth_enums
Imports google_auth_capabilities

Namespace google_auth

   Class GoogleAuthService
      Inherits GoogleAuthClient

      Private _config As GoogleAuthConfig
      Private _store As GoogleTokenStore
      Private _consent As GoogleConsentHandler
      Private _http As GoogleAuthHttp
      Private _endpoints As GoogleOAuthEndpoints
      Private _codeGrant As GoogleAuthGrant
      Private _refreshGrant As GoogleAuthGrant
      Private _ownsStore As Boolean
      Private _ownsConsent As Boolean
      Private _ownsHttp As Boolean
      Private _ownsEndpoints As Boolean
      Private _ownsConfig As Boolean
      Private _pendingPkce As GoogleAuthPkce
      Private _pendingState As GoogleAuthState
      Private _cancelled As Boolean

      Sub New(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pHttp As GoogleAuthHttp, pConsent As GoogleConsentHandler, pOwnsStore As Boolean = True, pOwnsHttp As Boolean = True, pOwnsConsent As Boolean = True)
         MyBase.New()
         me.Attach(pConfig, pStore, pHttp, pConsent, pOwnsStore, pOwnsHttp, pOwnsConsent, False, False)
      End Sub

      Private Sub Attach(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pHttp As GoogleAuthHttp, pConsent As GoogleConsentHandler, pOwnsStore As Boolean, pOwnsHttp As Boolean, pOwnsConsent As Boolean, pOwnsConfig As Boolean, pOwnsEndpoints As Boolean)
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleAuthErrors.ConfigRequired())
         End If
         If Not Assigned(pStore) Then
            Throw New Exception(GoogleAuthErrors.StoreRequired())
         End If
         GoogleAuthValidator.Validate(pConfig)
         me._config = pConfig
         me._store = pStore
         me._http = pHttp
         me._consent = pConsent
         me._ownsStore = pOwnsStore
         me._ownsHttp = pOwnsHttp
         me._ownsConsent = pOwnsConsent
         me._ownsConfig = pOwnsConfig
         me._ownsEndpoints = pOwnsEndpoints
         If Assigned(pHttp) Then
            me._endpoints = pHttp.Endpoints()
         End If
         me._codeGrant = New GoogleAuthGrantAuthorizationCode()
         me._refreshGrant = New GoogleAuthGrantRefreshToken()
      End Sub

      Shared Function Load(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pOwnsStore As Boolean = True) As GoogleAuthService
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleAuthErrors.ConfigRequired())
         End If
         If Not Assigned(pStore) Then
            Throw New Exception(GoogleAuthErrors.StoreRequired())
         End If
         GoogleAuthValidator.Validate(pConfig)
         Dim endpoints As GoogleOAuthEndpoints = GoogleOAuthEndpointCatalog.Make(pConfig.ApiVersion)
         Dim httpLayer As GoogleAuthHttp = GoogleAuthHttp.FromConfig(pConfig, endpoints)
         Dim consent As GoogleConsentHandler
         If pConfig.ConsentKind.AsString = GoogleAuthConsentKind.Manual().AsString Then
            consent = New GoogleConsentManual()
         Else
            consent = GoogleConsentLoopback.FromConfig(pConfig)
         End If
         Dim service As New GoogleAuthService(pConfig, pStore, httpLayer, consent, pOwnsStore, True, True)
         service._ownsEndpoints = True
         Load = service
      End Function

      Function Capabilities() As GoogleAuthCapabilities
         Capabilities = GoogleAuthCapabilities.UserOAuth()
      End Function

      Function Config() As GoogleAuthConfig
         Config = me._config
      End Function

      Overrides Function GetAccessToken() As String
         Dim tokens As GoogleTokenSet = me.CurrentTokens()
         If Assigned(tokens) Then
            If Not tokens.IsExpired(me._config.ExpirySkewSeconds) Then
               GetAccessToken = tokens.AccessToken
               tokens.Free()
               Exit Function
            End If
            If tokens.HasRefreshToken() Then
               Dim refreshed As GoogleTokenSet = me.RefreshWith(tokens)
               GetAccessToken = refreshed.AccessToken
               tokens.Free()
               refreshed.Free()
               Exit Function
            End If
            tokens.Free()
         End If
         Dim authorized As GoogleTokenSet = me.Authorize()
         GetAccessToken = authorized.AccessToken
         authorized.Free()
      End Function

      Function StartAuthorization() As String
         me.ResetPending()
         me._cancelled = False
         me._pendingPkce = GoogleAuthPkce.Generate()
         me._pendingState = New GoogleAuthState()
         StartAuthorization = me._http.Endpoints().BuildAuthorizationUrl(me._config, me._pendingPkce, me._pendingState.Value)
      End Function

      Function HasPendingAuthorization() As Boolean
         HasPendingAuthorization = Assigned(me._pendingPkce) And Assigned(me._pendingState)
      End Function

      Sub CancelConsent()
         me._cancelled = True
         If Assigned(me._consent) Then
            me._consent.Cancel()
         End If
      End Sub

      Function WasCancelled() As Boolean
         If me._cancelled Then
            WasCancelled = True
            Exit Function
         End If
         If Assigned(me._consent) Then
            WasCancelled = me._consent.WasCancelled()
         Else
            WasCancelled = False
         End If
      End Function

      Overrides Function Authorize() As GoogleTokenSet
         Dim authUrl As String = me.StartAuthorization()
         Dim code As GoogleAuthCode = me._consent.RequestCode(authUrl)
         If me.WasCancelled() Then
            If Assigned(code) Then
               code.Free()
            End If
            Throw New Exception(GoogleAuthErrors.ConsentCancelled())
         End If
         Dim tokens As GoogleTokenSet = me.FinishExchange(code)
         code.Free()
         Authorize = tokens
      End Function

      Function CompleteFromRedirectUrl(pUrl As String) As GoogleTokenSet
         If Not me.HasPendingAuthorization() Then
            Throw New Exception(GoogleAuthErrors.AuthorizationNotStarted())
         End If
         If Trim(pUrl) = "" Then
            Throw New Exception(GoogleAuthErrors.RedirectUrlRequired())
         End If
         Dim code As GoogleAuthCode = GoogleAuthCode.ExtractFromUrl(pUrl)
         Dim tokens As GoogleTokenSet
         Try
            tokens = me.FinishExchange(code)
         Catch ex As Exception
            code.Free()
            Throw New Exception(ex._GetMessage())
         End Try
         code.Free()
         CompleteFromRedirectUrl = tokens
      End Function

      Private Function FinishExchange(pCode As GoogleAuthCode) As GoogleTokenSet
         If Not me.HasPendingAuthorization() Then
            Throw New Exception(GoogleAuthErrors.AuthorizationNotStarted())
         End If
         If Not me._pendingState.Matches(pCode.State) Then
            Throw New Exception(GoogleAuthErrors.StateMismatch())
         End If
         Dim ctx As New GoogleAuthGrantContext()
         ctx.AuthCode = pCode
         ctx.Pkce = me._pendingPkce
         Dim tokens As GoogleTokenSet = me._codeGrant.Exchange(me._http, me._config, ctx)
         ctx.Free()
         me._store.Save(me._config.StoreKey(), tokens)
         me.ResetPending()
         me._cancelled = False
         FinishExchange = tokens
      End Function

      Private Sub ResetPending()
         If Assigned(me._pendingPkce) Then
            me._pendingPkce.Free()
            me._pendingPkce = Null
         End If
         If Assigned(me._pendingState) Then
            me._pendingState.Free()
            me._pendingState = Null
         End If
      End Sub

      Overrides Function RefreshTokens() As GoogleTokenSet
         Dim current As GoogleTokenSet = me._store.Load(me._config.StoreKey())
         If Not Assigned(current) Then
            Throw New Exception(GoogleAuthErrors.RefreshTokenRequired())
         End If
         If Not current.HasRefreshToken() Then
            current.Free()
            Throw New Exception(GoogleAuthErrors.RefreshTokenRequired())
         End If
         Dim refreshed As GoogleTokenSet = me.RefreshWith(current)
         current.Free()
         RefreshTokens = refreshed
      End Function

      Private Function RefreshWith(pCurrent As GoogleTokenSet) As GoogleTokenSet
         Dim ctx As New GoogleAuthGrantContext()
         ctx.RefreshToken = pCurrent.RefreshToken
         Dim fresh As GoogleTokenSet = me._refreshGrant.Exchange(me._http, me._config, ctx)
         ctx.Free()
         pCurrent.ApplyRefresh(fresh)
         me._store.Save(me._config.StoreKey(), pCurrent)
         fresh.Free()
         RefreshWith = pCurrent.Clone()
      End Function

      Overrides Sub Revoke()
         Dim tokens As GoogleTokenSet = me._store.Load(me._config.StoreKey())
         If Assigned(tokens) Then
            Dim value As String = tokens.AccessToken
            If Trim(value) = "" Then
               value = tokens.RefreshToken
            End If
            me._http.RevokeToken(value)
            tokens.Free()
         End If
         me._store.Clear(me._config.StoreKey())
      End Sub

      Overrides Function IsAuthorized() As Boolean
         Dim tokens As GoogleTokenSet = me._store.Load(me._config.StoreKey())
         If Not Assigned(tokens) Then
            IsAuthorized = False
            Exit Function
         End If
         IsAuthorized = tokens.HasAccessToken() Or tokens.HasRefreshToken()
         tokens.Free()
      End Function

      Function CurrentTokens() As GoogleTokenSet
         CurrentTokens = me._store.Load(me._config.StoreKey())
      End Function

      Function CreateBearerInterceptor() As HttpInterceptor
         CreateBearerInterceptor = New GoogleBearerInterceptor(me)
      End Function

      Overrides Sub Dispose()
         me.CancelConsent()
         me.ResetPending()
         If Assigned(me._codeGrant) Then
            me._codeGrant.Free()
            me._codeGrant = Null
         End If
         If Assigned(me._refreshGrant) Then
            me._refreshGrant.Free()
            me._refreshGrant = Null
         End If
         If me._ownsConsent And Assigned(me._consent) Then
            me._consent.Free()
         End If
         me._consent = Null
         If me._ownsHttp And Assigned(me._http) Then
            me._http.Free()
         End If
         me._http = Null
         If me._ownsStore And Assigned(me._store) Then
            me._store.Free()
         End If
         me._store = Null
         If me._ownsEndpoints And Assigned(me._endpoints) Then
            me._endpoints.Free()
         End If
         me._endpoints = Null
         If me._ownsConfig And Assigned(me._config) Then
            me._config.Free()
         End If
         me._config = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
