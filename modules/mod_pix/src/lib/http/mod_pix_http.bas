Imports http_client
Imports http_enums
Imports http_headers
Imports http_request
Imports http_response
Imports http_url
Imports mod_pix_config
Imports mod_pix_psp
Imports mod_tobject

Namespace mod_pix_http

   Class PixAccessToken
      Token As String
      Type As String
      Scopes As String
      ReadOnly CreatedAt As TDateTime
      ReadOnly ExpiresAt As TDateTime

      Private _expiresIn As Integer

      Property ExpiresIn As Integer
         Get
            Return me._expiresIn
         End Get
         Set(pValue As Integer)
            me._expiresIn = pValue
            me.ExpiresAt = me.CreatedAt.AddSeconds(me._expiresIn)
         End Set
      End Property

      Sub New()
         MyBase.New()
         me.Initialize()
      End Sub

      Sub New(pToken As String, pType As String, pScopes As String, pExpiresIn As Integer)
         MyBase.New()
         me.Initialize()
         me.Token = pToken
         me.Type = pType
         me.Scopes = pScopes
         me.ExpiresIn = pExpiresIn
      End Sub

      Private Sub Initialize()
         me.CreatedAt = DateTime()
      End Sub

      Function AsAuthorization() As String
         AsAuthorization = me.Type & " " & me.Token
      End Function

      Function IsExpired() As Boolean
         IsExpired = DateTime() > me.ExpiresAt
      End Function

      Shared Function FromJson(pJson As TJSONObject) As PixAccessToken
         With pJson
            FromJson = New PixAccessToken( _
                  .GetString("access_token"), _
                  .GetString("token_type"), _
                  .GetString("scope"), _
                  .GetInteger("expires_in") _
               )
         End With
      End Function

      Sub Free()
         me.CreatedAt = 0
         me.ExpiresAt = 0
         MyBase.Free()
      End Sub

   End Class

   Class PixHttpPairs
      Inherits TTObject

      Private _items As HttpBaseList

      Sub New(pItems As HttpBaseList)
         MyBase.New()
         me._items = pItems
      End Sub

      Sub Clear()
         me._items.Clear()
      End Sub

      Function Define(pName As String, pValue As String) As String
         Define = me._items.Define(pName, pValue)
      End Function

      Overrides Sub Dispose()
         me._items = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixHttpAuthRequest
      Inherits TTObject

      Private _client As HttpClient
      ReadOnly Headers As PixHttpPairs
      ReadOnly Params As PixHttpPairs

      Sub New(pClient As HttpClient)
         MyBase.New()
         me._client = pClient
         me.Headers = New PixHttpPairs(pClient.Headers)
         me.Params = New PixHttpPairs(pClient.Params)
      End Sub

      Property ContentType As String
         Get
            ContentType = me._client.ContentType
         End Get
         Set(pValue As String)
            me._setContentType(pValue)
         End Set
      End Property

      Private Sub _setContentType(pValue As String)
         me._client.ContentType = pValue
      End Sub

      Property Accept As String
         Get
            Accept = me._client.Accept
         End Get
         Set(pValue As String)
            me._setAccept(pValue)
         End Set
      End Property

      Private Sub _setAccept(pValue As String)
         me._client.Accept = pValue
      End Sub

      Overrides Sub Dispose()
         If Assigned(me.Headers) Then
            me.Headers.Free()
         End If
         If Assigned(me.Params) Then
            me.Params.Free()
         End If
         me._client = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixHttp
      Inherits HttpClient

      Protected _config As PixConfig
      Protected _token As PixAccessToken
      Private _certificateLoaded As Boolean

      Sub New(pConfig As PixConfig)
         MyBase.New(Http.DefaultTransport(), PixHttp.ResolveBaseUrl(pConfig))
         me.Setup(pConfig)
      End Sub

      Private Sub Setup(pConfig As PixConfig)
         me._config = pConfig
         me._token = New PixAccessToken()
         me.Timeout = pConfig.Timeout
      End Sub

      Shared Function ResolveBaseUrl(pConfig As PixConfig) As String
         If Not Assigned(pConfig) Then
            Throw New Exception("PixHttp requer PixConfig")
         End If
         If Not Assigned(pConfig.Psp) Then
            Throw New Exception("PixHttp requer PixPsp na configuração")
         End If
         ResolveBaseUrl = pConfig.Psp.BaseUrl(pConfig.Sandbox)
      End Function

      Shared Function UrlEncode(pValue As String) As String
         UrlEncode = http_url.Encode(pValue)
      End Function

      Shared Function DownloadToFile(pUrl As String, pPath As String) As String
         Dim client As HttpClient = Http.Create(Http.DefaultTransport())
         client.Certificate.Use = False
         Dim response As HttpResponse
         Dim _ret As String
         Try
            response = client.Gett(pUrl)
            If Not response.IsSuccessful Then
               Throw New Exception(response.ToString())
            End If
            response.Data.SaveToFile(pPath)
            _ret = pPath
         Catch ex As Exception
            If Assigned(response) Then
               response.Free()
               response = Null
            End If
            client.Free()
            Throw New Exception(ex._GetMessage())
         End Try
         response.Free()
         client.Free()
         DownloadToFile = _ret
      End Function

      Overrides Sub OnRequest(pReq As HttpRequest)
         me.LoadCertificate()
         me.Authenticate()
         pReq.Headers.Define("Authorization", me._token.AsAuthorization())
      End Sub

      Overrides Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
         me.Params.Clear()
         Dim detail As String = ""
         If pRes.Status < 200 Or pRes.Status >= 300 Then
            Dim body As String = ""
            If Assigned(pReq.Body) Then
               body = pReq.Body.AsText()
            End If
            detail = pRes.ToString() & CHAR(13) & CHAR(13) & pReq.ToString() & CHAR(13) & CHAR(13) & "Request Body:" & CHAR(13) & body
         End If
         me.CheckResponse(pRes.Status, detail)
         AfterRequest = pRes
      End Function

      Overridable Sub CheckResponse(pStatus As Integer, pDetail As String)
         If pStatus < 200 Or pStatus >= 300 Then
            Throw New Exception(pDetail)
         End If
      End Sub

      Overridable Sub Authenticate()
         If me._token = Null Or me._token.IsExpired() Then
            me.LoadToken()
         End If
      End Sub

      Function RequestJson(pMethod As String, pEndpoint As String, pPayload As String = "") As TJSONObject
         Dim method As HttpMethod = me.ParseMethod(pMethod)
         Dim _response As HttpResponse
         If pPayload = "" Then
            _response = me.Request(method, pEndpoint)
         Else
            _response = me.Request(method, pEndpoint, pPayload)
         End If
         RequestJson = _response.Data.AsJson
         _response.Free()
      End Function

      Overridable Sub LoadToken()
         me.LoadCertificate()
         Dim httpToken As HttpClient = Http.Create(Http.DefaultTransport())
         httpToken.Timeout = me._config.Timeout
         httpToken.ContentType = "application/x-www-form-urlencoded"
         httpToken.Accept = "application/json"
         httpToken.Headers.Define("Authorization", me._config.Credentials.AsAuthorization())
         httpToken.Headers.Define("grant_type", "client_credentials")
         httpToken.Headers.Define("client_id", me._config.Credentials.Id)
         httpToken.Headers.Define("client_secret", me._config.Credentials.Secret)
         httpToken.Certificate.Assign(me.Certificate)
         httpToken.Certificate.CleanOnFree = False

         Dim bodyParams As New HttpParams()
         bodyParams.Define("grant_type", "client_credentials")
         bodyParams.Define("scope", me._config.Psp.Scopes())
         If me._config.Credentials.Id <> "" Then
            bodyParams.Define("client_id", me._config.Credentials.Id)
         End If
         If me._config.Credentials.Secret <> "" Then
            bodyParams.Define("client_secret", me._config.Credentials.Secret)
         End If

         Dim body As String = bodyParams.AsText()
         bodyParams.Free()

         Dim authRequest As New PixHttpAuthRequest(httpToken)
         me.LoadToken_PreRequest(authRequest, body)
         authRequest.Free()

         Try
            Dim url As String = me._config.Psp.AuthUrl(me._config.Sandbox)
            Dim response As HttpResponse = httpToken.Post(url, body)
            If response.Status <> 200 Then
               Dim errorText As String = response.ToString()
               response.Free()
               Throw New Exception(errorText)
            End If

            Dim json As TJSONObject = response.Data.AsJson
            me._token.Free()
            me._token = PixAccessToken.FromJson(json)

            me.LoadToken_PostRequest(me._token)

            json.Free()
            response.Free()
            httpToken.Free()
         Catch Ex As Exception
            httpToken.Free()
            Throw New Exception("Erro ao obter token de autenticação PIX:" & CHAR(13) & Ex._GetMessage())
         End Try
      End Sub

      Overridable Sub LoadToken_PreRequest(ByRef pRequest As PixHttpAuthRequest, ByRef pBody As String)
      End Sub

      Overridable Sub LoadToken_PostRequest(ByRef pToken As PixAccessToken)
      End Sub

      Sub LoadCertificate()
         If Not me._certificateLoaded Then
            me.Certificate.Load(me._config.Certificate.Path, me._config.Certificate.Pass)
            me._certificateLoaded = True
         End If
      End Sub

      Function AccessToken() As PixAccessToken
         AccessToken = me._token
      End Function

      Private Function ParseMethod(pMethod As String) As HttpMethod
         Dim normalized As String = UCase(Trim(pMethod))
         If normalized = "GET" Then
            ParseMethod = HttpMethod.Gett()
         ElseIf normalized = "POST" Then
            ParseMethod = HttpMethod.Post()
         ElseIf normalized = "PUT" Then
            ParseMethod = HttpMethod.Put()
         ElseIf normalized = "PATCH" Then
            ParseMethod = HttpMethod.Patch()
         ElseIf normalized = "DELETE" Then
            ParseMethod = HttpMethod.Delete()
         Else
            Throw New Exception("Método HTTP não suportado: " & pMethod)
         End If
      End Function

      Sub Free()
         If Assigned(me._token) Then
            me._token.Free()
            me._token = Null
         End If
         me._config = Null
         MyBase.Free()
      End Sub

   End Class

End Namespace
