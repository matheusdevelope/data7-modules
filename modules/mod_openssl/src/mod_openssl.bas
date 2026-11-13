Imports Collections
Imports IO
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
         If Not IO.File.Exists(pPfx) Then
            Throw New Exception("PFX not found: " & pPfx)
         End If
         Dim autoOut As Boolean = False
         Dim outPath As String = Trim(pOutput)
         If outPath = "" Then
            outPath = me.GetTempFilePath(pPrefix, pExt)
            autoOut = True
         End If

         Dim passFile As String = me.WriteSecretFile(pPass)
         Dim args As String = "pkcs12 -in " & me.ArgQuote(pPfx) & " " & pFlags & " -passin " & me.ArgQuote("file:" & passFile) & " -out " & me.ArgQuote(outPath)
         Dim code As Integer = -1
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
         If Not IO.File.Exists(outPath) Then
            Throw New Exception("openssl pkcs12 did not write: " & outPath)
         End If
         If autoOut Then
            me.TrackTemp(outPath)
         End If
         ExportPkcs12 = outPath
      End Function

      Function Execute(pArgs As String) As String
         Dim code As Integer = me.RunOpenSsl(pArgs)
         If code <> 0 Then
            Throw New Exception("openssl failed (" & CStr(code) & "): " & me._lastOutput)
         End If
         Execute = me._lastOutput
      End Function

      Private Function RunOpenSsl(pArgs As String) As Integer
         Dim outFile As String = me.GetTempFilePath("ossl", ".txt")
         Dim wsh As Variant = CreateObject("WScript.Shell")
         Dim cmd As String = "cmd /c " & me.BuildCommand(Trim(pArgs)) & " > " & me.QuoteArg(outFile) & " 2>&1"
         Dim result As Integer = wsh.Run(cmd, 0, True)
         wsh = Unassigned
         me._lastOutput = me.ReadTextFile(outFile)
         me.DeleteQuiet(outFile)
         RunOpenSsl = result
      End Function

      Private Function WriteSecretFile(pSecret As String) As String
         Dim secretPath As String = me.GetTempFilePath("ossp", ".tmp")
         Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
         Dim ts As Variant = fso.CreateTextFile(secretPath, True)
         ts.Write(pSecret)
         ts.Close()
         ts = Unassigned
         fso = Unassigned
         WriteSecretFile = secretPath
      End Function

      Private Function ReadTextFile(pPath As String) As String
         If Not IO.File.Exists(pPath) Then
            ReadTextFile = ""
            Exit Function
         End If
         Dim lines As New StringList()
         lines.LoadFromFile(pPath)
         ReadTextFile = lines.Text
         lines.Free()
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
         If IO.File.Exists(pPath) Then
            Try
               IO.File.Delete(pPath)
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
