Imports Forms
Imports mod_tobject
Imports mod_grid_view
Imports mod_grid_row
Imports mod_pix_app_adapters
Imports mod_pix_app_session

Namespace mod_pix_app_list

   Class PixAppListPanel
      Inherits TTObject

      Private _kind As String
      Private _frame As PixAppGroup
      Private _host As PageControl
      Private _grid As TGridView
      Private _session As PixAppSession
      Private _mapper As PixAppGridMapper

      Sub New(pParent As TWinControl, pSession As PixAppSession, pKind As String)
         MyBase.New()
         me._session = pSession
         me._kind = LCase(Trim(pKind))
         me._mapper = New PixAppGridMapper()
         me._frame = New PixAppGroup(pParent, "Resultados", alClient)
         me._host = me._frame.Host
         me._grid = New TGridView(me._host)
         me._mapper.PrepareReadonly(me._grid, True)
         If me._kind = "cob" Then
            me._mapper.BindCobrancaColumns(me._grid)
         ElseIf me._kind = "pix" Then
            me._mapper.BindPixColumns(me._grid)
         Else
            me._mapper.BindDevolucaoColumns(me._grid)
         End If
         me._grid.Prepare()
         ' me._mapper.ApplyCellCopy(me._grid)
         me._bindNative()
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Sub Sync()
         If Assigned(me._frame) Then
            me._frame.Sync()
         End If
      End Sub

      Sub Reload()
         If me._kind = "cob" Then
            me._mapper.FillCobrancas(me._grid, me._session.ListaCobrancas())
         ElseIf me._kind = "pix" Then
            me._mapper.FillPix(me._grid, me._session.ListaPix())
         Else
            If me._mapper.CountOfDevolucoes(me._session.ListaDevPix()) > 0 Then
               me._mapper.FillDevolucoesFromPix(me._grid, me._session.ListaDevPix())
            ElseIf Assigned(me._session.Devolucao()) Then
               me._mapper.FillDevolucao(me._grid, me._session.Devolucao(), me._session.DevE2e(), me._session.DevTxId())
            Else
               me._mapper.FillDevolucoesFromPix(me._grid, me._session.ListaDevPix())
            End If
         End If
         me._selectFirstIfNeeded()
         me._bindNative()
      End Sub

      Private Sub _selectFirstIfNeeded()
         Dim row As TGridRow
         If me._grid.Data.RowCount <= 0 Then
            Exit Sub
         End If
         row = me._grid.Data.RowAt(0)
         If Not Assigned(row) Then
            Exit Sub
         End If
         If me._kind = "cob" Then
            If Not Assigned(me._session.Cobranca()) Then
               me._session.SelectCobranca(row.ID)
            End If
         ElseIf me._kind = "pix" Then
            If Not Assigned(me._session.Pix()) Then
               me._session.SelectPix(row.ID)
            End If
         Else
            If Not Assigned(me._session.Devolucao()) Then
               me._session.SelectDevolucao(PixAppFormat.DevRowE2e(row.ID), PixAppFormat.DevRowDevId(row.ID))
            End If
         End If
      End Sub

      Private Sub _bindNative()
         me._grid.Native.OnClick = me._onClick
         me._grid.Events.OnDblClickCell = me._onDblClick
      End Sub

      Private Sub _onClick(pSender As TObject)
         me._applySelection()
      End Sub

      Private Sub _onDblClick(pSender As TObject, pRow As Integer, pCol As Integer)
         me._applySelection()
      End Sub

      Private Sub _applySelection()
         Dim id As String = me._mapper.RowId(me._grid, me._grid.Native.Row)
         If id = "" Then
            Exit Sub
         End If
         If me._kind = "cob" Then
            me._session.SelectCobranca(id)
         ElseIf me._kind = "pix" Then
            me._session.SelectPix(id)
         Else
            me._session.SelectDevolucao(PixAppFormat.DevRowE2e(id), PixAppFormat.DevRowDevId(id))
         End If
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._grid) Then
            me._grid.Free()
            me._grid = Null
         End If
         If Assigned(me._mapper) Then
            me._mapper.Free()
            me._mapper = Null
         End If
         If Assigned(me._frame) Then
            me._frame.Free()
            me._frame = Null
         End If
         me._session = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
