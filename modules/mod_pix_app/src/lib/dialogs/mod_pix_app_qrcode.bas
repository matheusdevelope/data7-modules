Imports mod_pix_http
Imports mod_pix_runtime
Imports mod_pix_cobranca_completa
Imports mod_pix_config
Imports mod_pix_app_share

Namespace mod_pix_app_qrcode

   Class PixAppQrCode

      Private _timer As Forms.Timer
      Private _service As PixService
      Private _cobranca As PixCobrancaCompleta
      Private _codMovimentoPix As Integer
      Private _sharer As PixAppSharer

      Private _form As PixForm

      Private _iconOk As String = "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"
      Private _iconCancel As String = "iVBORw0KGgoAAAANSUhEUgAAAPAAAADwCAYAAAA+VemSAAAACXBIWXMAAAsTAAALEwEAmpwYAAARlUlEQVR4nO2dDaykZXXHHxZFKlpQFCpiqwVtggm7OvecubtdO8x55q7bCBFiNzFNrGmpbSC0S3dtSUt1qdoKkipU08QI2mpra9u0BVyJK6EtClQES0uDUIH6VVJkuXvvnGfutezGt3nm7k1WlL0fOzPn+fj/kn+yIbuXuec5v3nfeef5cA4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFbBvKdTB912q+/bb1Gh3erpWvX8CfV8s3q+M3h+SD39d/A0G6PCIXhuYpb+fPi/D/9O/Lt8p3q6ST19fOln0a74s4NMv35u2/SLMSgArAOV9unqp3pLkkZB6b4gNL8s48QiNK+e7j38GnYNX9PM5tMwqAAcptmx43jt0msHvv1r6umTKvTYxEVdY1T4cRW+JQhd0e+1tzY7zjkBAwqqYd7Ta1TaO1X41iNvc3NN/B3U8+fU02/M99qvtq4vAKO/ygp3g6ePqPCj1sJNII8ETx9W3z6v2eM2oJ1AdsTGjbeXQfj6eMuZgFQ2Ed4//Gjgp3qQGSTPwrapVwThPSr8TXN5Eot6+kYQfvegw2dajxMAP3CLPBC+UIU+q0KHrEVJPbFGsVYDz2+OtUMrAROe6HReEJ8eB+GHraXINcPvpIWuONDZeAraGEyEQW/LGer56uD5gLUA5WQ48eT94Y2tl6GNwVjod1ovieKqpwX7hi8zKvx/KvRRiAxGOoVRPV1lMhuq0gy/Hx8+wW+fjlYG66LZfvbzgvDvQFxDmYXnQpffidleYE0MZOqCpQkJ9lcjJNaAvq7CO9DG4KjMd6d+JgjfBmlSfeOgfZiuCX6IptN5zuH5ydnPTS496mkxPpPAbTUYEmZoU1w2Z92YyFprQP8+kBajjau+6vJ7MXsq91ld/J44ltb9BCbIYqf9yiD8JesGREYksucv47NxJQTPvxI8KeQp7Q2E+sHT2637C4yJptM5UT3dYN9oyDhroJ4+2UxP/xhEKmyZX7zNgjx1vHmo8FcXZ/hV1n0HRoBKeyYuLLduKmTiNXhSe+QhUcYE4YvV89OQp96n1P0eXWLdh2CNNM4dN1yAkEATIQnUQPh6bOmT0yIET582bxokrRoI/R0ebiVOM3PuSUH4C+bNgqRZA+F/fnLLlhda9yn4EcRtWQ4fMWLfKEiyNVDhe3B0TGLEAcHXRPZy5PQ1U3/7ppda9y04vNVNEH7AuimQzGog/EDsHUhkyGyvdTJWEiUgQ6ZRT/fPbd36IkhsQHN+6/nB0x3WTYDkXQMVujtuEQyJJylvp3Ni8HS79eAjhdRA+Lb49SMknoS8zh0XhP/CfNCRsmog/JnYW5B4zKina8wHGymyBur5fRB4jAShX7UeZKTsGvQxd3p8q4rU00HrAUbKroF6flq7LGNq4zpZ6LV+Mi4Psx5cpJIaCD2F9cSj3ElD+Cvmg4pUN1urwc4ex44K3Wg9mEidNVChPx9BC9e+AZ39QCIV16DLb7P2IEvmuq2zlnYaTGAQkYprQIota9e16TrdbT94CGrAwyWITav13PFcqgoknpiAxsGbR1I9ILzH2ossGPgpwnEnCTQs0hxZg+EcBJl+vbUfOZxX9FU0DwRKdflhg1vpZycIXWk9SAhqEI5eg9+e4DUtH+Y9vSae/QqBIFDKPaCeFuY602db+5IccU2m9eAgqEFYjcTCt1r7khQDoYsgD+TJqgd6/CZrb5Kg2XHOCUHov8wHBEEN/FpqQF/HLh5LD66ugDyQJ8ceUE+7XM0sbQlL89YDgaAGYX01OFD1JvEq9AHIA3ly7gH19IeuRuLO+HGiuPUAIKhBOBaBhYPObD7N1UbwdB3kgTwl9IB6utbVxECmX45JG/aNh/BoBBYeqLRPd7VQ69awCxe/tQm9afPXMbb0ppd+R+vX4Sefarakjeezxqd31gWfdBZ3vqP5/sJCc/D2fU3Yttn89Yw8venm4Oc/2zTfW2wW33mp/evxkw7NVnFEiwpfbl9sG3mXKU7iZXmXqVRiFb7MlUyzY8fxKvyodaEt5S1O4mfKW7HEKvRY7HFXKgPhC62LnIK8xUj8bPJWLPFApi5wpaKe9loXOBV5s5d4JXkrlVg93+xKZNDhM2vZKme18mYr8WrlrVBi9XQwfk3qSkM9XWVd3BTlzU7itcpbocRB6EpXEs0et0GFv2le2ETlzUbi9cpbmcQaH2aVdNZwv0s/Z13U1OVNXuJjlbcyiRc8bXalEDx9xLqgOcibrMSjkrcqielDrqDb58ftC5qHvMlJPGp5K5FYhR+Pve9yJx6WbF3M3ORNRuJxyVuJxH3hN7jcKfX2edzymks8bnmrkJiuc7kTPD9iX8jRJq64aRbHL+8yB/ftnewqpijvvr0T+/1iLQtdxfSQy32z9gSKmO/VyeJKbPW7zZS5zHKu2zrL5YpKe6d1AYtr9HFKDHmbUde076cudbkSd7A3Fw0SQ15v1yMqfIvL9aTBKjatK+FKjCtvM74eIY0uuBzP+TWXCxJDXp9Af/ip17ncqG7njRyvxLjyNpPojSx36gie/tZcKkgMeX0CfeHpr1xuqKfv2BcOEv/IGuDK20yyN1T4Wy4nQod+wlwkSAx5fUIS53R6Q+jyNuuCmSfFz8S48jZmAndZrL1cNSq021ygFJKSxJC3seyF+FDX5YIK/5m5PKkkBYkhb2PdByp0o8sF9XSfdcGSiqXEkLdJ5Ap8j8sFHNqdjsQTXVVU+MKEcEyhWZcD855OtS9WojGQeJJAXj7q+B/obDzFpc6g226Zi5JyCpUY8vLKYz9Dm1zq9IV/wVyS1FOYxJCXVzXuA6GLXOrgK6S6JIa8vOo3bvX8Wy511NO15le4XJK5xJCX1zTe6vlqlzrq+RPmYuSUTCWGvLzmsVZPN7jUiaezmUuRWzKTGPLyusZZPf2DSx0VvstciByTicSQl9c/xkJfdKkTt9I0lyHXJC4x5OVjG1+hB13qVLsOuHCJIS8f89jGEzpd6gTh75pLkHsSkxjy8ojGlv7XpU4QnjMXoIQkIjHk5brmQ6unBfPmLyXGEkNeHul4qvDApY4KHTJv/OIk3jt5ef/pC1hV5EctMB1yqQOBxyDwPguBEzmfuKBoFgLjFrqsW2hI3FR1C42HWGXIC4m5zodY+BqpHHmXwZWY6/kaCRM5ypJ3GUjMlUzkwFTK4uRdBhJzDVMp+c7Rf3aoIInLuwwk5mMYZ7rDpY56uslchtySibzLQGJe1zir5793qaOePm4uRE7JTN5lIDGvR+CPudRRoQ+YS5FLMpV3GUjMaxNY+P0udbCpXR3yLgOJuaxN7fq+/RbzK1vqKUTeZSAxr2rcB8IXutTBxu51ybsMJOaVJe7yRpc6c9umX2x+hUs1hcq7DCTmo47/bK91sssBzIdOQ964JNDkcDMsgGiynAe9jHq61/xql1Isj/hM4XxipFHPX3a5gM3dE5HX+jVA4iar74CXUU+78K6biLyQuEmhF9XTb7pcUD/Vsy6YeVKS1/o14UrcqHDX5UJ/+6aXmgsEeSGxTyfRCZcT6unb1kUzSYpX3lReY6VXYs1hHfAzCcKfsS7cxJODvNavtUaJhf/S5Ub80G5euEkmJ3mtX3NlEvf91KUuN6qaUpmjvNavvSaJuxlMoXwmTafznOBJzYs37uQsr/XvUIPEQvPNjh3HuxxRz58zL+A4U4K81r9L4RKrp5tcrhT9Obgkea1/p4Il7vfoEpcr8732q60LWFSjj1Ne69+tUIkX/dRPu5wJnh+xLuKos3DxW5tmcWFyDb5v71CsYs9jWlwY1tR6XMOoI/w1lzvB04fNCzmGLO58R/P9waDcIz4ndSX+3mKzuPsS8/EMYwl9yOWO+vZ59oXMU2Lz83nHLXHR8nLTP6/1sy53mj1ugwr9j3Uxc5PYXN5xS1y4vOrp27H3XQkE4T+xLmhOEicj77gkLlzeECP8x64U+r32VvOCZiJxcvKOWuIa5PXcDM5rt10pDG+jPX3DuqipS5ysvKOSuBJ5VfjRxrnjXEkE4XdbFzZliZOX91glrkTeECP8e640Bh0+U4UOmRc3QYmzkXe9Elckr3o6OOhtOcOViHraa13g1CTOTt61SlyRvCH3uc8rMfD8ZusCpyRxtvKuVuLK5A3D41OmLnClEpdVlTi1cj0SZy/vShJXKK8KPZbt0sHVUvQKpVVKXIy8zyZxhfKGXHfeWCvNzLknBeH91sW2krg4eZ8pcaXyBqGnYm+7GogHHZsX3CDDFTeTXFU06fSmy1xV5FeOevoDVwvhja2XqacF66IjqEEYhbzCQWc2n+ZqIgh9EAJBoBJ6QD1d42qj32m9JHjqWxcfQQ3CMdWAtLqr7zLq+WoIBIFy7gEVfo+rlXlPp+IwcPsmRHi9V9/ZA52Np7iaUaHdaCBIlGMPaE5Hho6LZsc5JwThh60HA0ENwlpqIPy1ptV6rrU/SRDnj0IgCJRVD8jUz1t7kxTB0z7zQUFQA7+qW+e91r4kuQk8JndAoNTfRFV4MNdtnWXtS5IEz79rPUAIahCOKjDttvYk6RMN1dN9kAgSpdgD6ul+PLhagUGPpmrZegfJa6uc4KdeN5lLWebElR3WA4agBuEHakDvsvYir1tp4bsgESRKogeEv1T8ThujJh7LGE83Nx88pO4aCM8tdtqvtPYhS4Knt5sPIFJ1DbRHv2jtQdao549ZDyJSaQ2E/9S6/7On2X7281T4HvPBRKqqgXr619h71v1fBAvbpl4RhL9rPahIJTUQeiKeJGLd90WhPfJL38UlMMBIsTVQz0/HQ+mt+71IgvDF1gOMlF2DgfCvW/d50ajQH1kPMlJmDbSmrWGtiOeuBs+fsh5spLAaCP91cWf6pkrT6ZwYhG8zH3SkkBrQPjxxnrTE57eeHzz/i/3gIznXQIXveqLTecGk+xc45/Zv5x9X4a9YNwGSZw1U+N/mtm59EWSy3iBe+AHrZkAyq4HQf8RtjSFvAsR30ThzxrwpkCxqoJ7ui2/81n0LjmC21zo5Lvuybg4k8RoIfTH2CuRJ9MGWevq8eZMgidaAbscDqxw2isf3xAnIklz+Jn79aN2fYBXEL+TV01UJNA2SQg2Er8ckjQwJ3fYvx8np5g2EmNRAPR3E3ObM0S4LliJW+CYi9ARWFRXCQKZfrkJ3mzcVMqkr770L3c0/Zd13YITEua7xsxAkKvuNRIU+Gh9kQp5CCV1+G3a7LDDCc9iArhLi7VXwdId50yGjuurejQPHKtw8PgjvwTY9+b6R6HCLJXoXNl2vGJX2udj1Mkt574/naFn3D0jmKJf2zuBJrRsTWVHchSB0RRwzB8CRxM9RKnwrJErzjUQ97Y1H7qBrwVFRP9ULnv/TumGRwzUQfjh4Oh9tC1ZNPMhZPe0Kng9AJKs3E5qNH21wqDZYN09u2fLC+Jkrfs8IkScmrqrnq7HdDRgZcfuV2FQqPIDIY/qMG2srfL1K+3S0LhgLsbnU8/uC0FMQeUTyCu9X4ffqzObT0LZgcnOrPf9S8PwQRF7vFZceG37GnTn3JLQtMCHOAhrI1AXq+WYVOgSZV5DW00H1dFOsGWZQgeSWLQZPvx+vLBD5hz7fPhqErhz0tpxhPU4ArIh26bVxW59h41b6na56+k58KNXvtbdiSxuQJc0et6Ev/Ibg6bqlCQn2Yo05DwWhDw6l3eM2WNcfgJESpwL2/dSlKnxL8NRPQLhji9B8/Pzf79ElizP8KrQLqIb4ECfM0CYVvix4+rQKf8tcyBWy9BqHr/Wy0OWNeBAFwBHEIz+0R16FL1dPNywd3kazNtMY+Z6l19DeGTcHxHEkAKyTA52Np8Sr9UDoosNyX6NCN6rQP8bjQoLQg0tPenn/kvBHLo2Mf6bZwxMm4tPgB+O/if92+DOGP4svjz87/j9w9AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwK2S/weS70IcheK57AAAAABJRU5ErkJggg=="
      Private _iconExpired As String = "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"
      Private _iconPrint As String = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAwklEQVR4nO2VQQrCMBBFn/Qc6rqn0Y0eQ+mqO8lSEG/RW2TbtVfRG0QCUwmh0U6j2EU//MWkk/9KQ6YwK0NO6VGAFjh/cJsDMAP6zGQAa+AI1GK/yQZ1ylZ6u/oArPrCHyMO1iV8jyGVPCjJVylZVeo7LoFdJsTF5xcC9sDtl4BvyA0B1EqrATmjwsWAkywW75oSil+ukNpnvrSVxSa6aEYB6PY1Um/CpgVw7blsRgHo7DMukvn/YWcVs2h6P5xZeD0BTIqL+Ej9EB8AAAAASUVORK5CYII="
      Private _iconCopy As String = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAA60lEQVR4nO2VMQ7CMAxFH0vFFToDV4ALIDgJPQESIBg6QSWuQbkI9BJ0hRVWulAUySxVRZwqsMCXPCRy/JLYceDLGgFTYKa0CAi1wfdA2cBuQN8WfCzOcyBwOHEHyIGjzXEhAJfgL22AAotiATRRrFnrA1DKSbK6nPgAJMBWcnKtVpfPK+rJePIpQEvGZv4P+KUrimTS9BZXpcDFBgilK+byWBKlpcADWNsAyPM+AHeHVn2W4IEGUJXKqUZqQFE5ulZtAZgv4K1MVzwBXYfg5qqWAhjanAeS+Cbf6E67I1Ndpitqq2ql2blXPQHyLocf4AJJBwAAAABJRU5ErkJggg=="

      Private _path_qrcode As String
      Private _path_icon_ok As String
      Private _path_icon_cancel As String
      Private _path_icon_expired As String
      Private _path_icon_print As String
      Private _path_icon_copy As String

      Private _path_image As String
      Private _message As String
      Private _message_to_show As String

      Private _pressingCTRL As Boolean

      Size As Integer = 233
      DelayOnClose As Integer = 500
      IntervalMonitor As Integer = 3000
      ShowMessageOnShow As Boolean = False
      CancelOnExpired As Boolean = True
      CancelOnExit As Boolean = True
      SaveMovimentoPixOnExit As Boolean = True

      Property Path As String
         Get
            Return me._path_qrcode
         End Get
      End Property

      Property Sharer As PixAppSharer
         Get
            Sharer = me._sharer
         End Get
      End Property

      Sub New(pService As PixService, pTitle As String = "Pagamento com Pix", pSharer As PixAppSharer = Null)
         MyBase.New()
         me._service = pService
         me._sharer = pSharer

         me._form = New PixForm(pTitle, me.Size)
         me._form.OnCanShow = me._handleFormOnCanShow
         me._form.OnShow = me._handleFormOnShow
         me._form.OnCanClose = me._handleFormOnCanClose
         me._form.OnClose = me._handleFormOnClose
         me._form.OnKeyDown = me._handleFormOnKeyDown
         me._form.OnKeyUp = me._handleFormOnKeyUp

         me._timer = New Forms.Timer(Null)
         me._timer.Enabled = False
         me._timer.Interval = me.IntervalMonitor
         me._timer.OnTimer = me._handleOnTimer

         me._loadIcons()
         me._bindActions()
      End Sub

      Private Sub _bindActions()
         With me._form
            .Btn1.OnClick = me._handleOnPrint
            .Btn1.LoadFromFile(me._path_icon_print)
            .Btn1.Hint = "Imprimir QR Code para pagamento Pix (Ctrl + P)"
            .Btn2.OnClick = me._handleOnCopy
            .Btn2.LoadFromFile(me._path_icon_copy)
            .Btn2.Hint = "Copiar a URL Pix para a área de transferência (Ctrl + C)"
         End With

         If Assigned(me._sharer) Then
            me._form.Btn3.OnClick = me._handleOnShare
            me._form.Btn3.LoadFromBase64(me._sharer.IconBase64())
            me._form.Btn3.Hint = me._sharer.Hint()
            me._form.LayoutActionButtons(True)
         Else
            me._form.LayoutActionButtons(False)
         End If
      End Sub

      Function Show(pCobranca As PixCobrancaCompleta) As PixCobrancaCompleta
         me._codMovimentoPix = pCobranca.CodMovimentoPix
         me._cobranca = pCobranca
         me._refreshCob()
         me._refreshForm()

         If me._shouldClose() Then
            If me._cobranca.IsDone() Then
               me._showMessage("Essa cobrança já foi recebida.")
            Else
               me._showMessage(me._message_to_show)
            End If
            me.Close()
         Else
            me._loadQrCode()
            me._refreshForm()
            me._form.Show("Pagamento com Pix - R$ " & me._cobranca.Valor.Original.ToString("0.00"))
         End If

         Show = me._cobranca
      End Function

      Sub Close()
         me._timer.Enabled = False
         If me.SaveMovimentoPixOnExit Then
            me._saveMovimentoPix()
         End If
         Sleep(me.DelayOnClose)
         If me.ShowMessageOnShow Then
            me._showMessage(me._message)
         End If
         me._form.Close()
      End Sub

      Private Sub _handleFormOnCanShow(pSender As TObject, ByRef pCan As Boolean)
      End Sub

      Private Sub _handleFormOnShow(pSender As TObject)
         me._refresh()
      End Sub

      Private Sub _handleFormOnCanClose(pSender As TObject, ByRef pCanClose As Boolean)
         me._timer.Enabled = False

         If me.CancelOnExpired And me._cobranca.IsActive() And me._cobranca.Calendario.IsExpired() Then
            me._cancelCob()
         ElseIf me.CancelOnExit And Not me._cobranca.IsDone() Then
            If Forms.MessageBox.Confirmation("Deseja cancelar a cobrança?") Then
               me._cancelCob()
            End If
         End If

         pCanClose = True
         me._timer.Enabled = me._form.Showing
      End Sub

      Private Sub _handleFormOnClose(pSender As TObject)
         me._timer.Enabled = False
      End Sub

      Private Sub _handleOnTimer(pSender As TObject)
         me._refresh()
      End Sub

      Private Sub _refresh()
         me._timer.Enabled = False
         me._refreshCob()
         me._refreshForm()

         If me._shouldClose() Then
            me._showMessage(me._message_to_show)
            me.Close()
         Else
            me._timer.Enabled = me._form.Showing
         End If
      End Sub

      Private Sub _refreshCob()
         me._cobranca = me._service.Cobranca.Consultar(me._cobranca.TxId)
      End Sub

      Private Sub _refreshForm()
         me._refreshStatusData()
         me._form.SetImage(me._path_image)
         me._form.SetLabel(me._message)
         Forms.ProcessMessages()
      End Sub

      Private Function _shouldClose() As Boolean
         _shouldClose = Not me._cobranca.IsActive() Or me._cobranca.Calendario.IsExpired()
      End Function

      Private Sub _cancelCob()
         If me._cobranca.IsActive() Then
            Sleep(me.DelayOnClose)
            me._form.SetLabel("Cancelando ...")
            me._cobranca = me._service.Cobranca.Cancelar(me._cobranca.TxId)
            me._refreshForm()
            If me._cobranca.IsCancelled() Then
               me._showMessage("Cobrança Cancelada!")
            End If
         End If
      End Sub

      Private Sub _saveMovimentoPix()
         me._service.Ledger().SaveCobranca(me._cobranca)
      End Sub

      Private Sub _refreshStatusData()
         Select Case True
            Case me._cobranca.IsDone()
               me._path_image = me._path_icon_ok
               me._message = "Cobrança Concluída!"
               me._message_to_show = ""

            Case me._cobranca.IsCancelled()
               me._path_image = me._path_icon_cancel
               me._message = "Cobrança Cancelada!"
               me._message_to_show = me._message

            Case me._cobranca.Calendario.IsExpired()
               me._path_image = me._path_icon_expired
               me._message = "Cobrança Expirada!"
               me._message_to_show = me._message

            Case me._cobranca.IsActive()
               me._path_image = me._path_qrcode
               If me.CancelOnExit Then
                  me._message = "ESC para Cancelar"
               Else
                  me._message = "ESC para Fechar"
               End If
               me._message_to_show = ""

            Case Else
               Throw New Exception("Status desconhecido: " & me._cobranca.Status.AsString)
         End Select
      End Sub

      Private Sub _loadQrCode()
         Dim _url As String = "https://api.qrserver.com/v1/create-qr-code/?size=" & CStr(me.Size) & "x" & CStr(me.Size) & "&data=" & me._cobranca.PixCopiaECola
         me._path_qrcode = me.TempPath("qrcode-pix.png")
         PixHttp.DownloadToFile(_url, me._path_qrcode)
      End Sub

      Private Sub _loadIcons()
         me._path_icon_ok = me.SaveTempImage(_iconOk, "icon-ok.png")
         me._path_icon_cancel = me.SaveTempImage(_iconCancel, "icon-cancel.png")
         me._path_icon_expired = me.SaveTempImage(_iconExpired, "icon-expired.png")
         me._path_icon_print = me.SaveTempImage(_iconPrint, "icon-print.png")
         me._path_icon_copy = me.SaveTempImage(_iconCopy, "icon-copy.png")
      End Sub

      Private Sub _handleOnPrint(pSender As TObject)
         me.Printe()
      End Sub

      Private Sub _handleOnCopy(pSender As TObject)
         me.CopyPix()
      End Sub

      Private Sub _handleOnShare(pSender As TObject)
         me.Share()
      End Sub

      Sub Printe()
         me._timer.Enabled = False
         Dim _reporter As New Data7.Report(Null)
         _reporter.CodRelatorio = CInt(Data7.Parametro("Recebimento_Pix_Api_CodRelatorio_QrCode"))
         _reporter.AddParam("CodEmpresa", CInt(me._service.Config().CodEmpresa))
         _reporter.AddParam("CodMovimentoPix", CInt(me._codMovimentoPix))
         If _reporter.Show() Then
            _reporter.Print()
         End If
         _reporter.Free()
         me._timer.Enabled = True
      End Sub

      Sub CopyPix()
         Dim _clip As New Clipboard()
         _clip.SetText(me._getContentCopy())
         _clip.Free()
      End Sub

      Sub Share()
         If Not Assigned(me._sharer) Then
            Exit Sub
         End If
         me._timer.Enabled = False
         Dim request As New PixAppShareRequest(me._cobranca, me.Path)
         me._sharer.Share(request)
         request.Free()
         me._timer.Enabled = me._form.Showing
      End Sub

      Function _getContentCopy() As String
         Dim _text As String = Trim(Data7.Parametro("Customizado_Projeto_Pix_ConteudoCopiaECola"))
         If _text.Trim() = "" Then
            _text = "@PixCopiaECola"
         End If
         _getContentCopy = PixAppShareRequest.ReplaceTokens(me._cobranca, _text)
      End Function

      Private Sub _handleFormOnKeyDown(ByRef pWord As Word, pShift As Forms.TShiftState)
         If pWord = 17 Then
            me._pressingCTRL = True
         End If
         Const K_C = 67
         Const K_P = 80
         If me._pressingCTRL And pWord = K_P Then
            me.Printe()
         End If
         If me._pressingCTRL And pWord = K_C Then
            me.CopyPix()
         End If
         If Assigned(me._sharer) Then
            If (me._sharer.ShortcutKey() > 0) And me._pressingCTRL And (pWord = me._sharer.ShortcutKey()) Then
               me.Share()
            End If
         End If
      End Sub

      Private Sub _handleFormOnKeyUp(ByRef pWord As Word, pShift As Forms.TShiftState)
         If pWord = 17 Then
            me._pressingCTRL = False
         End If
      End Sub

      Private Sub _showMessage(pMsg As String)
         If Len(pMsg) > 0 Then
            Forms.MessageBox.Show(pMsg)
         End If
      End Sub

      Private Function SaveTempImage(pBase64 As String, pName As String) As String
         Dim path As String = me.TempPath(pName)
         Base64ToFile(pBase64, path)
         SaveTempImage = path
      End Function

      Private Function TempPath(pName As String) As String
         TempPath =TPath.GetTempPath() & "\" & pName
      End Function

      Sub Free()
         If me._timer <> Null Then
            me._timer.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

   Delegate Sub DelegateOnShowClose(pSender As TObject)
   Delegate Sub DelegateCan(pSender As TObject, ByRef pCan As Boolean)
   Delegate Sub DelegateOnKeyDown(ByRef pKey As Word, pShift As Forms.TShiftState)

   Class PixForm

      Private _form As Forms.Form
      Private _image As Forms.Imagem
      Private _label As Forms.StaticText

      Private _sizeImage As Integer
      Private _icon_pix As String = "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"

      Btn1 As Forms.Imagem
      Btn2 As Forms.Imagem
      Btn3 As Forms.Imagem

      OnCanShow As DelegateCan
      OnShow As DelegateOnShowClose

      OnCanClose As DelegateCan
      OnClose As DelegateOnShowClose
      OnKeyDown As DelegateOnKeyDown
      OnKeyUp As DelegateOnKeyDown

      Property Showing As Boolean
         Get
            Return me._form.Showing
         End Get
      End Property

      Sub New(pTitle As String, pSizeImage As Integer = 233)
         MyBase.New()
         me._sizeImage = pSizeImage
         me._build(pTitle)
      End Sub

      Private Sub _build(pTitle As String)
         me._form = New Forms.Form()
         me._form.Caption = pTitle
         me._form.Width = 550
         me._form.Height = 509
         me._form.OnCanResize = me._handleOnCanResize
         me._form.OnShow = me._handleOnShow
         me._form.OnCloseQuery = me._handleOnCanClose
         me._form.OnClose = me._handleOnClose
         me._form.OnKeyDown = me._handleOnKeyDown
         me._form.OnKeyUp = me._handleOnKeyUp

         me._image = New Forms.Imagem(me._form)
         me._image.Top = 67
         me._image.Left = CInt((me._form.Width - me._sizeImage) / 2) - 4
         me._image.Height = me._sizeImage
         me._image.Width = me._sizeImage
         me._image.Stretch = True

         me._label = New Forms.StaticText(me._form)
         me._label.Font.Size = 18
         me._label.Top = 416
         me._label.Left = 16
         me._label.text = "ESC para Cancelar"

         With New Forms.Imagem(me._form)
            .Top = 373
            .Left = 325
            .LoadFromFile(me.SaveTempImage(me._icon_pix, "icon-pix.png"))
            .Stretch = True
            .Height = 72
            .Width = 200
         End With

         me.Btn1 = me.CreateButtonImage()
         me.Btn2 = me.CreateButtonImage()
         me.Btn3 = me.CreateButtonImage()
         me.LayoutActionButtons(True)

      End Sub

      Sub LayoutActionButtons(pShowShare As Boolean)
         Dim count As Integer = 2
         If pShowShare Then
            count = 3
         End If

         Dim top As Integer = 326
         Dim width As Integer = 30
         Dim gap As Integer = 8
         Dim total As Integer = (count * width) + ((count - 1) * gap)
         Dim left As Integer = CInt((me._form.Width - total) / 2)

         me.Btn1.Top = top
         me.Btn1.Left = left
         me.Btn2.Top = top
         me.Btn2.Left = left + width + gap
         me.Btn3.Top = top
         me.Btn3.Left = left + (2 * (width + gap))
         me.Btn3.Visible = pShowShare
      End Sub

      Private Function CreateButtonImage() As Forms.Imagem
         Dim btn As New Forms.Imagem(me._form)
         With btn
            .ShowHint = True
            .Center = True
            ' data7:disable-next-line unknown-member
            .AutoSize = True
         End With
         CreateButtonImage = btn
      End Function

      Sub SetImage(pPath As String)
         me._image.LoadFromFile(pPath)
         Forms.ProcessMessages()
      End Sub

      Sub SetLabel(pLabel As String)
         me._label.Text = pLabel
         Forms.ProcessMessages()
      End Sub

      Sub Show(pTitle As String = "")
         If pTitle <> "" Then
            me._form.Caption = pTitle
         End If
         Dim _canShow As Boolean = True
         If me.OnCanShow <> Null Then
            me.OnCanShow(me, _canShow)
         End If
         If _canShow Then
            me._form.Show()
         End If
      End Sub

      Sub Close()
         me._form.Close()
      End Sub

      Private Sub _handleOnShow(pSender As TObject)
         If me.OnShow <> Null Then
            me.OnShow(me)
         End If
      End Sub

      Private Sub _handleOnCanClose(pSender As TObject, ByRef pCanClose As Boolean)
         If me.OnCanClose <> Null Then
            me.OnCanClose(me, pCanClose)
         End If
      End Sub

      Private Sub _handleOnClose(pSender As TObject, pAction As TCloseAction)
         If me.OnClose <> Null Then
            me.OnClose(me)
         End If
      End Sub

      Private Sub _handleOnCanResize(S As TObject, ByRef W As Integer, ByRef H As Integer, ByRef pCanResize As Boolean)
         pCanResize = False
      End Sub

      Private Sub _handleOnKeyDown(S As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
         If me.OnKeyDown <> Null Then
            me.OnKeyDown(pKey, pShift)
         End If
      End Sub

      Private Sub _handleOnKeyUp(S As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
         If me.OnKeyUp <> Null Then
            me.OnKeyUp(pKey, pShift)
         End If
      End Sub

      Private Function SaveTempImage(pBase64 As String, pName As String) As String
         Dim path As String = me.TempPath(pName)
         Base64ToFile(pBase64, path)
         SaveTempImage = path
      End Function

      Private Function TempPath(pName As String) As String
         TempPath =TPath.GetTempPath() & "\" & pName
      End Function

      Sub Free()
         me._form.Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace