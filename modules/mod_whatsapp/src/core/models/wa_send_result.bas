Imports mod_tobject

Namespace mod_wa_send_result

   Class WaSendResult
      Inherits TTObject

      Success As Boolean
      Message As String
      ProviderResponse As String
      Recipient As String
      ClientName As String

      Sub New()
         MyBase.New()
         me.Success = False
      End Sub

      Shared Function Ok(pClientName As String, pRecipient As String, pMessage As String = "Mensagem enviada") As WaSendResult
         Dim _result As New WaSendResult()
         _result.Success = True
         _result.ClientName = pClientName
         _result.Recipient = pRecipient
         _result.Message = pMessage
         Ok = _result
      End Function

      Shared Function Fail(pClientName As String, pRecipient As String, pMessage As String) As WaSendResult
         Dim _result As New WaSendResult()
         _result.Success = False
         _result.ClientName = pClientName
         _result.Recipient = pRecipient
         _result.Message = pMessage
         Fail = _result
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaSendResult")
            .Prop("Success", me.Success)
            .Prop("ClientName", me.ClientName)
            .Prop("Recipient", me.Recipient)
            .Prop("Message", me.Message)
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

End Namespace
