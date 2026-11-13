Imports Forms

Namespace mod_wa_phone_mask

   Class WaPhoneMask

      Shared Function OnlyNumbers(pValue As String) As String
         If pValue.Length = 0 Then
            OnlyNumbers = ""
            Exit Function
         End If
         Dim _mask As New Forms.MaskTextBox(NULL)
         _mask.Mascara = pValue.StringOfChar("9", pValue.Length)
         _mask.Text = pValue
         Dim _digits As String = _mask.Text.Replace(" ", "").Replace(Char(13), "")
         _mask.Free()
         OnlyNumbers = _digits
      End Function

      Shared Function Apply(pPhone As String, pDefaultDDD As String) As String
         Dim _phone As String = WaPhoneMask.OnlyNumbers(pPhone)
         If _phone.Length = 13 Or _phone.Length = 12 Then
            _phone = _phone.Right(_phone.Length - 2)
         End If
         If _phone.Length = 11 Then
            Apply = $"({_phone.Copy(1, 2)}) {_phone.Copy(3, 5)}-{_phone.Copy(8, 4)}"
         ElseIf _phone.Length = 10 Then
            Apply = $"({_phone.Copy(1, 2)}) {_phone.Copy(3, 4)}-{_phone.Copy(7, 4)}"
         ElseIf _phone.Length = 9 Then
            Apply = $"({pDefaultDDD}) {_phone.Copy(1, 5)}-{_phone.Copy(6, 4)}"
         Else
            Apply = $"({pDefaultDDD}) {_phone.Copy(1, 4)}-{_phone.Copy(5, 4)}"
         End If
      End Function

      Shared Function GetMask(pPhone As String) As String
         Dim _phone As String = WaPhoneMask.OnlyNumbers(pPhone)
         GetMask = _phone.Length < 11 ? "(99) 9999-9999" : "(99) 99999-9999"
      End Function

      Shared Function DigitFromKey(pKey As Integer) As String
         If pKey >= 48 And pKey <= 57 Then
            DigitFromKey = Char(pKey)
         ElseIf pKey >= 96 And pKey <= 105 Then
            DigitFromKey = Char(pKey - 48)
         Else
            DigitFromKey = ""
         End If
      End Function

      Shared Function WithCountryCode(pPhone As String, pCountryCode As String, pDefaultDDD As String) As String
         Dim _digits As String = WaPhoneMask.OnlyNumbers(pPhone)
         If _digits.StartsWith(pCountryCode) And (_digits.Length = 12 Or _digits.Length = 13) Then
            WithCountryCode = _digits
            Exit Function
         End If
         If _digits.Length = 8 Or _digits.Length = 9 Then
            _digits = pDefaultDDD + _digits
         End If
         If Not _digits.StartsWith(pCountryCode) Then
            _digits = pCountryCode + _digits
         End If
         WithCountryCode = _digits
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
