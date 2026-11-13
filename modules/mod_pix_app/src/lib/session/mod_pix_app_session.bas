Imports mod_tobject
Imports mod_pix_runtime
Imports mod_pix_config
Imports mod_pix_capabilities
Imports mod_pix_cobranca_completa
Imports mod_pix_cobrancas
Imports mod_pix_recebimento
Imports mod_pix_recebimentos
Imports mod_pix_devolucao
Imports mod_pix_paginacao

Namespace mod_pix_app_session

   Delegate Sub PixAppStatusNotify(pText As String)

   Class PixAppSession
      Inherits TTObject

      Private _service As PixService
      Private _ownsService As Boolean
      Private _conta As String
      Private _mode As String
      Private _listaCob As PixCobrancas
      Private _listaPix As PixRecebimentos
      Private _listaDevPix As PixRecebimentos
      Private _cob As PixCobrancaCompleta
      Private _ownsCob As Boolean
      Private _pix As PixRecebimento
      Private _ownsPix As Boolean
      Private _dev As PixDevolucao
      Private _ownsDev As Boolean
      Private _devE2e As String
      Private _devTxId As String

      OnAccountChanged As TNotifyEvent
      OnListChanged As TNotifyEvent
      OnSelectionChanged As TNotifyEvent
      OnStatus As PixAppStatusNotify

      Sub New()
         MyBase.New()
         me._mode = "cob"
      End Sub

      Function HasService() As Boolean
         HasService = Assigned(me._service)
      End Function

      Function Service() As PixService
         Service = me._service
      End Function

      Function Config() As PixConfig
         If Assigned(me._service) Then
            Config = me._service.Config()
         Else
            Config = Null
         End If
      End Function

      Function Capabilities() As PixCapabilities
         If Assigned(me._service) Then
            Capabilities = me._service.Capabilities()
         Else
            Capabilities = Null
         End If
      End Function

      Function Conta() As String
         Conta = me._conta
      End Function

      Function Mode() As String
         Mode = me._mode
      End Function

      Function IsCobrancaMode() As Boolean
         IsCobrancaMode = me._mode = "cob"
      End Function

      Function IsPixMode() As Boolean
         IsPixMode = me._mode = "pix"
      End Function

      Function IsDevolucaoMode() As Boolean
         IsDevolucaoMode = me._mode = "dev"
      End Function

      Function IsCreateMode() As Boolean
         IsCreateMode = me._mode = "new"
      End Function

      Function ListaCobrancas() As PixCobrancas
         ListaCobrancas = me._listaCob
      End Function

      Function ListaPix() As PixRecebimentos
         ListaPix = me._listaPix
      End Function

      Function ListaDevPix() As PixRecebimentos
         ListaDevPix = me._listaDevPix
      End Function

      Function Cobranca() As PixCobrancaCompleta
         Cobranca = me._cob
      End Function

      Function Pix() As PixRecebimento
         Pix = me._pix
      End Function

      Function Devolucao() As PixDevolucao
         Devolucao = me._dev
      End Function

      Function DevE2e() As String
         DevE2e = me._devE2e
      End Function

      Function DevTxId() As String
         DevTxId = me._devTxId
      End Function

      Function PaginacaoCobrancas() As PixPaginacao
         If Assigned(me._listaCob) Then
            PaginacaoCobrancas = me._listaCob.Paginacao
         Else
            PaginacaoCobrancas = Null
         End If
      End Function

      Function PaginacaoPix() As PixPaginacao
         If Assigned(me._listaPix) Then
            PaginacaoPix = me._listaPix.Paginacao
         Else
            PaginacaoPix = Null
         End If
      End Function

      Function PaginacaoDev() As PixPaginacao
         If Assigned(me._listaDevPix) Then
            PaginacaoDev = me._listaDevPix.Paginacao
         Else
            PaginacaoDev = Null
         End If
      End Function

      Sub SetStatus(pText As String)
         If me.OnStatus <> NULL Then
            me.OnStatus(pText)
         End If
      End Sub

      Sub BindService(pService As PixService, pConta As String, pOwnsService As Boolean = True)
         me._releaseService()
         me._service = pService
         me._ownsService = pOwnsService
         me._conta = pConta
         me._clearLists()
         me._clearSelection()
         me._emitAccount()
         me._emitList()
         me._emitSelection()
         If Assigned(pService) Then
            me.SetStatus("Conta " & pConta & " conectada (" & pService.Client().GetName() & ").")
         Else
            me.SetStatus("Selecione uma conta financeira para começar.")
         End If
      End Sub

      Sub Unbind()
         me.BindService(Null, "", True)
      End Sub

      Sub SetMode(pMode As String)
         Dim nextMode As String = LCase(Trim(pMode))
         If nextMode = "" Then
            nextMode = "cob"
         End If
         If me._mode = nextMode Then
            Exit Sub
         End If
         me._mode = nextMode
         me._emitSelection()
      End Sub

      Sub ReplaceCobrancas(pLista As PixCobrancas)
         If Assigned(me._listaCob) Then
            me._listaCob.Free()
         End If
         me._listaCob = pLista
         me._releaseOwnedCob()
         me._cob = Null
         me._emitList()
         me._emitSelection()
      End Sub

      Sub ReplacePix(pLista As PixRecebimentos)
         If Assigned(me._listaPix) Then
            me._listaPix.Free()
         End If
         me._listaPix = pLista
         me._releaseOwnedPix()
         me._pix = Null
         me._emitList()
         me._emitSelection()
      End Sub

      Sub ReplaceDevPix(pLista As PixRecebimentos)
         If Assigned(me._listaDevPix) Then
            me._listaDevPix.Free()
         End If
         me._listaDevPix = pLista
         me._releaseOwnedDev()
         me._dev = Null
         me._devE2e = ""
         me._devTxId = ""
         me._emitList()
         me._emitSelection()
      End Sub

      Sub SelectCobranca(pTxId As String)
         If Assigned(me._cob) Then
            If Not me._ownsCob Then
               If me._cob.TxId = pTxId Then
                  Exit Sub
               End If
            End If
         End If
         me._releaseOwnedCob()
         me._cob = Null
         If Assigned(me._listaCob) Then
            If Assigned(me._listaCob.Cobrancas) Then
               me._cob = me._listaCob.Cobrancas.FindById(pTxId)
            End If
         End If
         me._ownsCob = False
         me._emitSelection()
      End Sub

      Sub SelectPix(pE2eId As String)
         If Assigned(me._pix) Then
            If Not me._ownsPix Then
               If me._pix.E2eId = pE2eId Then
                  Exit Sub
               End If
            End If
         End If
         me._releaseOwnedPix()
         me._pix = Null
         If Assigned(me._listaPix) Then
            If Assigned(me._listaPix.Pix) Then
               me._pix = me._listaPix.Pix.FindById(pE2eId)
            End If
         End If
         me._ownsPix = False
         me._emitSelection()
      End Sub

      Sub SelectDevolucao(pE2e As String, pId As String)
         Dim pix As PixRecebimento
         If Assigned(me._dev) Then
            If Not me._ownsDev Then
               If (me._devE2e = pE2e) AndAlso (me._dev.Id = pId) Then
                  Exit Sub
               End If
            End If
         End If
         me._releaseOwnedDev()
         me._dev = Null
         me._devE2e = pE2e
         me._devTxId = ""
         If Assigned(me._listaDevPix) Then
            If Assigned(me._listaDevPix.Pix) Then
               pix = me._listaDevPix.Pix.FindById(pE2e)
            End If
         End If
         If Assigned(pix) Then
            me._devTxId = pix.TxId
            If Assigned(pix.Devolucoes) Then
               me._dev = pix.Devolucoes.FindById(pId)
            End If
         End If
         me._ownsDev = False
         me._emitSelection()
      End Sub

      Sub AdoptCobranca(pCobranca As PixCobrancaCompleta)
         me._releaseOwnedCob()
         me._cob = pCobranca
         me._ownsCob = True
         me._upsertCobranca(pCobranca)
         me._emitList()
         me._emitSelection()
      End Sub

      Sub AdoptPix(pPix As PixRecebimento)
         me._releaseOwnedPix()
         me._pix = pPix
         me._ownsPix = True
         me._upsertPix(pPix)
         me._emitList()
         me._emitSelection()
      End Sub

      Sub AdoptDevolucao(pDevolucao As PixDevolucao, pE2e As String, pTxId As String)
         me._releaseOwnedDev()
         me._dev = pDevolucao
         me._ownsDev = True
         me._devE2e = pE2e
         me._devTxId = pTxId
         me._emitList()
         me._emitSelection()
      End Sub

      Sub RefreshUi()
         If me._ownsCob Then
            If Assigned(me._cob) Then
               me._upsertCobranca(me._cob)
            End If
         End If
         me._emitList()
         me._emitSelection()
      End Sub

      Private Sub _upsertCobranca(pCobranca As PixCobrancaCompleta)
         If Not Assigned(pCobranca) Then
            Exit Sub
         End If
         If Not Assigned(me._listaCob) Then
            me._listaCob = New PixCobrancas()
         End If
         Dim atual As PixCobrancaCompleta = me._listaCob.Cobrancas.FindById(pCobranca.TxId)
         If Assigned(atual) Then
            atual.AssignCompleta(pCobranca)
         Else
            me._listaCob.Cobrancas.Push(pCobranca.Clone())
         End If
      End Sub

      Private Sub _upsertPix(pPix As PixRecebimento)
         If Not Assigned(pPix) Then
            Exit Sub
         End If
         If Not Assigned(me._listaPix) Then
            me._listaPix = New PixRecebimentos()
         End If
         Dim atual As PixRecebimento = me._listaPix.Pix.FindById(pPix.E2eId)
         If Assigned(atual) Then
            atual.Assign(pPix)
         Else
            me._listaPix.Pix.Push(pPix.Clone())
         End If
      End Sub

      Private Sub _clearLists()
         If Assigned(me._listaCob) Then
            me._listaCob.Free()
            me._listaCob = Null
         End If
         If Assigned(me._listaPix) Then
            me._listaPix.Free()
            me._listaPix = Null
         End If
         If Assigned(me._listaDevPix) Then
            me._listaDevPix.Free()
            me._listaDevPix = Null
         End If
      End Sub

      Private Sub _clearSelection()
         me._releaseOwnedCob()
         me._releaseOwnedPix()
         me._releaseOwnedDev()
         me._cob = Null
         me._pix = Null
         me._dev = Null
         me._devE2e = ""
         me._devTxId = ""
      End Sub

      Private Sub _releaseOwnedCob()
         If me._ownsCob Then
            If Assigned(me._cob) Then
               me._cob.Free()
            End If
         End If
         me._cob = Null
         me._ownsCob = False
      End Sub

      Private Sub _releaseOwnedPix()
         If me._ownsPix Then
            If Assigned(me._pix) Then
               me._pix.Free()
            End If
         End If
         me._pix = Null
         me._ownsPix = False
      End Sub

      Private Sub _releaseOwnedDev()
         If me._ownsDev Then
            If Assigned(me._dev) Then
               me._dev.Free()
            End If
         End If
         me._dev = Null
         me._ownsDev = False
      End Sub

      Private Sub _releaseService()
         me._clearLists()
         me._clearSelection()
         If me._ownsService Then
            If Assigned(me._service) Then
               me._service.Free()
            End If
         End If
         me._service = Null
         me._ownsService = False
         me._conta = ""
      End Sub

      Private Sub _emitAccount()
         If me.OnAccountChanged <> NULL Then
            me.OnAccountChanged(me)
         End If
      End Sub

      Private Sub _emitList()
         If me.OnListChanged <> NULL Then
            me.OnListChanged(me)
         End If
      End Sub

      Private Sub _emitSelection()
         If me.OnSelectionChanged <> NULL Then
            me.OnSelectionChanged(me)
         End If
      End Sub

      Overrides Sub Dispose()
         me.OnAccountChanged = Null
         me.OnListChanged = Null
         me.OnSelectionChanged = Null
         me.OnStatus = Null
         me._releaseService()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
