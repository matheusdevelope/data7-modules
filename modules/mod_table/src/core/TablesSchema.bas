Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports TablesField

Namespace TablesSchema

   Private Dim _cache As StringList
   Private Dim _cacheReady As Boolean

   Class TTableSchema
      Inherits TTObject

      CacheKey As String
      TableName As String
      SchemaName As String
      Sequence As String
      FromClause As String
      Fields As StringList
      PkList As StringList
      PersistList As StringList
      SelectIndexes As StringList
      CachedAutoCode As TFieldDef
      CodEmpresaIndex As Integer
      Compiled As Boolean

      Sub New()
         MyBase.New()
         me.CacheKey = ""
         me.TableName = ""
         me.SchemaName = ""
         me.Sequence = ""
         me.FromClause = ""
         me.Fields = New StringList()
         me.Fields.OwnsObjects = True
         me.PkList = New StringList()
         me.PkList.OwnsObjects = False
         me.PersistList = New StringList()
         me.PersistList.OwnsObjects = False
         me.SelectIndexes = New StringList()
         me.SelectIndexes.OwnsObjects = False
         me.CachedAutoCode = Null
         me.CodEmpresaIndex = -1
         me.Compiled = False
      End Sub

      Shared Sub EnsureCache()
         If Not _cacheReady Then
            _cache = New StringList()
            _cache.OwnsObjects = False
            _cacheReady = True
         End If
      End Sub

      Shared Function HasCache(pClassName As String) As Boolean
         TTableSchema.EnsureCache()
         HasCache = _cache.IndexOf(pClassName) >= 0
      End Function

      Shared Function GetCache(pClassName As String) As TTableSchema
         TTableSchema.EnsureCache()
         Dim idx As Integer = _cache.IndexOf(pClassName)
         If idx >= 0 Then
            GetCache = CType(_cache.Objects(idx), TTableSchema)
         Else
            GetCache = Null
         End If
      End Function

      Shared Function FromCache(pClassName As String) As TTableSchema
         FromCache = TTableSchema.GetCache(pClassName)
      End Function

      Shared Function AddCache(pClassName As String, pSchema As TTableSchema) As TTableSchema
         TTableSchema.EnsureCache()
         Dim idx As Integer = _cache.IndexOf(pClassName)
         If idx >= 0 Then
            _cache.Objects(idx) = pSchema
         Else
            _cache.AddObject(pClassName, pSchema)
         End If
         AddCache = pSchema
      End Function

      Shared Sub PutCache(pClassName As String, pSchema As TTableSchema)
         TTableSchema.AddCache(pClassName, pSchema)
      End Sub

      Function Field(pIndex As Integer) As TFieldDef
         Field = CType(me.Fields.Objects(pIndex), TFieldDef)
      End Function

      Function Field(pName As String) As TFieldDef
         Dim id As String = UCase(pName)
         Dim idx As Integer = me.Fields.IndexOf(id)
         If idx >= 0 Then
            Field = CType(me.Fields.Objects(idx), TFieldDef)
            Exit Function
         End If
         Dim fieldDef As New TFieldDef(pName)
         me.Fields.AddObject(id, fieldDef)
         me.Compiled = False
         Field = fieldDef
      End Function

      Sub Compile()
         me.PkList.Clear()
         me.PersistList.Clear()
         me.SelectIndexes.Clear()
         me.CachedAutoCode = Null
         me.CodEmpresaIndex = -1
         Dim i As Integer
         Dim count As Integer = me.Fields.Count
         For i = 0 To count - 1
            Dim fieldDef As TFieldDef = CType(me.Fields.Objects(i), TFieldDef)
            Dim id As String = me.Fields.Strings(i)
            If fieldDef.PrimaryKey Then
               me.PkList.AddObject(id, fieldDef)
            End If
            If fieldDef.AutoCode Then
               me.CachedAutoCode = fieldDef
            End If
            If fieldDef.Persist And Not fieldDef.SelectOnly Then
               me.PersistList.AddObject(id, fieldDef)
            End If
            If fieldDef.IncludeInSelect Then
               me.SelectIndexes.Add(CStr(i))
            End If
            If (id = "CODEMPRESA") Or (UCase(fieldDef.DbName) = "CODEMPRESA") Then
               me.CodEmpresaIndex = i
            End If
         Next
         me.Compiled = True
      End Sub

      Function PersistFields() As TTList<TFieldDef>
         If Not me.Compiled Then
            me.Compile()
         End If
         Dim result[] As TFieldDef = []
         result.OwnsObjects = False
         Dim i As Integer
         For i = 0 To me.PersistList.Count - 1
            result.Push(CType(me.PersistList.Objects(i), TFieldDef))
         Next
         PersistFields = result
      End Function

      Function PkFields() As TTList<TFieldDef>
         If Not me.Compiled Then
            me.Compile()
         End If
         Dim result[] As TFieldDef = []
         result.OwnsObjects = False
         Dim i As Integer
         For i = 0 To me.PkList.Count - 1
            result.Push(CType(me.PkList.Objects(i), TFieldDef))
         Next
         PkFields = result
      End Function

      Function AutoCodeField() As TFieldDef
         If Not me.Compiled Then
            me.Compile()
         End If
         AutoCodeField = me.CachedAutoCode
      End Function

      Function ResolvedFromClause() As String
         If Trim(me.FromClause) <> "" Then
            ResolvedFromClause = me.FromClause
         Else
            ResolvedFromClause = me.TableName
         End If
      End Function

      Overrides Function GetID() As String
         GetID = me.TableName
      End Function

      Overrides Function Clone() As TTObject
         Dim n As New TTableSchema()
         n.CacheKey = me.CacheKey
         n.TableName = me.TableName
         n.SchemaName = me.SchemaName
         n.Sequence = me.Sequence
         n.FromClause = me.FromClause
         Dim i As Integer
         For i = 0 To me.Fields.Count - 1

            Dim fieldDef As TFieldDef = CType(me.Fields.Objects(i), TFieldDef)
            n.Fields.AddObject(me.Fields.Strings(i), fieldDef.Clone())
         Next
         n.Compile()
         Clone = n
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Fields) Then
            me.Fields.Free()
            me.Fields = Null
         End If
         If Assigned(me.PkList) Then
            me.PkList.Free()
            me.PkList = Null
         End If
         If Assigned(me.PersistList) Then
            me.PersistList.Free()
            me.PersistList = Null
         End If
         If Assigned(me.SelectIndexes) Then
            me.SelectIndexes.Free()
            me.SelectIndexes = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
