Imports Forms
Imports mod_winapi
Imports google_auth_consent
Imports google_auth_code
Imports google_auth_errors

Namespace google_auth_consent_manual

   Class GoogleConsentManual
      Inherits GoogleConsentHandler

      Private _captured As String
      Private _host As Forms.Form
      Private _codeBox As Forms.TextBox
      Private _cancelled As Boolean

      Sub New()
         MyBase.New()
         me._cancelled = False
      End Sub

      Overrides Function RequestCode(pAuthUrl As String) As GoogleAuthCode
         me._cancelled = False
         WinAPI.Execute(pAuthUrl, "", False, SW_SHOWNORMAL)
         me._captured = ""
         me.BuildPrompt()
         me._host.Show()
         While me._host.Visible
            If me._cancelled Then
               Exit While
            End If
            Forms.ProcessMessages()
            Sleep(50)
         End While
         Dim pasted As String = Trim(me._captured)
         If Assigned(me._host) Then
            me._host.Free()
            me._host = Null
         End If
         me._codeBox = Null
         If me._cancelled Then
            Throw New Exception(GoogleAuthErrors.ConsentCancelled())
         End If
         If pasted = "" Then
            Throw New Exception("Authorization code was not provided.")
         End If
         RequestCode = GoogleAuthCode.ExtractFromUrl(pasted)
      End Function

      Overrides Sub Cancel()
         me._cancelled = True
         If Assigned(me._host) Then
            me._host.Close()
         End If
      End Sub

      Overrides Function WasCancelled() As Boolean
         WasCancelled = me._cancelled
      End Function

      Private Sub BuildPrompt()
         me._host = New Forms.Form()
         me._host.Caption = "Autorização Google"
         me._host.Width = 520
         me._host.Height = 220
         me._host.Font.Size = 10

         Dim hint As Forms.StaticText = New Forms.StaticText(me._host)
         hint.Left = 12
         hint.Top = 12
         hint.Width = 480
         hint.Height = 60
         hint.Text = "Faça login no navegador, conceda as permissões e cole abaixo a URL completa de redirecionamento ou o código de autorização."

         me._codeBox = New Forms.TextBox(me._host)
         me._codeBox.Left = 12
         me._codeBox.Top = 80
         me._codeBox.Width = 480
         me._codeBox.Height = 28

         Dim okBtn As Forms.CommandButton = New Forms.CommandButton(me._host)
         okBtn.Left = 12
         okBtn.Top = 120
         okBtn.Width = 480
         okBtn.Height = 28
         okBtn.Text = "Continuar"
         okBtn.OnClick = me.OnContinue
      End Sub

      Private Sub OnContinue(pSender As TObject)
         me._captured = me._codeBox.Text
         me._host.Close()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
