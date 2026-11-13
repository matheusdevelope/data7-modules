Imports Forms
Imports mod_tobject
Imports mod_grid_col
Imports mod_grid_row
Imports mod_grid_column_kind
Namespace mod_grid_column_checkbox
   Class TGridCheckboxSupport
      Inherits TTObject
      Sub New()
         MyBase.New()
      End Sub
      Shared Function ValueAsString(pValue As Variant) As String
         If IsEmpty(pValue) Then
            ValueAsString = ""
         Else
            ValueAsString = CStr(pValue)
         End If
      End Function
      Shared Function IsChecked(pCol As TGridCol, pValue As Variant) As Boolean
         IsChecked = UCase(Trim(TGridCheckboxSupport.ValueAsString(pValue))) = UCase(Trim(pCol.Options.Checkbox.CheckedValue))
      End Function
      Shared Function ToggleValue(pCol As TGridCol, pCurrentValue As Variant) As String
         If TGridCheckboxSupport.IsChecked(pCol, pCurrentValue) Then
            ToggleValue = pCol.Options.Checkbox.UncheckedValue
         Else
            ToggleValue = pCol.Options.Checkbox.CheckedValue
         End If
      End Function
      Shared Function AcceptsActivationKey(pCol As TGridCol, pKey As Char) As Boolean
         Dim _accepted As Boolean = False
         If pCol.Options.Checkbox.ActivationKeys <> "" Then
            Dim i As Integer
            For i = 1 To Len(pCol.Options.Checkbox.ActivationKeys)
               If Not _accepted Then
                  If pCol.Options.Checkbox.ActivationKeys[i] = pKey Then
                     _accepted = True
                  End If
               End If
            Next
         End If
         AcceptsActivationKey = _accepted
      End Function
      Shared Function CanToggle(pCol As TGridCol, pRow As TGridRow) As Boolean
         If Assigned(pRow) AndAlso Not pRow.Editable Then
            CanToggle = False
         ElseIf pCol.Options.Interaction.OnlyRead Then
            CanToggle = False
         ElseIf pCol.Options.Checkbox.CanToggle <> Null Then
            CanToggle = pCol.Options.Checkbox.CanToggle(pRow, pCol)
         Else
            CanToggle = True
         End If
      End Function
      Shared Function ReadValue(pCtx As mod_grid_context.TGridContext, pDataIndex As Integer, pCol As TGridCol) As Variant
         Dim _value As Variant
         If Assigned(pCol) AndAlso Assigned(pCtx) Then
            Dim _row As TGridRow = pCtx.Data.RowAt(pDataIndex)
            If Assigned(_row) Then
               If pCol.Options.System.IsSelection Then
                  If _row.Selected Then
                     _value = pCol.Options.Checkbox.CheckedValue
                  Else
                     _value = pCol.Options.Checkbox.UncheckedValue
                  End If
               Else
                  _value = pCtx.Data.GetCell(pDataIndex, pCol.Index)
               End If
            End If
         End If
         ReadValue = _value
      End Function
      Shared Function TryApply(pCtx As mod_grid_context.TGridContext, pDataIndex As Integer, pCol As TGridCol, pNewValue As String) As Boolean
         Dim _ok As Boolean = False
         If Assigned(pCtx) AndAlso Assigned(pCol) AndAlso pDataIndex >= 0 Then
            If pCol.Kind = TGridColumnKind.Checkbox() Then
               Dim _row As TGridRow = pCtx.Data.RowAt(pDataIndex)
               If Assigned(_row) AndAlso TGridCheckboxSupport.CanToggle(pCol, _row) Then
                  Dim _current As Variant = TGridCheckboxSupport.ReadValue(pCtx, pDataIndex, pCol)
                  Dim _message As String = ""
                  Dim _valid As Boolean = True
                  If pCol.Options.Checkbox.ToggleValidate <> Null Then
                     _valid = pCol.Options.Checkbox.ToggleValidate(_row, pCol, TGridCheckboxSupport.ValueAsString(_current), pNewValue, _message)
                  End If
                  If _valid Then
                     _valid = pCol.Validate(pDataIndex, pCol.Index, pNewValue, _message)
                  End If
                  If _valid AndAlso Assigned(pCtx.Config) AndAlso Assigned(pCtx.Config.GlobalValidators) Then
                     _valid = pCtx.Config.GlobalValidators.Validate(pDataIndex, pCol.Index, pNewValue, _message)
                  End If
                  If _valid Then
                     Dim _value As Variant = pNewValue
                     If pCol.Options.System.IsSelection Then
                        _row.Selected = TGridCheckboxSupport.IsChecked(pCol, pNewValue)
                     Else
                        pCtx.Data.SetCell(pDataIndex, pCol.Index, _value)
                        _row.Dirty = True
                     End If
                     pCol.ApplySideEffects(pCtx.Data, _row, _value, _valid, pCtx.Adapter.Native)
                     If Assigned(pCtx.Config) AndAlso Assigned(pCtx.Config.GlobalSideEffects) Then
                        pCtx.Config.GlobalSideEffects.Apply(pCtx.Data, _row, pCol, _value, _valid, pCtx.Adapter.Native)
                     End If
                     pCtx.Presenter.PokeDataCell(pCol.Index, pDataIndex)
                     _ok = True
                  End If
               End If
            End If
         End If
         TryApply = _ok
      End Function
      Shared Function TryToggle(pCtx As mod_grid_context.TGridContext, pNativeRow As Integer, pNativeCol As Integer) As Boolean
         Dim _ok As Boolean = False
         Dim _dataIndex As Integer = pCtx.Presenter.ToDataIndex(pNativeRow)
         If _dataIndex >= 0 Then
            Dim _dataCol As Integer = pCtx.Adapter.ToDataCol(pNativeCol)
            If _dataCol >= 0 Then
               Dim _col As TGridCol = pCtx.Data.ColAt(_dataCol)
               If Assigned(_col) Then
                  Dim _current As Variant = TGridCheckboxSupport.ReadValue(pCtx, _dataIndex, _col)
                  _ok = TGridCheckboxSupport.TryApply(pCtx, _dataIndex, _col, TGridCheckboxSupport.ToggleValue(_col, _current))
               End If
            End If
         End If
         TryToggle = _ok
      End Function
      Shared Sub ApplyScope(pCtx As mod_grid_context.TGridContext, pCol As TGridCol, pDataIndex As Integer, pOp As String, pScope As String)
         If Assigned(pCtx) AndAlso Assigned(pCol) AndAlso Assigned(pCtx.Data) Then
            Dim i As Integer
            For i = 0 To pCtx.Data.RowCount - 1
               Dim _match As Boolean = False
               If pScope = "all" Then
                  _match = True
               ElseIf pScope = "current" Then
                  _match = (i = pDataIndex)
               Else
                  Dim _row As TGridRow = pCtx.Data.RowAt(i)
                  If Assigned(_row) Then
                     If pScope = "selected" Then
                        _match = _row.Selected
                     ElseIf pScope = "unselected" Then
                        _match = Not _row.Selected
                     End If
                  End If
               End If
               If _match Then
                  Dim _newValue As String
                  Dim _hasValue As Boolean = False
                  If pOp = "check" Then
                     _newValue = pCol.Options.Checkbox.CheckedValue
                     _hasValue = True
                  ElseIf pOp = "uncheck" Then
                     _newValue = pCol.Options.Checkbox.UncheckedValue
                     _hasValue = True
                  ElseIf pOp = "invert" Then
                     Dim _current As Variant = TGridCheckboxSupport.ReadValue(pCtx, i, pCol)
                     _newValue = TGridCheckboxSupport.ToggleValue(pCol, _current)
                     _hasValue = True
                  End If
                  If _hasValue Then
                     TGridCheckboxSupport.TryApply(pCtx, i, pCol, _newValue)
                  End If
               End If
            Next
         End If
      End Sub
      Sub New(pValue As TGridCheckboxSupport)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridCheckboxSupport)
      End Sub
      Overrides Function Clone() As TGridCheckboxSupport
         Clone = New TGridCheckboxSupport(me)
      End Function
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
