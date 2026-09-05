Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports TablesField
Imports TablesSchema

Namespace TablesSql

   Private Dim _resReady As Boolean
   Private Dim _resTrigger As TResourceKind
   Private Dim _resProcedure As TResourceKind
   Private Dim _resFunc As TResourceKind
   Private Dim _resView As TResourceKind
   Private Dim _resIndex As TResourceKind
   Private Dim _kindString As TKindField
   Private Dim _kindInteger As TKindField
   Private Dim _kindFloat As TKindField
   Private Dim _kindBoolean As TKindField
   Private Dim _kindDate As TKindField
   Private Dim _kindDateTime As TKindField

   MustInherit Class TSqlDialect
      Inherits TTObject

      Sub New()
         MyBase.New()
         TSqlDialect.EnsureKinds()
      End Sub

      Shared Sub EnsureKinds()
         If Not _resReady Then
            _resTrigger = TFieldCache.ResourceTrigger()
            _resProcedure = TFieldCache.ResourceProcedure()
            _resFunc = TFieldCache.ResourceFunc()
            _resView = TFieldCache.ResourceView()
            _resIndex = TFieldCache.ResourceIndex()
            _kindString = TFieldCache.KindString()
            _kindInteger = TFieldCache.KindInteger()
            _kindFloat = TFieldCache.KindFloat()
            _kindBoolean = TFieldCache.KindBoolean()
            _kindDate = TFieldCache.KindDate()
            _kindDateTime = TFieldCache.KindDateTime()
            _resReady = True
         End If
      End Sub

      Function JoinComma(pParts As StringList) As String
         Dim s As String = pParts.Text
         Dim sep As String = pParts.LineBreak
         Dim nSep As Integer = sep.Length
         If (nSep > 0) And (s.Length >= nSep) Then
            If s.Right(nSep) = sep Then
               s = s.Left(s.Length - nSep)
            End If
         End If
         JoinComma = Trim(s)
      End Function

      Overridable Function QuoteIdent(pName As String) As String
         QuoteIdent = """" & pName & """"
      End Function

      Overridable Function QuoteTable(pSchemaName As String, pTable As String) As String
         If Trim(pSchemaName) = "" Then
            QuoteTable = me.QuoteIdent(pTable)
         Else
            QuoteTable = me.QuoteIdent(pSchemaName) & "." & me.QuoteIdent(pTable)
         End If
      End Function

      Overridable Function QuoteSequence(pName As String) As String
         QuoteSequence = me.QuoteIdent(pName)
      End Function

      Overridable Function DefaultSchema() As String
         DefaultSchema = "dbo"
      End Function

      Overridable Function IsDefaultSchema(pSchemaName As String) As Boolean
         If Trim(pSchemaName) = "" Then
            IsDefaultSchema = True
         Else
            IsDefaultSchema = (UCase(Trim(pSchemaName)) = UCase(Trim(me.DefaultSchema())))
         End If
      End Function

      Overridable Function ParamToken(pName As String) As String
         ParamToken = ":" & pName
      End Function

      Overridable Function SqlParam(pField As TFieldDef) As String
         SqlParam = me.ParamToken(pField.ParamName)
      End Function

      Overridable Function NumericDbType(pField As TFieldDef, pFloatFallback As String) As String
         If pField.Precision > 0 Then
            NumericDbType = "NUMERIC(" & CStr(pField.Precision) & ", " & CStr(pField.Scale) & ")"
         Else
            NumericDbType = pFloatFallback
         End If
      End Function

      Overridable Function IsNumericNative(pNative As String) As Boolean
         Dim n As String = UCase(Trim(pNative))
         IsNumericNative = (n = "NUMERIC" Or n = "DECIMAL" Or n = "NUMBER")
      End Function

      Overridable Function TypeName(pField As TFieldDef) As String
         If Trim(pField.DbType) <> "" Then
            TypeName = pField.DbType
            Exit Function
         End If
         If pField.KindId = 1 Then
            TypeName = "INTEGER"
         ElseIf pField.KindId = 2 Then
            TypeName = me.NumericDbType(pField, "DOUBLE PRECISION")
         ElseIf pField.KindId = 4 Then
            TypeName = "DATE"
         ElseIf pField.KindId = 5 Then
            TypeName = "TIMESTAMP"
         Else
            TypeName = "VARCHAR(" & CStr(pField.MaxLength) & ")"
         End If
      End Function

      Overridable Function SqlTableExists(pTable As String) As String
         SqlTableExists = "SELECT 0 AS ok"
      End Function

      Overridable Function SqlColumnExists(pTable As String, pCol As String) As String
         SqlColumnExists = "SELECT 0 AS ok"
      End Function

      Overridable Function SqlListColumns(pTable As String) As String
         SqlListColumns = "SELECT CAST('' AS VARCHAR(1)) AS col WHERE 1 = 0"
      End Function

      Overridable Function SqlDescribeColumns(pSchemaName As String, pTable As String) As String
         SqlDescribeColumns = "SELECT CAST('' AS VARCHAR(1)) AS col, CAST('' AS VARCHAR(1)) AS typ, 0 AS max_len, 0 AS num_prec, 0 AS num_scale, 0 AS is_pk, 1 AS is_null, 0 AS is_ident WHERE 1 = 0"
      End Function

      Overridable Function MapFieldKind(pNative As String) As TKindField
         Dim n As String = UCase(Trim(pNative))
         If n = "INT" Or n = "INTEGER" Or n = "SMALLINT" Or n = "TINYINT" Or n = "BIGINT" Or n = "INT2" Or n = "INT4" Or n = "INT8" Or n = "SERIAL" Or n = "BIGSERIAL" Or n = "SMALLSERIAL" Then
            MapFieldKind = _kindInteger
         ElseIf n = "FLOAT" Or n = "REAL" Or n = "DOUBLE" Or n = "DOUBLE PRECISION" Or n = "NUMERIC" Or n = "DECIMAL" Or n = "MONEY" Or n = "NUMBER" Or n = "FLOAT4" Or n = "FLOAT8" Then
            MapFieldKind = _kindFloat
         ElseIf n = "BIT" Or n = "BOOLEAN" Or n = "BOOL" Then
            MapFieldKind = _kindBoolean
         ElseIf n = "DATE" Then
            MapFieldKind = _kindDate
         ElseIf n = "DATETIME" Or n = "DATETIME2" Or n = "SMALLDATETIME" Or n = "TIMESTAMP" Or n = "TIMESTAMPTZ" Or n = "TIME" Or n = "TIMETZ" Then
            MapFieldKind = _kindDateTime
         Else
            MapFieldKind = _kindString
         End If
      End Function

      Overridable Function SqlSequenceExists(pName As String) As String
         SqlSequenceExists = "SELECT 0 AS ok"
      End Function

      Overridable Function SqlRoutineExists(pKind As TResourceKind, pName As String) As String
         SqlRoutineExists = "SELECT 0 AS ok"
      End Function

      Overridable Function SqlCreateTable(pSchema As TTableSchema) As String
         Dim sqlText As String = "CREATE TABLE " & me.QuoteIdent(pSchema.TableName) & " ("
         Dim pk As String = ""
         Dim i As Integer
         Dim first As Boolean = True
         Dim persist[] As TFieldDef = pSchema.PersistFields()
         For i = 0 To persist.Length - 1
            Dim f As TFieldDef = persist.Take(i)
            If Not first Then
               sqlText = sqlText & ", "
            End If
            first = False
            sqlText = sqlText & me.QuoteIdent(f.DbName) & " " & me.TypeName(f)
            If f.Required Then
               sqlText = sqlText & " NOT NULL"
            End If
            If f.PrimaryKey Then
               If pk <> "" Then
                  pk = pk & ", "
               End If
               pk = pk & me.QuoteIdent(f.DbName)
            End If
         Next
         If pk <> "" Then
            sqlText = sqlText & ", PRIMARY KEY (" & pk & ")"
         End If
         sqlText = sqlText & ")"
         SqlCreateTable = sqlText
      End Function

      Overridable Function SqlDropTable(pTable As String) As String
         SqlDropTable = "DROP TABLE " & me.QuoteIdent(pTable)
      End Function

      Overridable Function SqlAddColumn(pTable As String, pField As TFieldDef) As String
         Dim sqlText As String = "ALTER TABLE " & me.QuoteIdent(pTable) & " ADD " & me.QuoteIdent(pField.DbName) & " " & me.TypeName(pField)
         If pField.Required Then
            sqlText = sqlText & " NOT NULL"
         End If
         SqlAddColumn = sqlText
      End Function

      Overridable Function SqlDropColumn(pTable As String, pCol As String) As String
         SqlDropColumn = "ALTER TABLE " & me.QuoteIdent(pTable) & " DROP COLUMN " & me.QuoteIdent(pCol)
      End Function

      Overridable Function SqlRenameColumn(pTable As String, pFrom As String, pTo As String) As String
         SqlRenameColumn = "ALTER TABLE " & me.QuoteIdent(pTable) & " RENAME COLUMN " & me.QuoteIdent(pFrom) & " TO " & me.QuoteIdent(pTo)
      End Function

      Overridable Function SqlAlterColumnType(pTable As String, pField As TFieldDef) As String
         SqlAlterColumnType = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER COLUMN " & me.QuoteIdent(pField.DbName) & " TYPE " & me.TypeName(pField)
      End Function

      Overridable Function SqlSetNullability(pTable As String, pCol As String, pRequired As Boolean) As String
         If pRequired Then
            SqlSetNullability = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER COLUMN " & me.QuoteIdent(pCol) & " SET NOT NULL"
         Else
            SqlSetNullability = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER COLUMN " & me.QuoteIdent(pCol) & " DROP NOT NULL"
         End If
      End Function

      Overridable Function SqlCreateSequence(pName As String) As String
         SqlCreateSequence = "CREATE SEQUENCE " & me.QuoteSequence(pName)
      End Function

      Overridable Function SqlDropSequence(pName As String) As String
         SqlDropSequence = "DROP SEQUENCE " & me.QuoteSequence(pName)
      End Function

      Overridable Function SqlRestartSequence(pName As String, pNext As Integer) As String
         SqlRestartSequence = "ALTER SEQUENCE " & me.QuoteSequence(pName) & " RESTART WITH " & CStr(pNext)
      End Function

      Overridable Function SqlPeekSequence(pName As String) As String
         SqlPeekSequence = "SELECT 0 AS v"
      End Function

      Overridable Function SqlAllocateSequence(pName As String, pCount As Integer) As String
         SqlAllocateSequence = me.SqlRestartSequence(pName, pCount)
      End Function

      Overridable Function SqlCreateOrAlter(pKind As TResourceKind, pName As String, pBody As String) As String
         If UCase(Trim(pBody)).StartsWith("CREATE") Then
            SqlCreateOrAlter = pBody
         Else
            SqlCreateOrAlter = pBody
         End If
      End Function

      Overridable Function SqlDropRoutine(pKind As TResourceKind, pName As String) As String
         If pKind = _resTrigger Then
            SqlDropRoutine = "DROP TRIGGER " & me.QuoteIdent(pName)
         ElseIf pKind = _resProcedure Then
            SqlDropRoutine = "DROP PROCEDURE " & me.QuoteIdent(pName)
         ElseIf pKind = _resFunc Then
            SqlDropRoutine = "DROP FUNCTION " & me.QuoteIdent(pName)
         ElseIf pKind = _resView Then
            SqlDropRoutine = "DROP VIEW " & me.QuoteIdent(pName)
         Else
            SqlDropRoutine = "DROP INDEX " & me.QuoteIdent(pName)
         End If
      End Function

      Overridable Function SqlCreateOrReplaceView(pName As String, pSelect As String) As String
         SqlCreateOrReplaceView = "CREATE OR REPLACE VIEW " & me.QuoteIdent(pName) & " AS " & pSelect
      End Function

      Overridable Function SqlCreateOrReplaceProcedure(pName As String) As String
         SqlCreateOrReplaceProcedure = "CREATE OR REPLACE PROCEDURE " & me.QuoteIdent(pName) & "() BEGIN SELECT 1 AS ok; END"
      End Function

      Overridable Function SqlCreateOrReplaceIntFunction(pName As String) As String
         SqlCreateOrReplaceIntFunction = "CREATE OR REPLACE FUNCTION " & me.QuoteIdent(pName) & "(n INTEGER) RETURNS INTEGER BEGIN RETURN n * 2; END"
      End Function

      Overridable Function SqlCallIntFunction(pName As String, pArg As Integer) As String
         SqlCallIntFunction = me.QuoteIdent(pName) & "(" & CStr(pArg) & ")"
      End Function

      Overridable Function SqlCreateIndexOnTable(pIndex As String, pTable As String, pColumn As String) As String
         SqlCreateIndexOnTable = "CREATE INDEX " & me.QuoteIdent(pIndex) & " ON " & me.QuoteIdent(pTable) & " (" & me.QuoteIdent(pColumn) & ")"
      End Function

      Overridable Function SqlDropIndexOnTable(pIndex As String, pTable As String) As String
         SqlDropIndexOnTable = "DROP INDEX " & me.QuoteIdent(pIndex)
      End Function

      Overridable Function SqlBeginBlock() As String
         SqlBeginBlock = "BEGIN"
      End Function

      Overridable Function SqlEndBlock() As String
         SqlEndBlock = "END"
      End Function

      Overridable Function SupportsDdlInTransaction() As Boolean
         SupportsDdlInTransaction = True
      End Function

      Overridable Function SupportsDropIfExists() As Boolean
         SupportsDropIfExists = False
      End Function

      Overridable Function SupportsInPlaceAlterType(pFrom As TFieldDef, pTo As TFieldDef) As Boolean
         If pFrom.KindId = pTo.KindId Then
            If pFrom.KindId = 0 Then
               SupportsInPlaceAlterType = (pTo.MaxLength >= pFrom.MaxLength)
            Else
               SupportsInPlaceAlterType = True
            End If
         Else
            SupportsInPlaceAlterType = False
         End If
      End Function

      Overridable Function SqlCastCopy(pTable As String, pTmp As String, pOld As String, pField As TFieldDef) As String
         SqlCastCopy = "UPDATE " & me.QuoteIdent(pTable) & " SET " & me.QuoteIdent(pTmp) & " = CAST(" & me.QuoteIdent(pOld) & " AS " & me.TypeName(pField) & ")"
      End Function

      Overridable Function SqlMergeSourceFrom() As String
         SqlMergeSourceFrom = ""
      End Function

      Overridable Function SqlMergeTarget(pTable As String) As String
         SqlMergeTarget = pTable & " AS t"
      End Function

      Overridable Function SqlMergeTerminator() As String
         SqlMergeTerminator = ""
      End Function

      Overridable Function SqlTypedParam(pParamName As String, pTypeName As String) As String
         SqlTypedParam = "CAST(" & me.ParamToken(pParamName) & " AS " & pTypeName & ")"
      End Function

      Overridable Function SqlMerge(pTable As String, pPkNames As StringList, pInsertNames As StringList, pInsertParams As StringList, pInsertTypes As StringList, pUpdateNames As StringList) As String
         Dim usingParts As New StringList()
         Dim onParts As New StringList()
         Dim insCols As New StringList()
         Dim insVals As New StringList()
         Dim updParts As New StringList()
         usingParts.LineBreak = ", "
         onParts.LineBreak = " AND "
         insCols.LineBreak = ", "
         insVals.LineBreak = ", "
         updParts.LineBreak = ", "
         Dim nIns As Integer = pInsertNames.Count
         Dim nPk As Integer = pPkNames.Count
         Dim nUpd As Integer = pUpdateNames.Count
         usingParts.Capacity = nIns
         onParts.Capacity = nPk
         insCols.Capacity = nIns
         insVals.Capacity = nIns
         updParts.Capacity = nUpd
         usingParts.BeginUpdate()
         insCols.BeginUpdate()
         insVals.BeginUpdate()
         Dim i As Integer
         For i = 0 To nIns - 1
            Dim colq As String = me.QuoteIdent(pInsertNames.Strings(i))
            usingParts.Add(me.SqlTypedParam(pInsertParams.Strings(i), pInsertTypes.Strings(i)) & " AS " & colq)
            insCols.Add(colq)
            insVals.Add("s." & colq)
         Next
         usingParts.EndUpdate()
         insCols.EndUpdate()
         insVals.EndUpdate()
         onParts.BeginUpdate()
         For i = 0 To nPk - 1
            Dim pkq As String = me.QuoteIdent(pPkNames.Strings(i))
            onParts.Add("t." & pkq & " = s." & pkq)
         Next
         onParts.EndUpdate()
         Dim sqlText As String = "MERGE INTO " & me.SqlMergeTarget(pTable) & " USING (SELECT " & me.JoinComma(usingParts) & me.SqlMergeSourceFrom() & ") AS s ON " & me.JoinComma(onParts)
         If nUpd > 0 Then
            updParts.BeginUpdate()
            For i = 0 To nUpd - 1
               Dim uq As String = me.QuoteIdent(pUpdateNames.Strings(i))
               updParts.Add("t." & uq & " = s." & uq)
            Next
            updParts.EndUpdate()
            sqlText = sqlText & " WHEN MATCHED THEN UPDATE SET " & me.JoinComma(updParts)
         End If
         sqlText = sqlText & " WHEN NOT MATCHED THEN INSERT (" & me.JoinComma(insCols) & ") VALUES (" & me.JoinComma(insVals) & ")" & me.SqlMergeTerminator()
         usingParts.Free()
         onParts.Free()
         insCols.Free()
         insVals.Free()
         updParts.Free()
         SqlMerge = sqlText
      End Function

      Overridable Function NormalizeWhere(pWhere As String) As String
         Dim w As String = Trim(pWhere)
         If w.Length = 0 Then
            NormalizeWhere = ""
            Exit Function
         End If
         If UCase(w).StartsWith("WHERE ") Then
            NormalizeWhere = " WHERE " & Trim(w.Right(w.Length - 5))
         Else
            NormalizeWhere = " WHERE " & w
         End If
      End Function

      Overridable Function ApplyLimit(pSql As String, pLimit As Integer) As String
         If pLimit <= 0 Then
            ApplyLimit = pSql
            Exit Function
         End If
         ApplyLimit = Trim(pSql) & " LIMIT " & CStr(pLimit)
      End Function

      Function ApplyTopLimit(pSql As String, pLimit As Integer) As String
         If pLimit <= 0 Then
            ApplyTopLimit = pSql
            Exit Function
         End If
         Dim body As String = Trim(pSql)
         If UCase(body.Left(6)) <> "SELECT" Then
            ApplyTopLimit = body
            Exit Function
         End If
         Dim rest As String = Trim(body.Right(body.Length - 6))
         If rest.Length >= 4 Then
            If UCase(rest.Left(4)) = "TOP " Then
               ApplyTopLimit = body
               Exit Function
            End If
         End If
         ApplyTopLimit = "SELECT TOP " & CStr(pLimit) & " " & rest
      End Function

      Overridable Function NormalizeOrderBy(pOrder As String) As String
         Dim w As String = Trim(pOrder)
         If w.Length = 0 Then
            NormalizeOrderBy = ""
            Exit Function
         End If
         If UCase(w).StartsWith("ORDER ") Then
            NormalizeOrderBy = " " & w
         Else
            NormalizeOrderBy = " ORDER BY " & me.QuoteOrderExpr(w)
         End If
      End Function

      Overridable Function QuoteOrderExpr(pExpr As String) As String
         Dim w As String = Trim(pExpr)
         If w.Length = 0 Then
            QuoteOrderExpr = ""
            Exit Function
         End If
         If w.StartsWith("""") Or w.StartsWith("[") Then
            QuoteOrderExpr = w
            Exit Function
         End If
         Dim i As Integer
         For i = 0 To w.Length - 1
            If w.Right(w.Length - i).StartsWith(".") Then
               Dim head As String = w.Left(i)
               Dim tail As String = w.Right(w.Length - i - 1)
               QuoteOrderExpr = head & "." & me.QuoteOrderExpr(tail)
               Exit Function
            End If
         Next
         QuoteOrderExpr = me.QuoteIdent(w)
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TSqlDialectMssql
      Inherits TSqlDialect

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function QuoteIdent(pName As String) As String
         QuoteIdent = "[" & pName & "]"
      End Function

      Overrides Function ParamToken(pName As String) As String
         ParamToken = ":" & pName
      End Function

      Overrides Function TypeName(pField As TFieldDef) As String
         If Trim(pField.DbType) <> "" Then
            TypeName = pField.DbType
            Exit Function
         End If
         If pField.KindId = 1 Then
            TypeName = "INT"
         ElseIf pField.KindId = 2 Then
            TypeName = me.NumericDbType(pField, "FLOAT")
         ElseIf pField.KindId = 4 Then
            TypeName = "DATE"
         ElseIf pField.KindId = 5 Then
            TypeName = "DATETIME"
         Else
            TypeName = "VARCHAR(" & CStr(pField.MaxLength) & ")"
         End If
      End Function

      Overrides Function SqlTableExists(pTable As String) As String
         SqlTableExists = "SELECT CASE WHEN OBJECT_ID(N'" & pTable & "', N'U') IS NULL THEN 0 ELSE 1 END AS ok"
      End Function

      Overrides Function SqlColumnExists(pTable As String, pCol As String) As String
         SqlColumnExists = "SELECT CASE WHEN COL_LENGTH(N'" & pTable & "', N'" & pCol & "') IS NULL THEN 0 ELSE 1 END AS ok"
      End Function

      Overrides Function SqlListColumns(pTable As String) As String
         SqlListColumns = "SELECT name AS col FROM sys.columns WHERE object_id = OBJECT_ID(N'" & pTable & "')"
      End Function

      Overrides Function SqlDescribeColumns(pSchemaName As String, pTable As String) As String
         Dim objName As String = pTable
         If Trim(pSchemaName) <> "" Then
            objName = pSchemaName & "." & pTable
         End If
         SqlDescribeColumns = "SELECT c.name AS col, TYPE_NAME(c.user_type_id) AS typ, CASE WHEN TYPE_NAME(c.user_type_id) IN (N'nvarchar', N'nchar') AND c.max_length > 0 THEN c.max_length / 2 WHEN c.max_length < 0 THEN 8000 ELSE CAST(c.max_length AS INT) END AS max_len, CASE WHEN TYPE_NAME(c.user_type_id) IN (N'decimal', N'numeric') THEN CAST(c.precision AS INT) ELSE 0 END AS num_prec, CASE WHEN TYPE_NAME(c.user_type_id) IN (N'decimal', N'numeric') THEN CAST(c.scale AS INT) ELSE 0 END AS num_scale, CASE WHEN pk.cid IS NULL THEN 0 ELSE 1 END AS is_pk, CASE WHEN c.is_nullable = 1 THEN 1 ELSE 0 END AS is_null, CASE WHEN c.is_identity = 1 THEN 1 ELSE 0 END AS is_ident FROM sys.columns c LEFT JOIN (SELECT ic.object_id AS oid, ic.column_id AS cid FROM sys.index_columns ic INNER JOIN sys.indexes i ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND i.is_primary_key = 1) pk ON pk.oid = c.object_id AND pk.cid = c.column_id WHERE c.object_id = OBJECT_ID(N'" & objName & "') ORDER BY c.column_id"
      End Function

      Overrides Function SqlSequenceExists(pName As String) As String
         SqlSequenceExists = "SELECT CASE WHEN EXISTS(SELECT 1 FROM sys.sequences WHERE name = N'" & pName & "') THEN 1 ELSE 0 END AS ok"
      End Function

      Overrides Function SqlRoutineExists(pKind As TResourceKind, pName As String) As String
         Dim t As String = "P"
         If pKind = _resTrigger Then
            t = "TR"
         ElseIf pKind = _resFunc Then
            t = "FN"
         ElseIf pKind = _resView Then
            t = "V"
         End If
         If pKind = _resIndex Then
            SqlRoutineExists = "SELECT CASE WHEN EXISTS(SELECT 1 FROM sys.indexes WHERE name = N'" & pName & "') THEN 1 ELSE 0 END AS ok"
         Else
            SqlRoutineExists = "SELECT CASE WHEN OBJECT_ID(N'" & pName & "', N'" & t & "') IS NULL THEN 0 ELSE 1 END AS ok"
         End If
      End Function

      Overrides Function SqlRenameColumn(pTable As String, pFrom As String, pTo As String) As String
         SqlRenameColumn = "EXEC sp_rename N'" & pTable & "." & pFrom & "', N'" & pTo & "', N'COLUMN'"
      End Function

      Overrides Function SqlAlterColumnType(pTable As String, pField As TFieldDef) As String
         SqlAlterColumnType = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER COLUMN " & me.QuoteIdent(pField.DbName) & " " & me.TypeName(pField)
      End Function

      Overrides Function SqlSetNullability(pTable As String, pCol As String, pRequired As Boolean) As String
         SqlSetNullability = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER COLUMN " & me.QuoteIdent(pCol) & " " & pCol
      End Function

      Overrides Function SqlPeekSequence(pName As String) As String
         SqlPeekSequence = "SELECT CAST(current_value AS INT) AS v FROM sys.sequences WHERE name = N'" & pName & "'"
      End Function

      Overrides Function SqlAllocateSequence(pName As String, pCount As Integer) As String
         SqlAllocateSequence = "SELECT CAST(current_value AS INT) AS v FROM sys.sequences WHERE name = N'" & pName & "'"
      End Function

      Overrides Function SqlDropColumn(pTable As String, pCol As String) As String
         SqlDropColumn = "ALTER TABLE " & me.QuoteIdent(pTable) & " DROP COLUMN " & me.QuoteIdent(pCol)
      End Function

      Overrides Function SqlCreateOrAlter(pKind As TResourceKind, pName As String, pBody As String) As String
         SqlCreateOrAlter = pBody
      End Function

      Overrides Function SqlCreateOrReplaceView(pName As String, pSelect As String) As String
         SqlCreateOrReplaceView = "CREATE OR ALTER VIEW " & me.QuoteIdent(pName) & " AS " & pSelect
      End Function

      Overrides Function SqlCreateOrReplaceProcedure(pName As String) As String
         SqlCreateOrReplaceProcedure = "CREATE OR ALTER PROCEDURE " & me.QuoteIdent(pName) & " AS BEGIN SELECT 1 AS ok END"
      End Function

      Overrides Function SqlCreateOrReplaceIntFunction(pName As String) As String
         SqlCreateOrReplaceIntFunction = "CREATE OR ALTER FUNCTION " & me.QuoteIdent(pName) & "(@n INT) RETURNS INT AS BEGIN RETURN @n * 2 END"
      End Function

      Overrides Function SqlCallIntFunction(pName As String, pArg As Integer) As String
         SqlCallIntFunction = "dbo." & me.QuoteIdent(pName) & "(" & CStr(pArg) & ")"
      End Function

      Overrides Function SupportsDropIfExists() As Boolean
         SupportsDropIfExists = True
      End Function

      Overrides Function SqlDropTable(pTable As String) As String
         SqlDropTable = "DROP TABLE IF EXISTS " & me.QuoteIdent(pTable)
      End Function

      Overrides Function SqlDropSequence(pName As String) As String
         SqlDropSequence = "DROP SEQUENCE IF EXISTS " & me.QuoteSequence(pName)
      End Function

      Overrides Function SqlDropRoutine(pKind As TResourceKind, pName As String) As String
         If pKind = _resTrigger Then
            SqlDropRoutine = "DROP TRIGGER IF EXISTS " & me.QuoteIdent(pName)
         ElseIf pKind = _resProcedure Then
            SqlDropRoutine = "DROP PROCEDURE IF EXISTS " & me.QuoteIdent(pName)
         ElseIf pKind = _resFunc Then
            SqlDropRoutine = "DROP FUNCTION IF EXISTS " & me.QuoteIdent(pName)
         ElseIf pKind = _resView Then
            SqlDropRoutine = "DROP VIEW IF EXISTS " & me.QuoteIdent(pName)
         Else
            SqlDropRoutine = "DROP INDEX IF EXISTS " & me.QuoteIdent(pName)
         End If
      End Function

      Overrides Function SqlDropIndexOnTable(pIndex As String, pTable As String) As String
         SqlDropIndexOnTable = "DROP INDEX IF EXISTS " & me.QuoteIdent(pIndex) & " ON " & me.QuoteIdent(pTable)
      End Function

      Overrides Function SqlMergeTarget(pTable As String) As String
         SqlMergeTarget = pTable & " WITH (HOLDLOCK) AS t"
      End Function

      Overrides Function SqlMergeTerminator() As String
         SqlMergeTerminator = ";"
      End Function

      Overrides Function ApplyLimit(pSql As String, pLimit As Integer) As String
         ApplyLimit = me.ApplyTopLimit(pSql, pLimit)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TSqlDialectAsa
      Inherits TSqlDialect

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function QuoteIdent(pName As String) As String
         QuoteIdent = """" & pName & """"
      End Function

      Overrides Function DefaultSchema() As String
         DefaultSchema = "dba"
      End Function

      Overrides Function TypeName(pField As TFieldDef) As String
         If Trim(pField.DbType) <> "" Then
            TypeName = pField.DbType
            Exit Function
         End If
         If pField.KindId = 1 Then
            TypeName = "INTEGER"
         ElseIf pField.KindId = 2 Then
            TypeName = me.NumericDbType(pField, "DOUBLE")
         ElseIf pField.KindId = 4 Then
            TypeName = "DATE"
         ElseIf pField.KindId = 5 Then
            TypeName = "TIMESTAMP"
         Else
            TypeName = "VARCHAR(" & CStr(pField.MaxLength) & ")"
         End If
      End Function

      Overrides Function SqlTableExists(pTable As String) As String
         SqlTableExists = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM SYS.SYSTABLE WHERE table_name = '" & pTable & "'"
      End Function

      Overrides Function SqlColumnExists(pTable As String, pCol As String) As String
         SqlColumnExists = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM SYS.SYSCOLUMN c JOIN SYS.SYSTABLE t ON t.table_id = c.table_id WHERE t.table_name = '" & pTable & "' AND c.column_name = '" & pCol & "'"
      End Function

      Overrides Function SqlListColumns(pTable As String) As String
         SqlListColumns = "SELECT c.column_name AS col FROM SYS.SYSCOLUMN c JOIN SYS.SYSTABLE t ON t.table_id = c.table_id WHERE t.table_name = '" & pTable & "'"
      End Function

      Overrides Function SqlDescribeColumns(pSchemaName As String, pTable As String) As String
         Dim ownerName As String = Trim(pSchemaName)
         If ownerName = "" Then
            ownerName = me.DefaultSchema()
         End If
         Dim sqlText As String = "SELECT c.column_name AS col, COALESCE(d.domain_name, '') AS typ"
         sqlText = sqlText & ", CAST(c.width AS INTEGER) AS max_len"
         sqlText = sqlText & ", CASE WHEN UPPER(COALESCE(d.domain_name, '')) IN ('NUMERIC', 'DECIMAL', 'NUMBER') THEN CAST(c.width AS INTEGER) ELSE 0 END AS num_prec"
         sqlText = sqlText & ", CASE WHEN UPPER(COALESCE(d.domain_name, '')) IN ('NUMERIC', 'DECIMAL', 'NUMBER') THEN CAST(c.scale AS INTEGER) ELSE 0 END AS num_scale"
         sqlText = sqlText & ", CASE WHEN c.pkey = 'Y' THEN 1 ELSE 0 END AS is_pk"
         sqlText = sqlText & ", CASE WHEN c.nulls = 'Y' THEN 1 ELSE 0 END AS is_null"
         sqlText = sqlText & ", 0 AS is_ident"
         sqlText = sqlText & " FROM SYS.SYSCOLUMN c JOIN SYS.SYSTABLE t ON t.table_id = c.table_id"
         sqlText = sqlText & " LEFT JOIN (SELECT domain_id, MAX(domain_name) AS domain_name FROM SYS.SYSDOMAIN GROUP BY domain_id) d ON d.domain_id = c.domain_id"
         sqlText = sqlText & " WHERE t.table_name = '" & pTable & "'"
         sqlText = sqlText & " AND USER_NAME(t.creator) = '" & ownerName & "'"
         sqlText = sqlText & " ORDER BY c.column_id"
         SqlDescribeColumns = sqlText
      End Function

      Overrides Function SqlSequenceExists(pName As String) As String
         SqlSequenceExists = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM SYS.SYSSEQUENCE WHERE sequence_name = '" & pName & "'"
      End Function

      Overrides Function SqlRoutineExists(pKind As TResourceKind, pName As String) As String
         If pKind = _resView Then
            SqlRoutineExists = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM SYS.SYSTABLE WHERE UPPER(table_name) = UPPER('" & pName & "') AND table_type = 'VIEW'"
         ElseIf pKind = _resIndex Then
            SqlRoutineExists = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM SYS.SYSIDX WHERE UPPER(index_name) = UPPER('" & pName & "')"
         Else
            SqlRoutineExists = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM SYS.SYSPROCEDURE WHERE UPPER(proc_name) = UPPER('" & pName & "')"
         End If
      End Function

      Overrides Function SqlPeekSequence(pName As String) As String
         SqlPeekSequence = "SELECT CAST(COALESCE(current_identity, start_with, 0) AS INTEGER) AS v FROM SYS.SYSSEQUENCE WHERE sequence_name = '" & pName & "'"
      End Function

      Overrides Function SqlAllocateSequence(pName As String, pCount As Integer) As String
         SqlAllocateSequence = me.SqlPeekSequence(pName)
      End Function

      Overrides Function SqlAlterColumnType(pTable As String, pField As TFieldDef) As String
         SqlAlterColumnType = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER " & me.QuoteIdent(pField.DbName) & " " & me.TypeName(pField)
      End Function

      Overrides Function SupportsDdlInTransaction() As Boolean
         SupportsDdlInTransaction = False
      End Function

      Overrides Function SqlCreateOrAlter(pKind As TResourceKind, pName As String, pBody As String) As String
         SqlCreateOrAlter = pBody
      End Function

      Overrides Function SqlDropColumn(pTable As String, pCol As String) As String
         SqlDropColumn = "ALTER TABLE " & me.QuoteIdent(pTable) & " DROP " & me.QuoteIdent(pCol)
      End Function

      Overrides Function SqlSetNullability(pTable As String, pCol As String, pRequired As Boolean) As String
         If pRequired Then
            SqlSetNullability = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER " & me.QuoteIdent(pCol) & " ADD NOT NULL"
         Else
            SqlSetNullability = "ALTER TABLE " & me.QuoteIdent(pTable) & " ALTER " & me.QuoteIdent(pCol) & " DROP NOT NULL"
         End If
      End Function

      Overrides Function SqlRenameColumn(pTable As String, pFrom As String, pTo As String) As String
         SqlRenameColumn = "ALTER TABLE " & me.QuoteIdent(pTable) & " RENAME " & me.QuoteIdent(pFrom) & " TO " & me.QuoteIdent(pTo)
      End Function

      Overrides Function SupportsDropIfExists() As Boolean
         SupportsDropIfExists = False
      End Function

      Overrides Function SqlDropTable(pTable As String) As String
         SqlDropTable = "DROP TABLE " & me.QuoteIdent(pTable)
      End Function

      Overrides Function SqlDropSequence(pName As String) As String
         SqlDropSequence = "DROP SEQUENCE " & me.QuoteSequence(pName)
      End Function

      Overrides Function SqlDropRoutine(pKind As TResourceKind, pName As String) As String
         If pKind = _resTrigger Then
            SqlDropRoutine = "DROP TRIGGER " & me.QuoteIdent(pName)
         ElseIf pKind = _resProcedure Then
            SqlDropRoutine = "DROP PROCEDURE " & me.QuoteIdent(pName)
         ElseIf pKind = _resFunc Then
            SqlDropRoutine = "DROP FUNCTION " & me.QuoteIdent(pName)
         ElseIf pKind = _resView Then
            SqlDropRoutine = "DROP VIEW " & me.QuoteIdent(pName)
         Else
            SqlDropRoutine = "DROP INDEX " & me.QuoteIdent(pName)
         End If
      End Function

      Overrides Function SqlDropIndexOnTable(pIndex As String, pTable As String) As String
         SqlDropIndexOnTable = "DROP INDEX " & me.QuoteIdent(pIndex)
      End Function

      Overrides Function SqlMergeSourceFrom() As String
         SqlMergeSourceFrom = " FROM SYS.DUMMY"
      End Function

      Overrides Function ApplyLimit(pSql As String, pLimit As Integer) As String
         ApplyLimit = me.ApplyTopLimit(pSql, pLimit)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TSqlDialectPostgres
      Inherits TSqlDialect

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function QuoteIdent(pName As String) As String
         QuoteIdent = """" & LCase(Trim(pName)) & """"
      End Function

      Overrides Function DefaultSchema() As String
         DefaultSchema = "dbo"
      End Function

      Overrides Function TypeName(pField As TFieldDef) As String
         If Trim(pField.DbType) <> "" Then
            TypeName = pField.DbType
            Exit Function
         End If
         If pField.KindId = 1 Then
            TypeName = "INTEGER"
         ElseIf pField.KindId = 2 Then
            TypeName = me.NumericDbType(pField, "DOUBLE PRECISION")
         ElseIf pField.KindId = 4 Then
            TypeName = "DATE"
         ElseIf pField.KindId = 5 Then
            TypeName = "TIMESTAMP"
         Else
            TypeName = "VARCHAR(" & CStr(pField.MaxLength) & ")"
         End If
      End Function

      Overrides Function SqlParam(pField As TFieldDef) As String
         SqlParam = me.SqlTypedParam(pField.ParamName, me.TypeName(pField))
      End Function

      Overrides Function SqlTableExists(pTable As String) As String
         SqlTableExists = "SELECT CASE WHEN to_regclass('" & LCase(pTable) & "') IS NULL THEN 0 ELSE 1 END AS ok"
      End Function

      Overrides Function SqlColumnExists(pTable As String, pCol As String) As String
         SqlColumnExists = "SELECT CASE WHEN EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name IN ('" & pTable & "', '" & LCase(pTable) & "') AND column_name IN ('" & pCol & "', '" & LCase(pCol) & "')) THEN 1 ELSE 0 END AS ok"
      End Function

      Overrides Function SqlListColumns(pTable As String) As String
         SqlListColumns = "SELECT column_name AS col FROM information_schema.columns WHERE table_name IN ('" & pTable & "', '" & LCase(pTable) & "')"
      End Function

      Overrides Function SqlDescribeColumns(pSchemaName As String, pTable As String) As String
         Dim schemaFilter As String
         If Trim(pSchemaName) = "" Then
            schemaFilter = "n.nspname = current_schema()"
         Else
            schemaFilter = "n.nspname IN ('" & pSchemaName & "', '" & LCase(pSchemaName) & "')"
         End If
         Dim sqlText As String = "SELECT a.attname AS col, t.typname AS typ"
         sqlText = sqlText & ", CASE WHEN t.typname IN ('varchar', 'bpchar', 'char') AND a.atttypmod > 4 THEN a.atttypmod - 4 ELSE 0 END AS max_len"
         sqlText = sqlText & ", CASE WHEN t.typname = 'numeric' AND a.atttypmod > 4 THEN CAST(((a.atttypmod - 4) / 65536) AS INTEGER) ELSE 0 END AS num_prec"
         sqlText = sqlText & ", CASE WHEN t.typname = 'numeric' AND a.atttypmod > 4 THEN CAST(((a.atttypmod - 4) % 65536) AS INTEGER) ELSE 0 END AS num_scale"
         sqlText = sqlText & ", CASE WHEN ix.indexrelid IS NULL THEN 0 ELSE 1 END AS is_pk"
         sqlText = sqlText & ", CASE WHEN a.attnotnull THEN 0 ELSE 1 END AS is_null"
         sqlText = sqlText & ", CASE WHEN COALESCE(pg_get_expr(ad.adbin, ad.adrelid), '') LIKE 'nextval%' THEN 1 ELSE 0 END AS is_ident"
         sqlText = sqlText & " FROM pg_attribute a"
         sqlText = sqlText & " INNER JOIN pg_class c ON c.oid = a.attrelid"
         sqlText = sqlText & " INNER JOIN pg_namespace n ON n.oid = c.relnamespace"
         sqlText = sqlText & " INNER JOIN pg_type t ON t.oid = a.atttypid"
         sqlText = sqlText & " LEFT JOIN pg_attrdef ad ON ad.adrelid = a.attrelid AND ad.adnum = a.attnum"
         sqlText = sqlText & " LEFT JOIN pg_index ix ON ix.indrelid = a.attrelid AND ix.indisprimary AND a.attnum = ANY (ix.indkey)"
         sqlText = sqlText & " WHERE a.attnum > 0 AND NOT a.attisdropped AND c.relkind IN ('r', 'p')"
         sqlText = sqlText & " AND " & schemaFilter
         sqlText = sqlText & " AND c.relname IN ('" & pTable & "', '" & LCase(pTable) & "')"
         sqlText = sqlText & " ORDER BY a.attnum"
         SqlDescribeColumns = sqlText
      End Function

      Overrides Function SqlSequenceExists(pName As String) As String
         SqlSequenceExists = "SELECT CASE WHEN to_regclass('" & LCase(pName) & "') IS NULL THEN 0 ELSE 1 END AS ok"
      End Function

      Overrides Function SqlRoutineExists(pKind As TResourceKind, pName As String) As String
         If pKind = _resTrigger Then
            SqlRoutineExists = "SELECT CASE WHEN EXISTS(SELECT 1 FROM pg_trigger WHERE tgname = '" & LCase(pName) & "') THEN 1 ELSE 0 END AS ok"
         ElseIf pKind = _resView Then
            SqlRoutineExists = "SELECT CASE WHEN to_regclass('" & LCase(pName) & "') IS NULL THEN 0 ELSE 1 END AS ok"
         ElseIf pKind = _resIndex Then
            SqlRoutineExists = "SELECT CASE WHEN EXISTS(SELECT 1 FROM pg_class WHERE relkind = 'i' AND relname IN ('" & pName & "', '" & LCase(pName) & "')) THEN 1 ELSE 0 END AS ok"
         Else
            SqlRoutineExists = "SELECT CASE WHEN EXISTS(SELECT 1 FROM pg_proc WHERE proname IN ('" & pName & "', '" & LCase(pName) & "')) THEN 1 ELSE 0 END AS ok"
         End If
      End Function

      Overrides Function SqlPeekSequence(pName As String) As String
         SqlPeekSequence = "SELECT last_value AS v FROM " & me.QuoteSequence(pName)
      End Function

      Overrides Function SqlAllocateSequence(pName As String, pCount As Integer) As String
         SqlAllocateSequence = "SELECT last_value AS v FROM " & me.QuoteSequence(pName)
      End Function

      Overrides Function SqlBeginBlock() As String
         SqlBeginBlock = "DO $$ BEGIN"
      End Function

      Overrides Function SqlEndBlock() As String
         SqlEndBlock = "END $$;"
      End Function

      Overrides Function SupportsDropIfExists() As Boolean
         SupportsDropIfExists = True
      End Function

      Overrides Function SqlDropTable(pTable As String) As String
         SqlDropTable = "DROP TABLE IF EXISTS " & me.QuoteIdent(pTable)
      End Function

      Overrides Function SqlDropSequence(pName As String) As String
         SqlDropSequence = "DROP SEQUENCE IF EXISTS " & me.QuoteSequence(pName)
      End Function

      Overrides Function SqlDropRoutine(pKind As TResourceKind, pName As String) As String
         If pKind = _resTrigger Then
            SqlDropRoutine = "DROP TRIGGER IF EXISTS " & me.QuoteIdent(pName)
         ElseIf pKind = _resProcedure Then
            SqlDropRoutine = "DROP PROCEDURE IF EXISTS " & me.QuoteIdent(pName)
         ElseIf pKind = _resFunc Then
            SqlDropRoutine = "DROP FUNCTION IF EXISTS " & me.QuoteIdent(pName)
         ElseIf pKind = _resView Then
            SqlDropRoutine = "DROP VIEW IF EXISTS " & me.QuoteIdent(pName)
         Else
            SqlDropRoutine = "DROP INDEX IF EXISTS " & me.QuoteIdent(pName)
         End If
      End Function

      Overrides Function SqlCreateOrAlter(pKind As TResourceKind, pName As String, pBody As String) As String
         SqlCreateOrAlter = pBody
      End Function

      Overrides Function SqlCreateOrReplaceProcedure(pName As String) As String
         SqlCreateOrReplaceProcedure = "CREATE OR REPLACE PROCEDURE " & me.QuoteIdent(pName) & "() LANGUAGE plpgsql AS $$ BEGIN PERFORM 1; END; $$"
      End Function

      Overrides Function SqlCreateOrReplaceIntFunction(pName As String) As String
         SqlCreateOrReplaceIntFunction = "CREATE OR REPLACE FUNCTION " & me.QuoteIdent(pName) & "(n INTEGER) RETURNS INTEGER LANGUAGE sql AS $$ SELECT n * 2 $$"
      End Function

      Overrides Function SqlDropIndexOnTable(pIndex As String, pTable As String) As String
         SqlDropIndexOnTable = "DROP INDEX IF EXISTS " & me.QuoteIdent(pIndex)
      End Function

      Overrides Function SqlMerge(pTable As String, pPkNames As StringList, pInsertNames As StringList, pInsertParams As StringList, pInsertTypes As StringList, pUpdateNames As StringList) As String
         Dim insCols As New StringList()
         Dim insVals As New StringList()
         Dim conflictCols As New StringList()
         Dim updParts As New StringList()
         insCols.LineBreak = ", "
         insVals.LineBreak = ", "
         conflictCols.LineBreak = ", "
         updParts.LineBreak = ", "
         Dim nIns As Integer = pInsertNames.Count
         Dim nPk As Integer = pPkNames.Count
         Dim nUpd As Integer = pUpdateNames.Count
         insCols.Capacity = nIns
         insVals.Capacity = nIns
         conflictCols.Capacity = nPk
         updParts.Capacity = nUpd
         insCols.BeginUpdate()
         insVals.BeginUpdate()
         Dim i As Integer
         For i = 0 To nIns - 1
            insCols.Add(me.QuoteIdent(pInsertNames.Strings(i)))
            insVals.Add(me.SqlTypedParam(pInsertParams.Strings(i), pInsertTypes.Strings(i)))
         Next
         insCols.EndUpdate()
         insVals.EndUpdate()
         conflictCols.BeginUpdate()
         For i = 0 To nPk - 1
            conflictCols.Add(me.QuoteIdent(pPkNames.Strings(i)))
         Next
         conflictCols.EndUpdate()
         Dim sqlText As String = "INSERT INTO " & pTable & " (" & me.JoinComma(insCols) & ") VALUES (" & me.JoinComma(insVals) & ") ON CONFLICT (" & me.JoinComma(conflictCols) & ")"
         If nUpd = 0 Then
            sqlText = sqlText & " DO NOTHING"
         Else
            updParts.BeginUpdate()
            For i = 0 To nUpd - 1
               Dim uq As String = me.QuoteIdent(pUpdateNames.Strings(i))
               updParts.Add(uq & " = EXCLUDED." & uq)
            Next
            updParts.EndUpdate()
            sqlText = sqlText & " DO UPDATE SET " & me.JoinComma(updParts)
         End If
         insCols.Free()
         insVals.Free()
         conflictCols.Free()
         updParts.Free()
         SqlMerge = sqlText
      End Function
      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Private Dim _current As TSqlDialect
   Private Dim _rdbmsKey As TRDBMS
   Private Dim _hasCurrent As Boolean

   Class TSqlDialects

      Sub New()
         MyBase.New()
      End Sub

      Shared Function Current() As TSqlDialect
         Dim key As TRDBMS = SQL.Connection.RDBMS
         If _hasCurrent Then
            If _rdbmsKey = key Then
               Current = _current
               Exit Function
            End If
         End If
         Dim sqlDialect As TSqlDialect
         Select Case SQL.Connection.RDBMS
            Case dbMSSQL
               sqlDialect = New TSqlDialectMssql()
            Case dbASA
               sqlDialect = New TSqlDialectAsa()
            Case dbPostgreSQL
               sqlDialect = New TSqlDialectPostgres()
            Case Else
               sqlDialect = New TSqlDialectMssql()
         End Select
         _current = sqlDialect
         _rdbmsKey = key
         _hasCurrent = True
         Current = sqlDialect
      End Function
      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Private Dim _pool As StringList
   Private Dim _poolReady As Boolean
   Private Dim _bindPool As StringList
   Private Dim _bindReady As Boolean
   Class TSql

      Sub New()
         MyBase.New()
      End Sub

      Shared Sub EnsurePool()
         If Not _poolReady Then
            _pool = New StringList()
            _pool.OwnsObjects = True
            _poolReady = True
         End If
      End Sub

      Shared Sub ClearPool()
         If Assigned(_bindPool) Then
            _bindPool.Free()
            _bindPool = Null
         End If
         _bindReady = False
         If Assigned(_pool) Then
            _pool.Free()
            _pool = Null
         End If
         _poolReady = False
      End Sub

      Shared Sub EnsureBindPool()
         If Not _bindReady Then
            _bindPool = New StringList()
            _bindPool.OwnsObjects = True
            _bindReady = True
         End If
      End Sub

      Shared Function ParamsFor(pCacheKey As String, pCmd As SQL.Command, pSchema As TTableSchema, pIdxs As StringList) As StringList
         TSql.EnsureBindPool()
         Dim idx As Integer = _bindPool.IndexOf(pCacheKey)
         If idx >= 0 Then
            ParamsFor = StringList(_bindPool.Objects(idx))
            Exit Function
         End If
         Dim map As New StringList()
         map.OwnsObjects = False
         Dim n As Integer = pIdxs.Count
         map.Capacity = n
         map.BeginUpdate()
         Dim i As Integer
         For i = 0 To n - 1
            Dim slot As Integer = CInt(pIdxs.Strings(i))
            Dim fieldDef As TFieldDef = pSchema.Field(slot)
            map.AddObject(CStr(slot), pCmd.Param(fieldDef.ParamName))
         Next
         map.EndUpdate()
         _bindPool.AddObject(pCacheKey, map)
         ParamsFor = map
      End Function

      Shared Function Dialect() As TSqlDialect
         Dialect = TSqlDialects.Current()
      End Function

      Shared Function ProximoCodigoKey(pSchemaName As String, pTable As String) As String
         If TSql.Dialect().IsDefaultSchema(pSchemaName) Then
            ProximoCodigoKey = pTable
         Else
            ProximoCodigoKey = Trim(pSchemaName) & "." & pTable
         End If
      End Function

      Shared Function StandardSequenceName(pSchemaName As String, pTable As String, pHasEmpresa As Boolean, pCodEmpresa As Integer) As String
         Dim seqName As String
         If TSql.Dialect().IsDefaultSchema(pSchemaName) Then
            seqName = pTable & "_Sequencia"
         Else
            seqName = Trim(pSchemaName) & "_" & pTable & "_Sequencia"
         End If
         If pHasEmpresa Then
            seqName = seqName & "_" & CStr(pCodEmpresa)
         End If
         StandardSequenceName = seqName
      End Function

      Shared Function ExplicitSequenceName(pSchema As TTableSchema) As String
         Dim seqName As String = Trim(pSchema.Sequence)
         If seqName = "" Then
            Dim ac As TFieldDef = pSchema.AutoCodeField()
            If Assigned(ac) Then
               seqName = Trim(ac.SequenceName)
            End If
         End If
         ExplicitSequenceName = seqName
      End Function

      Shared Function ResolvedSequenceName(pSchema As TTableSchema, pHasEmpresa As Boolean, pCodEmpresa As Integer) As String
         Dim seqName As String = TSql.ExplicitSequenceName(pSchema)
         If seqName = "" Then
            seqName = TSql.StandardSequenceName(pSchema.SchemaName, pSchema.TableName, pHasEmpresa, pCodEmpresa)
         End If
         ResolvedSequenceName = seqName
      End Function

      Shared Function CommandFor(pCacheKey As String, pCommandText As String) As SQL.Command
         TSql.EnsurePool()
         Dim query As SQL.Command
         Dim idx As Integer = _pool.IndexOf(pCacheKey)
         If idx >= 0 Then
            If Assigned(_pool.Objects(idx)) Then
               CommandFor = SQL.Command(_pool.Objects(idx))
               Exit Function
            End If
         End If
         query = New SQL.Command()
         query.CommandText = pCommandText
         _pool.AddObject(pCacheKey, query)
         CommandFor = query
      End Function

      Shared Function OpenQuery(pSql As String) As SQL.Command
         Dim query As SQL.Command = New SQL.Command()
         query.CommandText = pSql
         query.Open()
         OpenQuery = query
      End Function

      Shared Function ExecScalarInteger(pSql As String, pDefault As Integer = 0) As Integer
         Dim query As SQL.Command = New SQL.Command()
         query.CommandText = pSql
         query.Open()
         If query.Eof Then
            ExecScalarInteger = pDefault
         Else
            ExecScalarInteger = query.Field("ok").AsInteger
         End If
         query.Close()
         query.Free()
      End Function

      Shared Function ExecScalarV(pSql As String, pField As String, pDefault As Integer = 0) As Integer
         Dim query As SQL.Command = New SQL.Command()
         query.CommandText = pSql
         query.Open()
         If query.Eof Then
            ExecScalarV = pDefault
         Else
            ExecScalarV = query.Field(pField).AsInteger
         End If
         query.Close()
         query.Free()
      End Function

      Shared Function FetchStringColumn(pSql As String, pFieldName As String) As StringList
         Dim names As New StringList()
         Dim query As SQL.Command = TSql.OpenQuery(pSql)
         While Not query.Eof
            names.Add(UCase(Trim(query.Field(pFieldName).AsString)))
            query.Next()
         End While
         query.Close()
         query.Free()
         FetchStringColumn = names
      End Function

      Shared Function DescribeColumns(pSchemaName As String, pTable As String) As TTList<TColumnInfo>
         Dim sqlText As String = TSql.Dialect().SqlDescribeColumns(pSchemaName, pTable)
         Dim query As SQL.Command = TSql.OpenQuery(sqlText)
         Dim cols[] As TColumnInfo = []
         Dim seen As New StringList()
         While Not query.Eof
            Dim info As New TColumnInfo()
            info.Name = Trim(query.Field("col").AsString)
            info.NativeType = Trim(query.Field("typ").AsString)
            info.MaxLength = query.Field("max_len").AsInteger
            info.Precision = query.Field("num_prec").AsInteger
            info.Scale = query.Field("num_scale").AsInteger
            info.PrimaryKey = (query.Field("is_pk").AsInteger <> 0)
            info.Nullable = (query.Field("is_null").AsInteger <> 0)
            info.Identity = (query.Field("is_ident").AsInteger <> 0)
            Dim colKey As String = UCase(info.Name)
            Dim idx As Integer = seen.IndexOf(colKey)
            If idx >= 0 Then
               If info.PrimaryKey Then
                  Dim prev As TColumnInfo = cols.Take(idx)
                  prev.PrimaryKey = True
               End If
               If info.Identity Then
                  Dim prevIdent As TColumnInfo = cols.Take(idx)
                  prevIdent.Identity = True
               End If
               info.Free()
            Else
               seen.Add(colKey)
               cols.Push(info.Name, info)
            End If
            query.Next()
         End While
         query.Close()
         query.Free()
         seen.Free()
         If cols.Length = 0 Then
            cols.Free()
            Dim label As String = pTable
            If Trim(pSchemaName) <> "" Then
               label = pSchemaName & "." & pTable
            End If
            Throw New Exception("Tabela não encontrada: " & label)
         End If
         DescribeColumns = cols
      End Function

      Shared Function ExistsFlag(pSql As String) As Boolean
         ExistsFlag = (TSql.ExecScalarInteger(pSql, 0) <> 0)
      End Function

      Private Shared Function ExecSqlWithTx(pQuery As SQL.Command) As Integer
         Dim startedTx As Boolean = False
         Dim rowsAffected As Integer = 0
         If Not SQL.Connection.InTransaction() Then
            SQL.Connection.StartTransaction()
            startedTx = True
         End If
         Try
            rowsAffected = pQuery.ExecSQL()
            If startedTx Then
               If SQL.Connection.InTransaction() Then
                  SQL.Connection.Commit()
               End If
            End If
         Catch ex As Exception
            If startedTx Then
               If SQL.Connection.InTransaction() Then
                  SQL.Connection.RollBack()
               End If
            End If
            Throw New Exception(ex.Message)
         End Try
         ExecSqlWithTx = rowsAffected
      End Function

      Shared Function ExecCommand(pCmd As SQL.Command) As Integer
         ExecCommand = ExecSqlWithTx(pCmd)
      End Function

      Shared Function ExecScript(pSql As String) As Integer
         If Trim(pSql) = "" Then
            ExecScript = 0
            Exit Function
         End If
         Dim query As SQL.Command = New SQL.Command()
         query.CommandText = pSql
         Dim rowsAffected As Integer = 0
         Try
            rowsAffected = ExecSqlWithTx(query)
         Catch ex As Exception
            query.Free()
            TSql.ClearPool()
            Throw New Exception(ex.Message)
         End Try
         query.Free()
         TSql.ClearPool()
         ExecScript = rowsAffected
      End Function

      Shared Function ExecSelect(pSql As String) As String
         Dim query As SQL.Command = New SQL.Command()
         query.CommandText = "SELECT COALESCE(CAST((" & pSql & ") AS VARCHAR(1000)), '') AS Valor"
         query.Open()
         If query.Eof Then
            ExecSelect = ""
         Else
            ExecSelect = query.Field("Valor").AsString
         End If
         query.Close()
         query.Free()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
