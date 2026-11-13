Imports Collections
Imports mod_wa_compose
Imports mod_wa_client_evolution_go
Imports mod_wa_evolution_go_options
Imports mod_wa_desktop_options
Imports mod_wa_client_desktop
Imports mod_pix_app_share

Namespace mod_pix_app_whatsapp_sharer

   Delegate Sub DelegateOnBeforeShare(ByRef pCompose As WaCompose, ByRef pCanShare As Boolean)

   Class PixAppWhatsappSharer
      Inherits PixAppSharer

      Private _icon As String = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAABrElEQVR4nN2VvS+DURTGf9oyWMQksZL4I0wiURMq9I8oq1EkJL4VgwSbj2gsgs0/IAbSjfqaBCUxKGFDTvI0edPet31bW5/k5k3OPec+957znPNCraMBiAN7QAb41MrIFpdPVRgE7oFf4BlIAUtaKdls7w6IVXJwCJhX8DnQI5vLLwpcyHfOx68ICwrYACIB/MPArGLsWzYt5pikciwrdsDPoUE5P9etDPXAKNAZgCCsdN0qrghx3cBynsekbDdAXQCSqPyHXJsmu6eCQqUVYKsrAIHFZoFd1+a15OfFiQ7/ADoIhn31SRFywGKBbVgEpwFThPrEzirCN7DisB+IZPy/BKagQ4e9CbgCfoA1oBFolWImgOagKdoGHn2aq8XTsS+eEWLrzFHkHRdBtwJiJfpkDHjzHG5ryuPTW0qmxv4OrFMaEUl2TLr32tPqGWejtYk9QXVYVZ36/BxGRGBElSDsGXbTpRyPNUcQSULpivkUPqScp3XzmXLj2or3IJJ8AXP62gg5Up8kJcWsZ071B3nqJvCql1i62nUjU9eW/lxfGhuXkqKpxVnQ2sEfiiB6ID49oaMAAAAASUVORK5CYII="

      OnBeforeShare As DelegateOnBeforeShare

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function Hint() As String
         Hint = "Enviar Pix&Cola pelo WhatsApp (Ctrl + W)"
      End Function

      Overrides Function IconBase64() As String
         IconBase64 = me._icon
      End Function

      Overrides Function ShortcutKey() As Integer
         ShortcutKey = 87
      End Function

      Overrides Sub Share(pRequest As PixAppShareRequest)
         Dim compose As WaCompose = me.CreateCompose()
         compose.Message().Content = me.BuildMessage(pRequest)

         Dim canShare As Boolean = True
         If me.OnBeforeShare <> Null Then
            me.OnBeforeShare(compose, canShare)
         End If

         If canShare Then
            compose.Show()
         End If
         compose.Free()
      End Sub

      Private Function CreateCompose() As WaCompose
         Dim compose As New WaCompose()
         Dim evo As WaClientEvolutionGo = me.TryCreateEvolutionGo()
         If Assigned(evo) Then
            compose.RegisterClient(evo, "Evolution GO", evo.GetName(), True)
            compose.Options.DefaultClient = evo.GetName()
         End If

         Dim desktop As New WaClientDesktop(New WaDesktopOptions(), True)
         compose.RegisterClient(desktop, "WhatsApp Desktop", desktop.GetName(), True)
         If Trim(compose.Options.DefaultClient) = "" Then
            compose.Options.DefaultClient = desktop.GetName()
         End If

         compose.Options.Title = "PIX via WhatsApp"
         compose.Options.CanChangeClient = True
         CreateCompose = compose
      End Function

      Private Function BuildMessage(pRequest As PixAppShareRequest) As String
         Dim text As New StringList()
         text.Text = Trim(Data7.Parametro("Customizado_Projeto_Pix_ConteudoMensagemWhatsapp"))
         If text.Text.Trim() = "" Then
            With text
               .Add("Pagamento via PIX")
               .Add("")
               .Add("")
               .Add("Segue abaixo os dados para pagamento do Pix no valor de:")
               .Add("*R$ @Valor*")
               .Add("*Obs:* @SolicitacaoPagador")
               .Add("")
               .Add("Copie o código abaixo e cole no seu aplicativo de banco.")
               .Add("")
               .Add("*Pix Copia e Cola:*")
               .Add("@PixCopiaECola")
            End With
         End If
         BuildMessage = pRequest.ApplyTokens(text.Text)
         text.Free()
      End Function

      Private Function TryCreateEvolutionGo() As WaClientEvolutionGo
         Dim host As String = Trim(Data7.Parametro("WHATSAPP_HOSTDATA7MANAGER"))
         Dim token As String = Trim(Data7.Parametro("WHATSAPP_TOKENDATA7MANAGER"))
         If (host = "") Or (token = "") Then
            TryCreateEvolutionGo = Null
            Exit Function
         End If
         Try
            Dim options As WaEvolutionGoOptions = WaEvolutionGoOptions.FromCombinedToken(host, token, "")
            TryCreateEvolutionGo = New WaClientEvolutionGo(options, True)
         Catch ex As Exception
            Return Null
         End Try
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace

