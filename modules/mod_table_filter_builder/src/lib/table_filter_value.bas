Imports Forms
Imports mod_tlist
Imports mod_tobject
Imports table_filter_field
Imports table_filter_ops

Namespace table_filter_value

   Class TFilterValueHost
      Inherits TTObject

      Private _root As PageControl
      Private _inputSlot As PageControl
      Private _secondSlot As PageControl
      Private _rangeSep As StaticText
      Private _listGrid As Grid
      Private _sqlSlot As PageControl
      Private _editor As TWinControl
      Private _editor2 As TWinControl
      Private _sqlEditor As MemoTextBox
      Private _kind As String
      Private _field As TFilterField
      Private _condition As String
      Private _listValues[] As String = []
      Private _fontSize As Integer = 8
      Private _rowHeight As Integer = 15
      Private _editorHeight As Integer = 22
      Private _rangeValuesVertical As Boolean

      Sub New(pParent As TWinControl, pRangeValuesVertical As Boolean = True)
         MyBase.New()
         me._kind = "text"
         me._condition = "EQ"
         me._rangeValuesVertical = pRangeValuesVertical
         me._listValues = []
         me._root = me._panel(pParent, alClient, 0, 0)
         me._sqlSlot = me._panel(me._root, alClient, 0, 0)
         me._sqlSlot.Visible = False
         me._listGrid = New Grid(me._root)
         me._listGrid.TabStop = False
         me._listGrid.Align = alClient
         me._listGrid.AlignWithMargins = True
         me._listGrid.Margins.Left = 1
         me._listGrid.Margins.Top = 0
         me._listGrid.Margins.Right = 1
         me._listGrid.Margins.Bottom = 0
         me._listGrid.FixedCols = 0
         me._listGrid.FixedRows = 0
         me._listGrid.ColCount = 1
         me._listGrid.RowCount = 1
         me._listGrid.AutoSize = False
         me._listGrid.EditorMode = False
         me._listGrid.GridLineWidth = 0
         me._listGrid.GridOptions.RowSelect = True
         me._listGrid.GridOptions.HorzLine = False
         me._listGrid.MinRowHeight = me._rowHeight
         me._listGrid.DefaultRowHeight = me._rowHeight
         me._listGrid.ScrollBars = ssNone
         me._listGrid.IntelliZoom = False
         me._listGrid.OnCanEditCell = me._onCanEditList
         me._listGrid.OnResize = me._onListGridResize
         me._listGrid.Visible = False
         me._applyListRowHeights()
         me._secondSlot = me._panel(me._root, alTop, 0, me._editorHeight)
         me._secondSlot.Visible = False
         me._rangeSep = New StaticText(me._root)
         me._rangeSep.AutoSize = False
         me._rangeSep.Caption = "e"
         me._rangeSep.Alignment = taCenter
         me._rangeSep.Align = alNone
         me._rangeSep.Visible = False
         me._inputSlot = me._panel(me._root, alTop, 0, me._editorHeight)
      End Sub

      Property Root As PageControl
         Get
            Root = me._root
         End Get
      End Property

      Function IsList() As Boolean
         IsList = TFilterOps.IsList(me._condition)
      End Function

      Function IsRange() As Boolean
         IsRange = TFilterOps.IsRange(me._condition)
      End Function

      Function IsSql() As Boolean
         IsSql = TFilterOps.IsSql(me._condition)
      End Function

      Sub Rebuild(pField As TFilterField, pCondition As String)
         me._field = pField
         me._condition = UCase(Trim(pCondition))
         If me._condition = "" Then
            me._condition = "EQ"
         End If
         me._clearEditors()
         me._listValues.Clean()
         If TFilterOps.IsSql(me._condition) Then
            me._showSql()
         ElseIf TFilterOps.IsEmpty(me._condition) Then
            me._showNone()
         ElseIf TFilterOps.IsRange(me._condition) Then
            me._showRange()
         ElseIf TFilterOps.IsList(me._condition) Then
            me._showList()
         Else
            me._showSingle()
         End If
         me._syncList()
      End Sub

      Function ReadValues() As TTList<String>
         Dim values[] As String = []
         If TFilterOps.IsEmpty(me._condition) Then
            ReadValues = values
            Exit Function
         End If
         If TFilterOps.IsSql(me._condition) Then
            Dim sqlText As String = ""
            If Assigned(me._sqlEditor) Then
               sqlText = Trim(me._sqlEditor.Lines.Text)
            End If
            If sqlText <> "" Then
               values.Push(sqlText)
            End If
         ElseIf TFilterOps.IsList(me._condition) Then
            Dim i As Integer
            Dim last As Integer = me._listValues.Length - 1
            For i = 0 To last
               Dim item As String = Trim(me._listValues.Take(i))
               values.Push(item)
            Next
            If values.Length = 0 Then
               values.Push(me._readEditor(me._editor))
            End If
         ElseIf TFilterOps.IsRange(me._condition) Then
            values.Push(me._readEditor(me._editor))
            values.Push(me._readEditor(me._editor2))
         Else
            values.Push(me._readEditor(me._editor))
         End If
         ReadValues = values
      End Function

      Function ReadDisplay() As String
         Dim values[] As String = me.ReadValues()
         Dim text As String = ""
         If TFilterOps.IsEmpty(me._condition) Then
            text = ""
         ElseIf TFilterOps.IsSql(me._condition) Then
            If values.Length > 0 Then
               text = values.Take(0)
            End If
         ElseIf TFilterOps.IsRange(me._condition) Then
            If values.Length >= 2 Then
               text = values.Take(0) & " e " & values.Take(1)
            End If
         ElseIf TFilterOps.IsList(me._condition) Then
            text = values.Join(", ")
         ElseIf values.Length > 0 Then
            text = me._readDisplay(me._editor, values.Take(0))
            If text = "" Then
               text = "''"
            End If
         End If
         values.Free()
         ReadDisplay = text
      End Function

      Function InsertCurrent() As Boolean
         If Not TFilterOps.IsList(me._condition) Then
            InsertCurrent = False
            Exit Function
         End If
         Dim current As String = me._readEditor(me._editor)
         me._listValues.Push(current)
         me._syncList()
         me._clearInput()
         InsertCurrent = True
      End Function

      Function RemoveSelected() As Boolean
         If Not TFilterOps.IsList(me._condition) Then
            RemoveSelected = False
            Exit Function
         End If
         Dim idx As Integer = me._listGrid.Row
         If (idx < 0) Or (idx >= me._listValues.Length) Then
            RemoveSelected = False
            Exit Function
         End If
         me._listValues.Delete(idx)
         me._syncList()
         RemoveSelected = True
      End Function

      Sub ClearInput()
         me._clearInput()
         me._listValues.Clean()
         me._syncList()
      End Sub

      Private Sub _showSingle()
         me._inputSlot.Visible = True
         me._secondSlot.Visible = False
         me._listGrid.Visible = False
         me._sqlSlot.Visible = False
         me._applySlotLayout()
         me._editor = me._createEditor(me._inputSlot, me._field, me._condition)
      End Sub

      Private Sub _showRange()
         me._inputSlot.Visible = True
         me._secondSlot.Visible = True
         me._listGrid.Visible = False
         me._sqlSlot.Visible = False
         me._applySlotLayout()
         me._editor = me._createEditor(me._inputSlot, me._field, me._condition)
         me._editor2 = me._createEditor(me._secondSlot, me._field, me._condition)
      End Sub

      Private Sub _showList()
         me._inputSlot.Visible = True
         me._secondSlot.Visible = False
         me._listGrid.Visible = True
         me._sqlSlot.Visible = False
         me._applySlotLayout()
         me._editor = me._createEditor(me._inputSlot, me._field, me._condition)
         me._fitListColumn()
         me._applyListRowHeights()
      End Sub

      Private Sub _showSql()
         me._inputSlot.Visible = False
         me._secondSlot.Visible = False
         me._listGrid.Visible = False
         me._sqlSlot.Visible = True
         me._sqlEditor = New MemoTextBox(me._sqlSlot)
         me._sqlEditor.Align = alClient
         me._kind = "memo"
      End Sub

      Private Sub _showNone()
         me._inputSlot.Visible = False
         me._secondSlot.Visible = False
         me._listGrid.Visible = False
         me._sqlSlot.Visible = False
         me._rangeSep.Visible = False
         me._rangeSep.Align = alNone
      End Sub

      Private Function _createEditor(pParent As TWinControl, pField As TFilterField, pCondition As String) As TWinControl
         Dim kind As String = "text"
         If Assigned(pField) Then
            kind = pField.Kind()
         End If
         If TFilterOps.IsLike(pCondition) Or TFilterOps.IsSql(pCondition) Then
            kind = "text"
         End If
         me._kind = kind
         Dim _align As TAlign = alClient
         Dim editor As TWinControl
         If kind = "search" Then
            Dim searchEd As New SearchTextBox(pParent)
            If Assigned(pField) Then
               searchEd.CodPesquisa = pField.CodPesquisa
            End If
            searchEd.EditorDescricao = New MemoTextBox(pParent)
            _align = alLeft
            searchEd.EditorDescricao.Align = alClient
            editor = searchEd
         ElseIf kind = "combo" Then
            Dim comboEd As New HComboBox(pParent)
            If Assigned(pField) Then
               comboEd.ListaOpcoes = pField.ListaOpcoes
            End If
            editor = comboEd
         ElseIf kind = "date" Then
            editor = New DateTextBox(pParent)
         ElseIf kind = "datetime" Then
            editor = New DateTextBox(pParent)
         ElseIf kind = "time" Then
            editor = New TextBox(pParent)
         ElseIf kind = "check" Then
            Dim chk As New CheckBox(pParent)
            chk.Checked = False
            editor = chk
         ElseIf kind = "integer" Then
            Dim intEd As New ValueTextBox(pParent)
            intEd.DecimalPlaces = 0
            editor = intEd
         ElseIf kind = "number" Then
            Dim valueEd As New ValueTextBox(pParent)
            If Assigned(pField) Then
               If pField.DecimalPlaces > 0 Then
                  valueEd.DecimalPlaces = pField.DecimalPlaces
               Else
                  valueEd.DecimalPlaces = 2
               End If
            Else
               valueEd.DecimalPlaces = 2
            End If
            editor = valueEd
         ElseIf kind = "memo" Then
            editor = New MemoTextBox(pParent)
         Else
            editor = New TextBox(pParent)
         End If
         editor.Align = _align
         editor.Height = me._editorHeight
         _createEditor = editor
      End Function

      Private Function _panel(pParent As TWinControl, pAlign As TAlign, pWidth As Integer, pHeight As Integer) As PageControl
         Dim pnl As New PageControl(pParent)
         pnl.Align = pAlign
         pnl.ShowCardFrame = False
         pnl.ShowShadow = False
         pnl.TabStop = False
         If pWidth > 0 Then
            pnl.Width = pWidth
         End If
         If pHeight > 0 Then
            pnl.Height = pHeight
         End If
         _panel = pnl
      End Function

      Private Function _readEditor(pEditor As TWinControl) As String
         If Not Assigned(pEditor) Then
            _readEditor = ""
            Exit Function
         End If
         If TypeOf(pEditor) Is SearchTextBox Then
            Dim searchEd As SearchTextBox = CType(pEditor, SearchTextBox)
            _readEditor = Trim(searchEd.AsString)
         ElseIf TypeOf(pEditor) Is HComboBox Then
            Dim comboEd As HComboBox = CType(pEditor, HComboBox)
            _readEditor = Trim(comboEd.ValueSelect)
         ElseIf TypeOf(pEditor) Is DateTextBox Then
            Dim dateEd As DateTextBox = CType(pEditor, DateTextBox)
            If dateEd.AsDate = 0 Then
               _readEditor = ""
            Else
               _readEditor = Trim(CStr(dateEd.AsDate))
            End If
         ElseIf TypeOf(pEditor) Is ValueTextBox Then
            Dim valueEd As ValueTextBox = CType(pEditor, ValueTextBox)
            _readEditor = Trim(CStr(valueEd.Value))
         ElseIf TypeOf(pEditor) Is MemoTextBox Then
            Dim memoEd As MemoTextBox = CType(pEditor, MemoTextBox)
            _readEditor = Trim(memoEd.Lines.Text)
         ElseIf TypeOf(pEditor) Is CheckBox Then
            Dim chk As CheckBox = CType(pEditor, CheckBox)
            If chk.Checked Then
               _readEditor = "1"
            Else
               _readEditor = "0"
            End If
         ElseIf TypeOf(pEditor) Is TextBox Then
            Dim textEd As TextBox = CType(pEditor, TextBox)
            _readEditor = Trim(textEd.Text)
         Else
            _readEditor = ""
         End If
      End Function

      Private Function _readDisplay(pEditor As TWinControl, pRaw As String) As String
         If Assigned(pEditor) Then
            If TypeOf(pEditor) Is HComboBox Then
               Dim comboEd As HComboBox = CType(pEditor, HComboBox)
               Dim caption As String = ""
               If comboEd.SelectedItem >= 0 Then
                  caption = Trim(comboEd.Items.Strings(comboEd.SelectedItem))
               End If
               If (caption <> "") And (caption <> pRaw) Then
                  _readDisplay = pRaw & " " & caption
                  Exit Function
               End If
            End If
         End If
         _readDisplay = pRaw
      End Function

      Private Sub _clearInput()
         me._clearControl(me._editor)
         me._clearControl(me._editor2)
         If Assigned(me._sqlEditor) Then
            me._sqlEditor.Lines.Text = ""
         End If
      End Sub

      Private Sub _clearControl(pEditor As TWinControl)
         If Not Assigned(pEditor) Then
            Exit Sub
         End If
         If TypeOf(pEditor) Is SearchTextBox Then
            Dim searchEd As SearchTextBox = CType(pEditor, SearchTextBox)
            searchEd.AsString = ""
         ElseIf TypeOf(pEditor) Is HComboBox Then
            Dim comboEd As HComboBox = CType(pEditor, HComboBox)
            comboEd.ValueSelect = ""
         ElseIf TypeOf(pEditor) Is DateTextBox Then
            Dim dateEd As DateTextBox = CType(pEditor, DateTextBox)
            dateEd.AsDate = 0
         ElseIf TypeOf(pEditor) Is ValueTextBox Then
            Dim valueEd As ValueTextBox = CType(pEditor, ValueTextBox)
            valueEd.Value = 0
         ElseIf TypeOf(pEditor) Is MemoTextBox Then
            Dim memoEd As MemoTextBox = CType(pEditor, MemoTextBox)
            memoEd.Lines.Text = ""
         ElseIf TypeOf(pEditor) Is CheckBox Then
            Dim chk As CheckBox = CType(pEditor, CheckBox)
            chk.Checked = False
         ElseIf TypeOf(pEditor) Is TextBox Then
            Dim textEd As TextBox = CType(pEditor, TextBox)
            textEd.Text = ""
         End If
      End Sub

      Private Sub _onCanEditList(pSender As TObject, pRow As Integer, pCol As Integer, ByRef pCanEdit As Boolean)
         pCanEdit = False
      End Sub

      Private Sub _applySlotLayout()
         If TFilterOps.IsRange(me._condition) Then
            me._rangeSep.Caption = "e"
            me._rangeSep.Alignment = taCenter
            me._rangeSep.Visible = True
            If Not me._rangeValuesVertical Then
               me._secondSlot.Align = alClient
               me._secondSlot.AlignWithMargins = False
               me._rangeSep.Align = alLeft
               me._rangeSep.Width = 16
               me._rangeSep.Height = me._editorHeight
               me._inputSlot.Align = alLeft
               me._inputSlot.Height = me._editorHeight
               me._inputSlot.AlignWithMargins = False
               me._fitRangeColumns()
            Else
               me._secondSlot.Align = alTop
               me._secondSlot.Height = me._editorHeight
               me._secondSlot.AlignWithMargins = False
               me._rangeSep.Align = alTop
               me._rangeSep.Height = 13
               me._inputSlot.Align = alTop
               me._inputSlot.Height = me._editorHeight
               me._inputSlot.AlignWithMargins = False
            End If
         Else
            me._rangeSep.Visible = False
            me._rangeSep.Align = alNone
            me._inputSlot.Align = alTop
            me._inputSlot.Height = me._editorHeight
            me._inputSlot.AlignWithMargins = False
            me._secondSlot.Align = alTop
            me._secondSlot.Height = me._editorHeight
            me._secondSlot.AlignWithMargins = False
         End If
      End Sub

      Private Sub _fitRangeColumns()
         If Not Assigned(me._root) Then
            Exit Sub
         End If
         If Not Assigned(me._inputSlot) Then
            Exit Sub
         End If
         Dim total As Integer = me._root.ClientWidth
         If total < 1 Then
            total = me._root.Width
         End If
         If total < 8 Then
            me._inputSlot.Width = 120
         Else
            me._inputSlot.Width = Int((total - 16) / 2)
         End If
      End Sub

      Private Sub _onListGridResize(pSender As TObject)
         me._fitListColumn()
      End Sub

      Private Sub _fitListColumn()
         If Not Assigned(me._listGrid) Then
            Exit Sub
         End If
         Dim total As Integer = me._listGrid.ClientWidth
         If total < 1 Then
            total = me._listGrid.Width
         End If
         If total < 1 Then
            Exit Sub
         End If
         me._listGrid.ColWidth(0) = total
      End Sub

      Private Sub _applyListRowHeights()
         If Not Assigned(me._listGrid) Then
            Exit Sub
         End If
         Dim last As Integer = me._listGrid.RowCount - 1
         Dim i As Integer
         For i = 0 To last
            me._listGrid.RowHeight(i) = me._rowHeight
            me._listGrid.FontSize(0, i) = me._fontSize
         Next
      End Sub

      Private Sub _syncList()
         If me._listValues.Length = 0 Then
            me._listGrid.RowCount = 1
            me._listGrid.Cells(0, 0) = ""
            me._listGrid.FontSize(0, 0) = me._fontSize
         Else
            me._listGrid.RowCount = me._listValues.Length
            Dim i As Integer
            Dim last As Integer = me._listValues.Length - 1
            For i = 0 To last
               me._listGrid.Cells(0, i) = me._listValues.Take(i)
               me._listGrid.FontSize(0, i) = me._fontSize
            Next
         End If
         me._applyListRowHeights()
      End Sub

      Private Sub _clearEditors()
         me._freeEditor(me._editor)
         me._freeEditor(me._editor2)
         If Assigned(me._sqlEditor) Then
            me._sqlEditor.Free()
            me._sqlEditor = Null
         End If
      End Sub

      Private Sub _freeEditor(ByRef pEditor As TWinControl)
         If Assigned(pEditor) Then
            pEditor.Free()
            pEditor = Null
         End If
      End Sub

      Overrides Sub Dispose()
         me._clearEditors()
         If Assigned(me._listValues) Then
            me._listValues.Free()
            me._listValues = Null
         End If
         me._field = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
