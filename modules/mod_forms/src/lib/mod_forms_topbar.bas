Imports Forms
Imports mod_tlist
Imports mod_tenum
Imports mod_forms_icons
Imports mod_forms_screen
Imports mod_forms_shortcut


Namespace mod_forms_topbar

   Delegate Sub TFormsActionNotify(pSender As TObject, pAction As TFormsAction)

   Enun TFormsActionKind
      Button = "Button"
      Divider = "Divider"
   End Enun

   Class TFormsAction

      Private _id As String
      Private _kind As TFormsActionKind
      Private _caption As String
      Private _image As String
      Private _hint As String
      Private _order As Integer
      Private _hotkey As TFormsHotkey
      Private _control As TControl
      Private _onClick As TNotifyEvent
      Private _onNotify As TNotifyEvent
      Private _built As Boolean

      Sub New(pId As String, pKind As TFormsActionKind, pOrder As Integer)
         MyBase.New()
         me._id = pId
         me._kind = pKind ?? TFormsActionKind.Button()
         me._order = pOrder
         me._hotkey = New TFormsHotkey()
      End Sub

      Shared Function Button(pId As String, pCaption As String, pImage As String = "", pHint As String = "", pOrder As Integer = -1, pShortcut As String = "") As TFormsAction
         Dim action As TFormsAction = New TFormsAction(pId, TFormsActionKind.Button(), pOrder)
         action.Caption = pCaption
         action.Image = pImage
         action.Hint = pHint
         action.Shortcut = pShortcut
         Button = action
      End Function

      Shared Function Divider(pId As String, pOrder As Integer = -1) As TFormsAction
         Divider = New TFormsAction(pId, TFormsActionKind.Divider(), pOrder)
      End Function

      Property Id As String
         Get
            Id = me._id
         End Get
      End Property

      Property Kind As TFormsActionKind
         Get
            Kind = me._kind
         End Get
      End Property

      Property Caption As String
         Get
            Caption = me._caption
         End Get
         Set(pValue As String)
            me._caption = pValue
            me._refresh()
         End Set
      End Property

      Property Image As String
         Get
            Image = me._image
         End Get
         Set(pValue As String)
            me._image = pValue
            me._refresh()
         End Set
      End Property

      Property Hint As String
         Get
            Hint = me._hint
         End Get
         Set(pValue As String)
            me._hint = pValue
            me._refresh()
         End Set
      End Property

      Property Order As Integer
         Get
            Order = me._order
         End Get
         Set(pValue As Integer)
            me._order = pValue
            me._setOrder(pValue)
         End Set
      End Property

      Property Shortcut As String
         Get
            Shortcut = me._hotkey.Text
         End Get
         Set(pValue As String)
            me._setShortcut(pValue)
            me._refresh()
         End Set
      End Property

      Property Hotkey As TFormsHotkey
         Get
            Hotkey = me._hotkey
         End Get
      End Property

      Property Control As TControl
         Get
            Control = me._control
         End Get
      End Property

      Property OnClick As TNotifyEvent
         Get
            OnClick = me._onClick
         End Get
         Set(pValue As TNotifyEvent)
            me._onClick = pValue
            me._bindHotkeyAction()
         End Set
      End Property

      Property Visible As Boolean
         Get
            If me._control = NULL Then
               Visible = False
            Else
               Visible = me._control.Visible
            End If
         End Get
         Set(pValue As Boolean)
            me._setVisible(pValue)
         End Set
      End Property

      Property Enabled As Boolean
         Get
            If me._control = NULL Then
               Enabled = False
            Else
               Enabled = me._control.Enabled
            End If
         End Get
         Set(pValue As Boolean)
            me._setEnabled(pValue)
         End Set
      End Property

      Property Width As Integer
         Get
            If me._control = NULL Then
               Width = 0
            Else
               Width = me._control.Width
            End If
         End Get
         Set(pValue As Integer)
            me._setWidth(pValue)
         End Set
      End Property

      Sub BindNotifier(pAction As TNotifyEvent)
         me._onNotify = pAction
      End Sub

      Sub Place(pLeft As Integer)
         me._setOrder(pLeft)
      End Sub

      Private Sub _setOrder(pValue As Integer)
         If me._control <> NULL Then
            me._control.Left = pValue
         End If
      End Sub

      Private Sub _setShortcut(pValue As String)
         me._hotkey.Text = pValue
         me._bindHotkeyAction()
      End Sub

      Private Sub _bindHotkeyAction()
         me._hotkey.Action = me._dispatch
      End Sub

      Private Sub _setVisible(pValue As Boolean)
         If me._control <> NULL Then
            me._control.Visible = pValue
         End If
      End Sub

      Private Sub _setEnabled(pValue As Boolean)
         If me._control <> NULL Then
            me._control.Enabled = pValue
         End If
      End Sub

      Private Sub _setWidth(pValue As Integer)
         If me._control <> NULL Then
            me._control.Width = pValue
         End If
      End Sub

      Sub Mount(pParent As TWinControl)
         If me._kind.AsString = "Divider" Then
            me._mountDivider(pParent)
         Else
            me._mountButton(pParent)
         End If
         me._built = True
         me._refresh()
      End Sub

      Private Sub _mountButton(pParent As TWinControl)
         Dim _button As Forms.FlatButton = New Forms.FlatButton(pParent)
         _button.Width = 60
         _button.Align = alLeft
         _button.Layout = blGlyphTop
         _button.Spacing = 0
         _button.Transparent = True
         _button.Flat = True
         _button.ShowHint = True
         _button.Text = me._caption
         _button.Image = me._image
         _button.Left = me._order
         _button.OnClick = me._dispatch
         me._control = _button
      End Sub

      Private Sub _mountDivider(pParent As TWinControl)
         Dim _edge As Forms.Line = New Forms.Line(pParent)
         Dim _rgb As Integer = RGB(160, 160, 160)
         _edge.Width = 1
         _edge.Align = alLeft
         _edge.AlignWithMargins = True
         _edge.Margins.Left = 3
         _edge.Margins.Top = 5
         _edge.Margins.Right = 3
         _edge.Margins.Bottom = 4
         _edge.Pen.Color = _rgb
         _edge.Brush.Color = _rgb
         _edge.Left = me._order
         me._control = _edge
      End Sub

      Private Sub _refresh()
         If Not me._built Then
            Exit Sub
         End If
         If TypeOf me._control Is FlatButton Then
            With FlatButton(me._control)
               .Text = me._caption
               .Image = me._image
               .Hint = me._hintText()
            End With
         End If
      End Sub

      Private Function _hintText() As String
         If me._hotkey.Text <> "" Then
            _hintText = $"{me._hint} ({me._hotkey.Text})"
            Exit Function
         End If
         _hintText = me._hint
      End Function

      Private Sub _dispatch(pSender As TObject)
         If me._onClick <> NULL Then
            me._onClick(me)
         End If
         If me._onNotify <> NULL Then
            me._onNotify(me)
         End If
      End Sub

      Sub Free()
         If me._hotkey <> NULL Then
            me._hotkey.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

   Class TFormsTopBar

      Private _host As PageControl
      Private _strip As PageControl
      Private _edge As Line
      Private _items[] As TFormsAction = []
      Private _surface As Integer = RGB(243, 243, 243)
      Private _lineColor As Integer = RGB(192, 192, 192)

      AutoRealign As Boolean = True
      ShowActionDivider As Boolean = True
      OnItemClick As TFormsActionNotify

      Sub New(pParent As TWinControl)
         MyBase.New()
         me._host = New PageControl(pParent)
         me._host.Align = alTop
         me._host.Height = 58
         me._host.ShowCardFrame = False
         me._host.ShowShadow = False
         me._host.TabStop = False
         me._host.Color = me._surface

         me._strip = New PageControl(me._host)
         me._strip.Align = alClient
         me._strip.ShowCardFrame = False
         me._strip.ShowShadow = False
         me._strip.TabStop = False
         me._strip.AlignWithMargins = True
         me._strip.Margins.Bottom = 1

         me._edge = New Line(me._host)
         me._edge.Align = alBottom
         me._edge.Height = 1
         me._edge.Pen.Color = me._lineColor
         me._edge.Brush.Color = me._lineColor

         me._seedDefaults()
         me.Visible = False
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Property Items As TTList<TFormsAction>
         Get
            Items = me._items
         End Get
      End Property

      Property Height As Integer
         Get
            Height = me._host.Height
         End Get
         Set(pValue As Integer)
            me._setHeight(pValue)
         End Set
      End Property

      Property Visible As Boolean
         Get
            Visible = me._host.Visible
         End Get
         Set(pValue As Boolean)
            me._setVisible(pValue)
         End Set
      End Property

      Private Sub _setHeight(pValue As Integer)
         me._host.Height = pValue
      End Sub

      Private Sub _setVisible(pValue As Boolean)
         me._host.Visible = pValue
      End Sub

      Property Item(pId As String) As TFormsAction
         Get
            Item = me.Find(pId)
         End Get
      End Property

      Property Ok As TFormsAction
         Get
            Ok = me.Find("ok")
         End Get
      End Property

      Property Cancel As TFormsAction
         Get
            Cancel = me.Find("cancel")
         End Get
      End Property

      Function Find(pId As String) As TFormsAction
         Find = me._items.Find(
            Function(pItem As TFormsAction, pIdx As Integer, extra As Variant) As Boolean
               Return UCase(pItem.Id) = UCase(CStr(extra))
            End Function,
            pId
         )
      End Function

      Function Add(pAction As TFormsAction) As TFormsAction
         If pAction.Order < 0 Then
            pAction.Order = me._items.Length
         End If
         pAction.Mount(me._strip)
         pAction.BindNotifier(me._handleItemClick)
         me._items.Push(pAction)
         If me.ShowActionDivider Then
            Dim split As TFormsAction = me.Find("divider.actions")
            If split <> NULL Then
               split.Visible = True
            End If
         End If
         If me.AutoRealign Then
            me.Realign()
         End If
         Add = pAction
      End Function

      Function AddAction(pId As String, pCaption As String, pImage As String = "", pHint As String = "", pOrder As Integer = -1, pShortcut As String = "") As TFormsAction
         AddAction = me.Add(TFormsAction.Button(pId, pCaption, pImage, pHint, pOrder, pShortcut))
      End Function

      Function AddDivider(pId As String, pOrder As Integer = -1) As TFormsAction
         AddDivider = me.Add(TFormsAction.Divider(pId, pOrder))
      End Function

      Sub Realign()
         Dim n As Integer = me._items.Length
         Dim i As Integer
         For i = 0 To n - 1
            Dim action As TFormsAction = me._items[i]
            action.Place(me._alignSlot(action, i) * 100)
         Next
      End Sub

      Private Function _alignSlot(pAction As TFormsAction, pIndex As Integer) As Integer
         Dim slot As Integer = 0
         Dim n As Integer = me._items.Length
         Dim j As Integer
         For j = 0 To n - 1
            Dim other As TFormsAction = me._items[j]
            If other.Order < pAction.Order Then
               slot = slot + 1
            End If
            If other.Order = pAction.Order Then
               If j < pIndex Then
                  slot = slot + 1
               End If
            End If
         Next
         _alignSlot = slot
      End Function

      Sub BindHotkeys(pHotkeys As TFormsHotkeys)
         Dim i As Integer
         Dim n As Integer = me._items.Length
         For i = 0 To n - 1
            Dim action As TFormsAction = me._items[i]
            If action.Hotkey <> NULL Then
               pHotkeys.Assign(action.Hotkey)
            End If
         Next
      End Sub

      Private Sub _seedDefaults()
         me.AutoRealign = False
         me.ShowActionDivider = False
         me.AddAction("hp12c", "HP 12C", TFormsGlyph.HP12C(), "Calculadora financeira HP 12C", -10)
         me.AddAction("calc", "Calculadora", TFormsGlyph.CALC(), "Calculadora", -9)
         me.AddDivider("divider.tools", -8)
         me.AddDivider("divider.actions", 997)
         me.AddAction("ok", "&Ok", TFormsGlyph.OK(), "Ok", 998, "Ctrl+O")
         me.AddAction("cancel", "&Cancelar", TFormsGlyph.CANCEL(), "Cancelar", 999, "ESC")
         Dim _calc As TFormsAction = me.Find("calc")
         If _calc <> NULL Then
            _calc.Width = 70
         End If
         Dim split As TFormsAction = me.Find("divider.actions")
         If split <> NULL Then
            split.Visible = False
         End If
         me.Realign()
         me.ShowActionDivider = True
         me.AutoRealign = True
      End Sub

      Private Sub _handleItemClick(pSender As TObject)
         Dim action As TFormsAction = TFormsAction(pSender)
         me._runBuiltin(action)
         If me.OnItemClick <> NULL Then
            me.OnItemClick(pSender, action)
         End If
      End Sub

      Private Sub _runBuiltin(pAction As TFormsAction)
         Select UCase(pAction.Id)
            Case "CALC"
               Environment.Execute("calc", "", True)
               Sleep(500)
               TFormsDisplay.SendKeys("%1")
            Case "HP12C"
               Environment.Execute("calc", "", True)
               Sleep(500)
               TFormsDisplay.SendKeys("%2")
         End Select
      End Sub

      Sub Free()
         If me._items <> NULL Then
            me._items.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
