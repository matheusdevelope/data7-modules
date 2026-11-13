Imports TablesSchema
Imports TablesTable

Namespace table_ajuda

   Class TAjuda
      Inherits TTableOf<TAjuda>

      Sub New()
         MyBase.New("TAjuda")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Ajuda"
         pSchema.Field("CodTabela").AsInteger()
         pSchema.Field("CodCampo").AsInteger()
         pSchema.Field("Conteudo").AsString().MaxLen(2000)
         pSchema.Field("CodAjuda").AsInteger().AutoCodeField()
         pSchema.Field("CodAjudaPai").AsInteger()
         pSchema.Field("Descricao").AsString().MaxLen(201)
         pSchema.Field("CodRelatorio").AsInteger()
         pSchema.Field("CodProcessoTabela").AsInteger()
         pSchema.Field("CodFiltro").AsInteger()
         pSchema.Field("CodLegendaTabela").AsInteger()
         pSchema.Field("CodModulo").AsInteger()
         pSchema.Field("CodPesquisaPadrao").AsInteger()
         pSchema.Field("CodMensagem").AsString().MaxLen(101)
         pSchema.Field("NomeParametro").AsString().MaxLen(41)
         pSchema.Field("CodGatilho").AsInteger()
         pSchema.Field("CodRegraValidacao").AsInteger()
         pSchema.Field("CodProcedureFunction").AsInteger()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodAjuda)
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
         End Set
      End Property

      Property CodCampo As Integer
         Get
            CodCampo = me.GetInteger("CodCampo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampo", pValue)
         End Set
      End Property

      Property Conteudo As String
         Get
            Conteudo = me.GetString("Conteudo")
         End Get
         Set(pValue As String)
            me.SetString("Conteudo", pValue)
         End Set
      End Property

      Property CodAjuda As Integer
         Get
            CodAjuda = me.GetInteger("CodAjuda")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodAjuda", pValue)
         End Set
      End Property

      Property CodAjudaPai As Integer
         Get
            CodAjudaPai = me.GetInteger("CodAjudaPai")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodAjudaPai", pValue)
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

      Property CodRelatorio As Integer
         Get
            CodRelatorio = me.GetInteger("CodRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodRelatorio", pValue)
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

      Property CodFiltro As Integer
         Get
            CodFiltro = me.GetInteger("CodFiltro")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodFiltro", pValue)
         End Set
      End Property

      Property CodLegendaTabela As Integer
         Get
            CodLegendaTabela = me.GetInteger("CodLegendaTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodLegendaTabela", pValue)
         End Set
      End Property

      Property CodModulo As Integer
         Get
            CodModulo = me.GetInteger("CodModulo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodModulo", pValue)
         End Set
      End Property

      Property CodPesquisaPadrao As Integer
         Get
            CodPesquisaPadrao = me.GetInteger("CodPesquisaPadrao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPesquisaPadrao", pValue)
         End Set
      End Property

      Property CodMensagem As String
         Get
            CodMensagem = me.GetString("CodMensagem")
         End Get
         Set(pValue As String)
            me.SetString("CodMensagem", pValue)
         End Set
      End Property

      Property NomeParametro As String
         Get
            NomeParametro = me.GetString("NomeParametro")
         End Get
         Set(pValue As String)
            me.SetString("NomeParametro", pValue)
         End Set
      End Property

      Property CodGatilho As Integer
         Get
            CodGatilho = me.GetInteger("CodGatilho")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGatilho", pValue)
         End Set
      End Property

      Property CodRegraValidacao As Integer
         Get
            CodRegraValidacao = me.GetInteger("CodRegraValidacao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodRegraValidacao", pValue)
         End Set
      End Property

      Property CodProcedureFunction As Integer
         Get
            CodProcedureFunction = me.GetInteger("CodProcedureFunction")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodProcedureFunction", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
