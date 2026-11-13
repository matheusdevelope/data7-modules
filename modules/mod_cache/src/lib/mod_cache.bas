Imports Collections

' mod_cache
' Lista global de pools. Cada pool é uma lista key -> objeto.
' O cache é dono do objeto: Remove, ClearPool e Clear chamam Free.
' A lista global permanece na sessão.

Namespace mod_cache

   Private Dim _pools As StringList
   Private Dim _ready As Boolean

   Private Function _normalizeName(pName As String) As String
      _normalizeName = UCase(Trim(pName))
   End Function

   Private Sub _ensurePools()
      If _ready Then
         Exit Sub
      End If
      _pools = New StringList()
      _pools.OwnsObjects = False
      _ready = True
   End Sub

   Private Function _findPool(pObjectName As String) As StringList
      If Not _ready Then
         _findPool = Null
         Exit Function
      End If
      Dim poolKey As String = _normalizeName(pObjectName)
      If poolKey = "" Then
         _findPool = Null
         Exit Function
      End If
      Dim idx As Integer = _pools.IndexOf(poolKey)
      If idx = -1 Then
         _findPool = Null
      Else
         _findPool = CType(_pools.Objects(idx), StringList)
      End If
   End Function

   Private Function _ensurePool(pObjectName As String) As StringList
      _ensurePools()
      Dim pool As StringList = _findPool(pObjectName)
      If Assigned(pool) Then
         _ensurePool = pool
         Exit Function
      End If
      Dim poolKey As String = _normalizeName(pObjectName)
      If poolKey = "" Then
         _ensurePool = Null
         Exit Function
      End If
      pool = New StringList()
      pool.OwnsObjects = False
      _pools.AddObject(poolKey, pool)
      _ensurePool = pool
   End Function

   Private Sub _releaseObject(pObject As TObject)
      If Assigned(pObject) Then
         pObject.Free()
      End If
   End Sub

   Private Sub _releasePool(pPool As StringList)
      If Not Assigned(pPool) Then
         Exit Sub
      End If
      pPool.OwnsObjects = False
      Dim i As Integer
      Dim last As Integer = pPool.Count - 1
      For i = 0 To last
         _releaseObject(pPool.Objects(i))
      Next
      pPool.Clear()
      pPool.Free()
   End Sub

   Private Sub _dropPool(pObjectName As String)
      If Not _ready Then
         Exit Sub
      End If
      Dim poolKey As String = _normalizeName(pObjectName)
      Dim idx As Integer = _pools.IndexOf(poolKey)
      If idx = -1 Then
         Exit Sub
      End If
      Dim pool As StringList = CType(_pools.Objects(idx), StringList)
      _pools.Delete(idx)
      _releasePool(pool)
   End Sub

   ' data7:disable-next-line missing-mybase-free
   Class Cache

      Shared Sub Put(pObjectName As String, pKey As String, pObject As TObject)
         If Not Assigned(pObject) Then
            Exit Sub
         End If
         Dim itemKey As String = _normalizeName(pKey)
         If itemKey = "" Then
            Exit Sub
         End If
         Dim pool As StringList = _ensurePool(pObjectName)
         If Not Assigned(pool) Then
            Exit Sub
         End If
         Dim idx As Integer = pool.IndexOf(itemKey)
         If idx <> -1 Then
            Dim sameIdx As Integer = pool.IndexOfObject(pObject)
            If sameIdx <> idx Then
               _releaseObject(pool.Objects(idx))
            End If
            pool.Delete(idx)
         End If
         pool.AddObject(itemKey, pObject)
      End Sub

      Private Shared Function _findObject(pObjectName As String, pKey As String) As TObject
         Dim pool As StringList = _findPool(pObjectName)
         If Not Assigned(pool) Then
            _findObject = Null
            Exit Function
         End If
         Dim idx As Integer = pool.IndexOf(_normalizeName(pKey))
         If idx = -1 Then
            _findObject = Null
         Else
            _findObject = pool.Objects(idx)
         End If
      End Function

      Shared Function Find<T As TObject>(pObjectName As String, pKey As String) As T
         Dim obj As TObject = _findObject(pObjectName, pKey)
         If Not Assigned(obj) Then
            Find = Null
         Else
            ' data7:disable-next-line unknown-symbol
            Find = T(obj)
         End If
      End Function

      Shared Function Contains(pObjectName As String, pKey As String) As Boolean
         Contains = Assigned(_findObject(pObjectName, pKey))
      End Function

      Shared Function ContainsObject(pObjectName As String, pObject As TObject) As Boolean
         Dim pool As StringList = _findPool(pObjectName)
         If Not Assigned(pool) Then
            ContainsObject = False
            Exit Function
         End If
         ContainsObject = pool.IndexOfObject(pObject) <> -1
      End Function

      Shared Function PoolCount() As Integer
         If Not _ready Then
            PoolCount = 0
            Exit Function
         End If
         PoolCount = _pools.Count
      End Function

      Shared Function Count(pObjectName As String) As Integer
         Dim pool As StringList = _findPool(pObjectName)
         If Not Assigned(pool) Then
            Count = 0
         Else
            Count = pool.Count
         End If
      End Function

      Shared Function NameAt(pIndex As Integer) As String
         If Not _ready Then
            NameAt = ""
            Exit Function
         End If
         If (pIndex < 0) Or (pIndex >= _pools.Count) Then
            NameAt = ""
            Exit Function
         End If
         NameAt = _pools.Strings(pIndex)
      End Function

      Shared Sub Remove(pObjectName As String, pKey As String)
         Dim pool As StringList = _findPool(pObjectName)
         If Not Assigned(pool) Then
            Exit Sub
         End If
         Dim idx As Integer = pool.IndexOf(_normalizeName(pKey))
         If idx = -1 Then
            Exit Sub
         End If
         Dim obj As TObject = pool.Objects(idx)
         pool.Delete(idx)
         _releaseObject(obj)
         If pool.Count = 0 Then
            _dropPool(pObjectName)
         End If
      End Sub

      Shared Sub ClearPool(pObjectName As String)
         _dropPool(pObjectName)
      End Sub

      Shared Sub Clear()
         If Not _ready Then
            Exit Sub
         End If
         Dim i As Integer
         Dim last As Integer = _pools.Count - 1
         For i = 0 To last
            _releasePool(CType(_pools.Objects(i), StringList))
         Next
         _pools.Clear()
      End Sub

   End Class

End Namespace
