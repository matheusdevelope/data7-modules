Imports mod_tobject
Imports mod_ttmatrix
Imports mod_grid_col
Imports mod_grid_row
Imports mod_grid_editor_registry
Imports mod_grid_editor_contract
Namespace mod_grid_data
   Delegate Sub TGridRowStateDel(pRow As TGridRow)
   Delegate Function TGridSortRowDel(pRow As TGridRow, pIndex As Integer, pExtra As Variant) As String
   Class TGridData
      Inherits TTMatrix<TGridCol, TGridRow, Variant>
      Private _rowSeq As Integer = 0
      Private _maxItemNumber As Integer = 0
      ItemNumberSize As Integer = 1
      EditorRegistry As TGridEditorRegistry
      OnRowStateChanged As TGridRowStateDel
      Sub New()
         MyBase.New("TGridData", True, False)
      End Sub
      Sub New(pValue As TGridData)
         MyBase.New("TGridData", True, False)
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridData)
      End Sub
      Overrides Function Clone() As TTObject
         Clone = New TGridData(me)
      End Function
      Function ColAt(pIndex As Integer) As TGridCol
         If pIndex >= 0 AndAlso pIndex < me.ColCount Then
            ColAt = TGridCol(MyBase.Col(pIndex))
         End If
      End Function
      Function ColAt(pColID As String) As TGridCol
         Dim idx As Integer = me.GetColIndex(pColID)
         If idx >= 0 Then
            ColAt = me.ColAt(idx)
         End If
      End Function
      Function RowAt(pIndex As Integer) As TGridRow
         If pIndex >= 0 AndAlso pIndex < me.RowCount Then
            RowAt = TGridRow(MyBase.Row(pIndex))
         End If
      End Function
      Function RowAt(pRowID As String) As TGridRow
         RowAt = TGridRow(MyBase.RowFromID(pRowID))
      End Function
      Function GetColIndex(pColID As String) As Integer
         Dim _idx As Integer = -1
         Dim i As Integer
         For i = 0 To me.ColCount - 1
            If _idx < 0 Then
               Dim col As TGridCol = me.ColAt(i)
               If Assigned(col) AndAlso col.ID = pColID Then
                  _idx = i
               End If
            End If
         Next
         GetColIndex = _idx
      End Function
      Function HasCol(pColID As String) As Boolean
         HasCol = me.GetColIndex(pColID) >= 0
      End Function
      Sub MoveCol(pColID As String, pToIndex As Integer)
         MyBase.MoveCol(pColID, pToIndex)
      End Sub
      Sub DeleteCol(pColID As String)
         MyBase.DeleteColFromID(pColID)
      End Sub
      Sub DeleteCol(pIndex As Integer)
         MyBase.DeleteCol(pIndex)
      End Sub
      Sub DeleteRow(pRowID As String)
         MyBase.DeleteRowFromID(pRowID)
      End Sub
      Sub DeleteRow(pIndex As Integer)
         MyBase.DeleteRow(pIndex)
      End Sub
      Function PushColumn(pCol As TGridCol) As TGridCol
         If Assigned(pCol) Then
            ' data7:disable-next-line type-mismatch
            MyBase.AddColumn(pCol)
         End If
         PushColumn = pCol
      End Function
      Function PushRow() As TGridRow
         PushRow = me.PushRow(New TGridRow(me._nextRowID()))
      End Function
      Function PushRow(pID As String) As TGridRow
         If Trim(pID) = "" Then
            PushRow = me.PushRow()
         Else
            PushRow = me.PushRow(New TGridRow(pID))
         End If
      End Function
      Function PushRow(pRow As TGridRow) As TGridRow
         If Assigned(pRow) Then
            pRow.IsNew = True
            pRow.OnStateChanged = me._handleRowState
            If pRow.ItemNumber < 1 Then
               pRow.ItemNumber = me._nextItemNumber()
            ElseIf pRow.ItemNumber > me._maxItemNumber Then
               me._maxItemNumber = pRow.ItemNumber
            End If
            ' data7:disable-next-line type-mismatch
            MyBase.AddRow(pRow)
            me._applyColumnDefaults(pRow)
            PushRow = pRow
         End If
      End Function
      Private Function _nextRowID() As String
         me._rowSeq = me._rowSeq + 1
         _nextRowID = "r" + CStr(me._rowSeq)
      End Function
      Sub RenumberItems()
         Dim i As Integer
         For i = 0 To me.RowCount - 1
            Dim _row As TGridRow = me.RowAt(i)
            If Assigned(_row) Then
               _row.ItemNumber = i + 1
            End If
         Next
         me._maxItemNumber = me.RowCount
      End Sub
      Private Function _nextItemNumber() As Integer
         me._maxItemNumber = me._maxItemNumber + 1
         _nextItemNumber = me._maxItemNumber
      End Function
      Private Sub _applyColumnDefaults(pRow As TGridRow)
         If Assigned(pRow) Then
            Dim i As Integer
            Dim _rowIndex As Integer = pRow.Index
            For i = 0 To me.ColCount - 1
               Dim _col As TGridCol = me.ColAt(i)
               If Assigned(_col) AndAlso _col.HasDefault() Then
                  If Not _col.Options.System.IsRowNumber Then
                     If me._cellNeedsDefault(_rowIndex, i) Then
                        Dim _def As Variant = _col.ResolveDefault(pRow)
                        If Not IsEmpty(_def) Then
                           me.SetCell(_rowIndex, i, _def)
                        End If
                     End If
                  End If
               End If
            Next
         End If
      End Sub
      Private Function _cellNeedsDefault(pRowIndex As Integer, pColIndex As Integer) As Boolean
         Dim _raw As Variant = me.GetCell(pRowIndex, pColIndex)
         If IsEmpty(_raw) Then
            _cellNeedsDefault = True
         Else
            _cellNeedsDefault = Trim(CStr(_raw)) = ""
         End If
      End Function
      Private Sub _handleRowState(pRow As TGridRow)
         If me.OnRowStateChanged <> Null Then
            me.OnRowStateChanged(pRow)
         End If
      End Sub
      Sub SetCell(pRowIndex As Integer, pColIndex As Integer, pValue As Variant)
         Dim _col As TGridCol = me.ColAt(pColIndex)
         If Assigned(_col) Then
            If _col.Options.System.IsSelection Then
               Dim _row As TGridRow = me.RowAt(pRowIndex)
               If Assigned(_row) Then
                  Dim _text As String = ""
                  If Not IsEmpty(pValue) Then
                     _text = CStr(pValue)
                  End If
                  _row.Selected = UCase(Trim(_text)) = UCase(Trim(_col.Options.Checkbox.CheckedValue))
               End If
            ElseIf Not _col.Options.System.IsRowNumber Then
               ' data7:disable-next-line type-mismatch
               MyBase.SetValue(pRowIndex, pColIndex, pValue)
            End If
         Else
            ' data7:disable-next-line type-mismatch
            MyBase.SetValue(pRowIndex, pColIndex, pValue)
         End If
      End Sub
      Sub SetCell(pRowIndex As Integer, pColID As String, pValue As Variant)
         Dim cIdx As Integer = me.GetColIndex(pColID)
         If cIdx <> -1 Then
            me.SetCell(pRowIndex, cIdx, pValue)
         End If
      End Sub
      Sub SetCell(pRowID As String, pColID As String, pValue As Variant)
         Dim cIdx As Integer = me.GetColIndex(pColID)
         If cIdx >= 0 Then
            Dim _col As TGridCol = me.ColAt(cIdx)
            If Assigned(_col) Then
               If _col.Options.System.IsSelection Then
                  Dim _row As TGridRow = me.RowAt(pRowID)
                  If Assigned(_row) Then
                     Dim _text As String = ""
                     If Not IsEmpty(pValue) Then
                        _text = CStr(pValue)
                     End If
                     _row.Selected = UCase(Trim(_text)) = UCase(Trim(_col.Options.Checkbox.CheckedValue))
                  End If
               ElseIf Not _col.Options.System.IsRowNumber Then
                  ' data7:disable-next-line type-mismatch
                  ' data7:disable-next-line unknown-member
                  MyBase.SetValueFromID(pRowID, pColID, pValue)
               End If
            Else
               ' data7:disable-next-line type-mismatch
               ' data7:disable-next-line unknown-member
               MyBase.SetValueFromID(pRowID, pColID, pValue)
            End If
         End If
      End Sub
      Function GetCell(pRowIndex As Integer, pColIndex As Integer) As Variant
         ' data7:disable-next-line type-mismatch
         If pRowIndex >= 0 AndAlso pColIndex >= 0 AndAlso pRowIndex < me.RowCount AndAlso pColIndex < me.ColCount Then
            GetCell = MyBase.GetValue(pRowIndex, pColIndex)
         End If
      End Function
      Function GetCell(pRowIndex As Integer, pColID As String) As Variant
         Dim cIdx As Integer = me.GetColIndex(pColID)
         If cIdx >= 0 Then
            GetCell = me.GetCell(pRowIndex, cIdx)
         End If
      End Function
      Function GetCell(pRowID As String, pColID As String) As Variant
         Dim _row As TGridRow = me.RowAt(pRowID)
         If Assigned(_row) Then
            GetCell = me.GetCell(_row.Index, pColID)
         End If
      End Function
      Sub SortGridRows(pHandler As TGridSortRowDel, pAsc As Boolean, pExtra As Variant)
         ' data7:disable-next-line type-mismatch
         MyBase.SortRows(pHandler, pAsc, pExtra)
      End Sub
      Function CellRaw(pRowIndex As Integer, pColIndex As Integer) As Variant
         Dim _col As TGridCol = me.ColAt(pColIndex)
         If Assigned(_col) Then
            CellRaw = me._cellRaw(pRowIndex, _col)
         End If
      End Function
      Function CellRaw(pRowIndex As Integer, pCol As TGridCol) As Variant
         If Assigned(pCol) Then
            CellRaw = me._cellRaw(pRowIndex, pCol)
         End If
      End Function
      Function CellText(pRowIndex As Integer, pColIndex As Integer) As String
         Dim _col As TGridCol = me.ColAt(pColIndex)
         If Assigned(_col) Then
            CellText = me._formatCell(_col, me._cellRaw(pRowIndex, _col))
         Else
            CellText = ""
         End If
      End Function
      Private Function _formatCell(pCol As TGridCol, pRaw As Variant) As String
         Dim _factory As TGridEditorFactory
         If Assigned(pCol.Factory) Then
            _factory = pCol.Factory
         ElseIf Assigned(me.EditorRegistry) Then
            _factory = me.EditorRegistry.Resolve(pCol.Kind)
            pCol.Factory = _factory
         End If
         If Assigned(_factory) Then
            _formatCell = _factory.FormatValue(pCol, pRaw)
         Else
            _formatCell = me._asText(pRaw)
         End If
      End Function
      Private Function _asText(pValue As Variant) As String
         If IsEmpty(pValue) Then
            _asText = ""
         Else
            _asText = CStr(pValue)
         End If
      End Function
      Private Function _cellRaw(pRowIndex As Integer, pCol As TGridCol) As Variant
         If pCol.Options.System.IsSelection Then
            _cellRaw = me._selectionRaw(pRowIndex, pCol)
         ElseIf pCol.Options.System.IsRowNumber Then
            _cellRaw = me._rowNumberRaw(pRowIndex)
         Else
            _cellRaw = me.GetCell(pRowIndex, pCol.Index)
         End If
      End Function
      Private Function _selectionRaw(pRowIndex As Integer, pCol As TGridCol) As Variant
         Dim _row As TGridRow = me.RowAt(pRowIndex)
         If Assigned(_row) Then
            If _row.Selected Then
               _selectionRaw = pCol.Options.Checkbox.CheckedValue
            Else
               _selectionRaw = pCol.Options.Checkbox.UncheckedValue
            End If
         Else
            _selectionRaw = pCol.Options.Checkbox.UncheckedValue
         End If
      End Function
      Private Function _rowNumberRaw(pRowIndex As Integer) As Variant
         Dim n As Integer = pRowIndex + 1
         Dim _row As TGridRow = me.RowAt(pRowIndex)
         If Assigned(_row) Then
            If _row.ItemNumber > 0 Then
               n = _row.ItemNumber
            End If
         End If
         _rowNumberRaw = me._padItemNumber(n)
      End Function
      Function CellText(pRowIndex As Integer, pColID As String) As String
         Dim cIdx As Integer = me.GetColIndex(pColID)
         If cIdx >= 0 Then
            CellText = me.CellText(pRowIndex, cIdx)
         Else
            CellText = ""
         End If
      End Function
      Private Function _padItemNumber(pValue As Integer) As String
         Dim width As Integer = Len(CStr(me.RowCount))
         If me.ItemNumberSize > width Then
            width = me.ItemNumberSize
         End If
         If width < 1 Then
            width = 1
         End If
         Dim s As String = CStr(pValue)
         _padItemNumber = Right(s.StringOfChar("0", width) + s, width)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("ColCount", me.ColCount)
            .Prop("RowCount", me.RowCount)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me.OnRowStateChanged = Null
         me.EditorRegistry = Null
         MyBase.Dispose()
      End Sub
      Sub Free()
         MyBase.Free(True)
      End Sub
   End Class
End Namespace
