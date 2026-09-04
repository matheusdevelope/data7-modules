Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports TablesField
Imports TablesTable
Imports TablesSequence
Imports TablesSql

Namespace TablesExecutor

   Private Dim _execReady As Boolean
   Private Dim _opInsert As TTableOp
   Private Dim _opUpdate As TTableOp
   Private Dim _opDelete As TTableOp
   Private Dim _opUpsert As TTableOp
   Private Dim _opMerge As TTableOp
   Private Dim _opCustom As TTableOp
   Private Dim _commitSingle As TCommitMode
   Private Dim _commitPerBatch As TCommitMode
   Private Dim _commitPerStatement As TCommitMode
   Private Dim _commitJoinExisting As TCommitMode

   Class TWorkItem
      Inherits TTObject

      Op As TTableOp
      Table As TTable
      SqlText As String

      Sub New(pOp As TTableOp)
         MyBase.New()
         me.Op = pOp
         me.SqlText = ""
      End Sub

      Overrides Function GetID() As String
         If Assigned(me.Table) Then
            GetID = me.Op.AsString & "|" & me.Table.Schema.CacheKey
         Else
            GetID = me.Op.AsString & "|sql"
         End If
      End Function

      Overrides Function Clone() As TTObject
         Dim n As New TWorkItem(me.Op)
         n.Table = me.Table
         n.SqlText = me.SqlText
         Clone = n
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TExecutor
      Inherits TTObject

      BatchSize As Integer
      Queue[] As TWorkItem
      Leases[] As TSequenceLease

      Private _commitMode As TCommitMode
      Private _rewindOnError As Boolean
      Private _rewindSet As Boolean
      Private _keysAssigned As Boolean

      Sub New()
         MyBase.New()
         TExecutor.EnsureKinds()
         me.BatchSize = 50
         me.Queue = []
         me.Queue.OwnsObjects = True
         me.Leases = []
         me.Leases.OwnsObjects = True
         me._commitMode = _commitSingle
         me._rewindOnError = True
         me._rewindSet = False
         me._keysAssigned = False
      End Sub

      Shared Sub EnsureKinds()
         If Not _execReady Then
            _opInsert = TFieldCache.OpInsert()
            _opUpdate = TFieldCache.OpUpdate()
            _opDelete = TFieldCache.OpDelete()
            _opUpsert = TFieldCache.OpUpsert()
            _opMerge = TFieldCache.OpMerge()
            _opCustom = TFieldCache.OpCustom()
            _commitSingle = TFieldCache.CommitSingle()
            _commitPerBatch = TFieldCache.CommitPerBatch()
            _commitPerStatement = TFieldCache.CommitPerStatement()
            _commitJoinExisting = TFieldCache.CommitJoinExisting()
            _execReady = True
         End If
      End Sub

      Property CommitMode As TCommitMode
         Get
            CommitMode = me._commitMode
         End Get
         Set(pValue As TCommitMode)
            me._commitMode = pValue
            If Not me._rewindSet Then
               me._rewindOnError = (pValue = _commitSingle) Or (pValue = _commitJoinExisting)
            End If
         End Set
      End Property

      Property RewindOnError As Boolean
         Get
            RewindOnError = me._rewindOnError
         End Get
         Set(pValue As Boolean)
            me._rewindOnError = pValue
            me._rewindSet = True
         End Set
      End Property

      Sub AddInsert(pRow As TTable)
         Dim item As New TWorkItem(_opInsert)
         item.Table = pRow
         me.Queue.Push(CStr(me.Queue.Length), item)
      End Sub

      Sub AddUpdate(pRow As TTable)
         Dim item As New TWorkItem(_opUpdate)
         item.Table = pRow
         me.Queue.Push(CStr(me.Queue.Length), item)
      End Sub

      Sub AddDelete(pRow As TTable)
         Dim item As New TWorkItem(_opDelete)
         item.Table = pRow
         me.Queue.Push(CStr(me.Queue.Length), item)
      End Sub

      Sub AddUpsert(pRow As TTable)
         Dim item As New TWorkItem(_opUpsert)
         item.Table = pRow
         me.Queue.Push(CStr(me.Queue.Length), item)
      End Sub

      Sub AddMerge(pRow As TTable)
         Dim item As New TWorkItem(_opMerge)
         item.Table = pRow
         me.Queue.Push(CStr(me.Queue.Length), item)
      End Sub

      Sub AddSql(pSql As String)
         Dim item As New TWorkItem(_opCustom)
         item.SqlText = pSql
         me.Queue.Push(CStr(me.Queue.Length), item)
      End Sub

      Sub AddInsert(pRows[] As TTable)
         Dim i As Integer
         For i = 0 To pRows.Length - 1
            me.AddInsert(pRows.Take(i))
         Next
      End Sub

      Sub AddUpdate(pRows[] As TTable)
         Dim i As Integer
         For i = 0 To pRows.Length - 1
            me.AddUpdate(pRows.Take(i))
         Next
      End Sub

      Function SequenceNameOf(pRow As TTable) As String
         SequenceNameOf = TSql.ExplicitSequenceName(pRow.Schema)
      End Function

      Function IsInsertLike(pItem As TWorkItem) As Boolean
         IsInsertLike = (pItem.Op = _opInsert) Or (pItem.Op = _opUpsert) Or (pItem.Op = _opMerge)
      End Function

      Sub AssignKeys()
         If me._keysAssigned Then
            Exit Sub
         End If
         Dim i As Integer
         For i = 0 To me.Queue.Length - 1
            Dim item As TWorkItem = me.Queue.Take(i)
            If Assigned(item.Table) Then
               If me.IsInsertLike(item) Then
                  If item.Table.NeedsAutoCode() Then
                     item.Table.EnsurePrimaryKey()
                  End If
               End If
            End If
         Next
         me._keysAssigned = True
      End Sub

      Function ExecItem(pItem As TWorkItem) As Integer
         If pItem.Op = _opCustom Then
            ExecItem = TSql.ExecScript(pItem.SqlText)
            Exit Function
         End If
         Dim op As TTableOp = pItem.Op
         If op = _opUpsert Then
            If pItem.Table.ExistsByPk() Then
               op = _opUpdate
            Else
               op = _opInsert
            End If
         End If
         If op = _opMerge Then
            pItem.Table.EnsurePrimaryKey()
         End If
         Dim query As SQL.Command = pItem.Table.PreparedCommand(op)
         ExecItem = pItem.Table.ApplyDml(op, query)
      End Function

      Sub BeginTxIfNeeded(pOwn As Boolean)
         If Not pOwn Then
            Exit Sub
         End If
         If Not SQL.Connection.InTransaction() Then
            SQL.Connection.StartTransaction()
         End If
      End Sub

      Sub CommitTxIfNeeded(pOwn As Boolean)
         If Not pOwn Then
            Exit Sub
         End If
         If SQL.Connection.InTransaction() Then
            SQL.Connection.Commit()
         End If
      End Sub

      Sub RollbackTxIfNeeded(pOwn As Boolean)
         If SQL.Connection.InTransaction() Then
            SQL.Connection.RollBack()
         End If
      End Sub

      Sub CommitLeases()
         Dim i As Integer
         For i = 0 To me.Leases.Length - 1
            me.Leases.Take(i).Commit()
         Next
      End Sub

      Sub RewindLeases()
         Dim i As Integer
         For i = 0 To me.Leases.Length - 1
            me.Leases.Take(i).Rollback()
         Next
      End Sub

      Function Exec() As Integer
         Dim total As Integer = 0
         me.AssignKeys()
         Dim ownTx As Boolean = me._commitMode <> _commitJoinExisting
         Dim perStmt As Boolean = me._commitMode = _commitPerStatement
         Dim _perBatch As Boolean = me._commitMode = _commitPerBatch
         Dim batchCount As Integer = 0
         Try
            If Not perStmt Then
               me.BeginTxIfNeeded(ownTx)
            End If
            Dim i As Integer
            For i = 0 To me.Queue.Length - 1
               If perStmt Then
                  me.BeginTxIfNeeded(ownTx)
               End If
               total = total + me.ExecItem(me.Queue.Take(i))
               batchCount = batchCount + 1
               If perStmt Then
                  me.CommitTxIfNeeded(ownTx)
                  batchCount = 0
               ElseIf _perBatch = True Then
                  If batchCount >= me.BatchSize Then
                     me.CommitTxIfNeeded(ownTx)
                     batchCount = 0
                     If i < me.Queue.Length - 1 Then
                        me.BeginTxIfNeeded(ownTx)
                     End If
                  End If
               End If
            Next
            If ownTx And Not perStmt Then
               If SQL.Connection.InTransaction() Then
                  SQL.Connection.Commit()
               End If
            End If
            me.CommitLeases()
         Catch ex As Exception
            me.RollbackTxIfNeeded(ownTx)
            If me._rewindOnError Then
               me.RewindLeases()
            End If
            Throw New Exception("Erro ao executar ação em lote")
         End Try
         Exec = total
      End Function

      Sub Clear()
         me.Queue.Free()
         me.Queue = []
         me.Leases.Free()
         me.Leases = []
         me._keysAssigned = False
      End Sub

      Overrides Sub Dispose()
         If Assigned(me.Queue) Then
            me.Queue.Free()
            me.Queue = Null
         End If
         If Assigned(me.Leases) Then
            me.Leases.Free()
            me.Leases = Null
         End If
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New TExecutor()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
