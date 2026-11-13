Imports mod_tobject
Imports mod_pix_contracts
Imports mod_pix_capabilities
Imports mod_pix_config
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_filtro
Imports mod_pix_recebimento
Imports mod_pix_recebimentos
Imports mod_pix_devolucao
Imports mod_pix_enums
Imports mod_pix_utils

Namespace mod_pix_memory

   Class PixClientMemory
      Inherits PixClient

      Private _config As PixConfig
      Private _caps As PixCapabilities
      Private _cobs As PixCobrancaList
      Private _pix As PixRecebimentoList

      Sub New(pConfig As PixConfig)
         MyBase.New()
         If Not Assigned(pConfig) Then
            Throw New Exception("PixClientMemory requer PixConfig")
         End If
         me._config = pConfig.Clone()
         me._caps = PixCapabilities.Memory()
         me._cobs = New PixCobrancaList()
         me._pix = New PixRecebimentoList()
      End Sub

      Overrides Function GetName() As String
         GetName = "Memory"
      End Function

      Overrides Function GetCapabilities() As PixCapabilities
         GetCapabilities = me._caps
      End Function

      Overrides Function GetConfig() As PixConfig
         GetConfig = me._config
      End Function

      Overrides Function CobrancaRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
         If Assigned(me._cobs.FindById(pDados.TxId)) Then
            Throw New Exception("Já existe cobrança com TxId " & pDados.TxId)
         End If
         Dim stored As PixCobrancaCompleta = me.BuildCompleta(pDados)
         stored.Status = PixStatusCobranca.Ativa()
         stored.Revisao = 0
         stored.Calendario.Criacao = DateTime()
         stored.Location = "pix.memory.local/cob/" & stored.TxId
         stored.PixCopiaECola = GerarPixCopiaECola(stored.Location)
         me._cobs.Push(stored)
         CobrancaRegistrar = stored.Clone()
      End Function

      Overrides Function CobrancaAlterar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim stored As PixCobrancaCompleta = me.RequireCob(pDados.TxId)
         If Not stored.IsActive() Then
            Throw New Exception("Cobrança não está ativa e não pode ser alterada")
         End If
         stored.Chave = pDados.Chave
         stored.Revisao = pDados.Revisao
         stored.SolicitacaoPagador = pDados.SolicitacaoPagador
         stored.Valor.Assign(pDados.Valor)
         stored.Calendario.Expiracao = pDados.Calendario.Expiracao
         stored.Devedor.Assign(pDados.Devedor)
         CobrancaAlterar = stored.Clone()
      End Function

      Overrides Function CobrancaCancelar(pTxId As String) As PixCobrancaCompleta
         Dim stored As PixCobrancaCompleta = me.RequireCob(pTxId)
         If Not stored.IsActive() Then
            Throw New Exception("Somente cobrança ativa pode ser cancelada")
         End If
         stored.Status = PixStatusCobranca.RemovidaPeloUsuario()
         CobrancaCancelar = stored.Clone()
      End Function

      Overrides Function CobrancaConsultar(pTxId As String) As PixCobrancaCompleta
         CobrancaConsultar = me.RequireCob(pTxId).Clone()
      End Function

      Overrides Function CobrancaListar(pFiltros As PixFiltro) As PixCobrancas
         Dim result As New PixCobrancas()
         Dim i As Integer
         Dim count As Integer = me._cobs.Length - 1
         For i = 0 To count
            Dim cob As PixCobrancaCompleta = me._cobs.Take(i)
            If me.MatchCob(cob, pFiltros) Then
               result.Cobrancas.Push(cob.Clone())
            End If
         Next
         result.Paginacao.TotalItens = result.Cobrancas.Length
         result.Paginacao.PaginaAtual = pFiltros.Pagina
         result.Paginacao.ItensPorPagina = pFiltros.ItensPorPagina
         CobrancaListar = result
      End Function

      Overrides Function PixConsultar(pEndToEndId As String) As PixRecebimento
         Dim found As PixRecebimento = me._pix.FindById(pEndToEndId)
         If Not Assigned(found) Then
            Throw New Exception("PIX não encontrado: " & pEndToEndId)
         End If
         PixConsultar = found.Clone()
      End Function

      Overrides Function PixListar(pFiltros As PixFiltro) As PixRecebimentos
         Dim result As New PixRecebimentos()
         Dim i As Integer
         Dim count As Integer = me._pix.Length - 1
         For i = 0 To count
            Dim item As PixRecebimento = me._pix.Take(i)
            If item.Horario >= pFiltros.DataInicio And item.Horario <= pFiltros.DataFim Then
               result.Pix.Push(item.Clone())
            End If
         Next
         result.Paginacao.TotalItens = result.Pix.Length
         PixListar = result
      End Function

      Overrides Function DevolucaoRegistrar(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency) As PixDevolucao
         Dim pix As PixRecebimento = me._pix.FindById(pEndToEndId)
         If Not Assigned(pix) Then
            Throw New Exception("PIX não encontrado para devolução: " & pEndToEndId)
         End If
         If pix.TxId <> pTxId Then
            Throw New Exception("TxId não corresponde ao PIX informado")
         End If
         Dim cob As PixCobrancaCompleta = me.RequireCob(pTxId)
         Dim dev As New PixDevolucao()
         dev.Id = pIdDevolucao
         dev.RtrId = "D" & pIdDevolucao
         dev.Valor = pValor
         dev.Status = PixStatusDevolucao.Devolvido()
         dev.Horario.Solicitacao = DateTime()
         dev.Horario.Liquidacao = DateTime()
         pix.Devolucoes.Push(dev)
         pix.ValorDevolvido = pix.Devolucoes.ValorTotal()
         Dim cobPix As PixRecebimento = cob.Recebimentos.FindById(pEndToEndId)
         If Assigned(cobPix) Then
            cobPix.Devolucoes.Push(dev.Clone())
            cobPix.ValorDevolvido = cobPix.Devolucoes.ValorTotal()
         End If
         DevolucaoRegistrar = dev.Clone()
      End Function

      Overrides Function DevolucaoConsultar(pEndToEndId As String, pIdDevolucao As String) As PixDevolucao
         Dim pix As PixRecebimento = me._pix.FindById(pEndToEndId)
         If Not Assigned(pix) Then
            Throw New Exception("PIX não encontrado: " & pEndToEndId)
         End If
         Dim dev As PixDevolucao = pix.Devolucoes.FindById(pIdDevolucao)
         If Not Assigned(dev) Then
            Throw New Exception("Devolução não encontrada: " & pIdDevolucao)
         End If
         DevolucaoConsultar = dev.Clone()
      End Function

      Function SimulatePayment(pTxId As String, pValor As Double = 0) As PixRecebimento
         Dim cob As PixCobrancaCompleta = me.RequireCob(pTxId)
         If Not cob.IsActive() Then
            Throw New Exception("Somente cobrança ativa pode ser paga")
         End If
         Dim valorPago As Double = pValor
         If valorPago <= 0 Then
            valorPago = cob.Valor.Original
         End If
         Dim pix As New PixRecebimento()
         pix.E2eId = "E" & cob.TxId
         pix.TxId = cob.TxId
         pix.Chave = cob.Chave
         pix.Valor = valorPago
         pix.ValorCobranca = cob.Valor.Original
         pix.Horario = DateTime()
         cob.Status = PixStatusCobranca.Concluida()
         me._pix.Push(pix)
         cob.Recebimentos.Push(pix.Clone())
         SimulatePayment = pix.Clone()
      End Function

      Private Function BuildCompleta(pDados As PixCobranca) As PixCobrancaCompleta
         Dim cob As New PixCobrancaCompleta()
         cob.Assign(pDados)
         BuildCompleta = cob
      End Function

      Private Function RequireCob(pTxId As String) As PixCobrancaCompleta
         Dim stored As PixCobrancaCompleta = me._cobs.FindById(pTxId)
         If Not Assigned(stored) Then
            Throw New Exception("Cobrança não encontrada: " & pTxId)
         End If
         RequireCob = stored
      End Function

      Private Function MatchCob(pCob As PixCobrancaCompleta, pFiltros As PixFiltro) As Boolean
         If Assigned(pFiltros.Status) Then
            If pCob.Status <> pFiltros.Status Then
               MatchCob = False
               Exit Function
            End If
         End If
         If pCob.Calendario.Criacao < pFiltros.DataInicio Then
            MatchCob = False
            Exit Function
         End If
         If pCob.Calendario.Criacao > pFiltros.DataFim Then
            MatchCob = False
            Exit Function
         End If
         MatchCob = True
      End Function

      Overrides Sub Dispose()
         If Assigned(me._cobs) Then
            me._cobs.Free()
            me._cobs = Null
         End If
         If Assigned(me._pix) Then
            me._pix.Free()
            me._pix = Null
         End If
         If Assigned(me._caps) Then
            me._caps.Free()
            me._caps = Null
         End If
         If Assigned(me._config) Then
            me._config.Free()
            me._config = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
