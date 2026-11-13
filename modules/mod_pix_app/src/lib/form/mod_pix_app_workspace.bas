Imports Forms
Imports mod_forms
Imports mod_forms_topbar
Imports mod_forms_icons
Imports mod_pix_runtime
Imports mod_pix_capabilities
Imports mod_pix_filtro
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_recebimento
Imports mod_pix_recebimentos
Imports mod_pix_devolucao
Imports mod_pix_app_qrcode
Imports mod_pix_app_session
Imports mod_pix_app_adapters
Imports mod_pix_app_account
Imports mod_pix_app_browse
Imports mod_pix_app_create
Imports mod_pix_app_refund

Namespace mod_pix_app_workspace

   Delegate Sub PixAppAction()

   Class PixAppWorkspace
      Inherits TFormsWorkspace

      Private _session As PixAppSession
      Private _account As PixAppAccountPanel
      Private _tabs As PageControl
      Private _tabCob As TabSheet
      Private _tabPix As TabSheet
      Private _tabDev As TabSheet
      Private _tabNew As TabSheet
      Private _browseCob As PixAppBrowsePage
      Private _browsePix As PixAppBrowsePage
      Private _browseDev As PixAppBrowsePage
      Private _create As PixAppCreatePanel
      Private _status As StaticText
      Private _busy As Boolean
      Private _ready As Boolean
      Private _initialConta As String
      Private _initialTxId As String

      Sub New(pCodContaFinanceira As String = "", pTxId As String = "")
         MyBase.New("PIX", True)
         me._initialConta = Trim(pCodContaFinanceira)
         me._initialTxId = Trim(pTxId)
      End Sub

      Protected Overrides Sub Build()
         me._session = New PixAppSession()
         me.Size.Value = 95
         me.MaximizeOnF11 = True
         me.CloseOnOk = False
         me.Caption = "PIX"
         me.Header.Height = 38
         me.Footer.Height = 26

         me._account = New PixAppAccountPanel(me.Header, me._session)
         me._tabs = PixAppSurface.Tabs(me.Content)
         me._tabCob = PixAppSurface.Sheet(me._tabs, "Cobranças")
         me._tabPix = PixAppSurface.Sheet(me._tabs, "Recebimentos")
         me._tabDev = PixAppSurface.Sheet(me._tabs, "Devoluções")
         me._tabNew = PixAppSurface.Sheet(me._tabs, "Nova cobrança")

         me._browseCob = New PixAppBrowsePage(me._tabCob, me._session, "cob")
         me._browsePix = New PixAppBrowsePage(me._tabPix, me._session, "pix")
         me._browseDev = New PixAppBrowsePage(me._tabDev, me._session, "dev")
         me._create = New PixAppCreatePanel(me._tabNew, me._session)

         me._browseCob.OnPageChange = me._onPageChange
         me._browsePix.OnPageChange = me._onPageChange
         me._browseDev.OnPageChange = me._onPageChange
         me._create.OnRegistrar = me._onRegistrarClick
         me._tabCob.OnShow = me._onShowCob
         me._tabPix.OnShow = me._onShowPix
         me._tabDev.OnShow = me._onShowDev
         me._tabNew.OnShow = me._onShowNew

         me._status = PixAppSurface.Hint(me.Footer, "Selecione uma conta financeira para começar.")

         me._session.OnAccountChanged = me._onAccountChanged
         me._session.OnListChanged = me._onListChanged
         me._session.OnSelectionChanged = me._onSelectionChanged
         me._session.OnStatus = me._onStatus

         me._tabs.TabIndex = 0
         me._tabs.ActivePageIndex = 0
         
         me._buildActions()
         me.TopBar.Ok.Visible = False
         me.TopBar.Cancel.Caption = "Fechar"
         me.TopBar.Realign()
         me.OnResize = me._onResize
         me._ready = True
         me._refreshActions()
      End Sub

      Protected Overrides Sub AfterShow()
         me._syncLayout()
         If me._initialTxId <> "" Then
            me._browseCob.Filters.SetLookupId(me._initialTxId)
            If me._initialConta = "" Then
               me._session.SetStatus("Selecione uma conta financeira para consultar o TxId " & me._initialTxId & ".")
            End If
         End If
         If me._initialConta <> "" Then
            me._account.SetCodigo(me._initialConta)
         End If
         me._account.Focus()
      End Sub

      Private Sub _buildActions()
         me.TopBar.AddAction("buscar", "Buscar", "", "Listar ou consultar pelo identificador informado nos filtros", 1, "F5").OnClick = me._onBuscar
         me.TopBar.AddAction("gerar", "Gerar", "", "Abrir a aba Nova cobrança com dados de teste editáveis", 2, "F4").OnClick = me._onGerar
         me.TopBar.AddAction("registrar", "Registrar", "", "Registrar a cobrança preenchida na aba Nova cobrança", 3, "F7").OnClick = me._onRegistrarClick
         me.TopBar.AddAction("consultar", "Consultar", "", "Atualizar o item selecionado pelo TxId, E2E ou Id", 4, "F2").OnClick = me._onConsultar
         me.TopBar.AddAction("qrcode", "QR Code", "", "Abrir o QR Code da cobrança selecionada", 5, "F6").OnClick = me._onQrCode
         me.TopBar.AddAction("devolver", "Devolver", "", "Registrar devolução do recebimento selecionado", 6, "F8").OnClick = me._onDevolver
         me.TopBar.AddAction("cancelar", "Cancelar", "", "Cancelar a cobrança selecionada", 7, "F3").OnClick = me._onCancelar
      End Sub

      Private Sub _onResize(pSender As TObject)
         me._syncLayout()
      End Sub

      Private Sub _syncLayout()
         If Assigned(me._browseCob) Then
            me._browseCob.Sync(me.Content.Width)
         End If
         If Assigned(me._browsePix) Then
            me._browsePix.Sync(me.Content.Width)
         End If
         If Assigned(me._browseDev) Then
            me._browseDev.Sync(me.Content.Width)
         End If
         If Assigned(me._create) Then
            me._create.Sync()
         End If
      End Sub

      Private Sub _onShowCob(pSender As TObject)
         me._applyTab("cob")
      End Sub

      Private Sub _onShowPix(pSender As TObject)
         me._applyTab("pix")
      End Sub

      Private Sub _onShowDev(pSender As TObject)
         me._applyTab("dev")
      End Sub

      Private Sub _onShowNew(pSender As TObject)
         me._applyTab("new")
      End Sub

      Private Sub _applyTab(pMode As String)
         If Not me._ready Then
            Exit Sub
         End If
         me._session.SetMode(pMode)
         If pMode = "new" Then
            me._create.ApplyChave()
         End If
         me._refreshActions()
         me._syncLayout()
      End Sub

      Private Sub _showTab(pMode As String)
         If pMode = "pix" Then
            me._tabs.ActivePageIndex = 1
         ElseIf pMode = "dev" Then
            me._tabs.ActivePageIndex = 2
         ElseIf pMode = "new" Then
            me._tabs.ActivePageIndex = 3
         Else
            me._tabs.ActivePageIndex = 0
         End If
         me._applyTab(pMode)
      End Sub

      Private Function _browse() As PixAppBrowsePage
         If me._session.IsPixMode() Then
            _browse = me._browsePix
         ElseIf me._session.IsDevolucaoMode() Then
            _browse = me._browseDev
         Else
            _browse = me._browseCob
         End If
      End Function

      Private Sub _onAccountChanged(pSender As TObject)
         If me._session.HasService() Then
            If me._initialTxId <> "" Then
               me._consultInitialTxId()
            ElseIf me._session.IsCreateMode() Then
               me._create.FillSample()
            End If
         End If
         me._refreshActions()
      End Sub

      Private Sub _consultInitialTxId()
         Dim txId As String = me._initialTxId
         me._initialTxId = ""
         me._showTab("cob")
         me._browseCob.Filters.SetLookupId(txId)
         me._run("Consultando TxId...", me._buscar)
      End Sub

      Private Sub _onListChanged(pSender As TObject)
         me._browseCob.Reload()
         me._browsePix.Reload()
         me._browseDev.Reload()
         me._refreshActions()
      End Sub

      Private Sub _onSelectionChanged(pSender As TObject)
         If Not me._session.IsCreateMode() Then
            me._browse().Bind()
         End If
         me._refreshActions()
      End Sub

      Private Sub _onStatus(pText As String)
         me._status.Text = pText
         me._status.Caption = pText
      End Sub

      Private Sub _refreshActions()
         Dim ready As Boolean = me._session.HasService() AndAlso Not me._busy
         Dim cob As Boolean = ready AndAlso me._session.IsCobrancaMode() AndAlso Assigned(me._session.Cobranca())
         Dim pix As Boolean = ready AndAlso me._session.IsPixMode() AndAlso Assigned(me._session.Pix())
         Dim dev As Boolean = ready AndAlso me._session.IsDevolucaoMode() AndAlso Assigned(me._session.Devolucao())
         Dim creating As Boolean = me._session.IsCreateMode()
         Dim caps As PixCapabilities = me._session.Capabilities()
         Dim canList As Boolean = False
         If Assigned(caps) Then
            If me._session.IsCobrancaMode() Then
               canList = caps.CanCobrancaListar Or caps.CanCobrancaConsultar
            ElseIf me._session.IsPixMode() Then
               canList = caps.CanPixListar Or caps.CanPixConsultar
            ElseIf me._session.IsDevolucaoMode() Then
               canList = caps.CanPixListar Or caps.CanDevolucaoConsultar Or caps.CanPixConsultar
            End If
         End If
         me.TopBar.Item("buscar").Enabled = ready AndAlso canList AndAlso Not creating
         me.TopBar.Item("gerar").Enabled = ready AndAlso Assigned(caps) AndAlso caps.CanCobrancaRegistrar
         me.TopBar.Item("registrar").Enabled = ready AndAlso creating AndAlso Assigned(caps) AndAlso caps.CanCobrancaRegistrar
         me.TopBar.Item("consultar").Enabled = (cob AndAlso Assigned(caps) AndAlso caps.CanCobrancaConsultar) Or (pix AndAlso Assigned(caps) AndAlso caps.CanPixConsultar) Or (dev AndAlso Assigned(caps) AndAlso caps.CanDevolucaoConsultar)
         me.TopBar.Item("qrcode").Enabled = cob AndAlso (me._session.Cobranca().PixCopiaECola <> "")
         me.TopBar.Item("devolver").Enabled = Assigned(caps) AndAlso caps.CanDevolucaoRegistrar AndAlso me._canDevolver(cob, pix)
         me.TopBar.Item("cancelar").Enabled = cob AndAlso Assigned(caps) AndAlso caps.CanCobrancaCancelar AndAlso me._session.Cobranca().IsActive()
      End Sub

      Private Function _hasRecebimento() As Boolean
         If Not Assigned(me._session.Cobranca()) Then
            _hasRecebimento = False
            Exit Function
         End If
         If Not Assigned(me._session.Cobranca().Recebimentos) Then
            _hasRecebimento = False
            Exit Function
         End If
         _hasRecebimento = me._session.Cobranca().Recebimentos.Length > 0
      End Function

      Private Function _canDevolver(pCob As Boolean, pPix As Boolean) As Boolean
         If pCob Then
            _canDevolver = me._hasRecebimento()
            Exit Function
         End If
         If pPix Then
            _canDevolver = me._session.Pix().TxId <> ""
            Exit Function
         End If
         _canDevolver = False
      End Function

      Private Sub _onBuscar(pSender As TObject)
         me._run("Buscando...", me._buscarReset)
      End Sub

      Private Sub _onGerar(pSender As TObject)
         me._showTab("new")
         me._create.FillSample()
         me._session.SetStatus("Preencha ou ajuste os dados da cobrança e clique em Registrar.")
      End Sub

      Private Sub _onRegistrarClick(pSender As TObject)
         me._run("Registrando cobrança...", me._registrar)
      End Sub

      Private Sub _onConsultar(pSender As TObject)
         me._run("Consultando...", me._consultar)
      End Sub

      Private Sub _onQrCode(pSender As TObject)
         me._run("Abrindo QR Code...", me._qrcode)
      End Sub

      Private Sub _onDevolver(pSender As TObject)
         me._run("Devolução...", me._devolver)
      End Sub

      Private Sub _onCancelar(pSender As TObject)
         me._run("Cancelando...", me._cancelar)
      End Sub

      Private Sub _onPageChange(pSender As TObject)
         me._run("Buscando...", me._buscar)
      End Sub

      Private Sub _run(pBusyText As String, pAction As PixAppAction)
         If me._busy Then
            Exit Sub
         End If
         If Not me._session.HasService() Then
            Forms.MessageBox.Show("Selecione uma conta financeira antes de continuar.")
            Exit Sub
         End If
         me._busy = True
         me._refreshActions()
         me._session.SetStatus(pBusyText)
         Try
            pAction()
         Catch ex As Exception
            Forms.MessageBox.Show(ex._GetMessage())
            me._session.SetStatus("Falha: " & ex._GetMessage())
         End Try
         me._busy = False
         me._refreshActions()
      End Sub

      Private Sub _buscarReset()
         me._browse().Filters.SetPageIndex(0)
         me._buscar()
      End Sub

      Private Sub _buscar()
         If me._session.IsCreateMode() Then
            Exit Sub
         End If
         If me._session.IsCobrancaMode() Then
            me._buscarCobrancas()
         ElseIf me._session.IsPixMode() Then
            me._buscarPix()
         Else
            me._buscarDevolucoes()
         End If
      End Sub

      Private Sub _buscarCobrancas()
         Dim lookup As String = me._browseCob.Filters.LookupId()
         Dim cob As PixCobrancaCompleta
         Dim lista As PixCobrancas
         Dim filtro As PixFiltro
         Dim count As Integer
         If lookup <> "" Then
            cob = me._session.Service().Cobranca.Consultar(lookup)
            lista = New PixCobrancas()
            me._session.ReplaceCobrancas(lista)
            If Not Assigned(cob) Then
               me._session.SetStatus("Nenhuma cobrança encontrada para o TxId informado.")
               Exit Sub
            End If
            me._session.AdoptCobranca(cob)
            me._session.SetStatus("Cobrança " & cob.TxId & " consultada.")
         Else
            filtro = me._browseCob.Filters.Filtro()
            lista = me._session.Service().Cobranca.Listar(filtro)
            count = 0
            If Assigned(lista.Cobrancas) Then
               count = lista.Cobrancas.Length
            End If
            me._session.ReplaceCobrancas(lista)
            me._session.SetStatus(CStr(count) & " cobrança(s) nesta página.")
            filtro.Free()
         End If
      End Sub

      Private Sub _buscarPix()
         Dim lookup As String = me._browsePix.Filters.LookupId()
         Dim pix As PixRecebimento
         Dim lista As PixRecebimentos
         Dim filtro As PixFiltro
         Dim count As Integer
         If lookup <> "" Then
            pix = me._session.Service().Recebimento.Consultar(lookup)
            lista = New PixRecebimentos()
            me._session.ReplacePix(lista)
            me._session.AdoptPix(pix)
            me._session.SetStatus("PIX " & pix.E2eId & " consultado.")
         Else
            filtro = me._browsePix.Filters.Filtro()
            lista = me._session.Service().Recebimento.Listar(filtro)
            count = 0
            If Assigned(lista.Pix) Then
               count = lista.Pix.Length
            End If
            me._session.ReplacePix(lista)
            me._session.SetStatus(CStr(count) & " PIX nesta página.")
            filtro.Free()
         End If
      End Sub

      Private Sub _buscarDevolucoes()
         Dim e2e As String = me._browseDev.Filters.LookupId()
         Dim idDev As String = me._browseDev.Filters.LookupDevId()
         Dim devolucao As PixDevolucao
         Dim pix As PixRecebimento
         Dim lista As PixRecebimentos
         Dim filtro As PixFiltro
         Dim count As Integer
         Dim i As Integer
         Dim n As Integer
         Dim item As PixRecebimento
         If e2e <> "" AndAlso idDev <> "" Then
            devolucao = me._session.Service().Devolucao.Consultar(e2e, idDev)
            lista = New PixRecebimentos()
            me._session.ReplaceDevPix(lista)
            me._session.AdoptDevolucao(devolucao, e2e, "")
            me._session.SetStatus("Devolução " & devolucao.Id & " consultada.")
         ElseIf e2e <> "" Then
            pix = me._session.Service().Recebimento.Consultar(e2e)
            lista = New PixRecebimentos()
            lista.Pix.Push(pix)
            me._session.ReplaceDevPix(lista)
            count = 0
            If Assigned(pix.Devolucoes) Then
               count = pix.Devolucoes.Length
            End If
            me._session.SetStatus(CStr(count) & " devolução(ões) neste recebimento.")
         Else
            filtro = me._browseDev.Filters.Filtro()
            lista = me._session.Service().Recebimento.Listar(filtro)
            count = 0
            If Assigned(lista.Pix) Then
               n = lista.Pix.Length - 1
               For i = 0 To n
                  item = lista.Pix.Take(i)
                  If Assigned(item) Then
                     If Assigned(item.Devolucoes) Then
                        count = count + item.Devolucoes.Length
                     End If
                  End If
               Next
            End If
            me._session.ReplaceDevPix(lista)
            me._session.SetStatus(CStr(count) & " devolução(ões) nesta página de recebimentos.")
            filtro.Free()
         End If
      End Sub

      Private Sub _registrar()
         Dim dados As PixCobranca = me._create.ReadCobranca()
         Dim cob As PixCobrancaCompleta = me._session.Service().Cobranca.Registrar(dados)
         dados.Free()
         me._session.AdoptCobranca(cob)
         me._showTab("cob")
         me._session.SetStatus("Cobrança " & cob.TxId & " registrada (" & cob.Valor.Original.ToString("0.00") & ").")
         If cob.PixCopiaECola <> "" Then
            If Forms.MessageBox.Confirmation("Cobrança registrada. Abrir o QR Code para pagamento?") Then
               me._openQr(cob)
            End If
         End If
      End Sub

      Private Sub _consultar()
         Dim cob As PixCobrancaCompleta
         Dim pix As PixRecebimento
         Dim devolucao As PixDevolucao
         If me._session.IsCobrancaMode() Then
            If Not Assigned(me._session.Cobranca()) Then
               Throw New Exception("Selecione uma cobrança ou informe o TxId nos filtros.")
            End If
            cob = me._session.Service().Cobranca.Consultar(me._session.Cobranca().TxId)
            me._session.AdoptCobranca(cob)
            me._session.SetStatus("Cobrança " & cob.TxId & " atualizada (" & cob.Status.AsString & ").")
         ElseIf me._session.IsPixMode() Then
            If Not Assigned(me._session.Pix()) Then
               Throw New Exception("Selecione um PIX ou informe o E2E nos filtros.")
            End If
            pix = me._session.Service().Recebimento.Consultar(me._session.Pix().E2eId)
            me._session.AdoptPix(pix)
            me._session.SetStatus("PIX " & pix.E2eId & " atualizado.")
         ElseIf me._session.IsDevolucaoMode() Then
            If Not Assigned(me._session.Devolucao()) Then
               Throw New Exception("Selecione uma devolução ou informe E2E e Id nos filtros.")
            End If
            If me._session.DevE2e() = "" Then
               Throw New Exception("Informe o E2E da devolução.")
            End If
            devolucao = me._session.Service().Devolucao.Consultar(me._session.DevE2e(), me._session.Devolucao().Id)
            me._session.AdoptDevolucao(devolucao, me._session.DevE2e(), me._session.DevTxId())
            me._session.SetStatus("Devolução " & devolucao.Id & " atualizada (" & devolucao.Status.AsString & ").")
         Else
            Throw New Exception("Abra a aba de Cobranças, Recebimentos ou Devoluções para consultar.")
         End If
      End Sub

      Private Sub _qrcode()
         If Not Assigned(me._session.Cobranca()) Then
            Throw New Exception("Selecione uma cobrança no grid.")
         End If
         me._openQr(me._session.Cobranca())
      End Sub

      Private Sub _openQr(pCobranca As PixCobrancaCompleta)
         Dim qr As New PixAppQrCode(me._session.Service(), "Pagamento com Pix")
         qr.Show(pCobranca)
         qr.Free()
         me._session.RefreshUi()
      End Sub

      Private Sub _devolver()
         Dim dialog As PixAppRefundDialog
         Dim devolucao As PixDevolucao
         Dim txId As String
         Dim e2e As String
         Dim cob As PixCobrancaCompleta
         Dim pix As PixRecebimento
         If me._session.IsCobrancaMode() Then
            If Not Assigned(me._session.Cobranca()) Then
               Throw New Exception("Selecione uma cobrança no grid.")
            End If
            If Not me._hasRecebimento() Then
               Throw New Exception("Essa cobrança ainda não possui recebimentos para devolver.")
            End If
            dialog = New PixAppRefundDialog(me._session.Cobranca())
         Else
            If Not Assigned(me._session.Pix()) Then
               Throw New Exception("Selecione um PIX no grid.")
            End If
            If me._session.Pix().TxId = "" Then
               Throw New Exception("Esse PIX não possui TxId para registrar a devolução.")
            End If
            dialog = New PixAppRefundDialog(me._session.Pix())
         End If
         dialog.Show()
         If Not dialog.Accepted Then
            dialog.Free()
            me._session.SetStatus("Devolução cancelada.")
            Exit Sub
         End If
         devolucao = me._session.Service().Devolucao.Registrar(dialog.TxId, dialog.EndToEndId, dialog.IdDevolucao, dialog.Valor)
         txId = dialog.TxId
         e2e = dialog.EndToEndId
         dialog.Free()
         If me._session.IsCobrancaMode() Then
            cob = me._session.Service().Cobranca.Consultar(txId)
            me._session.AdoptCobranca(cob)
         Else
            pix = me._session.Service().Recebimento.Consultar(e2e)
            me._session.AdoptPix(pix)
         End If
         me._session.SetStatus("Devolução " & devolucao.Id & " registrada (" & devolucao.Status.AsString & ").")
         devolucao.Free()
      End Sub

      Private Sub _cancelar()
         If Not Assigned(me._session.Cobranca()) Then
            Throw New Exception("Selecione uma cobrança no grid.")
         End If
         If Not Forms.MessageBox.Confirmation("Cancelar a cobrança " & me._session.Cobranca().TxId & "?") Then
            me._session.SetStatus("Cancelamento ignorado.")
            Exit Sub
         End If
         Dim cob As PixCobrancaCompleta = me._session.Service().Cobranca.Cancelar(me._session.Cobranca().TxId)
         me._session.AdoptCobranca(cob)
         me._session.SetStatus("Cobrança " & cob.TxId & " cancelada.")
      End Sub

      Sub Free()
         me._ready = False
         If Assigned(me._session) Then
            me._session.OnAccountChanged = Null
            me._session.OnListChanged = Null
            me._session.OnSelectionChanged = Null
            me._session.OnStatus = Null
         End If
         If Assigned(me._browseCob) Then
            me._browseCob.Free()
            me._browseCob = Null
         End If
         If Assigned(me._browsePix) Then
            me._browsePix.Free()
            me._browsePix = Null
         End If
         If Assigned(me._browseDev) Then
            me._browseDev.Free()
            me._browseDev = Null
         End If
         If Assigned(me._create) Then
            me._create.Free()
            me._create = Null
         End If
         If Assigned(me._account) Then
            me._account.Free()
            me._account = Null
         End If
         If Assigned(me._session) Then
            me._session.Free()
            me._session = Null
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
