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
Imports mod_pix_http

Namespace mod_pix_bacen

   MustInherit Class PixClientBacen
      Inherits PixClient

      Protected _config As PixConfig
      Protected _http As PixHttp
      Protected _caps As PixCapabilities

      Sub New(pConfig As PixConfig)
         MyBase.New()
         If Not Assigned(pConfig) Then
            Throw New Exception("PixClientBacen requer PixConfig")
         End If
         me._config = pConfig.Clone()
         me.ApplyProfile(me._config)
         me._caps = me.CreateCapabilities()
         me._http = me.CreateHttp()
      End Sub

      MustOverride Overridable Sub ApplyProfile(pConfig As PixConfig)
      End Sub

      Overridable Function CreateHttp() As PixHttp
         CreateHttp = New PixHttp(me._config)
      End Function

      Overridable Function CreateCapabilities() As PixCapabilities
         CreateCapabilities = PixCapabilities.FullRecebimento()
      End Function

      Overridable Function CreateFiltroFormatter() As PixFiltroFormatter
         CreateFiltroFormatter = New PixFiltroFormatter()
      End Function

      Protected Function FilterQuery(pFiltros As PixFiltro) As String
         Dim formatter As PixFiltroFormatter = me.CreateFiltroFormatter()
         FilterQuery = formatter.ToParamsString(pFiltros, me._config.TimeZoneHours)
         formatter.Free()
      End Function

      Overrides Function FormatFiltro(pFiltros As PixFiltro) As String
         FormatFiltro = me.FilterQuery(pFiltros)
      End Function

      MustOverride Overrides Function GetName() As String
      End Function

      Overrides Function GetCapabilities() As PixCapabilities
         GetCapabilities = me._caps
      End Function

      Overrides Function GetConfig() As PixConfig
         GetConfig = me._config
      End Function

      Protected Function Execute(pMethod As String, pEndpoint As String, pPayload As String = "") As TJSONObject
         Execute = me._http.RequestJson(pMethod, pEndpoint, pPayload)
      End Function

      Protected Function ParseCobranca(pData As TJSONObject) As PixCobrancaCompleta
         ParseCobranca = PixCobrancaCompleta.FromJson(pData, me._config.TimeZoneHours)
         pData.Free()
      End Function

      Overrides Function CobrancaRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim endpoint As String = "/cob/" & pDados.TxId
         Dim payload As TJSONObject = pDados.ToJson()
         Dim data As TJSONObject = me.Execute("PUT", endpoint, payload.ToString())
         payload.Free()
         CobrancaRegistrar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaAlterar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim endpoint As String = "/cob/" & pDados.TxId
         Dim payload As TJSONObject = pDados.ToJson()
         Dim data As TJSONObject = me.Execute("PATCH", endpoint, payload.ToString())
         payload.Free()
         CobrancaAlterar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaCancelar(pTxId As String) As PixCobrancaCompleta
         Dim endpoint As String = "/cob/" & pTxId
         Dim payload As New TJSONObject()
         payload.PutString("status", PixStatusCobranca.RemovidaPeloUsuario().AsString)
         Dim data As TJSONObject = me.Execute("PATCH", endpoint, payload.ToString())
         payload.Free()
         CobrancaCancelar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaConsultar(pTxId As String) As PixCobrancaCompleta
         Dim data As TJSONObject = me.Execute("GET", "/cob/" & pTxId)
         CobrancaConsultar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaListar(pFiltros As PixFiltro) As PixCobrancas
         Dim data As TJSONObject = me.Execute("GET", "/cob?" & me.FilterQuery(pFiltros))
         CobrancaListar = PixCobrancas.FromJson(data, me._config.TimeZoneHours)
         data.Free()
      End Function

      Overrides Function PixConsultar(pEndToEndId As String) As PixRecebimento
         Dim data As TJSONObject = me.Execute("GET", "/pix/" & pEndToEndId)
         PixConsultar = PixRecebimento.FromJson(data, me._config.TimeZoneHours)
         data.Free()
      End Function

      Overrides Function PixListar(pFiltros As PixFiltro) As PixRecebimentos
         Dim data As TJSONObject = me.Execute("GET", "/pix?" & me.FilterQuery(pFiltros))
         PixListar = PixRecebimentos.FromJson(data, me._config.TimeZoneHours)
         data.Free()
      End Function

      Overrides Function DevolucaoRegistrar(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency) As PixDevolucao
         Dim endpoint As String = "/pix/" & pEndToEndId & "/devolucao/" & pIdDevolucao
         Dim payload As New TJSONObject()
         payload.PutString("e2eid", pEndToEndId)
         payload.PutString("id", pIdDevolucao)
         payload.PutString("valor", FormatValueToString(pValor))
         Dim data As TJSONObject = me.Execute("PUT", endpoint, payload.ToString())
         payload.Free()
         DevolucaoRegistrar = PixDevolucao.FromJson(data, me._config.TimeZoneHours)
         data.Free()
      End Function

      Overrides Function DevolucaoConsultar(pEndToEndId As String, pIdDevolucao As String) As PixDevolucao
         Dim data As TJSONObject = me.Execute("GET", "/pix/" & pEndToEndId & "/devolucao/" & pIdDevolucao)
         DevolucaoConsultar = PixDevolucao.FromJson(data, me._config.TimeZoneHours)
         data.Free()
      End Function

      Overrides Sub Dispose()
         If Assigned(me._http) Then
            me._http.Free()
            me._http = Null
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
