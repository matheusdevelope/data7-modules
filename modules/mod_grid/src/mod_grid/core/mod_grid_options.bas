Imports mod_tobject
Imports mod_grid_config
Imports mod_grid_context
Imports mod_grid_col
Namespace mod_grid_options
   Class TGridSelectionOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
      End Sub
      Private Function _data() As TGridSelectionOptionsConfig
         _data = me._ctx.Config.Options.Selection
      End Function
      Property Enabled As Boolean
         Get
            Enabled = me._data().Enabled
         End Get
         Set(pValue As Boolean)
            me._setEnabled(pValue)
            me._ctx.EnsureSystemColumns()
         End Set
      End Property
      Private Sub _setEnabled(pValue As Boolean)
         me._data().Enabled = pValue
      End Sub
      Property Index As Integer
         Get
            Index = me._data().Index
         End Get
         Set(pValue As Integer)
            me._setIndex(pValue)
            me._ctx.ReorderSystemColumns()
            me._ctx.Presenter.SyncIfPrepared()
         End Set
      End Property
      Private Sub _setIndex(pValue As Integer)
         me._data().Index = pValue
      End Sub
      Property Column As TGridCol
         Get
            Column = me._ctx.SelectionColumn
         End Get
      End Property
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Enabled", me.Enabled)
            .Prop("Index", me.Index)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridItemOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
      End Sub
      Private Function _data() As TGridItemOptionsConfig
         _data = me._ctx.Config.Options.Item
      End Function
      Property Enabled As Boolean
         Get
            Enabled = me._data().Enabled
         End Get
         Set(pValue As Boolean)
            me._setEnabled(pValue)
            me._ctx.EnsureSystemColumns()
         End Set
      End Property
      Private Sub _setEnabled(pValue As Boolean)
         me._data().Enabled = pValue
      End Sub
      Property Index As Integer
         Get
            Index = me._data().Index
         End Get
         Set(pValue As Integer)
            me._setIndex(pValue)
            me._ctx.ReorderSystemColumns()
            me._ctx.Presenter.SyncIfPrepared()
         End Set
      End Property
      Private Sub _setIndex(pValue As Integer)
         me._data().Index = pValue
      End Sub
      Property Size As Integer
         Get
            Size = me._data().Size
         End Get
         Set(pValue As Integer)
            Dim n As Integer = pValue
            If n < 1 Then
               n = 1
            End If
            me._setSize(n)
            me._ctx.Data.ItemNumberSize = n
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setSize(pValue As Integer)
         me._data().Size = pValue
      End Sub
      Property AutoUpdate As Boolean
         Get
            AutoUpdate = me._data().AutoUpdate
         End Get
         Set(pValue As Boolean)
            Dim wasAuto As Boolean = me._data().AutoUpdate
            me._setAutoUpdate(pValue)
            If wasAuto AndAlso Not pValue Then
               me._ctx.Data.RenumberItems()
            End If
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setAutoUpdate(pValue As Boolean)
         me._data().AutoUpdate = pValue
      End Sub
      Property Column As TGridCol
         Get
            Column = me._ctx.ItemColumn
         End Get
      End Property
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Enabled", me.Enabled)
            .Prop("Index", me.Index)
            .Prop("Size", me.Size)
            .Prop("AutoUpdate", me.AutoUpdate)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridLayoutOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
      End Sub
      Private Function _data() As TGridLayoutOptionsConfig
         _data = me._ctx.Config.Options.Layout
      End Function
      Property AutoSize As Boolean
         Get
            AutoSize = me._data().AutoSize
         End Get
         Set(pValue As Boolean)
            me._setAutoSize(pValue)
            me._ctx.Presenter.ApplyColumnLayout()
         End Set
      End Property
      Private Sub _setAutoSize(pValue As Boolean)
         me._data().AutoSize = pValue
      End Sub
      Property StretchLastColumn As Boolean
         Get
            StretchLastColumn = me._data().StretchLastColumn
         End Get
         Set(pValue As Boolean)
            me._setStretchLastColumn(pValue)
            me._ctx.Presenter.ApplyColumnLayout()
         End Set
      End Property
      Private Sub _setStretchLastColumn(pValue As Boolean)
         me._data().StretchLastColumn = pValue
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("AutoSize", me.AutoSize)
            .Prop("StretchLastColumn", me.StretchLastColumn)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridInteractionOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
      End Sub
      Private Function _data() As TGridInteractionOptionsConfig
         _data = me._ctx.Config.Options.Interaction
      End Function
      Property OnlyRead As Boolean
         Get
            OnlyRead = me._data().OnlyRead
         End Get
         Set(pValue As Boolean)
            me._setOnlyRead(pValue)
            me._ctx.Presenter.ApplyOptions()
         End Set
      End Property
      Private Sub _setOnlyRead(pValue As Boolean)
         me._data().OnlyRead = pValue
      End Sub
      Property AllowMarkForDelete As Boolean
         Get
            AllowMarkForDelete = me._data().AllowMarkForDelete
         End Get
         Set(pValue As Boolean)
            me._setAllowMarkForDelete(pValue)
            me._ctx.Presenter.SyncIfPrepared()
         End Set
      End Property
      Private Sub _setAllowMarkForDelete(pValue As Boolean)
         me._data().AllowMarkForDelete = pValue
      End Sub
      Property AddRowOnDown As Boolean
         Get
            AddRowOnDown = me._data().AddRowOnDown
         End Get
         Set(pValue As Boolean)
            me._setAddRowOnDown(pValue)
         End Set
      End Property
      Private Sub _setAddRowOnDown(pValue As Boolean)
         me._data().AddRowOnDown = pValue
      End Sub
      Property OnBeforeInsertNewRow As TGridBeforeInsertNewRowDel
         Get
            OnBeforeInsertNewRow = me._data().OnBeforeInsertNewRow
         End Get
         Set(pValue As TGridBeforeInsertNewRowDel)
            me._setOnBeforeInsertNewRow(pValue)
         End Set
      End Property
      Private Sub _setOnBeforeInsertNewRow(pValue As TGridBeforeInsertNewRowDel)
         me._data().OnBeforeInsertNewRow = pValue
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("OnlyRead", me.OnlyRead)
            .Prop("AllowMarkForDelete", me.AllowMarkForDelete)
            .Prop("AddRowOnDown", me.AddRowOnDown)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridHeaderColorOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
      End Sub
      Private Function _data() As TGridHeaderColorOptionsConfig
         _data = me._ctx.Config.Options.Color.Header
      End Function
      Property Text As Integer
         Get
            Text = me._data().Text
         End Get
         Set(pValue As Integer)
            me._setText(pValue)
            me._ctx.Presenter.ApplyOptions()
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setText(pValue As Integer)
         me._data().Text = pValue
      End Sub
      Property Back As Integer
         Get
            Back = me._data().Back
         End Get
         Set(pValue As Integer)
            me._setBack(pValue)
            me._ctx.Presenter.ApplyOptions()
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setBack(pValue As Integer)
         me._data().Back = pValue
      End Sub
      Property Required As Integer
         Get
            Required = me._data().Required
         End Get
         Set(pValue As Integer)
            me._setRequired(pValue)
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setRequired(pValue As Integer)
         me._data().Required = pValue
      End Sub
      Property RequiredBack As Integer
         Get
            RequiredBack = me._data().RequiredBack
         End Get
         Set(pValue As Integer)
            me._setRequiredBack(pValue)
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setRequiredBack(pValue As Integer)
         me._data().RequiredBack = pValue
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Text", me.Text)
            .Prop("Back", me.Back)
            .Prop("Required", me.Required)
            .Prop("RequiredBack", me.RequiredBack)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridFixedColorOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
      End Sub
      Private Function _data() As TGridFixedColorOptionsConfig
         _data = me._ctx.Config.Options.Color.Fixed
      End Function
      Property Back As Integer
         Get
            Back = me._data().Back
         End Get
         Set(pValue As Integer)
            me._setBack(pValue)
            me._ctx.Presenter.ApplyOptions()
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setBack(pValue As Integer)
         me._data().Back = pValue
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Back", me.Back)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridColorOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Header As TGridHeaderColorOptions
      Fixed As TGridFixedColorOptions
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
         me.Header = New TGridHeaderColorOptions(pContext)
         me.Fixed = New TGridFixedColorOptions(pContext)
      End Sub
      Private Function _data() As TGridColorOptionsConfig
         _data = me._ctx.Config.Options.Color
      End Function
      Property Text As Integer
         Get
            Text = me._data().Text
         End Get
         Set(pValue As Integer)
            me._setText(pValue)
            me._ctx.Presenter.ApplyOptions()
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setText(pValue As Integer)
         me._data().Text = pValue
      End Sub
      Property Back As Integer
         Get
            Back = me._data().Back
         End Get
         Set(pValue As Integer)
            me._setBack(pValue)
            me._ctx.Presenter.ApplyOptions()
            me._ctx.Presenter.InvalidateIfPrepared()
         End Set
      End Property
      Private Sub _setBack(pValue As Integer)
         me._data().Back = pValue
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Text", me.Text)
            .Prop("Back", me.Back)
            .Prop("Header", me.Header.ToString())
            .Prop("Fixed", me.Fixed.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
         If Assigned(me.Header) Then
            me.Header.Free()
            me.Header = Null
         End If
         If Assigned(me.Fixed) Then
            me.Fixed.Free()
            me.Fixed = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TTGridOptions
      Inherits TTObject
      Private _ctx As TGridContext
      Selection As TGridSelectionOptions
      Item As TGridItemOptions
      Layout As TGridLayoutOptions
      Interaction As TGridInteractionOptions
      Color As TGridColorOptions
      Sub New(pContext As TGridContext)
         MyBase.New()
         me._ctx = pContext
         me.Selection = New TGridSelectionOptions(pContext)
         me.Item = New TGridItemOptions(pContext)
         me.Layout = New TGridLayoutOptions(pContext)
         me.Interaction = New TGridInteractionOptions(pContext)
         me.Color = New TGridColorOptions(pContext)
      End Sub
      Shared Function DefaultColumnIndex() As Integer
         DefaultColumnIndex = TGridOptionsConfig.DefaultColumnIndex()
      End Function
      Shared Function LastColumnIndex() As Integer
         LastColumnIndex = TGridOptionsConfig.LastColumnIndex()
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Selection", me.Selection.ToString())
            .Prop("Item", me.Item.ToString())
            .Prop("Layout", me.Layout.ToString())
            .Prop("Interaction", me.Interaction.ToString())
            .Prop("Color", me.Color.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._ctx = Null
         If Assigned(me.Selection) Then
            me.Selection.Free()
            me.Selection = Null
         End If
         If Assigned(me.Item) Then
            me.Item.Free()
            me.Item = Null
         End If
         If Assigned(me.Layout) Then
            me.Layout.Free()
            me.Layout = Null
         End If
         If Assigned(me.Interaction) Then
            me.Interaction.Free()
            me.Interaction = Null
         End If
         If Assigned(me.Color) Then
            me.Color.Free()
            me.Color = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
