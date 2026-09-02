Imports Forms
Imports mod_tobject
Imports mod_grid_editor_contract
Imports mod_grid_editor_registry
Namespace mod_grid_editor_pool
   Class TGridEditorPool
      Inherits TTObject
      Private _grid As Grid
      Private _registry As TGridEditorRegistry
      Private _controls[] As Forms.TWinControl
      Sub New(pGrid As Grid, pRegistry As TGridEditorRegistry)
         MyBase.New()
         me._grid = pGrid
         me._registry = pRegistry
         me._controls = []
      End Sub
      Sub New(pValue As TGridEditorPool)
         MyBase.New()
         me._controls = []
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridEditorPool)
         If Assigned(pValue) Then
            me._grid = pValue._grid
            me._registry = pValue._registry
            If Assigned(me._controls) Then
               me._controls.Free()
            End If
            If Assigned(pValue._controls) Then
               me._controls = pValue._controls.Clone()
            Else
               me._controls = []
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridEditorPool
         Clone = New TGridEditorPool(me)
      End Function
      Function AcquireForEdit(pColDef As mod_grid_col.TGridCol, pCol As Integer, pRow As Integer, pValue As String) As Forms.TWinControl
         Dim _ctrl As Forms.TWinControl = me.Acquire(pColDef)
         If Assigned(_ctrl) Then
            Dim _factory As TGridEditorFactory = me.ResolveFactory(pColDef)
            If Assigned(_factory) Then
               _factory.ApplyValue(_ctrl, pValue)
            End If
            AcquireForEdit = _ctrl
         End If
      End Function
      Function Acquire(pColDef As mod_grid_col.TGridCol) As Forms.TWinControl
         Dim _factory As TGridEditorFactory = me.ResolveFactory(pColDef)
         If Assigned(_factory) Then
            Dim _poolKey As String = _factory.PoolKey(pColDef)
            Dim _idx As Integer = me._controls.IndexOf(_poolKey)
            If _idx >= 0 Then
               Dim _ctrl As Forms.TWinControl = me._controls.GetItem(_idx)
               _factory.Configure(_ctrl, pColDef)
               Acquire = _ctrl
            Else
               Dim _created As Forms.TWinControl = _factory.Build(me._grid, pColDef)
               If Assigned(_created) Then
                  _factory.Configure(_created, pColDef)
                  me._controls.Push(_poolKey, _created)
                  Acquire = _created
               End If
            End If
         End If
      End Function
      Function ResolveFactory(pColDef As mod_grid_col.TGridCol) As TGridEditorFactory
         If Assigned(pColDef) Then
            If Assigned(pColDef.Factory) Then
               ResolveFactory = pColDef.Factory
            ElseIf Assigned(me._registry) Then
               Dim _factory As TGridEditorFactory = me._registry.Resolve(pColDef.Kind)
               pColDef.Factory = _factory
               ResolveFactory = _factory
            End If
         End If
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("PoolSize", me._controls.Length)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me._controls) Then
            me._controls.Free()
            me._controls = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
