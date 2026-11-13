# mod_table

Runtime to map tables, persist rows, migrate schema, and generate `TTableOf<T>` subclasses from the catalog. It does **not** ship business tables: the consumer owns `DefineSchema`, property wrappers, migration ids, and when to call DDL. Version `1.0.0.6` (`data7.json`). `data7.json` `"dependencies"` is empty; source `Imports` used here are `Collections`, `mod_tobject`, `mod_tlist`, `mod_tenum`, and `IO` (codegen). Persistence goes through `SQL.Command` / `SQL.Connection`.

This file is the module contract. Do not open `.bas` files to call the API. Open implementation only to confirm a detail that is missing here.

## Quick Start (Minimal)

```
Imports TablesSchema
Imports TablesTable

Class TPedido
   Inherits TTableOf<TPedido>

   Sub New()
      MyBase.New("TPedido")   ' cache key for TTableSchema
   End Sub

   Overrides Sub DefineSchema(pSchema As TTableSchema)
      pSchema.TableName = "Pedido"
      pSchema.Field("CodPedido").AsInteger().AutoCodeField()
      pSchema.Field("Titulo").AsString().MaxLen(150).RequiredField()
      pSchema.Field("ValorTotal").AsFloat()
      pSchema.Field("Ativo").AsBoolean().DefaultVal(True)
   End Sub

   Property CodPedido As Integer
      Get
         CodPedido = me.GetInteger("CodPedido")
      End Get
      Set(pValue As Integer)
         me.SetInteger("CodPedido", pValue)
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
End Class

Dim row As New TPedido()
row.Titulo = "Pedido Alfa"   ' AutoCode fills CodPedido on Insert when it is 0
row.Insert()

Dim found As TPedido = TPedido.Find("Titulo = 'Pedido Alfa'")   ' Null if none
If Assigned(found) Then
   found.Titulo = "Pedido Alfa Edit"
   found.Update()
   found.Free()
End If
row.Free()
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/core/TablesField.bas` | `TablesField` | `TKindField`, `TTableOp`, `TResourceKind`, `TDdlOpKind`, `TCommitMode`, `TAlterColumnMode`, `TFieldCache`, `TFieldDef`, `TField`, `TFields`, `TDdlOp`, `TResource`, `TColumnInfo` |
| `src/core/TablesSchema.bas` | `TablesSchema` | `TTableSchema` |
| `src/core/TablesSql.bas` | `TablesSql` | `TSqlDialect`, `TSqlDialectMssql`, `TSqlDialectAsa`, `TSqlDialectPostgres`, `TSqlDialects`, `TSql` |
| `src/core/TablesTable.bas` | `TablesTable` | `TTable`, `TTableOf<T>` |
| `src/core/TablesDdl.bas` | `TablesDdl` | `TDdl` |
| `src/core/TablesSequence.bas` | `TablesSequence` | `TSequenceLease`, `TSequence` |
| `src/core/TablesRoutine.bas` | `TablesRoutine` | `TRoutine` |
| `src/core/TablesExecutor.bas` | `TablesExecutor` | `TWorkItem`, `TExecutor` |
| `src/core/TablesMigration.bas` | `TablesMigration` | `TTableMigrations`, `TMigrationContext`, `TMigration`, `TScriptMigration`, `TMigrationRunner` |
| `src/core/TablesCodegen.bas` | `TablesCodegen` | `TTableGenerator` |
| `src/tests/tests.bas` | `tests` | `TTablesTest` (suite; not a consumer API) |

## Enuns

Cached instances live on `TFieldCache` (`KindInteger()`, `OpInsert()`, `ResourceView()`, `CommitSingle()`, `DdlCreateTable()`, …). Compare with those Shared values.

```
Enun TKindField
   StringKind = "String"       ' KindId 0
   IntegerKind = "Integer"     ' KindId 1
   FloatKind = "Float"         ' KindId 2
   BooleanKind = "Boolean"     ' KindId 3
   DateKind = "Date"           ' KindId 4
   DateTimeKind = "DateTime"   ' KindId 5
   TimeKind = "Time"           ' KindId 6
   Base64Kind = "Base64"       ' KindId 7
End Enun

Enun TTableOp
   OpSelect = "Select"
   OpInsert = "Insert"
   OpUpdate = "Update"
   OpDelete = "Delete"
   OpUpsert = "Upsert"
   OpMerge = "Merge"
   OpCustom = "Custom"
End Enun

Enun TResourceKind
   Trigger
   Procedure
   Func = "Function"
   View
   Index
End Enun

Enun TDdlOpKind
   CreateTable
   DropTable
   AddColumn
   DropColumn
   RenameColumn
   AlterColumn
   EnsureSequence
   DropSequence
   CustomSql
   CreateOrAlterRoutine
   DropRoutine
End Enun

Enun TCommitMode
   SingleTransaction      ' default on TExecutor
   PerBatch
   PerStatement
   JoinExisting
End Enun

Enun TAlterColumnMode
   InPlace
   Rebuild
   Automatic              ' default on TDdlOp
End Enun
```

## Schema and fields

### `TTableSchema`

Holds field defs for one table class. First `TTable` construction with a given cache key calls `DefineSchema`, then `Compile()`, then stores the schema in a process cache.

| Member | Default | Notes |
|---|---|---|
| `CacheKey` | `""` | Set from `TTable.New(pName)` |
| `TableName` | `""` | Physical table |
| `SchemaName` | `""` | Empty / dialect default → no schema prefix on sequences/tables |
| `Sequence` | `""` | Explicit sequence name; wins over AutoCode `WithSequence` |
| `FromClause` | `""` | If empty, `TTable` sets it to `TableName`. Non-table SQL (JOIN) is used as-is in SELECT |
| `Fields` | owned `StringList` | Keys are `UCase(name)` |
| `CodEmpresaIndex` | `-1` | Index of field named `CodEmpresa` (name or `DbName`) |
| `Compiled` | `False` | `Field(name)` creating a new def sets this to `False` |

```
Function Field(pIndex As Integer) As TFieldDef
Function Field(pName As String) As TFieldDef   ' creates the def if missing
Sub Compile()
Function PersistFields() As TTList<TFieldDef>  ' Persist And Not SelectOnly; OwnsObjects = False
Function PkFields() As TTList<TFieldDef>       ' OwnsObjects = False
Function AutoCodeField() As TFieldDef          ' Null if none
Function ResolvedFromClause() As String        ' FromClause or TableName
Shared Function GetCache(pClassName As String) As TTableSchema  ' Null if missing
Shared Function FromCache(pClassName As String) As TTableSchema ' same as GetCache
Shared Function AddCache(pClassName As String, pSchema As TTableSchema) As TTableSchema
Shared Sub PutCache(pClassName As String, pSchema As TTableSchema)
Shared Function HasCache(pClassName As String) As Boolean
```

### `TFieldDef`

Fluent column definition. `New(pName)` copies `pName` to `Name`, `DbName`, `ParamName`.

| Member | Default |
|---|---|
| `Kind` / `KindId` | String / `0` |
| `DbType` | `""` (dialect `TypeName` infers from `KindId`) |
| `MaxLength` | `255` (`0` after first `AsBoolean`/`AsBase64` if still 255) |
| `Precision` / `Scale` | `0` / `0` |
| `DefaultValue` | `Unassigned` |
| `PrimaryKey` / `AutoCode` / `Required` | `False` |
| `Persist` / `Insertable` / `Updatable` / `IncludeInSelect` | `True` |
| `SelectOnly` | `False` |
| `NullIfEmpty` | `True` (`False` after `PrimaryKeyField` / `AutoCodeField`) |
| `SelectExpr` / `InsertExpr` / `UpdateExpr` / `SequenceName` | `""` |
| `BoolTrue` / `BoolFalse` | `""` until `AsBoolean` → `"S"` / `"N"` |

```
Function AsString() As TFieldDef
Function AsInteger() As TFieldDef
Function AsFloat() As TFieldDef
Function AsNumeric(pPrecision As Integer, pScale As Integer = 0) As TFieldDef
Function AsBoolean() As TFieldDef
Function TrueValue(pValue As String) As TFieldDef
Function FalseValue(pValue As String) As TFieldDef
Function AsDate() As TFieldDef
Function AsDateTime() As TFieldDef
Function AsTime() As TFieldDef
Function AsBase64() As TFieldDef          ' bind/read via SQL Param/Field.AsBase64
Function PrimaryKeyField() As TFieldDef   ' also Required, NullIfEmpty=False
Function AutoCodeField() As TFieldDef     ' also PrimaryKey, NullIfEmpty=False
Function RequiredField() As TFieldDef
Function MaxLen(pValue As Integer) As TFieldDef
Function NumericPrec(pPrecision As Integer, pScale As Integer = 0) As TFieldDef
Function DefaultVal(pValue As Variant) As TFieldDef
Function NullIfEmptyField(pValue As Boolean = True) As TFieldDef
Function SelectOnlyField() As TFieldDef   ' Persist/Insertable/Updatable = False
Function SelExpr(pExpression As String) As TFieldDef
Function InsExpr(pExpression As String) As TFieldDef
Function UpdExpr(pExpression As String) As TFieldDef
Function InsertableField(pValue As Boolean = True) As TFieldDef
Function UpdatableField(pValue As Boolean = True) As TFieldDef
Function NotUpdatable() As TFieldDef
Function WithDbType(pType As String) As TFieldDef
Function WithSequence(pName As String) As TFieldDef
Sub EnsureBoolLen()                       ' MaxLength at least len(True/False tokens)
Function FoldBoolToken(pText As String) As String
Function IsTrueToken(pFolded As String) As Boolean
Function ParseBoolText(pText As String) As Boolean
Function ParseBoolValue(pValue As Variant) As Boolean
Function BoolDbText(pValue As Boolean) As String
```

Boolean persist text is `BoolTrue`/`BoolFalse` (default `"S"`/`"N"`). `ParseBoolText` matches those tokens first; otherwise `IsTrueToken` accepts `S`, `SIM`, `TRUE`, `T`, `1`, `-1`, `Y`, `YES`, `V`, `VERDADEIRO` (folded uppercase). Empty text / empty Variant → `False`. `AsBoolean` sizes `MaxLength` to the longer of the two tokens (minimum 1). Dialect `TypeName` for boolean with empty `DbType` is `VARCHAR(MaxLength)` (e.g. `VARCHAR(1)` for S/N).

### `TField`

Row value plus `Def`. `New(pDef, pValue)`.

```
Function EffectiveValue() As Variant      ' Value, else Def.DefaultValue
Function IsNull() As Boolean
Function IsDateKind() As Boolean          ' KindId 4/5/6
Sub NormalizeDate()
Property AsInteger As Integer             ' empty → 0
Property AsString As String               ' dates format; empty → ""
Property AsFloat As Extended              ' empty → 0
Property AsBoolean As Boolean             ' empty → False
Property AsDateTime As TDateTime          ' empty → Unassigned
Property AsBase64 As String               ' trim-empty set → Unassigned
Shared Function IsBlankDate(pDate As TDateTime) As Boolean   ' 0 or Unassigned
Shared Function TypeErrorMarker() As String                  ' "Falha de tipo no campo "
Function WrapTypeError(pEx As Exception) As String
```

`IsNull`: if `NullIfEmpty` is False → never null. Empty Variant → null. Date kinds → blank date. `KindId` 0 or 7 → trim-empty string is null.

`AsString` set: trim-empty → `Unassigned`; date kinds parse compact `yyyyMMdd` / `yyyyMMddHHmmss`, ISO `yyyy-mm-dd` rewritten to local `dd/mm/yyyy`, then `TryStrToDate` / `StrToDateTime`. Failed parse → `Unassigned`.

Bind/read type errors are rethrown as `WrapTypeError` from `TTable.BindField` / `ReadField`.

### `TFields`

`TTable` inherits this. Field lookup is `UCase`. `Fields.OwnsObjects = True`.

```
Function HasField(pID As String) As Boolean
Function GetField(pIndex As Integer) As TField
Function GetField(pID As String) As TField      ' throws "Campo inexistente: {pID}"
Sub AddField(pField As TField)
Sub AddField(pID As String, pField As TField)
Sub SetField(pID As String, pField As TField)
Function GetInteger/GetString/GetFloat/GetBoolean/GetDateTime/GetBase64(...)
Sub SetInteger/SetString/SetFloat/SetBoolean/SetDateTime/SetBase64(...)
Function GetFieldList() As String               ' names joined by ","
```

`GetFloat` returns `Double`; `SetFloat` takes `Double`.

## Persistence

### `TTable`

Abstract row. `New(pName)` loads or builds `TTableSchema` under that cache key.

```
MustOverride Sub DefineSchema(pSchema As TTableSchema)
MustOverride Function CreateInstance() As TTable   ' TTableOf implements New T()
```

**IncludeField** (overridable):

| Op | Included when |
|---|---|
| Select | `IncludeInSelect` |
| Insert / Merge | `Persist And Insertable And Not SelectOnly` |
| Update | persist + updatable + not select-only + **not PK** |
| Delete | `PrimaryKey` |
| else | `Persist And Not SelectOnly` |

**Hooks** (empty defaults): `PrepareValue(pOp, pField)`, `ReadField`, `BindField`, `Bind`, `IncludeField`, `BuildFromClause`, `Validate`, `BeforeInsert` / `AfterInsert`, `BeforeUpdate` / `AfterUpdate`, `BeforeDelete` / `AfterDelete`, `BeforeLoad` / `AfterLoad`, `AfterAssignPrimaryKey`, `BeforeMerge` / `AfterMerge`.

```
Function Field(pIndex As Integer) As TField
Function Field(pName As String) As TField
Function Load(pWhere As String) As Boolean          ' False if Eof
Function LoadWhere(pWhere As String) As Boolean     ' alias of Load
Function FetchRows(pWhere, pOrder = "", pLimit = 0) As TTList<TTable>
Function RowExists(pWhere As String) As Boolean
Function ExistsByPk() As Boolean
Function Insert() As Integer
Function Update() As Integer
Function Delete() As Integer
Function Upsert() As Integer                        ' ExistsByPk → Update else Insert
Function Merge() As Integer
Sub EnsurePrimaryKey()                              ' AutoCode + value 0 → TSequence.NextValue
Sub AssignAutoCode(pValue As Integer)
Function NeedsAutoCode() As Boolean                 ' AutoCode field AsInteger = 0
Function HasCodEmpresa() As Boolean
Function CodEmpresaValue() As Integer               ' 0 if CodEmpresaIndex < 0
Function SequenceKey() As String                    ' TSql.ProximoCodigoKey
Function ResolvedSequenceName() As String
Function GetCommandText(pOp As TTableOp) As String
Function PreparedCommand(pOp As TTableOp) As SQL.Command
Function ApplyDml(pOp As TTableOp, pCmd As SQL.Command) As Integer
Sub AssignFrom(pOther As TTable)                    ' copies values for names that exist on both
Sub Hydrate(pCmd As SQL.Command)
Sub HydrateFrom(pSrcs As StringList)
```

`Validate` throws `"Campo obrigatório vazio: {CacheKey}.{Name}"` when Required (or PK that is not AutoCode) is null, unless the field is skipped by `IncludeField`, AutoCode on Insert/Merge, or Insert/Update expr is set.

`BuildPkWhereSql` / `Merge` throw if there is no PK. Merge also throws if there are no persistent insert columns.

`FetchRows` list `OwnsObjects = False` (caller owns rows). `pLimit <= 0` means no limit SQL.

`EnsurePrimaryKey` is a no-op if there is no AutoCode field or its `AsInteger <> 0`.

`GetCommandText(OpCustom)` uses the insert template. SQL text is cached per `IncludedFieldKey`.

`AssignFrom` copies `Value` only; it does not clone defs.

`ToString` logs `SchemaName.TableName` plus each field `Name`/`Value`.

### `TTableOf<T As TTable>`

```
Shared Function Fetch(pWhere, pOrder = "", pLimit = 0) As TTList<T>  ' OwnsObjects = False
Shared Function Find(pWhere As String) As T   ' Null if not found (probe is Freed)
Shared Function Exists(pWhere As String) As Boolean
Shared Function Insert/Update/Delete/Upsert/Merge(pRow As T) As Integer
```

WHERE/ORDER are appended via dialect `NormalizeWhere` / `NormalizeOrderBy`. Empty where → no `WHERE` clause (`NormalizeWhere("")` → `""`).

## SQL dialect

`TSql.Dialect()` → `TSqlDialects.Current()` from `SQL.Connection.RDBMS`: `dbMSSQL` → `TSqlDialectMssql`, `dbASA` → `TSqlDialectAsa`, `dbPostgreSQL` → `TSqlDialectPostgres`, else MSSQL.

| Dialect | `DefaultSchema` | Binary `TypeName` (`KindId` 7) | Sequence quote |
|---|---|---|---|
| MSSQL | `dbo` | `VARBINARY(MAX)` | unquoted `schema.object` (no `[name]` wrapping the dotted name) |
| ASA | `dba` | `LONG BINARY` | quoted parts |
| Postgres | `dbo` | `BYTEA` | quoted lowercase parts |

`IsDefaultSchema("")` is True. Empty `SchemaName` on a table uses the dialect default for sequence/table qualification.

### `TSql` (Shared)

```
Function Dialect() As TSqlDialect
Sub ApplyNative(pDef As TFieldDef, pNative As String)
Sub ApplyBinaryColumn(pDef As TFieldDef)
Function ProximoCodigoKey(pSchemaName, pTable) As String
   ' default schema → "Pedido"; else "Financeiro.ContaReceber"
Function StandardSequenceName(pSchemaName, pTable, pHasEmpresa, pCodEmpresa) As String
   ' "Pedido_Sequencia" | "EscritaFiscal.TipoNotaFiscalServico_Sequencia" | "..._Sequencia_2"
Function ExplicitSequenceName(pSchema As TTableSchema) As String
   ' Trim(Schema.Sequence), else AutoCode.SequenceName, else ""
Function ResolvedSequenceName(pSchema, pHasEmpresa, pCodEmpresa) As String
Function CommandFor(pCacheKey As String, pCommandText As String) As SQL.Command
Function OpenQuery(pSql As String) As SQL.Command          ' throws "Query:" + sql + "Error:"
Function ExecScalarInteger(pSql As String, pDefault As Integer = 0) As Integer  ' field "ok"
Function ExecScalarV(pSql As String, pField As String, pDefault As Integer = 0) As Integer
Function FetchStringColumn(pSql As String, pFieldName As String) As StringList  ' UCase values
Function DescribeColumns(pSchemaName, pTable) As TTList<TColumnInfo>
   ' throws "Tabela não encontrada: {schema.table}"
Function ExistsFlag(pSql As String) As Boolean             ' ExecScalarInteger <> 0
Function ExecCommand(pCmd As SQL.Command) As Integer
Function ExecScript(pSql As String) As Integer             ' Trim empty → 0; then ClearPool
Function ExecSelect(pSql As String) As String              ' SELECT (pSql) AS Valor; Eof → ""
Function LiteralDate(pDate As TDateTime, pWithTime As Boolean) As String  ' blank → "NULL"
Function LiteralTime(pDate As TDateTime) As String
Function ParamsFor(pCacheKey, pCmd, pSchema, pIdxs) As StringList
Sub ClearPool()
```

`ExecScript` / `ExecCommand` start a transaction only if the connection is not already in one; on failure they roll back that nested start. Failures wrap SQL text in `"Query:"` / `"Error:"`. `ExecScript` always `ClearPool` after run.

`MapFieldKind` native examples: `INTEGER`/`BIGINT`/`SERIAL` → Integer; `NUMERIC`/`FLOAT` → Float; `BIT`/`BOOLEAN` → Boolean; `DATE` → Date; `TIME`/`TIMETZ` → Time; `DATETIME`/`TIMESTAMP` → DateTime; `BYTEA`/`VARBINARY`/`IMAGE`/`BLOB`/`LONG BINARY`/`BINARY`/`BYTE` → Base64; else String.

### `TSqlDialect`

SQL builders (`QuoteIdent`, `QuoteTable`, `QuoteSequence`, `TypeName`, `SqlCreateTable`, `SqlMerge`, `ApplyLimit`, `NormalizeWhere`, `SqlNextSequence`, …). `SequenceSchemaOf` / `SequenceObjectOf` split on the first `.`. `SupportsDdlInTransaction`: MSSQL/Postgres True, ASA False. `SupportsDropIfExists`: MSSQL/Postgres True, ASA False.

`TColumnInfo` (catalog row): `Name`, `NativeType`, `MaxLength` default `0`, `Precision`/`Scale` `0`, `Nullable` True, `PrimaryKey`/`Identity` False.

## DDL, sequences, routines

### `TDdl`

Idempotent physical ops. No-ops: `CreateTable` if exists; `DropTable` if missing (when dialect has no `IF EXISTS`); `AddColumn` if exists; `DropColumn` if missing; `RenameColumn` if target exists or source missing.

```
Function TableExists/ColumnExists/SequenceExists(...) As Boolean
Function ListColumnNames(pTable As String) As StringList   ' UCase names
Function HasColumnName(pColNames As StringList, pCol As String) As Boolean
Sub CreateTable(pSchema As TTableSchema)
Sub DropTable(pTable As String)
Sub AddColumn(pTable As String, pField As TFieldDef)
Sub DropColumn(pTable As String, pCol As String)
Sub RenameColumn(pTable, pFrom, pTo)
Sub AlterColumn(pTable, pField, pMode As TAlterColumnMode)
Sub RebuildColumn(pTable, pField)          ' {DbName}_tmp + CAST copy + drop + rename
Sub SetNullability(pTable, pCol, pRequired As Boolean)
Sub CreateSequence/DropSequence(pName As String)
Function OpCreateTable/OpDropTable/OpAddColumn/OpDropColumn/OpAlterColumn/OpEnsureSequence(...)
Function OpsFromSchema(pSchema As TTableSchema) As TTList<TDdlOp>
Sub ApplyOp(pOp As TDdlOp)
Sub ApplyOps(pOps[] As TDdlOp)
```

`OpsFromSchema`: if the table has no columns → `CreateTable`; else `AddColumn` for each persist field missing in the catalog. If `ExplicitSequenceName` is non-empty and the sequence does not exist → `EnsureSequence`. Does not drop extra columns.

`ApplyOp` handles CreateTable, DropTable, AddColumn, DropColumn, RenameColumn, AlterColumn, EnsureSequence, DropSequence, CustomSql. `CreateOrAlterRoutine` / `DropRoutine` kinds are not applied here (`TRoutine` does routines).

`AlterColumn`: missing column → `AddColumn`. `Automatic` rebuilds when `SupportsInPlaceAlterType` is False (same `KindId`; for String, also `To.MaxLength >= From.MaxLength`).

### `TSequence`

```
Sub New(pName As String)
Sub New(pName As String, pCodEmpresa As Integer)
Sub New(pTableName As String, pSchemaName As String, pCodEmpresa As Integer)
Property TableName / SchemaName / CodEmpresa As ...
Property Name As String
Shared Function Load(pSchema As TTableSchema, pCodEmpresa As Integer = 0) As TSequence
Function Exists() As Boolean
Sub CreateIfMissing()     ' no-op if Exists
Sub DropIfExists()
Function CurrentValue() As Integer
Function NextValue() As Integer            ' dialect creates the sequence if missing
Sub SetValue(pNext As Integer)             ' RestartWith
Sub RestartWith(pNext As Integer)
Sub SyncFromMax(pTable As String, pPk As String)
Function AllocateBlock(pCount As Integer) As TSequenceLease  ' throws if pCount <= 0
```

`Name` without `_Sequencia` in it is a **literal** (e.g. `"_libtest_pedido_seq"`). Canonical names parse `Schema.Table_Sequencia` and optional `_Empresa` tail (`Financeiro.ContratoBancarioCobranca_Sequencia_1`). `Load` uses `ExplicitSequenceName` if set, else table/schema/empresa.

`CodEmpresa < 0` is stored as `0`. Setting `CodEmpresa` on the `New(pName, pCodEmpresa)` overload only applies when `pCodEmpresa > 0`.

### `TSequenceLease`

```
Sub New(pName As String, pNextBefore As Integer, pCount As Integer)
Function Take() As Integer    ' throws "TSequenceLease esgotado: {name}"
Sub Commit()
Sub Rollback()                ' RestartWith(NextBefore) unless already Commit/Rollback
```

`FirstCode` = `NextBefore`; `LastCode` = `NextBefore + pCount - 1`.

### `TRoutine`

```
Function Exists(pKind As TResourceKind, pName As String) As Boolean
Sub CreateOrAlter(pKind, pName, pBody As String)
Sub Drop(pKind, pName As String)
Sub DropIndexOnTable(pIndex As String, pTable As String)
Sub ApplyResource(pRes As TResource)   ' empty SqlText → Drop; else CreateOrAlter
```

### `TResource` / `TDdlOp`

`TResource.New(pKind, pName, pSql)` — `DropOnDown` default **True**.

`TDdlOp.New(pKind)` — strings empty, `AlterMode` = Automatic.

## Executor

### `TWorkItem`

`Op`, `Table` (may be unassigned), `SqlText` (custom SQL). `New(pOp)`.

### `TExecutor`

| Member | Default |
|---|---|
| `BatchSize` | `50` |
| `CommitMode` | `SingleTransaction` |
| `RewindOnError` | `True` until you set `CommitMode` (then True for Single/JoinExisting) or set `RewindOnError` explicitly |
| `Queue` / `Leases` | owned lists |

```
Sub AddInsert/AddUpdate/AddDelete/AddUpsert/AddMerge(pRow As TTable)
Sub AddInsert/AddUpdate(pRows[] As TTable)
Sub AddSql(pSql As String)
Sub AssignKeys()                 ' no-op if already run; EnsurePrimaryKey on insert-like
Function Exec() As Integer       ' throws "Erro ao executar ação em lote"
Sub Clear()
Function SequenceNameOf(pRow As TTable) As String   ' ExplicitSequenceName only
Function IsInsertLike(pItem As TWorkItem) As Boolean
Function ExecItem(pItem As TWorkItem) As Integer
```

`Exec` assigns AutoCode first. `JoinExisting` does not start/commit a transaction. `PerStatement` commits each item. `PerBatch` commits every `BatchSize` items. Upsert items become Update or Insert via `ExistsByPk`. Custom items call `TSql.ExecScript`. On error: rollback if a transaction is open; rewind leases when `RewindOnError`.

## Migrations

History table `_developer_table_migrations`: `Id` string PK max 150, `AppliedAt` required DateTime (`TTableMigrations`).

### `TMigrationContext`

`Ddl`, `Sequence` (`New("")`), `Routine`, `Exec`, `Query`.

### `TMigration`

```
Sub New(pId As String)
Sub New(pId As String, pTable As TTable)
Sub New(pId As String, pSql As String)
Function Id() As String
Overridable Function BuildOps/BuildDownOps(pCtx) As TTList<TDdlOp>
Overridable Function GetSql/GetDownSql(pCtx) As String   ' default ""
Overridable Sub Up(pCtx As TMigrationContext)
Overridable Sub Down(pCtx As TMigrationContext)
```

`Up`: if `GetSql` is non-empty → `ExecScript`; else `BuildOps` + `ApplyOps`; then if `RawSql` is set **and** `Table` is Null → `ExecScript(RawSql)`; then `ApplyResource` for each `Resources` item.

`Down`: `GetDownSql` if set; else script-only migrations require `RawSqlDown` or throw `"Down não definido para migração {id}"`; else inverse of CreateTable→DropTable and AddColumn→DropColumn; then drop resources with `DropOnDown`.

`TScriptMigration.New(pId, pSql)` is `TMigration` with `RawSql` only.

### `TMigrationRunner`

```
Sub Registerr(pMigration As TMigration)    ' key = migration Id
Function Execute() As Integer              ' count newly applied; sort pending by Id ascending
Sub RollbackLast()                         ' no-op if none applied
Sub Rollback(pId As String)                ' must be LatestAppliedId
Sub RollbackTo(pId As String)              ' downs every applied Id > pId, newest first
Function Pending() As TTList<TMigration>   ' OwnsObjects = False
Function AppliedIds() As StringList        ' copy
Function LatestAppliedId() As String       ' "" if none
Function FindRegistered(pId As String) As TMigration  ' Null if missing
Sub InvalidateApplied()
```

Pending = registered ids not in history. `Execute`/`Rollback` use a connection transaction when `SupportsDdlInTransaction`. Failures throw `"Erro ao executar migração: " & ex.Message` and `InvalidateApplied`. `Rollback` throws if `pId` is not the latest applied, or the migration is not registered.

## Codegen

### `TTableGenerator`

Reads `TSql.DescribeColumns` and writes a `TTableOf` subclass.

```
Shared Function Render(pTable As String, pSchema As String = "") As String
Shared Function Save(pFolder, pTable, pSchema = "", pFileName = "") As String  ' full path
Shared Function SaveMany(pFolder, pTables As StringList, pSchema = "") As StringList
Function Build/BuildLines/WriteFile/WriteMany(...)
Function NamespaceName(pSchemaName, pTable) As String
   ' "table_produto"; non-default schema "table_dicionario_projeto"
Function ClassNameOf(pSchemaName, pTable) As String
   ' "TProduto"; with schema "TDicionarioProjeto"
Function FileNameOf(...) As String         ' NamespaceName & ".bas"
Sub ParseName(pSpec, pDefaultSchema, ByRef pSchemaName, ByRef pTable)
   ' "Financeiro.Conta" splits on first "."
Function PropertyNameOf(pColName, pClassName As String) As String
```

Generated file `Imports TablesSchema` and `TablesTable`. `MyBase.New("TProduto")` uses the generated class name as cache key.

AutoCode in generated schema: integer PK, not `CodEmpresa`; identity column; or single PK; or two PKs including `CodEmpresa`.

`PropertyNameOf` keeps catalog case; prefixes `C` if reserved (`Field`, `Insert`, `Schema`, …) or if the ident starts with a digit; appends `Col` if it equals the class name.

## Extending (Consumer Project)

1. Subclass `TTableOf<TYourClass>` in the consumer project.
2. `Sub New()` → `MyBase.New("TYourClass")` (stable cache key).
3. Override `DefineSchema`: set `TableName` / optional `SchemaName`, `Sequence`, `FromClause`; chain `Field("Col").AsInteger()...`.
4. Optional: wrap `GetInteger`/`SetString`/… as properties; override `PrepareValue` and Before/After hooks.
5. Optional JOIN: set `FromClause` to a SQL fragment and `SelExpr` on `SelectOnly` fields.
6. Optional migrations: `TMigrationRunner.Registerr(New TMigration("id_01", New TYourClass()))` or `New TScriptMigration("id_02", "ALTER ...")`.
7. Optional codegen: `TTableGenerator.Save(folder, "Produto")` then move/edit the file in the consumer.

There is no UI in this module.

## Module Notes

- Schema is cached **per `TTable` constructor name** for the process; changing `DefineSchema` after the first instance of that key has no effect unless you replace the cache entry.
- Field names are matched with `UCase` (`"codpedido"` = `"CodPedido"`). Generated properties keep catalog case.
- `Fetch` / `FetchRows` lists do not own row objects (`OwnsObjects = False`).
- Boolean columns persist as text (`S`/`N` unless `TrueValue`/`FalseValue`). Binary files persist with `AsBase64` and `SQL.Param`/`SQL.Field.AsBase64`.
- Sequences: default schema `Tabela_Sequencia`; otherwise `Schema.Tabela_Sequencia` and optional `_CodEmpresa`. MSSQL does not wrap the dotted name in a single pair of brackets.
- `TSql.CommandFor` caches `SQL.Command` by key; `ExecScript` clears that pool.
- History table is always `_developer_table_migrations`. Register migrations with `Registerr`.
- Canonical suite: `src/Principal.bas` calls `TTablesTest.Setup`, then `StageMigrations`, `StageCodegen`, `StageDdl`, `StageRoutines`, `StageCrud`, `StageCompositePk`, `StageJoin`, `StageExecutor`, `StageRollback`, `StageLoad`, `StageDialect`, then `TTablesTest.Teardown`. Covers schema/codegen naming, DDL, routines, CRUD/upsert/merge, composite PK, JOIN `SelectOnly`, executor, migration rollback, load bench `_tables_bench`, and dialect SQL. There is no `RunAll`.
