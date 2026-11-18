Imports mod_tobject
Imports google_auth_token_set

Namespace google_auth_client

   MustInherit Class GoogleAuthClient
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function GetAccessToken() As String
         Throw New Exception("GetAccessToken must be implemented.")
      End Function

      Overridable Function Authorize() As GoogleTokenSet
         Throw New Exception("Authorize must be implemented.")
      End Function

      Overridable Function RefreshTokens() As GoogleTokenSet
         Throw New Exception("RefreshTokens must be implemented.")
      End Function

      Overridable Sub Revoke()
         Throw New Exception("Revoke must be implemented.")
      End Sub

      Overridable Function IsAuthorized() As Boolean
         Throw New Exception("IsAuthorized must be implemented.")
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
