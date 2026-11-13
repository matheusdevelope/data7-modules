Imports mod_tobject
Imports mod_wa_message

Namespace mod_wa_validators

   Class WaPhoneValidator
      Inherits TTObject

      RequireCountryCode55 As Boolean

      Sub New(pRequireCountryCode55 As Boolean = True)
         MyBase.New()
         me.RequireCountryCode55 = pRequireCountryCode55
      End Sub

      Function Normalize(pPhone As String) As String
         Normalize = pPhone.Trim().Replace(" ", "").Replace("-", "").Replace("(", "").Replace(")", "")
      End Function

      Sub Validate(pPhone As String)
         Dim _phone As String = me.Normalize(pPhone)
         If _phone = "" Then
            Throw New Exception("Número de telefone é obrigatório")
         End If
         If me.RequireCountryCode55 Then
            If Not _phone.StartsWith("55") Then
               Throw New Exception("O número de telefone deve iniciar com 55")
            End If
            If _phone.Length < 12 Or _phone.Length > 13 Then
               Throw New Exception("O número de telefone deve ter 12 ou 13 dígitos")
            End If
         End If
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   ' Regras de domínio do envio — independentes de qualquer client/provider.
   Class WaMessageValidator
      Inherits TTObject

      Private _phone As WaPhoneValidator
      Private _validatePhoneFormat As Boolean

      Sub New(pRequireCountryCode55 As Boolean = True, pValidatePhoneFormat As Boolean = True)
         MyBase.New()
         me._validatePhoneFormat = pValidatePhoneFormat
         me._phone = New WaPhoneValidator(pRequireCountryCode55)
      End Sub

      Sub Validate(pMessage As WaMessage)
         If pMessage = NULL Then
            Throw New Exception("Mensagem é obrigatória")
         End If
         If pMessage.Recipient.Trim() = "" Then
            Throw New Exception("Destinatário (Recipient) é obrigatório")
         End If
         If me._validatePhoneFormat Then
            me._phone.Validate(pMessage.Recipient)
         End If
         Dim _hasText As Boolean = pMessage.HasText()
         Dim _hasMedia As Boolean = pMessage.Attachments.Count() > 0
         If Not _hasText And Not _hasMedia Then
            Throw New Exception("Mensagem deve conter texto e/ou anexos")
         End If
      End Sub

      Function NormalizeRecipient(pMessage As WaMessage) As String
         NormalizeRecipient = me._phone.Normalize(pMessage.Recipient)
      End Function

      Overrides Sub Dispose()
         If Assigned(me._phone) Then
            me._phone.Free()
            me._phone = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
