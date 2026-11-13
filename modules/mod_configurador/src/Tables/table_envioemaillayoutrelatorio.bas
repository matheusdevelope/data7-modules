Imports TablesSchema
Imports TablesTable

Namespace table_envioemaillayoutrelatorio

   Class TEnvioEmailLayoutRelatorio
      Inherits TTableOf<TEnvioEmailLayoutRelatorio>

      Sub New()
         MyBase.New("TEnvioEmailLayoutRelatorio")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "EnvioEmailLayoutRelatorio"
         pSchema.Field("CodRelatorio").AsInteger().PrimaryKeyField()
         pSchema.Field("Item").AsString().MaxLen(6).PrimaryKeyField()
         pSchema.Field("Destinatario").AsString().MaxLen(100)
         pSchema.Field("Assunto").AsString().MaxLen(100)
         pSchema.Field("Conteudo").AsString().MaxLen(100)
         pSchema.Field("TipoValores").AsString().MaxLen(20).RequiredField()
         pSchema.Field("FormaEnvio").AsString().MaxLen(10)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodRelatorio) & "|" & me.Item
      End Function

      Property CodRelatorio As Integer
         Get
            CodRelatorio = me.GetInteger("CodRelatorio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodRelatorio", pValue)
         End Set
      End Property

      Property Item As String
         Get
            Item = me.GetString("Item")
         End Get
         Set(pValue As String)
            me.SetString("Item", pValue)
         End Set
      End Property

      Property Destinatario As String
         Get
            Destinatario = me.GetString("Destinatario")
         End Get
         Set(pValue As String)
            me.SetString("Destinatario", pValue)
         End Set
      End Property

      Property Assunto As String
         Get
            Assunto = me.GetString("Assunto")
         End Get
         Set(pValue As String)
            me.SetString("Assunto", pValue)
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

      Property TipoValores As String
         Get
            TipoValores = me.GetString("TipoValores")
         End Get
         Set(pValue As String)
            me.SetString("TipoValores", pValue)
         End Set
      End Property

      Property FormaEnvio As String
         Get
            FormaEnvio = me.GetString("FormaEnvio")
         End Get
         Set(pValue As String)
            me.SetString("FormaEnvio", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
