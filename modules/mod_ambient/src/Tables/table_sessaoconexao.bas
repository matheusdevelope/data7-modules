Imports TablesSchema
Imports TablesTable

Namespace table_sessaoconexao

   Class TSessaoConexao
      Inherits TTableOf<TSessaoConexao>

      Sub New()
         MyBase.New("TSessaoConexao")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "SessaoConexao"
         pSchema.Field("CodSessaoConexao").AsString().MaxLen(100).PrimaryKeyField()
         pSchema.Field("CodPeriodoCaixa").AsInteger()
         pSchema.Field("CodUsuario").AsInteger()
         pSchema.Field("NomeUsuario").AsString().MaxLen(20)
         pSchema.Field("EstacaoTrabalho").AsString().MaxLen(20)
         pSchema.Field("CodEstacaoTrabalho").AsInteger()
         pSchema.Field("CodEmpresa").AsInteger()
         pSchema.Field("CodFilial").AsInteger()
         pSchema.Field("CodModulo").AsInteger()
         pSchema.Field("NomeModulo").AsString().MaxLen(20)
         pSchema.Field("Data").AsDate().RequiredField()
         pSchema.Field("Hora").AsString().MaxLen(5).RequiredField()
      End Sub

      Overrides Function GetID() As String
         GetID = me.CodSessaoConexao
      End Function

      Property CodSessaoConexao As String
         Get
            CodSessaoConexao = me.GetString("CodSessaoConexao")
         End Get
         Set(pValue As String)
            me.SetString("CodSessaoConexao", pValue)
         End Set
      End Property

      Property CodPeriodoCaixa As Integer
         Get
            CodPeriodoCaixa = me.GetInteger("CodPeriodoCaixa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPeriodoCaixa", pValue)
         End Set
      End Property

      Property CodUsuario As Integer
         Get
            CodUsuario = me.GetInteger("CodUsuario")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodUsuario", pValue)
         End Set
      End Property

      Property NomeUsuario As String
         Get
            NomeUsuario = me.GetString("NomeUsuario")
         End Get
         Set(pValue As String)
            me.SetString("NomeUsuario", pValue)
         End Set
      End Property

      Property EstacaoTrabalho As String
         Get
            EstacaoTrabalho = me.GetString("EstacaoTrabalho")
         End Get
         Set(pValue As String)
            me.SetString("EstacaoTrabalho", pValue)
         End Set
      End Property

      Property CodEstacaoTrabalho As Integer
         Get
            CodEstacaoTrabalho = me.GetInteger("CodEstacaoTrabalho")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEstacaoTrabalho", pValue)
         End Set
      End Property

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("CodEmpresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEmpresa", pValue)
         End Set
      End Property

      Property CodFilial As Integer
         Get
            CodFilial = me.GetInteger("CodFilial")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodFilial", pValue)
         End Set
      End Property

      Property CodModulo As Integer
         Get
            CodModulo = me.GetInteger("CodModulo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodModulo", pValue)
         End Set
      End Property

      Property NomeModulo As String
         Get
            NomeModulo = me.GetString("NomeModulo")
         End Get
         Set(pValue As String)
            me.SetString("NomeModulo", pValue)
         End Set
      End Property

      Property Data As TDateTime
         Get
            Data = me.GetDateTime("Data")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("Data", pValue)
         End Set
      End Property

      Property Hora As String
         Get
            Hora = me.GetString("Hora")
         End Get
         Set(pValue As String)
            me.SetString("Hora", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
