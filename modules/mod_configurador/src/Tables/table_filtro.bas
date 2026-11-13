Imports TablesSchema
Imports TablesTable

Namespace table_filtro

   Class TFiltro
      Inherits TTableOf<TFiltro>

      Sub New()
         MyBase.New("TFiltro")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Filtro"
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("CodFiltro").AsInteger().PrimaryKeyField()
         pSchema.Field("Nome").AsString().MaxLen(51)
         pSchema.Field("proprietario").AsString().MaxLen(2)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodTabela) & "|" & CStr(me.CodFiltro)
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

      Property Nome As String
         Get
            Nome = me.GetString("Nome")
         End Get
         Set(pValue As String)
            me.SetString("Nome", pValue)
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

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
