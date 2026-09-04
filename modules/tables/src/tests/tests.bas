Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports TablesField
Imports TablesSchema
Imports TablesSql
Imports TablesTable
Imports TablesDdl
Imports TablesSequence
Imports TablesRoutine
Imports TablesExecutor
Imports TablesMigration
Imports TablesCodegen


' # Tables

' Core Data7 para mapear, persistir, migrar e gerar classes de tabela. Não contém as definições finais das tabelas de negócio — só o runtime e o gerador.

' ## Namespaces

' Cada módulo tem namespace próprio, prefixo `Tables`:

' | Arquivo | Namespace | Tipos |
' |---|---|---|
' | `src/core/TablesField.bas` | `TablesField` | `TField`, `TFieldDef`, `TFields`, `TFieldCache`, `TColumnInfo`, `TResource`, `TDdlOp` |
' | `src/core/TablesSchema.bas` | `TablesSchema` | `TTableSchema` |
' | `src/core/TablesSql.bas` | `TablesSql` | `TSql`, `TSqlDialect` (MSSQL, ASA, Postgres) |
' | `src/core/TablesTable.bas` | `TablesTable` | `TTable` |
' | `src/core/TablesDdl.bas` | `TablesDdl` | `TDdl` |
' | `src/core/TablesSequence.bas` | `TablesSequence` | `TSequence`, `TSequenceLease` |
' | `src/core/TablesRoutine.bas` | `TablesRoutine` | `TRoutine` |
' | `src/core/TablesExecutor.bas` | `TablesExecutor` | `TExecutor` |
' | `src/core/TablesMigration.bas` | `TablesMigration` | `TMigration`, `TMigrationRunner`, `TScriptMigration` |
' | `src/core/TablesCodegen.bas` | `TablesCodegen` | `TTableGenerator` |

' ```
' Imports TablesSchema
' Imports TablesTable
' ```

' ## Modelo

' `TTable` herda `TFields`. Cada instância copia as definições do schema (cache por nome de classe) e guarda valores em `TField` leves.

' ```
' Class TPedido
'    Inherits TTable

'    Sub New()
'       MyBase.New("TPedido")
'    End Sub

'    Overrides Sub DefineSchema(pSchema As TTableSchema)
'       pSchema.TableName = "Pedido"
'       pSchema.Field("CodPedido").AsInteger().AutoCodeField()
'       pSchema.Field("Titulo").AsString().MaxLen(150).RequiredField()
'       pSchema.Field("ValorTotal").AsFloat()
'       pSchema.Field("Ativo").AsBoolean().DefaultVal(True)
'    End Sub
' End Class
' ```

' Campo é encontrado por nome sem distinguir maiúsculas (`UCase`). Propriedades geradas preservam o case do catálogo (`CodPedido`, não `Codpedido`).

' Tipos: `String`, `Integer`, `Float`/`Numeric`, `Boolean`, `Date`, `DateTime`.

' Marcas úteis em `TFieldDef`: `PrimaryKeyField`, `AutoCodeField`, `RequiredField`, `NotUpdatable`, `SelectOnlyField`, `Expr`, `WithSequence`, `MaxLen`, `NumericPrec`.

' ## Persistência

' - `Insert` / `Update` / `Delete`
' - `Upsert` — update se a PK existir, senão insert
' - `Merge` — SQL MERGE (PK composta incluída no `ON`)
' - `Load` / `LoadWhere` / `Fetch(where, order, limit)`
' - `Exists` / `ExistsByPk`
' - `AssignFrom` / `Clone`
' - Hooks: `PrepareValue`, `Before*` / `After*` (insert, update, delete, merge, load)
' - AutoCode via `Data7.ProximoCodigo` (e `CodEmpresa` na PK quando existir)
' - Templates SQL e `SQL.Command` em cache por operação

' `FromClause` customizado permite JOIN; campos `SelectOnly` + `Expr` hidratam colunas calculadas sem persistir.

' ## SQL

' `TSql.Dialect()` escolhe MSSQL, SQL Anywhere ou Postgres. O dialeto gera `CREATE`/`ALTER`/`DROP`, quotes, `LIMIT`/`TOP`, routines e sequences.

' ## DDL, sequences e routines

' `TDdl` cria/remove tabela, coluna, rename, nullability e deriva ops a partir do schema (`OpsFromSchema` / `ApplyOps`).

' `TSequence` cria, peek, restart e `AllocateBlock`.

' `TRoutine` aplica view, procedure, function, trigger e índice.

' ## Executor

' `TExecutor` enfileira insert/update/delete/upsert/merge e SQL solto.

' Modos de commit: transação única, por batch, por statement, ou junta à transação já aberta. AutoCode no lote usa o mesmo `EnsurePrimaryKey` dos inserts individuais.

' ## Migrações

' `TMigrationRunner` registra migrações por id, aplica as pendentes, não reaplica, e faz `RollbackLast` / `RollbackTo`.

' Uma migração pode ser uma `TTable` (schema vira DDL), SQL cru (`TScriptMigration`) ou resources (view/procedure/function/index). Histórico em `_developer_table_migrations`.

' ## Gerador

' `TTableGenerator.Save(pasta, "Produto")` lê o catálogo (`DescribeColumns`) e grava uma subclasse de `TTable`.

' - Namespace gerado: snake do nome da tabela (`produto`, `dicionario_projeto`)
' - Classe: `T` + Pascal (`TProduto`, `TDicionarioProjeto`)
' - Propriedades: case original da coluna
' - Imports: `TablesSchema` e `TablesTable`

' ## Testes

' `src/tests/tests.bas` — `TTablesTest`, etapas no `Principal.bas`:

' Setup → Migrations → Codegen → Ddl → Routines → Crud → CompositePk → Join → Executor → Rollback → Load → Teardown

' O load cria a tabela temporária `_tables_bench` (16 colunas), mede alocação/CRUD e apaga a tabela no fim.


Namespace tests

   Private Dim _suite As TTablesTest

   Class TTestPedidoV1
      Inherits TTable

      Sub New()
         MyBase.New("TTestPedidoV1")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_pedido"
         pSchema.Sequence = "_libtest_pedido_seq"
         pSchema.Field("CodPedido").AsInteger().AutoCodeField().WithSequence("_libtest_pedido_seq")
         pSchema.Field("Codigo").AsString().MaxLen(20).RequiredField().NotUpdatable()
         pSchema.Field("Titulo").AsString().MaxLen(150).RequiredField()
         pSchema.Field("ValorTotal").AsFloat()
         pSchema.Field("Ativo").AsBoolean().DefaultVal(True)
         pSchema.Field("Status").AsString().MaxLen(20).DefaultVal("NOVO")
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TTestPedidoV1()
      End Function

      Overrides Function GetID() As String
         GetID = CStr(me.GetInteger("CodPedido"))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestPedido
      Inherits TTable

      AfterInsertRan As Boolean
      AfterLoadRan As Boolean

      Sub New()
         MyBase.New("TTestPedido")
         me.AfterInsertRan = False
         me.AfterLoadRan = False
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_pedido"
         pSchema.Sequence = "_libtest_pedido_seq"
         pSchema.Field("CodPedido").AsInteger().AutoCodeField().WithSequence("_libtest_pedido_seq")
         pSchema.Field("Codigo").AsString().MaxLen(20).RequiredField().NotUpdatable()
         pSchema.Field("Titulo").AsString().MaxLen(150).RequiredField()
         pSchema.Field("ValorTotal").AsFloat()
         pSchema.Field("Ativo").AsBoolean().DefaultVal(True)
         pSchema.Field("Status").AsString().MaxLen(20).DefaultVal("NOVO")
         pSchema.Field("Observacao").AsString().MaxLen(500)
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TTestPedido()
      End Function

      Overrides Sub PrepareValue(pOp As TTableOp, pField As TField)
         If pField.Def.Name = "Codigo" Then
            pField.Value = UCase(Trim(CStr(pField.EffectiveValue())))
         End If
      End Sub

      Overrides Sub AfterInsert()
         me.AfterInsertRan = True
      End Sub

      Overrides Sub AfterLoad()
         me.AfterLoadRan = True
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodPedido)
      End Function

      Property CodPedido As Integer
         Get
            CodPedido = me.GetInteger("CodPedido")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPedido", pValue)
         End Set
      End Property

      Property Codigo As String
         Get
            Codigo = me.GetString("Codigo")
         End Get
         Set(pValue As String)
            me.SetString("Codigo", pValue)
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

      Property ValorTotal As Extended
         Get
            ValorTotal = me.GetFloat("ValorTotal")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorTotal", pValue)
         End Set
      End Property

      Property Ativo As Boolean
         Get
            Ativo = me.GetBoolean("Ativo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("Ativo", pValue)
         End Set
      End Property

      Property Status As String
         Get
            Status = me.GetString("Status")
         End Get
         Set(pValue As String)
            me.SetString("Status", pValue)
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

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestItem
      Inherits TTable

      Sub New()
         MyBase.New("TTestItem")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_item"
         pSchema.Sequence = "_libtest_item_seq"
         pSchema.Field("CodItem").AsInteger().AutoCodeField().WithSequence("_libtest_item_seq")
         pSchema.Field("CodPedido").AsInteger().RequiredField()
         pSchema.Field("Item").AsString().MaxLen(3).RequiredField()
         pSchema.Field("Descricao").AsString().MaxLen(200)
         pSchema.Field("Quantidade").AsInteger().DefaultVal(1)
         pSchema.Field("Preco").AsFloat()
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TTestItem()
      End Function

      Overrides Sub PrepareValue(pOp As TTableOp, pField As TField)
         If pField.Def.Name = "Item" Then
            Dim raw As String = Trim(CStr(pField.EffectiveValue()))
            Dim padded As String = "000" & raw
            pField.Value = padded.Right(3)
         End If
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodItem)
      End Function

      Property CodItem As Integer
         Get
            CodItem = me.GetInteger("CodItem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodItem", pValue)
         End Set
      End Property

      Property CodPedido As Integer
         Get
            CodPedido = me.GetInteger("CodPedido")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPedido", pValue)
         End Set
      End Property

      Property Item As String
         Get
            Item = me.GetString("Item")
         End Get
         Set(pValue As String)
            me.SetString("Item", pValue)
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

      Property Quantidade As Integer
         Get
            Quantidade = me.GetInteger("Quantidade")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Quantidade", pValue)
         End Set
      End Property

      Property Preco As Extended
         Get
            Preco = me.GetFloat("Preco")
         End Get
         Set(pValue As Extended)
            me.SetFloat("Preco", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestItemComPedido
      Inherits TTable

      Sub New()
         MyBase.New("TTestItemComPedido")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         pSchema.TableName = "_libtest_item"
         pSchema.FromClause = sqlDialect.QuoteIdent("_libtest_item") & " I JOIN " & sqlDialect.QuoteIdent("_libtest_pedido") & " P ON P." & sqlDialect.QuoteIdent("CodPedido") & " = I." & sqlDialect.QuoteIdent("CodPedido")
         pSchema.Field("CodItem").AsInteger().PrimaryKeyField().Expr("I." & sqlDialect.QuoteIdent("CodItem"))
         pSchema.Field("CodPedido").AsInteger().Expr("I." & sqlDialect.QuoteIdent("CodPedido"))
         pSchema.Field("Item").AsString().MaxLen(3).Expr("I." & sqlDialect.QuoteIdent("Item"))
         pSchema.Field("Descricao").AsString().MaxLen(200).Expr("I." & sqlDialect.QuoteIdent("Descricao"))
         pSchema.Field("Quantidade").AsInteger().Expr("I." & sqlDialect.QuoteIdent("Quantidade"))
         pSchema.Field("Preco").AsFloat().Expr("I." & sqlDialect.QuoteIdent("Preco"))
         pSchema.Field("TituloPedido").AsString().SelectOnlyField().Expr("P." & sqlDialect.QuoteIdent("Titulo"))
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TTestItemComPedido()
      End Function

      Overrides Function GetID() As String
         GetID = CStr(me.GetInteger("CodItem"))
      End Function

      Property TituloPedido As String
         Get
            TituloPedido = me.GetString("TituloPedido")
         End Get
         Set(pValue As String)
            me.SetString("TituloPedido", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestVenda
      Inherits TTable

      Sub New()
         MyBase.New("TTestVenda")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_venda"
         pSchema.Field("CodEmpresa").AsInteger().PrimaryKeyField()
         pSchema.Field("CodVenda").AsInteger().AutoCodeField()
         pSchema.Field("Titulo").AsString().MaxLen(80).RequiredField()
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TTestVenda()
      End Function

      Overrides Function GetID() As String
         GetID = CStr(me.CodEmpresa) & "|" & CStr(me.CodVenda)
      End Function

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("CodEmpresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEmpresa", pValue)
         End Set
      End Property

      Property CodVenda As Integer
         Get
            CodVenda = me.GetInteger("CodVenda")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodVenda", pValue)
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

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestVendaItem
      Inherits TTable

      Sub New()
         MyBase.New("TTestVendaItem")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_venda_item"
         pSchema.Field("CodEmpresa").AsInteger().PrimaryKeyField()
         pSchema.Field("CodVenda").AsInteger().PrimaryKeyField()
         pSchema.Field("Item").AsString().MaxLen(3).PrimaryKeyField()
         pSchema.Field("Descricao").AsString().MaxLen(80)
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TTestVendaItem()
      End Function

      Overrides Function GetID() As String
         GetID = CStr(me.CodEmpresa) & "|" & CStr(me.CodVenda) & "|" & me.Item
      End Function

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("CodEmpresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEmpresa", pValue)
         End Set
      End Property

      Property CodVenda As Integer
         Get
            CodVenda = me.GetInteger("CodVenda")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodVenda", pValue)
         End Set
      End Property

      Property Item As String
         Get
            Item = me.GetString("Item")
         End Get
         Set(pValue As String)
            me.SetString("Item", pValue)
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

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TBench
      Inherits TTable

      Sub New()
         MyBase.New("TBench")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_tables_bench"
         pSchema.Sequence = "_tables_bench_seq"
         pSchema.Field("CodBench").AsInteger().AutoCodeField().WithSequence("_tables_bench_seq")
         pSchema.Field("Nome").AsString().MaxLen(80).RequiredField()
         pSchema.Field("Codigo").AsString().MaxLen(20)
         pSchema.Field("Grupo").AsInteger()
         pSchema.Field("Ativo").AsBoolean().DefaultVal(True)
         pSchema.Field("Preco").AsFloat()
         pSchema.Field("Qtde").AsInteger()
         pSchema.Field("Descricao").AsString().MaxLen(200)
         pSchema.Field("Status").AsString().MaxLen(20)
         pSchema.Field("Observacao").AsString().MaxLen(200)
         pSchema.Field("DataCadastro").AsDateTime()
         pSchema.Field("Valor1").AsFloat()
         pSchema.Field("Valor2").AsFloat()
         pSchema.Field("Valor3").AsFloat()
         pSchema.Field("FlagExtra").AsBoolean()
         pSchema.Field("Referencia").AsString().MaxLen(40)
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TBench()
      End Function

      Overrides Function GetID() As String
         GetID = CStr(me.CodBench)
      End Function

      Property CodBench As Integer
         Get
            CodBench = me.GetInteger("CodBench")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodBench", pValue)
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

      Property Codigo As String
         Get
            Codigo = me.GetString("Codigo")
         End Get
         Set(pValue As String)
            me.SetString("Codigo", pValue)
         End Set
      End Property

      Property Grupo As Integer
         Get
            Grupo = me.GetInteger("Grupo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Grupo", pValue)
         End Set
      End Property

      Property Ativo As Boolean
         Get
            Ativo = me.GetBoolean("Ativo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("Ativo", pValue)
         End Set
      End Property

      Property Preco As Extended
         Get
            Preco = me.GetFloat("Preco")
         End Get
         Set(pValue As Extended)
            me.SetFloat("Preco", pValue)
         End Set
      End Property

      Property Qtde As Integer
         Get
            Qtde = me.GetInteger("Qtde")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Qtde", pValue)
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

      Property Status As String
         Get
            Status = me.GetString("Status")
         End Get
         Set(pValue As String)
            me.SetString("Status", pValue)
         End Set
      End Property

      Property Referencia As String
         Get
            Referencia = me.GetString("Referencia")
         End Get
         Set(pValue As String)
            me.SetString("Referencia", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTablesTest
      Inherits TTObject

      Passed As Integer
      Failed As Integer
      StampSeq As Integer

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me.StampSeq = 0
      End Sub

      Shared Function Suite() As TTablesTest
         If Not Assigned(_suite) Then
            _suite = New TTablesTest()
         End If
         Suite = _suite
      End Function

      Shared Sub Setup()
         TTablesTest.Suite().DoSetup()
      End Sub

      Shared Sub StageMigrations()
         TTablesTest.Suite().DoMigrations()
      End Sub

      Shared Sub StageCodegen()
         TTablesTest.Suite().DoCodegen()
      End Sub

      Shared Sub StageDdl()
         TTablesTest.Suite().DoDdl()
      End Sub

      Shared Sub StageRoutines()
         TTablesTest.Suite().DoRoutines()
      End Sub

      Shared Sub StageCrud()
         TTablesTest.Suite().DoCrud()
      End Sub

      Shared Sub StageCompositePk()
         TTablesTest.Suite().DoCompositePk()
      End Sub

      Shared Sub StageJoin()
         TTablesTest.Suite().DoJoin()
      End Sub

      Shared Sub StageExecutor()
         TTablesTest.Suite().DoExecutor()
      End Sub

      Shared Sub StageRollback()
         TTablesTest.Suite().DoRollback()
      End Sub

      Shared Sub StageLoad()
         TTablesTest.Suite().DoLoad()
      End Sub

      Shared Sub Teardown()
         If Assigned(_suite) Then
            _suite.DoTeardown()
            _suite.Free()
            _suite = Null
         End If
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            console.log("OK  " & pMsg)
         Else
            me.Failed = me.Failed + 1
            console.log("FAIL  " & pMsg)
            Throw New Exception("FAIL: " & pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg & " (obtido=[" & pGot & "] esperado=[" & pWant & "])")
      End Sub

      Sub AssertEqInt(pGot As Integer, pWant As Integer, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg & " (obtido=" & CStr(pGot) & " esperado=" & CStr(pWant) & ")")
      End Sub

      Function QuoteName(pName As String) As String
         QuoteName = TSql.Dialect().QuoteIdent(pName)
      End Function

      Function NewRunner() As TMigrationRunner
         Dim runner As New TMigrationRunner()
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         Dim migPedido As New TMigration("libtest_01_pedido", New TTestPedidoV1())
         runner.Registerr(migPedido)
         runner.Registerr(New TMigration("libtest_02_item", New TTestItem()))
         runner.Registerr(New TMigration("libtest_03_pedido_observacao", New TTestPedido()))
         Dim migRoutines As New TMigration("libtest_04_routines")
         Dim viewSelect As String = "SELECT " & sqlDialect.QuoteIdent("CodPedido") & ", " & sqlDialect.QuoteIdent("Titulo") & ", " & sqlDialect.QuoteIdent("Status") & " FROM " & sqlDialect.QuoteIdent("_libtest_pedido")
         migRoutines.Resources.Push("vw", New TResource(TResourceKind.View(), "_libtest_vw_pedido", sqlDialect.SqlCreateOrReplaceView("_libtest_vw_pedido", viewSelect)))
         migRoutines.Resources.Push("sp", New TResource(TResourceKind.Procedure(), "_libtest_sp_ping", sqlDialect.SqlCreateOrReplaceProcedure("_libtest_sp_ping")))
         migRoutines.Resources.Push("fn", New TResource(TResourceKind.Func(), "_libtest_fn_double", sqlDialect.SqlCreateOrReplaceIntFunction("_libtest_fn_double")))
         runner.Registerr(migRoutines)
         Dim createAudit As String = "CREATE TABLE " & sqlDialect.QuoteIdent("_libtest_audit") & " (" & sqlDialect.QuoteIdent("Id") & " INTEGER NOT NULL PRIMARY KEY, " & sqlDialect.QuoteIdent("Nota") & " VARCHAR(100))"
         Dim migAudit As New TScriptMigration("libtest_05_audit", createAudit)
         migAudit.RawSqlDown = sqlDialect.SqlDropTable("_libtest_audit")
         runner.Registerr(migAudit)
         Dim migIndex As New TScriptMigration("libtest_06_index", sqlDialect.SqlCreateIndexOnTable("IX_libtest_pedido_status", "_libtest_pedido", "Status"))
         migIndex.RawSqlDown = sqlDialect.SqlDropIndexOnTable("IX_libtest_pedido_status", "_libtest_pedido")
         runner.Registerr(migIndex)
         NewRunner = runner
      End Function

      Sub Cleanup()
         console.timeStart("cleanup")
         Dim ddl As New TDdl()
         Dim routine As New TRoutine()
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         routine.DropIndexOnTable("IX_libtest_pedido_status", "_libtest_pedido")
         routine.Drop(TResourceKind.View(), "_libtest_vw_pedido")
         routine.Drop(TResourceKind.Procedure(), "_libtest_sp_ping")
         routine.Drop(TResourceKind.Func(), "_libtest_fn_double")
         ddl.DropTable("_libtest_audit")
         ddl.DropTable("_libtest_venda_item")
         ddl.DropTable("_libtest_venda")
         ddl.DropTable("_libtest_item")
         ddl.DropTable("_libtest_pedido")
         ddl.DropTable("_tables_bench")
         ddl.DropSequence("_libtest_item_seq")
         ddl.DropSequence("_libtest_pedido_seq")
         ddl.DropSequence("_tables_bench_seq")
         If ddl.TableExists("_developer_table_migrations") Then
            TSql.ExecScript("DELETE FROM " & sqlDialect.QuoteIdent("_developer_table_migrations") & " WHERE " & sqlDialect.QuoteIdent("Id") & " LIKE 'libtest_%'")
         End If
         routine.Free()
         ddl.Free()
         console.timeEnd("cleanup")
      End Sub

      Sub DoSetup()
         console.timeStart("suite")
         me.Passed = 0
         me.Failed = 0
         me.StampSeq = 0
         me.Cleanup()
      End Sub

      Sub DoTeardown()
         me.Cleanup()
         console.timeEnd("suite")
         console.log("Resultado: " & CStr(me.Passed) & " ok, " & CStr(me.Failed) & " falhas")
         If me.Failed > 0 Then
            Throw New Exception("Suíte de testes falhou: " & CStr(me.Failed) & " asserção(ões)")
         End If
      End Sub

      Sub DoMigrations()
         console.timeStart("migrations")
         Dim runner As TMigrationRunner = me.NewRunner()
         Dim applied As Integer = runner.Execute()
         me.AssertEqInt(applied, 6, "Execute aplica 6 migrações novas")
         Dim ddl As New TDdl()
         Dim routine As New TRoutine()
         me.AssertTrue(ddl.TableExists("_libtest_pedido"), "Tabela _libtest_pedido criada")
         me.AssertTrue(ddl.TableExists("_libtest_item"), "Tabela _libtest_item criada")
         me.AssertTrue(ddl.ColumnExists("_libtest_pedido", "Observacao"), "Coluna Observacao adicionada na v3")
         me.AssertTrue(ddl.SequenceExists("_libtest_pedido_seq"), "Sequence do pedido")
         me.AssertTrue(ddl.SequenceExists("_libtest_item_seq"), "Sequence do item")
         me.AssertTrue(ddl.TableExists("_libtest_audit"), "Tabela _libtest_audit via RawSql")
         me.AssertTrue(routine.Exists(TResourceKind.Index(), "IX_libtest_pedido_status"), "Índice IX_libtest_pedido_status")
         Dim again As TMigrationRunner = me.NewRunner()
         me.AssertEqInt(again.Execute(), 0, "Segunda Execute não reaplica migrações")
         again.Free()
         routine.Free()
         ddl.Free()
         runner.Free()
         console.timeEnd("migrations")
      End Sub

      Sub DoCodegen()
         console.timeStart("codegen")
         Dim gen As New TTableGenerator()
         Dim body As String = gen.Build("_libtest_pedido")
         me.AssertTrue(body.IndexOf("Namespace libtest_pedido") >= 0, "Namespace libtest_pedido")
         me.AssertTrue(body.IndexOf("Class TLibtestPedido") >= 0, "Classe TLibtestPedido")
         me.AssertTrue(body.IndexOf("Inherits TTable") >= 0, "Herda TTable")
         me.AssertTrue(body.IndexOf("Imports TablesSchema") >= 0, "Imports TablesSchema")
         me.AssertTrue(body.IndexOf("Imports TablesTable") >= 0, "Imports TablesTable")
         me.AssertTrue(body.IndexOf("pSchema.TableName = ""_libtest_pedido""") >= 0, "TableName no DefineSchema")
         me.AssertTrue(body.IndexOf("pSchema.Field(""CodPedido"").AsInteger().AutoCodeField()") >= 0, "Campo CodPedido AutoCode")
         me.AssertTrue(body.IndexOf("Property CodPedido As Integer") >= 0, "Property CodPedido")
         me.AssertTrue(body.IndexOf("Property Titulo As String") >= 0, "Property Titulo")
         me.AssertEq(gen.PropertyNameOf("CodProduto", "TProduto"), "CodProduto", "Prop preserva CodProduto")
         me.AssertEq(gen.PropertyNameOf("codproduto", "TProduto"), "codproduto", "Prop preserva codproduto")
         me.AssertEq(gen.PropertyNameOf("frentecaixa_disponivelpesquisa", "TProduto"), "frentecaixa_disponivelpesquisa", "Prop preserva underscore e case")
         me.AssertEq(gen.PropertyNameOf("CodPedido", "TLibtestPedido"), "CodPedido", "Prop CodPedido inalterada")
         me.AssertEq(gen.PropertyNameOf("Field", "TProduto"), "CField", "Prop reserva Field")
         me.AssertEq(gen.PropertyNameOf("2Preco", "TProduto"), "C2Preco", "Prop prefixa dígito inicial")
         me.AssertEq(gen.PropertyNameOf("TProduto", "TProduto"), "TProdutoCol", "Prop não colide com o nome da classe")
         me.AssertEq(gen.NamespaceName("", "Produto"), "produto", "Namespace dbo/default Produto")
         me.AssertEq(gen.ClassNameOf("", "Produto"), "TProduto", "Classe TProduto")
         me.AssertEq(gen.NamespaceName("Dicionario", "Projeto"), "dicionario_projeto", "Namespace schema não default")
         me.AssertEq(gen.ClassNameOf("Dicionario", "Projeto"), "TDicionarioProjeto", "Classe TDicionarioProjeto")
         me.AssertEq(TSql.ProximoCodigoKey("", "Produto"), "Produto", "ProximoCodigo dbo.Produto")
         me.AssertEq(TSql.ProximoCodigoKey("Financeiro", "ContaReceber"), "Financeiro.ContaReceber", "ProximoCodigo Financeiro.ContaReceber")
         me.AssertEq(TSql.StandardSequenceName("", "GrupoItemContabil", False, 0), "GrupoItemContabil_Sequencia", "Sequence GrupoItemContabil")
         me.AssertEq(TSql.StandardSequenceName("", "TeleCobranca", True, 2), "TeleCobranca_Sequencia_2", "Sequence TeleCobranca empresa 2")
         me.AssertEq(TSql.StandardSequenceName("Financeiro", "ContratoBancarioCobranca", True, 1), "Financeiro_ContratoBancarioCobranca_Sequencia_1", "Sequence Financeiro empresa 1")
         Dim sch As New TTableSchema()
         sch.TableName = "Venda"
         me.AssertEq(TSql.ExplicitSequenceName(sch), "", "Sequence explícita vazia")
         me.AssertEq(TSql.ResolvedSequenceName(sch, True, 3), "Venda_Sequencia_3", "Sequence padrão com empresa")
         sch.SchemaName = "Replicacao"
         me.AssertEq(TSql.ResolvedSequenceName(sch, True, 2), "Replicacao_Venda_Sequencia_2", "Sequence padrão Replicacao com empresa")
         sch.Sequence = "_libtest_pedido_seq"
         me.AssertEq(TSql.ResolvedSequenceName(sch, True, 2), "_libtest_pedido_seq", "Sequence explícita prevalece")
         sch.Free()
         Dim empCol As New TColumnInfo()
         empCol.Name = "CodEmpresa"
         empCol.NativeType = "INT"
         empCol.PrimaryKey = True
         Dim vendaCol As New TColumnInfo()
         vendaCol.Name = "CodVenda"
         vendaCol.NativeType = "INT"
         vendaCol.PrimaryKey = True
         Dim tituloCol As New TColumnInfo()
         tituloCol.Name = "Titulo"
         tituloCol.NativeType = "VARCHAR"
         Dim pk2[] As TColumnInfo = []
         pk2.Push("CodEmpresa", empCol)
         pk2.Push("CodVenda", vendaCol)
         pk2.Push("Titulo", tituloCol)
         me.AssertTrue(Not gen.IsAutoCode(empCol, TKindField.IntegerKind(), pk2), "CodEmpresa não é AutoCode")
         me.AssertTrue(gen.IsAutoCode(vendaCol, TKindField.IntegerKind(), pk2), "CodVenda é AutoCode na PK CodEmpresa+ID")
         me.AssertEq(gen.GetIdBody(pk2, "TVenda"), "GetID = CStr(me.CodEmpresa) & ""|"" & CStr(me.CodVenda)", "GetID composto CodEmpresa+CodVenda")
         Dim itemCol As New TColumnInfo()
         itemCol.Name = "Item"
         itemCol.NativeType = "VARCHAR"
         itemCol.PrimaryKey = True
         Dim pk3[] As TColumnInfo = []
         pk3.Push("CodEmpresa", empCol)
         pk3.Push("CodVenda", vendaCol)
         pk3.Push("Item", itemCol)
         me.AssertTrue(Not gen.IsAutoCode(vendaCol, TKindField.IntegerKind(), pk3), "PK 3 campos: CodVenda não é AutoCode automático")
         Dim numDef As New TFieldDef("Preco")
         numDef.AsNumeric(15, 2)
         me.AssertEq(TSql.Dialect().TypeName(numDef), "NUMERIC(15, 2)", "TypeName NUMERIC(15, 2)")
         Dim numCol As New TColumnInfo()
         numCol.Name = "Preco"
         numCol.NativeType = "numeric"
         numCol.Precision = 15
         numCol.Scale = 2
         me.AssertTrue(gen.FieldLine(numCol, TKindField.FloatKind(), False).IndexOf(".NumericPrec(15, 2)") >= 0, "Codegen emite NumericPrec")
         numDef.Free()
         numCol.Free()
         pk2.OwnsObjects = False
         pk2.Free()
         pk3.OwnsObjects = False
         pk3.Free()
         empCol.Free()
         vendaCol.Free()
         tituloCol.Free()
         itemCol.Free()
         gen.Free()
         console.timeEnd("codegen")
      End Sub

      Sub DoDdl()
         console.timeStart("ddl")
         Dim ddl As New TDdl()
         Dim extra As New TFieldDef("TmpTag")
         extra.AsString().MaxLen(40)
         ddl.AddColumn("_libtest_pedido", extra)
         me.AssertTrue(ddl.ColumnExists("_libtest_pedido", "TmpTag"), "AddColumn TmpTag")
         ddl.RenameColumn("_libtest_pedido", "TmpTag", "TmpTag2")
         me.AssertTrue(ddl.ColumnExists("_libtest_pedido", "TmpTag2"), "RenameColumn TmpTag -> TmpTag2")
         me.AssertTrue(Not ddl.ColumnExists("_libtest_pedido", "TmpTag"), "Nome antigo TmpTag sumiu")
         ddl.DropColumn("_libtest_pedido", "TmpTag2")
         me.AssertTrue(Not ddl.ColumnExists("_libtest_pedido", "TmpTag2"), "DropColumn TmpTag2")
         extra.Free()
         ddl.Free()
         console.timeEnd("ddl")
      End Sub

      Sub DoRoutines()
         console.timeStart("routines")
         Dim routine As New TRoutine()
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         me.AssertTrue(routine.Exists(TResourceKind.View(), "_libtest_vw_pedido"), "View existe")
         me.AssertTrue(routine.Exists(TResourceKind.Procedure(), "_libtest_sp_ping"), "Procedure existe")
         me.AssertTrue(routine.Exists(TResourceKind.Func(), "_libtest_fn_double"), "Function existe")
         Dim doubled As String = TSql.ExecSelect(sqlDialect.SqlCallIntFunction("_libtest_fn_double", 21))
         me.AssertEq(Trim(doubled), "42", "Function _libtest_fn_double(21)")
         Dim viewCount As String = TSql.ExecSelect("(SELECT COUNT(*) FROM " & sqlDialect.QuoteIdent("_libtest_vw_pedido") & ")")
         me.AssertTrue(Trim(viewCount) <> "", "SELECT na view _libtest_vw_pedido")
         routine.Free()
         console.timeEnd("routines")
      End Sub

      Sub DoCrud()
         console.timeStart("crud")
         Dim row As New TTestPedido()
         row.CodPedido = 1001
         row.Codigo = "abc-1"
         row.Titulo = "Pedido Alfa"
         row.ValorTotal = 10.5
         row.Ativo = True
         row.Status = "ABERTO"
         row.Observacao = "obs inicial"
         Dim inserted As Integer = row.Insert()
         me.AssertTrue(inserted >= 0, "Insert pedido")
         me.AssertTrue(row.AfterInsertRan, "Hook AfterInsert")
         me.AssertEq(row.Codigo, "ABC-1", "PrepareValue upper no Codigo")
         me.AssertTrue(row.ExistsByPk(), "ExistsByPk após insert")
         me.AssertTrue(row.Exists(me.QuoteName("Titulo") & " = 'Pedido Alfa'"), "Exists por WHERE")

         Dim loaded As New TTestPedido()
         loaded.CodPedido = 1001
         me.AssertTrue(loaded.Load(me.QuoteName("CodPedido") & " = 1001"), "Load pedido 1001")
         me.AssertTrue(loaded.AfterLoadRan, "Hook AfterLoad")
         me.AssertEq(loaded.Titulo, "Pedido Alfa", "Titulo hidratado")
         me.AssertEq(loaded.Observacao, "obs inicial", "Observacao hidratada")

         loaded.Titulo = "Pedido Alfa Edit"
         loaded.ValorTotal = 99
         loaded.Update()
         Dim again As New TTestPedido()
         again.Load(me.QuoteName("CodPedido") & " = 1001")
         me.AssertEq(again.Titulo, "Pedido Alfa Edit", "Update persistiu Titulo")

         Dim copied As TTestPedido = TTestPedido(again.Clone())
         me.AssertEq(copied.Titulo, again.Titulo, "Clone copia Titulo")
         copied.Free()

         Dim probe As New TTestPedido()
         Dim rows[] As TTable = probe.Fetch(me.QuoteName("CodPedido") & " = 1001", me.QuoteName("CodPedido"))
         me.AssertEqInt(rows.Length, 1, "Fetch devolve 1 pedido")
         rows.OwnsObjects = True
         rows.Free()
         probe.Free()

         Dim upsertRow As New TTestPedido()
         upsertRow.CodPedido = 1001
         upsertRow.Codigo = "ABC-1"
         upsertRow.Titulo = "Pedido Upsert"
         upsertRow.ValorTotal = 1
         upsertRow.Ativo = False
         upsertRow.Status = "FECHADO"
         upsertRow.Observacao = "via upsert"
         upsertRow.Upsert()
         again.Load(me.QuoteName("CodPedido") & " = 1001")
         me.AssertEq(again.Titulo, "Pedido Upsert", "Upsert atualiza existente")
         upsertRow.Free()

         Dim novo As New TTestPedido()
         novo.CodPedido = 1002
         novo.Codigo = "n2"
         novo.Titulo = "Novo via Upsert"
         novo.Status = "NOVO"
         novo.Upsert()
         me.AssertTrue(novo.ExistsByPk(), "Upsert insere quando não existe")
         novo.Delete()
         me.AssertTrue(Not novo.ExistsByPk(), "Delete remove 1002")
         novo.Free()

         Dim merged As New TTestPedido()
         merged.CodPedido = 1003
         merged.Codigo = "n3"
         merged.Titulo = "Via Merge"
         merged.Status = "NOVO"
         merged.Merge()
         me.AssertTrue(merged.ExistsByPk(), "Merge insere quando não existe")
         merged.Titulo = "Via Merge Edit"
         merged.Codigo = "xx"
         merged.Merge()
         Dim mergedLoad As New TTestPedido()
         mergedLoad.CodPedido = 1003
         mergedLoad.Load(me.QuoteName("CodPedido") & " = 1003")
         me.AssertEq(mergedLoad.Titulo, "Via Merge Edit", "Merge atualiza existente")
         me.AssertEq(mergedLoad.Codigo, "N3", "Merge não altera coluna NotUpdatable")
         merged.Delete()
         me.AssertTrue(Not merged.ExistsByPk(), "Delete remove 1003")
         mergedLoad.Free()
         merged.Free()

         Dim line As New TTestItem()
         line.CodItem = 2001
         line.CodPedido = 1001
         line.Item = "7"
         line.Descricao = "Peça"
         line.Quantidade = 3
         line.Preco = 2.5
         line.Insert()
         me.AssertEq(line.Item, "007", "PrepareValue pad Item para 3 chars")
         Dim loadedItem As New TTestItem()
         loadedItem.Load(me.QuoteName("CodItem") & " = 2001")
         me.AssertEq(loadedItem.Descricao, "Peça", "Item hidratado")
         me.AssertEqInt(loadedItem.CodPedido, 1001, "FK CodPedido")
         loadedItem.Quantidade = 8
         loadedItem.Update()
         Dim againItem As New TTestItem()
         againItem.Load(me.QuoteName("CodItem") & " = 2001")
         me.AssertEqInt(againItem.Quantidade, 8, "Update quantidade")
         againItem.Free()
         loadedItem.Free()
         line.Free()
         again.Free()
         loaded.Free()
         row.Free()
         console.timeEnd("crud")
      End Sub

      Sub DoCompositePk()
         console.timeStart("composite-pk")
         Dim ddl As New TDdl()
         ddl.DropTable("_libtest_venda_item")
         ddl.DropTable("_libtest_venda")
         Dim vendaProbe As New TTestVenda()
         Dim vendaOps[] As TDdlOp = ddl.OpsFromSchema(vendaProbe.Schema)
         ddl.ApplyOps(vendaOps)
         vendaOps.OwnsObjects = True
         vendaOps.Free()
         Dim itemProbe As New TTestVendaItem()
         Dim itemOps[] As TDdlOp = ddl.OpsFromSchema(itemProbe.Schema)
         ddl.ApplyOps(itemOps)
         itemOps.OwnsObjects = True
         itemOps.Free()

         Dim updSql As String = vendaProbe.GetCommandText(TTableOp.OpUpdate())
         Dim delSql As String = vendaProbe.GetCommandText(TTableOp.OpDelete())
         Dim merSql As String = vendaProbe.GetCommandText(TTableOp.OpMerge())
         me.AssertTrue(updSql.IndexOf("CodEmpresa") >= 0, "Update PK inclui CodEmpresa")
         me.AssertTrue(updSql.IndexOf("CodVenda") >= 0, "Update PK inclui CodVenda")
         me.AssertTrue(updSql.IndexOf(" AND ") >= 0, "Update WHERE composto")
         me.AssertTrue(delSql.IndexOf("CodEmpresa") >= 0, "Delete PK inclui CodEmpresa")
         me.AssertTrue(merSql.IndexOf("CodEmpresa") >= 0, "Merge PK inclui CodEmpresa")

         Dim a As New TTestVenda()
         a.CodEmpresa = 1
         a.CodVenda = 10
         a.Titulo = "Emp1"
         me.AssertTrue(Not a.NeedsAutoCode(), "ID informado não pede AutoCode")
         a.Insert()
         Dim b As New TTestVenda()
         b.CodEmpresa = 2
         b.CodVenda = 10
         b.Titulo = "Emp2"
         b.Insert()
         a.Titulo = "Emp1-edit"
         a.Update()
         Dim loadB As New TTestVenda()
         loadB.CodEmpresa = 2
         loadB.CodVenda = 10
         me.AssertTrue(loadB.Load(me.QuoteName("CodEmpresa") & " = 2 AND " & me.QuoteName("CodVenda") & " = 10"), "Load venda empresa 2")
         me.AssertEq(loadB.Titulo, "Emp2", "Update da empresa 1 não altera empresa 2")
         a.Delete()
         me.AssertTrue(Not a.ExistsByPk(), "Delete remove só empresa 1")
         me.AssertTrue(loadB.ExistsByPk(), "Empresa 2 permanece após delete da 1")
         loadB.Titulo = "Emp2-upsert"
         loadB.Upsert()
         loadB.Titulo = "Emp2-merge"
         loadB.Merge()
         Dim loadB2 As New TTestVenda()
         loadB2.CodEmpresa = 2
         loadB2.CodVenda = 10
         loadB2.Load(me.QuoteName("CodEmpresa") & " = 2 AND " & me.QuoteName("CodVenda") & " = 10")
         me.AssertEq(loadB2.Titulo, "Emp2-merge", "Merge atualiza PK composta")

         Dim lineA As New TTestVendaItem()
         lineA.CodEmpresa = 1
         lineA.CodVenda = 10
         lineA.Item = "001"
         lineA.Descricao = "A"
         lineA.Insert()
         Dim lineB As New TTestVendaItem()
         lineB.CodEmpresa = 2
         lineB.CodVenda = 10
         lineB.Item = "001"
         lineB.Descricao = "B"
         lineB.Insert()
         lineA.Descricao = "A-edit"
         lineA.Update()
         Dim loadLineB As New TTestVendaItem()
         loadLineB.CodEmpresa = 2
         loadLineB.CodVenda = 10
         loadLineB.Item = "001"
         loadLineB.Load(me.QuoteName("CodEmpresa") & " = 2 AND " & me.QuoteName("CodVenda") & " = 10 AND " & me.QuoteName("Item") & " = '001'")
         me.AssertEq(loadLineB.Descricao, "B", "Update PK 3 campos não vaza para outra empresa")
         lineA.Delete()
         me.AssertTrue(Not lineA.ExistsByPk(), "Delete item empresa 1")
         me.AssertTrue(loadLineB.ExistsByPk(), "Item empresa 2 permanece")

         ddl.DropTable("_libtest_venda_item")
         ddl.DropTable("_libtest_venda")
         loadLineB.Free()
         lineB.Free()
         lineA.Free()
         loadB2.Free()
         loadB.Free()
         b.Free()
         a.Free()
         itemProbe.Free()
         vendaProbe.Free()
         ddl.Free()
         console.timeEnd("composite-pk")
      End Sub

      Sub DoJoin()
         console.timeStart("schema-join")
         Dim probe As New TTestItemComPedido()
         Dim rows[] As TTable = probe.Fetch("I." & me.QuoteName("CodItem") & " = 2001", "I." & me.QuoteName("CodItem"))
         me.AssertEqInt(rows.Length, 1, "Fetch com JOIN FromClause")
         Dim joined As TTestItemComPedido = TTestItemComPedido(rows.Take(0))
         me.AssertEq(joined.TituloPedido, "Pedido Upsert", "SelectOnly Expr P.Titulo")
         rows.OwnsObjects = True
         rows.Free()
         probe.Free()
         console.timeEnd("schema-join")
      End Sub

      Sub DoExecutor()
         console.timeStart("executor")
         Dim a As New TTestPedido()
         a.CodPedido = 1101
         a.Codigo = "ex-a"
         a.Titulo = "Lote A"
         a.Status = "NOVO"
         Dim b As New TTestPedido()
         b.CodPedido = 1102
         b.Codigo = "ex-b"
         b.Titulo = "Lote B"
         b.Status = "NOVO"
         Dim db As New TExecutor()
         db.CommitMode = TCommitMode.SingleTransaction()
         db.AddInsert(a)
         db.AddInsert(b)
         Dim n As Integer = db.Exec()
         me.AssertTrue(n >= 2, "Executor Insert em lote")
         Dim chk As New TTestPedido()
         me.AssertTrue(chk.Exists(me.QuoteName("CodPedido") & " = 1101"), "Lote A persistido")
         me.AssertTrue(chk.Exists(me.QuoteName("CodPedido") & " = 1102"), "Lote B persistido")
         db.Clear()
         chk.CodPedido = 1101
         chk.Load(me.QuoteName("CodPedido") & " = 1101")
         chk.Titulo = "Lote A upd"
         db.AddUpdate(chk)
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         db.AddSql("UPDATE " & sqlDialect.QuoteIdent("_libtest_pedido") & " SET " & sqlDialect.QuoteIdent("Status") & " = 'LOTE' WHERE " & sqlDialect.QuoteIdent("CodPedido") & " = 1102")
         db.Exec()
         Dim chk2 As New TTestPedido()
         chk2.Load(me.QuoteName("CodPedido") & " = 1102")
         me.AssertEq(chk2.Status, "LOTE", "AddSql no executor")
         db.Clear()
         db.AddDelete(chk)
         db.AddDelete(chk2)
         db.Exec()
         me.AssertTrue(Not chk.Exists(me.QuoteName("CodPedido") & " IN (1101, 1102)"), "Executor Delete em lote")
         chk2.Free()
         chk.Free()
         db.Free()
         a.Free()
         b.Free()
         console.timeEnd("executor")
      End Sub

      Sub DoRollback()
         console.timeStart("rollback")
         Dim runner As TMigrationRunner = me.NewRunner()
         runner.Execute()
         Dim ddl As New TDdl()
         Dim routine As New TRoutine()
         runner.RollbackLast()
         me.AssertTrue(Not routine.Exists(TResourceKind.Index(), "IX_libtest_pedido_status"), "RollbackLast remove o índice")
         me.AssertTrue(ddl.TableExists("_libtest_audit"), "Audit permanece após RollbackLast do índice")
         Dim n1 As Integer = runner.Execute()
         me.AssertEqInt(n1, 1, "Reaplica só libtest_06")
         me.AssertTrue(routine.Exists(TResourceKind.Index(), "IX_libtest_pedido_status"), "Índice recriado")
         runner.RollbackTo("libtest_03_pedido_observacao")
         me.AssertTrue(Not routine.Exists(TResourceKind.View(), "_libtest_vw_pedido"), "RollbackTo remove view")
         me.AssertTrue(Not ddl.TableExists("_libtest_audit"), "RollbackTo remove audit")
         me.AssertTrue(ddl.TableExists("_libtest_pedido"), "Pedido permanece após RollbackTo 03")
         Dim n2 As Integer = runner.Execute()
         me.AssertEqInt(n2, 3, "Reaplica routines + audit + index")
         me.AssertTrue(routine.Exists(TResourceKind.View(), "_libtest_vw_pedido"), "View recriada")
         routine.Free()
         ddl.Free()
         runner.Free()
         console.timeEnd("rollback")
      End Sub

      Function NextStamp() As Integer
         me.StampSeq = me.StampSeq + 1
         NextStamp = me.StampSeq
      End Function

      Sub FillBench(pRow As TBench, pSeq As Integer)
         pRow.CodBench = 0
         pRow.Nome = "Bench " & CStr(pSeq)
         pRow.Codigo = "B" & CStr(pSeq)
         pRow.Grupo = pSeq Mod 5
         pRow.Ativo = True
         pRow.Preco = 10 + pSeq
         pRow.Qtde = pSeq
         pRow.Descricao = "Desc " & CStr(pSeq)
         pRow.Status = "NOVO"
         pRow.SetString("Observacao", "obs " & CStr(pSeq))
         pRow.SetFloat("Valor1", pSeq)
         pRow.SetFloat("Valor2", pSeq * 2)
         pRow.SetFloat("Valor3", pSeq * 3)
         pRow.SetBoolean("FlagExtra", False)
         pRow.Referencia = "REF" & CStr(pSeq)
      End Sub

      Function AsBench(pRows[] As TTable, pIdx As Integer) As TBench
         AsBench = TBench(pRows.Take(pIdx))
      End Function

      Sub PushRow(pRows[] As TTable, pRow As TTable)
         pRows.Push("r" & CStr(pRows.Length), pRow)
      End Sub

      Function MakeBenchCopy(pPool[] As TTable) As TBench
         Dim seq As Integer = me.NextStamp()
         Dim n As Integer = pPool.Length
         Dim j As Integer = seq - 1
         While j >= n
            j = j - n
         Wend
         Dim copied As TBench = TBench(pPool.Take(j).Clone())
         me.FillBench(copied, seq)
         MakeBenchCopy = copied
      End Function

      Sub EnsureBenchTable()
         Dim ddl As New TDdl()
         ddl.DropTable("_tables_bench")
         ddl.DropSequence("_tables_bench_seq")
         Dim probe As New TBench()
         Dim ops[] As TDdlOp = ddl.OpsFromSchema(probe.Schema)
         ddl.ApplyOps(ops)
         ops.OwnsObjects = True
         ops.Free()
         me.AssertTrue(ddl.TableExists("_tables_bench"), "Tabela temporária _tables_bench criada")
         me.AssertTrue(ddl.SequenceExists("_tables_bench_seq"), "Sequence _tables_bench_seq criada")
         probe.Free()
         ddl.Free()
      End Sub

      Sub DoLoad()
         console.timeStart("load")
         me.EnsureBenchTable()
         me.StampSeq = 0

         console.timeStart("alloc-10000")
         Dim i As Integer
         For i = 1 To 10000
            Dim tmp As New TBench()
            tmp.Free()
         Next
         console.timeEnd("alloc-10000")

         Dim probe As New TBench()
         console.timeStart("sql-build")
         Dim selSql As String = probe.GetCommandText(TTableOp.OpSelect())
         Dim insSql As String = probe.GetCommandText(TTableOp.OpInsert())
         Dim updSql As String = probe.GetCommandText(TTableOp.OpUpdate())
         Dim delSql As String = probe.GetCommandText(TTableOp.OpDelete())
         Dim merSql As String = probe.GetCommandText(TTableOp.OpMerge())
         Dim sel2 As String = probe.GetCommandText(TTableOp.OpSelect())
         console.timeEnd("sql-build")
         me.AssertTrue(selSql.Length > 0, "SQL SELECT gerado")
         me.AssertTrue(insSql.Length > 0, "SQL INSERT gerado")
         me.AssertTrue(updSql.Length > 0, "SQL UPDATE gerado")
         me.AssertTrue(delSql.Length > 0, "SQL DELETE gerado")
         me.AssertTrue(merSql.Length > 0, "SQL MERGE gerado")
         me.AssertTrue(sel2 = selSql, "Cache de template SELECT")

         console.timeStart("seed-100")
         Dim seed[] As TTable = []
         seed.OwnsObjects = True
         For i = 1 To 100
            Dim row As New TBench()
            me.FillBench(row, i)
            row.Insert()
            me.PushRow(seed, row)
         Next
         console.timeEnd("seed-100")
         me.AssertEqInt(seed.Length, 100, "Seed de 100 linhas na tabela temporária")

         console.timeStart("fetch-100")
         Dim pool[] As TTable = probe.Fetch("", me.QuoteName("CodBench"), 100)
         console.timeEnd("fetch-100")
         me.AssertEqInt(pool.Length, 100, "Fetch limitou em 100")
         pool.OwnsObjects = True

         console.timeStart("load-exists")
         For i = 0 To 19
            Dim src As TBench = me.AsBench(pool, i)
            Dim loaded As New TBench()
            loaded.CodBench = src.CodBench
            me.AssertTrue(loaded.Load(me.QuoteName("CodBench") & " = " & CStr(src.CodBench)), "Load PK bench")
            me.AssertTrue(loaded.ExistsByPk(), "ExistsByPk bench")
            Dim viaWhere As New TBench()
            me.AssertTrue(viaWhere.LoadWhere(me.QuoteName("CodBench") & " = " & CStr(src.CodBench)), "LoadWhere bench")
            viaWhere.Free()
            loaded.Free()
         Next
         console.timeEnd("load-exists")

         Dim created[] As TTable = []
         created.OwnsObjects = True
         Dim firstRow As TBench = me.MakeBenchCopy(pool)
         console.timeStart("insert-first")
         me.AssertTrue(firstRow.Insert() >= 0, "Insert primeiro clone")
         console.timeEnd("insert-first")
         me.AssertTrue(firstRow.CodBench <> 0, "AutoCode atribuiu CodBench")
         me.PushRow(created, firstRow)

         console.timeStart("insert-each")
         For i = 2 To 80
            Dim ins As TBench = me.MakeBenchCopy(pool)
            ins.Insert()
            me.PushRow(created, ins)
         Next
         console.timeEnd("insert-each")
         me.AssertEqInt(created.Length, 80, "80 inserts individuais")

         console.timeStart("update-each")
         For i = 0 To created.Length - 1
            Dim upd As TBench = me.AsBench(created, i)
            upd.Nome = "Upd " & CStr(upd.CodBench)
            upd.Preco = upd.Preco + 0.01
            upd.Update()
         Next
         console.timeEnd("update-each")
         Dim check As New TBench()
         Dim sample As TBench = me.AsBench(created, 0)
         me.AssertTrue(check.Load(me.QuoteName("CodBench") & " = " & CStr(sample.CodBench)), "Load após update")
         me.AssertTrue(check.Nome.IndexOf("Upd ") >= 0, "Update persistiu Nome")
         check.Free()

         console.timeStart("upsert-merge")
         Dim existing As TBench = me.AsBench(created, 0)
         existing.Nome = "UPS " & CStr(existing.CodBench)
         existing.Upsert()
         Dim loadedUps As New TBench()
         loadedUps.Load(me.QuoteName("CodBench") & " = " & CStr(existing.CodBench))
         me.AssertTrue(loadedUps.Nome.IndexOf("UPS ") >= 0, "Upsert atualiza existente")
         loadedUps.Free()
         For i = 1 To 10
            Dim novo As TBench = me.MakeBenchCopy(pool)
            novo.Upsert()
            me.AssertTrue(novo.ExistsByPk(), "Upsert insere quando não existe")
            me.PushRow(created, novo)
         Next
         Dim existingM As TBench = me.AsBench(created, 1)
         existingM.Nome = "MRG " & CStr(existingM.CodBench)
         existingM.Merge()
         Dim loadedMrg As New TBench()
         loadedMrg.Load(me.QuoteName("CodBench") & " = " & CStr(existingM.CodBench))
         me.AssertTrue(loadedMrg.Nome.IndexOf("MRG ") >= 0, "Merge atualiza existente")
         loadedMrg.Free()
         For i = 1 To 10
            Dim mrg As TBench = me.MakeBenchCopy(pool)
            mrg.Merge()
            me.AssertTrue(mrg.ExistsByPk(), "Merge insere quando não existe")
            me.PushRow(created, mrg)
         Next
         console.timeEnd("upsert-merge")

         console.timeStart("assign-from")
         For i = 1 To 10
            Dim src1 As TBench = me.AsBench(pool, 0)
            Dim dst As New TBench()
            dst.AssignFrom(src1)
            me.FillBench(dst, me.NextStamp())
            dst.Insert()
            me.AssertTrue(dst.ExistsByPk(), "AssignFrom + Insert")
            me.PushRow(created, dst)
         Next
         console.timeEnd("assign-from")

         Dim batch[] As TTable = []
         For i = 1 To 40
            me.PushRow(batch, me.MakeBenchCopy(pool))
         Next
         console.timeStart("exec-insert")
         Dim db As New TExecutor()
         db.CommitMode = TCommitMode.SingleTransaction()
         db.AddInsert(batch)
         db.Exec()
         console.timeEnd("exec-insert")
         For i = 0 To batch.Length - 1
            Dim exRow As TBench = me.AsBench(batch, i)
            me.AssertTrue(exRow.CodBench <> 0, "Executor atribuiu PK")
            me.PushRow(created, exRow)
         Next
         batch.OwnsObjects = False
         batch.Free()
         db.Free()

         console.timeStart("exec-update")
         Dim dbUpd As New TExecutor()
         dbUpd.CommitMode = TCommitMode.SingleTransaction()
         Dim nUpd As Integer = 40
         If nUpd > created.Length Then
            nUpd = created.Length
         End If
         For i = 0 To nUpd - 1
            Dim u As TBench = me.AsBench(created, i)
            u.Nome = "EXU " & CStr(u.CodBench)
            dbUpd.AddUpdate(u)
         Next
         dbUpd.Exec()
         console.timeEnd("exec-update")
         dbUpd.Free()

         Dim batch2[] As TTable = []
         For i = 1 To 12
            me.PushRow(batch2, me.MakeBenchCopy(pool))
         Next
         console.timeStart("exec-per-batch")
         Dim dbBatch As New TExecutor()
         dbBatch.CommitMode = TCommitMode.PerBatch()
         dbBatch.BatchSize = 5
         dbBatch.AddInsert(batch2)
         dbBatch.Exec()
         console.timeEnd("exec-per-batch")
         For i = 0 To batch2.Length - 1
            me.PushRow(created, me.AsBench(batch2, i))
         Next
         batch2.OwnsObjects = False
         batch2.Free()
         dbBatch.Free()

         Dim mixA As TBench = me.AsBench(created, 2)
         Dim mixB As TBench = me.AsBench(created, 3)
         Dim mixC As TBench = me.AsBench(created, 4)
         mixA.Nome = "MIX " & CStr(mixA.CodBench)
         mixB.Nome = "MIX " & CStr(mixB.CodBench)
         Dim dbMix As New TExecutor()
         dbMix.CommitMode = TCommitMode.SingleTransaction()
         dbMix.AddUpsert(mixA)
         dbMix.AddMerge(mixB)
         dbMix.AddSql("UPDATE " & me.QuoteName("_tables_bench") & " SET " & me.QuoteName("Descricao") & " = 'via-sql' WHERE " & me.QuoteName("CodBench") & " = " & CStr(mixC.CodBench))
         console.timeStart("exec-mixed")
         dbMix.Exec()
         console.timeEnd("exec-mixed")
         Dim checkMix As New TBench()
         checkMix.Load(me.QuoteName("CodBench") & " = " & CStr(mixC.CodBench))
         me.AssertEq(Trim(checkMix.Descricao), "via-sql", "AddSql persistiu Descricao")
         checkMix.Free()
         dbMix.Free()

         console.timeStart("fetch-copies")
         Dim copies[] As TTable = probe.Fetch("", me.QuoteName("CodBench"), 0)
         console.timeEnd("fetch-copies")
         console.log("Fetch total bench: " & CStr(copies.Length) & " (seed 100 + criadas " & CStr(created.Length) & ")")
         me.AssertEqInt(copies.Length, 100 + created.Length, "Fetch bate com seed + inseridas")
         copies.OwnsObjects = True
         copies.Free()

         console.timeStart("delete-each")
         For i = 0 To 14
            Dim delRow As TBench = me.AsBench(created, i)
            If delRow.ExistsByPk() Then
               delRow.Delete()
               me.AssertTrue(Not delRow.ExistsByPk(), "Delete removeu clone")
            End If
         Next
         console.timeEnd("delete-each")

         Dim dbDel As New TExecutor()
         dbDel.CommitMode = TCommitMode.SingleTransaction()
         Dim nAdd As Integer = 0
         For i = 0 To created.Length - 1
            Dim left As TBench = me.AsBench(created, i)
            If left.ExistsByPk() Then
               dbDel.AddDelete(left)
               nAdd = nAdd + 1
            End If
         Next
         For i = 0 To seed.Length - 1
            dbDel.AddDelete(me.AsBench(seed, i))
            nAdd = nAdd + 1
         Next
         console.timeStart("exec-delete")
         If nAdd > 0 Then
            dbDel.Exec()
         End If
         console.timeEnd("exec-delete")
         Dim _empty[] As TTable = probe.Fetch("", "", 0)
         me.AssertEqInt(_empty.Length, 0, "Tabela temporária vazia após deletes")
         _empty.OwnsObjects = True
         _empty.Free()
         dbDel.Free()
         created.Free()
         seed.Free()
         pool.Free()
         probe.Free()

         Dim ddl As New TDdl()
         ddl.DropTable("_tables_bench")
         ddl.DropSequence("_tables_bench_seq")
         me.AssertTrue(Not ddl.TableExists("_tables_bench"), "Tabela temporária removida")
         ddl.Free()
         console.timeEnd("load")
      End Sub

      Overrides Sub Dispose()
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New TTablesTest()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
