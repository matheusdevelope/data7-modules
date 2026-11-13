# mod_register

Dynamic record form for Data7: build a dialog from a `TRegisterFormConfig`, edit values, and persist through `Ambient` + `TTable`. Version **1.0.0.0**.

The module paints editors, applies Configurador defaults/readonly/required, validates, reserves sequence codes, inserts/updates/deletes, and writes `mod_log` entries. It does **not** load `Ambient`, choose `CodTabela`, or supply the grid `Where` — the host does that (`Principal.bas` / consumer).

Declared dependencies (`data7.json`): `mod_configurador` 1.0.0.0, `mod_forms` 1.0.0.0, `mod_editors` 1.0.0.1, `mod_ambient` 1.0.0.0, `mod_log` 1.0.0.0.

This file is the module contract. Consumers should call the API from here and open `.bas` files only to confirm a detail that is not stated.

---

## Quick Start (Minimal)

Host variables (`CodTabela`, `Where`, `TituloProcessoTabela`, …) are filled by the Data7 runner. `Ambient.Initialize` last argument is the selected-row `Where` (also `Ambient.InternalWhere()` after init).

```bas
Imports mod_register_config
Imports mod_register_session

Ambient.EnableCache()
Ambient.Initialize(CodEmpresa, CodFilial, CodUsuario, CodTabela, EstacaoTrabalho, UsuarioWindows, SchemaTabela, NomeTabela, CodigoProcessoTabela, TituloProcessoTabela, Where)

Dim mode As TRegisterMode = TRegisterMode.Load(TituloProcessoTabela)
Dim session As New TRegisterSession(mode)
session.Show()
session.Free()
```

- `TRegisterMode.Load` maps process title (`Incluir`, `Alterar`, `Excluir`, `Copiar`, `Visualizar`). Invalid title: `TRegisterMode.GetOptions()`.
- `TRegisterSession` reads identity from `Ambient.InternalWhere()`, builds the form from `Ambient.Tabela()`, loads/saves/deletes, then shows the dialog.

Hand-built form without session:

```bas
Imports mod_register_config
Imports mod_register_form

Dim cfg As New TRegisterFormConfig()
cfg.Title = "Cliente"
cfg.AddField("Ativo", "Ativo:").UseCombo("Sim=S;Não=N")
cfg.AddField("Codigo", "Código:").UseInteger().Lock()
cfg.AddField("NomeFantasia", "Nome Fantasia:").UseText().MaxLen(80)
cfg.AddFolder("01", "Endereço")
cfg.AddField("Endereco", "Endereço:").UseText().MaxLen(60).InFolder("01")

Dim form As New TRegisterForm(cfg, TRegisterMode.Incluir())
form.Show()
form.Free()
```

Without `OnCommit` + `AcceptCommit()`, OK validates but the dialog stays open (except `Visualizar`, which just closes).

---

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_register.bas` | `mod_register` | `TRegister` |
| `src/lib/mod_register_config.bas` | `mod_register_config` | `TRegisterEditorCreate`, `TRegisterMode`, `TRegisterFieldKind`, `TRegisterField`, `TRegisterFolder`, `TRegisterFormConfig` |
| `src/lib/mod_register_factory.bas` | `mod_register_factory` | `TRegisterKindBinder`, `TRegisterFactory` |
| `src/lib/mod_register_layout.bas` | `mod_register_layout` | `TRegisterFieldRow`, `TRegisterLayout` |
| `src/lib/mod_register_form.bas` | `mod_register_form` | `TRegisterKept`, `TRegisterForm` |
| `src/lib/mod_register_tabela.bas` | `mod_register_tabela` | `TRegisterTabela` |
| `src/lib/mod_register_record.bas` | `mod_register_record` | `TRegisterRecord` |
| `src/lib/mod_register_store.bas` | `mod_register_store` | `TRegisterStore` |
| `src/lib/mod_register_events.bas` | `mod_register_events` | `TRegisterContext`, `TRegisterGate`, `TRegisterHook`, `TRegisterEvents` |
| `src/lib/mod_register_session.bas` | `mod_register_session` | `TRegisterSession` |
| `src/lib/mod_register_log.bas` | `mod_register_log` | `TRegisterLog` |
| `src/lib/mod_register_eval.bas` | `mod_register_eval` | `TRegisterEval` |
| `src/lib/mod_register_validation.bas` | `mod_register_validation` | `TRegisterProcSpec`, `TRegisterProcResult`, `TRegisterValidation` |
| `src/tests/mod_register_eval_tests.bas` | `mod_register_eval_tests` | `TRegisterEvalTests` |

`src/Principal.bas` is the host entry (no namespace). Tests: `TRegisterEvalTests.Run()`.

---

## Configuration

### `TRegisterMode`

Process mode. String values: `"Incluir"`, `"Alterar"`, `"Excluir"`, `"Copiar"`, `"Visualizar"`.

```bas
Dim m As TRegisterMode = TRegisterMode.Incluir()
m = TRegisterMode.Load("Copiar")   ' throws if unknown
Dim opts As String = TRegisterMode.GetOptions()
```

### `TRegisterFieldKind`

Editor catalog. `KindKey()` prefers `EditorKind`, else `Kind.AsString`, else `"Text"`. `CreateDefault` also accepts aliases (`INT`, `DATA`, `LOOKUP`, …).

```bas
Enun TRegisterFieldKind
   fkText = "Text"
   fkInteger = "Integer"
   fkNumber = "Number"
   fkValue = "Value"
   fkDate = "Date"
   fkTime = "Time"
   fkDateTime = "DateTime"
   fkCombo = "Combo"
   fkSearch = "Search"
   fkMemo = "Memo"
   fkCheck = "Check"
   fkMask = "Mask"
   fkPassword = "Password"
   fkImage = "Image"
   fkButton = "Button"
   fkCEP = "CEP"
   fkCPF = "CPF"
   fkCNPJ = "CNPJ"
   fkCpfCnpj = "CpfCnpj"
   fkEmail = "Email"
   fkSite = "Site"
   fkIE = "IE"
   fkPlaca = "Placa"
   fkGtin = "Gtin"
   fkCnh = "Cnh"
   fkRenavam = "Renavam"
   fkSuframa = "Suframa"
   fkCustom = "Custom"
End Enun
```

### `TRegisterEditorCreate`

```bas
Delegate Function TRegisterEditorCreate(pParent As TWinControl, pField As TRegisterField) As TLabeledEditorBase
```

### `TRegisterField`

One editor definition. Fluent setters return `me`.

| Member | Default | Notes |
|---|---|---|
| `Name`, `Caption` | `""` | Field key / label |
| `EditorKind` | `"Text"` | Drives factory |
| `Kind` | `fkText()` | Set by `Use*` |
| `FolderId` | `""` | Empty = header (above tabs) |
| `Order` | index at `AddField` | Sort key |
| `MaxLength`, `Width`, `Height` | `0` | `0` = layout default |
| `LabelWidth` | copied from config if `<= 0` | |
| `LabelSpacing` | `5` | |
| `SpanRow` | `False` | Forced `True` by `UseMemo` / `UseImage` |
| `Column` | `0` | From Configurador |
| `Required` | `False` | Overridden by `CondicaoObrigatorio` if set |
| `Locked` | `False` | Always read-only |
| `Visible` / `Enabled` | `True` | `Hide()` sets `Visible = False` |
| `CanEditInsert` / `CanEditUpdate` | `True` | |
| `IsKey` / `AutoIncrement` / `KeepContent` | `False` | |
| `DefaultValue`, `TipoValorPadrao`, `FormulaValorPadrao` | `""` | See `TRegisterEval` |
| `CondicaoEditarInclusao` / `CondicaoEditarAlteracao` / `CondicaoObrigatorio` | `""` | Evaluated by `TCfgSql.AvaliarCondicao` |
| `ListaOpcoes` | `""` | e.g. `"Sim=S;Não=N"` |
| `CodPesquisa` | `0` | `UseSearch(12)` |
| `Mask` | `""` | `UseMask("999.999")` |
| `DecimalPlaces` | `-1` | `UseInteger` sets `0`; `UseValue` default `2` |
| `FontColor` / `TabOrder` | `-1` | |
| `Tipo` | `""` | Configurador type: `V`,`I`,`N`,`D`,`T`,`DT`,`IM`,`M`,`L` |
| `ValidacaoSistema` / `ValidacaoUsuario` | `""` | Procedure spec, see Validation |
| `Factory` | `Null` | Per-field factory |
| `Placement` | `TLabelPlacement.Load("Left")` | |

```bas
Function KindKey() As String
Function SetKind(pKind As TRegisterFieldKind) As TRegisterField
Function SetKind(pKey As String) As TRegisterField   ' EditorKind = pKey, Kind = fkCustom()
Function UseText() As TRegisterField
Function UseMemo() As TRegisterField                 ' SpanRow = True
Function UseCombo(pLista As String) As TRegisterField
Function UseSearch(pCodPesquisa As Integer) As TRegisterField
Function UseInteger() As TRegisterField
Function UseNumber() As TRegisterField
Function UseValue(pDecimals As Integer = 2) As TRegisterField
Function UseDate() As TRegisterField
Function UseTime() As TRegisterField
Function UseDateTime() As TRegisterField
Function UseCheck() As TRegisterField
Function UseMask(pMask As String) As TRegisterField
Function UsePassword() As TRegisterField
Function UseImage() As TRegisterField                ' SpanRow = True
Function UseButton() As TRegisterField
Function UseCEP() / UseCPF() / UseCNPJ() / UseCpfCnpj() As TRegisterField
Function UseEmail() / UseSite() / UseIE() / UsePlaca() As TRegisterField
Function UseGtin() / UseCnh() / UseRenavam() / UseSuframa() As TRegisterField
Function Require(pValue As Boolean = True) As TRegisterField
Function MaxLen(pValue As Integer) As TRegisterField
Function WithWidth / WithHeight / WithLabelWidth(pValue As Integer) As TRegisterField
Function FullRow(pValue As Boolean = True) As TRegisterField
Function Lock(pValue As Boolean = True) As TRegisterField
Function Hide() As TRegisterField
Function WithHint / WithMask / WithOptions / DefaultTo(pValue As String) As TRegisterField
Function WithOrder(pValue As Integer) As TRegisterField
Function KeyField(pValue As Boolean = True) As TRegisterField
Function WithFactory(pFactory As TRegisterEditorCreate) As TRegisterField  ' Kind = fkCustom()
Function InFolder(pId As String, pTitle As String = "") As TRegisterField
Function ToProps() As TEditorProps
```

- `InFolder("")` moves the field back to the header.
- `InFolder` with `Owner` set calls `MoveToFolder`; without owner only stores `FolderId`.
- `FieldByName` miss → `Null`.

### `TRegisterFolder`

Tab (or nested tab). `Fields.OwnsObjects = False` (fields live on the config). `Folders.OwnsObjects = True`.

| Member | Default |
|---|---|
| `Id`, `Title`, `ParentId`, `Estrutura` | `""` |
| `Visible` | `True` |
| `SubCadastro` | `False` |
| `Margin`, `Order`, `ContentHeight` | `0` |

```bas
Function AddField(pName As String, pCaption As String) As TRegisterField
Function AddFolder(pId As String, pTitle As String) As TRegisterFolder
Function HasChildren() As Boolean
Function HasFields() As Boolean
Function FieldByName(pName As String) As TRegisterField   ' Null if missing
```

### `TRegisterFormConfig`

Owns `Fields` and `Folders`. `HeaderFields` does not own objects.

| Member | Default |
|---|---|
| `Title` | `""` |
| `LabelWidth` | `110` |
| `LabelSpacing` | `5` |
| `FullRowChars` | `40` |
| `CharWidth` | `8` |
| `RowHeight` | `27` |
| `Gutter` | `8` |
| `ContentMargin` | `6` |
| `LayoutWidth` | `808` |
| `ConfirmDeleteMessage` | `"Confirma a exclusão do registro?"` |

```bas
Function AddField(pName As String, pCaption As String) As TRegisterField
Function AddFolder(pId As String, pTitle As String) As TRegisterFolder
Function AddFolder(pId As String, pTitle As String, pParentId As String) As TRegisterFolder
Function EnsureFolder(pId As String) As TRegisterFolder
Function EnsureFolder(pId As String, pParentId As String) As TRegisterFolder
Sub MoveToFolder(pField As TRegisterField, pId As String, pTitle As String = "")
Function FieldByName(pName As String) As TRegisterField   ' Null if missing
Function FolderById(pId As String) As TRegisterFolder      ' Null if missing
Function SortedHeaderFields() As TTList<TRegisterField>    ' OwnsObjects = False
Function FocusFields() As TTList<TRegisterField>           ' header then visible folders, OwnsObjects = False
Shared Function ParentFolderId(pId As String) As String
Shared Function IsEstruturaPrefix(pParent As String, pChild As String) As Boolean
Shared Function SortFields(pFields As TTList<TRegisterField>) As TTList<TRegisterField>
Shared Function FolderSortKey(pFolder As TRegisterFolder) As String
Shared Function SortFolders(pFolders As TTList<TRegisterFolder>) As TTList<TRegisterFolder>
```

- `AddFolder(id, title)` with empty `id` → `Null`.
- Duplicate `id` returns the existing folder and updates `Title` if non-empty.
- Two-arg `AddFolder` / `EnsureFolder` resolve parent: longest existing prefix via `IsEstruturaPrefix`, else dotted `ParentFolderId` (`"02.01"` → `"02"`; no dot → `""`).
- `IsEstruturaPrefix`: child starts with parent and either the next char is `"."` or neither string contains `"."`. Examples: `"02"` prefixes `"02.01"`; `"0106"` prefixes `"010601"`; `"02"` does not prefix `"0201"` if a dot is present in one of them.
- `FolderSortKey` = `Estrutura` or, if empty, `Id`.
- `FocusFields` skips folders with `Visible = False`.

### `TRegisterTabela`

Maps Configurador `Tabela` → `TRegisterFormConfig`.

```bas
Shared Function FromTabela(pTabela As Tabela) As TRegisterFormConfig
```

- `pTabela` `Null` → empty config (not `Null`).
- Title = `Tabela.Titulo`, else `Tabela.Nome`. `MargemEditor > 0` → `ContentMargin`.
- Folder id = `CStr(CodPasta)`. Parent = longest visible `Estrutura` prefix (`IsEstruturaPrefix`). Inactive folders (`Status` `N`/`I`/`0`/`INATIVO`) are omitted.
- Fields: `Extra = False`, `Tipo` in `V,I,N,D,T,DT,IM,M,L`, `Contexto` not `C`, `CondicaoVisivelEdicao` not hide (`N`). `"O"`/`"OCULTO"` → field added then `Hide()`. `"S"`/`"SIM"` visible. Caption = `TituloEdicao` else `Titulo` else `Nome`, with trailing `:`.
- Kind: `Especifico` (`CEP`, `CPF`, `CNPJ`, `CPFCNPJ`/`CPF_CNPJ`/`CPF/CNPJ`/`CPF-CNPJ`, `EMAIL`/`E-MAIL`, `SITE`/`URL`, `IE`/`INSCRICAO`, `PLACA`, `GTIN`/`EAN`, `CNH`, `RENAVAM`, `SUFRAMA`); else `CodPesquisaPadrao > 0` → search; else non-empty `ListaOpcao` → combo; else `Tipo`.
- `Required` is always `False` here; required comes from `CondicaoObrigatorio` at runtime.

---

## Form and layout

### `TRegisterLayout`

Row packer. Constructed by the form from config. `TRegisterFieldRow` holds `Items[]` (`OwnsObjects = False`) for one packed row. Constructor defaults: `LabelWidth=110`, `LabelSpacing=5`, `FullRowChars=40`, `CharWidth=6`, `RowHeight=27`, `Gutter=8`, `MinFieldWidth=48`, `LayoutWidth=808`, `SearchWidth=366`, `TabHeaderHeight=26`, `ContentMargin=6`. Values `> 0` on the config overwrite the matching fields (`SearchWidth` / `TabHeaderHeight` / `MinFieldWidth` are layout-only).

```bas
Function AvailableWidth(pParent As TWinControl) As Integer
Function OccupiesFullRow(pField As TRegisterField, pAvailable As Integer) As Boolean
Function EditorWidth(pField As TRegisterField, pMax As Integer) As Integer
Function Place(pParent As TWinControl, pFields As TTList<TRegisterField>, pCreate As TRegisterEditorCreate) As Integer
```

Full row when `SpanRow`, kind `MEMO`/`TEXTO`/`IMAGE`/`IMAGEM`/`FOTO`, `MaxLength >= 200`, or `Width` greater than half the available width. Search editors use width `366`. At most two non-full fields per row; `Place` returns total content height. `pCreate = Null` → `0`.

### `TRegisterKept`

`KeepContent` snapshot: `FieldName`, `FieldText`. Packed as `name & Chr(1) & text`.

### `TRegisterForm`

Inherits `TFormsWorkspace` as a dialog. `CloseOnOk = False`. Caption = `Title & " - " & Mode` (or Mode alone).

```bas
Sub New(pConfig As TRegisterFormConfig)                          ' mode Incluir
Sub New(pConfig As TRegisterFormConfig, pMode As TRegisterMode)
Property Config As TRegisterFormConfig                           ' get
Property Mode As TRegisterMode                                   ' get/set → ApplyMode
Property OwnsConfig As Boolean                                   ' default True; form Frees config
Property Confirmed As Boolean                                    ' True after successful OK
Property Layout As TRegisterLayout
Sub AcceptCommit()                                               ' required from OnCommit
Function Editor(pName As String) As TLabeledEditorBase           ' Null if missing
Function Value(pName As String) As String                        ' "" if no editor
Sub SetValue(pName As String, pValue As String)                  ' no-op if no editor
Function Values() As StringList                                  ' "NAME=text" entries
Sub LoadValues(pValues As StringList)                            ' no-op if Null
Sub Mount()                                                      ' no-op if already built
Function Validate() As Boolean
Sub ApplyMode()
Sub ResetFor(pMode As TRegisterMode)
Sub RememberContent()
Sub RestoreContent()
Function ExportKept() As StringList
Sub ApplyCopyDefaults()
Sub ApplyDefaults()                                              ' Incluir/Copiar only
Sub SyncPersonType()
OnCommit As TNotifyEvent
OnBuildFolder As TNotifyEvent
```

**OK (`HandleOk`)**

1. `Visualizar` → `Confirmed = True`, close.
2. Other modes except `Excluir` run `Validate()`. Failure keeps the dialog open.
3. Fire `OnCommit`. Session calls `AcceptCommit()` after a successful save.
4. If not accepted, stay open.
5. `Incluir` → `RememberContent()`. Set `Confirmed`, close.

**`Validate`**

- Required empty → `"{caption without :} é obrigatório."`
- `CNPJ_CPF` + `TipoPessoa` + kind CpfCnpj: document mismatch message from the editor.
- `ValidateField` hook: non-empty string is shown and blocks.
- Then `ValidacaoSistema` then `ValidacaoUsuario` per field (see Validation).

**Defaults / copy**

- `ShouldFillDefault`: fill if text is empty, equals the field name, or starts with `30/12/1899`.
- `ApplyCopyDefaults`: for non-autoincrement fields that are read-only on insert, write `ResolveDefault`.
- `ApplyMode` on `Copiar`: key/autoincrement editors get default or `Clear()`.
- `TipoPessoa` change updates `CNPJ_CPF` `PersonType` when both editors exist and the document field is CpfCnpj.
- CEP editor load fills `Endereco`/`Logradouro`, `Bairro`, `Complemento`, and município (`IBGE`) using the field-name prefix before `CEP`. CNPJ load fills `Nome`/`RazaoSocial`, `NomeFantasia`, `Email`/`EMail`, `Telefone`/`Fone`, address fields, then consults `{prefix}CEP` if that field is a CEP editor. Prefix is the field name without suffix `CNPJ_CPF` / `CPF_CNPJ` / `CPFCNPJ` / `CPF-CNPJ` / `CNPJ`.

**Overridable**

| Hook | Role |
|---|---|
| `AfterBuild` | After first `Mount` |
| `CreateEditor` | Build one editor (default: `TRegisterFactory.CreateEditor`) |
| `BuildSubCadastro` | Extra UI for a folder with `SubCadastro` |
| `ValidateField` | Extra check; `""` = ok |
| `HandleOk` / `AfterShow` / `Build` | Form lifecycle (`Build` is empty) |

`pConfig` `Null` → new empty config. `pMode` `Null` → `Incluir`.

---

## Factory

### `TRegisterKindBinder`

`Key` (uppercased kind), `Factory` delegate.

### `TRegisterFactory`

```bas
Shared Sub RegisterKind(pKind As String, pCreate As TRegisterEditorCreate)
Shared Function CreateEditor(pParent As Forms.TWinControl, pField As TRegisterField) As TLabeledEditorBase
Shared Function CreateDefault(pParent As Forms.TWinControl, pField As TRegisterField) As TLabeledEditorBase
```

Resolution order: `pField.Factory` if not `Null`; else binder for `KindKey()`; else `CreateDefault`. Re-`RegisterKind` with the same key replaces the factory. Unknown kind → `TTextEditor`.

---

## Eval

### `TRegisterEval`

```bas
Shared Function TextOf(pValue As String) As String
Shared Function ResolveDefault(pField As TRegisterField) As String
Shared Function IsRequired(pField As TRegisterField) As Boolean
Shared Function IsReadOnly(pField As TRegisterField, pMode As String, pForce As Boolean) As Boolean
Shared Function ShouldFillDefault(pCurrentText As String, pFieldName As String) As Boolean
Shared Function ApplyDefaultTo(pCurrentText As String, pField As TRegisterField) As String
```

- `ResolveDefault`: if `FormulaValorPadrao` is non-empty, `TCfgSql.AvaliarValorPadrao(TipoValorPadrao, formula)`; empty result falls back to `DefaultValue`.
- `IsRequired`: `CondicaoObrigatorio` non-empty → `AvaliarCondicao(..., False)`; else `Required`.
- `IsReadOnly`: `pForce`, `Locked`, or `AutoIncrement` → True. `INCLUIR`/`COPIAR`: not `CanEditInsert` or failed `CondicaoEditarInclusao` (default True if empty). `ALTERAR`: keys always read-only; else not `CanEditUpdate` or failed `CondicaoEditarAlteracao`. Other modes → False.

---

## Validation

Procedure specs on `ValidacaoSistema` / `ValidacaoUsuario`.

Examples: `"MinhaProc"`, `"MinhaProc(CodCliente, Nome)"`, `"MinhaProc CodCliente Nome"`.

```bas
Shared Function Parse(pSpec As String) As TRegisterProcSpec
Shared Function Execute(pSpec As String, pConfig As TRegisterFormConfig, pValues As StringList) As TRegisterProcResult
```

`TRegisterProcSpec`: `ProcedureName`, `Params` (`OwnsObjects = False`). Empty spec → empty name, `Execute` returns empty result (no query).

`TRegisterProcResult`: `Acao`, `Mensagem` from columns `Acao` / `Mensagem`.

Form mapping: `A` show message (if any) and continue; `P` confirm (empty message = continue); `B` show message and fail; anything else = continue. Query errors propagate.

Integer/number literals that cannot parse become SQL `NULL` (not an exception). Empty integer/number → `NULL`. Other values quoted. Images → `NULL`. `CodEmpresa` / `CodFilial` / `CodUsuario` fall back to `Ambient` if missing from `Values()`.

---

## Persistence

### `TRegisterRecord`

`TTable` bound to `Ambient.Tabela()`. Schema cache key = `schema.table` (see `TRegisterStore.CacheKey`).

```bas
Sub New(pCacheKey As String)
Overrides Sub DefineSchema(pSchema As TTableSchema)
Overrides Function CreateInstance() As TTable
Sub BeginBind()
Sub Mark(pName As String)
Overrides Function IncludeField(pOp As TTableOp, pDef As TFieldDef) As Boolean
Function UpdateWhere(pWhere As String) As Integer
Function DeleteWhere(pWhere As String) As Integer
Function BuildPkWhereSql() As String
Overrides Sub ReadField(pField As TField, pSrc As SQL.TField)
Overrides Sub BindField(pCmd As SQL.Command, pField As TField)
Overrides Sub Bind(pCmd As SQL.Command, pOp As TTableOp)
Shared Function TypeErrorText(pName As String, pEx As Exception) As String
Shared Function TypeErrorText(pName As String, pEx As Exception, pField As TField) As String
Shared Sub RaiseTypeError(pName As String, pEx As Exception, pField As TField)
Function AutoFieldName() As String
```

- `DefineSchema` throws `"Tabela do ambiente não carregada."` if `Ambient.Tabela()` is missing.
- Persist columns: Configurador `Campo` with name, not `Extra`, `Contexto = "R"`. Types: `I` integer; `N` numeric if `CasasDecimal > 0` else integer; `D` date; `T`/`H` time; `DT`/`DH` datetime; `L` integer; `LOG`/`BOL`/`BOOL` boolean; binary aliases `B,IM,IMG,IMA,PIC,IMAGE,BLOB,FOTO`; else string (+ `MaxLen` if `Tamanho > 0`). Then `TSql.ApplyNative`. Autoincrement if `CodCampo = CodCampoAutoIncremento`, else `Chave` → PK.
- `BeginBind` + `Mark`: INSERT/UPDATE persist only marked non-PK columns (PK always included). No bind list → all persistable columns.
- `UpdateWhere` / `DeleteWhere`: empty `pWhere` → `"Não foi possível montar a chave do registro."` Identity is inlined in SQL (not rebound as PK params). DELETE bind is skipped.
- `ReadField` / `BindField` catch conversion errors and `RaiseTypeError` (nome, título, tipo Configurador, inner message). Already-prefixed messages are rethrown as a **new** `Exception` with the same text.
- `AutoFieldName` → `""` if no autoincrement field.

### `TRegisterStore`

```bas
Shared Function CacheKey() As String
Shared Function OpenRecord() As TRegisterRecord
Shared Function Locate(pRecord As TRegisterRecord) As Boolean
Shared Sub Push(pForm As TRegisterForm, pRecord As TRegisterRecord)
Shared Sub Pull(pForm As TRegisterForm, pRecord As TRegisterRecord)
Shared Function Reserve(pRecord As TRegisterRecord) As Integer   ' 0 if no auto field
Shared Sub Release(pCode As Integer)                             ' no-op if pCode <= 0
Shared Sub InsertRow(pRecord As TRegisterRecord)
Shared Sub UpdateRow(pRecord As TRegisterRecord)
Shared Sub DeleteRow(pRecord As TRegisterRecord)
Shared Function IdentityWhere() As String
```

- `IdentityWhere` = `Trim(Ambient.InternalWhere())`; empty → `"Não foi possível montar a chave do registro."`
- `Locate` = `pRecord.Load(IdentityWhere())`.
- `Push` writes record → form; `TipoPessoa` first, then other fields with editors except `CNPJ_CPF`, then `SyncPersonType`, then `CNPJ_CPF`.
- `Pull` `BeginBind`, copies every config field that exists on the record, `Mark`s it, then fills empty `CodEmpresa` / `CodFilial` from Ambient when `> 0`.
- Sequence: `TSequence(table, schema, emp)` where `emp` is `Ambient.CodEmpresa()` only if `CodEmpresa` is a PK column.

### `TRegisterLog`

```bas
Shared Sub Save(pMode As String, pForm As TRegisterForm, pLoaded As StringList)
```

`pMode`: `INCLUIR`, `COPIAR`, `ALTERAR`, `EXCLUIR`. Types: insert / insert / update / delete. `NomeRotina = "Cadastro"`. Copy observation appends `IdentityWhere()`. Alter/delete store `ClausulaWhere`. Item values: types `I`,`N`,`L` raw; others wrapped in `'...'`. Strings clipped at 2000 chars. Exclude logs previous values only; alter logs diffs (and keys even if unchanged); include/copy log non-empty currents (copy may keep previous as old).

---

## Session and events

### `TRegisterContext`

| Member | Default |
|---|---|
| `Mode` | from session |
| `Form` / `Record` | set in `Show` |
| `RecordWhere` | `Trim(Ambient.InternalWhere())` at construct |
| `ReservedCode` | `0` |
| `CancelMessage` | `""` |
| `Allow` | `True` |

A gate sets `Allow = False` to abort. Non-empty `CancelMessage` is shown.

### Delegates

```bas
Delegate Sub TRegisterGate(pContext As TRegisterContext)
Delegate Sub TRegisterHook(pContext As TRegisterContext)
```

### `TRegisterEvents`

| Gate (can cancel) | Hook |
|---|---|
| `OnBeforeLoad` | `OnAfterLoad` |
| `OnBeforeReserve` | `OnAfterReserve` |
| `OnBeforeConfirm` | |
| `OnBeforeSave` | `OnAfterSave` |
| `OnBeforeDelete` | `OnAfterDelete` |
| | `OnCancel` (dialog not confirmed) |

### `TRegisterSession`

```bas
Events As TRegisterEvents
Context As TRegisterContext
Sub New(pMode As TRegisterMode)
Sub Show()
```

**`Show` flow**

1. Require `Ambient.Tabela()` else `"Ambiente não inicializado."`
2. Open form: if `Tabela.UsarCacheDeObjeto`, `Cache.Find<TRegisterForm>("Register.Form", CodTabela;NOME;SCHEMA)`. Hit → `ResetFor(mode)` (+ defaults/kept content on Incluir). Miss → `FromTabela` + `New TRegisterForm`, optionally `Cache.Put`.
3. `OpenRecord()`. Wire `OnCommit`.
4. `Incluir`: `Reserve` sequence, `ApplyMode`.
5. Else load: empty `RecordWhere` → `"Registro não informado."`; `Locate` false → `"Registro não encontrado."`; `Push` + capture loaded snapshot.
6. `Copiar`: `ApplyCopyDefaults`, clear auto editor, `ApplyDefaults`, `ApplyMode`, `Reserve`.
7. Else `ApplyMode`.
8. `form.Show()`. Confirmed → log already written in commit; Incluir may show `Data7.Report` when `CodRelatorioInclusao > 0` (params = field values) and loop if `InclusaoRecursiva`. Not confirmed → `Release(ReservedCode)`, `OnCancel`.
9. Exceptions: `Throw New Exception(ex.Message)` (new instance).

**Commit**

- Confirm: Excluir always (`ConfirmDeleteMessage`); Copiar always (`"Confirma a cópia do registro?"`); Incluir/Alterar only if `Tabela.ConfirmaInclusao` / `ConfirmaAlteracao`.
- Save: `Pull`; Incluir/Copiar `InsertRow` (re-apply reserved auto code); Alterar `UpdateRow`; then `TRegisterLog.Save`.
- Delete: `DeleteRow` + log `EXCLUIR`.

`Free` releases unused reserved code, form (unless cached), record, events, context.

Cache content key `"Register.Content"`: packed kept fields for recursive include.

---

## Extending (Consumer Project)

```bas
Function MinhaFactory(pParent As TWinControl, pField As TRegisterField) As TLabeledEditorBase
   MinhaFactory = New TTextEditor(pParent, pField.Caption, pField.ToProps())
End Function

TRegisterFactory.RegisterKind("MeuTipo", AddressOf MinhaFactory)
cfg.AddField("X", "X:").SetKind("MeuTipo")
cfg.AddField("Y", "Y:").WithFactory(AddressOf MinhaFactory)
```

Subclass `TRegisterForm` and override `CreateEditor`, `BuildSubCadastro`, `ValidateField`, `AfterBuild`. Assign `session.Events.OnBeforeSave` (etc.) before `Show()`. After `FromTabela`, call `cfg.AddField` for extra editors.

`TRegister` in `mod_register` has no members beyond construct/free.

---

## Host (`Principal.bas`)

Kept-name inputs: `CodTabela`, `NomeTabela`, `CodigoProcessoTabela`, `TituloProcessoTabela`, `Where`, `CodEmpresa`, `CodFilial`, `CodUsuario`, `SchemaTabela`, `EstacaoTrabalho`, `UsuarioWindows`. Zeros/blanks filled from `Data7.*` / `Environment.*`. DevMode sample: `CodTabela = 35`, `Where = "CodProduto = 1000"`, `TituloProcessoTabela = "Copiar"`. Commented: `TRegisterEvalTests.Run()`.

---

## Tests

`TRegisterEvalTests.Run()` — `TCfgSql` formulas/conditions, synthetic `TRegisterField` defaults/readonly/required, and mapping from a live `Ambient.Tabela()`. Prints a log and shows it in a message box. Not a generic runner.

---

## Module Notes

- Config `Fields`/`Folders` are owned; folder `Fields` and `HeaderFields` are not. `FocusFields` / `Sort*` lists are `OwnsObjects = False` — the caller Frees the list, not the items.
- Identity for load/update/delete is `Ambient.InternalWhere()` (the grid `Where`), not a rebuilt PK from edited values.
- INSERT/UPDATE persist only columns `Mark`ed after `BeginBind` (session `Pull` marks form fields).
- Inactive Configurador folders never appear; nested tabs follow `Estrutura` prefix (`02` / `02.01` and `0106` / `010601`).
- Type-cast failures on load/bind surface as `"Campo com tipo divergente entre o Configurador e o banco de dados."` plus Nome / Título / Tipo / Exceção. Do not rethrow the caught exception instance.
- `OnCommit` must call `AcceptCommit()` or OK does not close. `Visualizar` skips validate/commit.
- Form cache (`UsarCacheDeObjeto`) reuses the dialog; `OwnsConfig` default True means the form Frees the config unless the consumer sets it False.
- `KeepContent` + recursive include restore prior editor text from `"Register.Content"`; sequence `Release` runs on cancel/`Free` when the reserved code was not saved.
