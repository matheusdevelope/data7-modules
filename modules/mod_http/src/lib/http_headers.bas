Imports Collections
Imports mod_tobject

Namespace http_headers

   Class HttpBaseList
      Inherits TTObject

      Private _name As String
      Private _separator As String
      Protected _values As StringList

      Sub New(pName As String, pSeparator As String)
         MyBase.New()
         me._name = pName
         me._separator = pSeparator
         me._values = New StringList()
         me._values.NameValueSeparator = me._separator
      End Sub

      Overridable Function Load(pText As String) As HttpBaseList
         Throw New Exception("Load must be implemented.")
      End Function

      Overridable Function AsText() As String
         Throw New Exception("AsText must be implemented.")
      End Function

      Function Define(pName As String, pValue As Integer) As String
         Define = me.Define(pName, pValue.ToString())
      End Function

      Function Define(pName As String, pValue As String) As String
         me.Remove(pName)
         Dim line As String = pName + me._separator + pValue
         me._values.Add(line)
         Define = line
      End Function

      Function Remove(pName As String) As Boolean
         Dim idx As Integer = me._IndexOf(pName)
         If idx >= 0 Then
            me._values.Delete(idx)
            Remove = True
            Exit Function
         End If
         Remove = False
      End Function

      Function Take(pName As String) As String
         If Not me.Has(pName) Then
            Throw New Exception("No value found for the provided name: " & pName)
         End If
         Take = me.Value(pName)
      End Function

      Function Take(pIndex As Integer) As String
         me._ValidateIndex(pIndex)
         Take = me._values.Strings(pIndex)
      End Function

      Function Name(pIndex As Integer) As String
         me._ValidateIndex(pIndex)
         Name = me._values.Names(pIndex)
      End Function

      Function Value(pIndex As Integer) As String
         Value = me._values.Values(me.Name(pIndex))
      End Function

      Function Value(pName As String) As String
         If Not me.Has(pName) Then
            Throw New Exception("No value found for the provided name: " & pName)
         End If
         Value = me._values.Values(pName)
      End Function

      Function Has(pName As String) As Boolean
         Has = me._IndexOf(pName) >= 0
      End Function

      Sub Join(pValues As HttpBaseList)
         Dim i As Integer
         Dim count As Integer = pValues.Count
         For i = 0 To count - 1
            me.Define(pValues.Name(i), pValues.Value(i))
         Next
      End Sub

      Property Count As Integer
         Get
            Count = me._values.Count
         End Get
      End Property

      Property Separator As String
         Get
            Separator = me._separator
         End Get
      End Property

      Property Item(pIndex As Integer) As String
         Get
            Item = me.Take(pIndex)
         End Get
      End Property

      Overrides Function ToString() As String
         With me.BuildLogger(me._name)
            .Prop("", me._values.Text)
            ToString = .Text()
            .Free()
         End With
      End Function

      Sub Clear()
         me._values.Clear()
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._values) Then
            me._values.Free()
            me._values = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

      Private Function _IndexOf(pName As String) As Integer
         _IndexOf = me._values.IndexOfName(pName)
      End Function

      Private Sub _ValidateIndex(pIndex As Integer)
         If pIndex < 0 Or pIndex >= me._values.Count Then
            Throw New Exception("Invalid index: " & pIndex.ToString())
         End If
      End Sub

   End Class

   Class HttpHeaders
      Inherits HttpBaseList

      Sub New()
         MyBase.New("Headers", ":")
         me.Load("")
      End Sub

      Sub New(pHeaders As StringList)
         MyBase.New("Headers", ":")
         me.Load(pHeaders.Text)
      End Sub

      Sub New(pHeaders As String)
         MyBase.New("Headers", ":")
         me.Load(pHeaders)
      End Sub

      Overrides Function Load(pHeaders As String) As HttpHeaders
         pHeaders = pHeaders.Trim()
         me._values.Clear()
         If pHeaders <> "" Then
            me._values.Text = pHeaders
         End If
         Load = me
      End Function

      Overrides Function AsText() As String
         AsText = me._values.Text.Trim()
      End Function

      Function Copy() As HttpHeaders
         Copy = New HttpHeaders(me.AsText())
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class HttpParams
      Inherits HttpBaseList

      Sub New()
         MyBase.New("Params", "=")
         me.Load("")
      End Sub

      Sub New(pQuery As String)
         MyBase.New("Params", "=")
         me.Load(pQuery)
      End Sub

      Overrides Function Load(pUrl As String) As HttpParams
         pUrl = pUrl.Trim()
         me._values.Clear()
         If pUrl <> "" Then
            Dim query As String = pUrl
            Dim qIndex As Integer = pUrl.Pos("?") - 1
            If qIndex >= 0 Then
               query = pUrl.Right(pUrl.Length - qIndex - 1)
            End If
            Dim i As Integer
            Dim line As String
            With New StringList()
               .Text = query.Replace("&", .LineBreak)
               For i = 0 To .Count - 1
                  line = .Strings(i)
                  If line.Contains("=") Then
                     me._values.Add(line)
                  End If
               Next
               .Free()
            End With
         End If
         Load = me
      End Function

      Overrides Function AsText() As String
         AsText = me._values.Text.Trim().Replace(me._values.LineBreak, "&")
      End Function

      Function Copy() As HttpParams
         Copy = New HttpParams(me.AsText())
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
