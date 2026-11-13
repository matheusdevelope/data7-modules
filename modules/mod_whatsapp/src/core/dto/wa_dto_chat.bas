Imports Collections
Imports mod_tobject

Namespace mod_wa_dto_chat

   Function WaDtoChatStringListToJsonArray(pList As StringList) As String
      Dim s As String = "["
      If Assigned(pList) Then
         Dim i As Integer
         For i = 0 To pList.Count - 1
            If i > 0 Then
               s = s + ","
            End If
            s = s + pList.Strings(i).Quoted()
         Next
      End If
      s = s + "]"
      WaDtoChatStringListToJsonArray = s
   End Function

   Class WaChatActionRequest
      Inherits TTObject

      Chat As String
      Archive As Boolean
      HasArchive As Boolean

      Sub New()
         MyBase.New()
         me.Archive = False
         me.HasArchive = False
      End Sub

      Sub SetArchive(pArchive As Boolean)
         me.Archive = pArchive
         me.HasArchive = True
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("chat", me.Chat)
         If me.HasArchive Then
            _json.PutBoolean("archive", me.Archive)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("chat", me.Chat)
         If me.HasArchive Then
            _json.PutBoolean("archive", me.Archive)
         End If
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaCheckNumbersRequest
      Inherits TTObject

      Numbers As StringList

      Sub New()
         MyBase.New()
         me.Numbers = New StringList()
      End Sub

      Function ToJsonEvolution() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoChatStringListToJsonArray(me.Numbers))
         Dim _json As New TJSONObject()
         _json.PutArray("numbers", _arr)
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoChatStringListToJsonArray(me.Numbers))
         Dim _json As New TJSONObject()
         _json.PutBoolean("formatJid", True)
         _json.PutArray("number", _arr)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Numbers) Then
            me.Numbers.Free()
            me.Numbers = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaFindFilterRequest
      Inherits TTObject

      WhereJson As String

      Sub New()
         MyBase.New()
         me.WhereJson = "{}"
      End Sub

      Function ToJson() As String
         If me.WhereJson = "" Then
            ToJson = "{}"
         Else
            ToJson = me.WhereJson
         End If
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
