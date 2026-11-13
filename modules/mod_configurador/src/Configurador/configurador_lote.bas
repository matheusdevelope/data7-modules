
Imports configurador_campo
Imports configurador_filtro
Imports configurador_legenda
Imports configurador_processo
Imports configurador_ajuda
Imports configurador_grupotabela
Imports configurador_pasta
Imports configurador_pesquisa
Imports TablesSql
Imports configurador_sql
Imports Collections
Imports configurador_campo_busca

Namespace configurador_lote

   Private Dim _defPrefix As String
   Private Dim _defRdbms As TRDBMS

   Class PacoteTabela
      Campos[] As Campo
      Pastas[] As Pasta
      Legendas[] As Legenda
      Filtros[] As Filtro
      Pesquisas[] As Pesquisa
      Processos[] As Processo
      Ajudas[] As Ajuda
      Grupo As GrupoTabela

      Sub New()
         MyBase.New()
         me.Campos = []
         me.Pastas = []
         me.Legendas = []
         me.Filtros = []
         me.Pesquisas = []
         me.Processos = []
         me.Ajudas = []
         me.Grupo = Null
      End Sub

      Shared Function SuportaJson() As Boolean
         Dim r As TRDBMS = SQL.Connection.RDBMS
         SuportaJson = (r = dbMSSQL) Or (r = dbASA) Or (r = dbPostgreSQL)
      End Function

      Shared Function SqlDefinicao(pWhereTabela As String) As String
         Dim r As TRDBMS = SQL.Connection.RDBMS
         If (_defPrefix = "") Or (_defRdbms <> r) Then
            _defPrefix = PacoteTabela.MontarPrefixo()
            _defRdbms = r
         End If
         SqlDefinicao = _defPrefix & TSql.Dialect().NormalizeWhere(pWhereTabela)
      End Function

      Shared Function MontarPrefixo() As String
         Dim sqlText As String = "SELECT t.CodTabela, t.CodCampoAutoIncremento, t.CodCampoEstrutura, t.ControlaPorEmpresa, t.CodGrupoTabela, t.Proprietario, t.CodDBSpaceTabela, t.CodDBSpaceIndice, t.Observacao, t.UtilizaGradeZebrada, t.MargemEditor, t.ConfirmaInclusao, t.ConfirmaAlteracao, t.DesabilitaExclusao, t.DesabilitaVisualizacao, t.DesabilitaInclusao, t.DesabilitaAlteracao, t.ExibirDentroQuadroRolagem, t.AlturaQuadroRolagem, t.EditaNaGrade, t.CodTabelaEdicao, t.CodPastaTabelaEdicao, t.DllFormEdicao, t.Nome, t.Titulo, t.CodCampoLegenda1, t.CodCampoLegenda2, t.CodTabelaPropriedadeCampo, t.CodCampoPreferenciaPesquisa, t.TodosRegistrosNoInicio, t.PermiteMultiplaSelecaoNaGrade, t.UsarCacheDeObjeto, t.CodCampoOrdemPadrao, t.OrdemCampoOrdemPadrao, t.InclusaoRecursiva, t.Descricao, t.LogProcessosAtivo, t.LogInclusaoAtivo, t.LogExclusaoAtivo, t.LogAlteracaoAtivo, t.FiltroFixoGrade, t.ModeloLayout, t.CodRelatorioInclusao, t.ValidacaoInclusao, t.ValidacaoAlteracao, t.ValidacaoExclusao, t.ValidacaoVisualizacao, t.NomeSchema, t.ArquivoProjetoApoio"
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "Campo", "codtabela, codcampo, tipo, condicaoobrigatorio, condicaovisivelgrade, titulo, titulograde, titulorelatorio, titulopesquisa, tituloedicao, tamanho, casasdecimal, condicaovisiveledicao, ordemedicao, ordemgrade, mascaraedicao, mascaragrade, contexto, codpasta, formulavalorpadrao, listaopcao, condicaoeditarinclusao, condicaoeditaralteracao, codpesquisapadrao, ordempesquisa, condicaovisivelpesquisa, validacaousuario, codmensagemvalidacaousuario, validacaosistema, codmensagemvalidacaosistema, proprietario, observacao, larguragrade, larguraedicao, largurapesquisa, posicaox, posicaoy, alturaedicao, formulacalculovalor, scriptonexit, chave, tipopesquisa, visivelrelatorio, visivelparametrorelatorio, tituloinicialparametrorelatorio, titulofinalparametrorelatorio, exibirresumo, nome, exibirnorodapepesquisa, exibirnorodapegrade, caractere, tipocaractere, charcase, scriptonenter, alinhamentoedicao, nomefonteedicao, tamanhofonteedicao, corfonteedicao, fontenegritoedicao, fonteitalicoedicao, fontesublinhadoedicao, fonteriscadoedicao, condicaopadrao, pesquisaincremental, coluna, tipovalorpadrao, manterconteudo, condicaopesquisaespecifica, especifico, duplicidade", "codtabela = t.CodTabela", "ORDER BY codpasta, ordemedicao, codcampo", "cfg_campos")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "Pasta", "codtabela, codpasta, titulo, proprietario, status, estrutura, margemeditor, subcadastro", "codtabela = t.CodTabela", "ORDER BY codpasta", "cfg_pastas")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("Dicionario", "LegendaTabela", "codtabela, codlegendatabela, descricao, tipolegenda, ordem", "codtabela = t.CodTabela", "ORDER BY ordem, codlegendatabela", "cfg_legendas")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "Filtro", "codtabela, codfiltro, nome, proprietario", "codtabela = t.CodTabela", "ORDER BY codfiltro", "cfg_filtros")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "CampoFiltro", "codtabela, codfiltro, codcampo, valorpadrao, visivel, proprietario, ordem, condicao, titulo, comando, editavel, sqlwherecondition", "codtabela = t.CodTabela", "ORDER BY ordem, codcampo", "cfg_campofiltro")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "PesquisaPadrao", "codtabela, codpesquisapadrao, codcampodescricao, titulo, proprietario, permiteexcluir, permiteincluir, abrirposicionado, expressaofiltro, codimagem, codcampochave, dllformpesquisa, exibirdesativado, codscripter, manterultimofiltro, permitecadastrodireto, codtabelacadastrodireto, permiteinclusaocadastrodireto, permitealteracaocadastrodireto, permitevisualizarcadastrodireto, atalhoabrirpesquisa, atalhoinclusao, atalhoalteracao, atalhovisualizacao, exibebotaoinclusao, exibebotaoalteracao, exibebotaovisualizacao", "codtabela = t.CodTabela", "ORDER BY titulo", "cfg_pesquisas")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "CampoBuscaPesquisaPadrao", "codtabela, codpesquisapadrao, codcampo, ordem, condicao", "codtabela = t.CodTabela", "ORDER BY ordem, codcampo", "cfg_buscas")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "ProcessoTabela", "codtabela, codprocessotabela, titulo, imagem, ordem, localexibir, proprietario, shortcut, acao, valoracao, bloquear, verificarbloqueio, validacao, status, codwhatsappconfiguracoesenvio", "codtabela = t.CodTabela", "ORDER BY ordem, codprocessotabela", "cfg_processos")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "Ajuda", "codtabela, codcampo, conteudo, codajuda, codajudapai, descricao, codrelatorio, codprocessotabela, codfiltro, codlegendatabela, codmodulo, codpesquisapadrao, codmensagem, nomeparametro, codgatilho, codregravalidacao, codprocedurefunction", "codtabela = t.CodTabela", "ORDER BY codajuda", "cfg_ajudas")
         sqlText = sqlText & ", " & TCfgLoad.SqlJson("", "GrupoTabela", "codgrupotabela, nome, proprietario", "codgrupotabela = t.CodGrupoTabela", "", "cfg_grupo")
         sqlText = sqlText & " FROM " & TCfgDb.FromSql("", "Tabela") & " t"
         sqlText = LCase(sqlText)
         MontarPrefixo = sqlText
      End Function

      Shared Function DoQuery(pQuery As SQL.Command) As PacoteTabela
         Dim pacote As New PacoteTabela()
         pacote.Campos = TCfgLoad.CamposJson(pQuery.Field("cfg_campos").AsString)
         pacote.Pastas = TCfgLoad.PastasJson(pQuery.Field("cfg_pastas").AsString)
         pacote.Legendas = TCfgLoad.LegendasJson(pQuery.Field("cfg_legendas").AsString)
         pacote.Filtros = TCfgLoad.FiltrosJson(pQuery.Field("cfg_filtros").AsString)
         TCfgLoad.AnexarFiltroCampos(pacote.Filtros, pQuery.Field("cfg_campofiltro").AsString)
         pacote.Pesquisas = TCfgLoad.PesquisasJson(pQuery.Field("cfg_pesquisas").AsString)
         TCfgLoad.AnexarBuscas(pacote.Pesquisas, pQuery.Field("cfg_buscas").AsString)
         pacote.Processos = TCfgLoad.ProcessosJson(pQuery.Field("cfg_processos").AsString)
         pacote.Ajudas = TCfgLoad.AjudasJson(pQuery.Field("cfg_ajudas").AsString)
         pacote.Grupo = TCfgLoad.GrupoJson(pQuery.Field("cfg_grupo").AsString)
         DoQuery = pacote
      End Function

      Shared Function Fetch(pCodTabela As Integer) As PacoteTabela
         Dim pacote As New PacoteTabela()
         pacote.Campos = Campo.FetchByTabela(pCodTabela)
         pacote.Pastas = Pasta.FetchByTabela(pCodTabela)
         pacote.Legendas = Legenda.FetchByTabela(pCodTabela)
         pacote.Filtros = Filtro.FetchByTabela(pCodTabela)
         TCfgLoad.AnexarFiltroCamposLista(pacote.Filtros, pCodTabela)
         pacote.Pesquisas = Pesquisa.FetchByTabela(pCodTabela)
         TCfgLoad.AnexarBuscasLista(pacote.Pesquisas, pCodTabela)
         pacote.Processos = Processo.FetchByTabela(pCodTabela)
         pacote.Ajudas = Ajuda.Fetch(TCfgSql.Tabela(pCodTabela), "ORDER BY codajuda")
         Fetch = pacote
      End Function

      Overrides Sub Dispose()
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
         If Assigned(me.Grupo) Then
            me.Grupo.Free()
            me.Grupo = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TCfgLoad

      Shared Function SqlJson(pSchema As String, pTabela As String, pColunas As String, pWhere As String, pOrder As String, pAlias As String) As String
         Dim d As TSqlDialect = TSql.Dialect()
         Dim inner As String = "SELECT " & pColunas & " FROM " & d.QuoteTable(pSchema, pTabela) & d.NormalizeWhere(pWhere) & d.NormalizeOrderBy(pOrder)
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            SqlJson = "(SELECT convert_to(CAST(json_agg(_j) AS text), 'WIN1252') FROM (" & inner & ") _j) AS " & pAlias
         ElseIf SQL.Connection.RDBMS = dbMSSQL Then
            SqlJson = "CAST(CAST((" & inner & " FOR JSON AUTO) AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS " & pAlias
         Else
            SqlJson = "CSCONVERT(CAST((" & inner & " FOR JSON RAW) AS LONG VARCHAR), 'windows-1252', 'utf-8') AS " & pAlias

         End If
      End Function

      Shared Function AbrirArray(pJson As String) As TJSONArray
         Dim texto As String = Trim(pJson)
         If (texto = "") Or (UCase(texto) = "NULL") Then
            AbrirArray = Null
         Else
            AbrirArray = New TJSONArray(texto)
         End If
      End Function

      Shared Function CamposJson(pJson As String) As TTList<Campo>
         Dim lista[] As Campo = []
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            CamposJson = lista
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = arr.Length() - 1
         For i = 0 To count
            Dim item As New Campo()
            item.Fill(arr.GetJSONObject(i))
            lista.Push(item)
         Next
         arr.Free()
         CamposJson = lista
      End Function

      Shared Function PastasJson(pJson As String) As TTList<Pasta>
         Dim lista[] As Pasta = []
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            PastasJson = lista
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = arr.Length() - 1
         For i = 0 To count
            Dim item As New Pasta()
            item.Fill(arr.GetJSONObject(i))
            lista.Push(item)
         Next
         arr.Free()
         PastasJson = lista
      End Function

      Shared Function LegendasJson(pJson As String) As TTList<Legenda>
         Dim lista[] As Legenda = []
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            LegendasJson = lista
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = arr.Length() - 1
         For i = 0 To count
            Dim item As New Legenda()
            item.Fill(arr.GetJSONObject(i))
            lista.Push(item)
         Next
         arr.Free()
         LegendasJson = lista
      End Function

      Shared Function FiltrosJson(pJson As String) As TTList<Filtro>
         Dim lista[] As Filtro = []
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            FiltrosJson = lista
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = arr.Length() - 1
         For i = 0 To count
            Dim item As New Filtro()
            item.Fill(arr.GetJSONObject(i))
            lista.Push(item)
         Next
         arr.Free()
         FiltrosJson = lista
      End Function

      Shared Function PesquisasJson(pJson As String) As TTList<Pesquisa>
         Dim lista[] As Pesquisa = []
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            PesquisasJson = lista
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = arr.Length() - 1
         For i = 0 To count
            Dim item As New Pesquisa()
            item.Fill(arr.GetJSONObject(i))
            lista.Push(item)
         Next
         arr.Free()
         PesquisasJson = lista
      End Function

      Shared Function ProcessosJson(pJson As String) As TTList<Processo>
         Dim lista[] As Processo = []
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            ProcessosJson = lista
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = arr.Length() - 1
         For i = 0 To count
            Dim item As New Processo()
            item.Fill(arr.GetJSONObject(i))
            lista.Push(item)
         Next
         arr.Free()
         ProcessosJson = lista
      End Function

      Shared Function AjudasJson(pJson As String) As TTList<Ajuda>
         Dim lista[] As Ajuda = []
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            AjudasJson = lista
            Exit Function
         End If
         Dim i As Integer
         Dim count As Integer = arr.Length() - 1
         For i = 0 To count
            Dim item As New Ajuda()
            item.Fill(arr.GetJSONObject(i))
            lista.Push(item)
         Next
         arr.Free()
         AjudasJson = lista
      End Function

      Shared Function GrupoJson(pJson As String) As GrupoTabela
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            GrupoJson = Null
            Exit Function
         End If
         If arr.Length() <= 0 Then
            arr.Free()
            GrupoJson = Null
            Exit Function
         End If
         Dim item As New GrupoTabela()
         item.Fill(arr.GetJSONObject(0))
         arr.Free()
         GrupoJson = item
      End Function

      Shared Sub AnexarFiltroCampos(pFiltros As TTList<Filtro>, pJson As String)
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            Exit Sub
         End If
         Dim mapFiltro As New StringList()
         mapFiltro.OwnsObjects = False
         Dim i As Integer
         Dim count As Integer = pFiltros.Length - 1
         For i = 0 To count
            Dim filtroItem As Filtro = pFiltros.Take(i)
            mapFiltro.AddObject(CStr(filtroItem.CodFiltro), filtroItem)
         Next
         count = arr.Length() - 1
         For i = 0 To count
            Dim item As New FiltroCampo()
            item.Fill(arr.GetJSONObject(i))
            Dim idx As Integer = mapFiltro.IndexOf(CStr(item.CodFiltro))
            If idx >= 0 Then
               Dim filtroAlvo As Filtro = CType(mapFiltro.Objects(idx), Filtro)
               filtroAlvo.CamposFiltro.Push(item)
            Else
               item.Free()
            End If
         Next
         mapFiltro.Free()
         arr.Free()
      End Sub

      Shared Sub AnexarBuscas(pPesquisas As TTList<Pesquisa>, pJson As String)
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            Exit Sub
         End If
         Dim mapPesquisa As New StringList()
         mapPesquisa.OwnsObjects = False
         Dim i As Integer
         Dim count As Integer = pPesquisas.Length - 1
         For i = 0 To count
            Dim pesquisaItem As Pesquisa = pPesquisas.Take(i)
            mapPesquisa.AddObject(CStr(pesquisaItem.CodPesquisaPadrao), pesquisaItem)
         Next
         count = arr.Length() - 1
         For i = 0 To count
            Dim item As New CampoBusca()
            item.Fill(arr.GetJSONObject(i))
            Dim idx As Integer = mapPesquisa.IndexOf(CStr(item.CodPesquisaPadrao))
            If idx >= 0 Then
               Dim pesquisaAlvo As Pesquisa = CType(mapPesquisa.Objects(idx), Pesquisa)
               pesquisaAlvo.CamposBusca.Push(item)
            Else
               item.Free()
            End If
         Next
         mapPesquisa.Free()
         arr.Free()
      End Sub

      Shared Sub AnexarFiltroCamposLista(pFiltros As TTList<Filtro>, pCodTabela As Integer)
         Dim raw[] As FiltroCampo = FiltroCampo.Fetch(TCfgSql.Tabela(pCodTabela))
         Dim mapFiltro As New StringList()
         mapFiltro.OwnsObjects = False
         Dim i As Integer
         Dim count As Integer = pFiltros.Length - 1
         For i = 0 To count
            Dim filtroItem As Filtro = pFiltros.Take(i)
            mapFiltro.AddObject(CStr(filtroItem.CodFiltro), filtroItem)
         Next
         count = raw.Length - 1
         For i = 0 To count
            Dim item As FiltroCampo = raw.Take(i)
            Dim idx As Integer = mapFiltro.IndexOf(CStr(item.CodFiltro))
            If idx >= 0 Then
               Dim filtroAlvo As Filtro = CType(mapFiltro.Objects(idx), Filtro)
               filtroAlvo.CamposFiltro.Push(item)
            Else
               item.Free()
            End If
         Next
         raw.OwnsObjects = False
         raw.Free()
         mapFiltro.Free()
      End Sub

      Shared Sub AnexarBuscasLista(pPesquisas As TTList<Pesquisa>, pCodTabela As Integer)
         Dim raw[] As CampoBusca = CampoBusca.Fetch(TCfgSql.Tabela(pCodTabela))
         Dim mapPesquisa As New StringList()
         mapPesquisa.OwnsObjects = False
         Dim i As Integer
         Dim count As Integer = pPesquisas.Length - 1
         For i = 0 To count
            Dim pesquisaItem As Pesquisa = pPesquisas.Take(i)
            mapPesquisa.AddObject(CStr(pesquisaItem.CodPesquisaPadrao), pesquisaItem)
         Next
         count = raw.Length - 1
         For i = 0 To count
            Dim item As CampoBusca = raw.Take(i)
            Dim idx As Integer = mapPesquisa.IndexOf(CStr(item.CodPesquisaPadrao))
            If idx >= 0 Then
               Dim pesquisaAlvo As Pesquisa = CType(mapPesquisa.Objects(idx), Pesquisa)
               pesquisaAlvo.CamposBusca.Push(item)
            Else
               item.Free()
            End If
         Next
         raw.OwnsObjects = False
         raw.Free()
         mapPesquisa.Free()
      End Sub

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
