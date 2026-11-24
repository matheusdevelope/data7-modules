Imports mod_win_process

' Local / base64 payload on top of TWinProcess:
' Imports mod_portable_exe
'
' Class TMeuRecurso
'    Inherits TPortableExe
'
'    Sub New()
'       MyBase.New()
'       me.ExeBase64 = "TVqQ..."
'       me.ExeFileName = "meu_recurso.exe"
'       me.InstallFolder = "meu_recurso"
'    End Sub
' End Class
'
' Payload subclasses: TRemotePortableExe (HTTP), TZipPortableExe (zip).

Namespace mod_portable_exe

   Private Declare Function SearchPathW Lib "kernel32.dll" (ByVal pDir As Long, ByVal pFile As String, ByVal pExt As String, ByVal pBufLen As Long, ByVal pBuf As String, ByVal pFilePart As Long) As Long

   Class TPortableExe
      Inherits TWinProcess

      Private _exeBase64 As String
      Private _exeFileName As String
      Private _installFolder As String
      Private _exePath As String
      Private _pathPinned As Boolean

      Sub New()
         MyBase.New()
         me._exeBase64 = ""
         me._exeFileName = ""
         me._installFolder = ""
         me._exePath = ""
         me._pathPinned = False
      End Sub

      Property ExeBase64 As String
         Get
            ExeBase64 = me._exeBase64
         End Get
         Set(pValue As String)
            me._exeBase64 = pValue
            me._exePath = ""
            me._pathPinned = False
         End Set
      End Property

      Property ExeFileName As String
         Get
            ExeFileName = me._exeFileName
         End Get
         Set(pValue As String)
            me._exeFileName = pValue
            me._exePath = ""
            me._pathPinned = False
         End Set
      End Property

      Property InstallFolder As String
         Get
            InstallFolder = me._installFolder
         End Get
         Set(pValue As String)
            me._installFolder = pValue
            me._exePath = ""
            me._pathPinned = False
         End Set
      End Property

      Property ExePath As String
         Get
            me.EnsureExe()
            ExePath = me._exePath
         End Get
         Set(pValue As String)
            me._exePath = pValue
            me._pathPinned = (Trim(pValue) <> "")
         End Set
      End Property

      Function AppDir() As String
         AppDir = TPath.GetDirectoryName(Data7.NomeArquivoExecutavel())
      End Function

      Function InstalledExePath() As String
         Dim folder As String
         Dim fileName As String
         folder = me.AppDir()
         fileName = me._exeFileName
         If me._installFolder <> "" Then
            folder = TPath.Combine(folder, me._installFolder)
         End If
         If fileName = "" Then
            fileName = "portable.exe"
         End If
         InstalledExePath = TPath.Combine(folder, fileName)
      End Function

      Sub UsePath(pPath As String)
         Dim raw As String
         Dim buf As String
         Dim n As Long
         raw = Trim(pPath)
         If raw = "" Then
            me.ExePath = ""
            Exit Sub
         End If
         If TFile.Exists(raw) Then
            me.ExePath = raw
            Exit Sub
         End If
         buf = Space(520)
         n = SearchPathW(0, raw, ".exe", 520, buf, 0)
         If n > 0 Then
            me.ExePath = Left(buf, CInt(n))
            Exit Sub
         End If
         me.ExePath = raw
      End Sub

      Protected Function TryReuseExe() As Boolean
         Dim target As String
         If me._pathPinned Then
            TryReuseExe = True
            Exit Function
         End If
         target = me.InstalledExePath()
         If TFile.Exists(target) Then
            me.CacheExePath(target)
            TryReuseExe = True
            Exit Function
         End If
         TryReuseExe = False
      End Function

      Protected Sub CacheExePath(pPath As String)
         me._exePath = pPath
      End Sub

      Overridable Sub EnsureExe()
         Dim target As String
         If me.TryReuseExe() Then
            Exit Sub
         End If
         target = me.InstalledExePath()
         me.EnsureDirectory(TPath.GetDirectoryName(target))
         If me._exeBase64 <> "" Then
            Base64ToFile(me._exeBase64, target)
         End If
         me.CacheExePath(target)
      End Sub

      Protected Sub EnsureDirectory(pFolder As String)
         If pFolder = "" Then
            Exit Sub
         End If
         If Not TDirectory.Exists(pFolder) Then
            TDirectory.CreateDirectory(pFolder)
         End If
      End Sub

      Function BuildCommand(pArgs As String = "") As String
         Dim exeFile As String
         Dim cmd As String
         exeFile = me.ExePath
         cmd = exeFile.Quoted()
         If Trim(pArgs) <> "" Then
            cmd = cmd & " " & pArgs
         End If
         BuildCommand = cmd
      End Function

      Overrides Function Start(pCommand As String = "") As Boolean
         Start = MyBase.Start(me.BuildCommand(pCommand))
      End Function

      Overrides Sub Dispose()
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
