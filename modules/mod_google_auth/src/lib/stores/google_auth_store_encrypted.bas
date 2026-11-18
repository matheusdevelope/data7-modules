Imports Data7
Imports google_auth_store
Imports google_auth_token_set

Namespace google_auth_store_encrypted

   Class GoogleTokenStoreEncrypted
      Inherits GoogleTokenStore

      Private _inner As GoogleTokenStore
      Private _ownsInner As Boolean

      Sub New(pInner As GoogleTokenStore, pOwnsInner As Boolean = True)
         MyBase.New()
         If Not Assigned(pInner) Then
            Throw New Exception("GoogleTokenStoreEncrypted requires an inner store.")
         End If
         me._inner = pInner
         me._ownsInner = pOwnsInner
      End Sub

      Overrides Function Load(pKey As String) As GoogleTokenSet
         Dim stored As GoogleTokenSet = me._inner.Load(pKey)
         If Not Assigned(stored) Then
            Load = Null
            Exit Function
         End If
         stored.AccessToken = me.DecryptValue(stored.AccessToken)
         stored.RefreshToken = me.DecryptValue(stored.RefreshToken)
         stored.IdToken = me.DecryptValue(stored.IdToken)
         Load = stored
      End Function

      Overrides Sub Save(pKey As String, pTokens As GoogleTokenSet)
         If Not Assigned(pTokens) Then
            me._inner.Clear(pKey)
            Exit Sub
         End If
         Dim copy As GoogleTokenSet = pTokens.Clone()
         copy.AccessToken = me.EncryptValue(copy.AccessToken)
         copy.RefreshToken = me.EncryptValue(copy.RefreshToken)
         copy.IdToken = me.EncryptValue(copy.IdToken)
         me._inner.Save(pKey, copy)
         copy.Free()
      End Sub

      Overrides Sub Clear(pKey As String)
         me._inner.Clear(pKey)
      End Sub

      Overrides Function Exists(pKey As String) As Boolean
         Exists = me._inner.Exists(pKey)
      End Function

      Private Function EncryptValue(pValue As String) As String
         Dim secretValue As String = Trim(pValue)
         If secretValue = "" Then
            EncryptValue = ""
            Exit Function
         End If
         Dim encrypted As String
         encrypted = Data7.Criptografar(secretValue)
         EncryptValue = encrypted
      End Function

      Private Function DecryptValue(pValue As String) As String
         Dim _raw As String = Trim(pValue)
         If _raw = "" Then
            DecryptValue = ""
            Exit Function
         End If
         Try
            _raw = Data7.Descriptografar(_raw)
         Catch ex As Exception
            _raw = _raw
         End Try
         DecryptValue = _raw
      End Function

      Overrides Sub Dispose()
         If me._ownsInner And Assigned(me._inner) Then
            me._inner.Free()
         End If
         me._inner = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
