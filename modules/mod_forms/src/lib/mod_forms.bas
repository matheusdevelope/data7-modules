Imports Forms
Imports mod_tenum
Imports mod_forms_chrome
Imports mod_forms_metrics
Imports mod_forms_screen
Imports mod_forms_shortcut
Imports mod_forms_topbar

Namespace mod_forms

   Enun TFormsKind
      Content = "Content"
      Dialog = "Dialog"
      Workspace = "Workspace"
   End Enun

   Class TFormsForm

      Private _form As Form
      Private _topBar As TFormsTopBar
      Private _chrome As TFormsChrome
      Private _hotkeys As TFormsHotkeys
      Private _metrics As TFormsMetrics
      Private _kind As TFormsKind
      Private _maximizeHotkey As TFormsHotkey
      Private _maximizeOnF11 As Boolean
      Private _cancelled As Boolean
      Private _forceClose As Boolean

      CloseOnOk As Boolean = True
      ConfirmCloseMessage As String

      OnCanShowEvent As TCloseQueryEvent
      OnCanCloseEvent As TCloseQueryEvent
      OnShowEvent As TNotifyEvent
      OnCloseEvent As TNotifyEvent
      OnOkEvent As TNotifyEvent
      OnCancelEvent As TNotifyEvent
      OnCanResize As TCanResizeEvent
      OnResize As TNotifyEvent

      Sub New(pCaption As String = "")
         MyBase.New()
         me._boot(pCaption, TFormsKind.Workspace())
      End Sub

      Sub New(pCaption As String, pKind As TFormsKind)
         MyBase.New()
         me._boot(pCaption, pKind)
      End Sub

      Private Sub _boot(pCaption As String, pKind As TFormsKind)
         me._form = New Form()
         me._form.Caption = pCaption
         me._form.TabStop = False
         me._form.KeyPreview = True

         me._topBar = New TFormsTopBar(me._form)
         me._chrome = New TFormsChrome(me._form)
         me._hotkeys = New TFormsHotkeys()
         me._metrics = New TFormsMetrics(me._form)
         me._metrics.CanResize = True

         me._maximizeHotkey = TFormsHotkey.Parse("F11")
         me._maximizeHotkey.Action = me._toggleMaximized
         If Assigned(pKind)Then
            me.ApplyKind(pKind)
         Else
            me.ApplyKind(TFormsKind.Workspace())
         End If
         me._bindHost()
         me.Build()
      End Sub

      Property Host As Form
         Get
            Host = me._form
         End Get
      End Property

      Property Caption As String
         Get
            Caption = me._form.Caption
         End Get
         Set(pValue As String)
            me._setCaption(pValue)
         End Set
      End Property

      Property TopBar As TFormsTopBar
         Get
            TopBar = me._topBar
         End Get
      End Property

      Property Chrome As TFormsChrome
         Get
            Chrome = me._chrome
         End Get
      End Property

      Property Header As PageControl
         Get
            Header = me._chrome.Header
         End Get
      End Property

      Property Content As PageControl
         Get
            Content = me._chrome.Content
         End Get
      End Property

      Property Footer As PageControl
         Get
            Footer = me._chrome.Footer
         End Get
      End Property

      Property Hotkeys As TFormsHotkeys
         Get
            Hotkeys = me._hotkeys
         End Get
      End Property

      Property OnKeyDown As TKeyEvent
         Get
            OnKeyDown = me._hotkeys.OnKeyDown
         End Get
         Set(pValue As TKeyEvent)
            me._setOnKeyDown(pValue)
         End Set
      End Property

      Property OnKeyUp As TKeyEvent
         Get
            OnKeyUp = me._hotkeys.OnKeyUp
         End Get
         Set(pValue As TKeyEvent)
            me._setOnKeyUp(pValue)
         End Set
      End Property

      Property Metrics As TFormsMetrics
         Get
            Metrics = me._metrics
         End Get
      End Property

      Property Monitor As TFormsMonitor
         Get
            Monitor = me._metrics.Monitor
         End Get
      End Property

      Property Width As TFormsAxis
         Get
            Width = me._metrics.Width
         End Get
      End Property

      Property Height As TFormsAxis
         Get
            Height = me._metrics.Height
         End Get
      End Property

      Property CanResize As Boolean
         Get
            CanResize = me._metrics.CanResize
         End Get
         Set(pValue As Boolean)
            me._setCanResize(pValue)
         End Set
      End Property

      Property Margin As Integer
         Set(pValue As Integer)
            me._setMargin(pValue)
         End Set
      End Property

      Property MarginWidth As Integer
         Get
            MarginWidth = me._metrics.MarginWidth
         End Get
         Set(pValue As Integer)
            me._setMarginWidth(pValue)
         End Set
      End Property

      Property MarginHeight As Integer
         Get
            MarginHeight = me._metrics.MarginHeight
         End Get
         Set(pValue As Integer)
            me._setMarginHeight(pValue)
         End Set
      End Property

      Property Size As TFormsSize
         Get
            Size = me._metrics.Size
         End Get
      End Property

      Property SizeWidth As Integer
         Get
            SizeWidth = me._metrics.SizeWidth
         End Get
         Set(pValue As Integer)
            me._setSizeWidth(pValue)
         End Set
      End Property

      Property SizeHeight As Integer
         Get
            SizeHeight = me._metrics.SizeHeight
         End Get
         Set(pValue As Integer)
            me._setSizeHeight(pValue)
         End Set
      End Property

      Property Maximized As Boolean
         Get
            Maximized = me._metrics.Maximized
         End Get
         Set(pValue As Boolean)
            me._setMaximized(pValue)
         End Set
      End Property

      Property MaximizeOnF11 As Boolean
         Get
            MaximizeOnF11 = me._maximizeOnF11
         End Get
         Set(pValue As Boolean)
            me._maximizeOnF11 = pValue
            If pValue Then
               me._hotkeys.Assign(me._maximizeHotkey)
            Else
               me._hotkeys.Unassign(me._maximizeHotkey)
            End If
         End Set
      End Property

      Property Kind As TFormsKind
         Get
            Kind = me._kind
         End Get
         Set(pValue As TFormsKind)
            me.ApplyKind(pValue)
         End Set
      End Property

      Private Sub _setCaption(pValue As String)
         me._form.Caption = pValue
      End Sub

      Private Sub _setCanResize(pValue As Boolean)
         me._metrics.CanResize = pValue
      End Sub

      Private Sub _setMargin(pValue As Integer)
         me._metrics.Margin = pValue
      End Sub

      Private Sub _setMarginWidth(pValue As Integer)
         me._metrics.MarginWidth = pValue
      End Sub

      Private Sub _setMarginHeight(pValue As Integer)
         me._metrics.MarginHeight = pValue
      End Sub

      Private Sub _setSizeWidth(pValue As Integer)
         me._metrics.SizeWidth = pValue
      End Sub

      Private Sub _setSizeHeight(pValue As Integer)
         me._metrics.SizeHeight = pValue
      End Sub

      Private Sub _setMaximized(pValue As Boolean)
         me._metrics.Maximized = pValue
      End Sub

      Private Sub _setOnKeyDown(pValue As TKeyEvent)
         me._hotkeys.OnKeyDown = pValue
      End Sub

      Private Sub _setOnKeyUp(pValue As TKeyEvent)
         me._hotkeys.OnKeyUp = pValue
      End Sub

      Sub ApplyKind(pKind As TFormsKind)
         me._kind = pKind ?? TFormsKind.Workspace()
         If me._kind.AsString = "Workspace" Then
            me._chrome.ShowWorkspace()
         Else
            me._chrome.ShowContentOnly()
         End If
         me._topBar.Visible = (me._kind.AsString <> "Content")
      End Sub

      Function Show() As Boolean
         me._cancelled = False
         If Not me._canShow() Then
            Show = False
            Exit Function
         End If
         me._form.Show()
         Show = Not me._cancelled
      End Function

      Sub Close(pForce As Boolean = False)
         me._forceClose = pForce
         me._form.Close()
      End Sub

      Protected Overridable Sub Build()
      End Sub

      Protected Overridable Sub AfterShow()
      End Sub

      Protected Overridable Function CanShow() As Boolean
         CanShow = True
      End Function

      Protected Overridable Function CanClose() As Boolean
         CanClose = True
      End Function

      Protected Overridable Sub HandleOk(pSender As TObject)
      End Sub

      Protected Overridable Sub HandleCancel(pSender As TObject)
      End Sub

      Private Sub _bindHost()
         me._form.OnCanResize = me._onCanResize
         me._form.OnResize = me._onResize
         me._form.OnShow = me._onShow
         me._form.OnCloseQuery = me._onCloseQuery
         me._form.OnKeyDown = me._onKeyDown
         me._form.OnKeyUp = me._onKeyUp
         me._topBar.Ok.OnClick = me._onOk
         me._topBar.Cancel.OnClick = me._onCancel
      End Sub

      Private Function _canShow() As Boolean
         Dim allow As Boolean = me.CanShow()
         If me.OnCanShowEvent <> NULL Then
            me.OnCanShowEvent(me, allow)
         End If
         _canShow = allow
      End Function

      Private Function _canClose() As Boolean
         Dim allow As Boolean = me.CanClose()
         If allow And me.OnCanCloseEvent <> NULL Then
            me.OnCanCloseEvent(me, allow)
         End If
         If allow And me.ConfirmCloseMessage <> "" Then
            allow = Forms.MessageBox.Confirmation(me.ConfirmCloseMessage)
         End If
         _canClose = allow
      End Function

      Private Sub _onShow(pSender As TObject)
         me._metrics.RefreshMonitor()
         me._metrics.EnsureWorkAreaMax()
         me._metrics.ApplyPercent()
         me._topBar.BindHotkeys(me._hotkeys)
         me.AfterShow()
         If me.OnShowEvent <> NULL Then
            me.OnShowEvent(me)
         End If
      End Sub

      Private Sub _onCloseQuery(pSender As TObject, ByRef pCanClose As Boolean)
         If me._forceClose Then
            pCanClose = True
            me._forceClose = False
         Else
            pCanClose = me._canClose()
         End If
         If Not pCanClose Then
            Exit Sub
         End If
         If me._cancelled Then
            me.HandleCancel(pSender)
            If me.OnCancelEvent <> NULL Then
               me.OnCancelEvent(me)
            End If
         End If
         If me.OnCloseEvent <> NULL Then
            me.OnCloseEvent(me)
         End If
      End Sub

      Private Sub _onOk(pSender As TObject)
         me._cancelled = False
         me.HandleOk(pSender)
         If me.OnOkEvent <> NULL Then
            me.OnOkEvent(me)
         End If
         If me.CloseOnOk Then
            me.Close(True)
         End If
      End Sub

      Private Sub _onCancel(pSender As TObject)
         me._cancelled = True
         me.Close()
      End Sub

      Private Sub _onCanResize(pSender As TObject, ByRef pWidth As Integer, ByRef pHeight As Integer, ByRef pCan As Boolean)
         If me._metrics.CanResize Then
            pWidth = me._metrics.ClampWidth(pWidth)
            pHeight = me._metrics.ClampHeight(pHeight)
            pCan = True
         Else
            pCan = False
         End If
         If me.OnCanResize <> NULL Then
            me.OnCanResize(me, pWidth, pHeight, pCan)
         End If
         If pCan And me._metrics.CanResize Then
            pWidth = me._metrics.ClampWidth(pWidth)
            pHeight = me._metrics.ClampHeight(pHeight)
         Else
            pCan = False
         End If
      End Sub

      Private Sub _onResize(pSender As TObject)
         me._metrics.SyncFromForm()
         If me.OnResize <> NULL Then
            me.OnResize(me)
         End If
      End Sub

      Private Sub _onKeyDown(pSender As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
         me._hotkeys.HandleKeyDown(pSender, pKey, pShift)
      End Sub

      Private Sub _onKeyUp(pSender As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
         me._hotkeys.HandleKeyUp(pSender, pKey, pShift)
      End Sub

      Private Sub _toggleMaximized(pSender As TObject)
         me.Maximized = Not me.Maximized
      End Sub

      Sub Free()
         If me._hotkeys <> NULL Then
            me._hotkeys.Free()
         End If
         If me._maximizeHotkey <> NULL Then
            me._maximizeHotkey.Free()
         End If
         If me._metrics <> NULL Then
            me._metrics.Free()
         End If
         If me._topBar <> NULL Then
            me._topBar.Free()
         End If
         If me._chrome <> NULL Then
            me._chrome.Free()
         End If
         If me._form <> NULL Then
            me._form.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

   Class TFormsSimple
      Inherits TFormsForm

      Sub New(pCaption As String = "")
         MyBase.New(pCaption, TFormsKind.Content())
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TFormsDialog
      Inherits TFormsForm

      Sub New(pCaption As String = "")
         MyBase.New(pCaption, TFormsKind.Dialog())
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TFormsWorkspace
      Inherits TFormsForm

      Sub New(pCaption As String = "", pShowTopBar As Boolean = True)
         MyBase.New(pCaption, TFormsKind.Workspace())
         me.TopBar.Visible = pShowTopBar
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
