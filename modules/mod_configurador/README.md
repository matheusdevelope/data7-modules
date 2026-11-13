# mod_configurador

`mod_configurador` is the ERP dictionary domain library: it loads a table definition (`Tabela`, fields, folders, legends, filters, searches, processes, helps, group) and a report definition (`Relatorio` plus layouts, layout groups, email layouts, report group, WhatsApp send config) into concrete in-memory objects. It does **not** render forms, run grid CRUD, enforce field validation at save time, or write the dictionary — those belong to the consumer (UI, `TTableOf<T>` persistence classes in `src/Tables`, or `mod_table`). Version `1.0.0.0` (`data7.json`). Dependency: `mod_table` `1.0.0.6` (`TSql`, `TSqlDialect`, `TColumnInfo`, `TTableOf<T>`). Runtime SQL goes through `SQL.Connection` / `SQL.Command`.

This file is the module contract. Do not open `.bas` files to call the API. Open implementation only to confirm a detail that is missing here.

## Quick Start (Minimal)

```
Imports mod_configurador
Imports configurador_tabela
Imports configurador_campo

' Load the full dictionary graph for one table (JSON path on MSSQL / ASA / PostgreSQL).
Dim t As Tabela = Configurador.CarregarTabela("CaixaOperador")

' Mark Campo.Exists from physical columns; extras stay out (default False).
t.VerificarCamposFisicos()

' Fill Tabela.Acesso and each Processo.Acesso for this user. Acesso is never Null.
t.CarregarAcessos(1)

Dim c As Campo = t.CampoPorNome("CodEmpresa")   ' Null if the name is missing
print(c.EditarInclusao)                         ' cached AvaliarCondicao; empty → True
print(c.Obrigatorio)                            ' cached AvaliarCondicao; empty → False
print(t.Acesso.PermitidoAlterar)                ' False when no AcessoTabela row exists

' Optional: splice FormulaCalculoValor into a host SELECT when Contexto = "C".
print(c.Valor("SELECT :CodEmpresa, * FROM TipoOperacaoSaida WHERE CodTipoOperacaoSaida = 2"))

t.Free()
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_configurador.bas` | `mod_configurador` | `Configurador` |
| `src/Configurador/configurador_motor.bas` | `configurador_motor` | `Motor` |
| `src/Configurador/configurador_catalogo.bas` | `configurador_catalogo` | `Catalogo` |
| `src/Configurador/configurador_sql.bas` | `configurador_sql` | `TCfgSql`, `TCfgDb`, `TCfgRow`, `TCfgFlag` |
| `src/Configurador/configurador_lote.bas` | `configurador_lote` | `PacoteTabela`, `TCfgLoad` |
| `src/Configurador/Tables/configurador_tcfgbase.bas` | `configurador_tcfgbase` | `FoldBoolToken`, `TCfgBase` |
| `src/Configurador/Tables/configurador_tabela.bas` | `configurador_tabela` | `Tabela` |
| `src/Configurador/Tables/configurador_campo.bas` | `configurador_campo` | `Campo` |
| `src/Configurador/Tables/configurador_pasta.bas` | `configurador_pasta` | `Pasta` |
| `src/Configurador/Tables/configurador_campo_busca.bas` | `configurador_campo_busca` | `CampoBusca` |
| `src/Configurador/Tables/configurador_pesquisa.bas` | `configurador_pesquisa` | `Pesquisa` |
| `src/Configurador/Tables/configurador_filtro.bas` | `configurador_filtro` | `Filtro`, `FiltroCampo` |
| `src/Configurador/Tables/configurador_legenda.bas` | `configurador_legenda` | `Legenda` |
| `src/Configurador/Tables/configurador_processo.bas` | `configurador_processo` | `Processo` |
| `src/Configurador/Tables/configurador_acesso_tabela.bas` | `configurador_acesso_tabela` | `AcessoTabela` |
| `src/Configurador/Tables/configurador_acesso_processo.bas` | `configurador_acesso_processo` | `AcessoProcesso` |
| `src/Configurador/Tables/configurador_ajuda.bas` | `configurador_ajuda` | `Ajuda` |
| `src/Configurador/Tables/configurador_grupotabela.bas` | `configurador_grupotabela` | `GrupoTabela` |
| `src/Configurador/Tables/configurador_relatorio.bas` | `configurador_relatorio` | `Relatorio`, `LayoutRelatorio`, `GrupoLayoutRelatorio`, `EnvioEmailLayout`, `GrupoRelatorio`, `WhatsAppEnvio` |
| `src/Tables/table_tabela.bas` | `table_tabela` | `TTabela` |
| `src/Tables/table_campo.bas` | `table_campo` | `TCampo` |
| `src/Tables/table_pasta.bas` | `table_pasta` | `TPasta` |
| `src/Tables/table_filtro.bas` | `table_filtro` | `TFiltro` |
| `src/Tables/table_campofiltro.bas` | `table_campofiltro` | `TCampoFiltro` |
| `src/Tables/table_pesquisapadrao.bas` | `table_pesquisapadrao` | `TPesquisaPadrao` |
| `src/Tables/table_campobuscapesquisapadrao.bas` | `table_campobuscapesquisapadrao` | `TCampoBuscaPesquisaPadrao` |
| `src/Tables/table_processotabela.bas` | `table_processotabela` | `TProcessoTabela` |
| `src/Tables/table_ajuda.bas` | `table_ajuda` | `TAjuda` |
| `src/Tables/table_grupotabela.bas` | `table_grupotabela` | `TGrupoTabela` |
| `src/Tables/table_acessotabela.bas` | `table_acessotabela` | `TAcessoTabela` |
| `src/Tables/table_acessoprocessotabela.bas` | `table_acessoprocessotabela` | `TAcessoProcessoTabela` |
| `src/Tables/table_relatorio.bas` | `table_relatorio` | `TRelatorio` |
| `src/Tables/table_layoutrelatorio.bas` | `table_layoutrelatorio` | `TLayoutRelatorio` |
| `src/Tables/table_envioemaillayoutrelatorio.bas` | `table_envioemaillayoutrelatorio` | `TEnvioEmailLayoutRelatorio` |
| `src/Tables/table_dicionario_legendatabela.bas` | `table_dicionario_legendatabela` | `TDicionarioLegendaTabela` |
| `src/Tables/table_dicionario_gruporelatorio.bas` | `table_dicionario_gruporelatorio` | `TDicionarioGrupoRelatorio` |
| `src/Tables/table_dicionario_grupolayoutrelatorio.bas` | `table_dicionario_grupolayoutrelatorio` | `TDicionarioGrupoLayoutRelatorio` |
| `src/Tables/table_dicionario_whatsappconfiguracoesenvio.bas` | `table_dicionario_whatsappconfiguracoesenvio` | `TDicionarioWhatsAppConfiguracoesEnvio` |
| `src/Principal.bas` | *(no namespace)* | Host smoke script. There is no `TXxxxTests.RunAll` in this module. |

`data7_modules/` is the vendored `mod_table` + core copies. Their API is the `mod_table` contract, not this one.

---

## Facade

`Configurador` and `Motor` construct a fully hydrated `Tabela` or a fully hydrated `Relatorio`. They do not cache instances.

```
' Configurador / Motor — identical overloads
Shared Function CarregarTabela(pCodTabela As Integer) As Tabela
   ' out: New Tabela(pCodTabela). Throws if the row is missing.
End Function

Shared Function CarregarTabela(pNome As String, pSchema As String = "") As Tabela
   ' pSchema "" → dialect DefaultSchema() in the WHERE.
   ' Throws: "Tabela não encontrada: Nome" or "Tabela não encontrada: Schema.Nome"
End Function

Shared Function CarregarRelatorio(pCodRelatorio As Integer) As Relatorio
   ' out: New Relatorio(pCodRelatorio). Throws if the row is missing.
End Function
```

Prefer `Configurador.*` from a consumer. `Motor.*` is the same call.

---

## Table load (`Tabela`)

`Tabela` is the dictionary root for one catalog row in physical table `Tabela`. Constructors that take a key **hydrate children**. `Tabela.Fetch` / `Catalogo.FindTabela` fill **only the table row** (empty collections, default `Acesso`).

### Constructors and load

```
Sub New()
   ' Empty graph. Collections = []. Acesso = New AcessoTabela(). Grupo = Null.
End Sub

Sub New(pCodTabela As Integer)
   ' WHERE: codtabela = pCodTabela
   ' Throws: "Tabela não encontrada: codtabela=N"
End Sub

Sub New(pNome As String, pSchema As String = "")
   ' WHERE: UPPER(nome) = UCase(Trim(pNome)) AND schema coalesce (see TCfgSql.NomeSchema)
   ' Throws: "Tabela não encontrada: Nome" or "Tabela não encontrada: Schema.Nome"
End Sub

Shared Function Fetch(pWhere As String = "", pOrder As String = "ORDER BY nomeschema, nome") As TTList<Tabela>
   ' SELECT * FROM Tabela. Does not load Campos/Pastas/… . Caller owns the list.
End Function
```

Load algorithm (constructors with a key):

1. If `PacoteTabela.SuportaJson()` (`dbMSSQL` / `dbASA` / `dbPostgreSQL`): one query (`PacoteTabela.SqlDefinicao`) → `Fill` the table row from the query → `PacoteTabela.DoQuery` for JSON bags.
2. Else: `SELECT *` on `Tabela`; if EOF, throw; then `PacoteTabela.Fetch(CodTabela)` (N+1 queries).
3. Empty `NomeSchema` is replaced with `TSql.Dialect().DefaultSchema()`.
4. `Acesso.CodTabela` is set; flags stay `False` until `CarregarAcessos`.
5. Package lists are moved onto `Tabela` (package is freed). If `Grupo` is still Null and `CodGrupoTabela <> 0`, `GrupoTabela.Find`.
6. `LigarNavegacao` wires object pointers (see Internal flows).

### Identity, flags, text

| Member | Type | Notes |
|---|---|---|
| `CodTabela` | `Integer` | Dictionary PK. `GetID` = `CStr(CodTabela)`. |
| `Nome` / `Titulo` | `String` | Physical table name / caption. |
| `NomeSchema` | `String` | After load, never left blank. |
| `CodGrupoTabela` | `Integer` | `0` → no group lookup. |
| `CodCampoAutoIncremento` | `Integer` | `0` → `CampoAutoIncremento()` is Null. |
| `CodCampoEstrutura`, `CodCampoLegenda1`, `CodCampoLegenda2`, `CodCampoPreferenciaPesquisa`, `CodCampoOrdemPadrao` | `Integer` | Codes into `Campos`; `0` means none. |
| `CodTabelaEdicao`, `CodPastaTabelaEdicao`, `CodTabelaPropriedadeCampo` | `Integer` | |
| `CodRelatorioInclusao` | `Integer` | `0` → `RelatorioInclusao` stays Null. |
| `CodDBSpaceTabela`, `CodDBSpaceIndice`, `MargemEditor`, `AlturaQuadroRolagem` | `Integer` | |
| `Proprietario`, `Observacao`, `DllFormEdicao`, `OrdemCampoOrdemPadrao`, `Descricao` | `String` | |
| `LogProcessosAtivo`, `LogInclusaoAtivo`, `LogExclusaoAtivo`, `LogAlteracaoAtivo` | `String` | Stored tokens, not evaluated. |
| `FiltroFixoGrade`, `ModeloLayout` | `String` | |
| `ValidacaoInclusao`, `ValidacaoAlteracao`, `ValidacaoExclusao`, `ValidacaoVisualizacao` | `String` | SQL/script text; not run by this module. |
| `ArquivoProjetoApoio` | `String` | |
| `ControlaPorEmpresa`, `UtilizaGradeZebrada`, `ConfirmaInclusao`, `ConfirmaAlteracao`, `DesabilitaExclusao`, `DesabilitaVisualizacao`, `DesabilitaInclusao`, `DesabilitaAlteracao`, `ExibirDentroQuadroRolagem`, `EditaNaGrade`, `TodosRegistrosNoInicio`, `PermiteMultiplaSelecaoNaGrade`, `UsarCacheDeObjeto`, `InclusaoRecursiva` | `Boolean` | `GetFlagAsBoolean` on `"S"` only. Default `False`. |

### Graph

| Member | Type | Ownership |
|---|---|---|
| `Grupo` | `GrupoTabela` | Owned. Null if no row. |
| `Campos` | `TTList<Campo>` | Owned. |
| `Pastas` | `TTList<Pasta>` | Owned. |
| `Legendas` | `TTList<Legenda>` | Owned. |
| `Filtros` | `TTList<Filtro>` | Owned. |
| `Pesquisas` | `TTList<Pesquisa>` | Owned. |
| `Processos` | `TTList<Processo>` | Owned. |
| `Ajudas` | `TTList<Ajuda>` | Owned. |
| `Acesso` | `AcessoTabela` | Owned. **Never Null** after `New`. |
| `RelatorioInclusao` | `Relatorio` (Get) | Lazy. Owned when loaded. |

```
Property RelatorioInclusao As Relatorio
   ' First Get: if CodRelatorioInclusao <> 0 then Relatorio.Carregar(code) (Null if missing, no throw).
   ' Later Gets return the cached pointer (including Null).
End Property
```

### Lookups (in-memory, after a key constructor)

```
Function CampoPorCodigo(pCodCampo As Integer) As Campo   ' 0 or miss → Null
Function CampoPorNome(pNome As String) As Campo          ' UCase(Trim) vs Campo.Nome; miss → Null
Function PastaPorCodigo(pCodPasta As Integer) As Pasta   ' 0 or miss → Null
Function FiltroPorCodigo(pCodFiltro As Integer) As Filtro
Function PesquisaPorCodigo(pCodPesquisa As Integer) As Pesquisa   ' matches CodPesquisaPadrao
Function ProcessoPorCodigo(pCodProcesso As Integer) As Processo   ' matches CodProcessoTabela
Function CamposChave() As TTList<Campo>
   ' New list, OwnsObjects = False. Caller Frees the list, not the Campo items.
End Function
Function CampoAutoIncremento() As Campo                  ' CampoPorCodigo(CodCampoAutoIncremento)
```

`Campo.GetID` is `Nome`, so `t.Campos.Take("CodEmpresa")` resolves by field name.

### Physical columns

```
Sub VerificarCamposFisicos(pIncluirExtras As Boolean = False)
   ' TSql.DescribeColumns(NomeSchema, Nome). Match UCase(Trim(name)).
   ' 1. Every catalog Campo.Exists = (physical column present). Extra unchanged (default False).
   ' 2. If pIncluirExtras: physical names not in the catalog are appended:
   '    Nome = Titulo = column name, Tamanho = MaxLength, Chave = PrimaryKey,
   '    Exists = True, Extra = True, CodTabela = this table.
End Sub
```

No-op on the catalog when the physical table has no extra columns and `pIncluirExtras` is False (only `Exists` flags change).

### Access

```
Sub CarregarAcessos(pCodUsuario As Integer)
   ' 1. AcessoTabela.Find(CodTabela, pCodUsuario). Hit → replace Acesso.
   '    Miss → New AcessoTabela with CodTabela + CodUsuario; all Permitido* stay False.
   ' 2. If Processos.Length = 0: stop (table access is already applied).
   ' 3. AcessoProcesso.FetchByUsuario; match CodProcessoTabela; Processo.AplicarAcesso.
   '    No row → dummy AcessoProcesso with keys filled, Permitido = False.
   '    Unmatched access rows are freed.
End Sub
```

---

## Field (`Campo`)

One row of physical `Campo`. Lives on `Tabela.Campos`. `Pasta` / `Pesquisa` are back-pointers set by `LigarNavegacao` (not owned).

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodCampo` | `Integer` | |
| `Nome` | `String` | `GetID`. Used by `CampoPorNome` and `Take(name)`. |
| `Tipo` | `String` | Dictionary type token (e.g. stored `"I"`, `"S"`); not interpreted here. |
| `Titulo`, `TituloGrade`, `TituloRelatorio`, `TituloPesquisa`, `TituloEdicao` | `String` | |
| `Tamanho`, `CasasDecimal`, `OrdemEdicao`, `OrdemGrade`, `OrdemPesquisa` | `Integer` | |
| `MascaraEdicao`, `MascaraGrade` | `String` | |
| `Contexto` | `String` | `"C"` enables `Valor()`. Any other token (including `""`) → `Valor` returns `""`. |
| `CodPasta` | `Integer` | `0` → `Pasta` stays Null. |
| `CodPesquisaPadrao` | `Integer` | `0` → `TemPesquisa() = False`, `Pesquisa` Null. |
| `FormulaValorPadrao`, `TipoValorPadrao` | `String` | See `ValorPadrao`. |
| `ListaOpcao` | `String` | Opaque dictionary text. **Not parsed.** Empty default `""`. |
| `CondicaoObrigatorio`, `CondicaoVisivelGrade`, `CondicaoVisivelEdicao`, `CondicaoVisivelPesquisa`, `CondicaoEditarInclusao`, `CondicaoEditarAlteracao`, `CondicaoPesquisaEspecifica` | `String` | Condition tokens or SQL; see properties below for which are evaluated. |
| `ValidacaoUsuario`, `ValidacaoSistema` | `String` | Not run here. |
| `CodMensagemValidacaoUsuario`, `CodMensagemValidacaoSistema` | `String` | |
| `FormulaCalculoValor` | `String` | Used by `Valor` when `Contexto = "C"`. |
| `ScriptOnExit`, `ScriptOnEnter` | `String` | |
| `Chave` | `Boolean` | Flag `"S"`. Drives `CamposChave()`. |
| `TipoPesquisa`, `ExibirResumo`, `Caractere`, `TipoCaractere`, `CharCase`, `AlinhamentoEdicao`, `NomeFonteEdicao`, `Especifico`, `Duplicidade` | `String` | |
| `VisivelRelatorio`, `VisivelParametroRelatorio`, `ExibirNoRodapePesquisa`, `ExibirNoRodapeGrade`, `FonteNegritoEdicao`, `FonteItalicoEdicao`, `FonteSublinhadoEdicao`, `FonteRiscadoEdicao`, `PesquisaIncremental` | `Boolean` | Flag `"S"`. |
| `ManterConteudo` | `Boolean` | **`UCase(Trim(value)) = "SIM"` only** (not `"S"`). |
| `LarguraGrade`, `LarguraEdicao`, `LarguraPesquisa`, `PosicaoX`, `PosicaoY`, `AlturaEdicao`, `TamanhoFonteEdicao`, `CorFonteEdicao`, `CondicaoPadrao`, `Coluna` | `Integer` | |
| `TituloInicialParametroRelatorio`, `TituloFinalParametroRelatorio` | `String` | |
| `Exists` | `Boolean` | Default `False`. Set by `VerificarCamposFisicos`. |
| `Extra` | `Boolean` | Default `False`. `True` only for columns appended with `pIncluirExtras`. |
| `Pasta` | `Pasta` | Alias. Null if `CodPasta = 0` or pasta missing. |
| `Pesquisa` | `Pesquisa` | Alias. Null if `CodPesquisaPadrao = 0` or search missing. |

```
Property EditarInclusao As Boolean
   ' TCfgSql.AvaliarCondicao(CondicaoEditarInclusao, True) — empty → True. Cached.
End Property
Property EditarAlteracao As Boolean
   ' AvaliarCondicao(CondicaoEditarAlteracao, True) — empty → True. Cached.
End Property
Property Obrigatorio As Boolean
   ' AvaliarCondicao(CondicaoObrigatorio) — empty → False. Cached.
End Property
Property ValorPadrao As String
   ' TCfgSql.AvaliarValorPadrao(TipoValorPadrao, FormulaValorPadrao). Cached.
End Property

Function Valor(pQueryBase As String = "") As String
   ' Cached per Trim(pQueryBase). Delegates TCfgSql.AvaliarValor(Contexto, FormulaCalculoValor, Nome, query).
End Function

Function TemPesquisa() As Boolean
   ' CodPesquisaPadrao <> 0
End Function

Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codpasta, ordemedicao, codcampo") As TTList<Campo>
Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Campo>
Shared Function Find(pCodTabela As Integer, pCodCampo As Integer) As Campo          ' Null if EOF
Shared Function FindPorNome(pCodTabela As Integer, pNome As String) As Campo        ' UPPER(nome); Null if EOF
```

`Dispose` only nulls `Pasta` / `Pesquisa` (does not free them).

---

## Folders, searches, filters, legends, help, group

### `Pasta` — physical `Pasta`

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodPasta` | `Integer` | `GetID` = `CStr(CodPasta)`. |
| `Titulo`, `Proprietario`, `Status`, `Estrutura` | `String` | |
| `MargemEditor` | `Integer` | |
| `SubCadastro` | `String` | Flag token; `EhSubcadastro()` uses `GetFlagAsBoolean` (`"S"`). |
| `Campos` | `TTList<Campo>` | **`OwnsObjects = False`**. Filled by `LigarNavegacao`. |

```
Function EhSubcadastro() As Boolean
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codpasta") As TTList<Pasta>
Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Pasta>
Shared Function Find(pCodTabela As Integer, pCodPasta As Integer) As Pasta   ' Null if EOF
```

### `Pesquisa` — physical `PesquisaPadrao`

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodPesquisaPadrao` | `Integer` | `GetID` = `CStr(CodPesquisaPadrao)`. |
| `CodCampoDescricao`, `CodCampoChave` | `Integer` | `0` → pointer stays Null. |
| `Titulo`, `Proprietario`, `ExpressaoFiltro`, `DllFormPesquisa` | `String` | |
| `PermiteExcluir`, `PermiteIncluir`, `AbrirPosicionado`, `ExibirDesativado`, `ManterUltimoFiltro` | `String` | Stored; not coerced to Boolean. |
| `PermiteCadastroDireto`, `PermiteInclusaoCadastroDireto`, `PermiteAlteracaoCadastroDireto`, `PermiteVisualizarCadastroDireto` | `String` | |
| `AtalhoAbrirPesquisa`, `AtalhoInclusao`, `AtalhoAlteracao`, `AtalhoVisualizacao` | `String` | |
| `ExibeBotaoInclusao`, `ExibeBotaoAlteracao`, `ExibeBotaoVisualizacao` | `String` | |
| `CodImagem`, `CodScripter`, `CodTabelaCadastroDireto` | `Integer` | |
| `CamposBusca` | `TTList<CampoBusca>` | Owned. Attached by `TCfgLoad.AnexarBuscas*`. |
| `CampoChave`, `CampoDescricao` | `Campo` | Aliases. Null if code is `0` or field missing. |

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY titulo") As TTList<Pesquisa>
Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Pesquisa>
Shared Function Find(pCodPesquisaPadrao As Integer) As Pesquisa   ' Null if EOF
```

### `CampoBusca` — physical `CampoBuscaPesquisaPadrao`

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodPesquisaPadrao`, `CodCampo`, `Ordem` | `Integer` | `GetID` = `CodTabela & "-" & CodCampo`. |
| `Condicao` | `String` | Opaque. Empty default. |
| `Campo` | `Campo` | Alias; Null if `CodCampo = 0` or missing. |

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<CampoBusca>
```

A busca whose `CodPesquisaPadrao` is not in the loaded `Pesquisas` list is **freed and ignored**.

### `Filtro` / `FiltroCampo` — physical `Filtro` / `CampoFiltro`

`Filtro`:

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodFiltro` | `Integer` | `GetID` = `CStr(CodFiltro)`. |
| `Nome`, `Proprietario` | `String` | |
| `CamposFiltro` | `TTList<FiltroCampo>` | Owned. |

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codfiltro") As TTList<Filtro>
Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Filtro>
```

`FiltroCampo`:

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodFiltro`, `CodCampo`, `Ordem` | `Integer` | |
| `ValorPadrao` | `String` | Stored default; not `Campo.ValorPadrao`. |
| `Visivel`, `Editavel` | `String` | Tokens as stored (e.g. `"S"` / `"N"`); not converted. |
| `Proprietario`, `Condicao`, `Titulo`, `Comando`, `SQLWhereCondition` | `String` | `SQLWhereCondition` is the extra WHERE fragment as stored. |
| `Campo` | `Campo` | Alias. |

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<FiltroCampo>
```

A `FiltroCampo` whose `CodFiltro` is not in the loaded `Filtros` list is **freed and ignored**.

### `Legenda` — physical `Dicionario.LegendaTabela`

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodLegendaTabela`, `Ordem` | `Integer` | `GetID` = `CStr(CodLegendaTabela)`. |
| `Descricao`, `TipoLegenda` | `String` | |

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codlegendatabela") As TTList<Legenda>
Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Legenda>
```

### `Ajuda` — physical `Ajuda`

| Member | Type | Notes |
|---|---|---|
| `CodAjuda` | `Integer` | `GetID`. |
| `CodAjudaPai`, `CodTabela`, `CodCampo`, `CodRelatorio`, `CodProcessoTabela`, `CodFiltro`, `CodLegendaTabela`, `CodModulo`, `CodPesquisaPadrao`, `CodGatilho`, `CodRegraValidacao`, `CodProcedureFunction` | `Integer` | |
| `Conteudo`, `Descricao`, `CodMensagem`, `NomeParametro` | `String` | |
| JSON key for parent | | `Fill(json)` reads `"codajudaPai"` (capital `P`). |

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codajuda") As TTList<Ajuda>
```

### `GrupoTabela` — physical `GrupoTabela`

| Member | Type | Notes |
|---|---|---|
| `CodGrupoTabela` | `Integer` | `GetID`. |
| `Nome`, `Proprietario` | `String` | |

```
Shared Function Find(pCodGrupoTabela As Integer) As GrupoTabela   ' Null if EOF
```

---

## Processes and access

### `Processo` — physical `ProcessoTabela`

| Member | Type | Notes |
|---|---|---|
| `CodTabela`, `CodProcessoTabela` | `Integer` | `GetID` = `CStr(CodProcessoTabela)`. |
| `Titulo`, `Imagem`, `LocalExibir`, `Proprietario`, `Acao`, `ValorAcao`, `Bloquear`, `VerificarBloqueio`, `Validacao`, `Status` | `String` | Not executed here. |
| `Ordem`, `ShortCut`, `CodWhatsAppConfiguracoesEnvio` | `Integer` | |
| `Acesso` | `AcessoProcesso` | **Never Null** after `New` / `Fill` / `AplicarAcesso`. |

```
Sub PrepararAcesso()
   ' Ensures Acesso exists; copies CodTabela + CodProcessoTabela. Called from Fill.
End Sub

Sub AplicarAcesso(pRow As AcessoProcesso, pCodUsuario As Integer)
   ' Assigned(pRow) → take that instance (caller must not Free it afterwards).
   ' Else New AcessoProcesso with CodTabela, CodProcessoTabela, CodUsuario; Permitido = False.
   ' Previous Acesso is Freed if it is a different object.
End Sub

Sub CarregarAcesso(pCodUsuario As Integer)
   ' AplicarAcesso(AcessoProcesso.Find(...), pCodUsuario). Find miss → dummy row.
End Sub

Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codprocessotabela") As TTList<Processo>
Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Processo>
```

### `AcessoTabela` — physical `AcessoTabela`

All `Permitido*` default `False`. `Fill` sets the internal loaded flag. `Find` miss → **Null** (the dummy instance is created by `Tabela.CarregarAcessos`, not by `Find`).

| Member | Type |
|---|---|
| `CodUsuario`, `CodTabela` | `Integer` |
| `PermitidoExcluir`, `PermitidoIncluir`, `PermitidoAlterar`, `PermitidoVisualizar`, `PermitidoConsultar`, `PermitidoExportar`, `PermitidoAnaliseGerencial`, `PermitidoOpcoesColuna`, `PermitidoIncluirAnexo`, `PermitidoAlterarAnexo`, `PermitidoExcluirAnexo`, `PermitidoVisualizarAnexo`, `PermitidoSalvarAnexo` | `Boolean` (`"S"`) |

`GetID` = `CodTabela & "-" & CodUsuario`.

```
Shared Function Find(pCodTabela As Integer, pCodUsuario As Integer) As AcessoTabela   ' Null if EOF
```

### `AcessoProcesso` — physical `AcessoProcessoTabela`

| Member | Type |
|---|---|
| `CodUsuario`, `CodTabela`, `CodProcessoTabela` | `Integer` |
| `Permitido` | `Boolean` (`"S"`). Default `False`. |

`GetID` = `CStr(CodProcessoTabela)` (user is not in the id).

```
Shared Function FetchByUsuario(pCodTabela As Integer, pCodUsuario As Integer) As TTList<AcessoProcesso>
Shared Function Find(pCodTabela As Integer, pCodProcessoTabela As Integer, pCodUsuario As Integer) As AcessoProcesso
   ' Null if EOF
```

---

## Reports (`Relatorio`)

Physical `Relatorio`. Related rows load in **separate** `SELECT *` queries (`CarregarRelacionados`). `Relatorio.Fetch` does **not** load related graphs.

```
Sub New()                                      ' empty lists; Grupo / WhatsApp Null
Sub New(pCodRelatorio As Integer)
   ' Throws: "Relatório não encontrado: codrelatorio=N"
   ' Then CarregarRelacionados.
End Sub

Shared Function Carregar(pCodRelatorio As Integer) As Relatorio
   ' Null if missing (used by Tabela.RelatorioInclusao). Does not throw.
End Function

Shared Function Fetch(pWhere As String = "", pOrder As String = "ORDER BY titulo") As TTList<Relatorio>
   ' Header rows only.
End Function

Sub CarregarRelacionados()
   ' LayoutRelatorio WHERE codrelatorio = N ORDER BY ordem, item
   ' GrupoLayoutRelatorio (schema Dicionario) ORDER BY ordem, descricao
   ' EnvioEmailLayoutRelatorio (no default ORDER)
   ' If CodGrupoRelatorio <> 0: GrupoRelatorio.Find (may be Null)
   ' If CodWhatsAppConfiguracoesEnvio <> 0: WhatsAppEnvio.Find (may be Null)
End Sub
```

| Member | Type | Notes |
|---|---|---|
| `CodRelatorio` | `Integer` | `GetID`. |
| `Titulo` | `String` | |
| `CodGrupoRelatorio`, `CodWhatsAppConfiguracoesEnvio` | `Integer` | `0` skips Find. |
| `Layouts` | `TTList<LayoutRelatorio>` | Owned. |
| `GruposLayout` | `TTList<GrupoLayoutRelatorio>` | Owned. |
| `EnviosEmail` | `TTList<EnvioEmailLayout>` | Owned. |
| `Grupo` | `GrupoRelatorio` | Owned when found. |
| `WhatsApp` | `WhatsAppEnvio` | Owned when found. |

### `LayoutRelatorio` — physical `LayoutRelatorio`

String flags (`Ativo`, `Selecionado`, `Solicitar`, `Obrigatorio`, `ImprimirCapa`, …) are stored as dictionary text, **not** converted to Boolean. `Selecionado` is **not** filtered by this module.

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, item") As TTList<LayoutRelatorio>
```

Members: `CodRelatorio`, `Item`, `Titulo`, `Ordem`, `Ajuda`, `Exemplo`, `Ativo`, `Arquivo`, `NumeroCopia`, `ImpressoraPadrao`, `Orientacao`, `TamanhoPapel`, `Largura`, `Altura`, `Selecionado`, `Solicitar`, `Aviso`, `Acao`, `NomeArquivo`, `CodUsuario`, `CodEstacao`, `CodEmpresa`, `CodFilial`, `ArquivoFisico`, `CodGrupoLayoutRelatorio`, `Repx`, `SalvarAutomaticamenteEmDisco`, `PastaSalvarAutomaticamenteEmDisco`, `CodProjeto`, `ImprimirCapa`, `ExibirParametroCapaVazio`, `Obrigatorio`.

### `GrupoLayoutRelatorio` — `Dicionario.GrupoLayoutRelatorio`

```
Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, descricao") As TTList<GrupoLayoutRelatorio>
```

Members: `CodRelatorio`, `CodGrupoLayoutRelatorio`, `Descricao`, `CodGrupoLayoutRelatorioInferior`, `Ordem`.

### `EnvioEmailLayout` — physical `EnvioEmailLayoutRelatorio`

```
Shared Function Fetch(pWhere As String, pOrder As String = "") As TTList<EnvioEmailLayout>
```

Members: `CodRelatorio`, `Item`, `Destinatario`, `Assunto`, `Conteudo`, `TipoValores`, `FormaEnvio`.

### `GrupoRelatorio` — `Dicionario.GrupoRelatorio`

```
Shared Function Find(pCodGrupoRelatorio As Integer) As GrupoRelatorio   ' Null if EOF
```

Members: `CodGrupoRelatorio`, `Descricao`, `Ordem`, `CodGrupoRelatorioInferior`.

### `WhatsAppEnvio` — `Dicionario.WhatsAppConfiguracoesEnvio`

```
Shared Function Find(pCod As Integer) As WhatsAppEnvio   ' Null if EOF
```

Members: `CodWhatsAppConfiguracoesEnvio`, `Descricao`, `ExibirFormularioEnvio`, `OrigemContatoPadrao`, `ValorContatoPadrao`, `OrigemListaContatos`, `ValorListaContatos`, `OrigemAssunto`, `ValorAssunto`, `OrigemCorpoMensagem`, `ValorCorpoMensagem`, `OrigemAssinatura`, `ValorAssinatura`, `Observacoes`, `Teste_CodTabela`, `Teste_CodRelatorio`, `Teste_FiltroSQL`.

---

## Catalog (`Catalogo`)

Query facade. **No string→class registry** and no `Make` / `MakeByName`. Name lookup is `FindTabela(pNome, pSchema)` via `TCfgSql.NomeSchema`.

**Hydration:** `FindTabela` uses `Tabela.Fetch` → header only (empty child lists). Use `Configurador.CarregarTabela` / `New Tabela(...)` for the full graph. `FindRelatorio` uses `Relatorio.Carregar` → full related load, **Null** if missing. Other `Find*` / `*DaTabela` return the objects those `Fetch`/`Find` methods return (no `LigarNavegacao`).

```
Shared Function Tabelas(pWhere As String = "", pOrder As String = "ORDER BY nomeschema, nome") As TTList<Tabela>
Shared Function FindTabela(pCodTabela As Integer) As Tabela                          ' Null if none
Shared Function FindTabela(pNome As String, pSchema As String = "") As Tabela        ' Null if none

Shared Function Campos(pWhere As String, pOrder As String = "ORDER BY ordemedicao, ordemgrade, nome") As TTList<Campo>
Shared Function CamposDaTabela(pCodTabela As Integer) As TTList<Campo>
Shared Function FindCampo(pCodTabela As Integer, pCodCampo As Integer) As Campo
Shared Function FindCampo(pCodTabela As Integer, pNome As String) As Campo

Shared Function Pastas(pWhere As String, pOrder As String = "ORDER BY codpasta") As TTList<Pasta>
Shared Function PastasDaTabela(pCodTabela As Integer) As TTList<Pasta>
Shared Function FindPasta(pCodTabela As Integer, pCodPasta As Integer) As Pasta

Shared Function Legendas(pWhere As String, pOrder As String = "ORDER BY ordem, codlegendatabela") As TTList<Legenda>
Shared Function LegendasDaTabela(pCodTabela As Integer) As TTList<Legenda>

Shared Function Filtros(pWhere As String, pOrder As String = "ORDER BY codfiltro") As TTList<Filtro>
Shared Function FiltrosDaTabela(pCodTabela As Integer) As TTList<Filtro>
Shared Function CamposFiltro(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<FiltroCampo>
Shared Function CamposFiltroDaTabela(pCodTabela As Integer) As TTList<FiltroCampo>

Shared Function Pesquisas(pWhere As String, pOrder As String = "ORDER BY titulo") As TTList<Pesquisa>
Shared Function PesquisasDaTabela(pCodTabela As Integer) As TTList<Pesquisa>
Shared Function FindPesquisa(pCodPesquisaPadrao As Integer) As Pesquisa
Shared Function CamposBusca(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<CampoBusca>

Shared Function Processos(pWhere As String, pOrder As String = "ORDER BY ordem, codprocessotabela") As TTList<Processo>
Shared Function ProcessosDaTabela(pCodTabela As Integer) As TTList<Processo>

Shared Function Ajudas(pWhere As String, pOrder As String = "ORDER BY codajuda") As TTList<Ajuda>
Shared Function AjudasDaTabela(pCodTabela As Integer) As TTList<Ajuda>

Shared Function FindGrupo(pCodGrupoTabela As Integer) As GrupoTabela

Shared Function Relatorios(pWhere As String = "", pOrder As String = "ORDER BY titulo") As TTList<Relatorio>
Shared Function FindRelatorio(pCodRelatorio As Integer) As Relatorio                 ' Null if missing
Shared Function Layouts(pWhere As String, pOrder As String = "ORDER BY ordem, item") As TTList<LayoutRelatorio>
Shared Function LayoutsDoRelatorio(pCodRelatorio As Integer) As TTList<LayoutRelatorio>

Shared Function FindAcessoTabela(pCodTabela As Integer, pCodUsuario As Integer) As AcessoTabela
Shared Function FindAcessoProcesso(pCodTabela As Integer, pCodProcessoTabela As Integer, pCodUsuario As Integer) As AcessoProcesso
```

`pWhere` is a SQL fragment consumed by `TSql.Dialect().NormalizeWhere`, e.g. `"codtabela = 12"` or `TCfgSql.Tabela(12)` → `"codtabela = 12"`. Empty where means all rows.

---

## SQL and flags

### `TCfgSql`

```
Shared Function Str(pValue As String) As String
   ' "'" & Trim(pValue).Replace("'", "''") & "'"
End Function
Shared Function Int(pValue As Integer) As String                    ' CStr
Shared Function EqInt(pField As String, pValue As Integer) As String
   ' "codtabela = 12"
End Function
Shared Function EqStr(pField As String, pValue As String) As String
   ' "nome = 'CaixaOperador'"
End Function
Shared Function EqStrCI(pField As String, pValue As String) As String
   ' "UPPER(nome) = 'CAIXAOPERADOR'"
End Function
Shared Function AndInt(pLeft As String, pField As String, pValue As Integer) As String
Shared Function Tabela(pCodTabela As Integer) As String             ' EqInt("codtabela", n)
Shared Function Usuario(pCodUsuario As Integer) As String           ' EqInt("codusuario", n)
Shared Function NomeSchema(pNome As String, pSchema As String) As String
   ' Trim(pSchema) = "" → DefaultSchema(). Combines EqStrCI("nome", pNome) AND EqSchema("NomeSchema", schema).
End Function
Shared Function EqSchema(pField As String, pSchema As String) As String
   ' PostgreSQL: COALESCE(NULLIF(field, ''), default)
   ' Else:       ISNULL(NULLIF(field, ''), default)
   ' Compared with UPPER(...) = UCase(Trim(pSchema))
End Function

Shared Function AvaliarCondicao(pExpr As String, pVazio As Boolean = False) As Boolean
   ' Trim "" → pVazio
   ' TCfgFlag.Sim → True
   ' TCfgFlag.Nao → False
   ' Else: TSql.ExecScalarInteger("SELECT CASE WHEN (" & expr & ") THEN 1 ELSE 0 END AS ok", 0) <> 0
End Function

Shared Function AvaliarValorPadrao(pTipo As String, pFormula As String) As String
   ' UCase(Trim(tipo)):
   '   "FIXO"                              → formula as-is
   '   "VARIAVEL" / "VARIÁVEL"             → AvaliarValorPadraoVariavel
   '   "FORMULA" / "FÓRMULA" / "SQL"       → AvaliarFormula
   '   formula ""                          → ""
   '   else                                → try variable; if "" then AvaliarFormula
End Function

Shared Function AvaliarValorPadraoVariavel(pFormula As String) As String
   ' UCase(Trim(formula)):
   '   "CODEMPRESA"      → CStr(Data7.CodEmpresa())
   '   "CODFILIAL"       → CStr(Data7.CodFilial())
   '   "CODUSUARIO"      → CStr(Data7.CodUsuario())
   '   "NOMEUSUARIO"     → Data7.NomeUsuario()
   '   "CODPERIODOCAIXA" → CStr(Data7.CodPeriodoCaixa())  (module-cached while the string is non-empty)
   '   "NOMECOMPUTADOR"  → Environment.MachineName()
   '   "DATAATUAL"       → DateTime().ToString("dd/mm/yyyy")
   '   "HORAATUAL"       → DateTime().ToString("hh:nn:ss.zzz")
   '   "DATAHORAATUAL"   → DateTime().ToString("dd/mm/yyyy hh:nn:ss.zzz")
   '   "MESATUAL"        → DateTime().ToString("mm")
   '   "ANOATUAL"        → DateTime().ToString("yyyy")
   '   else              → ""
End Function

Shared Function AvaliarValor(pConAsString As String, pFormula As String, pNomeCampo As String = "", pQueryBase As String = "") As String
   ' Trim(pConAsString) <> "C" or empty formula → ""
   ' Empty query → AvaliarFormula(formula)
   ' Else replace ":" & Trim(pNomeCampo) in query with "(" & formula & ") AS " & nome, then ExecutarColuna
   ' Example host: "SELECT :CodEmpresa, * FROM TipoOperacaoSaida WHERE CodTipoOperacaoSaida = 2"
End Function

Shared Function AvaliarFormula(pFormula As String) As String
   ' Trim "" → "". Else TSql.ExecSelect(formula)  (formula is a full SELECT)
End Function

Shared Function ExecutarColuna(pSql As String, pCampo As String) As String
   ' OpenQuery; EOF → ""; else Field(pCampo).AsString. Always Close + Free.
End Function
```

### `TCfgDb`

```
Shared Function FromSql(pSchema As String, pTabela As String) As String
   ' TSql.Dialect().QuoteTable — e.g. schema "" + "Tabela", or "Dicionario" + "LegendaTabela"
End Function
Shared Function SelectAll(pSchema As String, pTabela As String, pWhere As String, pOrder As String) As String
Shared Function Abrir(pSchema As String, pTabela As String, pWhere As String, pOrder As String) As SQL.Command
```

### `TCfgRow` — JSON scalar decode

`TJSONObject.GetString` is case-sensitive. Keys in `Fill(json)` are lowercase unless noted (`codajudaPai`).

```
Shared Function AsString(pValue As String) As String
   ' LCase(Trim) in {"", "null"} → Unassigned; else original pValue (case preserved)
End Function
Shared Function AsInteger(pValue As String) As Integer
   ' LCase(Trim) in {"", "null"} → Unassigned; else CInt(pValue)
End Function
Shared Function Flag(pJson As TJSONObject, pNome As String) As Boolean
   ' TCfgFlag.Sim(AsString(GetString(pNome)))
End Function
```

Domain `Fill(json)` uses `GetFlagAsBoolean(GetString(...))` for Booleans, **not** `TCfgRow.Flag` (so `"SIM"` is False on those fields).

### `TCfgFlag`

```
Shared Function Sim(pValue As String) As Boolean
   ' UCase(Trim) in: "S", "SIM", "1", "T", "TRUE", "NOT IS FALSE"
End Function
Shared Function Nao(pValue As String) As Boolean
   ' UCase(Trim) in: "", "N", "NAO", "NÃO", "0", "F", "FALSE", "FALSO", "NOT IS TRUE"
End Function
```

### `TCfgBase` / `FoldBoolToken`

`FoldBoolToken(pText)` uppercases `pText` in place via `CharUpperBuffW` and returns it.

```
MustInherit Class TCfgBase
   Sub New(pName As String, pBoolTrue As String = "S", pBoolFalse As String = "N")
      ' Stores folded true/false tokens. Default true token "S", false token "N".
   End Sub

   Overridable Function GetFlagAsBoolean(pValue As String) As Boolean
      ' FoldBoolToken(Trim(pValue)) = _boolTrue     → "S" is True; "SIM" is False
   End Function
   Overridable Function GetFlagAsString(pValue As Boolean) As String
      ' True → "S"; False → "N" (the constructor tokens)
   End Function

   MustOverride Overridable Sub Fill(pJson As TJSONObject)
   MustOverride Overridable Sub Fill(pQuery As SQL.Command)
End Class
```

---

## Package load (`PacoteTabela` / `TCfgLoad`)

Used by `Tabela` constructors. Consumers rarely call this unless they assemble a graph themselves.

```
' PacoteTabela
Campos[] As Campo
Pastas[] As Pasta
Legendas[] As Legenda
Filtros[] As Filtro
Pesquisas[] As Pesquisa
Processos[] As Processo
Ajudas[] As Ajuda
Grupo As GrupoTabela          ' Null when JSON array is empty / missing

Shared Function SuportaJson() As Boolean
   ' SQL.Connection.RDBMS in {dbMSSQL, dbASA, dbPostgreSQL}
End Function

Shared Function SqlDefinicao(pWhereTabela As String) As String
   ' Cached SELECT prefix (invalidated when the prefix String is "" or RDBMS changed)
   ' + Dialect.NormalizeWhere(pWhereTabela)
End Function

Shared Function DoQuery(pQuery As SQL.Command) As PacoteTabela
   ' Reads binary/text fields: cfg_campos, cfg_pastas, cfg_legendas, cfg_filtros,
   ' cfg_campofiltro, cfg_pesquisas, cfg_buscas, cfg_processos, cfg_ajudas, cfg_grupo
End Function

Shared Function Fetch(pCodTabela As Integer) As PacoteTabela
   ' N+1 path. Does not set Grupo (Tabela.FinalizarCarga calls GrupoTabela.Find).
End Function
```

```
' TCfgLoad
Shared Function SqlJson(pSchema As String, pTabela As String, pColunas As String, pWhere As String, pOrder As String, pAlias As String) As String
   ' PostgreSQL: (SELECT convert_to(CAST(json_agg(_j) AS text), 'WIN1252') FROM (inner) _j) AS alias
   ' MSSQL:      CAST(CAST((inner FOR JSON AUTO) AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS alias
   ' else/ASA:   CSCONVERT(CAST((inner FOR JSON RAW) AS LONG VARCHAR), 'windows-1252', 'utf-8') AS alias
End Function

Shared Function AbrirArray(pJson As String) As TJSONArray
   ' Trim "" or UCase = "NULL" → Null; else New TJSONArray(texto)
End Function

Shared Function CamposJson / PastasJson / LegendasJson / FiltrosJson / PesquisasJson / ProcessosJson / AjudasJson(pJson As String)
   ' Empty/null JSON → empty list [] (not Null)
End Function
Shared Function GrupoJson(pJson As String) As GrupoTabela
   ' Null JSON or Length <= 0 → Null; else Fill index 0
End Function

Shared Sub AnexarFiltroCampos(pFiltros, pJson)
Shared Sub AnexarBuscas(pPesquisas, pJson)
Shared Sub AnexarFiltroCamposLista(pFiltros, pCodTabela As Integer)
Shared Sub AnexarBuscasLista(pPesquisas, pCodTabela As Integer)
```

The SELECT prefix is `LCase`'d. JSON `Fill` keys are the lowercase column names except `Ajuda.CodAjudaPai` (`"codajudaPai"`).

---

## Persistence CRUDs (`src/Tables`)

Generated `TTableOf<T>` subclasses for **writing** dictionary rows. `Tabela` / `Campo` / `Relatorio` load paths do **not** instantiate them. Persistence methods (`Insert`, `Update`, `Find`, …) are `mod_table`.

| Class | Physical table | PK / AutoCode |
|---|---|---|
| `TTabela` | `Tabela` | `CodTabela` AutoCode |
| `TCampo` | `Campo` | `CodTabela` + `CodCampo` |
| `TPasta` | `Pasta` | `CodTabela` + `CodPasta` |
| `TFiltro` | `Filtro` | `CodTabela` + `CodFiltro` |
| `TCampoFiltro` | `CampoFiltro` | *(no `PrimaryKeyField` in schema)* |
| `TPesquisaPadrao` | `PesquisaPadrao` | `CodPesquisaPadrao` AutoCode; `CodTabela` required |
| `TCampoBuscaPesquisaPadrao` | `CampoBuscaPesquisaPadrao` | `CodTabela` + `CodPesquisaPadrao` + `CodCampo` + `Condicao` |
| `TProcessoTabela` | `ProcessoTabela` | `CodTabela` + `CodProcessoTabela` |
| `TAjuda` | `Ajuda` | `CodAjuda` AutoCode |
| `TGrupoTabela` | `GrupoTabela` | `CodGrupoTabela` AutoCode |
| `TAcessoTabela` | `AcessoTabela` | `CodUsuario` + `CodTabela` |
| `TAcessoProcessoTabela` | `AcessoProcessoTabela` | `CodUsuario` + `CodTabela` + `CodProcessoTabela` |
| `TRelatorio` | `Relatorio` | `CodRelatorio` AutoCode |
| `TLayoutRelatorio` | `LayoutRelatorio` | `CodRelatorio` + `Item` |
| `TEnvioEmailLayoutRelatorio` | `EnvioEmailLayoutRelatorio` | `CodRelatorio` + `Item` |
| `TDicionarioLegendaTabela` | `Dicionario.LegendaTabela` | `CodTabela` + `CodLegendaTabela` |
| `TDicionarioGrupoRelatorio` | `Dicionario.GrupoRelatorio` | `CodGrupoRelatorio` AutoCode |
| `TDicionarioGrupoLayoutRelatorio` | `Dicionario.GrupoLayoutRelatorio` | `CodGrupoLayoutRelatorio` AutoCode |
| `TDicionarioWhatsAppConfiguracoesEnvio` | `Dicionario.WhatsAppConfiguracoesEnvio` | `CodWhatsAppConfiguracoesEnvio` AutoCode |

```
Dim row As New TTabela()
row.Nome = "MinhaTabela"
row.Titulo = "Minha tabela"
row.Insert()    ' AutoCode fills CodTabela when it is 0
row.Free()
```

Regenerate with `TTableGenerator.Save(path, tableName, schema)` from `mod_table` (see commented `BuildTablesTemplates` in `Principal.bas`). Schema `"Dicionario"` for the four dicionario tables; `""` / `"dbo"` for the rest.

---

## Internal flows

### Table hydration vs catalog fetch

| Call | Children | Navigation pointers | Access rows |
|---|---|---|---|
| `New Tabela(code\|name)` / `Configurador.CarregarTabela` | Yes | `LigarNavegacao` | Dummy `Acesso`; call `CarregarAcessos` |
| `Tabela.Fetch` / `Catalogo.FindTabela` | Empty `[]` | No | Dummy `Acesso` with `CodTabela` only |
| `New Relatorio(code)` / `Motor.CarregarRelatorio` | Yes (`CarregarRelacionados`) | n/a | n/a |
| `Relatorio.Carregar` / `Catalogo.FindRelatorio` | Yes | n/a | Null if missing |
| `Relatorio.Fetch` / `Catalogo.Relatorios` | Header only | n/a | n/a |

### `LigarNavegacao`

1. Index pastas by `CodPasta`, pesquisas by `CodPesquisaPadrao`, campos by `CodCampo`.
2. Each `Campo` with `CodPasta <> 0`: set `Campo.Pasta`, `Pasta.Campos.Push` (alias).
3. Each `Campo` with `CodPesquisaPadrao <> 0`: set `Campo.Pesquisa` if the search exists.
4. Each `Pesquisa`: set `CampoChave` / `CampoDescricao`; each `CampoBusca.Campo`.
5. Each `FiltroCampo.Campo`.
6. Missing codes stay Null (no throw). Processes, legends, helps, and `RelatorioInclusao` are not linked here.

### JSON bag attach

Unmatched `CampoFiltro` / `CampoBusca` rows (unknown `CodFiltro` / `CodPesquisaPadrao`) are `Free`'d. They never appear on the graph.

### `CODPERIODOCAIXA`

Module-level String cache in `TCfgSql`. Recomputed while the cached string is `""`.

---

## Extending (Consumer Project)

This module has no UI and no type registry.

- **New dictionary entity:** `Inherits TCfgBase`, `MyBase.New("Name")`, implement both `Fill` overloads. JSON keys must match `GetString` exactly (lowercase unless you copy `codajudaPai`). Use `TCfgRow.AsString` / `AsInteger` for nullish JSON.
- **Override flag mapping:** `GetFlagAsBoolean` / `GetFlagAsString` (default true token `"S"`).
- **Override table load behavior:** subclass `Tabela` and replace constructors / `VerificarCamposFisicos` / `CarregarAcessos` in the consumer. Nothing is registered globally; the consumer instantiates the subclass.
- **Persist dictionary rows:** subclass or use the generated `TTableOf<T>` types; do not expect `Tabela.Fill` to write.
- **WHERE helpers:** `TCfgSql.Tabela`, `Usuario`, `NomeSchema`, `EqInt`, `EqStrCI` — pass the fragment into `Catalogo.*` / `Fetch`.

Overridable hooks on `TCfgBase`:

| Hook | Purpose |
|---|---|
| `GetFlagAsBoolean` | Map a stored token to Boolean (`"S"` by default). |
| `GetFlagAsString` | Map Boolean back to `"S"` / `"N"`. |
| `Fill(TJSONObject)` | Hydrate from a JSON object. |
| `Fill(SQL.Command)` | Hydrate from an open query row. |

---

## Module Notes

- `Tabela` owns every child list except `Pasta.Campos` (`OwnsObjects = False`). `CamposChave()` returns a non-owning list. `Campo.Pasta` / `Campo.Pesquisa` / `FiltroCampo.Campo` / `CampoBusca.Campo` / `Pesquisa.CampoChave` are aliases.
- `Tabela.Acesso` and `Processo.Acesso` are never Null after construction/`Fill`. Missing DB rows leave `Permitido*` at `False` with keys filled. `AcessoTabela.Find` / `AcessoProcesso.Find` still return Null.
- JSON empty / `"null"` (any case) become `Unassigned` via `TCfgRow`. Boolean dictionary flags on domain objects accept only `"S"` (`GetFlagAsBoolean`). `TCfgFlag.Sim` is wider (`"S"`, `"SIM"`, `"1"`, `"T"`, `"TRUE"`, `"NOT IS FALSE"`) and is used by `AvaliarCondicao`. `Campo.ManterConteudo` is `"SIM"` only.
- `PacoteTabela` JSON prefix is cached in module `String`s keyed by RDBMS; an empty prefix or a dialect change rebuilds it. `CODPERIODOCAIXA` uses the same empty-string cache rule.
- `New Tabela` / `New Relatorio(code)` throw. `Relatorio.Carregar`, `Catalogo.Find*`, and per-type `Find` return Null. `Tabela.RelatorioInclusao` uses `Carregar` (Null, no throw).
- `ListaOpcao`, filter `Condicao` / `Comando` / `SQLWhereCondition`, process `Acao` / `Validacao`, and layout `Selecionado` are stored strings. This module does not parse option lists, does not apply filters, and does not skip unselected layouts.
- Load does not write. `query.Close` + `Free` after every `TCfgDb.Abrir` / `TSql.OpenQuery`. Persistence is the `TTableOf<T>` classes in `src/Tables`.
- `src/Principal.bas` is a live smoke of `New Tabela("CaixaOperador")`, `VerificarCamposFisicos`, and `Campo.Valor`. There is no `TXxxxTests.RunAll` in this project.
