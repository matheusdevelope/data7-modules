Imports Collections
Imports mod_tobject
Imports mod_win_process

Namespace mod_win_process_tests

   Class TWinProcessSuite
      Inherits TTObject

      Private _passed As Integer
      Private _failed As Integer

      Sub New()
         MyBase.New()
         me._passed = 0
         me._failed = 0
      End Sub

      Sub Run()
         print("=== TWinProcess ===")
         me.TestDefaults()
         me.TestCaptureEcho()
         me.TestRunExitCode()
         me.TestProcessIdentity()
         me.TestWorkingDir()
         me.TestMissingExe()
         me.TestStopProcess()
         print("====================")
         print("Passou: " & CStr(me._passed) & "  Falhou: " & CStr(me._failed))
         If me._failed = 0 Then
            print("Resultado: OK")
         Else
            print("Resultado: FALHOU")
         End If
      End Sub

      Private Sub Check(pOk As Boolean, pName As String, pDetail As String)
         If pOk Then
            me._passed = me._passed + 1
            print("OK     " & pName & "  " & pDetail)
         Else
            me._failed = me._failed + 1
            print("FALHOU " & pName & "  " & pDetail)
         End If
      End Sub

      Private Sub TestDefaults()
         Dim job As New TWinProcess()
         me.Check(job.UseConsole, "default UseConsole", "")
         me.Check(Not job.Visible, "default Visible", "")
         me.Check(job.MergeStdErr, "default MergeStdErr", "")
         me.Check(job.WorkingDir = "", "default WorkingDir", job.WorkingDir)
         me.Check(Not job.RunAsAdmin, "default RunAsAdmin", "")
         me.Check(job.ProcessId() = 0, "default ProcessId", CStr(job.ProcessId()))
         me.Check(job.CommandLine() = "", "default CommandLine", job.CommandLine())
         me.Check(job.ProcessKind() = "", "default ProcessKind", job.ProcessKind())
         job.Free()
      End Sub

      Private Sub TestCaptureEcho()
         Dim job As New TWinProcess()
         Dim linhas As StringList
         Dim joined As String
         linhas = job.CaptureLines("cmd.exe /c echo hello-win-process")
         joined = linhas.Text
         me.Check(InStr(LCase(joined), "hello-win-process") > 0, "CaptureLines echo", joined)
         me.Check(Not job.IsRunning(), "CaptureLines not running", "")
         me.Check(job.ProcessKind() = "pipes", "CaptureLines ProcessKind", job.ProcessKind())
         me.Check(job.ExitCode() = 0, "CaptureLines ExitCode", CStr(job.ExitCode()))
         linhas.Free()
         job.Free()
      End Sub

      Private Sub TestRunExitCode()
         Dim job As New TWinProcess()
         Dim code As Integer
         code = job.Run("cmd.exe /c exit 7")
         me.Check(code = 7, "Run exit 7", CStr(code))
         me.Check(job.ExitCode() = 7, "ExitCode 7", CStr(job.ExitCode()))
         job.Free()
      End Sub

      Private Sub TestProcessIdentity()
         Dim job As New TWinProcess()
         Dim linhas As StringList
         linhas = job.CaptureLines("cmd.exe /c echo id-check")
         me.Check(job.ProcessId() > 0, "ProcessId after CaptureLines", CStr(job.ProcessId()))
         me.Check(InStr(job.CommandLine(), "id-check") > 0, "CommandLine", job.CommandLine())
         linhas.Free()
         job.Free()
      End Sub

      Private Sub TestWorkingDir()
         Dim job As New TWinProcess()
         Dim linhas As StringList
         Dim joined As String
         job.WorkingDir = "C:\Windows"
         linhas = job.CaptureLines("cmd.exe /c cd")
         joined = LCase(linhas.Text)
         me.Check(InStr(joined, "c:\windows") > 0, "WorkingDir", linhas.Text)
         linhas.Free()
         job.Free()
      End Sub

      Private Sub TestMissingExe()
         Dim job As New TWinProcess()
         Dim started As Boolean
         started = job.Start("no_such_mod_win_process_xyz.exe")
         me.Check(Not started, "Start missing exe", "")
         me.Check(job.LastError() <> 0, "LastError missing exe", CStr(job.LastError()))
         me.Check(job.LastErrorText() <> "", "LastErrorText missing exe", job.LastErrorText())
         job.Free()
      End Sub

      Private Sub TestStopProcess()
         Dim job As New TWinProcess()
         Dim started As Boolean
         job.UseConsole = False
         started = job.Start("cmd.exe /c ping 127.0.0.1 -n 30")
         me.Check(started, "Start ping", job.LastErrorText())
         If started Then
            me.Check(job.IsRunning(), "IsRunning ping", "")
            me.Check(job.ProcessId() > 0, "ProcessId ping", CStr(job.ProcessId()))
            job.StopProcess(True)
            me.Check(Not job.IsRunning(), "StopProcess", CStr(job.ExitCode()))
         End If
         job.Free()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
