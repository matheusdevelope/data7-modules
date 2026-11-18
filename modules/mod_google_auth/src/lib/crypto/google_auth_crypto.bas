Imports TPath
Imports TFile
Imports mod_certutil

Namespace google_auth_crypto

   Function RandomUnreserved(pLength As Integer) As String
      Dim alphabet As String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
      Dim size As Integer = alphabet.Length
      Dim i As Integer
      Dim buffer As String = ""
      System.Randomize()
      For i = 1 To pLength
         Dim idx As Integer = System.Random(size)
         buffer = buffer & Mid(alphabet, idx + 1, 1)
      Next
      RandomUnreserved = buffer
   End Function

   Function ToBase64Url(pBase64 As String) As String
      Dim text As String = Trim(pBase64)
      text = text.Replace("+", "-")
      text = text.Replace("/", "_")
      text = text.Replace("=", "")
      text = text.Replace(CHAR(13), "")
      text = text.Replace(CHAR(10), "")
      ToBase64Url = text
   End Function

   Function HexNibble(pCh As String) As Integer
      Dim idx As Integer = InStr("0123456789ABCDEF", UCase(pCh))
      If idx <= 0 Then
         HexNibble = 0
      Else
         HexNibble = idx - 1
      End If
   End Function

   Function HexByteAt(pHex As String, pIndex As Integer) As Integer
      Dim pos As Integer = (pIndex * 2) + 1
      HexByteAt = (HexNibble(Mid(pHex, pos, 1)) * 16) + HexNibble(Mid(pHex, pos + 1, 1))
   End Function

   Function DivFloor(pValue As Long, pDiv As Long) As Long
      If pDiv = 0 Then
         DivFloor = 0
         Exit Function
      End If
      DivFloor = CLng((pValue - (pValue Mod pDiv)) / pDiv)
   End Function

   Function HexToBase64Url(pHex As String) As String
      Dim hexValue As String = UCase(Trim(pHex)).Replace(" ", "").Replace(":", "")
      If (Len(hexValue) Mod 2) = 1 Then
         hexValue = "0" & hexValue
      End If
      Dim byteCount As Integer = CInt(Len(hexValue) / 2)
      Dim alphabet As String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
      Dim buffer As String = ""
      Dim i As Integer = 0
      Dim remaining As Integer
      Dim b0 As Integer
      Dim b1 As Integer
      Dim b2 As Integer
      Dim n As Long
      Dim c0 As Long
      Dim c1 As Long
      Dim c2 As Long
      Dim c3 As Long
      While i < byteCount
         remaining = byteCount - i
         b0 = HexByteAt(hexValue, i)
         b1 = 0
         b2 = 0
         If remaining > 1 Then
            b1 = HexByteAt(hexValue, i + 1)
         End If
         If remaining > 2 Then
            b2 = HexByteAt(hexValue, i + 2)
         End If
         n = (CLng(b0) * 65536) + (CLng(b1) * 256) + CLng(b2)
         c0 = DivFloor(n, 262144)
         c1 = DivFloor(n, 4096) Mod 64
         c2 = DivFloor(n, 64) Mod 64
         c3 = n Mod 64
         buffer = buffer & Mid(alphabet, CInt(c0) + 1, 1)
         buffer = buffer & Mid(alphabet, CInt(c1) + 1, 1)
         If remaining > 1 Then
            buffer = buffer & Mid(alphabet, CInt(c2) + 1, 1)
         End If
         If remaining > 2 Then
            buffer = buffer & Mid(alphabet, CInt(c3) + 1, 1)
         End If
         i = i + 3
      End While
      HexToBase64Url = buffer
   End Function

   Function Sha256Hex(pText As String) As String
      Dim folder As String = TPath.GetTempPath()
      If Trim(folder) = "" Then
         Throw New Exception("Unable to resolve the temp folder for PKCE hashing.")
      End If
      Dim tempFilePath As String = folder & "\gauth_pkce_" & CStr(System.Random(99999999)) & ".tmp"
      Dim stm As Variant = CreateObject("ADODB.Stream")
      stm.Type = 2
      stm.Charset = "us-ascii"
      stm.Open()
      stm.WriteText(pText)
      If TFile.Exists(tempFilePath) Then
         TFile.Delete(tempFilePath)
      End If
      stm.SaveToFile(tempFilePath, 2)
      stm.Close()
      stm = Unassigned
      Dim hexValue As String = TCertUtil.Instance().HashFile(tempFilePath, "SHA256")
      If TFile.Exists(tempFilePath) Then
         TFile.Delete(tempFilePath)
      End If
      Sha256Hex = hexValue
   End Function

   Function Sha256Base64Url(pText As String) As String
      Sha256Base64Url = HexToBase64Url(Sha256Hex(pText))
   End Function

End Namespace
