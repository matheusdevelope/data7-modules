Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_legenda

   Class Legenda
      Inherits TCfgBase

      CodTabela As Integer
      CodLegendaTabela As Integer
      Descricao As String
      TipoLegenda As String
      Ordem As Integer

      Sub New()
         MyBase.New("Legenda")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodLegendaTabela = TCfgRow.AsInteger(pJson.GetString("codlegendatabela"))
         me.Descricao = TCfgRow.AsString(pJson.GetString("descricao"))
         me.TipoLegenda = TCfgRow.AsString(pJson.GetString("tipolegenda"))
         me.Ordem = TCfgRow.AsInteger(pJson.GetString("ordem"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodLegendaTabela = pQuery.Field("codlegendatabela").AsInteger
         me.Descricao = pQuery.Field("descricao").AsString
         me.TipoLegenda = pQuery.Field("tipolegenda").AsString
         me.Ordem = pQuery.Field("ordem").AsInteger
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodLegendaTabela)
      End Function 

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodLegendaTabela", me.CodLegendaTabela)
            .Prop("Descricao", me.Descricao)
            .Prop("TipoLegenda", me.TipoLegenda)
            .Prop("Ordem", me.Ordem)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codlegendatabela") As TTList<Legenda>
         Dim query As SQL.Command = TCfgDb.Abrir("Dicionario", "LegendaTabela", pWhere, pOrder)
         Dim lista[] As Legenda = []
         While Not query.Eof
            Dim item As New Legenda()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Legenda>
         FetchByTabela = Legenda.Fetch(TCfgSql.Tabela(pCodTabela))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
