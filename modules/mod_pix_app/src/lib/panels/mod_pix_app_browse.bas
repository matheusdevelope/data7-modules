Imports Forms
Imports mod_tobject
Imports mod_pix_paginacao
Imports mod_pix_app_adapters
Imports mod_pix_app_session
Imports mod_pix_app_filters
Imports mod_pix_app_list
Imports mod_pix_app_detail
Imports mod_pix_app_pager

Namespace mod_pix_app_browse

   Class PixAppBrowsePage
      Inherits TTObject

      Private _kind As String
      Private _session As PixAppSession
      Private _filters As PixAppFilterPanel
      Private _pager As PixAppPager
      Private _body As PageControl
      Private _list As PixAppListPanel
      Private _detail As PixAppDetailPanel
      Private _mapper As PixAppGridMapper

      OnPageChange As TNotifyEvent

      Sub New(pParent As TWinControl, pSession As PixAppSession, pKind As String)
         MyBase.New()
         me._session = pSession
         me._kind = LCase(Trim(pKind))
         me._mapper = New PixAppGridMapper()
         me._filters = New PixAppFilterPanel(pParent, pSession, me._kind)
         me._pager = New PixAppPager(pParent)
         me._pager.OnChange = me._onPager
         me._body = PixAppSurface.Page(pParent, alClient)
         me._detail = New PixAppDetailPanel(me._body, pSession, me._kind)
         me._list = New PixAppListPanel(me._body, pSession, me._kind)
      End Sub

      Function Kind() As String
         Kind = me._kind
      End Function

      Function Filters() As PixAppFilterPanel
         Filters = me._filters
      End Function

      Sub Sync(pTotalWidth As Integer)
         If Assigned(me._filters) Then
            me._filters.Sync()
         End If
         If Assigned(me._detail) Then
            me._detail.Fit(pTotalWidth)
         End If
         If Assigned(me._list) Then
            me._list.Sync()
         End If
      End Sub

      Sub Reload()
         If Assigned(me._list) Then
            me._list.Reload()
         End If
         me.BindPager()
      End Sub

      Sub Bind()
         If Assigned(me._detail) Then
            me._detail.Bind()
         End If
      End Sub

      Sub BindPager()
         Dim pag As PixPaginacao
         Dim total As Integer = 0
         Dim returned As Integer = 0
         Dim pageSize As Integer = me._filters.Itens()
         Dim byId As Boolean = me._filters.HasLookup()
         If me._kind = "cob" Then
            pag = me._session.PaginacaoCobrancas()
            returned = me._mapper.CountOfCobrancas(me._session.ListaCobrancas())
         ElseIf me._kind = "pix" Then
            pag = me._session.PaginacaoPix()
            returned = me._mapper.CountOfPix(me._session.ListaPix())
         Else
            pag = me._session.PaginacaoDev()
            returned = me._mapper.CountOfDevolucoes(me._session.ListaDevPix())
            If returned = 0 Then
               If Assigned(me._session.Devolucao()) Then
                  returned = 1
               End If
            End If
         End If
         If Assigned(pag) Then
            total = pag.TotalItens
            If pag.ItensPorPagina > 0 Then
               pageSize = pag.ItensPorPagina
            End If
            me._pager.Bind(me._filters.PageIndex(), pag.QuantidadePaginas, total, returned, pageSize, byId)
         Else
            me._pager.Bind(me._filters.PageIndex(), 0, returned, returned, pageSize, byId)
         End If
      End Sub

      Private Sub _onPager(pSender As TObject)
         me._filters.SetPageIndex(me._pager.PageIndex())
         If me.OnPageChange <> NULL Then
            me.OnPageChange(me)
         End If
      End Sub

      Overrides Sub Dispose()
         me.OnPageChange = Null
         If Assigned(me._list) Then
            me._list.Free()
            me._list = Null
         End If
         If Assigned(me._detail) Then
            me._detail.Free()
            me._detail = Null
         End If
         If Assigned(me._pager) Then
            me._pager.Free()
            me._pager = Null
         End If
         If Assigned(me._filters) Then
            me._filters.Free()
            me._filters = Null
         End If
         If Assigned(me._mapper) Then
            me._mapper.Free()
            me._mapper = Null
         End If
         me._body = Null
         me._session = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
