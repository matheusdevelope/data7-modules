Imports mod_pix_bacen
Imports mod_pix_capabilities
Imports mod_pix_config
Imports mod_pix_http
Imports mod_pix_http_santander
Imports mod_pix_psp
Imports mod_pix_enums
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_filtro
Imports mod_pix_recebimento

Namespace mod_pix_santander

   Class PixPspSantander
      Inherits PixPsp

      Sub New(pVersion As Integer = 1, pVersionAuth As Integer = 2)
         MyBase.New(PixBanco.Santander(), pVersion, pVersionAuth)
      End Sub

      Overrides Sub FillScopes()
         me.Scope.Add("cob.read")
         me.Scope.Add("cob.write")
         me.Scope.Add("pix.read")
         me.Scope.Add("pix.write")
      End Sub

      Overrides Sub FillUrls()
         me.AuthUrls.Add("https://trust-pix.santander.com.br/oauth/token")
         me.AuthUrls.Add("https://trust-pix.santander.com.br/oauth/token")
         me.BaseUrls.Add("https://trust-pix-h.santander.com.br/api/v" & CStr(me.Version))
         me.BaseUrls.Add("https://trust-pix.santander.com.br/api/v" & CStr(me.Version))
      End Sub

      Overrides Function Clone() As PixPsp
         Clone = New PixPspSantander(me._version, me._version_auth)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixClientSantander
      Inherits PixClientBacen

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub ApplyProfile(pConfig As PixConfig)
         pConfig.TimeZoneHours = -1
         pConfig.Version = 1
         If Assigned(pConfig.Psp) Then
            pConfig.Psp.Free()
         End If
         pConfig.Psp = New PixPspSantander(1, 2)
      End Sub

      Overrides Function GetName() As String
         GetName = "Santander"
      End Function

      Overrides Function CreateHttp() As PixHttp
         CreateHttp = New PixHttpSantander(me._config)
      End Function

      Overrides Function CreateCapabilities() As PixCapabilities
         Dim caps As PixCapabilities = PixCapabilities.FullRecebimento()
         caps.CanCobrancaListar = False
         caps.CanPixConsultar = False
         CreateCapabilities = caps
      End Function

      Shared Function BuildPatch(pDados As PixCobranca) As PixCobranca
         Dim patch As PixCobranca = pDados.Clone()
         patch.TxId = ""
         patch.Revisao = -1
         BuildPatch = patch
      End Function

      Overrides Function CobrancaRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim payload As TJSONObject = pDados.ToJson("txID")
         Dim data As TJSONObject = me.Execute("PUT", "/cob/" & pDados.TxId, payload.ToString())
         payload.Free()
         CobrancaRegistrar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaAlterar(pDados As PixCobranca) As PixCobrancaCompleta
         Dim patch As PixCobranca = PixClientSantander.BuildPatch(pDados)
         Dim payload As TJSONObject = patch.ToJson()
         Dim data As TJSONObject = me.Execute("PATCH", me.CobV2(pDados.TxId), payload.ToString())
         payload.Free()
         patch.Free()
         CobrancaAlterar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaCancelar(pTxId As String) As PixCobrancaCompleta
         Dim payload As New TJSONObject()
         payload.PutString("status", PixStatusCobranca.RemovidaPeloUsuario().AsString)
         Dim data As TJSONObject = me.Execute("PATCH", me.CobV2(pTxId), payload.ToString())
         payload.Free()
         CobrancaCancelar = me.ParseCobranca(data)
      End Function

      Overrides Function CobrancaListar(pFiltros As PixFiltro) As PixCobrancas
         Throw New Exception("Método não suportado, a API do Santander não possui um método para listar cobranças PIX, a consulta deve ser feita usando o TxId das cobranças geradas anteriomente.")
      End Function

      Overrides Function PixConsultar(pEndToEndId As String) As PixRecebimento
         Throw New Exception("Método não suportado, a API do Santander não possui um método para consultar um PIX específico, a consulta pode ser feita através da cobrança.")
      End Function

      Private Function CobV2(pTxId As String) As String
         CobV2 = me._config.Psp.VersionedBaseUrl(me._config.Sandbox, 2) & "/cob/" & pTxId
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
