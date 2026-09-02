Imports Forms
Imports IO
Imports mod_tobject
Imports mod_ttmatrix
Imports mod_grid_column_kind
Imports mod_grid_validator
Imports mod_grid_validators_builtin
Imports mod_grid_side_effect
Imports mod_grid_editor_contract
Imports mod_grid_row
Namespace mod_grid_col
   Delegate Function TGridCanEditDel(pRow As TGridRow, pCol As TGridCol) As Boolean
   Delegate Function TGridDefaultValueDel(pRow As TGridRow, pCol As TGridCol) As Variant
   Delegate Function TGridCheckboxToggleValidateDel(pRow As TGridRow, pCol As TGridCol, pCurrentValue As String, pNewValue As String, ByRef pMessage As String) As Boolean
   Delegate Function TGridCheckboxCanToggleDel(pRow As TGridRow, pCol As TGridCol) As Boolean

   Class TGridColLayoutOptions
      Inherits TTObject
      Width As Integer = 80
      Hidden As Boolean = False
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColLayoutOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColLayoutOptions)
         If Assigned(pValue) Then
            me.Width = pValue.Width
            me.Hidden = pValue.Hidden
         End If
      End Sub
      Overrides Function Clone() As TGridColLayoutOptions
         Clone = New TGridColLayoutOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Width", me.Width)
            .Prop("Hidden", me.Hidden)
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

   Class TGridColInteractionOptions
      Inherits TTObject
      OnlyRead As Boolean = False
      Required As Boolean = False
      CanMove As Boolean = True
      CanResize As Boolean = True
      CanEdit As TGridCanEditDel
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColInteractionOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColInteractionOptions)
         If Assigned(pValue) Then
            me.OnlyRead = pValue.OnlyRead
            me.Required = pValue.Required
            me.CanMove = pValue.CanMove
            me.CanResize = pValue.CanResize
            me.CanEdit = pValue.CanEdit
         End If
      End Sub
      Overrides Function Clone() As TGridColInteractionOptions
         Clone = New TGridColInteractionOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("OnlyRead", me.OnlyRead)
            .Prop("Required", me.Required)
            .Prop("CanMove", me.CanMove)
            .Prop("CanResize", me.CanResize)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me.CanEdit = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridColHeaderColorOptions
      Inherits TTObject
      Text As Integer = -1
      Back As Integer = -1
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColHeaderColorOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColHeaderColorOptions)
         If Assigned(pValue) Then
            me.Text = pValue.Text
            me.Back = pValue.Back
         End If
      End Sub
      Overrides Function Clone() As TGridColHeaderColorOptions
         Clone = New TGridColHeaderColorOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Text", me.Text)
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

   Class TGridColColorOptions
      Inherits TTObject
      Text As Integer = -1
      Back As Integer = -1
      Header As TGridColHeaderColorOptions
      Sub New()
         MyBase.New()
         me.Header = New TGridColHeaderColorOptions()
      End Sub
      Sub New(pValue As TGridColColorOptions)
         MyBase.New()
         me.Header = New TGridColHeaderColorOptions()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColColorOptions)
         If Assigned(pValue) Then
            me.Text = pValue.Text
            me.Back = pValue.Back
            If Assigned(pValue.Header) Then
               me.Header.Assign(pValue.Header)
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridColColorOptions
         Clone = New TGridColColorOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Text", me.Text)
            .Prop("Back", me.Back)
            .Prop("Header", me.Header.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me.Header) Then
            me.Header.Free()
            me.Header = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridColSearchOptions
      Inherits TTObject
      CodPesquisa As Integer = 0
      DescriptionColumnId As String = ""
      ApplyDescriptionOnSet As Boolean = False
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColSearchOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColSearchOptions)
         If Assigned(pValue) Then
            me.CodPesquisa = pValue.CodPesquisa
            me.DescriptionColumnId = pValue.DescriptionColumnId
            me.ApplyDescriptionOnSet = pValue.ApplyDescriptionOnSet
         End If
      End Sub
      Overrides Function Clone() As TGridColSearchOptions
         Clone = New TGridColSearchOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("CodPesquisa", me.CodPesquisa)
            .Prop("DescriptionColumnId", me.DescriptionColumnId)
            .Prop("ApplyDescriptionOnSet", me.ApplyDescriptionOnSet)
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

   Class TGridComboItem
      Inherits TTObject
      Key As String = ""
      Value As String = ""
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pKey As String, pValue As String)
         MyBase.New()
         me.Key = pKey
         me.Value = pValue
      End Sub
      Sub New(pValue As TGridComboItem)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridComboItem)
         If Assigned(pValue) Then
            me.Key = pValue.Key
            me.Value = pValue.Value
         End If
      End Sub
      Overrides Function Clone() As TGridComboItem
         Clone = New TGridComboItem(me)
      End Function
      Overrides Function GetID() As String
         GetID = me.Key
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Key", me.Key)
            .Prop("Value", me.Value)
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

   Class TGridColComboOptions
      Inherits TTObject
      Items[] As TGridComboItem
      ShowDescription As Boolean = True
      Sub New()
         MyBase.New()
         me.Items = []
      End Sub
      Sub New(pValue As TGridColComboOptions)
         MyBase.New()
         me.Items = []
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColComboOptions)
         If Assigned(pValue) Then
            me.ShowDescription = pValue.ShowDescription
            If Assigned(me.Items) Then
               me.Items.Free()
            End If
            If Assigned(pValue.Items) Then
               me.Items = pValue.Items.Clone()
            Else
               me.Items = []
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridColComboOptions
         Clone = New TGridColComboOptions(me)
      End Function
      Function Add(pKey As String, pValue As String) As TGridColComboOptions
         Dim _item As New TGridComboItem(pKey, pValue)
         me.Items.Push(_item)
         Add = me
      End Function
      Function SetLista(pLista As String) As TGridColComboOptions
         If Assigned(me.Items) Then
            me.Items.Free()
         End If
         me.Items = []
         Dim _pos As Integer = 1
         Dim _lista As String = Trim(pLista)
         While _pos <= Len(_lista)
            Dim _pair As String = me._readToken(_lista, _pos)
            If _pair <> "" Then
               me._addPair(_pair)
            End If
         End While
         SetLista = me
      End Function
      Function AsListaOpcoes() As String
         Dim _out As String = ""
         Dim i As Integer
         For i = 0 To me.Items.Length - 1
            Dim _item As TGridComboItem = me.Items.GetItem(i)
            If Assigned(_item) Then
               If _out <> "" Then
                  _out = _out + ";"
               End If
               _out = _out + me._formatPair(_item.Value, _item.Key)
            End If
         Next
         AsListaOpcoes = _out
      End Function
      Private Function _containsSpace(pText As String) As Boolean
         _containsSpace = (InStr(pText, " ") > 0)
      End Function
      Private Function _formatPair(pDescription As String, pKey As String) As String
         Dim _pair As String = pDescription + "=" + pKey
         If me._containsSpace(pDescription) Or me._containsSpace(pKey) Then
            _formatPair = """" + _pair + """"
         Else
            _formatPair = _pair
         End If
      End Function
      Private Function _readToken(pLista As String, ByRef pPos As Integer) As String
         _readToken = ""
         Dim n As Integer = Len(pLista)
         While pPos <= n
            If Mid(pLista, pPos, 1) = " " Then
               pPos = pPos + 1
            Else
               Exit While
            End If
         End While
         If pPos <= n Then
            If Mid(pLista, pPos, 1) = """" Then
               pPos = pPos + 1
               Dim _start As Integer = pPos
               While pPos <= n
                  If Mid(pLista, pPos, 1) = """" Then
                     Exit While
                  End If
                  pPos = pPos + 1
               End While
               _readToken = Mid(pLista, _start, pPos - _start)
               If pPos <= n Then
                  If Mid(pLista, pPos, 1) = """" Then
                     pPos = pPos + 1
                  End If
               End If
            Else
               Dim _start2 As Integer = pPos
               While pPos <= n
                  If Mid(pLista, pPos, 1) = ";" Then
                     Exit While
                  End If
                  pPos = pPos + 1
               End While
               _readToken = Trim(Mid(pLista, _start2, pPos - _start2))
            End If
            While pPos <= n
               If Mid(pLista, pPos, 1) = " " Then
                  pPos = pPos + 1
               Else
                  Exit While
               End If
            End While
            If pPos <= n Then
               If Mid(pLista, pPos, 1) = ";" Then
                  pPos = pPos + 1
               End If
            End If
         End If
      End Function
      Private Sub _addPair(pPair As String)
         Dim _pair As String = Trim(pPair)
         If _pair <> "" Then
            Dim _eq As Integer = InStr(_pair, "=")
            Dim _key As String = _pair
            Dim _value As String = _pair
            If _eq > 0 Then
               _value = Trim(Left(_pair, _eq - 1))
               _key = Trim(Mid(_pair, _eq + 1))
            End If
            me.Add(_key, _value)
         End If
      End Sub
      Function LookupValue(pKey As String) As String
         LookupValue = ""
         Dim _key As String = Trim(pKey)
         If _key <> "" Then
            Dim idx As Integer = me.Items.IndexOf(_key)
            If idx >= 0 Then
               Dim _item As TGridComboItem = me.Items.GetItem(idx)
               If Assigned(_item) Then
                  LookupValue = _item.Value
               End If
            End If
         End If
      End Function
      Function LookupKey(pValue As String) As String
         Dim _found As String = ""
         Dim _value As String = Trim(pValue)
         If _value <> "" Then
            Dim i As Integer
            For i = 0 To me.Items.Length - 1
               If _found = "" Then
                  Dim _item As TGridComboItem = me.Items.GetItem(i)
                  If Assigned(_item) AndAlso UCase(Trim(_item.Value)) = UCase(_value) Then
                     _found = _item.Key
                  End If
               End If
            Next
         End If
         LookupKey = _found
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("ShowDescription", me.ShowDescription)
            .Prop("Items", me.Items.Length)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me.Items) Then
            me.Items.Free()
            me.Items = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridImageItem
      Inherits TTObject
      Key As String = ""
      Base64 As String = ""
      Path As String = ""
      Html As String = ""
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pKey As String, pBase64 As String)
         MyBase.New()
         me.Key = pKey
         me.Base64 = pBase64
      End Sub
      Sub New(pValue As TGridImageItem)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridImageItem)
         If Assigned(pValue) Then
            me.Key = pValue.Key
            me.Base64 = pValue.Base64
            me.Path = pValue.Path
            me.Html = pValue.Html
         End If
      End Sub
      Overrides Function Clone() As TGridImageItem
         Clone = New TGridImageItem(me)
      End Function
      Overrides Function GetID() As String
         GetID = me.Key
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Key", me.Key)
            .Prop("Path", me.Path)
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

   Class TGridColImageOptions
      Inherits TTObject
      Items[] As TGridImageItem
      Private _fileSeq As Integer = 0
      Private _htmlKey As String = ""
      Private _htmlCached As String = ""
      Private _htmlReady As Boolean = False
      Sub New()
         MyBase.New()
         me.Items = []
      End Sub
      Sub New(pValue As TGridColImageOptions)
         MyBase.New()
         me.Items = []
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColImageOptions)
         If Assigned(pValue) Then
            me._fileSeq = pValue._fileSeq
            me._htmlReady = False
            me._htmlKey = ""
            me._htmlCached = ""
            If Assigned(me.Items) Then
               me.Items.Free()
            End If
            If Assigned(pValue.Items) Then
               me.Items = pValue.Items.Clone()
            Else
               me.Items = []
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridColImageOptions
         Clone = New TGridColImageOptions(me)
      End Function
      Function Add(pKey As String, pBase64 As String) As TGridColImageOptions
         Dim _key As String = Trim(pKey)
         Dim _item As TGridImageItem
         Dim idx As Integer = -1
         me._htmlReady = False
         If _key <> "" Then
            idx = me.Items.IndexOf(_key)
         End If
         If idx >= 0 Then
            _item = me.Items.GetItem(idx)
            If Assigned(_item) Then
               _item.Base64 = pBase64
               _item.Path = ""
               _item.Html = ""
            End If
         Else
            _item = New TGridImageItem(_key, pBase64)
            me.Items.Push(_item)
         End If
         me._materialize(_item)
         Add = me
      End Function
      Function LookupPath(pKey As String) As String
         LookupPath = me._itemPath(Trim(pKey))
      End Function
      Function AsHtml(pKey As String) As String
         Dim _key As String = Trim(pKey)
         If me._htmlReady AndAlso _key = me._htmlKey Then
            AsHtml = me._htmlCached
         Else
            Dim _html As String = me._itemHtml(_key)
            me._htmlKey = _key
            me._htmlCached = _html
            me._htmlReady = True
            AsHtml = _html
         End If
      End Function
      Private Function _itemPath(pKey As String) As String
         _itemPath = ""
         If pKey <> "" Then
            Dim _item As TGridImageItem = me._itemOf(pKey)
            If Assigned(_item) Then
               If _item.Path = "" Then
                  me._materialize(_item)
               End If
               _itemPath = _item.Path
            End If
         End If
      End Function
      Private Function _itemHtml(pKey As String) As String
         _itemHtml = ""
         If pKey <> "" Then
            Dim _item As TGridImageItem = me._itemOf(pKey)
            If Assigned(_item) Then
               If _item.Html = "" Then
                  If _item.Path = "" Then
                     me._materialize(_item)
                  Else
                     _item.Html = me._htmlOf(_item.Path)
                  End If
               End If
               _itemHtml = _item.Html
            End If
         End If
      End Function
      Private Function _itemOf(pKey As String) As TGridImageItem
         Dim idx As Integer = me.Items.IndexOf(pKey)
         If idx >= 0 Then
            _itemOf = me.Items.GetItem(idx)
         End If
      End Function
      Private Function _htmlOf(pPath As String) As String
         If pPath <> "" Then
            _htmlOf = "<img src=""file://" + pPath + """>"
         Else
            _htmlOf = ""
         End If
      End Function
      Private Sub _materialize(pItem As TGridImageItem)
         If Assigned(pItem) AndAlso Trim(pItem.Base64) <> "" Then
            If pItem.Path = "" Then
               pItem.Path = me._nextPath(pItem.Key, pItem.Base64)
               Base64ToFile(me._payload(pItem.Base64), pItem.Path)
            End If
            If pItem.Html = "" AndAlso pItem.Path <> "" Then
               pItem.Html = me._htmlOf(pItem.Path)
            End If
         End If
      End Sub
      Private Function _nextPath(pKey As String, pBase64 As String) As String
         me._fileSeq = me._fileSeq + 1
         _nextPath = me._cacheDir() + "\gimg_" + me._safeName(pKey) + "_" + CStr(me._fileSeq) + me._extOf(pBase64)
      End Function
      Private Function _cacheDir() As String
         Dim _dir As String = "C:\Windows\Temp\mod_grid_img"
         If Not Directory.Exists(_dir) Then
            Directory.Create(_dir)
         End If
         _cacheDir = _dir
      End Function
      Private Function _payload(pBase64 As String) As String
         Dim _raw As String = Trim(pBase64)
         Dim _comma As Integer = InStr(_raw, ",")
         If Left(LCase(_raw), 5) = "data:" AndAlso _comma > 0 Then
            _raw = Mid(_raw, _comma + 1)
         End If
         _payload = Replace(Replace(Replace(_raw, Chr(13), ""), Chr(10), ""), " ", "")
      End Function
      Private Function _extOf(pBase64 As String) As String
         Dim _b As String = me._payload(pBase64)
         If Left(_b, 4) = "/9j/" Then
            _extOf = ".jpg"
         ElseIf Left(_b, 6) = "R0lGOD" Then
            _extOf = ".gif"
         Else
            _extOf = ".png"
         End If
      End Function
      Private Function _safeName(pKey As String) As String
         Dim _src As String = Trim(pKey)
         Dim _out As String = ""
         Dim i As Integer
         For i = 1 To Len(_src)
            Dim _ch As String = Mid(_src, i, 1)
            If InStr("\/:*?""<>|", _ch) > 0 Then
               _out = _out + "_"
            Else
               _out = _out + _ch
            End If
         Next
         If _out = "" Then
            _out = "img"
         End If
         _safeName = _out
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Items", me.Items.Length)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me.Items) Then
            me.Items.Free()
            me.Items = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridColFormatOptions
      Inherits TTObject
      Mask As String = ""
      Decimals As Integer = 2
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColFormatOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColFormatOptions)
         If Assigned(pValue) Then
            me.Mask = pValue.Mask
            me.Decimals = pValue.Decimals
         End If
      End Sub
      Overrides Function Clone() As TGridColFormatOptions
         Clone = New TGridColFormatOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Mask", me.Mask)
            .Prop("Decimals", me.Decimals)
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

   Class TGridColCheckboxOptions
      Inherits TTObject
      CheckedValue As String = "S"
      UncheckedValue As String = "N"
      ToggleOnDblClick As Boolean = True
      ActivationKeys As String = " "
      ToggleValidate As TGridCheckboxToggleValidateDel
      CanToggle As TGridCheckboxCanToggleDel
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColCheckboxOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColCheckboxOptions)
         If Assigned(pValue) Then
            me.CheckedValue = pValue.CheckedValue
            me.UncheckedValue = pValue.UncheckedValue
            me.ToggleOnDblClick = pValue.ToggleOnDblClick
            me.ActivationKeys = pValue.ActivationKeys
            me.ToggleValidate = pValue.ToggleValidate
            me.CanToggle = pValue.CanToggle
         End If
      End Sub
      Overrides Function Clone() As TGridColCheckboxOptions
         Clone = New TGridColCheckboxOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("CheckedValue", me.CheckedValue)
            .Prop("UncheckedValue", me.UncheckedValue)
            .Prop("ToggleOnDblClick", me.ToggleOnDblClick)
            .Prop("ActivationKeys", me.ActivationKeys)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         me.ToggleValidate = Null
         me.CanToggle = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridColSystemOptions
      Inherits TTObject
      IsRowNumber As Boolean = False
      IsSelection As Boolean = False
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColSystemOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColSystemOptions)
         If Assigned(pValue) Then
            me.IsRowNumber = pValue.IsRowNumber
            me.IsSelection = pValue.IsSelection
         End If
      End Sub
      Overrides Function Clone() As TGridColSystemOptions
         Clone = New TGridColSystemOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("IsRowNumber", me.IsRowNumber)
            .Prop("IsSelection", me.IsSelection)
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

   Class TGridColEffectsOptions
      Inherits TTObject
      CascadeClearColumnId As String = ""
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColEffectsOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColEffectsOptions)
         If Assigned(pValue) Then
            me.CascadeClearColumnId = pValue.CascadeClearColumnId
         End If
      End Sub
      Overrides Function Clone() As TGridColEffectsOptions
         Clone = New TGridColEffectsOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("CascadeClearColumnId", me.CascadeClearColumnId)
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

   Class TGridColSortOptions
      Inherits TTObject
      Numeric As Boolean = False
      CanSort As Boolean = True
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridColSortOptions)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColSortOptions)
         If Assigned(pValue) Then
            me.Numeric = pValue.Numeric
            me.CanSort = pValue.CanSort
         End If
      End Sub
      Overrides Function Clone() As TGridColSortOptions
         Clone = New TGridColSortOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Numeric", me.Numeric)
            .Prop("CanSort", me.CanSort)
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

   Class TGridColOptions
      Inherits TTObject
      Layout As TGridColLayoutOptions
      Interaction As TGridColInteractionOptions
      Color As TGridColColorOptions
      Search As TGridColSearchOptions
      Combo As TGridColComboOptions
      Image As TGridColImageOptions
      Format As TGridColFormatOptions
      Checkbox As TGridColCheckboxOptions
      System As TGridColSystemOptions
      Effects As TGridColEffectsOptions
      Sort As TGridColSortOptions
      DefaultValue As Variant
      OnGetDefault As TGridDefaultValueDel
      Drawer As TGridCellDrawer
      Sub New()
         MyBase.New()
         me.Layout = New TGridColLayoutOptions()
         me.Interaction = New TGridColInteractionOptions()
         me.Color = New TGridColColorOptions()
         me.Search = New TGridColSearchOptions()
         me.Combo = New TGridColComboOptions()
         me.Image = New TGridColImageOptions()
         me.Format = New TGridColFormatOptions()
         me.Checkbox = New TGridColCheckboxOptions()
         me.System = New TGridColSystemOptions()
         me.Effects = New TGridColEffectsOptions()
         me.Sort = New TGridColSortOptions()
      End Sub
      Sub New(pValue As TGridColOptions)
         MyBase.New()
         me.Layout = New TGridColLayoutOptions()
         me.Interaction = New TGridColInteractionOptions()
         me.Color = New TGridColColorOptions()
         me.Search = New TGridColSearchOptions()
         me.Combo = New TGridColComboOptions()
         me.Image = New TGridColImageOptions()
         me.Format = New TGridColFormatOptions()
         me.Checkbox = New TGridColCheckboxOptions()
         me.System = New TGridColSystemOptions()
         me.Effects = New TGridColEffectsOptions()
         me.Sort = New TGridColSortOptions()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridColOptions)
         If Assigned(pValue) Then
            If Assigned(pValue.Layout) Then
               me.Layout.Assign(pValue.Layout)
            End If
            If Assigned(pValue.Interaction) Then
               me.Interaction.Assign(pValue.Interaction)
            End If
            If Assigned(pValue.Color) Then
               me.Color.Assign(pValue.Color)
            End If
            If Assigned(pValue.Search) Then
               me.Search.Assign(pValue.Search)
            End If
            If Assigned(pValue.Combo) Then
               me.Combo.Assign(pValue.Combo)
            End If
            If Assigned(pValue.Image) Then
               me.Image.Assign(pValue.Image)
            End If
            If Assigned(pValue.Format) Then
               me.Format.Assign(pValue.Format)
            End If
            If Assigned(pValue.Checkbox) Then
               me.Checkbox.Assign(pValue.Checkbox)
            End If
            If Assigned(pValue.System) Then
               me.System.Assign(pValue.System)
            End If
            If Assigned(pValue.Effects) Then
               me.Effects.Assign(pValue.Effects)
            End If
            If Assigned(pValue.Sort) Then
               me.Sort.Assign(pValue.Sort)
            End If
            me.DefaultValue = pValue.DefaultValue
            me.OnGetDefault = pValue.OnGetDefault
            me.Drawer = pValue.Drawer
         End If
      End Sub
      Overrides Function Clone() As TGridColOptions
         Clone = New TGridColOptions(me)
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Layout", me.Layout.ToString())
            .Prop("Interaction", me.Interaction.ToString())
            .Prop("Color", me.Color.ToString())
            .Prop("Search", me.Search.ToString())
            .Prop("Combo", me.Combo.ToString())
            .Prop("Image", me.Image.ToString())
            .Prop("Format", me.Format.ToString())
            .Prop("Checkbox", me.Checkbox.ToString())
            .Prop("System", me.System.ToString())
            .Prop("Effects", me.Effects.ToString())
            .Prop("Sort", me.Sort.ToString())
            If Not IsEmpty(me.DefaultValue) Then
               .Prop("DefaultValue", CStr(me.DefaultValue))
            End If
            .Prop("HasOnGetDefault", me.OnGetDefault <> Null)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
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
         If Assigned(me.Search) Then
            me.Search.Free()
            me.Search = Null
         End If
         If Assigned(me.Combo) Then
            me.Combo.Free()
            me.Combo = Null
         End If
         If Assigned(me.Image) Then
            me.Image.Free()
            me.Image = Null
         End If
         If Assigned(me.Format) Then
            me.Format.Free()
            me.Format = Null
         End If
         If Assigned(me.Checkbox) Then
            me.Checkbox.Free()
            me.Checkbox = Null
         End If
         If Assigned(me.System) Then
            me.System.Free()
            me.System = Null
         End If
         If Assigned(me.Effects) Then
            me.Effects.Free()
            me.Effects = Null
         End If
         If Assigned(me.Sort) Then
            me.Sort.Free()
            me.Sort = Null
         End If
         me.Drawer = Null
         me.OnGetDefault = Null
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TGridCol
      Inherits TTMatrixCol<Variant>
      Caption As String
      Kind As TGridColumnKind
      Options As TGridColOptions
      Factory As TGridEditorFactory
      Private _font As TFont
      Private _hasAlignment As Boolean = False
      Private _alignment As TAlignment
      Private _validators[] As TGridCellValidator
      Private _sideEffects[] As TGridSideEffect
      Sub New(pCaption As String, pId As String, pKind As TGridColumnKind)
         MyBase.New(pId)
         me.Caption = pCaption
         me.Kind = pKind
         me.Options = New TGridColOptions()
         me._validators = []
         me._sideEffects = []
         If Assigned(pKind) Then
            If pKind = TGridColumnKind.Number() Then
               me.Options.Sort.Numeric = True
            End If
            If pKind = TGridColumnKind.Value() Then
               me.Options.Sort.Numeric = True
            End If
            If pKind = TGridColumnKind.Image() Then
               me.Options.Interaction.OnlyRead = True
            End If
         End If
      End Sub
      Sub New(pColumn As TGridCol)
         MyBase.New(pColumn.ID)
         me._validators = []
         me._sideEffects = []
         me.Options = New TGridColOptions()
         me.Assign(pColumn)
      End Sub
      Sub Assign(pColumn As TGridCol)
         If Assigned(pColumn) Then
            me.Caption = pColumn.Caption
            me.Kind = pColumn.Kind
            me.Factory = pColumn.Factory
            If Assigned(pColumn.Options) Then
               me.Options.Assign(pColumn.Options)
            End If
            If Assigned(me._validators) Then
               me._validators.Free()
            End If
            If Assigned(me._sideEffects) Then
               me._sideEffects.Free()
            End If
            If Assigned(pColumn._validators) Then
               me._validators = pColumn._validators.Clone()
            Else
               me._validators = []
            End If
            If Assigned(pColumn._sideEffects) Then
               me._sideEffects = pColumn._sideEffects.Clone()
            Else
               me._sideEffects = []
            End If
            If pColumn.HasFont() Then
               me._copyFont(me.Font, pColumn.Font)
            ElseIf Assigned(me._font) Then
               ' data7:disable-next-line unknown-member
               me._font.Free()
               me._font = Null
            End If
            If pColumn.HasAlignment() Then
               me._alignment = pColumn.Alignment
               me._hasAlignment = True
            Else
               me._hasAlignment = False
            End If
         End If
      End Sub
      Overrides Function Clone() As TTObject
         Clone = New TGridCol(me)
      End Function
      Shared Function AsText(pCaption As String, pId As String) As TGridCol
         AsText = New TGridCol(pCaption, pId, TGridColumnKind.Text())
      End Function
      Shared Function AsDate(pCaption As String, pId As String) As TGridCol
         AsDate = New TGridCol(pCaption, pId, TGridColumnKind.Date())
      End Function
      Shared Function AsValue(pCaption As String, pId As String) As TGridCol
         AsValue = New TGridCol(pCaption, pId, TGridColumnKind.Value())
      End Function
      Shared Function AsNumber(pCaption As String, pId As String) As TGridCol
         AsNumber = New TGridCol(pCaption, pId, TGridColumnKind.Number())
      End Function
      Shared Function AsMask(pCaption As String, pId As String) As TGridCol
         AsMask = New TGridCol(pCaption, pId, TGridColumnKind.Mask())
      End Function
      Shared Function AsSearch(pCaption As String, pId As String) As TGridCol
         AsSearch = New TGridCol(pCaption, pId, TGridColumnKind.Search())
      End Function
      Shared Function AsCombo(pCaption As String, pId As String) As TGridCol
         AsCombo = New TGridCol(pCaption, pId, TGridColumnKind.Combo())
      End Function
      Shared Function AsImage(pCaption As String, pId As String) As TGridCol
         Dim def As New TGridCol(pCaption, pId, TGridColumnKind.Image())
         def.Options.Interaction.OnlyRead = True
         def.Options.Layout.Width = 36
         AsImage = def
      End Function
      Shared Function AsReadOnly(pCaption As String, pId As String) As TGridCol
         Dim def As New TGridCol(pCaption, pId, TGridColumnKind.OnlyRead())
         def.Options.Interaction.OnlyRead = True
         AsReadOnly = def
      End Function
      Shared Function AsCheckbox(pCaption As String, pId As String) As TGridCol
         Dim def As New TGridCol(pCaption, pId, TGridColumnKind.Checkbox())
         def.Options.Layout.Width = 30
         AsCheckbox = def
      End Function
      Shared Function AsSelection() As TGridCol
         Dim def As TGridCol = TGridCol.AsCheckbox("", "_selection")
         def.Options.System.IsSelection = True
         def.Options.Interaction.CanMove = False
         AsSelection = def
      End Function
      Shared Function AsItemNumber() As TGridCol
         Dim def As TGridCol = TGridCol.AsReadOnly("Item", "_item")
         def.Options.System.IsRowNumber = True
         def.Options.Layout.Width = 50
         def.Options.Sort.Numeric = True
         def.Options.Interaction.CanMove = False
         AsItemNumber = def
      End Function
      Function SetWidth(pWidth As Integer) As TGridCol
         me.Options.Layout.Width = pWidth
         SetWidth = me
      End Function
      Function SetDefault(pValue As Variant) As TGridCol
         me.Options.DefaultValue = pValue
         SetDefault = me
      End Function
      Function SetOnGetDefault(pHandler As TGridDefaultValueDel) As TGridCol
         me.Options.OnGetDefault = pHandler
         SetOnGetDefault = me
      End Function
      Function SetAlignment(pValue As TAlignment) As TGridCol
         me.Alignment = pValue
         SetAlignment = me
      End Function
      Function HasDefault() As Boolean
         Dim _has As Boolean = False
         If Assigned(me.Options) Then
            If me.Options.OnGetDefault <> Null Then
               _has = True
            ElseIf Not IsEmpty(me.Options.DefaultValue) Then
               _has = True
            End If
         End If
         HasDefault = _has
      End Function
      Function ResolveDefault(pRow As TGridRow) As Variant
         Dim _value As Variant
         If Assigned(me.Options) Then
            If me.Options.OnGetDefault <> Null Then
               _value = me.Options.OnGetDefault(pRow, me)
            End If
            If IsEmpty(_value) Then
               _value = me.Options.DefaultValue
            End If
         End If
         ResolveDefault = _value
      End Function
      Property Font As TFont
         Get
            If Not Assigned(me._font) Then
               me._font = New TFont()
            End If
            Font = me._font
         End Get
         Set(pValue As TFont)
            me._font = pValue
         End Set
      End Property
      Function HasFont() As Boolean
         HasFont = Assigned(me._font)
      End Function
      Property Alignment As TAlignment
         Get
            Alignment = me._alignment
         End Get
         Set(pValue As TAlignment)
            me._alignment = pValue
            me._hasAlignment = True
         End Set
      End Property
      Function HasAlignment() As Boolean
         HasAlignment = me._hasAlignment
      End Function
      Shared Sub ApplyFont(pTarget As TFont, pSource As TFont)
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
      Private Sub _copyFont(pTarget As TFont, pSource As TFont)
         TGridCol.ApplyFont(pTarget, pSource)
      End Sub
      Function SetNumericSort() As TGridCol
         me.Options.Sort.Numeric = True
         SetNumericSort = me
      End Function
      Function AddComboOption(pKey As String, pValue As String) As TGridCol
         me.Options.Combo.Add(pKey, pValue)
         AddComboOption = me
      End Function
      Function AddImage(pKey As String, pBase64 As String) As TGridCol
         me.Options.Image.Add(pKey, pBase64)
         AddImage = me
      End Function
      Function AsRowNumber() As TGridCol
         me.Options.System.IsRowNumber = True
         me.Options.Interaction.OnlyRead = True
         me.Options.Sort.Numeric = True
         me.Options.Interaction.CanMove = False
         AsRowNumber = me
      End Function
      Sub SetDrawer(pDrawer As TGridCellDrawer)
         me.Options.Drawer = pDrawer
      End Sub
      Sub AddValidator(ByRef pValidator As TGridCellValidator)
         If pValidator <> Null Then
            me._validators.Push(pValidator)
         End If
      End Sub
      Sub AddSideEffect(ByRef pEffect As TGridSideEffect)
         If pEffect <> Null Then
            me._sideEffects.Push(pEffect)
         End If
      End Sub
      Sub SetRequired()
         me.Options.Interaction.Required = True
         me.AddValidator(TGridValidators.Required)
      End Sub
      Sub SetCascadeClear(pColumnId As String)
         me.Options.Effects.CascadeClearColumnId = pColumnId
         me.AddSideEffect(mod_grid_effects_builtin.TGridEffects.CascadeClear)
      End Sub
      Function IsEditable(pRow As TGridRow) As Boolean
         If me.Kind = TGridColumnKind.Image() Then
            IsEditable = False
         ElseIf Assigned(pRow) AndAlso Not pRow.Editable Then
            IsEditable = False
         ElseIf me.Kind = TGridColumnKind.Checkbox() Then
            IsEditable = False
         ElseIf me.Options.Interaction.OnlyRead Then
            IsEditable = False
         ElseIf me.Kind = TGridColumnKind.OnlyRead() Then
            IsEditable = False
         ElseIf me.Options.System.IsRowNumber Then
            IsEditable = False
         ElseIf me.Options.Interaction.CanEdit <> Null Then
            If Assigned(pRow) Then
               IsEditable = me.Options.Interaction.CanEdit(pRow, me)
            Else
               IsEditable = False
            End If
         Else
            IsEditable = True
         End If
      End Function
      Function Validate(pRow As Integer, pCol As Integer, pValue As String, ByRef pMessage As String) As Boolean
         Dim _ok As Boolean = True
         Dim i As Integer
         For i = 0 To me._validators.Length - 1
            If _ok Then
               Dim _handler As TGridCellValidator = me._validators.GetItem(i)
               If _handler <> Null Then
                  If Not _handler(pRow, pCol, pValue, pMessage) Then
                     _ok = False
                  End If
               End If
            End If
         Next
         Validate = _ok
      End Function
      Sub ApplySideEffects(pData As TObject, pRow As TGridRow, ByRef pValue As Variant, ByRef pValid As Boolean, pNative As Grid)
         Dim i As Integer
         For i = 0 To me._sideEffects.Length - 1
            Dim _handler As TGridSideEffect = me._sideEffects.GetItem(i)
            If _handler <> Null Then
               _handler(pData, pRow, me, pValue, pValid, pNative)
            End If
         Next
      End Sub
      Function ValidatorCount() As Integer
         ValidatorCount = me._validators.Length
      End Function
      Function SideEffectCount() As Integer
         SideEffectCount = me._sideEffects.Length
      End Function

      Function SortKey(pValue As Variant) As String
         If IsEmpty(pValue) Then
            SortKey = ""
         ElseIf Not me.Options.Sort.Numeric Then
            SortKey = CStr(pValue)
         Else
            SortKey = me._numericSortKey(CStr(pValue))
         End If
      End Function
      Private Function _numericSortKey(pRaw As String) As String
         Dim t As String = Trim(pRaw)
         If t = "" Then
            _numericSortKey = ""
         Else
            Dim neg As Boolean = False
            Dim first As String = Left(t, 1)
            If first = "-" Then
               neg = True
               t = Mid(t, 2)
            Else
               If first = "+" Then
                  t = Mid(t, 2)
               End If
            End If
            Dim decSep As String = me._decimalSeparator(t)
            Dim intDigits As String = ""
            Dim fracDigits As String = ""
            Dim inFrac As Boolean = False
            Dim i As Integer
            For i = 1 To Len(t)
               Dim ch As String = Mid(t, i, 1)
               If InStr("0123456789", ch) > 0 Then
                  If inFrac Then
                     fracDigits = fracDigits + ch
                  Else
                     intDigits = intDigits + ch
                  End If
               Else
                  If ch = decSep Then
                     If Not inFrac Then
                        inFrac = True
                     End If
                  End If
               End If
            Next
            If intDigits = "" AndAlso fracDigits = "" Then
               _numericSortKey = ""
            Else
               If intDigits = "" Then
                  intDigits = "0"
               End If
               Dim intKey As String = intDigits
               While Len(intKey) < 18
                  intKey = "0" + intKey
               End While
               Dim fracKey As String = fracDigits
               While Len(fracKey) < 6
                  fracKey = fracKey + "0"
               End While
               If Len(fracKey) > 6 Then
                  fracKey = Left(fracKey, 6)
               End If
               Dim digits As String = intKey + fracKey
               If neg Then
                  _numericSortKey = "0" + me._nineComplement(digits)
               Else
                  _numericSortKey = "1" + digits
               End If
            End If
         End If
      End Function
      Private Function _decimalSeparator(pText As String) As String
         Dim lastComma As Integer = InStrRev(pText, ",")
         Dim lastDot As Integer = InStrRev(pText, ".")
         If lastComma > lastDot Then
            _decimalSeparator = ","
         Else
            _decimalSeparator = "."
         End If
      End Function
      Private Function _nineComplement(pDigits As String) As String
         Dim out As String = ""
         Dim i As Integer
         For i = 1 To Len(pDigits)
            Dim d As Integer = CInt(Mid(pDigits, i, 1))
            out = out + CStr(9 - d)
         Next
         _nineComplement = out
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("ID", me.ID)
            .Prop("Caption", me.Caption)
            .Prop("Kind", me.Kind)
            .Prop("Index", me.Index)
            .Prop("Options", me.Options.ToString())
            .Prop("HasFont", me.HasFont())
            .Prop("HasAlignment", me.HasAlignment())
            .Prop("ValidatorCount", me.ValidatorCount())
            .Prop("SideEffectCount", me.SideEffectCount())
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me._font) Then
         ' data7:disable-next-line unknown-member
            me._font.Free()
            me._font = Null
         End If
         If Assigned(me.Options) Then
            me.Options.Free()
            me.Options = Null
         End If
         If Assigned(me._validators) Then
            me._validators.Free()
            me._validators = Null
         End If
         If Assigned(me._sideEffects) Then
            me._sideEffects.Free()
            me._sideEffects = Null
         End If
         me.Factory = Null
         MyBase.Dispose()
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
