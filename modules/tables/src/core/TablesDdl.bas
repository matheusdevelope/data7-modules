Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports TablesField
Imports TablesSchema
Imports TablesSql
Imports TablesSequence

Namespace TablesDdl

   Class TDdl
      Inherits TTObject

      Sub New()
         MyBase.New()
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
         Dim useRebuild As Boolean = pMode.IsValue(TAlterColumnMode.Rebuild())
         If pMode.IsValue(TAlterColumnMode.Automatic()) Then
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
         Dim op As New TDdlOp(TDdlOpKind.CreateTable())
         op.TableName = pSchema.TableName
         op.SqlText = TSql.Dialect().SqlCreateTable(pSchema)
         OpCreateTable = op
      End Function

      Function OpDropTable(pTable As String) As TDdlOp
         Dim op As New TDdlOp(TDdlOpKind.DropTable())
         op.TableName = pTable
         OpDropTable = op
      End Function

      Function OpAddColumn(pTable As String, pField As TFieldDef) As TDdlOp
         Dim op As New TDdlOp(TDdlOpKind.AddColumn())
         op.TableName = pTable
         op.ColumnName = pField.DbName
         op.FieldDef = pField
         OpAddColumn = op
      End Function

      Function OpDropColumn(pTable As String, pCol As String) As TDdlOp
         Dim op As New TDdlOp(TDdlOpKind.DropColumn())
         op.TableName = pTable
         op.ColumnName = pCol
         OpDropColumn = op
      End Function

      Function OpAlterColumn(pTable As String, pField As TFieldDef) As TDdlOp
         Dim op As New TDdlOp(TDdlOpKind.AlterColumn())
         op.TableName = pTable
         op.ColumnName = pField.DbName
         op.FieldDef = pField
         OpAlterColumn = op
      End Function

      Function OpEnsureSequence(pName As String) As TDdlOp
         Dim op As New TDdlOp(TDdlOpKind.EnsureSequence())
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
         If pOp.Kind.IsValue(TDdlOpKind.CreateTable()) Then
            If Trim(pOp.SqlText) <> "" Then
               TSql.ExecScript(pOp.SqlText)
            End If
         ElseIf pOp.Kind.IsValue(TDdlOpKind.DropTable()) Then
            me.DropTable(pOp.TableName)
         ElseIf pOp.Kind.IsValue(TDdlOpKind.AddColumn()) Then
            TSql.ExecScript(TSql.Dialect().SqlAddColumn(pOp.TableName, pOp.FieldDef))
         ElseIf pOp.Kind.IsValue(TDdlOpKind.DropColumn()) Then
            me.DropColumn(pOp.TableName, pOp.ColumnName)
         ElseIf pOp.Kind.IsValue(TDdlOpKind.RenameColumn()) Then
            me.RenameColumn(pOp.TableName, pOp.ColumnName, pOp.ColumnNameTo)
         ElseIf pOp.Kind.IsValue(TDdlOpKind.AlterColumn()) Then
            me.AlterColumn(pOp.TableName, pOp.FieldDef, pOp.AlterMode)
         ElseIf pOp.Kind.IsValue(TDdlOpKind.EnsureSequence()) Then
            TSql.ExecScript(TSql.Dialect().SqlCreateSequence(pOp.SequenceName))
         ElseIf pOp.Kind.IsValue(TDdlOpKind.DropSequence()) Then
            me.DropSequence(pOp.SequenceName)
         ElseIf pOp.Kind.IsValue(TDdlOpKind.CustomSql()) Then
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
