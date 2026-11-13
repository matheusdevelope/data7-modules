Imports mod_tobject
Imports mod_pix_valor
Imports mod_pix_calendario
Imports mod_pix_devedor
Imports mod_pix_info_adicional

Namespace mod_pix_cobranca

   Class PixCobranca
      Inherits TTObject

      TxId As String
      Chave As String
      Revisao As Integer
      SolicitacaoPagador As String
      Valor As PixValor
      Calendario As PixCalendario
      Devedor As PixDevedor
      InfoAdicionais As PixInfoAdicionalList

      Sub New()
         MyBase.New()
         me.Valor = New PixValor()
         me.Calendario = New PixCalendario()
         me.Devedor = New PixDevedor()
         me.InfoAdicionais = New PixInfoAdicionalList()
      End Sub

      Overrides Function GetID() As String
         GetID = me.TxId
      End Function

      Sub Assign(pValue As PixCobranca)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.TxId = pValue.TxId
         me.Chave = pValue.Chave
         me.Revisao = pValue.Revisao
         me.SolicitacaoPagador = pValue.SolicitacaoPagador
         If Assigned(me.Valor) Then
            me.Valor.Free()
         End If
         me.Valor = pValue.Valor.Clone()
         If Assigned(me.Calendario) Then
            me.Calendario.Free()
         End If
         me.Calendario = pValue.Calendario.Clone()
         If Assigned(me.Devedor) Then
            me.Devedor.Free()
         End If
         me.Devedor = pValue.Devedor.Clone()
         If Assigned(me.InfoAdicionais) Then
            me.InfoAdicionais.Free()
         End If
         me.InfoAdicionais = pValue.InfoAdicionais.CopyItems()
      End Sub

      Overrides Function Clone() As PixCobranca
         Dim copy As New PixCobranca()
         copy.Assign(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject) As PixCobranca
         Dim value As New PixCobranca()
         If pJson.Has("txid") Then
            value.TxId = pJson.GetString("txid")
         End If
         If pJson.Has("chave") Then
            value.Chave = pJson.GetString("chave")
         End If
         If pJson.Has("revisao") Then
            value.Revisao = pJson.GetInteger("revisao")
         End If
         If pJson.Has("solicitacaoPagador") Then
            value.SolicitacaoPagador = pJson.GetString("solicitacaoPagador")
         End If
         If pJson.Has("valor") Then
            value.Valor.Free()
            value.Valor = PixValor.FromJson(pJson.GetJSONObject("valor"))
         End If
         If pJson.Has("calendario") Then
            value.Calendario.Free()
            value.Calendario = PixCalendario.FromJson(pJson.GetJSONObject("calendario"))
         End If
         If pJson.Has("devedor") Then
            value.Devedor.Free()
            value.Devedor = PixDevedor.FromJson(pJson.GetJSONObject("devedor"))
         End If
         If pJson.Has("infoAdicionais") Then
            value.InfoAdicionais.Free()
            value.InfoAdicionais = PixInfoAdicionalList.FromJson(pJson.GetArray("infoAdicionais"))
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         ToJson = me.ToJson("txid")
      End Function

      Function ToJson(pTxIdKey As String) As TJSONObject
         Dim json As New TJSONObject()
         If me.TxId <> "" Then
            json.PutString(pTxIdKey, me.TxId)
         End If
         If me.Chave <> "" Then
            json.PutString("chave", me.Chave)
         End If
         If me.Revisao <> -1 Then
            json.PutInteger("revisao", me.Revisao)
         End If
         If me.SolicitacaoPagador <> "" Then
            json.PutString("solicitacaoPagador", me.SolicitacaoPagador)
         End If
         If Assigned(me.Valor) Then
            json.PutObject("valor", me.Valor.ToJson())
         End If
         If Assigned(me.Calendario) Then
            Dim cal As TJSONObject = me.Calendario.ToJson()
            If cal.ToString() <> "{}" Then
               json.PutObject("calendario", cal)
            Else
               cal.Free()
            End If
         End If
         If Assigned(me.Devedor) Then
            Dim dev As TJSONObject = me.Devedor.ToJson()
            If dev.ToString() <> "{}" Then
               json.PutObject("devedor", dev)
            Else
               dev.Free()
            End If
         End If
         If Assigned(me.InfoAdicionais) Then
            If me.InfoAdicionais.Length > 0 Then
               json.PutArray("infoAdicionais", me.InfoAdicionais.ToJson())
            End If
         End If
         ToJson = json
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixCobranca")
            .Prop("TxId", me.TxId)
            .Prop("Chave", me.Chave)
            .Prop("Revisao", me.Revisao)
            .Prop("SolicitacaoPagador", me.SolicitacaoPagador)
            .Prop("Valor", me.Valor.ToString())
            .Prop("Calendario", me.Calendario.ToString())
            .Prop("Devedor", me.Devedor.ToString())
            .Prop("InfoAdicionais", me.InfoAdicionais.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Valor) Then
            me.Valor.Free()
            me.Valor = Null
         End If
         If Assigned(me.Calendario) Then
            me.Calendario.Free()
            me.Calendario = Null
         End If
         If Assigned(me.Devedor) Then
            me.Devedor.Free()
            me.Devedor = Null
         End If
         If Assigned(me.InfoAdicionais) Then
            me.InfoAdicionais.Free()
            me.InfoAdicionais = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
