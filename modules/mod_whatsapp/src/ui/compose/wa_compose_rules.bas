' data7:disable unknown-member
Imports Forms
Imports IO
Imports Collections
Imports mod_wa_compose_options
Imports mod_wa_compose_form
Imports mod_wa_contact
Imports mod_wa_attachment
Imports mod_wa_phone_mask
Imports mod_wa_compose_client
Imports mod_wa_message
Imports mod_editors_combo

Namespace mod_wa_compose_rules

   Class WaComposeRules

      Private _form As mod_wa_compose_form.WaComposeForm
      Private _options As WaComposeOptions
      Private _bgColor As Integer = RGB(222, 215, 197)
      Private _initialized As Boolean

      OnCanShow As WaCanDelegate
      OnCanClose As WaCanDelegate
      OnOk As TNotifyEvent
      OnSelectClient As WaIndexDelegate

      Sub New(pForm As mod_wa_compose_form.WaComposeForm, pOptions As WaComposeOptions)
         MyBase.New()
         me._form = pForm
         me._options = pOptions
         me._options.OnChange = me.OnChangeOptions
      End Sub

      Private Sub OnChangeOptions(pPropChanged As String, pOptions As WaComposeOptions)
         me.RefreshForm()
      End Sub

      Sub AddAttachment(pValue As WaAttachment)
         Dim _pathAlreadyInList As Boolean = me._options.Message.Attachments.IndexOfPath(pValue.Path) >= 0
         If pValue.Path.Length = 0 Or Not File.Exists(pValue.Path) Or _pathAlreadyInList Then
            Exit Sub
         End If

         If me._form.Grid.RowCount = 0 Then
            me._form.Grid.AddRow()
         End If

         Dim _row As Integer = me._form.Grid.RowCount - 1
         If me._form.Grid.GetCelulas(1, _row).Length > 0 Then
            me._form.Grid.AddRow()
            _row = me._form.Grid.RowCount - 1
         End If

         If pValue.Caption.Trim().Length = 0 Then
            pValue.Caption = pValue.Filename
            If pValue.Caption.Contains(".") Then
               pValue.Caption = pValue.Caption.Left(pValue.Caption.LastDelimiter(".") - 1)
            End If
         End If

         me._form.Grid.SetCelulas(0, _row, "true")
         me._form.Grid.SetCelulas(1, _row, pValue.Path)
         me._form.Grid.SetCelulas(2, _row, pValue.Filename)
         me._form.Grid.SetCelulas(3, _row, pValue.Caption)
         me.PaintGridCells()
         me._options.Message.Attachments.Add(pValue)
      End Sub

      Sub AddAttachment(pPath As String = "")
         Dim _paths As StringList = TDialogs.OpenFiles("Selecione os arquivos a serem anexados", "Todos os arquivos|*.*", "")
         If Assigned(_paths) Then
            Dim i As Integer
            For i = 0 To _paths.Count - 1
               me.AddAttachment(New WaAttachment(_paths.Strings(i)))
            Next
            _paths.Free()
         End If
      End Sub

      Function GetMaskPhone(pText As String) As String
         GetMaskPhone = WaPhoneMask.GetMask(pText)
      End Function

      Private Function SenderKey(pContact As WaContact) As String
         If pContact.Id.Trim() <> "" Then
            SenderKey = pContact.Id.Trim()
         ElseIf pContact.Name.Trim() <> "" Then
            SenderKey = pContact.Name.Trim()
         Else
            SenderKey = pContact.Phone.Trim()
         End If
      End Function

      Private Function IndexOfSender(pContacts As WaContactList, pSender As String) As Integer
         Dim _key As String = pSender.Trim()
         If _key = "" Or pContacts.Count() = 0 Then
            IndexOfSender = -1
            Exit Function
         End If
         Dim i As Integer
         For i = 0 To pContacts.Count() - 1
            Dim _contact As WaContact = pContacts.Take(i)
            If _contact.Id = _key Or _contact.Name = _key Or _contact.Phone = _key Then
               IndexOfSender = i
               Exit Function
            End If
         Next
         IndexOfSender = -1
      End Function

      Private Sub FillSenders(pCombo As TComboEditor, pContacts As WaContactList, pCurrentSender As String)
         pCombo.Items.Clear()
         Dim _idx As Integer = me.IndexOfSender(pContacts, pCurrentSender)
         If _idx = -1 And pCurrentSender.Trim().Length > 0 Then
            Dim _manual As New WaContact()
            _manual.Name = "Manual"
            _manual.Id = pCurrentSender.Trim()
            _manual.Phone = pCurrentSender.Trim()
            pContacts.Add(_manual)
            _idx = pContacts.Count() - 1
         End If
         If _idx = -1 Then
            _idx = 0
         End If
         If pContacts.Count() = 0 Then
            Exit Sub
         End If
         Dim i As Integer
         For i = 0 To pContacts.Count() - 1
            Dim _contact As WaContact = pContacts.Take(i)
            Dim _label As String = _contact.Name.Trim()
            If _label = "" Then
               _label = _contact.Id.Trim()
            End If
            If _contact.Phone.Trim() <> "" And _contact.Phone.Trim() <> _label Then
               Dim _masked As String = WaPhoneMask.Apply(_contact.Phone, me._options.DefaultDDD)
               If _label = "" Then
                  _label = _masked
               Else
                  _label = $"{_label}: {_masked}"
               End If
            End If
            If _label = "" Then
               _label = me.SenderKey(_contact)
            End If
            pCombo.Items.Add(_label)
         Next
         pCombo.ItemIndex = _idx
      End Sub

      Private Sub FillClients(pCombo As TComboEditor, pClients As WaComposeClientList, pCurrent As String)
         pCombo.Items.Clear()
         If pClients.Count() = 0 Then
            Exit Sub
         End If
         Dim _idx As Integer = pClients.IndexOfKey(pCurrent)
         If _idx = -1 Then
            _idx = 0
         End If
         Dim i As Integer
         For i = 0 To pClients.Count() - 1
            Dim _entry As WaComposeClient = pClients.Take(i)
            Dim _label As String = _entry.Label.Trim()
            If _label = "" Then
               _label = _entry.Key
            End If
            pCombo.Items.Add(_label)
         Next
         pCombo.ItemIndex = _idx
      End Sub

      Private Sub FillPhones(pCombo As TComboEditor, pContacts As WaContactList, pCurrentPhone As String)
         pCombo.Items.Clear()
         Dim _phone As String = WaPhoneMask.OnlyNumbers(pCurrentPhone)
         Dim _idx As Integer = pContacts.IndexOfPhone(_phone)
         If _idx = -1 And _phone.Trim().Length > 0 Then
            Dim _manual As New WaContact()
            _manual.Name = "Manual"
            _manual.Phone = _phone
            pContacts.Add(_manual)
            _idx = pContacts.Count() - 1
         End If
         If _idx = -1 Then
            _idx = 0
         End If
         If pContacts.Count() = 0 Then
            Exit Sub
         End If
         Dim i As Integer
         For i = 0 To pContacts.Count() - 1
            Dim _contact As WaContact = pContacts.Take(i)
            Dim _masked As String = WaPhoneMask.Apply(_contact.Phone, me._options.DefaultDDD)
            Dim _label As String
            If _contact.Name.Trim() = "" Then
               _label = _masked
            Else
               _label = $"{_contact.Name}: {_masked}"
            End If
            pCombo.Items.Add(_label)
         Next
         pCombo.ItemIndex = _idx
      End Sub

      Private Sub InitializeForm()
         me._options.Notify = False
         If Not me._initialized Then
            me.FillPhones(me._form.cbxPhoneRecipient, me._options.Recipients, me._options.Message.Recipient)
            me.FillSenders(me._form.cbxPhoneSender, me._options.Senders, me._options.Message.Sender)
            me.FillClients(me._form.cbxClient, me._options.Clients, me.CurrentClientKey())

            Dim _count As Integer = me._options.Message.Attachments.Count()
            If _count > 0 Then
               Dim _paths As New StringList()
               Dim i As Integer
               For i = 0 To _count - 1
                  _paths.Add(me._options.Message.Attachments.Take(i).Path)
               Next
               me._options.Message.Attachments.Clean()
               For i = 0 To _paths.Count - 1
                  me.AddAttachment(_paths.Strings(i))
               Next
               _paths.Free()
            End If
            me._initialized = True
         End If
         me._options.Notify = True
      End Sub

      Private Sub SetFormValueFields()
         me._options.Notify = False
         me._form.Caption = me._options.Title
         Dim _value As String = WaPhoneMask.OnlyNumbers(WaPhoneMask.Apply(me._options.Message.Recipient, me._options.DefaultDDD))
         me._form.txtPhoneRecipient.Mascara = me.GetMaskPhone(_value)
         me._form.txtPhoneRecipient.Text = _value
         me._options.Message.Recipient = _value
         me._form.txtSubject.Text = me._options.Message.Subject
         me._form.txtContent.Text = me._options.Message.Content
         me._form.txtSignature.Text = me._options.Message.Signature
         me.BindInfoTab()
         me._options.Notify = True
      End Sub

      Private Sub BindInfoTab()
         me._form.txtClientName.Text = me._options.ClientName
         me._form.txtClientFeatures.Text = me._options.ClientFeatures
         me._form.txtDefaultClient.Text = me._options.DefaultClient
         me._form.txtClientCount.Text = CStr(me._options.Clients.Count())
         me._form.chkRequiresSender.Checked = me._options.RequiresSender
         me._form.txtDDD.Text = me._options.DefaultDDD
         me._form.txtCountryCode.Text = me._options.CountryCode
         me._form.txtRecipientCount.Text = CStr(me._options.Recipients.Count())
         me._form.txtSenderCount.Text = CStr(me._options.Senders.Count())
         me._form.txtTitle.Text = me._options.Title
         me._form.chkCloseAfterSend.Checked = me._options.CloseAfterSend
         me._form.txtMessageOnExit.Text = me._options.MessageOnExit
         me._form.chkCanChangeRecipient.Checked = me._options.CanChangeRecipient
         me._form.chkCanChangeSender.Checked = me._options.CanChangeSender
         me._form.chkCanChangeClient.Checked = me._options.CanChangeClient
         me._form.txtAttachMode.Text = "padrão do client"
         me._form.txtLayoutParts.Text = "padrão do client"
         me._form.chkSendCaption.Checked = False
         me._form.chkAttachmentsReversed.Checked = False
         me._form.chkIncludeEmptyParts.Checked = False
         me._form.chkInterceptText.Checked = me._options.OnFormatText <> NULL
         me._form.chkInterceptPlan.Checked = me._options.OnBuildPlan <> NULL
         If Assigned(me._options.Formatter) Then
            Dim _layout As WaMessageLayout = me._options.Formatter.Layout
            me._form.txtAttachMode.Text = _layout.ModeName()
            me._form.txtLayoutParts.Text = me.LayoutPartsText(_layout)
            me._form.chkSendCaption.Checked = _layout.SendCaption
            me._form.chkAttachmentsReversed.Checked = _layout.AttachmentsReversed
            me._form.chkIncludeEmptyParts.Checked = _layout.IncludeEmptyParts
         End If
      End Sub

      Private Function LayoutPartsText(pLayout As WaMessageLayout) As String
         Dim _text As String = ""
         Dim i As Integer
         For i = 0 To pLayout.PartCount() - 1
            If i > 0 Then
               _text = _text & ", "
            End If
            _text = _text & pLayout.PartAt(i)
         Next
         LayoutPartsText = _text
      End Function

      Private Function CurrentClientKey() As String
         If me._options.DefaultClient.Trim() <> "" Then
            CurrentClientKey = me._options.DefaultClient
         Else
            CurrentClientKey = me._options.ClientName
         End If
      End Function

      Private Sub SetFormEnabledFields()
         me._form.txtPhoneRecipient.Enabled = me._options.CanChangeRecipient
         me._form.cbxPhoneRecipient.Enabled = me._options.CanChangeRecipient
         me._form.cbxPhoneSender.Enabled = me._options.CanChangeSender
         me._form.cbxClient.Enabled = me._options.CanChangeClient And me._options.Clients.Count() > 1
      End Sub

      Private Sub SetFormVisibleFields()
         me._form.ApplyAppRow(me._options.ShowClient(), me._options.ShowSender())
      End Sub

      Sub RefreshForm()
         me.SetFormValueFields()
         me.SetFormEnabledFields()
         me.SetFormVisibleFields()
      End Sub

      Private Sub PaintGridCells()
         If me._form.Grid.RowCount = 0 Then
            Exit Sub
         End If
         me._form.Grid.BeginUpdate()
         Dim _row As Integer
         Dim _col As Integer
         For _row = 0 To me._form.Grid.RowCount - 1
            For _col = 0 To me._form.Grid.ColCount - 1
               me._form.Grid.CellColor(_col, _row) = me._bgColor
            Next
         Next
         me._form.Grid.AutoSize = True
         me._form.Grid.ColWidth(0) = 18
         me._form.Grid.EndUpdate()

      End Sub

      Sub HandlerOnCanShow(ByRef pCanShow As Boolean)
         If me.OnCanShow <> Null Then
            me.OnCanShow(pCanShow)
         End If
         If pCanShow Then
            me.InitializeForm()
            me.PaintGridCells()
            me.RefreshForm()
         End If
      End Sub

      Sub HandlerOnShow()
         me._form.IsOpen = True
      End Sub

      Sub HandlerOnCanClose(ByRef pCanClose As Boolean)
         If me.OnCanClose <> Null Then
            me.OnCanClose(pCanClose)
         End If
      End Sub

      Sub HandlerOnClose()
         me._form.IsOpen = False
      End Sub

      Sub HandlerOnSelectPhoneRecipient(pIndex As Integer)
         If pIndex >= 0 And pIndex < me._options.Recipients.Count() Then
            me._options.Message.Recipient = me._options.Recipients.Take(pIndex).Phone
         End If
         me.RefreshForm()
      End Sub

      Sub HandlerOnChangePhoneRecipient(pText As String)
         me._options.Message.Recipient = WaPhoneMask.OnlyNumbers(pText)
         me.SetFormEnabledFields()
      End Sub

      Sub HandlerOnSelectPhoneSender(pIndex As Integer)
         If pIndex >= 0 And pIndex < me._options.Senders.Count() Then
            me._options.Message.Sender = me.SenderKey(me._options.Senders.Take(pIndex))
         End If
         me.RefreshForm()
      End Sub

      Sub HandlerOnSelectClient(pIndex As Integer)
         If me.OnSelectClient <> NULL Then
            me.OnSelectClient(pIndex)
         End If
      End Sub

      Sub ReloadAfterClientChange()
         me.FillSenders(me._form.cbxPhoneSender, me._options.Senders, me._options.Message.Sender)
         me.RefreshForm()
      End Sub

      Sub HandlerOnChangeSubject(pText As String)
         me._options.Message.Subject = pText
      End Sub

      Sub HandlerOnChangeContent(pText As String)
         me._options.Message.Content = pText
      End Sub

      Sub HandlerOnChangeSignature(pText As String)
         me._options.Message.Signature = pText
      End Sub

      Sub HandlerOnDblClickCell(pRow As Integer, pCol As Integer)
         Dim _path As String = me._form.Grid.GetCelulas(1, pRow).Trim()
         If _path.Length = 0 Then
            Exit Sub
         End If
         Dim _checked As Boolean = me._form.Grid.GetCelulas(0, pRow).ToLower() = "false"
         me._form.Grid.SetCelulas(0, pRow, CStr(_checked))
         Dim _idx As Integer = me._options.Message.Attachments.IndexOfPath(_path)
         If _checked And _idx = -1 Then
            Dim _caption As String = me._form.Grid.GetCelulas(3, pRow).Trim()
            me._options.Message.Attachments.Add(New WaAttachment(_path, _caption))
         ElseIf Not _checked And _idx >= 0 Then
            me._options.Message.Attachments.RemoveAt(_idx)
         End If
         me.SetFormEnabledFields()
         me._form.Grid.Enabled = False
         me._form.Grid.Enabled = True
      End Sub

      Sub HandlerOnDrawCellGrid(pCol As Integer, pRow As Integer, pRect As TRect)
         If pCol <> 0 Then
            Exit Sub
         End If
         Dim _checkSize As Integer = 13
         me._form.Grid.Canvas.Pen.Width = 2
         me._form.Grid.Canvas.Pen.Color = RGB(192, 192, 192)
         me._form.Grid.Canvas.Brush.Color = RGB(255, 255, 255)
         me._form.Grid.Canvas.Rectangle(pRect.Left + 3, pRect.Top + 3, pRect.Right, pRect.Bottom)
         If me._form.Grid.GetCelulas(0, pRow).ToLower() = "true" Then
            me._form.Grid.Canvas.Pen.Width = 2
            me._form.Grid.Canvas.Pen.Color = RGB(0, 0, 0)
            me._form.Grid.Canvas.MoveTo(pRect.Left + 5, pRect.Bottom - 4)
            me._form.Grid.Canvas.LineTo(pRect.Left + _checkSize, pRect.Top + 5)
            me._form.Grid.Canvas.MoveTo(pRect.Left + 5, pRect.Top + 5)
            me._form.Grid.Canvas.LineTo(pRect.Left + _checkSize, pRect.Bottom - 4)
         End If
      End Sub

      Function HandlerOnBtnOk() As Boolean
         If me._options.ShowSender() Then
            Dim _idx As Integer = me._form.cbxPhoneSender.ItemIndex
            If _idx >= 0 And _idx < me._options.Senders.Count() Then
               me._options.Message.Sender = me.SenderKey(me._options.Senders.Take(_idx))
            End If
            If me._options.Message.Sender.Trim().Length = 0 Then
               Forms.MessageBox.Show("Informe um remetente para prosseguir, verifique.")
               me._form.cbxPhoneSender.SetFocus()
               HandlerOnBtnOk = False
               Exit Function
            End If
         End If
         Dim _phone As String = WaPhoneMask.OnlyNumbers(me._options.Message.Recipient)
         If _phone.Length < 10 Then
            Forms.MessageBox.Show("Informe um destinatário válido para prosseguir, verifique.")
            me._form.txtPhoneRecipient.SetFocus()
            HandlerOnBtnOk = False
            Exit Function
         End If
         If me._options.Message.Content.Trim().Length = 0 And me._options.Message.Attachments.Count() = 0 Then
            Forms.MessageBox.Show("Informe uma mensagem ou um arquivo em anexo para envio, verifique.")
            me._form.txtContent.SetFocus()
            HandlerOnBtnOk = False
            Exit Function
         End If
         me._options.Message.Recipient = WaPhoneMask.WithCountryCode(_phone, me._options.CountryCode, me._options.DefaultDDD)
         HandlerOnBtnOk = True
      End Function

      Sub HandlerOnCancel()
         me._form.Close()
      End Sub

      Sub HandlerOnAddAttachment()
         me.AddAttachment()
      End Sub

      Sub Free()
         If Assigned(me._options) Then
            me._options.OnChange = Null
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
