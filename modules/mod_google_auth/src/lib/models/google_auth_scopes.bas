Imports Collections
Imports mod_tobject
Imports mod_tlist

Namespace google_auth_scopes

   Class GoogleAuthScopes
      Inherits TTObject

      Private _items As TTList<String>

      Sub New()
         MyBase.New()
         me._items = New TTList<String>()
      End Sub

      Sub Add(pScope As String)
         Dim scopeValue As String = Trim(pScope)
         If scopeValue = "" Then
            Exit Sub
         End If
         If me.Contains(scopeValue) Then
            Exit Sub
         End If
         me._items.Push(scopeValue)
      End Sub

      Sub AddMany(pScopes As String)
         Dim raw As String = Trim(pScopes)
         If raw = "" Then
            Exit Sub
         End If
         Dim normalized As String = raw.Replace(",", " ")
         Dim parts As StringList = New StringList()
         parts.Text = normalized.Replace(" ", parts.LineBreak)
         Dim i As Integer
         For i = 0 To parts.Count - 1
            me.Add(parts.Strings(i))
         Next
         parts.Free()
      End Sub

      Function Contains(pScope As String) As Boolean
         Dim needle As String = Trim(pScope).ToLower()
         Dim i As Integer
         For i = 0 To me._items.Length - 1
            If me._items.Take(i).ToLower() = needle Then
               Contains = True
               Exit Function
            End If
         Next
         Contains = False
      End Function

      Function Count() As Integer
         Count = me._items.Length
      End Function

      Function ItemAt(pIndex As Integer) As String
         ItemAt = me._items.Take(pIndex)
      End Function

      Function AsQuery() As String
         Dim text As String = ""
         Dim i As Integer
         For i = 0 To me._items.Length - 1
            If i > 0 Then
               text = text & " "
            End If
            text = text & me._items.Take(i)
         Next
         AsQuery = text
      End Function

      Sub Assign(pValue As GoogleAuthScopes)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me._items.Clean()
         Dim i As Integer
         For i = 0 To pValue.Count() - 1
            me.Add(pValue.ItemAt(i))
         Next
      End Sub

      Overrides Function Clone() As GoogleAuthScopes
         Dim copy As New GoogleAuthScopes()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         ToString = me.AsQuery()
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
