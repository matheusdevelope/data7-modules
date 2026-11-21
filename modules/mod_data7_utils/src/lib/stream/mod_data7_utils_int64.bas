Namespace mod_data7_utils_int64

   ' Data7 Long is 32-bit. File Size/Position/Seek must use Int64 (same as mod_http).

   Function UtilsZero64() As Int64
      Dim zeroText As String = "0"
      UtilsZero64 = zeroText.ToInt64()
   End Function

   Function UtilsFromInteger(pValue As Integer) As Int64
      Dim text As String = CStr(pValue)
      UtilsFromInteger = text.ToInt64()
   End Function

   Function UtilsParseInt64(pText As String) As Int64
      Dim raw As String = Trim(pText)
      If raw = "" Then
         UtilsParseInt64 = UtilsZero64()
         Exit Function
      End If
      UtilsParseInt64 = raw.ToInt64()
   End Function

   Function UtilsInt64Text(pValue As Int64) As String
      UtilsInt64Text = pValue.ToString()
   End Function

End Namespace
