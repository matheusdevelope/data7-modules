Imports mod_tobject
Imports mod_grid_data
Imports mod_grid_col
Imports mod_grid_row
Imports mod_grid_config
Imports mod_grid_native_adapter
Namespace mod_grid_presenter
   Class TGridPresenter
      Inherits TTObject
      Private _data As TGridData
      Private _adapter As TNativeGridAdapter
      Private _options As TGridOptionsConfig
      Private _syncing As Boolean
      Private _prepared As Boolean
      Sub New(pData As TGridData, pAdapter As TNativeGridAdapter, pOptions As TGridOptionsConfig)
         MyBase.New()
         me._data = pData
         me._adapter = pAdapter
         me._options = pOptions
         me._syncing = False
         me._prepared = False
         me._bindData()
      End Sub
      Sub New(pValue As TGridPresenter)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridPresenter)
         If Assigned(pValue) Then
            me._data = pValue._data
            me._adapter = pValue._adapter
            me._options = pValue._options
            me._syncing = pValue._syncing
            me._prepared = pValue._prepared
         End If
      End Sub
      Overrides Function Clone() As TGridPresenter
         Clone = New TGridPresenter(me)
      End Function
      Property Syncing As Boolean
         Get
            Syncing = me._syncing
         End Get
      End Property
      Property Prepared As Boolean
         Get
            Prepared = me._prepared
         End Get
      End Property
      Private Sub _bindData()
         If Assigned(me._data) Then
            me._data.OnAfterAddRow = me._onRowAdded
            me._data.OnAfterDeleteRow = me._onRowDeleted
            me._data.OnAfterAddCol = me._onColAdded
            me._data.OnAfterDeleteCol = me._onColDeleted
            me._data.OnAfterMoveCol = me._onColMoved
            me._data.OnAfterClean = me._onClean
            me._data.OnAfterEndUpdate = me._onEndUpdate
            me._data.OnRowStateChanged = me._onRowState
         End If
      End Sub
      Private Function _ready() As Boolean
         _ready = me._prepared AndAlso Not me._syncing AndAlso Assigned(me._adapter)
      End Function
      Sub Prepare()
         If Assigned(me._adapter) Then
            If Not me._prepared Then
               me._adapter.Mount()
               me._prepared = True
            End If
            me.SyncStructure()
         End If
      End Sub
      Sub Refresh()
         me.Prepare()
      End Sub
      Sub SyncIfPrepared()
         If me._prepared Then
            me.SyncStructure()
         End If
      End Sub
      Sub InvalidateIfPrepared()
         If me._ready() Then
            me._adapter.InvalidateDisplay()
         End If
      End Sub
      Sub PokeDataCell(pDataCol As Integer, pDataIndex As Integer)
         If Assigned(me._adapter) AndAlso Assigned(me._data) Then
            If pDataCol >= 0 AndAlso pDataIndex >= 0 AndAlso pDataCol < me._data.ColCount AndAlso pDataIndex < me._data.RowCount Then
               Dim _text As String = me._data.CellText(pDataIndex, pDataCol)
               me._adapter.PokeCell(me._adapter.ToNativeCol(pDataCol), me.ToNativeRow(pDataIndex), _text)
            End If
         End If
      End Sub
      Sub ApplyOptions()
         If me._prepared AndAlso Assigned(me._adapter) AndAlso Assigned(me._options) Then
            me._adapter.ApplyOptions(me._options)
         End If
      End Sub
      Function ToNativeRow(pDataIndex As Integer) As Integer
         ToNativeRow = me._adapter.ToNativeRow(pDataIndex)
      End Function
      Function ToDataIndex(pNativeRow As Integer) As Integer
         Dim _idx As Integer = me._adapter.ToDataRow(pNativeRow)
         If _idx >= 0 AndAlso _idx < me._data.RowCount Then
            ToDataIndex = _idx
         Else
            ToDataIndex = -1
         End If
      End Function
      Sub SyncStructure()
         If me._prepared AndAlso Assigned(me._adapter) Then
            me._syncing = True
            me._syncItemNumbers()
            me._adapter.BeginUpdate()
            If Assigned(me._options) Then
               me._adapter.ApplyOptions(me._options)
            End If
            me._adapter.SetVisibleColCount(me._data)
            me._adapter.ApplyColumnWidths(me._data)
            me._adapter.ApplyColumnAlignments(me._data)
            me._adapter.SetDataRowCount(me._data.RowCount)
            me._adapter.ApplyHiddenColumns(me._data)
            me._applyMarkForDelete()
            me._applyColumnLayout()
            me._adapter.EndUpdate()
            me._syncing = False
         End If
      End Sub
      Private Sub _applyMarkForDelete()
         If Assigned(me._adapter) AndAlso Assigned(me._options) Then
            me._adapter.ApplyMarkForDelete(me._options.Interaction.AllowMarkForDelete)
         End If
      End Sub
      Private Sub _applyColumnLayout()
         If Assigned(me._adapter) AndAlso Assigned(me._options) Then
            me._adapter.ApplyColumnLayout(me._options)
         End If
      End Sub
      Sub ApplyColumnLayout()
         If me._prepared Then
            me._applyColumnLayout()
         End If
      End Sub
      Sub ApplyColumnLayoutOnResize()
         If me._prepared AndAlso Assigned(me._adapter) AndAlso Assigned(me._options) Then
            me._adapter.ApplyColumnLayoutOnResize(me._options)
         End If
      End Sub
      Function ResolveDataFontColor(pCol As TGridCol, pRow As TGridRow) As Integer
         If Assigned(pRow) AndAlso pRow.Options.Color.Text <> -1 Then
            ResolveDataFontColor = pRow.Options.Color.Text
         ElseIf Assigned(pCol) AndAlso pCol.Options.Color.Text <> -1 Then
            ResolveDataFontColor = pCol.Options.Color.Text
         ElseIf Assigned(me._options) AndAlso me._options.Color.Text <> -1 Then
            ResolveDataFontColor = me._options.Color.Text
         Else
            ResolveDataFontColor = -1
         End If
      End Function
      Function ResolveHeaderFontColor(pCol As TGridCol) As Integer
         If Assigned(pCol) AndAlso pCol.Options.Color.Header.Text <> -1 Then
            ResolveHeaderFontColor = pCol.Options.Color.Header.Text
         ElseIf Assigned(pCol) AndAlso pCol.Options.Interaction.Required AndAlso Assigned(me._options) AndAlso me._options.Color.Header.Required <> -1 Then
            ResolveHeaderFontColor = me._options.Color.Header.Required
         ElseIf Assigned(me._options) AndAlso me._options.Color.Header.Text <> -1 Then
            ResolveHeaderFontColor = me._options.Color.Header.Text
         ElseIf Assigned(me._options) AndAlso me._options.Color.Text <> -1 Then
            ResolveHeaderFontColor = me._options.Color.Text
         Else
            ResolveHeaderFontColor = -1
         End If
      End Function
      Function ResolveDataBackColor(pCol As TGridCol, pRow As TGridRow, pNativeCol As Integer) As Integer
         If Assigned(pRow) AndAlso pRow.Options.Color.Back <> -1 Then
            ResolveDataBackColor = pRow.Options.Color.Back
         ElseIf Assigned(pCol) AndAlso pCol.Options.Color.Back <> -1 Then
            ResolveDataBackColor = pCol.Options.Color.Back
         ElseIf Assigned(me._adapter) AndAlso pNativeCol < me._adapter.Native.FixedCols AndAlso Assigned(me._options) AndAlso me._options.Color.Fixed.Back <> -1 Then
            ResolveDataBackColor = me._options.Color.Fixed.Back
         ElseIf Assigned(me._options) AndAlso me._options.Color.Back <> -1 Then
            ResolveDataBackColor = me._options.Color.Back
         Else
            ResolveDataBackColor = -1
         End If
      End Function
      Function ResolveHeaderBackColor(pCol As TGridCol) As Integer
         If Assigned(pCol) AndAlso pCol.Options.Color.Header.Back <> -1 Then
            ResolveHeaderBackColor = pCol.Options.Color.Header.Back
         ElseIf Assigned(pCol) AndAlso pCol.Options.Interaction.Required AndAlso Assigned(me._options) AndAlso me._options.Color.Header.RequiredBack <> -1 Then
            ResolveHeaderBackColor = me._options.Color.Header.RequiredBack
         ElseIf Assigned(me._options) AndAlso me._options.Color.Header.Back <> -1 Then
            ResolveHeaderBackColor = me._options.Color.Header.Back
         ElseIf Assigned(me._options) AndAlso me._options.Color.Fixed.Back <> -1 Then
            ResolveHeaderBackColor = me._options.Color.Fixed.Back
         ElseIf Assigned(me._options) AndAlso me._options.Color.Back <> -1 Then
            ResolveHeaderBackColor = me._options.Color.Back
         Else
            ResolveHeaderBackColor = -1
         End If
      End Function
      Private Sub _syncItemNumbers()
         If Assigned(me._data) AndAlso Assigned(me._options) AndAlso me._options.Item.AutoUpdate Then
            me._data.RenumberItems()
         End If
      End Sub
      Private Sub _syncRowCount()
         If me._ready() Then
            me._syncing = True
            me._syncItemNumbers()
            me._adapter.SetDataRowCount(me._data.RowCount)
            me._syncing = False
         End If
      End Sub
      Private Sub _onRowAdded(pRowID As String, pIndex As Integer)
         me._syncRowCount()
      End Sub
      Private Sub _onRowDeleted(pRowID As String, pIndex As Integer)
         me._syncRowCount()
      End Sub
      Private Sub _onColAdded(pColID As String, pIndex As Integer)
         me.SyncIfPrepared()
      End Sub
      Private Sub _onColDeleted(pColID As String, pIndex As Integer)
         me.SyncIfPrepared()
      End Sub
      Private Sub _onColMoved(pID As String, pFromIndex As Integer, pToIndex As Integer)
         me.SyncIfPrepared()
      End Sub
      Private Sub _onClean(pAny As Variant)
         me._syncRowCount()
      End Sub
      Private Sub _onEndUpdate(pAny As Variant)
         me.SyncIfPrepared()
      End Sub
      Private Sub _onRowState(pRow As TGridRow)
         me.InvalidateIfPrepared()
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Syncing", me._syncing)
            .Prop("Prepared", me._prepared)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me._data) Then
            me._data.OnAfterAddRow = Null
            me._data.OnAfterDeleteRow = Null
            me._data.OnAfterAddCol = Null
            me._data.OnAfterDeleteCol = Null
            me._data.OnAfterMoveCol = Null
            me._data.OnAfterClean = Null
            me._data.OnAfterEndUpdate = Null
            me._data.OnRowStateChanged = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
