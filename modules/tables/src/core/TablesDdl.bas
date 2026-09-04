Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports TablesField
Imports TablesSchema
Imports TablesSql
Imports TablesSequence

Namespace TablesDdl

   Private Dim _ddlReady As Boolean
   Private Dim _ddlCreateTable As TDdlOpKind
   Private Dim _ddlDropTable As TDdlOpKind
   Private Dim _ddlAddColumn As TDdlOpKind
   Private Dim _ddlDropColumn As TDdlOpKind
   Private Dim _ddlRenameColumn As TDdlOpKind
   Private Dim _ddlAlterColumn As TDdlOpKind
   Private Dim _ddlEnsureSequence As TDdlOpKind
   Private Dim _ddlDropSequence As TDdlOpKind
   Private Dim _ddlCustomSql As TDdlOpKind
   Private Dim _alterRebuild As TAlterColumnMode
   Private Dim _alterAutomatic As TAlterColumnMode

   Class TDdl
      Inherits TTObject

      Sub New()
         MyBase.New()
         TDdl.EnsureKinds()
      End Sub

      Shared Sub EnsureKinds()
         If Not _ddlReady Then
            _ddlCreateTable = TFieldCache.DdlCreateTable()
            _ddlDropTable = TFieldCache.DdlDropTable()
            _ddlAddColumn = TFieldCache.DdlAddColumn()
            _ddlDropColumn = TFieldCache.DdlDropColumn()
            _ddlRenameColumn = TFieldCache.DdlRenameColumn()
            _ddlAlterColumn = TFieldCache.DdlAlterColumn()
            _ddlEnsureSequence = TFieldCache.DdlEnsureSequence()
            _ddlDropSequence = TFieldCache.DdlDropSequence()
            _ddlCustomSql = TFieldCache.DdlCustomSql()
            _alterRebuild = TFieldCache.AlterRebuild()
            _alterAutomatic = TFieldCache.AlterAutomatic()
            _ddlReady = True
         End If
      End Sub

      Function TableExists(pTable As String) As Boolean
         TableExists = TSql.ExistsFlag(TSql.Dialect().SqlTableExists(pTable))
      End Function

      Function ColumnExists(pTable As String, pCol As String) As Boolean
         ColumnExists = TSql.ExistsFlag(TSql.Dialect().SqlColumnExists(pTable, pCol))
      End Function

      Function ListColumnNames(pTable As String) As StringList
         ListColumnNames = TSql.FetchStringColumn(TSql.Dialect().SqlListColumns(pTable), "col")
      End Function

      Function HasColumnName(pColNames As StringList, pCol As String) As Boolean
         HasColumnName = pColNames.IndexOf(UCase(Trim(pCol))) >= 0
      End Function

      Function SequenceExists(pName As String) As Boolean
         SequenceExists = TSql.ExistsFlag(TSql.Dialect().SqlSequenceExists(pName))
      End Function

      Sub CreateTable(pSchema As TTableSchema)
         If me.TableExists(pSchema.TableName) Then
            Exit Sub
         End If
         TSql.ExecScript(TSql.Dialect().SqlCreateTable(pSchema))
      End Sub

      Sub DropTable(pTable As String)
         If TSql.Dialect().SupportsDropIfExists() Then
            TSql.ExecScript(TSql.Dialect().SqlDropTable(pTable))
         Else
            If Not me.TableExists(pTable) Then
               Exit Sub
            End If
            TSql.ExecScript(TSql.Dialect().SqlDropTable(pTable))
         End If
      End Sub

      Sub AddColumn(pTable As String, pField As TFieldDef)
         If me.ColumnExists(pTable, pField.DbName) Then
            Exit Sub
         End If
         TSql.ExecScript(TSql.Dialect().SqlAddColumn(pTable, pField))
      End Sub

      Sub DropColumn(pTable As String, pCol As String)
         If Not me.ColumnExists(pTable, pCol) Then
            Exit Sub
         End If
         TSql.ExecScript(TSql.Dialect().SqlDropColumn(pTable, pCol))
      End Sub

      Sub RenameColumn(pTable As String, pFrom As String, pTo As String)
         Dim colNames As StringList = me.ListColumnNames(pTable)
         If me.HasColumnName(colNames, pTo) Then
            colNames.Free()
            Exit Sub
         End If
         If Not me.HasColumnName(colNames, pFrom) Then
            colNames.Free()
            Exit Sub
         End If
         colNames.Free()
         TSql.ExecScript(TSql.Dialect().SqlRenameColumn(pTable, pFrom, pTo))
      End Sub

      Sub AlterColumn(pTable As String, pField As TFieldDef, pMode As TAlterColumnMode)
         If Not me.ColumnExists(pTable, pField.DbName) Then
            me.AddColumn(pTable, pField)
            Exit Sub
         End If
         Dim useRebuild As Boolean = pMode = _alterRebuild
         If pMode = _alterAutomatic Then
            useRebuild = Not TSql.Dialect().SupportsInPlaceAlterType(pField, pField)
         End If
         If useRebuild Then
            me.RebuildColumn(pTable, pField)
         Else
            TSql.ExecScript(TSql.Dialect().SqlAlterColumnType(pTable, pField))
         End If
      End Sub

      Sub RebuildColumn(pTable As String, pField As TFieldDef)
         Dim tmp As String = pField.DbName & "_tmp"
         Dim tmpDef As TFieldDef = TFieldDef(pField.Clone())
         tmpDef.DbName = tmp
         tmpDef.Name = tmp
         me.AddColumn(pTable, tmpDef)
         TSql.ExecScript(TSql.Dialect().SqlCastCopy(pTable, tmp, pField.DbName, pField))
         me.DropColumn(pTable, pField.DbName)
         me.RenameColumn(pTable, tmp, pField.DbName)
         tmpDef.Free()
      End Sub

      Sub SetNullability(pTable As String, pCol As String, pRequired As Boolean)
         TSql.ExecScript(TSql.Dialect().SqlSetNullability(pTable, pCol, pRequired))
      End Sub

      Sub CreateSequence(pName As String)
         Dim seq As New TSequence(pName)
         seq.CreateIfMissing()
         seq.Free()
      End Sub

      Sub DropSequence(pName As String)
         Dim seq As New TSequence(pName)
         seq.DropIfExists()
         seq.Free()
      End Sub

      Function OpCreateTable(pSchema As TTableSchema) As TDdlOp
         Dim op As New TDdlOp(_ddlCreateTable)
         op.TableName = pSchema.TableName
         op.SqlText = TSql.Dialect().SqlCreateTable(pSchema)
         OpCreateTable = op
      End Function

      Function OpDropTable(pTable As String) As TDdlOp
         Dim op As New TDdlOp(_ddlDropTable)
         op.TableName = pTable
         OpDropTable = op
      End Function

      Function OpAddColumn(pTable As String, pField As TFieldDef) As TDdlOp
         Dim op As New TDdlOp(_ddlAddColumn)
         op.TableName = pTable
         op.ColumnName = pField.DbName
         op.FieldDef = pField
         OpAddColumn = op
      End Function

      Function OpDropColumn(pTable As String, pCol As String) As TDdlOp
         Dim op As New TDdlOp(_ddlDropColumn)
         op.TableName = pTable
         op.ColumnName = pCol
         OpDropColumn = op
      End Function

      Function OpAlterColumn(pTable As String, pField As TFieldDef) As TDdlOp
         Dim op As New TDdlOp(_ddlAlterColumn)
         op.TableName = pTable
         op.ColumnName = pField.DbName
         op.FieldDef = pField
         OpAlterColumn = op
      End Function

      Function OpEnsureSequence(pName As String) As TDdlOp
         Dim op As New TDdlOp(_ddlEnsureSequence)
         op.SequenceName = pName
         OpEnsureSequence = op
      End Function

      Function OpsFromSchema(pSchema As TTableSchema) As TTList<TDdlOp>
         Dim ops[] As TDdlOp = []
         Dim colNames As StringList = me.ListColumnNames(pSchema.TableName)
         If colNames.Count = 0 Then
            ops.Push(me.OpCreateTable(pSchema))
         Else
            Dim persist[] As TFieldDef = pSchema.PersistFields()
            persist.OwnsObjects = False
            Dim i As Integer
            For i = 0 To persist.Length - 1
               Dim fieldDef As TFieldDef = persist.Take(i)
               If Not me.HasColumnName(colNames, fieldDef.DbName) Then
                  ops.Push(me.OpAddColumn(pSchema.TableName, fieldDef))
               End If
            Next
         End If
         colNames.Free()
         Dim seqName As String = TSql.ExplicitSequenceName(pSchema)
         If seqName <> "" Then
            If Not me.SequenceExists(seqName) Then
               ops.Push(me.OpEnsureSequence(seqName))
            End If
         End If
         OpsFromSchema = ops
      End Function

      Sub ApplyOp(pOp As TDdlOp)
         If pOp.Kind = _ddlCreateTable Then
            If Trim(pOp.SqlText) <> "" Then
               TSql.ExecScript(pOp.SqlText)
            End If
         ElseIf pOp.Kind = _ddlDropTable Then
            me.DropTable(pOp.TableName)
         ElseIf pOp.Kind = _ddlAddColumn Then
            TSql.ExecScript(TSql.Dialect().SqlAddColumn(pOp.TableName, pOp.FieldDef))
         ElseIf pOp.Kind = _ddlDropColumn Then
            me.DropColumn(pOp.TableName, pOp.ColumnName)
         ElseIf pOp.Kind = _ddlRenameColumn Then
            me.RenameColumn(pOp.TableName, pOp.ColumnName, pOp.ColumnNameTo)
         ElseIf pOp.Kind = _ddlAlterColumn Then
            me.AlterColumn(pOp.TableName, pOp.FieldDef, pOp.AlterMode)
         ElseIf pOp.Kind = _ddlEnsureSequence Then
            TSql.ExecScript(TSql.Dialect().SqlCreateSequence(pOp.SequenceName))
         ElseIf pOp.Kind = _ddlDropSequence Then
            me.DropSequence(pOp.SequenceName)
         ElseIf pOp.Kind = _ddlCustomSql Then
            TSql.ExecScript(pOp.SqlText)
         End If
      End Sub

      Sub ApplyOps(pOps[] As TDdlOp)
         Dim i As Integer
         For i = 0 To pOps.Length - 1
            me.ApplyOp(pOps.Take(i))
         Next
      End Sub

      Overrides Sub Dispose()
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New TDdl()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
