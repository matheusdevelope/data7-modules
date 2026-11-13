# mod_log

Writes ERP audit rows to `LogSistema` (header) and `LogSistemaDetalhe` (field items). The consumer builds a `Logg`, optionally sets type/items, and calls `LogBatch.SaveOne` or `LogBatch.Save`. Empty company, branch, user, machine, schema, version, period, date, and time are filled from the ERP session on save.

This module does not own the business transaction being audited, does not discover table fields, and does not open UI. Deciding what changed, which `TipoLog` to use, and the `ClausulaWhere` that identifies the record are the consumer’s job.

Version `1.0.0.0`. Dependency in `data7.json`: `mod_table` `1.0.0.6`.

This file is the module contract. Consumers can assemble, extend, and call the API from this README without opening `.bas` files.

## Quick Start (Minimal)

```basic
Imports mod_log
Imports mod_log_type
Imports mod_log_batch

' Header: entity name, operation, screen, optional table code.
Dim entry As New Logg()
entry.Nome = "Produto"
entry.SetType(TLogType.ltInsert())
entry.NomeRotina = "Cadastro"
entry.CodTabela = 35

' Detail: field name, old value, new value (stored exactly as passed).
entry.AddItem("PrecoVenda", "", "2.00")
entry.AddItem("PrecoVenda2", "", "45.00")

' One sequence code, session fill, insert header + items.
LogBatch.SaveOne(entry)
' entry.CodLogSistema > 0 and entry.IsSaved() after success.
```

Several logs in one sequence block and one session/version read:

```basic
Imports mod_log
Imports mod_log_type
Imports mod_log_batch

Dim batch As New LogBatch()
Dim entry As Logg = batch.NewLog()
entry.Nome = "Produto"
entry.SetType(TLogType.ltUpdate())
entry.NomeRotina = "Cadastro"
entry.ClausulaWhere = "CodProduto = 706"
entry.AddItem("PrecoVenda", "1.00", "2.00")
batch.Save()
batch.Free()
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_log.bas` | `mod_log` | `Logg` |
| `src/lib/mod_log_item.bas` | `mod_log_item` | `LogItem` |
| `src/lib/mod_log_type.bas` | `mod_log_type` | `TLogType` |
| `src/lib/mod_log_context.bas` | `mod_log_context` | `LogContext` |
| `src/lib/mod_log_batch.bas` | `mod_log_batch` | `LogBatch` |
| `src/Tables/table_logsistema.bas` | `table_logsistema` | `TLogSistema`, `TLogSistemaSave` |
| `src/Tables/table_logsistemadetalhe.bas` | `table_logsistemadetalhe` | `TLogSistemaDetalhe` |
| `src/tests/log_tests.bas` | `mod_log_tests` | `TLogTest` |

`src/Principal.bas` runs `TLogTest` stages against a live database. It is not part of the consumer API.

## Types (`TLogType`)

Value stored in `LogSistema.TipoLog` (max 5 characters). `Logg.SetType` writes `pType.AsString`. A custom string in `Logg.TipoLog` is stored as-is (example: `"X"`).

```basic
Enun TLogType
   ltUpdate = "A"
   ltAccessMenu = "AMENU"
   ltAccessProcess = "APROC"
   ltDelete = "E"
   ltError = "ERR"
   ltInsert = "I"
   ltLogin = "LOGIN"
   ltLogout = "LOGOF"
End Enun
```

## Entry (`Logg` / `LogItem`)

### `LogItem`

One `LogSistemaDetalhe` row. `Valor` and `ValorAntigo` are stored exactly as passed (`"2.00"`, `"null"`, `"'JOGO'"`).

| Member | Type | Default |
|---|---|---|
| `Sequencia` | `Integer` | `0` until save renumbers `1..N`, or `AddItem` sets `Items.Length + 1` |
| `Nome` | `String` | `""` (required on save; blank/whitespace throws) |
| `ValorAntigo` | `String` | `""` → SQL `NULL` |
| `Valor` | `String` | `""` → SQL `NULL` |
| `Observacao` | `String` | `""` → SQL `NULL` |

### `Logg`

One complete log (header + owned `Items`). `CodLogSistema` is assigned on save when it is `<= 0`.

| Member | Type | Default | Notes |
|---|---|---|---|
| `CodLogSistema` | `Integer` | `0` | Preset keeps the code; `0` consumes the sequence. |
| `CodEmpresa` | `Integer` | `0` | Filled from session when `<= 0`. |
| `CodFilial` | `Integer` | `0` | Filled from session when `<= 0`. |
| `CodUsuario` | `Integer` | `0` | Filled from session when `<= 0`. |
| `CodPeriodoCaixa` | `Integer` | `0` | Filled from `Data7.CodPeriodoCaixa()` when `<= 0`; `0` stored as SQL `NULL`. |
| `CodTabela` | `Integer` | `0` | Left empty; `0` stored as SQL `NULL`. |
| `Nome` | `String` | `""` | Required. Max 200. |
| `TipoLog` | `String` | `""` | Required. Max 5. Prefer `SetType`. |
| `NomeRotina` | `String` | `""` | Max 100. Required by the table schema. |
| `Observacao` | `String` | `""` | Max 2000; empty → SQL `NULL`. |
| `ClausulaWhere` | `String` | `""` | Max 2000; empty string is stored (not `NULL`). Example: `"CodProduto = 706"`. |
| `NomeUsuario` | `String` | `""` | Session `Data7.NomeUsuario` when empty; clipped to 100. |
| `NomeComputador` | `String` | `""` | `Environment.MachineName` when empty; clipped to 100. |
| `UsuarioWindows` | `String` | `""` | `Environment.UserName` when empty; clipped to 30. |
| `NomeSistema` | `String` | `""` | `"Data7"` when empty; clipped to 100. |
| `VersaoSistema` | `String` | `""` | One `Sistema` query when empty; clipped to 100. |
| `NomeSchema` | `String` | `""` | Dialect default schema when empty; clipped to 50; empty → SQL `NULL`. |
| `Hora` | `String` | `""` | `hh:nn:ss` from save time when empty; clipped to 12. |
| `Data` | `TDateTime` | unset | `Date()` on save if `HasDate()` is False. |
| `Items` | `LogItem` list | `[]` | Owns items. Header-only logs are valid. |

```basic
Sub New()
   ' all integers 0, all strings "", Items empty and owned, not saved.

Property Data As TDateTime
   ' set marks HasDate True.

Function HasDate() As Boolean
   ' out: True only after Data was assigned.

Function IsSaved() As Boolean
   ' out: True after a successful Save / SaveOne.

Function IsGeneratedCode() As Boolean
   ' out: True after the batch assigned CodLogSistema; cleared on MarkSaved.

Sub SetType(pType As TLogType)
   ' in: Enun member; writes TipoLog (example ltInsert → "I").

Function AddItem(pNome As String, pValorAntigo As String, pValor As String, pObservacao As String = "") As LogItem
   ' in: field name and values; Observacao optional.
   ' out: the item, Sequencia = Items.Length after push.

Sub AssignCode(pCode As Integer, pGenerated As Boolean)
   ' in: explicit CodLogSistema; pGenerated True means RevertCode clears it on save failure.

Sub MarkSaved()
   ' sets IsSaved True and IsGeneratedCode False. Called by LogBatch after commit.

Sub RevertCode()
   ' if IsGeneratedCode, CodLogSistema = 0. No-op when the code was preset.

Function Copy() As Logg
   ' out: unsaved clone without CodLogSistema; items copied by value (not shared).
```

`Clone` is `Copy`.

## Session (`LogContext`)

Process-wide session snapshot reused by every save. Company, branch, user, and machine are read from ERP memory on each `Capture`. `VersaoSistema` and `CodPeriodoCaixa` hit the database at most once until `Invalidate`.

| Member | Type | Default |
|---|---|---|
| `CodEmpresa` / `CodFilial` / `CodUsuario` / `CodPeriodoCaixa` | `Integer` | `0` |
| `NomeUsuario` / `NomeComputador` / `UsuarioWindows` / `NomeSistema` / `VersaoSistema` / `NomeSchema` | `String` | `""` |

```basic
Shared Function Current() As LogContext
   ' out: process singleton (created on first call).

Shared Sub Invalidate()
   ' frees the singleton; next Current() is a new object (version/period load again).

Sub Capture()
   ' Data7.CodEmpresa/CodFilial/CodUsuario/NomeUsuario,
   ' Environment.MachineName / UserName,
   ' NomeSistema "Data7" if still empty,
   ' NomeSchema = TSql.Dialect().DefaultSchema() if still empty.

Function Version() As String
   ' out: VersaoSistema; first call runs InsertExpr on Sistema unless already set.
   ' expr: select (CAST(Versao AS VARCHAR) + '.' + CAST(MenorVersao AS VARCHAR) + '.' + CAST(ReleaseDaVersao AS VARCHAR) + '.' + CAST(BuilderDaVersao AS VARCHAR)) from Sistema

Function Period() As Integer
   ' out: CodPeriodoCaixa; first call uses Data7.CodPeriodoCaixa() if still <= 0.
```

`LogBatch.Context` starts as `NULL`. When `NULL`, save uses `LogContext.Current()` and calls `Capture`. Assign a filled `LogContext` to skip the singleton.

## Writer (`LogBatch`)

Collects `Logg` rows (or a compact template + where list) and inserts them. Sequence name comes from `TLogSistema` schema (`LogSistema_Sequencia`). Codes for `CodLogSistema <= 0` are reserved in one block; a preset code is kept.

| Member | Type | Default | Notes |
|---|---|---|---|
| `Context` | `LogContext` | `NULL` | Optional override of `LogContext.Current()`. |

```basic
Sub New(pOwnsLogs As Boolean = True)
   ' in: True = Free() also frees logs added via NewLog/Add. SaveOne uses False.

Function NewLog() As Logg
   ' out: new Logg already in the batch. Throws if already saved.

Function Add(pLog As Logg) As Logg
   ' in: existing entry. Throws "Log is required" if NULL.
   ' out: the same pLog.

Function Count() As Integer
   ' out: compact where count when AddWhere was used; otherwise _logs.Length.

Sub SetTemplate(pLog As Logg)
   ' in: header prototype for compact save. Takes ownership (frees the previous template).

Sub AddWhere(pWhere As String)
   ' in: ClausulaWhere for the next compact header. Resets compact item sequence to 0.

Sub AddCompactItem(pNome As String, pOld As String, pNew As String)
   ' in: item attached to the last AddWhere. Observacao is always NULL on write.
   ' throws "Log where is required" if no AddWhere yet.

Shared Sub SaveOne(pEntry As Logg)
   ' in: one Logg (not owned by the temporary batch). Throws "Log is required" if NULL.

Sub Save()
   ' apply session, validate, renumber items, reserve codes, insert.

Sub SaveFast()
   ' same write path without apply/validate/renumber. Compact path ignores this flag.
```

### Save algorithm

1. Already saved → throw `"Log batch already saved"`.
2. If any `AddWhere` → compact path (template required; no apply/validate on the `Logg` list).
3. If no logs → no-op (does not mark saved).
4. `Save` only: `Capture` session, fill empty fields, validate, set each item `Sequencia` to `1..N`.
5. Reserve contiguous codes for entries with `CodLogSistema <= 0`. If the sequence is behind `MAX(LogSistema.CodLogSistema)`, restart it and clear the SQL command pool; otherwise consume `NextValue` once per pending code.
6. Insert each header (`TLogSistemaSave`) then its details (`TLogSistemaDetalhe`) in one connection transaction when the connection was not already in a transaction.
7. On success: `MarkSaved` on each `Logg`. On failure: `RevertCode` on generated codes, rollback, throw `"Error saving LogSistema: " & inner`.

Compact save: one header per `AddWhere` cloned from the template (then `ClausulaWhere` replaced), items from `AddCompactItem` keyed to the where index. Does not fill session fields on the template.

### Throws / no-op / NULL

| Situation | Result |
|---|---|
| `Save` / `NewLog` / `Add` / `SetTemplate` / `AddWhere` after a successful save | `"Log batch already saved"` |
| `Save` of a `Logg` with `IsSaved` True | `"Log already saved: " & Nome` |
| Trim `Nome` empty | `"Log without Nome"` |
| Trim `TipoLog` empty | `"Log {Nome} without TipoLog"` |
| `CodEmpresa` / `CodFilial` / `CodUsuario` still `<= 0` after apply | `"Log {Nome} without CodEmpresa"` (or Filial / Usuario) |
| Item with Trim `Nome` empty | `"Item of log {Nome} without Nome"` |
| String longer than the max in the table below | `"{Field} exceeds {n} characters"` |
| Sequence `NextValue` `<= 0` | `"Não foi possível obter o próximo código de LogSistema."` |
| Compact save without `SetTemplate` | `"Log template is required"` |
| `AddCompactItem` before `AddWhere` | `"Log where is required"` |
| `Add` / `SaveOne` with `NULL` | `"Log is required"` |
| Empty `_logs` and no compact wheres | no-op |
| Write / sequence failure | `"Error saving LogSistema: …"` or `"Falha ao gravar LogSistema."` if the inner message is empty |

Clip / validate lengths (after session fill):

| Field | Max |
|---|---|
| `Nome`, `Item.Nome` | 200 |
| `TipoLog` | 5 |
| `NomeRotina`, `NomeComputador`, `NomeUsuario`, `NomeSistema`, `VersaoSistema` | 100 |
| `NomeSchema` | 50 |
| `UsuarioWindows` | 30 |
| `Hora` | 12 |
| `Observacao`, `ClausulaWhere`, `Item.ValorAntigo`, `Item.Valor`, `Item.Observacao` | 2000 |

## Persistence (`TLogSistema` / `TLogSistemaSave` / `TLogSistemaDetalhe`)

`mod_table` row types for the physical tables. Writers use `TLogSistemaSave` so `VersaoSistema` is a bound value (the shared `TLogSistema` schema keeps `InsertExpr` for `LogContext.Version`). Consumers load with `TLogSistema.Find` / `TLogSistemaDetalhe.Fetch`.

### `TLogSistema` — table `LogSistema`, sequence `LogSistema_Sequencia`

| Property | Column | Required | Empty → |
|---|---|---|---|
| `CodLogSistema` | `CodLogSistema` | PK / auto code | assigned on insert |
| `CodUsuario` | `CodUsuario` | yes | — |
| `Nome` | `Nome` | yes | — |
| `Data` | `Data` | yes | — |
| `Hora` | `Hora` | yes | — |
| `TipoLog` | `TipoLog` | yes | — |
| `NomeComputador` | `NomeComputador` | yes | — |
| `NomeUsuario` | `NomeUsuario` | yes | — |
| `NomeSistema` | `NomeSistema` | yes | — |
| `NomeRotina` | `NomeRotina` | yes | — |
| `VersaoSistema` | `VersaoSistema` | yes | `InsertExpr` on `TLogSistema` only |
| `Observacao` | `Observacao` | no | `NULL` |
| `CodPeriodoCaixa` | `CodPeriodoCaixa` | no | `NULL` |
| `ClausulaWhere` | `ClausulaWhere` | no | empty string kept |
| `CodTabela` | `CodTabela` | no | `NULL` |
| `UsuarioWindows` | `UsuarioWindows` | no | empty string |
| `CodEmpresa` | `Id_Empresa` | yes | — |
| `CodFilial` | `Id_Filial` | yes | — |
| `NomeSchema` | `NomeSchema` | no | `NULL` |

`GetID` is `CStr(CodLogSistema)`.

```basic
Sub New()
   ' cache key "TLogSistema".

Sub New(pCacheKey As String)
   ' used by TLogSistemaSave ("TLogSistemaSave").
```

### `TLogSistemaSave`

Same columns as `TLogSistema`, but `VersaoSistema.InsExpr` is `""` so the writer binds the string already on `Logg`.

### `TLogSistemaDetalhe` — table `LogSistemaDetalhe`

Composite PK `(Id_LogSistema, Sequencia)`. No sequence.

| Property | Column | Empty → |
|---|---|---|
| `CodLogSistema` | `Id_LogSistema` | PK |
| `Sequencia` | `Sequencia` | PK |
| `Nome` | `Nome` | required |
| `ValorAntigo` | `ValorAntigo` | `NULL` |
| `Valor` | `Valor` | `NULL` |
| `Observacao` | `Observacao` | `NULL` |

`GetID` is `CodLogSistema & "|" & Sequencia`.

Load example used by tests:

```basic
Dim header As TLogSistema = TLogSistema.Find(quoteIdent("CodLogSistema") & " = " & CStr(id))
Dim details[] As TLogSistemaDetalhe = TLogSistemaDetalhe.Fetch(quoteIdent("Id_LogSistema") & " = " & CStr(id), quoteIdent("Sequencia"), 0)
```

## Extending (Consumer Project)

There is no type catalog or UI to register. Typical extension:

- Fill a `Logg` in the consumer (register, grid, process) and call `LogBatch.SaveOne`.
- For a burst of logs, `New LogBatch()`, `NewLog` / `Add`, one `Save`.
- Preset `CodLogSistema` on a `Logg` (or mixed into a batch) to reuse a code; only entries with `CodLogSistema <= 0` consume the sequence block.
- Assign `batch.Context` (or fields on `LogContext.Current()` before save) when the ERP session is not the source of company/user/version.
- Compact path: `SetTemplate` + `AddWhere` / `AddCompactItem` when many headers share the same session fields and differ only by `ClausulaWhere`.
- Inherit `TLogSistema` only if the consumer needs a different `VersaoSistema` insert expression; writers must keep `TLogSistemaSave` semantics (bound version) if they insert through `LogBatch`.

`Logg.Copy` is the supported way to fork an unsaved template without sharing `Items`.

## Tests

`src/Principal.bas` runs:

```basic
TLogTest.Setup()
TLogTest.StageSession()
TLogTest.StageProductInsert()
TLogTest.StageProductUpdate()
TLogTest.StageBatch()
TLogTest.StageEdges()
TLogTest.Teardown()
```

On failure it calls `TLogTest.Cleanup()` (deletes only `CodLogSistema` values the suite tracked) and rethrows. Coverage: session fill and version read, product insert/update round-trip, 45-log batch with contiguous codes, validation errors, quotes, omitted `CodTabela`, custom `TipoLog`, `Copy`, mixed preset + generated codes. `Invalidate` then another `SaveOne` still advances the sequence.

## Module Notes

- `Logg.Items` and default `LogBatch` (`New()` / `NewLog`) own their objects; `LogBatch.SaveOne` and `New LogBatch(False)` do not own the `Logg` you pass to `Add`.
- `SetTemplate` owns the template `Logg` and frees the previous one.
- Integers `<= 0` and trimmed `""` mean “fill from session” on `Save`, except `CodTabela` / `CodLogSistema` which stay at the caller value (`0` = no table / assign a code).
- `Save` of an empty object-list batch is a no-op and does not set `_saved`; a second `Save` is then still allowed.
- Item `Sequencia` is rewritten to `1..N` on `Save`; the caller’s values are ignored. `SaveFast` does not renumber.
- Failed save rolls back the connection transaction started by the batch, restores generated `CodLogSistema` to `0`, and does not mark entries saved. Preset codes are left unchanged.
- `ClausulaWhere` empty is persisted as `''`, not `NULL`. Empty item `Valor` / `ValorAntigo` / `Observacao` become `NULL`.
- Canonical live test is `TLogTest` via `Principal.bas`; it writes real `LogSistema` rows and deletes only the ids it created.
