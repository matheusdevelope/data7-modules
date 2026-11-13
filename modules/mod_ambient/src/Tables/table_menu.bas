Imports TablesSchema
Imports TablesTable

Namespace table_menu

   Class TMenu
      Inherits TTableOf<TMenu>

      Sub New()
         MyBase.New("TMenu")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Menu"
         pSchema.Field("CodModulo").AsInteger().PrimaryKeyField()
         pSchema.Field("CodMenu").AsInteger().PrimaryKeyField()
         pSchema.Field("Titulo").AsString().MaxLen(51)
         pSchema.Field("ValorAcao").AsString().MaxLen(250)
         pSchema.Field("CodMenuPai").AsInteger()
         pSchema.Field("Proprietario").AsString().MaxLen(2)
         pSchema.Field("Ordem").AsInteger()
         pSchema.Field("CodImagem").AsInteger()
         pSchema.Field("Acao").AsString().MaxLen(4)
         pSchema.Field("Estrutura").AsString().MaxLen(21)
         pSchema.Field("Validacao").AsString().MaxLen(2000)
         pSchema.Field("VigenciaInicial").AsDate()
         pSchema.Field("VigenciaFinal").AsDate()
         pSchema.Field("ExclusivoAdministrador").AsString().MaxLen(1).RequiredField()
         pSchema.Field("Bloqueado").AsString().MaxLen(1).RequiredField()
         pSchema.Field("FuncaoID").AsString().MaxLen(10)
         pSchema.Field("CodWhatsAppConfiguracoesEnvio").AsInteger()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodModulo) & "|" & CStr(me.CodMenu)
      End Function

      Property CodModulo As Integer
         Get
            CodModulo = me.GetInteger("CodModulo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodModulo", pValue)
         End Set
      End Property

      Property CodMenu As Integer
         Get
            CodMenu = me.GetInteger("CodMenu")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodMenu", pValue)
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

      Property ValorAcao As String
         Get
            ValorAcao = me.GetString("ValorAcao")
         End Get
         Set(pValue As String)
            me.SetString("ValorAcao", pValue)
         End Set
      End Property

      Property CodMenuPai As Integer
         Get
            CodMenuPai = me.GetInteger("CodMenuPai")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodMenuPai", pValue)
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

      Property Ordem As Integer
         Get
            Ordem = me.GetInteger("Ordem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Ordem", pValue)
         End Set
      End Property

      Property CodImagem As Integer
         Get
            CodImagem = me.GetInteger("CodImagem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodImagem", pValue)
         End Set
      End Property

      Property Acao As String
         Get
            Acao = me.GetString("Acao")
         End Get
         Set(pValue As String)
            me.SetString("Acao", pValue)
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

      Property Validacao As String
         Get
            Validacao = me.GetString("Validacao")
         End Get
         Set(pValue As String)
            me.SetString("Validacao", pValue)
         End Set
      End Property

      Property VigenciaInicial As TDateTime
         Get
            VigenciaInicial = me.GetDateTime("VigenciaInicial")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("VigenciaInicial", pValue)
         End Set
      End Property

      Property VigenciaFinal As TDateTime
         Get
            VigenciaFinal = me.GetDateTime("VigenciaFinal")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("VigenciaFinal", pValue)
         End Set
      End Property

      Property ExclusivoAdministrador As String
         Get
            ExclusivoAdministrador = me.GetString("ExclusivoAdministrador")
         End Get
         Set(pValue As String)
            me.SetString("ExclusivoAdministrador", pValue)
         End Set
      End Property

      Property Bloqueado As String
         Get
            Bloqueado = me.GetString("Bloqueado")
         End Get
         Set(pValue As String)
            me.SetString("Bloqueado", pValue)
         End Set
      End Property

      Property FuncaoID As String
         Get
            FuncaoID = me.GetString("FuncaoID")
         End Get
         Set(pValue As String)
            me.SetString("FuncaoID", pValue)
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
