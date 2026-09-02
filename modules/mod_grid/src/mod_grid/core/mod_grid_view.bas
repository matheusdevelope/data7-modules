Imports Forms
Imports mod_tobject
Imports mod_grid_config
Imports mod_grid_context
Imports mod_grid_options
Imports mod_grid_data
Imports mod_grid_col
Imports mod_grid_row
Imports mod_grid_column_kind
Imports mod_grid_effects_builtin
Imports mod_grid_event_hub
Namespace mod_grid_view
   Class TGridView
      Inherits TTObject
      Private _context As TGridContext
      Private _options As TTGridOptions
      Sub New(pParent As TWinControl)
         MyBase.New()
         me._context = New TGridContext(TGridConfig.Create(), pParent)
         me._options = New TTGridOptions(me._context)
      End Sub
      Sub New(pParent As TWinControl, pConfig As TGridConfig)
         MyBase.New()
         me._context = New TGridContext(pConfig, pParent)
         me._options = New TTGridOptions(me._context)
      End Sub
      Sub New(pValue As TGridView)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridView)
         If Assigned(pValue) Then
            me._context = pValue._context
            me._options = pValue._options
         End If
      End Sub
      Overrides Function Clone() As TGridView
         Clone = New TGridView(me)
      End Function
      Property Native As Grid
         Get
            Native = me._context.Adapter.Native
         End Get
      End Property
      Property Context As TGridContext
         Get
            Context = me._context
         End Get
      End Property
      Property Config As TGridConfig
         Get
            Config = me._context.Config
         End Get
      End Property
      Property Data As TGridData
         Get
            Data = me._context.Data
         End Get
      End Property
      Property Options As TTGridOptions
         Get
            Options = me._options
         End Get
      End Property
      Property Events As TGridEventHub
         Get
            Events = me._context.EventHub
         End Get
      End Property
      Function AddColumn(pCol As TGridCol) As TGridCol
         If Assigned(pCol) AndAlso pCol.Kind = TGridColumnKind.Search() AndAlso pCol.Options.Search.DescriptionColumnId <> "" AndAlso pCol.SideEffectCount() = 0 Then
            pCol.AddSideEffect(mod_grid_effects_builtin.TGridEffects.SearchDescription)
         End If
         If Assigned(pCol) Then
            me._context.EditorPool.ResolveFactory(pCol)
         End If
         AddColumn = me._context.Data.PushColumn(pCol)
         me._context.ReorderSystemColumns()
      End Function
      Function AddRow() As TGridRow
         AddRow = me._context.Data.PushRow()
      End Function
      Function AddRow(pID As String) As TGridRow
         AddRow = me._context.Data.PushRow(pID)
      End Function
      Sub SetValue(pRowIndex As Integer, pColID As String, pValue As Variant)
         me._context.Data.SetCell(pRowIndex, pColID, pValue)
         me._applySearchDescriptionOnSet(pRowIndex, pColID, pValue)
      End Sub
      Sub SetValue(pRowID As String, pColID As String, pValue As Variant)
         me._context.Data.SetCell(pRowID, pColID, pValue)
      End Sub
      Private Sub _applySearchDescriptionOnSet(pRowIndex As Integer, pColID As String, pValue As Variant)
         Dim _col As TGridCol = me._context.Data.ColAt(pColID)
         If Assigned(_col) AndAlso _col.Options.Search.ApplyDescriptionOnSet AndAlso _col.Options.Search.DescriptionColumnId <> "" AndAlso _col.Kind = TGridColumnKind.Search() Then
            Dim _row As TGridRow = me._context.Data.RowAt(pRowIndex)
            If Assigned(_row) Then
               Dim _ctrl As TWinControl = me._context.EditorPool.Acquire(_col)
               If Assigned(_ctrl) Then
                  Dim _valid As Boolean = True
                  Dim _value As Variant = pValue
                  TGridEffects.ApplySearchDescriptionFromControl(me._context.Data, _row, _col, _ctrl, _value, _valid)
                  Dim _descIdx As Integer = me._context.Data.GetColIndex(_col.Options.Search.DescriptionColumnId)
                  me._context.Presenter.PokeDataCell(_descIdx, pRowIndex)
               End If
            End If
         End If
      End Sub
      Function GetValue(pRowIndex As Integer, pColID As String) As Variant
         GetValue = me._context.Data.GetCell(pRowIndex, pColID)
      End Function
      Function GetValue(pRowID As String, pColID As String) As Variant
         GetValue = me._context.Data.GetCell(pRowID, pColID)
      End Function
      Sub Prepare()
         If Assigned(me._context) Then
            me._context.EnsureSystemColumns()
            me._ensureStarterRow()
            If Assigned(me._context.Presenter) Then
               me._context.Presenter.Prepare()
            End If
            If Assigned(me._context.EventHub) Then
               me._context.EventHub.Wire()
            End If
         End If
      End Sub
      Private Sub _ensureStarterRow()
         If Assigned(me._context.Data) AndAlso me._context.Data.RowCount = 0 Then
            Dim _onlyRead As Boolean = False
            If Assigned(me._context.Config) AndAlso Assigned(me._context.Config.Options) Then
               _onlyRead = me._context.Config.Options.Interaction.OnlyRead
            End If
            If Not _onlyRead Then
               me._context.Data.PushRow()
            End If
         End If
      End Sub
      Sub Refresh()
         me.Prepare()
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Context", me._context.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me._options) Then
            me._options.Free()
            me._options = Null
         End If
         If Assigned(me._context) Then
            me._context.Free()
            me._context = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
