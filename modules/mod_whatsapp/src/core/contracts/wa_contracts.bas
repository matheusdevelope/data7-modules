Imports mod_tobject
Imports mod_wa_capabilities
Imports mod_wa_message
Imports mod_wa_instance
Imports mod_wa_contact
Imports mod_wa_send_result
Imports mod_wa_api_result
Imports mod_wa_dto_instance
Imports mod_wa_dto_send
Imports mod_wa_dto_message
Imports mod_wa_dto_user
Imports mod_wa_dto_chat
Imports mod_wa_dto_group

Namespace mod_wa_contracts

   ' Contrato Strategy do motor WhatsApp.
   ' Defaults Overridable lançam NotSupported — WaService valida Capabilities antes.
      MustInherit Class WaClient
      Inherits TTObject

      Private _formatter As WaMessageFormatter

      Sub New()
         MyBase.New()
      End Sub

      MustOverride Overridable Function GetName() As String
      End Function

      MustOverride Overridable Function GetCapabilities() As WaCapabilities
      End Function

      Overridable Function Online() As Boolean
         Online = True
      End Function

      Overridable Function GetFormatter() As WaMessageFormatter
         If me._formatter = NULL Then
            me._formatter = WaMessageFormatter.CreateDefault()
         End If
         GetFormatter = me._formatter
      End Function

      Function ResolveFormatter(pMessage As WaMessage) As WaMessageFormatter
         If Assigned(pMessage) Then
            If Assigned(pMessage.Formatter) Then
               ResolveFormatter = pMessage.Formatter
               Exit Function
            End If
         End If
         ResolveFormatter = me.GetFormatter()
      End Function

      ' --- Envio de alto nível (WaMessage) ---
      MustOverride Overridable Function SendMessage(pMessage As WaMessage) As WaSendResult
      End Function

      ' --- Instance ---
      Overridable Function InstanceCreate(pReq As WaInstanceCreateRequest) As WaApiResult
         Throw New Exception("InstanceCreate não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceAll() As WaInstanceList
         Throw New Exception("InstanceAll não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceInfo(pId As String) As WaInstance
         Throw New Exception("InstanceInfo não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceConnect(pId As String = "") As WaApiResult
         Throw New Exception("InstanceConnect não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceStatus(pId As String = "") As WaApiResult
         Throw New Exception("InstanceStatus não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceRestart(pId As String = "") As WaApiResult
         Throw New Exception("InstanceRestart não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceLogout(pId As String = "") As WaApiResult
         Throw New Exception("InstanceLogout não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceDelete(pId As String = "") As WaApiResult
         Throw New Exception("InstanceDelete não suportado por " + me.GetName())
      End Function

      Overridable Function InstanceQr(pId As String = "") As WaApiResult
         Throw New Exception("InstanceQr não suportado por " + me.GetName())
      End Function

      ' --- Send (DTOs tipados) ---
      Overridable Function SendText(pReq As WaSendTextRequest) As WaApiResult
         Throw New Exception("SendText não suportado por " + me.GetName())
      End Function

      Overridable Function SendMedia(pReq As WaSendMediaRequest) As WaApiResult
         Throw New Exception("SendMedia não suportado por " + me.GetName())
      End Function

      Overridable Function SendButtons(pReq As WaSendButtonsRequest) As WaApiResult
         Throw New Exception("SendButtons não suportado por " + me.GetName())
      End Function

      Overridable Function SendPoll(pReq As WaSendPollRequest) As WaApiResult
         Throw New Exception("SendPoll não suportado por " + me.GetName())
      End Function

      Overridable Function SendList(pReq As WaSendListRequest) As WaApiResult
         Throw New Exception("SendList não suportado por " + me.GetName())
      End Function

      Overridable Function SendLocation(pReq As WaSendLocationRequest) As WaApiResult
         Throw New Exception("SendLocation não suportado por " + me.GetName())
      End Function

      Overridable Function SendContact(pReq As WaSendContactRequest) As WaApiResult
         Throw New Exception("SendContact não suportado por " + me.GetName())
      End Function

      Overridable Function SendSticker(pReq As WaSendStickerRequest) As WaApiResult
         Throw New Exception("SendSticker não suportado por " + me.GetName())
      End Function

      ' --- Message ops ---
      Overridable Function MessageReact(pReq As WaMessageReactRequest) As WaApiResult
         Throw New Exception("MessageReact não suportado por " + me.GetName())
      End Function

      Overridable Function MessageMarkRead(pReq As WaMessageMarkReadRequest) As WaApiResult
         Throw New Exception("MessageMarkRead não suportado por " + me.GetName())
      End Function

      Overridable Function MessageDelete(pReq As WaMessageDeleteRequest) As WaApiResult
         Throw New Exception("MessageDelete não suportado por " + me.GetName())
      End Function

      Overridable Function MessageEdit(pReq As WaMessageEditRequest) As WaApiResult
         Throw New Exception("MessageEdit não suportado por " + me.GetName())
      End Function

      Overridable Function MessagePresence(pReq As WaMessagePresenceRequest) As WaApiResult
         Throw New Exception("MessagePresence não suportado por " + me.GetName())
      End Function

      ' --- User ---
      Overridable Function UserInfo(pReq As WaUserLookupRequest) As WaApiResult
         Throw New Exception("UserInfo não suportado por " + me.GetName())
      End Function

      Overridable Function UserCheck(pReq As WaUserLookupRequest) As WaApiResult
         Throw New Exception("UserCheck não suportado por " + me.GetName())
      End Function

      Overridable Function UserContacts(pInstance As String = "") As WaContactList
         Throw New Exception("UserContacts não suportado por " + me.GetName())
      End Function

      Overridable Function UserAvatar(pPhone As String, pInstance As String = "") As WaApiResult
         Throw New Exception("UserAvatar não suportado por " + me.GetName())
      End Function

      Overridable Function UserBlock(pReq As WaUserBlockRequest) As WaApiResult
         Throw New Exception("UserBlock não suportado por " + me.GetName())
      End Function

      Overridable Function UserUnblock(pReq As WaUserBlockRequest) As WaApiResult
         Throw New Exception("UserUnblock não suportado por " + me.GetName())
      End Function

      Overridable Function UserSetProfileName(pReq As WaUserProfileNameRequest) As WaApiResult
         Throw New Exception("UserSetProfileName não suportado por " + me.GetName())
      End Function

      Overridable Function UserSetProfileStatus(pReq As WaUserProfileStatusRequest) As WaApiResult
         Throw New Exception("UserSetProfileStatus não suportado por " + me.GetName())
      End Function

      Overridable Function ValidatePhone(pInstance As String, pPhone As String) As Boolean
         Throw New Exception("ValidatePhone não suportado por " + me.GetName())
      End Function

      Overridable Function GetContact(pInstance As String, pPhone As String) As WaContact
         Throw New Exception("GetContact não suportado por " + me.GetName())
      End Function

      Overridable Function ListContacts(pInstance As String) As WaContactList
         ListContacts = me.UserContacts(pInstance)
      End Function

      Overridable Function ListInstances() As WaInstanceList
         ListInstances = me.InstanceAll()
      End Function

      Overridable Function GetInstance(pId As String) As WaInstance
         GetInstance = me.InstanceInfo(pId)
      End Function

      ' --- Chat ---
      Overridable Function ChatFind(pReq As WaFindFilterRequest) As WaApiResult
         Throw New Exception("ChatFind não suportado por " + me.GetName())
      End Function

      Overridable Function ChatFindMessages(pReq As WaFindFilterRequest) As WaApiResult
         Throw New Exception("ChatFindMessages não suportado por " + me.GetName())
      End Function

      Overridable Function ChatFindContacts(pReq As WaFindFilterRequest) As WaApiResult
         Throw New Exception("ChatFindContacts não suportado por " + me.GetName())
      End Function

      Overridable Function ChatArchive(pReq As WaChatActionRequest) As WaApiResult
         Throw New Exception("ChatArchive não suportado por " + me.GetName())
      End Function

      Overridable Function ChatPin(pReq As WaChatActionRequest) As WaApiResult
         Throw New Exception("ChatPin não suportado por " + me.GetName())
      End Function

      Overridable Function ChatUnpin(pReq As WaChatActionRequest) As WaApiResult
         Throw New Exception("ChatUnpin não suportado por " + me.GetName())
      End Function

      Overridable Function ChatMute(pReq As WaChatActionRequest) As WaApiResult
         Throw New Exception("ChatMute não suportado por " + me.GetName())
      End Function

      Overridable Function ChatUnmute(pReq As WaChatActionRequest) As WaApiResult
         Throw New Exception("ChatUnmute não suportado por " + me.GetName())
      End Function

      Overridable Function ChatCheckNumbers(pReq As WaCheckNumbersRequest) As WaApiResult
         Throw New Exception("ChatCheckNumbers não suportado por " + me.GetName())
      End Function

      ' --- Group ---
      Overridable Function GroupCreate(pReq As WaGroupCreateRequest) As WaApiResult
         Throw New Exception("GroupCreate não suportado por " + me.GetName())
      End Function

      Overridable Function GroupList(pInstance As String = "") As WaApiResult
         Throw New Exception("GroupList não suportado por " + me.GetName())
      End Function

      Overridable Function GroupInfo(pReq As WaGroupInfoRequest) As WaApiResult
         Throw New Exception("GroupInfo não suportado por " + me.GetName())
      End Function

      Overridable Function GroupParticipants(pReq As WaGroupInfoRequest) As WaApiResult
         Throw New Exception("GroupParticipants não suportado por " + me.GetName())
      End Function

      Overridable Function GroupUpdateParticipant(pReq As WaGroupParticipantRequest) As WaApiResult
         Throw New Exception("GroupUpdateParticipant não suportado por " + me.GetName())
      End Function

      Overridable Function GroupInviteLink(pReq As WaGroupInviteRequest) As WaApiResult
         Throw New Exception("GroupInviteLink não suportado por " + me.GetName())
      End Function

      Overridable Function GroupLeave(pReq As WaGroupInfoRequest) As WaApiResult
         Throw New Exception("GroupLeave não suportado por " + me.GetName())
      End Function

      Overridable Function GroupUpdateSubject(pReq As WaGroupUpdateTextRequest) As WaApiResult
         Throw New Exception("GroupUpdateSubject não suportado por " + me.GetName())
      End Function

      Overridable Function GroupUpdateDescription(pReq As WaGroupUpdateTextRequest) As WaApiResult
         Throw New Exception("GroupUpdateDescription não suportado por " + me.GetName())
      End Function

      Overrides Sub Dispose()
         If Assigned(me._formatter) Then
            me._formatter.Free()
            me._formatter = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
