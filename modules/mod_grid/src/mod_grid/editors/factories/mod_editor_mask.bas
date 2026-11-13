Imports Forms
Imports mod_grid_editor_contract
Imports mod_tmasktextbox

Namespace mod_grid_editor_mask
   ' data7:disable unknown-member
   Class TMaskEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TMaskEditorFactory)
         MyBase.New(pValue)
      End Sub
      Sub Assign(pValue As TMaskEditorFactory)
         If Assigned(pValue) Then
            me.Assign(TGridEditorFactory(pValue))
         End If
      End Sub
      Overrides Function Clone() As TMaskEditorFactory
         Clone = New TMaskEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Mask()
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Dim _ctrl As New TMaskTextBox(pParent)
         _ctrl.Visible = False
         me.Configure(_ctrl, pColDef)
         Build = _ctrl
      End Function
      Overrides Sub Configure(pControl As TWinControl, pColDef As mod_grid_col.TGridCol)
         If Assigned(pControl) AndAlso pColDef.Options.Format.Mask <> "" Then
            TMaskTextBox(pControl).Mascara = pColDef.Options.Format.Mask
         End If
      End Sub
      Overrides Function GetValue(pControl As TWinControl) As String
         GetValue = TMaskTextBox(pControl).AsString
      End Function
      Overrides Sub ApplyValue(pControl As TWinControl, pValue As String)
         TMaskTextBox(pControl).AsString = pValue
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
