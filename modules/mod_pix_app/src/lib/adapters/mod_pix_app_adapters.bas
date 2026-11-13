Imports Forms
Imports mod_tobject
Imports mod_pix_erp
Imports mod_pix_runtime
Imports mod_pix_config
Imports mod_pix_filtro
Imports mod_pix_enums
Imports mod_pix_utils
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_recebimento
Imports mod_pix_recebimentos
Imports mod_pix_info_adicional
Imports mod_pix_devolucao
Imports mod_grid_view
Imports mod_grid_col
Imports mod_grid_row
Imports mod_grid_context
Imports mod_grid_presenter
Imports Collections

Namespace mod_pix_app_adapters

   ' data7:disable-next-line missing-mybase-free
   Class PixAppSurface

      Shared Function Page(pParent As TWinControl, pAlign As TAlign, pHeight As Integer = 0, pWidth As Integer = 0) As PageControl
         Dim surface As New PageControl(pParent)
         surface.Align = pAlign
         surface.ShowCardFrame = False
         surface.ShowShadow = False
         surface.TabStop = False
         If pHeight > 0 Then
            surface.Height = pHeight
         End If
         If pWidth > 0 Then
            surface.Width = pWidth
         End If
         Page = surface
      End Function

      Shared Function Caption(pParent As TWinControl, pText As String, pAlign As TAlign = alTop) As StaticText
         Dim label As New StaticText(pParent)
         label.Align = pAlign
         label.AutoSize = False
         label.Height = 18
         label.Text = pText
         label.Font.SetBold(True)
         Caption = label
      End Function

      Shared Function Hint(pParent As TWinControl, pText As String, pAlign As TAlign = alClient) As StaticText
         Dim label As New StaticText(pParent)
         label.Align = pAlign
         label.AutoSize = False
         label.Text = pText
         Hint = label
      End Function

      Shared Sub Show(pHost As TWinControl, pVisible As Boolean, pAlign As TAlign)
         If pHost.Visible = pVisible Then
            Exit Sub
         End If
         pHost.Visible = pVisible
         If pVisible Then
            pHost.Align = pAlign
         End If
      End Sub

      Shared Function Tabs(pParent As TWinControl) As PageControl
         Dim pages As New PageControl(pParent)
         pages.Align = alClient
         pages.ShowCardFrame = True
         pages.ShowShadow = False
         Tabs = pages
      End Function

      Shared Function Sheet(pTabs As PageControl, pCaption As String) As TabSheet
         Dim tabPage As New TabSheet(pTabs)
         tabPage.Caption = pCaption
         tabPage.Align = alClient
         Sheet = tabPage
      End Function

      Shared Function ScrollHost(pParent As TWinControl) As TForm
         Dim host As New Form()
         host.Parent = pParent
         host.Align = alClient
         ' data7:disable-next-line unknown-member
         host.OcultarBordas = True
         host.Visible = True
         host.OnCloseQuery = PixAppSurface.OnDenyClose
         ScrollHost = host
      End Function

      Shared Sub OnDenyClose(pSender As TObject, ByRef pCanClose As Boolean)
         pCanClose = False
      End Sub

   End Class

   Class PixAppGroup
      Inherits TTObject

      Private _shell As PageControl
      Private _group As ControlGroup
      Private _host As PageControl

      Sub New(pParent As TWinControl, pCaption As String, pAlign As TAlign, pHeight As Integer = 0, pWidth As Integer = 0)
         MyBase.New()
         me._shell = PixAppSurface.Page(pParent, alNone, pHeight, pWidth)
         me._shell.AlignWithMargins = True
         me._shell.Margins.Left = 2
         me._shell.Margins.Top = 2
         me._shell.Margins.Right = 2
         me._shell.Margins.Bottom = 2
         me._shell.Align = pAlign

         me._group = New ControlGroup(me._shell)
         me._group.Text = pCaption
         me._group.Align = alClient

         me._host = PixAppSurface.Page(me._shell, alNone)
         me._host.AlignWithMargins = True
         me._host.Margins.Left = 2
         me._host.Margins.Top = 18
         me._host.Margins.Right = 2
         me._host.Margins.Bottom = 2
         me._host.Align = alClient
      End Sub

      Property Shell As PageControl
         Get
            Shell = me._shell
         End Get
      End Property

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Property Caption As String
         Get
            Caption = me._group.Caption
         End Get
         Set(pValue As String)
            me._setCaption(pValue)
         End Set
      End Property

      Private Sub _setCaption(pValue As String)
         me._group.Caption = pValue
      End Sub

      Sub Sync()
         If Not Assigned(me._group) Then
            Exit Sub
         End If
         me._group.Align = alClient
      End Sub

      Overrides Sub Dispose()
         me._host = Null
         me._group = Null
         me._shell = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   ' data7:disable-next-line missing-mybase-free
   Class PixAppFormat

      Shared Function Money(pValue As Double) As String
         Money = pValue.ToString("0.00")
      End Function

      Shared Function DateTimeText(pValue As TDateTime) As String
         If IsEmptyDate(pValue) Then
            DateTimeText = ""
         Else
            DateTimeText = pValue.ToString("dd/mm/yyyy hh:nn:ss")
         End If
      End Function

      Shared Function StatusText(pStatus As PixStatusCobranca) As String
         If Assigned(pStatus) Then
            StatusText = pStatus.AsString
         Else
            StatusText = ""
         End If
      End Function

      Shared Function DevolucaoStatus(pStatus As PixStatusDevolucao) As String
         If Assigned(pStatus) Then
            DevolucaoStatus = pStatus.AsString
         Else
            DevolucaoStatus = ""
         End If
      End Function

      Shared Function Devedor(pCobranca As PixCobrancaCompleta) As String
         If Not Assigned(pCobranca) Then
            Devedor = ""
            Exit Function
         End If
         If Not Assigned(pCobranca.Devedor) Then
            Devedor = ""
            Exit Function
         End If
         Dim nome As String = Trim(pCobranca.Devedor.Nome)
         Dim doc As String = Trim(pCobranca.Devedor.CPF)
         If doc = "" Then
            doc = Trim(pCobranca.Devedor.CNPJ)
         End If
         If nome <> "" And doc <> "" Then
            Devedor = nome & " (" & doc & ")"
         ElseIf nome <> "" Then
            Devedor = nome
         Else
            Devedor = doc
         End If
      End Function

      Shared Function EndOfDay(pDate As TDateTime) As TDateTime
         If IsEmptyDate(pDate) Then
            EndOfDay = pDate
            Exit Function
         End If
         Dim dt As TDateTime = DateTime()
         EndOfDay = dt.EncodeDateTime(pDate.YearOf(), pDate.MonthOf(), pDate.DayOf(), 23, 59, 59, 0)
      End Function

      Shared Function StartOfDay(pDate As TDateTime) As TDateTime
         If IsEmptyDate(pDate) Then
            StartOfDay = pDate
            Exit Function
         End If
         Dim dt As TDateTime = DateTime()
         StartOfDay = dt.EncodeDateTime(pDate.YearOf(), pDate.MonthOf(), pDate.DayOf(), 0, 0, 0, 0)
      End Function

      Shared Function DevRowId(pE2e As String, pId As String) As String
         DevRowId = pE2e & "|" & pId
      End Function

      Shared Function DevRowE2e(pRowId As String) As String
         Dim p As Integer = InStr(pRowId, "|")
         If p <= 0 Then
            DevRowE2e = pRowId
         Else
            DevRowE2e = Left(pRowId, p - 1)
         End If
      End Function

      Shared Function DevRowDevId(pRowId As String) As String
         Dim p As Integer = InStr(pRowId, "|")
         If p <= 0 Then
            DevRowDevId = ""
         Else
            DevRowDevId = Mid(pRowId, p + 1)
         End If
      End Function

      Shared Function PagerText(pPageIndex As Integer, pPageCount As Integer, pTotal As Integer, pReturned As Integer, pById As Boolean) As String
         Dim page As Integer = pPageIndex + 1
         If page < 1 Then
            page = 1
         End If
         If pById Then
            PagerText = "Consulta por identificador · " & CStr(pReturned) & " registro(s)"
         ElseIf pPageCount > 1 Then
            PagerText = "Página " & CStr(page) & " de " & CStr(pPageCount) & " · " & CStr(pTotal) & " item(ns)"
         ElseIf pPageCount = 1 Then
            PagerText = "Página 1 de 1 · " & CStr(pTotal) & " item(ns)"
         ElseIf pReturned > 0 Then
            PagerText = "Página " & CStr(page) & " · " & CStr(pReturned) & " item(ns) nesta página · pode haver mais"
         Else
            PagerText = "Nenhum item nesta página"
         End If
      End Function

      Shared Function PageCountOf(pPageCount As Integer, pTotal As Integer, pPageSize As Integer, pReturned As Integer) As Integer
         Dim pages As Integer = pPageCount
         If pages <= 0 Then
            If pTotal > 0 And pPageSize > 0 Then
               pages = CInt(pTotal / pPageSize)
               If pages * pPageSize < pTotal Then
                  pages = pages + 1
               End If
            ElseIf pReturned >= pPageSize And pPageSize > 0 Then
               pages = 0
            Else
               pages = 1
            End If
         End If
         PageCountOf = pages
      End Function

   End Class

   Class PixAppServiceAdapter
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Function OpenConta(pCodContaFinanceira As String) As PixService
         Dim config As PixConfig = PixErp.FromContaFinanceira(pCodContaFinanceira)
         OpenConta = PixService.Load(config)
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixAppFilterMapper
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Function ToFiltro(pInicio As TDateTime, pFim As TDateTime, pStatus As String, pCpf As String, pCnpj As String, pPagina As Integer, pItens As Integer) As PixFiltro
         Dim filtro As New PixFiltro()
         If Not IsEmptyDate(pInicio) Then
            filtro.DataInicio = PixAppFormat.StartOfDay(pInicio)
         End If
         If Not IsEmptyDate(pFim) Then
            If pFim.DayOf() = DateTime().DayOf() And pFim.MonthOf() = DateTime().MonthOf() And pFim.YearOf() = DateTime().YearOf() Then
               filtro.DataFim = DateTime()
            Else
               filtro.DataFim = PixAppFormat.EndOfDay(pFim)
            End If
         End If
         If Trim(pStatus) <> "" Then
            filtro.Status = PixStatusCobranca.Load(Trim(pStatus))
         End If
         filtro.CPF = Trim(pCpf)
         filtro.CNPJ = Trim(pCnpj)
         If pPagina > 0 Then
            filtro.Pagina = pPagina
         End If
         If pItens > 0 Then
            filtro.ItensPorPagina = pItens
         End If
         ToFiltro = filtro
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixAppGridMapper
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Sub PrepareReadonly(pGrid As TGridView, pShowItem As Boolean = True)
         pGrid.Options.Item.Enabled = pShowItem
         pGrid.Options.Item.Size = 3
         pGrid.Options.Interaction.OnlyRead = True
         pGrid.Options.Interaction.AllowMarkForDelete = False
         pGrid.Options.Layout.StretchLastColumn = True
         ' pGrid.Events.OnCanEditCell = me._denyEdit
      End Sub

      ' Sub ApplyCellCopy(pGrid As TGridView)
      '    pGrid.Native.GridOptions.RowSelect = True
      '    pGrid.Native.GridOptions.ColSizing = True
      '    pGrid.Native.ActiveCellShow = False
      '    pGrid.Native.OnClipboardPaste = me._denyClipboard
      '    pGrid.Native.OnClipboardCut = me._denyClipboard
      ' End Sub

      ' Private Sub _denyEdit(pSender As TObject, pRow As Integer, pCol As Integer, ByRef pCanEdit As Boolean)
      '    pCanEdit = False
      ' End Sub

      ' Private Sub _denyClipboard(pSender As TObject, ByRef pAllow As Boolean)
      '    pAllow = False
      ' End Sub

      Sub BindCobrancaColumns(pGrid As TGridView)
         pGrid.AddColumn(TGridCol.AsText("TxId", "txid").SetWidth(220))
         pGrid.AddColumn(TGridCol.AsText("Status", "status").SetWidth(160))
         pGrid.AddColumn(TGridCol.AsValue("Valor", "valor").SetWidth(90).SetAlignment(taRightJustify))
         pGrid.AddColumn(TGridCol.AsText("Devedor", "devedor").SetWidth(180))
         pGrid.AddColumn(TGridCol.AsText("Criação", "criacao").SetWidth(140))
         pGrid.AddColumn(TGridCol.AsText("Chave", "chave").SetWidth(180))
      End Sub

      Sub BindPixColumns(pGrid As TGridView)
         pGrid.AddColumn(TGridCol.AsText("E2E", "e2e").SetWidth(220))
         pGrid.AddColumn(TGridCol.AsText("TxId", "txid").SetWidth(180))
         pGrid.AddColumn(TGridCol.AsValue("Valor", "valor").SetWidth(90).SetAlignment(taRightJustify))
         pGrid.AddColumn(TGridCol.AsText("Horário", "horario").SetWidth(140))
         pGrid.AddColumn(TGridCol.AsText("Chave", "chave").SetWidth(180))
      End Sub

      Sub BindRecebimentoColumns(pGrid As TGridView)
         pGrid.AddColumn(TGridCol.AsText("E2E", "e2e").SetWidth(180))
         pGrid.AddColumn(TGridCol.AsValue("Valor", "valor").SetWidth(80).SetAlignment(taRightJustify))
         pGrid.AddColumn(TGridCol.AsText("Horário", "horario").SetWidth(130))
         pGrid.AddColumn(TGridCol.AsValue("Devolvido", "devolvido").SetWidth(80).SetAlignment(taRightJustify))
      End Sub

      Sub BindDevolucaoColumns(pGrid As TGridView)
         pGrid.AddColumn(TGridCol.AsText("Id", "id").SetWidth(120))
         pGrid.AddColumn(TGridCol.AsValue("Valor", "valor").SetWidth(80).SetAlignment(taRightJustify))
         pGrid.AddColumn(TGridCol.AsText("Status", "status").SetWidth(130))
         pGrid.AddColumn(TGridCol.AsText("E2E", "e2e").SetWidth(160))
         pGrid.AddColumn(TGridCol.AsText("TxId", "txid").SetWidth(160))
      End Sub

      Sub BindInfoColumns(pGrid As TGridView)
         pGrid.AddColumn(TGridCol.AsText("Nome", "nome").SetWidth(120))
         pGrid.AddColumn(TGridCol.AsText("Valor", "valor").SetWidth(180))
      End Sub

      Sub ClearRows(pGrid As TGridView)
         Do While pGrid.Data.RowCount > 0
            pGrid.Data.DeleteRow(pGrid.Data.RowCount - 1)
         Loop
      End Sub

      Private Sub _fillStart(pGrid As TGridView)
         pGrid.Data.BeginUpdate()
         me.ClearRows(pGrid)
      End Sub


      Private Sub _fillDone(pGrid As TGridView)
         Dim widths As New StringList()
         Dim i As Integer
         Dim n As Integer = pGrid.Native.ColCount - 1
         For i = 0 To n
            widths.Add(CStr(pGrid.Native.ColWidth(i)))
         Next
         pGrid.Data.EndUpdate()
         ' me.ApplyCellCopy(pGrid)
         n = widths.Count - 1
         If n > pGrid.Native.ColCount - 1 Then
            n = pGrid.Native.ColCount - 1
         End If
         For i = 0 To n
            pGrid.Native.ColWidth(i) = CInt(widths.Strings(i))
         Next
         widths.Free()
      End Sub

      Sub FillCobrancas(pGrid As TGridView, pLista As PixCobrancas)
         Dim i As Integer
         Dim n As Integer
         Dim cob As PixCobrancaCompleta
         Dim row As TGridRow
         Dim idx As Integer
         me._fillStart(pGrid)
         If Assigned(pLista) Then
            If Assigned(pLista.Cobrancas) Then
               n = pLista.Cobrancas.Length - 1
               For i = 0 To n
                  cob = pLista.Cobrancas.Take(i)
                  row = pGrid.AddRow(cob.TxId)
                  idx = pGrid.Data.RowCount - 1
                  pGrid.SetValue(idx, "txid", cob.TxId)
                  pGrid.SetValue(idx, "status", PixAppFormat.StatusText(cob.Status))
                  pGrid.SetValue(idx, "valor", cob.Valor.Original)
                  pGrid.SetValue(idx, "devedor", PixAppFormat.Devedor(cob))
                  pGrid.SetValue(idx, "criacao", PixAppFormat.DateTimeText(cob.Calendario.Criacao))
                  pGrid.SetValue(idx, "chave", cob.Chave)
                  row.Editable = False
               Next
            End If
         End If
         me._fillDone(pGrid)
      End Sub

      Sub FillPix(pGrid As TGridView, pLista As PixRecebimentos)
         Dim i As Integer
         Dim n As Integer
         Dim pix As PixRecebimento
         Dim row As TGridRow
         Dim idx As Integer
         me._fillStart(pGrid)
         If Assigned(pLista) Then
            If Assigned(pLista.Pix) Then
               n = pLista.Pix.Length - 1
               For i = 0 To n
                  pix = pLista.Pix.Take(i)
                  row = pGrid.AddRow(pix.E2eId)
                  idx = pGrid.Data.RowCount - 1
                  pGrid.SetValue(idx, "e2e", pix.E2eId)
                  pGrid.SetValue(idx, "txid", pix.TxId)
                  pGrid.SetValue(idx, "valor", pix.Valor)
                  pGrid.SetValue(idx, "horario", PixAppFormat.DateTimeText(pix.Horario))
                  pGrid.SetValue(idx, "chave", pix.Chave)
                  row.Editable = False
               Next
            End If
         End If
         me._fillDone(pGrid)
      End Sub

      Sub FillRecebimentos(pGrid As TGridView, pCobranca As PixCobrancaCompleta)
         Dim i As Integer
         Dim n As Integer
         Dim pix As PixRecebimento
         Dim row As TGridRow
         Dim idx As Integer
         me._fillStart(pGrid)
         If Assigned(pCobranca) Then
            If Assigned(pCobranca.Recebimentos) Then
               n = pCobranca.Recebimentos.Length - 1
               For i = 0 To n
                  pix = pCobranca.Recebimentos.Take(i)
                  row = pGrid.AddRow(pix.E2eId)
                  idx = pGrid.Data.RowCount - 1
                  pGrid.SetValue(idx, "e2e", pix.E2eId)
                  pGrid.SetValue(idx, "valor", pix.Valor)
                  pGrid.SetValue(idx, "horario", PixAppFormat.DateTimeText(pix.Horario))
                  pGrid.SetValue(idx, "devolvido", pix.ValorDevolvido)
                  row.Editable = False
               Next
            End If
         End If
         me._fillDone(pGrid)
      End Sub

      Sub FillDevolucoes(pGrid As TGridView, pCobranca As PixCobrancaCompleta, pPix As PixRecebimento)
         Dim i As Integer
         Dim n As Integer
         me._fillStart(pGrid)
         If Assigned(pPix) Then
            me._fillDevolucoesOf(pGrid, pPix)
         ElseIf Assigned(pCobranca) Then
            If Assigned(pCobranca.Recebimentos) Then
               n = pCobranca.Recebimentos.Length - 1
               For i = 0 To n
                  me._fillDevolucoesOf(pGrid, pCobranca.Recebimentos.Take(i))
               Next
            End If
         End If
         me._fillDone(pGrid)
      End Sub

      Private Sub _fillDevolucoesOf(pGrid As TGridView, pPix As PixRecebimento)
         If Not Assigned(pPix) Then
            Exit Sub
         End If
         If Not Assigned(pPix.Devolucoes) Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = pPix.Devolucoes.Length - 1
         For i = 0 To n
            Dim item As PixDevolucao = pPix.Devolucoes.Take(i)
            Dim row As TGridRow = pGrid.AddRow(item.Id)
            Dim idx As Integer = pGrid.Data.RowCount - 1
            pGrid.SetValue(idx, "id", item.Id)
            pGrid.SetValue(idx, "valor", item.Valor)
            pGrid.SetValue(idx, "status", PixAppFormat.DevolucaoStatus(item.Status))
            pGrid.SetValue(idx, "e2e", pPix.E2eId)
            pGrid.SetValue(idx, "txid", pPix.TxId)
            row.Editable = False
         Next
      End Sub

      Sub FillInfos(pGrid As TGridView, pCobranca As PixCobrancaCompleta)
         Dim i As Integer
         Dim n As Integer
         Dim item As PixInfoAdicional
         Dim row As TGridRow
         Dim idx As Integer
         me._fillStart(pGrid)
         If Assigned(pCobranca) Then
            If Assigned(pCobranca.InfoAdicionais) Then
               n = pCobranca.InfoAdicionais.Length - 1
               For i = 0 To n
                  item = pCobranca.InfoAdicionais.Take(i)
                  row = pGrid.AddRow(item.Nome)
                  idx = pGrid.Data.RowCount - 1
                  pGrid.SetValue(idx, "nome", item.Nome)
                  pGrid.SetValue(idx, "valor", item.Valor)
                  row.Editable = False
               Next
            End If
         End If
         me._fillDone(pGrid)
      End Sub

      Sub FillDevolucoesFromPix(pGrid As TGridView, pLista As PixRecebimentos)
         Dim i As Integer
         Dim j As Integer
         Dim n As Integer
         Dim pix As PixRecebimento
         Dim item As PixDevolucao
         Dim row As TGridRow
         Dim idx As Integer
         Dim m As Integer
         me._fillStart(pGrid)
         If Assigned(pLista) Then
            If Assigned(pLista.Pix) Then
               n = pLista.Pix.Length - 1
               For i = 0 To n
                  pix = pLista.Pix.Take(i)
                  If Assigned(pix) Then
                     If Assigned(pix.Devolucoes) Then
                        m = pix.Devolucoes.Length - 1
                        For j = 0 To m
                           item = pix.Devolucoes.Take(j)
                           row = pGrid.AddRow(PixAppFormat.DevRowId(pix.E2eId, item.Id))
                           idx = pGrid.Data.RowCount - 1
                           pGrid.SetValue(idx, "id", item.Id)
                           pGrid.SetValue(idx, "valor", item.Valor)
                           pGrid.SetValue(idx, "status", PixAppFormat.DevolucaoStatus(item.Status))
                           pGrid.SetValue(idx, "e2e", pix.E2eId)
                           pGrid.SetValue(idx, "txid", pix.TxId)
                           row.Editable = False
                        Next
                     End If
                  End If
               Next
            End If
         End If
         me._fillDone(pGrid)
      End Sub

      Sub FillDevolucao(pGrid As TGridView, pItem As PixDevolucao, pE2e As String, pTxId As String)
         Dim row As TGridRow
         Dim idx As Integer
         me._fillStart(pGrid)
         If Assigned(pItem) Then
            row = pGrid.AddRow(PixAppFormat.DevRowId(pE2e, pItem.Id))
            idx = pGrid.Data.RowCount - 1
            pGrid.SetValue(idx, "id", pItem.Id)
            pGrid.SetValue(idx, "valor", pItem.Valor)
            pGrid.SetValue(idx, "status", PixAppFormat.DevolucaoStatus(pItem.Status))
            pGrid.SetValue(idx, "e2e", pE2e)
            pGrid.SetValue(idx, "txid", pTxId)
            row.Editable = False
         End If
         me._fillDone(pGrid)
      End Sub

      Function CountOfCobrancas(pLista As PixCobrancas) As Integer
         If Not Assigned(pLista) Then
            CountOfCobrancas = 0
         ElseIf Not Assigned(pLista.Cobrancas) Then
            CountOfCobrancas = 0
         Else
            CountOfCobrancas = pLista.Cobrancas.Length
         End If
      End Function

      Function CountOfPix(pLista As PixRecebimentos) As Integer
         If Not Assigned(pLista) Then
            CountOfPix = 0
         ElseIf Not Assigned(pLista.Pix) Then
            CountOfPix = 0
         Else
            CountOfPix = pLista.Pix.Length
         End If
      End Function

      Function CountOfDevolucoes(pLista As PixRecebimentos) As Integer
         Dim total As Integer = 0
         If Not Assigned(pLista) Then
            CountOfDevolucoes = 0
            Exit Function
         End If
         If Not Assigned(pLista.Pix) Then
            CountOfDevolucoes = 0
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pLista.Pix.Length - 1
         Dim pix As PixRecebimento
         For i = 0 To n
            pix = pLista.Pix.Take(i)
            If Assigned(pix) Then
               If Assigned(pix.Devolucoes) Then
                  total = total + pix.Devolucoes.Length
               End If
            End If
         Next
         CountOfDevolucoes = total
      End Function

      Function RowId(pGrid As TGridView, pNativeRow As Integer) As String
         Dim idx As Integer = pGrid.Context.Presenter.ToDataIndex(pNativeRow)
         If idx < 0 Then
            RowId = ""
            Exit Function
         End If
         Dim row As TGridRow = pGrid.Data.RowAt(idx)
         If Assigned(row) Then
            RowId = row.ID
         Else
            RowId = ""
         End If
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixAppSampleFactory
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Function Cobranca() As PixCobranca
         Dim cob As New PixCobranca()
         cob.TxId = GenerateTxID()
         cob.Valor.Original = me._randomValor()
         cob.Calendario.Expiracao = 3600
         cob.SolicitacaoPagador = "Teste PIX " & DateTime().ToString("dd/mm hh:nn:ss")
         cob.InfoAdicionais.Push(New PixInfoAdicional("origem", "pix-app"))
         cob.InfoAdicionais.Push(New PixInfoAdicional("amostra", "aleatoria"))
         Cobranca = cob
      End Function

      Private Function _randomValor() As Double
         Dim n As Integer = 1 + (DateTime().SecondOf() Mod 8)
         _randomValor = FormatValueToDouble(CStr(n) & ".25")
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
