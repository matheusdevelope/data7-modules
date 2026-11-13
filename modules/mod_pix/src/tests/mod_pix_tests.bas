Imports Collections
Imports mod_pix_enums
Imports mod_pix_capabilities
Imports mod_pix_utils
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_filtro
Imports mod_pix_recebimento
Imports mod_pix_recebimentos
Imports mod_pix_devolucao
Imports mod_pix_info_adicional
Imports mod_pix_validation
Imports mod_pix_config
Imports mod_pix_runtime
Imports mod_pix_memory
Imports mod_pix_sicredi
Imports mod_pix_itau
Imports mod_pix_santander
Imports mod_pix_bradesco
Imports mod_pix_credentials

Namespace mod_pix_tests

   Class PixTests
      Passed As Integer
      Failed As Integer
      Private _failures As StringList

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
      End Sub

      Shared Sub RunAll()
         Using suite As New PixTests()
            suite.Run()
         End Using
      End Sub

      Sub Run()
         print("==== PIX v2 ====")
         me.TestCapabilitiesSantander()
         me.TestCapabilitiesFull()
         me.TestGenerateTxIdLength()
         me.TestMoneyFormatRoundtrip()
         me.TestIso8601Parse()
         me.TestEmvCopiaECola()
         me.TestFiltroQueryString()
         me.TestCobrancaJsonRoundtrip()
         me.TestValidatorRejectsBadTxId()
         me.TestValidatorRejectsMissingChave()
         me.TestValidatorRejectsBadCpf()
         me.TestValidatorAcceptsValidPayload()
         me.TestMemoryRegistrarConsultar()
         me.TestMemoryAlterar()
         me.TestMemoryListar()
         me.TestMemoryCancelar()
         me.TestMemoryPagamentoEDevolucao()
         me.TestMemoryRejectsAlterarConcluida()
         me.TestApplyBankProfileSicredi()
         me.TestApplyBankProfileSantander()
         me.TestApplyBankProfileBradesco()
         me.TestFactoryNamesAndTimezone()
         me.TestSantanderCapabilitiesBlockList()
         me.TestItauPatchOmitsUnchanged()
         me.TestSantanderPatchOmitsTxId()
         me.TestBradescoCreateUsesTxID()
         me.TestBradescoFilterUsesMillis()
         me.TestBradescoFilterDefaultPageSize()
         me.TestBradescoPatchOmitsTxId()
         me.TestBasicAuthorizationHasNoLineBreak()
         me.TestSlotCobvBlocked()
         me.TestSlotPagamentoBlocked()
         me.TestSlotWebhookBlocked()
         me.PrintSummary()
      End Sub

      Function MakeCobranca() As PixCobranca
         Dim cob As New PixCobranca()
         cob.TxId = GenerateTxID()
         cob.Chave = "teste-chave-pix"
         cob.Valor.Original = 1.5
         cob.Calendario.Expiracao = 3600
         cob.SolicitacaoPagador = "Teste Se7e"
         cob.InfoAdicionais.Push(New PixInfoAdicional("origem", "pix-tests"))
         MakeCobranca = cob
      End Function

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            print("  OK    " + pMsg)
         Else
            me.Failed = me.Failed + 1
            me._failures.Add(pMsg)
            print("  FAIL  " + pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=[" + pGot + "] esperado=[" + pWant + "])")
      End Sub

      Sub AssertEqInt(pGot As Integer, pWant As Integer, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=" + CStr(pGot) + " esperado=" + CStr(pWant) + ")")
      End Sub

      Sub AssertEqBool(pGot As Boolean, pWant As Boolean, pMsg As String)
         Dim gotTxt As String = "False"
         Dim wantTxt As String = "False"
         If pGot Then
            gotTxt = "True"
         End If
         If pWant Then
            wantTxt = "True"
         End If
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=" + gotTxt + " esperado=" + wantTxt + ")")
      End Sub

      Sub TestCapabilitiesSantander()
         Dim config As New PixConfig(PixBanco.Santander(), 1)
         Dim client As New PixClientSantander(config)
         Dim caps As PixCapabilities = client.GetCapabilities()
         me.AssertEqBool(caps.CanCobrancaRegistrar, True, "Santander registra cobrança")
         me.AssertEqBool(caps.CanCobrancaListar, False, "Santander não lista cobranças")
         me.AssertEqBool(caps.CanPixConsultar, False, "Santander não consulta PIX por e2e")
         me.AssertEqBool(caps.CanPixListar, True, "Santander lista PIX")
         me.AssertEqBool(caps.CanDevolucaoRegistrar, True, "Santander registra devolução")
         client.Free()
         config.Free()
      End Sub

      Sub TestCapabilitiesFull()
         Dim caps As PixCapabilities = PixCapabilities.FullRecebimento()
         me.AssertEqBool(caps.CanCobrancaListar, True, "Full lista cobranças")
         me.AssertEqBool(caps.CanPixConsultar, True, "Full consulta PIX")
         me.AssertEqBool(caps.CanCobrancaVencimento, False, "cobv ainda desligado")
         me.AssertEqBool(caps.CanPagamento, False, "pagamento ainda desligado")
         caps.Free()
      End Sub

      Sub TestGenerateTxIdLength()
         Dim txid As String = GenerateTxID()
         me.AssertTrue(Len(txid) >= 26 And Len(txid) <= 35, "TxId default entre 26 e 35")
         Dim rtid As String = GenerateIDDevolucao()
         me.AssertEqInt(Len(rtid), 20, "Id devolução tem 20 caracteres")
      End Sub

      Sub TestMoneyFormatRoundtrip()
         me.AssertEq(FormatValueToString(10.5), "10.50", "FormatValueToString 10.50")
         me.AssertTrue(FormatValueToDouble("10.50") = 10.5, "FormatValueToDouble 10.50")
      End Sub

      Sub TestIso8601Parse()
         Dim parsed As TDateTime = ParseISO8601("2026-10-03T12:30:00.00Z")
         Dim iso As String = DateToISO8601(parsed)
         me.AssertTrue(iso.StartsWith("2026-10-03T12:30:00"), "ISO-8601 roundtrip prefix")
      End Sub

      Sub TestEmvCopiaECola()
         Dim emv As String = GerarPixCopiaECola("pix.memory.local/cob/abc")
         me.AssertTrue(emv.StartsWith("00020126"), "EMV começa com payload 00 e MAI 26")
         me.AssertTrue(emv.Contains("br.gov.bcb.pix"), "EMV contém GUI BACEN")
         me.AssertEqInt(Len(Right(emv, 4)), 4, "EMV termina com CRC16 de 4 hex")
         Dim crc As String = CRC16CCITT("000201")
         me.AssertEqInt(Len(crc), 4, "CRC16 tem 4 caracteres")
      End Sub

      Sub TestFiltroQueryString()
         Dim filtro As New PixFiltro()
         filtro.DataInicio = ParseISO8601("2026-10-01T00:00:00Z")
         filtro.DataFim = ParseISO8601("2026-10-03T00:00:00Z")
         filtro.CPF = "52998224725"
         Dim qs As String = filtro.ToParamsString()
         me.AssertTrue(qs.Contains("cpf=52998224725"), "filtro serializa cpf")
         me.AssertTrue(qs.Contains("inicio="), "filtro serializa inicio")
         me.AssertTrue(qs.Contains("fim="), "filtro serializa fim")
         Dim qsUtc As String = filtro.ToParamsString(-4)
         me.AssertTrue(qsUtc.Contains("2026-10-01T04%3A00%3A00Z"), "filtro converte inicio para UTC")
         me.AssertTrue(qsUtc.Contains("2026-10-03T04%3A00%3A00Z"), "filtro converte fim para UTC")
         filtro.Free()
      End Sub

      Sub TestCobrancaJsonRoundtrip()
         Dim cob As PixCobranca = me.MakeCobranca()
         Dim json As TJSONObject = cob.ToJson()
         Dim loaded As PixCobranca = PixCobranca.FromJson(json)
         me.AssertEq(loaded.TxId, cob.TxId, "JSON txid")
         me.AssertEq(loaded.Chave, cob.Chave, "JSON chave")
         me.AssertTrue(loaded.Valor.Original = cob.Valor.Original, "JSON valor")
         me.AssertEqInt(loaded.Calendario.Expiracao, cob.Calendario.Expiracao, "JSON expiracao")
         me.AssertEqInt(loaded.InfoAdicionais.Length, 1, "JSON infoAdicionais")
         json.Free()
         loaded.Free()
         cob.Free()
      End Sub

      Sub TestValidatorRejectsBadTxId()
         Dim validator As New PixValidator()
         Dim cob As PixCobranca = me.MakeCobranca()
         cob.TxId = "curto"
         Dim errors As String = validator.ValidateCobranca(cob)
         me.AssertTrue(errors.Contains("TxID inválido"), "valida TxId curto")
         cob.Free()
         validator.Free()
      End Sub

      Sub TestValidatorRejectsMissingChave()
         Dim validator As New PixValidator()
         Dim cob As PixCobranca = me.MakeCobranca()
         cob.Chave = ""
         Dim errors As String = validator.ValidateCobranca(cob)
         me.AssertTrue(errors.Contains("Chave PIX"), "valida chave vazia")
         cob.Free()
         validator.Free()
      End Sub

      Sub TestValidatorRejectsBadCpf()
         Dim validator As New PixValidator()
         Dim cob As PixCobranca = me.MakeCobranca()
         cob.Devedor.CPF = "12345678900"
         cob.Devedor.Nome = "Joao"
         Dim errors As String = validator.ValidateCobranca(cob)
         me.AssertTrue(errors.Contains("[Devedor.CPF] inválido"), "valida CPF inválido")
         cob.Free()
         validator.Free()
      End Sub

      Sub TestValidatorAcceptsValidPayload()
         Dim validator As New PixValidator()
         Dim cob As PixCobranca = me.MakeCobranca()
         cob.Devedor.CPF = "52998224725"
         cob.Devedor.Nome = "Joao Teste"
         Dim errors As String = validator.ValidateCobranca(cob)
         me.AssertEq(errors, "", "payload válido não gera erro")
         cob.Free()
         validator.Free()
      End Sub

      Sub TestMemoryRegistrarConsultar()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         Dim cob As PixCobranca = me.MakeCobranca()
         Dim registered As PixCobrancaCompleta = pix.Cobranca.Registrar(cob)
         me.AssertEqBool(registered.IsActive(), True, "registrar deixa cobrança ATIVA")
         me.AssertTrue(registered.PixCopiaECola <> "", "registrar gera copia-e-cola")
         me.AssertTrue(registered.Location.Contains(cob.TxId), "location contém txid")
         Dim consulted As PixCobrancaCompleta = pix.Cobranca.Consultar(cob.TxId)
         me.AssertEq(consulted.TxId, cob.TxId, "consultar devolve o mesmo txid")
         consulted.Free()
         registered.Free()
         cob.Free()
         pix.Free()
         config.Free()
      End Sub

      Sub TestMemoryAlterar()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         Dim cob As PixCobranca = me.MakeCobranca()
         Dim registered As PixCobrancaCompleta = pix.Cobranca.Registrar(cob)
         cob.Valor.Original = 2.75
         Dim altered As PixCobrancaCompleta = pix.Cobranca.Alterar(cob)
         me.AssertTrue(altered.Valor.Original = 2.75, "alterar atualiza valor")
         me.AssertEqInt(altered.Revisao, 1, "alterar incrementa revisão")
         altered.Free()
         registered.Free()
         cob.Free()
         pix.Free()
         config.Free()
      End Sub

      Sub TestMemoryListar()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         Dim cob As PixCobranca = me.MakeCobranca()
         Dim registered As PixCobrancaCompleta = pix.Cobranca.Registrar(cob)
         Dim filtro As New PixFiltro()
         filtro.DataInicio = DateTime().AddHours(-1)
         filtro.DataFim = DateTime().AddHours(1)
         Dim lista As PixCobrancas = pix.Cobranca.Listar(filtro)
         me.AssertTrue(lista.Cobrancas.Length >= 1, "listar cobranças retorna itens")
         lista.Free()
         filtro.Free()
         registered.Free()
         cob.Free()
         pix.Free()
         config.Free()
      End Sub

      Sub TestMemoryCancelar()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         Dim cob As PixCobranca = me.MakeCobranca()
         Dim registered As PixCobrancaCompleta = pix.Cobranca.Registrar(cob)
         Dim canceled As PixCobrancaCompleta = pix.Cobranca.Cancelar(cob.TxId)
         me.AssertEqBool(canceled.IsCancelled(), True, "cancelar marca cobrança cancelada")
         canceled.Free()
         registered.Free()
         cob.Free()
         pix.Free()
         config.Free()
      End Sub

      Sub TestMemoryPagamentoEDevolucao()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         Dim cob As PixCobranca = me.MakeCobranca()
         Dim registered As PixCobrancaCompleta = pix.Cobranca.Registrar(cob)
         Dim client As PixClientMemory = CType(pix.Client(), PixClientMemory)
         Dim pagamento As PixRecebimento = client.SimulatePayment(cob.TxId)
         Dim done As PixCobrancaCompleta = pix.Cobranca.Consultar(cob.TxId)
         me.AssertEqBool(done.IsDone(), True, "pagamento conclui a cobrança")
         Dim recebido As PixRecebimento = pix.Recebimento.Consultar(pagamento.E2eId)
         me.AssertEq(recebido.TxId, cob.TxId, "consultar PIX pelo e2e")
         Dim filtro As New PixFiltro()
         filtro.DataInicio = DateTime().AddHours(-1)
         filtro.DataFim = DateTime().AddHours(1)
         Dim pixLista As PixRecebimentos = pix.Recebimento.Listar(filtro)
         me.AssertTrue(pixLista.Pix.Length >= 1, "listar PIX após pagamento")
         Dim rtid As String = GenerateIDDevolucao()
         Dim devolucao As PixDevolucao = pix.Devolucao.Registrar(cob.TxId, pagamento.E2eId, rtid, registered.Valor.Original)
         me.AssertEq(devolucao.Status.AsString, PixStatusDevolucao.Devolvido().AsString, "devolução DEVOLVIDO")
         Dim consultedDev As PixDevolucao = pix.Devolucao.Consultar(pagamento.E2eId, rtid)
         me.AssertEq(consultedDev.Id, rtid, "consultar devolução pelo id")
         consultedDev.Free()
         devolucao.Free()
         pixLista.Free()
         filtro.Free()
         recebido.Free()
         pagamento.Free()
         done.Free()
         registered.Free()
         cob.Free()
         pix.Free()
         config.Free()
      End Sub

      Sub TestMemoryRejectsAlterarConcluida()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         Dim cob As PixCobranca = me.MakeCobranca()
         Dim registered As PixCobrancaCompleta = pix.Cobranca.Registrar(cob)
         Dim client As PixClientMemory = CType(pix.Client(), PixClientMemory)
         Dim pagamento As PixRecebimento = client.SimulatePayment(cob.TxId)
         Dim threw As Boolean = False
         Try
            cob.Valor.Original = 3
            pix.Cobranca.Alterar(cob)
         Catch ex As Exception
            threw = True
            me.AssertTrue(ex._GetMessage().Contains("não está ativa"), "alterar concluída falha")
         End Try
         me.AssertEqBool(threw, True, "alterar cobrança concluída lança erro")
         pagamento.Free()
         registered.Free()
         cob.Free()
         pix.Free()
         config.Free()
      End Sub

      Sub TestApplyBankProfileSicredi()
         Dim config As New PixConfig(PixBanco.Sicredi(), 1)
         Dim client As New PixClientSicredi(config)
         Dim applied As PixConfig = client.GetConfig()
         me.AssertEqInt(applied.TimeZoneHours, -4, "Sicredi timezone -4")
         me.AssertEqInt(applied.Version, 2, "Sicredi força API v2")
         me.AssertEqInt(applied.Psp.Version, 2, "Sicredi PSP v2")
         me.AssertEqInt(applied.Psp.VersionAuth, 2, "Sicredi auth v2")
         client.Free()
         config.Free()
      End Sub

      Sub TestApplyBankProfileSantander()
         Dim config As New PixConfig(PixBanco.Santander(), 2)
         Dim client As New PixClientSantander(config)
         Dim applied As PixConfig = client.GetConfig()
         me.AssertEqInt(applied.TimeZoneHours, -1, "Santander timezone -1")
         me.AssertEqInt(applied.Version, 1, "Santander força API v1")
         me.AssertEqInt(applied.Psp.Version, 1, "Santander PSP v1")
         me.AssertEqInt(applied.Psp.VersionAuth, 2, "Santander auth v2")
         me.AssertEq(applied.Psp.Scopes(), "cob.read+cob.write+pix.read+pix.write", "Santander scopes")
         me.AssertEq(applied.Psp.VersionedBaseUrl(False, 2), "https://trust-pix.santander.com.br/api/v2", "Santander PATCH usa v2")
         client.Free()
         config.Free()
      End Sub

      Sub TestApplyBankProfileBradesco()
         Dim config As New PixConfig(PixBanco.Bradesco(), 1)
         Dim client As New PixClientBradesco(config)
         Dim applied As PixConfig = client.GetConfig()
         me.AssertEqInt(applied.TimeZoneHours, -4, "Bradesco timezone -4")
         me.AssertEqInt(applied.Version, 2, "Bradesco força API v2")
         me.AssertEqInt(applied.Psp.Version, 2, "Bradesco PSP v2")
         me.AssertEqInt(applied.Psp.VersionAuth, 2, "Bradesco auth v2")
         me.AssertEq(applied.Psp.AuthUrl(False), "https://qrpix.bradesco.com.br/oauth/token", "Bradesco auth produção")
         me.AssertEq(applied.Psp.BaseUrl(False), "https://qrpix.bradesco.com.br/v2", "Bradesco base produção v2")
         client.Free()
         config.Free()
      End Sub

      Sub TestFactoryNamesAndTimezone()
         Dim sicrediCfg As New PixConfig(PixBanco.Sicredi(), 2)
         sicrediCfg.ChavePix = "chave-sicredi"
         Dim _sicredi As PixService = PixService.Load(sicrediCfg)
         me.AssertEq(_sicredi.Client().GetName(), "Sicredi", "factory Sicredi")
         me.AssertEqInt(_sicredi.Config().TimeZoneHours, -4, "factory Sicredi tz")
         _sicredi.Free()
         sicrediCfg.Free()

         Dim sicoobCfg As New PixConfig(PixBanco.Sicoob(), 2)
         sicoobCfg.ChavePix = "chave-sicoob"
         Dim _sicoob As PixService = PixService.Load(sicoobCfg)
         me.AssertEq(_sicoob.Client().GetName(), "Sicoob", "factory Sicoob")
         me.AssertEqInt(_sicoob.Config().TimeZoneHours, -4, "factory Sicoob tz")
         _sicoob.Free()
         sicoobCfg.Free()

         Dim itauCfg As New PixConfig(PixBanco.Itau(), 2)
         itauCfg.ChavePix = "chave-itau"
         Dim _itau As PixService = PixService.Load(itauCfg)
         me.AssertEq(_itau.Client().GetName(), "Itau", "factory Itau")
         me.AssertEqInt(_itau.Config().TimeZoneHours, -1, "factory Itau tz")
         _itau.Free()
         itauCfg.Free()

         Dim bradescoCfg As New PixConfig(PixBanco.Bradesco(), 2)
         bradescoCfg.ChavePix = "chave-bradesco"
         Dim _bradesco As PixService = PixService.Load(bradescoCfg)
         me.AssertEq(_bradesco.Client().GetName(), "Bradesco", "factory Bradesco")
         me.AssertEqInt(_bradesco.Config().TimeZoneHours, -4, "factory Bradesco tz")
         _bradesco.Free()
         bradescoCfg.Free()
      End Sub

      Sub TestSantanderCapabilitiesBlockList()
         Dim config As New PixConfig(PixBanco.Santander(), 1)
         config.ChavePix = "chave-santander"
         Dim pix As PixService = PixService.Load(config)
         me.AssertEq(pix.Client().GetName(), "Santander", "factory Santander")
         me.AssertEqBool(pix.Capabilities().CanCobrancaListar, False, "Santander cap listar cob")
         me.AssertEqBool(pix.Capabilities().CanPixConsultar, False, "Santander cap consultar pix e2e")
         Dim filtro As New PixFiltro()
         filtro.DataInicio = DateTime().AddHours(-1)
         filtro.DataFim = DateTime().AddHours(1)
         Dim threwList As Boolean = False
         Try
            pix.Cobranca.Listar(filtro)
         Catch ex As Exception
            threwList = True
            me.AssertTrue(ex._GetMessage().Contains("não suporta"), "Santander listar cobra capability")
         End Try
         me.AssertEqBool(threwList, True, "Santander listar cobrança bloqueado")
         Dim threwPix As Boolean = False
         Try
            pix.Recebimento.Consultar("E2E123")
         Catch ex As Exception
            threwPix = True
            me.AssertTrue(ex._GetMessage().Contains("não suporta"), "Santander consultar pix capability")
         End Try
         me.AssertEqBool(threwPix, True, "Santander consultar PIX e2e bloqueado")
         filtro.Free()
         pix.Free()
         config.Free()
      End Sub

      Sub TestItauPatchOmitsUnchanged()
         Dim atual As New PixCobrancaCompleta()
         atual.TxId = "txid1234567890123456789012345678"
         atual.Chave = "chave-igual"
         atual.Valor.Original = 10
         atual.Valor.ModalidadeAlteracao = PixModalidadeAlteracao.Nao()
         atual.SolicitacaoPagador = "pagador"
         atual.Calendario.Expiracao = 3600
         atual.Devedor.Nome = "Joao"
         atual.Devedor.CPF = "52998224725"
         Dim novo As PixCobranca = atual.Clone()
         novo.Valor.Original = 20
         novo.SolicitacaoPagador = "pagador-novo"
         Dim patch As PixCobranca = PixClientItau.BuildPatch(atual, novo)
         me.AssertEq(patch.Chave, "", "Itaú omite chave igual")
         me.AssertEq(patch.Devedor.Nome, "", "Itaú omite nome igual")
         me.AssertEq(patch.Devedor.CPF, "", "Itaú omite CPF igual")
         me.AssertEqInt(patch.Calendario.Expiracao, -1, "Itaú omite expiração igual")
         me.AssertTrue(patch.Valor.Original > 0, "Itaú mantém valor alterado")
         me.AssertEq(patch.SolicitacaoPagador, "pagador-novo", "Itaú mantém solicitação alterada")
         Dim json As TJSONObject = patch.ToJson()
         me.AssertEqBool(json.Has("chave"), False, "JSON Itaú sem chave")
         me.AssertEqBool(json.Has("solicitacaoPagador"), True, "JSON Itaú com solicitação")
         json.Free()
         patch.Free()
         novo.Free()
         atual.Free()
      End Sub

      Sub TestSantanderPatchOmitsTxId()
         Dim cob As New PixCobranca()
         cob.TxId = "txid1234567890123456789012345678"
         cob.Revisao = 3
         cob.Chave = "chave-santander"
         cob.Valor.Original = 15
         Dim patch As PixCobranca = PixClientSantander.BuildPatch(cob)
         me.AssertEq(patch.TxId, "", "Santander PATCH sem txid")
         me.AssertEqInt(patch.Revisao, -1, "Santander PATCH revisao -1")
         Dim json As TJSONObject = patch.ToJson()
         me.AssertEqBool(json.Has("txid"), False, "JSON Santander sem txid")
         me.AssertEqBool(json.Has("revisao"), False, "JSON Santander sem revisao")
         me.AssertEqBool(json.Has("chave"), True, "JSON Santander mantém chave")
         json.Free()
         Dim createJson As TJSONObject = cob.ToJson("txID")
         me.AssertEqBool(createJson.Has("txid"), False, "JSON Santander create sem txid")
         me.AssertEq(createJson.GetString("txID"), cob.TxId, "JSON Santander create usa txID")
         createJson.Free()
         patch.Free()
         cob.Free()
      End Sub

      Sub TestBradescoCreateUsesTxID()
         Dim cob As New PixCobranca()
         cob.TxId = "txid1234567890123456789012345678"
         cob.Revisao = 0
         cob.Chave = "chave-bradesco"
         cob.Valor.Original = 104.26
         cob.Calendario.Expiracao = 300
         Dim body As PixCobranca = PixClientBradesco.BuildCreate(cob)
         me.AssertEqInt(body.Revisao, -1, "Bradesco create revisao -1")
         Dim json As TJSONObject = body.ToJson("txID")
         me.AssertEqBool(json.Has("txid"), False, "JSON Bradesco create sem txid")
         me.AssertEq(json.GetString("txID"), cob.TxId, "JSON Bradesco create usa txID")
         me.AssertEqBool(json.Has("revisao"), False, "JSON Bradesco create sem revisao")
         me.AssertEqBool(json.Has("chave"), True, "JSON Bradesco create mantém chave")
         json.Free()
         body.Free()
         cob.Free()
      End Sub

      Sub TestBradescoFilterUsesMillis()
         Dim filtro As New PixFiltro()
         filtro.DataInicio = ParseISO8601("2026-10-01T00:00:00Z")
         filtro.DataFim = ParseISO8601("2026-10-03T00:00:00Z")
         filtro.Pagina = 1
         filtro.ItensPorPagina = 5
         Dim qs As String = PixClientBradesco.FilterQuery(filtro, 0)
         me.AssertTrue(qs.Contains("2026-10-01T00%3A00%3A00.000Z"), "Bradesco inicio com milissegundos")
         me.AssertTrue(qs.Contains("2026-10-03T00%3A00%3A00.000Z"), "Bradesco fim com milissegundos")
         me.AssertTrue(qs.Contains("paginacao.paginaAtual=1"), "Bradesco paginaAtual")
         me.AssertTrue(qs.Contains("paginacao.itensPorPagina=5"), "Bradesco itensPorPagina")
         filtro.Free()
      End Sub

      Sub TestBradescoFilterDefaultPageSize()
         Dim filtro As New PixFiltro()
         filtro.DataInicio = ParseISO8601("2026-10-01T00:00:00Z")
         filtro.DataFim = ParseISO8601("2026-10-03T00:00:00Z")
         Dim qs As String = PixClientBradesco.FilterQuery(filtro, 0)
         me.AssertTrue(qs.Contains("paginacao.itensPorPagina=100"), "Bradesco default 100 itens")
         filtro.Free()
      End Sub

      Sub TestBradescoPatchOmitsTxId()
         Dim cob As New PixCobranca()
         cob.TxId = "txid1234567890123456789012345678"
         cob.Revisao = 3
         cob.Chave = "chave-bradesco"
         cob.Valor.Original = 0.11
         Dim patch As PixCobranca = PixClientBradesco.BuildPatch(cob)
         me.AssertEq(patch.TxId, "", "Bradesco PATCH sem txid")
         me.AssertEqInt(patch.Revisao, -1, "Bradesco PATCH revisao -1")
         me.AssertEq(patch.Chave, "chave-bradesco", "Bradesco PATCH mantém chave")
         patch.Free()
         cob.Free()
      End Sub

      Sub TestBasicAuthorizationHasNoLineBreak()
         Dim cred As New PixCredentials()
         cred.Id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
         cred.Secret = "ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj"
         Dim auth As String = cred.AsAuthorization()
         me.AssertTrue(auth.StartsWith("Basic "), "Authorization começa com Basic")
         me.AssertTrue(InStr(auth, CHAR(13)) = 0, "Authorization sem CR")
         me.AssertTrue(InStr(auth, CHAR(10)) = 0, "Authorization sem LF")
         me.AssertTrue(InStr(Mid(auth, 7), " ") = 0, "Base64 sem espaço/quebra")
         cred.Free()
      End Sub

      Sub TestSlotCobvBlocked()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         me.AssertEqBool(pix.Capabilities().CanCobrancaVencimento, False, "cobv desligado no recebimento")
         Dim threw As Boolean = False
         Try
            pix.CobrancaVencimento.Registrar(me.MakeCobranca())
         Catch ex As Exception
            threw = True
            me.AssertTrue(ex._GetMessage().Contains("não suporta"), "cobv bloqueado por capability")
         End Try
         me.AssertEqBool(threw, True, "slot cobv lança erro")
         pix.Free()
         config.Free()
      End Sub

      Sub TestSlotPagamentoBlocked()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         me.AssertEqBool(pix.Capabilities().CanPagamento, False, "pagamento desligado no recebimento")
         Dim threw As Boolean = False
         Try
            pix.Pagamento.Enviar("chave", 1)
         Catch ex As Exception
            threw = True
            me.AssertTrue(ex._GetMessage().Contains("não suporta"), "pagamento bloqueado por capability")
         End Try
         me.AssertEqBool(threw, True, "slot pagamento lança erro")
         pix.Free()
         config.Free()
      End Sub

      Sub TestSlotWebhookBlocked()
         Dim config As PixConfig = PixConfig.Memory()
         Dim pix As PixService = PixService.Load(config)
         me.AssertEqBool(pix.Capabilities().CanWebhook, False, "webhook desligado no recebimento")
         Dim threw As Boolean = False
         Try
            pix.Webhook.Configurar("https://example.local/pix")
         Catch ex As Exception
            threw = True
            me.AssertTrue(ex._GetMessage().Contains("não suporta"), "webhook bloqueado por capability")
         End Try
         me.AssertEqBool(threw, True, "slot webhook lança erro")
         pix.Free()
         config.Free()
      End Sub

      Sub PrintSummary()
         print("----")
         print("PIX v2: " + CStr(me.Passed) + " ok, " + CStr(me.Failed) + " falha(s)")
         If me.Failed > 0 Then
            Dim i As Integer
            Dim n As Integer = me._failures.Count
            For i = 0 To n - 1
               print("  - " + me._failures.Strings(i))
            Next
            Throw New Exception("PIX v2: " + CStr(me.Failed) + " teste(s) falharam")
         End If
      End Sub

      Sub Free()
         If Assigned(me._failures) Then
            me._failures.Free()
            me._failures = Null
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
