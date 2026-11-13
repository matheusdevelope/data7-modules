Imports mod_tlist
Imports http_enums
Imports http_url
Imports http_headers
Imports http_body
Imports http_form
Imports mod_certificate
Imports http_request
Imports http_response
Imports http_transport
Imports http_interceptor
Imports http_winhttp
Imports http_curl
Imports http_data7
Imports http_mock

Namespace http_client

   Class HttpClient

      BaseUrl As String
      Timeout As Integer = 10000
      ReadOnly Headers As HttpHeaders
      ReadOnly Params As HttpParams
      ReadOnly Certificate As TCertificate

      Private _contentType As String
      Private _accept As String
      Private _userAgent As String
      Private _transport As IHttpTransport
      Private _interceptors As TTList<HttpInterceptor>
      Private _ownsTransport As Boolean

      Sub New(pTransport As IHttpTransport, pBaseUrl As String = "", pOwnsTransport As Boolean = True)
         MyBase.New()
         me._transport = pTransport
         me._ownsTransport = pOwnsTransport
         me.BaseUrl = pBaseUrl
         me.Headers = New HttpHeaders()
         me.Params = New HttpParams()
         me.Certificate = New TCertificate()
         me._interceptors = New TTList<HttpInterceptor>()
         me.ContentType = "application/json"
         me.Accept = "application/json"
         me.UserAgent = "Data7/1.0"
      End Sub

      Property Transport As IHttpTransport
         Get
            Transport = me._transport
         End Get
      End Property

      Property ContentType As String
         Get
            ContentType = me._contentType
         End Get
         Set(pValue As String)
            me._contentType = pValue
            me.Headers.Define("Content-Type", pValue)
         End Set
      End Property

      Property Accept As String
         Get
            Accept = me._accept
         End Get
         Set(pValue As String)
            me._accept = pValue
            me.Headers.Define("Accept", pValue)
         End Set
      End Property

      Property UserAgent As String
         Get
            UserAgent = me._userAgent
         End Get
         Set(pValue As String)
            me._userAgent = pValue
            me.Headers.Define("User-Agent", pValue)
         End Set
      End Property

      Function Use(pInterceptor As HttpInterceptor) As HttpClient
         me._interceptors.Push(pInterceptor)
         Use = me
      End Function

      Overridable Sub OnRequest(pReq As HttpRequest)
      End Sub

      Overridable Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
         AfterRequest = pRes
      End Function

      Function Request(pMethod As HttpMethod, pEndpoint As String) As HttpResponse
         Dim body As HttpBody = New HttpBody()
         Dim result As HttpResponse = me.Request(pMethod, pEndpoint, body)
         body.Free()
         Request = result
      End Function

      Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As String) As HttpResponse
         Dim body As HttpBody = HttpBody.FromText(pBody, me.ContentType)
         Dim result As HttpResponse = me.Request(pMethod, pEndpoint, body)
         body.Free()
         Request = result
      End Function

      Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As FormData) As HttpResponse
         Dim body As HttpBody = HttpBody.FromForm(pBody)
         Dim result As HttpResponse = me.Request(pMethod, pEndpoint, body)
         body.Free()
         Request = result
      End Function

      Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As TJSONObject) As HttpResponse
         Dim jsonText As String = pBody.ToString()
         Dim body As HttpBody = HttpBody.FromJson(jsonText)
         Dim result As HttpResponse = me.Request(pMethod, pEndpoint, body)
         body.Free()
         Request = result
      End Function

      Function Request(pMethod As HttpMethod, pEndpoint As String, pBody As HttpBody) As HttpResponse
         Dim req As HttpRequest = me.BuildRequest(pMethod, pEndpoint, pBody)
         me.OnRequest(req)
         Dim i As Integer
         Dim n As Integer = me._interceptors.Length
         For i = 0 To n - 1
            me._interceptors.Take(i).OnRequest(req)
         Next
         Dim res As HttpResponse = me._transport.Send(req)
         res = me.AfterRequest(req, res)
         For i = 0 To n - 1
            res = me._interceptors.Take(i).AfterRequest(req, res)
         Next
         req.Free()
         Request = res
      End Function

      Function Gett(pEndpoint As String = "") As HttpResponse
         Gett = me.Request(HttpMethod.Gett(), pEndpoint)
      End Function

      Function Post(pEndpoint As String) As HttpResponse
         Post = me.Request(HttpMethod.Post(), pEndpoint)
      End Function

      Function Post(pEndpoint As String, pBody As HttpBody) As HttpResponse
         Post = me.Request(HttpMethod.Post(), pEndpoint, pBody)
      End Function

      Function Post(pEndpoint As String, pBody As String) As HttpResponse
         Post = me.Request(HttpMethod.Post(), pEndpoint, pBody)
      End Function

      Function Post(pEndpoint As String, pBody As FormData) As HttpResponse
         Post = me.Request(HttpMethod.Post(), pEndpoint, pBody)
      End Function

      Function Post(pEndpoint As String, pBody As TJSONObject) As HttpResponse
         Dim jsonText As String = pBody.ToString()
         Dim body As HttpBody = HttpBody.FromJson(jsonText)
         Dim result As HttpResponse = me.Request(HttpMethod.Post(), pEndpoint, body)
         body.Free()
         Post = result
      End Function

      Function Put(pEndpoint As String) As HttpResponse
         Put = me.Request(HttpMethod.Put(), pEndpoint)
      End Function

      Function Put(pEndpoint As String, pBody As HttpBody) As HttpResponse
         Put = me.Request(HttpMethod.Put(), pEndpoint, pBody)
      End Function

      Function Put(pEndpoint As String, pBody As String) As HttpResponse
         Put = me.Request(HttpMethod.Put(), pEndpoint, pBody)
      End Function

      Function Put(pEndpoint As String, pBody As FormData) As HttpResponse
         Put = me.Request(HttpMethod.Put(), pEndpoint, pBody)
      End Function

      Function Patch(pEndpoint As String) As HttpResponse
         Patch = me.Request(HttpMethod.Patch(), pEndpoint)
      End Function

      Function Patch(pEndpoint As String, pBody As HttpBody) As HttpResponse
         Patch = me.Request(HttpMethod.Patch(), pEndpoint, pBody)
      End Function

      Function Patch(pEndpoint As String, pBody As String) As HttpResponse
         Patch = me.Request(HttpMethod.Patch(), pEndpoint, pBody)
      End Function

      Function Patch(pEndpoint As String, pBody As FormData) As HttpResponse
         Patch = me.Request(HttpMethod.Patch(), pEndpoint, pBody)
      End Function

      Function Delete(pEndpoint As String) As HttpResponse
         Delete = me.Request(HttpMethod.Delete(), pEndpoint)
      End Function

      Function Delete(pEndpoint As String, pBody As HttpBody) As HttpResponse
         Delete = me.Request(HttpMethod.Delete(), pEndpoint, pBody)
      End Function

      Function Delete(pEndpoint As String, pBody As String) As HttpResponse
         Delete = me.Request(HttpMethod.Delete(), pEndpoint, pBody)
      End Function

      Function Delete(pEndpoint As String, pBody As FormData) As HttpResponse
         Delete = me.Request(HttpMethod.Delete(), pEndpoint, pBody)
      End Function

      Private Function BuildRequest(pMethod As HttpMethod, pEndpoint As String, pBody As HttpBody) As HttpRequest
         Dim headers As HttpHeaders = me.Headers.Copy()
         Dim body As HttpBody
         If Assigned(pBody) Then
            body = pBody
         Else
            body = New HttpBody()
         End If
         If body.IsForm Then
            headers.Define("Content-Type", body.ContentType)
         ElseIf body.IsEmpty Then
            If headers.Has("Content-Type") And (pMethod.AsString = "GET" Or pMethod.AsString = "HEAD") Then
               ' keep session content-type; harmless on GET
            End If
         ElseIf body.ContentType <> "" Then
            headers.Define("Content-Type", body.ContentType)
         End If
         Dim url As String = http_url.Build(me.BaseUrl, pEndpoint, me.Params)
         BuildRequest = New HttpRequest(pMethod, url, headers, body, me.Certificate, me.Timeout)
      End Function

      Sub Free()
         If me._ownsTransport And Assigned(me._transport) Then
            me._transport.Free()
         End If
         If Assigned(me._interceptors) Then
            me._interceptors.Free()
         End If
         If Assigned(me.Headers) Then
            me.Headers.Free()
         End If
         If Assigned(me.Params) Then
            me.Params.Free()
         End If
         If Assigned(me.Certificate) Then
            me.Certificate.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

   Class Http

      Sub New()
         MyBase.New()
      End Sub

      Shared Function DefaultKind() As HttpClientKind
         Dim configured As String = UCase(Data7.Parametro("Customizado_Projeto_ClientePadraoModuloHttp"))
         If configured = "CURL" Then
            DefaultKind = HttpClientKind.Curl()
         Else
            DefaultKind = HttpClientKind.WinHttp()
         End If
      End Function

      Shared Function DefaultTransport() As IHttpTransport
         If Http.DefaultKind().AsString = "CURL" Then
            DefaultTransport = New CurlTransport()
         Else
            DefaultTransport = New WinHttpTransport()
         End If
      End Function

      Shared Function FromTransport(pTransport As IHttpTransport, pBaseUrl As String = "") As HttpClient
         FromTransport = New HttpClient(pTransport, pBaseUrl)
      End Function

      Shared Function WinHttp(pBaseUrl As String = "") As HttpClient
         WinHttp = New HttpClient(New WinHttpTransport(), pBaseUrl)
      End Function

      Shared Function Curl(pBaseUrl As String = "") As HttpClient
         Curl = New HttpClient(New CurlTransport(), pBaseUrl)
      End Function

      Shared Function DevStudio(pBaseUrl As String = "") As HttpClient
         DevStudio = New HttpClient(New Data7Transport(), pBaseUrl)
      End Function

      Shared Function Mock(pStatus As Integer = 200, pBody As String = "{}", pHeaders As String = "Content-Type: application/json") As HttpClient
         Dim transport As New MockTransport()
         transport.DefaultStatus = pStatus
         transport.DefaultBody = pBody
         transport.DefaultHeaders = pHeaders
         Mock = New HttpClient(transport, "")
      End Function

      Shared Function Gett(pUrl As String) As HttpResponse
         Dim client As HttpClient = New HttpClient(Http.DefaultTransport())
         Dim result As HttpResponse = client.Gett(pUrl)
         client.Free()
         Gett = result
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
