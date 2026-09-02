Imports Forms
Imports mod_grid_editor_contract
Namespace mod_grid_editor_text
   Class TTextEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TTextEditorFactory)
         MyBase.New(pValue)
      End Sub
      Sub Assign(pValue As TTextEditorFactory)
         If Assigned(pValue) Then
            me.Assign(TGridEditorFactory(pValue))
         End If
      End Sub
      Overrides Function Clone() As TTextEditorFactory
         Clone = New TTextEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Text()
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Dim _ctrl As New TextBox(pParent)
         _ctrl.Visible = False
         Build = _ctrl
      End Function
      Overrides Function GetValue(pControl As TWinControl) As String
         GetValue = TextBox(pControl).Text
      End Function
      Overrides Sub ApplyValue(pControl As TWinControl, pValue As String)
         TextBox(pControl).Text = pValue
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