Imports Collections
Imports mod_cert_dump
Imports mod_cert_enums
Imports mod_certificate
Imports mod_tlist

Namespace mod_certificates

   Class TCertificates
      Inherits TTList<TCertificate>

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromDump(pLines As StringList, pLocation As TCertLocation, pStore As TCertStoreName) As TCertificates
         Dim certs As New TCertificates()
         Dim starts As New StringList()
         Dim i As Integer
         For i = 0 To pLines.Count - 1
            If TCertDump.IsCertHeader(pLines.Strings(i)) Then
               starts.Add(CStr(i))
            End If
         Next
         If starts.Count = 0 Then
            If TCertDump.FirstDumpField(pLines, "Requerente", "Subject") <> "" Or TCertDump.FirstDumpField(pLines, "Hash Cert(sha1)", "Cert Hash(sha1)") <> "" Then
               Dim singleCert As New TCertificate()
               singleCert.Location = pLocation
               singleCert.Store = pStore
               singleCert.CleanOnFree = False
               singleCert.ApplyDump(pLines)
               singleCert.MarkInstalled()
               certs.Push(singleCert)
            End If
            starts.Free()
            FromDump = certs
            Exit Function
         End If
         Dim h As Integer
         For h = 0 To starts.Count - 1
            Dim startIdx As Integer = CInt(starts.Strings(h))
            Dim endIdx As Integer
            If h < starts.Count - 1 Then
               endIdx = CInt(starts.Strings(h + 1)) - 1
            Else
               endIdx = pLines.Count - 1
            End If
            Dim block As New StringList()
            Dim j As Integer
            For j = startIdx + 1 To endIdx
               block.Add(pLines.Strings(j))
            Next
            Dim cert As New TCertificate()
            cert.Location = pLocation
            cert.Store = pStore
            cert.CleanOnFree = False
            cert.ApplyDump(block)
            cert.MarkInstalled()
            certs.Push(cert)
            block.Free()
         Next
         starts.Free()
         FromDump = certs
      End Function

      Function Expired() As TCertificates
         Expired = me.SelectWhere(True, False, False, 0, "")
      End Function

      Function Valid() As TCertificates
         Valid = me.SelectWhere(False, True, False, 0, "")
      End Function

      Function WithPrivateKey() As TCertificates
         WithPrivateKey = me.SelectWhere(False, False, True, 0, "")
      End Function

      Function ExpiringWithin(pDays As Integer) As TCertificates
         ExpiringWithin = me.SelectWhere(False, False, False, pDays, "")
      End Function

      Function Search(pQuery As String) As TCertificates
         Search = me.SelectWhere(False, False, False, 0, pQuery)
      End Function

      Function FindByThumbprint(pHash As String) As TCertificate
         Dim needle As String = TCertificate.NormalizeHash(pHash)
         Dim i As Integer
         For i = 0 To me.Length - 1
            Dim cert As TCertificate = me.Take(i)
            If cert.Thumbprint = needle Then
               FindByThumbprint = cert
               Exit Function
            End If
         Next
      End Function

      Function FindByName(pName As String) As TCertificate
         Dim needle As String = UCase(Trim(pName))
         Dim i As Integer
         For i = 0 To me.Length - 1
            Dim cert As TCertificate = me.Take(i)
            If UCase(cert.Name) = needle Then
               FindByName = cert
               Exit Function
            End If
         Next
         For i = 0 To me.Length - 1
            Dim cert2 As TCertificate = me.Take(i)
            If cert2.Matches(pName) Then
               FindByName = cert2
               Exit Function
            End If
         Next
      End Function

      Function FindBySerial(pSerial As String) As TCertificate
         Dim needle As String = UCase(Replace(Trim(pSerial), " ", ""))
         Dim i As Integer
         For i = 0 To me.Length - 1
            Dim cert As TCertificate = me.Take(i)
            If UCase(Replace(cert.Serie, " ", "")) = needle Then
               FindBySerial = cert
               Exit Function
            End If
         Next
      End Function

      Private Function SelectWhere(pExpired As Boolean, pValid As Boolean, pPrivateKey As Boolean, pDays As Integer, pQuery As String) As TCertificates
         Dim result As New TCertificates()
         Dim i As Integer
         For i = 0 To me.Length - 1
            Dim cert As TCertificate = me.Take(i)
            Dim ok As Boolean = True
            If pExpired Then
               ok = cert.IsExpired
            End If
            If ok And pValid Then
               ok = cert.IsValid
            End If
            If ok And pPrivateKey Then
               ok = cert.HasPrivateKey
            End If
            If ok And (pDays > 0) Then
               ok = cert.IsValid And (cert.DaysToExpire() <= pDays)
            End If
            If ok And (Trim(pQuery) <> "") Then
               ok = cert.Matches(pQuery)
            End If
            If ok Then
               result.Push(cert.Copy())
            End If
         Next
         SelectWhere = result
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
