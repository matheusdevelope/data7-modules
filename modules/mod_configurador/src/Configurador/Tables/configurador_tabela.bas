Imports configurador_grupotabela
Imports configurador_campo
Imports configurador_legenda
Imports configurador_pasta
Imports configurador_filtro
Imports configurador_pesquisa
Imports configurador_processo
Imports configurador_ajuda
Imports configurador_acesso_tabela
Imports configurador_acesso_processo
Imports configurador_relatorio
Imports configurador_sql
Imports configurador_tcfgbase
Imports TablesSql
Imports configurador_lote
Imports Collections
Imports configurador_campo_busca
Imports TablesField
Imports mod_logger


Namespace configurador_tabela

   Class Tabela
      Inherits TCfgBase

      CodTabela As Integer
      CodCampoAutoIncremento As Integer
      CodCampoEstrutura As Integer
      CodGrupoTabela As Integer
      CodDBSpaceTabela As Integer
      CodDBSpaceIndice As Integer
      MargemEditor As Integer
      AlturaQuadroRolagem As Integer
      CodTabelaEdicao As Integer
      CodPastaTabelaEdicao As Integer
      CodCampoLegenda1 As Integer
      CodCampoLegenda2 As Integer
      CodTabelaPropriedadeCampo As Integer
      CodCampoPreferenciaPesquisa As Integer
      CodCampoOrdemPadrao As Integer
      CodRelatorioInclusao As Integer
      Proprietario As String
      Observacao As String
      DllFormEdicao As String
      Nome As String
      Titulo As String
      OrdemCampoOrdemPadrao As String
      Descricao As String
      LogProcessosAtivo As String
      LogInclusaoAtivo As String
      LogExclusaoAtivo As String
      LogAlteracaoAtivo As String
      FiltroFixoGrade As String
      ModeloLayout As String
      ValidacaoInclusao As String
      ValidacaoAlteracao As String
      ValidacaoExclusao As String
      ValidacaoVisualizacao As String
      NomeSchema As String
      ArquivoProjetoApoio As String

      ControlaPorEmpresa As Boolean
      UtilizaGradeZebrada As Boolean
      ConfirmaInclusao As Boolean
      ConfirmaAlteracao As Boolean
      DesabilitaExclusao As Boolean
      DesabilitaVisualizacao As Boolean
      DesabilitaInclusao As Boolean
      DesabilitaAlteracao As Boolean
      ExibirDentroQuadroRolagem As Boolean
      EditaNaGrade As Boolean
      TodosRegistrosNoInicio As Boolean
      PermiteMultiplaSelecaoNaGrade As Boolean
      UsarCacheDeObjeto As Boolean
      InclusaoRecursiva As Boolean

      Grupo As GrupoTabela
      Campos[] As Campo
      Pastas[] As Pasta
      Legendas[] As Legenda
      Filtros[] As Filtro
      Pesquisas[] As Pesquisa
      Processos[] As Processo
      Ajudas[] As Ajuda
      Acesso As AcessoTabela
      Private _relatorioInclusao As Relatorio
      Private _relatorioInclusaoPronto As Boolean

      Sub New()
         MyBase.New("Tabela")
         me.InitColecoes()
      End Sub

      Sub New(pCodTabela As Integer)
         MyBase.New("Tabela")
         me.InitColecoes()
         me.CarregarPorWhere(TCfgSql.Tabela(pCodTabela), "Tabela não encontrada: codtabela=" & CStr(pCodTabela))
      End Sub

      Sub New(pNome As String, pSchema As String = "")
         MyBase.New("Tabela")
         me.InitColecoes()
         Dim erro As String
         If Trim(pSchema) = "" Then
            erro = "Tabela não encontrada: " & Trim(pNome)
         Else
            erro = "Tabela não encontrada: " & Trim(pSchema) & "." & Trim(pNome)
         End If
         me.CarregarPorWhere(TCfgSql.NomeSchema(pNome, pSchema), erro)
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodCampoAutoIncremento = pQuery.Field("codcampoautoincremento").AsInteger
         me.CodCampoEstrutura = pQuery.Field("codcampoestrutura").AsInteger
         me.ControlaPorEmpresa = me.GetFlagAsBoolean(pQuery.Field("controlaporempresa").AsString)
         me.CodGrupoTabela = pQuery.Field("codgrupotabela").AsInteger
         me.Proprietario = pQuery.Field("proprietario").AsString
         me.CodDBSpaceTabela = pQuery.Field("coddbspacetabela").AsInteger
         me.CodDBSpaceIndice = pQuery.Field("coddbspaceindice").AsInteger
         me.Observacao = pQuery.Field("observacao").AsString
         me.UtilizaGradeZebrada = me.GetFlagAsBoolean(pQuery.Field("utilizagradezebrada").AsString)
         me.MargemEditor = pQuery.Field("margemeditor").AsInteger
         me.ConfirmaInclusao = me.GetFlagAsBoolean(pQuery.Field("confirmainclusao").AsString)
         me.ConfirmaAlteracao = me.GetFlagAsBoolean(pQuery.Field("confirmaalteracao").AsString)
         me.DesabilitaExclusao = me.GetFlagAsBoolean(pQuery.Field("desabilitaexclusao").AsString)
         me.DesabilitaVisualizacao = me.GetFlagAsBoolean(pQuery.Field("desabilitavisualizacao").AsString)
         me.DesabilitaInclusao = me.GetFlagAsBoolean(pQuery.Field("desabilitainclusao").AsString)
         me.DesabilitaAlteracao = me.GetFlagAsBoolean(pQuery.Field("desabilitaalteracao").AsString)
         me.ExibirDentroQuadroRolagem = me.GetFlagAsBoolean(pQuery.Field("exibirdentroquadrorolagem").AsString)
         me.AlturaQuadroRolagem = pQuery.Field("alturaquadrorolagem").AsInteger
         me.EditaNaGrade = me.GetFlagAsBoolean(pQuery.Field("editanagrade").AsString)
         me.CodTabelaEdicao = pQuery.Field("codtabelaedicao").AsInteger
         me.CodPastaTabelaEdicao = pQuery.Field("codpastatabelaedicao").AsInteger
         me.DllFormEdicao = pQuery.Field("dllformedicao").AsString
         me.Nome = pQuery.Field("nome").AsString
         me.Titulo = pQuery.Field("titulo").AsString
         me.CodCampoLegenda1 = pQuery.Field("codcampolegenda1").AsInteger
         me.CodCampoLegenda2 = pQuery.Field("codcampolegenda2").AsInteger
         me.CodTabelaPropriedadeCampo = pQuery.Field("codtabelapropriedadecampo").AsInteger
         me.CodCampoPreferenciaPesquisa = pQuery.Field("codcampopreferenciapesquisa").AsInteger
         me.TodosRegistrosNoInicio = me.GetFlagAsBoolean(pQuery.Field("todosregistrosnoinicio").AsString)
         me.PermiteMultiplaSelecaoNaGrade = me.GetFlagAsBoolean(pQuery.Field("permitemultiplaselecaonagrade").AsString)
         me.UsarCacheDeObjeto = me.GetFlagAsBoolean(pQuery.Field("usarcachedeobjeto").AsString)
         me.CodCampoOrdemPadrao = pQuery.Field("codcampoordempadrao").AsInteger
         me.OrdemCampoOrdemPadrao = pQuery.Field("ordemcampoordempadrao").AsString
         me.InclusaoRecursiva = me.GetFlagAsBoolean(pQuery.Field("inclusaorecursiva").AsString)
         me.Descricao = pQuery.Field("descricao").AsString
         me.LogProcessosAtivo = pQuery.Field("logprocessosativo").AsString
         me.LogInclusaoAtivo = pQuery.Field("loginclusaoativo").AsString
         me.LogExclusaoAtivo = pQuery.Field("logexclusaoativo").AsString
         me.LogAlteracaoAtivo = pQuery.Field("logalteracaoativo").AsString
         me.FiltroFixoGrade = pQuery.Field("filtrofixograde").AsString
         me.ModeloLayout = pQuery.Field("modelolayout").AsString
         me.CodRelatorioInclusao = pQuery.Field("codrelatorioinclusao").AsInteger
         me.ValidacaoInclusao = pQuery.Field("validacaoinclusao").AsString
         me.ValidacaoAlteracao = pQuery.Field("validacaoalteracao").AsString
         me.ValidacaoExclusao = pQuery.Field("validacaoexclusao").AsString
         me.ValidacaoVisualizacao = pQuery.Field("validacaovisualizacao").AsString
         me.NomeSchema = pQuery.Field("nomeschema").AsString
         me.ArquivoProjetoApoio = pQuery.Field("arquivoprojetoapoio").AsString
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodCampoAutoIncremento = TCfgRow.AsInteger(pJson.GetString("codcampoautoincremento"))
         me.CodCampoEstrutura = TCfgRow.AsInteger(pJson.GetString("codcampoestrutura"))
         me.ControlaPorEmpresa = me.GetFlagAsBoolean(pJson.GetString("controlaporempresa"))
         me.CodGrupoTabela = TCfgRow.AsInteger(pJson.GetString("codgrupotabela"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
         me.CodDBSpaceTabela = TCfgRow.AsInteger(pJson.GetString("coddbspacetabela"))
         me.CodDBSpaceIndice = TCfgRow.AsInteger(pJson.GetString("coddbspaceindice"))
         me.Observacao = TCfgRow.AsString(pJson.GetString("observacao"))
         me.UtilizaGradeZebrada = me.GetFlagAsBoolean(pJson.GetString("utilizagradezebrada"))
         me.MargemEditor = TCfgRow.AsInteger(pJson.GetString("margemeditor"))
         me.ConfirmaInclusao = me.GetFlagAsBoolean(pJson.GetString("confirmainclusao"))
         me.ConfirmaAlteracao = me.GetFlagAsBoolean(pJson.GetString("confirmaalteracao"))
         me.DesabilitaExclusao = me.GetFlagAsBoolean(pJson.GetString("desabilitaexclusao"))
         me.DesabilitaVisualizacao = me.GetFlagAsBoolean(pJson.GetString("desabilitavisualizacao"))
         me.DesabilitaInclusao = me.GetFlagAsBoolean(pJson.GetString("desabilitainclusao"))
         me.DesabilitaAlteracao = me.GetFlagAsBoolean(pJson.GetString("desabilitaalteracao"))
         me.ExibirDentroQuadroRolagem = me.GetFlagAsBoolean(pJson.GetString("exibirdentroquadrorolagem"))
         me.AlturaQuadroRolagem = TCfgRow.AsInteger(pJson.GetString("alturaquadrorolagem"))
         me.EditaNaGrade = me.GetFlagAsBoolean(pJson.GetString("editanagrade"))
         me.CodTabelaEdicao = TCfgRow.AsInteger(pJson.GetString("codtabelaedicao"))
         me.CodPastaTabelaEdicao = TCfgRow.AsInteger(pJson.GetString("codpastatabelaedicao"))
         me.DllFormEdicao = TCfgRow.AsString(pJson.GetString("dllformedicao"))
         me.Nome = TCfgRow.AsString(pJson.GetString("nome"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.CodCampoLegenda1 = TCfgRow.AsInteger(pJson.GetString("codcampolegenda1"))
         me.CodCampoLegenda2 = TCfgRow.AsInteger(pJson.GetString("codcampolegenda2"))
         me.CodTabelaPropriedadeCampo = TCfgRow.AsInteger(pJson.GetString("codtabelapropriedadecampo"))
         me.CodCampoPreferenciaPesquisa = TCfgRow.AsInteger(pJson.GetString("codcampopreferenciapesquisa"))
         me.TodosRegistrosNoInicio = me.GetFlagAsBoolean(pJson.GetString("todosregistrosnoinicio"))
         me.PermiteMultiplaSelecaoNaGrade = me.GetFlagAsBoolean(pJson.GetString("permitemultiplaselecaonagrade"))
         me.UsarCacheDeObjeto = me.GetFlagAsBoolean(pJson.GetString("usarcachedeobjeto"))
         me.CodCampoOrdemPadrao = TCfgRow.AsInteger(pJson.GetString("codcampoordempadrao"))
         me.OrdemCampoOrdemPadrao = TCfgRow.AsString(pJson.GetString("ordemcampoordempadrao"))
         me.InclusaoRecursiva = me.GetFlagAsBoolean(pJson.GetString("inclusaorecursiva"))
         me.Descricao = TCfgRow.AsString(pJson.GetString("descricao"))
         me.LogProcessosAtivo = TCfgRow.AsString(pJson.GetString("logprocessosativo"))
         me.LogInclusaoAtivo = TCfgRow.AsString(pJson.GetString("loginclusaoativo"))
         me.LogExclusaoAtivo = TCfgRow.AsString(pJson.GetString("logexclusaoativo"))
         me.LogAlteracaoAtivo = TCfgRow.AsString(pJson.GetString("logalteracaoativo"))
         me.FiltroFixoGrade = TCfgRow.AsString(pJson.GetString("filtrofixograde"))
         me.ModeloLayout = TCfgRow.AsString(pJson.GetString("modelolayout"))
         me.CodRelatorioInclusao = TCfgRow.AsInteger(pJson.GetString("codrelatorioinclusao"))
         me.ValidacaoInclusao = TCfgRow.AsString(pJson.GetString("validacaoinclusao"))
         me.ValidacaoAlteracao = TCfgRow.AsString(pJson.GetString("validacaoalteracao"))
         me.ValidacaoExclusao = TCfgRow.AsString(pJson.GetString("validacaoexclusao"))
         me.ValidacaoVisualizacao = TCfgRow.AsString(pJson.GetString("validacaovisualizacao"))
         me.NomeSchema = TCfgRow.AsString(pJson.GetString("nomeschema"))
         me.ArquivoProjetoApoio = TCfgRow.AsString(pJson.GetString("arquivoprojetoapoio"))
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodTabela)
      End Function 

      Overrides Function ToString() As String
         Dim _null As String = "Null"
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodCampoAutoIncremento", me.CodCampoAutoIncremento)
            .Prop("CodCampoEstrutura", me.CodCampoEstrutura)
            .Prop("ControlaPorEmpresa", me.ControlaPorEmpresa)
            .Prop("CodGrupoTabela", me.CodGrupoTabela)
            .Prop("Proprietario", me.Proprietario)
            .Prop("CodDBSpaceTabela", me.CodDBSpaceTabela)
            .Prop("CodDBSpaceIndice", me.CodDBSpaceIndice)
            .Prop("Observacao", me.Observacao)
            .Prop("UtilizaGradeZebrada", me.UtilizaGradeZebrada)
            .Prop("MargemEditor", me.MargemEditor)
            .Prop("ConfirmaInclusao", me.ConfirmaInclusao)
            .Prop("ConfirmaAlteracao", me.ConfirmaAlteracao)
            .Prop("DesabilitaExclusao", me.DesabilitaExclusao)
            .Prop("DesabilitaVisualizacao", me.DesabilitaVisualizacao)
            .Prop("DesabilitaInclusao", me.DesabilitaInclusao)
            .Prop("DesabilitaAlteracao", me.DesabilitaAlteracao)
            .Prop("ExibirDentroQuadroRolagem", me.ExibirDentroQuadroRolagem)
            .Prop("AlturaQuadroRolagem", me.AlturaQuadroRolagem)
            .Prop("EditaNaGrade", me.EditaNaGrade)
            .Prop("CodTabelaEdicao", me.CodTabelaEdicao)
            .Prop("CodPastaTabelaEdicao", me.CodPastaTabelaEdicao)
            .Prop("DllFormEdicao", me.DllFormEdicao)
            .Prop("Nome", me.Nome)
            .Prop("Titulo", me.Titulo)
            .Prop("CodCampoLegenda1", me.CodCampoLegenda1)
            .Prop("CodCampoLegenda2", me.CodCampoLegenda2)
            .Prop("CodTabelaPropriedadeCampo", me.CodTabelaPropriedadeCampo)
            .Prop("CodCampoPreferenciaPesquisa", me.CodCampoPreferenciaPesquisa)
            .Prop("TodosRegistrosNoInicio", me.TodosRegistrosNoInicio)
            .Prop("PermiteMultiplaSelecaoNaGrade", me.PermiteMultiplaSelecaoNaGrade)
            .Prop("UsarCacheDeObjeto", me.UsarCacheDeObjeto)
            .Prop("CodCampoOrdemPadrao", me.CodCampoOrdemPadrao)
            .Prop("OrdemCampoOrdemPadrao", me.OrdemCampoOrdemPadrao)
            .Prop("InclusaoRecursiva", me.InclusaoRecursiva)
            .Prop("Descricao", me.Descricao)
            .Prop("LogProcessosAtivo", me.LogProcessosAtivo)
            .Prop("LogInclusaoAtivo", me.LogInclusaoAtivo)
            .Prop("LogExclusaoAtivo", me.LogExclusaoAtivo)
            .Prop("LogAlteracaoAtivo", me.LogAlteracaoAtivo)
            .Prop("FiltroFixoGrade", me.FiltroFixoGrade)
            .Prop("ModeloLayout", me.ModeloLayout)
            .Prop("CodRelatorioInclusao", me.CodRelatorioInclusao)
            .Prop("ValidacaoInclusao", me.ValidacaoInclusao)
            .Prop("ValidacaoAlteracao", me.ValidacaoAlteracao)
            .Prop("ValidacaoExclusao", me.ValidacaoExclusao)
            .Prop("ValidacaoVisualizacao", me.ValidacaoVisualizacao)
            .Prop("NomeSchema", me.NomeSchema)
            .Prop("ArquivoProjetoApoio", me.ArquivoProjetoApoio)
            If Assigned(me.Grupo) Then
               .Prop("Grupo", me.Grupo.ToString())
            Else
               .Prop("Grupo", _null)
            End If
            If Assigned(me.Acesso) Then
               .Prop("Acesso", me.Acesso.ToString())
            Else
               .Prop("Acesso", _null)
            End If
            If Assigned(me.RelatorioInclusao) Then
               .Prop("RelatorioInclusao", me.RelatorioInclusao.ToString())
            Else
               .Prop("RelatorioInclusao", _null)
            End If
            If Assigned(me.Campos) Then
               .Prop("Campos", me.Campos.Length)
            Else
               .Prop("Campos", _null)
            End If
            If Assigned(me.Pastas) Then
               .Prop("Pastas", me.Pastas.Length)
            Else
               .Prop("Pastas", _null)
            End If
            If Assigned(me.Legendas) Then
               .Prop("Legendas", me.Legendas.Length)
            Else
               .Prop("Legendas", _null)
            End If
            If Assigned(me.Filtros) Then
               .Prop("Filtros", me.Filtros.Length)
            Else
               .Prop("Filtros", _null)
            End If
            If Assigned(me.Pesquisas) Then
               .Prop("Pesquisas", me.Pesquisas.Length)
            Else
               .Prop("Pesquisas", _null)
            End If
            If Assigned(me.Processos) Then
               .Prop("Processos", me.Processos.Length)
            Else
               .Prop("Processos", _null)
            End If
            If Assigned(me.Ajudas) Then
               .Prop("Ajudas", me.Ajudas.Length)
            Else
               .Prop("Ajudas", _null)
            End If
            ToString = .Text
            .Free()
         End With
      End Function

      Private Sub GarantirNomeSchema()
         If Trim(me.NomeSchema) = "" Then
            me.NomeSchema = TSql.Dialect().DefaultSchema()
         End If
      End Sub

      Private Sub InitColecoes()
         me.Grupo = Null
         me._relatorioInclusao = Null
         me._relatorioInclusaoPronto = False
         me.Campos = []
         me.Pastas = []
         me.Legendas = []
         me.Filtros = []
         me.Pesquisas = []
         me.Processos = []
         me.Ajudas = []
         me.Acesso = New AcessoTabela()
      End Sub

      Private Sub CarregarPorWhere(pWhere As String, pErro As String)
         If PacoteTabela.SuportaJson() Then
            Dim pacote As PacoteTabela = me.CarregarPacoteJson(pWhere)
            If Not Assigned(pacote) Then
               Throw New Exception(pErro)
            End If
            me.FinalizarCarga(pacote)
         Else
            Dim query As SQL.Command = TCfgDb.Abrir("", "Tabela", pWhere, "")
            If query.Eof Then
               query.Close()
               query.Free()
               Throw New Exception(pErro)
            End If
            me.Fill(query)
            query.Close()
            query.Free()
            me.FinalizarCarga(PacoteTabela.Fetch(me.CodTabela))
         End If
      End Sub

      Private Function CarregarPacoteJson(pWhere As String) As PacoteTabela
         Dim _sql As String = PacoteTabela.SqlDefinicao(pWhere)
         Dim query As SQL.Command = TSql.OpenQuery(_sql)
         If query.Eof Then
            query.Close()
            query.Free()
            CarregarPacoteJson = Null
            Exit Function
         End If
         me.Fill(query)
         Dim pacote As PacoteTabela = PacoteTabela.DoQuery(query)
         query.Close()
         query.Free()
         CarregarPacoteJson = pacote
      End Function

      Private Sub FinalizarCarga(pPacote As PacoteTabela)
         me.GarantirNomeSchema()
         me.Acesso.CodTabela = me.CodTabela
         me.AplicarPacote(pPacote)
         If (Not Assigned(me.Grupo)) And (me.CodGrupoTabela <> 0) Then
            me.Grupo = GrupoTabela.Find(me.CodGrupoTabela)
         End If
         me.LigarNavegacao()
      End Sub

      Private Sub AplicarPacote(pPacote As PacoteTabela)
         me.Campos.Free()
         me.Campos = pPacote.Campos
         pPacote.Campos = Null
         me.Pastas.Free()
         me.Pastas = pPacote.Pastas
         pPacote.Pastas = Null
         me.Legendas.Free()
         me.Legendas = pPacote.Legendas
         pPacote.Legendas = Null
         me.Filtros.Free()
         me.Filtros = pPacote.Filtros
         pPacote.Filtros = Null
         me.Pesquisas.Free()
         me.Pesquisas = pPacote.Pesquisas
         pPacote.Pesquisas = Null
         me.Processos.Free()
         me.Processos = pPacote.Processos
         pPacote.Processos = Null
         me.Ajudas.Free()
         me.Ajudas = pPacote.Ajudas
         pPacote.Ajudas = Null
         me.Grupo = pPacote.Grupo
         pPacote.Grupo = Null
         pPacote.Free()
      End Sub

      Property RelatorioInclusao As Relatorio
         Get
            If Not me._relatorioInclusaoPronto Then
               me._relatorioInclusaoPronto = True
               If me.CodRelatorioInclusao <> 0 Then
                  me._relatorioInclusao = Relatorio.Carregar(me.CodRelatorioInclusao)
               End If
            End If
            RelatorioInclusao = me._relatorioInclusao
         End Get
      End Property

      Private Sub LigarNavegacao()
         Dim mapPasta As New StringList()
         mapPasta.OwnsObjects = False
         Dim mapPesquisa As New StringList()
         mapPesquisa.OwnsObjects = False
         Dim mapCampo As New StringList()
         mapCampo.OwnsObjects = False
         Dim i As Integer
         Dim j As Integer
         Dim count As Integer = me.Pastas.Length - 1
         For i = 0 To count
            Dim pastaItem As Pasta = me.Pastas.Take(i)
            mapPasta.AddObject(CStr(pastaItem.CodPasta), pastaItem)
         Next
         count = me.Pesquisas.Length - 1
         For i = 0 To count
            Dim pesquisaItem1 As Pesquisa = me.Pesquisas.Take(i)
            mapPesquisa.AddObject(CStr(pesquisaItem1.CodPesquisaPadrao), pesquisaItem1)
         Next
         count = me.Campos.Length - 1
         For i = 0 To count
            Dim campoItem As Campo = me.Campos.Take(i)
            mapCampo.AddObject(CStr(campoItem.CodCampo), campoItem)
            If campoItem.CodPasta <> 0 Then
               Dim idxPasta As Integer = mapPasta.IndexOf(CStr(campoItem.CodPasta))
               If idxPasta >= 0 Then
                  campoItem.Pasta = CType(mapPasta.Objects(idxPasta), Pasta)
                  campoItem.Pasta.Campos.Push(campoItem)
               End If
            End If
            If campoItem.CodPesquisaPadrao <> 0 Then
               Dim idxPesq As Integer = mapPesquisa.IndexOf(CStr(campoItem.CodPesquisaPadrao))
               If idxPesq >= 0 Then
                  campoItem.Pesquisa = CType(mapPesquisa.Objects(idxPesq), Pesquisa)
               End If
            End If
         Next
         count = me.Pesquisas.Length - 1
         For i = 0 To count
            Dim pesquisaItem As Pesquisa = me.Pesquisas.Take(i)
            If pesquisaItem.CodCampoChave <> 0 Then
               Dim idxChave As Integer = mapCampo.IndexOf(CStr(pesquisaItem.CodCampoChave))
               If idxChave >= 0 Then
                  pesquisaItem.CampoChave = CType(mapCampo.Objects(idxChave), Campo)
               End If
            End If
            If pesquisaItem.CodCampoDescricao <> 0 Then
               Dim idxDesc As Integer = mapCampo.IndexOf(CStr(pesquisaItem.CodCampoDescricao))
               If idxDesc >= 0 Then
                  pesquisaItem.CampoDescricao = CType(mapCampo.Objects(idxDesc), Campo)
               End If
            End If
            Dim buscaCount As Integer = pesquisaItem.CamposBusca.Length - 1
            For j = 0 To buscaCount
               Dim itemBusca As CampoBusca = pesquisaItem.CamposBusca.Take(j)
               If itemBusca.CodCampo <> 0 Then
                  Dim idxCampoBusca As Integer = mapCampo.IndexOf(CStr(itemBusca.CodCampo))
                  If idxCampoBusca >= 0 Then
                     itemBusca.Campo = CType(mapCampo.Objects(idxCampoBusca), Campo)
                  End If
               End If
            Next
         Next
         count = me.Filtros.Length - 1
         For i = 0 To count
            Dim filtroItem As Filtro = me.Filtros.Take(i)
            Dim filtroCampoCount As Integer = filtroItem.CamposFiltro.Length - 1
            For j = 0 To filtroCampoCount
               Dim itemFiltroCampo As FiltroCampo = filtroItem.CamposFiltro.Take(j)
               If itemFiltroCampo.CodCampo <> 0 Then
                  Dim idxCampoFiltro As Integer = mapCampo.IndexOf(CStr(itemFiltroCampo.CodCampo))
                  If idxCampoFiltro >= 0 Then
                     itemFiltroCampo.Campo = CType(mapCampo.Objects(idxCampoFiltro), Campo)
                  End If
               End If
            Next
         Next
         mapPasta.Free()
         mapPesquisa.Free()
         mapCampo.Free()
      End Sub

      Function CampoPorCodigo(pCodCampo As Integer) As Campo
         If pCodCampo = 0 Then
            CampoPorCodigo = Null
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = me.Campos.Length - 1
         For i = 0 To count
            Dim item As Campo = me.Campos.Take(i)
            If item.CodCampo = pCodCampo Then
               CampoPorCodigo = item
               Exit Function
            End If
         Next
         CampoPorCodigo = Null
      End Function

      Function CampoPorNome(pNome As String) As Campo
         Dim alvo As String = UCase(Trim(pNome))
         Dim i As Integer
         Dim count As Integer = me.Campos.Length - 1
         For i = 0 To count
            Dim item As Campo = me.Campos.Take(i)
            If UCase(Trim(item.Nome)) = alvo Then
               CampoPorNome = item
               Exit Function
            End If
         Next
         CampoPorNome = Null
      End Function

      Function PastaPorCodigo(pCodPasta As Integer) As Pasta
         If pCodPasta = 0 Then
            PastaPorCodigo = Null
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = me.Pastas.Length - 1
         For i = 0 To count
            Dim item As Pasta = me.Pastas.Take(i)
            If item.CodPasta = pCodPasta Then
               PastaPorCodigo = item
               Exit Function
            End If
         Next
         PastaPorCodigo = Null
      End Function

      Function FiltroPorCodigo(pCodFiltro As Integer) As Filtro
         Dim i As Integer
         Dim count As Integer = me.Filtros.Length - 1
         For i = 0 To count
            Dim item As Filtro = me.Filtros.Take(i)
            If item.CodFiltro = pCodFiltro Then
               FiltroPorCodigo = item
               Exit Function
            End If
         Next
         FiltroPorCodigo = Null
      End Function

      Function PesquisaPorCodigo(pCodPesquisa As Integer) As Pesquisa
         Dim i As Integer
         Dim count As Integer = me.Pesquisas.Length - 1
         For i = 0 To count
            Dim item As Pesquisa = me.Pesquisas.Take(i)
            If item.CodPesquisaPadrao = pCodPesquisa Then
               PesquisaPorCodigo = item
               Exit Function
            End If
         Next
         PesquisaPorCodigo = Null
      End Function

      Function ProcessoPorCodigo(pCodProcesso As Integer) As Processo
         Dim i As Integer
         Dim count As Integer = me.Processos.Length - 1
         For i = 0 To count
            Dim item As Processo = me.Processos.Take(i)
            If item.CodProcessoTabela = pCodProcesso Then
               ProcessoPorCodigo = item
               Exit Function
            End If
         Next
         ProcessoPorCodigo = Null
      End Function

      Function CamposChave() As TTList<Campo>
         Dim lista[] As Campo = []
         lista.OwnsObjects = False
         Dim i As Integer
         Dim count As Integer = me.Campos.Length - 1
         For i = 0 To count
            Dim item As Campo = me.Campos.Take(i)
            If item.Chave Then
               lista.Push(item)
            End If
         Next
         CamposChave = lista
      End Function

      Function CampoAutoIncremento() As Campo
         CampoAutoIncremento = me.CampoPorCodigo(me.CodCampoAutoIncremento)
      End Function

      Sub VerificarCamposFisicos(pIncluirExtras As Boolean = False)
         Dim _cols[] As TColumnInfo = TSql.DescribeColumns(me.NomeSchema, me.Nome)
         Dim mapFisico As New StringList()
         mapFisico.OwnsObjects = False
         Dim i As Integer
         Dim count As Integer = _cols.Length - 1
         For i = 0 To count
            Dim col As TColumnInfo = _cols.Take(i)
            mapFisico.AddObject(UCase(Trim(col.Name)), col)
         Next
         Dim mapCatalogo As New StringList()
         mapCatalogo.OwnsObjects = False
         count = me.Campos.Length - 1
         For i = 0 To count
            Dim campoItem As Campo = me.Campos.Take(i)
            Dim nomeKey As String = UCase(Trim(campoItem.Nome))
            mapCatalogo.AddObject(nomeKey, campoItem)
            Dim idxFisico As Integer = mapFisico.IndexOf(nomeKey)
            campoItem.Exists = (idxFisico >= 0)
         Next
         If pIncluirExtras Then
            count = _cols.Length - 1
            For i = 0 To count
               Dim colExtra As TColumnInfo = _cols.Take(i)
               Dim keyExtra As String = UCase(Trim(colExtra.Name))
               If mapCatalogo.IndexOf(keyExtra) < 0 Then
                  Dim extra As New Campo()
                  extra.CodTabela = me.CodTabela
                  extra.Nome = colExtra.Name
                  extra.Titulo = colExtra.Name
                  extra.Tamanho = colExtra.MaxLength
                  extra.Chave = colExtra.PrimaryKey
                  extra.Exists = True
                  extra.Extra = True
                  me.Campos.Push(extra)
                  mapCatalogo.AddObject(keyExtra, extra)
               End If
            Next
         End If
         mapFisico.Free()
         mapCatalogo.Free()
         _cols.Free()
      End Sub

      Sub CarregarAcessos(pCodUsuario As Integer)
         Dim row As AcessoTabela = AcessoTabela.Find(me.CodTabela, pCodUsuario)
         Dim antigo As AcessoTabela = me.Acesso
         If Assigned(row) Then
            me.Acesso = row
         Else
            me.Acesso = New AcessoTabela()
            me.Acesso.CodTabela = me.CodTabela
            me.Acesso.CodUsuario = pCodUsuario
         End If
         If Assigned(antigo) Then
            antigo.Free()
         End If
         If me.Processos.Length = 0 Then
            Exit Sub
         End If
         Dim acessos[] As AcessoProcesso = AcessoProcesso.FetchByUsuario(me.CodTabela, pCodUsuario)
         acessos.OwnsObjects = False
         Dim mapAcesso As New StringList()
         mapAcesso.OwnsObjects = False
         Dim i As Integer
         Dim count As Integer = acessos.Length - 1
         For i = 0 To count
            Dim acessoItem As AcessoProcesso = acessos.Take(i)
            mapAcesso.AddObject(CStr(acessoItem.CodProcessoTabela), acessoItem)
         Next
         count = me.Processos.Length - 1
         For i = 0 To count
            Dim item As Processo = me.Processos.Take(i)
            Dim chave As String = CStr(item.CodProcessoTabela)
            Dim idx As Integer = mapAcesso.IndexOf(chave)
            If idx >= 0 Then
               Dim rowAcesso As AcessoProcesso = CType(mapAcesso.Objects(idx), AcessoProcesso)
               mapAcesso.Delete(mapAcesso.IndexOf(chave))
               item.AplicarAcesso(rowAcesso, pCodUsuario)
            Else
               item.AplicarAcesso(Null, pCodUsuario)
            End If
         Next
         count = mapAcesso.Count - 1
         For i = 0 To count
            Dim sobra As AcessoProcesso = CType(mapAcesso.Objects(i), AcessoProcesso)
            If Assigned(sobra) Then
               sobra.Free()
            End If
         Next
         mapAcesso.Free()
         acessos.Free()
      End Sub

      Shared Function Fetch(pWhere As String = "", pOrder As String = "ORDER BY nomeschema, nome") As TTList<Tabela>
         Dim query As SQL.Command = TCfgDb.Abrir("", "Tabela", pWhere, pOrder)
         Dim lista[] As Tabela = []
         While Not query.Eof
            Dim item As New Tabela()
            item.Fill(query)
            item.Acesso.CodTabela = item.CodTabela
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Acesso) Then
            me.Acesso.Free()
            me.Acesso = Null
         End If
         If Assigned(me._relatorioInclusao) Then
            me._relatorioInclusao.Free()
            me._relatorioInclusao = Null
         End If
         If Assigned(me.Grupo) Then
            me.Grupo.Free()
            me.Grupo = Null
         End If
         If Assigned(me.Campos) Then
            me.Campos.Free()
            me.Campos = Null
         End If
         If Assigned(me.Pastas) Then
            me.Pastas.Free()
            me.Pastas = Null
         End If
         If Assigned(me.Legendas) Then
            me.Legendas.Free()
            me.Legendas = Null
         End If
         If Assigned(me.Filtros) Then
            me.Filtros.Free()
            me.Filtros = Null
         End If
         If Assigned(me.Pesquisas) Then
            me.Pesquisas.Free()
            me.Pesquisas = Null
         End If
         If Assigned(me.Processos) Then
            me.Processos.Free()
            me.Processos = Null
         End If
         If Assigned(me.Ajudas) Then
            me.Ajudas.Free()
            me.Ajudas = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
