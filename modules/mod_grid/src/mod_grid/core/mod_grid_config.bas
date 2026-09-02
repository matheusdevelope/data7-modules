Imports mod_tobject
Imports mod_grid_row
Namespace mod_grid_config
   Delegate Sub TGridBeforeInsertNewRowDel(pRow As TGridRow, ByRef pCanInsert As Boolean, ByRef pMessage As String)

   Class TGridSelectionOptionsConfig
      Inherits TTObject
      Enabled As Boolean = False
      Index As Integer = -1
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridSelectionOptionsConfig)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridSelectionOptionsConfig)
         If Assigned(pValue) Then
            me.Enabled = pValue.Enabled
            me.Index = pValue.Index
         End If
      End Sub
      Overrides Function Clone() As TGridSelectionOptionsConfig
         Clone = New TGridSelectionOptionsConfig(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Enabled", me.Enabled)
            .Prop("Index", me.Index)
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

   Class TGridItemOptionsConfig
      Inherits TTObject
      Enabled As Boolean = False
      Index As Integer = -1
      Size As Integer = 1
      AutoUpdate As Boolean = True
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridItemOptionsConfig)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridItemOptionsConfig)
         If Assigned(pValue) Then
            me.Enabled = pValue.Enabled
            me.Index = pValue.Index
            me.Size = pValue.Size
            me.AutoUpdate = pValue.AutoUpdate
         End If
      End Sub
      Overrides Function Clone() As TGridItemOptionsConfig
         Clone = New TGridItemOptionsConfig(me)
      End Function
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
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridLayoutOptionsConfig
      Inherits TTObject
      AutoSize As Boolean = False
      StretchLastColumn As Boolean = False
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridLayoutOptionsConfig)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridLayoutOptionsConfig)
         If Assigned(pValue) Then
            me.AutoSize = pValue.AutoSize
            me.StretchLastColumn = pValue.StretchLastColumn
         End If
      End Sub
      Overrides Function Clone() As TGridLayoutOptionsConfig
         Clone = New TGridLayoutOptionsConfig(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("AutoSize", me.AutoSize)
            .Prop("StretchLastColumn", me.StretchLastColumn)
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

   Class TGridInteractionOptionsConfig
      Inherits TTObject
      OnlyRead As Boolean = False
      AllowMarkForDelete As Boolean = False
      AddRowOnDown As Boolean = False
      OnBeforeInsertNewRow As TGridBeforeInsertNewRowDel
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridInteractionOptionsConfig)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridInteractionOptionsConfig)
         If Assigned(pValue) Then
            me.OnlyRead = pValue.OnlyRead
            me.AllowMarkForDelete = pValue.AllowMarkForDelete
            me.AddRowOnDown = pValue.AddRowOnDown
            me.OnBeforeInsertNewRow = pValue.OnBeforeInsertNewRow
         End If
      End Sub
      Overrides Function Clone() As TGridInteractionOptionsConfig
         Clone = New TGridInteractionOptionsConfig(me)
      End Function
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
         me.OnBeforeInsertNewRow = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridHeaderColorOptionsConfig
      Inherits TTObject
      Text As Integer = -1
      Back As Integer = -1
      Required As Integer = RGB(0, 0, 255)
      RequiredBack As Integer = -1
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridHeaderColorOptionsConfig)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridHeaderColorOptionsConfig)
         If Assigned(pValue) Then
            me.Text = pValue.Text
            me.Back = pValue.Back
            me.Required = pValue.Required
            me.RequiredBack = pValue.RequiredBack
         End If
      End Sub
      Overrides Function Clone() As TGridHeaderColorOptionsConfig
         Clone = New TGridHeaderColorOptionsConfig(me)
      End Function
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
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridFixedColorOptionsConfig
      Inherits TTObject
      Back As Integer = -1
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridFixedColorOptionsConfig)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridFixedColorOptionsConfig)
         If Assigned(pValue) Then
            me.Back = pValue.Back
         End If
      End Sub
      Overrides Function Clone() As TGridFixedColorOptionsConfig
         Clone = New TGridFixedColorOptionsConfig(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Back", me.Back)
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

   Class TGridColorOptionsConfig
      Inherits TTObject
      Text As Integer = -1
      Back As Integer = -1
      Header As TGridHeaderColorOptionsConfig
      Fixed As TGridFixedColorOptionsConfig
      Sub New()
         MyBase.New()
         me.Header = New TGridHeaderColorOptionsConfig()
         me.Fixed = New TGridFixedColorOptionsConfig()
      End Sub
      Sub New(pValue As TGridColorOptionsConfig)
         MyBase.New()
         me.Header = New TGridHeaderColorOptionsConfig()
         me.Fixed = New TGridFixedColorOptionsConfig()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColorOptionsConfig)
         If Assigned(pValue) Then
            me.Text = pValue.Text
            me.Back = pValue.Back
            If Assigned(pValue.Header) Then
               me.Header.Assign(pValue.Header)
            End If
            If Assigned(pValue.Fixed) Then
               me.Fixed.Assign(pValue.Fixed)
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridColorOptionsConfig
         Clone = New TGridColorOptionsConfig(me)
      End Function
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

   Class TGridOptionsConfig
      Inherits TTObject
      Selection As TGridSelectionOptionsConfig
      Item As TGridItemOptionsConfig
      Layout As TGridLayoutOptionsConfig
      Interaction As TGridInteractionOptionsConfig
      Color As TGridColorOptionsConfig
      Sub New()
         MyBase.New()
         me.Selection = New TGridSelectionOptionsConfig()
         me.Item = New TGridItemOptionsConfig()
         me.Layout = New TGridLayoutOptionsConfig()
         me.Interaction = New TGridInteractionOptionsConfig()
         me.Color = New TGridColorOptionsConfig()
      End Sub
      Sub New(pValue As TGridOptionsConfig)
         MyBase.New()
         me.Selection = New TGridSelectionOptionsConfig()
         me.Item = New TGridItemOptionsConfig()
         me.Layout = New TGridLayoutOptionsConfig()
         me.Interaction = New TGridInteractionOptionsConfig()
         me.Color = New TGridColorOptionsConfig()
         me.Assign(pValue)
      End Sub
      Shared Function Defaultt() As TGridOptionsConfig
         Defaultt = New TGridOptionsConfig()
      End Function
      Shared Function DefaultColumnIndex() As Integer
         DefaultColumnIndex = -1
      End Function
      Shared Function LastColumnIndex() As Integer
         LastColumnIndex = -2
      End Function
      Sub Assign(pValue As TGridOptionsConfig)
         If Assigned(pValue) Then
            If Assigned(pValue.Selection) Then
               me.Selection.Assign(pValue.Selection)
            End If
            If Assigned(pValue.Item) Then
               me.Item.Assign(pValue.Item)
            End If
            If Assigned(pValue.Layout) Then
               me.Layout.Assign(pValue.Layout)
            End If
            If Assigned(pValue.Interaction) Then
               me.Interaction.Assign(pValue.Interaction)
            End If
            If Assigned(pValue.Color) Then
               me.Color.Assign(pValue.Color)
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridOptionsConfig
         Clone = New TGridOptionsConfig(me)
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

   Class TGridConfig
      Inherits TTObject
      Options As TGridOptionsConfig
      GlobalValidators As mod_grid_validator.TGridValidatorChain
      GlobalSideEffects As mod_grid_side_effect.TGridSideEffectChain
      EditorRegistry As mod_grid_editor_registry.TGridEditorRegistry
      Shared Function Create() As TGridConfig
         Create = New TGridConfig()
      End Function
      Sub New()
         MyBase.New()
         me.Options = TGridOptionsConfig.Defaultt()
         me.GlobalValidators = New mod_grid_validator.TGridValidatorChain()
         me.GlobalSideEffects = New mod_grid_side_effect.TGridSideEffectChain()
         me.EditorRegistry = New mod_grid_editor_registry.TGridEditorRegistry()
      End Sub
      Sub New(pValue As TGridConfig)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridConfig)
         If Assigned(pValue) Then
            If Assigned(pValue.Options) Then
               me.Options = pValue.Options.Clone()
            End If
            me.GlobalValidators = pValue.GlobalValidators
            me.GlobalSideEffects = pValue.GlobalSideEffects
            me.EditorRegistry = pValue.EditorRegistry
         End If
      End Sub
      Overrides Function Clone() As TGridConfig
         Clone = New TGridConfig(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Options", me.Options.ToString())
            .Prop("GlobalValidators", me.GlobalValidators.ToString())
            .Prop("GlobalSideEffects", me.GlobalSideEffects.ToString())
            .Prop("EditorRegistry", me.EditorRegistry.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me.Options) Then
            me.Options.Free()
            me.Options = Null
         End If
         If Assigned(me.GlobalValidators) Then
            me.GlobalValidators.Free()
            me.GlobalValidators = Null
         End If
         If Assigned(me.GlobalSideEffects) Then
            me.GlobalSideEffects.Free()
            me.GlobalSideEffects = Null
         End If
         If Assigned(me.EditorRegistry) Then
            me.EditorRegistry.Free()
            me.EditorRegistry = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
