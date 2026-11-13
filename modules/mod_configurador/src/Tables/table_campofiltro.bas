Imports TablesSchema
Imports TablesTable

Namespace table_campofiltro

   Class TCampoFiltro
      Inherits TTableOf<TCampoFiltro>

      Sub New()
         MyBase.New("TCampoFiltro")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "CampoFiltro"
         pSchema.Field("CodTabela").AsInteger()
         pSchema.Field("CodFiltro").AsInteger()
         pSchema.Field("CodCampo").AsInteger()
         pSchema.Field("ValorPadrao").AsString().MaxLen(51)
         pSchema.Field("Visivel").AsString().MaxLen(2)
         pSchema.Field("proprietario").AsString().MaxLen(2)
         pSchema.Field("Ordem").AsInteger()
         pSchema.Field("Condicao").AsString().MaxLen(21)
         pSchema.Field("Titulo").AsString().MaxLen(21)
         pSchema.Field("Comando").AsString().MaxLen(16)
         pSchema.Field("Editavel").AsString().MaxLen(2)
         pSchema.Field("SQLWhereCondition").AsString().MaxLen(2001)
      End Sub

      Overrides Function GetID() As String
         GetID = ""
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
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

      Property CodCampo As Integer
         Get
            CodCampo = me.GetInteger("CodCampo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampo", pValue)
         End Set
      End Property

      Property ValorPadrao As String
         Get
            ValorPadrao = me.GetString("ValorPadrao")
         End Get
         Set(pValue As String)
            me.SetString("ValorPadrao", pValue)
         End Set
      End Property

      Property Visivel As String
         Get
            Visivel = me.GetString("Visivel")
         End Get
         Set(pValue As String)
            me.SetString("Visivel", pValue)
         End Set
      End Property

      Property proprietario As String
         Get
            proprietario = me.GetString("proprietario")
         End Get
         Set(pValue As String)
            me.SetString("proprietario", pValue)
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

      Property Condicao As String
         Get
            Condicao = me.GetString("Condicao")
         End Get
         Set(pValue As String)
            me.SetString("Condicao", pValue)
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

      Property Comando As String
         Get
            Comando = me.GetString("Comando")
         End Get
         Set(pValue As String)
            me.SetString("Comando", pValue)
         End Set
      End Property

      Property Editavel As String
         Get
            Editavel = me.GetString("Editavel")
         End Get
         Set(pValue As String)
            me.SetString("Editavel", pValue)
         End Set
      End Property

      Property SQLWhereCondition As String
         Get
            SQLWhereCondition = me.GetString("SQLWhereCondition")
         End Get
         Set(pValue As String)
            me.SetString("SQLWhereCondition", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
