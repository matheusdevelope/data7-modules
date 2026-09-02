' data7:disable unknown-member
Imports Forms
Imports mod_tobject
Imports mod_grid_editor_contract
Namespace mod_grid_drawer_checkbox
   Class TCheckboxDrawer
      Inherits TGridCellDrawer
      Margin As Integer = 2
      BoxSize As Integer = -1
      BorderWidth As Integer = 1
      CheckWidth As Integer = 2
      CellColor As Integer = -1
      BoxColor As Integer = RGB(255, 255, 255)
      BorderColor As Integer = RGB(192, 192, 192)
      CheckColor As Integer = RGB(0, 0, 0)
      HasBorder As Boolean = True
      OffsetX As Integer = 2
      OffsetY As Integer = 2
      Private _resolvedBackColor As Integer
      Private _resolvedIsFixed As Boolean
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TCheckboxDrawer)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TCheckboxDrawer)
         If Assigned(pValue) Then
            me.Margin = pValue.Margin
            me.BoxSize = pValue.BoxSize
            me.BorderWidth = pValue.BorderWidth
            me.CheckWidth = pValue.CheckWidth
            me.CellColor = pValue.CellColor
            me.BoxColor = pValue.BoxColor
            me.BorderColor = pValue.BorderColor
            me.CheckColor = pValue.CheckColor
            me.HasBorder = pValue.HasBorder
            me.OffsetX = pValue.OffsetX
            me.OffsetY = pValue.OffsetY
         End If
      End Sub
      Overrides Function Clone() As TCheckboxDrawer
         Clone = New TCheckboxDrawer(me)
      End Function
      Overrides Sub Draw(pGrid As Grid, pRow As Integer, pCol As Integer, pColDef As mod_grid_col.TGridCol, pRect As TRect, pValue As String)
         me.Layout(pRect)
         me._resolvedIsFixed = me._isFixedCell(pGrid, pCol, pRow)
         me._resolvedBackColor = me.ResolveBackColor(pGrid, pCol, pRow)
         Dim _checked As Boolean = mod_grid_column_checkbox.TGridCheckboxSupport.IsChecked(pColDef, pValue)
         me.Paint(pGrid, pRect, _checked)
      End Sub
      Function ResolveBackColor(pGrid As Grid, pCol As Integer, pRow As Integer) As Integer
         If me._resolvedIsFixed Then
            ResolveBackColor = pGrid.FixedColor
         ElseIf me._isSelectedCell(pGrid, pCol, pRow) Then
            ResolveBackColor = pGrid.SelectionColor
         ElseIf me.PaintBackColor <> -1 Then
            ResolveBackColor = me.PaintBackColor
         ElseIf me.CellColor <> -1 Then
            ResolveBackColor = me.CellColor
         Else
            ResolveBackColor = pGrid.Color
         End If
      End Function
      Private Function _isFixedCell(pGrid As Grid, pCol As Integer, pRow As Integer) As Boolean
         If pCol < pGrid.FixedCols Then
            _isFixedCell = True
         ElseIf pRow < pGrid.FixedRows Then
            _isFixedCell = True
         ElseIf pGrid.FixedRightCols > 0 AndAlso pCol >= pGrid.ColCount - pGrid.FixedRightCols Then
            _isFixedCell = True
         Else
            _isFixedCell = False
         End If
      End Function
      Private Function _isSelectedCell(pGrid As Grid, pCol As Integer, pRow As Integer) As Boolean
         If Not pGrid.ShowSelection Then
            _isSelectedCell = False
         ElseIf pGrid.IsSelectionHidden() Then
            _isSelectedCell = False
         ElseIf pGrid.GridOptions.RowSelect Then
            _isSelectedCell = pGrid.Row = pRow
         ElseIf pGrid.Row <> pRow Then
            _isSelectedCell = False
         Else
            _isSelectedCell = pGrid.Col = pCol
         End If
      End Function
      Sub Layout(pRect As TRect)
         Dim _size As Integer = me.BoxSize
         Dim _cellH As Integer = pRect.Bottom - pRect.Top
         Dim _cellW As Integer = pRect.Right - pRect.Left
         If _size < 0 Then
            _size = _cellH - (me.Margin * 2)
         End If
         If _size > _cellH Then
            _size = _cellH - (me.Margin * 2)
         End If
         me.BoxSize = _size
         me.OffsetY = CInt((_cellH - me.BoxSize) / 2)
         me.OffsetX = CInt((_cellW - me.BoxSize) / 2)
      End Sub
      Overridable Sub Paint(pGrid As Grid, pRect As TRect, pChecked As Boolean)
      End Sub
      Sub FillCell(pGrid As Grid, pRect As TRect)
         Dim bg As Integer = me._resolvedBackColor
         pGrid.Canvas.Pen.Width = 1
         pGrid.Canvas.Pen.Color = bg
         pGrid.Canvas.Brush.Color = bg
         pGrid.Canvas.Rectangle(pRect.Left, pRect.Top, pRect.Right, pRect.Bottom)
         If me._resolvedIsFixed Then
            Dim lineW As Integer = pGrid.GridFixedLineWidth
            If lineW < 1 Then
               lineW = 1
            End If
            pGrid.Canvas.Pen.Width = lineW
            pGrid.Canvas.Pen.Color = pGrid.GridFixedLineColor
            pGrid.Canvas.MoveTo(pRect.Left, pRect.Top)
            pGrid.Canvas.LineTo(pRect.Right, pRect.Top)
            pGrid.Canvas.LineTo(pRect.Right, pRect.Bottom + 1)
            pGrid.Canvas.LineTo(pRect.Left, pRect.Bottom + 1)
            pGrid.Canvas.LineTo(pRect.Left, pRect.Top)
         End If
      End Sub
      Sub DrawBox(pGrid As Grid, pRect As TRect)
         pGrid.Canvas.Pen.Width = me.BorderWidth
         pGrid.Canvas.Pen.Color = me.BorderColor
         pGrid.Canvas.Brush.Color = me.BoxColor
         pGrid.Canvas.Rectangle(pRect.Left + me.OffsetX, pRect.Top + me.OffsetY, pRect.Right - me.OffsetX, pRect.Bottom - me.OffsetY)
      End Sub
      Sub DrawShadow(pGrid As Grid, pRect As TRect)
         Dim _inset As Integer = 1
         pGrid.Canvas.Pen.Color = RGB(0, 0, 0)
         pGrid.Canvas.MoveTo(pRect.Left + me.OffsetX + _inset, pRect.Bottom - me.OffsetY - _inset)
         pGrid.Canvas.LineTo(pRect.Left + me.OffsetX + _inset, pRect.Top + me.OffsetY + _inset)
         pGrid.Canvas.MoveTo(pRect.Left + me.OffsetX + _inset, pRect.Top + me.OffsetY + _inset)
         pGrid.Canvas.LineTo(pRect.Right - me.OffsetX - _inset, pRect.Top + me.OffsetY + _inset)
      End Sub
      Sub DrawCross(pGrid As Grid, pRect As TRect, pPadding As Integer)
         pGrid.Canvas.Pen.Width = me.CheckWidth
         pGrid.Canvas.Pen.Color = me.CheckColor
         pGrid.Canvas.MoveTo(pRect.Left + me.OffsetX + pPadding - 1, pRect.Bottom - me.OffsetY - pPadding)
         pGrid.Canvas.LineTo(pRect.Right - me.OffsetX - pPadding, pRect.Top + me.OffsetY + pPadding - 1)
         pGrid.Canvas.MoveTo(pRect.Left + me.OffsetX + pPadding - 1, pRect.Top + me.OffsetY + pPadding - 1)
         pGrid.Canvas.LineTo(pRect.Right - me.OffsetX - pPadding, pRect.Bottom - me.OffsetY - pPadding)
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Margin", me.Margin)
            .Prop("BoxSize", me.BoxSize)
            .Prop("BorderWidth", me.BorderWidth)
            .Prop("CheckWidth", me.CheckWidth)
            .Prop("CellColor", me.CellColor)
            .Prop("BoxColor", me.BoxColor)
            .Prop("BorderColor", me.BorderColor)
            .Prop("CheckColor", me.CheckColor)
            .Prop("HasBorder", me.HasBorder)
            .Prop("OffsetX", me.OffsetX)
            .Prop("OffsetY", me.OffsetY)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TDefaultCheckboxDrawer
      Inherits TCheckboxDrawer
      Sub New()
         MyBase.New()
         me.BoxColor = RGB(131, 132, 134)
         me.BorderColor = RGB(192, 192, 192)
         me.CheckColor = RGB(0, 255, 0)
         me.BoxSize = 14
      End Sub
      Sub New(pValue As TDefaultCheckboxDrawer)
         MyBase.New(pValue)
      End Sub
      Overrides Function Clone() As TDefaultCheckboxDrawer
         Clone = New TDefaultCheckboxDrawer(me)
      End Function
      Overrides Sub Paint(pGrid As Grid, pRect As TRect, pChecked As Boolean)
         pGrid.Canvas.Pen.Width = me.BorderWidth
         me.FillCell(pGrid, pRect)
         If me.HasBorder Then
            me.DrawBox(pGrid, pRect)
         End If
         me.DrawShadow(pGrid, pRect)
         If pChecked Then
            me.DrawCross(pGrid, pRect, 4)
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
