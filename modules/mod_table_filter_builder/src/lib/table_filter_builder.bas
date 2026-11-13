Imports Forms
Imports mod_tlist
Imports mod_tobject
Imports table_filter_field
Imports table_filter_item
Imports table_filter_json
Imports table_filter_ops
Imports table_filter_sql
Imports table_filter_table
Imports table_filter_value
Imports TDialogs
Imports TDirectory
Imports TFile


' Imports ambient
' Imports mod_campo
' Imports mod_configurador
' Function FromDefinicao() As TFilterTable
'    Dim CodTabela As Integer
'    Dim NomeTabela As String
'    Dim CodigoProcessoTabela As Integer
'    Dim TituloProcessoTabela As String
'    Dim Where As String
'    Dim CodEmpresa As Integer
'    Dim CodFilial As Integer
'    Dim CodUsuario As Integer
'    Dim SchemaTabela As String
'    Dim EstacaoTrabalho As String
'    Dim UsuarioWindows As String
'    If CodEmpresa = 0 Then
'       CodEmpresa = Data7.CodEmpresa()
'    End If
'    If CodFilial = 0 Then
'       CodFilial = Data7.CodFilial()
'    End If
'    If CodUsuario = 0 Then
'       CodUsuario = Data7.CodUsuario()
'    End If
'    If EstacaoTrabalho = "" Then
'       EstacaoTrabalho = Environment.MachineName()
'    End If
'    If UsuarioWindows = "" Then
'       UsuarioWindows = Environment.UserName()
'    End If
'    If Ambient.DevMode() Then
'       CodTabela = 6
'    End If
'    Ambient.EnableCache()
'    Ambient.Initialize(CodEmpresa, CodFilial, CodUsuario, CodTabela, EstacaoTrabalho, UsuarioWindows, SchemaTabela, NomeTabela, CodigoProcessoTabela, TituloProcessoTabela, Where)
'    Dim pTabela As Tabela = Ambient.Tabela()
'    Dim filterTable As New TFilterTable()
'    If Assigned(pTabela) Then
'       filterTable.Schema = pTabela.NomeSchema
'       filterTable.Nome = pTabela.Nome
'       Dim i As Integer
'       Dim last As Integer = pTabela.Campos.Length - 1
'       For i = 0 To last
'          Dim source As Campo = pTabela.Campos.Take(i)
'          If Trim(source.Nome) <> "" Then
'             filterTable.AddField(source.Nome, source.Titulo, source.Tipo, source.CodPesquisaPadrao, source.ListaOpcao, source.CasasDecimal)
'          End If
'       Next
'    End If
'    FromDefinicao = filterTable
' End Function

Namespace table_filter_builder

   ' Construtor de filtro SQL auto-contido.
   ' Hospeda a UI em qualquer TWinControl e devolve o predicado via ToSql()/ToWhere().
   Class TTableFilterBuilder
      Inherits TTObject

      QualifyWithTable As Boolean
      ActionsVertical As Boolean
      RangeValuesVertical As Boolean
      Private _jsonActionsEnabled As Boolean

      Private _tabela As TFilterTable
      Private _items[] As TFilterItem = []
      Private _seq As Integer

      Private _host As PageControl
      Private _header As PageControl
      Private _actions As PageControl
      Private _fields As PageControl
      Private _valuePanel As PageControl
      Private _gridHost As PageControl
      Private _jsonActions As PageControl

      Private _opEditor As HComboBox
      Private _fieldEditor As HComboBox
      Private _condEditor As HComboBox
      Private _valueHost As TFilterValueHost
      Private _grid As Grid

      Private _btnAdd As CommandButton
      Private _btnClear As CommandButton
      Private _btnDelete As CommandButton
      Private _listButtons As PageControl
      Private _btnInsert As CommandButton
      Private _btnRemove As CommandButton
      Private _btnExport As CommandButton
      Private _btnImport As CommandButton

      Private _updating As Boolean
      Private _fontSize As Integer = 8
      Private _rowHeight As Integer = 16
      Private _editorHeight As Integer = 22
      Private _headerExpanded As Integer = 90
      Private _jsonActionsWidth As Integer = 78

      Sub New(pParent As TWinControl, pTabela As TFilterTable, pActionsVertical As Boolean = True, pRangeValuesVertical As Boolean = True, pJsonActionsEnabled As Boolean = True)
         MyBase.New()
         If Not Assigned(pTabela) Then
            Throw New Exception("TTableFilterBuilder requer um objeto TFilterTable.")
         End If
         me.QualifyWithTable = True
         me.ActionsVertical = pActionsVertical
         me.RangeValuesVertical = pRangeValuesVertical
         me._jsonActionsEnabled = pJsonActionsEnabled
         me._items = []
         me._tabela = pTabela.Clone()
         me._seq = 0
         me._updating = False
         me._build(pParent)
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Property Tabela As TFilterTable
         Get
            Tabela = me._tabela
         End Get
      End Property

      Property JsonActionsEnabled As Boolean
         Get
            JsonActionsEnabled = me._jsonActionsEnabled
         End Get
         Set(pValue As Boolean)
            me._jsonActionsEnabled = pValue
            If Assigned(me._jsonActions) Then
               me._jsonActions.Visible = pValue
            End If
         End Set
      End Property

      Function Count() As Integer
         Count = me._items.Length
      End Function

      Function ItemAt(pIndex As Integer) As TFilterItem
         If (pIndex < 0) Or (pIndex >= me._items.Length) Then
            ItemAt = Null
         Else
            ItemAt = me._items.Take(pIndex)
         End If
      End Function

      Function ToSql() As String
         ToSql = TFilterSql.Build(me._tabela, me._items, me.QualifyWithTable)
      End Function

      Function ToWhere() As String
         ToWhere = TFilterSql.BuildWhere(me._tabela, me._items, me.QualifyWithTable)
      End Function

      Function ToJson() As String
         ToJson = TFilterJson.Build(me._tabela, me._items, me.QualifyWithTable)
      End Function

      Function FromJson(pJson As String) As Boolean
         Dim qualify As Boolean = me.QualifyWithTable
         Dim loaded[] As TFilterItem = []
         Dim ok As Boolean = False
         Try
            ok = TFilterJson.TryLoad(pJson, me._tabela, loaded, qualify)
            If ok Then
               me.QualifyWithTable = qualify
               me._items.Clean()
               me._seq = 0
               Dim i As Integer
               Dim last As Integer = loaded.Length - 1
               For i = 0 To last
                  Dim item As TFilterItem = loaded.Take(i).Clone()
                  me._seq = me._seq + 1
                  item.SetID("f" & CStr(me._seq))
                  me._items.Push(item)
               Next
               me._refreshGrid()
            End If
         Catch ex As Exception
            loaded.Free()
            Throw New Exception(ex.Message)
         End Try
         loaded.Free()
         FromJson = ok
      End Function

      Private Sub _build(pParent As TWinControl)
         me._host = me._panel(pParent, alClient, 0, 0)
         me._buildHeader()
         me._buildGrid()
         me._fillEditors()
         me._bindEvents()
      End Sub

      Private Sub _buildHeader()
         me._header = me._panel(me._host, alTop, 0, me._headerHeightForCondition())
         me._header.AlignWithMargins = True
         me._header.Margins.Left = 4
         me._header.Margins.Top = 4
         me._header.Margins.Right = 4
         me._header.Margins.Bottom = 4
         If me.ActionsVertical Then
            me._actions = me._panel(me._header, alRight, 80, 0)
            me._actions.AlignWithMargins = True
            me._actions.Margins.Left = 0
            me._actions.Margins.Top = 6
            me._actions.Margins.Right = 0
            me._actions.Margins.Bottom = 0
         End If
         Dim body As PageControl = me._panel(me._header, alClient, 0, 0)
         Dim labels As PageControl = me._panel(body, alTop, 0, 13)
         me._label(labels, "Operador", 94)
         me._label(labels, "Campo", 164)
         me._label(labels, "Condição", 184)
         me._label(labels, "Valor do filtro", 160)
         Dim content As PageControl = me._panel(body, alClient, 0, 0)
         content.AlignWithMargins = True
         content.Margins.Left = 0
         content.Margins.Top = 2
         content.Margins.Right = 0
         content.Margins.Bottom = 0
         If Not me.ActionsVertical Then
            me._actions = me._panel(content, alRight, 228, 0)
         End If
         me._fields = me._panel(content, alLeft, 442, 0)
         me._valuePanel = me._panel(content, alClient, 0, 0)
         me._buildFieldEditors()
         me._buildValuePanel()
         me._buildActionButtons()
      End Sub

      Private Sub _buildFieldEditors()
         Dim editors As PageControl = me._panel(me._fields, alTop, 0, me._editorHeight)
         me._opEditor = me._combo(editors, 90, "E=AND".Quoted() & ";" & "OU=OR".Quoted())
         me._fieldEditor = me._combo(editors, 160, "")
         me._condEditor = me._combo(editors, 180, TFilterOps.ListaOpcoes())
         Dim bottom As PageControl = me._panel(me._fields, alClient, 0, 0)
         me._listButtons = me._panel(bottom, alRight, 76, 0)
         me._listButtons.AlignWithMargins = True
         me._listButtons.Margins.Right = 4
         me._btnInsert = me._listButton(me._listButtons, "Inserir")
         me._btnRemove = me._listButton(me._listButtons, "Remover")
         me._listButtons.Visible = False
         Dim leftRest As PageControl = me._panel(bottom, alClient, 0, 0)
         Dim caption As PageControl = me._panel(leftRest, alBottom, 0, 16)
         me._label(caption, "Filtro", 80)
      End Sub

      Private Sub _buildValuePanel()
         me._valueHost = New TFilterValueHost(me._valuePanel, me.RangeValuesVertical)
      End Sub

      Private Sub _buildActionButtons()
         Dim host As TWinControl = me._actions
         Dim btnAlign As TAlign = alTop
         If Not me.ActionsVertical Then
            host = me._panel(me._actions, alTop, 0, me._editorHeight)
            btnAlign = alLeft
         End If
         me._btnAdd = me._button(host, "Adicionar", btnAlign)
         me._btnDelete = me._button(host, "Excluir", btnAlign)
         me._btnClear = me._button(host, "Limpar", btnAlign)
      End Sub

      Private Sub _buildGrid()
         Dim wrap As PageControl = me._panel(me._host, alClient, 0, 0)
         wrap.AlignWithMargins = True
         wrap.Margins.Left = 5
         wrap.Margins.Top = 2
         wrap.Margins.Right = 4
         wrap.Margins.Bottom = 4
         me._buildJsonActions(wrap)
         me._gridHost = me._panel(wrap, alClient, 0, 0)
         me._grid = New Grid(me._gridHost)
         me._grid.TabStop = False
         me._grid.Align = alClient
         me._grid.FixedCols = 0
         me._grid.FixedRows = 1
         me._grid.ColCount = 4
         me._grid.RowCount = 2
         me._grid.AutoSize = False
         me._grid.Cells(0, 0) = "Operador"
         me._grid.Cells(1, 0) = "Campo"
         me._grid.Cells(2, 0) = "Condição"
         me._grid.Cells(3, 0) = "Valor do filtro"
         me._grid.EditorMode = False
         me._grid.GridLineWidth = 0
         me._grid.GridOptions.RowSelect = True
         me._grid.HoverRow = True
         me._grid.HoverRowColor = rgb(204, 232, 255)
         me._grid.GridOptions.FixedVerLine = False
         me._grid.GridOptions.FixedHorzLine = False
         me._grid.GridOptions.HorzLine = False
         me._grid.GridOptions.VerLine = False
         me._grid.MinRowHeight = me._rowHeight
         me._grid.DefaultRowHeight = me._rowHeight
         me._grid.FixedRowHeight = me._rowHeight
         me._grid.ScrollBars = ssVertical
         me._grid.IntelliZoom = False
         me._applyFilterCellFonts()
         me._grid.OnCanEditCell = me._onCanEditGrid
         me._grid.OnResize = me._onFilterGridResize
         me._fitFilterColumns()
         me._applyFilterRowHeights()
         me._clearDataRow(1)
      End Sub

      Private Sub _fillEditors()
         me._updating = True
         me._fieldEditor.ListaOpcoes = me._tabela.FieldListaOpcoes()
         If me._tabela.Campos.Length > 0 Then
            me._fieldEditor.ValueSelect = me._tabela.Campos.Take(0).Nome
         End If
         me._opEditor.ValueSelect = "AND"
         me._condEditor.ValueSelect = TFilterOps.Equal()
         me._updating = False
         me._rebuildValue()
      End Sub

      Private Sub _bindEvents()
         me._fieldEditor.OnChange = me._onFieldChange
         me._condEditor.OnChange = me._onConditionChange
         me._btnAdd.OnClick = me._onAdd
         me._btnClear.OnClick = me._onClear
         me._btnDelete.OnClick = me._onDelete
         me._btnInsert.OnClick = me._onInsert
         me._btnRemove.OnClick = me._onRemove
         If Assigned(me._btnExport) Then
            me._btnExport.OnClick = me._onExportJson
         End If
         If Assigned(me._btnImport) Then
            me._btnImport.OnClick = me._onImportJson
         End If
      End Sub

      Private Sub _onFieldChange(pSender As TObject)
         If me._updating Then
            Exit Sub
         End If
         me._rebuildValue()
      End Sub

      Private Sub _onConditionChange(pSender As TObject)
         If me._updating Then
            Exit Sub
         End If
         me._rebuildValue()
      End Sub

      Private Sub _onAdd(pSender As TObject)
         Dim field As TFilterField = me._currentField()
         Dim condition As String = Trim(me._condEditor.ValueSelect)
         Dim values[] As String = me._valueHost.ReadValues()
         If Not TFilterOps.IsSql(condition) Then
            If Not Assigned(field) Then
               values.Free()
               Forms.MessageBox.Show("Selecione um campo.")
               Exit Sub
            End If
         End If
         If (Not TFilterOps.IsEmpty(condition)) And (values.Length = 0) Then
            values.Free()
            Forms.MessageBox.Show("Informe o valor do filtro.")
            Exit Sub
         End If
         If TFilterOps.IsRange(condition) And (values.Length < 2) Then
            values.Free()
            Forms.MessageBox.Show("Informe o valor inicial e o valor final.")
            Exit Sub
         End If
         If TFilterOps.AllowsBlankValue(condition) Then
            If me._hasBlankOrZero(values) Then
               If Not Forms.MessageBox.Confirmation("O valor informado está vazio ou é zero." & Char(13) & "Deseja adicionar este filtro mesmo assim?") Then
                  values.Free()
                  Exit Sub
               End If
            End If
         End If
         Dim item As New TFilterItem()
         me._seq = me._seq + 1
         item.SetID("f" & CStr(me._seq))
         item.LogicalOp = Trim(me._opEditor.ValueSelect)
         If item.LogicalOp = "" Then
            item.LogicalOp = "AND"
         End If
         If Assigned(field) Then
            item.FieldName = field.Nome
            item.FieldTitle = field.Titulo
            item.FieldTipo = field.Tipo
            item.FieldKind = field.Kind()
         End If
         item.Condition = condition
         item.ConditionTitle = TFilterOps.TitleOf(condition)
         Dim i As Integer
         Dim last As Integer = values.Length - 1
         For i = 0 To last
            item.Values.Push(values.Take(i))
         Next
         item.DisplayValue = me._valueHost.ReadDisplay()
         values.Free()
         me._items.Push(item)
         me._appendGridRow(item)
         me._valueHost.ClearInput()
      End Sub

      Private Function _hasBlankOrZero(pValues As TTList<String>) As Boolean
         Dim i As Integer
         Dim last As Integer = pValues.Length - 1
         For i = 0 To last
            Dim raw As String = Trim(pValues.Take(i))
            If raw = "" Then
               _hasBlankOrZero = True
               Exit Function
            End If
            Try
               Dim parsed As Double = CDbl(raw)
               If parsed = 0 Then
                  _hasBlankOrZero = True
                  Exit Function
               End If
            Catch ex As Exception
            End Try
         Next
         _hasBlankOrZero = False
      End Function

      Private Sub _onClear(pSender As TObject)
         me._items.Clean()
         me._refreshGrid()
         me._valueHost.ClearInput()
      End Sub

      Private Sub _onDelete(pSender As TObject)
         Dim idx As Integer = me._selectedItemIndex()
         If (idx < 0) Or (idx >= me._items.Length) Then
            Forms.MessageBox.Show("Selecione um filtro para excluir.")
            Exit Sub
         End If
         me._items.Delete(idx)
         me._refreshGrid()
      End Sub

      Private Sub _onExportJson(pSender As TObject)
         Dim path As String = Trim(TDialogs.SaveFile("Exportar filtro", me._jsonFileFilter(), "", "7json", me._defaultJsonName()))
         If path = "" Then
            Exit Sub
         End If
         Try
            TFile.WriteAllText(path, me.ToJson())
         Catch ex As Exception
            Forms.MessageBox.Show("Não foi possível exportar o filtro." & Char(13) & ex.Message)
         End Try
      End Sub

      Private Sub _onImportJson(pSender As TObject)
         Dim path As String = Trim(TDialogs.OpenFile("Importar filtro", me._jsonFileFilter(), ""))
         If path = "" Then
            Exit Sub
         End If
         Try
            If Not me.FromJson(TFile.ReadAllText(path)) Then
               Forms.MessageBox.Show("Não foi possível importar o JSON do filtro.")
            End If
         Catch ex As Exception
            Forms.MessageBox.Show("Não foi possível importar o filtro." & Char(13) & ex.Message)
         End Try
      End Sub

      Private Function _jsonFileFilter() As String
         _jsonFileFilter = "Filtros Data7 (*.7json)|*.7json"
      End Function

      Private Function _defaultJsonName() As String
         Dim nome As String = "filtro"
         If Assigned(me._tabela) Then
            If Trim(me._tabela.Nome) <> "" Then
               nome = Trim(me._tabela.Nome)
            End If
         End If
         _defaultJsonName = nome & ".7json"
      End Function

      Private Sub _onInsert(pSender As TObject)
         If Not me._valueHost.InsertCurrent() Then
            Forms.MessageBox.Show("Informe um valor para inserir na lista.")
         End If
      End Sub

      Private Sub _onRemove(pSender As TObject)
         If Not me._valueHost.RemoveSelected() Then
            Forms.MessageBox.Show("Selecione um valor da lista para remover.")
         End If
      End Sub

      Private Sub _appendGridRow(pItem As TFilterItem)
         If me._items.Length = 1 Then
            me._writeItemRow(1, pItem)
         Else
            me._grid.AddRow()
            me._writeItemRow(me._grid.RowCount - 1, pItem)
         End If
         me._applyFilterRowHeights()
      End Sub

      Private Sub _refreshGrid()
         Dim n As Integer = me._items.Length
         If n < 1 Then
            me._grid.RowCount = 2
            me._clearDataRow(1)
            me._applyFilterRowHeights()
            Exit Sub
         End If
         me._grid.RowCount = n + 1
         Dim i As Integer
         For i = 0 To n - 1
            me._writeItemRow(i + 1, me._items.Take(i))
         Next
         me._applyFilterRowHeights()
      End Sub

      Private Sub _writeItemRow(pRow As Integer, pItem As TFilterItem)
         Dim opTitle As String = "E"
         If UCase(pItem.LogicalOp) = "OR" Then
            opTitle = "OU"
         End If
         me._grid.Cells(0, pRow) = opTitle
         me._grid.Cells(1, pRow) = pItem.FieldTitle
         me._grid.Cells(2, pRow) = pItem.ConditionTitle
         me._grid.Cells(3, pRow) = pItem.DisplayValue
         me._grid.FontSize(0, pRow) = me._fontSize
         me._grid.FontSize(1, pRow) = me._fontSize
         me._grid.FontSize(2, pRow) = me._fontSize
         me._grid.FontSize(3, pRow) = me._fontSize
      End Sub

      Private Sub _clearDataRow(pRow As Integer)
         me._grid.Cells(0, pRow) = ""
         me._grid.Cells(1, pRow) = ""
         me._grid.Cells(2, pRow) = ""
         me._grid.Cells(3, pRow) = ""
      End Sub

      Private Sub _onCanEditGrid(pSender As TObject, pRow As Integer, pCol As Integer, ByRef pCanEdit As Boolean)
         pCanEdit = False
      End Sub

      Private Sub _onFilterGridResize(pSender As TObject)
         me._fitFilterColumns()
      End Sub

      Private Sub _fitFilterColumns()
         If Not Assigned(me._grid) Then
            Exit Sub
         End If
         If me._grid.ColCount < 1 Then
            Exit Sub
         End If
         Dim total As Integer = me._grid.ClientWidth
         If total < 1 Then
            total = me._grid.Width
         End If
         If total < 1 Then
            Exit Sub
         End If
         Dim last As Integer = me._grid.ColCount - 1
         Dim colW As Integer = Int(total / me._grid.ColCount)
         Dim i As Integer
         For i = 0 To last - 1
            me._grid.ColWidth(i) = colW
         Next
         me._grid.ColWidth(last) = total - (colW * last)
      End Sub

      Private Function _selectedItemIndex() As Integer
         Dim row As Integer = me._grid.Row
         If row < 1 Then
            _selectedItemIndex = -1
            Exit Function
         End If
         Dim idx As Integer = row - 1
         If (idx < 0) Or (idx >= me._items.Length) Then
            _selectedItemIndex = -1
         Else
            _selectedItemIndex = idx
         End If
      End Function

      Private Sub _applyFilterRowHeights()
         If Not Assigned(me._grid) Then
            Exit Sub
         End If
         Dim last As Integer = me._grid.RowCount - 1
         Dim i As Integer
         For i = 0 To last
            If i = 0 Then
               me._grid.RowHeight(i) = me._rowHeight + 1
            Else
               me._grid.RowHeight(i) = me._rowHeight
            End If
         Next
         me._applyFilterCellFonts()
      End Sub

      Private Sub _applyFilterCellFonts()
         If Not Assigned(me._grid) Then
            Exit Sub
         End If
         Dim lastR As Integer = me._grid.RowCount - 1
         Dim lastC As Integer = me._grid.ColCount - 1
         Dim r As Integer
         Dim c As Integer
         For r = 0 To lastR
            For c = 0 To lastC
               me._grid.FontSize(c, r) = me._fontSize
            Next
         Next
      End Sub

      Private Sub _rebuildValue()
         me._valueHost.Rebuild(me._currentField(), me._condEditor.ValueSelect)
         me._applyConditionUi()
      End Sub

      Private Sub _applyConditionUi()
         If Assigned(me._listButtons) Then
            me._listButtons.Visible = TFilterOps.IsList(me._condEditor.ValueSelect)
         End If
         If Assigned(me._header) Then
            me._header.Height = me._headerHeightForCondition()
         End If
      End Sub

      Private Function _compactHeaderHeight() As Integer
         _compactHeaderHeight = 13 + 2 + me._editorHeight
      End Function

      Private Function _headerHeightForCondition() As Integer
         If me.ActionsVertical Then
            _headerHeightForCondition = me._headerExpanded
            Exit Function
         End If
         Dim condition As String = ""
         If Assigned(me._condEditor) Then
            condition = me._condEditor.ValueSelect
         End If
         If TFilterOps.IsList(condition) Or TFilterOps.IsSql(condition) Then
            _headerHeightForCondition = me._headerExpanded
         ElseIf TFilterOps.IsRange(condition) And me.RangeValuesVertical Then
            _headerHeightForCondition = me._compactHeaderHeight() + me._editorHeight + 13
         Else
            _headerHeightForCondition = me._compactHeaderHeight()
         End If
      End Function

      Private Function _currentField() As TFilterField
         _currentField = me._tabela.FindByName(me._fieldEditor.ValueSelect)
      End Function

      Private Function _combo(pParent As TWinControl, pWidth As Integer, pLista As String) As HComboBox
         Dim editor As New HComboBox(pParent)
         editor.Align = alLeft
         editor.Width = pWidth
         editor.Height = me._editorHeight
         editor.AlignWithMargins = True
         editor.Margins.Left = 0
         editor.Margins.Top = 0
         editor.Margins.Right = 4
         editor.Margins.Bottom = 0
         If pLista <> "" Then
            editor.ListaOpcoes = pLista
         End If
         _combo = editor
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

      Private Function _label(pParent As TWinControl, pCaption As String, pWidth As Integer) As StaticText
         Dim lbl As New StaticText(pParent)
         lbl.AutoSize = False
         lbl.Align = alLeft
         lbl.Width = pWidth
         lbl.Caption = pCaption
         _label = lbl
      End Function

      Private Function _button(pParent As TWinControl, pCaption As String, pAlign As TAlign) As CommandButton
         Dim btn As New CommandButton(pParent)
         btn.Align = pAlign
         btn.AlignWithMargins = True
         btn.Text = pCaption
         If pAlign = alLeft Then
            btn.Width = 72
            btn.Height = me._editorHeight
            btn.Margins.Left = 2
            btn.Margins.Top = 0
            btn.Margins.Right = 2
            btn.Margins.Bottom = 0
         Else
            btn.Height = 24
            btn.Margins.Left = 4
            btn.Margins.Top = 2
            btn.Margins.Right = 4
            btn.Margins.Bottom = 2
         End If
         _button = btn
      End Function

      Private Sub _buildJsonActions(pParent As TWinControl)
         me._jsonActions = me._panel(pParent, alRight, me._jsonActionsWidth, 0)
         me._jsonActions.AlignWithMargins = True
         me._jsonActions.Margins.Left = 0
         me._jsonActions.Margins.Top = 0
         me._jsonActions.Margins.Right = 0
         me._jsonActions.Margins.Bottom = 0
         me._btnImport = me._button(me._jsonActions, "Importar", alTop)
         me._btnImport.Margins.Right = 2
         me._btnExport = me._button(me._jsonActions, "Exportar", alTop)
         me._btnExport.Margins.Right = 2
         me._jsonActions.Visible = me._jsonActionsEnabled
      End Sub

      Private Function _listButton(pParent As TWinControl, pCaption As String) As CommandButton
         Dim btn As New CommandButton(pParent)
         btn.Align = alTop
         btn.Height = 18
         btn.AlignWithMargins = True
         btn.Margins.Left = 4
         btn.Margins.Top = 0
         btn.Margins.Right = 0
         btn.Margins.Bottom = 2
         btn.Text = pCaption
         _listButton = btn
      End Function

      Overrides Sub Dispose()
         If Assigned(me._valueHost) Then
            me._valueHost.Free()
            me._valueHost = Null
         End If
         me._grid = Null
         If Assigned(me._items) Then
            me._items.Free()
            me._items = Null
         End If
         If Assigned(me._tabela) Then
            me._tabela.Free()
            me._tabela = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
