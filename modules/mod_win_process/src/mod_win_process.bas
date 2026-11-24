Imports Collections
Imports mod_tobject

' Windows process engine (hidden by default; Visible=True shows the window).
' Imports mod_win_process
' Dim job As New TWinProcess()
' job.Visible = True
' job.RunAsAdmin = True
' job.WorkingDir = "C:\data"
' If job.Start("""C:\tool\tool.exe"" -args") Then
'    While job.IsRunning()
'       Dim line As String = job.PullStdOutLine()
'    Wend
' End If
' job.Free()

Namespace mod_win_process

   Private Const STILL_ACTIVE = 259
   Private Const CREATE_NO_WINDOW = 134217728
   Private Const STARTF_USESHOWWINDOW = 1
   Private Const STARTF_USESTDHANDLES = 256
   Private Const STARTUPINFO_BYTES = 68
   Private Const STARTUPINFOEX_BYTES = 72
   Private Const HANDLE_FLAG_INHERIT = 1
   Private Const PIPE_READ_MAX = 4096
   Private Const EXTENDED_STARTUPINFO_PRESENT = 524288
   Private Const PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE = 131094
   Private Const HEAP_ZERO_MEMORY = 8
   Private Const PTY_COLS = 120
   Private Const PTY_ROWS = 40
   Private Const CREATE_NEW_CONSOLE = 16
   Private Const SW_HIDE = 0
   Private Const SW_SHOWNORMAL = 1
   Private Const CONSOLE_LINE_CHARS = 120
   Private Const GENERIC_READ_WRITE = -1073741824
   Private Const FILE_SHARE_RW = 3
   Private Const OPEN_EXISTING = 3
   Private Const INVALID_HANDLE_VALUE = -1
   Private Const WAIT_OBJECT_0 = 0
   Private Const SEE_MASK_NOCLOSEPROCESS = 64
   Private Const SHELLEXECINFO_BYTES = 60
   Private Const TOKEN_QUERY = 8
   Private Const TokenElevation = 20
   Private Const ERROR_CANCELLED = 1223

   Private Structure TProcStartup
      cb As Long
      reserved1 As Long
      desktop As Long
      titleText As Long
      x As Long
      y As Long
      xSize As Long
      ySize As Long
      xCount As Long
      yCount As Long
      fill As Long
      flags As Long
      showAndRes As Long
      reserved3 As Long
      stdIn As Long
      stdOut As Long
      stdErr As Long
   End Structure

   Private Structure TProcInfo
      hProc As Long
      hThread As Long
      processId As Long
      threadId As Long
   End Structure

   Private Structure TPipeSecurity
      nLength As Long
      descriptor As Long
      inheritHandle As Long
   End Structure

   Private Structure TConsoleInfo
      sizeXY As Long
      cursorXY As Long
      attributes As Word
      winLeft As Word
      winTop As Word
      winRight As Word
      winBottom As Word
      maxWinXY As Long
   End Structure

   Private Structure TTokenElevation
      TokenIsElevated As Long
   End Structure

   Private Structure TShellExecInfo
      cbSize As Long
      fMask As Long
      hwnd As Long
      lpVerb As String
      lpFile As String
      lpParameters As String
      lpDirectory As String
      nShow As Long
      hInstApp As Long
      lpIDList As Long
      lpClass As Long
      hkeyClass As Long
      dwHotKey As Long
      hIcon As Long
      hProcess As Long
   End Structure

   Private Structure TProcStartupEx
      cb As Long
      reserved1 As Long
      desktop As Long
      titleText As Long
      x As Long
      y As Long
      xSize As Long
      ySize As Long
      xCount As Long
      yCount As Long
      fill As Long
      flags As Long
      showAndRes As Long
      reserved3 As Long
      stdIn As Long
      stdOut As Long
      stdErr As Long
      attrList As Long
   End Structure

   Private Declare Function CloseHandle Lib "kernel32.dll" (ByVal pHandle As Long) As Long
   Private Declare Function TerminateProcess Lib "kernel32.dll" (ByVal pProcess As Long, ByVal pExitCode As Long) As Long
   Private Declare Function GetExitCodeProcess Lib "kernel32.dll" (ByVal pProcess As Long, ByRef pExitCode As Long) As Long
   Private Declare Function CreatePipe Lib "kernel32.dll" (ByRef pRead As Long, ByRef pWrite As Long, ByRef pSec As TPipeSecurity, ByVal pSize As Long) As Long
   Private Declare Function SetHandleInformation Lib "kernel32.dll" (ByVal pHandle As Long, ByVal pMask As Long, ByVal pFlags As Long) As Long
   Private Declare Function PeekNamedPipe Lib "kernel32.dll" (ByVal pPipe As Long, ByVal pBuffer As Long, ByVal pSize As Long, ByVal pRead As Long, ByRef pAvail As Long, ByVal pLeft As Long) As Long
   Private Declare Function ReadFile Lib "kernel32.dll" (ByVal pFile As Long, ByVal pBuffer As AnsiString, ByVal pBytes As Long, ByRef pRead As Long, ByVal pOverlapped As Long) As Long
   Private Declare Function WriteFile Lib "kernel32.dll" (ByVal pFile As Long, ByVal pBuffer As AnsiString, ByVal pBytes As Long, ByRef pWritten As Long, ByVal pOverlapped As Long) As Long
   Private Declare Function CreateProcessW Lib "kernel32.dll" (ByVal pAppName As Long, ByVal pCmdLine As String, ByVal pProcAttr As Long, ByVal pThreadAttr As Long, ByVal pInherit As Long, ByVal pFlags As Long, ByVal pEnv As Long, ByVal pCurDir As Long, ByRef pStartup As TProcStartup, ByRef pInfo As TProcInfo) As Long
   Private Declare Function CreateProcessWAt Lib "kernel32.dll" Alias "CreateProcessW" (ByVal pAppName As Long, ByVal pCmdLine As String, ByVal pProcAttr As Long, ByVal pThreadAttr As Long, ByVal pInherit As Long, ByVal pFlags As Long, ByVal pEnv As Long, ByVal pCurDir As String, ByRef pStartup As TProcStartup, ByRef pInfo As TProcInfo) As Long
   Private Declare Function CreateProcessWEx Lib "kernel32.dll" Alias "CreateProcessW" (ByVal pAppName As Long, ByVal pCmdLine As String, ByVal pProcAttr As Long, ByVal pThreadAttr As Long, ByVal pInherit As Long, ByVal pFlags As Long, ByVal pEnv As Long, ByVal pCurDir As Long, ByRef pStartup As TProcStartupEx, ByRef pInfo As TProcInfo) As Long
   Private Declare Function CreateProcessWExAt Lib "kernel32.dll" Alias "CreateProcessW" (ByVal pAppName As Long, ByVal pCmdLine As String, ByVal pProcAttr As Long, ByVal pThreadAttr As Long, ByVal pInherit As Long, ByVal pFlags As Long, ByVal pEnv As Long, ByVal pCurDir As String, ByRef pStartup As TProcStartupEx, ByRef pInfo As TProcInfo) As Long
   Private Declare Function CreatePseudoConsole Lib "kernel32.dll" (ByVal pSize As Long, ByVal pInput As Long, ByVal pOutput As Long, ByVal pFlags As Long, ByRef pHpcon As Long) As Long
   Private Declare Function ClosePseudoConsole Lib "kernel32.dll" (ByVal pHpcon As Long) As Long
   Private Declare Function InitializeProcThreadAttributeList Lib "kernel32.dll" (ByVal pList As Long, ByVal pCount As Long, ByVal pFlags As Long, ByRef pSize As Long) As Long
   Private Declare Function UpdateProcThreadAttribute Lib "kernel32.dll" (ByVal pList As Long, ByVal pFlags As Long, ByVal pAttr As Long, ByRef pValue As Long, ByVal pSize As Long, ByVal pPrev As Long, ByVal pReturnSize As Long) As Long
   Private Declare Function DeleteProcThreadAttributeList Lib "kernel32.dll" (ByVal pList As Long) As Long
   Private Declare Function GetProcessHeap Lib "kernel32.dll" () As Long
   Private Declare Function HeapAlloc Lib "kernel32.dll" (ByVal pHeap As Long, ByVal pFlags As Long, ByVal pBytes As Long) As Long
   Private Declare Function HeapFree Lib "kernel32.dll" (ByVal pHeap As Long, ByVal pFlags As Long, ByVal pMem As Long) As Long
   Private Declare Function GetCurrentProcess Lib "kernel32.dll" () As Long
   Private Declare Function IsWow64Process Lib "kernel32.dll" (ByVal pProcess As Long, ByRef pWow64 As Long) As Long
   Private Declare Function AttachConsole Lib "kernel32.dll" (ByVal pPid As Long) As Long
   Private Declare Function FreeConsole Lib "kernel32.dll" () As Long
   Private Declare Function GetConsoleScreenBufferInfo Lib "kernel32.dll" (ByVal pConsole As Long, ByRef pInfo As TConsoleInfo) As Long
   Private Declare Function ReadConsoleOutputCharacterW Lib "kernel32.dll" (ByVal pConsole As Long, ByVal pChars As String, ByVal pLen As Long, ByVal pCoord As Long, ByRef pRead As Long) As Long
   Private Declare Function GetConsoleWindow Lib "kernel32.dll" () As Long
   Private Declare Function ShowWindowApi Lib "user32.dll" Alias "ShowWindow" (ByVal pHwnd As Long, ByVal pCmd As Long) As Long
   Private Declare Function CreateFileW Lib "kernel32.dll" (ByVal pName As String, ByVal pAccess As Long, ByVal pShare As Long, ByVal pSec As Long, ByVal pDisp As Long, ByVal pFlags As Long, ByVal pTemp As Long) As Long
   Private Declare Function WaitForSingleObject Lib "kernel32.dll" (ByVal pHandle As Long, ByVal pMs As Long) As Long
   Private Declare Function GetProcessId Lib "kernel32.dll" (ByVal pProcess As Long) As Long
   Private Declare Function OpenProcessToken Lib "advapi32.dll" (ByVal pProcess As Long, ByVal pAccess As Long, ByRef pToken As Long) As Long
   Private Declare Function GetTokenInformation Lib "advapi32.dll" (ByVal pToken As Long, ByVal pClass As Long, ByRef pInfo As TTokenElevation, ByVal pLen As Long, ByRef pRetLen As Long) As Long
   Private Declare Function ShellExecuteExW Lib "shell32.dll" (ByRef pExec As TShellExecInfo) As Long
   Private Declare Function GetLastError Lib "kernel32.dll" () As Long

   Class TWinProcess
      Inherits TTObject

      Private _useConsole As Boolean
      Private _mergeStdErr As Boolean
      Private _visible As Boolean
      Private _workingDir As String
      Private _runAsAdmin As Boolean
      Private _hProcess As Long
      Private _hStdInWrite As Long
      Private _hStdOutRead As Long
      Private _hStdErrRead As Long
      Private _hPC As Long
      Private _pid As Long
      Private _outBuf As String
      Private _errBuf As String
      Private _exitCode As Integer
      Private _kind As String
      Private _lastConsoleLine As String
      Private _commandLine As String
      Private _lastError As Long
      Private _lastErrorText As String

      Sub New()
         MyBase.New()
         me._useConsole = True
         me._mergeStdErr = True
         me._visible = False
         me._workingDir = ""
         me._runAsAdmin = False
         me._hProcess = 0
         me._hStdInWrite = 0
         me._hStdOutRead = 0
         me._hStdErrRead = 0
         me._hPC = 0
         me._pid = 0
         me._outBuf = ""
         me._errBuf = ""
         me._exitCode = -1
         me._kind = ""
         me._lastConsoleLine = ""
         me._commandLine = ""
         me._lastError = 0
         me._lastErrorText = ""
      End Sub

      Property UseConsole As Boolean
         Get
            UseConsole = me._useConsole
         End Get
         Set(pValue As Boolean)
            me._useConsole = pValue
         End Set
      End Property

      Property MergeStdErr As Boolean
         Get
            MergeStdErr = me._mergeStdErr
         End Get
         Set(pValue As Boolean)
            me._mergeStdErr = pValue
         End Set
      End Property

      Property Visible As Boolean
         Get
            Visible = me._visible
         End Get
         Set(pValue As Boolean)
            me._visible = pValue
         End Set
      End Property

      Property WorkingDir As String
         Get
            WorkingDir = me._workingDir
         End Get
         Set(pValue As String)
            me._workingDir = pValue
         End Set
      End Property

      Property RunAsAdmin As Boolean
         Get
            RunAsAdmin = me._runAsAdmin
         End Get
         Set(pValue As Boolean)
            me._runAsAdmin = pValue
         End Set
      End Property

      Function ProcessKind() As String
         ProcessKind = me._kind
      End Function

      Function ProcessId() As Long
         ProcessId = me._pid
      End Function

      Function CommandLine() As String
         CommandLine = me._commandLine
      End Function

      Function LastError() As Long
         LastError = me._lastError
      End Function

      Function LastErrorText() As String
         LastErrorText = me._lastErrorText
      End Function

      Function IsRunning() As Boolean
         IsRunning = me.StillRunning()
      End Function

      Function ExitCode() As Integer
         If me._hProcess <> 0 Then
            me.StillRunning()
         End If
         ExitCode = me._exitCode
      End Function

      Overridable Function Start(pCommand As String = "") As Boolean
         me.StopProcess(True)
         me._exitCode = -1
         me._pid = 0
         me._outBuf = ""
         me._errBuf = ""
         me._kind = ""
         me._lastConsoleLine = ""
         me._commandLine = pCommand
         me._lastError = 0
         me._lastErrorText = ""
         If me._runAsAdmin Then
            If Not me.ParentIsElevated() Then
               If me.SpawnElevated(pCommand) Then
                  me._kind = "runas"
                  Start = True
                  Exit Function
               End If
               me.CaptureWinError("Failed to start elevated process")
               Start = False
               Exit Function
            End If
         End If
         If me._useConsole Then
            If Not me._visible Then
               If Not me.ParentIsWow64() Then
                  If me.SpawnPty(pCommand) Then
                     me._kind = "pty"
                     Start = True
                     Exit Function
                  End If
               End If
            End If
            If me.SpawnConsole(pCommand) Then
               me._kind = "console"
               Start = True
               Exit Function
            End If
         End If
         If me.SpawnPipes(pCommand) Then
            me._kind = "pipes"
            Start = True
            Exit Function
         End If
         me.CaptureWinError("Failed to start process")
         Start = False
      End Function

      Private Function StartPipes(pCommand As String) As Boolean
         Dim prevConsole As Boolean
         prevConsole = me._useConsole
         me._useConsole = False
         StartPipes = me.Start(pCommand)
         me._useConsole = prevConsole
      End Function

      Function Run(pCommand As String = "") As Integer
         If Not me.StartPipes(pCommand) Then
            Run = 1
            Exit Function
         End If
         While Not me.WaitExit(50)
            me.PullStdOut()
            me.PullStdErr()
         Wend
         Run = me.ExitCode()
         me.StopProcess(False)
      End Function

      Function CaptureLines(pCommand As String = "") As StringList
         Dim list As New StringList()
         Dim line As String
         If Not me.StartPipes(pCommand) Then
            CaptureLines = list
            Exit Function
         End If
         While True
            line = me.PullStdOutLine()
            If line <> "" Then
               If Trim(line) <> "" Then
                  list.Add(line)
               End If
            Else
               If Not me.IsRunning() Then
                  Exit While
               End If
               me.WaitExit(50)
            End If
         Wend
         me.StopProcess(False)
         CaptureLines = list
      End Function

      Function PullStdOut() As String
         If me._hStdOutRead <> 0 Then
            PullStdOut = me.DrainHandle(me._hStdOutRead)
            Exit Function
         End If
         PullStdOut = me.DrainConsole()
      End Function

      Function PullStdOutLine() As String
         PullStdOutLine = me.NextBufferedLine(me.PullStdOut(), me._outBuf)
      End Function

      Function PullStdErr() As String
         If me._hStdErrRead = 0 Then
            PullStdErr = ""
            Exit Function
         End If
         PullStdErr = me.DrainHandle(me._hStdErrRead)
      End Function

      Function PullStdErrLine() As String
         PullStdErrLine = me.NextBufferedLine(me.PullStdErr(), me._errBuf)
      End Function

      Function WriteStdin(pText As String) As Boolean
         If me._hStdInWrite <> 0 Then
            WriteStdin = me.WritePipe(me._hStdInWrite, pText)
            Exit Function
         End If
         If me._pid <> 0 Then
            WriteStdin = me.WriteConsoleIn(pText)
            Exit Function
         End If
         WriteStdin = False
      End Function

      Function WriteLine(pText As String) As Boolean
         WriteLine = me.WriteStdin(pText & Chr(13) & Chr(10))
      End Function

      Function WaitLine() As String
         Dim line As String
         While True
            line = me.PullStdOutLine()
            If line <> "" Then
               WaitLine = line
               Exit Function
            End If
            If Not me.IsRunning() Then
               WaitLine = me.PullStdOutLine()
               Exit Function
            End If
            Sleep(10)
         Wend
      End Function

      Function WaitOutput(pSuccessToken As String, pErrorToken As String = "") As String
         Dim line As String
         While True
            line = me.PullStdOutLine()
            If line <> "" Then
               If pSuccessToken <> "" Then
                  If line.Contains(pSuccessToken) Then
                     WaitOutput = line
                     Exit Function
                  End If
               End If
               If pErrorToken <> "" Then
                  If line.Contains(pErrorToken) Then
                     WaitOutput = line
                     Exit Function
                  End If
               End If
            Else
               If Not me.IsRunning() Then
                  WaitOutput = ""
                  Exit Function
               End If
               Sleep(10)
            End If
         Wend
      End Function

      Function WaitExit(pTimeoutMs As Long = -1) As Boolean
         Dim waitCode As Long
         If me._hProcess = 0 Then
            WaitExit = True
            Exit Function
         End If
         waitCode = WaitForSingleObject(me._hProcess, pTimeoutMs)
         me.StillRunning()
         WaitExit = Not me.IsRunning()
      End Function

      Sub StopProcess(pKill As Boolean = True)
         If me._hProcess <> 0 Then
            If pKill Then
               If me.StillRunning() Then
                  TerminateProcess(me._hProcess, 1)
               End If
            Else
               me.StillRunning()
            End If
         End If
         If me._hPC <> 0 Then
            ClosePseudoConsole(me._hPC)
            me._hPC = 0
         End If
         me._lastConsoleLine = ""
         me.ReleaseHandle(me._hStdInWrite)
         me.ReleaseHandle(me._hStdOutRead)
         me.ReleaseHandle(me._hStdErrRead)
         me.ReleaseHandle(me._hProcess)
         me._outBuf = ""
         me._errBuf = ""
      End Sub

      Private Sub ReleaseHandle(ByRef pHandle As Long)
         If pHandle <> 0 Then
            CloseHandle(pHandle)
            pHandle = 0
         End If
      End Sub

      Private Sub CaptureWinError(pText As String)
         Dim code As Long
         Dim detail As String
         code = GetLastError()
         If code = 0 Then
            code = me._lastError
         End If
         me._lastError = code
         If code = ERROR_CANCELLED Then
            me._lastErrorText = "The user cancelled the UAC prompt"
            Exit Sub
         End If
         detail = pText
         If code <> 0 Then
            detail = pText & " (" & CStr(code) & ")"
         End If
         me._lastErrorText = detail
      End Sub

      Private Function WindowShowCmd() As Long
         If me._visible Then
            WindowShowCmd = SW_SHOWNORMAL
         Else
            WindowShowCmd = SW_HIDE
         End If
      End Function

      Private Function PipeCreateFlags() As Long
         If me._visible Then
            PipeCreateFlags = 0
         Else
            PipeCreateFlags = CREATE_NO_WINDOW
         End If
      End Function

      Private Function LaunchProcess(pCommand As String, pInherit As Long, pFlags As Long, ByRef pStartup As TProcStartup, ByRef pInfo As TProcInfo) As Long
         Dim cmdCopy As String
         Dim created As Long
         cmdCopy = pCommand
         If me._workingDir = "" Then
            created = CreateProcessW(0, cmdCopy, 0, 0, pInherit, pFlags, 0, 0, pStartup, pInfo)
         Else
            created = CreateProcessWAt(0, cmdCopy, 0, 0, pInherit, pFlags, 0, me._workingDir, pStartup, pInfo)
         End If
         If created = 0 Then
            me._lastError = GetLastError()
         End If
         LaunchProcess = created
      End Function

      Private Function LaunchProcessEx(pCommand As String, pInherit As Long, pFlags As Long, ByRef pStartup As TProcStartupEx, ByRef pInfo As TProcInfo) As Long
         Dim cmdCopy As String
         Dim created As Long
         cmdCopy = pCommand
         If me._workingDir = "" Then
            created = CreateProcessWEx(0, cmdCopy, 0, 0, pInherit, pFlags, 0, 0, pStartup, pInfo)
         Else
            created = CreateProcessWExAt(0, cmdCopy, 0, 0, pInherit, pFlags, 0, me._workingDir, pStartup, pInfo)
         End If
         If created = 0 Then
            me._lastError = GetLastError()
         End If
         LaunchProcessEx = created
      End Function

      Private Function SpawnPty(pCommand As String) As Boolean
         Dim hInRead As Long
         Dim hInWrite As Long
         Dim hOutRead As Long
         Dim hOutWrite As Long
         Dim hPC As Long
         Dim sa As TPipeSecurity
         Dim attrSize As Long
         Dim attrList As Long
         Dim heap As Long
         Dim packedSize As Long
         Dim rowBits As Long
         Dim startup As TProcStartupEx
         Dim procInfo As TProcInfo
         Dim hr As Long
         Dim ok As Long
         SpawnPty = False
         sa.nLength = 12
         sa.descriptor = 0
         sa.inheritHandle = 0
         hInRead = 0
         hInWrite = 0
         hOutRead = 0
         hOutWrite = 0
         hPC = 0
         If CreatePipe(hOutRead, hOutWrite, sa, 0) = 0 Then
            Exit Function
         End If
         If CreatePipe(hInRead, hInWrite, sa, 0) = 0 Then
            CloseHandle(hOutRead)
            CloseHandle(hOutWrite)
            Exit Function
         End If
         rowBits = PTY_ROWS
         rowBits = rowBits * 65536
         packedSize = PTY_COLS + rowBits
         hr = CreatePseudoConsole(packedSize, hInRead, hOutWrite, 0, hPC)
         If (hr <> 0) Or (hPC = 0) Then
            CloseHandle(hInRead)
            CloseHandle(hInWrite)
            CloseHandle(hOutRead)
            CloseHandle(hOutWrite)
            Exit Function
         End If
         CloseHandle(hInRead)
         hInRead = 0
         CloseHandle(hOutWrite)
         hOutWrite = 0
         attrSize = 0
         InitializeProcThreadAttributeList(0, 1, 0, attrSize)
         If attrSize = 0 Then
            ClosePseudoConsole(hPC)
            CloseHandle(hInWrite)
            CloseHandle(hOutRead)
            Exit Function
         End If
         heap = GetProcessHeap()
         attrList = HeapAlloc(heap, HEAP_ZERO_MEMORY, attrSize)
         If attrList = 0 Then
            ClosePseudoConsole(hPC)
            CloseHandle(hInWrite)
            CloseHandle(hOutRead)
            Exit Function
         End If
         If InitializeProcThreadAttributeList(attrList, 1, 0, attrSize) = 0 Then
            HeapFree(heap, 0, attrList)
            ClosePseudoConsole(hPC)
            CloseHandle(hInWrite)
            CloseHandle(hOutRead)
            Exit Function
         End If
         If UpdateProcThreadAttribute(attrList, 0, PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE, hPC, 4, 0, 0) = 0 Then
            DeleteProcThreadAttributeList(attrList)
            HeapFree(heap, 0, attrList)
            ClosePseudoConsole(hPC)
            CloseHandle(hInWrite)
            CloseHandle(hOutRead)
            Exit Function
         End If
         startup.cb = STARTUPINFOEX_BYTES
         startup.reserved1 = 0
         startup.desktop = 0
         startup.titleText = 0
         startup.x = 0
         startup.y = 0
         startup.xSize = 0
         startup.ySize = 0
         startup.xCount = 0
         startup.yCount = 0
         startup.fill = 0
         startup.flags = 0
         startup.showAndRes = 0
         startup.reserved3 = 0
         startup.stdIn = 0
         startup.stdOut = 0
         startup.stdErr = 0
         startup.attrList = attrList
         procInfo.hProc = 0
         procInfo.hThread = 0
         procInfo.processId = 0
         procInfo.threadId = 0
         ok = me.LaunchProcessEx(pCommand, 0, EXTENDED_STARTUPINFO_PRESENT, startup, procInfo)
         DeleteProcThreadAttributeList(attrList)
         HeapFree(heap, 0, attrList)
         If ok = 0 Then
            ClosePseudoConsole(hPC)
            CloseHandle(hInWrite)
            CloseHandle(hOutRead)
            Exit Function
         End If
         If procInfo.hThread <> 0 Then
            CloseHandle(procInfo.hThread)
         End If
         me._hPC = hPC
         me._hStdInWrite = hInWrite
         me._hStdOutRead = hOutRead
         me._hProcess = procInfo.hProc
         me._pid = procInfo.processId
         SpawnPty = (me._hProcess <> 0)
      End Function

      Private Function SpawnConsole(pCommand As String) As Boolean
         Dim startup As TProcStartup
         Dim procInfo As TProcInfo
         Dim created As Long
         SpawnConsole = False
         startup.cb = STARTUPINFO_BYTES
         startup.reserved1 = 0
         startup.desktop = 0
         startup.titleText = 0
         startup.x = 0
         startup.y = 0
         startup.xSize = 0
         startup.ySize = 0
         startup.xCount = 0
         startup.yCount = 0
         startup.fill = 0
         startup.flags = STARTF_USESHOWWINDOW
         startup.showAndRes = me.WindowShowCmd()
         startup.reserved3 = 0
         startup.stdIn = 0
         startup.stdOut = 0
         startup.stdErr = 0
         procInfo.hProc = 0
         procInfo.hThread = 0
         procInfo.processId = 0
         procInfo.threadId = 0
         created = me.LaunchProcess(pCommand, 0, CREATE_NEW_CONSOLE, startup, procInfo)
         If created = 0 Then
            Exit Function
         End If
         If procInfo.hThread <> 0 Then
            CloseHandle(procInfo.hThread)
         End If
         me._hProcess = procInfo.hProc
         me._pid = procInfo.processId
         SpawnConsole = (me._hProcess <> 0)
      End Function

      Private Function SpawnPipes(pCommand As String) As Boolean
         Dim hInRead As Long
         Dim hInWrite As Long
         Dim hOutRead As Long
         Dim hOutWrite As Long
         Dim hErrRead As Long
         Dim hErrWrite As Long
         Dim sa As TPipeSecurity
         Dim startup As TProcStartup
         Dim procInfo As TProcInfo
         Dim created As Long
         SpawnPipes = False
         sa.nLength = 12
         sa.descriptor = 0
         sa.inheritHandle = 1
         hInRead = 0
         hInWrite = 0
         hOutRead = 0
         hOutWrite = 0
         hErrRead = 0
         hErrWrite = 0
         If CreatePipe(hOutRead, hOutWrite, sa, 0) = 0 Then
            Exit Function
         End If
         SetHandleInformation(hOutRead, HANDLE_FLAG_INHERIT, 0)
         If CreatePipe(hInRead, hInWrite, sa, 0) = 0 Then
            CloseHandle(hOutRead)
            CloseHandle(hOutWrite)
            Exit Function
         End If
         SetHandleInformation(hInWrite, HANDLE_FLAG_INHERIT, 0)
         If Not me._mergeStdErr Then
            If CreatePipe(hErrRead, hErrWrite, sa, 0) = 0 Then
               CloseHandle(hInRead)
               CloseHandle(hInWrite)
               CloseHandle(hOutRead)
               CloseHandle(hOutWrite)
               Exit Function
            End If
            SetHandleInformation(hErrRead, HANDLE_FLAG_INHERIT, 0)
         End If
         startup.cb = STARTUPINFO_BYTES
         startup.reserved1 = 0
         startup.desktop = 0
         startup.titleText = 0
         startup.x = 0
         startup.y = 0
         startup.xSize = 0
         startup.ySize = 0
         startup.xCount = 0
         startup.yCount = 0
         startup.fill = 0
         startup.flags = STARTF_USESHOWWINDOW + STARTF_USESTDHANDLES
         startup.showAndRes = me.WindowShowCmd()
         startup.reserved3 = 0
         startup.stdIn = hInRead
         startup.stdOut = hOutWrite
         If me._mergeStdErr Then
            startup.stdErr = hOutWrite
         Else
            startup.stdErr = hErrWrite
         End If
         procInfo.hProc = 0
         procInfo.hThread = 0
         procInfo.processId = 0
         procInfo.threadId = 0
         created = me.LaunchProcess(pCommand, 1, me.PipeCreateFlags(), startup, procInfo)
         CloseHandle(hInRead)
         CloseHandle(hOutWrite)
         If hErrWrite <> 0 Then
            CloseHandle(hErrWrite)
         End If
         If created = 0 Then
            CloseHandle(hInWrite)
            CloseHandle(hOutRead)
            If hErrRead <> 0 Then
               CloseHandle(hErrRead)
            End If
            Exit Function
         End If
         If procInfo.hThread <> 0 Then
            CloseHandle(procInfo.hThread)
         End If
         me._hProcess = procInfo.hProc
         me._hStdInWrite = hInWrite
         me._hStdOutRead = hOutRead
         me._hStdErrRead = hErrRead
         me._pid = procInfo.processId
         SpawnPipes = (me._hProcess <> 0)
      End Function

      Private Function SpawnElevated(pCommand As String) As Boolean
         Dim info As TShellExecInfo
         Dim exeFile As String
         Dim args As String
         Dim verb As String
         SpawnElevated = False
         me.SplitCommand(pCommand, exeFile, args)
         If exeFile = "" Then
            Exit Function
         End If
         verb = "runas"
         info.cbSize = SHELLEXECINFO_BYTES
         info.fMask = SEE_MASK_NOCLOSEPROCESS
         info.hwnd = 0
         info.lpVerb = verb
         info.lpFile = exeFile
         info.lpParameters = args
         info.lpDirectory = me._workingDir
         info.nShow = me.WindowShowCmd()
         info.hInstApp = 0
         info.lpIDList = 0
         info.lpClass = 0
         info.hkeyClass = 0
         info.dwHotKey = 0
         info.hIcon = 0
         info.hProcess = 0
         If ShellExecuteExW(info) = 0 Then
            me._lastError = GetLastError()
            Exit Function
         End If
         me._hProcess = info.hProcess
         If me._hProcess <> 0 Then
            me._pid = GetProcessId(me._hProcess)
         End If
         SpawnElevated = (me._hProcess <> 0)
      End Function

      Private Sub SplitCommand(pCommand As String, ByRef pFile As String, ByRef pArgs As String)
         Dim raw As String
         Dim inner As String
         Dim cutAt As Integer
         raw = Trim(pCommand)
         pFile = ""
         pArgs = ""
         If raw = "" Then
            Exit Sub
         End If
         If Left(raw, 1) = Chr(34) Then
            inner = Mid(raw, 2)
            cutAt = InStr(inner, Chr(34))
            If cutAt > 0 Then
               pFile = Left(inner, cutAt - 1)
               pArgs = Trim(Mid(inner, cutAt + 1))
            Else
               pFile = inner
            End If
            Exit Sub
         End If
         cutAt = InStr(raw, " ")
         If cutAt > 0 Then
            pFile = Left(raw, cutAt - 1)
            pArgs = Trim(Mid(raw, cutAt + 1))
         Else
            pFile = raw
         End If
      End Sub

      Private Function ParentIsElevated() As Boolean
         Dim hToken As Long
         Dim info As TTokenElevation
         Dim retLen As Long
         ParentIsElevated = False
         hToken = 0
         If OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, hToken) = 0 Then
            Exit Function
         End If
         info.TokenIsElevated = 0
         retLen = 0
         If GetTokenInformation(hToken, TokenElevation, info, 4, retLen) <> 0 Then
            ParentIsElevated = (info.TokenIsElevated <> 0)
         End If
         CloseHandle(hToken)
      End Function

      Private Function ParentIsWow64() As Boolean
         Dim wow As Long
         wow = 0
         If IsWow64Process(GetCurrentProcess(), wow) = 0 Then
            ParentIsWow64 = False
            Exit Function
         End If
         ParentIsWow64 = (wow <> 0)
      End Function

      Private Function StillRunning() As Boolean
         Dim code As Long
         code = 0
         If me._hProcess = 0 Then
            StillRunning = False
            Exit Function
         End If
         If GetExitCodeProcess(me._hProcess, code) = 0 Then
            StillRunning = False
            Exit Function
         End If
         If code = STILL_ACTIVE Then
            StillRunning = True
            Exit Function
         End If
         me._exitCode = CInt(code)
         StillRunning = False
      End Function

      Private Function DrainConsole() As String
         Dim info As TConsoleInfo
         Dim hOut As Long
         Dim hwnd As Long
         Dim nRead As Long
         Dim cursorY As Long
         Dim coord As Long
         Dim buf As String
         Dim text As String
         DrainConsole = ""
         If me._pid = 0 Then
            Exit Function
         End If
         FreeConsole()
         If AttachConsole(me._pid) = 0 Then
            Exit Function
         End If
         hwnd = GetConsoleWindow()
         If hwnd <> 0 Then
            If Not me._visible Then
               ShowWindowApi(hwnd, SW_HIDE)
            End If
         End If
         hOut = CreateFileW("CONOUT$", GENERIC_READ_WRITE, FILE_SHARE_RW, 0, OPEN_EXISTING, 0, 0)
         If (hOut = 0) Or (hOut = INVALID_HANDLE_VALUE) Then
            FreeConsole()
            Exit Function
         End If
         info.sizeXY = 0
         info.cursorXY = 0
         info.attributes = 0
         info.winLeft = 0
         info.winTop = 0
         info.winRight = 0
         info.winBottom = 0
         info.maxWinXY = 0
         If GetConsoleScreenBufferInfo(hOut, info) = 0 Then
            CloseHandle(hOut)
            FreeConsole()
            Exit Function
         End If
         cursorY = CInt(info.cursorXY / 65536)
         coord = cursorY * 65536
         buf = Space(CONSOLE_LINE_CHARS)
         nRead = 0
         If ReadConsoleOutputCharacterW(hOut, buf, CONSOLE_LINE_CHARS, coord, nRead) = 0 Then
            CloseHandle(hOut)
            FreeConsole()
            Exit Function
         End If
         CloseHandle(hOut)
         FreeConsole()
         If nRead <= 0 Then
            Exit Function
         End If
         text = Trim(Left(buf, CInt(nRead)))
         If text = "" Then
            Exit Function
         End If
         If text = me._lastConsoleLine Then
            Exit Function
         End If
         me._lastConsoleLine = text
         DrainConsole = text & Chr(13)
      End Function

      Private Function DrainHandle(pHandle As Long) As String
         Dim avail As Long
         Dim toRead As Long
         Dim bytesRead As Long
         Dim peeked As Long
         Dim pipeBuf As AnsiString
         DrainHandle = ""
         If pHandle = 0 Then
            Exit Function
         End If
         avail = 0
         peeked = PeekNamedPipe(pHandle, 0, 0, 0, avail, 0)
         If peeked = 0 Then
            Exit Function
         End If
         If avail <= 0 Then
            Exit Function
         End If
         toRead = avail
         If toRead > PIPE_READ_MAX Then
            toRead = PIPE_READ_MAX
         End If
         pipeBuf = pipeBuf.FromUnicode(Space(CInt(toRead)))
         bytesRead = 0
         If ReadFile(pHandle, pipeBuf, toRead, bytesRead, 0) = 0 Then
            Exit Function
         End If
         If bytesRead <= 0 Then
            Exit Function
         End If
         DrainHandle = pipeBuf.Left(CInt(bytesRead)).ToUnicode()
      End Function

      Private Function WritePipe(pHandle As Long, pText As String) As Boolean
         Dim pipeBuf As AnsiString
         Dim n As Long
         Dim written As Long
         WritePipe = False
         If pHandle = 0 Then
            Exit Function
         End If
         pipeBuf = pipeBuf.FromUnicode(pText)
         n = pipeBuf.Length()
         If n <= 0 Then
            WritePipe = True
            Exit Function
         End If
         written = 0
         If WriteFile(pHandle, pipeBuf, n, written, 0) = 0 Then
            Exit Function
         End If
         WritePipe = (written > 0)
      End Function

      Private Function WriteConsoleIn(pText As String) As Boolean
         Dim hIn As Long
         WriteConsoleIn = False
         If me._pid = 0 Then
            Exit Function
         End If
         FreeConsole()
         If AttachConsole(me._pid) = 0 Then
            Exit Function
         End If
         hIn = CreateFileW("CONIN$", GENERIC_READ_WRITE, FILE_SHARE_RW, 0, OPEN_EXISTING, 0, 0)
         If (hIn = 0) Or (hIn = INVALID_HANDLE_VALUE) Then
            FreeConsole()
            Exit Function
         End If
         WriteConsoleIn = me.WritePipe(hIn, pText)
         CloseHandle(hIn)
         FreeConsole()
      End Function

      Private Function NextBufferedLine(pChunk As String, ByRef pBuf As String) As String
         Dim buf As String
         Dim nPos As Integer
         Dim rPos As Integer
         Dim cutAt As Integer
         Dim skipCount As Integer
         Dim line As String
         If pChunk <> "" Then
            pBuf = pBuf & pChunk
         End If
         buf = pBuf
         If buf = "" Then
            NextBufferedLine = ""
            Exit Function
         End If
         nPos = InStr(buf, Chr(10))
         rPos = InStr(buf, Chr(13))
         cutAt = 0
         skipCount = 0
         If (nPos > 0) And (rPos > 0) Then
            If rPos < nPos Then
               cutAt = rPos
               If nPos = (rPos + 1) Then
                  skipCount = 2
               Else
                  skipCount = 1
               End If
            Else
               cutAt = nPos
               skipCount = 1
            End If
         Else
            If nPos > 0 Then
               cutAt = nPos
               skipCount = 1
            Else
               If rPos > 0 Then
                  cutAt = rPos
                  skipCount = 1
               End If
            End If
         End If
         If cutAt = 0 Then
            If me.IsRunning() Then
               NextBufferedLine = ""
               Exit Function
            End If
            pBuf = ""
            NextBufferedLine = buf
            Exit Function
         End If
         line = Left(buf, cutAt - 1)
         If Right(line, 1) = Chr(13) Then
            line = Left(line, Len(line) - 1)
         End If
         pBuf = Mid(buf, cutAt + skipCount)
         NextBufferedLine = line
      End Function

      Overrides Sub Dispose()
         me.StopProcess(True)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
