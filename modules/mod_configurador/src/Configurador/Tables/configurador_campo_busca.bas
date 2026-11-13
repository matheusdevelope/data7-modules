Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_campo_busca

   Class CampoBusca
      Inherits TCfgBase

      CodTabela As Integer
      CodPesquisaPadrao As Integer
      CodCampo As Integer
      Ordem As Integer
      Condicao As String
      Campo As configurador_campo.Campo

      Sub New()
         MyBase.New("CampoBusca")
         me.Campo = Null
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodPesquisaPadrao = TCfgRow.AsInteger(pJson.GetString("codpesquisapadrao"))
         me.CodCampo = TCfgRow.AsInteger(pJson.GetString("codcampo"))
         me.Ordem = TCfgRow.AsInteger(pJson.GetString("ordem"))
         me.Condicao = TCfgRow.AsString(pJson.GetString("condicao"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodPesquisaPadrao = pQuery.Field("codpesquisapadrao").AsInteger
         me.CodCampo = pQuery.Field("codcampo").AsInteger
         me.Ordem = pQuery.Field("ordem").AsInteger
         me.Condicao = pQuery.Field("condicao").AsString
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodTabela) & "-" & CStr(me.CodCampo)
      End Function   

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodPesquisaPadrao", me.CodPesquisaPadrao)
            .Prop("CodCampo", me.CodCampo)
            .Prop("Ordem", me.Ordem)
            .Prop("Condicao", me.Condicao)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<CampoBusca>
         Dim query As SQL.Command = TCfgDb.Abrir("", "CampoBuscaPesquisaPadrao", pWhere, pOrder)
         Dim lista[] As CampoBusca = []
         While Not query.Eof
            Dim item As New CampoBusca()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Overrides Sub Dispose()
         me.Campo = Null
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
