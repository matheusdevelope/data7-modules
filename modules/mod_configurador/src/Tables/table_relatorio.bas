Imports TablesSchema
Imports TablesTable

Namespace table_relatorio

   Class TRelatorio
      Inherits TTableOf<TRelatorio>

      Sub New()
         MyBase.New("TRelatorio")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Relatorio"
         pSchema.Field("CodRelatorio").AsInteger().AutoCodeField()
         pSchema.Field("Titulo").AsString().MaxLen(101)
         pSchema.Field("CodGrupoRelatorio").AsInteger()
         pSchema.Field("CodWhatsAppConfiguracoesEnvio").AsInteger()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodRelatorio)
      End Function

      Property CodRelatorio As Integer
         Get
            CodRelatorio = me.GetInteger("CodRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodRelatorio", pValue)
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

      Property CodGrupoRelatorio As Integer
         Get
            CodGrupoRelatorio = me.GetInteger("CodGrupoRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGrupoRelatorio", pValue)
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
