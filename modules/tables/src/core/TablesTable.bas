Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports TablesField
Imports TablesSchema
Imports TablesSql

Namespace TablesTable

   Private Dim _tplKeys As StringList
   Private Dim _tplSqls As StringList
   Private Dim _tplReady As Boolean

   Private Dim _sqlDialect As TSqlDialect
   Private Dim _opSelect As TTableOp
   Private Dim _opInsert As TTableOp
   Private Dim _opUpdate As TTableOp
   Private Dim _opDelete As TTableOp
   Private Dim _opMerge As TTableOp
   Private Dim _runtimeReady As Boolean

   MustInherit Class TTable
      Inherits TFields

      Schema As TTableSchema

      Sub New(pName As String)
         MyBase.New()
         me.InitSchema(pName)
         me.InitFields()
      End Sub

      Shared Sub EnsureRuntime()
         If Not _runtimeReady Then
            TFieldCache.Ensure()
            _sqlDialect = TSql.Dialect()
            _opSelect = TFieldCache.OpSelect()
            _opInsert = TFieldCache.OpInsert()
            _opUpdate = TFieldCache.OpUpdate()
            _opDelete = TFieldCache.OpDelete()
            _opMerge = TFieldCache.OpMerge()
            _runtimeReady = True
         End If
      End Sub

      Private Sub InitSchema(pName As String)
         TTable.EnsureRuntime()
         Dim sch As TTableSchema = TTableSchema.GetCache(pName)
         If Assigned(sch) Then
            me.Schema = sch
         Else
            sch = New TTableSchema()
            sch.CacheKey = pName
            me.DefineSchema(sch)
            If Trim(sch.FromClause) = "" Then
               sch.FromClause = sch.TableName
            End If
            sch.Compile()
            TTableSchema.AddCache(pName, sch)
            me.Schema = sch
         End If
      End Sub

      Private Sub InitFields()
         Dim defs As StringList = me.Schema.Fields
         Dim count As Integer = defs.Count
         me.Fields.Capacity = count
         me.Fields.BeginUpdate()
         Dim i As Integer
         For i = 0 To count - 1
            Dim fieldDef As TFieldDef = CType(defs.Objects(i), TFieldDef)
            me.Fields.AddObject(defs.Strings(i), New TField(fieldDef, Unassigned))
         Next
         me.Fields.EndUpdate()
      End Sub

      MustOverride Overridable Sub DefineSchema(pSchema As TTableSchema)
      End Sub

      MustOverride Overridable Function CreateInstance() As TTable
         CreateInstance = Null
      End Function

      Shared Sub EnsureTplCache()
         If Not _tplReady Then
            _tplKeys = New StringList()
            _tplSqls = New StringList()
            _tplReady = True
         End If
      End Sub

      Function Field(pIndex As Integer) As TField
         Field = me.GetField(pIndex)
      End Function

      Function Field(pName As String) As TField
         Field = me.GetField(pName)
      End Function

      Overridable Function IncludeField(pOp As TTableOp, pDef As TFieldDef) As Boolean
         If pOp = _opSelect Then
            IncludeField = pDef.IncludeInSelect
            Exit Function
         End If
         If pOp = _opInsert Then
            IncludeField = pDef.Persist And pDef.Insertable And Not pDef.SelectOnly
            Exit Function
         End If
         If pOp = _opMerge Then
            IncludeField = pDef.Persist And pDef.Insertable And Not pDef.SelectOnly
            Exit Function
         End If
         If pOp = _opUpdate Then
            IncludeField = pDef.Persist And pDef.Updatable And Not pDef.SelectOnly And Not pDef.PrimaryKey
            Exit Function
         End If
         If pOp = _opDelete Then
            IncludeField = pDef.PrimaryKey
            Exit Function
         End If
         IncludeField = pDef.Persist And Not pDef.SelectOnly
      End Function

      Overridable Sub PrepareValue(pOp As TTableOp, pField As TField)
      End Sub

      Overridable Sub ReadField(pField As TField, pSrc As SQL.TField)
         Dim kindId As Integer = pField.Def.KindId
         If kindId = 1 Then
            pField.Value = pSrc.AsInteger
         ElseIf kindId = 2 Then
            pField.Value = pSrc.AsFloat
         ElseIf kindId = 3 Then
            pField.Value = pSrc.AsBoolean
         ElseIf kindId = 4 Then
            pField.Value = pSrc.AsDate
         ElseIf kindId = 5 Then
            pField.Value = pSrc.AsDateTime
         Else
            pField.Value = pSrc.AsString
         End If
      End Sub

      Overridable Function BuildFromClause() As String
         Dim fromText As String = me.Schema.ResolvedFromClause()
         If fromText = me.Schema.TableName Then
            BuildFromClause = _sqlDialect.QuoteTable(me.Schema.SchemaName, me.Schema.TableName)
         Else
            BuildFromClause = fromText
         End If
      End Function

      Overridable Sub Validate(pOp As TTableOp)
         Dim i As Integer
         For i = 0 To me.Fields.Count - 1
            Dim f As TField = me.GetField(i)
            Dim check As Boolean = f.Def.Required Or (f.Def.PrimaryKey And Not f.Def.AutoCode)
            If check Then
               If Not me.IncludeField(pOp, f.Def) Then
                  If Not f.Def.PrimaryKey Then
                     check = False
                  End If
               End If
            End If
            If check Then
               If f.IsNull() Then
                  If f.Def.AutoCode And (pOp = _opInsert Or pOp = _opMerge) Then
                     check = False
                  End If
               End If
            End If
            If check Then
               If f.IsNull() Then
                  Throw New Exception("Campo obrigatório vazio: " & me.Schema.CacheKey & "." & f.Def.Name)
               End If
            End If
         Next
      End Sub

      Overridable Sub BeforeInsert()
      End Sub

      Overridable Sub AfterInsert()
      End Sub

      Overridable Sub BeforeUpdate()
      End Sub

      Overridable Sub AfterUpdate()
      End Sub

      Overridable Sub BeforeDelete()
      End Sub

      Overridable Sub AfterDelete()
      End Sub

      Overridable Sub BeforeLoad()
      End Sub

      Overridable Sub AfterLoad()
      End Sub

      Overridable Sub AfterAssignPrimaryKey()
      End Sub

      Overridable Sub BeforeMerge()
      End Sub

      Overridable Sub AfterMerge()
      End Sub

      Function IncludedFieldKey(pOp As TTableOp) As String
         Dim key As String = me.Schema.CacheKey & "|" & pOp.AsString
         Dim i As Integer
         Dim count As Integer = me.Schema.Fields.Count
         For i = 0 To count - 1
            Dim fieldDef As TFieldDef = CType(me.Schema.Fields.Objects(i), TFieldDef)
            If me.IncludeField(pOp, fieldDef) Then
               key = key & "|" & fieldDef.Name
            End If
         Next
         IncludedFieldKey = key
      End Function

      Function SelectColumnSql(pDef As TFieldDef) As String
         Dim sqlDialect As TSqlDialect = _sqlDialect
         If Trim(pDef.SelectExpr) <> "" Then
            SelectColumnSql = pDef.SelectExpr & " AS " & sqlDialect.QuoteIdent(pDef.DbName)
         Else
            SelectColumnSql = sqlDialect.QuoteIdent(pDef.DbName)
         End If
      End Function

      Function BuildSelectSql() As String
         Dim sqlDialect As TSqlDialect = _sqlDialect
         Dim sqlText As String = "SELECT "
         Dim first As Boolean = True
         Dim i As Integer
         Dim count As Integer = me.Schema.Fields.Count
         For i = 0 To count - 1
            Dim fieldDef As TFieldDef = CType(me.Schema.Fields.Objects(i), TFieldDef)
            If me.IncludeField(_opSelect, fieldDef) Then
               If Not first Then
                  sqlText = sqlText & ", "
               End If
               first = False
               sqlText = sqlText & me.SelectColumnSql(fieldDef)
            End If
         Next
         sqlText = sqlText & " FROM " & me.BuildFromClause()
         BuildSelectSql = sqlText
      End Function

      Function BuildInsertSql() As String
         Dim sqlDialect As TSqlDialect = _sqlDialect
         Dim cols As String = ""
         Dim vals As String = ""
         Dim first As Boolean = True
         Dim i As Integer
         Dim count As Integer = me.Schema.Fields.Count
         For i = 0 To count - 1
            Dim fieldDef As TFieldDef = CType(me.Schema.Fields.Objects(i), TFieldDef)
            If me.IncludeField(_opInsert, fieldDef) Then
               If Not first Then
                  cols = cols & ", "
                  vals = vals & ", "
               End If
               first = False
               cols = cols & sqlDialect.QuoteIdent(fieldDef.DbName)
               vals = vals & sqlDialect.SqlParam(fieldDef)
            End If
         Next
         BuildInsertSql = "INSERT INTO " & sqlDialect.QuoteTable(me.Schema.SchemaName, me.Schema.TableName) & " (" & cols & ") VALUES (" & vals & ")"
      End Function

      Function BuildUpdateSql() As String
         Dim sqlDialect As TSqlDialect = _sqlDialect
         Dim sqlText As String = "UPDATE " & sqlDialect.QuoteTable(me.Schema.SchemaName, me.Schema.TableName) & " SET "
         Dim first As Boolean = True
         Dim i As Integer
         Dim count As Integer = me.Schema.Fields.Count
         For i = 0 To count - 1
            Dim fieldDef As TFieldDef = CType(me.Schema.Fields.Objects(i), TFieldDef)
            If me.IncludeField(_opUpdate, fieldDef) Then
               If Not first Then
                  sqlText = sqlText & ", "
               End If
               first = False
               sqlText = sqlText & sqlDialect.QuoteIdent(fieldDef.DbName) & " = " & sqlDialect.SqlParam(fieldDef)
            End If
         Next
         sqlText = sqlText & me.BuildPkWhereSql()
         BuildUpdateSql = sqlText
      End Function

      Function BuildDeleteSql() As String
         Dim sqlDialect As TSqlDialect = _sqlDialect
         BuildDeleteSql = "DELETE FROM " & sqlDialect.QuoteTable(me.Schema.SchemaName, me.Schema.TableName) & me.BuildPkWhereSql()
      End Function

      Function BuildMergeSql() As String
         Dim sqlDialect As TSqlDialect = _sqlDialect
         Dim pkNames As New StringList()
         Dim insNames As New StringList()
         Dim insParams As New StringList()
         Dim insTypes As New StringList()
         Dim updNames As New StringList()
         Dim pks As StringList = me.Schema.PkList
         Dim i As Integer
         For i = 0 To pks.Count - 1
            Dim pkField As TFieldDef = CType(pks.Objects(i), TFieldDef)
            pkNames.Add(pkField.DbName)
         Next
         Dim count As Integer = me.Schema.Fields.Count
         For i = 0 To count - 1
            Dim fieldDef As TFieldDef = CType(me.Schema.Fields.Objects(i), TFieldDef)
            If me.IncludeField(_opMerge, fieldDef) Then
               insNames.Add(fieldDef.DbName)
               insParams.Add(fieldDef.ParamName)
               insTypes.Add(sqlDialect.TypeName(fieldDef))
            End If
            If me.IncludeField(_opUpdate, fieldDef) Then
               updNames.Add(fieldDef.DbName)
            End If
         Next
         For i = 0 To pks.Count - 1
            Dim pkIns As TFieldDef = CType(pks.Objects(i), TFieldDef)
            If insNames.IndexOf(pkIns.DbName) < 0 Then
               insNames.Add(pkIns.DbName)
               insParams.Add(pkIns.ParamName)
               insTypes.Add(sqlDialect.TypeName(pkIns))
            End If
         Next
         If pkNames.Count = 0 Then
            pkNames.Free()
            insNames.Free()
            insParams.Free()
            insTypes.Free()
            updNames.Free()
            Throw New Exception("Merge requer chave primária em " & me.Schema.CacheKey)
         End If
         If insNames.Count = 0 Then
            pkNames.Free()
            insNames.Free()
            insParams.Free()
            insTypes.Free()
            updNames.Free()
            Throw New Exception("Merge requer colunas persistentes em " & me.Schema.CacheKey)
         End If
         Dim sqlText As String = sqlDialect.SqlMerge(sqlDialect.QuoteTable(me.Schema.SchemaName, me.Schema.TableName), pkNames, insNames, insParams, insTypes, updNames)
         pkNames.Free()
         insNames.Free()
         insParams.Free()
         insTypes.Free()
         updNames.Free()
         BuildMergeSql = sqlText
      End Function

      Function BuildPkWhereSql() As String
         Dim sqlDialect As TSqlDialect = _sqlDialect
         Dim pks As StringList = me.Schema.PkList
         If pks.Count = 0 Then
            Throw New Exception("Tabela sem chave primária: " & me.Schema.CacheKey)
         End If
         Dim sqlText As String = " WHERE "
         Dim first As Boolean = True
         Dim i As Integer
         For i = 0 To pks.Count - 1
            Dim fieldDef As TFieldDef = CType(pks.Objects(i), TFieldDef)
            If Not first Then
               sqlText = sqlText & " AND "
            End If
            first = False
            sqlText = sqlText & sqlDialect.QuoteIdent(fieldDef.DbName) & " = " & sqlDialect.SqlParam(fieldDef)
         Next
         BuildPkWhereSql = sqlText
      End Function

      Function GetCommandText(pOp As TTableOp) As String
         TTable.EnsureTplCache()
         Dim key As String = me.IncludedFieldKey(pOp)
         Dim idx As Integer = _tplKeys.IndexOf(key)
         If idx >= 0 Then
            GetCommandText = _tplSqls.Strings(idx)
            Exit Function
         End If
         Dim sqlText As String
         If pOp = _opSelect Then
            sqlText = me.BuildSelectSql()
         ElseIf pOp = _opInsert Then
            sqlText = me.BuildInsertSql()
         ElseIf pOp = _opUpdate Then
            sqlText = me.BuildUpdateSql()
         ElseIf pOp = _opDelete Then
            sqlText = me.BuildDeleteSql()
         ElseIf pOp = _opMerge Then
            sqlText = me.BuildMergeSql()
         Else
            sqlText = me.BuildInsertSql()
         End If
         _tplKeys.Add(key)
         _tplSqls.Add(sqlText)
         GetCommandText = sqlText
      End Function

      Function PreparedCommand(pOp As TTableOp) As SQL.Command
         PreparedCommand = TSql.CommandFor(me.IncludedFieldKey(pOp), me.GetCommandText(pOp))
      End Function

      Sub BindField(pCmd As SQL.Command, pField As TField)
         Dim prm As SQL.TFDParam = pCmd.Param(pField.Def.ParamName)
         If pField.IsNull() Then
            prm.Value = Unassigned
            Exit Sub
         End If
         Dim kindId As Integer = pField.Def.KindId
         If kindId = 1 Then
            prm.AsInteger = pField.AsInteger
         ElseIf kindId = 2 Then
            prm.AsFloat = pField.AsFloat
         ElseIf kindId = 3 Then
            prm.AsBoolean = pField.AsBoolean
         ElseIf kindId = 4 Then
            prm.AsDateTime = pField.AsDateTime
         ElseIf kindId = 5 Then
            prm.AsDateTime = pField.AsDateTime
         Else
            prm.AsString = pField.AsString
         End If
      End Sub

      Sub Bind(pCmd As SQL.Command, pOp As TTableOp)
         Dim i As Integer
         For i = 0 To me.Fields.Count - 1
            Dim f As TField = me.GetField(i)
            Dim usePk As Boolean = f.Def.PrimaryKey And (pOp = _opUpdate Or pOp = _opDelete Or pOp = _opMerge)
            If usePk Or me.IncludeField(pOp, f.Def) Then
               me.PrepareValue(pOp, f)
               me.BindField(pCmd, f)
            End If
         Next
      End Sub

      Function ResolveSelectSources(pCmd As SQL.Command) As StringList
         Dim srcs As New StringList()
         srcs.OwnsObjects = False
         Dim slots As StringList = me.Schema.SelectIndexes
         Dim i As Integer
         For i = 0 To slots.Count - 1
            Dim idx As Integer = CInt(slots.Strings(i))
            Dim fieldDef As TFieldDef = CType(me.Schema.Fields.Objects(idx), TFieldDef)
            srcs.AddObject(slots.Strings(i), pCmd.Field(fieldDef.DbName))
         Next
         ResolveSelectSources = srcs
      End Function

      Sub HydrateFrom(pSrcs As StringList)
         me.BeforeLoad()
         Dim i As Integer
         For i = 0 To pSrcs.Count - 1
            Dim idx As Integer = CInt(pSrcs.Strings(i))
            me.ReadField(me.GetField(idx), SQL.TField(pSrcs.Objects(i)))
         Next
         me.AfterLoad()
      End Sub

      Sub Hydrate(pCmd As SQL.Command)
         Dim srcs As StringList = me.ResolveSelectSources(pCmd)
         me.HydrateFrom(srcs)
         srcs.Free()
      End Sub

      Function Load(pWhere As String) As Boolean
         Dim query As SQL.Command
         Dim sqlText As String = me.GetCommandText(_opSelect) & _sqlDialect.NormalizeWhere(pWhere)
         query = TSql.OpenQuery(sqlText)
         If query.Eof Then
            Load = False
         Else
            me.Hydrate(query)
            Load = True
         End If
         query.Close()
         query.Free()
      End Function

      Function LoadWhere(pWhere As String) As Boolean
         LoadWhere = me.Load(pWhere)
      End Function

      Function FetchRows(pWhere As String, pOrder As String = "", pLimit As Integer = 0) As TTList<TTable>
         Dim query As SQL.Command
         Dim rows[] As TTable = []
         Dim sqlDialect As TSqlDialect = _sqlDialect
         Dim sqlText As String = me.GetCommandText(_opSelect) & sqlDialect.NormalizeWhere(pWhere) & sqlDialect.NormalizeOrderBy(pOrder)
         sqlText = sqlDialect.ApplyLimit(sqlText, pLimit)
         query = TSql.OpenQuery(sqlText)
         Dim srcs As StringList = me.ResolveSelectSources(query)
         While Not query.Eof
            Dim row As TTable = me.CreateInstance()
            row.HydrateFrom(srcs)
            rows.Push(row)
            query.Next()
         End While
         srcs.Free()
         query.Close()
         query.Free()
         rows.OwnsObjects = False
         FetchRows = rows
      End Function

      Function RowExists(pWhere As String) As Boolean
         Dim sqlText As String = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM " & me.BuildFromClause() & _sqlDialect.NormalizeWhere(pWhere)
         RowExists = TSql.ExistsFlag(sqlText)
      End Function

      Function ExistsByPk() As Boolean
         Dim sqlDialect As TSqlDialect = _sqlDialect
         Dim sqlText As String = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM " & sqlDialect.QuoteTable(me.Schema.SchemaName, me.Schema.TableName) & me.BuildPkWhereSql()
         Dim query As SQL.Command = TSql.CommandFor(me.IncludedFieldKey(_opDelete) & "|exists", sqlText)
         me.Bind(query, _opDelete)
         query.Open()
         Dim n As Integer = 0
         If Not query.Eof Then
            n = query.Field("ok").AsInteger
         End If
         query.Close()
         ExistsByPk = (n <> 0)
      End Function

      Sub EnsurePrimaryKey()
         Dim ac As TFieldDef = me.Schema.CachedAutoCode
         If Not Assigned(ac) Then
            Exit Sub
         End If
         Dim f As TField = me.GetField(ac.Name)
         If f.AsInteger <> 0 Then
            Exit Sub
         End If
         Dim seqKey As String = me.SequenceKey()
         Dim n As Integer
         If me.HasCodEmpresa() Then
            n = Data7.ProximoCodigo(seqKey, me.CodEmpresaValue())
         Else
            n = Data7.ProximoCodigo(seqKey)
         End If
         f.Value = n
         me.AfterAssignPrimaryKey()
      End Sub

      Function SequenceKey() As String
         SequenceKey = TSql.ProximoCodigoKey(me.Schema.SchemaName, me.Schema.TableName)
      End Function

      Function ResolvedSequenceName() As String
         ResolvedSequenceName = TSql.ResolvedSequenceName(me.Schema, me.HasCodEmpresa(), me.CodEmpresaValue())
      End Function

      Function HasCodEmpresa() As Boolean
         HasCodEmpresa = (me.Schema.CodEmpresaIndex >= 0)
      End Function

      Function CodEmpresaValue() As Integer
         If me.Schema.CodEmpresaIndex < 0 Then
            CodEmpresaValue = 0
         Else
            CodEmpresaValue = me.GetField(me.Schema.CodEmpresaIndex).AsInteger
         End If
      End Function

      Function NeedsAutoCode() As Boolean
         Dim ac As TFieldDef = me.Schema.CachedAutoCode
         If Not Assigned(ac) Then
            NeedsAutoCode = False
            Exit Function
         End If
         Dim f As TField = me.GetField(ac.Name)
         NeedsAutoCode = (f.AsInteger = 0)
      End Function

      Sub AssignAutoCode(pValue As Integer)
         Dim ac As TFieldDef = me.Schema.CachedAutoCode
         If Not Assigned(ac) Then
            Exit Sub
         End If
         Dim f As TField = me.GetField(ac.Name)
         f.Value = pValue
         me.AfterAssignPrimaryKey()
      End Sub

      Function ApplyDml(pOp As TTableOp, pCmd As SQL.Command) As Integer
         If pOp = _opInsert Then
            me.BeforeInsert()
            me.Validate(pOp)
         ElseIf pOp = _opUpdate Then
            me.BeforeUpdate()
            me.Validate(pOp)
         ElseIf pOp = _opDelete Then
            me.BeforeDelete()
            me.Validate(pOp)
         ElseIf pOp = _opMerge Then
            me.BeforeMerge()
            me.Validate(pOp)
         End If
         me.Bind(pCmd, pOp)
         ApplyDml = TSql.ExecCommand(pCmd)
         If pOp = _opInsert Then
            me.AfterInsert()
         ElseIf pOp = _opUpdate Then
            me.AfterUpdate()
         ElseIf pOp = _opDelete Then
            me.AfterDelete()
         ElseIf pOp = _opMerge Then
            me.AfterMerge()
         End If
      End Function

      Function Insert() As Integer
         me.EnsurePrimaryKey()
         Dim query As SQL.Command = me.PreparedCommand(_opInsert)
         Insert = me.ApplyDml(_opInsert, query)
      End Function

      Function Update() As Integer
         Dim query As SQL.Command = me.PreparedCommand(_opUpdate)
         Update = me.ApplyDml(_opUpdate, query)
      End Function

      Function Delete() As Integer
         Dim query As SQL.Command = me.PreparedCommand(_opDelete)
         Delete = me.ApplyDml(_opDelete, query)
      End Function

      Function Upsert() As Integer
         If me.ExistsByPk() Then
            Upsert = me.Update()
         Else
            Upsert = me.Insert()
         End If
      End Function

      Function Merge() As Integer
         me.EnsurePrimaryKey()
         Dim query As SQL.Command = me.PreparedCommand(_opMerge)
         Merge = me.ApplyDml(_opMerge, query)
      End Function

      Sub AssignFrom(pOther As TTable)
         Dim i As Integer
         For i = 0 To pOther.Fields.Count - 1
            Dim src As TField = pOther.GetField(i)
            If me.HasField(src.Name) Then
               me.GetField(src.Name).Value = src.Value
            End If
         Next
      End Sub

      Overrides Function Clone() As TTObject
         Dim n As TTable = me.CreateInstance()
         Dim i As Integer
         For i = 0 To me.Fields.Count - 1
            n.GetField(i).Value = me.GetField(i).Value
         Next
         Clone = n
      End Function

      Overrides Function ToString() As String
          With me.BuildLogger(me.Schema.SchemaName & "." & me.Schema.TableName)
            Dim i As Integer
            Dim count As Integer = me.Fields.Count
            For i = 0 To count - 1
               Dim f As TField = me.GetField(i)
               .Prop(f.Def.Name, CStr(f.Value))
            Next
            ToString = .Text
            .Free()
          End With
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   MustInherit Class TTableOf<T As TTable>
      Inherits TTable

      Sub New(pName As String)
         MyBase.New(pName)
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New T()
      End Function

      MustOverride Overridable Sub DefineSchema(pSchema As TTableSchema)
      End Sub

      Shared Function Fetch(pWhere As String, pOrder As String = "", pLimit As Integer = 0) As TTList<T>
         Dim probe As New T()
         Dim raw[] As TTable = probe.FetchRows(pWhere, pOrder, pLimit)
         probe.Free()
         Dim rows[] As T = []
         Dim i As Integer
         Dim count As Integer = raw.Length
         For i = 0 To count - 1
            rows.Push(T(raw.Take(i)))
         Next
         raw.OwnsObjects = False
         raw.Free()
         rows.OwnsObjects = False
         Fetch = rows
      End Function

      Shared Function Find(pWhere As String) As T
         Dim row As New T()
         If row.Load(pWhere) Then
            Find = row
         Else
            row.Free()
            Find = Null
         End If
      End Function

      Shared Function Exists(pWhere As String) As Boolean
         Dim probe As New T()
         Dim ok As Boolean = probe.RowExists(pWhere)
         probe.Free()
         Exists = ok
      End Function

      Shared Function Insert(pRow As T) As Integer
         Insert = pRow.Insert()
      End Function

      Shared Function Update(pRow As T) As Integer
         Update = pRow.Update()
      End Function

      Shared Function Delete(pRow As T) As Integer
         Delete = pRow.Delete()
      End Function

      Shared Function Upsert(pRow As T) As Integer
         Upsert = pRow.Upsert()
      End Function

      Shared Function Merge(pRow As T) As Integer
         Merge = pRow.Merge()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
