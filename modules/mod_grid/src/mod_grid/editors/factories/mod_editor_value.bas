Imports Forms
Imports mod_grid_editor_contract
Namespace mod_grid_editor_value
   Class TValueEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TValueEditorFactory)
         MyBase.New(pValue)
      End Sub
      Sub Assign(pValue As TValueEditorFactory)
         If Assigned(pValue) Then
            me.Assign(TGridEditorFactory(pValue))
         End If
      End Sub
      Overrides Function Clone() As TValueEditorFactory
         Clone = New TValueEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Value()
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Dim _ctrl As New ValueTextBox(pParent)
         _ctrl.Visible = False
         Build = _ctrl
      End Function
      Overrides Sub Configure(pControl As TWinControl, pColDef As mod_grid_col.TGridCol)
         If Assigned(pControl) AndAlso pColDef.Options.Format.Mask <> "" Then
            Dim _ctrl As ValueTextBox = ValueTextBox(pControl)
            _ctrl.DisplayFormat = pColDef.Options.Format.Mask
         End If
      End Sub
      Overrides Function FormatValue(pColDef As mod_grid_col.TGridCol, pValue As Variant) As String
         If IsEmpty(pValue) Then
            FormatValue = ""
         ElseIf Assigned(pColDef) AndAlso pColDef.Options.Format.Mask <> "" Then
            Dim _text As String = me.AsText(pValue)
            If _text = "" Then
               FormatValue = ""
            Else
               Dim _double As Double = pValue
               FormatValue = _double.ToString(pColDef.Options.Format.Mask)
            End If
         Else
            FormatValue = me.AsText(pValue)
         End If
      End Function
      Overrides Function GetValue(pControl As TWinControl) As String
         GetValue = CStr(ValueTextBox(pControl).AsFloat)
      End Function
      Overrides Sub ApplyValue(pControl As TWinControl, pValue As String)
         ValueTextBox(pControl).EditValue = pValue
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