Imports mod_pix_cobranca_completa
Imports mod_pix_recebimento
Imports mod_pix_config
Imports mod_pix_enums
Imports mod_pix_devolucao

Namespace mod_pix_ledger

   Class PixMovimentoLedger
      Inherits PixLedger

      Private _codEmpresa As Integer
      Private _codFilial As Integer
      Private _codContaFinanceira As String

      Sub New(pConfig As PixConfig)
         MyBase.New()
         If Not Assigned(pConfig) Then
            Throw New Exception("PixMovimentoLedger requer PixConfig")
         End If
         me._codEmpresa = pConfig.CodEmpresa
         me._codFilial = pConfig.CodFilial
         me._codContaFinanceira = pConfig.CodContaFinanceira
      End Sub

      Private Function LoadMovimento(pCobranca As PixCobrancaCompleta) As MovimentoPix
         Dim found As MovimentoPix = Null
         If pCobranca.CodMovimentoPix > 0 Then
            found = MovimentoPix.Find("CodEmpresa = " & CStr(me._codEmpresa) & " AND CodMovimentoPix = " & CStr(pCobranca.CodMovimentoPix))
         End If
         If Not Assigned(found) Then
            If Trim(pCobranca.TxId) <> "" Then
               found = MovimentoPix.Find("TxID = '" & pCobranca.TxId & "'")
            End If
         End If
         LoadMovimento = found
      End Function

      Overrides Sub SaveCobranca(pCobranca As PixCobrancaCompleta, pDataCancelamento As TDateTime = 0)
         If Not Assigned(pCobranca) Then
            Exit Sub
         End If

         Dim mov As MovimentoPix = me.LoadMovimento(pCobranca)
         If Not Assigned(mov) Then
            mov = New MovimentoPix()
            mov.CodEmpresa = me._codEmpresa
            mov.CodFilial = me._codFilial
            mov.CodContaFinanceira = me._codContaFinanceira
            mov.TxID = pCobranca.TxId
         End If
         mov.PixCopiaECola = pCobranca.PixCopiaECola
         mov.Valor = pCobranca.Valor.Original
         If Assigned(pCobranca.Status) Then
            mov.Status = pCobranca.Status.AsString
         End If
         mov.DataCriacao = pCobranca.Calendario.Criacao
         mov.DataExpiracao = pCobranca.Calendario.DataExpiracao()
         mov.DataCancelamento = pDataCancelamento

         If pCobranca.Recebimentos.Length > 0 Then
            Dim pix As PixRecebimento = pCobranca.Recebimentos.Take(0)
            mov.EndToEndID = pix.E2eId
            mov.Valor = pix.Valor
            If pix.Devolucoes.Length > 0 Then
               Dim dev As PixDevolucao = pix.Devolucoes.Take(0)
               mov.IDDevolucao = dev.Id
               If Assigned(dev.Status) Then
                  mov.StatusDevolucao = dev.Status.AsString
               End If
               If Assigned(dev.Status) Then
                  If dev.Status = PixStatusDevolucao.Devolvido() Then
                     mov.DataDevolucao = dev.Horario.Liquidacao
                  Else
                     mov.DataDevolucao = dev.Horario.Solicitacao
                  End If
               End If
            End If
         End If

         mov.Upsert()
         pCobranca.CodMovimentoPix = mov.CodMovimentoPix
         mov.Free()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
