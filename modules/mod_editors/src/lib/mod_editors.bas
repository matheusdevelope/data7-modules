' data7:external-type TCharacterCasing scope=file

Imports Forms
Imports mod_tenum

Namespace mod_editors

   Enun TLabelPlacement
      Left = "Left"
      Top = "Top"
      Right = "Right"
      Bottom = "Bottom"
      Hidden = "Hidden"
   End Enun

   Private Dim _enumReady As Boolean
   Private Dim _placementLeft As TLabelPlacement
   Private Dim _placementTop As TLabelPlacement
   Private Dim _placementRight As TLabelPlacement
   Private Dim _placementBottom As TLabelPlacement
   Private Dim _placementHidden As TLabelPlacement

   Private Sub _initializeEnums()
      If Not _enumReady Then
         _placementLeft = TLabelPlacement.Left()
         _placementTop = TLabelPlacement.Top()
         _placementRight = TLabelPlacement.Right()
         _placementBottom = TLabelPlacement.Bottom()
         _placementHidden = TLabelPlacement.Hidden()
         _enumReady = True
      End If
   End Sub

   Class TFontFace
      Private _name As String
      Private _size As Integer
      Private _color As Integer
      Private _bold As Boolean
      Private _italic As Boolean
      Private _underline As Boolean
      Private _hasName As Boolean
      Private _hasSize As Boolean
      Private _hasColor As Boolean
      Private _hasBold As Boolean
      Private _hasItalic As Boolean
      Private _hasUnderline As Boolean
      Private _silent As Boolean
      Private _host As TLabeledEditorBase
      Private _kindLabel As Boolean

      Sub New()
         MyBase.New()
         me._color = -1
      End Sub

      Sub Bind(pHost As TLabeledEditorBase, pKindLabel As Boolean)
         me._host = pHost
         me._kindLabel = pKindLabel
      End Sub

      Property Name As String
         Get
            If me._host <> Null Then
               Name = me._host.ReadMappedFontName(me._kindLabel, me._name)
            Else
               Name = me._name
            End If
         End Get
         Set(pValue As String)
            me._setName(pValue)
         End Set
      End Property

      Private Sub _setName(pValue As String)
         me._name = pValue
         me._hasName = True
         me._writeName()
      End Sub

      Property Size As Integer
         Get
            If me._host <> Null Then
               Size = me._host.ReadMappedFontSize(me._kindLabel, me._size)
            Else
               Size = me._size
            End If
         End Get
         Set(pValue As Integer)
            me._setSize(pValue)
         End Set
      End Property

      Private Sub _setSize(pValue As Integer)
         me._size = pValue
         me._hasSize = True
         me._writeSize()
      End Sub

      Property Color As Integer
         Get
            If me._host <> Null Then
               Color = me._host.ReadMappedFontColor(me._kindLabel, me._color)
            Else
               Color = me._color
            End If
         End Get
         Set(pValue As Integer)
            me._setColor(pValue)
         End Set
      End Property

      Private Sub _setColor(pValue As Integer)
         me._color = pValue
         me._hasColor = True
         me._writeColor()
      End Sub

      Property Bold As Boolean
         Get
            If me._host <> Null Then
               Bold = me._host.ReadMappedFontBold(me._kindLabel, me._bold)
            Else
               Bold = me._bold
            End If
         End Get
         Set(pValue As Boolean)
            me._setBold(pValue)
         End Set
      End Property

      Private Sub _setBold(pValue As Boolean)
         me._bold = pValue
         me._hasBold = True
         me._writeBold()
      End Sub

      Property Italic As Boolean
         Get
            If me._host <> Null Then
               Italic = me._host.ReadMappedFontItalic(me._kindLabel, me._italic)
            Else
               Italic = me._italic
            End If
         End Get
         Set(pValue As Boolean)
            me._setItalic(pValue)
         End Set
      End Property

      Private Sub _setItalic(pValue As Boolean)
         me._italic = pValue
         me._hasItalic = True
         me._writeItalic()
      End Sub

      Property Underline As Boolean
         Get
            If me._host <> Null Then
               Underline = me._host.ReadMappedFontUnderline(me._kindLabel, me._underline)
            Else
               Underline = me._underline
            End If
         End Get
         Set(pValue As Boolean)
            me._setUnderline(pValue)
         End Set
      End Property

      Private Sub _setUnderline(pValue As Boolean)
         me._underline = pValue
         me._hasUnderline = True
         me._writeUnderline()
      End Sub

      Sub Apply(pName As String = "", pSize As Integer = 0, pBold As Boolean = False, pItalic As Boolean = False, pColor As Integer = -1, pUnderline As Boolean = False)
         me._silent = True
         If pName <> "" Then
            me._name = pName
            me._hasName = True
         End If
         If pSize > 0 Then
            me._size = pSize
            me._hasSize = True
         End If
         me._bold = pBold
         me._hasBold = True
         me._italic = pItalic
         me._hasItalic = True
         me._underline = pUnderline
         me._hasUnderline = True
         If pColor >= 0 Then
            me._color = pColor
            me._hasColor = True
         End If
         me._silent = False
         me._flush()
      End Sub

      Private Sub _writeName()
         If me._silent Then
            Exit Sub
         End If
         If me._host <> Null Then
            me._host.WriteMappedFontName(me._kindLabel, me._name)
         End If
      End Sub

      Private Sub _writeSize()
         If me._silent Then
            Exit Sub
         End If
         If me._host <> Null Then
            me._host.WriteMappedFontSize(me._kindLabel, me._size)
         End If
      End Sub

      Private Sub _writeColor()
         If me._silent Then
            Exit Sub
         End If
         If me._host <> Null Then
            me._host.WriteMappedFontColor(me._kindLabel, me._color)
         End If
      End Sub

      Private Sub _writeBold()
         If me._silent Then
            Exit Sub
         End If
         If me._host <> Null Then
            me._host.WriteMappedFontBold(me._kindLabel, me._bold)
         End If
      End Sub

      Private Sub _writeItalic()
         If me._silent Then
            Exit Sub
         End If
         If me._host <> Null Then
            me._host.WriteMappedFontItalic(me._kindLabel, me._italic)
         End If
      End Sub

      Private Sub _writeUnderline()
         If me._silent Then
            Exit Sub
         End If
         If me._host <> Null Then
            me._host.WriteMappedFontUnderline(me._kindLabel, me._underline)
         End If
      End Sub

      Private Sub _flush()
         If me._host = Null Then
            Exit Sub
         End If
         If me._hasName Then
            me._host.WriteMappedFontName(me._kindLabel, me._name)
         End If
         If me._hasSize Then
            me._host.WriteMappedFontSize(me._kindLabel, me._size)
         End If
         If me._hasColor Then
            me._host.WriteMappedFontColor(me._kindLabel, me._color)
         End If
         If me._hasBold Then
            me._host.WriteMappedFontBold(me._kindLabel, me._bold)
         End If
         If me._hasItalic Then
            me._host.WriteMappedFontItalic(me._kindLabel, me._italic)
         End If
         If me._hasUnderline Then
            me._host.WriteMappedFontUnderline(me._kindLabel, me._underline)
         End If
      End Sub

      Sub Free()
         me._host = Null
         MyBase.Free()
      End Sub
   End Class

   Class TEditorProps
      Caption As String
      FieldName As String
      Placement As TLabelPlacement
      LabelWidth As Integer
      LabelSpacing As Integer
      EditorHeight As Integer
      Align As TAlign
      Width As Integer
      Height As Integer
      Left As Integer
      Top As Integer
      Enabled As Boolean
      Visible As Boolean
      TabStop As Boolean
      TabOrder As Integer
      Required As Boolean
      RequiredColor As Integer
      Hint As String
      Ajuda As String
      TextHint As String
      OnlyRead As Boolean
      MaxLength As Integer
      Mask As String
      CharCase As TCharacterCasing
      LabelName As String
      LabelSize As Integer
      LabelBold As Boolean
      LabelItalic As Boolean
      LabelColor As Integer
      EditorName As String
      EditorSize As Integer
      EditorBold As Boolean
      EditorItalic As Boolean
      EditorUnderline As Boolean
      EditorColor As Integer
      EditorBackColor As Integer
      EditorAlignment As String
      DecimalPlaces As Integer
      DisplayFormat As String
      ShowTime As Boolean
      TimeOnly As Boolean
      ListaOpcoes As String
      CodPesquisa As Integer
      TipoPesquisa As String
      PesquisaIncremental As Boolean
      ExpressaoFiltro As String

      Sub New()
         MyBase.New()
         _initializeEnums()
         me.Placement = _placementLeft
         me.LabelWidth = 80
         me.LabelSpacing = 6
         me.EditorHeight = 0
         me.Align = alTop
         me.Enabled = True
         me.Visible = True
         me.TabStop = True
         me.TabOrder = -1
         me.Left = -1
         me.Top = -1
         me.LabelColor = -1
         me.EditorColor = -1
         me.EditorBackColor = -1
         me.RequiredColor = -1
         me.DecimalPlaces = -1
         me.CharCase = ccNormal
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Function CharCaseFromCode(pCode As String) As TCharacterCasing
      Dim code As String = UCase(Trim(pCode))
      If code = "U" Then
         CharCaseFromCode = ccUpper
      ElseIf code = "L" Then
         CharCaseFromCode = ccLower
      Else
         CharCaseFromCode = ccNormal
      End If
   End Function

   MustInherit Class TLabeledEditorBase
      FieldName As String
      EditorAlignment As String

      Protected _host As CustomControl
      Protected _label As StaticText
      Protected _slot As CustomControl
      Protected _labelFont As TFontFace
      Protected _editorFont As TFontFace
      Protected _placement As TLabelPlacement
      Protected _labelWidth As Integer
      Protected _spacing As Integer
      Protected _editorHeight As Integer
      Protected _caption As String
      Protected _required As Boolean
      Protected _requiredColor As Integer
      Protected _idleLabelColor As Integer
      Protected _charCase As TCharacterCasing

      OnExit As TNotifyEvent
      OnEnter As TNotifyEvent
      OnValidate As TNotifyEvent
      OnKeyPress As TKeyPressEvent
      OnClick As TNotifyEvent
      OnDblClick As TNotifyEvent
      OnChange As TNotifyEvent
      OnFocusChanged As TNotifyEvent

      Protected _nativeOnExit As TNotifyEvent
      Protected _nativeOnEnter As TNotifyEvent
      Protected _nativeOnKeyPress As TKeyPressEvent
      Protected _nativeOnClick As TNotifyEvent
      Protected _nativeOnDblClick As TNotifyEvent
      Protected _nativeOnChange As TNotifyEvent
      Protected _nativeOnFocusChanged As TNotifyEvent

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New()
         _initializeEnums()
         me._placement = _placementLeft
         me._labelWidth = 80
         me._spacing = 6
         me._editorHeight = 27
         me._requiredColor = RGB(0, 0, 255)
         me._idleLabelColor = -1
         me._charCase = ccNormal
         me._build(pParent, pCaption, pProps)
      End Sub

      Private Sub _build(pParent As TWinControl, pCaption As String, pProps As TEditorProps)
         me._host = New CustomControl(pParent)
         me._host.Align = alTop

         me._label = New StaticText(me._host)
         me._label.AutoSize = False
         me._label.WordWrap = True
         me._label.AlignWithMargins = True

         me._slot = New CustomControl(me._host)
         me._slot.AlignWithMargins = True

         me.CreateControl()
         me._labelFont = New TFontFace()
         me._labelFont.Bind(me, True)
         me._editorFont = New TFontFace()
         me._editorFont.Bind(me, False)
         me._bindNativeEvents()
         me.Caption = pCaption
         me.OnBuilt()
         me._relayout()
         If pProps <> Null Then
            me.Apply(pProps)
         End If
      End Sub

      Protected MustOverride Overridable Sub CreateControl()
      End Sub

      Protected Overridable Sub OnBuilt()
      End Sub

      Protected Overridable Sub OnApply(pProps As TEditorProps)
      End Sub

      Overridable Function ReadMappedFontName(pIsLabel As Boolean, pFallback As String) As String
         If pIsLabel Then
            ReadMappedFontName = me._readLabelFontName()
         Else
            ReadMappedFontName = pFallback
         End If
      End Function

      Overridable Sub WriteMappedFontName(pIsLabel As Boolean, pValue As String)
         If pIsLabel Then
            me._writeLabelFontName(pValue)
         End If
      End Sub

      Overridable Function ReadMappedFontSize(pIsLabel As Boolean, pFallback As Integer) As Integer
         If pIsLabel Then
            ReadMappedFontSize = me._readLabelFontSize()
         Else
            ReadMappedFontSize = pFallback
         End If
      End Function

      Overridable Sub WriteMappedFontSize(pIsLabel As Boolean, pValue As Integer)
         If pIsLabel Then
            me._writeLabelFontSize(pValue)
         End If
      End Sub

      Overridable Function ReadMappedFontColor(pIsLabel As Boolean, pFallback As Integer) As Integer
         If pIsLabel Then
            ReadMappedFontColor = me._readLabelFontColor()
         Else
            ReadMappedFontColor = pFallback
         End If
      End Function

      Overridable Sub WriteMappedFontColor(pIsLabel As Boolean, pValue As Integer)
         If pIsLabel Then
            me._writeLabelFontColor(pValue)
         End If
      End Sub

      Overridable Function ReadMappedFontBold(pIsLabel As Boolean, pFallback As Boolean) As Boolean
         If pIsLabel Then
            ReadMappedFontBold = me._readLabelFontBold()
         Else
            ReadMappedFontBold = pFallback
         End If
      End Function

      Overridable Sub WriteMappedFontBold(pIsLabel As Boolean, pValue As Boolean)
         If pIsLabel Then
            me._writeLabelFontBold(pValue)
         End If
      End Sub

      Overridable Function ReadMappedFontItalic(pIsLabel As Boolean, pFallback As Boolean) As Boolean
         If pIsLabel Then
            ReadMappedFontItalic = me._readLabelFontItalic()
         Else
            ReadMappedFontItalic = pFallback
         End If
      End Function

      Overridable Sub WriteMappedFontItalic(pIsLabel As Boolean, pValue As Boolean)
         If pIsLabel Then
            me._writeLabelFontItalic(pValue)
         End If
      End Sub

      Overridable Function ReadMappedFontUnderline(pIsLabel As Boolean, pFallback As Boolean) As Boolean
         If pIsLabel Then
            ReadMappedFontUnderline = me._readLabelFontUnderline()
         Else
            ReadMappedFontUnderline = pFallback
         End If
      End Function

      Overridable Sub WriteMappedFontUnderline(pIsLabel As Boolean, pValue As Boolean)
         If pIsLabel Then
            me._writeLabelFontUnderline(pValue)
         End If
      End Sub

      Private Function _readLabelFontName() As String
         _readLabelFontName = me._label.Font.Name
      End Function

      Private Sub _writeLabelFontName(pValue As String)
         me._label.Font.Name = pValue
      End Sub

      Private Function _readLabelFontSize() As Integer
         _readLabelFontSize = me._label.Font.Size
      End Function

      Private Sub _writeLabelFontSize(pValue As Integer)
         me._label.Font.Size = pValue
      End Sub

      Private Function _readLabelFontColor() As Integer
         _readLabelFontColor = me._label.Font.Color
      End Function

      Private Sub _writeLabelFontColor(pValue As Integer)
         me._label.Font.Color = pValue
      End Sub

      Private Function _readLabelFontBold() As Boolean
         _readLabelFontBold = me._label.Font.GetBold()
      End Function

      Private Sub _writeLabelFontBold(pValue As Boolean)
         me._label.Font.SetBold(pValue)
      End Sub

      Private Function _readLabelFontItalic() As Boolean
         _readLabelFontItalic = me._label.Font.GetItalic()
      End Function

      Private Sub _writeLabelFontItalic(pValue As Boolean)
         me._label.Font.SetItalic(pValue)
      End Sub

      Private Function _readLabelFontUnderline() As Boolean
         _readLabelFontUnderline = me._label.Font.GetUnderline()
      End Function

      Private Sub _writeLabelFontUnderline(pValue As Boolean)
         me._label.Font.SetUnderline(pValue)
      End Sub

      Protected Overridable Sub _bindNativeEvents()
         me._bindEditValueEvents()
      End Sub

      Protected Overridable Sub _bindEditValueEvents()
      End Sub

      Protected Overridable Sub _handleExit(pSender As TObject)
         If me._nativeOnExit <> Null Then
            me._nativeOnExit(pSender)
         End If
         If me.OnValidate <> Null Then
            If me.ShouldRunValidate() Then
               me.OnValidate(me)
            End If
         End If
         If me.OnExit <> Null Then
            me.OnExit(pSender)
         End If
      End Sub

      Protected Overridable Function ShouldRunValidate() As Boolean
         ShouldRunValidate = True
      End Function

      Protected Sub _handleEnter(pSender As TObject)
         If me._nativeOnEnter <> Null Then
            me._nativeOnEnter(pSender)
         End If
         If me.OnEnter <> Null Then
            me.OnEnter(pSender)
         End If
      End Sub

      Protected Overridable Sub OnControlKeyPress(ByRef pKey As Char)
      End Sub

      Protected Overridable Sub _handleKeyPress(pSender As TObject, ByRef pKey As Char)
         me.OnControlKeyPress(pKey)
         If CInt(Asc(pKey)) = 0 Then
            Exit Sub
         End If
         If me._nativeOnKeyPress <> Null Then
            me._nativeOnKeyPress(pSender, pKey)
         End If
         If me.OnKeyPress <> Null Then
            me.OnKeyPress(pSender, pKey)
         End If
      End Sub

      Protected Sub _handleClick(pSender As TObject)
         If me._nativeOnClick <> Null Then
            me._nativeOnClick(pSender)
         End If
         If me.OnClick <> Null Then
            me.OnClick(pSender)
         End If
      End Sub

      Protected Sub _handleDblClick(pSender As TObject)
         If me._nativeOnDblClick <> Null Then
            me._nativeOnDblClick(pSender)
         End If
         If me.OnDblClick <> Null Then
            me.OnDblClick(pSender)
         End If
      End Sub

      Protected Sub _handleChange(pSender As TObject)
         If me._nativeOnChange <> Null Then
            me._nativeOnChange(pSender)
         End If
         If me.OnChange <> Null Then
            me.OnChange(pSender)
         End If
      End Sub

      Protected Overridable Sub _handleFocusChanged(pSender As TObject)
         If me._nativeOnFocusChanged <> Null Then
            me._nativeOnFocusChanged(pSender)
         End If
         If me.OnFocusChanged <> Null Then
            me.OnFocusChanged(pSender)
         End If
      End Sub

      Property Host As CustomControl
         Get
            Host = me._host
         End Get
      End Property

      Property Label As StaticText
         Get
            Label = me._label
         End Get
      End Property

      Property Slot As CustomControl
         Get
            Slot = me._slot
         End Get
      End Property

      Property LabelFont As TFontFace
         Get
            LabelFont = me._labelFont
         End Get
      End Property

      Property EditorFont As TFontFace
         Get
            EditorFont = me._editorFont
         End Get
      End Property

      Property Caption As String
         Get
            Caption = me._caption
         End Get
         Set(pValue As String)
            me._setCaption(pValue)
         End Set
      End Property

      Private Sub _setCaption(pValue As String)
         me._caption = pValue
         me._applyCaption()
      End Sub

      Property Required As Boolean
         Get
            Required = me._required
         End Get
         Set(pValue As Boolean)
            me._setRequired(pValue)
         End Set
      End Property

      Private Sub _setRequired(pValue As Boolean)
         me._required = pValue
         me._applyCaption()
      End Sub

      Property RequiredColor As Integer
         Get
            RequiredColor = me._requiredColor
         End Get
         Set(pValue As Integer)
            me._setRequiredColor(pValue)
         End Set
      End Property

      Private Sub _setRequiredColor(pValue As Integer)
         me._requiredColor = pValue
         me._applyCaption()
      End Sub

      Private Sub _applyCaption()
         me._label.Caption = me._caption
         me._applyRequiredColor()
         me._relayout()
      End Sub

      Private Sub _applyRequiredColor()
         If me._required Then
            If me._idleLabelColor < 0 Then
               me._idleLabelColor = me.LabelFont.Color
            End If
            me.LabelFont.Color = me._requiredColor
         ElseIf me._idleLabelColor >= 0 Then
            me.LabelFont.Color = me._idleLabelColor
         End If
      End Sub

      Property LabelPlacement As TLabelPlacement
         Get
            LabelPlacement = me._placement
         End Get
         Set(pValue As TLabelPlacement)
            me._setLabelPlacement(pValue)
         End Set
      End Property

      Private Sub _setLabelPlacement(pValue As TLabelPlacement)
         me._placement = pValue
         me._relayout()
      End Sub

      Property LabelWidth As Integer
         Get
            LabelWidth = me._labelWidth
         End Get
         Set(pValue As Integer)
            me._setLabelWidth(pValue)
         End Set
      End Property

      Private Sub _setLabelWidth(pValue As Integer)
         me._labelWidth = pValue
         me._relayout()
      End Sub

      Property LabelSpacing As Integer
         Get
            LabelSpacing = me._spacing
         End Get
         Set(pValue As Integer)
            me._setLabelSpacing(pValue)
         End Set
      End Property

      Private Sub _setLabelSpacing(pValue As Integer)
         me._spacing = pValue
         me._relayout()
      End Sub

      Property EditorHeight As Integer
         Get
            EditorHeight = me._editorHeight
         End Get
         Set(pValue As Integer)
            me._setEditorHeight(pValue)
         End Set
      End Property

      Private Sub _setEditorHeight(pValue As Integer)
         me._editorHeight = pValue
         me._relayout()
      End Sub

      Property Align As TAlign
         Get
            Align = me._host.Align
         End Get
         Set(pValue As TAlign)
            me._setAlign(pValue)
         End Set
      End Property

      Private Sub _setAlign(pValue As TAlign)
         me._host.Align = pValue
      End Sub

      Property AlignWithMargins As Boolean
         Get
            AlignWithMargins = me._host.AlignWithMargins
         End Get
         Set(pValue As Boolean)
            me._setAlignWithMargins(pValue)
         End Set
      End Property

      Private Sub _setAlignWithMargins(pValue As Boolean)
         me._host.AlignWithMargins = pValue
      End Sub

      Property Left As Integer
         Get
            Left = me._host.Left
         End Get
         Set(pValue As Integer)
            me._setLeft(pValue)
         End Set
      End Property

      Private Sub _setLeft(pValue As Integer)
         me._host.Left = pValue
      End Sub

      Property Top As Integer
         Get
            Top = me._host.Top
         End Get
         Set(pValue As Integer)
            me._setTop(pValue)
         End Set
      End Property

      Private Sub _setTop(pValue As Integer)
         me._host.Top = pValue
      End Sub

      Property Width As Integer
         Get
            Width = me._host.Width
         End Get
         Set(pValue As Integer)
            me._setWidth(pValue)
         End Set
      End Property

      Private Sub _setWidth(pValue As Integer)
         me._host.Width = pValue
      End Sub

      Property Height As Integer
         Get
            Height = me._host.Height
         End Get
         Set(pValue As Integer)
            me._setHeight(pValue)
         End Set
      End Property

      Private Sub _setHeight(pValue As Integer)
         me._host.Height = pValue
      End Sub

      Property Visible As Boolean
         Get
            Visible = me._host.Visible
         End Get
         Set(pValue As Boolean)
            me._setVisible(pValue)
         End Set
      End Property

      Private Sub _setVisible(pValue As Boolean)
         me._host.Visible = pValue
      End Sub

      Property Enabled As Boolean
         Get
            Enabled = me.GetEnabled()
         End Get
         Set(pValue As Boolean)
            me.SetEnabled(pValue)
         End Set
      End Property

      Protected Overridable Function GetEnabled() As Boolean
         GetEnabled = me._host.Enabled
      End Function

      Protected Overridable Sub SetEnabled(pValue As Boolean)
         me._host.Enabled = pValue
      End Sub

      Property Hint As String
         Get
            Hint = me.GetControlHint()
         End Get
         Set(pValue As String)
            me._setHint(pValue)
         End Set
      End Property

      Private Sub _setHint(pValue As String)
         me._host.ShowHint = True
         me._label.ShowHint = True
         me._host.Hint = pValue
         me._label.Hint = pValue
         me.SetControlHint(pValue)
      End Sub

      Protected Overridable Function GetControlHint() As String
         GetControlHint = ""
      End Function

      Protected Overridable Sub SetControlHint(pValue As String)
      End Sub

      Property Name As String
         Get
            Name = me.GetControlName()
         End Get
         Set(pValue As String)
            me._setName(pValue)
         End Set
      End Property

      Private Sub _setName(pValue As String)
         me.SetControlName(pValue)
         me._host.Name = pValue & "_host"
      End Sub

      Protected Overridable Function GetControlName() As String
         GetControlName = ""
      End Function

      Protected Overridable Sub SetControlName(pValue As String)
      End Sub

      Property TabStop As Boolean
         Get
            TabStop = me.GetTabStop()
         End Get
         Set(pValue As Boolean)
            me._setTabStop(pValue)
         End Set
      End Property

      Private Sub _setTabStop(pValue As Boolean)
         me.SetTabStop(pValue)
      End Sub

      Protected Overridable Function GetTabStop() As Boolean
         GetTabStop = False
      End Function

      Protected Overridable Sub SetTabStop(pValue As Boolean)
      End Sub

      Property TabOrder As Integer
         Get
            TabOrder = me.GetTabOrder()
         End Get
         Set(pValue As Integer)
            me._setTabOrder(pValue)
         End Set
      End Property

      Private Sub _setTabOrder(pValue As Integer)
         me.SetTabOrder(pValue)
      End Sub

      Protected Overridable Function GetTabOrder() As Integer
         GetTabOrder = -1
      End Function

      Protected Overridable Sub SetTabOrder(pValue As Integer)
      End Sub

      Overridable Function GetBoundText() As String
         GetBoundText = me.GetText()
      End Function

      Overridable Sub SetBoundText(pValue As String)
         me.SetText(pValue)
      End Sub

      Property Text As String
         Get
            Text = me.GetBoundText()
         End Get
         Set(pValue As String)
            me._setBoundText(pValue)
         End Set
      End Property

      Private Sub _setBoundText(pValue As String)
         me.SetBoundText(pValue)
      End Sub

      Protected Overridable Function GetText() As String
         GetText = ""
      End Function

      Protected Overridable Sub SetText(pValue As String)
      End Sub

      Property AsString As String
         Get
            AsString = me.Text
         End Get
         Set(pValue As String)
            me._setAsString(pValue)
         End Set
      End Property

      Private Sub _setAsString(pValue As String)
         me.Text = pValue
      End Sub

      Property OnlyRead As Boolean
         Get
            OnlyRead = me.GetReadOnly()
         End Get
         Set(pValue As Boolean)
            me.SetReadOnly(pValue)
         End Set
      End Property

      Protected Overridable Function GetReadOnly() As Boolean
         GetReadOnly = False
      End Function

      Protected Overridable Sub SetReadOnly(pValue As Boolean)
      End Sub

      Property Ajuda As String
         Get
            Ajuda = me.GetAjuda()
         End Get
         Set(pValue As String)
            me._setAjuda(pValue)
         End Set
      End Property

      Private Sub _setAjuda(pValue As String)
         me.SetAjuda(pValue)
      End Sub

      Protected Overridable Function GetAjuda() As String
         GetAjuda = ""
      End Function

      Protected Overridable Sub SetAjuda(pValue As String)
      End Sub

      Property Modified As Boolean
         Get
            Modified = me.GetModified()
         End Get
         Set(pValue As Boolean)
            me._setModified(pValue)
         End Set
      End Property

      Private Sub _setModified(pValue As Boolean)
         me.SetModified(pValue)
      End Sub

      Protected Overridable Function GetModified() As Boolean
         GetModified = False
      End Function

      Protected Overridable Sub SetModified(pValue As Boolean)
      End Sub

      Property IsFocused As Boolean
         Get
            IsFocused = me.GetIsFocused()
         End Get
      End Property

      Protected Overridable Function GetIsFocused() As Boolean
         GetIsFocused = False
      End Function

      Property EditorColor As Integer
         Get
            EditorColor = me.GetEditorColor()
         End Get
         Set(pValue As Integer)
            me._setEditorColor(pValue)
         End Set
      End Property

      Private Sub _setEditorColor(pValue As Integer)
         me.SetEditorColor(pValue)
      End Sub

      Protected Overridable Function GetEditorColor() As Integer
         GetEditorColor = 0
      End Function

      Protected Overridable Sub SetEditorColor(pValue As Integer)
      End Sub

      Sub Clear()
         me.SetText("")
      End Sub

      Property TextHint As String
         Get
            TextHint = me.GetTextHint()
         End Get
         Set(pValue As String)
            me._setTextHint(pValue)
         End Set
      End Property

      Private Sub _setTextHint(pValue As String)
         me.SetTextHint(pValue)
      End Sub

      Protected Overridable Function GetTextHint() As String
         GetTextHint = ""
      End Function

      Protected Overridable Sub SetTextHint(pValue As String)
      End Sub

      Property MaxLength As Integer
         Get
            MaxLength = me.GetMaxLength()
         End Get
         Set(pValue As Integer)
            me._setMaxLength(pValue)
         End Set
      End Property

      Private Sub _setMaxLength(pValue As Integer)
         me.SetMaxLength(pValue)
      End Sub

      Protected Overridable Function GetMaxLength() As Integer
         GetMaxLength = 0
      End Function

      Protected Overridable Sub SetMaxLength(pValue As Integer)
      End Sub

      Property CharCase As TCharacterCasing
         Get
            CharCase = me._charCase
         End Get
         Set(pValue As TCharacterCasing)
            me._setCharCase(pValue)
         End Set
      End Property

      Private Sub _setCharCase(pValue As TCharacterCasing)
         me._charCase = pValue
         me.ApplyCharCase(pValue)
      End Sub

      Protected Overridable Sub ApplyCharCase(pValue As TCharacterCasing)
      End Sub

      Property SelStart As Integer
         Get
            SelStart = me.GetSelStart()
         End Get
         Set(pValue As Integer)
            me._setSelStart(pValue)
         End Set
      End Property

      Private Sub _setSelStart(pValue As Integer)
         me.SetSelStart(pValue)
      End Sub

      Protected Overridable Function GetSelStart() As Integer
         GetSelStart = 0
      End Function

      Protected Overridable Sub SetSelStart(pValue As Integer)
      End Sub

      Property SelLength As Integer
         Get
            SelLength = me.GetSelLength()
         End Get
         Set(pValue As Integer)
            me._setSelLength(pValue)
         End Set
      End Property

      Private Sub _setSelLength(pValue As Integer)
         me.SetSelLength(pValue)
      End Sub

      Protected Overridable Function GetSelLength() As Integer
         GetSelLength = 0
      End Function

      Protected Overridable Sub SetSelLength(pValue As Integer)
      End Sub

      Function Place(pPlacement As TLabelPlacement) As TLabeledEditorBase
         me.LabelPlacement = pPlacement
         Place = me
      End Function

      Function WithLabelWidth(pWidth As Integer) As TLabeledEditorBase
         me.LabelWidth = pWidth
         WithLabelWidth = me
      End Function

      Function WithFonts(pLabelSize As Integer, pEditorSize As Integer, pLabelBold As Boolean = False) As TLabeledEditorBase
         me.LabelFont.Size = pLabelSize
         me.EditorFont.Size = pEditorSize
         me.LabelFont.Bold = pLabelBold
         WithFonts = me
      End Function

      Overridable Sub Apply(pProps As TEditorProps)
         If pProps = Null Then
            Exit Sub
         End If
         me.FieldName = pProps.FieldName
         me.EditorAlignment = pProps.EditorAlignment
         me._applyIdentity(pProps)
         me._applyLayout(pProps)
         me._applyFonts(pProps)
         me._applyControl(pProps)
         me.OnApply(pProps)
      End Sub

      Private Sub _applyIdentity(pProps As TEditorProps)
         If pProps.Caption <> "" Then
            me.Caption = pProps.Caption
         End If
         If pProps.FieldName <> "" Then
            me.Name = pProps.FieldName
         End If
      End Sub

      Private Sub _applyLayout(pProps As TEditorProps)
         If Assigned(pProps.Placement) Then
            me.LabelPlacement = pProps.Placement
         End If
         If pProps.LabelWidth > 0 Then
            me.LabelWidth = pProps.LabelWidth
         End If
         me.LabelSpacing = pProps.LabelSpacing
         If pProps.EditorHeight > 0 Then
            me.EditorHeight = pProps.EditorHeight
         End If
         me.Align = pProps.Align
         me.Enabled = pProps.Enabled
         me.Visible = pProps.Visible
         If pProps.Width > 0 Then
            me.Width = pProps.Width
         End If
         If pProps.Height > 0 Then
            me.Height = pProps.Height
         End If
         If pProps.Left >= 0 Then
            me.Left = pProps.Left
         End If
         If pProps.Top >= 0 Then
            me.Top = pProps.Top
         End If
      End Sub

      Private Sub _applyFonts(pProps As TEditorProps)
         If pProps.LabelName <> "" Then
            me.LabelFont.Name = pProps.LabelName
         End If
         If pProps.LabelSize > 0 Then
            me.LabelFont.Size = pProps.LabelSize
         End If
         me.LabelFont.Bold = pProps.LabelBold
         me.LabelFont.Italic = pProps.LabelItalic
         If pProps.LabelColor >= 0 Then
            me._idleLabelColor = pProps.LabelColor
            If Not me._required Then
               me.LabelFont.Color = pProps.LabelColor
            End If
         End If
         If pProps.EditorName <> "" Then
            me.EditorFont.Name = pProps.EditorName
         End If
         If pProps.EditorSize > 0 Then
            me.EditorFont.Size = pProps.EditorSize
         End If
         me.EditorFont.Bold = pProps.EditorBold
         me.EditorFont.Italic = pProps.EditorItalic
         me.EditorFont.Underline = pProps.EditorUnderline
         If pProps.EditorColor >= 0 Then
            me.EditorFont.Color = pProps.EditorColor
         End If
         If pProps.RequiredColor >= 0 Then
            me.RequiredColor = pProps.RequiredColor
         End If
         me.Required = pProps.Required
      End Sub

      Private Sub _applyControl(pProps As TEditorProps)
         me.TabStop = pProps.TabStop
         If pProps.TabOrder >= 0 Then
            me.TabOrder = pProps.TabOrder
         End If
         If pProps.Hint <> "" Then
            me.Hint = pProps.Hint
         End If
         me.OnlyRead = pProps.OnlyRead
         If pProps.Ajuda <> "" Then
            me.Ajuda = pProps.Ajuda
         End If
         If pProps.EditorBackColor >= 0 Then
            me.EditorColor = pProps.EditorBackColor
         End If
         If pProps.TextHint <> "" Then
            me.TextHint = pProps.TextHint
         End If
         If pProps.MaxLength > 0 Then
            me.MaxLength = pProps.MaxLength
         End If
         If pProps.CharCase <> ccNormal Then
            me.CharCase = pProps.CharCase
         End If
      End Sub

      Overridable Sub SetFocus()
      End Sub

      Private Sub _clearMargins(pMargins As TMargins)
         pMargins.Left = 0
         pMargins.Top = 0
         pMargins.Right = 0
         pMargins.Bottom = 0
      End Sub

      Protected Overridable Sub _relayout()
         me._label.Width = me._labelWidth
         me._slot.Align = alClient
         me._clearMargins(me._label.Margins)
         me._clearMargins(me._slot.Margins)
         me._slot.Margins.Top = 1
         me._slot.Margins.Bottom = 4

         If me._placement = _placementHidden Then
            me._label.Visible = False
            me._host.Height = me._editorHeight
         Else
            me._label.Visible = True
            me._label.Align = me._alignOf(me._placement)
            If me._placement = _placementTop Then
               me._label.Alignment = taLeftJustify
               me._label.Height = 14
               me._label.Margins.Left = 1
               me._label.Margins.Bottom = 0
               me._host.Height = 14 + me._editorHeight
            ElseIf me._placement = _placementBottom Then
               me._label.Alignment = taLeftJustify
               me._label.Height = 14
               me._label.Margins.Left = 1
               me._label.Margins.Top = 0
               me._host.Height = 14 + me._editorHeight
            ElseIf me._placement = _placementRight Then
               me._label.Alignment = taLeftJustify
               me._label.Margins.Left = me._spacing
               me._host.Height = me._editorHeight
               If me.Caption.Length <= 20 Then
                  me._label.Margins.Top = 3
               End If
            Else
               me._label.Alignment = taRightJustify
               me._label.Margins.Right = me._spacing
               me._host.Height = me._editorHeight
               If me.Caption.Length <= 20 Then
                  me._label.Margins.Top = 3
               End If
            End If
         End If
      End Sub

      Private Function _alignOf(pPlacement As TLabelPlacement) As TAlign
         If pPlacement = _placementTop Then
            _alignOf = alTop
         ElseIf pPlacement = _placementBottom Then
            _alignOf = alBottom
         ElseIf pPlacement = _placementRight Then
            _alignOf = alRight
         Else
            _alignOf = alLeft
         End If
      End Function

      Overridable Sub Free()
         If me._labelFont <> Null Then
            me._labelFont.Free()
            me._labelFont = Null
         End If
         If me._editorFont <> Null Then
            me._editorFont.Free()
            me._editorFont = Null
         End If
         MyBase.Free()
      End Sub
   End Class

   Class TLabeledEditor<T>
      Inherits TLabeledEditorBase

      Protected _control As T

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Protected Overridable Overrides Sub CreateControl()
         me._control = New T(me._slot)
         me._control.Align = alClient
      End Sub

      Protected Overridable Overrides Sub _bindNativeEvents()
         me._nativeOnClick = me._control.OnClick
         me._control.OnClick = me._handleClick
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         me._nativeOnExit = me._control.OnExit
         me._nativeOnEnter = me._control.OnEnter
         me._control.OnExit = me._handleExit
         me._control.OnEnter = me._handleEnter
         me._nativeOnKeyPress = me._control.OnKeyPress
         me._control.OnKeyPress = me._handleKeyPress
         me._nativeOnDblClick = me._control.OnDblClick
         me._control.OnDblClick = me._handleDblClick
         <# End If #>
         me._bindEditValueEvents()
      End Sub

      Protected Overridable Overrides Sub _bindEditValueEvents()
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         me._nativeOnChange = me._control.OnChange
         me._nativeOnFocusChanged = me._control.OnFocusChanged
         me._control.OnChange = me._handleChange
         me._control.OnFocusChanged = me._handleFocusChanged
         <# End If #>
      End Sub

      Overridable Overrides Function ReadMappedFontName(pIsLabel As Boolean, pFallback As String) As String
         If pIsLabel Then
            ReadMappedFontName = MyBase.ReadMappedFontName(pIsLabel, pFallback)
         Else
            ReadMappedFontName = me._readEditorFontName(pFallback)
         End If
      End Function

      Overridable Overrides Sub WriteMappedFontName(pIsLabel As Boolean, pValue As String)
         If pIsLabel Then
            MyBase.WriteMappedFontName(pIsLabel, pValue)
         Else
            me._writeEditorFontName(pValue)
         End If
      End Sub

      Overridable Overrides Function ReadMappedFontSize(pIsLabel As Boolean, pFallback As Integer) As Integer
         If pIsLabel Then
            ReadMappedFontSize = MyBase.ReadMappedFontSize(pIsLabel, pFallback)
         Else
            ReadMappedFontSize = me._readEditorFontSize(pFallback)
         End If
      End Function

      Overridable Overrides Sub WriteMappedFontSize(pIsLabel As Boolean, pValue As Integer)
         If pIsLabel Then
            MyBase.WriteMappedFontSize(pIsLabel, pValue)
         Else
            me._writeEditorFontSize(pValue)
         End If
      End Sub

      Overridable Overrides Function ReadMappedFontColor(pIsLabel As Boolean, pFallback As Integer) As Integer
         If pIsLabel Then
            ReadMappedFontColor = MyBase.ReadMappedFontColor(pIsLabel, pFallback)
         Else
            ReadMappedFontColor = me._readEditorFontColor(pFallback)
         End If
      End Function

      Overridable Overrides Sub WriteMappedFontColor(pIsLabel As Boolean, pValue As Integer)
         If pIsLabel Then
            MyBase.WriteMappedFontColor(pIsLabel, pValue)
         Else
            me._writeEditorFontColor(pValue)
         End If
      End Sub

      Overridable Overrides Function ReadMappedFontBold(pIsLabel As Boolean, pFallback As Boolean) As Boolean
         If pIsLabel Then
            ReadMappedFontBold = MyBase.ReadMappedFontBold(pIsLabel, pFallback)
         Else
            ReadMappedFontBold = me._readEditorFontBold(pFallback)
         End If
      End Function

      Overridable Overrides Sub WriteMappedFontBold(pIsLabel As Boolean, pValue As Boolean)
         If pIsLabel Then
            MyBase.WriteMappedFontBold(pIsLabel, pValue)
         Else
            me._writeEditorFontBold(pValue)
         End If
      End Sub

      Overridable Overrides Function ReadMappedFontItalic(pIsLabel As Boolean, pFallback As Boolean) As Boolean
         If pIsLabel Then
            ReadMappedFontItalic = MyBase.ReadMappedFontItalic(pIsLabel, pFallback)
         Else
            ReadMappedFontItalic = me._readEditorFontItalic(pFallback)
         End If
      End Function

      Overridable Overrides Sub WriteMappedFontItalic(pIsLabel As Boolean, pValue As Boolean)
         If pIsLabel Then
            MyBase.WriteMappedFontItalic(pIsLabel, pValue)
         Else
            me._writeEditorFontItalic(pValue)
         End If
      End Sub

      Overridable Overrides Function ReadMappedFontUnderline(pIsLabel As Boolean, pFallback As Boolean) As Boolean
         If pIsLabel Then
            ReadMappedFontUnderline = MyBase.ReadMappedFontUnderline(pIsLabel, pFallback)
         Else
            ReadMappedFontUnderline = me._readEditorFontUnderline(pFallback)
         End If
      End Function

      Overridable Overrides Sub WriteMappedFontUnderline(pIsLabel As Boolean, pValue As Boolean)
         If pIsLabel Then
            MyBase.WriteMappedFontUnderline(pIsLabel, pValue)
         Else
            me._writeEditorFontUnderline(pValue)
         End If
      End Sub

      Private Function _readEditorFontName(pFallback As String) As String
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         _readEditorFontName = me._control.Font.Name
         <# Else #>
         _readEditorFontName = pFallback
         <# End If #>
      End Function

      Private Sub _writeEditorFontName(pValue As String)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.Font.Name = pValue
         <# End If #>
      End Sub

      Private Function _readEditorFontSize(pFallback As Integer) As Integer
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         _readEditorFontSize = me._control.Font.Size
         <# Else #>
         _readEditorFontSize = pFallback
         <# End If #>
      End Function

      Private Sub _writeEditorFontSize(pValue As Integer)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.Font.Size = pValue
         <# End If #>
      End Sub

      Private Function _readEditorFontColor(pFallback As Integer) As Integer
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         _readEditorFontColor = me._control.Font.Color
         <# Else #>
         _readEditorFontColor = pFallback
         <# End If #>
      End Function

      Private Sub _writeEditorFontColor(pValue As Integer)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.Font.Color = pValue
         <# End If #>
      End Sub

      Private Function _readEditorFontBold(pFallback As Boolean) As Boolean
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         _readEditorFontBold = me._control.Font.GetBold()
         <# Else #>
         _readEditorFontBold = pFallback
         <# End If #>
      End Function

      Private Sub _writeEditorFontBold(pValue As Boolean)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.Font.SetBold(pValue)
         <# End If #>
      End Sub

      Private Function _readEditorFontItalic(pFallback As Boolean) As Boolean
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         _readEditorFontItalic = me._control.Font.GetItalic()
         <# Else #>
         _readEditorFontItalic = pFallback
         <# End If #>
      End Function

      Private Sub _writeEditorFontItalic(pValue As Boolean)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.Font.SetItalic(pValue)
         <# End If #>
      End Sub

      Private Function _readEditorFontUnderline(pFallback As Boolean) As Boolean
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         _readEditorFontUnderline = me._control.Font.GetUnderline()
         <# Else #>
         _readEditorFontUnderline = pFallback
         <# End If #>
      End Function

      Private Sub _writeEditorFontUnderline(pValue As Boolean)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.Font.SetUnderline(pValue)
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetControlHint() As String
         GetControlHint = me._control.Hint
      End Function

      Protected Overridable Overrides Sub SetControlHint(pValue As String)
         me._control.ShowHint = True
         me._control.Hint = pValue
      End Sub

      Protected Overridable Overrides Function GetControlName() As String
         GetControlName = me._control.Name
      End Function

      Protected Overridable Overrides Sub SetControlName(pValue As String)
         me._control.Name = pValue
      End Sub

      Protected Overridable Overrides Function GetTabStop() As Boolean
         <# If TypeSystem.InheritsFrom(T, "TWinControl") Then #>
         GetTabStop = me._control.TabStop
         <# Else #>
         GetTabStop = False
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetTabStop(pValue As Boolean)
         <# If TypeSystem.InheritsFrom(T, "TWinControl") Then #>
         me._control.TabStop = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetTabOrder() As Integer
         <# If TypeSystem.InheritsFrom(T, "TWinControl") Then #>
         GetTabOrder = me._control.TabOrder
         <# Else #>
         GetTabOrder = -1
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetTabOrder(pValue As Integer)
         <# If TypeSystem.InheritsFrom(T, "TWinControl") Then #>
         me._control.TabOrder = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetText() As String
         <# If TypeSystem.IsType(T, "MemoTextBox") Then #>
         GetText = me._control.Lines.Text
         <# ElseIf TypeSystem.IsType(T, "NumberTextBox") Then #>
         GetText = CStr(me._control.Value)
         <# ElseIf TypeSystem.IsType(T, "ValueTextBox") Then #>
         If me._control.DecimalPlaces = 0 Then
            GetText = CStr(me._control.AsInteger)
         Else
            GetText = CStr(me._control.AsFloat)
         End If
         <# ElseIf TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         GetText = me._control.Text
         <# Else #>
         GetText = ""
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetText(pValue As String)
         <# If TypeSystem.IsType(T, "MemoTextBox") Then #>
         me._control.Lines.Text = pValue
         <# ElseIf TypeSystem.IsType(T, "NumberTextBox") Then #>
         me._control.Value = CDbl(pValue)
         <# ElseIf TypeSystem.IsType(T, "ValueTextBox") Then #>
         If me._control.DecimalPlaces = 0 Then
            me._control.AsInteger = CInt(pValue)
         Else
            me._control.AsFloat = CDbl(pValue)
         End If
         <# ElseIf TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         me._control.Text = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetReadOnly() As Boolean
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         GetReadOnly = me._control.ReadOnly
         <# Else #>
         GetReadOnly = False
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetReadOnly(pValue As Boolean)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.ReadOnly = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetAjuda() As String
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         GetAjuda = me._control.Ajuda
         <# Else #>
         GetAjuda = ""
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetAjuda(pValue As String)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         me._control.Ajuda = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetModified() As Boolean
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         GetModified = me._control.EditModified
         <# Else #>
         GetModified = False
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetModified(pValue As Boolean)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.EditModified = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetIsFocused() As Boolean
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         GetIsFocused = me._control.IsFocused
         <# Else #>
         GetIsFocused = False
         <# End If #>
      End Function

      Protected Overridable Overrides Function GetEditorColor() As Integer
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         GetEditorColor = me._control.Color
         <# Else #>
         GetEditorColor = 0
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetEditorColor(pValue As Integer)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomEdit") Then #>
         me._control.Color = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetTextHint() As String
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         GetTextHint = me._control.Hint
         <# Else #>
         GetTextHint = ""
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetTextHint(pValue As String)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         me._control.Hint = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetMaxLength() As Integer
         <# If TypeSystem.IsType(T, "TextBox") Then #>
         GetMaxLength = me._control.MaxLength
         <# Else #>
         GetMaxLength = 0
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetMaxLength(pValue As Integer)
         <# If TypeSystem.IsType(T, "TextBox") Then #>
         me._control.MaxLength = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Sub ApplyCharCase(pValue As TCharacterCasing)
         <# If TypeSystem.IsType(T, "TextBox") Then #>
         me._control.CharCase = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetSelStart() As Integer
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         GetSelStart = me._control.SelStart
         <# Else #>
         GetSelStart = 0
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetSelStart(pValue As Integer)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         me._control.SelStart = pValue
         <# End If #>
      End Sub

      Protected Overridable Overrides Function GetSelLength() As Integer
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         GetSelLength = me._control.SelLength
         <# Else #>
         GetSelLength = 0
         <# End If #>
      End Function

      Protected Overridable Overrides Sub SetSelLength(pValue As Integer)
         <# If TypeSystem.InheritsFrom(T, "TcxCustomTextEdit") Then #>
         me._control.SelLength = pValue
         <# End If #>
      End Sub

      Overridable Overrides Sub SetFocus()
         <# If TypeSystem.InheritsFrom(T, "TWinControl") Then #>
         me._control.SetFocus()
         <# End If #>
      End Sub

      Property Control As T
         Get
            Control = me._control
         End Get
      End Property

      Function Place(pPlacement As TLabelPlacement) As TLabeledEditor<T>
         me.LabelPlacement = pPlacement
         Place = me
      End Function

      Function WithLabelWidth(pWidth As Integer) As TLabeledEditor<T>
         me.LabelWidth = pWidth
         WithLabelWidth = me
      End Function

      Function WithFonts(pLabelSize As Integer, pEditorSize As Integer, pLabelBold As Boolean = False) As TLabeledEditor<T>
         me.LabelFont.Size = pLabelSize
         me.EditorFont.Size = pEditorSize
         me.LabelFont.Bold = pLabelBold
         WithFonts = me
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
