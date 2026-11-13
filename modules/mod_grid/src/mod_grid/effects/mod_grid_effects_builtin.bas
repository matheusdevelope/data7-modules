Imports Forms
Imports mod_tobject
Imports mod_grid_data
Imports mod_grid_row
Imports mod_grid_col
Imports mod_grid_editor_contract
Namespace mod_grid_effects_builtin
   ' data7:disable unknown-member
   Class TGridEffects
      Inherits TTObject
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridEffects)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridEffects)
      End Sub
      Overrides Function Clone() As TGridEffects
         Clone = New TGridEffects(me)
      End Function
      Shared Sub SearchDescription(pData As TObject, pRow As TGridRow, pCol As TGridCol, ByRef pValue As Variant, ByRef pValid As Boolean, pNative As Grid)
         If pCol.Options.Search.DescriptionColumnId <> "" AndAlso Assigned(pNative) Then
            Dim _edit As GridEditorLink = pNative.GetEditorLink()
            If Assigned(_edit) AndAlso Assigned(_edit.Control) AndAlso (TypeOf _edit.Control Is SearchTextBox) Then
               TGridEffects.ApplySearchDescription(pData, pRow, pCol, SearchTextBox(_edit.Control), pValue, pValid)
            End If
         End If
      End Sub
      Shared Sub ApplySearchDescriptionFromControl(pData As TObject, pRow As TGridRow, pCol As TGridCol, pControl As TWinControl, ByRef pValue As Variant, ByRef pValid As Boolean)
         If Assigned(pControl) AndAlso (TypeOf pControl Is SearchTextBox) Then
            Dim _search As SearchTextBox = SearchTextBox(pControl)
            If pCol.Options.Search.CodPesquisa > 0 Then
               _search.CodPesquisa = pCol.Options.Search.CodPesquisa
            End If
            Dim _text As String = ""
            If Not IsEmpty(pValue) Then
               _text = CStr(pValue)
            End If
            _search.Text = _text
            TGridEffects.ApplySearchDescription(pData, pRow, pCol, _search, pValue, pValid)
         End If
      End Sub
      Shared Sub ApplySearchDescription(pData As TObject, pRow As TGridRow, pCol As TGridCol, pSearch As SearchTextBox, ByRef pValue As Variant, ByRef pValid As Boolean)
         If Assigned(pSearch) AndAlso Assigned(pRow) AndAlso pCol.Options.Search.DescriptionColumnId <> "" Then
            Dim _gridData As TGridData = TGridData(pData)
            pSearch.Valida()
            pValid = pSearch.IsValid()
            Dim _rowIndex As Integer = pRow.Index
            Dim _empty As Variant
            _empty = ""
            If Not pValid Then
               pValid = pSearch.IsEmpty()
               pValue = _empty
               _gridData.SetCell(_rowIndex, pCol.ID, _empty)
               _gridData.SetCell(_rowIndex, pCol.Options.Search.DescriptionColumnId, _empty)
            ElseIf pSearch.IsEmpty() Then
               pValid = True
               pValue = _empty
               _gridData.SetCell(_rowIndex, pCol.ID, _empty)
               _gridData.SetCell(_rowIndex, pCol.Options.Search.DescriptionColumnId, _empty)
            Else
               pValue = pSearch.AsString
               _gridData.SetCell(_rowIndex, pCol.ID, pValue)
               Dim _desc As Variant
               _desc = pSearch.GetValorDescricao()
               _gridData.SetCell(_rowIndex, pCol.Options.Search.DescriptionColumnId, _desc)
            End If
         End If
      End Sub
      Shared Sub CascadeClear(pData As TObject, pRow As TGridRow, pCol As TGridCol, ByRef pValue As Variant, ByRef pValid As Boolean, pNative As Grid)
         If pCol.Options.Effects.CascadeClearColumnId <> "" Then
            Dim _text As String = ""
            If Not IsEmpty(pValue) Then
               _text = Trim(CStr(pValue))
            End If
            If _text = "" Then
               Dim _empty As Variant
               _empty = ""
               TGridData(pData).SetCell(pRow.Index, pCol.Options.Effects.CascadeClearColumnId, _empty)
            End If
         End If
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
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
End Namespace
