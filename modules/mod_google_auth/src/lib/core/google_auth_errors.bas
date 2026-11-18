Imports mod_tobject

Namespace google_auth_errors

   Class GoogleAuthErrors
      Inherits TTObject

      Shared Function StoreRequired() As String
         StoreRequired = "GoogleAuthService requires a GoogleTokenStore."
      End Function

      Shared Function ConfigRequired() As String
         ConfigRequired = "GoogleAuthService requires a GoogleAuthConfig."
      End Function

      Shared Function ClientIdRequired() As String
         ClientIdRequired = "Client ID is required."
      End Function

      Shared Function ClientSecretRequired() As String
         ClientSecretRequired = "Client Secret is required. Google Desktop OAuth clients send it on the token request."
      End Function

      Shared Function ScopeRequired() As String
         ScopeRequired = "At least one OAuth scope is required."
      End Function

      Shared Function RedirectRequired() As String
         RedirectRequired = "Redirect URI is required."
      End Function

      Shared Function AuthorizationCodeRequired() As String
         AuthorizationCodeRequired = "Authorization code is required."
      End Function

      Shared Function RefreshTokenRequired() As String
         RefreshTokenRequired = "Refresh token is required."
      End Function

      Shared Function StateMismatch() As String
         StateMismatch = "OAuth state mismatch. The authorization response is invalid."
      End Function

      Shared Function ConsentDenied(pError As String) As String
         If Trim(pError) = "" Then
            ConsentDenied = "Google authorization was denied."
         Else
            ConsentDenied = "Google authorization was denied: " & pError
         End If
      End Function

      Shared Function TokenRequestFailed(pDetail As String) As String
         TokenRequestFailed = "Google token request failed." & CHAR(13) & pDetail
      End Function

      Shared Function ServiceAccountUnsupported() As String
         ServiceAccountUnsupported = "Service Account grant is not supported in this version."
      End Function

      Shared Function UnknownApiVersion(pName As String) As String
         UnknownApiVersion = "Unknown Google OAuth API version: " & pName
      End Function

      Shared Function NotAuthorized() As String
         NotAuthorized = "Google account is not authorized."
      End Function

      Shared Function ConsentCancelled() As String
         ConsentCancelled = "Authorization was cancelled."
      End Function

      Shared Function AuthorizationNotStarted() As String
         AuthorizationNotStarted = "Start authorization before extracting the redirect URL."
      End Function

      Shared Function RedirectUrlRequired() As String
         RedirectUrlRequired = "Redirect URL is required."
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
