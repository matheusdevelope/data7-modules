Imports mod_strings

Namespace mod_validators

   Class TDocs

      Sub New()
         MyBase.New()
      End Sub

      Private Shared Function _onlyAlphaNum(pValue As String) As String
         Dim cleaned As String
         Dim result As String
         cleaned = ReplacePattern(pValue, "[^A-Za-z0-9]", "")
         result = ToUpperCase(cleaned)
         _onlyAlphaNum = result
      End Function

      Private Shared Function _allSame(pValue As String) As Boolean
         If IsEmptyString(pValue) Then
            _allSame = True
            Exit Function
         End If
         Dim same As Boolean
         same = IsMatch(pValue, "^(.)\1*$", False)
         _allSame = same
      End Function

      Shared Function FormatCPF(pDigits As String) As String
         Dim d As String = OnlyNumbers(pDigits)
         If Len(d) <> 11 Then
            FormatCPF = pDigits
         Else
            FormatCPF = Left(d, 3) + "." + Mid(d, 4, 3) + "." + Mid(d, 7, 3) + "-" + Right(d, 2)
         End If
      End Function

      Shared Function FormatCNPJ(pDigits As String) As String
         Dim d As String = _onlyAlphaNum(pDigits)
         If Len(d) <> 14 Then
            FormatCNPJ = pDigits
         Else
            FormatCNPJ = Left(d, 2) + "." + Mid(d, 3, 3) + "." + Mid(d, 6, 3) + "/" + Mid(d, 9, 4) + "-" + Right(d, 2)
         End If
      End Function

      Shared Function FormatCEP(pDigits As String) As String
         Dim d As String = OnlyNumbers(pDigits)
         If Len(d) <> 8 Then
            FormatCEP = pDigits
         Else
            FormatCEP = Left(d, 5) + "-" + Right(d, 3)
         End If
      End Function

      Shared Function IsValidCEP(pValue As String) As Boolean
         Dim d As String = OnlyNumbers(pValue)
         Dim ok As Boolean
         ok = IsMatch(d, "^\d{8}$", False)
         IsValidCEP = ok
      End Function

      Shared Function IsValidCPF(pValue As String) As Boolean
         Dim d As String = OnlyNumbers(pValue)
         If Len(d) <> 11 Then
            IsValidCPF = False
            Exit Function
         End If
         If _allSame(d) Then
            IsValidCPF = False
            Exit Function
         End If
         Dim i As Integer
         Dim sum As Integer = 0
         Dim weight As Integer = 10
         For i = 1 To 9
            sum = sum + TText.DigitAt(d, i) * weight
            weight = weight - 1
         Next
         Dim rest As Integer = sum Mod 11
         Dim dv1 As Integer
         If rest < 2 Then
            dv1 = 0
         Else
            dv1 = 11 - rest
         End If
         If dv1 <> TText.DigitAt(d, 10) Then
            IsValidCPF = False
            Exit Function
         End If
         sum = 0
         weight = 11
         For i = 1 To 10
            sum = sum + TText.DigitAt(d, i) * weight
            weight = weight - 1
         Next
         rest = sum Mod 11
         Dim dv2 As Integer
         If rest < 2 Then
            dv2 = 0
         Else
            dv2 = 11 - rest
         End If
         IsValidCPF = CBool(dv2 = TText.DigitAt(d, 11))
      End Function

      Shared Function IsValidCNPJ(pValue As String) As Boolean
         Dim d As String = _onlyAlphaNum(pValue)
         If Len(d) <> 14 Then
            IsValidCNPJ = False
            Exit Function
         End If
         Dim i As Integer
         For i = 1 To 12
            Dim ch As String = Mid(d, i, 1)
            If Not ((ch >= "0" And ch <= "9") Or (ch >= "A" And ch <= "Z")) Then
               IsValidCNPJ = False
               Exit Function
            End If
         Next
         If Not ((Mid(d, 13, 1) >= "0" And Mid(d, 13, 1) <= "9") And (Mid(d, 14, 1) >= "0" And Mid(d, 14, 1) <= "9")) Then
            IsValidCNPJ = False
            Exit Function
         End If
         If _allSame(d) Then
            IsValidCNPJ = False
            Exit Function
         End If
         If _cnpjMod11(Left(d, 12)) <> TText.DigitAt(d, 13) Then
            IsValidCNPJ = False
            Exit Function
         End If
         IsValidCNPJ = CBool(_cnpjMod11(Left(d, 13)) = TText.DigitAt(d, 14))
      End Function

      Shared Function IsValidCPFCnpj(pValue As String) As Boolean
         Dim d As String = _onlyAlphaNum(pValue)
         Dim n As Integer = Len(d)
         If n = 11 Then
            If d <> OnlyNumbers(d) Then
               IsValidCPFCnpj = False
            Else
               IsValidCPFCnpj = TDocs.IsValidCPF(d)
            End If
         ElseIf n = 14 Then
            IsValidCPFCnpj = TDocs.IsValidCNPJ(d)
         Else
            IsValidCPFCnpj = False
         End If
      End Function

      Shared Function IsValidCNH(pValue As String) As Boolean
         Dim d As String = OnlyNumbers(pValue)
         If Len(d) <> 11 Then
            IsValidCNH = False
            Exit Function
         End If
         If _allSame(d) Then
            IsValidCNH = False
            Exit Function
         End If
         Dim i As Integer
         Dim sum As Integer = 0
         Dim weight As Integer = 9
         For i = 1 To 9
            sum = sum + TText.DigitAt(d, i) * weight
            weight = weight - 1
         Next
         Dim dv1 As Integer = sum Mod 11
         Dim dsc As Integer = 0
         If dv1 > 9 Then
            dv1 = 0
            dsc = 2
         End If
         sum = 0
         weight = 1
         For i = 1 To 9
            sum = sum + TText.DigitAt(d, i) * weight
            weight = weight + 1
         Next
         Dim dv2 As Integer = sum Mod 11
         If dv2 > 9 Then
            dv2 = 0
         End If
         dv2 = dv2 - dsc
         If dv2 < 0 Then
            dv2 = dv2 + 11
         End If
         IsValidCNH = CBool(dv1 = TText.DigitAt(d, 10) And dv2 = TText.DigitAt(d, 11))
      End Function

      Shared Function IsValidRenavam(pValue As String) As Boolean
         Dim d As String = OnlyNumbers(pValue)
         Dim n As Integer = Len(d)
         If n <> 9 And n <> 10 And n <> 11 Then
            IsValidRenavam = False
            Exit Function
         End If
         d = PadStart(d, 11, "0")
         Dim seq As String = "3298765432"
         Dim i As Integer
         Dim sum As Integer = 0
         For i = 1 To 10
            sum = sum + TText.DigitAt(d, i) * TText.DigitAt(seq, i)
         Next
         Dim dv As Integer = 11 - (sum Mod 11)
         If dv = 10 Or dv = 11 Then
            dv = 0
         End If
         IsValidRenavam = CBool(dv = TText.DigitAt(d, 11))
      End Function

      Shared Function IsValidSuframa(pValue As String) As Boolean
         Dim d As String = OnlyNumbers(pValue)
         If Len(d) <> 9 Then
            IsValidSuframa = False
            Exit Function
         End If
         Dim i As Integer = 8
         Dim sum As Integer = 0
         Dim weight As Integer = 2
         While i >= 1
            sum = sum + TText.DigitAt(d, i) * weight
            weight = weight + 1
            If weight > 9 Then
               weight = 2
            End If
            i = i - 1
         Wend
         Dim rest As Integer = sum Mod 11
         Dim dv As Integer
         If rest < 2 Then
            dv = 0
         Else
            dv = 11 - rest
         End If
         IsValidSuframa = CBool(dv = TText.DigitAt(d, 9))
      End Function

      Shared Function IsValidGTIN(pValue As String) As Boolean
         Dim d As String = OnlyNumbers(pValue)
         Dim n As Integer = Len(d)
         If n <> 8 And n <> 12 And n <> 13 And n <> 14 Then
            IsValidGTIN = False
            Exit Function
         End If
         Dim sum As Integer = 0
         Dim pos As Integer = 0
         Dim i As Integer = n - 1
         While i >= 1
            Dim factor As Integer
            If (pos Mod 2) = 0 Then
               factor = 3
            Else
               factor = 1
            End If
            sum = sum + TText.DigitAt(d, i) * factor
            pos = pos + 1
            i = i - 1
         Wend
         Dim dv As Integer = (10 - (sum Mod 10)) Mod 10
         IsValidGTIN = CBool(dv = TText.DigitAt(d, n))
      End Function

      Shared Function IsValidPlaca(pValue As String) As Boolean
         Dim raw As String = _onlyAlphaNum(pValue)
         If Len(raw) <> 7 Then
            IsValidPlaca = False
            Exit Function
         End If
         Dim oldOk As Boolean
         Dim merOk As Boolean
         oldOk = IsMatch(raw, "^[A-Z]{3}[0-9]{4}$", True)
         merOk = IsMatch(raw, "^[A-Z]{3}[0-9][A-Z][0-9]{2}$", True)
         IsValidPlaca = CBool(oldOk Or merOk)
      End Function

      Shared Function IsValidIE(pValue As String, pUF As String) As Boolean
         Dim uf As String = ToUpperCase(pUF.Trim())
         Dim raw As String = pValue.Trim()
         If EqualsIgnoreCase(raw, "ISENTO") Then
            IsValidIE = True
            Exit Function
         End If
         Dim d As String = OnlyNumbers(pValue)
         If IsBlank(uf) Or Len(d) < 8 Or Len(d) > 14 Then
            IsValidIE = False
            Exit Function
         End If
         If uf = "AC" Then
            IsValidIE = _ieAC(d)
         ElseIf uf = "AL" Then
            IsValidIE = _ieAL(d)
         ElseIf uf = "AM" Then
            IsValidIE = _ieNove(d, "9")
         ElseIf uf = "AP" Then
            IsValidIE = _ieAP(d)
         ElseIf uf = "BA" Then
            IsValidIE = _ieBA(d)
         ElseIf uf = "CE" Then
            IsValidIE = _ieNove(d, "")
         ElseIf uf = "DF" Then
            IsValidIE = _ieDF(d)
         ElseIf uf = "ES" Then
            IsValidIE = _ieNove(d, "")
         ElseIf uf = "GO" Then
            IsValidIE = _ieNove(d, "")
         ElseIf uf = "MA" Then
            IsValidIE = _ieNove(d, "12")
         ElseIf uf = "MG" Then
            IsValidIE = _ieMG(d)
         ElseIf uf = "MS" Then
            IsValidIE = _ieNove(d, "28")
         ElseIf uf = "MT" Then
            IsValidIE = _ieMT(d)
         ElseIf uf = "PA" Then
            IsValidIE = _ieNove(d, "15")
         ElseIf uf = "PB" Then
            IsValidIE = _ieNove(d, "")
         ElseIf uf = "PE" Then
            IsValidIE = _iePE(d)
         ElseIf uf = "PI" Then
            IsValidIE = _ieNove(d, "")
         ElseIf uf = "PR" Then
            IsValidIE = _iePR(d)
         ElseIf uf = "RJ" Then
            IsValidIE = _ieRJ(d)
         ElseIf uf = "RN" Then
            IsValidIE = _ieRN(d)
         ElseIf uf = "RO" Then
            IsValidIE = _ieRO(d)
         ElseIf uf = "RR" Then
            IsValidIE = _ieRR(d)
         ElseIf uf = "RS" Then
            IsValidIE = _ieRS(d)
         ElseIf uf = "SC" Then
            IsValidIE = _ieNove(d, "")
         ElseIf uf = "SE" Then
            IsValidIE = _ieNove(d, "")
         ElseIf uf = "SP" Then
            IsValidIE = _ieSP(d)
         ElseIf uf = "TO" Then
            IsValidIE = _ieTO(d)
         Else
            IsValidIE = False
         End If
      End Function

      Private Shared Function _cnpjMod11(pBase As String) As Integer
         Dim pos As Integer = Len(pBase)
         Dim sum As Integer = 0
         Dim weight As Integer = 2
         While pos >= 1
            Dim ch As String = Mid(pBase, pos, 1)
            sum = sum + (CInt(Asc(ch.LastChar())) - 48) * weight
            weight = weight + 1
            If weight > 9 Then
               weight = 2
            End If
            pos = pos - 1
         Wend
         Dim rest As Integer = sum Mod 11
         If rest < 2 Then
            _cnpjMod11 = 0
         Else
            _cnpjMod11 = 11 - rest
         End If
      End Function

      Private Shared Function _ieNove(pDigits As String, pPrefix As String) As Boolean
         If Len(pDigits) <> 9 Then
            _ieNove = False
            Exit Function
         End If
         If pPrefix <> "" Then
            If pDigits.Left( Len(pPrefix)) <> pPrefix Then
               _ieNove = False
               Exit Function
            End If
         End If
         _ieNove = CBool(TText.Mod11(pDigits.Left(8), "98765432") = TText.DigitAt(pDigits, 9))
      End Function

      Private Shared Function _ieAC(pDigits As String) As Boolean
         If Len(pDigits) <> 13 Then
            _ieAC = False
            Exit Function
         End If
         Dim prefix As String
         prefix = pDigits.Left(2)
         If prefix <> "01" Then
            _ieAC = False
            Exit Function
         End If
         Dim body11 As String
         Dim dv1 As Integer
         Dim got1 As Integer
         body11 = pDigits.Left(11)
         dv1 = TText.Mod11(body11, "43298765432")
         got1 = TText.DigitAt(pDigits, 12)
         If dv1 <> got1 Then
            _ieAC = False
            Exit Function
         End If
         Dim body12 As String
         Dim dv2 As Integer
         Dim got2 As Integer
         body12 = pDigits.Left(12)
         dv2 = TText.Mod11(body12, "543298765432")
         got2 = TText.DigitAt(pDigits, 13)
         _ieAC = CBool(dv2 = got2)
      End Function

      Private Shared Function _ieAL(pDigits As String) As Boolean
         If Len(pDigits) <> 9 Then
            _ieAL = False
            Exit Function
         End If
         If pDigits.Left( 2) <> "24" Then
            _ieAL = False
            Exit Function
         End If
         Dim i As Integer
         Dim sum As Integer = 0
         Dim weight As Integer = 9
         For i = 1 To 8
            sum = sum + TText.DigitAt(pDigits, i) * weight
            weight = weight - 1
         Next
         sum = sum * 10
         Dim rest As Integer = sum Mod 11
         If rest = 10 Then
            rest = 0
         End If
         _ieAL = CBool(rest = TText.DigitAt(pDigits, 9))
      End Function

      Private Shared Function _ieAP(pDigits As String) As Boolean
         If Len(pDigits) <> 9 Then
            _ieAP = False
            Exit Function
         End If
         If pDigits.Left( 2) <> "03" Then
            _ieAP = False
            Exit Function
         End If
         Dim body As Integer = CInt(pDigits.Left( 8))
         Dim p As Integer = 0
         Dim d As Integer = 0
         If body >= 3000001 And body <= 3017000 Then
            p = 5
            d = 0
         ElseIf body >= 3017001 And body <= 3019022 Then
            p = 9
            d = 1
         End If
         Dim i As Integer
         Dim sum As Integer = p
         Dim weight As Integer = 9
         For i = 1 To 8
            sum = sum + TText.DigitAt(pDigits, i) * weight
            weight = weight - 1
         Next
         Dim rest As Integer = sum Mod 11
         Dim dv As Integer
         If rest = 10 Then
            dv = 0
         ElseIf rest = 11 Then
            dv = d
         Else
            dv = 11 - rest
         End If
         _ieAP = CBool(dv = TText.DigitAt(pDigits, 9))
      End Function

      Private Shared Function _ieBA(pDigits As String) As Boolean
         Dim n As Integer = Len(pDigits)
         If n <> 8 And n <> 9 Then
            _ieBA = False
            Exit Function
         End If
         Dim modulo As Integer = 10
         If TText.DigitAt(pDigits, 1) = 6 Or TText.DigitAt(pDigits, 1) = 7 Or TText.DigitAt(pDigits, 1) = 9 Then
            modulo = 11
         End If
         Dim baseLen As Integer = n - 2
         Dim body As String = pDigits.Left( baseLen)
         Dim i As Integer
         Dim sum As Integer = 0
         Dim weight As Integer = baseLen + 1
         For i = 1 To baseLen
            sum = sum + TText.DigitAt(body, i) * weight
            weight = weight - 1
         Next
         Dim rest As Integer = sum Mod modulo
         Dim dv2 As Integer
         If rest = 0 Then
            dv2 = 0
         Else
            dv2 = modulo - rest
         End If
         If dv2 >= 10 Then
            dv2 = 0
         End If
         Dim withDv2 As String = body + CStr(dv2)
         sum = 0
         weight = baseLen + 2
         For i = 1 To baseLen + 1
            sum = sum + TText.DigitAt(withDv2, i) * weight
            weight = weight - 1
         Next
         rest = sum Mod modulo
         Dim dv1 As Integer
         If rest = 0 Then
            dv1 = 0
         Else
            dv1 = modulo - rest
         End If
         If dv1 >= 10 Then
            dv1 = 0
         End If
         _ieBA = CBool(CStr(dv1) + CStr(dv2) = Right(pDigits, 2))
      End Function

      Private Shared Function _ieDF(pDigits As String) As Boolean
         If Len(pDigits) <> 13 Then
            _ieDF = False
            Exit Function
         End If
         If TText.Mod11(pDigits.Left( 11), "43298765432") <> TText.DigitAt(pDigits, 12) Then
            _ieDF = False
            Exit Function
         End If
         _ieDF = CBool(TText.Mod11(pDigits.Left( 12), "543298765432") = TText.DigitAt(pDigits, 13))
      End Function

      Private Shared Function _ieMG(pDigits As String) As Boolean
         If Len(pDigits) <> 13 Then
            _ieMG = False
            Exit Function
         End If
         Dim ie2 As String = pDigits.Left( 3) + "0" + Mid(pDigits, 4, 8)
         Dim i As Integer
         Dim sum As Integer = 0
         For i = 1 To Len(ie2)
            Dim factor As Integer
            If (i Mod 2) = 1 Then
               factor = 1
            Else
               factor = 2
            End If
            Dim prod As Integer = TText.DigitAt(ie2, i) * factor
            Dim tens As Integer = 0
            If prod >= 10 Then
               tens = 1
            End If
            sum = sum + tens + (prod Mod 10)
         Next
         Dim dv1 As Integer = (10 - (sum Mod 10)) Mod 10
         If dv1 <> TText.DigitAt(pDigits, 12) Then
            _ieMG = False
            Exit Function
         End If
         Dim w As String = "321A98765432"
         Dim sum2 As Integer = 0
         For i = 1 To 12
            Dim wc As String = Mid(w, i, 1)
            Dim weight As Integer
            If wc = "A" Then
               weight = 10
            Else
               weight = CInt(wc)
            End If
            sum2 = sum2 + TText.DigitAt(pDigits, i) * weight
         Next
         Dim rest As Integer = sum2 Mod 11
         Dim dv2 As Integer
         If rest < 2 Then
            dv2 = 0
         Else
            dv2 = 11 - rest
         End If
         _ieMG = CBool(dv2 = TText.DigitAt(pDigits, 13))
      End Function

      Private Shared Function _ieMT(pDigits As String) As Boolean
         If Len(pDigits) <> 11 Then
            _ieMT = False
            Exit Function
         End If
         _ieMT = CBool(TText.Mod11(pDigits.Left( 10), "3298765432") = TText.DigitAt(pDigits, 11))
      End Function

      Private Shared Function _iePE(pDigits As String) As Boolean
         Dim n As Integer = Len(pDigits)
         If n = 9 Then
            If TText.Mod11(pDigits.Left( 7), "8765432") <> TText.DigitAt(pDigits, 8) Then
               _iePE = False
               Exit Function
            End If
            _iePE = CBool(TText.Mod11(pDigits.Left( 8), "98765432") = TText.DigitAt(pDigits, 9))
         ElseIf n = 14 Then
            _iePE = CBool(TText.Mod11(pDigits.Left( 13), "5432987654321") = TText.DigitAt(pDigits, 14))
         Else
            _iePE = False
         End If
      End Function

      Private Shared Function _iePR(pDigits As String) As Boolean
         If Len(pDigits) <> 10 Then
            _iePR = False
            Exit Function
         End If
         If TText.Mod11(pDigits.Left( 8), "32765432") <> TText.DigitAt(pDigits, 9) Then
            _iePR = False
            Exit Function
         End If
         _iePR = CBool(TText.Mod11(pDigits.Left( 9), "432765432") = TText.DigitAt(pDigits, 10))
      End Function

      Private Shared Function _ieRJ(pDigits As String) As Boolean
         If Len(pDigits) <> 8 Then
            _ieRJ = False
            Exit Function
         End If
         _ieRJ = CBool(TText.Mod11(pDigits.Left( 7), "2765432") = TText.DigitAt(pDigits, 8))
      End Function

      Private Shared Function _ieRN(pDigits As String) As Boolean
         Dim n As Integer = Len(pDigits)
         If n <> 9 And n <> 10 Then
            _ieRN = False
            Exit Function
         End If
         If pDigits.Left( 2) <> "20" Then
            _ieRN = False
            Exit Function
         End If
         Dim i As Integer
         Dim sum As Integer = 0
         Dim weight As Integer = n
         For i = 1 To n - 1
            sum = sum + TText.DigitAt(pDigits, i) * weight
            weight = weight - 1
         Next
         sum = sum * 10
         Dim rest As Integer = sum Mod 11
         If rest = 10 Then
            rest = 0
         End If
         _ieRN = CBool(rest = TText.DigitAt(pDigits, n))
      End Function

      Private Shared Function _ieRO(pDigits As String) As Boolean
         Dim n As Integer = Len(pDigits)
         If n = 9 Then
            _ieRO = CBool(TText.Mod11(pDigits.Left( 8), "65432987") = TText.DigitAt(pDigits, 9))
         ElseIf n = 14 Then
            _ieRO = CBool(TText.Mod11(pDigits.Left( 13), "6543298765432") = TText.DigitAt(pDigits, 14))
         Else
            _ieRO = False
         End If
      End Function

      Private Shared Function _ieRR(pDigits As String) As Boolean
         If Len(pDigits) <> 9 Then
            _ieRR = False
            Exit Function
         End If
         If pDigits.Left( 2) <> "24" Then
            _ieRR = False
            Exit Function
         End If
         Dim i As Integer
         Dim sum As Integer = 0
         For i = 1 To 8
            sum = sum + TText.DigitAt(pDigits, i) * i
         Next
         _ieRR = CBool((sum Mod 9) = TText.DigitAt(pDigits, 9))
      End Function

      Private Shared Function _ieRS(pDigits As String) As Boolean
         If Len(pDigits) <> 10 Then
            _ieRS = False
            Exit Function
         End If
         _ieRS = CBool(TText.Mod11(pDigits.Left( 9), "298765432") = TText.DigitAt(pDigits, 10))
      End Function

      Private Shared Function _ieSP(pDigits As String) As Boolean
         If Len(pDigits) <> 12 Then
            _ieSP = False
            Exit Function
         End If
         Dim i As Integer
         Dim sum As Integer = 0
         Dim w1 As String = "1345678A"
         For i = 1 To 8
            Dim wc As String = Mid(w1, i, 1)
            Dim weight As Integer
            If wc = "A" Then
               weight = 10
            Else
               weight = CInt(wc)
            End If
            sum = sum + TText.DigitAt(pDigits, i) * weight
         Next
         Dim dv1 As Integer = (sum Mod 11) Mod 10
         If dv1 <> TText.DigitAt(pDigits, 9) Then
            _ieSP = False
            Exit Function
         End If
         sum = 0
         Dim w2 As String = "32A98765432"
         For i = 1 To 11
            Dim wc2 As String = Mid(w2, i, 1)
            Dim weight2 As Integer
            If wc2 = "A" Then
               weight2 = 10
            Else
               weight2 = CInt(wc2)
            End If
            sum = sum + TText.DigitAt(pDigits, i) * weight2
         Next
         Dim dv2 As Integer = (sum Mod 11) Mod 10
         _ieSP = CBool(dv2 = TText.DigitAt(pDigits, 12))
      End Function

      Private Shared Function _ieTO(pDigits As String) As Boolean
         If Len(pDigits) <> 11 Then
            _ieTO = False
            Exit Function
         End If
         Dim body As String = pDigits.Left( 2) + Mid(pDigits, 5, 6)
         _ieTO = CBool(TText.Mod11(body, "98765432") = TText.DigitAt(pDigits, 11))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
