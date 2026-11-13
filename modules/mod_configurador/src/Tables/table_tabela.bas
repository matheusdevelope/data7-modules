Imports TablesSchema
Imports TablesTable

Namespace table_tabela

   Class TTabela
      Inherits TTableOf<TTabela>

      Sub New()
         MyBase.New("TTabela")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Tabela"
         pSchema.Field("CodTabela").AsInteger().AutoCodeField()
         pSchema.Field("CodCampoAutoIncremento").AsInteger()
         pSchema.Field("CodCampoEstrutura").AsInteger()
         pSchema.Field("ControlaPorEmpresa").AsBoolean()
         pSchema.Field("CodGrupoTabela").AsInteger()
         pSchema.Field("Proprietario").AsString().MaxLen(2)
         pSchema.Field("CodDBSpaceTabela").AsInteger()
         pSchema.Field("CodDBSpaceIndice").AsInteger()
         pSchema.Field("Observacao").AsString().MaxLen(251)
         pSchema.Field("UtilizaGradeZebrada").AsBoolean()
         pSchema.Field("MargemEditor").AsInteger()
         pSchema.Field("ConfirmaInclusao").AsBoolean()
         pSchema.Field("ConfirmaAlteracao").AsBoolean()
         pSchema.Field("DesabilitaExclusao").AsBoolean()
         pSchema.Field("DesabilitaVisualizacao").AsBoolean()
         pSchema.Field("DesabilitaInclusao").AsBoolean()
         pSchema.Field("DesabilitaAlteracao").AsBoolean()
         pSchema.Field("ExibirDentroQuadroRolagem").AsBoolean()
         pSchema.Field("AlturaQuadroRolagem").AsInteger()
         pSchema.Field("EditaNaGrade").AsBoolean()
         pSchema.Field("CodTabelaEdicao").AsInteger()
         pSchema.Field("CodPastaTabelaEdicao").AsInteger()
         pSchema.Field("DllFormEdicao").AsString().MaxLen(101)
         pSchema.Field("Nome").AsString().MaxLen(101)
         pSchema.Field("Titulo").AsString().MaxLen(101)
         pSchema.Field("CodCampoLegenda1").AsInteger()
         pSchema.Field("CodCampoLegenda2").AsInteger()
         pSchema.Field("CodTabelaPropriedadeCampo").AsInteger()
         pSchema.Field("CodCampoPreferenciaPesquisa").AsInteger()
         pSchema.Field("TodosRegistrosNoInicio").AsBoolean()
         pSchema.Field("PermiteMultiplaSelecaoNaGrade").AsBoolean()
         pSchema.Field("UsarCacheDeObjeto").AsBoolean()
         pSchema.Field("CodCampoOrdemPadrao").AsInteger()
         pSchema.Field("OrdemCampoOrdemPadrao").AsString().MaxLen(2)
         pSchema.Field("InclusaoRecursiva").AsBoolean()
         pSchema.Field("Descricao").AsString().MaxLen(2001)
         pSchema.Field("LogProcessosAtivo").AsString().MaxLen(1)
         pSchema.Field("LogInclusaoAtivo").AsString().MaxLen(1)
         pSchema.Field("LogExclusaoAtivo").AsString().MaxLen(1)
         pSchema.Field("LogAlteracaoAtivo").AsString().MaxLen(1)
         pSchema.Field("FiltroFixoGrade").AsString().MaxLen(2000)
         pSchema.Field("ModeloLayout").AsString().MaxLen(1)
         pSchema.Field("CodRelatorioInclusao").AsInteger()
         pSchema.Field("ValidacaoInclusao").AsString().MaxLen(2000)
         pSchema.Field("ValidacaoAlteracao").AsString().MaxLen(2000)
         pSchema.Field("ValidacaoExclusao").AsString().MaxLen(2000)
         pSchema.Field("ValidacaoVisualizacao").AsString().MaxLen(2000)
         pSchema.Field("NomeSchema").AsString().MaxLen(50)
         pSchema.Field("ArquivoProjetoApoio").AsString().MaxLen(200)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodTabela)
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
         End Set
      End Property

      Property CodCampoAutoIncremento As Integer
         Get
            CodCampoAutoIncremento = me.GetInteger("CodCampoAutoIncremento")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoAutoIncremento", pValue)
         End Set
      End Property

      Property CodCampoEstrutura As Integer
         Get
            CodCampoEstrutura = me.GetInteger("CodCampoEstrutura")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoEstrutura", pValue)
         End Set
      End Property

      Property ControlaPorEmpresa As Boolean
         Get
            ControlaPorEmpresa = me.GetBoolean("ControlaPorEmpresa")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("ControlaPorEmpresa", pValue)
         End Set
      End Property

      Property CodGrupoTabela As Integer
         Get
            CodGrupoTabela = me.GetInteger("CodGrupoTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodGrupoTabela", pValue)
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

      Property CodDBSpaceTabela As Integer
         Get
            CodDBSpaceTabela = me.GetInteger("CodDBSpaceTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodDBSpaceTabela", pValue)
         End Set
      End Property

      Property CodDBSpaceIndice As Integer
         Get
            CodDBSpaceIndice = me.GetInteger("CodDBSpaceIndice")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodDBSpaceIndice", pValue)
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

      Property UtilizaGradeZebrada As Boolean
         Get
            UtilizaGradeZebrada = me.GetBoolean("UtilizaGradeZebrada")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("UtilizaGradeZebrada", pValue)
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

      Property ConfirmaInclusao As Boolean
         Get
            ConfirmaInclusao = me.GetBoolean("ConfirmaInclusao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("ConfirmaInclusao", pValue)
         End Set
      End Property

      Property ConfirmaAlteracao As Boolean
         Get
            ConfirmaAlteracao = me.GetBoolean("ConfirmaAlteracao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("ConfirmaAlteracao", pValue)
         End Set
      End Property

      Property DesabilitaExclusao As Boolean
         Get
            DesabilitaExclusao = me.GetBoolean("DesabilitaExclusao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("DesabilitaExclusao", pValue)
         End Set
      End Property

      Property DesabilitaVisualizacao As Boolean
         Get
            DesabilitaVisualizacao = me.GetBoolean("DesabilitaVisualizacao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("DesabilitaVisualizacao", pValue)
         End Set
      End Property

      Property DesabilitaInclusao As Boolean
         Get
            DesabilitaInclusao = me.GetBoolean("DesabilitaInclusao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("DesabilitaInclusao", pValue)
         End Set
      End Property

      Property DesabilitaAlteracao As Boolean
         Get
            DesabilitaAlteracao = me.GetBoolean("DesabilitaAlteracao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("DesabilitaAlteracao", pValue)
         End Set
      End Property

      Property ExibirDentroQuadroRolagem As Boolean
         Get
            ExibirDentroQuadroRolagem = me.GetBoolean("ExibirDentroQuadroRolagem")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("ExibirDentroQuadroRolagem", pValue)
         End Set
      End Property

      Property AlturaQuadroRolagem As Integer
         Get
            AlturaQuadroRolagem = me.GetInteger("AlturaQuadroRolagem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("AlturaQuadroRolagem", pValue)
         End Set
      End Property

      Property EditaNaGrade As Boolean
         Get
            EditaNaGrade = me.GetBoolean("EditaNaGrade")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("EditaNaGrade", pValue)
         End Set
      End Property

      Property CodTabelaEdicao As Integer
         Get
            CodTabelaEdicao = me.GetInteger("CodTabelaEdicao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabelaEdicao", pValue)
         End Set
      End Property

      Property CodPastaTabelaEdicao As Integer
         Get
            CodPastaTabelaEdicao = me.GetInteger("CodPastaTabelaEdicao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPastaTabelaEdicao", pValue)
         End Set
      End Property

      Property DllFormEdicao As String
         Get
            DllFormEdicao = me.GetString("DllFormEdicao")
         End Get
         Set(pValue As String)
            me.SetString("DllFormEdicao", pValue)
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

      Property Titulo As String
         Get
            Titulo = me.GetString("Titulo")
         End Get
         Set(pValue As String)
            me.SetString("Titulo", pValue)
         End Set
      End Property

      Property CodCampoLegenda1 As Integer
         Get
            CodCampoLegenda1 = me.GetInteger("CodCampoLegenda1")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoLegenda1", pValue)
         End Set
      End Property

      Property CodCampoLegenda2 As Integer
         Get
            CodCampoLegenda2 = me.GetInteger("CodCampoLegenda2")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoLegenda2", pValue)
         End Set
      End Property

      Property CodTabelaPropriedadeCampo As Integer
         Get
            CodTabelaPropriedadeCampo = me.GetInteger("CodTabelaPropriedadeCampo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabelaPropriedadeCampo", pValue)
         End Set
      End Property

      Property CodCampoPreferenciaPesquisa As Integer
         Get
            CodCampoPreferenciaPesquisa = me.GetInteger("CodCampoPreferenciaPesquisa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoPreferenciaPesquisa", pValue)
         End Set
      End Property

      Property TodosRegistrosNoInicio As Boolean
         Get
            TodosRegistrosNoInicio = me.GetBoolean("TodosRegistrosNoInicio")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("TodosRegistrosNoInicio", pValue)
         End Set
      End Property

      Property PermiteMultiplaSelecaoNaGrade As Boolean
         Get
            PermiteMultiplaSelecaoNaGrade = me.GetBoolean("PermiteMultiplaSelecaoNaGrade")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermiteMultiplaSelecaoNaGrade", pValue)
         End Set
      End Property

      Property UsarCacheDeObjeto As Boolean
         Get
            UsarCacheDeObjeto = me.GetBoolean("UsarCacheDeObjeto")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("UsarCacheDeObjeto", pValue)
         End Set
      End Property

      Property CodCampoOrdemPadrao As Integer
         Get
            CodCampoOrdemPadrao = me.GetInteger("CodCampoOrdemPadrao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampoOrdemPadrao", pValue)
         End Set
      End Property

      Property OrdemCampoOrdemPadrao As String
         Get
            OrdemCampoOrdemPadrao = me.GetString("OrdemCampoOrdemPadrao")
         End Get
         Set(pValue As String)
            me.SetString("OrdemCampoOrdemPadrao", pValue)
         End Set
      End Property

      Property InclusaoRecursiva As Boolean
         Get
            InclusaoRecursiva = me.GetBoolean("InclusaoRecursiva")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("InclusaoRecursiva", pValue)
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

      Property LogProcessosAtivo As String
         Get
            LogProcessosAtivo = me.GetString("LogProcessosAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogProcessosAtivo", pValue)
         End Set
      End Property

      Property LogInclusaoAtivo As String
         Get
            LogInclusaoAtivo = me.GetString("LogInclusaoAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogInclusaoAtivo", pValue)
         End Set
      End Property

      Property LogExclusaoAtivo As String
         Get
            LogExclusaoAtivo = me.GetString("LogExclusaoAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogExclusaoAtivo", pValue)
         End Set
      End Property

      Property LogAlteracaoAtivo As String
         Get
            LogAlteracaoAtivo = me.GetString("LogAlteracaoAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogAlteracaoAtivo", pValue)
         End Set
      End Property

      Property FiltroFixoGrade As String
         Get
            FiltroFixoGrade = me.GetString("FiltroFixoGrade")
         End Get
         Set(pValue As String)
            me.SetString("FiltroFixoGrade", pValue)
         End Set
      End Property

      Property ModeloLayout As String
         Get
            ModeloLayout = me.GetString("ModeloLayout")
         End Get
         Set(pValue As String)
            me.SetString("ModeloLayout", pValue)
         End Set
      End Property

      Property CodRelatorioInclusao As Integer
         Get
            CodRelatorioInclusao = me.GetInteger("CodRelatorioInclusao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodRelatorioInclusao", pValue)
         End Set
      End Property

      Property ValidacaoInclusao As String
         Get
            ValidacaoInclusao = me.GetString("ValidacaoInclusao")
         End Get
         Set(pValue As String)
            me.SetString("ValidacaoInclusao", pValue)
         End Set
      End Property

      Property ValidacaoAlteracao As String
         Get
            ValidacaoAlteracao = me.GetString("ValidacaoAlteracao")
         End Get
         Set(pValue As String)
            me.SetString("ValidacaoAlteracao", pValue)
         End Set
      End Property

      Property ValidacaoExclusao As String
         Get
            ValidacaoExclusao = me.GetString("ValidacaoExclusao")
         End Get
         Set(pValue As String)
            me.SetString("ValidacaoExclusao", pValue)
         End Set
      End Property

      Property ValidacaoVisualizacao As String
         Get
            ValidacaoVisualizacao = me.GetString("ValidacaoVisualizacao")
         End Get
         Set(pValue As String)
            me.SetString("ValidacaoVisualizacao", pValue)
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

      Property ArquivoProjetoApoio As String
         Get
            ArquivoProjetoApoio = me.GetString("ArquivoProjetoApoio")
         End Get
         Set(pValue As String)
            me.SetString("ArquivoProjetoApoio", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
