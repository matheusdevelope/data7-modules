Imports Forms
Imports mod_tobject
Imports mod_editors
Imports mod_editors_text
Imports mod_editors_memo
Imports mod_grid_view
Imports mod_pix_cobranca_completa
Imports mod_pix_recebimento
Imports mod_pix_devolucao
Imports mod_pix_app_adapters
Imports mod_pix_app_session

Namespace mod_pix_app_detail

   Class PixAppDetailPanel
      Inherits TTObject

      Private _kind As String
      Private _frame As PixAppGroup
      Private _host As PageControl
      Private _scroll As TForm
      Private _content As PageControl
      Private _fields As PageControl
      Private _txid As TTextEditor
      Private _status As TTextEditor
      Private _valor As TTextEditor
      Private _chave As TTextEditor
      Private _devedor As TTextEditor
      Private _criacao As TTextEditor
      Private _location As TTextEditor
      Private _copia As TMemoEditor
      Private _recvFrame As PixAppGroup
      Private _devFrame As PixAppGroup
      Private _infoFrame As PixAppGroup
      Private _recv As TGridView
      Private _devs As TGridView
      Private _infos As TGridView
      Private _session As PixAppSession
      Private _mapper As PixAppGridMapper

      Sub New(pParent As TWinControl, pSession As PixAppSession, pKind As String)
         MyBase.New()
         me._session = pSession
         me._kind = LCase(Trim(pKind))
         me._mapper = New PixAppGridMapper()
         me._frame = New PixAppGroup(pParent, "Detalhes", alRight, 0, 430)
         me._host = me._frame.Host
         me._scroll = PixAppSurface.ScrollHost(me._host)
         me._scroll.OnResize = me._onScrollResize
         me._content = PixAppSurface.Page(me._scroll, alTop, 750)

         ' alTop coloca o último controle no topo: grids primeiro, campos por último.
         me._infoFrame = New PixAppGroup(me._content, "Informações adicionais", alTop, 120)
         me._infos = New TGridView(me._infoFrame.Host)
         me._mapper.PrepareReadonly(me._infos, False)
         me._mapper.BindInfoColumns(me._infos)
         me._infos.Prepare()
         ' me._mapper.ApplyCellCopy(me._infos)

         me._devFrame = New PixAppGroup(me._content, "Devoluções", alTop, 120)
         me._devs = New TGridView(me._devFrame.Host)
         me._mapper.PrepareReadonly(me._devs, False)
         me._mapper.BindDevolucaoColumns(me._devs)
         me._devs.Prepare()
         ' me._mapper.ApplyCellCopy(me._devs)

         me._recvFrame = New PixAppGroup(me._content, "Recebimentos", alTop, 120)
         me._recv = New TGridView(me._recvFrame.Host)
         me._mapper.PrepareReadonly(me._recv, False)
         me._mapper.BindRecebimentoColumns(me._recv)
         me._recv.Prepare()
         ' me._mapper.ApplyCellCopy(me._recv)

         me._fields = PixAppSurface.Page(me._content, alTop, 250)
         me._txid = me._field("TxId")
         me._status = me._field("Status")
         me._valor = me._field("Valor")
         me._chave = me._field("Chave")
         me._devedor = me._field("Devedor")
         me._criacao = me._field("Criação")
         me._location = me._field("Location")
         me._copia = New TMemoEditor(me._fields, "Copia e cola")
         me._copia.Align = alTop
         me._copia.LabelPlacement = TLabelPlacement.Left()
         me._copia.LabelWidth = 90
         me._copia.EditorHeight = 48
         me._copia.WordWrap = True
         me._copia.OnlyRead = True

         me._applyKindLayout()
         me.Clear()
         me.Sync()
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Sub Fit(pTotalWidth As Integer)
         Dim width As Integer = CInt(pTotalWidth * 0.38)
         If width < 360 Then
            width = 360
         End If
         If width > 520 Then
            width = 520
         End If
         If me._frame.Shell.Width = width Then
            Exit Sub
         End If
         me._frame.Shell.Width = width
         me.Sync()
      End Sub

      Sub Sync()
         If Assigned(me._frame) Then
            me._frame.Sync()
         End If
         If Assigned(me._recvFrame) Then
            me._recvFrame.Sync()
         End If
         If Assigned(me._devFrame) Then
            me._devFrame.Sync()
         End If
         If Assigned(me._infoFrame) Then
            me._infoFrame.Sync()
         End If
         me._fitContent()
      End Sub

      Private Sub _stackContent()
         If Assigned(me._infoFrame) Then
            If me._infoFrame.Shell.Visible Then
               me._infoFrame.Shell.Align = alTop
            End If
         End If
         If Assigned(me._devFrame) Then
            If me._devFrame.Shell.Visible Then
               me._devFrame.Shell.Align = alTop
            End If
         End If
         If Assigned(me._recvFrame) Then
            If me._recvFrame.Shell.Visible Then
               me._recvFrame.Shell.Align = alTop
            End If
         End If
         If Assigned(me._fields) Then
            me._fields.Align = alTop
         End If
      End Sub

      Private Sub _fitContent()
         Dim height As Integer
         If Not Assigned(me._content) Then
            Exit Sub
         End If
         height = 8
         If Assigned(me._fields) Then
            height = height + me._fields.Height
         End If
         If Assigned(me._recvFrame) Then
            If me._recvFrame.Shell.Visible Then
               height = height + me._recvFrame.Shell.Height
            End If
         End If
         If Assigned(me._devFrame) Then
            If me._devFrame.Shell.Visible Then
               height = height + me._devFrame.Shell.Height
            End If
         End If
         If Assigned(me._infoFrame) Then
            If me._infoFrame.Shell.Visible Then
               height = height + me._infoFrame.Shell.Height
            End If
         End If
         If me._content.Height <> height Then
            me._content.Height = height
         End If
      End Sub

      Private Sub _onScrollResize(pSender As TObject)
         me.Sync()
      End Sub

      Private Function _field(pCaption As String) As TTextEditor
         Dim editor As New TTextEditor(me._fields, pCaption)
         editor.Align = alTop
         editor.LabelPlacement = TLabelPlacement.Left()
         editor.LabelWidth = 90
         editor.OnlyRead = True
         _field = editor
      End Function

      Private Sub _applyKindLayout()
         If me._kind = "pix" Then
            me._txid.Caption = "TxId"
            me._status.Caption = "E2E"
            me._chave.Caption = "Chave"
            me._devedor.Caption = "Devolvido"
            me._criacao.Caption = "Horário"
            me._location.Caption = "Location"
            PixAppSurface.Show(me._copia.Host, False, alTop)
            PixAppSurface.Show(me._recvFrame.Shell, False, alTop)
            PixAppSurface.Show(me._infoFrame.Shell, False, alTop)
            PixAppSurface.Show(me._devFrame.Shell, True, alTop)
         ElseIf me._kind = "dev" Then
            me._txid.Caption = "TxId"
            me._status.Caption = "Status"
            me._chave.Caption = "E2E"
            me._devedor.Caption = "Id"
            me._criacao.Caption = "Horário"
            me._location.Caption = "Motivo"
            me._copia.Caption = "RtrId"
            PixAppSurface.Show(me._copia.Host, True, alTop)
            PixAppSurface.Show(me._recvFrame.Shell, False, alTop)
            PixAppSurface.Show(me._infoFrame.Shell, False, alTop)
            PixAppSurface.Show(me._devFrame.Shell, True, alTop)
         Else
            PixAppSurface.Show(me._copia.Host, True, alTop)
            PixAppSurface.Show(me._recvFrame.Shell, True, alTop)
            PixAppSurface.Show(me._devFrame.Shell, True, alTop)
            PixAppSurface.Show(me._infoFrame.Shell, True, alTop)
         End If
         me._stackContent()
      End Sub

      Sub Bind()
         If me._kind = "cob" Then
            me._bindCobranca(me._session.Cobranca())
         ElseIf me._kind = "pix" Then
            me._bindPix(me._session.Pix())
         Else
            me._bindDev(me._session.Devolucao())
         End If
      End Sub

      Sub Clear()
         me._txid.Text = ""
         me._status.Text = ""
         me._valor.Text = ""
         me._chave.Text = ""
         me._devedor.Text = ""
         me._criacao.Text = ""
         me._location.Text = ""
         me._copia.Text = ""
         me._mapper.FillRecebimentos(me._recv, Null)
         me._mapper.FillDevolucoes(me._devs, Null, Null)
         me._mapper.FillInfos(me._infos, Null)
      End Sub

      Private Sub _bindCobranca(pCobranca As PixCobrancaCompleta)
         If Not Assigned(pCobranca) Then
            me.Clear()
            Exit Sub
         End If
         me._txid.Text = pCobranca.TxId
         me._status.Text = PixAppFormat.StatusText(pCobranca.Status)
         me._valor.Text = PixAppFormat.Money(pCobranca.Valor.Original)
         me._chave.Text = pCobranca.Chave
         me._devedor.Text = PixAppFormat.Devedor(pCobranca)
         me._criacao.Text = PixAppFormat.DateTimeText(pCobranca.Calendario.Criacao)
         me._location.Text = pCobranca.Location
         me._copia.Text = pCobranca.PixCopiaECola
         me._mapper.FillRecebimentos(me._recv, pCobranca)
         me._mapper.FillDevolucoes(me._devs, pCobranca, Null)
         me._mapper.FillInfos(me._infos, pCobranca)
      End Sub

      Private Sub _bindPix(pPix As PixRecebimento)
         If Not Assigned(pPix) Then
            me.Clear()
            Exit Sub
         End If
         me._txid.Text = pPix.TxId
         me._status.Text = pPix.E2eId
         me._valor.Text = PixAppFormat.Money(pPix.Valor)
         me._chave.Text = pPix.Chave
         me._devedor.Text = PixAppFormat.Money(pPix.ValorDevolvido)
         me._criacao.Text = PixAppFormat.DateTimeText(pPix.Horario)
         me._location.Text = ""
         me._copia.Text = ""
         me._mapper.FillDevolucoes(me._devs, Null, pPix)
      End Sub

      Private Sub _bindDev(pItem As PixDevolucao)
         If Not Assigned(pItem) Then
            me.Clear()
            Exit Sub
         End If
         me._txid.Text = me._session.DevTxId()
         me._status.Text = PixAppFormat.DevolucaoStatus(pItem.Status)
         me._valor.Text = PixAppFormat.Money(pItem.Valor)
         me._chave.Text = me._session.DevE2e()
         me._devedor.Text = pItem.Id
         me._criacao.Text = PixAppFormat.DateTimeText(pItem.Horario.Solicitacao)
         me._location.Text = pItem.Motivo
         me._copia.Text = pItem.RtrId
         me._mapper.FillDevolucao(me._devs, pItem, me._session.DevE2e(), me._session.DevTxId())
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._txid) Then
            me._txid.Free()
         End If
         If Assigned(me._status) Then
            me._status.Free()
         End If
         If Assigned(me._valor) Then
            me._valor.Free()
         End If
         If Assigned(me._chave) Then
            me._chave.Free()
         End If
         If Assigned(me._devedor) Then
            me._devedor.Free()
         End If
         If Assigned(me._criacao) Then
            me._criacao.Free()
         End If
         If Assigned(me._location) Then
            me._location.Free()
         End If
         If Assigned(me._copia) Then
            me._copia.Free()
         End If
         If Assigned(me._recv) Then
            me._recv.Free()
         End If
         If Assigned(me._devs) Then
            me._devs.Free()
         End If
         If Assigned(me._infos) Then
            me._infos.Free()
         End If
         If Assigned(me._mapper) Then
            me._mapper.Free()
         End If
         If Assigned(me._recvFrame) Then
            me._recvFrame.Free()
         End If
         If Assigned(me._devFrame) Then
            me._devFrame.Free()
         End If
         If Assigned(me._infoFrame) Then
            me._infoFrame.Free()
         End If
         If Assigned(me._scroll) Then
            me._scroll.OnResize = Null
            me._scroll.Free()
            me._scroll = Null
         End If
         If Assigned(me._frame) Then
            me._frame.Free()
         End If
         me._session = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
