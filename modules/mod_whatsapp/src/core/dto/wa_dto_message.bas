Imports Collections
Imports mod_tobject

Namespace mod_wa_dto_message

   Function WaDtoMessageStringListToJsonArray(pList As StringList) As String
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
      WaDtoMessageStringListToJsonArray = s
   End Function

   Class WaMessageKey
      Inherits TTObject

      RemoteJid As String
      FromMe As Boolean
      Id As String
      Participant As String

      Sub New()
         MyBase.New()
         me.FromMe = False
      End Sub

      Function ToJsonObject() As TJSONObject
         Dim _json As New TJSONObject()
         If me.RemoteJid <> "" Then
            _json.PutString("remoteJid", me.RemoteJid)
         End If
         _json.PutBoolean("fromMe", me.FromMe)
         If me.Id <> "" Then
            _json.PutString("id", me.Id)
         End If
         If me.Participant <> "" Then
            _json.PutString("participant", me.Participant)
         End If
         ToJsonObject = _json
      End Function

      Function ToJson() As String
         Dim _json As TJSONObject = me.ToJsonObject()
         ToJson = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaMessageReactRequest
      Inherits TTObject

      Key As WaMessageKey
      Reaction As String
      Number As String

      Sub New()
         MyBase.New()
         me.Key = New WaMessageKey()
      End Sub

      Function ToJsonEvolution() As String
         Dim _key As TJSONObject = me.Key.ToJsonObject()
         Dim _json As New TJSONObject()
         _json.PutObject("key", _key)
         _json.PutString("reaction", me.Reaction)
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         If me.Number <> "" Then
            _json.PutString("number", me.Number)
         ElseIf Assigned(me.Key) Then
            If me.Key.RemoteJid <> "" Then
               _json.PutString("number", me.Key.RemoteJid)
            End If
         End If
         If Assigned(me.Key) Then
            If me.Key.Id <> "" Then
               _json.PutString("id", me.Key.Id)
            End If
         End If
         _json.PutString("reaction", me.Reaction)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Key) Then
            me.Key.Free()
            me.Key = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaMessageMarkReadRequest
      Inherits TTObject

      Number As String
      Id As String
      FromMe As Boolean
      MessageIds As StringList

      Sub New()
         MyBase.New()
         me.FromMe = False
         me.MessageIds = New StringList()
      End Sub

      Function ToJsonEvolution() As String
         Dim _key As New TJSONObject()
         If me.Number <> "" Then
            _key.PutString("remoteJid", me.Number)
         End If
         _key.PutBoolean("fromMe", me.FromMe)
         If me.Id <> "" Then
            _key.PutString("id", me.Id)
         End If

         Dim _arr As TJSONArray
         If me.Id <> "" Then
            _arr =New TJSONArray("[" + _key.ToString() + "]")
         ElseIf Assigned(me.MessageIds) Then
            If me.MessageIds.Count > 0 Then
               Dim _keys As String = "["
               Dim i As Integer
               For i = 0 To me.MessageIds.Count - 1
                  If i > 0 Then
                     _keys = _keys + ","
                  End If
                  Dim _item As New TJSONObject()
                  _item.PutString("remoteJid", me.Number)
                  _item.PutBoolean("fromMe", me.FromMe)
                  _item.PutString("id", me.MessageIds.Strings(i))
                  _keys = _keys + _item.ToString()
                  _item.Free()
               Next
               _keys = _keys + "]"
               _arr =New TJSONArray(_keys)
            Else
               _arr =New TJSONArray("[]")
            End If
         Else
            _arr =New TJSONArray("[]")
         End If
         _key.Free()

         Dim _json As New TJSONObject()
         _json.PutArray("readMessages", _arr)
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         If Assigned(me.MessageIds) Then
            If me.MessageIds.Count = 0 And me.Id <> "" Then
               me.MessageIds.Add(me.Id)
            End If
         End If
         Dim _arr As TJSONArray =New TJSONArray(WaDtoMessageStringListToJsonArray(me.MessageIds))
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutArray("messageIds", _arr)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
         If Assigned(me.MessageIds) Then
            me.MessageIds.Free()
            me.MessageIds = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaMessageDeleteRequest
      Inherits TTObject

      Chat As String
      RemoteJid As String
      MessageId As String
      Id As String
      FromMe As Boolean

      Sub New()
         MyBase.New()
         me.FromMe = True
      End Sub

      Private Function ResolveChat() As String
         If me.Chat <> "" Then
            ResolveChat = me.Chat
         Else
            ResolveChat = me.RemoteJid
         End If
      End Function

      Private Function ResolveId() As String
         If me.MessageId <> "" Then
            ResolveId = me.MessageId
         Else
            ResolveId = me.Id
         End If
      End Function

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("id", me.ResolveId())
         _json.PutString("remoteJid", me.ResolveChat())
         _json.PutBoolean("fromMe", me.FromMe)
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("chat", me.ResolveChat())
         _json.PutString("messageId", me.ResolveId())
         _json.PutBoolean("fromMe", me.FromMe)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaMessageEditRequest
      Inherits TTObject

      Chat As String
      MessageId As String
      NewText As String

      Sub New()
         MyBase.New()
      End Sub

      Function ToJsonEvolution() As String
         Dim _key As New TJSONObject()
         _key.PutString("remoteJid", me.Chat)
         _key.PutBoolean("fromMe", True)
         _key.PutString("id", me.MessageId)

         Dim _json As New TJSONObject()
         _json.PutString("number", me.Chat)
         _json.PutObject("key", _key)
         _json.PutString("text", me.NewText)
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("chat", me.Chat)
         _json.PutString("messageId", me.MessageId)
         _json.PutString("text", me.NewText)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaMessagePresenceRequest
      Inherits TTObject

      Number As String
      Presence As String
      Delay As Integer

      Sub New()
         MyBase.New()
         me.Presence = "composing"
         me.Delay = 0
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("presence", me.Presence)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("presence", me.Presence)
         _json.PutInteger("delay", me.Delay)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
