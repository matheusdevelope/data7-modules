'
' mod_configurador
' Biblioteca de dominio do dicionario do ERP (tabelas, campos, filtros,
' pesquisas, processos, acessos e relatorios).
'
' As classes de dominio (Tabela, Campo, Filtro, ...) sao concretas.
' A definicao de uma tabela e carregada com uma consulta (JSON no SQL Server,
' Sybase e PostgreSQL) e preenchida direto nos campos. O dialeto, o quoting
' e a execucao SQL continuam em mod_table (TSql / TSqlDialect).
'
' src/Tables guarda os CRUDs gerados em TTable. Esse caminho e a excecao,
' para quando for preciso gravar o dicionario. O load da definicao nao usa.
'
' ---------------------------------------------------------------------------
' Namespaces
' ---------------------------------------------------------------------------
'   configurador_sql        TCfgSql, TCfgDb, TCfgRow, TCfgFlag
'   configurador_catalogo   Catalogo (Fetch/Find das classes concretas)
'   configurador_campo      Campo, Pasta, Pesquisa, CampoBusca
'   configurador_filtro     Filtro, FiltroCampo
'   configurador_legenda    Legenda
'   configurador_processo   Processo, AcessoProcesso
'   configurador_lote       PacoteTabela, TCfgLoad, Ajuda, GrupoTabela
'   configurador_tabela     Tabela, AcessoTabela
'   configurador_relatorio  Relatorio
'   configurador_motor      Motor
'
' ---------------------------------------------------------------------------
' Tabela
' ---------------------------------------------------------------------------
'   New Tabela(pNome [, pSchema])
'   New Tabela(pCodTabela)
'
'   Carrega campos, pastas, legendas, filtros (+ campos do filtro), pesquisas
'   (+ buscas), processos, ajudas e grupo. Em SQL Server, Sybase e PostgreSQL
'   a definicao inteira vem em uma query (SELECT * + JSON por dialeto) e as
'   classes concretas sao preenchidas em memoria. RelatorioInclusao e lazy.
'
'   NomeSchema vazio e preenchido com TSql.Dialect().DefaultSchema().
'
'   Lookups: CampoPorNome, CampoPorCodigo, PastaPorCodigo, FiltroPorCodigo,
'   PesquisaPorCodigo, ProcessoPorCodigo, CamposChave, CampoAutoIncremento.
'
'   VerificarCamposFisicos([pIncluirExtras])
'     Marca Campo.Exists conforme as colunas fisicas.
'     Com True, inclui colunas extras (Exists=True, Extra=True).
'
'   CarregarAcessos(pCodUsuario)
'     Preenche Tabela.Acesso (AcessoTabela) e Processo.Acesso
'     (AcessoProcesso). Acesso nunca e Null. Fill marca _loaded quando a
'     linha veio do banco. Sem linha, as flags ficam no default (False) e as chaves
'     (CodTabela / CodUsuario / CodProcessoTabela) permanecem preenchidas.
'
' ---------------------------------------------------------------------------
' Campo
' ---------------------------------------------------------------------------
'   EditarInclusao / EditarAlteracao / Obrigatorio
'     Avaliam Condicao* via TCfgSql.AvaliarCondicao (S/N ou expressao SQL).
'     Resultado em cache.
'
'   ValorPadrao
'     TipoValorPadrao + FormulaValorPadrao (FORMULA / FIXO / vazio).
'
'   Valor([pQueryBase])
'     FormulaCalculoValor quando Contexto = "C".
'     pQueryBase troca :NomeCampo por (formula) AS Nome.
'
'   TemPesquisa() — codpesquisapadrao <> 0
'
' ---------------------------------------------------------------------------
' Relatorio
' ---------------------------------------------------------------------------
'   New Relatorio(pCodRelatorio)
'   Relatorio.Carregar(pCod) devolve Null se nao existir (uso lazy).
'   Layouts, GruposLayout, EnviosEmail, Grupo, WhatsApp em SELECT * separados.
'
' ---------------------------------------------------------------------------
' Catalogo
' ---------------------------------------------------------------------------
'   Find/Fetch de Tabela, Campo, Pasta, Filtro, Pesquisa, Processo, Ajuda,
'   Relatorio, Layout, AcessoTabela, AcessoProcesso.
'
' ---------------------------------------------------------------------------
' TCfgSql / TCfgFlag
' ---------------------------------------------------------------------------
'   EqInt, EqStr, EqStrCI, AndInt, Tabela, Usuario, NomeSchema.
'   AvaliarCondicao, AvaliarValorPadrao, AvaliarValor, AvaliarFormula.
'   TCfgFlag.Sim / TCfgFlag.Nao.
'
' ---------------------------------------------------------------------------
' Motor
' ---------------------------------------------------------------------------
'   Motor.CarregarTabela(pNome [, pSchema])
'   Motor.CarregarTabela(pCodTabela)
'   Motor.CarregarRelatorio(pCodRelatorio)
'
' ---------------------------------------------------------------------------
' CRUDs gerados
' ---------------------------------------------------------------------------
'   Principal.BuildTablesTemplates usa TTableGenerator.Save e grava src/Tables.
'   Esses modulos continuam no projeto para gravar o dicionario. O load de
'   Tabela/Campo/Relatorio nao instancia essas classes.
'
' Uso:
'   Imports configurador_tabela
'   Imports configurador_campo
'   Dim t As New Tabela("MinhaTabela")
'   t.VerificarCamposFisicos()
'   t.CarregarAcessos(codUsuario)
'   print t.CampoPorNome("CodEmpresa").EditarInclusao
'   print t.Acesso.PermitidoAlterar
'   t.Free()
'

Imports configurador_motor
Imports configurador_tabela
Imports configurador_relatorio

Namespace mod_configurador

   Class Configurador
      Shared Function CarregarTabela(pCodTabela As Integer) As Tabela
         CarregarTabela = Motor.CarregarTabela(pCodTabela)
      End Function

      Shared Function CarregarTabela(pNome As String, pSchema As String = "") As Tabela
         CarregarTabela = Motor.CarregarTabela(pNome, pSchema)
      End Function

      Shared Function CarregarRelatorio(pCodRelatorio As Integer) As Relatorio
         CarregarRelatorio = Motor.CarregarRelatorio(pCodRelatorio)
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
