Imports TablesSchema
Imports TablesTable

Namespace table_grupotabela

   Class TGrupoTabela
      Inherits TTableOf<TGrupoTabela>

      Sub New()
         MyBase.New("TGrupoTabela")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "GrupoTabela"
         pSchema.Field("CodGrupoTabela").AsInteger().AutoCodeField()
         pSchema.Field("Nome").AsString().MaxLen(31)
         pSchema.Field("Proprietario").AsString().MaxLen(2)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodGrupoTabela)
      End Function

      Property CodGrupoTabela As Integer
         Get
            CodGrupoTabela = me.GetInteger("CodGrupoTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGrupoTabela", pValue)
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

      Property Proprietario As String
         Get
            Proprietario = me.GetString("Proprietario")
         End Get
         Set(pValue As String)
            me.SetString("Proprietario", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
