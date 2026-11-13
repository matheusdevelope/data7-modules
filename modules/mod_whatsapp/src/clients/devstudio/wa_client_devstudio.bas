Imports Collections
Imports mod_wa_contracts
Imports mod_wa_capabilities
Imports mod_wa_message
Imports mod_wa_send_result
Imports mod_wa_devstudio_options

Namespace mod_wa_client_devstudio

   Class WaClientDevStudio
      Inherits WaClient

      Private _options As WaDevStudioOptions
      Private _capabilities As WaCapabilities
      Private _ownsOptions As Boolean

      Sub New()
         MyBase.New()
         me._options = New WaDevStudioOptions()
         me._ownsOptions = True
         me._capabilities = WaCapabilities.Deprecated()
      End Sub

      Sub New(pOptions As WaDevStudioOptions, pOwnsOptions As Boolean = False)
         MyBase.New()
         If pOptions = NULL Then
            Throw New Exception("WaClientDevStudio requer WaDevStudioOptions")
         End If
         pOptions.Validate()
         me._options = pOptions
         me._ownsOptions = pOwnsOptions
         me._capabilities = WaCapabilities.Deprecated()
      End Sub

      Overrides Function GetName() As String
         GetName = "DevStudio"
      End Function

      Overrides Function GetCapabilities() As WaCapabilities
         GetCapabilities = me._capabilities
      End Function

      Overrides Function SendMessage(pMessage As WaMessage) As WaSendResult
         Dim _send As New WhatsappSend()
         Dim _native As New WhatsappMessage()
         Dim _result As WaSendResult

         Try
            _native.Recipient = pMessage.Recipient
            _native.Subject = pMessage.Subject
            _native.Content = pMessage.Content
            _native.Signature = pMessage.Signature

            Dim i As Integer
            For i = 0 To pMessage.Attachments.Count() - 1
               _native.Attachments.Add(pMessage.Attachments.Take(i).Path)
            Next

            Dim _ok As Boolean = _send.SendMessage(_native)
            If _ok Then
               _result = WaSendResult.Ok(me.GetName(), pMessage.Recipient)
            Else
               _result = WaSendResult.Fail(me.GetName(), pMessage.Recipient, "WhatsappSend.SendMessage retornou False")
            End If
         Catch ex As Exception
            _native.Free()
            _send.Free()
            Return WaSendResult.Fail(me.GetName(), pMessage.Recipient, ex._GetMessage())
         End Try

         _native.Free()
         _send.Free()
         SendMessage = _result
      End Function

      Overrides Sub Dispose()
         If Assigned(me._capabilities) Then
            me._capabilities.Free()
            me._capabilities = NULL
         End If
         If me._ownsOptions And Assigned(me._options) Then
            me._options.Free()
         End If
         me._options = NULL
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
