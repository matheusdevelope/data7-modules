Imports TablesSchema
Imports TablesTable

Namespace table_logsistema

   Class TLogSistema
      Inherits TTableOf<TLogSistema>

      Sub New()
         MyBase.New("TLogSistema")
      End Sub

      Sub New(pCacheKey As String)
         MyBase.New(pCacheKey)
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "LogSistema"
         pSchema.Sequence = "LogSistema_Sequencia"
         pSchema.Field("CodLogSistema").AsInteger().AutoCodeField()
         pSchema.Field("CodUsuario").AsInteger().RequiredField()
         pSchema.Field("Nome").AsString().MaxLen(200).RequiredField()
         pSchema.Field("Data").AsDateTime().RequiredField()
         pSchema.Field("Hora").AsString().MaxLen(12).RequiredField()
         pSchema.Field("TipoLog").AsString().MaxLen(5).RequiredField()
         pSchema.Field("NomeComputador").AsString().MaxLen(100).RequiredField()
         pSchema.Field("NomeUsuario").AsString().MaxLen(100).RequiredField()
         pSchema.Field("NomeSistema").AsString().MaxLen(100).RequiredField()
         pSchema.Field("NomeRotina").AsString().MaxLen(100).RequiredField()
         pSchema.Field("VersaoSistema").AsString().MaxLen(100).RequiredField().InsExpr("select (CAST(Versao AS VARCHAR) + '.' + CAST(MenorVersao AS VARCHAR) + '.' + CAST(ReleaseDaVersao AS VARCHAR) + '.' + CAST(BuilderDaVersao AS VARCHAR)) from Sistema")
         pSchema.Field("Observacao").AsString().MaxLen(2000).NullIfEmptyField()
         pSchema.Field("CodPeriodoCaixa").AsInteger().NullIfEmptyField()
         pSchema.Field("ClausulaWhere").AsString().MaxLen(2000).NullIfEmptyField(False)
         pSchema.Field("CodTabela").AsInteger().NullIfEmptyField()
         pSchema.Field("UsuarioWindows").AsString().MaxLen(30)
         pSchema.Field("Id_Empresa").AsInteger().RequiredField()
         pSchema.Field("Id_Filial").AsInteger().RequiredField()
         pSchema.Field("NomeSchema").AsString().MaxLen(50).NullIfEmptyField()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodLogSistema)
      End Function

      Property CodLogSistema As Integer
         Get
            CodLogSistema = me.GetInteger("CodLogSistema")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodLogSistema", pValue)
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

      Property Nome As String
         Get
            Nome = me.GetString("Nome")
         End Get
         Set(pValue As String)
            me.SetString("Nome", pValue)
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

      Property TipoLog As String
         Get
            TipoLog = me.GetString("TipoLog")
         End Get
         Set(pValue As String)
            me.SetString("TipoLog", pValue)
         End Set
      End Property

      Property NomeComputador As String
         Get
            NomeComputador = me.GetString("NomeComputador")
         End Get
         Set(pValue As String)
            me.SetString("NomeComputador", pValue)
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

      Property NomeSistema As String
         Get
            NomeSistema = me.GetString("NomeSistema")
         End Get
         Set(pValue As String)
            me.SetString("NomeSistema", pValue)
         End Set
      End Property

      Property NomeRotina As String
         Get
            NomeRotina = me.GetString("NomeRotina")
         End Get
         Set(pValue As String)
            me.SetString("NomeRotina", pValue)
         End Set
      End Property

      Property VersaoSistema As String
         Get
            VersaoSistema = me.GetString("VersaoSistema")
         End Get
         Set(pValue As String)
            me.SetString("VersaoSistema", pValue)
         End Set
      End Property

      Property Observacao As String
         Get
            Observacao = me.GetString("Observacao")
         End Get
         Set(pValue As String)
            me.SetString("Observacao", pValue)
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

      Property ClausulaWhere As String
         Get
            ClausulaWhere = me.GetString("ClausulaWhere")
         End Get
         Set(pValue As String)
            me.SetString("ClausulaWhere", pValue)
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

      Property UsuarioWindows As String
         Get
            UsuarioWindows = me.GetString("UsuarioWindows")
         End Get
         Set(pValue As String)
            me.SetString("UsuarioWindows", pValue)
         End Set
      End Property

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("Id_Empresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Id_Empresa", pValue)
         End Set
      End Property

      Property CodFilial As Integer
         Get
            CodFilial = me.GetInteger("Id_Filial")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Id_Filial", pValue)
         End Set
      End Property

      Property NomeSchema As String
         Get
            NomeSchema = me.GetString("NomeSchema")
         End Get
         Set(pValue As String)
            me.SetString("NomeSchema", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   ' Same columns as TLogSistema, but VersaoSistema is a bound value.
   ' The shared schema keeps its InsertExpr for the single version read.
   Class TLogSistemaSave
      Inherits TLogSistema

      Sub New()
         MyBase.New("TLogSistemaSave")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         MyBase.DefineSchema(pSchema)
         pSchema.Field("VersaoSistema").InsExpr("")
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
