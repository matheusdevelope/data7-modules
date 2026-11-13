Imports TablesSchema
Imports TablesTable

Namespace table_pesquisapadrao

   Class TPesquisaPadrao
      Inherits TTableOf<TPesquisaPadrao>

      Sub New()
         MyBase.New("TPesquisaPadrao")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "PesquisaPadrao"
         pSchema.Field("CodTabela").AsInteger().RequiredField()
         pSchema.Field("CodPesquisaPadrao").AsInteger().AutoCodeField()
         pSchema.Field("CodCampoDescricao").AsInteger()
         pSchema.Field("Titulo").AsString().MaxLen(51)
         pSchema.Field("proprietario").AsString().MaxLen(2)
         pSchema.Field("PermiteExcluir").AsString().MaxLen(2)
         pSchema.Field("PermiteIncluir").AsString().MaxLen(2)
         pSchema.Field("AbrirPosicionado").AsString().MaxLen(2)
         pSchema.Field("ExpressaoFiltro").AsString().MaxLen(8000)
         pSchema.Field("CodImagem").AsInteger()
         pSchema.Field("CodCampoChave").AsInteger()
         pSchema.Field("DllFormPesquisa").AsString().MaxLen(101)
         pSchema.Field("ExibirDesativado").AsString().MaxLen(2)
         pSchema.Field("CodScripter").AsInteger()
         pSchema.Field("ManterUltimoFiltro").AsString().MaxLen(3)
         pSchema.Field("PermiteCadastroDireto").AsString().MaxLen(3)
         pSchema.Field("CodTabelaCadastroDireto").AsInteger()
         pSchema.Field("PermiteInclusaoCadastroDireto").AsString().MaxLen(3)
         pSchema.Field("PermiteAlteracaoCadastroDireto").AsString().MaxLen(3)
         pSchema.Field("PermiteVisualizarCadastroDireto").AsString().MaxLen(3)
         pSchema.Field("AtalhoAbrirPesquisa").AsString().MaxLen(30)
         pSchema.Field("AtalhoInclusao").AsString().MaxLen(30)
         pSchema.Field("AtalhoAlteracao").AsString().MaxLen(30)
         pSchema.Field("AtalhoVisualizacao").AsString().MaxLen(30)
         pSchema.Field("ExibeBotaoInclusao").AsString().MaxLen(3)
         pSchema.Field("ExibeBotaoAlteracao").AsString().MaxLen(3)
         pSchema.Field("ExibeBotaoVisualizacao").AsString().MaxLen(3)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodPesquisaPadrao)
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
         End Set
      End Property

      Property CodPesquisaPadrao As Integer
         Get
            CodPesquisaPadrao = me.GetInteger("CodPesquisaPadrao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPesquisaPadrao", pValue)
         End Set
      End Property

      Property CodCampoDescricao As Integer
         Get
            CodCampoDescricao = me.GetInteger("CodCampoDescricao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoDescricao", pValue)
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

      Property PermiteExcluir As String
         Get
            PermiteExcluir = me.GetString("PermiteExcluir")
         End Get
         Set(pValue As String)
            me.SetString("PermiteExcluir", pValue)
         End Set
      End Property

      Property PermiteIncluir As String
         Get
            PermiteIncluir = me.GetString("PermiteIncluir")
         End Get
         Set(pValue As String)
            me.SetString("PermiteIncluir", pValue)
         End Set
      End Property

      Property AbrirPosicionado As String
         Get
            AbrirPosicionado = me.GetString("AbrirPosicionado")
         End Get
         Set(pValue As String)
            me.SetString("AbrirPosicionado", pValue)
         End Set
      End Property

      Property ExpressaoFiltro As String
         Get
            ExpressaoFiltro = me.GetString("ExpressaoFiltro")
         End Get
         Set(pValue As String)
            me.SetString("ExpressaoFiltro", pValue)
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

      Property CodCampoChave As Integer
         Get
            CodCampoChave = me.GetInteger("CodCampoChave")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoChave", pValue)
         End Set
      End Property

      Property DllFormPesquisa As String
         Get
            DllFormPesquisa = me.GetString("DllFormPesquisa")
         End Get
         Set(pValue As String)
            me.SetString("DllFormPesquisa", pValue)
         End Set
      End Property

      Property ExibirDesativado As String
         Get
            ExibirDesativado = me.GetString("ExibirDesativado")
         End Get
         Set(pValue As String)
            me.SetString("ExibirDesativado", pValue)
         End Set
      End Property

      Property CodScripter As Integer
         Get
            CodScripter = me.GetInteger("CodScripter")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodScripter", pValue)
         End Set
      End Property

      Property ManterUltimoFiltro As String
         Get
            ManterUltimoFiltro = me.GetString("ManterUltimoFiltro")
         End Get
         Set(pValue As String)
            me.SetString("ManterUltimoFiltro", pValue)
         End Set
      End Property

      Property PermiteCadastroDireto As String
         Get
            PermiteCadastroDireto = me.GetString("PermiteCadastroDireto")
         End Get
         Set(pValue As String)
            me.SetString("PermiteCadastroDireto", pValue)
         End Set
      End Property

      Property CodTabelaCadastroDireto As Integer
         Get
            CodTabelaCadastroDireto = me.GetInteger("CodTabelaCadastroDireto")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabelaCadastroDireto", pValue)
         End Set
      End Property

      Property PermiteInclusaoCadastroDireto As String
         Get
            PermiteInclusaoCadastroDireto = me.GetString("PermiteInclusaoCadastroDireto")
         End Get
         Set(pValue As String)
            me.SetString("PermiteInclusaoCadastroDireto", pValue)
         End Set
      End Property

      Property PermiteAlteracaoCadastroDireto As String
         Get
            PermiteAlteracaoCadastroDireto = me.GetString("PermiteAlteracaoCadastroDireto")
         End Get
         Set(pValue As String)
            me.SetString("PermiteAlteracaoCadastroDireto", pValue)
         End Set
      End Property

      Property PermiteVisualizarCadastroDireto As String
         Get
            PermiteVisualizarCadastroDireto = me.GetString("PermiteVisualizarCadastroDireto")
         End Get
         Set(pValue As String)
            me.SetString("PermiteVisualizarCadastroDireto", pValue)
         End Set
      End Property

      Property AtalhoAbrirPesquisa As String
         Get
            AtalhoAbrirPesquisa = me.GetString("AtalhoAbrirPesquisa")
         End Get
         Set(pValue As String)
            me.SetString("AtalhoAbrirPesquisa", pValue)
         End Set
      End Property

      Property AtalhoInclusao As String
         Get
            AtalhoInclusao = me.GetString("AtalhoInclusao")
         End Get
         Set(pValue As String)
            me.SetString("AtalhoInclusao", pValue)
         End Set
      End Property

      Property AtalhoAlteracao As String
         Get
            AtalhoAlteracao = me.GetString("AtalhoAlteracao")
         End Get
         Set(pValue As String)
            me.SetString("AtalhoAlteracao", pValue)
         End Set
      End Property

      Property AtalhoVisualizacao As String
         Get
            AtalhoVisualizacao = me.GetString("AtalhoVisualizacao")
         End Get
         Set(pValue As String)
            me.SetString("AtalhoVisualizacao", pValue)
         End Set
      End Property

      Property ExibeBotaoInclusao As String
         Get
            ExibeBotaoInclusao = me.GetString("ExibeBotaoInclusao")
         End Get
         Set(pValue As String)
            me.SetString("ExibeBotaoInclusao", pValue)
         End Set
      End Property

      Property ExibeBotaoAlteracao As String
         Get
            ExibeBotaoAlteracao = me.GetString("ExibeBotaoAlteracao")
         End Get
         Set(pValue As String)
            me.SetString("ExibeBotaoAlteracao", pValue)
         End Set
      End Property

      Property ExibeBotaoVisualizacao As String
         Get
            ExibeBotaoVisualizacao = me.GetString("ExibeBotaoVisualizacao")
         End Get
         Set(pValue As String)
            me.SetString("ExibeBotaoVisualizacao", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
