Imports mod_tobject
Imports mod_pix_capabilities
Imports mod_pix_config
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_filtro
Imports mod_pix_recebimento
Imports mod_pix_recebimentos
Imports mod_pix_devolucao

Namespace mod_pix_contracts

   MustInherit Class PixClient
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      MustOverride Overridable Function GetName() As String
      End Function

      MustOverride Overridable Function GetCapabilities() As PixCapabilities
      End Function

      MustOverride Overridable Function GetConfig() As PixConfig
      End Function

      Overridable Function FormatFiltro(pFiltros As PixFiltro) As String
         FormatFiltro = pFiltros.ToParamsString(me.GetConfig().TimeZoneHours)
      End Function

      Overridable Function CobrancaRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
         Throw New Exception("Cobranca.Registrar não suportado por " & me.GetName())
      End Function

      Overridable Function CobrancaAlterar(pDados As PixCobranca) As PixCobrancaCompleta
         Throw New Exception("Cobranca.Alterar não suportado por " & me.GetName())
      End Function

      Overridable Function CobrancaCancelar(pTxId As String) As PixCobrancaCompleta
         Throw New Exception("Cobranca.Cancelar não suportado por " & me.GetName())
      End Function

      Overridable Function CobrancaConsultar(pTxId As String) As PixCobrancaCompleta
         Throw New Exception("Cobranca.Consultar não suportado por " & me.GetName())
      End Function

      Overridable Function CobrancaListar(pFiltros As PixFiltro) As PixCobrancas
         Throw New Exception("Cobranca.Listar não suportado por " & me.GetName())
      End Function

      Overridable Function PixConsultar(pEndToEndId As String) As PixRecebimento
         Throw New Exception("Recebimento.Consultar não suportado por " & me.GetName())
      End Function

      Overridable Function PixListar(pFiltros As PixFiltro) As PixRecebimentos
         Throw New Exception("Recebimento.Listar não suportado por " & me.GetName())
      End Function

      Overridable Function DevolucaoRegistrar(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency) As PixDevolucao
         Throw New Exception("Devolucao.Registrar não suportado por " & me.GetName())
      End Function

      Overridable Function DevolucaoConsultar(pEndToEndId As String, pIdDevolucao As String) As PixDevolucao
         Throw New Exception("Devolucao.Consultar não suportado por " & me.GetName())
      End Function

      Overridable Function CobrancaVencimentoRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
         Throw New Exception("CobrancaVencimento.Registrar não suportado por " & me.GetName())
      End Function

      Overridable Function PagamentoEnviar(pChave As String, pValor As Currency) As PixRecebimento
         Throw New Exception("Pagamento.Enviar não suportado por " & me.GetName())
      End Function

      Overridable Function WebhookConfigurar(pUrl As String) As String
         Throw New Exception("Webhook.Configurar não suportado por " & me.GetName())
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
