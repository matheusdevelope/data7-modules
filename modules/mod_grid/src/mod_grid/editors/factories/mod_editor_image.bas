Imports Forms
Imports mod_grid_editor_contract
Namespace mod_grid_editor_image
   Class TImageEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TImageEditorFactory)
         MyBase.New(pValue)
      End Sub
      Sub Assign(pValue As TImageEditorFactory)
         If Assigned(pValue) Then
            me.Assign(TGridEditorFactory(pValue))
         End If
      End Sub
      Overrides Function Clone() As TImageEditorFactory
         Clone = New TImageEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Image()
      End Function
      Overrides Function UsesInplaceEditor() As Boolean
         UsesInplaceEditor = False
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Build = NULL
      End Function
      Overrides Function FormatValue(pColDef As mod_grid_col.TGridCol, pValue As Variant) As String
         Dim _text As String = me.AsText(pValue)
         If Assigned(pColDef) Then
            FormatValue = pColDef.Options.Image.AsHtml(_text)
         Else
            FormatValue = _text
         End If
      End Function
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
