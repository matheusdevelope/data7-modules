Imports mod_tobject
Imports mod_wa_message
Imports mod_wa_send_result
Imports mod_wa_api_result
Imports mod_wa_dto_send

Namespace mod_wa_service

   ' wa.Send.*
   Class WaSendResource
      Inherits WaResource

      Sub New(pService As WaService)
         MyBase.New(pService)
      End Sub

      Function Message(pMessage As WaMessage) As WaSendResult
         me.Validator().Validate(pMessage)
         me.EnsureCanSend(pMessage)
         pMessage.Recipient = me.Validator().NormalizeRecipient(pMessage)
         Message = me.Client().SendMessage(pMessage)
      End Function

      Function Message(pMessages As WaMessageList) As Boolean
         Dim i As Integer
         For i = 0 To pMessages.Count() - 1
            Dim _result As WaSendResult = me.Message(pMessages.Take(i))
            If Not _result.Success Then
               Dim _err As String = _result.Message
               _result.Free()
               Throw New Exception(_err)
            End If
            _result.Free()
         Next
         Message = True
      End Function

      Function Text(pReq As WaSendTextRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendText, "envio de texto")
         Text = me.Client().SendText(pReq)
      End Function

      Function Media(pReq As WaSendMediaRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendMedia, "envio de mídia")
         Media = me.Client().SendMedia(pReq)
      End Function

      Function Button(pReq As WaSendButtonsRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendButtons, "envio de botões")
         Button = me.Client().SendButtons(pReq)
      End Function

      Function Poll(pReq As WaSendPollRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendPoll, "envio de enquete")
         Poll = me.Client().SendPoll(pReq)
      End Function

      Function List(pReq As WaSendListRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendList, "envio de lista")
         List = me.Client().SendList(pReq)
      End Function

      Function Location(pReq As WaSendLocationRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendLocation, "envio de localização")
         Location = me.Client().SendLocation(pReq)
      End Function

      Function Contact(pReq As WaSendContactRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendContact, "envio de contato")
         Contact = me.Client().SendContact(pReq)
      End Function

      Function Sticker(pReq As WaSendStickerRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanSendSticker, "envio de sticker")
         Sticker = me.Client().SendSticker(pReq)
      End Function

      Private Sub EnsureCanSend(pMessage As WaMessage)
         me.EnsureReady()
         Dim _hasText As Boolean = pMessage.HasText()
         Dim _hasMedia As Boolean = pMessage.Attachments.Count() > 0
         If _hasText Then
            me.EnsureCapability(me.Caps().CanSendText, "envio de texto")
         End If
         If _hasMedia Then
            me.EnsureCapability(me.Caps().CanSendMedia, "envio de mídia/anexos")
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
