' data7:disable shared-return-global-function
Imports mod_winapi


Namespace mod_forms_screen

   Class TFormsDisplay

      Shared Function ForegroundWindow() As Long
         ForegroundWindow = WinAPI.Window.GetForeground()
      End Function

      Shared Function MonitorFromWindow(pHandle As Long) As TFormsMonitor
         MonitorFromWindow = New TFormsMonitor()
      End Function

      Shared Function CurrentMonitor() As TFormsMonitor
         CurrentMonitor = New TFormsMonitor()
      End Function

      Shared Function PrimaryMonitor() As TFormsMonitor
         PrimaryMonitor = New TFormsMonitor()
      End Function

      Shared Sub SendKeys(pKeys As String, pWait As Boolean = False)
         WinAPI.SendKeys(pKeys, pWait)
      End Sub

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TFormsMonitor

      Private _id As Long
      Private _primary As Boolean
      Private _left As Integer
      Private _top As Integer
      Private _width As Integer
      Private _height As Integer

      Sub New()
         MyBase.New()
         Dim workLeft As Integer
         Dim workTop As Integer
         Dim workWidth As Integer
         Dim workHeight As Integer
         WinAPI.Screen.FillWorkArea(workLeft, workTop, workWidth, workHeight)
         me._id = 0
         me._primary = True
         me._left = workLeft
         me._top = workTop
         me._width = workWidth
         me._height = workHeight
      End Sub

      Sub New(pId As Long, pPrimary As Boolean, pLeft As Integer, pTop As Integer, pWidth As Integer, pHeight As Integer)
         MyBase.New()
         me._id = pId
         me._primary = pPrimary
         me._left = pLeft
         me._top = pTop
         me._width = pWidth
         me._height = pHeight
      End Sub

      Property Id As Long
         Get
            Id = me._id
         End Get
      End Property

      Property Primary As Boolean
         Get
            Primary = me._primary
         End Get
      End Property

      Property Width As Integer
         Get
            Width = me._width
         End Get
      End Property

      Property Height As Integer
         Get
            Height = me._height
         End Get
      End Property

      Property WorkAreaWidth As Integer
         Get
            WorkAreaWidth = me._width
         End Get
      End Property

      Property WorkAreaHeight As Integer
         Get
            WorkAreaHeight = me._height
         End Get
      End Property

      Function SafeWidth(pMarginPercent As Integer) As Integer
         SafeWidth = CInt(me._width * (1 - (pMarginPercent / 100)))
      End Function

      Function SafeHeight(pMarginPercent As Integer) As Integer
         SafeHeight = CInt(me._height * (1 - (pMarginPercent / 100)))
      End Function

      Function CenterLeft(pWidth As Integer) As Integer
         CenterLeft = me._left + CInt((me._width - pWidth) / 2)
      End Function

      Function CenterTop(pHeight As Integer) As Integer
         CenterTop = me._top + CInt((me._height - pHeight) / 2)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
