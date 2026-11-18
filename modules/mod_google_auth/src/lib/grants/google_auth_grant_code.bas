Imports http_headers
Imports google_auth_grant
Imports google_auth_config
Imports google_auth_http
Imports google_auth_token_set
Imports google_auth_errors
Imports google_auth_enums

Namespace google_auth_grant_code

   Class GoogleAuthGrantAuthorizationCode
      Inherits GoogleAuthGrant

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function Exchange(pHttp As GoogleAuthHttp, pConfig As GoogleAuthConfig, pContext As GoogleAuthGrantContext) As GoogleTokenSet
         If Not Assigned(pContext) Then
            Throw New Exception(GoogleAuthErrors.AuthorizationCodeRequired())
         End If
         If Not Assigned(pContext.AuthCode) Then
            Throw New Exception(GoogleAuthErrors.AuthorizationCodeRequired())
         End If
         pContext.AuthCode.EnsureValid()
         Dim tokenForm As HttpParams = me.BaseParams(pConfig)
         tokenForm.Define("grant_type", GoogleAuthGrantType.AuthorizationCode().AsString)
         tokenForm.Define("code", pContext.AuthCode.Value)
         tokenForm.Define("redirect_uri", pConfig.ResolveRedirectUri())
         If Assigned(pContext.Pkce) Then
            tokenForm.Define("code_verifier", pContext.Pkce.Verifier)
         End If
         Dim tokens As GoogleTokenSet = pHttp.RequestToken(tokenForm)
         tokenForm.Free()
         Exchange = tokens
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
