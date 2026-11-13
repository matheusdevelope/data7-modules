
Namespace mod_pix_utils

   Function GenerateTxID(pLenght As Integer = 35) As String
      If pLenght > 35 Then
         pLenght = 35
      End If
      GenerateTxID = Data7.Criptografar(DateTime().ToString("dd/mm/yyyy h:n:s.z")).Right(pLenght)
   End Function

   Function GenerateIDDevolucao() As String
      GenerateIDDevolucao = GenerateTxID(20)
   End Function

   Function FormatValueToString(pValor As Double) As String
      FormatValueToString = pValor.ToString("0.00").Replace(",", ".")
   End Function

   Function FormatValueToDouble(pValor As String) As Double
      FormatValueToDouble = CDbl(pValor.Replace(".", ","))
   End Function

   Function IsEmptyDate(pDate As TDateTime) As Boolean
      IsEmptyDate = pDate.ToInt32() = 18991230
   End Function

   Function DateToUTC(pDate As TDateTime, pTimeZoneHours As Integer = 0) As TDateTime
      DateToUTC = pDate.AddHours(-pTimeZoneHours)
   End Function

   Function DateToISO8601(pDate As TDateTime, pTimeZoneHours As Integer = 0) As String
      Dim utc As TDateTime = DateToUTC(pDate, pTimeZoneHours)
      DateToISO8601 = utc.ToString("yyyy-mm-dd") & "T" & utc.ToString("hh:nn:ss.zz") & "Z"
   End Function

   Function DateToQueryParam(pDate As TDateTime, pTimeZoneHours As Integer = 0) As String
      Dim utc As TDateTime = DateToUTC(pDate, pTimeZoneHours)
      DateToQueryParam = utc.ToString("yyyy-mm-dd") & "T" & utc.ToString("hh:nn:ss") & "Z"
   End Function

   Function DateToISO8601Millis(pDate As TDateTime, pTimeZoneHours As Integer = 0) As String
      Dim utc As TDateTime = DateToUTC(pDate, pTimeZoneHours)
      Dim ms As String = Right("000" & CStr(utc.MilliSecondOf()), 3)
      DateToISO8601Millis = utc.ToString("yyyy-mm-dd") & "T" & utc.ToString("hh:nn:ss") & "." & ms & "Z"
   End Function

   Function ParseISO8601(pValue As String) As TDateTime
      Dim ano As Integer = CInt(Mid(pValue, 1, 4))
      Dim mes As Integer = CInt(Mid(pValue, 6, 2))
      Dim dia As Integer = CInt(Mid(pValue, 9, 2))
      Dim hora As Integer = CInt(Mid(pValue, 12, 2))
      Dim minuto As Integer = CInt(Mid(pValue, 15, 2))
      Dim segundo As Integer = 0
      Dim millis As Integer = 0

      If pValue.Length >= 17 Then
         If Mid(pValue, 17, 1) = ":" Then
            segundo = CInt(Mid(pValue, 18, 2))
            If Mid(pValue, 20, 1) = "." Then
               Dim msStr As String
               Dim i As Integer = 21
               Do While i <= pValue.Length And Mid(pValue, i, 1) >= "0" And Mid(pValue, i, 1) <= "9"
                  msStr += Mid(pValue, i, 1)
                  i += 1
               Loop
               If msStr <> "" Then
                  millis = CInt(msStr)
               End If
            End If
         End If
      End If

      Dim dt As TDateTime = DateTime()
      ParseISO8601 = dt.EncodeDateTime(ano, mes, dia, hora, minuto, segundo, millis)
   End Function

   Function GerarPixCopiaECola(pLocation As String) As String
      Dim urlLimpa As String = pLocation
      If LCase(Left(pLocation, 8)) = "https://" Then
         urlLimpa = Mid(pLocation, 9)
      End If
      Dim sGui As String = BuildFieldEMV("00", "br.gov.bcb.pix")
      Dim sUrl As String = BuildFieldEMV("25", urlLimpa)
      Dim emv As String = BuildFieldEMV("00", "01")
      emv = emv & BuildFieldEMV("26", sGui & sUrl)
      emv = emv & BuildFieldEMV("52", "0000")
      emv = emv & BuildFieldEMV("53", "986")
      emv = emv & BuildFieldEMV("58", "BR")
      emv = emv & BuildFieldEMV("59", "PIX")
      emv = emv & BuildFieldEMV("60", "Cidade")
      emv = emv & BuildFieldEMV("62", "0503***")
      emv = emv & BuildFieldEMV("63", CRC16CCITT(emv & "6304"))
      GerarPixCopiaECola = emv
   End Function

   Function BuildFieldEMV(pId As String, pValue As String) As String
      BuildFieldEMV = pId & Right("00" & CStr(Len(pValue)), 2) & pValue
   End Function

   Function CRC16CCITT(pData As String) As String
      Dim length As Long = pData.Length
      Dim wCrc As Long = &HFFFF
      Dim i As Long
      Dim j As Integer
      Dim ch As Byte
      For i = 1 To length
         ch = Asc(Mid(pData, i, 1).LastChar())
         wCrc = wCrc Xor (CLng(ch) * &H100)
         For j = 1 To 8
            If (wCrc And &H8000) <> 0 Then
               wCrc = ((wCrc And &H7FFF) * 2) Xor &H1021
            Else
               wCrc = (wCrc And &H7FFF) * 2
            End If
         Next
      Next
      wCrc = wCrc And &HFFFF
      CRC16CCITT = Right("0000" & Hex(wCrc), 4)
   End Function

End Namespace
