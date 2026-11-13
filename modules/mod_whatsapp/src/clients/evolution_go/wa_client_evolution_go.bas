Imports Collections
Imports mod_tobject
Imports mod_wa_contracts
Imports mod_wa_capabilities
Imports mod_wa_message
Imports mod_wa_attachment
Imports mod_wa_send_result
Imports mod_wa_api_result
Imports mod_wa_instance
Imports mod_wa_contact
Imports mod_wa_http
Imports mod_wa_auth
Imports mod_wa_evolution_go_options
Imports mod_wa_dto_instance
Imports mod_wa_dto_send
Imports mod_wa_dto_message
Imports mod_wa_dto_user
Imports mod_wa_dto_chat
Imports mod_wa_dto_group

Namespace mod_wa_client_evolution_go

   ' Cliente FullApi para o Evolution GO (Baileys em Go).
   ' Auth dupla: MasterToken (gestão de instâncias) / InstanceToken (operações da instância).
   Class WaClientEvolutionGo
      Inherits WaClient

      Private _options As WaEvolutionGoOptions
      Private _http As WaHttp
      Private _auth As WaAuthDualToken
      Private _capabilities As WaCapabilities
      Private _ownsOptions As Boolean

      Sub New(pOptions As WaEvolutionGoOptions, pOwnsOptions As Boolean = False)
         MyBase.New()
         If pOptions = NULL Then
            Throw New Exception("WaClientEvolutionGo requer WaEvolutionGoOptions")
         End If
         pOptions.Validate()
         me._options = pOptions
         me._ownsOptions = pOwnsOptions
         me._capabilities = WaCapabilities.FullApi()
         me._auth = New WaAuthDualToken(pOptions.MasterToken, pOptions.InstanceToken)
         me._http = New WaHttp(pOptions.Host, me._auth, True)
      End Sub

      Overrides Function GetName() As String
         GetName = "EvolutionGO"
      End Function

      Overrides Function GetCapabilities() As WaCapabilities
         GetCapabilities = me._capabilities
      End Function

      Overrides Function GetFormatter() As WaMessageFormatter
         GetFormatter = me._options.Formatter
      End Function

      Overrides Function Online() As Boolean
         Try
            me.UseMaster()
            me._http.Gett("/instance/all")
            Online = me._http.IsSuccess()
         Catch ex As Exception
            Return False
         End Try
      End Function

      ' ======================= Helpers =======================

      Private Function ResolveInstance(pOverride As String) As String
         If pOverride.Trim() <> "" Then
            ResolveInstance = pOverride.Trim()
         Else
            ResolveInstance = me._options.Instance.Trim()
         End If
      End Function

      Private Function HttpResult() As WaApiResult
         If me._http.IsSuccess() Then
            HttpResult = WaApiResult.Ok(me.GetName(), me._http.ResponseText(), me._http.StatusCode())
         Else
            HttpResult = WaApiResult.Fail(me.GetName(), "Falha na requisição HTTP", me._http.StatusCode(), me._http.ResponseText())
         End If
      End Function

      Private Sub UseMaster()
         me._auth.UseMaster()
      End Sub

      Private Sub UseInstanceToken()
         me._auth.UseInstance()
      End Sub

      Private Function DoGet(pPath As String, pMaster As Boolean = False) As WaApiResult
         Try
            If pMaster Then
               me.UseMaster()
            Else
               me.UseInstanceToken()
            End If
            me._http.Gett(pPath)
            DoGet = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Private Function DoPost(pPath As String, pBody As String, pMaster As Boolean = False) As WaApiResult
         Try
            If pMaster Then
               me.UseMaster()
            Else
               me.UseInstanceToken()
            End If
            me._http.Post(pPath, pBody)
            DoPost = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      Private Function DoDelete(pPath As String, pBody As String = "", pMaster As Boolean = False) As WaApiResult
         Try
            If pMaster Then
               me.UseMaster()
            Else
               me.UseInstanceToken()
            End If
            me._http.Deletee(pPath, pBody)
            DoDelete = me.HttpResult()
         Catch ex As Exception
            Return WaApiResult.Fail(me.GetName(), ex._GetMessage())
         End Try
      End Function

      ' ======================= Send de alto nível (WaMessage) =======================

      Overrides Function SendMessage(pMessage As WaMessage) As WaSendResult
         Dim _instance As String = me.ResolveInstance(pMessage.Sender)
         Try
            If me._options.ValidatePhoneOnProvider Then
               me.ValidatePhone(_instance, pMessage.Recipient)
            End If
            me.DispatchPlan(pMessage)
            SendMessage = WaSendResult.Ok(me.GetName(), pMessage.Recipient)
         Catch ex As Exception
            Return WaSendResult.Fail(me.GetName(), pMessage.Recipient, ex._GetMessage())
         End Try
      End Function

      Private Sub DispatchPlan(pMessage As WaMessage)
         Dim _plan As WaSendPlan = me.ResolveFormatter(pMessage).BuildPlan(pMessage)
         If Not Assigned(_plan) Then
            Exit Sub
         End If
         Try
            Dim i As Integer
            For i = 0 To _plan.Count() - 1
               Dim _step As WaSendStep = _plan.Take(i)
               If _step.IsMedia Then
                  me.SendPlainMedia(pMessage.Recipient, _step.Attachment, _step.Text)
               Else
                  me.SendPlainText(pMessage.Recipient, _step.Text)
               End If
            Next
         Catch ex As Exception
            _plan.Free()
            Throw New Exception(ex._GetMessage())
         End Try
         _plan.Free()
      End Sub

      Private Sub SendPlainText(pPhone As String, pText As String)
         If pText = "" Then
            Exit Sub
         End If
         Dim _req As New WaSendTextRequest()
         _req.Number = pPhone
         _req.Text = pText
         Dim _result As WaApiResult = me.SendText(_req)
         _req.Free()
         If Not _result.Success Then
            Dim _msg As String = _result.Message
            _result.Free()
            Throw New Exception(_msg)
         End If
         _result.Free()
      End Sub

      Private Sub SendPlainMedia(pPhone As String, pAttachment As WaAttachment, pCaption As String)
         Dim _req As New WaSendMediaRequest()
         _req.Number = pPhone
         _req.GoType = "document"
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

      ' ======================= Instance =======================

      Overrides Function InstanceCreate(pReq As WaInstanceCreateRequest) As WaApiResult
         InstanceCreate = me.DoPost("/instance/create", pReq.ToJsonEvolutionGo(), True)
      End Function

      Overrides Function InstanceAll() As WaInstanceList
         Dim _list As New WaInstanceList()
         me.UseMaster()
         me._http.Gett("/instance/all")
         Dim _json As TJSONObject = me._http.ResponseAsJson()
         Dim _response As TJSONArray = _json.GetArray("data")
         Dim _filter As String = me._options.Filter.ToUpper()
         Dim i As Integer
         For i = 0 To _response.Length() - 1
            Dim _row As TJSONObject = _response.GetJSONObject(i)
            Dim _name As String = _row.GetString("name")
            If _filter = "" Or _name.ToUpper().Contains(_filter) Then
               Dim _item As New WaInstance()
               _item.Id = _name
               _item.Name = _name
               _item.Connected = _row.GetBoolean("connected")
               _item.Authenticated = _item.Connected
               _item.Phone = _row.GetString("jid").Split(":")[0]
               _list.Add(_item)
            End If
            _row.Free()
         Next
         _response.Free()
         _json.Free()
         InstanceAll = _list
      End Function

      Overrides Function InstanceInfo(pId As String) As WaInstance
         me.UseMaster()
         me._http.Gett("/instance/info/" + pId)
         Dim _json As TJSONObject = me._http.ResponseAsJson()
         Dim _row As TJSONObject = _json
         If _json.Has("data") Then
            _row = _json.GetJSONObject("data")
         End If

         Dim _item As New WaInstance()
         _item.Id = pId
         If _row.Has("name") Then
            Dim _name As String = _row.GetString("name")
            If _name <> "" Then
               _item.Id = _name
               _item.Name = _name
            End If
         End If
         If _row.Has("connected") Then
            _item.Connected = _row.GetBoolean("connected")
            _item.Authenticated = _item.Connected
         End If
         If _row.Has("jid") Then
            _item.Phone = _row.GetString("jid").Split(":")[0]
         End If
         _json.Free()
         InstanceInfo = _item
      End Function

      Overrides Function InstanceConnect(pId As String = "") As WaApiResult
         InstanceConnect = me.DoPost("/instance/connect", "{}")
      End Function

      Overrides Function InstanceStatus(pId As String = "") As WaApiResult
         InstanceStatus = me.DoGet("/instance/status")
      End Function

      Overrides Function InstanceRestart(pId As String = "") As WaApiResult
         InstanceRestart = me.DoPost("/instance/reconnect", "{}")
      End Function

      Overrides Function InstanceLogout(pId As String = "") As WaApiResult
         InstanceLogout = me.DoDelete("/instance/logout")
      End Function

      Overrides Function InstanceDelete(pId As String = "") As WaApiResult
         InstanceDelete = me.DoDelete("/instance/delete/" + pId, "", True)
      End Function

      Overrides Function InstanceQr(pId As String = "") As WaApiResult
         InstanceQr = me.DoGet("/instance/qr")
      End Function

      ' ======================= Send (DTOs tipados) =======================

      Overrides Function SendText(pReq As WaSendTextRequest) As WaApiResult
         SendText = me.DoPost("/send/text", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function SendMedia(pReq As WaSendMediaRequest) As WaApiResult
         SendMedia = me.DoPost("/send/media", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function SendButtons(pReq As WaSendButtonsRequest) As WaApiResult
         SendButtons = me.DoPost("/send/button", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function SendPoll(pReq As WaSendPollRequest) As WaApiResult
         SendPoll = me.DoPost("/send/poll", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function SendList(pReq As WaSendListRequest) As WaApiResult
         SendList = me.DoPost("/send/list", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function SendLocation(pReq As WaSendLocationRequest) As WaApiResult
         SendLocation = me.DoPost("/send/location", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function SendContact(pReq As WaSendContactRequest) As WaApiResult
         SendContact = me.DoPost("/send/contact", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function SendSticker(pReq As WaSendStickerRequest) As WaApiResult
         SendSticker = me.DoPost("/send/sticker", pReq.ToJsonEvolutionGo())
      End Function

      ' ======================= Message ops =======================

      Overrides Function MessageReact(pReq As WaMessageReactRequest) As WaApiResult
         MessageReact = me.DoPost("/message/react", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function MessageMarkRead(pReq As WaMessageMarkReadRequest) As WaApiResult
         MessageMarkRead = me.DoPost("/message/markread", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function MessageDelete(pReq As WaMessageDeleteRequest) As WaApiResult
         MessageDelete = me.DoPost("/message/delete", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function MessageEdit(pReq As WaMessageEditRequest) As WaApiResult
         MessageEdit = me.DoPost("/message/edit", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function MessagePresence(pReq As WaMessagePresenceRequest) As WaApiResult
         MessagePresence = me.DoPost("/message/presence", pReq.ToJsonEvolutionGo())
      End Function

      ' ======================= User =======================

      Overrides Function UserInfo(pReq As WaUserLookupRequest) As WaApiResult
         UserInfo = me.DoPost("/user/info", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function UserCheck(pReq As WaUserLookupRequest) As WaApiResult
         UserCheck = me.DoPost("/user/check", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function UserContacts(pInstance As String = "") As WaContactList
         Dim _list As New WaContactList()
         me.UseInstanceToken()
         me._http.Gett("/user/contacts")
         Dim _raw As String = me._http.ResponseText().Trim()

         Dim _array As TJSONArray
         If _raw.StartsWith("[") Then
            _array = me._http.ResponseAsArray()
         Else
            Dim _json As TJSONObject = me._http.ResponseAsJson()
            _array = _json.GetArray("data")
            _json.Free()
         End If

         Dim i As Integer
         For i = 0 To _array.Length() - 1
            Dim _row As TJSONObject = _array.GetJSONObject(i)
            Dim _contact As New WaContact()
            If _row.Has("id") Then
               _contact.Id = _row.GetString("id")
            ElseIf _row.Has("jid") Then
               _contact.Id = _row.GetString("jid")
            End If
            _contact.Phone = _contact.Id.Split("@")[0]
            If _row.Has("name") Then
               _contact.Name = _row.GetString("name")
            ElseIf _row.Has("notify") Then
               _contact.Name = _row.GetString("notify")
            ElseIf _row.Has("pushname") Then
               _contact.Name = _row.GetString("pushname")
            End If
            _contact.Exists = True
            _list.Add(_contact)
            _row.Free()
         Next
         _array.Free()
         UserContacts = _list
      End Function

      Overrides Function UserAvatar(pPhone As String, pInstance As String = "") As WaApiResult
         Dim _arr As TJSONArray =New TJSONArray("[" + pPhone.Quoted() + "]")
         Dim _body As New TJSONObject()
         _body.PutArray("number", _arr)
         UserAvatar = me.DoPost("/user/avatar", _body.ToString())
         _body.Free()
      End Function

      Overrides Function UserBlock(pReq As WaUserBlockRequest) As WaApiResult
         UserBlock = me.DoPost("/user/block", pReq.ToJson())
      End Function

      Overrides Function UserUnblock(pReq As WaUserBlockRequest) As WaApiResult
         UserUnblock = me.DoPost("/user/unblock", pReq.ToJson())
      End Function

      Overrides Function UserSetProfileName(pReq As WaUserProfileNameRequest) As WaApiResult
         UserSetProfileName = me.DoPost("/user/profileName", pReq.ToJson())
      End Function

      Overrides Function UserSetProfileStatus(pReq As WaUserProfileStatusRequest) As WaApiResult
         UserSetProfileStatus = me.DoPost("/user/profileStatus", pReq.ToJson())
      End Function

      Private Function FetchUserInfo(pPhone As String) As TJSONObject
         Dim _req As New WaUserLookupRequest()
         _req.Numbers.Add(pPhone)
         me.UseInstanceToken()
         me._http.Post("/user/info", _req.ToJsonEvolutionGo())
         _req.Free()
         FetchUserInfo = me._http.ResponseAsJson()
      End Function

      Private Function FetchUserCheck(pPhone As String) As TJSONObject
         Dim _req As New WaUserLookupRequest()
         _req.Numbers.Add(pPhone)
         me.UseInstanceToken()
         me._http.Post("/user/check", _req.ToJsonEvolutionGo())
         _req.Free()
         FetchUserCheck = me._http.ResponseAsJson()
      End Function

      Private Function OnlyDigits(pValue As String) As String
         Dim _value As String = pValue.Trim()
         If _value.Contains("@") Then
            _value = _value.Split("@")[0]
         End If
         OnlyDigits = _value.Replace("+", "").Replace(" ", "").Replace("-", "").Replace("(", "").Replace(")", "")
      End Function

      Private Function CanonicalBrPhone(pDigits As String) As String
         If pDigits.StartsWith("55") And pDigits.Length = 13 Then
            CanonicalBrPhone = pDigits.Left(4) + pDigits.Right(8)
         Else
            CanonicalBrPhone = pDigits
         End If
      End Function

      Private Function SameGoPhone(pLeft As String, pRight As String) As Boolean
         Dim _a As String = me.OnlyDigits(pLeft)
         Dim _b As String = me.OnlyDigits(pRight)
         If _a = "" Or _b = "" Then
            SameGoPhone = False
            Exit Function
         End If
         If _a = _b Then
            SameGoPhone = True
            Exit Function
         End If
         If me.CanonicalBrPhone(_a) = me.CanonicalBrPhone(_b) Then
            SameGoPhone = True
            Exit Function
         End If
         SameGoPhone = _a.EndsWith(_b) Or _b.EndsWith(_a)
      End Function

      Private Function RowMatchesPhone(pRow As TJSONObject, pPhone As String) As Boolean
         Dim _query As String = ""
         Dim _jid As String = ""
         Dim _remote As String = ""
         If pRow.Has("Query") Then
            _query = pRow.GetString("Query")
         End If
         If pRow.Has("JID") Then
            _jid = pRow.GetString("JID")
         End If
         If pRow.Has("RemoteJID") Then
            _remote = pRow.GetString("RemoteJID")
         End If
         RowMatchesPhone = me.SameGoPhone(pPhone, _query) Or me.SameGoPhone(pPhone, _jid) Or me.SameGoPhone(pPhone, _remote)
      End Function

      Private Function FindGoUserRow(pRoot As TJSONObject, pPhone As String) As TJSONObject
         If Not pRoot.Has("data") Then
            FindGoUserRow = NULL
            Exit Function
         End If
         Dim _data As TJSONObject = pRoot.GetJSONObject("data")
         If Not _data.Has("Users") Then
            _data.Free()
            FindGoUserRow = NULL
            Exit Function
         End If

         Dim _users As TJSONArray = _data.GetArray("Users")
         Dim _match As TJSONObject = NULL
         Dim i As Integer
         For i = 0 To _users.Length() - 1
            Dim _row As TJSONObject = _users.GetJSONObject(i)
            If _match = NULL And me.RowMatchesPhone(_row, pPhone) Then
               _match = _row
            ElseIf _match = NULL And _users.Length() = 1 Then
               _match = _row
            Else
               _row.Free()
            End If
         Next
         _users.Free()
         _data.Free()
         FindGoUserRow = _match
      End Function

      Private Function ExtractUserExists(pRoot As TJSONObject, pPhone As String) As Boolean
         Dim _row As TJSONObject = me.FindGoUserRow(pRoot, pPhone)
         If _row = NULL Then
            ExtractUserExists = False
            Exit Function
         End If
         Dim _exists As Boolean = False
         If _row.Has("IsInWhatsapp") Then
            _exists = _row.GetBoolean("IsInWhatsapp")
         End If
         _row.Free()
         ExtractUserExists = _exists
      End Function

      Overrides Function ValidatePhone(pInstance As String, pPhone As String) As Boolean
         Dim _root As TJSONObject = me.FetchUserCheck(pPhone)
         Dim _exists As Boolean = me.ExtractUserExists(_root, pPhone)
         _root.Free()
         If Not _exists Then
            Throw New Exception("Número inválido no WhatsApp: " + pPhone)
         End If
         ValidatePhone = True
      End Function

      Overrides Function GetContact(pInstance As String, pPhone As String) As WaContact
         Dim _root As TJSONObject = me.FetchUserInfo(pPhone)
         Dim _row As TJSONObject = me.FindGoUserRow(_root, pPhone)
         Dim _contact As New WaContact()
         _contact.Phone = pPhone

         If _row = NULL Then
            _contact.Exists = False
         Else
            If _row.Has("IsInWhatsapp") Then
               _contact.Exists = _row.GetBoolean("IsInWhatsapp")
            Else
               _contact.Exists = True
            End If
            If _row.Has("JID") Then
               _contact.Id = _row.GetString("JID")
            ElseIf _row.Has("RemoteJID") Then
               _contact.Id = _row.GetString("RemoteJID")
            End If
            If _row.Has("VerifiedName") Then
               _contact.Name = _row.GetString("VerifiedName")
            ElseIf _row.Has("Status") Then
               _contact.Name = _row.GetString("Status")
            End If
            If _row.Has("PictureURL") Then
               _contact.ProfileImageUrl = _row.GetString("PictureURL")
            End If
            _row.Free()
         End If
         _root.Free()
         GetContact = _contact
      End Function

      ' ======================= Chat =======================

      Overrides Function ChatFind(pReq As WaFindFilterRequest) As WaApiResult
         ChatFind = WaApiResult.Fail(me.GetName(), "ChatFind não disponível no Evolution GO")
      End Function

      Overrides Function ChatFindMessages(pReq As WaFindFilterRequest) As WaApiResult
         ChatFindMessages = WaApiResult.Fail(me.GetName(), "ChatFindMessages não disponível no Evolution GO")
      End Function

      Overrides Function ChatFindContacts(pReq As WaFindFilterRequest) As WaApiResult
         ChatFindContacts = WaApiResult.Fail(me.GetName(), "ChatFindContacts não disponível no Evolution GO")
      End Function

      Overrides Function ChatArchive(pReq As WaChatActionRequest) As WaApiResult
         Dim _path As String = "/chat/archive"
         If pReq.HasArchive And Not pReq.Archive Then
            _path = "/chat/unarchive"
         End If
         ChatArchive = me.DoPost(_path, pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function ChatPin(pReq As WaChatActionRequest) As WaApiResult
         ChatPin = me.DoPost("/chat/pin", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function ChatUnpin(pReq As WaChatActionRequest) As WaApiResult
         ChatUnpin = me.DoPost("/chat/unpin", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function ChatMute(pReq As WaChatActionRequest) As WaApiResult
         ChatMute = me.DoPost("/chat/mute", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function ChatUnmute(pReq As WaChatActionRequest) As WaApiResult
         ChatUnmute = me.DoPost("/chat/unmute", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function ChatCheckNumbers(pReq As WaCheckNumbersRequest) As WaApiResult
         ChatCheckNumbers = me.DoPost("/user/check", pReq.ToJsonEvolutionGo())
      End Function

      ' ======================= Group =======================

      Overrides Function GroupCreate(pReq As WaGroupCreateRequest) As WaApiResult
         GroupCreate = me.DoPost("/group/create", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function GroupList(pInstance As String = "") As WaApiResult
         GroupList = me.DoGet("/group/list")
      End Function

      Overrides Function GroupInfo(pReq As WaGroupInfoRequest) As WaApiResult
         GroupInfo = me.DoPost("/group/info", pReq.ToJson())
      End Function

      Overrides Function GroupParticipants(pReq As WaGroupInfoRequest) As WaApiResult
         GroupParticipants = me.GroupInfo(pReq)
      End Function

      Overrides Function GroupUpdateParticipant(pReq As WaGroupParticipantRequest) As WaApiResult
         GroupUpdateParticipant = me.DoPost("/group/participant", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function GroupInviteLink(pReq As WaGroupInviteRequest) As WaApiResult
         GroupInviteLink = me.DoPost("/group/invitelink", pReq.ToJson())
      End Function

      Overrides Function GroupLeave(pReq As WaGroupInfoRequest) As WaApiResult
         GroupLeave = me.DoPost("/group/leave", pReq.ToJson())
      End Function

      Overrides Function GroupUpdateSubject(pReq As WaGroupUpdateTextRequest) As WaApiResult
         GroupUpdateSubject = me.DoPost("/group/name", pReq.ToJsonEvolutionGo())
      End Function

      Overrides Function GroupUpdateDescription(pReq As WaGroupUpdateTextRequest) As WaApiResult
         GroupUpdateDescription = me.DoPost("/group/description", pReq.ToJsonEvolutionGo())
      End Function

      ' ======================= Dispose =======================

      Overrides Sub Dispose()
         ' _auth é owned pelo WaHttp
         me._auth = NULL
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
