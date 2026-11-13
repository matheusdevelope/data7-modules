
Imports configurador_campo
Imports configurador_filtro
Imports configurador_legenda
Imports configurador_processo
Imports configurador_relatorio
Imports configurador_tabela
Imports configurador_ajuda
Imports configurador_grupotabela
Imports configurador_acesso_tabela
Imports configurador_pasta
Imports configurador_pesquisa
Imports configurador_campo_busca
Imports configurador_sql
Imports configurador_acesso_processo

Namespace configurador_catalogo

   Class Catalogo
      Shared Function Tabelas(pWhere As String = "", pOrder As String = "ORDER BY nomeschema, nome") As TTList<Tabela>
         Tabelas = Tabela.Fetch(pWhere, pOrder)
      End Function

      Shared Function FindTabela(pCodTabela As Integer) As Tabela
         Dim lista[] As Tabela = Tabela.Fetch(TCfgSql.Tabela(pCodTabela))
         If lista.Length = 0 Then
            lista.Free()
            FindTabela = Null
         Else
            FindTabela = lista.Take(0)
            lista.OwnsObjects = False
            lista.Free()
         End If
      End Function

      Shared Function FindTabela(pNome As String, pSchema As String = "") As Tabela
         Dim lista[] As Tabela = Tabela.Fetch(TCfgSql.NomeSchema(pNome, pSchema))
         If lista.Length = 0 Then
            lista.Free()
            FindTabela = Null
         Else
            FindTabela = lista.Take(0)
            lista.OwnsObjects = False
            lista.Free()
         End If
      End Function

      Shared Function Campos(pWhere As String, pOrder As String = "ORDER BY ordemedicao, ordemgrade, nome") As TTList<Campo>
         Campos = Campo.Fetch(pWhere, pOrder)
      End Function

      Shared Function CamposDaTabela(pCodTabela As Integer) As TTList<Campo>
         CamposDaTabela = Campo.FetchByTabela(pCodTabela)
      End Function

      Shared Function FindCampo(pCodTabela As Integer, pCodCampo As Integer) As Campo
         FindCampo = Campo.Find(pCodTabela, pCodCampo)
      End Function

      Shared Function FindCampo(pCodTabela As Integer, pNome As String) As Campo
         FindCampo = Campo.FindPorNome(pCodTabela, pNome)
      End Function

      Shared Function Pastas(pWhere As String, pOrder As String = "ORDER BY codpasta") As TTList<Pasta>
         Pastas = Pasta.Fetch(pWhere, pOrder)
      End Function

      Shared Function PastasDaTabela(pCodTabela As Integer) As TTList<Pasta>
         PastasDaTabela = Pasta.FetchByTabela(pCodTabela)
      End Function

      Shared Function FindPasta(pCodTabela As Integer, pCodPasta As Integer) As Pasta
         FindPasta = Pasta.Find(pCodTabela, pCodPasta)
      End Function

      Shared Function Legendas(pWhere As String, pOrder As String = "ORDER BY ordem, codlegendatabela") As TTList<Legenda>
         Legendas = Legenda.Fetch(pWhere, pOrder)
      End Function

      Shared Function LegendasDaTabela(pCodTabela As Integer) As TTList<Legenda>
         LegendasDaTabela = Legenda.FetchByTabela(pCodTabela)
      End Function

      Shared Function Filtros(pWhere As String, pOrder As String = "ORDER BY codfiltro") As TTList<Filtro>
         Filtros = Filtro.Fetch(pWhere, pOrder)
      End Function

      Shared Function FiltrosDaTabela(pCodTabela As Integer) As TTList<Filtro>
         FiltrosDaTabela = Filtro.FetchByTabela(pCodTabela)
      End Function

      Shared Function CamposFiltro(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<FiltroCampo>
         CamposFiltro = FiltroCampo.Fetch(pWhere, pOrder)
      End Function

      Shared Function CamposFiltroDaTabela(pCodTabela As Integer) As TTList<FiltroCampo>
         CamposFiltroDaTabela = FiltroCampo.Fetch(TCfgSql.Tabela(pCodTabela), "ORDER BY ordem, codcampo")
      End Function

      Shared Function Pesquisas(pWhere As String, pOrder As String = "ORDER BY titulo") As TTList<Pesquisa>
         Pesquisas = Pesquisa.Fetch(pWhere, pOrder)
         
      End Function

      Shared Function PesquisasDaTabela(pCodTabela As Integer) As TTList<Pesquisa>
         PesquisasDaTabela = Pesquisa.FetchByTabela(pCodTabela)
      End Function

      Shared Function FindPesquisa(pCodPesquisaPadrao As Integer) As Pesquisa
         FindPesquisa = Pesquisa.Find(pCodPesquisaPadrao)
      End Function

      Shared Function CamposBusca(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<CampoBusca>
         CamposBusca = CampoBusca.Fetch(pWhere, pOrder)
      End Function

      Shared Function Processos(pWhere As String, pOrder As String = "ORDER BY ordem, codprocessotabela") As TTList<Processo>
         Processos = Processo.Fetch(pWhere, pOrder)
      End Function

      Shared Function ProcessosDaTabela(pCodTabela As Integer) As TTList<Processo>
         ProcessosDaTabela = Processo.FetchByTabela(pCodTabela)
      End Function

      Shared Function Ajudas(pWhere As String, pOrder As String = "ORDER BY codajuda") As TTList<Ajuda>
         Ajudas = Ajuda.Fetch(pWhere, pOrder)
      End Function

      Shared Function AjudasDaTabela(pCodTabela As Integer) As TTList<Ajuda>
         AjudasDaTabela = Ajuda.Fetch(TCfgSql.Tabela(pCodTabela), "ORDER BY codajuda")
      End Function

      Shared Function FindGrupo(pCodGrupoTabela As Integer) As GrupoTabela
         FindGrupo = GrupoTabela.Find(pCodGrupoTabela)
      End Function

      Shared Function Relatorios(pWhere As String = "", pOrder As String = "ORDER BY titulo") As TTList<Relatorio>
         Relatorios = Relatorio.Fetch(pWhere, pOrder)
      End Function

      Shared Function FindRelatorio(pCodRelatorio As Integer) As Relatorio
         FindRelatorio = Relatorio.Carregar(pCodRelatorio)
      End Function

      Shared Function Layouts(pWhere As String, pOrder As String = "ORDER BY ordem, item") As TTList<LayoutRelatorio>
         Layouts = LayoutRelatorio.Fetch(pWhere, pOrder)
      End Function

      Shared Function LayoutsDoRelatorio(pCodRelatorio As Integer) As TTList<LayoutRelatorio>
         LayoutsDoRelatorio = LayoutRelatorio.Fetch(TCfgSql.EqInt("codrelatorio", pCodRelatorio), "ORDER BY ordem, item")
      End Function

      Shared Function FindAcessoTabela(pCodTabela As Integer, pCodUsuario As Integer) As AcessoTabela
         FindAcessoTabela = AcessoTabela.Find(pCodTabela, pCodUsuario)
      End Function

      Shared Function FindAcessoProcesso(pCodTabela As Integer, pCodProcessoTabela As Integer, pCodUsuario As Integer) As AcessoProcesso
         FindAcessoProcesso = AcessoProcesso.Find(pCodTabela, pCodProcessoTabela, pCodUsuario)
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
