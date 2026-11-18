Imports http_headers
Imports http_url
Imports mod_tobject
Imports google_auth_config
Imports google_auth_pkce

Namespace google_auth_endpoints

   MustInherit Class GoogleOAuthEndpoints
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function AuthorizationUrl() As String
         Throw New Exception("AuthorizationUrl must be implemented.")
      End Function

      Overridable Function TokenUrl() As String
         Throw New Exception("TokenUrl must be implemented.")
      End Function

      Overridable Function RevokeUrl() As String
         Throw New Exception("RevokeUrl must be implemented.")
      End Function

      Overridable Function UserInfoUrl() As String
         Throw New Exception("UserInfoUrl must be implemented.")
      End Function

      Function BuildAuthorizationUrl(pConfig As GoogleAuthConfig, pPkce As GoogleAuthPkce, pState As String) As String
         Dim query As New HttpParams()
         query.Define("client_id", pConfig.Credentials.ClientId)
         query.Define("redirect_uri", pConfig.ResolveRedirectUri())
         query.Define("response_type", "code")
         query.Define("scope", pConfig.Scopes.AsQuery())
         query.Define("access_type", pConfig.AccessType)
         query.Define("prompt", pConfig.Prompt)
         query.Define("state", pState)
         query.Define("code_challenge", pPkce.Challenge)
         query.Define("code_challenge_method", pPkce.Method)
         query.Define("include_granted_scopes", "true")
         Dim url As String = http_url.WithQuery(me.AuthorizationUrl(), query)
         query.Free()
         BuildAuthorizationUrl = url
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
