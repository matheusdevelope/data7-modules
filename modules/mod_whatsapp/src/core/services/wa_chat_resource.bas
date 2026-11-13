Imports mod_tobject
Imports mod_wa_api_result
Imports mod_wa_dto_chat

Namespace mod_wa_service

   ' wa.Chat.*
   Class WaChatResource
      Inherits WaResource

      Sub New(pService As WaService)
         MyBase.New(pService)
      End Sub

      Function Find(pReq As WaFindFilterRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "listar chats")
         Find = me.Client().ChatFind(pReq)
      End Function

      Function FindMessages(pReq As WaFindFilterRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "buscar mensagens")
         FindMessages = me.Client().ChatFindMessages(pReq)
      End Function

      Function FindContacts(pReq As WaFindFilterRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "buscar contatos no chat")
         FindContacts = me.Client().ChatFindContacts(pReq)
      End Function

      Function Archive(pReq As WaChatActionRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "arquivar chat")
         Archive = me.Client().ChatArchive(pReq)
      End Function

      Function Pin(pReq As WaChatActionRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "fixar chat")
         Pin = me.Client().ChatPin(pReq)
      End Function

      Function Unpin(pReq As WaChatActionRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "desafixar chat")
         Unpin = me.Client().ChatUnpin(pReq)
      End Function

      Function Mute(pReq As WaChatActionRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "silenciar chat")
         Mute = me.Client().ChatMute(pReq)
      End Function

      Function Unmute(pReq As WaChatActionRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageChats, "ativar som do chat")
         Unmute = me.Client().ChatUnmute(pReq)
      End Function

      Function CheckNumbers(pReq As WaCheckNumbersRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanValidatePhone, "verificar números no WhatsApp")
         CheckNumbers = me.Client().ChatCheckNumbers(pReq)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
