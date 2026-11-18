Imports http_headers
Imports mod_tobject
Imports google_auth_config
Imports google_auth_http
Imports google_auth_token_set
Imports google_auth_code
Imports google_auth_pkce

Namespace google_auth_grant

   Class GoogleAuthGrantContext
      Inherits TTObject

      AuthCode As GoogleAuthCode
      Pkce As GoogleAuthPkce
      RefreshToken As String

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Dispose()
         me.AuthCode = Null
         me.Pkce = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   MustInherit Class GoogleAuthGrant
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function Exchange(pHttp As GoogleAuthHttp, pConfig As GoogleAuthConfig, pContext As GoogleAuthGrantContext) As GoogleTokenSet
         Throw New Exception("Exchange must be implemented.")
      End Function

      Protected Function BaseParams(pConfig As GoogleAuthConfig) As HttpParams
         Dim tokenForm As New HttpParams()
         tokenForm.Define("client_id", pConfig.Credentials.ClientId)
         tokenForm.Define("client_secret", Trim(pConfig.Credentials.ClientSecret))
         BaseParams = tokenForm
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
