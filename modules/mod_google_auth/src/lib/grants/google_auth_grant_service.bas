Imports google_auth_grant
Imports google_auth_config
Imports google_auth_http
Imports google_auth_token_set
Imports google_auth_errors

Namespace google_auth_grant_service

   Class GoogleAuthGrantServiceAccount
      Inherits GoogleAuthGrant

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function Exchange(pHttp As GoogleAuthHttp, pConfig As GoogleAuthConfig, pContext As GoogleAuthGrantContext) As GoogleTokenSet
         Throw New Exception(GoogleAuthErrors.ServiceAccountUnsupported())
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
