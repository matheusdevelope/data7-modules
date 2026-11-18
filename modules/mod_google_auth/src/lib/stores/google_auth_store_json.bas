Imports TFile
Imports TPath
Imports google_auth_store
Imports google_auth_token_set

Namespace google_auth_store_json

   Class GoogleTokenStoreJson
      Inherits GoogleTokenStore

      Private _path As String

      Sub New(pPath As String)
         MyBase.New()
         me._path = Trim(pPath)
         If me._path = "" Then
            Throw New Exception("GoogleTokenStoreJson requires a file path.")
         End If
      End Sub

      Overrides Function Load(pKey As String) As GoogleTokenSet
         Dim root As TJSONObject = me.ReadRoot()
         Dim key As String = Trim(pKey)
         If Not root.Has(key) Then
            root.Free()
            Load = Null
            Exit Function
         End If
         Dim payload As TJSONObject = root.GetJSONObject(key)
         Dim tokens As GoogleTokenSet = GoogleTokenSet.FromJson(payload)
         payload.Free()
         root.Free()
         Load = tokens
      End Function

      Overrides Sub Save(pKey As String, pTokens As GoogleTokenSet)
         Dim root As TJSONObject = me.ReadRoot()
         Dim key As String = Trim(pKey)
         If Assigned(pTokens) Then
            Dim payload As TJSONObject = pTokens.ToJson()
            root.PutObject(key, payload)
         End If
         me.WriteRoot(root)
         root.Free()
      End Sub

      Overrides Sub Clear(pKey As String)
         Dim root As TJSONObject = me.ReadRoot()
         Dim key As String = Trim(pKey)
         If root.Has(key) Then
            root.PutString(key, "")
         End If
         me.WriteRoot(root)
         root.Free()
      End Sub

      Overrides Function Exists(pKey As String) As Boolean
         Dim root As TJSONObject = me.ReadRoot()
         Dim key As String = Trim(pKey)
         Dim found As Boolean = False
         If root.Has(key) Then
            Try
               Dim payload As TJSONObject = root.GetJSONObject(key)
               found = Assigned(payload)
               If Assigned(payload) Then
                  payload.Free()
               End If
            Catch ex As Exception
               found = False
            End Try
         End If
         root.Free()
         Exists = found
      End Function

      Private Function ReadRoot() As TJSONObject
         Dim root As New TJSONObject()
         If TFile.Exists(me._path) Then
            Try
               root.LoadFromFile(me._path)
            Catch ex As Exception
               root.Free()
               root = New TJSONObject()
            End Try
         End If
         ReadRoot = root
      End Function

      Private Sub WriteRoot(pRoot As TJSONObject)
         Dim folder As String = TPath.GetDirectoryName(me._path)
         If folder <> "" Then
            If Not TFile.Exists(folder) Then
               ' parent folder is the caller's responsibility
            End If
         End If
         pRoot.SaveToFile(me._path)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
