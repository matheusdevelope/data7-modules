Imports Forms
Imports mod_grid_editor_contract
Namespace mod_grid_editor_combo
   ' data7:disable unknown-member
   Class TComboEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TComboEditorFactory)
         MyBase.New(pValue)
      End Sub
      Sub Assign(pValue As TComboEditorFactory)
         If Assigned(pValue) Then
            me.Assign(TGridEditorFactory(pValue))
         End If
      End Sub
      Overrides Function Clone() As TComboEditorFactory
         Clone = New TComboEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Combo()
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Dim _ctrl As New HComboBox(pParent)
         _ctrl.Visible = False
         me.Configure(_ctrl, pColDef)
         Build = _ctrl
      End Function
      Overrides Sub Configure(pControl As TWinControl, pColDef As mod_grid_col.TGridCol)
         If Assigned(pControl) Then
            Dim _ctrl As HComboBox = HComboBox(pControl)
            _ctrl.ListaOpcoes = pColDef.Options.Combo.AsListaOpcoes()
         End If
      End Sub
      Overrides Function GetValue(pControl As TWinControl) As String
         GetValue = HComboBox(pControl).ValueSelect
      End Function
      Overrides Sub ApplyValue(pControl As TWinControl, pValue As String)
         HComboBox(pControl).ValueSelect = pValue
      End Sub
      Overrides Function PoolKey(pColDef As mod_grid_col.TGridCol) As String
         PoolKey = me.Kind().AsString + ":" + pColDef.ID
      End Function
      Overrides Function FormatValue(pColDef As mod_grid_col.TGridCol, pValue As Variant) As String
         Dim _text As String = me.AsText(pValue)
         If Assigned(pColDef) AndAlso pColDef.Options.Combo.ShowDescription Then
            Dim _desc As String = pColDef.Options.Combo.LookupValue(_text)
            If _desc <> "" Then
               _text = _desc
            End If
         End If
         FormatValue = _text
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
