Imports mod_pix_bacen
Imports mod_pix_config
Imports mod_pix_http
Imports mod_pix_http_itau
Imports mod_pix_psp
Imports mod_pix_enums
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa

Namespace mod_pix_itau

   Class PixPspItau
      Inherits PixPsp

      Sub New(pVersion As Integer, pVersionAuth As Integer = -1)
         MyBase.New(PixBanco.Itau(), pVersion, pVersionAuth)
      End Sub

      Overrides Sub FillUrls()
         me.AuthUrls.Add("https://sts.itau.com.br/api/oauth/token")
         me.AuthUrls.Add("https://sts.itau.com.br/api/oauth/token")
         me.BaseUrls.Add("https://sandbox.devportal.itau.com.br/itau-ep9-gtw-pix-recebimentos-ext-v2/v" & CStr(me.VersionAuth))
         me.BaseUrls.Add("https://pix-pj.api.itau.com/regulatorio-pix/v" & CStr(me.Version))
      End Sub

      Overrides Function Clone() As PixPsp
         Clone = New PixPspItau(me._version, me._version_auth)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixClientItau
      Inherits PixClientBacen

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub ApplyProfile(pConfig As PixConfig)
         pConfig.TimeZoneHours = -1
         If Assigned(pConfig.Psp) Then
            pConfig.Psp.Free()
         End If
         pConfig.Psp = New PixPspItau(pConfig.Version)
      End Sub

      Overrides Function GetName() As String
         GetName = "Itau"
      End Function

      Overrides Function CreateHttp() As PixHttp
         CreateHttp = New PixHttpItau(me._config)
      End Function

      Shared Function BuildPatch(pAtual As PixCobranca, pNovo As PixCobranca) As PixCobranca
         Dim patch As PixCobranca = pNovo.Clone()
         If pAtual.Chave = pNovo.Chave Then
            patch.Chave = ""
         End If
         If pAtual.Valor.Original = pNovo.Valor.Original Then
            patch.Valor.Original = 0
         End If
         If pAtual.Valor.ModalidadeAlteracao = pNovo.Valor.ModalidadeAlteracao Then
            patch.Valor.ModalidadeAlteracao = Null
         End If
         If pAtual.SolicitacaoPagador = pNovo.SolicitacaoPagador Then
            patch.SolicitacaoPagador = ""
         End If
         If pAtual.Calendario.Expiracao = pNovo.Calendario.Expiracao Then
            patch.Calendario.Expiracao = -1
         End If
         If pAtual.Devedor.Nome = pNovo.Devedor.Nome Then
            patch.Devedor.Nome = ""
         End If
         If pAtual.Devedor.CPF = pNovo.Devedor.CPF Then
            patch.Devedor.CPF = ""
         End If
         If pAtual.Devedor.CNPJ = pNovo.Devedor.CNPJ Then
            patch.Devedor.CNPJ = ""
         End If
         BuildPatch = patch
      End Function

      Overrides Function CobrancaAlterar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim atual As PixCobrancaCompleta = me.CobrancaConsultar(pDados.TxId)
         Dim patch As PixCobranca = PixClientItau.BuildPatch(atual, pDados)
         Dim result As PixCobrancaCompleta = MyBase.CobrancaAlterar(patch)
         atual.Free()
         patch.Free()
         CobrancaAlterar = result
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
