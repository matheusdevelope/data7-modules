Imports Collections
Imports mod_win_process
Imports mod_zip_exe

Namespace mod_openssl

   Class OpenSSL
      Inherits TZipPortableExe

      Private _lastOutput As String
      Private _ownedTemps As StringList

      Sub New()
         MyBase.New()
         me.DownloadUrl = "https://github.com/matheusdevelope/openssl/releases/download/main/openssl.zip"
         me.DownloadTimeoutMs = 120000
         me.InstallFolder = "openssl"
         me.ExeFileName = "openssl.exe"
         me.ArchiveName = "OpenSSL.zip"
         me.SearchRecursive = True
         me._ownedTemps = New StringList()
      End Sub

      Property Path As String
         Get
            Path = me.ExePath
         End Get
      End Property

      Property LastOutput As String
         Get
            LastOutput = me._lastOutput
         End Get
      End Property

      Function Version() As String
         Version = Trim(me.Execute("version"))
      End Function

      Function ExportCrt(pPfx As String, pPass As String, pOutput As String = "") As String
         ExportCrt = me.ExportPkcs12(pPfx, pPass, pOutput, "crt", ".crt", "-clcerts -nokeys")
      End Function

      Function ExportKey(pPfx As String, pPass As String, pOutput As String = "") As String
         ExportKey = me.ExportPkcs12(pPfx, pPass, pOutput, "key", ".key", "-nocerts -nodes")
      End Function

      Private Function ExportPkcs12(pPfx As String, pPass As String, pOutput As String, pPrefix As String, pExt As String, pFlags As String) As String
         Dim autoOut As Boolean
         Dim outPath As String
         Dim passFile As String
         Dim args As String
         Dim code As Integer
         If Not TFile.Exists(pPfx) Then
            Throw New Exception("PFX not found: " & pPfx)
         End If
         autoOut = False
         outPath = Trim(pOutput)
         If outPath = "" Then
            outPath = me.GetTempFilePath(pPrefix, pExt)
            autoOut = True
         End If

         passFile = me.WriteSecretFile(pPass)
         args = "pkcs12 -in " & me.ArgQuote(pPfx) & " " & pFlags & " -passin " & me.ArgQuote("file:" & passFile) & " -out " & me.ArgQuote(outPath)
         code = -1
         Try
            code = me.RunOpenSsl(args)
            If code <> 0 Then
               code = me.RunOpenSsl(args & " -legacy")
            End If
         Catch ex As Exception
            me.DeleteQuiet(passFile)
            Throw New Exception(ex._GetMessage())
         End Try
         me.DeleteQuiet(passFile)

         If code <> 0 Then
            Throw New Exception("openssl pkcs12 failed: " & me._lastOutput)
         End If
         If Not TFile.Exists(outPath) Then
            Throw New Exception("openssl pkcs12 did not write: " & outPath)
         End If
         If autoOut Then
            me.TrackTemp(outPath)
         End If
         ExportPkcs12 = outPath
      End Function

      Function Execute(pArgs As String) As String
         Dim code As Integer
         code = me.RunOpenSsl(pArgs)
         If code <> 0 Then
            Throw New Exception("openssl failed (" & CStr(code) & "): " & me._lastOutput)
         End If
         Execute = me._lastOutput
      End Function

      Private Function RunOpenSsl(pArgs As String) As Integer
         Dim job As TWinProcess
         Dim lines As StringList
         Dim code As Integer
         job = New TWinProcess()
         lines = job.CaptureLines(me.BuildCommand(Trim(pArgs)))
         me._lastOutput = lines.Text
         lines.Free()
         code = job.ExitCode()
         job.Free()
         If code < 0 Then
            code = 1
         End If
         RunOpenSsl = code
      End Function

      Private Function GetTempFilePath(pPrefix As String, pExt As String) As String
         Dim createdFile As String
         Dim destFile As String
         Dim destName As String
         Dim folderName As String
         createdFile = TPath.GetTempFileName()
         If createdFile = "" Then
            Throw New Exception("Could not create temp file")
         End If
         folderName = TPath.GetDirectoryName(createdFile)
         destName = pPrefix & TPath.GetFileNameWithoutExtension(createdFile) & pExt
         destFile = TPath.Combine(folderName, destName)
         If destFile <> createdFile Then
            If TFile.Exists(destFile) Then
               TFile.Delete(destFile)
            End If
            TFile.Move(createdFile, destFile)
         End If
         GetTempFilePath = destFile
      End Function

      Private Function WriteSecretFile(pSecret As String) As String
         Dim secretPath As String
         Dim fso As Variant
         Dim ts As Variant
         secretPath = me.GetTempFilePath("ossp", ".tmp")
         fso = CreateObject("Scripting.FileSystemObject")
         ts = fso.CreateTextFile(secretPath, True)
         ts.Write(pSecret)
         ts.Close()
         ts = Unassigned
         fso = Unassigned
         WriteSecretFile = secretPath
      End Function

      Private Function ArgQuote(pValue As String) As String
         ArgQuote = """" & pValue.Replace("""", """""") & """"
      End Function

      Sub TrackTemp(pPath As String)
         If pPath <> "" Then
            me._ownedTemps.Add(pPath)
         End If
      End Sub

      Private Sub DeleteQuiet(pPath As String)
         If pPath = "" Then
            Exit Sub
         End If
         If TFile.Exists(pPath) Then
            Try
               TFile.Delete(pPath)
            Catch
            End Try
         End If
      End Sub

      Private Sub CleanTemps()
         Dim i As Integer
         For i = 0 To me._ownedTemps.Count - 1
            me.DeleteQuiet(me._ownedTemps.Strings(i))
         Next
         me._ownedTemps.Clear()
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("OpenSSL")
            .Prop("Path", me.InstalledExePath())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         me.CleanTemps()
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
