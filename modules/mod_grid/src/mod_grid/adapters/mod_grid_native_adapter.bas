Imports Forms
Imports mod_tobject
Imports mod_grid_data
Imports mod_grid_col
Imports mod_grid_config
Imports mod_grid_column_kind
Namespace mod_grid_native_adapter
   Class TNativeGridAdapter
      Inherits TTObject
      Private _parent As TWinControl
      Private _grid As Grid
      Private _layoutBusy As Boolean
      Private _poking As Boolean
      Sub New(pParent As TWinControl)
         MyBase.New()
         me._parent = pParent
         me._grid = New Grid(me._parent)
      End Sub
      Sub New(pValue As TNativeGridAdapter)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TNativeGridAdapter)
         If Assigned(pValue) Then
            me._parent = pValue._parent
            me._grid = pValue._grid
            me._poking = pValue._poking
         End If
      End Sub
      Overrides Function Clone() As TNativeGridAdapter
         Clone = New TNativeGridAdapter(me)
      End Function
      Property Native As Grid
         Get
            Native = me._grid
         End Get
      End Property
      Sub Mount()
         me._grid.Align = alClient
         me._grid.AlignWithMargins = True
         me._grid.GridOptions.ColMoving = False
         me._grid.GridOptions.RowMoving = False
         me._grid.GridOptions.ColSizing = False
         me._grid.GridOptions.RowSizing = False
         me._grid.GridOptions.FixedColClick = True
         me._grid.GridOptions.FixedRowClick = True
         me._grid.VirtualEdit = False
         me._grid.EnableHTML = True
      End Sub
      Sub BeginUpdate()
         me._grid.BeginUpdate()
      End Sub
      Sub EndUpdate()
         me._grid.EndUpdate()
      End Sub
      Sub InvalidateDisplay()
      End Sub
      Function IsPoking() As Boolean
         IsPoking = me._poking
      End Function
      Sub PokeCell(pNativeCol As Integer, pNativeRow As Integer, pText As String)
         If Assigned(me._grid) AndAlso pNativeCol >= 0 AndAlso pNativeRow >= 0 Then
            me._poking = True
            me._grid.Cells(pNativeCol, pNativeRow) = pText
            me._poking = False
         End If
      End Sub
      Sub ApplyColumns(pData As TGridData)
         me.SetVisibleColCount(pData)
         me.ApplyColumnWidths(pData)
         me.ApplyColumnAlignments(pData)
      End Sub
      Sub SetVisibleColCount(pData As TGridData)
         Dim _count As Integer = pData.ColCount
         If _count < 1 Then
            _count = 1
         End If
         me._grid.PermiteMarcarExclusao = False
         me._grid.UnHideColumnsAll()
         me._grid.ColCount = _count
         If me._grid.RowCount < me._grid.FixedRows + 1 Then
            me._grid.RowCount = me._grid.FixedRows + 1
         End If
      End Sub
      Sub ApplyColumnWidths(pData As TGridData)
         Dim i As Integer
         For i = 0 To pData.ColCount - 1
            Dim _col As TGridCol = pData.ColAt(i)
            If Assigned(_col) Then
               me._grid.ColWidth(i) = _col.Options.Layout.Width
            End If
         Next
      End Sub
      Sub ApplyColumnAlignments(pData As TGridData)
         Dim i As Integer
         For i = 0 To pData.ColCount - 1
            Dim _col As TGridCol = pData.ColAt(i)
            If Assigned(_col) AndAlso _col.HasAlignment() Then
               me._grid.ColAlignment(i) = _col.Alignment
            End If
         Next
      End Sub
      Sub ApplyColumnHeaders(pData As TGridData)
         me.ApplyColumnWidths(pData)
         me.ApplyColumnAlignments(pData)
      End Sub
      Sub ApplyHiddenColumns(pData As TGridData)
         Dim i As Integer = pData.ColCount - 1
         While i >= 0
            Dim _col As TGridCol = pData.ColAt(i)
            If Assigned(_col) AndAlso _col.Options.Layout.Hidden Then
               me._grid.HideColumn(i)
            End If
            i = i - 1
         Wend
      End Sub
      Sub ApplyOptions(pOptions As TGridOptionsConfig)
         If Assigned(pOptions) Then
            me._grid.GridOptions.RowSelect = pOptions.Interaction.OnlyRead
            If pOptions.Color.Text <> -1 Then
               me._grid.Font.Color = pOptions.Color.Text
            End If
            If pOptions.Color.Header.Text <> -1 Then
               me._grid.FixedFont.Color = pOptions.Color.Header.Text
            ElseIf pOptions.Color.Text <> -1 Then
               me._grid.FixedFont.Color = pOptions.Color.Text
            End If
            If pOptions.Color.Back <> -1 Then
               me._grid.Color = pOptions.Color.Back
            End If
            If pOptions.Color.Fixed.Back <> -1 Then
               me._grid.FixedColor = pOptions.Color.Fixed.Back
            ElseIf pOptions.Color.Header.Back <> -1 Then
               me._grid.FixedColor = pOptions.Color.Header.Back
            End If
         End If
      End Sub
      Sub SetCellFontColor(pNativeCol As Integer, pNativeRow As Integer, pColor As Integer)
         me._grid.FontColor(pNativeCol, pNativeRow) = pColor
      End Sub
      Sub SetCellBackColor(pNativeCol As Integer, pNativeRow As Integer, pColor As Integer)
         me._grid.CellColor(pNativeCol, pNativeRow) = pColor
      End Sub
      Sub ApplyMarkForDelete(pAllow As Boolean)
         me._grid.PermiteMarcarExclusao = pAllow
      End Sub
      Sub ApplyColumnLayout(pOptions As TGridOptionsConfig)
         If Not me._layoutBusy AndAlso Assigned(pOptions) Then
            me._layoutBusy = True
            me._grid.AutoSize = pOptions.Layout.AutoSize
            If pOptions.Layout.StretchLastColumn Then
               If pOptions.Layout.AutoSize Then
                  me._grid.AutoSize = False
               End If
               me.StretchLastVisibleColumn()
            End If
            me._layoutBusy = False
         End If
      End Sub
      Sub ApplyColumnLayoutOnResize(pOptions As TGridOptionsConfig)
         If Not me._layoutBusy AndAlso Assigned(pOptions) AndAlso pOptions.Layout.StretchLastColumn Then
            me._layoutBusy = True
            me.StretchLastVisibleColumn()
            me._layoutBusy = False
         End If
      End Sub
      Sub StretchLastVisibleColumn()
         Dim last As Integer = -1
         Dim i As Integer
         For i = 0 To me._grid.ColCount - 1
            If Not me._grid.IsHiddenColumn(i) Then
               last = i
            End If
         Next
         If last >= 0 Then
            Dim used As Integer = 0
            For i = 0 To last - 1
               If Not me._grid.IsHiddenColumn(i) Then
                  used = used + me._grid.ColWidth(i)
               End If
            Next
            Dim avail As Integer = me._grid.ClientWidth
            If avail < 1 Then
               avail = me._grid.Width
            End If
            Dim remain As Integer = avail - used
            Dim _min As Integer = me._grid.MinColWidth
            If _min < 1 Then
               _min = 20
            End If
            If remain < _min Then
               remain = _min
            End If
            me._grid.ColWidth(last) = remain
         End If
      End Sub
      Function NativeColAtX(pX As Integer) As Integer
         Dim _found As Integer = -1
         Dim _acc As Integer = 0
         Dim i As Integer
         Dim _fixed As Integer = me._grid.FixedCols
         If _fixed < 0 Then
            _fixed = 0
         End If
         For i = 0 To _fixed - 1
            If _found < 0 Then
               If Not me._grid.IsHiddenColumn(i) Then
                  _acc = _acc + me._grid.ColWidth(i)
                  If pX < _acc Then
                     _found = i
                  End If
               End If
            End If
         Next
         Dim _start As Integer = me._grid.LeftCol
         If _start < _fixed Then
            _start = _fixed
         End If
         For i = _start To me._grid.ColCount - 1
            If _found < 0 Then
               If Not me._grid.IsHiddenColumn(i) Then
                  _acc = _acc + me._grid.ColWidth(i)
                  If pX < _acc Then
                     _found = i
                  End If
               End If
            End If
         Next
         If _found < 0 Then
            _found = me._grid.Col
         End If
         NativeColAtX = _found
      End Function
      Private Function _rowHeightAt(pRow As Integer) As Integer
         Dim _h As Integer
         If pRow < me._grid.FixedRows Then
            _h = me._grid.FixedRowHeight
         Else
            _h = me._grid.DefaultRowHeight
         End If
         If _h < 1 Then
            _h = 18
         End If
         _rowHeightAt = _h
      End Function
      Function NativeRowAtY(pY As Integer) As Integer
         Dim _found As Integer = -1
         Dim _acc As Integer = 0
         Dim i As Integer
         Dim _fixed As Integer = me._grid.FixedRows
         If _fixed < 0 Then
            _fixed = 0
         End If
         For i = 0 To _fixed - 1
            If _found < 0 Then
               _acc = _acc + me._rowHeightAt(i)
               If pY < _acc Then
                  _found = i
               End If
            End If
         Next
         Dim _start As Integer = me._grid.TopRow
         If _start < _fixed Then
            _start = _fixed
         End If
         For i = _start To me._grid.RowCount - 1
            If _found < 0 Then
               _acc = _acc + me._rowHeightAt(i)
               If pY < _acc Then
                  _found = i
               End If
            End If
         Next
         If _found < 0 Then
            _found = me._grid.Row
         End If
         NativeRowAtY = _found
      End Function
      Function ToNativeCol(pDataCol As Integer) As Integer
         ToNativeCol = pDataCol
      End Function
      Function ToDataCol(pNativeCol As Integer) As Integer
         If pNativeCol >=0 AndAlso pNativeCol < me._grid.ColCount Then
            ToDataCol = pNativeCol
         Else
            ToDataCol = -1
         End If
      End Function
      Function ToNativeRow(pDataRow As Integer) As Integer
         ToNativeRow = pDataRow + me._grid.FixedRows
      End Function
      Function ToDataRow(pNativeRow As Integer) As Integer
         ToDataRow = pNativeRow - me._grid.FixedRows
      End Function
      Function IsHeaderRow(pNativeRow As Integer) As Boolean
         IsHeaderRow = pNativeRow < me._grid.FixedRows
      End Function
      Sub SetDataRowCount(pCount As Integer)
         Dim _target As Integer = pCount + me._grid.FixedRows
         If _target <= me._grid.FixedRows Then
            _target = me._grid.FixedRows + 1
         End If
         me._grid.RowCount = _target
      End Sub
      Function DataRowCount() As Integer
         DataRowCount = me._grid.RowCount - me._grid.FixedRows
      End Function
      Function FixedRows() As Integer
         FixedRows = me._grid.FixedRows
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            If Assigned(me._grid) Then
               .Prop("ColCount", me._grid.ColCount)
               .Prop("AllColCount", me._grid.AllColCount)
               .Prop("RowCount", me._grid.RowCount)
               .Prop("FixedRows", me._grid.FixedRows)
            End If
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me._grid) Then
            me._grid.Free()
            me._grid = NULL
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
