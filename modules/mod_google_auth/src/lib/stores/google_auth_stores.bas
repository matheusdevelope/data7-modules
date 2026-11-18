Imports mod_tobject
Imports google_auth_store
Imports google_auth_store_memory
Imports google_auth_store_json
Imports google_auth_store_encrypted

Namespace google_auth_stores

   Class GoogleTokenStores
      Inherits TTObject

      Shared Function Memory() As GoogleTokenStore
         Memory = New GoogleTokenStoreMemory()
      End Function

      Shared Function Json(pPath As String) As GoogleTokenStore
         Json = New GoogleTokenStoreEncrypted(New GoogleTokenStoreJson(pPath), True)
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
