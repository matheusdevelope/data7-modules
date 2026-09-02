Imports Forms
Imports mod_tobject
Imports mod_tlist
Namespace mod_grid_popup
   Private Declare Function GetCursorPos Lib "user32" (ByRef lpPoint As TPoint) As Long
   Private Declare Function WindowFromPoint Lib "user32" (ByVal x As Long, ByVal y As Long) As Long
   Private Declare Function GetAsyncKeyState Lib "user32" (ByVal vKey As Long) As Integer
   Private Declare Function GetForegroundWindow Lib "user32" () As Long

   Private Const VK_LBUTTON = &H1
   Private Const VK_RBUTTON = &H2

   Delegate Sub TGridPopupActionDel(pItem As TGridPopupItem)

   Class TGridPopupItem
      Inherits TTObject
      Title As String
      Key As String
      Action As TGridPopupActionDel
      Private _onPick As TGridPopupActionDel
      Private _panel As PageControl
      Private _caption As StaticText
      Private _bgColor As Integer
      Private _bgHover As Integer
      Sub New(pKey As String, pTitle As String, pAction As TGridPopupActionDel)
         MyBase.New()
         me.Key = pKey
         me.Title = pTitle
         me.Action = pAction
         me._bgColor = RGB(249, 249, 249)
         me._bgHover = RGB(240, 240, 240)
      End Sub
      Sub New(pTitle As String, pAction As TGridPopupActionDel)
         MyBase.New()
         me.Key = pTitle
         me.Title = pTitle
         me.Action = pAction
         me._bgColor = RGB(249, 249, 249)
         me._bgHover = RGB(240, 240, 240)
      End Sub
      Sub New(pValue As TGridPopupItem)
         MyBase.New()
         me._bgColor = RGB(249, 249, 249)
         me._bgHover = RGB(240, 240, 240)
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridPopupItem)
         If Assigned(pValue) Then
            me.Title = pValue.Title
            me.Key = pValue.Key
            me.Action = pValue.Action
         End If
      End Sub
      Overrides Function Clone() As TGridPopupItem
         Clone = New TGridPopupItem(me)
      End Function
      Overrides Function GetID() As String
         If me.Key <> "" Then
            GetID = me.Key
         Else
            GetID = me.Title
         End If
      End Function
      Overridable Function ItemHeight() As Integer
         ItemHeight = 22
      End Function
      Sub ApplyItemHeight()
         If Assigned(me._panel) Then
            me._panel.Height = me.ItemHeight()
         End If
      End Sub
      Overridable Sub Build(pControl As TWinControl, pOnPick As TGridPopupActionDel)
         me._onPick = pOnPick
         me.BuildContainer(pControl)
         me.BuildItem(me._panel)
      End Sub
      Overridable Sub BuildContainer(pControl As TWinControl)
         me._panel = New PageControl(pControl)
         me._panel.Align = alTop
         me._panel.ShowCardFrame = False
         me._panel.Height = 22
         me._panel.Width = pControl.Width
         me._panel.Color = me._bgColor
      End Sub
      Overridable Sub BuildItem(pControl As TWinControl)
         me._caption = New StaticText(pControl)
         me._caption.Align = alClient
         me._caption.AlignWithMargins = True
         me._caption.Margins.Left = 12
         me._caption.Margins.Top = 2
         me._caption.Margins.Right = 8
         me._caption.Margins.Bottom = 2
         me._caption.AutoSize = False
         me._caption.Caption = me.Title
         me._caption.Color = me._bgColor
         me._caption.OnClick = me._handleClick
         me._caption.OnMouseEnter = me._handleMouseEnter
         me._caption.OnMouseLeave = me._handleMouseLeave
      End Sub
      Private Sub _paint(pColor As Integer)
         If Assigned(me._panel) Then
            me._panel.Color = pColor
         End If
         If Assigned(me._caption) Then
            me._caption.Color = pColor
         End If
      End Sub
      Private Sub _handleClick(pSender As TObject)
         If me._onPick <> Null Then
            me._onPick(me)
         End If
      End Sub
      Private Sub _handleMouseEnter(pSender As TObject)
         me._paint(me._bgHover)
      End Sub
      Private Sub _handleMouseLeave(pSender As TObject)
         me._paint(me._bgColor)
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Title", me.Title)
            .Prop("Key", me.Key)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me.Title = ""
         me.Key = ""
         me.Action = Null
         me._onPick = Null
         me._caption = Null
         me._panel = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridPopupSeparator
      Inherits TGridPopupItem
      Sub New()
         MyBase.New("separator", "", Null)
      End Sub
      Sub New(pKey As String)
         MyBase.New(pKey, "", Null)
      End Sub
      Overrides Function GetID() As String
         GetID = "separator-" + CStr(me.GetHashCode)
      End Function
      Overrides Function ItemHeight() As Integer
         ItemHeight = 7
      End Function
      Overrides Sub BuildItem(pControl As TWinControl)
         pControl.Height = 7
         Dim _line As Line = New Line(pControl)
         _line.Height = 1
         _line.Align = alTop
         _line.AlignWithMargins = True
         _line.Margins.Left = 8
         _line.Margins.Top = 3
         _line.Margins.Right = 8
         _line.Margins.Bottom = 3
         _line.Pen.Color = RGB(149, 149, 149)
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridPopup
      Inherits TTObject
      ExecuteActionOnClose As Boolean = True
      Private _form As Form
      Private _page As PageControl
      Private _items[] As TGridPopupItem
      Private _timer As Timer
      Private _parentHandle As Long
      Private _watchStep As Integer
      Private _itemSelected As TGridPopupItem
      Sub New()
         MyBase.New()
         me._items = []
         me._build()
      End Sub
      Sub New(pValue As TGridPopup)
         MyBase.New()
         me._items = []
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridPopup)
         If Assigned(pValue) Then
            me.ExecuteActionOnClose = pValue.ExecuteActionOnClose
         End If
      End Sub
      Overrides Function Clone() As TGridPopup
         Clone = New TGridPopup(me)
      End Function
      Private Sub _build()
         me._form = New Form()
         me._form.Position = poDesigned
         me._form.BorderStyle = bsNone
         me._form.ShowInTaskBar = False
         me._form.AutoScroll = False
         me._form.BorderWidth = 0
         ' data7:disable-next-line unknown-member
         me._form.OcultarBordas = True
         me._form.OnActivate = me._handleActivate
         me._form.OnDeactivate = me._handleDeactivate
         me._page = New PageControl(me._form)
         me._page.Align = alClient
         me._page.ShowCardFrame = False
         me._page.Color = RGB(249, 249, 249)
         me._timer = New Timer(me._form)
         me._setSize(800, 328)
      End Sub
      Private Sub _setSize(pHeight As Integer, pWidth As Integer)
         me._form.Width = pWidth
         me._form.Height = pHeight
      End Sub
      Private Sub _buildItems()
         Dim totalHeight As Integer = 0
         Dim i As Integer
         me._setSize(800, 328)
         For i = 0 To me._items.Length - 1
            Dim _item As TGridPopupItem = me._items[i]
            _item.Build(me._page, me._handleClickItem)
         Next
         For i = 0 To me._items.Length - 1
            me._items[i].ApplyItemHeight()
            totalHeight = totalHeight + me._items[i].ItemHeight()
         Next
         me._setSize(totalHeight + 40, 328)
      End Sub
      Private Sub _handleActivate(pSender As TObject)
         me._startWatcher()
      End Sub
      Private Sub _handleDeactivate(pSender As TObject)
         me._stopWatcher()
      End Sub
      Private Sub _handleClickItem(pItem As TGridPopupItem)
         me._itemSelected = pItem
         me.Close()
      End Sub
      Function Show() As TGridPopupItem
         Dim _result As TGridPopupItem
         me._buildItems()
         me._parentHandle = GetForegroundWindow()
         Dim _point As TPoint
         GetCursorPos(_point)
         me._form.Left = _point.X
         me._form.Top = _point.Y
         me._form.Show()
         If Assigned(me._itemSelected) Then
            _result = me._itemSelected
            If me.ExecuteActionOnClose AndAlso me._itemSelected.Action <> Null Then
               me._itemSelected.Action(me._itemSelected)
            End If
         End If
         Show = _result
      End Function
      Sub Close()
         me._stopWatcher()
         If Assigned(me._form) Then
            me._form.Close()
         End If
      End Sub
      Sub Add(pItem As TGridPopupItem)
         If Assigned(pItem) Then
            me._items.Push(pItem)
         End If
      End Sub
      Private Sub _startWatcher()
         me._watchStep = 0
         me._timer.Interval = 100
         me._timer.OnTimer = me._watchMouse
         me._timer.Enabled = True
      End Sub
      Private Sub _stopWatcher()
         If Assigned(me._timer) Then
            me._timer.Enabled = False
         End If
      End Sub
      Private Sub _watchMouse(pSender As TObject)
         If me._watchStep = 0 Then
            GetAsyncKeyState(VK_LBUTTON)
            GetAsyncKeyState(VK_RBUTTON)
         Else
            Dim _left As Integer = GetAsyncKeyState(VK_LBUTTON)
            Dim _right As Integer = GetAsyncKeyState(VK_RBUTTON)
            If _left <> 0 Or _right <> 0 Then
               Dim pt As TPoint
               GetCursorPos(pt)
               If WindowFromPoint(pt.X, pt.Y) = me._parentHandle Then
                  me.Close()
               End If
            End If
         End If
         me._watchStep = me._watchStep + 1
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Items", me._items.Length)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._stopWatcher()
         me._itemSelected = Null
         If Assigned(me._timer) Then
            me._timer.Enabled = False
            me._timer.OnTimer = Null
            me._timer = Null
         End If
         If Assigned(me._items) Then
            me._items.Free()
            me._items = Null
         End If
         me._page = Null
         If Assigned(me._form) Then
            me._form.Free()
            me._form = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
