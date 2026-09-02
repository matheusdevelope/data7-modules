Imports Forms
Imports mod_tobject
Imports mod_ttmatrix
Namespace mod_grid_row
   Delegate Sub TGridRowStateChangedDel(pRow As TGridRow)

   Class TGridRowColorOptions
      Inherits TTObject
      Private _owner As TGridRow
      Private _text As Integer = -1
      Private _back As Integer = -1
      Sub New(pOwner As TGridRow)
         MyBase.New()
         me._owner = pOwner
      End Sub
      Sub Assign(pValue As TGridRowColorOptions)
         If Assigned(pValue) Then
            me._text = pValue.Text
            me._back = pValue.Back
         End If
      End Sub
      Property Text As Integer
         Get
            Text = me._text
         End Get
         Set(pValue As Integer)
            If me._text <> pValue Then
               me._text = pValue
               me._notifyOwner()
            End If
         End Set
      End Property
      Property Back As Integer
         Get
            Back = me._back
         End Get
         Set(pValue As Integer)
            If me._back <> pValue Then
               me._back = pValue
               me._notifyOwner()
            End If
         End Set
      End Property
      Private Sub _notifyOwner()
         If Assigned(me._owner) Then
            me._owner.NotifyState()
         End If
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Text", me._text)
            .Prop("Back", me._back)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me._owner = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridRowOptions
      Inherits TTObject
      Color As TGridRowColorOptions
      Sub New(pOwner As TGridRow)
         MyBase.New()
         me.Color = New TGridRowColorOptions(pOwner)
      End Sub
      Sub Assign(pValue As TGridRowOptions)
         If Assigned(pValue) Then
            If Assigned(pValue.Color) Then
               me.Color.Assign(pValue.Color)
            End If
         End If
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Color", me.Color.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me.Color) Then
            me.Color.Free()
            me.Color = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridRow
      Inherits TTMatrixRow<Variant>
      Private _selected As Boolean = False
      Private _deleted As Boolean = False
      Private _isNew As Boolean = False
      Private _dirty As Boolean = False
      Private _editable As Boolean = True
      Private _canMove As Boolean = True
      Private _canResize As Boolean = True
      Private _itemNumber As Integer = 0
      Private _font As TFont
      Options As TGridRowOptions
      Tag As TObject
      OnStateChanged As TGridRowStateChangedDel
      Sub New(pID As String)
         MyBase.New(pID)
         me.Options = New TGridRowOptions(me)
      End Sub
      Sub New(pValue As TGridRow)
         MyBase.New(pValue.ID)
         me.Options = New TGridRowOptions(me)
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridRow)
         If Assigned(pValue) Then
            me._selected = pValue.Selected
            me._deleted = pValue.Deleted
            me._isNew = pValue.IsNew
            me._dirty = pValue.Dirty
            me._editable = pValue.Editable
            me._canMove = pValue.CanMove
            me._canResize = pValue.CanResize
            me._itemNumber = pValue.ItemNumber
            If pValue.HasFont() Then
               me._copyFont(me.Font, pValue.Font)
            ElseIf Assigned(me._font) Then
         ' data7:disable-next-line unknown-member
               me._font.Free()
               me._font = Null
            End If
            If Assigned(pValue.Options) Then
               me.Options.Assign(pValue.Options)
            End If
            me.Tag = pValue.Tag
         End If
      End Sub
      Overrides Function Clone() As TTObject
         Clone = New TGridRow(me)
      End Function
      Property Selected As Boolean
         Get
            Selected = me._selected
         End Get
         Set(pValue As Boolean)
            If me._selected <> pValue Then
               me._selected = pValue
               me.NotifyState()
            End If
         End Set
      End Property
      Property Deleted As Boolean
         Get
            Deleted = me._deleted
         End Get
         Set(pValue As Boolean)
            me._deleted = pValue
         End Set
      End Property
      Property IsNew As Boolean
         Get
            IsNew = me._isNew
         End Get
         Set(pValue As Boolean)
            me._isNew = pValue
         End Set
      End Property
      Property Dirty As Boolean
         Get
            Dirty = me._dirty
         End Get
         Set(pValue As Boolean)
            me._dirty = pValue
         End Set
      End Property
      Property Editable As Boolean
         Get
            Editable = me._editable
         End Get
         Set(pValue As Boolean)
            If me._editable <> pValue Then
               me._editable = pValue
               me.NotifyState()
            End If
         End Set
      End Property
      Property CanMove As Boolean
         Get
            CanMove = me._canMove
         End Get
         Set(pValue As Boolean)
            me._canMove = pValue
         End Set
      End Property
      Property CanResize As Boolean
         Get
            CanResize = me._canResize
         End Get
         Set(pValue As Boolean)
            me._canResize = pValue
         End Set
      End Property
      Property ItemNumber As Integer
         Get
            ItemNumber = me._itemNumber
         End Get
         Set(pValue As Integer)
            me._itemNumber = pValue
         End Set
      End Property
      Property Font As TFont
         Get
            If Not Assigned(me._font) Then
               me._font = New TFont()
            End If
            Font = me._font
         End Get
         Set(pValue As TFont)
            me._font = pValue
            me.NotifyState()
         End Set
      End Property
      Function HasFont() As Boolean
         HasFont = Assigned(me._font)
      End Function
      Private Sub _copyFont(pTarget As TFont, pSource As TFont)
         If Assigned(pTarget) AndAlso Assigned(pSource) Then
            If Trim(pSource.Name) <> "" Then
               pTarget.Name = pSource.Name
            End If
            If pSource.Size <> 0 Then
               pTarget.Size = pSource.Size
            End If
            pTarget.Color = pSource.Color
            pTarget.Bold = pSource.Bold
            pTarget.Italic = pSource.Italic
            pTarget.Underline = pSource.Underline
            pTarget.Orientation = pSource.Orientation
            pTarget.Charset = pSource.Charset
            pTarget.Pitch = pSource.Pitch
            pTarget.Quality = pSource.Quality
         End If
      End Sub
      Sub NotifyState()
         If me.OnStateChanged <> Null Then
            me.OnStateChanged(me)
         End If
      End Sub
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("ID", me.ID)
            .Prop("Selected", me._selected)
            .Prop("Deleted", me._deleted)
            .Prop("IsNew", me._isNew)
            .Prop("Dirty", me._dirty)
            .Prop("Editable", me._editable)
            .Prop("CanMove", me._canMove)
            .Prop("CanResize", me._canResize)
            .Prop("ItemNumber", me._itemNumber)
            .Prop("HasFont", me.HasFont())
            .Prop("Options", me.Options.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me.OnStateChanged = Null
         me.Tag = Null
         If Assigned(me._font) Then
         ' data7:disable-next-line unknown-member
            me._font.Free()
            me._font = Null
         End If
         If Assigned(me.Options) Then
            me.Options.Free()
            me.Options = Null
         End If
         MyBase.Dispose()
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
