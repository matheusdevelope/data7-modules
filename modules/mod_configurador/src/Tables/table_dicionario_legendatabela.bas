Imports TablesSchema
Imports TablesTable

Namespace table_dicionario_legendatabela

   Class TDicionarioLegendaTabela
      Inherits TTableOf<TDicionarioLegendaTabela>

      Sub New()
         MyBase.New("TDicionarioLegendaTabela")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.SchemaName = "Dicionario"
         pSchema.TableName = "LegendaTabela"
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("CodLegendaTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("Descricao").AsString().MaxLen(100).RequiredField()
         pSchema.Field("TipoLegenda").AsString().MaxLen(10).RequiredField()
         pSchema.Field("Ordem").AsInteger().RequiredField()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodTabela) & "|" & CStr(me.CodLegendaTabela)
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
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

      Property Descricao As String
         Get
            Descricao = me.GetString("Descricao")
         End Get
         Set(pValue As String)
            me.SetString("Descricao", pValue)
         End Set
      End Property

      Property TipoLegenda As String
         Get
            TipoLegenda = me.GetString("TipoLegenda")
         End Get
         Set(pValue As String)
            me.SetString("TipoLegenda", pValue)
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

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
