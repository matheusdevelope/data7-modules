Imports mod_strings

Namespace mod_validators

   Class TText

      Sub New()
         MyBase.New()
      End Sub

      Shared Function OnlyDigits(pValue As String) As String
         Dim digits As String
         digits = OnlyNumbers(pValue)
         OnlyDigits = digits
      End Function

      Shared Function OnlyAlphaNum(pValue As String) As String
         Dim cleaned As String
         Dim result As String
         cleaned = ReplacePattern(pValue, "[^A-Za-z0-9]", "")
         result = ToUpperCase(cleaned)
         OnlyAlphaNum = result
      End Function

      Shared Function DigitAt(pDigits As String, pIndex As Integer) As Integer
         If pIndex < 1 Or pIndex > Len(pDigits) Then
            DigitAt = 0
            Exit Function
         End If
         Dim ch As String
         ch = Mid(pDigits, pIndex, 1)
         If ch = "" Then
            DigitAt = 0
            Exit Function
         End If
         DigitAt = CInt(ch)
      End Function

      Shared Function Mod11(pBase As String, pWeights As String) As Integer
         Dim i As Integer
         Dim n As Integer = Len(pBase)
         Dim sum As Integer = 0
         For i = 1 To n
            Dim baseDigit As Integer
            Dim weightDigit As Integer
            baseDigit = DigitAt(pBase, i)
            weightDigit = DigitAt(pWeights, i)
            sum = sum + baseDigit * weightDigit
         Next
         Dim rest As Integer = sum Mod 11
         If rest < 2 Then
            Mod11 = 0
         Else
            Mod11 = 11 - rest
         End If
      End Function

      Shared Function AllSameDigits(pValue As String) As Boolean
         If IsEmptyString(pValue) Then
            AllSameDigits = True
            Exit Function
         End If
         Dim same As Boolean
         same = IsMatch(pValue, "^(.)\1*$", False)
         AllSameDigits = same
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
