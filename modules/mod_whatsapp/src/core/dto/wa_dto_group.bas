Imports Collections
Imports mod_tobject

Namespace mod_wa_dto_group

   Function WaDtoGroupStringListToJsonArray(pList As StringList) As String
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
      WaDtoGroupStringListToJsonArray = s
   End Function

   Class WaGroupCreateRequest
      Inherits TTObject

      Subject As String
      GroupName As String
      Participants As StringList
      Description As String

      Sub New()
         MyBase.New()
         me.Participants = New StringList()
      End Sub

      Private Function ResolveSubject() As String
         If me.Subject <> "" Then
            ResolveSubject = me.Subject
         Else
            ResolveSubject = me.GroupName
         End If
      End Function

      Function ToJsonEvolution() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoGroupStringListToJsonArray(me.Participants))
         Dim _json As New TJSONObject()
         _json.PutString("subject", me.ResolveSubject())
         _json.PutArray("participants", _arr)
         If me.Description <> "" Then
            _json.PutString("description", me.Description)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoGroupStringListToJsonArray(me.Participants))
         Dim _json As New TJSONObject()
         _json.PutString("groupName", me.ResolveSubject())
         _json.PutArray("participants", _arr)
         If me.Description <> "" Then
            _json.PutString("description", me.Description)
         End If
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Participants) Then
            me.Participants.Free()
            me.Participants = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaGroupInfoRequest
      Inherits TTObject

      GroupJid As String

      Sub New()
         MyBase.New()
      End Sub

      Function ToJson() As String
         Dim _json As New TJSONObject()
         _json.PutString("groupJid", me.GroupJid)
         ToJson = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaGroupParticipantRequest
      Inherits TTObject

      GroupJid As String
      Participants As StringList
      Action As String

      Sub New()
         MyBase.New()
         me.Participants = New StringList()
         me.Action = "add"
      End Sub

      Function ToJsonEvolution() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoGroupStringListToJsonArray(me.Participants))
         Dim _json As New TJSONObject()
         _json.PutArray("participants", _arr)
         If me.Action <> "" Then
            _json.PutString("action", me.Action)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoGroupStringListToJsonArray(me.Participants))
         Dim _json As New TJSONObject()
         _json.PutString("groupJid", me.GroupJid)
         _json.PutArray("participants", _arr)
         If me.Action <> "" Then
            _json.PutString("action", me.Action)
         End If
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Participants) Then
            me.Participants.Free()
            me.Participants = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaGroupUpdateTextRequest
      Inherits TTObject

      GroupJid As String
      Text As String

      Sub New()
         MyBase.New()
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("subject", me.Text)
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("groupJid", me.GroupJid)
         _json.PutString("text", me.Text)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaGroupInviteRequest
      Inherits TTObject

      GroupJid As String

      Sub New()
         MyBase.New()
      End Sub

      Function ToJson() As String
         Dim _json As New TJSONObject()
         _json.PutString("groupJid", me.GroupJid)
         ToJson = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
