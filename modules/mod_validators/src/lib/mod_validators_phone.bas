Imports mod_strings

Namespace mod_validators

   Class TPhone

      Sub New()
         MyBase.New()
      End Sub

      Shared Function IsValid(pValue As String) As Boolean
         Dim n As String
         n = OnlyNumbers(pValue)
         Dim nLen As Integer = Len(n)
         IsValid = (nLen = 10 Or nLen = 11 Or nLen = 12 Or nLen = 13)
      End Function

      Shared Function Format(pPhone As String, DefaultDDD As String = "", DefaultCodPais As String = "") As String
         pPhone = OnlyNumbers(pPhone)
         DefaultDDD = OnlyNumbers(DefaultDDD)
         DefaultCodPais = OnlyNumbers(DefaultCodPais)
         pPhone = pPhone.Left(13)
         Dim mask As String = "+$1 ($2) $3-$4"
         Dim pattern As String = "(\d{2})(\d{2})(\d{4,5})(\d{4})"
         If Len(pPhone) = 11 Or Len(pPhone) = 10 Then
            pPhone = DefaultCodPais.Left(2) + pPhone
         End If
         If Len(pPhone) = 9 Or Len(pPhone) = 8 Then
            pPhone = DefaultCodPais.Left(2) + DefaultDDD.Left(2) + pPhone
         End If
         If Len(pPhone) = 11 Or Len(pPhone) = 10 Then
            pattern = "(\d{2})(\d{4,5})(\d{4})"
            mask = "($1) $2-$3"
         End If
         If Len(pPhone) = 9 Or Len(pPhone) = 8 Then
            pattern = "(\d{4,5})(\d{4})"
            mask = "$1-$2"
         End If
         Dim masked As String = pPhone
         If IsMatch(pPhone, pattern, False) Then
            masked = ReplacePattern(pPhone, pattern, mask, False)
         End If
         Format = masked
      End Function

      Shared Function Mask(pPhone As String) As String
         Dim n As String
         n = OnlyNumbers(pPhone)
         If n.Length < 11 Then
            Mask = "(99) 9999-9999"
         Else
            Mask = "(99) 99999-9999"
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
