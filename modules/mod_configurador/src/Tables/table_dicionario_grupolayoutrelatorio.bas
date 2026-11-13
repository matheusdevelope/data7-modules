Imports TablesSchema
Imports TablesTable

Namespace table_dicionario_grupolayoutrelatorio

   Class TDicionarioGrupoLayoutRelatorio
      Inherits TTableOf<TDicionarioGrupoLayoutRelatorio>

      Sub New()
         MyBase.New("TDicionarioGrupoLayoutRelatorio")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.SchemaName = "Dicionario"
         pSchema.TableName = "GrupoLayoutRelatorio"
         pSchema.Field("CodRelatorio").AsInteger().RequiredField()
         pSchema.Field("CodGrupoLayoutRelatorio").AsInteger().AutoCodeField()
         pSchema.Field("Descricao").AsString().MaxLen(60).RequiredField()
         pSchema.Field("CodGrupoLayoutRelatorioInferior").AsInteger()
         pSchema.Field("Ordem").AsInteger()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodGrupoLayoutRelatorio)
      End Function

      Property CodRelatorio As Integer
         Get
            CodRelatorio = me.GetInteger("CodRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodRelatorio", pValue)
         End Set
      End Property

      Property CodGrupoLayoutRelatorio As Integer
         Get
            CodGrupoLayoutRelatorio = me.GetInteger("CodGrupoLayoutRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGrupoLayoutRelatorio", pValue)
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

      Property CodGrupoLayoutRelatorioInferior As Integer
         Get
            CodGrupoLayoutRelatorioInferior = me.GetInteger("CodGrupoLayoutRelatorioInferior")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGrupoLayoutRelatorioInferior", pValue)
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
