' data7:disable unknown-symbol
' data7:disable shared-return-global-function
Imports Forms

Namespace mod_winapi

   Const SW_HIDE = 0
   Const SW_SHOWNORMAL = 1
   Const SW_NORMAL = 1
   Const SW_SHOWMINIMIZED = 2
   Const SW_SHOWMAXIMIZED = 3
   Const SW_MAXIMIZE = 3
   Const SW_SHOWNOACTIVATE = 4
   Const SW_SHOW = 5
   Const SW_MINIMIZE = 6
   Const SW_SHOWMINNOACTIVE = 7
   Const SW_SHOWNA = 8
   Const SW_RESTORE = 9
   Const SW_SHOWDEFAULT = 10
   Const SW_FORCEMINIMIZE = 11

   Private Const SM_CXSCREEN = 0
   Private Const SM_CYSCREEN = 1
   Private Const SM_XVIRTUALSCREEN = 76
   Private Const SM_YVIRTUALSCREEN = 77
   Private Const SM_CXVIRTUALSCREEN = 78
   Private Const SM_CYVIRTUALSCREEN = 79

   Private Const MOUSEEVENTF_MOVE = 1
   Private Const MOUSEEVENTF_LEFTDOWN = 2
   Private Const MOUSEEVENTF_LEFTUP = 4
   Private Const MOUSEEVENTF_RIGHTDOWN = 8
   Private Const MOUSEEVENTF_RIGHTUP = 16
   Private Const MOUSEEVENTF_MIDDLEDOWN = 32
   Private Const MOUSEEVENTF_MIDDLEUP = 64
   Private Const MOUSEEVENTF_WHEEL = 2048
   Private Const MOUSEEVENTF_ABSOLUTE = 32768

   Private Const MONITOR_DEFAULTTONULL = 0
   Private Const MONITOR_DEFAULTTOPRIMARY = 1
   Private Const MONITOR_DEFAULTTONEAREST = 2
   Private Const MONITOR_SIZE = 40
   Private Const SPI_GETWORKAREA = 48
   Private Const GW_HWNDNEXT = 2
   Private Const GW_CHILD = 5

   Private Structure TApiPoint
      X As Long
      Y As Long
   End Structure

   Private Structure TApiRect
      Left As Long
      Top As Long
      Right As Long
      Bottom As Long
   End Structure

   Private Structure TApiMonitorInfo
      cbSize As Long
      monLeft As Long
      monTop As Long
      monRight As Long
      monBottom As Long
      workLeft As Long
      workTop As Long
      workRight As Long
      workBottom As Long
      dwFlags As Long
   End Structure

   Private Structure TOSVersion
      Major As Long
      Minor As Long
      Build As Long
      Success As Boolean
      Function ToString() As String
         ToString = Major & "." & Minor & "." & Build
      End Function
   End Structure

   Private Declare Function _GetForegroundWindow Lib "user32.dll" Alias "GetForegroundWindow" As Long
   Private Declare Function _SetForegroundWindow Lib "user32.dll" Alias "SetForegroundWindow" (pHwnd As Long) As Long
   Private Declare Function _FindWindow Lib "user32.dll" Alias "FindWindowW" (pClassName As String, pWindowName As String) As Long
   Private Declare Function _FindWindowByTitle Lib "user32.dll" Alias "FindWindowW" (pClassName As Long, pWindowName As String) As Long
   Private Declare Function _GetDesktopWindow Lib "user32.dll" Alias "GetDesktopWindow" () As Long
   Private Declare Function _GetWindow Lib "user32.dll" Alias "GetWindow" (pHwnd As Long, pCmd As Long) As Long
   Private Declare Function _GetWindowTextW Lib "user32.dll" Alias "GetWindowTextW" (pHwnd As Long, pText As String, pMaxCount As Long) As Long
   Private Declare Function _IsWindowVisible Lib "user32.dll" Alias "IsWindowVisible" (pHwnd As Long) As Long
   Private Declare Function _MoveWindow Lib "user32.dll" Alias "MoveWindow" (pHwnd As Long, pX As Long, pY As Long, pWidth As Long, pHeight As Long, pRepaint As Boolean) As Long
   Private Declare Function _ShowWindow Lib "user32.dll" Alias "ShowWindow" (pHwnd As Long, pCmdShow As Long) As Long
   Private Declare Function _GetWindowRect Lib "user32.dll" Alias "GetWindowRect" (pHwnd As Long, ByRef pRect As TApiRect) As Long
   Private Declare Function _GetSystemMetrics Lib "user32.dll" Alias "GetSystemMetrics" (pIndex As Long) As Long
   Private Declare Function _SetCursorPos Lib "user32.dll" Alias "SetCursorPos" (pX As Long, pY As Long) As Long
   Private Declare Function _GetCursorPos Lib "user32.dll" Alias "GetCursorPos" (ByRef pPoint As TApiPoint) As Long
   Private Declare Function _GetMonitorInfo Lib "user32.dll" Alias "GetMonitorInfoA" (pMonitor As Long, ByRef pInfo As TApiMonitorInfo) As Long
   Private Declare Function _MonitorFromWindow Lib "user32.dll" Alias "MonitorFromWindow" (pHwnd As Long, pFlags As Long) As Long
   Private Declare Function _MonitorFromPoint Lib "user32.dll" Alias "MonitorFromPoint" (pX As Long, pY As Long, pFlags As Long) As Long
   Private Declare Function _MonitorFromRect Lib "user32.dll" Alias "MonitorFromRect" (ByRef pRect As TApiRect, pFlags As Long) As Long
   Private Declare Function _SystemParametersInfo Lib "user32.dll" Alias "SystemParametersInfoA" (pAction As Long, pParam As Long, ByRef pRect As TApiRect, pWinIni As Long) As Long
   Private Declare Sub _MouseEvent Lib "user32.dll" Alias "mouse_event" (pFlags As Long, pX As Long, pY As Long, pButtons As Long, pExtra As Long)

   Private Declare Function _CreateCompatibleDC Lib "gdi32" Alias "CreateCompatibleDC" (pDc As Long) As Long
   Private Declare Function _DeleteDC Lib "gdi32" Alias "DeleteDC" (pDc As Long) As Long
   Private Declare Function _CreateFont Lib "gdi32" Alias "CreateFontA" (pHeight As Long, pWidth As Long, pEscapement As Long, pOrientation As Long, pWeight As Long, pItalic As Long, pUnderline As Long, pStrikeOut As Long, pCharSet As Long, pOutputPrecision As Long, pClipPrecision As Long, pQuality As Long, pPitchAndFamily As Long, pFace As String) As Long
   Private Declare Function _SelectObject Lib "gdi32" Alias "SelectObject" (pDc As Long, pObject As Long) As Long
   Private Declare Function _DeleteObject Lib "gdi32" Alias "DeleteObject" (pObject As Long) As Long
   Private Declare Function _GetTextExtentPoint32 Lib "gdi32" Alias "GetTextExtentPoint32A" (pDc As Long, pText As String, pCount As Long, ByRef pSize As TApiPoint) As Long
   Private Declare Function _GetDC Lib "user32.dll" Alias "GetDC" (pHwnd As Long) As Long
   Private Declare Function _ReleaseDC Lib "user32.dll" Alias "ReleaseDC" (pHwnd As Long, pDc As Long) As Long

   Private Declare Function _ShellExecute Lib "shell32.dll" Alias "ShellExecuteW" (ByVal pHwnd As Long, ByVal pOperation As String, ByVal pFile As String, ByVal pParameters As String, ByVal pDirectory As String, ByVal pShowCmd As Long) As Long
   Private Declare Function _CharUpperBuffW Lib "user32" Alias "CharUpperBuffW" (ByVal lpsz As String, ByVal cchLength As Long) As Long
   Private Declare Function _CharLowerBuffW Lib "user32" Alias "CharLowerBuffW" (ByVal lpsz As String, ByVal cchLength As Long) As Long
   Private Declare Function _RtlGetVersion Lib "ntdll.dll" Alias "RtlGetVersion" (ByRef pOsInfo As Long) As Long

   Class WinAPI

      Shared Function Execute(pFile As String, pParameters As String, pRunAsAdm As Boolean = False, pShowWindow As Long = SW_HIDE) As Long
         Dim operation As String
         If pRunAsAdm Then
            operation = "runas"
         End If
         Execute = _ShellExecute(0, operation, pFile, pParameters, "", pShowWindow)
      End Function

      Shared Function Execute(pHwnd As Long, pOperation As String, pFile As String, pParameters As String, pDirectory As String, pShowWindow As Long) As Long
         Execute = _ShellExecute(pHwnd, pOperation, pFile, pParameters, pDirectory, pShowWindow)
      End Function

      Shared Function GetMetric(pIndex As Long) As Long
         GetMetric = _GetSystemMetrics(pIndex)
      End Function

      Shared Sub SendKeys(pKeys As String, pWait As Boolean = False)
         Dim shell As Variant = CreateObject("WScript.Shell")
         shell.SendKeys(pKeys, pWait)
         shell = ""
      End Sub

      Shared Function MeasureText(pHwnd As Long, pText As String) As TPoint
         Dim hDC As Long = _GetDC(pHwnd)
         Dim size As TApiPoint
         If hDC <> 0 Then
            _GetTextExtentPoint32(hDC, pText, Len(pText), size)
            _ReleaseDC(pHwnd, hDC)
         End If
         MeasureText = _toPoint(size)
      End Function

      Shared Function MeasureText(pText As String, pFont As FontConfig, pHwnd As Long = 0) As TPoint
         MeasureText = WinAPI.MeasureText(pText, pFont.Name, pFont.Height, pFont.Bold, pFont.Italic, pFont.Underline, pFont.Orientation, pFont.Charset, _fontQualityToInt(pFont.Quality), _fontPitchToInt(pFont.Pitch), pHwnd)
      End Function

      Shared Function MeasureText(pText As String, pFont As TFont, pHwnd As Long = 0) As TPoint
         MeasureText = WinAPI.MeasureText(pText, pFont.Name, pFont.Height, pFont.Bold, pFont.Italic, pFont.Underline, pFont.Orientation, pFont.Charset, _fontQualityToInt(pFont.Quality), _fontPitchToInt(pFont.Pitch), pHwnd)
      End Function

      Shared Function MeasureText(pText As String, pName As String, pHeight As Long, pBold As Boolean = False, pItalic As Boolean = False, pUnderline As Boolean = False, pOrientation As Long = 0, pCharSet As Long = 0, pQuality As Long = 0, pPitch As Long = 0, pHwnd As Long = 0) As TPoint
         Dim hDC As Long
         Dim hFont As Long
         Dim hOld As Long
         Dim size As TApiPoint
         Dim weight As Long = 400
         Dim italic As Long = 0
         Dim underline As Long = 0
         If pBold Then
            weight = 700
         End If
         If pItalic Then
            italic = 1
         End If
         If pUnderline Then
            underline = 1
         End If
         If pHwnd <> 0 Then
            hDC = _GetDC(pHwnd)
         Else
            hDC = _CreateCompatibleDC(0)
         End If
         hFont = _CreateFont(pHeight, 0, pOrientation, 0, weight, italic, underline, 0, pCharSet, 0, 0, pQuality, pPitch, pName)
         hOld = _SelectObject(hDC, hFont)
         _GetTextExtentPoint32(hDC, pText, Len(pText), size)
         _SelectObject(hDC, hOld)
         _DeleteObject(hFont)
         If pHwnd <> 0 Then
            _ReleaseDC(pHwnd, hDC)
         Else
            _DeleteDC(hDC)
         End If
         size.X = CLng(size.X * 1.2)
         MeasureText = _toPoint(size)
      End Function

      Shared Function CharUpper(pText As String) As String
         _CharUpperBuffW(pText, Len(pText))
         CharUpper = pText
      End Function

      Shared Function CharLower(pText As String) As String
         _CharLowerBuffW(pText, Len(pText))
         CharLower = pText
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

      Class Window

         Shared Function GetForeground() As Long
            GetForeground = _GetForegroundWindow()
         End Function

         Shared Function SetForeground(pHwnd As Long) As Long
            SetForeground = _SetForegroundWindow(pHwnd)
         End Function

         Shared Function Find(pClassName As String, pWindowName As String) As Long
            Find = _FindWindow(pClassName, pWindowName)
         End Function

         Shared Function FindByTitle(pWindowName As String) As Long
            FindByTitle = _FindWindowByTitle(0, pWindowName)
         End Function

         Shared Function FindContains(pPart As String) As Long
            Dim _needle As String = Trim(pPart)
            If _needle = "" Then
               FindContains = 0
               Exit Function
            End If
            _needle = UCase(_needle)
            Dim hwnd As Long = _GetWindow(_GetDesktopWindow(), GW_CHILD)
            Dim n As Integer
            For n = 1 To 4096
               If hwnd = 0 Then
                  Exit For
               End If
               If _IsWindowVisible(hwnd) <> 0 Then
                  Dim _title As String = GetTitle(hwnd)
                  If InStr(UCase(_title), _needle) > 0 Then
                     FindContains = hwnd
                     Exit Function
                  End If
               End If
               hwnd = _GetWindow(hwnd, GW_HWNDNEXT)
            Next
            FindContains = 0
         End Function

         Shared Function GetTitle(pHwnd As Long) As String
            Dim buf As String = Space(512)
            Dim n As Long = _GetWindowTextW(pHwnd, buf, 512)
            If n <= 0 Then
               GetTitle = ""
            Else
               GetTitle = Left(buf, CInt(n))
            End If
         End Function

         Shared Function IsVisible(pHwnd As Long) As Boolean
            IsVisible = (_IsWindowVisible(pHwnd) <> 0)
         End Function

         Shared Function Move(pHwnd As Long, pX As Long, pY As Long, pWidth As Long, pHeight As Long, pRepaint As Boolean) As Long
            Move = _MoveWindow(pHwnd, pX, pY, pWidth, pHeight, pRepaint)
         End Function

         Shared Function Show(pHwnd As Long, pCmdShow As Long) As Long
            Show = _ShowWindow(pHwnd, pCmdShow)
         End Function

         Shared Function Focus(pHwnd As Long, pRestore As Boolean = False) As Boolean
            If pRestore Then
               _ShowWindow(pHwnd, SW_RESTORE)
            End If
            _SetForegroundWindow(pHwnd)
            Focus = (_GetForegroundWindow() = pHwnd)
         End Function

         Shared Function GetRect(pHwnd As Long) As TRect
            Dim box As TApiRect
            _GetWindowRect(pHwnd, box)
            GetRect = _toRect(box)
         End Function

         Sub New()
            MyBase.New()
         End Sub

         Sub Free()
            MyBase.Free()
         End Sub

      End Class

      Class Mouse

         Shared Function GetPos() As TPoint
            Dim pos As TApiPoint
            _GetCursorPos(pos)
            GetPos = _toPoint(pos)
         End Function

         Shared Sub SetPos(pPoint As TPoint)
            Mouse.SetPos(pPoint.X, pPoint.Y)
         End Sub

         Shared Sub SetPos(pX As Long, pY As Long)
            _SetCursorPos(pX, pY)
         End Sub

         Shared Sub LeftClick()
            Mouse.Dispatch(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
            Mouse.Dispatch(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
         End Sub

         Shared Sub LeftClick(pPoint As TPoint)
            Mouse.LeftClick(pPoint.X, pPoint.Y)
         End Sub

         Shared Sub LeftClick(pX As Long, pY As Long)
            Mouse.SetPos(pX, pY)
            Sleep(50)
            Mouse.LeftClick()
         End Sub

         Shared Sub RightClick()
            Mouse.Dispatch(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
            Mouse.Dispatch(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
         End Sub

         Shared Sub RightClick(pPoint As TPoint)
            Mouse.RightClick(pPoint.X, pPoint.Y)
         End Sub

         Shared Sub RightClick(pX As Long, pY As Long)
            Mouse.SetPos(pX, pY)
            Sleep(50)
            Mouse.RightClick()
         End Sub

         Shared Sub MiddleClick()
            Mouse.Dispatch(MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0)
            Mouse.Dispatch(MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0)
         End Sub

         Shared Sub DoubleClick()
            Mouse.LeftClick()
            Sleep(100)
            Mouse.LeftClick()
         End Sub

         Shared Sub ScrollVertical(pAmount As Long)
            Mouse.Dispatch(MOUSEEVENTF_WHEEL, 0, 0, pAmount, 0)
         End Sub

         Shared Sub Dispatch(pFlags As Long, pX As Long, pY As Long, pButtons As Long, pExtra As Long)
            _MouseEvent(pFlags, pX, pY, pButtons, pExtra)
         End Sub

         Sub New()
            MyBase.New()
         End Sub

         Sub Free()
            MyBase.Free()
         End Sub

      End Class

      Class Screen

         Shared Function CurrentWindow() As Integer
            CurrentWindow = CInt(WinAPI.Window.GetForeground())
         End Function

         Shared Function Height() As Integer
            Dim workLeft As Integer
            Dim workTop As Integer
            Dim workWidth As Integer
            Dim workHeight As Integer
            Screen.FillWorkArea(workLeft, workTop, workWidth, workHeight)
            Height = workHeight
         End Function

         Shared Function Width() As Integer
            Dim workLeft As Integer
            Dim workTop As Integer
            Dim workWidth As Integer
            Dim workHeight As Integer
            Screen.FillWorkArea(workLeft, workTop, workWidth, workHeight)
            Width = workWidth
         End Function

         Shared Function WorkAreaHeight() As Integer
            WorkAreaHeight = Screen.Height()
         End Function

         Shared Function WorkAreaWidth() As Integer
            WorkAreaWidth = Screen.Width()
         End Function

         Shared Sub FillWorkArea(ByRef pLeft As Integer, ByRef pTop As Integer, ByRef pWidth As Integer, ByRef pHeight As Integer)
            Dim box As TApiRect = _workAreaBox()
            pLeft = CInt(box.Left)
            pTop = CInt(box.Top)
            pWidth = CInt(box.Right - box.Left)
            pHeight = CInt(box.Bottom - box.Top)
            If pWidth < 1 Then
               pWidth = 1
            End If
            If pHeight < 1 Then
               pHeight = 1
            End If
         End Sub

         Shared Function VirtualHeight() As Integer
            VirtualHeight = Screen.VirtualMonitor().Height
         End Function

         Shared Function VirtualWidth() As Integer
            VirtualWidth = Screen.VirtualMonitor().Width
         End Function

         Shared Function CurrentMonitor() As TMonitor
            CurrentMonitor = Screen.FromWorkArea()
         End Function

         Shared Function PrimaryMonitor() As TMonitor
            PrimaryMonitor = Screen.FromWorkArea()
         End Function

         Shared Function VirtualMonitor() As TMonitor
            VirtualMonitor = New TMonitor(0, False, 0, 0, CInt(_GetSystemMetrics(SM_CXVIRTUALSCREEN)), CInt(_GetSystemMetrics(SM_CYVIRTUALSCREEN)))
         End Function

         Shared Function MonitorFromPoint(pPoint As TPoint) As TMonitor
            Dim hMonitor As Long = _MonitorFromPoint(pPoint.X, pPoint.Y, MONITOR_DEFAULTTONEAREST)
            MonitorFromPoint = GetMonitorByHandle(hMonitor)
         End Function

         Shared Function MonitorFromWindow(pHandle As Long) As TMonitor
            Dim flags As Long = MONITOR_DEFAULTTONEAREST
            If pHandle = 0 Then
               flags = MONITOR_DEFAULTTOPRIMARY
            End If
            MonitorFromWindow = GetMonitorByHandle(_MonitorFromWindow(pHandle, flags))
         End Function

         Shared Function MonitorFromRect(pRect As TRect) As TMonitor
            Dim box As TApiRect = _fromRect(pRect)
            MonitorFromRect = GetMonitorByHandle(_MonitorFromRect(box, MONITOR_DEFAULTTONEAREST))
         End Function

         Shared Function FromWorkArea() As TMonitor
            Dim box As TApiRect = _workAreaBox()
            FromWorkArea = New TMonitor(0, True, CInt(box.Left), CInt(box.Top), CInt(box.Right), CInt(box.Bottom))
         End Function

         Private Shared Function _workAreaBox() As TApiRect
            Dim box As TApiRect
            If _SystemParametersInfo(SPI_GETWORKAREA, 0, box, 0) = 0 Then
               box.Left = _GetSystemMetrics(SM_XVIRTUALSCREEN)
               box.Top = _GetSystemMetrics(SM_YVIRTUALSCREEN)
               box.Right = box.Left + _GetSystemMetrics(SM_CXSCREEN)
               box.Bottom = box.Top + _GetSystemMetrics(SM_CYSCREEN)
               If box.Right <= box.Left Then
                  box.Right = box.Left + _GetSystemMetrics(SM_CXVIRTUALSCREEN)
               End If
               If box.Bottom <= box.Top Then
                  box.Bottom = box.Top + _GetSystemMetrics(SM_CYVIRTUALSCREEN)
               End If
            End If
            _workAreaBox = box
         End Function

         Private Shared Function GetMonitorByHandle(pHandle As Long) As TMonitor
            Dim box As TApiRect = _workAreaBox()
            GetMonitorByHandle = New TMonitor(pHandle, True, CInt(box.Left), CInt(box.Top), CInt(box.Right), CInt(box.Bottom))
         End Function

         Sub New()
            MyBase.New()
         End Sub

         Sub Free()
            MyBase.Free()
         End Sub

      End Class

      Class OS
         
         Sub New()
            MyBase.New()
         End Sub

         Sub Free()
            MyBase.Free()
         End Sub

         Private Shared Function _GetOSData() As TOSVersion
            ' @data7:keep
            Dim osInfo(70) As Long
            Dim res As TOSVersion

            osInfo(0) = 284
            res.Success = False

            If _RtlGetVersion(osInfo(0)) = 0 Then
               res.Major = osInfo(1)
               res.Minor = osInfo(2)
               res.Build = osInfo(3)
               res.Success = True
            End If

            _GetOSData = res
         End Function

         Shared Function GetVersion() As TOSVersion
            GetVersion = _GetOSData()
         End Function

         Shared Function IsWindows11() As Boolean
            Dim os As TOSVersion = _GetOSData()
            If os.Success Then
               ' Windows 11 é versão 10.0 com Build 22000 ou superior
               IsWindows11 = (os.Major = 10 And os.Minor = 0 And os.Build >= 22000)
            Else
               IsWindows11 = False
            End If
         End Function

         Shared Function IsWindows10() As Boolean
            Dim os As TOSVersion = _GetOSData()
            If os.Success Then
               ' Windows 10 é versão 10.0 com Build inferior a 22000
               IsWindows10 = (os.Major = 10 And os.Minor = 0 And os.Build < 22000)
            Else
               IsWindows10 = False
            End If
         End Function

         Shared Function IsWindows8Or81() As Boolean
            Dim os As TOSVersion = _GetOSData()
            If os.Success Then
               ' Windows 8 é 6.2 e Windows 8.1 é 6.3
               IsWindows8Or81 = (os.Major = 6 And (os.Minor = 2 Or os.Minor = 3))
            Else
               IsWindows8Or81 = False
            End If
         End Function

         Shared Function IsWindows7() As Boolean
            Dim os As TOSVersion = _GetOSData()
            If os.Success Then
               ' Windows 7 é 6.1
               IsWindows7 = (os.Major = 6 And os.Minor = 1)
            Else
               IsWindows7 = False
            End If
         End Function

      End Class

   End Class

   Class TMonitor

      Private _id As Long
      Private _primary As Boolean
      Private _left As Integer
      Private _top As Integer
      Private _right As Integer
      Private _bottom As Integer
      Private _workLeft As Integer
      Private _workTop As Integer
      Private _workRight As Integer
      Private _workBottom As Integer

      Sub New(pId As Long, pPrimary As Boolean, pLeft As Integer, pTop As Integer, pRight As Integer, pBottom As Integer)
         MyBase.New()
         me._id = pId
         me._primary = pPrimary
         me._left = pLeft
         me._top = pTop
         me._right = pRight
         me._bottom = pBottom
         me._workLeft = pLeft
         me._workTop = pTop
         me._workRight = pRight
         me._workBottom = pBottom
      End Sub

      Property ID As Long
         Get
            ID = me._id
         End Get
      End Property

      Property Primary As Boolean
         Get
            Primary = me._primary
         End Get
      End Property

      Property WorkLeft As Integer
         Get
            WorkLeft = me._workLeft
         End Get
      End Property

      Property WorkTop As Integer
         Get
            WorkTop = me._workTop
         End Get
      End Property

      Property Bounds As TRect
         Get
            Bounds = _makeRect(me._left, me._top, me._right, me._bottom)
         End Get
      End Property

      Property WorkArea As TRect
         Get
            WorkArea = _makeRect(me._workLeft, me._workTop, me._workRight, me._workBottom)
         End Get
      End Property

      Property Width As Integer
         Get
            Width = me._right - me._left
         End Get
      End Property

      Property Height As Integer
         Get
            Height = me._bottom - me._top
         End Get
      End Property

      Property WorkAreaWidth As Integer
         Get
            WorkAreaWidth = me._workRight - me._workLeft
         End Get
      End Property

      Property WorkAreaHeight As Integer
         Get
            WorkAreaHeight = me._workBottom - me._workTop
         End Get
      End Property

      Function SafeWidth(pMarginPercent As Integer) As Integer
         SafeWidth = CInt(me.WorkAreaWidth * (1 - (pMarginPercent / 100)))
      End Function

      Function SafeHeight(pMarginPercent As Integer) As Integer
         SafeHeight = CInt(me.WorkAreaHeight * (1 - (pMarginPercent / 100)))
      End Function

      Function CenterLeft(pWidth As Integer) As Integer
         CenterLeft = me._workLeft + CInt((me.WorkAreaWidth - pWidth) / 2)
      End Function

      Function CenterTop(pHeight As Integer) As Integer
         CenterTop = me._workTop + CInt((me.WorkAreaHeight - pHeight) / 2)
      End Function

      Private Function _rectText(pLeft As Integer, pTop As Integer, pRight As Integer, pBottom As Integer) As String
         _rectText = "[" & CStr(pLeft) & "," & CStr(pTop) & " - " & CStr(pRight) & "," & CStr(pBottom) & "]"
      End Function

      Function ToString(pPrint As Boolean = False) As String
         With New Collections.StringList()
            .Add("ID: " & CStr(me.ID))
            .Add("Primary: " & CStr(me.Primary))
            .Add("Bounds: " & me._rectText(me._left, me._top, me._right, me._bottom))
            .Add("WorkArea: " & me._rectText(me._workLeft, me._workTop, me._workRight, me._workBottom))
            .Add("Width: " & CStr(me.Width))
            .Add("Height: " & CStr(me.Height))
            .Add("WorkAreaWidth: " & CStr(me.WorkAreaWidth))
            .Add("WorkAreaHeight: " & CStr(me.WorkAreaHeight))
            If pPrint Then
               print(.Text)
               Forms.ProcessMessages()
            End If
            ToString = .Text
            .Free()
         End With
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Private Function _toPoint(pValue As TApiPoint) As TPoint
      Dim nextPoint As TPoint
      nextPoint.X = CInt(pValue.X)
      nextPoint.Y = CInt(pValue.Y)
      _toPoint = nextPoint
   End Function

   Private Function _toRect(pValue As TApiRect) As TRect
      _toRect = _makeRect(CInt(pValue.Left), CInt(pValue.Top), CInt(pValue.Right), CInt(pValue.Bottom))
   End Function

   Private Function _fromRect(pValue As TRect) As TApiRect
      Dim box As TApiRect
      box.Left = pValue.Left
      box.Top = pValue.Top
      box.Right = pValue.Right
      box.Bottom = pValue.Bottom
      _fromRect = box
   End Function

   Private Function _makeRect(pLeft As Integer, pTop As Integer, pRight As Integer, pBottom As Integer) As TRect
      Dim box As TRect
      box.Left = pLeft
      box.Top = pTop
      box.Right = pRight
      box.Bottom = pBottom
      _makeRect = box
   End Function

   Private Function _fontQualityToInt(pQuality As TFontQuality) As Long
      Select pQuality
         Case fqDefault
            _fontQualityToInt = 0
         Case fqDraft
            _fontQualityToInt = 1
         Case fqProof
            _fontQualityToInt = 2
         Case fqNonAntialiased
            _fontQualityToInt = 3
         Case fqAntialiased
            _fontQualityToInt = 4
         Case fqClearType
            _fontQualityToInt = 5
         Case fqClearTypeNatural
            _fontQualityToInt = 6
         Case Else
            _fontQualityToInt = 0
      End Select
   End Function

   Private Function _fontPitchToInt(pPitch As TFontPitch) As Long
      Select pPitch
         Case fpDefault
            _fontPitchToInt = 0
         Case fpFixed
            _fontPitchToInt = 2
         Case fpVariable
            _fontPitchToInt = 1
         Case Else
            _fontPitchToInt = 0
      End Select
   End Function

End Namespace
