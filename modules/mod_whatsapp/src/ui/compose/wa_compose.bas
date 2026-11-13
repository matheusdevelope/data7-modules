Imports Forms
Imports mod_tobject
Imports mod_wa_service
Imports mod_wa_message
Imports mod_wa_send_result
Imports mod_wa_capabilities
Imports mod_wa_compose_options
Imports mod_wa_compose_form
Imports mod_wa_compose_rules
Imports mod_wa_compose_events
Imports mod_wa_compose_client
Imports mod_wa_instance
Imports mod_wa_contact
Imports mod_wa_contracts

Namespace mod_wa_compose

   Class WaCompose
      Inherits TTObject

      Private _form As WaComposeForm
      Private _rules As WaComposeRules
      Private _events As WaComposeEvents
      Private _service As WaService
      Private _ownsService As Boolean
      Private _ownsOptions As Boolean
      Private _sending As Boolean
      Private _sent As Boolean
      Private _lastResult As WaSendResult

      Options As WaComposeOptions
      OnCanShow As WaCanDelegate
      OnCanClose As WaCanDelegate
      OnBeforeSend As WaBeforeSendDelegate
      OnFilterInstances As WaInstancesDelegate

      Sub New()
         MyBase.New()
         me._service = New WaService()
         me._ownsService = True
         me.Options = New WaComposeOptions()
         me._ownsOptions = True
      End Sub

      Sub New(pClient As WaClient, pOwnsClient As Boolean = True)
         MyBase.New()
         If pClient = NULL Then
            Throw New Exception("WaCompose requer um WaClient")
         End If
         me._service = New WaService()
         me._ownsService = True
         me.Options = New WaComposeOptions()
         me._ownsOptions = True
         me.RegisterClient(pClient, "", "", pOwnsClient)
      End Sub

      Sub New(pService As WaService, pOwnsService As Boolean = False)
         MyBase.New()
         If pService = NULL Then
            Throw New Exception("WaCompose requer um WaService injetado")
         End If
         me._service = pService
         me._ownsService = pOwnsService
         me.Options = New WaComposeOptions()
         me._ownsOptions = True
      End Sub

      Sub New(pService As WaService, pOptions As WaComposeOptions, pOwnsService As Boolean = False, pOwnsOptions As Boolean = False)
         MyBase.New()
         If pService = NULL Then
            Throw New Exception("WaCompose requer um WaService injetado")
         End If
         If pOptions = NULL Then
            Throw New Exception("WaCompose requer WaComposeOptions")
         End If
         me._service = pService
         me._ownsService = pOwnsService
         me.Options = pOptions
         me._ownsOptions = pOwnsOptions
      End Sub

      Function Message() As WaMessage
         Message = me.Options.Message
      End Function

      Function Sent() As Boolean
         Sent = me._sent
      End Function

      Function LastResult() As WaSendResult
         LastResult = me._lastResult
      End Function

      Function Service() As WaService
         Service = me._service
      End Function

      Function Show() As Boolean
         me.EnsureCurrentClientRegistered()
         me.ResolveActiveClient()
         me.BindClientInfo()
         me.BindSenders()
         me.RebuildUi()
         Dim _canShow As Boolean = True
         me._rules.HandlerOnCanShow(_canShow)
         If _canShow Then
            me._form.Show()
         End If
         Show = me._sent
      End Function

      Sub Close()
         If Assigned(me._form) And me._form.IsOpen Then
            me._form.Close()
         End If
      End Sub

      Function SendMessage() As Boolean
         Dim _send As Boolean = True
         Dim _close As Boolean = me.Options.CloseAfterSend
         If me.OnBeforeSend <> NULL Then
            me.OnBeforeSend(me.Options.Message, _send, _close)
         End If
         If Not _send Then
            SendMessage = False
            Exit Function
         End If

         me._sending = True
         me._sent = False
         Try
            If Assigned(me._lastResult) Then
               me._lastResult.Free()
               me._lastResult = NULL
            End If
            me.Options.ApplyFormatterTo(me.Options.Message)
            me._lastResult = me._service.Send.Message(me.Options.Message)
            me._sent = me._lastResult.Success
            If Not me._sent Then
               Forms.MessageBox.Show($"Erro ao enviar mensagem, verifique!{Char(13)}{me._lastResult.Message}")
            End If
         Catch ex As Exception
            me._sent = False
            Forms.MessageBox.Show($"Erro ao enviar mensagem, verifique!{Char(13)}{ex.Message}")
         End Try
         me._sending = False

         If me._sent And _close Then
            me.Options.MessageOnExit = ""
            me.Close()
         End If
         SendMessage = me._sent
      End Function

      Private Sub RebuildUi()
         me.FreeUi()
         me._form = New WaComposeForm()
         me._rules = New WaComposeRules(me._form, me.Options)
         me._events = New WaComposeEvents(me._rules)
         me._rules.OnOk = me.HandleOnOk
         me._rules.OnCanShow = me.HandleOnCanShow
         me._rules.OnCanClose = me.HandleOnCanClose
         me._rules.OnSelectClient = me.HandleOnSelectClient
         me.BindHandlers()
      End Sub

      Private Sub BindHandlers()
         me._form.OnShowEvent = me._events.HandleOnShow
         me._form.OnCloseEvent = me._events.HandleOnClose
         me._form.OnCanCloseEvent = me._events.HandleOnCanClose
         me._form.cbxPhoneRecipient.OnChange = me._events.HandleOnSelectPhoneRecipient
         me._form.cbxPhoneSender.OnChange = me._events.HandleOnSelectPhoneSender
         me._form.cbxPhoneSender.Control.OnChange = me._events.HandleOnSelectPhoneSender
         me._form.cbxClient.OnChange = me._events.HandleOnSelectClient
         me._form.cbxClient.Control.OnChange = me._events.HandleOnSelectClient
         me._form.txtPhoneRecipient.OnChange = me._events.HandleOnChangePhoneRecipient
         me._form.txtPhoneRecipient.Control.OnKeyDown = me._events.HandleOnKeyDownPhoneRecipient
         me._form.txtSubject.OnChange = me._events.HandleOnChangeSubject
         me._form.txtContent.OnChange = me._events.HandleOnChangeContent
         me._form.txtSignature.OnChange = me._events.HandleOnChangeSignature
         me._form.Grid.OnDrawCell = me._events.HandleOnDrawCellGrid
         me._form.Grid.OnDblClickCell = me._events.HandleOnDblClickCellGrid
         me._form.btnOk.OnClick = me._events.HandleOnBtnOk
         me._form.btnCancel.OnClick = me._events.HandleOnBtnCancel
         me._form.btnAttachment.OnClick = me._events.HandleOnBtnAttachment
      End Sub

      Private Sub BindClientInfo()
         me.Options.Notify = False
         me.Options.ClientName = me._service.Client().GetName()
         me.Options.ClientFeatures = me.DescribeFeatures(me._service.Capabilities())
         me.Options.RequiresSender = me._service.Capabilities().NeedsSender
         me.Options.Notify = True
      End Sub

      Sub RegisterClient(pClient As WaClient, pLabel As String = "", pKey As String = "", pOwnsClient As Boolean = False)
         If pClient = NULL Then
            Exit Sub
         End If
         If Assigned(me._service) Then
            If me._service.HasClient() Then
               If pClient = me._service.Client() Then
                  pOwnsClient = False
               End If
            End If
         End If
         me.Options.Clients.Add(pClient, pLabel, pKey, pOwnsClient)
         If Assigned(me._service) Then
            If Not me._service.HasClient() Then
               me._service.SetClient(pClient)
            End If
         End If
      End Sub

      Private Sub EnsureCurrentClientRegistered()
         If Not Assigned(me._service) Then
            Exit Sub
         End If
         If Not me._service.HasClient() Then
            Exit Sub
         End If
         Dim _current As WaClient = me._service.Client()
         me.Options.Clients.Add(_current, _current.GetName(), _current.GetName(), False)
      End Sub

      Private Sub ResolveActiveClient()
         me.ApplyDefaultClient()
         If Not Assigned(me._service) Then
            Throw New Exception("WaCompose requer ao menos um WaClient. Use RegisterClient.")
         End If
         If Not me._service.HasClient() Then
            Throw New Exception("WaCompose requer ao menos um WaClient. Use RegisterClient.")
         End If
      End Sub

      Private Sub ApplyDefaultClient()
         If Not me.Options.HasClients() Then
            Exit Sub
         End If
         Dim _entry As WaComposeClient = NULL
         If me.Options.DefaultClient.Trim() <> "" Then
            _entry = me.Options.Clients.Find(me.Options.DefaultClient)
         End If
         If Not Assigned(_entry) Then
            If me._service.HasClient() Then
               Dim _idx As Integer = me.Options.Clients.IndexOfClient(me._service.Client())
               If _idx >= 0 Then
                  _entry = me.Options.Clients.Take(_idx)
               End If
            End If
         End If
         If Not Assigned(_entry) Then
            _entry = me.Options.Clients.Take(0)
         End If
         If Assigned(_entry) Then
            me.ActivateClient(_entry, False)
         End If
      End Sub

      Private Sub ActivateClient(pEntry As WaComposeClient, pReloadSenders As Boolean)
         If Not Assigned(pEntry) Or Not Assigned(pEntry.Client) Then
            Exit Sub
         End If
         me._service.SetClient(pEntry.Client)
         me.Options.Notify = False
         me.Options.DefaultClient = pEntry.Key
         me.Options.Notify = True
         me.BindClientInfo()
         If pReloadSenders Then
            me.ReloadSenders()
         End If
      End Sub

      Private Sub ReloadSenders()
         me.Options.Notify = False
         me.Options.Senders = New WaContactList()
         me.Options.Message.Sender = ""
         me.Options.Notify = True
         me.BindSenders()
      End Sub

      Private Sub HandleOnSelectClient(pIndex As Integer)
         If pIndex < 0 Or pIndex >= me.Options.Clients.Count() Then
            Exit Sub
         End If
         Dim _entry As WaComposeClient = me.Options.Clients.Take(pIndex)
         If me._service.HasClient() Then
            If _entry.Client = me._service.Client() Then
               Exit Sub
            End If
         End If
         me.ActivateClient(_entry, True)
         If Assigned(me._rules) Then
            me._rules.ReloadAfterClientChange()
         End If
      End Sub

      Private Sub BindSenders()
         If Not me.Options.RequiresSender Then
            Exit Sub
         End If
         If me.Options.HasSenders() Then
            Exit Sub
         End If
         If Not me._service.Capabilities().CanManageInstances Then
            Exit Sub
         End If

         Dim _instances As WaInstanceList = NULL
         Try
            _instances = me._service.Instance.All()
            me.ApplyInstanceFilters(_instances)
            me.FillSendersFromInstances(_instances)
         Catch ex As Exception
            Forms.MessageBox.Show($"Não foi possível carregar os remetentes, verifique!{Char(13)}{ex.Message}")
         End Try
         If Assigned(_instances) Then
            _instances.Free()
         End If

         If me.Options.Message.Sender.Trim() = "" And me.Options.HasSenders() Then
            Dim _first As WaContact = me.Options.Senders.Take(0)
            If _first.Id.Trim() <> "" Then
               me.Options.Message.Sender = _first.Id
            Else
               me.Options.Message.Sender = _first.Name
            End If
         End If
      End Sub

      Private Sub ApplyInstanceFilters(ByRef pInstances As WaInstanceList)
         If Not Assigned(pInstances) Then
            Exit Sub
         End If
         pInstances.KeepNameContains(me.Options.SenderNameFilter)
         me.InvokeFilterInstances(me.Options.OnFilterInstances, pInstances)
         me.InvokeFilterInstances(me.OnFilterInstances, pInstances)
      End Sub

      Private Sub InvokeFilterInstances(pHandler As WaInstancesDelegate, ByRef pInstances As WaInstanceList)
         If pHandler = NULL Then
            Exit Sub
         End If
         Dim _before As WaInstanceList = pInstances
         pHandler(pInstances)
         If Assigned(_before) And _before <> pInstances Then
            _before.Free()
         End If
      End Sub

      Private Sub FillSendersFromInstances(pInstances As WaInstanceList)
         If Not Assigned(pInstances) Then
            Exit Sub
         End If
         Dim i As Integer
         For i = 0 To pInstances.Count() - 1
            Dim _inst As WaInstance = pInstances.Take(i)
            Dim _sender As New WaContact()
            _sender.Id = _inst.Id
            If _sender.Id.Trim() = "" Then
               _sender.Id = _inst.Name
            End If
            If _inst.ProfileName.Trim() <> "" Then
               _sender.Name = _inst.ProfileName
            Else
               _sender.Name = _inst.Name
            End If
            _sender.Phone = _inst.Phone
            me.Options.Senders.Add(_sender)
         Next
      End Sub

      Private Function DescribeFeatures(pCaps As WaCapabilities) As String
         Dim _parts As String = ""
         If pCaps.CanSendText Then
            _parts = "Texto"
         End If
         If pCaps.CanSendMedia Then
            If _parts = "" Then
               _parts = "Mídia"
            Else
               _parts = $"{_parts}, Mídia"
            End If
         End If
         If _parts = "" Then
            DescribeFeatures = "Envio básico"
         Else
            DescribeFeatures = _parts
         End If
      End Function

      Private Sub HandleOnOk(pSender As TObject)
         me.SendMessage()
      End Sub

      Private Sub HandleOnCanShow(ByRef pCanShow As Boolean)
         If me.OnCanShow <> NULL Then
            me.OnCanShow(pCanShow)
         End If
      End Sub

      Private Sub HandleOnCanClose(ByRef pCanClose As Boolean)
         If me.OnCanClose <> NULL Then
            me.OnCanClose(pCanClose)
            Exit Sub
         End If
         Dim _allow As Boolean = True
         If me._sending Then
            _allow = Forms.MessageBox.Confirmation("A mensagem está sendo enviada, deseja realmente cancelar?")
         End If
         If me.Options.MessageOnExit.Trim().Length > 0 Then
            _allow = Forms.MessageBox.Confirmation(me.Options.MessageOnExit)
         End If
         pCanClose = _allow
      End Sub

      Private Sub FreeUi()
         If Assigned(me._events) Then
            me._events.Free()
            me._events = NULL
         End If
         If Assigned(me._rules) Then
            me._rules.Free()
            me._rules = NULL
         End If
         If Assigned(me._form) Then
            me._form.Free()
            me._form = NULL
         End If
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("WaCompose")
            If Assigned(me._service) Then
               If me._service.HasClient() Then
                  .Prop("Client", me._service.Client().GetName())
               End If
            End If
            .Prop("Sent", me._sent)
            .Prop("Sending", me._sending)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         me.FreeUi()
         If Assigned(me._lastResult) Then
            me._lastResult.Free()
            me._lastResult = NULL
         End If
         If me._ownsOptions And Assigned(me.Options) Then
            me.Options.Free()
         End If
         me.Options = NULL
         If me._ownsService And Assigned(me._service) Then
            me._service.Free()
         End If
         me._service = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
