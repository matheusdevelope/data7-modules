Imports TablesSchema
Imports TablesTable

Namespace table_dicionario_gruporelatorio

   Class TDicionarioGrupoRelatorio
      Inherits TTableOf<TDicionarioGrupoRelatorio>

      Sub New()
         MyBase.New("TDicionarioGrupoRelatorio")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.SchemaName = "Dicionario"
         pSchema.TableName = "GrupoRelatorio"
         pSchema.Field("CodGrupoRelatorio").AsInteger().AutoCodeField()
         pSchema.Field("Descricao").AsString().MaxLen(60).RequiredField()
         pSchema.Field("Ordem").AsInteger()
         pSchema.Field("CodGrupoRelatorioInferior").AsInteger()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodGrupoRelatorio)
      End Function

      Property CodGrupoRelatorio As Integer
         Get
            CodGrupoRelatorio = me.GetInteger("CodGrupoRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGrupoRelatorio", pValue)
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

      Property Ordem As Integer
         Get
            Ordem = me.GetInteger("Ordem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Ordem", pValue)
         End Set
      End Property

      Property CodGrupoRelatorioInferior As Integer
         Get
            CodGrupoRelatorioInferior = me.GetInteger("CodGrupoRelatorioInferior")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGrupoRelatorioInferior", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
