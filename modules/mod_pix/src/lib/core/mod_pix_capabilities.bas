Imports mod_tobject

Namespace mod_pix_capabilities

   Class PixCapabilities
      Inherits TTObject

      CanCobrancaRegistrar As Boolean
      CanCobrancaAlterar As Boolean
      CanCobrancaCancelar As Boolean
      CanCobrancaConsultar As Boolean
      CanCobrancaListar As Boolean
      CanPixConsultar As Boolean
      CanPixListar As Boolean
      CanDevolucaoRegistrar As Boolean
      CanDevolucaoConsultar As Boolean
      CanCobrancaVencimento As Boolean
      CanPagamento As Boolean
      CanWebhook As Boolean

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FullRecebimento() As PixCapabilities
         Dim caps As New PixCapabilities()
         caps.CanCobrancaRegistrar = True
         caps.CanCobrancaAlterar = True
         caps.CanCobrancaCancelar = True
         caps.CanCobrancaConsultar = True
         caps.CanCobrancaListar = True
         caps.CanPixConsultar = True
         caps.CanPixListar = True
         caps.CanDevolucaoRegistrar = True
         caps.CanDevolucaoConsultar = True
         FullRecebimento = caps
      End Function

      Shared Function Memory() As PixCapabilities
         Memory = PixCapabilities.FullRecebimento()
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixCapabilities")
            .Prop("CanCobrancaRegistrar", me.CanCobrancaRegistrar)
            .Prop("CanCobrancaAlterar", me.CanCobrancaAlterar)
            .Prop("CanCobrancaCancelar", me.CanCobrancaCancelar)
            .Prop("CanCobrancaConsultar", me.CanCobrancaConsultar)
            .Prop("CanCobrancaListar", me.CanCobrancaListar)
            .Prop("CanPixConsultar", me.CanPixConsultar)
            .Prop("CanPixListar", me.CanPixListar)
            .Prop("CanDevolucaoRegistrar", me.CanDevolucaoRegistrar)
            .Prop("CanDevolucaoConsultar", me.CanDevolucaoConsultar)
            .Prop("CanCobrancaVencimento", me.CanCobrancaVencimento)
            .Prop("CanPagamento", me.CanPagamento)
            .Prop("CanWebhook", me.CanWebhook)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
