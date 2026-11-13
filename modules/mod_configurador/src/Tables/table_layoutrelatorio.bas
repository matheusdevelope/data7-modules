Imports TablesSchema
Imports TablesTable

Namespace table_layoutrelatorio

   Class TLayoutRelatorio
      Inherits TTableOf<TLayoutRelatorio>

      Sub New()
         MyBase.New("TLayoutRelatorio")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "LayoutRelatorio"
         pSchema.Field("CodRelatorio").AsInteger().PrimaryKeyField()
         pSchema.Field("Item").AsString().MaxLen(6).PrimaryKeyField()
         pSchema.Field("Titulo").AsString().MaxLen(2001)
         pSchema.Field("Ordem").AsInteger()
         pSchema.Field("Ajuda").AsString().MaxLen(2001)
         pSchema.Field("Exemplo").AsString().MaxLen(8000)
         pSchema.Field("Ativo").AsString().MaxLen(2)
         pSchema.Field("Arquivo").AsString().MaxLen(251)
         pSchema.Field("NumeroCopia").AsInteger()
         pSchema.Field("ImpressoraPadrao").AsString().MaxLen(201)
         pSchema.Field("Orientacao").AsString().MaxLen(2)
         pSchema.Field("TamanhoPapel").AsInteger()
         pSchema.Field("Largura").AsInteger()
         pSchema.Field("Altura").AsInteger()
         pSchema.Field("Selecionado").AsString().MaxLen(2)
         pSchema.Field("Solicitar").AsString().MaxLen(2)
         pSchema.Field("Aviso").AsString().MaxLen(251)
         pSchema.Field("Acao").AsString().MaxLen(6)
         pSchema.Field("NomeArquivo").AsString().MaxLen(2001)
         pSchema.Field("CodUsuario").AsInteger()
         pSchema.Field("CodEstacao").AsInteger()
         pSchema.Field("CodEmpresa").AsInteger()
         pSchema.Field("CodFilial").AsInteger()
         pSchema.Field("ArquivoFisico").AsString().MaxLen(8000)
         pSchema.Field("CodGrupoLayoutRelatorio").AsInteger().RequiredField()
         pSchema.Field("Repx").AsString().MaxLen(16)
         pSchema.Field("SalvarAutomaticamenteEmDisco").AsString().MaxLen(3)
         pSchema.Field("PastaSalvarAutomaticamenteEmDisco").AsString().MaxLen(500)
         pSchema.Field("CodProjeto").AsInteger()
         pSchema.Field("ImprimirCapa").AsString().MaxLen(3).RequiredField()
         pSchema.Field("ExibirParametroCapaVazio").AsString().MaxLen(3).RequiredField()
         pSchema.Field("Obrigatorio").AsString().MaxLen(3).RequiredField()
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

      Property Titulo As String
         Get
            Titulo = me.GetString("Titulo")
         End Get
         Set(pValue As String)
            me.SetString("Titulo", pValue)
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

      Property Ajuda As String
         Get
            Ajuda = me.GetString("Ajuda")
         End Get
         Set(pValue As String)
            me.SetString("Ajuda", pValue)
         End Set
      End Property

      Property Exemplo As String
         Get
            Exemplo = me.GetString("Exemplo")
         End Get
         Set(pValue As String)
            me.SetString("Exemplo", pValue)
         End Set
      End Property

      Property Ativo As String
         Get
            Ativo = me.GetString("Ativo")
         End Get
         Set(pValue As String)
            me.SetString("Ativo", pValue)
         End Set
      End Property

      Property Arquivo As String
         Get
            Arquivo = me.GetString("Arquivo")
         End Get
         Set(pValue As String)
            me.SetString("Arquivo", pValue)
         End Set
      End Property

      Property NumeroCopia As Integer
         Get
            NumeroCopia = me.GetInteger("NumeroCopia")
         End Get
         Set(pValue As Integer)
            me.SetInteger("NumeroCopia", pValue)
         End Set
      End Property

      Property ImpressoraPadrao As String
         Get
            ImpressoraPadrao = me.GetString("ImpressoraPadrao")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraPadrao", pValue)
         End Set
      End Property

      Property Orientacao As String
         Get
            Orientacao = me.GetString("Orientacao")
         End Get
         Set(pValue As String)
            me.SetString("Orientacao", pValue)
         End Set
      End Property

      Property TamanhoPapel As Integer
         Get
            TamanhoPapel = me.GetInteger("TamanhoPapel")
         End Get
         Set(pValue As Integer)
            me.SetInteger("TamanhoPapel", pValue)
         End Set
      End Property

      Property Largura As Integer
         Get
            Largura = me.GetInteger("Largura")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Largura", pValue)
         End Set
      End Property

      Property Altura As Integer
         Get
            Altura = me.GetInteger("Altura")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Altura", pValue)
         End Set
      End Property

      Property Selecionado As String
         Get
            Selecionado = me.GetString("Selecionado")
         End Get
         Set(pValue As String)
            me.SetString("Selecionado", pValue)
         End Set
      End Property

      Property Solicitar As String
         Get
            Solicitar = me.GetString("Solicitar")
         End Get
         Set(pValue As String)
            me.SetString("Solicitar", pValue)
         End Set
      End Property

      Property Aviso As String
         Get
            Aviso = me.GetString("Aviso")
         End Get
         Set(pValue As String)
            me.SetString("Aviso", pValue)
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

      Property NomeArquivo As String
         Get
            NomeArquivo = me.GetString("NomeArquivo")
         End Get
         Set(pValue As String)
            me.SetString("NomeArquivo", pValue)
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

      Property CodEstacao As Integer
         Get
            CodEstacao = me.GetInteger("CodEstacao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEstacao", pValue)
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

      Property ArquivoFisico As String
         Get
            ArquivoFisico = me.GetString("ArquivoFisico")
         End Get
         Set(pValue As String)
            me.SetString("ArquivoFisico", pValue)
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

      Property Repx As String
         Get
            Repx = me.GetString("Repx")
         End Get
         Set(pValue As String)
            me.SetString("Repx", pValue)
         End Set
      End Property

      Property SalvarAutomaticamenteEmDisco As String
         Get
            SalvarAutomaticamenteEmDisco = me.GetString("SalvarAutomaticamenteEmDisco")
         End Get
         Set(pValue As String)
            me.SetString("SalvarAutomaticamenteEmDisco", pValue)
         End Set
      End Property

      Property PastaSalvarAutomaticamenteEmDisco As String
         Get
            PastaSalvarAutomaticamenteEmDisco = me.GetString("PastaSalvarAutomaticamenteEmDisco")
         End Get
         Set(pValue As String)
            me.SetString("PastaSalvarAutomaticamenteEmDisco", pValue)
         End Set
      End Property

      Property CodProjeto As Integer
         Get
            CodProjeto = me.GetInteger("CodProjeto")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodProjeto", pValue)
         End Set
      End Property

      Property ImprimirCapa As String
         Get
            ImprimirCapa = me.GetString("ImprimirCapa")
         End Get
         Set(pValue As String)
            me.SetString("ImprimirCapa", pValue)
         End Set
      End Property

      Property ExibirParametroCapaVazio As String
         Get
            ExibirParametroCapaVazio = me.GetString("ExibirParametroCapaVazio")
         End Get
         Set(pValue As String)
            me.SetString("ExibirParametroCapaVazio", pValue)
         End Set
      End Property

      Property Obrigatorio As String
         Get
            Obrigatorio = me.GetString("Obrigatorio")
         End Get
         Set(pValue As String)
            me.SetString("Obrigatorio", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
