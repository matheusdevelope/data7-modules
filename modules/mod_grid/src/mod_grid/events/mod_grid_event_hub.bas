Imports Forms
Imports mod_tobject
Imports mod_grid_context
Imports mod_grid_column_kind
Imports mod_grid_column_checkbox
Imports mod_grid_editor_contract
Imports mod_grid_col
Imports mod_grid_row
Imports mod_grid_popup_checkbox
Imports mod_grid_popup
Namespace mod_grid_event_hub
   Delegate Sub TGridAllowIndexEvent(pSender As TObject, pIndex As Integer, ByRef pAllow As Boolean)
   Class TGridEventHub
      Inherits TTObject
      Private _ctx As TGridContext
      Private _sortColId As String = ""
      Private _sortAsc As Boolean = True
      Private _sortCol As TGridCol
      Private _sortColIndex As Integer = -1
      Private _committing As Boolean

      OnCanEditCell As TCanEditCellEvent
      OnGetInplaceEditor As TGridGetInplaceEditorEvent
      OnGetDisplText As TGetDisplTextEvent
      OnGetEditText As TGetEditEvent
      OnSetEditText As TSetEditEvent
      OnCellValidate As TCellValidateEvent
      OnGetCellColor As TGridColorEvent
      OnDrawCell As TDrawCellEvent
      OnDblClickCell As TDblClickCellEvent
      OnKeyPress As TKeyPressEvent
      OnKeyDown As TKeyEvent
      OnRowMoved As TMovedEvent
      OnColumnMoved As TMovedEvent
      OnRowMove As TGridAllowIndexEvent
      OnColumnMove As TGridAllowIndexEvent
      OnRowSize As TGridAllowIndexEvent
      OnColumnSize As TGridAllowIndexEvent
      OnClickSort As TClickSortEvent
      OnCanSort As TCanSortEvent
      OnMarcaDesmarcaLinhaParaExclusao As TMarcaDesmarcaLinhaParaExclusaoEvent
      OnResize As TNotifyEvent
      OnContextPopup As TContextPopupEvent

      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
         me._committing = False
      End Sub
      Sub New(pValue As TGridEventHub)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridEventHub)
         If Assigned(pValue) Then
            me._ctx = pValue._ctx
            me._committing = pValue._committing
            me.OnCanEditCell = pValue.OnCanEditCell
            me.OnGetInplaceEditor = pValue.OnGetInplaceEditor
            me.OnGetDisplText = pValue.OnGetDisplText
            me.OnGetEditText = pValue.OnGetEditText
            me.OnSetEditText = pValue.OnSetEditText
            me.OnCellValidate = pValue.OnCellValidate
            me.OnGetCellColor = pValue.OnGetCellColor
            me.OnDrawCell = pValue.OnDrawCell
            me.OnDblClickCell = pValue.OnDblClickCell
            me.OnKeyPress = pValue.OnKeyPress
            me.OnKeyDown = pValue.OnKeyDown
            me.OnRowMoved = pValue.OnRowMoved
            me.OnColumnMoved = pValue.OnColumnMoved
            me.OnRowMove = pValue.OnRowMove
            me.OnColumnMove = pValue.OnColumnMove
            me.OnRowSize = pValue.OnRowSize
            me.OnColumnSize = pValue.OnColumnSize
            me.OnClickSort = pValue.OnClickSort
            me.OnCanSort = pValue.OnCanSort
            me.OnMarcaDesmarcaLinhaParaExclusao = pValue.OnMarcaDesmarcaLinhaParaExclusao
            me.OnResize = pValue.OnResize
            me.OnContextPopup = pValue.OnContextPopup
         End If
      End Sub
      Overrides Function Clone() As TGridEventHub
         Clone = New TGridEventHub(me)
      End Function

      Sub Wire()
         Dim _grid As Grid = me._ctx.Adapter.Native
         _grid.OnCanEditCell = me._handleCanEditCell
         _grid.OnGetInplaceEditor = me._handleGetInplaceEditor
         _grid.OnGetDisplText = me._handleGetDisplText
         _grid.OnGetEditText = me._handleGetEditText
         _grid.OnSetEditText = me._handleSetEditText
         _grid.OnCellValidate = me._handleCellValidate
         _grid.OnGetCellColor = me._handleGetCellColor
         _grid.OnDrawCell = me._handleDrawCell
         _grid.OnDblClickCell = me._handleDblClickCell
         _grid.OnKeyPress = me._handleKeyPress
         _grid.OnKeyDown = me._handleKeyDown
         _grid.OnRowMove = me._handleRowMove
         _grid.OnColumnMove = me._handleColumnMove
         _grid.OnRowSize = me._handleRowSize
         _grid.OnColumnSize = me._handleColumnSize
         _grid.OnRowMoved = me._handleRowMoved
         _grid.OnColumnMoved = me._handleColumnMoved
         _grid.OnClickSort = me._handleClickSort
         _grid.OnCanSort = me._handleCanSort
         _grid.OnMarcaDesmarcaLinhaParaExclusao = me._handleMarcaExclusao
         _grid.OnResize = me._handleResize
         _grid.OnContextPopup = me._handleContextPopup
      End Sub

      Private Function _colAt(pNativeCol As Integer) As TGridCol
         Dim _dataCol As Integer = me._ctx.Adapter.ToDataCol(pNativeCol)
         If _dataCol >= 0 AndAlso _dataCol < me._ctx.Data.ColCount Then
            _colAt = me._ctx.Data.ColAt(_dataCol)
         End If
      End Function

      Private Function _rowAtNative(pNativeRow As Integer) As TGridRow
         Dim _idx As Integer = me._ctx.Presenter.ToDataIndex(pNativeRow)
         If _idx >= 0 Then
            _rowAtNative = me._ctx.Data.RowAt(_idx)
         End If
      End Function

      Private Function _ensureRowAtNative(pNativeRow As Integer) As TGridRow
         Dim _row As TGridRow = me._rowAtNative(pNativeRow)
         If Assigned(_row) Then
            _ensureRowAtNative = _row
         ElseIf Not me._isOnlyRead() AndAlso Not me._ctx.Adapter.IsHeaderRow(pNativeRow) Then
            If me._ctx.Data.RowCount = 0 Then
               _ensureRowAtNative = me._ctx.Data.PushRow()
            End If
         End If
      End Function

      Private Function _isOnlyRead() As Boolean
         If Assigned(me._ctx.Config) AndAlso Assigned(me._ctx.Config.Options) Then
            _isOnlyRead = me._ctx.Config.Options.Interaction.OnlyRead
         Else
            _isOnlyRead = False
         End If
      End Function

      Private Function _toggleSelectionAtNativeRow(pNativeRow As Integer) As Boolean
         If Assigned(me._ctx.SelectionColumn) Then
            Dim _nativeCol As Integer = me._ctx.Adapter.ToNativeCol(me._ctx.SelectionColumn.Index)
            _toggleSelectionAtNativeRow = TGridCheckboxSupport.TryToggle(me._ctx, pNativeRow, _nativeCol)
         Else
            _toggleSelectionAtNativeRow = False
         End If
      End Function

      Private Sub _handleGetDisplText(pSender As TObject, pCol As Integer, pRow As Integer, ByRef pValue As String)
         Dim _col As TGridCol = me._colAt(pCol)
         If Assigned(_col) Then
            If pRow = 0 Then
               pValue = _col.Caption
            Else
               Dim _idx As Integer = me._ctx.Presenter.ToDataIndex(pRow)
               If _idx >= 0 Then
                  pValue = me._displayText(_col, _idx)
               End If
            End If
         End If
         If Assigned(me.OnGetDisplText) Then
            me.OnGetDisplText(pSender, pCol, pRow, pValue)
         End If
      End Sub

      Private Sub _handleGetEditText(pSender As TObject, pCol As Integer, pRow As Integer, ByRef pValue As String)
         me._ensureRowAtNative(pRow)
         Dim _idx As Integer = me._ctx.Presenter.ToDataIndex(pRow)
         If _idx >= 0 Then
            Dim _col As TGridCol = me._colAt(pCol)
            If Assigned(_col) Then
               pValue = me._editText(_col, _idx)
            Else
               pValue = ""
            End If
         Else
            pValue = ""
         End If
         If Assigned(me.OnGetEditText) Then
            me.OnGetEditText(pSender, pCol, pRow, pValue)
         End If
      End Sub

      Private Function _factoryOf(pCol As TGridCol) As TGridEditorFactory
         If Assigned(pCol) Then
            If Assigned(pCol.Factory) Then
               _factoryOf = pCol.Factory
            Else
               _factoryOf = me._ctx.EditorPool.ResolveFactory(pCol)
            End If
         End If
      End Function

      Private Function _displayText(pCol As TGridCol, pDataIndex As Integer) As String
         Dim _factory As TGridEditorFactory = me._factoryOf(pCol)
         Dim _raw As Variant = me._ctx.Data.CellRaw(pDataIndex, pCol)
         If Assigned(_factory) Then
            _displayText = _factory.FormatValue(pCol, _raw)
         Else
            _displayText = me._asText(_raw)
         End If
      End Function

      Private Function _editText(pCol As TGridCol, pDataIndex As Integer) As String
         Dim _factory As TGridEditorFactory = me._factoryOf(pCol)
         Dim _raw As Variant = me._ctx.Data.CellRaw(pDataIndex, pCol)
         If Assigned(_factory) Then
            _editText = _factory.FormatEditValue(pCol, _raw)
         Else
            _editText = me._asText(_raw)
         End If
      End Function

      Private Function _asText(pValue As Variant) As String
         If IsEmpty(pValue) Then
            _asText = ""
         Else
            _asText = CStr(pValue)
         End If
      End Function

      Private Sub _handleGetCellColor(pSender As TObject, pRow As Integer, pCol As Integer, pState As TGridDrawState, pBrush As TBrush, pFont As TFont)
         Dim _col As TGridCol = me._colAt(pCol)
         Dim _color As Integer
         Dim _back As Integer
         If me._ctx.Adapter.IsHeaderRow(pRow) Then
            If Assigned(_col) AndAlso _col.HasFont() Then
               TGridCol.ApplyFont(pFont, _col.Font)
            End If
            _color = me._ctx.Presenter.ResolveHeaderFontColor(_col)
            _back = me._ctx.Presenter.ResolveHeaderBackColor(_col)
         Else
            Dim _row As TGridRow = me._rowAtNative(pRow)
            If Assigned(_col) AndAlso _col.HasFont() Then
               TGridCol.ApplyFont(pFont, _col.Font)
            End If
            If Assigned(_row) AndAlso _row.HasFont() Then
               TGridCol.ApplyFont(pFont, _row.Font)
            End If
            _color = me._ctx.Presenter.ResolveDataFontColor(_col, _row)
            _back = me._ctx.Presenter.ResolveDataBackColor(_col, _row, pCol)
         End If
         If _color <> -1 Then
            pFont.Color = _color
         End If
         If _back <> -1 Then
            pBrush.Color = _back
         End If
         If Assigned(me.OnGetCellColor) Then
            me.OnGetCellColor(pSender, pRow, pCol, pState, pBrush, pFont)
         End If
      End Sub

      Private Sub _handleCanEditCell(pSender As TObject, pRow As Integer, pCol As Integer, ByRef pCanEdit As Boolean)
         Dim _col As TGridCol = me._colAt(pCol)
         If Not me._isOnlyRead() AndAlso Not me._ctx.Adapter.IsHeaderRow(pRow) Then
            If Assigned(_col) Then
               pCanEdit = _col.IsEditable(me._rowAtNative(pRow))
            End If
         End If
         If Assigned(me.OnCanEditCell) Then
            me.OnCanEditCell(pSender, pRow, pCol, pCanEdit)
         End If
      End Sub

      Private Sub _handleGetInplaceEditor(pSender As TObject, pCol As Integer, pRow As Integer, ByRef pEditor As TWinControl)
         Dim _col As TGridCol = me._colAt(pCol)
         pEditor = Null
         If Not me._isOnlyRead() AndAlso Not me._ctx.Adapter.IsHeaderRow(pRow) Then
            Dim _row As TGridRow = me._ensureRowAtNative(pRow)
            If Assigned(_col) AndAlso Assigned(_row) AndAlso _col.IsEditable(_row) Then
               Dim _factory As TGridEditorFactory = me._factoryOf(_col)
               If Assigned(_factory) AndAlso _factory.UsesInplaceEditor() Then
                  Dim _idx As Integer = me._ctx.Presenter.ToDataIndex(pRow)
                  If _idx < 0 Then
                     _idx = _row.Index
                  End If
                  If _idx >= 0 Then
                     pEditor = me._ctx.EditorPool.AcquireForEdit(_col, pCol, pRow, me._editText(_col, _idx))
                  End If
               End If
            End If
         End If
         If Assigned(me.OnGetInplaceEditor) Then
            me.OnGetInplaceEditor(pSender, pCol, pRow, pEditor)
         End If
      End Sub

      Private Sub _handleDrawCell(pSender As TObject, pCol As Integer, pRow As Integer, pRect As TRect, pState As TGridDrawState)
         If Not me._ctx.Adapter.IsHeaderRow(pRow) Then
            Dim _col As TGridCol = me._colAt(pCol)
            If Assigned(_col) Then
               Dim _drawer As TGridCellDrawer = _col.Options.Drawer
               If Not Assigned(_drawer) Then
                  Dim _factory As TGridEditorFactory = me._factoryOf(_col)
                  If Assigned(_factory) Then
                     _drawer = _factory.Drawer
                  End If
               End If
               If Assigned(_drawer) Then
                  Dim _idx As Integer = me._ctx.Presenter.ToDataIndex(pRow)
                  Dim _text As String = ""
                  Dim _row As TGridRow
                  If _idx >= 0 Then
                     _text = me._displayText(_col, _idx)
                     _row = me._ctx.Data.RowAt(_idx)
                  End If
                  Dim _grid As Grid = me._ctx.Adapter.Native
                  Dim _back As Integer = me._ctx.Presenter.ResolveDataBackColor(_col, _row, pCol)
                  If _back = -1 Then
                     If pCol < _grid.FixedCols Then
                        _back = _grid.FixedColor
                     Else
                        _back = _grid.Color
                     End If
                  End If
                  _drawer.PaintBackColor = _back
                  _drawer.Draw(_grid, pRow, pCol, _col, pRect, _text)
                  _drawer.PaintBackColor = -1
               End If
            End If
         End If
         If Assigned(me.OnDrawCell) Then
            me.OnDrawCell(pSender, pCol, pRow, pRect, pState)
         End If
      End Sub

      Private Sub _handleDblClickCell(pSender As TObject, pRow As Integer, pCol As Integer)
         If Not me._ctx.Adapter.IsHeaderRow(pRow) Then
            If me._isOnlyRead() Then
               If Assigned(me._ctx.SelectionColumn) Then
                  me._toggleSelectionAtNativeRow(pRow)
               End If
            Else
               Dim _col As TGridCol = me._colAt(pCol)
               If Assigned(_col) AndAlso _col.Kind = TGridColumnKind.Checkbox() AndAlso _col.Options.Checkbox.ToggleOnDblClick Then
                  TGridCheckboxSupport.TryToggle(me._ctx, pRow, pCol)
               End If
            End If
         End If
         If Assigned(me.OnDblClickCell) Then
            me.OnDblClickCell(pSender, pRow, pCol)
         End If
      End Sub

      Private Sub _handleKeyPress(pSender As TObject, ByRef pKey As Char)
         Dim _grid As Grid = me._ctx.Adapter.Native
         If Not me._ctx.Adapter.IsHeaderRow(_grid.Row) Then
            Dim _toggled As Boolean = False
            If me._isOnlyRead() AndAlso Assigned(me._ctx.SelectionColumn) Then
               If TGridCheckboxSupport.AcceptsActivationKey(me._ctx.SelectionColumn, pKey) Then
                  _toggled = me._toggleSelectionAtNativeRow(_grid.Row)
               End If
            End If
            If Not _toggled Then
               Dim _col As TGridCol = me._colAt(_grid.Col)
               If Assigned(_col) AndAlso _col.Kind = TGridColumnKind.Checkbox() Then
                  If TGridCheckboxSupport.AcceptsActivationKey(_col, pKey) Then
                     _toggled = TGridCheckboxSupport.TryToggle(me._ctx, _grid.Row, _grid.Col)
                  End If
               End If
            End If
            If _toggled Then
               me._moveToNextDataRow(_grid.Row)
            End If
         End If
         If Assigned(me.OnKeyPress) Then
            me.OnKeyPress(pSender, pKey)
         End If
      End Sub

      Private Sub _moveToNextDataRow(pNativeRow As Integer)
         Dim _next As Integer = pNativeRow + 1
         If me._ctx.Presenter.ToDataIndex(_next) >= 0 Then
            me._ctx.Adapter.Native.Row = _next
         End If
      End Sub

      Private Sub _handleKeyDown(pSender As TObject, ByRef pKey As Word, ByRef pShift As TShiftState)
         If pKey = 40 AndAlso Assigned(me._ctx.Config) AndAlso Assigned(me._ctx.Config.Options) AndAlso me._ctx.Config.Options.Interaction.AddRowOnDown AndAlso Not me._isOnlyRead() Then
            If me._ctx.Data.RowCount = 0 Then
               pKey = 0
               me._insertFirstRowFromPlaceholder()
            Else
               Dim _dataIndex As Integer = me._ctx.Presenter.ToDataIndex(me._ctx.Adapter.Native.Row)
               If _dataIndex >= 0 AndAlso _dataIndex = me._ctx.Data.RowCount - 1 Then
                  Dim _row As TGridRow = me._ctx.Data.RowAt(_dataIndex)
                  Dim _requiredOk As Boolean = me._requiredCellsFilled(_dataIndex)
                  Dim _canInsert As Boolean = _requiredOk
                  Dim _message As String = ""
                  If Not _requiredOk Then
                     _message = "Antes de inserir uma nova linha, informe os dados obrigatórios na linha atual."
                  End If
                  If me._ctx.Config.Options.Interaction.OnBeforeInsertNewRow <> Null Then
                     me._ctx.Config.Options.Interaction.OnBeforeInsertNewRow(_row, _canInsert, _message)
                  End If
                  If Not _requiredOk Then
                     _canInsert = False
                     If Trim(_message) = "" Then
                        _message = "Antes de inserir uma nova linha, informe os dados obrigatórios na linha atual."
                     End If
                  End If
                  pKey = 0
                  If Not _canInsert Then
                     If Trim(_message) <> "" Then
                        MessageBox.Show(_message)
                     End If
                  Else
                     me._insertRowAndFocus()
                  End If
               End If
            End If
         End If
         If Assigned(me.OnKeyDown) Then
            me.OnKeyDown(pSender, pKey, pShift)
         End If
      End Sub

      Private Function _requiredCellsFilled(pDataIndex As Integer) As Boolean
         Dim _filled As Boolean = True
         Dim c As Integer
         For c = 0 To me._ctx.Data.ColCount - 1
            If _filled Then
               Dim _col As TGridCol = me._ctx.Data.ColAt(c)
               If Assigned(_col) AndAlso _col.Options.Interaction.Required Then
                  If me._isRequiredCellEmpty(pDataIndex, c) Then
                     _filled = False
                  End If
               End If
            End If
         Next
         _requiredCellsFilled = _filled
      End Function

      Private Function _isRequiredCellEmpty(pDataIndex As Integer, pColIndex As Integer) As Boolean
         Dim _raw As Variant = me._ctx.Data.GetCell(pDataIndex, pColIndex)
         If IsEmpty(_raw) Then
            _isRequiredCellEmpty = True
         Else
            _isRequiredCellEmpty = Trim(CStr(_raw)) = ""
         End If
      End Function

      Private Sub _insertFirstRowFromPlaceholder()
         Dim _canInsert As Boolean = True
         Dim _message As String = ""
         Dim _row As TGridRow = Null
         If me._ctx.Config.Options.Interaction.OnBeforeInsertNewRow <> Null Then
            me._ctx.Config.Options.Interaction.OnBeforeInsertNewRow(_row, _canInsert, _message)
         End If
         If Not _canInsert Then
            If Trim(_message) <> "" Then
               MessageBox.Show(_message)
            End If
         Else
            me._insertRowAndFocus()
         End If
      End Sub

      Private Sub _insertRowAndFocus()
         Dim _newRow As TGridRow = me._ctx.Data.PushRow()
         If Assigned(_newRow) Then
            Dim _nativeRow As Integer = me._ctx.Presenter.ToNativeRow(_newRow.Index)
            Dim _focused As Boolean = False
            Dim c As Integer
            For c = 0 To me._ctx.Data.ColCount - 1
               If Not _focused Then
                  Dim _col As TGridCol = me._ctx.Data.ColAt(c)
                  If Assigned(_col) AndAlso Not _col.Options.Layout.Hidden AndAlso _col.IsEditable(_newRow) Then
                     me._ctx.Adapter.Native.Col = me._ctx.Adapter.ToNativeCol(c)
                     me._ctx.Adapter.Native.Row = _nativeRow
                     _focused = True
                  End If
               End If
            Next
            If Not _focused Then
               me._ctx.Adapter.Native.Row = _nativeRow
            End If
         End If
      End Sub

      Private Sub _handleCellValidate(pSender As TObject, pCol As Integer, pRow As Integer, ByRef pValue As String, ByRef pValid As Boolean)
         pValid = True
         If Not me._isOnlyRead() AndAlso Not me._ctx.Presenter.Syncing Then
            Dim _col As TGridCol = me._colAt(pCol)
            If Assigned(_col) Then
               Dim _dataCol As Integer = _col.Index
               Dim _dataIndex As Integer = me._ctx.Presenter.ToDataIndex(pRow)
               If _dataIndex >= 0 Then
                  If _col.Options.System.IsSelection Then
                     pValue = me._ctx.Data.CellText(_dataIndex, _dataCol)
                  ElseIf _col.Options.System.IsRowNumber Then
                     pValue = me._ctx.Data.CellText(_dataIndex, _dataCol)
                  Else
                     Dim _factory As TGridEditorFactory = me._factoryOf(_col)
                     If Assigned(_factory) AndAlso _factory.UsesInplaceEditor() Then
                        Dim _edit As GridEditorLink = me._ctx.Adapter.Native.GetEditorLink()
                        If Assigned(_edit) AndAlso Assigned(_edit.Control) Then
                           pValid = _factory.Validate(_edit.Control)
                           If pValid Then
                              pValue = _factory.GetValue(_edit.Control)
                           End If
                        End If
                     End If
                     Dim _message As String = ""
                     If pValid Then
                        pValid = _col.Validate(_dataIndex, _dataCol, pValue, _message)
                     End If
                     If pValid AndAlso Assigned(me._ctx.Config) AndAlso Assigned(me._ctx.Config.GlobalValidators) Then
                        pValid = me._ctx.Config.GlobalValidators.Validate(_dataIndex, _dataCol, pValue, _message)
                     End If
                  End If
               End If
            End If
         End If
         If Assigned(me.OnCellValidate) Then
            me.OnCellValidate(pSender, pCol, pRow, pValue, pValid)
         End If
      End Sub

      Private Sub _handleSetEditText(pSender As TObject, pCol As Integer, pRow As Integer, pValue As String)
         If Not me._committing AndAlso Not me._ctx.Adapter.IsPoking() AndAlso Not me._isOnlyRead() AndAlso Not me._ctx.Presenter.Syncing Then
            Dim _col As TGridCol = me._colAt(pCol)
            If Assigned(_col) AndAlso Not _col.Options.System.IsSelection AndAlso Not _col.Options.System.IsRowNumber Then
               Dim _factory As TGridEditorFactory = me._factoryOf(_col)
               Dim _canSet As Boolean = True
               If Assigned(_factory) Then
                  _canSet = _factory.UsesInplaceEditor()
               End If
               If _canSet Then
                  Dim _dataCol As Integer = _col.Index
                  Dim _dataIndex As Integer = me._ctx.Presenter.ToDataIndex(pRow)
                  If _dataIndex >= 0 Then
                     Dim _row As TGridRow = me._ctx.Data.RowAt(_dataIndex)
                     If Assigned(_row) AndAlso _row.Editable Then
                        me._committing = True
                        Dim _valid As Boolean = True
                        Dim _value As Variant = pValue
                        me._ctx.Data.SetCell(_dataIndex, _dataCol, _value)
                        _row.Dirty = True
                        _col.ApplySideEffects(me._ctx.Data, _row, _value, _valid, me._ctx.Adapter.Native)
                        If Assigned(me._ctx.Config) AndAlso Assigned(me._ctx.Config.GlobalSideEffects) Then
                           me._ctx.Config.GlobalSideEffects.Apply(me._ctx.Data, _row, _col, _value, _valid, me._ctx.Adapter.Native)
                        End If
                        me._ctx.Presenter.PokeDataCell(_dataCol, _dataIndex)
                        If _col.Options.Search.DescriptionColumnId <> "" Then
                           Dim _descIdx As Integer = me._ctx.Data.GetColIndex(_col.Options.Search.DescriptionColumnId)
                           me._ctx.Presenter.PokeDataCell(_descIdx, _dataIndex)
                        End If
                        me._committing = False
                     End If
                  End If
               End If
            End If
         End If
         If Assigned(me.OnSetEditText) Then
            me.OnSetEditText(pSender, pCol, pRow, pValue)
         End If
      End Sub

      Private Sub _handleRowMove(pSender As TObject, pRow As Integer, ByRef pAllow As Boolean)
         Dim _row As TGridRow = me._rowAtNative(pRow)
         If Assigned(_row) Then
            pAllow = _row.CanMove
         End If
         If Assigned(me.OnRowMove) Then
            me.OnRowMove(pSender, pRow, pAllow)
         End If
      End Sub

      Private Sub _handleColumnMove(pSender As TObject, pCol As Integer, ByRef pAllow As Boolean)
         Dim _col As TGridCol = me._colAt(pCol)
         If Assigned(_col) Then
            pAllow = _col.Options.Interaction.CanMove
         End If
         If Assigned(me.OnColumnMove) Then
            me.OnColumnMove(pSender, pCol, pAllow)
         End If
      End Sub

      Private Sub _handleRowSize(pSender As TObject, pRow As Integer, ByRef pAllow As Boolean)
         Dim _row As TGridRow = me._rowAtNative(pRow)
         If Assigned(_row) Then
            pAllow = _row.CanResize
         End If
         If Assigned(me.OnRowSize) Then
            me.OnRowSize(pSender, pRow, pAllow)
         End If
      End Sub

      Private Sub _handleColumnSize(pSender As TObject, pCol As Integer, ByRef pAllow As Boolean)
         Dim _col As TGridCol = me._colAt(pCol)
         If Assigned(_col) Then
            pAllow = _col.Options.Interaction.CanResize
         End If
         If Assigned(me.OnColumnSize) Then
            me.OnColumnSize(pSender, pCol, pAllow)
         End If
      End Sub

      Private Sub _handleRowMoved(pSender As TObject, pFromIndex As Integer, pToIndex As Integer)
         If Not me._ctx.Presenter.Syncing Then
            Dim _from As Integer = me._ctx.Adapter.ToDataRow(pFromIndex)
            Dim _to As Integer = me._ctx.Adapter.ToDataRow(pToIndex)
            If _from >= 0 AndAlso _to >= 0 AndAlso _from < me._ctx.Data.RowCount AndAlso _to < me._ctx.Data.RowCount Then
               Dim _row As TGridRow = me._ctx.Data.RowAt(_from)
               If Assigned(_row) Then
                  me._ctx.Data.MoveRow(_row.ID, _to)
               End If
            End If
         End If
         If Assigned(me.OnRowMoved) Then
            me.OnRowMoved(pSender, pFromIndex, pToIndex)
         End If
      End Sub

      Private Sub _handleColumnMoved(pSender As TObject, pFromIndex As Integer, pToIndex As Integer)
         If Not me._ctx.Presenter.Syncing Then
            Dim _from As Integer = me._ctx.Adapter.ToDataCol(pFromIndex)
            Dim _to As Integer = me._ctx.Adapter.ToDataCol(pToIndex)
            If _from >= 0 AndAlso _to >= 0 AndAlso _from < me._ctx.Data.ColCount AndAlso _to < me._ctx.Data.ColCount Then
               Dim _col As TGridCol = me._ctx.Data.ColAt(_from)
               If Assigned(_col) Then
                  me._ctx.Data.MoveCol(_col.ID, _to)
                  me._ctx.ReorderSystemColumns()
               End If
            End If
         End If
         me._ctx.Adapter.ApplyColumnAlignments(me._ctx.Data)
         If Assigned(me.OnColumnMoved) Then
            me.OnColumnMoved(pSender, pFromIndex, pToIndex)
         End If
      End Sub

      Private Sub _handleCanSort(pSender As TObject, pCol As Integer, ByRef pDoSort As Boolean)
         Dim _col As TGridCol = me._colAt(pCol)
         pDoSort = me._canSortCol(_col)
         If Assigned(me.OnCanSort) Then
            me.OnCanSort(pSender, pCol, pDoSort)
         End If
      End Sub

      Private Function _canSortCol(pCol As TGridCol) As Boolean
         Dim _ok As Boolean = False
         If Assigned(pCol) AndAlso pCol.Options.Sort.CanSort AndAlso Not pCol.Options.System.IsSelection Then
            _ok = True
            If pCol.Options.System.IsRowNumber AndAlso Assigned(me._ctx.Config) AndAlso Assigned(me._ctx.Config.Options) AndAlso me._ctx.Config.Options.Item.AutoUpdate Then
               _ok = False
            End If
         End If
         _canSortCol = _ok
      End Function

      Private Sub _handleClickSort(pSender As TObject, pCol As Integer)
         Dim _col As TGridCol = me._colAt(pCol)
         If me._canSortCol(_col) Then
            Dim _asc As Boolean = True
            If me._sortColId = _col.ID Then
               _asc = Not me._sortAsc
            End If
            me._sortColId = _col.ID
            me._sortAsc = _asc
            me._sortCol = _col
            me._sortColIndex = _col.Index
            me._ctx.Data.SortGridRows(me._sortByColId, _asc, _col.ID)
            If Assigned(me._ctx.Config) AndAlso Assigned(me._ctx.Config.Options) AndAlso me._ctx.Config.Options.Item.AutoUpdate Then
               me._ctx.Data.RenumberItems()
            End If
            me._ctx.Presenter.InvalidateIfPrepared()
         End If
         If Assigned(me.OnClickSort) Then
            me.OnClickSort(pSender, pCol)
         End If
      End Sub

      Private Function _sortByColId(pRow As TGridRow, pIndex As Integer, pExtra As Variant) As String
         Dim _col As TGridCol = me._sortCol
         If Assigned(_col) Then
            Dim _value As Variant
            If _col.Options.System.IsRowNumber Then
               If Assigned(pRow) Then
                  _value = pRow.ItemNumber
               Else
                  _value = Unassigned
               End If
            ElseIf me._sortColIndex >= 0 Then
               _value = me._ctx.Data.GetCell(pIndex, me._sortColIndex)
            Else
               _value = me._ctx.Data.GetCell(pIndex, CStr(pExtra))
            End If
            _sortByColId = _col.SortKey(_value)
         Else
            _sortByColId = ""
         End If
      End Function

      Private Function _canCheckboxPopup(pCol As TGridCol, pRow As TGridRow) As Boolean
         Dim _ok As Boolean = False
         If Assigned(pCol) AndAlso Assigned(pRow) AndAlso pRow.Editable Then
            If pCol.Kind = TGridColumnKind.Checkbox() Then
               If Not pCol.Options.Interaction.OnlyRead Then
                  If me._isOnlyRead() Then
                     _ok = pCol.Options.System.IsSelection
                  Else
                     _ok = True
                  End If
               End If
            End If
         End If
         _canCheckboxPopup = _ok
      End Function

      Private Sub _handleContextPopup(pSender As TObject, pMousePos As TPoint, ByRef pHandled As Boolean)
         pHandled = False
         Dim _grid As Grid = me._ctx.Adapter.Native
         Dim _nativeCol As Integer
         Dim _nativeRow As Integer
         If pMousePos.X <= 0 And pMousePos.Y <= 0 Then
            _nativeCol = _grid.Col
            _nativeRow = _grid.Row
         Else
            _nativeCol = me._ctx.Adapter.NativeColAtX(pMousePos.X)
            _nativeRow = me._ctx.Adapter.NativeRowAtY(pMousePos.Y)
         End If
         Dim _col As TGridCol = me._colAt(_nativeCol)
         Dim _row As TGridRow = me._rowAtNative(_nativeRow)
         If me._canCheckboxPopup(_col, _row) Then
            If _nativeCol >= 0 Then
               _grid.Col = _nativeCol
            End If
            If _nativeRow >= 0 Then
               _grid.Row = _nativeRow
            End If
            Dim _popup As TGridCheckboxPopup = New TGridCheckboxPopup()
            Dim _item As TGridPopupItem = _popup.Show(_col.Options.System.IsSelection)
            If Assigned(_item) Then
               me._applyCheckboxPopup(_col, me._ctx.Presenter.ToDataIndex(_nativeRow), _item.Key)
            End If
            _popup.Free()
            pHandled = True
         End If
         If Assigned(me.OnContextPopup) Then
            me.OnContextPopup(pSender, pMousePos, pHandled)
         End If
      End Sub

      Private Sub _applyCheckboxPopup(pCol As TGridCol, pDataIndex As Integer, pKey As String)
         If pKey = "check-current" Then
            TGridCheckboxSupport.ApplyScope(me._ctx, pCol, pDataIndex, "check", "current")
         ElseIf pKey = "uncheck-current" Then
            TGridCheckboxSupport.ApplyScope(me._ctx, pCol, pDataIndex, "uncheck", "current")
         ElseIf pKey = "check-all" Then
            TGridCheckboxSupport.ApplyScope(me._ctx, pCol, pDataIndex, "check", "all")
         ElseIf pKey = "uncheck-all" Then
            TGridCheckboxSupport.ApplyScope(me._ctx, pCol, pDataIndex, "uncheck", "all")
         ElseIf pKey = "invert-all" Then
            TGridCheckboxSupport.ApplyScope(me._ctx, pCol, pDataIndex, "invert", "all")
         End If
      End Sub

      Private Sub _handleResize(pSender As TObject)
         If Assigned(me._ctx.Presenter) Then
            me._ctx.Presenter.ApplyColumnLayoutOnResize()
         End If
         If Assigned(me.OnResize) Then
            me.OnResize(pSender)
         End If
      End Sub

      Private Sub _handleMarcaExclusao(pSender As TObject, pARow As Integer)
         Dim _idx As Integer = me._ctx.Presenter.ToDataIndex(pARow)
         If _idx >= 0 Then
            Dim _row As TGridRow = me._ctx.Data.RowAt(_idx)
            If Assigned(_row) AndAlso _row.Editable Then
               _row.Deleted = Not _row.Deleted
            End If
         End If
         If Assigned(me.OnMarcaDesmarcaLinhaParaExclusao) Then
            me.OnMarcaDesmarcaLinhaParaExclusao(pSender, pARow)
         End If
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me.OnCanEditCell = Null
         me.OnGetInplaceEditor = Null
         me.OnGetDisplText = Null
         me.OnGetEditText = Null
         me.OnSetEditText = Null
         me.OnCellValidate = Null
         me.OnGetCellColor = Null
         me.OnDrawCell = Null
         me.OnDblClickCell = Null
         me.OnKeyPress = Null
         me.OnKeyDown = Null
         me.OnRowMoved = Null
         me.OnColumnMoved = Null
         me.OnRowMove = Null
         me.OnColumnMove = Null
         me.OnRowSize = Null
         me.OnColumnSize = Null
         me.OnClickSort = Null
         me.OnCanSort = Null
         me.OnMarcaDesmarcaLinhaParaExclusao = Null
         me.OnResize = Null
         me.OnContextPopup = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
