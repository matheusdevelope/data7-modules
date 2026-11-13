Imports mod_tobject
Imports mod_wa_contact
Imports mod_wa_api_result
Imports mod_wa_dto_user

Namespace mod_wa_service

   ' wa.User.*
   Class WaUserResource
      Inherits WaResource

      Sub New(pService As WaService)
         MyBase.New(pService)
      End Sub

      Function Contacts(pInstance As String = "") As WaContactList
         me.EnsureCapability(me.Caps().CanManageContacts, "listar contatos")
         Contacts = me.Client().UserContacts(pInstance)
      End Function

      Function Info(pReq As WaUserLookupRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageContacts, "info de usuário")
         Info = me.Client().UserInfo(pReq)
      End Function

      Function Info(pInstance As String, pPhone As String) As WaContact
         me.EnsureCapability(me.Caps().CanManageContacts, "obter contato")
         Info = me.Client().GetContact(pInstance, pPhone)
      End Function

      Function Check(pReq As WaUserLookupRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanValidatePhone, "checar usuário no WhatsApp")
         Check = me.Client().UserCheck(pReq)
      End Function

      Function ValidatePhone(pInstance As String, pPhone As String) As Boolean
         me.EnsureCapability(me.Caps().CanValidatePhone, "validar telefone no provider")
         ValidatePhone = me.Client().ValidatePhone(pInstance, pPhone)
      End Function

      Function Avatar(pPhone As String, pInstance As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageContacts, "avatar do usuário")
         Avatar = me.Client().UserAvatar(pPhone, pInstance)
      End Function

      Function Block(pReq As WaUserBlockRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageContacts, "bloquear usuário")
         Block = me.Client().UserBlock(pReq)
      End Function

      Function Unblock(pReq As WaUserBlockRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageContacts, "desbloquear usuário")
         Unblock = me.Client().UserUnblock(pReq)
      End Function

      Function SetProfileName(pReq As WaUserProfileNameRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageContacts, "atualizar nome do perfil")
         SetProfileName = me.Client().UserSetProfileName(pReq)
      End Function

      Function SetProfileStatus(pReq As WaUserProfileStatusRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageContacts, "atualizar status do perfil")
         SetProfileStatus = me.Client().UserSetProfileStatus(pReq)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
