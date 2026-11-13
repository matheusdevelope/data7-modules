Imports Collections
Imports IO
Imports mod_tobject

' Ex local / base64:
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
' Derivadas: TRemotePortableExe (mod_remote_exe), TZipPortableExe (mod_zip_exe).

Namespace mod_portable_exe

   Class TPortableExe
      Inherits TTObject

      Private _exeBase64 As String
      Private _exeFileName As String
      Private _installFolder As String
      Private _exePath As String
      Private _process As Variant
      Private _shell As Variant

      Sub New()
         MyBase.New()
         me._exeBase64 = ""
         me._exeFileName = ""
         me._installFolder = ""
         me._exePath = ""
      End Sub

      Property ExeBase64 As String
         Get
            ExeBase64 = me._exeBase64
         End Get
         Set(pValue As String)
            me._exeBase64 = pValue
            me._exePath = ""
         End Set
      End Property

      Property ExeFileName As String
         Get
            ExeFileName = me._exeFileName
         End Get
         Set(pValue As String)
            me._exeFileName = pValue
            me._exePath = ""
         End Set
      End Property

      Property InstallFolder As String
         Get
            InstallFolder = me._installFolder
         End Get
         Set(pValue As String)
            me._installFolder = pValue
            me._exePath = ""
         End Set
      End Property

      Property ExePath As String
         Get
            me.EnsureExe()
            ExePath = me._exePath
         End Get
         Set(pValue As String)
            me._exePath = pValue
         End Set
      End Property

      Function IsRunning() As Boolean
         If IsEmpty(me._process) Then
            IsRunning = False
            Exit Function
         End If
         IsRunning = (me._process.Status = 0)
      End Function

      Function AppDir() As String
         AppDir = IO.File.ExtractDir(Data7.NomeArquivoExecutavel())
      End Function

      Function InstalledExePath() As String
         Dim folder As String = me.AppDir()
         Dim fileName As String = me._exeFileName
         If me._installFolder <> "" Then
            folder = folder & "\" & me._installFolder
         End If
         If fileName = "" Then
            fileName = "portable.exe"
         End If
         InstalledExePath = folder & "\" & fileName
      End Function

      Overridable Sub EnsureExe()
         Dim target As String = me.InstalledExePath()
         If IO.File.Exists(target) Then
            me._exePath = target
            Exit Sub
         End If

         me.EnsureDirectory(IO.File.ExtractDir(target))
         If me._exeBase64 <> "" Then
            Base64ToFile(me._exeBase64, target)
         End If
         me._exePath = target
      End Sub

      Protected Sub EnsureDirectory(pFolder As String)
         If pFolder = "" Then
            Exit Sub
         End If
         If Not TDirectory.Exists(pFolder) Then
            TDirectory.CreateDirectory(pFolder)
         End If
      End Sub

      Function GetTempFolder() As String
         Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
         GetTempFolder = fso.GetSpecialFolder(2)
         fso = Unassigned
      End Function

      Function GetTempFilePath(pPrefix As String = "", pExtension As String = "") As String
         Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
         Dim tempFolder As String = fso.GetSpecialFolder(2)
         Dim tempName As String = fso.GetTempName
         fso = Unassigned
         GetTempFilePath = tempFolder & "\" & pPrefix & tempName & pExtension
      End Function

      Function QuoteArg(pValue As String) As String
         QuoteArg = """" & pValue & """"
      End Function

      Function BuildCommand(pArgs As String = "") As String
         Dim cmd As String = me.QuoteArg(me.ExePath)
         If Trim(pArgs) <> "" Then
            cmd = cmd & " " & pArgs
         End If
         BuildCommand = cmd
      End Function

      Function RunWait(pArgs As String = "") As Integer
         me.EnsureExe()
         If IsEmpty(me._shell) Then
            me._shell = CreateObject("WScript.Shell")
         End If
         RunWait = me._shell.Run(me.BuildCommand(pArgs), 0, True)
      End Function

      Function StartProcess(pArgs As String = "") As Boolean
         me.EnsureExe()
         If IsEmpty(me._shell) Then
            me._shell = CreateObject("WScript.Shell")
         End If
         me._process = me._shell.Exec(me.BuildCommand(pArgs))
         StartProcess = me.IsRunning()
      End Function

      Function ExecReadLines(pArgs As String = "") As StringList
         Dim list As New StringList()
         me.EnsureExe()
         Dim outFile As String = me.GetTempFilePath("exeout_", ".txt")
         Dim inner As String = me.BuildCommand(pArgs) & " > " & me.QuoteArg(outFile) & " 2>&1"
         If IsEmpty(me._shell) Then
            me._shell = CreateObject("WScript.Shell")
         End If
         me._shell.Run("cmd.exe /s /c " & Chr(34) & inner & Chr(34), 0, True)
         If IO.File.Exists(outFile) Then
            Dim raw As New StringList()
            raw.LoadFromFile(outFile)
            Dim i As Integer
            For i = 0 To raw.Count - 1
               Dim line As String = raw.Strings(i)
               If Trim(line) <> "" Then
                  list.Add(line)
               End If
            Next
            raw.Free()
            Try
               IO.File.Delete(outFile)
            Catch
            End Try
         End If
         ExecReadLines = list
      End Function

      Function WriteLine(pCommand As String) As Boolean
         If Not me.IsRunning() Then
            WriteLine = False
            Exit Function
         End If
         me._process.StdIn.WriteLine(pCommand)
         WriteLine = True
      End Function

      Function ReadLine() As String
         If Not me.IsRunning() Then
            ReadLine = ""
            Exit Function
         End If
         If me._process.StdOut.AtEndOfStream Then
            ReadLine = ""
            Exit Function
         End If
         ReadLine = me._process.StdOut.ReadLine
      End Function

      Function WaitForOutput(pSuccessToken As String, pErrorToken As String = "") As String
         If Not me.IsRunning() Then
            WaitForOutput = ""
            Exit Function
         End If
         While Not me._process.StdOut.AtEndOfStream
            Dim line As String = me._process.StdOut.ReadLine
            If pSuccessToken <> "" Then
               If InStr(line, pSuccessToken) > 0 Then
                  WaitForOutput = line
                  Exit Function
               End If
            End If
            If pErrorToken <> "" Then
               If InStr(line, pErrorToken) > 0 Then
                  WaitForOutput = line
                  Exit Function
               End If
            End If
         End While
         WaitForOutput = ""
      End Function

      Sub StopProcess(pExitCommand As String = "exit")
         If Not IsEmpty(me._process) Then
            Try
               If pExitCommand <> "" Then
                  me._process.StdIn.WriteLine(pExitCommand)
               End If
            Catch
            End Try
            me._process = Unassigned
         End If
      End Sub

      Overrides Sub Dispose()
         me.StopProcess()
         me._shell = Unassigned
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
