Imports mod_tobject
Imports mod_grid_column_kind
Imports mod_grid_editor_contract
Imports mod_grid_editor_text
Imports mod_grid_editor_date
Imports mod_grid_editor_value
Imports mod_grid_editor_number
Imports mod_grid_editor_mask
Imports mod_grid_editor_search
Imports mod_grid_editor_checkbox
Imports mod_grid_editor_combo
Imports mod_grid_editor_image
Imports mod_grid_editor_readonly
Namespace mod_grid_editor_registry
   Class TGridEditorRegistry
      Inherits TTObject
      Private _factories[] As TGridEditorFactory
      Sub New()
         MyBase.New()
         me._factories = []
         me.RegisterDefaults()
      End Sub
      Sub New(pValue As TGridEditorRegistry)
         MyBase.New()
         me._factories = []
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridEditorRegistry)
         If Assigned(pValue) Then
            If Assigned(me._factories) Then
               me._factories.Free()
            End If
            If Assigned(pValue._factories) Then
               me._factories = pValue._factories.Clone()
            Else
               me._factories = []
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridEditorRegistry
         Clone = New TGridEditorRegistry(me)
      End Function
      Sub RegisterDefaults()
         me.Registerr(TGridColumnKind.Text(), New TTextEditorFactory())
         me.Registerr(TGridColumnKind.Date(), New TDateEditorFactory())
         me.Registerr(TGridColumnKind.Value(), New TValueEditorFactory())
         me.Registerr(TGridColumnKind.Number(), New TNumberEditorFactory())
         me.Registerr(TGridColumnKind.Mask(), New TMaskEditorFactory())
         me.Registerr(TGridColumnKind.Search(), New TSearchEditorFactory())
         me.Registerr(TGridColumnKind.Checkbox(), New TCheckboxEditorFactory())
         me.Registerr(TGridColumnKind.Combo(), New TComboEditorFactory())
         me.Registerr(TGridColumnKind.Image(), New TImageEditorFactory())
         me.Registerr(TGridColumnKind.OnlyRead(), New TReadOnlyEditorFactory())
      End Sub
      Sub Registerr(pKind As TGridColumnKind, pFactory As TGridEditorFactory)
         Dim idx As Integer = me._factories.IndexOf(pKind.AsString)
         If idx >= 0 Then
            me._factories[idx] = pFactory
         Else
            me._factories.Push(pFactory)
         End If
      End Sub
      Function Resolve(pKind As TGridColumnKind) As TGridEditorFactory
         Dim idx As Integer = me._factories.IndexOf(pKind.AsString)
         If idx >= 0 Then
            Resolve = me._factories.GetItem(idx)
         Else
            Resolve = Null
         End If
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Factories", me._factories.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me._factories) Then
            me._factories.Free()
            me._factories = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
