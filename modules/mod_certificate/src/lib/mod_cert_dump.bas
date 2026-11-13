Imports Collections
Imports mod_tobject

Namespace mod_cert_dump

   Class TCertDump
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Shared Function IsCertHeader(pLine As String) As Boolean
         IsCertHeader = (InStr(pLine, "================ Certificado ") > 0) Or (InStr(pLine, "================ Certificate ") > 0)
      End Function

      Shared Function IsMissingPrivateKeyLine(pLine As String) As Boolean
         Dim line As String = UCase(pLine)
         If (InStr(line, "CHAVE PRIVADA") > 0) And (InStr(line, "DECOD") > 0) Then
            IsMissingPrivateKeyLine = True
            Exit Function
         End If
         If (InStr(line, "PRIVATE KEY") > 0) And ((InStr(line, "DECRYPT") > 0) Or (InStr(line, "CANNOT FIND") > 0)) Then
            IsMissingPrivateKeyLine = True
            Exit Function
         End If
         IsMissingPrivateKeyLine = False
      End Function

      Shared Function IsDumpFieldLine(pLine As String) As Boolean
         Dim sep As Integer = InStr(pLine, ":")
         If sep <= 0 Then
            IsDumpFieldLine = False
            Exit Function
         End If
         Dim fieldName As String = Trim(Left(pLine, sep - 1))
         If (fieldName = "") Or (InStr(fieldName, "=") > 0) Or (InStr(fieldName, ",") > 0) Then
            IsDumpFieldLine = False
            Exit Function
         End If
         IsDumpFieldLine = (Len(fieldName) < 40)
      End Function

      Shared Function DumpField(pLines As StringList, pKey As String) As String
         Dim needle As String = UCase(Trim(pKey))
         Dim i As Integer
         For i = 0 To pLines.Count - 1
            Dim line As String = pLines.Strings(i)
            Dim sep As Integer = InStr(line, ":")
            If sep > 0 Then
               Dim fieldName As String = UCase(Trim(Left(line, sep - 1)))
               If fieldName = needle Then
                  Dim value As String = Trim(Mid(line, sep + 1))
                  Dim j As Integer
                  For j = i + 1 To pLines.Count - 1
                     Dim nextLine As String = pLines.Strings(j)
                     If TCertDump.IsCertHeader(nextLine) Then
                        Exit For
                     End If
                     If TCertDump.IsDumpFieldLine(nextLine) Then
                        Exit For
                     End If
                     If InStr(nextLine, "=") = 0 Then
                        Exit For
                     End If
                     value = Trim(value & " " & Trim(nextLine))
                  Next
                  DumpField = value
                  Exit Function
               End If
            End If
         Next
         DumpField = ""
      End Function

      Shared Function FirstDumpField(pLines As StringList, pKey1 As String, pKey2 As String = "") As String
         Dim found As String = TCertDump.DumpField(pLines, pKey1)
         If found <> "" Then
            FirstDumpField = found
            Exit Function
         End If
         If pKey2 <> "" Then
            FirstDumpField = TCertDump.DumpField(pLines, pKey2)
            Exit Function
         End If
         FirstDumpField = ""
      End Function

      Shared Function BlockContains(pLines As StringList, pText As String) As Boolean
         Dim needle As String = UCase(pText)
         Dim i As Integer
         For i = 0 To pLines.Count - 1
            If InStr(UCase(pLines.Strings(i)), needle) > 0 Then
               BlockContains = True
               Exit Function
            End If
         Next
         BlockContains = False
      End Function

      Shared Function BlockMissingPrivateKey(pLines As StringList) As Boolean
         Dim i As Integer
         For i = 0 To pLines.Count - 1
            If TCertDump.IsMissingPrivateKeyLine(pLines.Strings(i)) Then
               BlockMissingPrivateKey = True
               Exit Function
            End If
         Next
         BlockMissingPrivateKey = False
      End Function

      Shared Function ExtractCN(pSubject As String) As String
         Dim subject As String = Trim(pSubject)
         Dim pos As Integer = InStr(UCase(subject), "CN=")
         If pos > 0 Then
            Dim rest As String = Mid(subject, pos + 3)
            Dim comma As Integer = InStr(rest, ",")
            If comma > 0 Then
               ExtractCN = Trim(Left(rest, comma - 1))
            Else
               ExtractCN = Trim(rest)
            End If
            Exit Function
         End If
         ExtractCN = subject
      End Function

      Shared Function ParseDumpDate(pValue As String) As TDateTime
         Dim raw As String = Trim(pValue)
         Dim parsed As TDateTime = 0
         Dim ok As Boolean = False
         If raw = "" Then
            ParseDumpDate = 0
            Exit Function
         End If
         Try
            parsed = StrToDateTime(raw & ":00")
            ok = True
         Catch
         End Try
         If Not ok Then
            Try
               parsed = StrToDateTime(raw)
            Catch
               parsed = 0
            End Try
         End If
         ParseDumpDate = parsed
      End Function

      Shared Function NormalizeHash(pValue As String) As String
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

      Shared Function ExtractLeafCert(pLines As StringList) As StringList
         Dim lastHeader As Integer = -1
         Dim leafHeader As Integer = -1
         Dim currentHeader As Integer = -1
         Dim currentHasKey As Boolean = True
         Dim i As Integer
         For i = 0 To pLines.Count - 1
            If TCertDump.IsCertHeader(pLines.Strings(i)) Then
               If currentHeader >= 0 Then
                  lastHeader = currentHeader
                  If currentHasKey Then
                     leafHeader = currentHeader
                  End If
               End If
               currentHeader = i
               currentHasKey = True
            ElseIf TCertDump.IsMissingPrivateKeyLine(pLines.Strings(i)) Then
               currentHasKey = False
            End If
         Next
         If currentHeader >= 0 Then
            lastHeader = currentHeader
            If currentHasKey Then
               leafHeader = currentHeader
            End If
         End If

         Dim startIdx As Integer = leafHeader
         If startIdx < 0 Then
            startIdx = lastHeader
         End If

         Dim leaf As New StringList()
         If startIdx < 0 Then
            leaf.Text = pLines.Text
            ExtractLeafCert = leaf
            Exit Function
         End If
         For i = startIdx + 1 To pLines.Count - 1
            If TCertDump.IsCertHeader(pLines.Strings(i)) Then
               Exit For
            End If
            leaf.Add(pLines.Strings(i))
         Next
         ExtractLeafCert = leaf
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
