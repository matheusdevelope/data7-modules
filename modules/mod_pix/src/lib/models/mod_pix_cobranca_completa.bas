Imports mod_tobject
Imports mod_tlist
Imports mod_pix_enums
Imports mod_pix_utils
Imports mod_pix_cobranca
Imports mod_pix_calendario
Imports mod_pix_recebimento

Namespace mod_pix_cobranca_completa

   Class PixCobrancaCompleta
      Inherits PixCobranca

      CodMovimentoPix As Integer
      PixCopiaECola As String
      Status As PixStatusCobranca
      Location As String
      Recebimentos As PixRecebimentoList

      Sub New()
         MyBase.New()
         me.Recebimentos = New PixRecebimentoList()
      End Sub

      Function IsActive() As Boolean
         IsActive = me.Status = PixStatusCobranca.Ativa()
      End Function

      Function IsDone() As Boolean
         IsDone = me.Status = PixStatusCobranca.Concluida()
      End Function

      Function IsCancelled() As Boolean
         IsCancelled = Assigned(me.Status) And Not me.IsActive() And Not me.IsDone()
      End Function

      Sub AssignCompleta(pValue As PixCobrancaCompleta)
         me.Assign(pValue)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.CodMovimentoPix = pValue.CodMovimentoPix
         me.PixCopiaECola = pValue.PixCopiaECola
         me.Status = pValue.Status
         me.Location = pValue.Location
         If Assigned(me.Recebimentos) Then
            me.Recebimentos.Free()
         End If
         me.Recebimentos = pValue.Recebimentos.CopyItems()
      End Sub

      Overrides Function Clone() As PixCobrancaCompleta
         Dim copy As New PixCobrancaCompleta()
         copy.AssignCompleta(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixCobrancaCompleta
         Dim value As New PixCobrancaCompleta()
         Dim base As PixCobranca = PixCobranca.FromJson(pJson)
         value.Assign(base)
         base.Free()
         If pJson.Has("pixCopiaECola") Then
            value.PixCopiaECola = pJson.GetString("pixCopiaECola").Trim()
         End If
         If pJson.Has("brcode") Then
            value.PixCopiaECola = pJson.GetString("brcode").Trim()
         End If
         If pJson.Has("status") Then
            value.Status = PixStatusCobranca.Load(pJson.GetString("status"))
         End If
         If pJson.Has("location") Then
            value.Location = pJson.GetString("location").Trim()
         End If
         If value.Location = "" And pJson.Has("loc") Then
            Try
               Dim loc As TJSONObject = pJson.GetJSONObject("loc")
               If Assigned(loc) Then
                  If loc.Has("location") Then
                     value.Location = loc.GetString("location").Trim()
                  End If
               End If
            Catch ex As Exception
            End Try
         End If
         If pJson.Has("calendario") Then
            value.Calendario.Free()
            value.Calendario = PixCalendario.FromJson(pJson.GetJSONObject("calendario"), pTimeZoneHours)
         End If
         If pJson.Has("pix") Then
            value.Recebimentos.Free()
            value.Recebimentos = PixRecebimentoList.FromJson(pJson.GetArray("pix"), pTimeZoneHours)
         End If
         If value.PixCopiaECola = "" And value.Location <> "" Then
            value.PixCopiaECola = GerarPixCopiaECola(value.Location)
         End If
         FromJson = value
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixCobrancaCompleta")
            .Prop("TxId", me.TxId)
            .Prop("Chave", me.Chave)
            .Prop("Revisao", me.Revisao)
            .Prop("SolicitacaoPagador", me.SolicitacaoPagador)
            .Prop("Valor", me.Valor.ToString())
            .Prop("Calendario", me.Calendario.ToString())
            .Prop("Devedor", me.Devedor.ToString())
            .Prop("InfoAdicionais", me.InfoAdicionais.ToString())     
            .Prop("Recebimentos", me.Recebimentos.ToString())
            .Prop("Location", me.Location)
            .Prop("CodMovimentoPix", me.CodMovimentoPix)
            .Prop("PixCopiaECola", me.PixCopiaECola)
            If Assigned(me.Status) Then
               .Prop("Status", me.Status.AsString)
            End If
            .Prop("IsActive", me.IsActive())
            .Prop("IsDone", me.IsDone())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Recebimentos) Then
            me.Recebimentos.Free()
            me.Recebimentos = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixCobrancaList
      Inherits TTList<PixCobrancaCompleta>

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromJson(pJson As TJSONArray, pTimeZoneHours As Integer = 0) As PixCobrancaList
         Dim list As New PixCobrancaList()
         Dim i As Integer
         Dim count As Integer = pJson.Length() - 1
         For i = 0 To count
            list.Push(PixCobrancaCompleta.FromJson(pJson.GetJSONObject(i), pTimeZoneHours))
         Next
         FromJson = list
      End Function

      Function CopyItems() As PixCobrancaList
         Dim list As New PixCobrancaList()
         Dim i As Integer
         Dim count As Integer = me.Length - 1
         For i = 0 To count
            list.Push(me.Take(i).Clone())
         Next
         CopyItems = list
      End Function

      Function Count() As Integer
         Count = me.Length
      End Function

      Function First() As PixCobrancaCompleta
         If me.Length = 0 Then
            First = Null
         Else
            First = me.Take(0)
         End If
      End Function

      Function FindById(pTxId As String) As PixCobrancaCompleta
         Dim idx As Integer = me.IndexOf(pTxId)
         If idx < 0 Then
            FindById = Null
         Else
            FindById = me.Take(idx)
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
