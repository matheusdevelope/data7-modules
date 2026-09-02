Imports Forms
Imports mod_grid_editor_contract
Imports mod_grid_drawer_checkbox
Namespace mod_grid_editor_checkbox
   Class TCheckboxEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
         me.Drawer = New TDefaultCheckboxDrawer()
      End Sub
      Sub New(pValue As TCheckboxEditorFactory)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TCheckboxEditorFactory)
         If Assigned(pValue) Then
            If Assigned(pValue.Drawer) Then
               me.Drawer = pValue.Drawer.Clone()
            Else
               me.Drawer = NULL
            End If
         End If
      End Sub
      Overrides Function Clone() As TCheckboxEditorFactory
         Clone = New TCheckboxEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Checkbox()
      End Function
      Overrides Function UsesInplaceEditor() As Boolean
         UsesInplaceEditor = False
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Build = NULL
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Kind", me.Kind())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         MyBase.Dispose()
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
