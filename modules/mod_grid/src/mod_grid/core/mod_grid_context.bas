Imports Forms
Imports mod_tobject
Imports mod_grid_config
Imports mod_grid_data
Imports mod_grid_col
Imports mod_grid_presenter
Namespace mod_grid_context
   Class TGridContext
      Inherits TTObject
      Config As TGridConfig
      Data As TGridData
      Adapter As mod_grid_native_adapter.TNativeGridAdapter
      EditorPool As mod_grid_editor_pool.TGridEditorPool
      EventHub As mod_grid_event_hub.TGridEventHub
      Presenter As TGridPresenter
      Private _ensuring As Boolean
      Private _selectionCol As TGridCol
      Private _itemCol As TGridCol
      Sub New(pConfig As TGridConfig, pParent As TWinControl)
         MyBase.New()
         me.Config = pConfig
         me.Data = New TGridData()
         If Assigned(pConfig) Then
            me.Data.EditorRegistry = pConfig.EditorRegistry
            If Assigned(pConfig.Options) Then
               me.Data.ItemNumberSize = pConfig.Options.Item.Size
            End If
         End If
         me.Adapter = New mod_grid_native_adapter.TNativeGridAdapter(pParent)
         me.EditorPool = New mod_grid_editor_pool.TGridEditorPool(me.Adapter.Native, pConfig.EditorRegistry)
         me.Presenter = New TGridPresenter(me.Data, me.Adapter, pConfig.Options)
         me.EventHub = New mod_grid_event_hub.TGridEventHub(me)
      End Sub
      Sub New(pValue As TGridContext)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridContext)
         If Assigned(pValue) Then
            me.Config = pValue.Config
            me.Data = pValue.Data
            me.Adapter = pValue.Adapter
            me.EditorPool = pValue.EditorPool
            me.EventHub = pValue.EventHub
            me.Presenter = pValue.Presenter
            me._selectionCol = pValue._selectionCol
            me._itemCol = pValue._itemCol
         End If
      End Sub
      Overrides Function Clone() As TGridContext
         Clone = New TGridContext(me)
      End Function
      Sub EnsureSystemColumns()
         If Not me._ensuring AndAlso Assigned(me.Config) AndAlso Assigned(me.Config.Options) AndAlso Assigned(me.Data) Then
            Dim opt As TGridOptionsConfig = me.Config.Options
            me.Data.ItemNumberSize = opt.Item.Size
            Dim _need As Boolean = False
            If opt.Selection.Enabled Then
               _need = True
            ElseIf opt.Item.Enabled Then
               _need = True
            ElseIf Assigned(me._selectionCol) Then
               _need = True
            ElseIf Assigned(me._itemCol) Then
               _need = True
            End If
            If _need Then
               me._applySystemColumns(opt)
            End If
         End If
      End Sub
      Private Sub _applySystemColumns(opt As TGridOptionsConfig)
         me._ensuring = True
         If opt.Selection.Enabled Then
            If Not Assigned(me._selectionCol) Then
               me._selectionCol = me.Data.PushColumn(TGridCol.AsSelection())
               me.EditorPool.ResolveFactory(me._selectionCol)
            End If
         ElseIf Assigned(me._selectionCol) Then
            Dim selectionColId As String = me._selectionCol.ID
            me._selectionCol = Null
            me.Data.DeleteCol(selectionColId)
         End If
         If opt.Item.Enabled Then
            If Not Assigned(me._itemCol) Then
               me._itemCol = me.Data.PushColumn(TGridCol.AsItemNumber())
               me.EditorPool.ResolveFactory(me._itemCol)
            End If
         ElseIf Assigned(me._itemCol) Then
            Dim itemColId As String = me._itemCol.ID
            me._itemCol = Null
            me.Data.DeleteCol(itemColId)
         End If
         me.ReorderSystemColumns()
         me._ensuring = False
         If Assigned(me.Presenter) Then
            me.Presenter.SyncIfPrepared()
         End If
      End Sub
      Sub ReorderSystemColumns()
         If Assigned(me.Data) AndAlso Assigned(me.Config) AndAlso Assigned(me.Config.Options) Then
            Dim count As Integer = me.Data.ColCount
            If count >= 1 Then
               Dim opt As TGridOptionsConfig = me.Config.Options
               If Assigned(me._selectionCol) Then
                  Dim selIndex As Integer = me._resolveSystemColIndex(opt.Selection.Index, 0, count)
                  me._moveSystemCol(me._selectionCol, selIndex)
               End If
               If Assigned(me._itemCol) Then
                  Dim itemFallback As Integer = 0
                  If Assigned(me._selectionCol) Then
                     itemFallback = 1
                  End If
                  Dim itemIndex As Integer = me._resolveSystemColIndex(opt.Item.Index, itemFallback, me.Data.ColCount)
                  me._moveSystemCol(me._itemCol, itemIndex)
               End If
            End If
         End If
      End Sub
      Private Function _resolveSystemColIndex(pRequested As Integer, pFallback As Integer, pColCount As Integer) As Integer
         Dim idx As Integer
         If pRequested = TGridOptionsConfig.LastColumnIndex() Then
            idx = pColCount - 1
         Else
            If pRequested < 0 Then
               idx = pFallback
            Else
               idx = pRequested
            End If
         End If
         If idx < 0 Then
            idx = 0
         End If
         If idx >= pColCount Then
            idx = pColCount - 1
         End If
         _resolveSystemColIndex = idx
      End Function
      Private Sub _moveSystemCol(pCol As TGridCol, pIndex As Integer)
         If Assigned(pCol) AndAlso pCol.Index <> pIndex Then
            me.Data.MoveCol(pCol.ID, pIndex)
         End If
      End Sub
      Property SelectionColumn As TGridCol
         Get
            SelectionColumn = me._selectionCol
         End Get
      End Property
      Property ItemColumn As TGridCol
         Get
            ItemColumn = me._itemCol
         End Get
      End Property
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            If Assigned(me.Data) Then
               .Prop("Config", me.Config.ToString())
               .Prop("Data", me.Data.ToString())
               .Prop("Adapter", me.Adapter.ToString())
               .Prop("EditorPool", me.EditorPool.ToString())
               .Prop("EventHub", me.EventHub.ToString())
               .Prop("Presenter", me.Presenter.ToString())
            End If
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._selectionCol = Null
         me._itemCol = Null
         If Assigned(me.EventHub) Then
            me.EventHub.Free()
            me.EventHub = Null
         End If
         If Assigned(me.Presenter) Then
            me.Presenter.Free()
            me.Presenter = Null
         End If
         If Assigned(me.EditorPool) Then
            me.EditorPool.Free()
            me.EditorPool = Null
         End If
         If Assigned(me.Adapter) Then
            me.Adapter.Free()
            me.Adapter = Null
         End If
         If Assigned(me.Data) Then
            me.Data.Free()
            me.Data = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
