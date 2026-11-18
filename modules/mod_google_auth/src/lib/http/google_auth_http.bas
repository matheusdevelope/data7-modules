Imports http_client
Imports http_headers
Imports http_url
Imports http_response
Imports mod_tobject
Imports google_auth_config
Imports google_auth_endpoints
Imports google_auth_token_set
Imports google_auth_errors

Namespace google_auth_http

   Class GoogleAuthHttp
      Inherits TTObject

      Private _client As HttpClient
      Private _ownsClient As Boolean
      Private _endpoints As GoogleOAuthEndpoints

      Sub New(pClient As HttpClient, pEndpoints As GoogleOAuthEndpoints, pOwnsClient As Boolean = True)
         MyBase.New()
         If Not Assigned(pClient) Then
            Throw New Exception("GoogleAuthHttp requires an HttpClient.")
         End If
         If Not Assigned(pEndpoints) Then
            Throw New Exception("GoogleAuthHttp requires GoogleOAuthEndpoints.")
         End If
         me._client = pClient
         me._endpoints = pEndpoints
         me._ownsClient = pOwnsClient
         me._client.ContentType = "application/x-www-form-urlencoded"
         me._client.Accept = "application/json"
         me._client.Certificate.Use = False
      End Sub

      Function Client() As HttpClient
         Client = me._client
      End Function

      Function Endpoints() As GoogleOAuthEndpoints
         Endpoints = me._endpoints
      End Function

      Function PostForm(pUrl As String, pParams As HttpParams) As HttpResponse
         Dim body As String = me.EncodeForm(pParams)
         me._client.ContentType = "application/x-www-form-urlencoded"
         me._client.Accept = "application/json"
         PostForm = me._client.Post(pUrl, body)
      End Function

      Function RequestToken(pParams As HttpParams) As GoogleTokenSet
         Dim response As HttpResponse = me.PostForm(me._endpoints.TokenUrl(), pParams)
         If Not response.IsSuccessful Then
            Dim detail As String = response.Body.AsText
            response.Free()
            Throw New Exception(GoogleAuthErrors.TokenRequestFailed(detail))
         End If
         Dim json As TJSONObject = response.Body.AsJson
         Dim tokens As GoogleTokenSet = GoogleTokenSet.FromJson(json)
         json.Free()
         response.Free()
         RequestToken = tokens
      End Function

      Sub RevokeToken(pToken As String)
         If Trim(pToken) = "" Then
            Exit Sub
         End If
         Dim tokenForm As New HttpParams()
         tokenForm.Define("token", Trim(pToken))
         Dim response As HttpResponse = me.PostForm(me._endpoints.RevokeUrl(), tokenForm)
         tokenForm.Free()
         If Not response.IsSuccessful Then
            Dim detail As String = response.Body.AsText
            response.Free()
            Throw New Exception(GoogleAuthErrors.TokenRequestFailed(detail))
         End If
         response.Free()
      End Sub

      Function EncodeForm(pParams As HttpParams) As String
         Dim text As String = ""
         If Not Assigned(pParams) Then
            EncodeForm = text
            Exit Function
         End If
         Dim i As Integer
         Dim paramCount As Integer = pParams.Count
         For i = 0 To paramCount - 1
            If i > 0 Then
               text = text & "&"
            End If
            text = text & http_url.Encode(pParams.Name(i)) & "=" & http_url.Encode(pParams.Value(i))
         Next
         EncodeForm = text
      End Function

      Shared Function FromConfig(pConfig As GoogleAuthConfig, pEndpoints As GoogleOAuthEndpoints) As GoogleAuthHttp
         Dim httpSession As HttpClient = Http.FromTransport(Http.DefaultTransport())
         httpSession.Timeout = pConfig.Timeout
         FromConfig = New GoogleAuthHttp(httpSession, pEndpoints, True)
      End Function

      Overrides Sub Dispose()
         If me._ownsClient And Assigned(me._client) Then
            me._client.Free()
         End If
         me._client = Null
         me._endpoints = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
