Imports mod_tobject
Imports google_auth_token_set

Namespace google_auth_store

   MustInherit Class GoogleTokenStore
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function Load(pKey As String) As GoogleTokenSet
         Throw New Exception("GoogleTokenStore.Load must be implemented.")
      End Function

      Overridable Sub Save(pKey As String, pTokens As GoogleTokenSet)
         Throw New Exception("GoogleTokenStore.Save must be implemented.")
      End Sub

      Overridable Sub Clear(pKey As String)
         Throw New Exception("GoogleTokenStore.Clear must be implemented.")
      End Sub

      Overridable Function Exists(pKey As String) As Boolean
         Dim tokens As GoogleTokenSet = me.Load(pKey)
         If Assigned(tokens) Then
            Exists = True
            tokens.Free()
         Else
            Exists = False
         End If
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
