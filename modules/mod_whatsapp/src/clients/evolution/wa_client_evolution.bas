Imports Collections
Imports mod_wa_contracts
Imports mod_wa_capabilities
Imports mod_wa_message
Imports mod_wa_attachment
Imports mod_wa_send_result
Imports mod_wa_instance
Imports mod_wa_contact
Imports mod_wa_http
Imports mod_wa_auth
Imports mod_wa_api_result
Imports mod_wa_evolution_options
Imports mod_wa_dto_instance
Imports mod_wa_dto_send
Imports mod_wa_dto_message
Imports mod_wa_dto_user
Imports mod_wa_dto_chat
Imports mod_wa_dto_group

Namespace mod_wa_client_evolution

   ' Client Evolution API v2.3 — REST puro, apikey via header (WaAuthApiKey).
   ' Todos os endpoints usam o padrão /{recurso}/{instance} com apikey no header.
   Class WaClientEvolution
      Inherits WaClient

      Private _options As WaEvolutionOptions
      Private _http As WaHttp
      Private _capabilities As WaCapabilities
      Private _ownsOptions As Boolean

      Sub New(pOptions As WaEvolutionOptions, pOwnsOptions As Boolean = False)
         MyBase.New()
         If pOptions = NULL Then
            Throw New Exception("WaClientEvolution requer WaEvolutionOptions")
         End If
         pOptions.Validate()
         me._options = pOptions
         me._ownsOptions = pOwnsOptions
         me._capabilities = WaCapabilities.FullApi()
         me._capabilities.NeedsSender = True
         me._http = New WaHttp(pOptions.Host, New WaAuthApiKey(pOptions.Token), True)
      End Sub

      Overrides Function GetName() As String
         GetName = "Evolution"
      End Function

      Overrides Function GetCapabilities() As WaCapabilities
         GetCapabilities = me._capabilities
      End Function

      Overrides Function GetFormatter() As WaMessageFormatter
         GetFormatter = me._options.Formatter
      End Function

      Overrides Function Online() As Boolean
         Try
            me._http.Gett("/")
            Online = me._http.StatusCode() = 200
         Catch ex As Exception
            Return False
         End Try
      End Function

      ' --- Helpers ---

      Private Function ResolveInstance(pOverride As String) As String
         If pOverride.Trim() <> "" Then
            ResolveInstance = pOverride.Trim()
         Else
            ResolveInstance = me._options.Instance.Trim()
         End If
      End Function

      Private Function HttpResult() As WaApiResult
         Dim code As Integer = me._http.StatusCode()
         Dim raw As String = me._http.ResponseText()
         If me._http.IsSuccess() Then
            HttpResult = WaApiResult.Ok(me.GetName(), raw, code)
         Else
            HttpResult = WaApiResult.Fail(me.GetName(), "HTTP " + code.ToString(), code, raw)
         End If
      End Function

      ' --- Instance ---

      Overrides Function InstanceCreate(pReq As WaInstanceCreateRequest) As WaApiResult
         Try
            me._http.Post("/instance/create", pReq.ToJsonEvolution())
            InstanceCreate = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function InstanceAll() As WaInstanceList
         Dim _list As New WaInstanceList()
         me._http.Gett("/instance/fetchInstances")
         Dim _response As TJSONArray = me._http.ResponseAsArray()
         Dim i As Integer
         For i = 0 To _response.Length() - 1
            Dim _row As TJSONObject = _response.GetJSONObject(i)
            Dim _item As New WaInstance()
            _item.Id = _row.GetString("name")
            _item.Name = _row.GetString("name")
            _item.Connected = UCase(_row.GetString("connectionStatus")) = "OPEN"
            _item.Authenticated = _item.Connected
            _item.Phone = _row.GetString("ownerJid").Split("@")[0]
            _item.ProfileName = _row.GetString("profileName")
            _item.ProfileImageUrl = _row.GetString("profilePicUrl")
            _list.Add(_item)
            _row.Free()
         Next
         _response.Free()
         InstanceAll = _list
      End Function

      Overrides Function InstanceInfo(pId As String) As WaInstance
         Dim _id As String = me.ResolveInstance(pId)
         Dim _list As WaInstanceList = me.InstanceAll()
         Dim _found As WaInstance
         Dim i As Integer
         For i = 0 To _list.Count() - 1
            Dim _item As WaInstance = _list.Take(i)
            If UCase(_item.Id) = UCase(_id) Or UCase(_item.Name) = UCase(_id) Then
               _found = New WaInstance()
               _found.Id = _item.Id
               _found.Name = _item.Name
               _found.Phone = _item.Phone
               _found.Connected = _item.Connected
               _found.Authenticated = _item.Authenticated
               _found.ProfileName = _item.ProfileName
               _found.ProfileImageUrl = _item.ProfileImageUrl
               Exit For
            End If
         Next
         _list.Free()

         If Assigned(_found) Then
            InstanceInfo = _found
            Exit Function
         End If

         me._http.Gett("/instance/connectionState/" + _id)
         Dim _json As TJSONObject = me._http.ResponseAsJson()
         Dim _result As New WaInstance()
         _result.Id = _id
         _result.Name = _id
         If _json.Has("instance") Then
            Dim _inner As TJSONObject = _json.GetJSONObject("instance")
            _result.Connected = UCase(_inner.GetString("state")) = "OPEN"
            _result.Authenticated = _result.Connected
            _inner.Free()
         End If
         _json.Free()
         InstanceInfo = _result
      End Function

      Overrides Function InstanceConnect(pId As String = "") As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pId)
            me._http.Gett("/instance/connect/" + _instance)
            InstanceConnect = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function InstanceStatus(pId As String = "") As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pId)
            me._http.Gett("/instance/connectionState/" + _instance)
            InstanceStatus = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function InstanceRestart(pId As String = "") As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pId)
            me._http.Post("/instance/restart/" + _instance, "{}")
            InstanceRestart = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function InstanceLogout(pId As String = "") As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pId)
            me._http.Deletee("/instance/logout/" + _instance)
            InstanceLogout = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function InstanceDelete(pId As String = "") As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pId)
            me._http.Deletee("/instance/delete/" + _instance)
            InstanceDelete = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      ' --- Send (DTOs tipados) ---

      Overrides Function SendText(pReq As WaSendTextRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendText/" + _instance, pReq.ToJsonEvolution())
            SendText = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function SendMedia(pReq As WaSendMediaRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendMedia/" + _instance, pReq.ToJsonEvolution())
            SendMedia = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function SendButtons(pReq As WaSendButtonsRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendButtons/" + _instance, pReq.ToJsonEvolution())
            SendButtons = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function SendPoll(pReq As WaSendPollRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendPoll/" + _instance, pReq.ToJsonEvolution())
            SendPoll = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function SendList(pReq As WaSendListRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendList/" + _instance, pReq.ToJsonEvolution())
            SendList = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function SendLocation(pReq As WaSendLocationRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendLocation/" + _instance, pReq.ToJsonEvolution())
            SendLocation = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function SendContact(pReq As WaSendContactRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendContact/" + _instance, pReq.ToJsonEvolution())
            SendContact = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function SendSticker(pReq As WaSendStickerRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pReq.Instance)
            me._http.Post("/message/sendSticker/" + _instance, pReq.ToJsonEvolution())
            SendSticker = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      ' --- Envio de alto nível (WaMessage) ---

      Overrides Function SendMessage(pMessage As WaMessage) As WaSendResult
         Dim _instance As String = me.ResolveInstance(pMessage.Sender)
         If _instance = "" Then
            SendMessage = WaSendResult.Fail(me.GetName(), pMessage.Recipient, "Instance/Sender é obrigatório na Evolution")
            Exit Function
         End If

         Try
            If me._options.ValidatePhoneOnProvider Then
               me.ValidatePhone(_instance, pMessage.Recipient)
            End If
            me.DispatchPlan(_instance, pMessage)
            SendMessage = WaSendResult.Ok(me.GetName(), pMessage.Recipient)
         Catch ex As Exception
            Return WaSendResult.Fail(me.GetName(), pMessage.Recipient, ex._GetMessage())
         End Try
      End Function

      Private Sub DispatchPlan(pInstance As String, pMessage As WaMessage)
         Dim _plan As WaSendPlan = me.ResolveFormatter(pMessage).BuildPlan(pMessage)
         If Not Assigned(_plan) Then
            Exit Sub
         End If
         Try
            Dim i As Integer
            For i = 0 To _plan.Count() - 1
               Dim _step As WaSendStep = _plan.Take(i)
               If _step.IsMedia Then
                  me.SendMediaInternal(pInstance, pMessage.Recipient, _step.Attachment, _step.Text)
               Else
                  me.SendTextInternal(pInstance, pMessage.Recipient, _step.Text)
               End If
            Next
         Catch ex As Exception
            _plan.Free()
            Throw New Exception(ex._GetMessage())
         End Try
         _plan.Free()
      End Sub

      Private Sub SendTextInternal(pInstance As String, pPhone As String, pText As String)
         If pText = "" Then
            Exit Sub
         End If
         Dim _req As New WaSendTextRequest()
         _req.Number = pPhone
         _req.Text = pText
         _req.Instance = pInstance
         Dim _result As WaApiResult = me.SendText(_req)
         _req.Free()
         If Not _result.Success Then
            Dim _msg As String = _result.Message
            _result.Free()
            Throw New Exception(_msg)
         End If
         _result.Free()
      End Sub

      Private Sub SendMediaInternal(pInstance As String, pPhone As String, pAttachment As WaAttachment, pCaption As String)
         Dim _req As New WaSendMediaRequest()
         _req.Number = pPhone
         _req.Instance = pInstance
         _req.MediaType = "document"
         _req.MimeType = pAttachment.MimeType
         _req.Caption = pCaption.Trim()
         _req.FileName = pAttachment.Filename
         _req.Media = pAttachment.ToBase64()
         Dim _result As WaApiResult = me.SendMedia(_req)
         _req.Free()
         If Not _result.Success Then
            Dim _msg As String = _result.Message
            _result.Free()
            Throw New Exception(_msg)
         End If
         _result.Free()
      End Sub

      ' --- Message ops ---

      Overrides Function MessageReact(pReq As WaMessageReactRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/message/sendReaction/" + _instance, pReq.ToJsonEvolution())
            MessageReact = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function MessageMarkRead(pReq As WaMessageMarkReadRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/markMessageAsRead/" + _instance, pReq.ToJsonEvolution())
            MessageMarkRead = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function MessageDelete(pReq As WaMessageDeleteRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Deletee("/chat/deleteMessageForEveryone/" + _instance, pReq.ToJsonEvolution())
            MessageDelete = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function MessageEdit(pReq As WaMessageEditRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/updateMessage/" + _instance, pReq.ToJsonEvolution())
            MessageEdit = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function MessagePresence(pReq As WaMessagePresenceRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/sendPresence/" + _instance, pReq.ToJsonEvolution())
            MessagePresence = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      ' --- User ---

      Overrides Function UserInfo(pReq As WaUserLookupRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/whatsappNumbers/" + _instance, pReq.ToJsonEvolution())
            UserInfo = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function UserCheck(pReq As WaUserLookupRequest) As WaApiResult
         UserCheck = me.UserInfo(pReq)
      End Function

      Overrides Function UserContacts(pInstance As String = "") As WaContactList
         Dim _list As New WaContactList()
         Dim _instance As String = me.ResolveInstance(pInstance)
         Try
            me._http.Post("/chat/findContacts/" + _instance, "{""where"":{}}")
            If me._http.IsSuccess() Then
               Dim _arr As TJSONArray = me._http.ResponseAsArray()
               Dim i As Integer
               For i = 0 To _arr.Length() - 1
                  Dim _row As TJSONObject = _arr.GetJSONObject(i)
                  Dim _contact As New WaContact()
                  _contact.Id = _row.GetString("id")
                  _contact.Phone = _row.GetString("id").Split("@")[0]
                  _contact.Name = _row.GetString("pushName")
                  _contact.ProfileImageUrl = _row.GetString("profilePicUrl")
                  _contact.Exists = True
                  _list.Add(_contact)
                  _row.Free()
               Next
               _arr.Free()
            End If
            UserContacts = _list
         Catch ex As Exception
            Return _list
         End Try
      End Function

      Overrides Function UserAvatar(pPhone As String, pInstance As String = "") As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pInstance)
            me._http.Post("/chat/fetchProfilePictureUrl/" + _instance, "{""number"":" + pPhone.Quoted() + "}")
            UserAvatar = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function UserBlock(pReq As WaUserBlockRequest) As WaApiResult
         UserBlock = me.SetBlockStatus(pReq.Number, "block")
      End Function

      Overrides Function UserUnblock(pReq As WaUserBlockRequest) As WaApiResult
         UserUnblock = me.SetBlockStatus(pReq.Number, "unblock")
      End Function

      Private Function SetBlockStatus(pNumber As String, pStatus As String) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            Dim _body As String = "{""number"":" + pNumber.Quoted() + ",""status"":" + pStatus.Quoted() + "}"
            me._http.Post("/message/updateBlockStatus/" + _instance, _body)
            SetBlockStatus = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function UserSetProfileName(pReq As WaUserProfileNameRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/updateProfileName/" + _instance, pReq.ToJson())
            UserSetProfileName = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function UserSetProfileStatus(pReq As WaUserProfileStatusRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/updateProfileStatus/" + _instance, pReq.ToJson())
            UserSetProfileStatus = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function ValidatePhone(pInstance As String, pPhone As String) As Boolean
         Dim _instance As String = me.ResolveInstance(pInstance)
         Dim _body As String = "{""numbers"":[" + pPhone.Quoted() + "]}"
         me._http.Post("/chat/whatsappNumbers/" + _instance, _body)
         Dim _arr As TJSONArray = me._http.ResponseAsArray()
         If _arr.Length() = 0 Then
            _arr.Free()
            Throw New Exception("Número inválido no WhatsApp: " + pPhone)
         End If
         Dim _contact As TJSONObject = _arr.GetJSONObject(0)
         Dim _exists As Boolean = _contact.GetBoolean("exists")
         _contact.Free()
         _arr.Free()
         If Not _exists Then
            Throw New Exception("Número inválido no WhatsApp: " + pPhone)
         End If
         ValidatePhone = True
      End Function

      Overrides Function GetContact(pInstance As String, pPhone As String) As WaContact
         Dim _instance As String = me.ResolveInstance(pInstance)
         Dim _body As String = "{""numbers"":[" + pPhone.Quoted() + "]}"
         me._http.Post("/chat/whatsappNumbers/" + _instance, _body)
         Dim _arr As TJSONArray = me._http.ResponseAsArray()
         Dim _contact As New WaContact()
         _contact.Phone = pPhone
         If _arr.Length() > 0 Then
            Dim _row As TJSONObject = _arr.GetJSONObject(0)
            _contact.Exists = _row.GetBoolean("exists")
            _contact.Id = _row.GetString("jid")
            _contact.Name = _row.GetString("name")
            _row.Free()
         End If
         _arr.Free()
         GetContact = _contact
      End Function

      ' --- Chat ---

      Overrides Function ChatFind(pReq As WaFindFilterRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/findChats/" + _instance, pReq.ToJson())
            ChatFind = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function ChatFindMessages(pReq As WaFindFilterRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/findMessages/" + _instance, pReq.ToJson())
            ChatFindMessages = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function ChatFindContacts(pReq As WaFindFilterRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/findContacts/" + _instance, pReq.ToJson())
            ChatFindContacts = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function ChatArchive(pReq As WaChatActionRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/archiveChat/" + _instance, pReq.ToJsonEvolution())
            ChatArchive = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      ' Pin/Mute não existem na Evolution API v2 (recursos exclusivos da EvolutionGO).
      Overrides Function ChatPin(pReq As WaChatActionRequest) As WaApiResult
         ChatPin = WaApiResult.Fail(me.GetName(), "ChatPin não disponível na Evolution API v2")
      End Function

      Overrides Function ChatUnpin(pReq As WaChatActionRequest) As WaApiResult
         ChatUnpin = WaApiResult.Fail(me.GetName(), "ChatUnpin não disponível na Evolution API v2")
      End Function

      Overrides Function ChatMute(pReq As WaChatActionRequest) As WaApiResult
         ChatMute = WaApiResult.Fail(me.GetName(), "ChatMute não disponível na Evolution API v2")
      End Function

      Overrides Function ChatUnmute(pReq As WaChatActionRequest) As WaApiResult
         ChatUnmute = WaApiResult.Fail(me.GetName(), "ChatUnmute não disponível na Evolution API v2")
      End Function

      Overrides Function ChatCheckNumbers(pReq As WaCheckNumbersRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/chat/whatsappNumbers/" + _instance, pReq.ToJsonEvolution())
            ChatCheckNumbers = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      ' --- Group ---

      Overrides Function GroupCreate(pReq As WaGroupCreateRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/group/create/" + _instance, pReq.ToJsonEvolution())
            GroupCreate = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupList(pInstance As String = "") As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance(pInstance)
            me._http.Gett("/group/fetchAllGroups/" + _instance + "?getParticipants=false")
            GroupList = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupInfo(pReq As WaGroupInfoRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Gett("/group/findGroupInfos/" + _instance + "?groupJid=" + pReq.GroupJid)
            GroupInfo = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupParticipants(pReq As WaGroupInfoRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Gett("/group/participants/" + _instance + "?groupJid=" + pReq.GroupJid)
            GroupParticipants = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupUpdateParticipant(pReq As WaGroupParticipantRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/group/updateParticipant/" + _instance + "?groupJid=" + pReq.GroupJid, pReq.ToJsonEvolution())
            GroupUpdateParticipant = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupInviteLink(pReq As WaGroupInviteRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Gett("/group/inviteCode/" + _instance + "?groupJid=" + pReq.GroupJid)
            GroupInviteLink = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupLeave(pReq As WaGroupInfoRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Deletee("/group/leaveGroup/" + _instance + "?groupJid=" + pReq.GroupJid)
            GroupLeave = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupUpdateSubject(pReq As WaGroupUpdateTextRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            me._http.Post("/group/updateGroupSubject/" + _instance + "?groupJid=" + pReq.GroupJid, pReq.ToJsonEvolution())
            GroupUpdateSubject = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Function GroupUpdateDescription(pReq As WaGroupUpdateTextRequest) As WaApiResult
         Try
            Dim _instance As String = me.ResolveInstance("")
            Dim _body As String = "{""description"":" + pReq.Text.Quoted() + "}"
            me._http.Post("/group/updateGroupDescription/" + _instance + "?groupJid=" + pReq.GroupJid, _body)
            GroupUpdateDescription = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Overrides Sub Dispose()
         If Assigned(me._http) Then
            me._http.Free()
            me._http = NULL
         End If
         If Assigned(me._capabilities) Then
            me._capabilities.Free()
            me._capabilities = NULL
         End If
         If me._ownsOptions And Assigned(me._options) Then
            me._options.Free()
         End If
         me._options = NULL
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
