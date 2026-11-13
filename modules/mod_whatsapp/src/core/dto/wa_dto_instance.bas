Imports Collections
Imports mod_tobject

Namespace mod_wa_dto_instance

   Class WaInstanceCreateRequest
      Inherits TTObject

      InstanceName As String
      Token As String
      Number As String
      QrCode As Boolean
      Integration As String

      Sub New()
         MyBase.New()
         me.QrCode = True
         me.Integration = "WHATSAPP-BAILEYS"
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("instanceName", me.InstanceName)
         If me.Token <> "" Then
            _json.PutString("token", me.Token)
         End If
         If me.Number <> "" Then
            _json.PutString("number", me.Number)
         End If
         _json.PutBoolean("qrcode", me.QrCode)
         If me.Integration <> "" Then
            _json.PutString("integration", me.Integration)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("name", me.InstanceName)
         If me.Token <> "" Then
            _json.PutString("token", me.Token)
         End If
         If me.InstanceName <> "" Then
            _json.PutString("instanceId", me.InstanceName)
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

End Namespace
