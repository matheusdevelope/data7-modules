Imports TablesSchema
Imports TablesTable

Namespace table_dicionario_whatsappconfiguracoesenvio

   Class TDicionarioWhatsAppConfiguracoesEnvio
      Inherits TTableOf<TDicionarioWhatsAppConfiguracoesEnvio>

      Sub New()
         MyBase.New("TDicionarioWhatsAppConfiguracoesEnvio")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.SchemaName = "Dicionario"
         pSchema.TableName = "WhatsAppConfiguracoesEnvio"
         pSchema.Field("CodWhatsAppConfiguracoesEnvio").AsInteger().AutoCodeField()
         pSchema.Field("Descricao").AsString().MaxLen(200).RequiredField()
         pSchema.Field("ExibirFormularioEnvio").AsString().MaxLen(20)
         pSchema.Field("OrigemContatoPadrao").AsString().MaxLen(100)
         pSchema.Field("ValorContatoPadrao").AsString().MaxLen(8000)
         pSchema.Field("OrigemListaContatos").AsString().MaxLen(100)
         pSchema.Field("ValorListaContatos").AsString().MaxLen(8000)
         pSchema.Field("OrigemAssunto").AsString().MaxLen(100)
         pSchema.Field("ValorAssunto").AsString().MaxLen(8000)
         pSchema.Field("OrigemCorpoMensagem").AsString().MaxLen(100)
         pSchema.Field("ValorCorpoMensagem").AsString().MaxLen(8000)
         pSchema.Field("OrigemAssinatura").AsString().MaxLen(100)
         pSchema.Field("ValorAssinatura").AsString().MaxLen(8000)
         pSchema.Field("Observacoes").AsString().MaxLen(8000)
         pSchema.Field("Teste_CodTabela").AsInteger()
         pSchema.Field("Teste_CodRelatorio").AsInteger()
         pSchema.Field("Teste_FiltroSQL").AsString().MaxLen(8000)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodWhatsAppConfiguracoesEnvio)
      End Function

      Property CodWhatsAppConfiguracoesEnvio As Integer
         Get
            CodWhatsAppConfiguracoesEnvio = me.GetInteger("CodWhatsAppConfiguracoesEnvio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodWhatsAppConfiguracoesEnvio", pValue)
         End Set
      End Property

      Property Descricao As String
         Get
            Descricao = me.GetString("Descricao")
         End Get
         Set(pValue As String)
            me.SetString("Descricao", pValue)
         End Set
      End Property

      Property ExibirFormularioEnvio As String
         Get
            ExibirFormularioEnvio = me.GetString("ExibirFormularioEnvio")
         End Get
         Set(pValue As String)
            me.SetString("ExibirFormularioEnvio", pValue)
         End Set
      End Property

      Property OrigemContatoPadrao As String
         Get
            OrigemContatoPadrao = me.GetString("OrigemContatoPadrao")
         End Get
         Set(pValue As String)
            me.SetString("OrigemContatoPadrao", pValue)
         End Set
      End Property

      Property ValorContatoPadrao As String
         Get
            ValorContatoPadrao = me.GetString("ValorContatoPadrao")
         End Get
         Set(pValue As String)
            me.SetString("ValorContatoPadrao", pValue)
         End Set
      End Property

      Property OrigemListaContatos As String
         Get
            OrigemListaContatos = me.GetString("OrigemListaContatos")
         End Get
         Set(pValue As String)
            me.SetString("OrigemListaContatos", pValue)
         End Set
      End Property

      Property ValorListaContatos As String
         Get
            ValorListaContatos = me.GetString("ValorListaContatos")
         End Get
         Set(pValue As String)
            me.SetString("ValorListaContatos", pValue)
         End Set
      End Property

      Property OrigemAssunto As String
         Get
            OrigemAssunto = me.GetString("OrigemAssunto")
         End Get
         Set(pValue As String)
            me.SetString("OrigemAssunto", pValue)
         End Set
      End Property

      Property ValorAssunto As String
         Get
            ValorAssunto = me.GetString("ValorAssunto")
         End Get
         Set(pValue As String)
            me.SetString("ValorAssunto", pValue)
         End Set
      End Property

      Property OrigemCorpoMensagem As String
         Get
            OrigemCorpoMensagem = me.GetString("OrigemCorpoMensagem")
         End Get
         Set(pValue As String)
            me.SetString("OrigemCorpoMensagem", pValue)
         End Set
      End Property

      Property ValorCorpoMensagem As String
         Get
            ValorCorpoMensagem = me.GetString("ValorCorpoMensagem")
         End Get
         Set(pValue As String)
            me.SetString("ValorCorpoMensagem", pValue)
         End Set
      End Property

      Property OrigemAssinatura As String
         Get
            OrigemAssinatura = me.GetString("OrigemAssinatura")
         End Get
         Set(pValue As String)
            me.SetString("OrigemAssinatura", pValue)
         End Set
      End Property

      Property ValorAssinatura As String
         Get
            ValorAssinatura = me.GetString("ValorAssinatura")
         End Get
         Set(pValue As String)
            me.SetString("ValorAssinatura", pValue)
         End Set
      End Property

      Property Observacoes As String
         Get
            Observacoes = me.GetString("Observacoes")
         End Get
         Set(pValue As String)
            me.SetString("Observacoes", pValue)
         End Set
      End Property

      Property Teste_CodTabela As Integer
         Get
            Teste_CodTabela = me.GetInteger("Teste_CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Teste_CodTabela", pValue)
         End Set
      End Property

      Property Teste_CodRelatorio As Integer
         Get
            Teste_CodRelatorio = me.GetInteger("Teste_CodRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Teste_CodRelatorio", pValue)
         End Set
      End Property

      Property Teste_FiltroSQL As String
         Get
            Teste_FiltroSQL = me.GetString("Teste_FiltroSQL")
         End Get
         Set(pValue As String)
            me.SetString("Teste_FiltroSQL", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
