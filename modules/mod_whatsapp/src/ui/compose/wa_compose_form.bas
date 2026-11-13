Imports Forms
Imports mod_forms
Imports mod_editors
Imports mod_editors_mask
Imports mod_editors_text
Imports mod_editors_memo
Imports mod_editors_combo
Imports mod_editors_check

Namespace mod_wa_compose_form

   Class WaComposeForm
      Inherits TFormsSimple

      IsOpen As Boolean
      Grid As Forms.Grid

      btnAttachment As Forms.CommandButton
      btnOk As Forms.ButtonOk
      btnCancel As Forms.ButtonCancel

      txtPhoneRecipient As TMaskEditor
      cbxPhoneRecipient As TComboEditor
      txtSubject As TTextEditor
      txtContent As TMemoEditor
      txtSignature As TMemoEditor
      cbxClient As TComboEditor
      cbxPhoneSender As TComboEditor

      txtClientName As TTextEditor
      txtClientFeatures As TTextEditor
      txtDefaultClient As TTextEditor
      txtClientCount As TTextEditor
      txtDDD As TTextEditor
      txtCountryCode As TTextEditor
      txtRecipientCount As TTextEditor
      txtSenderCount As TTextEditor
      txtTitle As TTextEditor
      txtMessageOnExit As TTextEditor
      txtAttachMode As TTextEditor
      txtLayoutParts As TTextEditor
      chkRequiresSender As TCheckEditor
      chkCloseAfterSend As TCheckEditor
      chkCanChangeRecipient As TCheckEditor
      chkCanChangeSender As TCheckEditor
      chkCanChangeClient As TCheckEditor
      chkSendCaption As TCheckEditor
      chkAttachmentsReversed As TCheckEditor
      chkIncludeEmptyParts As TCheckEditor
      chkInterceptText As TCheckEditor
      chkInterceptPlan As TCheckEditor

      Private _page As Forms.PageControl
      Private _tabMessage As Forms.TabSheet
      Private _tabInfo As Forms.TabSheet
      Private _pnlActions As Forms.PageControl
      Private _pnlContact As Forms.PageControl
      Private _pnlApp As Forms.PageControl
      Private _pnlAttach As Forms.PageControl

      Private _gap As Integer = 4
      Private _pad As Integer = 8
      Private _labelWidth As Integer = 80
      Private _rowHeight As Integer = 22
      Private _clientWidth As Integer = 200
      Private _recipientComboWidth As Integer = 190
      Private _attachHeight As Integer = 150
      Private _signatureHeight As Integer = 48
      Private _actionHeight As Integer = 32
      Private _bgColor As Integer = RGB(222, 215, 197)

      Sub New()
         MyBase.New("Envio WhatsApp")
         me.CanResize = True
         me.MaximizeOnF11 = True
         me.Width.Min = 640
         me.Height.Min = 560
         me.SizeWidth = 42
         me.SizeHeight = 62
      End Sub

      Protected Overrides Sub Build()
         me.Host.Font.Name = "Tahoma"
         me.Host.Font.Size = 8
         me.BuildActions()
         me.BuildTabs()
         me.BuildTabMessage()
         me.BuildTabInfo()
         me._page.TabIndex = 0
         me.ApplyTabOrder()
      End Sub

      Protected Overrides Sub AfterShow()
         me.ApplyTabOrder()
      End Sub

      Private Sub BuildActions()
         me._pnlActions = me.MakePanel(me.Content, alBottom, me._actionHeight)
         me._pnlActions.AlignWithMargins = True
         me._pnlActions.Margins.Left = me._gap
         me._pnlActions.Margins.Top = 2
         me._pnlActions.Margins.Right = me._gap
         me._pnlActions.Margins.Bottom = me._gap

         me.btnCancel = New Forms.ButtonCancel(me._pnlActions)
         me.btnCancel.Align = alRight
         me.btnCancel.Width = 80
         me.btnCancel.AlignWithMargins = True

         me.btnOk = New Forms.ButtonOk(me._pnlActions)
         me.btnOk.Align = alRight
         me.btnOk.Width = 80
         me.btnOk.AlignWithMargins = True

         me.btnAttachment = New Forms.CommandButton(me._pnlActions)
         me.btnAttachment.Caption = "Adicionar Arquivo"
         me.btnAttachment.Align = alLeft
         me.btnAttachment.Width = 127
         me.btnAttachment.AlignWithMargins = True
      End Sub

      Private Sub BuildTabs()
         me._page = New Forms.PageControl(me.Content)
         me._page.Align = alClient
         me._page.TabStop = False
         me._page.ShowShadow = False
         me._page.AlignWithMargins = True
      End Sub

      Private Sub BuildTabMessage()
         me._tabMessage = New Forms.TabSheet(me._page)
         me._tabMessage.Text = "Dados Envio"
         me._tabMessage.TabStop = False
         me._tabMessage.PageIndex = 0
         ' data7:disable-next-line unknown-member
         me._tabMessage.Color = me._bgColor

         ' alBottom: o primeiro criado fica no fundo.
         me.BuildAttach()
         me.BuildAppRow()
         me.BuildSignature()

         ' alTop: o último criado fica no topo. Assunto primeiro, Contato por último.
         me.BuildSubject()
         me.BuildContact()

         me.BuildContent()
      End Sub

      Private Sub BuildAttach()
         me._pnlAttach = me.MakePanel(me._tabMessage, alBottom, me._attachHeight)
         me._pnlAttach.AlignWithMargins = True
         me._pnlAttach.Margins.Left = 0
         me._pnlAttach.Margins.Right = 0
         me._pnlAttach.Margins.Top = me._gap
         me._pnlAttach.Margins.Bottom = me._gap

         Dim _lblFiles As Forms.StaticText = New Forms.StaticText(me._pnlAttach)
         _lblFiles.Align = alTop
         _lblFiles.Height = 18
         _lblFiles.Caption = "Arquivos:"
         _lblFiles.AlignWithMargins = True
         _lblFiles.Margins.Left = me._pad
         _lblFiles.Margins.Top = me._gap
         _lblFiles.Margins.Right = me._pad
         _lblFiles.Margins.Bottom = 0

         me.Grid = New Forms.Grid(me._pnlAttach)
         me.Grid.Align = alClient
         me.Grid.AlignWithMargins = True
         me.Grid.Margins.Left = me._pad
         me.Grid.Margins.Top = 2
         me.Grid.Margins.Right = me._pad
         me.Grid.Margins.Bottom = me._gap
         me.Grid.Color = me._bgColor
         me.Grid.DefaultRowHeight = 18
         me.Grid.ColCount = 5
         me.Grid.ColWidth(0) = 18
         me.Grid.ColWidth(1) = 200
         me.Grid.HideColumns(2, 4)
         me.Grid.GridOptions.RowSelect = True
         me.Grid.GridOptions.VerLine = False
         me.Grid.GridOptions.HorzLine = False
         me.Grid.ShowSelection = False
         me.Grid.RowCount = 0
         me.Grid.TabStop = False
         me.Grid.AutoSize = True
      End Sub

      Private Sub BuildAppRow()
         me._pnlApp = me.MakePanel(me._tabMessage, alBottom, 0)
         me._pnlApp.Height = 0
         me._pnlApp.Visible = False

         me.cbxClient = New TComboEditor(me._pnlApp, "Aplicativo:")
         me.cbxClient.LabelWidth = me._labelWidth
         me.cbxClient.Align = alLeft
         me.cbxClient.Width = me._clientWidth
         me.cbxClient.Visible = False
         me.PadEditor(me.cbxClient, 0)
         me.cbxClient.Host.Margins.Right = me._gap

         me.cbxPhoneSender = New TComboEditor(me._pnlApp, "Remetente:")
         me.cbxPhoneSender.LabelWidth = me._labelWidth
         me.cbxPhoneSender.Align = alClient
         me.cbxPhoneSender.Visible = False
         me.PadEditor(me.cbxPhoneSender, 0)
         me.cbxPhoneSender.Host.Margins.Left = me._gap
      End Sub

      Private Sub BuildSignature()
         me.txtSignature = New TMemoEditor(me._tabMessage, "Assinatura:")
         me.txtSignature.LabelWidth = me._labelWidth
         me.txtSignature.EditorHeight = me._signatureHeight
         me.txtSignature.Align = alBottom
         me.txtSignature.WordWrap = True
         me.PadEditor(me.txtSignature)
      End Sub

      Private Sub BuildSubject()
         me.txtSubject = New TTextEditor(me._tabMessage, "Assunto:")
         me.txtSubject.LabelWidth = me._labelWidth
         me.txtSubject.Align = alTop
         me.txtSubject.Height = me._rowHeight
         me.PadEditor(me.txtSubject)
      End Sub

      Private Sub BuildContact()
         me._pnlContact = me.MakePanel(me._tabMessage, alTop, me._rowHeight)
         me._pnlContact.AlignWithMargins = True
         me._pnlContact.Margins.Left = 0
         me._pnlContact.Margins.Top = me._gap
         me._pnlContact.Margins.Right = 0
         me._pnlContact.Margins.Bottom = me._gap

         me.cbxPhoneRecipient = New TComboEditor(me._pnlContact, "")
         me.cbxPhoneRecipient.LabelPlacement = TLabelPlacement.Hidden()
         me.cbxPhoneRecipient.Align = alRight
         me.cbxPhoneRecipient.Width = me._recipientComboWidth
         me.cbxPhoneRecipient.Slot.AlignWithMargins = False
         me.cbxPhoneRecipient.Host.AlignWithMargins = True
         me.cbxPhoneRecipient.Host.Margins.Left = me._gap
         me.cbxPhoneRecipient.Host.Margins.Top = 0
         me.cbxPhoneRecipient.Host.Margins.Right = me._pad
         me.cbxPhoneRecipient.Host.Margins.Bottom = 0       

         me.txtPhoneRecipient = New TMaskEditor(me._pnlContact, "Contato:")
         me.txtPhoneRecipient.Required = True
         me.txtPhoneRecipient.LabelWidth = me._labelWidth
         me.txtPhoneRecipient.Align = alClient
         me.PadEditor(me.txtPhoneRecipient, 0)
         me.txtPhoneRecipient.Host.Margins.Right = 0
      End Sub

      Private Sub BuildContent()
         me.txtContent = New TMemoEditor(me._tabMessage, "Conteúdo:")
         me.txtContent.LabelWidth = me._labelWidth
         me.txtContent.Align = alClient
         me.txtContent.WordWrap = True
         me.PadEditor(me.txtContent)
      End Sub

      Private Sub BuildTabInfo()
         me._tabInfo = New Forms.TabSheet(me._page)
         me._tabInfo.Text = "Informações"
         me._tabInfo.PageIndex = 1
         me._tabInfo.TabStop = False
         ' data7:disable-next-line unknown-member
         me._tabInfo.Color = me._bgColor

         ' alTop: último criado fica no topo. Criar de baixo para cima.
         me.chkInterceptPlan = me.MakeInfoCheck(me._tabInfo, "Intercepta plano:")
         me.chkInterceptText = me.MakeInfoCheck(me._tabInfo, "Intercepta texto:")
         me.txtLayoutParts = me.MakeInfoText(me._tabInfo, "Partes layout:")
         me.chkIncludeEmptyParts = me.MakeInfoCheck(me._tabInfo, "Partes vazias:")
         me.chkAttachmentsReversed = me.MakeInfoCheck(me._tabInfo, "Anexos invertidos:")
         me.chkSendCaption = me.MakeInfoCheck(me._tabInfo, "Envia caption:")
         me.txtAttachMode = me.MakeInfoText(me._tabInfo, "Texto x anexo:")
         me.chkCanChangeClient = me.MakeInfoCheck(me._tabInfo, "Altera aplicativo:")
         me.chkCanChangeSender = me.MakeInfoCheck(me._tabInfo, "Altera remetente:")
         me.chkCanChangeRecipient = me.MakeInfoCheck(me._tabInfo, "Altera destinatário:")
         me.txtMessageOnExit = me.MakeInfoText(me._tabInfo, "Msg. ao sair:")
         me.chkCloseAfterSend = me.MakeInfoCheck(me._tabInfo, "Fecha após envio:")
         me.txtTitle = me.MakeInfoText(me._tabInfo, "Título:")
         me.txtSenderCount = me.MakeInfoText(me._tabInfo, "Remetentes:")
         me.txtRecipientCount = me.MakeInfoText(me._tabInfo, "Destinatários:")
         me.txtCountryCode = me.MakeInfoText(me._tabInfo, "Cód. país:")
         me.txtDDD = me.MakeInfoText(me._tabInfo, "DDD padrão:")
         me.chkRequiresSender = me.MakeInfoCheck(me._tabInfo, "Requer remetente:")
         me.txtClientCount = me.MakeInfoText(me._tabInfo, "Apps registrados:")
         me.txtDefaultClient = me.MakeInfoText(me._tabInfo, "App padrão:")
         me.txtClientFeatures = me.MakeInfoText(me._tabInfo, "Recursos:")
         me.txtClientName = me.MakeInfoText(me._tabInfo, "Cliente:")
      End Sub

      Sub ApplyAppRow(pShowClient As Boolean, pShowSender As Boolean)
         me._pnlApp.Top = me._pnlAttach.Top - 4
         Dim _showRow As Boolean = pShowClient Or pShowSender
         me._pnlApp.Visible = _showRow
         If _showRow Then
            me._pnlApp.Height = me._rowHeight
         Else
            me._pnlApp.Height = 0
         End If
         me.cbxClient.Visible = pShowClient
         me.cbxPhoneSender.Visible = pShowSender
         If pShowSender And Not pShowClient Then
            me.cbxPhoneSender.Host.Margins.Left = me._pad
         Else
            me.cbxPhoneSender.Host.Margins.Left = me._gap
         End If
      End Sub

      Private Function MakeInfoText(pParent As TWinControl, pCaption As String) As TTextEditor
         Dim _editor As TTextEditor = New TTextEditor(pParent, pCaption)
         _editor.LabelWidth = me._labelWidth
         _editor.OnlyRead = True
         _editor.Align = alTop
         _editor.TabStop = False
         me.PadEditor(_editor)
         _editor.Height = me._rowHeight
         MakeInfoText = _editor
      End Function

      Private Function MakeInfoCheck(pParent As TWinControl, pCaption As String) As TCheckEditor
         Dim _editor As TCheckEditor = New TCheckEditor(pParent, pCaption)
         _editor.LabelWidth = me._labelWidth
         _editor.Enabled = False
         _editor.Align = alTop
         _editor.TabStop = False
         me.PadEditor(_editor)
         MakeInfoCheck = _editor
      End Function

      Private Function MakePanel(pParent As TWinControl, pAlign As TAlign, pHeight As Integer = 0) As Forms.PageControl
         Dim _panel As Forms.PageControl = New Forms.PageControl(pParent)
         _panel.Align = pAlign
         _panel.ShowCardFrame = False
         _panel.ShowShadow = False
         _panel.TabStop = False
         If pHeight > 0 Then
            _panel.Height = pHeight
         End If
         MakePanel = _panel
      End Function

      Private Sub PadEditor(pEditor As TLabeledEditorBase, pBottom As Integer = 4)
         pEditor.AlignWithMargins = True
         pEditor.Host.TabStop = False
         pEditor.Slot.TabStop = False
         pEditor.Host.Margins.Left = me._pad
         pEditor.Host.Margins.Top = 0
         pEditor.Host.Margins.Right = me._pad
         pEditor.Host.Margins.Bottom = pBottom
         pEditor.Slot.Margins.Top = 0
         pEditor.Slot.Margins.Bottom = 0
      End Sub

      Private Sub ApplyTabOrder()
         me._page.TabStop = False
         me._pnlActions.TabStop = False
         me._pnlAttach.TabStop = False
         me._pnlContact.TabStop = False
         me._pnlApp.TabStop = False
         me.Grid.TabStop = False
         me.btnOk.TabOrder = 1
         me.txtPhoneRecipient.TabOrder = 2
         me.cbxPhoneRecipient.TabOrder = 3
         me.txtSubject.TabOrder = 4
         me.txtContent.TabOrder = 5
         me.txtSignature.TabOrder = 6
         me.cbxClient.TabOrder = 7
         me.cbxPhoneSender.TabOrder = 8
         me.btnAttachment.TabOrder = 9
         me.btnCancel.TabOrder = 10
      End Sub

      Private Sub FreeEditors()
         If Assigned(me.txtPhoneRecipient) Then
            me.txtPhoneRecipient.Free()
            me.txtPhoneRecipient = NULL
         End If
         If Assigned(me.cbxPhoneRecipient) Then
            me.cbxPhoneRecipient.Free()
            me.cbxPhoneRecipient = NULL
         End If
         If Assigned(me.txtSubject) Then
            me.txtSubject.Free()
            me.txtSubject = NULL
         End If
         If Assigned(me.txtContent) Then
            me.txtContent.Free()
            me.txtContent = NULL
         End If
         If Assigned(me.txtSignature) Then
            me.txtSignature.Free()
            me.txtSignature = NULL
         End If
         If Assigned(me.cbxPhoneSender) Then
            me.cbxPhoneSender.Free()
            me.cbxPhoneSender = NULL
         End If
         If Assigned(me.cbxClient) Then
            me.cbxClient.Free()
            me.cbxClient = NULL
         End If
         If Assigned(me.txtClientName) Then
            me.txtClientName.Free()
            me.txtClientName = NULL
         End If
         If Assigned(me.txtClientFeatures) Then
            me.txtClientFeatures.Free()
            me.txtClientFeatures = NULL
         End If
         If Assigned(me.txtDefaultClient) Then
            me.txtDefaultClient.Free()
            me.txtDefaultClient = NULL
         End If
         If Assigned(me.txtClientCount) Then
            me.txtClientCount.Free()
            me.txtClientCount = NULL
         End If
         If Assigned(me.txtDDD) Then
            me.txtDDD.Free()
            me.txtDDD = NULL
         End If
         If Assigned(me.txtCountryCode) Then
            me.txtCountryCode.Free()
            me.txtCountryCode = NULL
         End If
         If Assigned(me.txtRecipientCount) Then
            me.txtRecipientCount.Free()
            me.txtRecipientCount = NULL
         End If
         If Assigned(me.txtSenderCount) Then
            me.txtSenderCount.Free()
            me.txtSenderCount = NULL
         End If
         If Assigned(me.txtTitle) Then
            me.txtTitle.Free()
            me.txtTitle = NULL
         End If
         If Assigned(me.txtMessageOnExit) Then
            me.txtMessageOnExit.Free()
            me.txtMessageOnExit = NULL
         End If
         If Assigned(me.txtAttachMode) Then
            me.txtAttachMode.Free()
            me.txtAttachMode = NULL
         End If
         If Assigned(me.txtLayoutParts) Then
            me.txtLayoutParts.Free()
            me.txtLayoutParts = NULL
         End If
         If Assigned(me.chkRequiresSender) Then
            me.chkRequiresSender.Free()
            me.chkRequiresSender = NULL
         End If
         If Assigned(me.chkCloseAfterSend) Then
            me.chkCloseAfterSend.Free()
            me.chkCloseAfterSend = NULL
         End If
         If Assigned(me.chkCanChangeRecipient) Then
            me.chkCanChangeRecipient.Free()
            me.chkCanChangeRecipient = NULL
         End If
         If Assigned(me.chkCanChangeSender) Then
            me.chkCanChangeSender.Free()
            me.chkCanChangeSender = NULL
         End If
         If Assigned(me.chkCanChangeClient) Then
            me.chkCanChangeClient.Free()
            me.chkCanChangeClient = NULL
         End If
         If Assigned(me.chkSendCaption) Then
            me.chkSendCaption.Free()
            me.chkSendCaption = NULL
         End If
         If Assigned(me.chkAttachmentsReversed) Then
            me.chkAttachmentsReversed.Free()
            me.chkAttachmentsReversed = NULL
         End If
         If Assigned(me.chkIncludeEmptyParts) Then
            me.chkIncludeEmptyParts.Free()
            me.chkIncludeEmptyParts = NULL
         End If
         If Assigned(me.chkInterceptText) Then
            me.chkInterceptText.Free()
            me.chkInterceptText = NULL
         End If
         If Assigned(me.chkInterceptPlan) Then
            me.chkInterceptPlan.Free()
            me.chkInterceptPlan = NULL
         End If
      End Sub

      Sub Free()
         me.FreeEditors()
         MyBase.Free()
      End Sub

   End Class

End Namespace
