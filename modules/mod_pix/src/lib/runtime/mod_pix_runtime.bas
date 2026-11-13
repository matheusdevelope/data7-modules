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
Imports mod_pix_validation
Imports mod_pix_ledger
Imports mod_pix_utils
Imports mod_pix_enums
Imports mod_pix_memory
Imports mod_pix_sicredi
Imports mod_pix_sicoob
Imports mod_pix_itau
Imports mod_pix_santander
Imports mod_pix_bradesco


Namespace mod_pix_runtime

   MustInherit Class PixResource
      Inherits TTObject

      Protected _service As PixService

      Sub New(pService As PixService)
         MyBase.New()
         If Not Assigned(pService) Then
            Throw New Exception("PixResource requer PixService")
         End If
         me._service = pService
      End Sub

      Protected Function Client() As PixClient
         Client = me._service.Client()
      End Function

      Protected Function Caps() As PixCapabilities
         Caps = me._service.Capabilities()
      End Function

      Protected Function Validator() As PixValidator
         Validator = me._service.Validator()
      End Function

      Protected Function Ledger() As PixLedger
         Ledger = me._service.Ledger()
      End Function

      Protected Sub EnsureCapability(pAllowed As Boolean, pFeature As String)
         me._service.EnsureCapability(pAllowed, pFeature)
      End Sub

      Overrides Sub Dispose()
         me._service = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixCobrancaResource
      Inherits PixResource

      Sub New(pService As PixService)
         MyBase.New(pService)
      End Sub

      Function Registrar(pDados As PixCobranca) As PixCobrancaCompleta
         me.EnsureCapability(me.Caps().CanCobrancaRegistrar, "registrar cobrança")
         If pDados.Chave = "" Then
            pDados.Chave = me._service.Config().ChavePix
         End If
         If pDados.TxId = "" Then
            pDados.TxId = GenerateTxID()
         End If
         me.Validator().EnsureCobranca(pDados)
         Dim cob As PixCobrancaCompleta = me.Client().CobrancaRegistrar(pDados)
         me.Ledger().SaveCobranca(cob)
         Registrar = cob
      End Function

      Function Alterar(pDados As PixCobranca) As PixCobrancaCompleta
         me.EnsureCapability(me.Caps().CanCobrancaAlterar, "alterar cobrança")
         If pDados.Chave = "" Then
            pDados.Chave = me._service.Config().ChavePix
         End If
         pDados.Revisao = pDados.Revisao + 1
         me.Validator().EnsureCobranca(pDados)
         Dim atual As PixCobrancaCompleta = me.Client().CobrancaConsultar(pDados.TxId)
         If Not Assigned(atual) Then
            Throw New Exception("Cobrança não encontrada")
         End If
         If Not atual.IsActive() Then
            atual.Free()
            Throw New Exception("Cobrança não está ativa e não pode ser alterada")
         End If
         atual.Free()
         Dim cob As PixCobrancaCompleta = me.Client().CobrancaAlterar(pDados)
         me.Ledger().SaveCobranca(cob)
         Alterar = cob
      End Function

      Function Cancelar(pTxId As String) As PixCobrancaCompleta
         me.EnsureCapability(me.Caps().CanCobrancaCancelar, "cancelar cobrança")
         me.Validator().EnsureTxId(pTxId)
         Dim cob As PixCobrancaCompleta = me.Client().CobrancaCancelar(pTxId)
         me.Ledger().SaveCobranca(cob, DateTime())
         Cancelar = cob
      End Function

      Function Consultar(pTxId As String) As PixCobrancaCompleta
         me.EnsureCapability(me.Caps().CanCobrancaConsultar, "consultar cobrança")
         me.Validator().EnsureTxId(pTxId)
         Consultar = me.Client().CobrancaConsultar(pTxId)
      End Function

      Function Listar(pFiltros As PixFiltro) As PixCobrancas
         me.EnsureCapability(me.Caps().CanCobrancaListar, "listar cobranças")
         me.Validator().EnsureFiltro(pFiltros)
         Listar = me.Client().CobrancaListar(pFiltros)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixRecebimentoResource
      Inherits PixResource

      Sub New(pService As PixService)
         MyBase.New(pService)
      End Sub

      Function Consultar(pEndToEndId As String) As PixRecebimento
         me.EnsureCapability(me.Caps().CanPixConsultar, "consultar PIX")
         me.Validator().EnsureE2eId(pEndToEndId)
         Consultar = me.Client().PixConsultar(pEndToEndId)
      End Function

      Function Listar(pFiltros As PixFiltro) As PixRecebimentos
         me.EnsureCapability(me.Caps().CanPixListar, "listar PIX")
         me.Validator().EnsureFiltro(pFiltros)
         Listar = me.Client().PixListar(pFiltros)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixDevolucaoResource
      Inherits PixResource

      Sub New(pService As PixService)
         MyBase.New(pService)
      End Sub

      Function Registrar(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency) As PixDevolucao
         me.EnsureCapability(me.Caps().CanDevolucaoRegistrar, "registrar devolução")
         me.Validator().EnsureDevolucao(pTxId, pEndToEndId, pIdDevolucao, pValor)
         Dim cob As PixCobrancaCompleta = me._service.Cobranca.Consultar(pTxId)
         If Not Assigned(cob) Then
            Throw New Exception("Não existe cobrança para o TxId informado, verifique!")
         End If
         Dim result As PixDevolucao = me.Client().DevolucaoRegistrar(pTxId, pEndToEndId, pIdDevolucao, pValor)
         me.Ledger().SaveCobranca(cob)
         cob.Free()
         Registrar = result
      End Function

      Function Consultar(pEndToEndId As String, pIdDevolucao As String) As PixDevolucao
         me.EnsureCapability(me.Caps().CanDevolucaoConsultar, "consultar devolução")
         me.Validator().EnsureE2eId(pEndToEndId)
         If pIdDevolucao = "" Then
            Throw New Exception("Id da devolução é obrigatório")
         End If
         Consultar = me.Client().DevolucaoConsultar(pEndToEndId, pIdDevolucao)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixCobrancaVencimentoResource
      Inherits PixResource

      Sub New(pService As PixService)
         MyBase.New(pService)
      End Sub

      Function Registrar(pDados As PixCobranca) As PixCobrancaCompleta
         me.EnsureCapability(me.Caps().CanCobrancaVencimento, "cobrança com vencimento (cobv)")
         Registrar = me.Client().CobrancaVencimentoRegistrar(pDados)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixPagamentoResource
      Inherits PixResource

      Sub New(pService As PixService)
         MyBase.New(pService)
      End Sub

      Function Enviar(pChave As String, pValor As Currency) As PixRecebimento
         me.EnsureCapability(me.Caps().CanPagamento, "pagamento PIX")
         Enviar = me.Client().PagamentoEnviar(pChave, pValor)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixWebhookResource
      Inherits PixResource

      Sub New(pService As PixService)
         MyBase.New(pService)
      End Sub

      Function Configurar(pUrl As String) As String
         me.EnsureCapability(me.Caps().CanWebhook, "webhook")
         Configurar = me.Client().WebhookConfigurar(pUrl)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixService
      Inherits TTObject

      Private _config As PixConfig
      Private _client As PixClient
      Private _validator As PixValidator
      Private _ledger As PixLedger
      Private _ownsClient As Boolean
      Private _ownsValidator As Boolean
      Private _ownsLedger As Boolean

      Cobranca As PixCobrancaResource
      Recebimento As PixRecebimentoResource
      Devolucao As PixDevolucaoResource
      CobrancaVencimento As PixCobrancaVencimentoResource
      Pagamento As PixPagamentoResource
      Webhook As PixWebhookResource

      Sub New(pClient As PixClient, pOwnsClient As Boolean = True)
         MyBase.New()
         If Not Assigned(pClient) Then
            Throw New Exception("PixService requer um PixClient")
         End If
         me._client = pClient
         me._ownsClient = pOwnsClient
         me._config = pClient.GetConfig()
         me._validator = New PixValidator()
         me._ownsValidator = True
         me._ledger = New PixNullLedger()
         me._ownsLedger = True
         me.BuildResources()
      End Sub

      Sub New(pClient As PixClient, pLedger As PixLedger, pOwnsClient As Boolean = True, pOwnsLedger As Boolean = False)
         MyBase.New()
         If Not Assigned(pClient) Then
            Throw New Exception("PixService requer um PixClient")
         End If
         If Not Assigned(pLedger) Then
            Throw New Exception("PixService requer um PixLedger")
         End If
         me._client = pClient
         me._ownsClient = pOwnsClient
         me._config = pClient.GetConfig()
         me._validator = New PixValidator()
         me._ownsValidator = True
         me._ledger = pLedger
         me._ownsLedger = pOwnsLedger
         me.BuildResources()
      End Sub

      Shared Function Load(pConfig As PixConfig) As PixService
         If pConfig.ChavePix = "" Then
            Throw New Exception("Chave PIX não informada nas configurações [ChavePIX], verifique!")
         End If
         Dim client As PixClient = PixService.CreateClient(pConfig)
         Dim ledger As PixLedger
         If pConfig.CodEmpresa > 0 Then
            ledger = New PixMovimentoLedger(pConfig)
         Else
            ledger = New PixNullLedger()
         End If
         Load = New PixService(client, ledger, True, True)
      End Function

      Shared Function CreateClient(pConfig As PixConfig) As PixClient
         If pConfig.Banco.IsValue(PixBanco.Memory()) Then
            CreateClient = New PixClientMemory(pConfig)
         ElseIf pConfig.Banco.IsValue(PixBanco.Sicredi()) Then
            CreateClient = New PixClientSicredi(pConfig)
         ElseIf pConfig.Banco.IsValue(PixBanco.Sicoob()) Then
            CreateClient = New PixClientSicoob(pConfig)
         ElseIf pConfig.Banco.IsValue(PixBanco.Itau()) Then
            CreateClient = New PixClientItau(pConfig)
         ElseIf pConfig.Banco.IsValue(PixBanco.Santander()) Then
            CreateClient = New PixClientSantander(pConfig)
         ElseIf pConfig.Banco.IsValue(PixBanco.Bradesco()) Then
            CreateClient = New PixClientBradesco(pConfig)
         Else
            Throw New Exception("Banco não suportado: " & pConfig.Banco.AsString)
         End If

      End Function

      Private Sub BuildResources()
         me.Cobranca = New PixCobrancaResource(me)
         me.Recebimento = New PixRecebimentoResource(me)
         me.Devolucao = New PixDevolucaoResource(me)
         me.CobrancaVencimento = New PixCobrancaVencimentoResource(me)
         me.Pagamento = New PixPagamentoResource(me)
         me.Webhook = New PixWebhookResource(me)
      End Sub

      Function Client() As PixClient
         Client = me._client
      End Function

      Function Config() As PixConfig
         Config = me._config
      End Function

      Function Validator() As PixValidator
         Validator = me._validator
      End Function

      Function Ledger() As PixLedger
         Ledger = me._ledger
      End Function

      Function Capabilities() As PixCapabilities
         Capabilities = me._client.GetCapabilities()
      End Function

      Sub EnsureCapability(pAllowed As Boolean, pFeature As String)
         If Not pAllowed Then
            Throw New Exception("O cliente [" & me._client.GetName() & "] não suporta o recurso: " & pFeature)
         End If
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("PixService")
            .Prop("Client", me._client.GetName())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Cobranca) Then
            me.Cobranca.Free()
            me.Cobranca = Null
         End If
         If Assigned(me.Recebimento) Then
            me.Recebimento.Free()
            me.Recebimento = Null
         End If
         If Assigned(me.Devolucao) Then
            me.Devolucao.Free()
            me.Devolucao = Null
         End If
         If Assigned(me.CobrancaVencimento) Then
            me.CobrancaVencimento.Free()
            me.CobrancaVencimento = Null
         End If
         If Assigned(me.Pagamento) Then
            me.Pagamento.Free()
            me.Pagamento = Null
         End If
         If Assigned(me.Webhook) Then
            me.Webhook.Free()
            me.Webhook = Null
         End If
         If me._ownsValidator Then
            If Assigned(me._validator) Then
               me._validator.Free()
               me._validator = Null
            End If
         End If
         If me._ownsLedger Then
            If Assigned(me._ledger) Then
               me._ledger.Free()
               me._ledger = Null
            End If
         End If
         If me._ownsClient Then
            If Assigned(me._client) Then
               me._client.Free()
               me._client = Null
            End If
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
