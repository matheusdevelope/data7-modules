Imports http_interceptor
Imports http_request
Imports google_auth_client

Namespace google_auth_bearer

   Class GoogleBearerInterceptor
      Inherits HttpInterceptor

      Private _auth As GoogleAuthClient

      Sub New(pAuth As GoogleAuthClient)
         MyBase.New()
         If Not Assigned(pAuth) Then
            Throw New Exception("GoogleBearerInterceptor requires a GoogleAuthClient.")
         End If
         me._auth = pAuth
      End Sub

      Overrides Sub OnRequest(pReq As HttpRequest)
         Dim access As String = me._auth.GetAccessToken()
         pReq.Headers.Define("Authorization", "Bearer " & access)
      End Sub

      Overrides Sub Dispose()
         me._auth = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
