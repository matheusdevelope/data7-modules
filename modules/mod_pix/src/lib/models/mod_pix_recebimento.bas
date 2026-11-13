Imports mod_tobject
Imports mod_tlist
Imports mod_pix_utils
Imports mod_pix_devolucao

Namespace mod_pix_recebimento

   Class PixRecebimento
      Inherits TTObject

      E2eId As String
      TxId As String
      Chave As String
      Valor As Double
      ValorCobranca As Double
      ValorDevolvido As Double
      Horario As TDateTime
      Devolucoes As PixDevolucaoList

      Sub New()
         MyBase.New()
         me.Devolucoes = New PixDevolucaoList()
      End Sub

      Overrides Function GetID() As String
         GetID = me.E2eId
      End Function

      Sub Assign(pValue As PixRecebimento)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.E2eId = pValue.E2eId
         me.TxId = pValue.TxId
         me.Chave = pValue.Chave
         me.Valor = pValue.Valor
         me.ValorCobranca = pValue.ValorCobranca
         me.ValorDevolvido = pValue.ValorDevolvido
         me.Horario = pValue.Horario
         If Assigned(me.Devolucoes) Then
            me.Devolucoes.Free()
         End If
         me.Devolucoes = pValue.Devolucoes.CopyItems()
      End Sub

      Overrides Function Clone() As PixRecebimento
         Dim copy As New PixRecebimento()
         copy.Assign(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixRecebimento
         Dim value As New PixRecebimento()
         If pJson.Has("endToEndId") Then
            value.E2eId = pJson.GetString("endToEndId")
         End If
         If pJson.Has("txid") Then
            value.TxId = pJson.GetString("txid")
         End If
         If pJson.Has("chave") Then
            value.Chave = pJson.GetString("chave")
         End If
         If pJson.Has("valor") Then
            value.Valor = FormatValueToDouble(pJson.GetString("valor"))
         End If
         If pJson.Has("horario") Then
            Dim _hor As TDateTime = ParseISO8601(pJson.GetString("horario"))
            value.Horario = _hor.AddHours(pTimeZoneHours)
         End If
         If pJson.Has("componentesValor") Then
            Dim objComponentes As TJSONObject = pJson.GetJsonObject("componentesValor")
            If objComponentes.Has("original") Then
               Dim objOriginal As TJSONObject = objComponentes.GetJsonObject("original")
               If objOriginal.Has("valor") Then
                  value.ValorCobranca = FormatValueToDouble(objOriginal.GetString("valor"))
               End If
            End If
         End If
         If pJson.Has("devolucoes") Then
            value.Devolucoes.Free()
            value.Devolucoes = PixDevolucaoList.FromJson(pJson.GetArray("devolucoes"), pTimeZoneHours)
         End If
         value.ValorDevolvido = value.Devolucoes.ValorTotal()
         If value.ValorCobranca = 0 Then
            value.ValorCobranca = value.Valor
         End If
         FromJson = value
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixRecebimento")
            .Prop("TxId", me.TxId)
            .Prop("Chave", me.Chave)
            .Prop("E2eId", me.E2eId)
            .Prop("Valor", me.Valor)
            .Prop("ValorCobranca", me.ValorCobranca)
            .Prop("ValorDevolvido", me.ValorDevolvido)
            .Prop("Horario", DateToISO8601(me.Horario))
            .Prop("Devolucoes", me.Devolucoes.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Devolucoes) Then
            me.Devolucoes.Free()
            me.Devolucoes = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixRecebimentoList
      Inherits TTList<PixRecebimento>

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromJson(pJson As TJSONArray, pTimeZoneHours As Integer = 0) As PixRecebimentoList
         Dim list As New PixRecebimentoList()
         Dim i As Integer
         Dim count As Integer = pJson.Length() - 1
         For i = 0 To count
            list.Push(PixRecebimento.FromJson(pJson.GetJSONObject(i), pTimeZoneHours))
         Next
         FromJson = list
      End Function

      Function CopyItems() As PixRecebimentoList
         Dim list As New PixRecebimentoList()
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

      Function First() As PixRecebimento
         If me.Length = 0 Then
            First = Null
         Else
            First = me.Take(0)
         End If
      End Function

      Function FindById(pE2e As String) As PixRecebimento
         Dim idx As Integer = me.IndexOf(pE2e)
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
