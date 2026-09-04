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

Namespace TablesMigration

   Class TTableMigrations
      Inherits TTable

      Sub New()
         MyBase.New("TTableMigrations")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "_developer_table_migrations"
         pSchema.Field("Id").AsString().MaxLen(150).PrimaryKeyField()
         pSchema.Field("AppliedAt").AsDateTime().RequiredField()
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TTableMigrations()
      End Function

      Property IdValue As String
         Get
            IdValue = me.GetString("Id")
         End Get
         Set(pValue As String)
            me.SetString("Id", pValue)
         End Set
      End Property

      Property AppliedAt As TDateTime
         Get
            AppliedAt = me.GetDateTime("AppliedAt")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("AppliedAt", pValue)
         End Set
      End Property

      Overrides Function GetID() As String
         GetID = me.IdValue
      End Function
      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TMigrationContext
      Inherits TTObject

      Ddl As TDdl
      Sequence As TSequence
      Routine As TRoutine
      Exec As TExecutor
      Query As SQL.Command

      Sub New()
         MyBase.New()
         me.Ddl = New TDdl()
         me.Sequence = New TSequence("")
         me.Routine = New TRoutine()
         me.Exec = New TExecutor()
      End Sub

      Overrides Sub Dispose()
         If Assigned(me.Ddl) Then
            me.Ddl.Free()
            me.Ddl = Null
         End If
         If Assigned(me.Sequence) Then
            me.Sequence.Free()
            me.Sequence = Null
         End If
         If Assigned(me.Routine) Then
            me.Routine.Free()
            me.Routine = Null
         End If
         If Assigned(me.Exec) Then
            me.Exec.Free()
            me.Exec = Null
         End If
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New TMigrationContext()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TMigration
      Inherits TTObject

      Table As TTable
      Resources[] As TResource
      RawSql As String
      RawSqlDown As String

      Private _id As String

      Sub New(pId As String)
         MyBase.New()
         me._id = pId
         me.RawSql = ""
         me.RawSqlDown = ""
         me.Resources = []
      End Sub

      Sub New(pId As String, pTable As TTable)
         MyBase.New()
         me._id = pId
         me.Table = pTable
         me.RawSql = ""
         me.RawSqlDown = ""
         me.Resources = []
      End Sub

      Sub New(pId As String, pSql As String)
         MyBase.New()
         me._id = pId
         me.RawSql = pSql
         me.RawSqlDown = ""
         me.Resources = []
      End Sub

      Function Id() As String
         Id = me._id
      End Function

      Overridable Function BuildOps(pCtx As TMigrationContext) As TTList<TDdlOp>
         If Assigned(me.Table) Then
            BuildOps = pCtx.Ddl.OpsFromSchema(me.Table.Schema)
         Else
            BuildOps = []
         End If
      End Function

      Overridable Function BuildDownOps(pCtx As TMigrationContext) As TTList<TDdlOp>
         Dim ups[] As TDdlOp = me.BuildOps(pCtx)
         Dim downs[] As TDdlOp = []
         Dim i As Integer = ups.Length - 1
         While i >= 0
            Dim op As TDdlOp = ups.Take(i)
            If op.Kind.IsValue(TDdlOpKind.CreateTable()) Then
               downs.Push(pCtx.Ddl.OpDropTable(op.TableName))
            ElseIf op.Kind.IsValue(TDdlOpKind.AddColumn()) Then
               downs.Push(pCtx.Ddl.OpDropColumn(op.TableName, op.ColumnName))
            End If
            i = i - 1
         End While
         If Assigned(ups) Then
            ups.OwnsObjects = False
            ups.Free()
         End If
         BuildDownOps = downs
      End Function

      Overridable Function GetSql(pCtx As TMigrationContext) As String
         GetSql = ""
      End Function

      Overridable Function GetDownSql(pCtx As TMigrationContext) As String
         GetDownSql = ""
      End Function

      Overridable Sub Up(pCtx As TMigrationContext)
         Dim sqlText As String = me.GetSql(pCtx)
         If Trim(sqlText) <> "" Then
            TSql.ExecScript(sqlText)
         Else
            Dim ops[] As TDdlOp = me.BuildOps(pCtx)
            pCtx.Ddl.ApplyOps(ops)
            If Assigned(ops) Then
               ops.OwnsObjects = False
               ops.Free()
            End If
            If Trim(me.RawSql) <> "" Then
               If Not Assigned(me.Table) Then
                  TSql.ExecScript(me.RawSql)
               End If
            End If
         End If
         Dim i As Integer
         For i = 0 To me.Resources.Length - 1
            pCtx.Routine.ApplyResource(me.Resources.Take(i))
         Next
      End Sub

      Overridable Sub Down(pCtx As TMigrationContext)
         Dim sqlText As String = me.GetDownSql(pCtx)
         If Trim(sqlText) <> "" Then
            TSql.ExecScript(sqlText)
         Else
            If Trim(me.RawSql) <> "" Then
               If Not Assigned(me.Table) Then
                  If Trim(me.RawSqlDown) = "" Then
                     Throw New Exception("Down não definido para migração " & me.Id())
                  End If
                  TSql.ExecScript(me.RawSqlDown)
                  Exit Sub
               End If
            End If
            Dim ops[] As TDdlOp = me.BuildDownOps(pCtx)
            pCtx.Ddl.ApplyOps(ops)
            If Assigned(ops) Then
               ops.OwnsObjects = False
               ops.Free()
            End If
         End If
         Dim i As Integer = me.Resources.Length - 1
         While i >= 0
            Dim res As TResource = me.Resources.Take(i)
            If res.DropOnDown Then
               pCtx.Routine.Drop(res.Kind, res.Name)
            End If
            i = i - 1
         End While
      End Sub

      Overrides Function GetID() As String
         GetID = me._id
      End Function

      Overrides Function Clone() As TTObject
         Dim n As New TMigration(me._id)
         n.Table = me.Table
         n.RawSql = me.RawSql
         n.RawSqlDown = me.RawSqlDown
         Clone = n
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Resources) Then
            me.Resources.Free()
            me.Resources = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TScriptMigration
      Inherits TMigration

      Sub New(pId As String, pSql As String)
         MyBase.New(pId, pSql)
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TMigrationRunner
      Inherits TTObject

      Migrations[] As TMigration

      Private _applied As StringList
      Private _appliedReady As Boolean
      Private _historyReady As Boolean

      Sub New()
         MyBase.New()
         me.Migrations = []
         me._appliedReady = False
         me._historyReady = False
      End Sub

      Sub Registerr(pMigration As TMigration)
         me.Migrations.Push(pMigration.Id(), pMigration)
      End Sub

      Sub InvalidateApplied()
         me._appliedReady = False
         me._historyReady = False
      End Sub

      Sub EnsureHistory()
         If me._historyReady Then
            Exit Sub
         End If
         Dim ddl As New TDdl()
         Dim hist As New TTableMigrations()
         ddl.CreateTable(hist.Schema)
         hist.Free()
         ddl.Free()
         me._historyReady = True
      End Sub

      Sub LoadApplied()
         If me._appliedReady Then
            Exit Sub
         End If
         If Not Assigned(me._applied) Then
            me._applied = New StringList()
         Else
            me._applied.Clear()
         End If
         Dim probe As New TTableMigrations()
         Dim rows[] As TTable = probe.Fetch("", "Id")
         Dim i As Integer
         For i = 0 To rows.Length - 1
            Dim rec As TTableMigrations = TTableMigrations(rows.Take(i))
            me._applied.Add(rec.IdValue)
         Next
         rows.OwnsObjects = False
         rows.Free()
         probe.Free()
         me._appliedReady = True
      End Sub

      Function AppliedIds() As StringList
         me.LoadApplied()
         Dim ids As New StringList()
         ids.Assign(me._applied)
         AppliedIds = ids
      End Function

      Function Pending() As TTList<TMigration>
         Dim applied As StringList = me.AppliedIds()
         Dim _pending[] As TMigration = []
         _pending.OwnsObjects = False
         Dim i As Integer
         For i = 0 To me.Migrations.Length - 1
            Dim m As TMigration = me.Migrations.Take(i)
            If applied.IndexOf(m.Id()) < 0 Then
               _pending.Push(m.Id(), m)
            End If
         Next
         applied.Free()
         Pending = _pending
      End Function

      Sub SortById(pList[] As TMigration)
         Dim i As Integer
         Dim j As Integer
         For i = 0 To pList.Length - 2
            For j = i + 1 To pList.Length - 1
               Dim a As TMigration = pList.Take(i)
               Dim b As TMigration = pList.Take(j)
               If a.Id() > b.Id() Then
                  pList.Item(i) = b
                  pList.Item(j) = a
               End If
            Next
         Next
      End Sub

      Sub RecordApplied(pId As String)
         Dim rec As New TTableMigrations()
         rec.IdValue = pId
         rec.AppliedAt = DateTime()
         rec.Insert()
         rec.Free()
         If me._appliedReady Then
            If me._applied.IndexOf(pId) < 0 Then
               me._applied.Add(pId)
            End If
         End If
      End Sub

      Sub ForgetApplied(pId As String)
         Dim rec As New TTableMigrations()
         rec.IdValue = pId
         rec.Delete()
         rec.Free()
         If me._appliedReady Then
            Dim idx As Integer = me._applied.IndexOf(pId)
            If idx >= 0 Then
               me._applied.Delete(idx)
            End If
         End If
      End Sub

      Function LatestAppliedId() As String
         me.LoadApplied()
         If me._applied.Count = 0 Then
            LatestAppliedId = ""
            Exit Function
         End If
         Dim best As String = me._applied.Strings(0)
         Dim i As Integer
         For i = 1 To me._applied.Count - 1
            If me._applied.Strings(i) > best Then
               best = me._applied.Strings(i)
            End If
         Next
         LatestAppliedId = best
      End Function

      Function FindRegistered(pId As String) As TMigration
         If me.Migrations.Includes(pId) Then
            FindRegistered = me.Migrations.Take(pId)
         Else
            FindRegistered = Null
         End If
      End Function

      Sub ExecuteOne(pMig As TMigration, pCtx As TMigrationContext)
         pMig.Up(pCtx)
         me.RecordApplied(pMig.Id())
      End Sub

      Sub RollbackOne(pMig As TMigration, pCtx As TMigrationContext)
         pMig.Down(pCtx)
         me.ForgetApplied(pMig.Id())
      End Sub

      Function Execute() As Integer
         me.EnsureHistory()
         Dim pend[] As TMigration = me.Pending()
         pend.OwnsObjects = False
         me.SortById(pend)
         Dim n As Integer = 0
         Dim ctx As New TMigrationContext()
         Dim useTx As Boolean = TSql.Dialect().SupportsDdlInTransaction()
         Dim ownTx As Boolean = False
         Try
            If useTx Then
               If Not SQL.Connection.InTransaction() Then
                  SQL.Connection.StartTransaction()
                  ownTx = True
               End If
            End If
            Dim i As Integer
            For i = 0 To pend.Length - 1
               me.ExecuteOne(pend.Take(i), ctx)
               n = n + 1
            Next
            If ownTx Then
               If SQL.Connection.InTransaction() Then
                  SQL.Connection.Commit()
               End If
            End If
         Catch ex As Exception
            If SQL.Connection.InTransaction() Then
               SQL.Connection.RollBack()
            End If
            me.InvalidateApplied()
            pend.Free()
            ctx.Free()
            Throw New Exception("Erro ao executar migração: " & ex.Message)
         End Try
         Execute = n
         pend.Free()
         ctx.Free()
      End Function

      Sub RollbackLast()
         me.EnsureHistory()
         Dim last As String = me.LatestAppliedId()
         If Trim(last) = "" Then
            Exit Sub
         End If
         me.Rollback(last)
      End Sub

      Sub Rollback(pId As String)
         me.EnsureHistory()
         Dim last As String = me.LatestAppliedId()
         If last <> pId Then
            Throw New Exception("Rollback só é permitido na migração mais recente. Atual: " & last & " pedido: " & pId)
         End If
         Dim mig As TMigration = me.FindRegistered(pId)
         If Not Assigned(mig) Then
            Throw New Exception("Migração não registrada para Down: " & pId)
         End If
         Dim ctx As New TMigrationContext()
         Dim useTx As Boolean = TSql.Dialect().SupportsDdlInTransaction()
         Dim ownTx As Boolean = False
         Try
            If useTx Then
               If Not SQL.Connection.InTransaction() Then
                  SQL.Connection.StartTransaction()
                  ownTx = True
               End If
            End If
            me.RollbackOne(mig, ctx)
            If ownTx Then
               If SQL.Connection.InTransaction() Then
                  SQL.Connection.Commit()
               End If
            End If
         Catch ex As Exception
            If SQL.Connection.InTransaction() Then
               SQL.Connection.RollBack()
            End If
            me.InvalidateApplied()
            ctx.Free()
            Throw New Exception("Erro ao executar migração: " & ex.Message)
         End Try
         ctx.Free()
      End Sub

      Sub RollbackTo(pId As String)
         me.EnsureHistory()
         Dim ids As StringList = me.AppliedIds()
         Dim toUndo As New StringList()
         Dim i As Integer
         For i = 0 To ids.Count - 1
            If ids.Strings(i) > pId Then
               toUndo.Add(ids.Strings(i))
            End If
         Next
         ids.Free()
         Dim a As Integer
         Dim b As Integer
         For a = 0 To toUndo.Count - 2
            For b = a + 1 To toUndo.Count - 1
               If toUndo.Strings(a) < toUndo.Strings(b) Then
                  Dim tmp As String = toUndo.Strings(a)
                  toUndo.Strings(a) = toUndo.Strings(b)
                  toUndo.Strings(b) = tmp
               End If
            Next
         Next
         For i = 0 To toUndo.Count - 1
            me.Rollback(toUndo.Strings(i))
         Next
         toUndo.Free()
      End Sub

      Overrides Sub Dispose()
         If Assigned(me.Migrations) Then
            me.Migrations.Free()
            me.Migrations = Null
         End If
         If Assigned(me._applied) Then
            me._applied.Free()
            me._applied = Null
         End If
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New TMigrationRunner()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
