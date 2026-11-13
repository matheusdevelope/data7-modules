Imports mod_pix_bacen
Imports mod_pix_config
Imports mod_pix_http
Imports mod_pix_http_bradesco
Imports mod_pix_psp
Imports mod_pix_enums
Imports mod_pix_filtro
Imports mod_pix_utils
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_devolucao

Namespace mod_pix_bradesco

   Class PixPspBradesco
      Inherits PixPsp

      Sub New(pVersion As Integer = 2, pVersionAuth As Integer = 2)
         MyBase.New(PixBanco.Bradesco(), pVersion, pVersionAuth)
      End Sub

      Overrides Sub FillUrls()
         me.AuthUrls.Add("https://qrpix-h.bradesco.com.br/oauth/token")
         me.AuthUrls.Add("https://qrpix.bradesco.com.br/oauth/token")
         me.BaseUrls.Add("https://qrpix-h.bradesco.com.br/v" & CStr(me.Version))
         me.BaseUrls.Add("https://qrpix.bradesco.com.br/v" & CStr(me.Version))
      End Sub

      Overrides Function Clone() As PixPsp
         Clone = New PixPspBradesco(me._version, me._version_auth)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixFiltroFormatterBradesco
      Inherits PixFiltroFormatter

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function FormatDate(pDate As TDateTime, pTimeZoneHours As Integer) As String
         FormatDate = DateToISO8601Millis(pDate, pTimeZoneHours)
      End Function

      Overrides Function DefaultItensPorPagina() As Integer
         DefaultItensPorPagina = 100
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixClientBradesco
      Inherits PixClientBacen

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub ApplyProfile(pConfig As PixConfig)
         pConfig.TimeZoneHours = -4
         pConfig.Version = 2
         If Assigned(pConfig.Psp) Then
            pConfig.Psp.Free()
         End If
         pConfig.Psp = New PixPspBradesco(2, 2)
      End Sub

      Overrides Function GetName() As String
         GetName = "Bradesco"
      End Function

      Overrides Function CreateHttp() As PixHttp
         CreateHttp = New PixHttpBradesco(me._config)
      End Function

      Overrides Function CreateFiltroFormatter() As PixFiltroFormatter
         CreateFiltroFormatter = New PixFiltroFormatterBradesco()
      End Function

      Shared Function BuildCreate(pDados As PixCobranca) As PixCobranca
         Dim body As PixCobranca = pDados.Clone()
         body.Revisao = -1
         BuildCreate = body
      End Function

      Shared Function BuildPatch(pDados As PixCobranca) As PixCobranca
         Dim patch As PixCobranca = pDados.Clone()
         patch.TxId = ""
         patch.Revisao = -1
         BuildPatch = patch
      End Function

      Shared Function FilterQuery(pFiltros As PixFiltro, pTimeZoneHours As Integer) As String
         Dim formatter As New PixFiltroFormatterBradesco()
         FilterQuery = formatter.ToParamsString(pFiltros, pTimeZoneHours)
         formatter.Free()
      End Function

      Overrides Function CobrancaRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim body As PixCobranca = PixClientBradesco.BuildCreate(pDados)
         Dim payload As TJSONObject = body.ToJson("txID")
         Dim data As TJSONObject = me.Execute("PUT", "/cob/" & pDados.TxId, payload.ToString())
         payload.Free()
         body.Free()
         CobrancaRegistrar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaAlterar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim patch As PixCobranca = PixClientBradesco.BuildPatch(pDados)
         Dim payload As TJSONObject = patch.ToJson()
         Dim data As TJSONObject = me.Execute("PATCH", "/cob/" & pDados.TxId, payload.ToString())
         payload.Free()
         patch.Free()
         CobrancaAlterar = me.ParseCobranca(data)
      End Function

      Overrides Function DevolucaoRegistrar(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency) As PixDevolucao
         Dim endpoint As String = "/pix/" & pEndToEndId & "/devolucao/" & pIdDevolucao
         Dim payload As New TJSONObject()
         payload.PutString("valor", FormatValueToString(pValor))
         Dim data As TJSONObject = me.Execute("PUT", endpoint, payload.ToString())
         payload.Free()
         DevolucaoRegistrar = PixDevolucao.FromJson(data, me._config.TimeZoneHours)
         data.Free()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
