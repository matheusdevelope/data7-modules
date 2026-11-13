# mod_ambient

Loads the Data7 execution environment for a script: company, branch, user, session, cash period, workstation, system, database, current menu, table dictionary, and the selected process. After `Initialize`, it can load field values for the selected grid row using the SQL `Where` the ERP already injects.

This module does **not** run table processes, render UI, persist dictionary changes, or invent a record key. The consumer supplies `CodTabela` / `NomeTabela`, `CodigoProcessoTabela`, and `Where`. Menu discovery still reads recent `LogSistema` rows; process lookup does not.

Version `1.0.0.0`. Dependencies (`data7.json`): `mod_configurador` `1.0.0.0`, `mod_cache` `1.0.0.0`. `TProcessoTabela` comes from `mod_configurador` (`table_processotabela`). Table CRUD helpers live in this project; dictionary types (`configurador_tabela.Tabela`, `configurador_grupotabela.GrupoTabela`, `configurador_campo.Campo`) come from `mod_configurador`.

This file is the module contract. Consumers must be able to call the API from this README alone. Open `.bas` files only to confirm a detail that is not stated here.

## Quick Start (Minimal)

ERP script runners inject `CodTabela`, `NomeTabela`, `CodigoProcessoTabela`, `TituloProcessoTabela`, and `Where` before this snippet runs.

```bas
Imports Ambient
Imports ambient_campos
Imports ambient_campo

' Optional: reuse sistema/empresa/filial/usuario/sessao/periodo/estacao/database across Initialize calls.
Ambient.EnableCache()

' Loads ambient JSON, current menu, process by CodTabela+CodigoProcessoTabela, and table dictionary.
Ambient.Initialize(CodEmpresa, CodFilial, CodUsuario, CodTabela, EstacaoTrabalho, UsuarioWindows, SchemaTabela, NomeTabela, CodigoProcessoTabela, TituloProcessoTabela, Where)

' Include calculated dictionary fields (Contexto <> "R" and FormulaCalculoValor <> "") in the SELECT.
Ambient.Campos().Config.Calculated = True

' SELECT ... FROM schema.table WHERE <injected Where>; fills TCampoValue.Value. No-op if Where is empty.
Ambient.Campos().LoadValues()

Dim clause As String = Ambient.InternalWhere()   ' same SQL fragment stored on Campos.AppliedWhere
Dim nome As String = Ambient.Empresa().Nome
Dim procTitulo As String = Ambient.Processo().Titulo
If Ambient.Campos.Has("CodProduto") Then
   Dim campo As TCampoValue = Ambient.Campos.Take("CodProduto")  ' list id is TCampoValue.Nome
End If
```

`InternalWhere()` after `Initialize` is enough when the consumer only needs the clause for another query. `LoadValues` is optional.

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_ambient.bas` | `Ambient` | facade functions (no class) |
| `src/Ambient/ambient_context.bas` | `ambient_context` | `TPlace`, `TContext` |
| `src/Ambient/ambient_campos.bas` | `ambient_campos` | `TCamposConfig`, `TCampoList` |
| `src/Ambient/ambient_campo.bas` | `ambient_campo` | `TCampoValue` |
| `src/Ambient/ambient_database.bas` | `ambient_database` | `TDatabase` |
| `src/Ambient/ambient_query.bas` | `ambient_query` | `TAmbientQuery` |
| `src/Ambient/ambient_json.bas` | `ambient_json` | `TAmbientJson` |
| `src/Tables/table_sistema.bas` | `table_sistema` | `TSistema` |
| `src/Tables/table_empresa.bas` | `table_empresa` | `TEmpresa` |
| `src/Tables/table_filial.bas` | `table_filial` | `TFilial` |
| `src/Tables/table_usuario.bas` | `table_usuario` | `TUsuario` |
| `src/Tables/table_sessaoconexao.bas` | `table_sessaoconexao` | `TSessaoConexao` |
| `src/Tables/table_periodocaixa.bas` | `table_periodocaixa` | `TPeriodoCaixa` |
| `src/Tables/table_estacao.bas` | `table_estacao` | `TEstacao` |
| `src/Tables/table_menu.bas` | `table_menu` | `TMenu` |

`src/Principal.bas` has no namespace. It is the demo script for this project, not a test runner. There is no `TXxxTests.RunAll`.

---

## Facade (`Ambient`)

Singleton orchestrator. First `Initialize` loads ambient entities; later calls reuse cache when `EnableCache` was used. Table dictionary reloads when `CodTabela` / schema / name change. `Menu`, `MenuPai`, and `Processo` are queried on every `Initialize`.

### Lifecycle

```bas
Sub EnableCache()
   ' Sets _useCache = True. Call before Initialize. No-op if already true.

Sub ClearCache()
   ' Frees the singleton TContext and Cache.ClearPool for all Ambient.* pools.

Sub Initialize(pCodEmpresa As Integer, pCodFilial As Integer, pCodUsuario As Integer, pCodTabela As Integer, pStationName As String, pStationUser As String, pSchemaTabela As String = "", pNomeTabela As String = "", pCodProcessoTabela As Integer = 0, pTituloProcessoTabela As String = "", pWhere As String = "")
   ' 1. Default Ambient.LogSeconds to 3 if <= 0
   ' 2. Prepare context (stores process codes + Trim(pWhere) as RecordWhere)
   ' 3. Detect DevMode / ExecutorMode from Data7.NomeArquivoExecutavel
   ' 4. OpenCaches: restore ambient pools or mark LoadAmbient
   ' 5. TAmbientQuery.Load
   ' 6. LoadDefinition (dictionary + TCampoList)
   ' 7. Finish: decrypt user if loaded, bind Campos.AppliedWhere = RecordWhere, store caches
```

| Parameter | Role |
|---|---|
| `pCodEmpresa`, `pCodFilial`, `pCodUsuario` | Session identity. Ignored for those fields when ambient cache already exists. |
| `pCodTabela` | Dictionary table code. `0` + empty `pNomeTabela` tries `Processo.CodTabela` after query. |
| `pStationName`, `pStationUser` | Workstation / Windows user for menu-log matching. |
| `pSchemaTabela` | Optional. Empty + `pCodTabela = 0` + named table → dialect default schema. |
| `pNomeTabela` | Optional. Used when `pCodTabela = 0` to construct `configurador_tabela.Tabela`. |
| `pCodProcessoTabela` | `ProcessoTabela` key with `CodTabela`. `0` falls back to title match. |
| `pTituloProcessoTabela` | Used only if `pCodProcessoTabela = 0` and `pCodTabela > 0`. |
| `pWhere` | Raw SQL fragment, e.g. `"CodProduto = 10406"` or `"CodEmpresa = 1 AND CodOrcamento = 1236"`. |

Any getter below (`Empresa`, `Campos`, …) calls `_EnsureReady`: if the singleton is missing or `IsReady = False`, it auto-`Initialize`s with `Data7.CodEmpresa/CodFilial/CodUsuario`, `pCodTabela = 0`, `Environment.MachineName/UserName`, and empty schema/name/process/where.

### Accessors

```bas
Function Current() As TContext          ' Creates empty TContext if missing; does not Initialize.
Function Instance() As TContext         ' Alias of Current.

Function Data7Mode() As Boolean         ' True when executable name contains neither DEVSTUDIO nor EXECUTOR.
Function DevMode() As Boolean           ' UCase(Data7.NomeArquivoExecutavel) contains "DEVSTUDIO".
Function ExecutorMode() As Boolean      ' Contains "EXECUTOR".

Function CodEmpresa() As Integer
Function CodFilial() As Integer
Function CodUsuario() As Integer
Function CodProcessoTabela() As Integer
Function TituloProcessoTabela() As String
Function InternalWhere(pWhere As String = "") As String
   ' Non-empty pWhere → Campos.ApplyWhere(pWhere) and return it.
   ' Empty → Campos.AppliedWhere (set from Initialize pWhere).

Function Sistema() As TSistema
Function Estacao() As TEstacao
Function Empresa() As TEmpresa
Function Filial() As TFilial
Function Usuario() As TUsuario
Function Sessao() As TSessaoConexao
Function Periodo() As TPeriodoCaixa
Function Menu() As TMenu
Function MenuPai() As TMenu
Function Processo() As TProcessoTabela   ' From mod_configurador; never Null after Initialize (may be empty row).
Function Tabela() As configurador_tabela.Tabela
Function Definicao() As configurador_tabela.Tabela  ' Same as Tabela.
Function GrupoTabela() As configurador_grupotabela.GrupoTabela  ' Null if Definicao is Null.
Function CampoChave() As TCampoValue     ' Null if no autoincrement/PK field bound.
Function Campos() As TCampoList
Function Database() As TDatabase

Function IsCached() As Boolean           ' True after Initialize if EnableCache was used (UseCache).
Function IsFromCache() As Boolean        ' UseCache And Not LoadAmbient And Not LoadDefinicao.
Function ToString() As String            ' TContext dump: ids, InternalWhere, entities, field counts.
```

Public variable: `Ambient.LogSeconds As Integer` (default applied as `3` when `<= 0`). Stored on context; menu-log query does not use it.

### Throws / NULL / no-op

| Situation | Behavior |
|---|---|
| Ambient SQL fails | `Exception` `"Erro ao obter dados do ambiente:"` + message + SQL. |
| Ambient query EOF, or `Empresa.CodEmpresa <= 0` on load | `"Nenhum registro de ambiente encontrado para empresa/filial/usuario informados."` |
| `GrupoTabela()` with no dictionary | `Null` |
| `CampoChave()` with no matching field | `Null` |
| `InternalWhere("")` before any where stored | `""` |
| Auto-`Initialize` from a getter | Runs with `CodTabela = 0` and empty `Where` (no selected row). |

---

## Context (`TContext`, `TPlace`)

`TContext` is the singleton payload. Prefer `Ambient.*` accessors. Direct use is valid after `Current()` / `Initialize`.

### `TPlace`

Module slot filled in `Finish` from `Sessao.CodModulo` / `Sessao.NomeModulo`. `UF` is unused by this module.

| Field | Meaning |
|---|---|
| `Codigo` | `Sessao.CodModulo` |
| `Nome` | `Sessao.NomeModulo` |
| `UF` | Not assigned by `Finish` |

### `TContext` fields

| Field | Default / sentinel | Notes |
|---|---|---|
| `CodEmpresa`, `CodFilial`, `CodUsuario` | From `Prepare` unless ambient cache hit | Cache hit keeps previous identity |
| `CodTabela` | `0` | Filled from dictionary after load |
| `CodProcessoTabela` | `0` | |
| `TituloProcessoTabela` | `""` | |
| `SchemaTabela`, `NomeTabela` | `""` | Overwritten from dictionary when present |
| `RecordWhere` | `Trim(pWhere)` | Copied to `Campos.AppliedWhere` in `Finish` |
| `StationName`, `StationUser` | From `Prepare` unless ambient cache | If `Estacao.Nome = ""` after load, set to `StationName` |
| `LogSeconds` | `3` if `<= 0` | |
| `IsReady` | `False` until `Finish` | |
| `Cached` | `UseCache` after `Finish` | |
| `FromCache` | See facade | |
| `UseCache` | Copied from `EnableCache` | |
| `LoadAmbient` | `True` when ambient pools miss | |
| `LoadDefinicao` | `True` when table/field cache miss | |
| `TabelaCacheKey` | `CodTabela;SCHEMA;NOME` (schema/name uppercased) | |
| `ModeData7`, `ModeDev`, `ModeExecutor` | From `SetMode` | |
| `UsuarioExpiresOn` | `0` = no expiry | `StrToDate(DataValidade)` unless `""` or `"00/00/0000"` |
| Entity refs | Always allocated | `Definicao` / `CampoChave` may be `Null` |

### Public methods (beyond fields)

```bas
Sub Prepare(...)   ' See Initialize parameter list + pLogSeconds. Sets IsReady = False.
Sub SetMode(pData7 As Boolean, pDev As Boolean, pExecutor As Boolean)
Sub OpenCaches()   ' Resolves ambient cache; always new empty Menu/MenuPai/Processo.
Sub LoadDefinition()
Sub Finish()
Sub BindCampoChave()
   ' 1. Definicao.CampoAutoIncremento().Nome if present in Campos
   ' 2. Else first IsPrimaryKey field, skipping CodEmpresa unless table is Empresa, skipping CodFilial unless table is Filial
   ' 3. Else Null

Function FullTableName() As String     ' "schema.name" or name
Function FullVersion() As String       ' Sistema.Version
Function IsPeriodoOpen() As Boolean    ' Periodo.DataAbertura <> 0
Function IsPeriodoClosed() As Boolean  ' Periodo.DataFechamento <> 0
Function IsUsuarioGroup() As Boolean   ' TCfgFlag.Sim(Usuario.Grupo)
Function IsUsuarioBlocked() As Boolean ' TCfgFlag.Sim(Usuario.Bloqueado)
Function IsUsuarioExpired() As Boolean ' UsuarioExpiresOn <> 0 And UsuarioExpiresOn < DateTime()

Shared Sub ClearPools()                ' Cache.ClearPool for Ambient.Sistema/Empresa/Filial/Usuario/Sessao/Periodo/Estacao/Database/Tabela/Campos
```

Dictionary load:

1. `CodTabela > 0` → `New configurador_tabela.Tabela(CodTabela)`.
2. Else named table → `New Tabela(NomeTabela, SchemaTabela)`; constructor failure is swallowed (`Definicao = Null`).
3. If `Definicao` assigned: copy code/name/schema, `CarregarAcessos(CodUsuario)` when `CodUsuario > 0`, `VerificarCamposFisicos(True)`, `Campos.Build`.
4. Else `Campos.BuildPhysical(SchemaTabela, NomeTabela)` (physical catalog only).

`IsPrimaryKey` on `TCampoValue` is **not** `Campo.Chave` from the dictionary. After `Build`, keys are overlaid from `TSql.DescribeColumns` (`col.PrimaryKey`). `TipoDB` is updated from `NativeType` when present.

Cache pools (string names): `Ambient.Sistema`, `Ambient.Empresa`, `Ambient.Filial`, `Ambient.Usuario`, `Ambient.Sessao`, `Ambient.Periodo`, `Ambient.Estacao`, `Ambient.Database`, `Ambient.Tabela`, `Ambient.Campos`. Ambient objects share key `"Ambient"`. Table/fields use `TabelaCacheKey`.

On first ambient load, `Usuario.NomeCompleto`, `Senha`, `Bloqueado`, and `DataValidade` are passed through `Data7.Descriptografar`; decrypt failure keeps the raw string.

---

## Fields (`TCampoList`, `TCamposConfig`, `TCampoValue`)

### `TCamposConfig`

| Field | Default | Used by |
|---|---|---|
| `Calculated` | `False` | `LoadValues` SELECT: include formula fields |
| `IncludeHidden` | `False` | SELECT/fill when `CondicaoVisivelGrade = "N"` |
| `FilterEmpresa` | `True` | Stored only; **not** applied to `LoadValues` / `ApplyWhere` |
| `FilterFilial` | `False` | Stored only; **not** applied to `LoadValues` / `ApplyWhere` |
| `ThrowExceptionInvalidTable` | `False` | `LoadValues` calls `Check` instead of silent exit |

### `TCampoList`

Owns `TCampoValue` instances (`OwnsObjects = True`). `Count()` is `Length`. List id for `Take("Nome")` is `TCampoValue.Nome`.

```bas
Function Count() As Integer
Function CountKeys() As Integer                 ' Count of IsPrimaryKey
Function Has(pName As String) As Boolean        ' Case-insensitive Trim match on Nome
Function FindByNameCI(pName As String) As TCampoValue  ' Null if pName is "" or not found

Sub Build(pTabela As configurador_tabela.Tabela)
   ' Includes source.Exists Or source.Extra Or calculated (Contexto <> "R" And formula <> "").
   ' Skips empty Nome. Then overlays physical PKs via DescribeColumns.

Sub BuildPhysical(pSchema As String, pName As String)
   ' No-op if Trim(pName) = "". DescribeColumns; empty Name skipped.

Function ApplyWhere(pWhere As String) As String
   ' Trim empty → return AppliedWhere unchanged.
   ' Else store and return the fragment (not parsed, not rewritten).

Sub LoadValues(pWhere As String = "")
   ' Clause = Trim(pWhere) or AppliedWhere.
   ' Empty clause → no-op.
   ' ThrowExceptionInvalidTable → Check (not ready / empty NomeTabela).
   ' Else empty NomeTabela → no-op.
   ' SELECT physical columns; calculated only if Config.Calculated.
   ' Hidden skipped unless IncludeHidden.
   ' LIMIT 1. Missing row leaves Values Unassigned (not an exception).
```

| Field | Meaning |
|---|---|
| `Config` | See above |
| `CodEmpresa`, `CodFilial`, `CodTabela` | Copied from context in `PublishCampos` |
| `SchemaTabela`, `NomeTabela` | Target of `LoadValues` |
| `AppliedWhere` | SQL fragment used in `WHERE` |
| `Ready` | `True` after `Finish` |

`LoadValues` throws `"Erro ao obter valores dos campos de ambiente no banco de dados:"` + message + SQL on open failure.

`Check` throws `"Ambiente não inicializado, execute Ambient.Initialize primeiro!"` or `"Tabela não informada para carregar os valores."`

`BuildPhysical` / physical overlay throw if `TSql.DescribeColumns` cannot find the table (`"Tabela não encontrada: ..."` from `mod_table`).

### `TCampoValue`

Runtime field snapshot. `GetID` returns `Nome` (special: name lookup on the list).

| Field | Default | Notes |
|---|---|---|
| `CodTabela`, `CodCampo` | `0` | From dictionary |
| `Nome`, `Titulo` | | |
| `Tipo` | Uppercased dictionary tipo | `"I"` → initial `TipoDB = "INT4"` else `"VARCHAR"` |
| `TipoDB` | `""` then overlay | Physical native type when described |
| `Contexto` | `""` | `"R"` = record/physical for `IsCalculated` |
| `FormulaCalculoValor` | `""` | Wrapped as `(formula) AS "Nome"` when calculated |
| `OrdemGrade` | `0` | |
| `CondicaoVisivelGrade` | `"O"` | `"N"` (any case after Trim) → not visible |
| `IsPhysical` | `False` | `Exists Or Extra`, or always true in `BuildPhysical` |
| `IsPrimaryKey` | `False` | Physical PK only after overlay |
| `Value` | `Unassigned` | Set by `LoadValues` |

```bas
Function IsVisible() As Boolean      ' CondicaoVisivelGrade <> "N"
Function IsCalculated() As Boolean   ' Contexto <> "R" And FormulaCalculoValor <> ""
```

Literal contracts:

- Visible grade flag: `"O"` (shown), `"N"` (hidden).
- Calculated vs record: `Contexto = "R"` is never calculated even if a formula exists.
- Where examples: `"CodProduto = 10406"`, `"CodEmpresa = 1 AND CodOrcamento = 1236"`.

---

## Database (`TDatabase`)

Connection snapshot filled from the ambient query (not a live connector).

| Field | Source |
|---|---|
| `Description`, `Name` | Current database name |
| `Host`, `Port` | Server / port (dialect-specific SQL) |
| `User` | Current DB user |
| `Pass` | Parametro `Backup_SenhaBancoDados` (ValorParametro or ValorPadrao) |
| `RDBMS` | `SQL.Connection.RDBMS` (`dbMSSQL` / `dbASA` / `dbPostgreSQL`) |
| `Schema` | Dialect default schema |

```bas
Function RDBMSAsString() As String
   ' dbMSSQL → "Sql Server"; dbASA → "Sybase"; dbPostgreSQL → "PostgreSql"; else empty.
```

---

## Query helpers (used by `Initialize`)

Consumers normally do not call these. Signatures exist and are public.

### `TAmbientQuery`

```bas
Shared Sub Load(pCtx As TContext)
   ' Builds one SQL batch. Fills ambient JSON columns when LoadAmbient.
   ' Always fills Menu, MenuPai, Processo from JSON columns.
```

Process `WHERE`:

1. `CodProcessoTabela > 0` and `CodTabela > 0` → `CodTabela = n AND CodProcessoTabela = n`.
2. `CodProcessoTabela > 0` only → `CodProcessoTabela = n`.
3. Else title + table → `CodTabela = n AND Titulo = 'Editar'` (dialect string compare).
4. Else `1 = 0` (empty process row).

Menu: last 10 `LogSistema` rows, tipo `"AMENU"`, matching Windows user, machine, empresa, filial, `CodUsuario`, detalhe nome `'CÓDIGO'`. Parent menu uses `Menu.CodMenuPai`.

### `TAmbientJson`

Shared SQL/JSON helpers: `CastC`, `Cmp`, `CmpCI`, `SqlNow`, `SqlSecondsAgo`, `KeySeparator`, `LimitOne`, `SqlJson`, `SelectColumns`, `SelectFromTable`, `Fill`.

`KeySeparator`: SQL Server ` + '-' + `; otherwise ` || '-' || `.

`SqlNow`: PostgreSQL `CURRENT_TIMESTAMP`; otherwise `GETDATE()`.

`Fill` no-op if JSON array missing or empty. Field names matched lowercased then as-is; `"null"` / empty skipped.

---

## Entity tables (this module)

Generated `TTableOf<T>` wrappers. `Initialize` fills them from JSON; consumers read properties. They are not the dictionary of the **selected** business table (`Ambient.Tabela` is).

| Class | DB table | Identity | Properties (all public Get/Set) |
|---|---|---|---|
| `TSistema` | `Sistema` | `GetID = ""`; `Version` is `Versao.MenorVersao.ReleaseDaVersao.BuilderDaVersao` | `Version`, `Versao`, `ReleaseDaVersao`, `BuilderDaVersao`, `NomeComercialPAF`, `VersaoPAF`, `RazaoSocial`, `CNPJ`, `Endereco`, `Telefone`, `Contato`, `NumeroLaudo`, `DataVersao`, `HoraVersao`, `MenorVersao`, `MD5`, `MD5Sistema`, `HashAtualizaVersao` |
| `TEmpresa` | `Empresa` | PK `CodEmpresa` | `CodigoRemoto`, `CodTabelaPreco`, `CodLocalArmazenagem`, `CodMunicipio`, `CodEmpresa`, `PercentualCustoFixo`, `AliquotaSimples`, `Validador`, `Contato`, `Old_SenhaCertificadoDigital`, `Old_CertificadoDigital`, `CNAE`, `RegimeTributario`, `UF`, `FTP`, `HomePage`, `EMail`, `FAX`, `Telefone`, `DDD`, `InscricaoMunicipal`, `RG`, `InscricaoEstadual`, `CNPJ_CPF`, `TipoPessoa`, `CaixaPostal`, `Bairro`, `Complemento`, `Numero`, `Endereco`, `CEP`, `NomeFantasia`, `Nome`, `NFEmsgContribuinte`, `ResponsavelLegal` |
| `TFilial` | `Filial` | PK `CodEmpresa`; `CodFilial` AutoCode | `Contato`, `CodContador`, `CodEmpresa`, `CodFilial`, `Identificacao`, `Nome`, `NomeFantasia`, `CNPJ`, `InscricaoEstadual`, `CodMunicipio`, `Logradouro`, `NumeroLogradouro`, `Complemento`, `PontoReferencia`, `Bairro`, `CEP`, `InscricaoMunicipal`, `InscricaoSuframa`, `PerfilEFD`, `IndicadorAtividadeEFD`, `Telefone`, `Fax`, `EMail`, `Liberacao`, `CertificadoDigital`, `SenhaCertificadoDigital`, `Licenca`, `RegimeTributario`, `CST_Pis`, `CST_Cofins`, `CodSerieNFe`, `CNAE`, `PercentualCustoFixo`, `AliquotaIcmsOperacoesInternas`, `CodigoAutorizacaoCODIF`, `CodTabelaPreco`, `AliquotaSimplesNacional`, `NaturezaPessoaJuridica`, `AtividadePreponderante`, `RegimeApuracao`, `Enquadramento`, `CodColigadas`, `TokenID`, `Token`, `AliquotaIRRF`, `AliquotaCSLL`, `LicencaForcaVenda`, `MensagemNotaFiscal`, `AliquotaISS`, `ChaveDigital`, `CodigoAtividadeEconomica`, `TokenDeOlhoNoImposto`, `ProvedorNfse`, `IssTributavelValorFixo`, `IncidenciaTributaria`, `ContribuicaoApurada`, `AliquotaEstimativaSimplificada`, `EstimativaSimplificada`, `UsuarioProvedorNFSe`, `SenhaProvedorNFSe`, `ClassificacaoContribuinteIPI`, `CodLocalArmazenagem`, `AliquotaInss`, `AliquotaFunRural`, `CadastroImovelRural`, `AtividadeEconomicaPessoaFisica`, `TipoExploracaoImovelRural`, `ParticipacaoImovelRural`, `Ativo`, `LiberacaoFrenteLoja`, `CodTipoNFSe`, `AliquotaCBS`, `FaixaEnquadramentoSimplesNacional`, `CNAESecundario` |
| `TUsuario` | `Usuario` | `CodUsuario` AutoCode | `CodUsuario`, `Nome`, `NomeLegivel`, `NomeCompleto` (decrypted on ambient load), `Senha` (decrypted), `Bloqueado` (decrypted; flag for `IsUsuarioBlocked`), `DataValidade` (decrypted string; `"00/00/0000"` = no date), `PodeAlterarSenha`, `AlterarSenhaProximoLogin`, `Departamento`, `Cargo`, `E_MAIL`, `NomeSuperior`, `Domingo_Inicio`, `Domingo_Fim`, `Segunda_Inicio`, `Segunda_Fim`, `Terca_Inicio`, `Terca_Fim`, `Quarta_Inicio`, `Quarta_Fim`, `Quinta_Inicio`, `Quinta_Fim`, `Sexta_Inicio`, `Sexta_Fim`, `Sabado_Inicio`, `Sabado_Fim`, `Grupo` (flag for `IsUsuarioGroup`), `Documento`, `CodCentroCusto`, `LogProcessosAtivo`, `LogInclusaoAtivo`, `LogAlteracaoAtivo`, `LogExclusaoAtivo`, `LogRelatorioAtivo`, `LogTransacaoAtivo`, `LogRespostaParametroAtivo`, `MenuUsuarioHabilitado`, `AcessoFrenteLoja`, `PercentualDescontoFrenteLoja`, `CodConfiguracaoEnvioEmail`, `PercentualDescontoContaReceberFrenteLoja`, `AcessoSupervisorFrenteLoja`, `AssinaturaMensagem` |
| `TSessaoConexao` | `SessaoConexao` | PK `CodSessaoConexao` (string) | `CodSessaoConexao`, `CodPeriodoCaixa`, `CodUsuario`, `NomeUsuario`, `EstacaoTrabalho`, `CodEstacaoTrabalho`, `CodEmpresa`, `CodFilial`, `CodModulo`, `NomeModulo`, `Data`, `Hora` |
| `TPeriodoCaixa` | `PeriodoCaixa` | PK `CodEmpresa`; `CodPeriodoCaixa` AutoCode | `CodEmpresa`, `CodPeriodoCaixa`, `CodContaFinanceira`, `CodUsuarioAbertura`, `NomeUsuarioAbertura`, `DataAbertura`, `HoraAbertura`, `DataFechamento`, `HoraFechamento`, `SaldoAbertura`, `TrocoAbertura`, `EstacaoTrabalhoAbertura`, `CodUsuarioFechamento`, `NomeUsuarioFechamento`, `SaldoAntesFechamento`, `EstacaoTrabalhoFechamento`, `QtdaMoeda01`, `QtdaMoeda05`, `QtdaMoeda10`, `QtdaMoeda25`, `QtdaMoeda50`, `QtdaMoeda1`, `QtdaTotalMoeda`, `ValorTotalMoeda`, `QtdaNota1`, `QtdaNota2`, `QtdaNota5`, `QtdaNota10`, `QtdaNota20`, `QtdaNota50`, `QtdaNota100`, `QtdaNota200`, `QtdaTotalNota`, `ValorTotalNota`, `QtdaCheque`, `ValorCheque`, `QtdaCartaoCredito`, `ValorCartaoCredito`, `QtdaCartaoDebito`, `ValorCartaoDebito`, `QtdaVale`, `ValorVale`, `QtdaTicket`, `ValorTicket`, `QtdaNotaCliente`, `ValorNotaCliente`, `QtdaOutros`, `ValorOutros`, `QtdaTotalOutros`, `ValorTotalOutros`, `SaldoContagem`, `DiferencaSaldo`, `SaldoAposFechamento`, `ValorSangria`, `CodContaFinanceiraTransferencia`, `TipoTransferencia`, `CodLocalArmazenagem` |
| `TEstacao` | `Estacao` | `CodEstacao` AutoCode | `CodImpressoraFiscal`, `LeitorCMC7_AtrasoLeitura`, `LeitorCMC7_BitsDados`, `LeitorCMC7_BitsSegundo`, `CodBalanca`, `TEF_Comprovante_Vias`, `ImpressoraCupom`, `ImpressoraCheque`, `CodEstacao`, `LeitorCMC7_BitsPorParada`, `TEF_Comprovante_Impressora`, `TEF_Tipo`, `ImpressoraCheque_Modelo`, `ImpressoraCheque_Marca`, `LeitorCMC7_ControleFluxo`, `LeitorCMC7_Paridade`, `LeitorCMC7_Modelo`, `LeitorCMC7_Marca`, `LeitorCMC7_Porta`, `MensagemCupomFiscal`, `ImpressoraCodigoBarra_Porta`, `ImpressoraCodigoBarra_Modelo`, `TEF_Pasta_Recepcao`, `TEF_Pasta_Transmissao`, `Gaveta_Porta`, `Gaveta_Modelo`, `CartaoMagnetico_Porta`, `CartaoMagnetico_Modelo`, `CodigoBarra_Porta`, `CodigoBarra_Modelo`, `PinPad_Mensagem`, `PinPad_Porta`, `PinPad_Modelo`, `ImpressoraCupom_Porta`, `ImpressoraCheque_Porta`, `ImpressoraFiscal_Serie`, `ImpressoraFiscal_Numero`, `ImpressoraFiscal_Porta`, `ImpressoraFiscal`, `Nome`, `PinPad_NumeroSerie` |
| `TMenu` | `Menu` | PK `CodModulo` + `CodMenu` | `CodModulo`, `CodMenu`, `Titulo`, `ValorAcao`, `CodMenuPai`, `Proprietario`, `Ordem`, `CodImagem`, `Acao`, `Estrutura`, `Validacao`, `VigenciaInicial`, `VigenciaFinal`, `ExclusivoAdministrador`, `Bloqueado`, `FuncaoID`, `CodWhatsAppConfiguracoesEnvio` |

`TProcessoTabela` (dependency): table `ProcessoTabela`, PK `CodTabela` + `CodProcessoTabela`. Consumer-facing: `Titulo`, `Acao`, `ValorAcao`, `Bloquear`, `VerificarBloqueio`, `Validacao`, `Status`, `LocalExibir`, `Ordem`, `Imagem`, `ShortCut`, `Proprietario`, `CodWhatsAppConfiguracoesEnvio`.

`Tabela()` / `Definicao()` is `configurador_tabela.Tabela` (dictionary of the **selected** table: `Nome`, `NomeSchema`, `CodTabela`, `Campos`, `Pastas`, `Grupo`, `CarregarAcessos`, `VerificarCamposFisicos`). See `mod_configurador` for that contract.

---

## Initialize flow (usage-relevant)

1. `EnableCache` (optional).
2. `Initialize(...)` stores `Where` as `RecordWhere`, loads ambient (or cache), always reloads menu/process.
3. Dictionary: by `CodTabela`, else by `NomeTabela`+schema, else physical columns if a name exists.
4. `Finish` sets `Campos.Ready = True` and `Campos.AppliedWhere = RecordWhere`.
5. Consumer may `Campos.Config.Calculated = True` then `LoadValues()` or only read `InternalWhere()`.

Ignored / filtered:

- Dictionary `Campo.Chave = S` does not mark `IsPrimaryKey`.
- Fields with empty `Nome` are skipped.
- Non-existent non-extra non-calculated dictionary fields are skipped (`Exists`/`Extra`/`calculated` gate).
- Grade `"N"` omitted from SELECT unless `IncludeHidden`.
- Process SQL becomes `1 = 0` when both process code and (title+table) are missing.
- `FilterEmpresa` / `FilterFilial` do not modify the injected `Where`.

---

## Extending (Consumer Project)

This core has no UI and no type catalog to register.

- Depend on `mod_ambient` and `Imports Ambient` (plus `ambient_campos` / entity namespaces as needed).
- Pass ERP-injected `CodTabela`, `NomeTabela`, `CodigoProcessoTabela`, `TituloProcessoTabela`, `Where` into `Initialize`. Do not rebuild keys from `ID_Developer`.
- Do not inherit `TContext` unless replacing the whole singleton; the facade owns one instance.
- `TCampoList` may be used after `Initialize`; `Build` / `BuildPhysical` are already invoked internally.
- Extra queries in the consumer should reuse `Ambient.InternalWhere()` as a SQL fragment, not parse it.

---

## Module Notes

- `TCampoList` owns its `TCampoValue` objects. Cached `Campos` / `Definicao` are the same instances until `ClearCache`.
- `EnableCache` must run **before** `Initialize`. Cache does not store `Menu`, `MenuPai`, or `Processo`.
- `AppliedWhere` is the ERP fragment as given; this module does not quote, AND `CodEmpresa`, or rewrite it.
- `Usuario` decrypt runs only when ambient is loaded from SQL (`LoadAmbient`), not when restored from cache (already decrypted).
- `CampoChave` prefers dictionary autoincrement, then physical PK (skipping `CodEmpresa`/`CodFilial` except on tables named `Empresa`/`Filial`).
- `LoadValues` without a clause and without a stored `Where` is a silent no-op; it does not throw.
- `Principal.bas` is a runnable sample: fills company/user from `Data7` / `Environment`, optionally overrides table/where in `DevMode`, then `EnableCache` + `Initialize` + `LoadValues`.
- There is no automated test entrypoint in this project.
