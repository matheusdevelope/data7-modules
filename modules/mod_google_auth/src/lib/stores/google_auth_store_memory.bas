Imports mod_tobject
Imports google_auth_store
Imports google_auth_token_set

Namespace google_auth_store_memory

   Class GoogleTokenStoreMemory
      Inherits GoogleTokenStore

      Private _items As TTObjectList

      Sub New()
         MyBase.New()
         me._items = New TTObjectList("GoogleTokenStoreMemory", True, True)
      End Sub

      Overrides Function Load(pKey As String) As GoogleTokenSet
         Dim key As String = Trim(pKey)
         If Not me._items.Includes(key) Then
            Load = Null
            Exit Function
         End If
         Dim stored As GoogleTokenSet = CType(me._items.Take(key), GoogleTokenSet)
         Load = stored.Clone()
      End Function

      Overrides Sub Save(pKey As String, pTokens As GoogleTokenSet)
         Dim key As String = Trim(pKey)
         If me._items.Includes(key) Then
            me._items.Delete(key)
         End If
         If Assigned(pTokens) Then
            me._items.Push(key, pTokens.Clone())
         End If
      End Sub

      Overrides Sub Clear(pKey As String)
         Dim key As String = Trim(pKey)
         If me._items.Includes(key) Then
            me._items.Delete(key)
         End If
      End Sub

      Overrides Function Exists(pKey As String) As Boolean
         Exists = me._items.Includes(Trim(pKey))
      End Function

      Overrides Sub Dispose()
         If Assigned(me._items) Then
            me._items.Free()
            me._items = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
