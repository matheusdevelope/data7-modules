Imports mod_tobject
Imports google_auth_crypto

Namespace google_auth_state

   Class GoogleAuthState
      Inherits TTObject

      Value As String

      Sub New()
         MyBase.New()
         me.Value = RandomUnreserved(32)
      End Sub

      Sub New(pValue As String)
         MyBase.New()
         me.Value = Trim(pValue)
      End Sub

      Function Matches(pOther As String) As Boolean
         Matches = me.Value = Trim(pOther)
      End Function

      Overrides Function ToString() As String
         ToString = me.Value
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
