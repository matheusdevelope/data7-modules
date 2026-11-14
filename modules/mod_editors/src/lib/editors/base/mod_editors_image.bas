Imports mod_editors
Imports mod_clipboard_manager
Imports mod_camera
Imports Forms

Namespace mod_editors_image

   Class TImageEditor
      Inherits TLabeledEditor<Imagem>

      Private _payload As String
      Private _readonly As Boolean
      Private _shell As PageControl
      Private _imgBox As PageControl
      Private _footer As CustomControl
      Private _btnOpen As CommandButton
      Private _btnCapture As CommandButton
      Private _btnSave As CommandButton
      Private _btnCopy As CommandButton
      Private _btnPaste As CommandButton
      Private _btnClear As CommandButton
      Private _clip As Clipboard

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.EditorHeight = 400
      End Sub

      Protected Overrides Sub CreateControl()
         me._shell = New PageControl(me._slot)
         me._shell.Align = alClient
         me._shell.ShowCardFrame = False
         me._shell.ShowShadow = False
         me._shell.TabStop = False

         me._footer = New CustomControl(me._shell)
         me._footer.Align = alBottom
         me._footer.AlignWithMargins = True
         me._footer.Height = 30
         me._footer.TabStop = False

         me._btnCapture = me._makeButton("Capturar", "Capturar imagem pela câmera", me._handleCapture)
         me._btnOpen = me._makeButton("Abrir", "Abrir imagem de um arquivo", me._handleOpen)
         me._btnSave = me._makeButton("Salvar", "Salvar imagem em um arquivo", me._handleSave)
         me._btnCopy = me._makeButton("Copiar", "Copiar imagem para a área de transferência", me._handleCopy)
         me._btnPaste = me._makeButton("Colar", "Colar imagem da área de transferência", me._handlePaste)
         me._btnClear = me._makeButton("Limpar", "Remover a imagem", me._handleClear)

         me._imgBox = New PageControl(me._shell)
         me._imgBox.Color = RGB(255, 255, 255)
         me._imgBox.ShowCardFrame = False
         me._imgBox.ShowShadow = False
         me._imgBox.Align = alClient
         me._imgBox.AlignWithMargins = True
         me._imgBox.TabStop = False

         me._control = New Imagem(me._imgBox)
         me._control.Align = alClient
         me._control.Stretch = True
         me._control.Proportional = True
         me._control.Center = True
      End Sub

      Private Function _makeButton(pCaption As String, pHint As String, pHandler As TNotifyEvent) As CommandButton
         Dim btn As New CommandButton(me._footer)
         btn.Text = pCaption
         btn.Align = alLeft
         btn.Width = 90
         btn.AlignWithMargins = True
         btn.ShowHint = True
         btn.Hint = pHint
         btn.OnClick = pHandler
         btn.TabStop = False
         _makeButton = btn
      End Function

      Protected Overrides Sub OnBuilt()
         me.EditorHeight = 250
         me.Control.Stretch = True
         me.Control.Proportional = True
         me.Control.Center = True
      End Sub

      Overrides Function GetBoundText() As String
         GetBoundText = me._payload
      End Function

      Overrides Sub SetBoundText(pValue As String)
         me.LoadFromBase64(pValue)
      End Sub

      Protected Overrides Function GetReadOnly() As Boolean
         GetReadOnly = me._readonly
      End Function

      Protected Overrides Sub SetReadOnly(pValue As Boolean)
         me._readonly = pValue
         me._syncButtons()
      End Sub

      Protected Overrides Function GetEnabled() As Boolean
         GetEnabled = me._host.Enabled
      End Function

      Protected Overrides Sub SetEnabled(pValue As Boolean)
         me._host.Enabled = pValue
         me._syncButtons()
      End Sub

      Private Sub _syncButtons()
         Dim canEdit As Boolean = CBool((Not me._readonly) And me._host.Enabled)
         me._btnOpen.Enabled = canEdit
         me._btnCapture.Enabled = canEdit
         me._btnPaste.Enabled = canEdit
         me._btnClear.Enabled = canEdit
         me._btnSave.Enabled = me._host.Enabled
         me._btnCopy.Enabled = me._host.Enabled
      End Sub

      Private Function _fileFilter() As String
         _fileFilter = "Imagens (*.bmp; *.jpg; *.png; *.gif; *.ico; *.webp)|*.bmp;*.jpg;*.jpeg;*.png;*.gif;*.ico;*.webp|Bitmap (*.bmp)|*.bmp|JPEG (*.jpg; *.jpeg)|*.jpg;*.jpeg|PNG (*.png)|*.png|GIF (*.gif)|*.gif|Ícone (*.ico)|*.ico|WebP (*.webp)|*.webp|SVG (*.svg)|*.svg|Todos os arquivos (*.*)|*.*"
      End Function

      Private Function _extensionFromPayload() As String
         Dim raw As String = Trim(me._payload)
         If raw.StartsWith("iVBORw0KGgo") Then
            _extensionFromPayload = "*.png"
         ElseIf raw.StartsWith("/9j/") Then
            _extensionFromPayload = "*.jpg"
         ElseIf raw.StartsWith("R0lGOD") Then
            _extensionFromPayload = "*.gif"
         ElseIf raw.StartsWith("UklGR") Then
            _extensionFromPayload = "*.webp"
         ElseIf raw.StartsWith("PHN2Zy") Then
            _extensionFromPayload = "*.svg"
         ElseIf raw.StartsWith("AAABAA") Then
            _extensionFromPayload = "*.ico"
         ElseIf raw.StartsWith("Qk") Then
            _extensionFromPayload = "*.bmp"
         Else
            _extensionFromPayload = "*.png"
         End If
      End Function

      Private Sub _showImage(pVisible As Boolean)
         me.Control.Visible = pVisible
      End Sub

      Private Sub _fireChange()
         If me.OnChange <> NULL Then
            me.OnChange(me)
         End If
      End Sub

      Private Sub _handleOpen(pSender As TObject)
         me.Open()
      End Sub

      Private Sub _handleCapture(pSender As TObject)
         me.CaptureFromCamera()
      End Sub

      Private Sub _handleSave(pSender As TObject)
         me.Save()
      End Sub

      Private Sub _handleCopy(pSender As TObject)
         me.Copy()
      End Sub

      Private Sub _handlePaste(pSender As TObject)
         me.Paste()
      End Sub

      Private Sub _handleClear(pSender As TObject)
         me.Clear()
      End Sub

      Property HasImage As Boolean
         Get
            HasImage = CBool(Trim(me._payload) <> "")
         End Get
      End Property

      Sub Open()
         If me._readonly Then
            Exit Sub
         End If
         Dim chosen As String = Trim(TDialogs.OpenFile("Abrir imagem", me._fileFilter(), ""))
         If chosen <> "" Then
            me.LoadFromFile(chosen)
            me._fireChange()
         End If
      End Sub

      Sub CaptureFromCamera()
         If me._readonly Then
            Exit Sub
         End If
         Dim cam As New TCamera()
         Dim foto As String = cam.Capture()
         cam.Free()
         If Trim(foto) = "" Then
            Exit Sub
         End If
         If TFile.Exists(foto) Then
            me.LoadFromFile(foto)
            TFile.Delete(foto)
         Else
            me.LoadFromBase64(foto)
         End If
         me._fireChange()
      End Sub

      Sub Save()
         If Trim(me._payload) = "" Then
            Exit Sub
         End If
         Dim workExt As String = me._extensionFromPayload()
         Dim chosen As String = Trim(TDialogs.SaveFile("Salvar imagem", me._fileFilter(), "", workExt))
         If chosen <> "" Then
            Base64ToFile(me._payload, chosen)
         End If
      End Sub

      Sub Copy()
         If Trim(me._payload) <> "" Then
            ClipboardManager.SetImageFromBase64(me._payload)
         End If
      End Sub

      Sub Paste()
         If me._readonly Then
            Exit Sub
         End If
         If Not ClipboardManager.HasImage() Then
            Exit Sub
         End If
         me.LoadFromBase64(ClipboardManager.GetImageAsBase64())
         me._fireChange()
      End Sub

      Sub Clear()
         If me._readonly Then
            Exit Sub
         End If
         me._payload = ""
         me._showImage(False)
         me._fireChange()
      End Sub

      Sub LoadFromFile(pPath As String)
         Dim chosen As String = Trim(pPath)
         If chosen = "" Then
            me._payload = ""
            me._showImage(False)
            Exit Sub
         End If
         me.Control.LoadFromFile(chosen)
         me._payload = FileToBase64(chosen)
         me._showImage(True)
      End Sub

      Sub LoadFromBase64(pBase64 As String)
         Dim raw As String = Trim(pBase64)
         me._payload = raw
         If raw <> "" Then
            me.Control.LoadFromBase64(raw)
            me._showImage(True)
         Else
            me._showImage(False)
         End If
      End Sub

      Overrides Sub Free()
         If Assigned(me._clip) Then
            me._clip.Free()
            me._clip = NULL
         End If
         MyBase.Free()
      End Sub
   End Class

End Namespace
