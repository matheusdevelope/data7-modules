Imports Collections
Imports mod_strings

Namespace mod_validators

   Class TEmail

      Sub New()
         MyBase.New()
      End Sub

      Shared Function IsValid(pValue As String) As Boolean
         If IsBlank(pValue) Then
            IsValid = False
            Exit Function
         End If
         Dim parts As StringList = SplitToList(pValue, ";")
         Dim found As Boolean = False
         Dim i As Integer
         Dim n As Integer = parts.Count
         For i = 0 To n - 1
            Dim piece As String = parts.Strings(i).Trim()
            If Not IsBlank(piece) Then
               found = True
               If Not IsMatch(piece, "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$", True) Then
                  parts.Free()
                  IsValid = False
                  Exit Function
               End If
            End If
         Next
         parts.Free()
         IsValid = found
      End Function

      Shared Function Format(pValue As String) As String
         If IsBlank(pValue) Then
            Format = pValue
            Exit Function
         End If
         Dim result As String
         result = ToLowerCase(pValue.Trim())
         Format = result
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
