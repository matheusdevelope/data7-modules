Imports TablesSchema
Imports TablesTable

Namespace table_processotabela

   Class TProcessoTabela
      Inherits TTableOf<TProcessoTabela>

      Sub New()
         MyBase.New("TProcessoTabela")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "ProcessoTabela"
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("CodProcessoTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("Titulo").AsString().MaxLen(51)
         pSchema.Field("Imagem").AsString().MaxLen(51)
         pSchema.Field("Ordem").AsInteger()
         pSchema.Field("LocalExibir").AsString().MaxLen(2)
         pSchema.Field("Proprietario").AsString().MaxLen(2)
         pSchema.Field("ShortCut").AsInteger()
         pSchema.Field("Acao").AsString().MaxLen(6)
         pSchema.Field("ValorAcao").AsString().MaxLen(250)
         pSchema.Field("Bloquear").AsString().MaxLen(10)
         pSchema.Field("VerificarBloqueio").AsString().MaxLen(10)
         pSchema.Field("Validacao").AsString().MaxLen(2000)
         pSchema.Field("Status").AsString().MaxLen(1)
         pSchema.Field("CodWhatsAppConfiguracoesEnvio").AsInteger()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodTabela) & "|" & CStr(me.CodProcessoTabela)
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
         End Set
      End Property

      Property CodProcessoTabela As Integer
         Get
            CodProcessoTabela = me.GetInteger("CodProcessoTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodProcessoTabela", pValue)
         End Set
      End Property

      Property Titulo As String
         Get
            Titulo = me.GetString("Titulo")
         End Get
         Set(pValue As String)
            me.SetString("Titulo", pValue)
         End Set
      End Property

      Property Imagem As String
         Get
            Imagem = me.GetString("Imagem")
         End Get
         Set(pValue As String)
            me.SetString("Imagem", pValue)
         End Set
      End Property

      Property Ordem As Integer
         Get
            Ordem = me.GetInteger("Ordem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Ordem", pValue)
         End Set
      End Property

      Property LocalExibir As String
         Get
            LocalExibir = me.GetString("LocalExibir")
         End Get
         Set(pValue As String)
            me.SetString("LocalExibir", pValue)
         End Set
      End Property

      Property Proprietario As String
         Get
            Proprietario = me.GetString("Proprietario")
         End Get
         Set(pValue As String)
            me.SetString("Proprietario", pValue)
         End Set
      End Property

      Property ShortCut As Integer
         Get
            ShortCut = me.GetInteger("ShortCut")
         End Get
         Set(pValue As Integer)
            me.SetInteger("ShortCut", pValue)
         End Set
      End Property

      Property Acao As String
         Get
            Acao = me.GetString("Acao")
         End Get
         Set(pValue As String)
            me.SetString("Acao", pValue)
         End Set
      End Property

      Property ValorAcao As String
         Get
            ValorAcao = me.GetString("ValorAcao")
         End Get
         Set(pValue As String)
            me.SetString("ValorAcao", pValue)
         End Set
      End Property

      Property Bloquear As String
         Get
            Bloquear = me.GetString("Bloquear")
         End Get
         Set(pValue As String)
            me.SetString("Bloquear", pValue)
         End Set
      End Property

      Property VerificarBloqueio As String
         Get
            VerificarBloqueio = me.GetString("VerificarBloqueio")
         End Get
         Set(pValue As String)
            me.SetString("VerificarBloqueio", pValue)
         End Set
      End Property

      Property Validacao As String
         Get
            Validacao = me.GetString("Validacao")
         End Get
         Set(pValue As String)
            me.SetString("Validacao", pValue)
         End Set
      End Property

      Property Status As String
         Get
            Status = me.GetString("Status")
         End Get
         Set(pValue As String)
            me.SetString("Status", pValue)
         End Set
      End Property

      Property CodWhatsAppConfiguracoesEnvio As Integer
         Get
            CodWhatsAppConfiguracoesEnvio = me.GetInteger("CodWhatsAppConfiguracoesEnvio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodWhatsAppConfiguracoesEnvio", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
