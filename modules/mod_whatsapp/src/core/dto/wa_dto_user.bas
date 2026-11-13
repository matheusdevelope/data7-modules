Imports Collections
Imports mod_tobject

Namespace mod_wa_dto_user

   Function WaDtoUserStringListToJsonArray(pList As StringList) As String
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
      WaDtoUserStringListToJsonArray = s
   End Function

   Class WaUserLookupRequest
      Inherits TTObject

      Numbers As StringList

      Sub New()
         MyBase.New()
         me.Numbers = New StringList()
      End Sub

      Function ToJsonEvolution() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoUserStringListToJsonArray(me.Numbers))
         Dim _json As New TJSONObject()
         _json.PutArray("numbers", _arr)
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _arr As TJSONArray =New TJSONArray(WaDtoUserStringListToJsonArray(me.Numbers))
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

   Class WaUserProfileNameRequest
      Inherits TTObject

      Name As String

      Sub New()
         MyBase.New()
      End Sub

      Function ToJson() As String
         Dim _json As New TJSONObject()
         _json.PutString("name", me.Name)
         ToJson = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaUserProfileStatusRequest
      Inherits TTObject

      Status As String

      Sub New()
         MyBase.New()
      End Sub

      Function ToJson() As String
         Dim _json As New TJSONObject()
         _json.PutString("status", me.Status)
         ToJson = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaUserBlockRequest
      Inherits TTObject

      Number As String

      Sub New()
         MyBase.New()
      End Sub

      Function ToJson() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
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
