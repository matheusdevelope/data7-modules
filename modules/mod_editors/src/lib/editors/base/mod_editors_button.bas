Imports Forms
Imports mod_editors

Namespace mod_editors_button

   Class ButtonedTextBox
      ReadOnly Container As PageControl
      ReadOnly TextEditor As TextBox
      ReadOnly ButtonEditor As Imagem

      Private _pnlImgCtx As PageControl
      Private _pnlImgBtn As PageControl

      Private _pattern As String
      Private _readonly As Boolean
      Private _enabled As Boolean = True
      Private _focused As Boolean
      Private _mouseInClient As Boolean
      Private _updating As Boolean
      Private _inChange As Boolean

      Private _key As Char
      Private _sel As Integer

      Protected BORDER_FOCUSED As Integer = RGB(0, 120, 215)
      Protected BORDER_NORMAL As Integer = RGB(160, 160, 160)
      Protected EDIT_FOCUSED As Integer = RGB(255, 255, 215)
      Protected EDIT_NORMAL As Integer = RGB(255, 255, 255)
      Protected EDIT_READONLY As Integer = RGB(229, 229, 229)
      Protected EDIT_DISABLED As Integer = RGB(240, 240, 240)
      Protected BTN_NORMAL As Integer = RGB(240, 240, 240)
      Protected BTN_FOCUSED As Integer = RGB(179, 215, 244)
      Protected BTN_PRESSED As Integer = RGB(136, 189, 231)

      OnKeyPress As TKeyPressEvent
      OnPreviewKeyPress As TKeyPressEvent
      OnBeforeChange As TNotifyEvent
      OnChange As TNotifyEvent
      OnButtonClick As TNotifyEvent

      Sub New(pOwner As TWinControl)
         MyBase.New()

         me.Container = New PageControl(pOwner)
         me._pnlImgCtx = New PageControl(me.Container)
         me._pnlImgBtn = New PageControl(me._pnlImgCtx)
         me.ButtonEditor = New Imagem(me._pnlImgBtn)
         me.TextEditor = New TextBox(me.Container)

         me.TextEditor.OnKeyPress = me._handleKeyPress
         me.TextEditor.OnChange = me._handleOnChange
         me._pattern = ""

         me._createUI()
      End Sub

      Property Updating As Boolean
         Get
            Updating = me._updating
         End Get
      End Property

      Property InChange As Boolean
         Get
            InChange = me._inChange
         End Get
      End Property

      Property Align As TAlign
         Get
            Align = me.Container.Align
         End Get
         Set(pValue As TAlign)
            me._setAlign(pValue)
         End Set
      End Property

      Private Sub _setAlign(pValue As TAlign)
         me.Container.Align = pValue
      End Sub

      Property Text As String
         Get
            Text = me.TextEditor.Text
         End Get
         Set(pValue As String)
            me._setText(pValue)
         End Set
      End Property

      Private Sub _setText(pValue As String)
         me._updating = True
         me.TextEditor.OnChange = Null
         me.TextEditor.Text = me._applyMask(pValue)
         me.TextEditor.OnChange = me._handleOnChange
         me._updating = False
      End Sub

      Property Mask As String
         Get
            Mask = me._pattern
         End Get
         Set(pValue As String)
            me._setMask(pValue)
         End Set
      End Property

      Private Sub _setMask(pValue As String)
         me._pattern = pValue
      End Sub

      Property OnlyRead As Boolean
         Get
            OnlyRead = me._readonly
         End Get
         Set(pValue As Boolean)
            me._setOnlyRead(pValue)
         End Set
      End Property

      Private Sub _setOnlyRead(pValue As Boolean)
         me._readonly = pValue
         me._updateVisual()
      End Sub

      Property Enabled As Boolean
         Get
            Enabled = me._enabled
         End Get
         Set(pValue As Boolean)
            me._setEnabled(pValue)
         End Set
      End Property

      Private Sub _setEnabled(pValue As Boolean)
         me._enabled = pValue
         me._updateVisual()
      End Sub

      Property ButtonVisible As Boolean
         Get
            ButtonVisible = me._pnlImgCtx.Visible
         End Get
         Set(pValue As Boolean)
            me._setButtonVisible(pValue)
         End Set
      End Property

      Private Sub _setButtonVisible(pValue As Boolean)
         me._pnlImgCtx.Visible = pValue
         me._syncEditorRightMargin()
      End Sub

      Private Sub _syncEditorRightMargin()
         If me._pnlImgCtx.Visible Then
            me.TextEditor.Margins.Right = 0
         Else
            me.TextEditor.Margins.Right = -1
         End If
      End Sub

      Sub LoadFromFile(pPath As String)
         me.ButtonEditor.LoadFromFile(pPath)
      End Sub

      Sub LoadFromBase64(pBase64 As String)
         me.ButtonEditor.LoadFromBase64(pBase64)
      End Sub

      Protected Overridable Sub _createUI()
         me.Container.Width = 200
         me.Container.Height = 20
         me.Container.Margins.Left = 1
         me.Container.Margins.Top = 1
         me.Container.Margins.Right = 1
         me.Container.Margins.Bottom = 1
         me.Container.AlignWithMargins = True
         me.Container.Color = me.BORDER_NORMAL
         me.Container.ShowCardFrame = False
         me.Container.ShowShadow = False
         me.Container.TabStop = False

         me._pnlImgCtx.TabStop = False
         me._pnlImgCtx.Align = alRight
         me._pnlImgCtx.Width = 20
         me._pnlImgCtx.AlignWithMargins = True
         me._pnlImgCtx.Margins.Left = -1
         me._pnlImgCtx.Margins.Top = 1
         me._pnlImgCtx.Margins.Right = 1
         me._pnlImgCtx.Margins.Bottom = 1
         me._pnlImgCtx.ShowCardFrame = False
         me._pnlImgCtx.ShowShadow = False
         me._pnlImgCtx.Color = me.EDIT_NORMAL

         me._pnlImgBtn.TabStop = False
         me._pnlImgBtn.Align = alClient
         me._pnlImgBtn.AlignWithMargins = True
         me._pnlImgBtn.Margins.Left = 1
         me._pnlImgBtn.Margins.Top = 1
         me._pnlImgBtn.Margins.Right = 1
         me._pnlImgBtn.Margins.Bottom = 1
         me._pnlImgBtn.ShowCardFrame = False
         me._pnlImgBtn.ShowShadow = False
         me._pnlImgBtn.Color = me.BTN_NORMAL

         me.ButtonEditor.Align = alClient
         me.ButtonEditor.AlignWithMargins = True
         me.ButtonEditor.Margins.Left = 1
         me.ButtonEditor.Margins.Top = 0
         me.ButtonEditor.Margins.Right = 0
         me.ButtonEditor.Margins.Bottom = 0
         me.ButtonEditor.ShowHint = True
         me.ButtonEditor.OnMouseEnter = me._handleImgMouseEnter
         me.ButtonEditor.OnMouseLeave = me._handleImgMouseLeave
         me.ButtonEditor.OnClick = me._handleButtonClick
         me.ButtonEditor.OnMouseMove = me._handleImgMouseMove

         me.TextEditor.Align = alClient
         me.TextEditor.AlignWithMargins = True
         me.TextEditor.Margins.Left = -1
         me.TextEditor.Margins.Top = -1
         me.TextEditor.Margins.Right = 0
         me.TextEditor.Margins.Bottom = -1

         me.TextEditor.OnEnter = me._handleEnter
         me.TextEditor.OnExit = me._handleExit
         me.TextEditor.OnMouseEnter = me._handleMouseEnter
         me.TextEditor.OnMouseLeave = me._handleMouseLeave
      End Sub

      Protected Overridable Sub _handleOnChange(pSender As TObject)
         me._inChange = True
         me._updating = True
         me.TextEditor.OnChange = Null
         If me.OnBeforeChange <> Null Then
            me.OnBeforeChange(pSender)
         End If
         Dim incoming As String = me.TextEditor.Text
         Dim keyCode As Integer = CInt(Asc(me._key))
         Dim caret As Integer = me._caretFromKey(incoming, keyCode)
         me.TextEditor.Text = me._applyMask(incoming)
         If caret < 0 Then
            caret = 0
         End If
         If caret > Len(me.TextEditor.Text) Then
            caret = Len(me.TextEditor.Text)
         End If
         me.TextEditor.SelStart = caret

         me.TextEditor.OnChange = me._handleOnChange
         me._updating = False
         If me.OnChange <> Null Then
            me.OnChange(pSender)
         End If
         me._inChange = False
      End Sub

      Private Function _caretFromKey(pIncoming As String, pKeyCode As Integer) As Integer
         If me._pattern = "" Then
            If pKeyCode = 8 Then
               _caretFromKey = me._sel - 1
            ElseIf pKeyCode = 24 Then
               _caretFromKey = 0
            ElseIf pKeyCode = 22 Then
               _caretFromKey = Len(pIncoming)
            Else
               _caretFromKey = me._sel + 1
            End If
            Exit Function
         End If
         Dim take As Integer
         If pKeyCode = 8 Then
            take = me._sel
         ElseIf pKeyCode = 24 Then
            take = 0
         ElseIf pKeyCode = 22 Then
            take = Len(pIncoming)
         Else
            take = me._sel + 1
         End If
         If take < 0 Then
            take = 0
         End If
         If take > Len(pIncoming) Then
            take = Len(pIncoming)
         End If
         Dim rawWanted As Integer = 0
         If take > 0 Then
            rawWanted = Len(me._extractRaw(Left(pIncoming, take), me._pattern))
         End If
         _caretFromKey = me._caretAfterRaw(rawWanted)
      End Function

      Private Function _caretAfterRaw(pRawCount As Integer) As Integer
         If pRawCount <= 0 Then
            _caretAfterRaw = 0
            Exit Function
         End If
         Dim seen As Integer = 0
         Dim pos As Integer = 0
         Dim i As Integer
         Dim n As Integer = Len(me._pattern)
         For i = 1 To n
            Dim mc As String = Mid(me._pattern, i, 1)
            If me._isMaskToken(mc) Then
               seen = seen + 1
               pos = pos + 1
               If seen = pRawCount Then
                  Exit For
               End If
            Else
               If seen > 0 Then
                  pos = pos + 1
               End If
            End If
         Next
         _caretAfterRaw = pos
      End Function

      Private Function _isMaskToken(pChar As String) As Boolean
         If pChar = "9" Or pChar = "A" Or pChar = "C" Then
            _isMaskToken = True
         Else
            _isMaskToken = False
         End If
      End Function

      Private Function _charFits(pToken As String, pChar As String) As Boolean
         If pToken = "9" Then
            _charFits = CBool(pChar >= "0" And pChar <= "9")
         ElseIf pToken = "A" Then
            _charFits = CBool(pChar >= "A" And pChar <= "Z")
         ElseIf pToken = "C" Then
            _charFits = CBool((pChar >= "0" And pChar <= "9") Or (pChar >= "A" And pChar <= "Z"))
         Else
            _charFits = False
         End If
      End Function

      Private Function _keepRawChar(pChar As String, pMask As String) As Boolean
         Dim i As Integer
         Dim n As Integer = Len(pMask)
         For i = 1 To n
            If me._charFits(Mid(pMask, i, 1), pChar) Then
               _keepRawChar = True
               Exit Function
            End If
         Next
         _keepRawChar = False
      End Function

      Private Function _extractRaw(pValue As String, pMask As String) As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = Len(pValue)
         For i = 1 To n
            Dim ch As String = UCase(Mid(pValue, i, 1))
            If me._keepRawChar(ch, pMask) Then
               result = result + ch
            End If
         Next
         _extractRaw = result
      End Function

      Private Function _applyMask(pValue As String) As String
         Dim mask As String = me._pattern
         If mask = "" Then
            _applyMask = pValue
            Exit Function
         End If
         Dim raw As String = me._extractRaw(pValue, mask)
         Dim out As String = ""
         Dim ri As Integer = 1
         Dim i As Integer
         Dim n As Integer = Len(mask)
         For i = 1 To n
            Dim mc As String = Mid(mask, i, 1)
            If me._isMaskToken(mc) Then
               While ri <= Len(raw)
                  If me._charFits(mc, Mid(raw, ri, 1)) Then
                     Exit While
                  End If
                  ri = ri + 1
               Wend
               If ri > Len(raw) Then
                  Exit For
               End If
               out = out + Mid(raw, ri, 1)
               ri = ri + 1
            Else
               If Len(out) = 0 Then
                  Exit For
               End If
               If ri > Len(raw) Then
                  Exit For
               End If
               out = out + mc
            End If
         Next
         _applyMask = out
      End Function

      Protected Overridable Sub _handleKeyPress(pSender As TObject, ByRef pKey As Char)
         me._key = pKey
         me._sel = me.TextEditor.SelStart
         If me.OnPreviewKeyPress <> Null Then
            me.OnPreviewKeyPress(pSender, pKey)
         End If
         If me._pattern <> "" Then
            Dim code As Integer = CInt(Asc(pKey))
            If code >= 32 Then
               If me.TextEditor.SelLength = 0 Then
                  If Len(me.TextEditor.Text) >= Len(me._pattern) Then
                     pKey = Char(0)
                  End If
               End If
            End If
         End If
      End Sub

      Protected Overridable Sub _handleEnter(pSender As TObject)
         me._focused = True
         me._updateVisual()
      End Sub

      Protected Overridable Sub _handleExit(pSender As TObject)
         If me._updating Or me._inChange Then
            Exit Sub
         End If
         me._focused = False
         me._updateVisual()
      End Sub

      Protected Overridable Sub _handleMouseEnter(pSender As TObject)
         me._mouseInClient = True
         me._updateVisual()
      End Sub

      Protected Overridable Sub _handleMouseLeave(pSender As TObject)
         me._mouseInClient = False
         me._updateVisual()
      End Sub

      Protected Overridable Sub _handleImgMouseEnter(pSender As TObject)
         me._pnlImgBtn.Color = me.BTN_FOCUSED
         me._handleMouseEnter(pSender)
      End Sub

      Protected Overridable Sub _handleImgMouseLeave(pSender As TObject)
         me._pnlImgBtn.Color = me.BTN_NORMAL
         me._handleMouseLeave(pSender)
      End Sub

      Protected Overridable Sub _handleImgMouseMove(pSender As TObject, pShift As TShiftState, pX As Integer, pY As Integer)
         If me._pnlImgBtn.Color = me.BTN_PRESSED Then
            me._pnlImgBtn.Color = me.BTN_FOCUSED
         End If
      End Sub

      Private Sub _handleButtonClick(pSender As TObject)
         me._pnlImgBtn.Color = me.BTN_PRESSED
         If me.OnButtonClick <> Null Then
            me.OnButtonClick(pSender)
         End If
      End Sub

      Protected Overridable Sub _updateVisual()
         If Not me._enabled Then
            me.Container.Color = me.BORDER_NORMAL
            me.TextEditor.Color = me.EDIT_DISABLED
            me._pnlImgCtx.Color = me.EDIT_DISABLED
            me.TextEditor.Enabled = False
            me.ButtonEditor.Enabled = False
            Exit Sub
         End If

         me.TextEditor.Enabled = True
         me.ButtonEditor.Enabled = True

         me.Container.Color = (me._focused Or me._mouseInClient) ? me.BORDER_FOCUSED : me.BORDER_NORMAL
         me.TextEditor.ReadOnly = me._readonly

         If me._readonly Then
            me.TextEditor.Color = me.EDIT_READONLY
            me._pnlImgCtx.Color = me.EDIT_READONLY
         ElseIf me._focused Then
            me.TextEditor.Color = me.EDIT_FOCUSED
            me._pnlImgCtx.Color = me.EDIT_FOCUSED
         Else
            me.TextEditor.Color = me.EDIT_NORMAL
            me._pnlImgCtx.Color = me.EDIT_NORMAL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TButtonEditor
      Inherits TLabeledEditor<TextBox>

      Protected _button As ButtonedTextBox

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Property Button As Imagem
         Get
            Button = me._button.ButtonEditor
         End Get
      End Property

      Property Chrome As ButtonedTextBox
         Get
            Chrome = me._button
         End Get
      End Property

      Protected _rejectLeave As Boolean
      Protected _justValidated As Boolean

      OnButtonClick As TNotifyEvent

      Protected Overrides Sub OnBuilt()
         me._button.OnPreviewKeyPress = me._firePreviewKey
         me._button.OnBeforeChange = me._fireBeforeMask
         me._button.OnChange = me._fireOnChange
         me._button.OnButtonClick = me._fireOnButtonClick
         me._control.OnKeyDown = me._handleEditorKeyDown
      End Sub

      Protected Overridable Sub OnEditorBeforeMask()
      End Sub

      Protected Overridable Sub OnEditorKeyPress(ByRef pKey As Char)
      End Sub

      Private Sub _fireBeforeMask(pSender As TObject)
         me.OnEditorBeforeMask()
      End Sub

      Private Sub _firePreviewKey(pSender As TObject, ByRef pKey As Char)
         me.OnEditorKeyPress(pKey)
      End Sub

      Protected Overrides Function ShouldRunValidate() As Boolean
         ShouldRunValidate = CBool((Not me._button.Updating) And (Not me._button.InChange))
      End Function

      Protected Overrides Sub _handleExit(pSender As TObject)
         If me._button.Updating Or me._button.InChange Then
            Exit Sub
         End If
         If me._justValidated Then
            me._justValidated = False
            Exit Sub
         End If
         MyBase._handleExit(pSender)
      End Sub

      Protected Overrides Sub _bindEditValueEvents()
         me._nativeOnFocusChanged = me._control.OnFocusChanged
         me._control.OnFocusChanged = me._handleFocusChanged
      End Sub

      Private Sub _handleEditorKeyDown(pSender As TObject, ByRef pKey As Word, pShift As TShiftState)
         If (pKey <> 9) And (pKey <> 13) Then
            Exit Sub
         End If
         me._rejectLeave = False
         If me.OnValidate <> Null Then
            If me.ShouldRunValidate() Then
               me.OnValidate(me)
            End If
         End If
         me._justValidated = True
         If me._rejectLeave Then
            pKey = 0
         End If
      End Sub

      Private Sub _fireOnChange(pSender As TObject)
         me._rejectLeave = False
         me._justValidated = False
         If me.OnChange <> NULL Then
            me.OnChange(pSender)
         End If
      End Sub

      Private Sub _fireOnButtonClick(pSender As TObject)
         If me.OnButtonClick <> NULL Then
            me.OnButtonClick(pSender)
         End If
      End Sub

      Property ImageBase64 As String
         Get
            ImageBase64 = ""
         End Get
         Set(pValue As String)
            me._setImageBase64(pValue)
         End Set
      End Property

      Private Sub _setImageBase64(pValue As String)
         me._button.LoadFromBase64(pValue)
      End Sub

      Property ImagePath As String
         Get
            ImagePath = ""
         End Get
         Set(pValue As String)
            me._setImagePath(pValue)
         End Set
      End Property

      Private Sub _setImagePath(pValue As String)
         me._button.LoadFromFile(pValue)
      End Sub

      Property ButtonHint As String
         Get
            ButtonHint = me._button.ButtonEditor.Hint
         End Get
         Set(pValue As String)
            me._setButtonHint(pValue)
         End Set
      End Property

      Private Sub _setButtonHint(pValue As String)
         me._button.ButtonEditor.ShowHint = True
         me._button.ButtonEditor.Hint = pValue
      End Sub

      Property ButtonVisible As Boolean
         Get
            ButtonVisible = me._button.ButtonVisible
         End Get
         Set(pValue As Boolean)
            me._setButtonVisible(pValue)
         End Set
      End Property

      Private Sub _setButtonVisible(pValue As Boolean)
         me._button.ButtonVisible = pValue
      End Sub

      Property Mascara As String
         Get
            Mascara = me._button.Mask
         End Get
         Set(pValue As String)
            me._setMascara(pValue)
         End Set
      End Property

      Private Sub _setMascara(pValue As String)
         me._button.Mask = pValue
         If pValue <> "" Then
            me._control.MaxLength = 255
         End If
      End Sub

      Property Mask As String
         Get
            Mask = me.Mascara
         End Get
         Set(pValue As String)
            me._setMask(pValue)
         End Set
      End Property

      Private Sub _setMask(pValue As String)
         me.Mascara = pValue
      End Sub

      Protected Overrides Sub CreateControl()
         me._button = New ButtonedTextBox(me._slot)
         me._button.Align = alClient
         me._control = me._button.TextEditor
      End Sub

      Protected Overrides Function GetReadOnly() As Boolean
         GetReadOnly = me._button.OnlyRead
      End Function

      Protected Overrides Sub SetReadOnly(pValue As Boolean)
         me._button.OnlyRead = pValue
      End Sub

      Protected Overrides Function GetEnabled() As Boolean
         GetEnabled = me._button.Enabled
      End Function

      Protected Overrides Sub SetEnabled(pValue As Boolean)
         me._host.Enabled = pValue
         me._button.Enabled = pValue
      End Sub

      Protected Overrides Function GetText() As String
         GetText = me._button.Text
      End Function

      Protected Overridable Overrides Sub SetText(pValue As String)
         me._button.Text = pValue
      End Sub

      Protected Overrides Sub SetMaxLength(pValue As Integer)
         If me._button.Mask <> "" Then
            me._control.MaxLength = 255
         Else
            me._control.MaxLength = pValue
         End If
      End Sub

      Protected Overrides Sub OnApply(pProps As TEditorProps)
         If pProps.Mask <> "" Then
            me.Mascara = pProps.Mask
         End If
      End Sub

      Function OnlyDigits() As String
         OnlyDigits = me.Text.Trim().Replace(".", "").Replace("-", "").Replace("/", "").Replace(" ", "").Replace("(", "").Replace(")", "")
      End Function

      Overrides Sub Free()
         If me._button <> NULL Then
            me._button.Free()
            me._button = NULL
         End If
         MyBase.Free()
      End Sub
   End Class

End Namespace
