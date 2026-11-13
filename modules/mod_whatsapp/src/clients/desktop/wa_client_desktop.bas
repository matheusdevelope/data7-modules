Imports IO
Imports Collections
Imports mod_winapi
Imports mod_clipboard_manager
Imports mod_wa_contracts
Imports mod_wa_capabilities
Imports mod_wa_message
Imports mod_wa_attachment
Imports mod_wa_send_result
Imports mod_wa_desktop_options

Namespace mod_wa_client_desktop

   Class WaClientDesktop
      Inherits WaClient

      Private _options As WaDesktopOptions
      Private _capabilities As WaCapabilities
      Private _ownsOptions As Boolean

      Sub New(pOptions As WaDesktopOptions, pOwnsOptions As Boolean = False)
         MyBase.New()
         If pOptions = NULL Then
            Throw New Exception("WaClientDesktop requer WaDesktopOptions")
         End If
         pOptions.Validate()
         me._options = pOptions
         me._ownsOptions = pOwnsOptions
         me._capabilities = WaCapabilities.LimitedSend()
      End Sub

      Overrides Function GetName() As String
         GetName = "Desktop"
      End Function

      Overrides Function GetCapabilities() As WaCapabilities
         GetCapabilities = me._capabilities
      End Function

      Overrides Function Online() As Boolean
         Online = me.FindWhatsApp() <> 0
      End Function

      Overrides Function SendMessage(pMessage As WaMessage) As WaSendResult
         Try
            me.DispatchDesktop(pMessage)
            SendMessage = WaSendResult.Ok(me.GetName(), pMessage.Recipient)
         Catch ex As Exception
            Return WaSendResult.Fail(me.GetName(), pMessage.Recipient, ex._GetMessage())
         End Try
      End Function

      Private Sub DispatchDesktop(pMessage As WaMessage)
         Dim _hwnd As Long = me.RequireWhatsApp()
         Dim _previous As Long = WinAPI.Window.GetForeground()
         Dim _text As String = me.ResolveFormatter(pMessage).FormatText(pMessage)
         Dim _sendTextFirst As Boolean = me.SendTextBeforeFiles(pMessage, _text)

         me.OpenChat(pMessage.Recipient, _text)
         me.WaitMs(me._options.OpenWaitMs)
         _hwnd = me.RequireWhatsApp()
         WinAPI.Window.Focus(_hwnd, False)

         If _sendTextFirst Then
            me.ConfirmSend(_hwnd)
         End If

         me.PasteFiles(pMessage, _hwnd)

         If me._options.AutoSend Then
            me.ConfirmSend(_hwnd)
            me.WaitMs(100)
            If me._options.RestoreFocus And _previous <> 0 Then
               WinAPI.Window.Focus(_previous, False)
            End If
         End If
      End Sub

      Private Function SendTextBeforeFiles(pMessage As WaMessage, pText As String) As Boolean
         If pText.Trim() = "" Then
            SendTextBeforeFiles = False
            Exit Function
         End If
         If Not Assigned(pMessage.Attachments) Then
            SendTextBeforeFiles = False
            Exit Function
         End If
         If pMessage.Attachments.Count() = 0 Then
            SendTextBeforeFiles = False
            Exit Function
         End If
         SendTextBeforeFiles = me.ResolveFormatter(pMessage).Layout.EffectiveModeName() = "SeparateBefore"
      End Function

      Private Function RequireWhatsApp() As Long
         Dim _hwnd As Long = me.FindWhatsApp()
         If _hwnd = 0 Then
            Throw New Exception("O WhatsApp não está aberto. Abra o aplicativo e tente novamente.")
         End If
         RequireWhatsApp = _hwnd
      End Function

      Private Function FindWhatsApp() As Long
         Dim _title As String = Trim(me._options.WindowTitle)
         Dim _hwnd As Long = WinAPI.Window.FindByTitle(_title)
         If _hwnd <> 0 And WinAPI.Window.IsVisible(_hwnd) Then
            FindWhatsApp = _hwnd
            Exit Function
         End If
         FindWhatsApp = WinAPI.Window.FindContains(_title)
      End Function

      Private Sub OpenChat(pPhone As String, pText As String)
         Dim _phone As String = me.OnlyDigits(pPhone)
         If _phone = "" Then
            Throw New Exception("Informe um destinatário válido para o WhatsApp Desktop.")
         End If
         Dim _uri As String = "whatsapp://send?phone=" + _phone
         If pText.Trim() <> "" Then
            _uri = _uri + "&text=" + me.EncodeUri(pText)
         End If
         me.ShellOpen(_uri)
         If pText.Trim() <> "" Then
            me.WaitMs(200)
            me.ShellOpen(_uri)
         End If
      End Sub

      Private Sub ShellOpen(pUri As String)
         Dim _result As Long = WinAPI.Execute(0, "open", pUri, "", "", SW_SHOW)
         If _result <= 32 Then
            Throw New Exception("Não foi possível abrir a conversa no WhatsApp Desktop.")
         End If
      End Sub

      Private Sub PasteFiles(pMessage As WaMessage, pHwnd As Long)
         If Not Assigned(pMessage.Attachments) Then
            Exit Sub
         End If
         If pMessage.Attachments.Count() = 0 Then
            Exit Sub
         End If
         Dim _paths As New StringList()
         me.CollectPaths(pMessage, _paths)
         If _paths.Count = 0 Then
            _paths.Free()
            Exit Sub
         End If
         If Not ClipboardManager.SetFiles(_paths) Then
            _paths.Free()
            Throw New Exception("Não foi possível copiar os arquivos para a área de transferência.")
         End If
         _paths.Free()
         WinAPI.Window.Focus(pHwnd, False)
         me.WaitMs(me._options.PasteWaitMs)
         WinAPI.SendKeys("^v", True)
         me.WaitMs(me._options.PasteWaitMs)
      End Sub

      Private Sub CollectPaths(pMessage As WaMessage, pPaths As StringList)
         Dim _count As Integer = pMessage.Attachments.Count()
         Dim _reversed As Boolean = me.ResolveFormatter(pMessage).Layout.AttachmentsReversed
         Dim i As Integer
         For i = 0 To _count - 1
            Dim _idx As Integer = i
            If _reversed Then
               _idx = _count - 1 - i
            End If
            Dim _att As WaAttachment = pMessage.Attachments.Take(_idx)
            If _att.Path.Trim() <> "" And File.Exists(_att.Path) Then
               pPaths.Add(_att.Path)
            End If
         Next
      End Sub

      Private Sub ConfirmSend(pHwnd As Long)
         If Not me._options.AutoSend Then
            Exit Sub
         End If
         WinAPI.Window.Focus(pHwnd, False)
         Dim _rect As TRect = WinAPI.Window.GetRect(pHwnd)
         WinAPI.Mouse.LeftClick(_rect.Right - 400, _rect.Bottom - 50)
         me.WaitMs(200)
         WinAPI.SendKeys("{ENTER}", True)
         me.WaitMs(me._options.EnterWaitMs)
      End Sub

      Private Sub WaitMs(pMs As Integer)
         If pMs > 0 Then
            Sleep(pMs)
         End If
      End Sub

      Private Function OnlyDigits(pText As String) As String
         Dim _out As String = ""
         Dim i As Integer
         For i = 1 To Len(pText)
            Dim _ch As String = Mid(pText, i, 1)
            If _ch >= "0" And _ch <= "9" Then
               _out = _out + _ch
            End If
         Next
         OnlyDigits = _out
      End Function

      PRivate Function EncodeUri(pUrl As String) As String
         Dim JSEngine As Variant = CreateObject("MSScriptControl.ScriptControl")
         JSEngine.Language = "JScript"
         EncodeUri = JSEngine.Run("encodeURIComponent", pUrl)
         JSEngine = Unassigned
      End Function

      ' Private Function EncodeUri(pText As String) As String
      '    Dim _out As String = ""
      '    Dim i As Integer
      '    For i = 1 To Len(pText)
      '       Dim _ch As String = Mid(pText, i, 1)
      '       Dim _code As Integer = Asc(_ch)
      '       If me.IsUnreserved(_code) Then
      '          _out = _out + _ch
      '       ElseIf _code < 128 Then
      '          _out = _out + me.PercentByte(_code)
      '       ElseIf _code < 2048 Then
      '          _out = _out + me.PercentByte(192 + Int(_code / 64))
      '          _out = _out + me.PercentByte(128 + (_code Mod 64))
      '       Else
      '          _out = _out + me.PercentByte(224 + Int(_code / 4096))
      '          _out = _out + me.PercentByte(128 + (Int(_code / 64) Mod 64))
      '          _out = _out + me.PercentByte(128 + (_code Mod 64))
      '       End If
      '    Next
      '    EncodeUri = _out
      ' End Function

      ' Private Function IsUnreserved(pCode As Integer) As Boolean
      '    If pCode >= 65 And pCode <= 90 Then
      '       IsUnreserved = True
      '    ElseIf pCode >= 97 And pCode <= 122 Then
      '       IsUnreserved = True
      '    ElseIf pCode >= 48 And pCode <= 57 Then
      '       IsUnreserved = True
      '    ElseIf pCode = 45 Or pCode = 46 Or pCode = 95 Or pCode = 126 Then
      '       IsUnreserved = True
      '    Else
      '       IsUnreserved = False
      '    End If
      ' End Function

      ' Private Function PercentByte(pValue As Integer) As String
      '    Dim _hex As String = Hex(pValue)
      '    If Len(_hex) = 1 Then
      '       _hex = "0" + _hex
      '    End If
      '    PercentByte = "%" + _hex
      ' End Function

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
