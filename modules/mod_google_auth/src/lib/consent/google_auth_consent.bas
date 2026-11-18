Imports mod_tobject
Imports google_auth_code

Namespace google_auth_consent

   MustInherit Class GoogleConsentHandler
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function RequestCode(pAuthUrl As String) As GoogleAuthCode
         Throw New Exception("RequestCode must be implemented.")
      End Function

      Overridable Sub Cancel()
      End Sub

      Overridable Function WasCancelled() As Boolean
         WasCancelled = False
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
