Imports IO
Imports Collections
Imports mod_tobject

Namespace mod_wa_attachment

   Class WaAttachment
      Inherits TTObject

      Path As String
      Filename As String
      Caption As String
      MimeType As String
      Base64Data As String

      Sub New()
         MyBase.New()
      End Sub

      Sub New(pPath As String)
         MyBase.New()
         me.Path = pPath
         me.Filename = File.ExtractName(pPath)
      End Sub

      Sub New(pPath As String, pCaption As String)
         MyBase.New()
         me.Path = pPath
         me.Filename = File.ExtractName(pPath)
         me.Caption = pCaption
      End Sub

      Function ToBase64() As String
         If me.Base64Data <> "" Then
            ToBase64 = me.Base64Data
            Exit Function
         End If
         If me.Path = "" Or Not File.Exists(me.Path) Then
            Throw New Exception("Anexo inválido ou arquivo não encontrado: " + me.Path)
         End If
         Dim _raw As String
         Dim _lines As New StringList()
         _lines.LoadFromFile(me.Path)
         _raw = _lines.Text
         me.Base64Data = _raw.ToBase64().ToString()
         _lines.Free()
         ToBase64 = me.Base64Data
      End Function

      Overrides Function GetID() As String
         If me.Path <> "" Then
            GetID = me.Path
         Else
            GetID = me.Filename
         End If
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaAttachment")
            .Prop("Path", me.Path)
            .Prop("Filename", me.Filename)
            .Prop("Caption", me.Caption)
            .Prop("MimeType", me.MimeType)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaAttachmentList
      Inherits TTObject

      Private _list As TTObjectList

      Sub New()
         MyBase.New()
         me._list = New TTObjectList("WaAttachmentList", True)
      End Sub

      Sub Add(pAttachment As WaAttachment)
         me._list.Push(pAttachment)
      End Sub

      Sub Add(pPath As String)
         me.Add(New WaAttachment(pPath))
      End Sub

      Sub Add(pPath As String, pCaption As String)
         me.Add(New WaAttachment(pPath, pCaption))
      End Sub

      Function Take(pIndex As Integer) As WaAttachment
         Take = WaAttachment(me._list.Take(pIndex))
      End Function

      Function Count() As Integer
         Count = me._list.Length()
      End Function

      Function IndexOfPath(pPath As String) As Integer
         If me.Count() = 0 Then
            IndexOfPath = -1
            Exit Function
         End If
         Dim i As Integer
         For i = 0 To me.Count() - 1
            If me.Take(i).Path = pPath Then
               IndexOfPath = i
               Exit Function
            End If
         Next
         IndexOfPath = -1
      End Function

      Sub RemoveAt(pIndex As Integer)
         If pIndex < 0 Or pIndex >= me.Count() Then
            Exit Sub
         End If
         Dim _item As WaAttachment = WaAttachment(me._list.Extract(pIndex))
         If Assigned(_item) Then
            _item.Free()
         End If
      End Sub

      Sub Clean()
         me._list.Clean()
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._list) Then
            me._list.Free()
            me._list = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
