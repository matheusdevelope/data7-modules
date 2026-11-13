Imports TablesSchema
Imports TablesTable

Namespace table_pasta

   Class TPasta
      Inherits TTableOf<TPasta>

      Sub New()
         MyBase.New("TPasta")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Pasta"
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("CodPasta").AsInteger().PrimaryKeyField()
         pSchema.Field("Titulo").AsString().MaxLen(41)
         pSchema.Field("proprietario").AsString().MaxLen(2)
         pSchema.Field("Status").AsString().MaxLen(2)
         pSchema.Field("Estrutura").AsString().MaxLen(11)
         pSchema.Field("MargemEditor").AsInteger()
         pSchema.Field("SubCadastro").AsString().MaxLen(2)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodTabela) & "|" & CStr(me.CodPasta)
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
         End Set
      End Property

      Property CodPasta As Integer
         Get
            CodPasta = me.GetInteger("CodPasta")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPasta", pValue)
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

      Property proprietario As String
         Get
            proprietario = me.GetString("proprietario")
         End Get
         Set(pValue As String)
            me.SetString("proprietario", pValue)
         End Set
      End Property

      Property Status As String
         Get
            Status = me.GetString("Status")
         End Get
         Set(pValue As String)
            me.SetString("Status", pValue)
         End Set
      End Property

      Property Estrutura As String
         Get
            Estrutura = me.GetString("Estrutura")
         End Get
         Set(pValue As String)
            me.SetString("Estrutura", pValue)
         End Set
      End Property

      Property MargemEditor As Integer
         Get
            MargemEditor = me.GetInteger("MargemEditor")
         End Get
         Set(pValue As Integer)
            me.SetInteger("MargemEditor", pValue)
         End Set
      End Property

      Property SubCadastro As String
         Get
            SubCadastro = me.GetString("SubCadastro")
         End Get
         Set(pValue As String)
            me.SetString("SubCadastro", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
