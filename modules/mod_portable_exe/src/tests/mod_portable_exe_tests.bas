Imports Collections
Imports IO
Imports mod_portable_exe
Imports mod_remote_exe
Imports mod_tobject
Imports mod_zip_exe

Namespace mod_portable_exe_tests

   Class TPortableTestExe
      Inherits TPortableExe

      Sub New()
         MyBase.New()
         me.ExeBase64 = "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YCMAAGsjAAAIKAAAIQACAABUCABgIwAAayMAAAgoAAABAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/////wEAAAABAAAAAgAAAAAACAAAAAAAAAAAAgAAAAD//////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADKi3y2ZKwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADNXSDSZtT//wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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ZVcAAEtFUk5FTDMyLmRsbAAACABfX0Nfc3BlY2lmaWNfaGFuZGxlcgAAGwBfX2N1cnJlbnRfZXhjZXB0aW9uABwAX19jdXJyZW50X2V4Y2VwdGlvbl9jb250ZXh0AFZDUlVOVElNRTE0MC5kbGwAAIYAc3RyY21wAACJAHN0cmNweV9zAACOAHN0cm5jbXAAiwBzdHJsZW4AAA0AX19zdGRpb19jb21tb25fdnNwcmludGYAQABfc2VoX2ZpbHRlcl9leGUAQgBfc2V0X2FwcF90eXBlAAkAX19zZXR1c2VybWF0aGVycgAAGABfY29uZmlndXJlX25hcnJvd19hcmd2AAAzAF9pbml0aWFsaXplX25hcnJvd19lbnZpcm9ubWVudAAAKABfZ2V0X2luaXRpYWxfbmFycm93X2Vudmlyb25tZW50ADYAX2luaXR0ZXJtADcAX2luaXR0ZXJtX2UAVQBleGl0AAAjAF9leGl0AFQAX3NldF9mbW9kZQAABABfX3BfX19hcmdjAAAFAF9fcF9fX2FyZ3YAABYAX2NleGl0AAAVAF9jX2V4aXQAPQBfcmVnaXN0ZXJfdGhyZWFkX2xvY2FsX2V4ZV9hdGV4aXRfY2FsbGJhY2sAAAgAX2NvbmZpZ3RocmVhZGxvY2FsZQAWAF9zZXRfbmV3X21vZGUAAQBfX3BfX2NvbW1vZGUAADQAX2luaXRpYWxpemVfb25leGl0X3RhYmxlAAA8AF9yZWdpc3Rlcl9vbmV4aXRfZnVuY3Rpb24AHgBfY3J0X2F0ZXhpdABnAHRlcm1pbmF0ZQBhcGktbXMtd2luLWNydC1zdHJpbmctbDEtMS0wLmRsbAAAYXBpLW1zLXdpbi1jcnQtc3RkaW8tbDEtMS0wLmRsbABhcGktbXMtd2luLWNydC1ydW50aW1lLWwxLTEtMC5kbGwAYXBpLW1zLXdpbi1jcnQtbWF0aC1sMS0xLTAuZGxsAABhcGktbXMtd2luLWNydC1sb2NhbGUtbDEtMS0wLmRsbAAAYXBpLW1zLXdpbi1jcnQtaGVhcC1sMS0xLTAuZGxsAAA+AG1lbXNldAAAPABtZW1jcHkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAACAAAAAIoCCgKKC4otCi2KJgo3ijgKOIo5CjmKMAQAAAFAAAAACiCKIQohiiIKIwogAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
         me.ExeFileName = "portable_test.exe"
         me.InstallFolder = "_pex_local"
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TRemoteTestExe
      Inherits TRemotePortableExe

      Sub New()
         MyBase.New()
         me.ExeFileName = "portable_test.exe"
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TZipTestExe
      Inherits TZipPortableExe

      Sub New()
         MyBase.New()
         me.ExeFileName = "portable_test.exe"
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TPortableExeSuite
      Inherits TTObject

      Private _passed As Integer
      Private _failed As Integer
      Private _sourceExe As String
      Private _sourceZip As String
      Private _keepZip As String
      Private _hasLocal As Boolean
      Private _local As TPortableTestExe

      Sub New()
         MyBase.New()
         me._passed = 0
         me._failed = 0
         me._sourceExe = ""
         me._sourceZip = ""
         me._keepZip = ""
         me._hasLocal = False
      End Sub

      Sub Run()
         print("=== TPortableExe ===")
         me.TestLocalMigrate()
         me.TestLocalQuoteArg()
         me.TestLocalRunWait()
         me.TestLocalList()
         me.TestLocalIpc()
         me.TestLocalIsRunningStopped()
         me.PrepareZipArtifact()

         print("=== TRemotePortableExe ===")
         me.TestRemotePaths()
         me.TestRemoteMissingUrl()
         me.TestRemoteAlreadyInstalled()

         print("=== TZipPortableExe ===")
         me.TestZipMissingSource()
         me.TestZipPath()
         me.TestZipBase64()
         me.TestZipKeepArchive()
         me.TestZipAlreadyInstalled()
         me.TestZipDownloadUrl()

         me.CleanupInstallFolders()

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

      Private Sub CheckIpc(pExe As TPortableExe, pName As String)
         If Not pExe.StartProcess() Then
            me.Check(False, pName, "StartProcess")
            Exit Sub
         End If
         Dim ready As String = pExe.WaitForOutput("ready")
         pExe.WriteLine("ping")
         Dim pong As String = pExe.WaitForOutput("pong")
         pExe.WriteLine("echo hello-test")
         Dim echoLine As String = pExe.WaitForOutput("echo:")
         pExe.StopProcess()
         Dim ok As Boolean = (InStr(ready, "ready") > 0) And (InStr(pong, "pong") > 0) And (InStr(echoLine, "hello-test") > 0)
         me.Check(ok, pName, ready & " | " & pong & " | " & echoLine)
      End Sub

      Private Sub DeleteFolder(pFolder As String)
         Try
            If TDirectory.Exists(pFolder) Then
               TDirectory.Delete(pFolder, True)
            End If
         Catch
         End Try
      End Sub

      Private Sub ReleaseLocal()
         If me._hasLocal Then
            me._local.Free()
            me._hasLocal = False
         End If
      End Sub

      Private Sub TestLocalMigrate()
         me._local = New TPortableTestExe()
         me._hasLocal = True
         me._local.EnsureExe()
         me._sourceExe = me._local.ExePath
         me.Check(IO.File.Exists(me._sourceExe), "local migracao", me._sourceExe)
         me.Check(LCase(me._sourceExe) = LCase(me._local.InstalledExePath()), "local pasta do programa", me._sourceExe)
      End Sub

      Private Sub TestLocalQuoteArg()
         Dim quoted As String = me._local.QuoteArg("ab")
         me.Check(quoted = """ab""", "local QuoteArg", quoted)
         Dim cmd As String = me._local.BuildCommand("-list")
         me.Check(InStr(cmd, "-list") > 0, "local BuildCommand", cmd)
      End Sub

      Private Sub TestLocalRunWait()
         Dim code As Integer = me._local.RunWait("-list")
         me.Check(code = 0, "local RunWait -list", CStr(code))
      End Sub

      Private Sub TestLocalList()
         Dim linhas As StringList = me._local.ExecReadLines("-list")
         me.Check(linhas.Count = 2, "local ExecReadLines -list", linhas.Text)
         linhas.Free()
      End Sub

      Private Sub TestLocalIpc()
         me.CheckIpc(me._local, "local IPC")
      End Sub

      Private Sub TestLocalIsRunningStopped()
         me.Check(Not me._local.IsRunning(), "local IsRunning parado", "")
      End Sub

      Private Sub PrepareZipArtifact()
         If me._sourceExe = "" Then
            me.Check(False, "zip artifact", "exe origem ausente")
            Exit Sub
         End If
         me._sourceZip = me._local.GetTempFilePath("pex_test_", ".zip")
         If IO.File.Exists(me._sourceZip) Then
            IO.File.Delete(me._sourceZip)
         End If
         With New IO.File.ZipFile()
            .Zip(me._sourceExe, me._sourceZip)
            .Free()
         End With
         me.Check(IO.File.Exists(me._sourceZip), "zip artifact", me._sourceZip)
      End Sub

      Private Sub TestRemotePaths()
         Dim remote As New TRemoteTestExe()
         remote.InstallFolder = "_pex_remote_ok"
         remote.DownloadTimeoutMs = 1234
         Dim expected As String = remote.AppDir() & "\_pex_remote_ok\portable_test.exe"
         me.Check(LCase(remote.InstalledExePath()) = LCase(expected), "remote InstalledExePath", remote.InstalledExePath())
         me.Check(remote.DownloadTimeoutMs = 1234, "remote DownloadTimeoutMs", CStr(remote.DownloadTimeoutMs))
         remote.Free()
      End Sub

      Private Sub TestRemoteMissingUrl()
         Dim remote As New TRemoteTestExe()
         remote.InstallFolder = "_pex_remote_miss"
         Try
            remote.EnsureExe()
            me.Check(False, "remote sem DownloadUrl", "deveria lancar")
         Catch
            me.Check(True, "remote sem DownloadUrl", "excecao ok")
         End Try
         remote.Free()
      End Sub

      Private Sub TestRemoteAlreadyInstalled()
         Dim remote As New TRemoteTestExe()
         remote.InstallFolder = "_pex_remote_ok"
         Dim target As String = remote.InstalledExePath()
         Dim folder As String = IO.File.ExtractDir(target)
         If Not TDirectory.Exists(folder) Then
            TDirectory.CreateDirectory(folder)
         End If
         TFile.Copy(me._sourceExe, target, True)
         remote.EnsureExe()
         me.Check((IO.File.Exists(remote.ExePath) And (LCase(remote.ExePath) = LCase(target))), "remote ja instalado", remote.ExePath)
         me.CheckIpc(remote, "remote IPC")
         remote.Free()
      End Sub

      Private Sub TestZipMissingSource()
         Dim zip As New TZipTestExe()
         zip.InstallFolder = "_pex_zip_miss"
         Try
            zip.EnsureExe()
            me.Check(False, "zip sem origem", "deveria lancar")
         Catch
            me.Check(True, "zip sem origem", "excecao ok")
         End Try
         zip.Free()
      End Sub

      Private Sub TestZipPath()
         Dim zip As New TZipTestExe()
         zip.InstallFolder = "_pex_zip_path"
         zip.ZipPath = me._sourceZip
         zip.DeleteArchive = True
         zip.EnsureExe()
         Dim okExe As Boolean = IO.File.Exists(zip.ExePath)
         Dim zipKept As Boolean = IO.File.Exists(me._sourceZip)
         me.Check(okExe, "zip ZipPath extraido", zip.ExePath)
         me.Check(zipKept, "zip ZipPath preservado", me._sourceZip)
         me.CheckIpc(zip, "zip ZipPath IPC")
         zip.Free()
      End Sub

      Private Sub TestZipBase64()
         Dim payload As String = FileToBase64(me._sourceZip)
         Dim zip As New TZipTestExe()
         zip.InstallFolder = "_pex_zip_b64"
         zip.ZipBase64 = payload
         zip.EnsureExe()
         Dim generatedZip As String = zip.AppDir() & "\_pex_zip_b64.zip"
         me.Check(IO.File.Exists(zip.ExePath), "zip ZipBase64 extraido", zip.ExePath)
         me.Check(Not IO.File.Exists(generatedZip), "zip ZipBase64 remove arquivo gerado", generatedZip)
         me.CheckIpc(zip, "zip ZipBase64 IPC")
         zip.Free()
      End Sub

      Private Sub TestZipKeepArchive()
         Dim payload As String = FileToBase64(me._sourceZip)
         Dim zip As New TZipTestExe()
         zip.InstallFolder = "_pex_zip_keep"
         zip.ArchiveName = "_pex_keep.zip"
         zip.ZipBase64 = payload
         zip.DeleteArchive = False
         zip.EnsureExe()
         me._keepZip = zip.AppDir() & "\_pex_keep.zip"
         me.Check(IO.File.Exists(zip.ExePath), "zip DeleteArchive=False extraido", zip.ExePath)
         me.Check(IO.File.Exists(me._keepZip), "zip DeleteArchive=False preserva zip", me._keepZip)
         zip.Free()
      End Sub

      Private Sub TestZipAlreadyInstalled()
         Dim zip As New TZipTestExe()
         zip.InstallFolder = "_pex_zip_path"
         zip.EnsureExe()
         me.Check(IO.File.Exists(zip.ExePath), "zip ja extraido", zip.ExePath)
         zip.Free()
      End Sub

      Private Sub TestZipDownloadUrl()
         Dim zip As New TZipTestExe()
         zip.ExeFileName = "curl.exe"
         zip.InstallFolder = "_pex_zip_http"
         zip.DownloadUrl = "https://curl.se/windows/latest.cgi?p=win64-mingw.zip"
         zip.DownloadTimeoutMs = 120000
         Try
            zip.EnsureExe()
            Dim generatedZip As String = zip.AppDir() & "\_pex_zip_http.zip"
            Dim nameOk As Boolean = (LCase(IO.File.ExtractName(zip.ExePath)) = "curl.exe")
            me.Check(IO.File.Exists(zip.ExePath) And nameOk, "zip DownloadUrl extraido", zip.ExePath)
            me.Check(Not IO.File.Exists(generatedZip), "zip DownloadUrl remove arquivo gerado", generatedZip)
         Catch ex As Exception
            me.Check(False, "zip DownloadUrl", ex.Message)
         End Try
         zip.Free()
      End Sub

      Private Sub CleanupInstallFolders()
         Dim appDir As String = IO.File.ExtractDir(Data7.NomeArquivoExecutavel())
         me.DeleteFolder(appDir & "\_pex_local")
         me.DeleteFolder(appDir & "\_pex_remote_miss")
         me.DeleteFolder(appDir & "\_pex_remote_ok")
         me.DeleteFolder(appDir & "\_pex_zip_miss")
         me.DeleteFolder(appDir & "\_pex_zip_path")
         me.DeleteFolder(appDir & "\_pex_zip_b64")
         me.DeleteFolder(appDir & "\_pex_zip_keep")
         me.DeleteFolder(appDir & "\_pex_zip_http")
         If me._sourceZip <> "" Then
            If IO.File.Exists(me._sourceZip) Then
               IO.File.Delete(me._sourceZip)
            End If
         End If
         If me._keepZip <> "" Then
            If IO.File.Exists(me._keepZip) Then
               IO.File.Delete(me._keepZip)
            End If
         End If
         me.ReleaseLocal()
      End Sub

      Overrides Sub Dispose()
         me.ReleaseLocal()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace