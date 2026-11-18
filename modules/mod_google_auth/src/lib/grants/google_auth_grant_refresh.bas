Imports http_headers
Imports google_auth_grant
Imports google_auth_config
Imports google_auth_http
Imports google_auth_token_set
Imports google_auth_errors
Imports google_auth_enums

Namespace google_auth_grant_refresh

   Class GoogleAuthGrantRefreshToken
      Inherits GoogleAuthGrant

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function Exchange(pHttp As GoogleAuthHttp, pConfig As GoogleAuthConfig, pContext As GoogleAuthGrantContext) As GoogleTokenSet
         Dim refreshValue As String = ""
         If Assigned(pContext) Then
            refreshValue = Trim(pContext.RefreshToken)
         End If
         If refreshValue = "" Then
            Throw New Exception(GoogleAuthErrors.RefreshTokenRequired())
         End If
         Dim tokenForm As HttpParams = me.BaseParams(pConfig)
         tokenForm.Define("grant_type", GoogleAuthGrantType.RefreshToken().AsString)
         tokenForm.Define("refresh_token", refreshValue)
         Dim tokens As GoogleTokenSet = pHttp.RequestToken(tokenForm)
         tokenForm.Free()
         Exchange = tokens
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
