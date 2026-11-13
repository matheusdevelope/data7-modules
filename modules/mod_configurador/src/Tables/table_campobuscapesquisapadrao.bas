Imports TablesSchema
Imports TablesTable

Namespace table_campobuscapesquisapadrao

   Class TCampoBuscaPesquisaPadrao
      Inherits TTableOf<TCampoBuscaPesquisaPadrao>

      Sub New()
         MyBase.New("TCampoBuscaPesquisaPadrao")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "CampoBuscaPesquisaPadrao"
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("CodPesquisaPadrao").AsInteger().PrimaryKeyField()
         pSchema.Field("CodCampo").AsInteger().PrimaryKeyField()
         pSchema.Field("Ordem").AsInteger()
         pSchema.Field("Condicao").AsString().MaxLen(2).PrimaryKeyField()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodTabela) & "|" & CStr(me.CodPesquisaPadrao) & "|" & CStr(me.CodCampo) & "|" & me.Condicao
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
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

      Property CodCampo As Integer
         Get
            CodCampo = me.GetInteger("CodCampo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampo", pValue)
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

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
