Imports Forms
Imports mod_grid_editor_contract
Namespace mod_grid_editor_number
   Class TNumberEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TNumberEditorFactory)
         MyBase.New(pValue)
      End Sub
      Sub Assign(pValue As TNumberEditorFactory)
         If Assigned(pValue) Then
            me.Assign(TGridEditorFactory(pValue))
         End If
      End Sub
      Overrides Function Clone() As TNumberEditorFactory
         Clone = New TNumberEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Number()
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Dim _ctrl As New ValueTextBox(pParent)
         _ctrl.Visible = False
         Build = _ctrl
      End Function
      Overrides Sub Configure(pControl As TWinControl, pColDef As mod_grid_col.TGridCol)
         If Assigned(pControl) Then
            Dim _ctrl As ValueTextBox = ValueTextBox(pControl)
            _ctrl.DecimalPlaces =0
            _ctrl.DisplayFormat = "0"
         End If
      End Sub      
      Overrides Function GetValue(pControl As TWinControl) As String
         GetValue = Cstr(ValueTextBox(pControl).AsInteger)
      End Function
      Overrides Sub ApplyValue(pControl As TWinControl, pValue As String)
         ValueTextBox(pControl).AsInteger = CInt(pValue)
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Kind", me.Kind())
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