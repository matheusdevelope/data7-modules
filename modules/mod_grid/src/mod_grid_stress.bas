
Imports Forms
Imports IO
Imports SQL
Imports mod_tobject
Imports mod_grid_view
Imports mod_grid_col
Imports mod_grid_row
Imports mod_grid_data
Imports mod_grid_column_kind

Namespace mod_grid_stress

Class TGridStressRun
    Inherits TTObject
    FForm As Form
    Grid As TGridView
    Private _total As Integer
    Private _passed As Integer
    Private _failed As Integer
    Private _firstCodigo As String
    Private _lastCodigo As String
    Private _midCodigo As String
    Private _midNome As String
    Private _midItem As Integer
    Private _selectedCount As Integer
    Private _timerStart As TDateTime
    Private _sortCol As TGridCol
    Private _sortColIndex As Integer
    Sub New()
        MyBase.New()
        me._total = 0
        me._passed = 0
        me._failed = 0
        me._firstCodigo = ""
        me._lastCodigo = ""
        me._midCodigo = ""
        me._midNome = ""
        me._midItem = 0
        me._selectedCount = 0
    End Sub
    Sub New(pValue As TGridStressRun)
        MyBase.New()
        me.Assign(pValue)
    End Sub
    Sub Assign(pValue As TGridStressRun)
        If Assigned(pValue) Then
            me.FForm = pValue.FForm
            me.Grid = pValue.Grid
            me._total = pValue._total
            me._passed = pValue._passed
            me._failed = pValue._failed
            me._firstCodigo = pValue._firstCodigo
            me._lastCodigo = pValue._lastCodigo
            me._midCodigo = pValue._midCodigo
            me._midNome = pValue._midNome
            me._midItem = pValue._midItem
            me._selectedCount = pValue._selectedCount
        End If
    End Sub
    Overrides Function Clone() As TGridStressRun
        Clone = New TGridStressRun(me)
    End Function
    Sub Execute()
        print("=== mod_grid stress ===")
        me._buildForm()
        me._timeStart("add-cols")
        me._addColumns()
        me._timeEnd("add-cols")
        me._applyOptions()
        me._fillFromDatabase()
        me._timeStart("prepare")
        me.Grid.Prepare()
        me.Grid.Native.SortHeader = True
        me._timeEnd("prepare")
        me._assertFill()
        me._assertHiddenSurvived()
        me._assertImageAndMask("after fill")
        me._timeStart("sort-asc")
        me._sortBy("CodProduto", True)
        me._timeEnd("sort-asc")
        me._assertSorted(True, "sort ASC CodProduto")
        me._assertRowIntegrity("after ASC")
        me._assertItemKept("after ASC")
        me._assertImageAndMask("after ASC")
        me._timeStart("sort-desc")
        me._sortBy("CodProduto", False)
        me._timeEnd("sort-desc")
        me._assertSorted(False, "sort DESC CodProduto")
        me._assertRowIntegrity("after DESC")
        me._assertItemKept("after DESC")
        me._assertImageAndMask("after DESC")
        me._timeStart("sort-valor")
        me._sortBy("PrecoVenda", True)
        me._timeEnd("sort-valor")
        me._assertValorOrdered()
        me._assertMoveKeepsItem()
        me._assertDisplayMatchesMatrix()
        me._printSummary()
    End Sub
    Private Sub _buildForm()
        me.FForm = New Form()
        me.FForm.Caption = "mod_grid stress"
        me.FForm.Width = 1100
        me.FForm.Height = 700
        me.Grid = New TGridView(me.FForm)
    End Sub
    Private Sub _applyOptions()
        me.Grid.Options.Selection.Enabled = True
        me.Grid.Options.Item.Enabled = True
        me.Grid.Options.Item.Size = 3
        me.Grid.Options.Layout.StretchLastColumn = False
        me.Grid.Options.Interaction.AllowMarkForDelete = True
        me.Grid.Options.Interaction.AddRowOnDown = True
        me.Grid.Options.Interaction.OnBeforeInsertNewRow = me._onBeforeInsert

        'me.Grid.Options.Interaction.OnlyRead = True
    End Sub
    Private Sub _addColumns()
        me.Grid.AddColumn(TGridCol.AsCheckbox("Ativo", "Ativo").SetWidth(50).SetDefault("S"))
        Dim codigo As TGridCol = TGridCol.AsSearch("Código", "CodProduto")
        codigo.Options.Search.CodPesquisa = Data7.PesquisaPadrao("ItemProdutoVendido", "CodProduto")
        codigo.Options.Search.DescriptionColumnId = "Nome"
        codigo.Options.Layout.Width = 80
        codigo.Options.Color.Header.Text = RGB(0, 0, 120)
        codigo.SetRequired()
        codigo.SetNumericSort()
        me.Grid.AddColumn(codigo)
        me.Grid.AddColumn(TGridCol.AsReadOnly("Nome", "Nome").SetWidth(220))
        Dim preco As TGridCol = TGridCol.AsValue("Preço", "PrecoVenda").SetWidth(80).SetAlignment(taRightJustify).SetDefault(0)
        preco.Options.Format.Mask = ",0.00"
        me.Grid.AddColumn(preco)
        Dim tipo As TGridCol = TGridCol.AsCombo("Tipo", "CodTipoProduto").SetWidth(110)
        tipo.Options.Combo.SetLista("""Beneficiamento=BN"";""Material de Consumo=MC"";""Mercadoria=ME"";""Mão de Obra=MO"";""Materia Prima=MP"";""Produto Acabado=PA"";""Produto Intermediario=PI"";""Ativo Imobilizado=AI"";""Embalagem=EM"";""Produto em Processo=PP"";""Outros Insumos=OI"";""Outros=O""")
        tipo.SetDefault("ME")
        me.Grid.AddColumn(tipo)
        Dim marca As TGridCol = TGridCol.AsSearch("Cod. Marca", "CodMarca")
        marca.Options.Search.CodPesquisa = Data7.PesquisaPadrao("Produto", "CodMarca")
        marca.Options.Search.DescriptionColumnId = "NomeMarca"
        marca.Options.Layout.Width = 80
        marca.SetNumericSort()
        me.Grid.AddColumn(marca)
        me.Grid.AddColumn(TGridCol.AsReadOnly("Nome Marca", "NomeMarca").SetWidth(160))
        me.Grid.AddColumn(TGridCol.AsDate("Cadastro", "DataCadastro").SetWidth(90).SetOnGetDefault(me._defaultCadastro))
        me.Grid.AddColumn(TGridCol.AsCheckbox("Permite Venda", "PermiteVenda").SetWidth(90))
        Dim status As TGridCol = TGridCol.AsImage("Status", "status").SetWidth(40).SetAlignment(taCenter)
        status.AddImage("S", me._pngBase64("S"))
        status.AddImage("N", me._pngBase64("N"))
        me.Grid.AddColumn(status)
        Dim cep As TGridCol = TGridCol.AsMask("CEP", "cep").SetWidth(90)
        cep.Options.Format.Mask = "00.000-000"
        me.Grid.AddColumn(cep)
        me.Grid.AddColumn(TGridCol.AsText("Descrição", "Descricao").SetWidth(180))
        Dim hiddenCol As TGridCol = TGridCol.AsText("Interno", "interno")
        hiddenCol.Options.Layout.Hidden = True
        me.Grid.AddColumn(hiddenCol)
    End Sub
    Private Sub _fillFromDatabase()
        Dim _query As New SQL.Command()
        _query.CommandText = "SELECT TOP 100 P.Ativo, P.CodProduto, P.Nome, P.PrecoVenda, P.CodTipoProduto, P.CodMarca, M.Nome NomeMarca, P.DataCadastro, P.PermiteVenda, P.Descricao FROM Produto P JOIN Marca M ON M.CodMarca = P.CodMarca ORDER BY P.CodProduto ASC"
        _query.Open()
        me._timeStart("add-rows")
        While Not _query.Eof
            me.Grid.AddRow(_query.Field("CodProduto").AsString)
            _query.Next()
        End While
        me._timeEnd("add-rows")
        me._timeStart("set-values")
        _query.First()
        Dim i As Integer = 0
        Dim cAtivo As Integer = me.Grid.Data.GetColIndex("Ativo")
        Dim cCodigo As Integer = me.Grid.Data.GetColIndex("CodProduto")
        Dim cNome As Integer = me.Grid.Data.GetColIndex("Nome")
        Dim cPreco As Integer = me.Grid.Data.GetColIndex("PrecoVenda")
        Dim cTipo As Integer = me.Grid.Data.GetColIndex("CodTipoProduto")
        Dim cMarca As Integer = me.Grid.Data.GetColIndex("CodMarca")
        Dim cNomeMarca As Integer = me.Grid.Data.GetColIndex("NomeMarca")
        Dim cData As Integer = me.Grid.Data.GetColIndex("DataCadastro")
        Dim cVenda As Integer = me.Grid.Data.GetColIndex("PermiteVenda")
        Dim cDesc As Integer = me.Grid.Data.GetColIndex("Descricao")
        Dim cInterno As Integer = me.Grid.Data.GetColIndex("interno")
        Dim cStatus As Integer = me.Grid.Data.GetColIndex("status")
        Dim cCep As Integer = me.Grid.Data.GetColIndex("cep")
        While Not _query.Eof
            Dim codigo As String = _query.Field("CodProduto").AsString
            Dim nome As String = _query.Field("Nome").AsString
            Dim ativo As String = UCase(Trim(_query.Field("Ativo").AsString))
            me.Grid.Data.SetCell(i, cAtivo, _query.Field("Ativo").AsString)
            me.Grid.Data.SetCell(i, cCodigo, codigo)
            me.Grid.Data.SetCell(i, cNome, nome)
            me.Grid.Data.SetCell(i, cPreco, _query.Field("PrecoVenda").AsFloat)
            me.Grid.Data.SetCell(i, cTipo, _query.Field("CodTipoProduto").AsString)
            me.Grid.Data.SetCell(i, cMarca, _query.Field("CodMarca").AsInteger)
            me.Grid.Data.SetCell(i, cNomeMarca, _query.Field("NomeMarca").AsString)
            me.Grid.Data.SetCell(i, cData, _query.Field("DataCadastro").AsString)
            me.Grid.Data.SetCell(i, cVenda, _query.Field("PermiteVenda").AsString)
            me.Grid.Data.SetCell(i, cDesc, _query.Field("Descricao").AsString)
            me.Grid.Data.SetCell(i, cInterno, "X" + codigo)
            If ativo = "S" Or ativo = "N" Then
                me.Grid.Data.SetCell(i, cStatus, ativo)
            End If
            me.Grid.Data.SetCell(i, cCep, me._cepOf(i))
            Dim row As TGridRow = me.Grid.Data.RowAt(i)
            If Assigned(row) Then
                If (i Mod 5) = 0 Then
                    row.Selected = True
                    me._selectedCount = me._selectedCount + 1
                End If
                If i = 0 Then
                    me._firstCodigo = codigo
                End If
                me._lastCodigo = codigo
                If i = 50 Then
                    me._midCodigo = codigo
                    me._midNome = nome
                    me._midItem = row.ItemNumber
                End If
            End If
            i = i + 1
            _query.Next()
        End While
        me._timeEnd("set-values")
        _query.Free()
        me._total = me.Grid.Data.RowCount
        If me._midCodigo = "" AndAlso me._total > 0 Then
            Dim midIdx As Integer = Int(me._total / 2)
            Dim midRow As TGridRow = me.Grid.Data.RowAt(midIdx)
            If Assigned(midRow) Then
                me._midCodigo = me._cell(midIdx, "CodProduto")
                me._midNome = me._cell(midIdx, "Nome")
                me._midItem = midRow.ItemNumber
            End If
        End If
    End Sub
    Private Sub _assertFill()
        me._ok(me.Grid.Data.RowCount = me._total AndAlso me._total > 0, "RowCount=" + CStr(me._total) + " atual=" + CStr(me.Grid.Data.RowCount))
        me._ok(me.Grid.Data.ColCount >= 10, "ColCount>=10 atual=" + CStr(me.Grid.Data.ColCount))
        me._ok(me._cell(0, "CodProduto") = me._firstCodigo, "primeira linha codigo do banco")
        me._ok(me._cell(me._total - 1, "CodProduto") = me._lastCodigo, "ultima linha codigo do banco")
        me._ok(me._countSelected() = me._selectedCount, "selecionados a cada 5 atual=" + CStr(me._countSelected()) + " esperado=" + CStr(me._selectedCount))
    End Sub
    Private Sub _assertHiddenSurvived()
        Dim i As Integer
        Dim ok As Boolean = True
        For i = 0 To me._total - 1
            Dim codigo As String = me._cell(i, "CodProduto")
            If me._cell(i, "interno") <> "X" + codigo Then
                ok = False
            End If
        Next
        me._ok(ok, "coluna oculta interno sobreviveu na matrix")
    End Sub
    Private Sub _sortBy(pColId As String, pAsc As Boolean)
        me._sortCol = me.Grid.Data.ColAt(pColId)
        me._sortColIndex = me.Grid.Data.GetColIndex(pColId)
        me.Grid.Data.SortGridRows(me._sortByCol, pAsc, pColId)
    End Sub
    Private Sub _assertSorted(pAsc As Boolean, pName As String)
        Dim ordered As Boolean = True
        Dim i As Integer
        For i = 1 To me._total - 1
            Dim prevKey As String = me._sortKey(i - 1)
            Dim curKey As String = me._sortKey(i)
            If pAsc Then
                If curKey < prevKey Then
                    ordered = False
                End If
            Else
                If curKey > prevKey Then
                    ordered = False
                End If
            End If
        Next
        me._ok(ordered, pName)
        If pAsc Then
            me._ok(me._cell(0, "CodProduto") = me._firstCodigo, "ASC inicia no menor codigo")
            me._ok(me._cell(me._total - 1, "CodProduto") = me._lastCodigo, "ASC termina no maior codigo")
        Else
            me._ok(me._cell(0, "CodProduto") = me._lastCodigo, "DESC inicia no maior codigo")
            me._ok(me._cell(me._total - 1, "CodProduto") = me._firstCodigo, "DESC termina no menor codigo")
        End If
    End Sub
    Private Sub _assertRowIntegrity(pLabel As String)
        Dim i As Integer
        Dim ok As Boolean = True
        Dim ativoOk As Boolean = True
        For i = 0 To me._total - 1
            Dim codigo As String = me._cell(i, "CodProduto")
            If me._cell(i, "interno") <> "X" + codigo Then
                ok = False
            End If
            If me._cell(i, "Nome") = "" Then
                ok = False
            End If
            Dim ativo As String = UCase(Trim(me._cell(i, "Ativo")))
            If ativo <> "S" AndAlso ativo <> "N" AndAlso ativo <> "" Then
                ativoOk = False
            End If
        Next
        me._ok(ok, "dados da linha acompanham o codigo " + pLabel)
        me._ok(me._countSelected() = me._selectedCount, "Selected acompanha a linha " + pLabel)
        me._ok(ativoOk, "checkbox ativo acompanha a linha " + pLabel)
        Dim statusOk As Boolean = True
        Dim cepOk As Boolean = True
        For i = 0 To me._total - 1
            Dim ativoVal As String = UCase(Trim(me._cell(i, "Ativo")))
            Dim statusVal As String = UCase(Trim(me._cell(i, "status")))
            If ativoVal = "S" Or ativoVal = "N" Then
                If statusVal <> ativoVal Then
                    statusOk = False
                End If
            End If
            If Len(me._cell(i, "cep")) <> 8 Then
                cepOk = False
            End If
        Next
        me._ok(statusOk, "imagem status acompanha Ativo " + pLabel)
        me._ok(cepOk, "mascara cep com 8 digitos " + pLabel)
        If me._midCodigo <> "" Then
            Dim mid As TGridRow = me._rowByCodigo(me._midCodigo)
            Dim midOk As Boolean = Assigned(mid) AndAlso me._cell(mid.Index, "Nome") = me._midNome
            me._ok(midOk, "amostra Nome acompanha codigo " + pLabel)
        End If
    End Sub
    Private Sub _assertItemKept(pLabel As String)
        If me._midCodigo = "" Then
            me._ok(False, "ItemNumber original preservado " + pLabel)
            Exit Sub
        End If
        Dim row As TGridRow = me._rowByCodigo(me._midCodigo)
        Dim ok As Boolean = Assigned(row) AndAlso row.ItemNumber = me._midItem
        me._ok(ok, "ItemNumber original preservado " + pLabel)
    End Sub
    Private Sub _assertMoveKeepsItem()
        Dim target As TGridRow = me._rowByCodigo(me._midCodigo)
        If Not Assigned(target) Then
            me._ok(False, "MoveRow: linha amostra encontrada")
            Exit Sub
        End If
        Dim itemBefore As Integer = target.ItemNumber
        Dim id As String = target.ID
        me.Grid.Data.MoveRow(id, 0)
        Dim moved As TGridRow = me.Grid.Data.RowAt(0)
        Dim okCodigo As Boolean = Assigned(moved) AndAlso me._cell(0, "CodProduto") = me._midCodigo
        Dim okItem As Boolean = Assigned(moved) AndAlso moved.ItemNumber = itemBefore
        me._ok(okCodigo, "MoveRow amostra foi para o indice 0")
        me._ok(okItem, "MoveRow manteve ItemNumber=" + CStr(itemBefore))
    End Sub
    Private Sub _assertDisplayMatchesMatrix()
        Dim samples[] As Integer = [0, 1]
        If me._total > 10 Then
            samples = [0, 1, 10, 40, 80, me._total - 1]
        End If
        Dim ok As Boolean = True
        Dim i As Integer
        For i = 0 To samples.Length - 1
            Dim r As Integer = samples.GetItem(i)
            If r < 0 Or r >= me._total Then
                ok = False
            Else
                Dim display As String = me.Grid.Data.CellText(r, "CodProduto")
                Dim raw As String = me._cell(r, "CodProduto")
                If UCase(Trim(display)) <> UCase(Trim(raw)) Then
                    ok = False
                End If
            End If
        Next
        me._ok(ok, "CellText codigo = matrix GetValue nas amostras")
    End Sub
    Private Sub _assertImageAndMask(pLabel As String)
        Dim statusCol As TGridCol = me.Grid.Data.ColAt("status")
        Dim cepCol As TGridCol = me.Grid.Data.ColAt("cep")
        me._ok(Assigned(statusCol) AndAlso statusCol.Kind = TGridColumnKind.Image(), "coluna status e Image " + pLabel)
        me._ok(me.Grid.Native.EnableHTML, "EnableHTML ligado pela coluna Image " + pLabel)
        me._ok(Assigned(statusCol) AndAlso Not statusCol.IsEditable(Null), "coluna Image nao e editavel " + pLabel)
        me._ok(Assigned(cepCol) AndAlso cepCol.Kind = TGridColumnKind.Mask(), "coluna cep e Mask " + pLabel)
        me._ok(Assigned(cepCol) AndAlso cepCol.Options.Format.Mask = "00.000-000", "mascara CEP 00.000-000 " + pLabel)
        me._ok(Assigned(cepCol) AndAlso cepCol.IsEditable(Null), "coluna Mask continua editavel " + pLabel)
        Dim pathS As String = ""
        Dim pathN As String = ""
        If Assigned(statusCol) Then
            pathS = statusCol.Options.Image.LookupPath("S")
            pathN = statusCol.Options.Image.LookupPath("N")
        End If
        me._ok(pathS <> "" AndAlso File.Exists(pathS), "cache disco da imagem S " + pLabel)
        me._ok(pathN <> "" AndAlso File.Exists(pathN), "cache disco da imagem N " + pLabel)
        Dim pathS2 As String = ""
        If Assigned(statusCol) Then
            pathS2 = statusCol.Options.Image.LookupPath("S")
        End If
        me._ok(pathS <> "" AndAlso pathS = pathS2, "LookupPath S reusa o mesmo arquivo " + pLabel)
        Dim htmlOk As Boolean = True
        Dim i As Integer
        For i = 0 To me._total - 1
            Dim key As String = UCase(Trim(me._cell(i, "status")))
            If key = "S" Or key = "N" Then
                Dim html As String = me.Grid.Data.CellText(i, "status")
                Dim expected As String = ""
                If Assigned(statusCol) Then
                    expected = statusCol.Options.Image.AsHtml(key)
                End If
                If html <> expected Or InStr(html, "<img src=""file://") <> 1 Then
                    htmlOk = False
                End If
            End If
        Next
        me._ok(htmlOk, "CellText Image monta tag file:// " + pLabel)
    End Sub
    Private Function _sortByCol(pRow As TGridRow, pIndex As Integer, pExtra As Variant) As String
        Dim _col As TGridCol = me._sortCol
        Dim v As Variant
        If me._sortColIndex >= 0 Then
            v = me.Grid.Data.GetCell(pIndex, me._sortColIndex)
        Else
            v = me.Grid.Data.GetCell(pIndex, CStr(pExtra))
        End If
        If Assigned(_col) Then
            _sortByCol = _col.SortKey(v)
            Exit Function
        End If
        If IsEmpty(v) Then
            _sortByCol = ""
        Else
            _sortByCol = CStr(v)
        End If
    End Function
    Private Function _sortKey(pIndex As Integer) As String
        _sortKey = me._sortByCol(me.Grid.Data.RowAt(pIndex), pIndex, "")
    End Function
    Private Sub _assertValorOrdered()
        Dim ordered As Boolean = True
        Dim i As Integer
        For i = 1 To me._total - 1
            Dim prevKey As String = me._sortKey(i - 1)
            Dim curKey As String = me._sortKey(i)
            If curKey < prevKey Then
                ordered = False
            End If
        Next
        me._ok(ordered, "sort ASC PrecoVenda numerico")
    End Sub
    Private Sub _onBeforeInsert(pRow As TGridRow, ByRef pCanInsert As Boolean, ByRef pMessage As String)
    End Sub
    Private Function _defaultCadastro(pRow As TGridRow, pCol As TGridCol) As Variant
        _defaultCadastro = DateTime().ToString("dd/mm/yyyy hh:MM:ss.zz")
    End Function
    Private Function _cepOf(pIndex As Integer) As String
        Dim n As Integer = (pIndex * 137) Mod 100000000
        Dim s As String = CStr(n)
        While Len(s) < 8
            s = "0" + s
        End While
        _cepOf = s
    End Function
    Private Function _pngBase64(pKey As String) As String
        Dim _path As String = ""
        If pKey = "S" Then
            _pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAABHElEQVR4nGNgoAXw2+Cn5b0uoNJ7XcB8KK70WhegSVCjy6pQfu/1/st81gX881kf8B8Frwv4570uYKnHNg8+nJp91vtfxtCIadAlrIZ4g2wmoNlvQyCU7b8Yw88+2JyNhJP3xvzf9aUdTIPUooSJ93r/KkKaD/3s/r/qZf3/gE1BMK9UIAxYFzAfpjh4c8j/xD1RKJoP/kDTDPHGXGQD5sEkJt0uBmsAacRqMxR7rwuYg9ULAZuCwBpAGnFpxvCC17oATeRADNgY9H/Z8zqcmr3X+//1WROkgRqN6wKWIisCacRqM8T5izDSgcc2Dz5QIiGUFrzXBVzEmRrBhqz3X4ItTYCcDbIZp2ZkAAoT7/X+5fDMtN6/DMPP1AIACYRseuTahd8AAAAASUVORK5CYII="
        Else
            _pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA8UlEQVR4nLVTSwrCMBDtCfQa1m2Z6X4SxKu4FvzdQd2oG3/g7z7qNcRFE5AubCQVa2paqlAHHgwh7yVv8uI4/6iAsC4Z9gXDtYbuA+67hcQr96qSwUEwjCRDZSJeI9xfmljJJxOeP4kWCE6ZIpLBoZD8xtbyLIxr39otFU6GCUH3es20k5qJJByYJ2iCiiIVzsYx4t4QjMGhlwiI56RTG8LZSL0qnE8tG4JgaQjA6mcBBovyLATcd38aIuE9aHi19DMS7r99RsFgY+Xg0sSKDkmxABxz0/gUwV1mlAnv+uRccipY3HclQTf5TIQdy3NZ9QCinYz4xQE55gAAAABJRU5ErkJggg=="
        End If
    End Function
    Private Function _rowByCodigo(pCodigo As String) As TGridRow
        Dim i As Integer
        For i = 0 To me._total - 1
            If me._cell(i, "CodProduto") = pCodigo Then
                _rowByCodigo = me.Grid.Data.RowAt(i)
                Exit Function
            End If
        Next
        _rowByCodigo = Null
    End Function
    Private Function _countSelected() As Integer
        Dim n As Integer = 0
        Dim i As Integer
        For i = 0 To me.Grid.Data.RowCount - 1
            Dim row As TGridRow = me.Grid.Data.RowAt(i)
            If Assigned(row) AndAlso row.Selected Then
                n = n + 1
            End If
        Next
        _countSelected = n
    End Function
    Private Function _cell(pIndex As Integer, pId As String) As String
        Dim v As Variant = me.Grid.GetValue(pIndex, pId)
        If IsEmpty(v) Then
            _cell = ""
        Else
            _cell = CStr(v)
        End If
    End Function
    Private Sub _timeStart(pLabel As String)
        me._timerStart = DateTime()
        print("[TIME START] " + pLabel + ": ")
    End Sub
    Private Sub _timeEnd(pLabel As String)
        Dim _diff As TDateTime = DateTime() - me._timerStart
        print("[TIME END] " + pLabel + ": " + _diff.ToString("hh:nn:ss.zzz"))
    End Sub
    Private Sub _ok(pCond As Boolean, pName As String)
        If pCond Then
            me._passed = me._passed + 1
            print("  OK   " + pName)
        Else
            me._failed = me._failed + 1
            print("  FAIL " + pName)
        End If
    End Sub
    Private Sub _printSummary()
        print("=== resultado: " + CStr(me._passed) + " ok, " + CStr(me._failed) + " fail ===")
        If me._failed = 0 Then
            print("matrix preenchida, ordenada e integro apos sort/move.")
        End If
    End Sub
    Sub _printData()
        If me.Grid.Data.RowCount > 0 Then
            print(me.Grid.Data.GetCell(0, "Nome"))
        End If
    End Sub
    Overrides Function ToString() As String
        With me.BuildLogger(me.ClassName)
            .Prop("Passed", me._passed)
            .Prop("Failed", me._failed)
            ToString = .Text()
            .Free()
        End With
    End Function
    Overrides Sub Dispose()
        If Assigned(me.Grid) Then
            me.Grid.Free()
        End If
        If Assigned(me.FForm) Then
            me.FForm.Free()
        End If
    End Sub
    Sub Free()
        MyBase.Free()
    End Sub
End Class

End Namespace