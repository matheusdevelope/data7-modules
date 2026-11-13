Imports mod_logger
Imports mod_pix_runtime
Imports mod_pix_config
Imports mod_pix_erp
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_filtro
Imports mod_pix_paginacao
Imports mod_pix_recebimento
Imports mod_pix_recebimentos
Imports mod_pix_devolucao
Imports mod_pix_info_adicional
Imports mod_pix_enums
Imports mod_pix_utils
' Imports mod_pix_app_qrcode
' Imports mod_pix_app_whatsapp
Imports mod_pix_capabilities

Namespace mod_pix_tests

   Class PixLiveTests
      Private _conta As String
      Private _telefone As String
      Private _config As PixConfig
      Private _service As PixService
      Private _passed As Integer
      Private _failed As Integer

      Sub New()
         MyBase.New()
         me._conta = ""
         me._telefone = ""
         me._config = Null
         me._service = Null
         me._passed = 0
         me._failed = 0
      End Sub

      Shared Sub Run(pContaFinanceira As String, pTelefone As String)
         ConfigureConsole()
         GetDefault().Options.Level = LogLevel.DebugValue()
         Using live As New PixLiveTests()
            live.Execute(pContaFinanceira, pTelefone)
         End Using
      End Sub

      Shared Sub RunHomologados(pTelefone As String)
         PixLiveTests.Run("SIC", pTelefone)
         PixLiveTests.Run("SICA", pTelefone)
         PixLiveTests.Run("BI", pTelefone)
         PixLiveTests.Run("SAN", pTelefone)
      End Sub

      Private Sub Execute(pContaFinanceira As String, pTelefone As String)
         me._conta = Trim(pContaFinanceira)
         me._telefone = Trim(pTelefone)
         GetDefault().Options.Label = "PIX/" & me._conta

         Dim timer As String = "live-" & me._conta
         TimeStart(timer)
         Info("Homologação iniciada")

         Try
            me._config = PixErp.FromContaFinanceira(me._conta)
            me._service = PixService.Load(me._config)
            Dim cfg As PixConfig = me._service.Config()
            me.Ok("load", cfg.Banco.AsString & " v" & CStr(cfg.Psp.Version) & " auth=v" & CStr(cfg.Psp.VersionAuth) & " tz=" & CStr(cfg.TimeZoneHours) & " sandbox=" & me.BoolTxt(cfg.Sandbox))

            me.LogCapabilities()
            me.TestarSlotsNaoHomologados()
            me.TestarFiltroInvalido()
            me.TestarListagensEFiltros()
            me.TestarCicloCobrancaECancelamento()
            me.TestarCicloPagamentoEDevolucao()
         Catch ex As Exception
            me.Fail("execute", ex._GetMessage())
            Dim _msg As String = "Homologação interrompida"
            Erro(_msg, ex)
         End Try

         If Assigned(me._service) Then
            me._service.Free()
            me._service = Null
         End If
         If Assigned(me._config) Then
            me._config.Free()
            me._config = Null
         End If

         Info("Resumo: " & CStr(me._passed) & " ok, " & CStr(me._failed) & " falha(s)")
         TimeEnd(timer, "homologação encerrada")
      End Sub

      Private Function Caps() As PixCapabilities
         Caps = me._service.Capabilities()
      End Function

      Private Sub LogCapabilities()
         Dim c As PixCapabilities = me.Caps()
         Info("Capabilities: cob.reg=" & me.BoolTxt(c.CanCobrancaRegistrar) & " cob.alt=" & me.BoolTxt(c.CanCobrancaAlterar) & " cob.can=" & me.BoolTxt(c.CanCobrancaCancelar) & " cob.get=" & me.BoolTxt(c.CanCobrancaConsultar) & " cob.list=" & me.BoolTxt(c.CanCobrancaListar))
         Info("Capabilities: pix.get=" & me.BoolTxt(c.CanPixConsultar) & " pix.list=" & me.BoolTxt(c.CanPixListar) & " dev.reg=" & me.BoolTxt(c.CanDevolucaoRegistrar) & " dev.get=" & me.BoolTxt(c.CanDevolucaoConsultar))
         Info("Capabilities: cobv=" & me.BoolTxt(c.CanCobrancaVencimento) & " pag=" & me.BoolTxt(c.CanPagamento) & " webhook=" & me.BoolTxt(c.CanWebhook))
      End Sub

      Private Sub TestarSlotsNaoHomologados()
         me.AssertUnsupported("cobv", me.Caps().CanCobrancaVencimento)
         me.AssertUnsupported("pagamento", me.Caps().CanPagamento)
         me.AssertUnsupported("webhook", me.Caps().CanWebhook)
      End Sub

      Private Sub AssertUnsupported(pFeature As String, pAllowed As Boolean)
         If pAllowed Then
            me.Skip(pFeature, "capability ligada — não exercita mutação em homologação live")
            Exit Sub
         End If
         Try
            If pFeature = "cobv" Then
               me._service.CobrancaVencimento.Registrar(me.NovaCobranca(1))
            ElseIf pFeature = "pagamento" Then
               me._service.Pagamento.Enviar("chave-teste", 1)
            Else
               me._service.Webhook.Configurar("https://example.local/pix")
            End If
            me.Fail(pFeature, "deveria estar bloqueado por capability")
         Catch ex As Exception
            If ex._GetMessage().Contains("não suporta") Then
               me.Ok(pFeature, "bloqueado por capability")
            Else
               me.Fail(pFeature, ex._GetMessage())
            End If
         End Try
      End Sub

      Private Sub TestarFiltroInvalido()
         Dim filtro As New PixFiltro()
         filtro.DataInicio = DateTime()
         filtro.DataFim = DateTime().AddHours(-1)
         Try
            me._service.Recebimento.Listar(filtro)
            me.Fail("filtro-invertido", "deveria rejeitar intervalo início > fim")
         Catch ex As Exception
            If ex._GetMessage().Contains("Intervalo de datas") Then
               me.Ok("filtro-invertido", "validador rejeitou datas invertidas")
            Else
               me.Fail("filtro-invertido", ex._GetMessage())
            End If
         End Try
         filtro.Free()
      End Sub

      Private Sub TestarListagensEFiltros()
         Dim janela As PixFiltro = me.FiltroJanela()
         me.ListarPix(janela)

         Dim pagina As PixFiltro = me.FiltroJanela()
         pagina.Pagina = 0
         pagina.ItensPorPagina = 5
         me.ListarPix(pagina)
         pagina.Free()

         If me.Caps().CanCobrancaListar Then
            me.ListarCobrancas(janela, "cob-periodo")
            Dim ativas As PixFiltro = me.FiltroJanela()
            ativas.Status = PixStatusCobranca.Ativa()
            me.ListarCobrancas(ativas, "cob-ativas")
            ativas.Free()
            Dim concluidas As PixFiltro = me.FiltroJanela()
            concluidas.Status = PixStatusCobranca.Concluida()
            me.ListarCobrancas(concluidas, "cob-concluidas")
            concluidas.Free()
         Else
            me.Skip("cob-listar", "PSP não lista cobranças")
            Try
               me._service.Cobranca.Listar(janela)
               me.Fail("cob-listar-cap", "deveria bloquear listagem")
            Catch ex As Exception
               me.Ok("cob-listar-cap", "capability bloqueou listagem")
            End Try
         End If
         janela.Free()
      End Sub

      Private Sub ListarPix(pFiltro As PixFiltro)
         If Not me.Caps().CanPixListar Then
            me.Skip("pix-listar", "PSP não lista PIX")
            Exit Sub
         End If
         Try
            Dim lista As PixRecebimentos = me._service.Recebimento.Listar(pFiltro)
            me.Ok("pix-listar", CStr(lista.Pix.Count()) & " item(ns) qs=" & me._service.Client().FormatFiltro(pFiltro))
            If Assigned(lista.Pix.First()) Then
               Debug(lista.Pix.First())
               If me.Caps().CanPixConsultar Then
                  Dim pix As PixRecebimento = me._service.Recebimento.Consultar(lista.Pix.First().E2eId)
                  me.Ok("pix-consultar", pix.E2eId & " valor=" & pix.Valor.ToString())
                  Debug(pix)
               Else
                  me.Skip("pix-consultar", "PSP não consulta PIX por e2e")
                  Try
                     me._service.Recebimento.Consultar(lista.Pix.First().E2eId)
                     me.Fail("pix-consultar-cap", "deveria bloquear consulta e2e")
                  Catch ex As Exception
                     me.Ok("pix-consultar-cap", "capability bloqueou consulta e2e")
                  End Try
               End If
            Else
               Info("pix-listar sem itens na janela")
            End If
         Catch ex As Exception
            me.Fail("pix-listar", ex._GetMessage())
         End Try
      End Sub

      Private Sub ListarCobrancas(pFiltro As PixFiltro, pStep As String)
         Try
            Dim lista As PixCobrancas = me._service.Cobranca.Listar(pFiltro)
            me.Ok(pStep, CStr(lista.Cobrancas.Count()) & " item(ns) qs=" & me._service.Client().FormatFiltro(pFiltro))
            If Assigned(lista.Paginacao) Then
               Debug("paginacao total=" & CStr(lista.Paginacao.TotalItens) & " pagina=" & CStr(lista.Paginacao.PaginaAtual))
            End If
            If Assigned(lista.Cobrancas.First()) Then
               Dim cob As PixCobrancaCompleta = me._service.Cobranca.Consultar(lista.Cobrancas.First().TxId)
               me.Ok(pStep & "-consultar", cob.TxId & " status=" & cob.Status.AsString & " pix=" & CStr(cob.Recebimentos.Count()))
               Debug(cob)
            End If
         Catch ex As Exception
            me.Fail(pStep, ex._GetMessage())
         End Try
      End Sub

      Private Sub _wait(pMilliseconds As Integer = 500)
         Sleep(pMilliseconds)
      End Sub

      Private Sub TestarCicloCobrancaECancelamento()
         Dim cob As PixCobranca = me.NovaCobranca(1)
         Dim registered As PixCobrancaCompleta = Null
         Try
            registered = me._service.Cobranca.Registrar(cob)
            me.AssertTrue(registered.IsActive(), "cob-registrar", "status ATIVA txid=" & registered.TxId)
            me.AssertTrue(registered.PixCopiaECola <> "", "cob-emv", "copia-e-cola gerado")
            Debug(registered)

            me._wait()
            Dim consulted As PixCobrancaCompleta = me._service.Cobranca.Consultar(cob.TxId)
            me.AssertTrue(consulted.TxId = cob.TxId, "cob-consultar", "txid=" & consulted.TxId & " status=" & consulted.Status.AsString)
            me.AssertTrue(consulted.IsActive(), "cob-consultar-ativa", consulted.Status.AsString)

            If me.Caps().CanCobrancaListar Then
               me._wait()
               Dim filtro As PixFiltro = me.FiltroJanela()
               filtro.Status = PixStatusCobranca.Ativa()
               Dim lista As PixCobrancas = me._service.Cobranca.Listar(filtro)
               me.AssertTrue(me.ListaTemTxId(lista.Cobrancas, cob.TxId), "cob-listar-txid", "txid=" & cob.TxId & " em " & CStr(lista.Cobrancas.Length) & " ativa(s)")
               filtro.Free()
            End If

            cob.Valor.Original = 0.11
            cob.SolicitacaoPagador = "Teste Se7e - alterado"
            cob.Calendario.Expiracao = 1800
            Dim altered As PixCobrancaCompleta = me._service.Cobranca.Alterar(cob)
            me.AssertTrue(altered.Valor.Original = 0.11, "cob-alterar", "valor=" & altered.Valor.Original.ToString() & " revisao=" & CStr(altered.Revisao))

            me._wait()
            Dim afterAlter As PixCobrancaCompleta = me._service.Cobranca.Consultar(cob.TxId)
            me.AssertTrue(afterAlter.Valor.Original = 0.11, "cob-consultar-alterado", "valor=" & afterAlter.Valor.Original.ToString())
            me.AssertTrue(afterAlter.IsActive(), "cob-ainda-ativa", afterAlter.Status.AsString)

            Dim canceled As PixCobrancaCompleta = me._service.Cobranca.Cancelar(cob.TxId)
            me.AssertTrue(canceled.IsCancelled(), "cob-cancelar", canceled.Status.AsString)

            me._wait(1000)
            Dim afterCancel As PixCobrancaCompleta = me._service.Cobranca.Consultar(cob.TxId)
            me.AssertTrue(afterCancel.IsCancelled(), "cob-consultar-cancelada", afterCancel.Status.AsString)

            Try
               cob.Valor.Original = 0.22
               me._service.Cobranca.Alterar(cob)
               me.Fail("cob-alterar-cancelada", "não deveria alterar cobrança cancelada")
            Catch ex As Exception
               me.Ok("cob-alterar-cancelada", "recusou alteração")
            End Try
         Catch ex As Exception
            me.Fail("cob-ciclo-cancelamento", ex._GetMessage())
         End Try
      End Sub

      Private Sub TestarCicloPagamentoEDevolucao()
         Dim cob As PixCobranca = me.NovaCobranca(0.11)
         Dim registered As PixCobrancaCompleta = Null
         Try
            registered = me._service.Cobranca.Registrar(cob)
            me.Ok("pay-registrar", registered.TxId & " valor=" & registered.Valor.Original.ToString())

            If Not Forms.MessageBox.Confirmation("[" & me._conta & "] Pagar a cobrança " & registered.TxId & " para testar recebimento/devolução?") Then
               me.Skip("pay-qr", "pagamento ignorado pelo operador")
               If registered.IsActive() Then
                  Dim canceled As PixCobrancaCompleta = me._service.Cobranca.Cancelar(registered.TxId)
                  me.Ok("pay-cleanup", "cobrança cancelada " & canceled.Status.AsString)
               End If
               Exit Sub
            End If

            ' Dim form As New PixAppQrCode(me._service)
            ' form.OnSendWhatsapp = me.OnSendWhatsapp
            ' registered = form.Show(registered)
            ' form.Free()

            registered = me._service.Cobranca.Consultar(cob.TxId)
            me.Ok("pay-consultar", registered.TxId & " status=" & registered.Status.AsString & " pix=" & CStr(registered.Recebimentos.Count()))

            If Not registered.IsDone() Then
               me.Skip("pay-devolucao", "cobrança não concluída status=" & registered.Status.AsString)
               If registered.IsActive() Then
                  If Forms.MessageBox.Confirmation("[" & me._conta & "] Cancelar a cobrança não paga " & registered.TxId & "?") Then
                     registered = me._service.Cobranca.Cancelar(registered.TxId)
                     me.Ok("pay-cancelar", registered.Status.AsString)
                  End If
               End If
               Exit Sub
            End If

            If registered.Recebimentos.Count() <= 0 Then
               me.Fail("pay-recebimento", "cobrança concluída sem PIX associado")
               Exit Sub
            End If

            Dim pix As PixRecebimento = registered.Recebimentos.First()
            me.Ok("pay-e2e", pix.E2eId & " valor=" & pix.Valor.ToString())

            If me.Caps().CanPixConsultar Then
               Dim consultedPix As PixRecebimento = me._service.Recebimento.Consultar(pix.E2eId)
               me.AssertTrue(consultedPix.TxId = cob.TxId, "pay-pix-consultar", consultedPix.E2eId)
            Else
               me.Skip("pay-pix-consultar", "PSP não consulta PIX por e2e")
            End If

            If me.Caps().CanPixListar Then
               Dim filtro As PixFiltro = me.FiltroJanela()
               Dim lista As PixRecebimentos = me._service.Recebimento.Listar(filtro)
               me.Ok("pay-pix-listar", CStr(lista.Pix.Count()) & " item(ns) após pagamento")
               filtro.Free()
            End If

            If Not Forms.MessageBox.Confirmation("[" & me._conta & "] Registrar devolução de " & registered.Valor.Original.ToString() & "?") Then
               me.Skip("pay-devolucao", "devolução ignorada pelo operador")
               Exit Sub
            End If

            Dim rtid As String = GenerateIDDevolucao()
            Dim devolucao As PixDevolucao = me._service.Devolucao.Registrar(registered.TxId, pix.E2eId, rtid, registered.Valor.Original)
            me.Ok("dev-registrar", rtid & " status=" & devolucao.Status.AsString)

            Dim consultedDev As PixDevolucao = me._service.Devolucao.Consultar(pix.E2eId, rtid)
            me.AssertTrue(consultedDev.Id = rtid, "dev-consultar", consultedDev.Id & " status=" & consultedDev.Status.AsString)

            Dim afterDev As PixCobrancaCompleta = me._service.Cobranca.Consultar(cob.TxId)
            me.Ok("dev-cob-consultar", afterDev.TxId & " status=" & afterDev.Status.AsString)
            Debug(afterDev)
         Catch ex As Exception
            me.Fail("pay-ciclo", ex._GetMessage())
         End Try
      End Sub

      Private Function NovaCobranca(pValor As Currency) As PixCobranca
         Dim cob As New PixCobranca()
         cob.TxId = GenerateTxID()
         cob.Valor.Original = pValor
         cob.Calendario.Expiracao = 3600
         cob.SolicitacaoPagador = "Teste Se7e Sistemas"
         cob.InfoAdicionais.Push(New PixInfoAdicional("origem", "pix-live-tests"))
         cob.InfoAdicionais.Push(New PixInfoAdicional("conta", me._conta))
         NovaCobranca = cob
      End Function

      Private Function FiltroJanela() As PixFiltro
         Dim filtro As New PixFiltro()
         filtro.DataInicio = DateTime().AddHours(-4)
         filtro.DataFim = DateTime()
         FiltroJanela = filtro
      End Function

      Private Function ListaTemTxId(pLista As PixCobrancaList, pTxId As String) As Boolean
         Dim i As Integer
         Dim n As Integer = pLista.Length
         For i = 0 To n - 1
            If pLista.Take(i).TxId = pTxId Then
               ListaTemTxId = True
               Exit Function
            End If
         Next
         ListaTemTxId = False
      End Function

      ' Private Sub OnSendWhatsapp(ByRef pOptions As PixAppWhatsapp, ByRef pCanSend As Boolean)
      '    If Trim(me._telefone) <> "" Then
      '       pOptions.Message().Recipient = me._telefone
      '    End If
      ' End Sub

      Private Function BoolTxt(pValue As Boolean) As String
         If pValue Then
            BoolTxt = "True"
         Else
            BoolTxt = "False"
         End If
      End Function

      Private Sub AssertTrue(pOk As Boolean, pStep As String, pDetail As String)
         If pOk Then
            me.Ok(pStep, pDetail)
         Else
            me.Fail(pStep, pDetail)
         End If
      End Sub

      Private Sub Ok(pStep As String, pDetail As String)
         me._passed = me._passed + 1
         TimeLog("live-" & me._conta, "OK " & pStep & " — " & pDetail)
      End Sub

      Private Sub Fail(pStep As String, pDetail As String)
         me._failed = me._failed + 1
         Erro("FAIL " & pStep & " — " & pDetail)
      End Sub

      Private Sub Skip(pStep As String, pReason As String)
         Warn("SKIP " & pStep & " — " & pReason)
      End Sub

      Sub Free()
         If Assigned(me._service) Then
            me._service.Free()
            me._service = Null
         End If
         If Assigned(me._config) Then
            me._config.Free()
            me._config = Null
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
