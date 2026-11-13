Imports mod_strings

Namespace mod_validators

   Class TUrl

      Sub New()
         MyBase.New()
      End Sub

      Shared Function IsValid(pValue As String) As Boolean
         Dim raw As String = pValue.Trim()
         If IsBlank(raw) Then
            IsValid = False
            Exit Function
         End If
         Dim ok As Boolean
         ok = IsMatch(raw, "^(HTTPS?://)?([A-Z0-9-]+\.)+[A-Z]{2,}(/[A-Z0-9._~:/?#@!$&''()*+,;=-]*)?$", True)
         IsValid = ok
      End Function

      Shared Function IsValidHttp(pValue As String) As Boolean
         Dim raw As String = pValue.Trim()
         If IsBlank(raw) Then
            IsValidHttp = False
            Exit Function
         End If
         Dim ok As Boolean
         ok = IsMatch(raw, "^https?://[^\s<>""']+$", True)
         IsValidHttp = ok
      End Function

      Shared Function Format(pValue As String) As String
         Dim raw As String = pValue.Trim()
         If IsBlank(raw) Then
            Format = pValue
            Exit Function
         End If
         Dim hasProtocol As Boolean
         hasProtocol = IsMatch(raw, "^https?://", True)
         If hasProtocol Then
            Format = raw
            Exit Function
         End If
         Format = "https://" + raw
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
