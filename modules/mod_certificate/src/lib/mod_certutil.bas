Imports Collections
Imports IO
Imports mod_cert_enums
Imports mod_portable_exe

Namespace mod_certutil

      Private Dim _instance As TCertUtil
      Private Dim _certUtilPath As String

   Class TCertUtil
      Inherits TPortableExe

      Shared Function Instance() As TCertUtil
         If Not Assigned(_instance) Then
            _instance = New TCertUtil()
         End If
         Instance = _instance
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub EnsureExe()
         If _certUtilPath <> "" Then
            If IO.File.Exists(_certUtilPath) Then
               me.ExePath = _certUtilPath
               Exit Sub
            End If
         End If
         _certUtilPath = me.ResolveCertUtil()
         me.ExePath = _certUtilPath
      End Sub

      Private Function ResolveCertUtil() As String
         Dim wsh As Variant = CreateObject("WScript.Shell")
         Dim sysRoot As String = wsh.ExpandEnvironmentStrings("%SystemRoot%")
         wsh = Unassigned
         Dim certUtilPath As String = sysRoot & "\System32\certutil.exe"
         If Not IO.File.Exists(certUtilPath) Then
            Throw New Exception("certutil.exe not found: " & certUtilPath)
         End If
         ResolveCertUtil = certUtilPath
      End Function

      Function LocationFlag(pLocation As TCertLocation) As String
         Dim loc As String = UCase(Replace(Trim(pLocation.AsString), "_", ""))
         If (loc = "CURRENTUSER") Or (loc = "USER") Then
            LocationFlag = "-user"
            Exit Function
         End If
         If loc = "ENTERPRISE" Then
            LocationFlag = "-enterprise"
            Exit Function
         End If
         If (loc = "GROUPPOLICY") Or (loc = "GP") Then
            LocationFlag = "-grouppolicy"
            Exit Function
         End If
         If loc = "SERVICE" Then
            LocationFlag = "-service"
            Exit Function
         End If
         LocationFlag = ""
      End Function

      Function Prefix(pLocation As TCertLocation, pArgs As String) As String
         Dim flag As String = me.LocationFlag(pLocation)
         If flag = "" Then
            Prefix = Trim(pArgs)
            Exit Function
         End If
         Prefix = Trim(flag & " " & pArgs)
      End Function

      Function Exec(pArgs As String) As StringList
         Exec = me.ExecReadLines(pArgs)
      End Function

      Function ExecCode(pArgs As String) As Integer
         ExecCode = me.RunWait(pArgs)
      End Function

      Function ExecChecked(pArgs As String, pError As String) As Integer
         Dim result As Integer = me.RunWait(pArgs)
         If result <> 0 Then
            Throw New Exception(pError)
         End If
         ExecChecked = result
      End Function

      Function Help(pVerb As String = "") As StringList
         If Trim(pVerb) = "" Then
            Help = me.Exec("-?")
            Exit Function
         End If
         Dim verb As String = Trim(pVerb)
         If Left(verb, 1) <> "-" Then
            verb = "-" & verb
         End If
         Help = me.Exec(verb & " -?")
      End Function

      Function HashFile(pPath As String, pAlg As String = "SHA1") As String
         If Not IO.File.Exists(pPath) Then
            Throw New Exception("Arquivo nao encontrado: " & pPath)
         End If
         Dim lines As StringList = me.Exec("-hashfile " & pPath.Quoted() & " " & pAlg)
         Dim hash As String = ""
         Dim i As Integer
         For i = 0 To lines.Count - 1
            Dim line As String = Trim(lines.Strings(i))
            If (line <> "") And (InStr(UCase(line), "CERTUTIL") = 0) And (InStr(UCase(line), "HASH") = 0) Then
               hash = me.NormalizeHash(line)
               If hash <> "" Then
                  Exit For
               End If
            End If
         Next
         lines.Free()
         HashFile = hash
      End Function

      Function DumpFile(pPath As String, pPass As String = "") As StringList
         If Not IO.File.Exists(pPath) Then
            Throw New Exception("Arquivo nao encontrado: " & pPath)
         End If
         If Trim(pPass) <> "" Then
            DumpFile = me.Exec("-p " & pPass.Quoted() & " -dump " & pPath.Quoted())
            Exit Function
         End If
         DumpFile = me.Exec("-dump " & pPath.Quoted())
      End Function

      Function Encode(pInFile As String, pOutFile As String) As Integer
         Encode = me.ExecChecked("-encode " & pInFile.Quoted() & " " & pOutFile.Quoted(), "Falha ao codificar arquivo em Base64.")
      End Function

      Function Decode(pInFile As String, pOutFile As String) As Integer
         Decode = me.ExecChecked("-decode " & pInFile.Quoted() & " " & pOutFile.Quoted(), "Falha ao decodificar arquivo Base64.")
      End Function

      Private Function NormalizeHash(pValue As String) As String
         Dim raw As String = UCase(Trim(pValue))
         Dim hex As String = ""
         Dim i As Integer
         For i = 1 To Len(raw)
            Dim ch As String = Mid(raw, i, 1)
            If InStr("0123456789ABCDEF", ch) > 0 Then
               hex = hex & ch
            ElseIf (ch <> " ") And (ch <> ":") And (ch <> "-") Then
               Exit For
            End If
         Next
         NormalizeHash = hex
      End Function

      Function MergePfx(pInFiles As String, pOutFile As String, pPass As String) As Integer
         MergePfx = me.ExecChecked("-f -p " & pPass.Quoted() & " -MergePFX " & pInFiles.Quoted() & " " & pOutFile.Quoted(), "Falha ao mesclar arquivos PFX.")
      End Function

      Overrides Sub Dispose()
         If Assigned(_instance) Then
            If _instance = me Then
               _instance = Null
            End If
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
