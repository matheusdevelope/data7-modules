Imports mod_tobject
Imports http_request
Imports http_response

Namespace http_interceptor

   Class HttpInterceptor
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Sub OnRequest(pReq As HttpRequest)
      End Sub

      Overridable Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
         AfterRequest = pRes
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class BearerAuth
      Inherits HttpInterceptor

      Private _token As String

      Sub New(pToken As String)
         MyBase.New()
         me._token = pToken
      End Sub

      Overrides Sub OnRequest(pReq As HttpRequest)
         pReq.Headers.Define("Authorization", "Bearer " & me._token)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class BasicAuth
      Inherits HttpInterceptor

      Private _user As String
      Private _pass As String

      Sub New(pUser As String, pPass As String)
         MyBase.New()
         me._user = pUser
         me._pass = pPass
      End Sub

      Overrides Sub OnRequest(pReq As HttpRequest)
         Dim raw As String = me._user & ":" & me._pass
         Dim encoded As String = raw.ToBase64()
         pReq.Headers.Define("Authorization", "Basic " & encoded)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
