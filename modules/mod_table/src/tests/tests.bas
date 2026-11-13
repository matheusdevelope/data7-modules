Imports TablesTable
Imports TablesSchema
Imports TablesField
Imports TablesSql
Imports Collections
Imports mod_tobject
Imports TablesMigration
Imports TablesDdl
Imports TablesRoutine
Imports TablesCodegen
Imports TablesExecutor
Imports TablesSequence

Namespace tests

   Private Dim _suite As TTablesTest

   Class TTestPedidoV1
      Inherits TTableOf<TTestPedidoV1>

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

      Overrides Function GetID() As String
         GetID = CStr(me.GetInteger("CodPedido"))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestPedido
      Inherits TTableOf<TTestPedido>

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
         pSchema.Field("AtivoS").AsBoolean().TrueValue("Sim").FalseValue("Não").DefaultVal(True)
         pSchema.Field("Status").AsString().MaxLen(20).DefaultVal("NOVO")
         pSchema.Field("Observacao").AsString().MaxLen(500)
      End Sub

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

      Property AtivoS As Boolean
         Get
            AtivoS = me.GetBoolean("AtivoS")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("AtivoS", pValue)
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

   Class TTestExpr
      Inherits TTableOf<TTestExpr>

      Sub New()
         MyBase.New("TTestExpr")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_expr"
         pSchema.Field("Id").AsInteger().PrimaryKeyField()
         pSchema.Field("Titulo").AsString().MaxLen(40).RequiredField()
         pSchema.Field("Origem").AsString().MaxLen(20).InsExpr("UPPER('web')")
         pSchema.Field("Nota").AsString().MaxLen(20).UpdExpr("UPPER('ok')")
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.GetInteger("Id"))
      End Function

      Property Id As Integer
         Get
            Id = me.GetInteger("Id")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Id", pValue)
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

      Property Origem As String
         Get
            Origem = me.GetString("Origem")
         End Get
         Set(pValue As String)
            me.SetString("Origem", pValue)
         End Set
      End Property

      Property Nota As String
         Get
            Nota = me.GetString("Nota")
         End Get
         Set(pValue As String)
            me.SetString("Nota", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestArquivo
      Inherits TTableOf<TTestArquivo>

      Sub New()
         MyBase.New("TTestArquivo")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_arquivo"
         pSchema.Field("Id").AsInteger().PrimaryKeyField()
         pSchema.Field("Nome").AsString().MaxLen(40)
         pSchema.Field("Conteudo").AsBase64()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.GetInteger("Id"))
      End Function

      Property Id As Integer
         Get
            Id = me.GetInteger("Id")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Id", pValue)
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

      Property Conteudo As String
         Get
            Conteudo = me.GetBase64("Conteudo")
         End Get
         Set(pValue As String)
            me.SetBase64("Conteudo", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTestItem
      Inherits TTableOf<TTestItem>

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
      Inherits TTableOf<TTestItemComPedido>

      Sub New()
         MyBase.New("TTestItemComPedido")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         pSchema.TableName = "_libtest_item"
         pSchema.FromClause = sqlDialect.QuoteIdent("_libtest_item") & " I JOIN " & sqlDialect.QuoteIdent("_libtest_pedido") & " P ON P." & sqlDialect.QuoteIdent("CodPedido") & " = I." & sqlDialect.QuoteIdent("CodPedido")
         pSchema.Field("CodItem").AsInteger().PrimaryKeyField().SelExpr("I." & sqlDialect.QuoteIdent("CodItem"))
         pSchema.Field("CodPedido").AsInteger().SelExpr("I." & sqlDialect.QuoteIdent("CodPedido"))
         pSchema.Field("Item").AsString().MaxLen(3).SelExpr("I." & sqlDialect.QuoteIdent("Item"))
         pSchema.Field("Descricao").AsString().MaxLen(200).SelExpr("I." & sqlDialect.QuoteIdent("Descricao"))
         pSchema.Field("Quantidade").AsInteger().SelExpr("I." & sqlDialect.QuoteIdent("Quantidade"))
         pSchema.Field("Preco").AsFloat().SelExpr("I." & sqlDialect.QuoteIdent("Preco"))
         pSchema.Field("TituloPedido").AsString().SelectOnlyField().SelExpr("P." & sqlDialect.QuoteIdent("Titulo"))
      End Sub

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
      Inherits TTableOf<TTestVenda>

      Sub New()
         MyBase.New("TTestVenda")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_libtest_venda"
         pSchema.Field("CodEmpresa").AsInteger().PrimaryKeyField()
         pSchema.Field("CodVenda").AsInteger().AutoCodeField()
         pSchema.Field("Titulo").AsString().MaxLen(80).RequiredField()
      End Sub

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
      Inherits TTableOf<TTestVendaItem>

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
      Inherits TTableOf<TBench>

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

      Shared Sub StageDialect()
         TTablesTest.Suite().DoDialect()
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
            mod_logger.Info("OK  " & pMsg)
         Else
            me.Failed = me.Failed + 1
            mod_logger.Info("FAIL  " & pMsg)
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
         migRoutines.Resources.Push("vw", New TResource(TFieldCache.ResourceView(), "_libtest_vw_pedido", sqlDialect.SqlCreateOrReplaceView("_libtest_vw_pedido", viewSelect)))
         migRoutines.Resources.Push("sp", New TResource(TFieldCache.ResourceProcedure(), "_libtest_sp_ping", sqlDialect.SqlCreateOrReplaceProcedure("_libtest_sp_ping")))
         migRoutines.Resources.Push("fn", New TResource(TFieldCache.ResourceFunc(), "_libtest_fn_double", sqlDialect.SqlCreateOrReplaceIntFunction("_libtest_fn_double")))
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
         mod_logger.timeStart("cleanup")
         Dim ddl As New TDdl()
         Dim routine As New TRoutine()
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         routine.DropIndexOnTable("IX_libtest_pedido_status", "_libtest_pedido")
         routine.Drop(TFieldCache.ResourceView(), "_libtest_vw_pedido")
         routine.Drop(TFieldCache.ResourceProcedure(), "_libtest_sp_ping")
         routine.Drop(TFieldCache.ResourceFunc(), "_libtest_fn_double")
         routine.Drop(TFieldCache.ResourceView(), "_libtest_dialect_vw")
         routine.Drop(TFieldCache.ResourceProcedure(), "_libtest_dialect_sp")
         routine.Drop(TFieldCache.ResourceFunc(), "_libtest_dialect_fn")
         ddl.DropTable("_libtest_audit")
         ddl.DropTable("_libtest_venda_item")
         ddl.DropTable("_libtest_venda")
         ddl.DropTable("_libtest_item")
         ddl.DropTable("_libtest_pedido")
         ddl.DropTable("_libtest_expr")
         ddl.DropTable("_libtest_arquivo")
         ddl.DropTable("_libtest_dialect")
         ddl.DropTable("_tables_bench")
         ddl.DropSequence("_libtest_item_seq")
         ddl.DropSequence("_libtest_pedido_seq")
         ddl.DropSequence("_tables_bench_seq")
         ddl.DropSequence("_libtest_dialect_seq")
         If ddl.TableExists("_developer_table_migrations") Then
            TSql.ExecScript("DELETE FROM " & sqlDialect.QuoteIdent("_developer_table_migrations") & " WHERE " & sqlDialect.QuoteIdent("Id") & " LIKE 'libtest_%'")
         End If
         routine.Free()
         ddl.Free()
         mod_logger.timeEnd("cleanup")
      End Sub

      Sub DoSetup()
         mod_logger.timeStart("suite")
         me.Passed = 0
         me.Failed = 0
         me.StampSeq = 0
         me.Cleanup()
      End Sub

      Sub DoTeardown()
         me.Cleanup()
         mod_logger.timeEnd("suite")
         mod_logger.Info("Resultado: " & CStr(me.Passed) & " ok, " & CStr(me.Failed) & " falhas")
         If me.Failed > 0 Then
            Throw New Exception("Suíte de testes falhou: " & CStr(me.Failed) & " asserção(ões)")
         End If
      End Sub

      Sub DoMigrations()
         mod_logger.timeStart("migrations")
         Dim runner As TMigrationRunner = me.NewRunner()
         Dim applied As Integer = runner.Execute()
         me.AssertEqInt(applied, 6, "Execute aplica 6 migrações novas")
         Dim ddl As New TDdl()
         Dim routine As New TRoutine()
         me.AssertTrue(ddl.TableExists("_libtest_pedido"), "Tabela _libtest_pedido criada")
         me.AssertTrue(ddl.TableExists("_libtest_item"), "Tabela _libtest_item criada")
         me.AssertTrue(ddl.ColumnExists("_libtest_pedido", "Observacao"), "Coluna Observacao adicionada na v3")
         me.AssertTrue(ddl.ColumnExists("_libtest_pedido", "AtivoS"), "Coluna AtivoS adicionada na v3")
         me.AssertTrue(ddl.SequenceExists("_libtest_pedido_seq"), "Sequence do pedido")
         me.AssertTrue(ddl.SequenceExists("_libtest_item_seq"), "Sequence do item")
         me.AssertTrue(ddl.TableExists("_libtest_audit"), "Tabela _libtest_audit via RawSql")
         me.AssertTrue(routine.Exists(TFieldCache.ResourceIndex(), "IX_libtest_pedido_status"), "Índice IX_libtest_pedido_status")
         Dim again As TMigrationRunner = me.NewRunner()
         me.AssertEqInt(again.Execute(), 0, "Segunda Execute não reaplica migrações")
         again.Free()
         routine.Free()
         ddl.Free()
         runner.Free()
         mod_logger.timeEnd("migrations")
      End Sub

      Sub DoCodegen()
         mod_logger.timeStart("codegen")
         Dim gen As New TTableGenerator()
         Dim body As String = gen.Build("_libtest_pedido")
         me.AssertTrue(body.IndexOf("Namespace table_libtest_pedido") >= 0, "Namespace table_libtest_pedido")
         me.AssertTrue(body.IndexOf("Class TLibtestPedido") >= 0, "Classe TLibtestPedido")
         me.AssertTrue(body.IndexOf("Inherits TTableOf<TLibtestPedido>") >= 0, "Herda TTableOf<TLibtestPedido>")
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
         me.AssertEq(gen.NamespaceName("", "Produto"), "table_produto", "Namespace dbo/default Produto")
         me.AssertEq(gen.ClassNameOf("", "Produto"), "TProduto", "Classe TProduto")
         me.AssertEq(gen.NamespaceName("Dicionario", "Projeto"), "table_dicionario_projeto", "Namespace schema não default")
         me.AssertEq(gen.ClassNameOf("Dicionario", "Projeto"), "TDicionarioProjeto", "Classe TDicionarioProjeto")
         me.AssertEq(TSql.ProximoCodigoKey("", "Produto"), "Produto", "ProximoCodigo dbo.Produto")
         me.AssertEq(TSql.ProximoCodigoKey("Financeiro", "ContaReceber"), "Financeiro.ContaReceber", "ProximoCodigo Financeiro.ContaReceber")
         me.AssertEq(TSql.StandardSequenceName("", "GrupoItemContabil", False, 0), "GrupoItemContabil_Sequencia", "Sequence GrupoItemContabil")
         me.AssertEq(TSql.StandardSequenceName("", "TeleCobranca", True, 2), "TeleCobranca_Sequencia_2", "Sequence TeleCobranca empresa 2")
         me.AssertEq(TSql.StandardSequenceName("Financeiro", "ContratoBancarioCobranca", True, 1), "Financeiro.ContratoBancarioCobranca_Sequencia_1", "Sequence Financeiro empresa 1")
         Dim seqPlain As New TSequence("GrupoItemContabil_Sequencia")
         me.AssertEq(seqPlain.TableName, "GrupoItemContabil", "Name decompõe tabela")
         me.AssertEq(seqPlain.Name, "GrupoItemContabil_Sequencia", "Name recomõe sem empresa")
         seqPlain.Free()
         Dim seqEmp As New TSequence("TeleCobranca_Sequencia", 2)
         me.AssertEqInt(seqEmp.CodEmpresa, 2, "CodEmpresa fica na instância")
         me.AssertEq(seqEmp.Name, "TeleCobranca_Sequencia_2", "Name recomõe com empresa")
         seqEmp.Free()
         Dim seqSch As New TSequence("ContratoBancarioCobranca", "Financeiro", 1)
         me.AssertEq(seqSch.SchemaName, "Financeiro", "Schema na criação")
         me.AssertEq(seqSch.Name, "Financeiro.ContratoBancarioCobranca_Sequencia_1", "Name schema+tabela+empresa")
         seqSch.Free()
         Dim seqParsed As New TSequence("Financeiro.ContratoBancarioCobranca_Sequencia_1")
         me.AssertEq(seqParsed.SchemaName, "Financeiro", "Decompõe schema do nome com ponto")
         me.AssertEq(seqParsed.TableName, "ContratoBancarioCobranca", "Decompõe tabela do nome com ponto")
         me.AssertEqInt(seqParsed.CodEmpresa, 1, "Decompõe empresa do nome com ponto")
         seqParsed.Free()
         Dim seqLit As New TSequence("_libtest_pedido_seq")
         me.AssertEq(seqLit.Name, "_libtest_pedido_seq", "Nome explícito permanece")
         seqLit.Free()
         Dim sch As New TTableSchema()
         sch.TableName = "Venda"
         me.AssertEq(TSql.ExplicitSequenceName(sch), "", "Sequence explícita vazia")
         me.AssertEq(TSql.ResolvedSequenceName(sch, True, 3), "Venda_Sequencia_3", "Sequence padrão com empresa")
         sch.SchemaName = "Replicacao"
         me.AssertEq(TSql.ResolvedSequenceName(sch, True, 2), "Replicacao.Venda_Sequencia_2", "Sequence padrão Replicacao com empresa")
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
         me.AssertTrue(Not gen.IsAutoCode(empCol, TFieldCache.KindInteger(), pk2), "CodEmpresa não é AutoCode")
         me.AssertTrue(gen.IsAutoCode(vendaCol, TFieldCache.KindInteger(), pk2), "CodVenda é AutoCode na PK CodEmpresa+ID")
         me.AssertEq(gen.GetIdBody(pk2, "TVenda"), "GetID = CStr(me.CodEmpresa) & ""|"" & CStr(me.CodVenda)", "GetID composto CodEmpresa+CodVenda")
         Dim itemCol As New TColumnInfo()
         itemCol.Name = "Item"
         itemCol.NativeType = "VARCHAR"
         itemCol.PrimaryKey = True
         Dim pk3[] As TColumnInfo = []
         pk3.Push("CodEmpresa", empCol)
         pk3.Push("CodVenda", vendaCol)
         pk3.Push("Item", itemCol)
         me.AssertTrue(Not gen.IsAutoCode(vendaCol, TFieldCache.KindInteger(), pk3), "PK 3 campos: CodVenda não é AutoCode automático")
         Dim numDef As New TFieldDef("Preco")
         numDef.AsNumeric(15, 2)
         me.AssertEq(TSql.Dialect().TypeName(numDef), "NUMERIC(15, 2)", "TypeName NUMERIC(15, 2)")
         Dim boolDef As New TFieldDef("Ativo")
         boolDef.AsBoolean()
         me.AssertEq(TSql.Dialect().TypeName(boolDef), "VARCHAR(1)", "Boolean padrão persiste VARCHAR(1)")
         me.AssertEq(boolDef.BoolDbText(True), "S", "Boolean padrão True grava S")
         me.AssertEq(boolDef.BoolDbText(False), "N", "Boolean padrão False grava N")
         me.AssertTrue(boolDef.ParseBoolText("S"), "Lê S como True")
         me.AssertTrue(boolDef.ParseBoolText("1"), "Lê 1 como True")
         me.AssertTrue(boolDef.ParseBoolText("sim"), "Lê sim como True")
         me.AssertTrue(Not boolDef.ParseBoolText("N"), "Lê N como False")
         me.AssertTrue(Not boolDef.ParseBoolText("nao"), "Lê nao como False")
         boolDef.TrueValue("Sim").FalseValue("Não")
         me.AssertEq(TSql.Dialect().TypeName(boolDef), "VARCHAR(3)", "Boolean Sim/Não persiste VARCHAR(3)")
         me.AssertEq(boolDef.BoolDbText(True), "Sim", "TrueValue Sim")
         me.AssertEq(boolDef.BoolDbText(False), "Não", "FalseValue Não")
         me.AssertTrue(boolDef.ParseBoolText("Sim"), "Lê Sim configurado")
         me.AssertTrue(Not boolDef.ParseBoolText("Não"), "Lê Não configurado")
         boolDef.Free()
         Dim numCol As New TColumnInfo()
         numCol.Name = "Preco"
         numCol.NativeType = "numeric"
         numCol.Precision = 15
         numCol.Scale = 2
         me.AssertTrue(gen.FieldLine(numCol, TFieldCache.KindFloat(), False).IndexOf(".NumericPrec(15, 2)") >= 0, "Codegen emite NumericPrec")
         Dim b64Def As New TFieldDef("Arquivo")
         b64Def.AsBase64()
         me.AssertEqInt(b64Def.KindId, 7, "AsBase64 KindId")
         me.AssertEq(TSql.Dialect().TypeName(b64Def), TSql.Dialect().ResolvedBinaryDbType(), "TypeName Base64 usa tipo binário")
         Dim b64Field As New TField(b64Def, Unassigned)
         me.AssertTrue(b64Field.IsNull(), "AsBase64 vazio é null")
         b64Field.AsBase64 = "SGVsbG8="
         me.AssertEq(b64Field.AsBase64, "SGVsbG8=", "TField AsBase64 roundtrip")
         me.AssertTrue(Not b64Field.IsNull(), "AsBase64 preenchido não é null")
         b64Field.AsBase64 = ""
         me.AssertTrue(b64Field.IsNull(), "AsBase64 limpo volta a null")
         b64Field.Free()
         Dim b64Col As New TColumnInfo()
         b64Col.Name = "Arquivo"
         b64Col.NativeType = "bytea"
         me.AssertTrue(gen.FieldLine(b64Col, TFieldCache.KindBase64(), False).IndexOf(".AsBase64()") >= 0, "Codegen emite AsBase64")
         me.AssertTrue(TSql.Dialect().MapFieldKind("BYTEA") = TFieldCache.KindBase64(), "MapFieldKind BYTEA")
         b64Def.Free()
         b64Col.Free()
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
         mod_logger.timeEnd("codegen")
      End Sub

      Sub DoDdl()
         mod_logger.timeStart("ddl")
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
         mod_logger.timeEnd("ddl")
      End Sub

      Sub DoRoutines()
         mod_logger.timeStart("routines")
         Dim routine As New TRoutine()
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         me.AssertTrue(routine.Exists(TFieldCache.ResourceView(), "_libtest_vw_pedido"), "View existe")
         me.AssertTrue(routine.Exists(TFieldCache.ResourceProcedure(), "_libtest_sp_ping"), "Procedure existe")
         me.AssertTrue(routine.Exists(TFieldCache.ResourceFunc(), "_libtest_fn_double"), "Function existe")
         Dim doubled As String = TSql.ExecSelect(sqlDialect.SqlCallIntFunction("_libtest_fn_double", 21))
         me.AssertEq(Trim(doubled), "42", "Function _libtest_fn_double(21)")
         Dim viewCount As String = TSql.ExecSelect("(SELECT COUNT(*) FROM " & sqlDialect.QuoteIdent("_libtest_vw_pedido") & ")")
         me.AssertTrue(Trim(viewCount) <> "", "SELECT na view _libtest_vw_pedido")
         routine.Free()
         mod_logger.timeEnd("routines")
      End Sub

      Sub DoCrud()
         mod_logger.timeStart("crud")
         Dim row As New TTestPedido()
         row.CodPedido = 1001
         row.Codigo = "abc-1"
         row.Titulo = "Pedido Alfa"
         row.ValorTotal = 10.5
         row.Ativo = True
         row.AtivoS = True
         row.Status = "ABERTO"
         row.Observacao = "obs inicial"
         Dim inserted As Integer = row.Insert()
         me.AssertTrue(inserted >= 0, "Insert pedido")
         me.AssertTrue(row.AfterInsertRan, "Hook AfterInsert")
         me.AssertEq(row.Codigo, "ABC-1", "PrepareValue upper no Codigo")
         me.AssertTrue(row.ExistsByPk(), "ExistsByPk após insert")
         me.AssertTrue(TTestPedido.Exists(me.QuoteName("Titulo") & " = 'Pedido Alfa'"), "Exists por WHERE")

         Dim loaded As New TTestPedido()
         loaded.CodPedido = 1001
         me.AssertTrue(loaded.Load(me.QuoteName("CodPedido") & " = 1001"), "Load pedido 1001")
         me.AssertTrue(loaded.AfterLoadRan, "Hook AfterLoad")
         me.AssertEq(loaded.Titulo, "Pedido Alfa", "Titulo hidratado")
         me.AssertTrue(loaded.Ativo, "Ativo True hidratado")
         me.AssertTrue(loaded.AtivoS, "AtivoS True hidratado")
         Dim ativoDb As StringList = TSql.FetchStringColumn("SELECT " & me.QuoteName("Ativo") & " AS v FROM " & me.QuoteName("_libtest_pedido") & " WHERE " & me.QuoteName("CodPedido") & " = 1001", "v")
         me.AssertEqInt(ativoDb.Count, 1, "Leu Ativo no banco")
         me.AssertEq(ativoDb.Strings(0), "S", "Ativo gravado como S")
         ativoDb.Free()
         Dim ativoSDb As StringList = TSql.FetchStringColumn("SELECT " & me.QuoteName("AtivoS") & " AS v FROM " & me.QuoteName("_libtest_pedido") & " WHERE " & me.QuoteName("CodPedido") & " = 1001", "v")
         me.AssertEqInt(ativoSDb.Count, 1, "Leu AtivoS no banco")
         me.AssertEq(ativoSDb.Strings(0), "SIM", "AtivoS gravado como Sim")
         ativoSDb.Free()
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

         Dim found As TTestPedido = TTestPedido.Find(me.QuoteName("CodPedido") & " = 1001")
         me.AssertTrue(Assigned(found), "Find pedido 1001")
         me.AssertEq(found.Titulo, "Pedido Alfa Edit", "Find hidrata Titulo")
         found.Free()

         Dim rows[] As TTestPedido = TTestPedido.Fetch(me.QuoteName("CodPedido") & " = 1001", me.QuoteName("CodPedido"))
         me.AssertEqInt(rows.Length, 1, "Fetch devolve 1 pedido")
         me.AssertEq(rows.Take(0).Titulo, "Pedido Alfa Edit", "Fetch tipado")
         rows.OwnsObjects = True
         rows.Free()

         Dim upsertRow As New TTestPedido()
         upsertRow.CodPedido = 1001
         upsertRow.Codigo = "ABC-1"
         upsertRow.Titulo = "Pedido Upsert"
         upsertRow.ValorTotal = 1
         upsertRow.Ativo = False
         upsertRow.AtivoS = False
         upsertRow.Status = "FECHADO"
         upsertRow.Observacao = "via upsert"
         upsertRow.Upsert()
         again.Load(me.QuoteName("CodPedido") & " = 1001")
         me.AssertEq(again.Titulo, "Pedido Upsert", "Upsert atualiza existente")
         me.AssertTrue(Not again.Ativo, "Ativo False após upsert")
         me.AssertTrue(Not again.AtivoS, "AtivoS False após upsert")
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
         me.DoFieldExpr()
         me.DoFieldBase64()
         mod_logger.timeEnd("crud")
      End Sub

      Sub DoFieldExpr()
         Dim ddl As New TDdl()
         ddl.DropTable("_libtest_expr")
         Dim probe As New TTestExpr()
         ddl.CreateTable(probe.Schema)
         Dim insSql As String = probe.GetCommandText(TFieldCache.OpInsert())
         Dim updSql As String = probe.GetCommandText(TFieldCache.OpUpdate())
         me.AssertTrue(insSql.IndexOf("UPPER('web')") > 0, "Insert usa InsExpr")
         me.AssertTrue(updSql.IndexOf("UPPER('ok')") > 0, "Update usa UpdExpr")
         probe.Id = 1
         probe.Titulo = "Expr"
         probe.Nota = "manual"
         probe.Insert()
         Dim loaded As New TTestExpr()
         loaded.Id = 1
         me.AssertTrue(loaded.Load(me.QuoteName("Id") & " = 1"), "Load expr")
         me.AssertEq(loaded.Origem, "WEB", "InsExpr gravou UPPER('web')")
         me.AssertEq(loaded.Nota, "manual", "Nota no insert usa o parâmetro")
         loaded.Titulo = "Expr Edit"
         loaded.Nota = "ignorar"
         loaded.Update()
         Dim again As New TTestExpr()
         again.Id = 1
         again.Load(me.QuoteName("Id") & " = 1")
         me.AssertEq(again.Titulo, "Expr Edit", "Update persiste Titulo")
         me.AssertEq(again.Nota, "OK", "UpdExpr gravou UPPER('ok')")
         me.AssertEq(again.Origem, "WEB", "Update não reaplica InsExpr")
         again.Free()
         loaded.Free()
         probe.Free()
         ddl.DropTable("_libtest_expr")
         ddl.Free()
      End Sub

      Sub DoFieldBase64()
         Dim ddl As New TDdl()
         ddl.DropTable("_libtest_arquivo")
         Dim probe As New TTestArquivo()
         ddl.CreateTable(probe.Schema)
         probe.Id = 1
         probe.Nome = "hello.txt"
         probe.Conteudo = "SGVsbG8="
         probe.Insert()
         Dim loaded As New TTestArquivo()
         loaded.Id = 1
         me.AssertTrue(loaded.Load(me.QuoteName("Id") & " = 1"), "Load arquivo")
         me.AssertEq(loaded.Nome, "hello.txt", "Nome do arquivo hidratado")
         me.AssertEq(loaded.Conteudo, "SGVsbG8=", "Conteudo AsBase64 hidratado")
         loaded.Conteudo = "Ynl0ZQ=="
         loaded.Update()
         Dim again As New TTestArquivo()
         again.Id = 1
         again.Load(me.QuoteName("Id") & " = 1")
         me.AssertEq(again.Conteudo, "Ynl0ZQ==", "Update persiste AsBase64")
         again.Free()
         loaded.Free()
         probe.Free()
         ddl.DropTable("_libtest_arquivo")
         ddl.Free()
      End Sub

      Sub DoCompositePk()
         mod_logger.timeStart("composite-pk")
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

         Dim updSql As String = vendaProbe.GetCommandText(TFieldCache.OpUpdate())
         Dim delSql As String = vendaProbe.GetCommandText(TFieldCache.OpDelete())
         Dim merSql As String = vendaProbe.GetCommandText(TFieldCache.OpMerge())
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
         mod_logger.timeEnd("composite-pk")
      End Sub

      Sub DoJoin()
         mod_logger.timeStart("schema-join")
         Dim rows[] As TTestItemComPedido = TTestItemComPedido.Fetch("I." & me.QuoteName("CodItem") & " = 2001", "I." & me.QuoteName("CodItem"))
         me.AssertEqInt(rows.Length, 1, "Fetch com JOIN FromClause")
         Dim joined As TTestItemComPedido = rows.Take(0)
         me.AssertEq(joined.TituloPedido, "Pedido Upsert", "SelectOnly Expr P.Titulo")
         rows.OwnsObjects = True
         rows.Free()
         mod_logger.timeEnd("schema-join")
      End Sub

      Sub DoExecutor()
         mod_logger.timeStart("executor")
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
         db.CommitMode = TFieldCache.CommitSingle()
         db.AddInsert(a)
         db.AddInsert(b)
         Dim n As Integer = db.Exec()
         me.AssertTrue(n >= 2, "Executor Insert em lote")
         Dim chk As New TTestPedido()
         me.AssertTrue(TTestPedido.Exists(me.QuoteName("CodPedido") & " = 1101"), "Lote A persistido")
         me.AssertTrue(TTestPedido.Exists(me.QuoteName("CodPedido") & " = 1102"), "Lote B persistido")
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
         me.AssertTrue(Not TTestPedido.Exists(me.QuoteName("CodPedido") & " IN (1101, 1102)"), "Executor Delete em lote")
         chk2.Free()
         chk.Free()
         db.Free()
         a.Free()
         b.Free()
         mod_logger.timeEnd("executor")
      End Sub

      Sub DoRollback()
         mod_logger.timeStart("rollback")
         Dim runner As TMigrationRunner = me.NewRunner()
         runner.Execute()
         Dim ddl As New TDdl()
         Dim routine As New TRoutine()
         runner.RollbackLast()
         me.AssertTrue(Not routine.Exists(TFieldCache.ResourceIndex(), "IX_libtest_pedido_status"), "RollbackLast remove o índice")
         me.AssertTrue(ddl.TableExists("_libtest_audit"), "Audit permanece após RollbackLast do índice")
         Dim n1 As Integer = runner.Execute()
         me.AssertEqInt(n1, 1, "Reaplica só libtest_06")
         me.AssertTrue(routine.Exists(TFieldCache.ResourceIndex(), "IX_libtest_pedido_status"), "Índice recriado")
         runner.RollbackTo("libtest_03_pedido_observacao")
         me.AssertTrue(Not routine.Exists(TFieldCache.ResourceView(), "_libtest_vw_pedido"), "RollbackTo remove view")
         me.AssertTrue(Not ddl.TableExists("_libtest_audit"), "RollbackTo remove audit")
         me.AssertTrue(ddl.TableExists("_libtest_pedido"), "Pedido permanece após RollbackTo 03")
         Dim n2 As Integer = runner.Execute()
         me.AssertEqInt(n2, 3, "Reaplica routines + audit + index")
         me.AssertTrue(routine.Exists(TFieldCache.ResourceView(), "_libtest_vw_pedido"), "View recriada")
         routine.Free()
         ddl.Free()
         runner.Free()
         mod_logger.timeEnd("rollback")
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

      Function AsBench(pRows[] As TBench, pIdx As Integer) As TBench
         AsBench = pRows.Take(pIdx)
      End Function

      Function AsTableBench(pRows[] As TTable, pIdx As Integer) As TBench
         AsTableBench = TBench(pRows.Take(pIdx))
      End Function

      Sub PushRow(pRows[] As TTable, pRow As TTable)
         pRows.Push("r" & CStr(pRows.Length), pRow)
      End Sub

      Sub PushBench(pRows[] As TBench, pRow As TBench)
         pRows.Push("r" & CStr(pRows.Length), pRow)
      End Sub

      Function MakeBenchCopy(pPool[] As TBench) As TBench
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
         mod_logger.timeStart("load")
         me.EnsureBenchTable()
         me.StampSeq = 0

         mod_logger.timeStart("alloc-2000")
         Dim i As Integer
         For i = 1 To 2000
            Dim tmp As New TBench()
            tmp.Free()
         Next
         mod_logger.timeEnd("alloc-2000")

         Dim probe As New TBench()
         mod_logger.timeStart("sql-build")
         Dim selSql As String = probe.GetCommandText(TFieldCache.OpSelect())
         Dim insSql As String = probe.GetCommandText(TFieldCache.OpInsert())
         Dim updSql As String = probe.GetCommandText(TFieldCache.OpUpdate())
         Dim delSql As String = probe.GetCommandText(TFieldCache.OpDelete())
         Dim merSql As String = probe.GetCommandText(TFieldCache.OpMerge())
         Dim sel2 As String = probe.GetCommandText(TFieldCache.OpSelect())
         mod_logger.timeEnd("sql-build")
         me.AssertTrue(selSql.Length > 0, "SQL SELECT gerado")
         me.AssertTrue(insSql.Length > 0, "SQL INSERT gerado")
         me.AssertTrue(updSql.Length > 0, "SQL UPDATE gerado")
         me.AssertTrue(delSql.Length > 0, "SQL DELETE gerado")
         me.AssertTrue(merSql.Length > 0, "SQL MERGE gerado")
         me.AssertTrue(sel2 = selSql, "Cache de template SELECT")

         mod_logger.timeStart("seed-20")
         Dim seed[] As TBench = []
         seed.OwnsObjects = True
         For i = 1 To 20
            Dim row As New TBench()
            me.FillBench(row, i)
            row.Insert()
            me.PushBench(seed, row)
         Next
         mod_logger.timeEnd("seed-20")
         me.AssertEqInt(seed.Length, 20, "Seed de 20 linhas na tabela temporária")

         mod_logger.timeStart("fetch-20")
         Dim pool[] As TBench = TBench.Fetch("", me.QuoteName("CodBench"), 20)
         mod_logger.timeEnd("fetch-20")
         print(pool.First.ToString())
         me.AssertEqInt(pool.Length, 20, "Fetch limitou em 20")
         pool.OwnsObjects = True

         mod_logger.timeStart("load-exists")
         For i = 0 To 4
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
         mod_logger.timeEnd("load-exists")

         Dim created[] As TBench = []
         created.OwnsObjects = True
         Dim firstRow As TBench = me.MakeBenchCopy(pool)
         mod_logger.timeStart("insert-first")
         me.AssertTrue(firstRow.Insert() >= 0, "Insert primeiro clone")
         mod_logger.timeEnd("insert-first")
         me.AssertTrue(firstRow.CodBench <> 0, "AutoCode atribuiu CodBench")
         me.PushBench(created, firstRow)

         mod_logger.timeStart("insert-each")
         For i = 2 To 20
            Dim ins As TBench = me.MakeBenchCopy(pool)
            ins.Insert()
            me.PushBench(created, ins)
         Next
         mod_logger.timeEnd("insert-each")
         me.AssertEqInt(created.Length, 20, "20 inserts individuais")

         mod_logger.timeStart("update-each")
         For i = 0 To created.Length - 1
            Dim upd As TBench = me.AsBench(created, i)
            upd.Nome = "Upd " & CStr(upd.CodBench)
            upd.Preco = upd.Preco + 0.01
            upd.Update()
         Next
         mod_logger.timeEnd("update-each")
         Dim check As New TBench()
         Dim sample As TBench = me.AsBench(created, 0)
         me.AssertTrue(check.Load(me.QuoteName("CodBench") & " = " & CStr(sample.CodBench)), "Load após update")
         me.AssertTrue(check.Nome.IndexOf("Upd ") >= 0, "Update persistiu Nome")
         check.Free()

         mod_logger.timeStart("upsert-merge")
         Dim existing As TBench = me.AsBench(created, 0)
         existing.Nome = "UPS " & CStr(existing.CodBench)
         existing.Upsert()
         Dim loadedUps As New TBench()
         loadedUps.Load(me.QuoteName("CodBench") & " = " & CStr(existing.CodBench))
         me.AssertTrue(loadedUps.Nome.IndexOf("UPS ") >= 0, "Upsert atualiza existente")
         loadedUps.Free()
         For i = 1 To 3
            Dim novo As TBench = me.MakeBenchCopy(pool)
            novo.Upsert()
            me.AssertTrue(novo.ExistsByPk(), "Upsert insere quando não existe")
            me.PushBench(created, novo)
         Next
         Dim existingM As TBench = me.AsBench(created, 1)
         existingM.Nome = "MRG " & CStr(existingM.CodBench)
         existingM.Merge()
         Dim loadedMrg As New TBench()
         loadedMrg.Load(me.QuoteName("CodBench") & " = " & CStr(existingM.CodBench))
         me.AssertTrue(loadedMrg.Nome.IndexOf("MRG ") >= 0, "Merge atualiza existente")
         loadedMrg.Free()
         For i = 1 To 3
            Dim mrg As TBench = me.MakeBenchCopy(pool)
            mrg.Merge()
            me.AssertTrue(mrg.ExistsByPk(), "Merge insere quando não existe")
            me.PushBench(created, mrg)
         Next
         mod_logger.timeEnd("upsert-merge")

         mod_logger.timeStart("assign-from")
         For i = 1 To 3
            Dim src1 As TBench = me.AsBench(pool, 0)
            Dim dst As New TBench()
            dst.AssignFrom(src1)
            me.FillBench(dst, me.NextStamp())
            dst.Insert()
            me.AssertTrue(dst.ExistsByPk(), "AssignFrom + Insert")
            me.PushBench(created, dst)
         Next
         mod_logger.timeEnd("assign-from")

         Dim batch[] As TTable = []
         For i = 1 To 10
            me.PushRow(batch, me.MakeBenchCopy(pool))
         Next
         mod_logger.timeStart("exec-insert")
         Dim db As New TExecutor()
         db.CommitMode = TFieldCache.CommitSingle()
         db.AddInsert(batch)
         db.Exec()
         mod_logger.timeEnd("exec-insert")
         For i = 0 To batch.Length - 1
            Dim exRow As TBench = me.AsTableBench(batch, i)
            me.AssertTrue(exRow.CodBench <> 0, "Executor atribuiu PK")
            me.PushBench(created, exRow)
         Next
         batch.OwnsObjects = False
         batch.Free()
         db.Free()

         mod_logger.timeStart("exec-update")
         Dim dbUpd As New TExecutor()
         dbUpd.CommitMode = TFieldCache.CommitSingle()
         Dim nUpd As Integer = 10
         If nUpd > created.Length Then
            nUpd = created.Length
         End If
         For i = 0 To nUpd - 1
            Dim u As TBench = me.AsBench(created, i)
            u.Nome = "EXU " & CStr(u.CodBench)
            dbUpd.AddUpdate(u)
         Next
         dbUpd.Exec()
         mod_logger.timeEnd("exec-update")
         dbUpd.Free()

         Dim batch2[] As TTable = []
         For i = 1 To 6
            me.PushRow(batch2, me.MakeBenchCopy(pool))
         Next
         mod_logger.timeStart("exec-per-batch")
         Dim dbBatch As New TExecutor()
         dbBatch.CommitMode = TFieldCache.CommitPerBatch()
         dbBatch.BatchSize = 5
         dbBatch.AddInsert(batch2)
         dbBatch.Exec()
         mod_logger.timeEnd("exec-per-batch")
         For i = 0 To batch2.Length - 1
            me.PushBench(created, me.AsTableBench(batch2, i))
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
         dbMix.CommitMode = TFieldCache.CommitSingle()
         dbMix.AddUpsert(mixA)
         dbMix.AddMerge(mixB)
         dbMix.AddSql("UPDATE " & me.QuoteName("_tables_bench") & " SET " & me.QuoteName("Descricao") & " = 'via-sql' WHERE " & me.QuoteName("CodBench") & " = " & CStr(mixC.CodBench))
         mod_logger.timeStart("exec-mixed")
         dbMix.Exec()
         mod_logger.timeEnd("exec-mixed")
         Dim checkMix As New TBench()
         checkMix.Load(me.QuoteName("CodBench") & " = " & CStr(mixC.CodBench))
         me.AssertEq(Trim(checkMix.Descricao), "via-sql", "AddSql persistiu Descricao")
         checkMix.Free()
         dbMix.Free()

         mod_logger.timeStart("fetch-copies")
         Dim copies[] As TBench = TBench.Fetch("", me.QuoteName("CodBench"), 0)
         mod_logger.timeEnd("fetch-copies")
         mod_logger.Info("Fetch total bench: " & CStr(copies.Length) & " (seed 20 + criadas " & CStr(created.Length) & ")")
         me.AssertEqInt(copies.Length, 20 + created.Length, "Fetch bate com seed + inseridas")
         copies.OwnsObjects = True
         copies.Free()

         mod_logger.timeStart("delete-each")
         For i = 0 To 4
            Dim delRow As TBench = me.AsBench(created, i)
            If delRow.ExistsByPk() Then
               delRow.Delete()
               me.AssertTrue(Not delRow.ExistsByPk(), "Delete removeu clone")
            End If
         Next
         mod_logger.timeEnd("delete-each")

         Dim dbDel As New TExecutor()
         dbDel.CommitMode = TFieldCache.CommitSingle()
         Dim nAdd As Integer = 0
         For i = 5 To created.Length - 1
            dbDel.AddDelete(me.AsBench(created, i))
            nAdd = nAdd + 1
         Next
         For i = 0 To seed.Length - 1
            dbDel.AddDelete(me.AsBench(seed, i))
            nAdd = nAdd + 1
         Next
         mod_logger.timeStart("exec-delete")
         If nAdd > 0 Then
            dbDel.Exec()
         End If
         mod_logger.timeEnd("exec-delete")
         Dim _empty[] As TBench = TBench.Fetch("", "", 0)
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
         mod_logger.timeEnd("load")
      End Sub

      Function SqlHas(pSql As String, pPart As String) As Boolean
         Dim at As Integer = pSql.IndexOf(pPart)
         If at < 0 Then
            SqlHas = False
            Exit Function
         End If
         SqlHas = pSql.Right(pSql.Length - at).Left(pPart.Length) = pPart
      End Function

      Sub AssertQuery(pName As String, pSql As String)
         Dim query As SQL.Command = Null
         Try
            query = TSql.OpenQuery(pSql)
            query.Close()
            query.Free()
            me.AssertTrue(True, pName)
         Catch ex As Exception
            If Assigned(query) Then
               query.Free()
            End If
            me.AssertTrue(False, pName & ": " & ex.Message)
         End Try
      End Sub

      Sub AssertExec(pName As String, pSql As String)
         Try
            TSql.ExecScript(pSql)
            me.AssertTrue(True, pName)
         Catch ex As Exception
            me.AssertTrue(False, pName & ": " & ex.Message)
         End Try
      End Sub

      Sub AssertDialectText(pDialect As TSqlDialect, pLabel As String)
         Dim schema As New TTableSchema()
         schema.TableName = "_libtest_dialect"
         schema.Field("Id").AsInteger().PrimaryKeyField()
         Dim nome As TFieldDef = schema.Field("Nome").AsString().MaxLen(40)
         Dim seqName As String = "_libtest_dialect_seq"
         me.AssertTrue(pDialect.QuoteIdent("Id") <> "", pLabel & " QuoteIdent")
         me.AssertTrue(pDialect.QuoteTable("", "_libtest_dialect") <> "", pLabel & " QuoteTable")
         me.AssertTrue(pDialect.QuoteSequence(seqName) <> "", pLabel & " QuoteSequence")
         me.AssertTrue(pDialect.DefaultSchema() <> "", pLabel & " DefaultSchema")
         me.AssertTrue(pDialect.ParamToken("Id") <> "", pLabel & " ParamToken")
         me.AssertTrue(pDialect.SqlParam(nome) <> "", pLabel & " SqlParam")
         me.AssertTrue(pDialect.TypeName(nome) <> "", pLabel & " TypeName")
         me.AssertTrue(pDialect.IsDefaultSchema(""), pLabel & " IsDefaultSchema")
         me.AssertTrue(pDialect.IsNumericNative("NUMERIC"), pLabel & " IsNumericNative")
         me.AssertTrue(pDialect.NumericDbType(nome, "DOUBLE") <> "", pLabel & " NumericDbType")
         me.AssertTrue(pDialect.NormalizeWhere("Id = 1") <> "", pLabel & " NormalizeWhere")
         me.AssertTrue(pDialect.NormalizeOrderBy("Id") <> "", pLabel & " NormalizeOrderBy")
         me.AssertTrue(pDialect.QuoteOrderExpr("Id") <> "", pLabel & " QuoteOrderExpr")
         Dim parts As New StringList()
         parts.Add("A")
         parts.Add("B")
         me.AssertTrue(pDialect.JoinComma(parts) <> "", pLabel & " JoinComma")
         parts.Free()
         me.AssertTrue(Assigned(pDialect.MapFieldKind("INTEGER")), pLabel & " MapFieldKind")
         me.AssertTrue(pDialect.MapFieldKind("BYTEA") = TFieldCache.KindBase64(), pLabel & " MapFieldKind BYTEA")
         Dim arquivo As TFieldDef = schema.Field("Arquivo").AsBase64()
         me.AssertTrue(pDialect.TypeName(arquivo) <> "", pLabel & " TypeName Base64")
         me.AssertTrue(pDialect.BinaryDbType() <> "", pLabel & " BinaryDbType")
         Dim block As String = pDialect.SqlBeginBlock()
         me.AssertTrue(block <> "", pLabel & " SqlBeginBlock")
         me.AssertTrue(pDialect.SqlEndBlock() <> "", pLabel & " SqlEndBlock")
         Dim srcFrom As String = pDialect.SqlMergeSourceFrom()
         Dim term As String = pDialect.SqlMergeTerminator()
         me.AssertTrue(srcFrom.Length >= 0 And term.Length >= 0, pLabel & " SqlMergeSourceFrom")
         me.AssertTrue(pDialect.SqlMergeTarget("_libtest_dialect") <> "", pLabel & " SqlMergeTarget")
         me.AssertTrue(pDialect.SqlTypedParam("Id", "INTEGER") <> "", pLabel & " SqlTypedParam")
         me.AssertTrue(pDialect.ApplyLimit("SELECT 1 AS ok", 1) <> "", pLabel & " ApplyLimit")
         me.AssertTrue(pDialect.SqlTableExists("_libtest_dialect") <> "", pLabel & " SqlTableExists")
         me.AssertTrue(pDialect.SqlColumnExists("_libtest_dialect", "Id") <> "", pLabel & " SqlColumnExists")
         me.AssertTrue(pDialect.SqlListColumns("_libtest_dialect") <> "", pLabel & " SqlListColumns")
         me.AssertTrue(pDialect.SqlDescribeColumns("", "_libtest_dialect") <> "", pLabel & " SqlDescribeColumns")
         me.AssertTrue(pDialect.SqlSequenceExists(seqName) <> "", pLabel & " SqlSequenceExists")
         me.AssertTrue(pDialect.SqlRoutineExists(TFieldCache.ResourceView(), "_libtest_dialect_vw") <> "", pLabel & " SqlRoutineExists view")
         me.AssertTrue(pDialect.SqlRoutineExists(TFieldCache.ResourceIndex(), "IX_libtest_dialect") <> "", pLabel & " SqlRoutineExists index")
         me.AssertTrue(pDialect.SqlRoutineExists(TFieldCache.ResourceProcedure(), "_libtest_dialect_sp") <> "", pLabel & " SqlRoutineExists procedure")
         me.AssertTrue(pDialect.SqlRoutineExists(TFieldCache.ResourceFunc(), "_libtest_dialect_fn") <> "", pLabel & " SqlRoutineExists function")
         me.AssertTrue(pDialect.SqlRoutineExists(TFieldCache.ResourceTrigger(), "_libtest_dialect_trg") <> "", pLabel & " SqlRoutineExists trigger")
         me.AssertTrue(pDialect.SqlCreateTable(schema) <> "", pLabel & " SqlCreateTable")
         me.AssertTrue(pDialect.SqlDropTable("_libtest_dialect") <> "", pLabel & " SqlDropTable")
         me.AssertTrue(pDialect.SqlAddColumn("_libtest_dialect", nome) <> "", pLabel & " SqlAddColumn")
         me.AssertTrue(pDialect.SqlDropColumn("_libtest_dialect", "Nome") <> "", pLabel & " SqlDropColumn")
         me.AssertTrue(pDialect.SqlRenameColumn("_libtest_dialect", "Nome", "Obs") <> "", pLabel & " SqlRenameColumn")
         me.AssertTrue(pDialect.SqlAlterColumnType("_libtest_dialect", nome) <> "", pLabel & " SqlAlterColumnType")
         me.AssertTrue(pDialect.SqlSetNullability("_libtest_dialect", "Nome", False) <> "", pLabel & " SqlSetNullability")
         me.AssertTrue(pDialect.SqlCreateSequence(seqName) <> "", pLabel & " SqlCreateSequence")
         me.AssertTrue(pDialect.SqlDropSequence(seqName) <> "", pLabel & " SqlDropSequence")
         me.AssertTrue(pDialect.SqlRestartSequence(seqName, 10) <> "", pLabel & " SqlRestartSequence")
         me.AssertTrue(pDialect.SqlPeekSequence(seqName) <> "", pLabel & " SqlPeekSequence")
         me.AssertTrue(pDialect.SqlAllocateSequence(seqName, 5) <> "", pLabel & " SqlAllocateSequence")
         me.AssertTrue(pDialect.SqlNextSequence(seqName) <> "", pLabel & " SqlNextSequence")
         me.AssertTrue(pDialect.SqlCreateOrAlter(TFieldCache.ResourceProcedure(), "_libtest_dialect_sp", "SELECT 1") <> "", pLabel & " SqlCreateOrAlter")
         me.AssertTrue(pDialect.SqlDropRoutine(TFieldCache.ResourceView(), "_libtest_dialect_vw") <> "", pLabel & " SqlDropRoutine")
         me.AssertTrue(pDialect.SqlCreateOrReplaceView("_libtest_dialect_vw", "SELECT 1 AS ok") <> "", pLabel & " SqlCreateOrReplaceView")
         me.AssertTrue(pDialect.SqlCreateOrReplaceProcedure("_libtest_dialect_sp") <> "", pLabel & " SqlCreateOrReplaceProcedure")
         me.AssertTrue(pDialect.SqlCreateOrReplaceIntFunction("_libtest_dialect_fn") <> "", pLabel & " SqlCreateOrReplaceIntFunction")
         me.AssertTrue(pDialect.SqlCallIntFunction("_libtest_dialect_fn", 2) <> "", pLabel & " SqlCallIntFunction")
         me.AssertTrue(pDialect.SqlCreateIndexOnTable("IX_libtest_dialect", "_libtest_dialect", "Nome") <> "", pLabel & " SqlCreateIndexOnTable")
         me.AssertTrue(pDialect.SqlDropIndexOnTable("IX_libtest_dialect", "_libtest_dialect") <> "", pLabel & " SqlDropIndexOnTable")
         me.AssertTrue(pDialect.SqlCastCopy("_libtest_dialect", "Nota", "Nome", nome) <> "", pLabel & " SqlCastCopy")
         Dim pkNames As New StringList()
         Dim insNames As New StringList()
         Dim insParams As New StringList()
         Dim insTypes As New StringList()
         Dim updNames As New StringList()
         pkNames.Add("Id")
         insNames.Add("Id")
         insParams.Add(pDialect.ParamToken("Id"))
         insTypes.Add("INTEGER")
         updNames.Add("Nome")
         me.AssertTrue(pDialect.SqlMerge("_libtest_dialect", pkNames, insNames, insParams, insTypes, updNames) <> "", pLabel & " SqlMerge")
         pkNames.Free()
         insNames.Free()
         insParams.Free()
         insTypes.Free()
         updNames.Free()
         schema.Free()
         Dim ddlTx As Boolean = pDialect.SupportsDdlInTransaction()
         Dim dropIf As Boolean = pDialect.SupportsDropIfExists()
         me.AssertTrue(ddlTx = True Or ddlTx = False, pLabel & " SupportsDdlInTransaction")
         me.AssertTrue(dropIf = True Or dropIf = False, pLabel & " SupportsDropIfExists")
      End Sub

      Sub DoDialect()
         mod_logger.timeStart("dialect")
         Dim mssql As New TSqlDialectMssql()
         Dim asa As New TSqlDialectAsa()
         Dim postgres As New TSqlDialectPostgres()
         me.AssertDialectText(mssql, "MSSQL")
         me.AssertDialectText(asa, "ASA")
         me.AssertDialectText(postgres, "Postgres")
         Dim peekSql As String = asa.SqlPeekSequence("_libtest_dialect_seq")
         me.AssertTrue(me.SqlHas(peekSql, "resume_at"), "ASA SqlPeekSequence usa resume_at")
         me.AssertTrue(me.SqlHas(peekSql, "SYSSEQUENCE"), "ASA SqlPeekSequence usa SYSSEQUENCE")
         me.AssertTrue(Not me.SqlHas(peekSql, "current_identity"), "ASA SqlPeekSequence sem current_identity")
         me.AssertTrue(me.SqlHas(asa.SqlAllocateSequence("_libtest_dialect_seq", 1), "resume_at"), "ASA SqlAllocateSequence usa resume_at")
         Dim seqSql As String = mssql.SqlNextSequence("EscritaFiscal.TipoNotaFiscalServico_Sequencia")
         me.AssertTrue(Not me.SqlHas(seqSql, "[EscritaFiscal.TipoNotaFiscalServico_Sequencia]"), "MSSQL sequence sem colchetes no nome composto")
         me.AssertTrue(me.SqlHas(seqSql, "CREATE SEQUENCE EscritaFiscal.TipoNotaFiscalServico_Sequencia"), "MSSQL CREATE SEQUENCE schema.objeto")
         me.AssertTrue(me.SqlHas(seqSql, "NEXT VALUE FOR EscritaFiscal.TipoNotaFiscalServico_Sequencia"), "MSSQL NEXT VALUE FOR schema.objeto")
         me.AssertEq(mssql.QuoteSequence("EscritaFiscal.TipoNotaFiscalServico_Sequencia"), "EscritaFiscal.TipoNotaFiscalServico_Sequencia", "MSSQL QuoteSequence sem colchetes")
         mssql.Free()
         asa.Free()
         postgres.Free()

         Dim d As TSqlDialect = TSql.Dialect()
         Dim tableName As String = "_libtest_dialect"
         Dim seqName As String = "_libtest_dialect_seq"
         Dim ddl As New TDdl()
         Dim routine As New TRoutine()
         routine.Drop(TFieldCache.ResourceView(), "_libtest_dialect_vw")
         routine.Drop(TFieldCache.ResourceProcedure(), "_libtest_dialect_sp")
         routine.Drop(TFieldCache.ResourceFunc(), "_libtest_dialect_fn")
         ddl.DropTable(tableName)
         ddl.DropSequence(seqName)

         Dim schema As New TTableSchema()
         schema.TableName = tableName
         schema.Field("Id").AsInteger().PrimaryKeyField()
         Dim nome As TFieldDef = schema.Field("Nome").AsString().MaxLen(40)
         me.AssertExec("SqlCreateTable", d.SqlCreateTable(schema))
         Dim nota As TFieldDef = schema.Field("Nota").AsString().MaxLen(20)
         me.AssertQuery("SqlTableExists", d.SqlTableExists(tableName))
         me.AssertQuery("SqlColumnExists", d.SqlColumnExists(tableName, "Id"))
         me.AssertQuery("SqlListColumns", d.SqlListColumns(tableName))
         me.AssertQuery("SqlDescribeColumns", d.SqlDescribeColumns("", tableName))
         me.AssertExec("SqlAddColumn", d.SqlAddColumn(tableName, nota))
         me.AssertExec("SqlCastCopy", d.SqlCastCopy(tableName, "Nota", "Nome", nota))
         me.AssertExec("SqlAlterColumnType", d.SqlAlterColumnType(tableName, nome))
         me.AssertExec("SqlSetNullability", d.SqlSetNullability(tableName, "Nome", False))
         me.AssertExec("SqlRenameColumn", d.SqlRenameColumn(tableName, "Nota", "Obs"))
         me.AssertExec("SqlCreateIndexOnTable", d.SqlCreateIndexOnTable("IX_libtest_dialect", tableName, "Nome"))
         me.AssertQuery("SqlRoutineExists index", d.SqlRoutineExists(TFieldCache.ResourceIndex(), "IX_libtest_dialect"))
         me.AssertExec("SqlDropIndexOnTable", d.SqlDropIndexOnTable("IX_libtest_dialect", tableName))
         me.AssertExec("SqlCreateSequence", d.SqlCreateSequence(seqName))
         me.AssertQuery("SqlSequenceExists", d.SqlSequenceExists(seqName))
         Dim peeked As Integer = TSql.ExecScalarV(d.SqlPeekSequence(seqName), "v", -1)
         me.AssertTrue(peeked >= 0, "SqlPeekSequence valor")
         me.AssertExec("SqlRestartSequence", d.SqlRestartSequence(seqName, 10))
         peeked = TSql.ExecScalarV(d.SqlPeekSequence(seqName), "v", -1)
         me.AssertTrue(peeked >= 0, "SqlPeekSequence após restart")
         If d.DefaultSchema() = "dba" Then
            me.AssertEqInt(peeked, 10, "ASA SqlPeekSequence resume_at após restart")
         End If
         me.AssertQuery("SqlAllocateSequence", d.SqlAllocateSequence(seqName, 5))
         Dim nxt As Integer = TSql.ExecScalarV(d.SqlNextSequence(seqName), "v", -1)
         me.AssertTrue(nxt >= 1, "SqlNextSequence")
         me.AssertQuery("SqlRoutineExists trigger", d.SqlRoutineExists(TFieldCache.ResourceTrigger(), "_libtest_dialect_trg"))
         me.AssertQuery("SqlRoutineExists procedure", d.SqlRoutineExists(TFieldCache.ResourceProcedure(), "_libtest_dialect_sp"))
         me.AssertQuery("SqlRoutineExists function", d.SqlRoutineExists(TFieldCache.ResourceFunc(), "_libtest_dialect_fn"))
         Dim viewSelect As String = "SELECT " & d.QuoteIdent("Id") & " FROM " & d.QuoteIdent(tableName)
         me.AssertExec("SqlCreateOrReplaceView", d.SqlCreateOrReplaceView("_libtest_dialect_vw", viewSelect))
         me.AssertQuery("SqlRoutineExists view", d.SqlRoutineExists(TFieldCache.ResourceView(), "_libtest_dialect_vw"))
         me.AssertExec("SqlDropRoutine view", d.SqlDropRoutine(TFieldCache.ResourceView(), "_libtest_dialect_vw"))
         me.AssertExec("SqlCreateOrReplaceProcedure", d.SqlCreateOrReplaceProcedure("_libtest_dialect_sp"))
         me.AssertExec("SqlCreateOrReplaceIntFunction", d.SqlCreateOrReplaceIntFunction("_libtest_dialect_fn"))
         me.AssertQuery("SqlCallIntFunction", "SELECT " & d.SqlCallIntFunction("_libtest_dialect_fn", 2) & " AS v" & d.SqlMergeSourceFrom())
         me.AssertQuery("ApplyLimit", d.ApplyLimit("SELECT 1 AS ok", 1))
         me.AssertExec("SqlDropColumn", d.SqlDropColumn(tableName, "Obs"))
         me.AssertExec("SqlDropSequence", d.SqlDropSequence(seqName))
         me.AssertExec("SqlDropRoutine procedure", d.SqlDropRoutine(TFieldCache.ResourceProcedure(), "_libtest_dialect_sp"))
         me.AssertExec("SqlDropRoutine function", d.SqlDropRoutine(TFieldCache.ResourceFunc(), "_libtest_dialect_fn"))
         me.AssertExec("SqlDropTable", d.SqlDropTable(tableName))
         schema.Free()
         routine.Free()
         ddl.Free()
         mod_logger.timeEnd("dialect")
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
