Imports mod_wa_phone_mask

Namespace mod_wa_compose_events

   Class WaComposeEvents

      Private _rules As mod_wa_compose_rules.WaComposeRules

      Sub New(pRules As mod_wa_compose_rules.WaComposeRules)
         MyBase.New()
         me._rules = pRules
      End Sub

      Sub HandleOnCanShow(ByRef pCanShow As Boolean)
         me._rules.HandlerOnCanShow(pCanShow)
      End Sub

      Sub HandleOnShow(pSender As TObject)
         me._rules.HandlerOnShow()
      End Sub

      Sub HandleOnCanClose(pSender As TObject, ByRef pCanClose As Boolean)
         me._rules.HandlerOnCanClose(pCanClose)
      End Sub

      Sub HandleOnClose(pSender As TObject)
         me._rules.HandlerOnClose()
      End Sub

      Sub HandleOnBtnOk(pSender As TObject)
         If me._rules.HandlerOnBtnOk() Then
            If me._rules.OnOk <> NULL Then
               me._rules.OnOk(pSender)
            End If
         End If
      End Sub

      Sub HandleOnBtnCancel(pSender As TObject)
         me._rules.HandlerOnCancel()
      End Sub

      Sub HandleOnBtnAttachment(pSender As TObject)
         me._rules.HandlerOnAddAttachment()
      End Sub

      Sub HandleOnChangeSubject(pSender As TObject)
         me._rules.HandlerOnChangeSubject(Forms.TextBox(pSender).Text)
      End Sub

      Sub HandleOnChangeContent(pSender As TObject)
         me._rules.HandlerOnChangeContent(Forms.MemoTextBox(pSender).Lines.Text)
      End Sub

      Sub HandleOnChangeSignature(pSender As TObject)
         me._rules.HandlerOnChangeSignature(Forms.MemoTextBox(pSender).Lines.Text)
      End Sub

      Sub HandleOnChangePhoneRecipient(pSender As TObject)
         me._rules.HandlerOnChangePhoneRecipient(Forms.MaskTextBox(pSender).Text)
      End Sub

      Sub HandleOnKeyDownPhoneRecipient(pSender As TObject, ByRef pWord As Word, pShift As Forms.TShiftState)
         Dim _input As Forms.MaskTextBox = Forms.MaskTextBox(pSender)
         Dim _text As String = _input.Text
         Dim _selStart As Integer = _input.SelStart
         Dim _selLength As Integer = _input.SelLength
         If pWord = 8 Then
            If _selLength = 0 Then
               _selLength = 1
            End If
            _text = _text.Left(_text.Copy(1, _text.Length - _selLength).Length)
         End If
         Dim _newMask As String = me._rules.GetMaskPhone(_text + WaPhoneMask.DigitFromKey(pWord))
         If _newMask <> _input.Mascara Then
            _input.Mascara = "(99) 9999999999"
            _input.Mascara = _newMask
            _input.SelStart = _selStart
         End If
      End Sub

      Sub HandleOnSelectPhoneSender(pSender As TObject)
         Dim _combo As Forms.HComboBox = Forms.HComboBox(pSender)
         If _combo.ItemIndex >= 0 Then
            me._rules.HandlerOnSelectPhoneSender(_combo.ItemIndex)
         End If
      End Sub

      Sub HandleOnSelectClient(pSender As TObject)
         Dim _combo As Forms.HComboBox = Forms.HComboBox(pSender)
         If _combo.ItemIndex >= 0 Then
            me._rules.HandlerOnSelectClient(_combo.ItemIndex)
         End If
      End Sub

      Sub HandleOnSelectPhoneRecipient(pSender As TObject)
         Dim _combo As Forms.HComboBox = Forms.HComboBox(pSender)
         If _combo.ItemIndex >= 0 Then
            me._rules.HandlerOnSelectPhoneRecipient(_combo.ItemIndex)
         End If
      End Sub

      Sub HandleOnDblClickCellGrid(pSender As TObject, pRow As Integer, pCol As Integer)
         me._rules.HandlerOnDblClickCell(pRow, pCol)
      End Sub

      Sub HandleOnDrawCellGrid(pSender As TObject, pCol As Integer, pRow As Integer, pRect As TRect, pState As Forms.TGridDrawState)
         me._rules.HandlerOnDrawCellGrid(pCol, pRow, pRect)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
