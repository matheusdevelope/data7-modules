Imports mod_tobject
Imports mod_wa_api_result
Imports mod_wa_dto_message

Namespace mod_wa_service

   ' wa.Message.* — operações sobre mensagens já enviadas
   Class WaMessageResource
      Inherits WaResource

      Sub New(pService As WaService)
         MyBase.New(pService)
      End Sub

      Function React(pReq As WaMessageReactRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageMessages, "reagir a mensagem")
         React = me.Client().MessageReact(pReq)
      End Function

      Function MarkRead(pReq As WaMessageMarkReadRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageMessages, "marcar mensagem como lida")
         MarkRead = me.Client().MessageMarkRead(pReq)
      End Function

      Function Delete(pReq As WaMessageDeleteRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageMessages, "apagar mensagem")
         Delete = me.Client().MessageDelete(pReq)
      End Function

      Function Edit(pReq As WaMessageEditRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageMessages, "editar mensagem")
         Edit = me.Client().MessageEdit(pReq)
      End Function

      Function Presence(pReq As WaMessagePresenceRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageMessages, "enviar presence")
         Presence = me.Client().MessagePresence(pReq)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
