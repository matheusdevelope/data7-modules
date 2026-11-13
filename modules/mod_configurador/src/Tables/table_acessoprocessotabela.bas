Imports TablesSchema
Imports TablesTable

Namespace table_acessoprocessotabela

   Class TAcessoProcessoTabela
      Inherits TTableOf<TAcessoProcessoTabela>

      Sub New()
         MyBase.New("TAcessoProcessoTabela")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "AcessoProcessoTabela"
         pSchema.Field("CodUsuario").AsInteger().PrimaryKeyField()
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("CodProcessoTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("Permitido").AsBoolean().RequiredField()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodUsuario) & "|" & CStr(me.CodTabela) & "|" & CStr(me.CodProcessoTabela)
      End Function

      Property CodUsuario As Integer
         Get
            CodUsuario = me.GetInteger("CodUsuario")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodUsuario", pValue)
         End Set
      End Property

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

      Property Permitido As Boolean
         Get
            Permitido = me.GetBoolean("Permitido")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("Permitido", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
