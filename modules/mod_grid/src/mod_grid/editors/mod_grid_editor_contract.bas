Imports Forms
Imports mod_tobject
Namespace mod_grid_editor_contract
   Class TGridCellDrawer
      Inherits TTObject
      PaintBackColor As Integer = -1
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridCellDrawer)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridCellDrawer)
      End Sub
      Overrides Function Clone() As TGridCellDrawer
         Clone = New TGridCellDrawer(me)
      End Function
      Overridable Sub Draw(pGrid As Grid, pRow As Integer, pCol As Integer, pColDef As mod_grid_col.TGridCol, pRect As TRect, pValue As String)
      End Sub
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
   Class TGridEditorHandle
      Inherits TTObject
      Control As TWinControl
      PoolKey As String
      Sub New(pControl As TWinControl, pPoolKey As String)
         MyBase.New()
         me.Control = pControl
         me.PoolKey = pPoolKey
      End Sub
      Sub New(pValue As TGridEditorHandle)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridEditorHandle)
         If Assigned(pValue) Then
            me.Control = pValue.Control
            me.PoolKey = pValue.PoolKey
         End If
      End Sub
      Overrides Function Clone() As TGridEditorHandle
         Clone = New TGridEditorHandle(me)
      End Function
      Overrides Function GetID() As String
         GetID = me.PoolKey
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("PoolKey", me.PoolKey)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me.Control = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
   Class TGridEditorFactory
      Inherits TTObject
      Drawer As TGridCellDrawer
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridEditorFactory)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridEditorFactory)
         If Assigned(pValue) Then
            me.Drawer = pValue.Drawer
         End If
      End Sub
      Overrides Function Clone() As TGridEditorFactory
         Clone = New TGridEditorFactory(me)
      End Function
      Overridable Function Kind() As mod_grid_column_kind.TGridColumnKind
         Throw New Exception("TGridEditorFactory.Kind must be implemented.")
      End Function
      Overridable Function UsesInplaceEditor() As Boolean
         UsesInplaceEditor = True
      End Function
      Overridable Function Build(pParent As TWinControl, pColDef As mod_grid_col.TGridCol) As TWinControl
         Throw New Exception("TGridEditorFactory.Build must be implemented.")
      End Function
      Overridable Sub Configure(pControl As TWinControl, pColDef As mod_grid_col.TGridCol)
      End Sub
      Overridable Function Validate(pControl As TWinControl) As Boolean
         Validate = True
      End Function
      Overridable Function GetValue(pControl As TWinControl) As String
         GetValue = ""
      End Function
      Overridable Sub ApplyValue(pControl As TWinControl, pValue As String)
      End Sub
      Overridable Function PoolKey(pColDef As mod_grid_col.TGridCol) As String
         PoolKey = me.Kind().AsString
      End Function
      Overridable Function GetDrawer() As TGridCellDrawer
         GetDrawer = me.Drawer
      End Function
      Sub SetDrawer(pDrawer As TGridCellDrawer)
         me.Drawer = pDrawer
      End Sub
      Overridable Function AsText(pValue As Variant) As String
         If IsEmpty(pValue) Then
            AsText = ""
         Else
            AsText = CStr(pValue)
         End If
      End Function
      Overridable Function FormatValue(pColDef As mod_grid_col.TGridCol, pValue As Variant) As String
         FormatValue = me.AsText(pValue)
      End Function
      Overridable Function FormatEditValue(pColDef As mod_grid_col.TGridCol, pValue As Variant) As String
         FormatEditValue = me.AsText(pValue)
      End Function
      Overridable Sub Draw(pGrid As Grid, pRow As Integer, pCol As Integer, pColDef As mod_grid_col.TGridCol, pRect As TRect, pValue As String)
         Dim _drawer As TGridCellDrawer = me.GetDrawer()
         If Assigned(_drawer) Then
            _drawer.Draw(pGrid, pRow, pCol, pColDef, pRect, pValue)
         End If
      End Sub
      Overrides Function GetID() As String
         GetID = me.Kind().AsString
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Kind", me.Kind())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me.Drawer) Then
            me.Drawer.Free()
            me.Drawer = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
