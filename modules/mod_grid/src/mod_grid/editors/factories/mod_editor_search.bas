Imports Forms
Imports mod_grid_editor_contract
Namespace mod_grid_editor_search
   ' data7:disable unknown-member
   Class TSearchEditorFactory
      Inherits TGridEditorFactory
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TSearchEditorFactory)
         MyBase.New(pValue)
      End Sub
      Sub Assign(pValue As TSearchEditorFactory)
         If Assigned(pValue) Then
            me.Assign(TGridEditorFactory(pValue))
         End If
      End Sub
      Overrides Function Clone() As TSearchEditorFactory
         Clone = New TSearchEditorFactory(me)
      End Function
      Overrides Function Kind() As mod_grid_column_kind.TGridColumnKind
         Kind = mod_grid_column_kind.TGridColumnKind.Search()
      End Function
      Overrides Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Dim _ctrl As New SearchTextBox(pParent)
         _ctrl.Visible = False
         me.Configure(_ctrl, pColDef)
         Build = _ctrl
      End Function
      Overrides Sub Configure(pControl As TWinControl, pColDef As mod_grid_col.TGridCol)
         If Assigned(pControl) Then
            Dim _ctrl As SearchTextBox = SearchTextBox(pControl)
            If pColDef.Options.Search.CodPesquisa > 0 Then
               _ctrl.CodPesquisa = pColDef.Options.Search.CodPesquisa
            End If
         End If
      End Sub
      Overrides Function Validate(pControl As TWinControl) As Boolean
         Dim _search As SearchTextBox = SearchTextBox(pControl)
         _search.Valida()
         Validate = _search.IsValid()
      End Function
      Overrides Function GetValue(pControl As TWinControl) As String
         GetValue = SearchTextBox(pControl).AsString
      End Function
      Overrides Sub ApplyValue(pControl As TWinControl, pValue As String)
         SearchTextBox(pControl).Text = pValue
      End Sub
      Overrides Function PoolKey(pColDef As mod_grid_col.TGridCol) As String
         PoolKey = me.Kind().AsString + ":" + CStr(pColDef.Options.Search.CodPesquisa)
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
