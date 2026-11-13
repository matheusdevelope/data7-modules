Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_filtro

   Class FiltroCampo
      Inherits TCfgBase

      CodTabela As Integer
      CodFiltro As Integer
      CodCampo As Integer
      ValorPadrao As String
      Visivel As String
      Proprietario As String
      Ordem As Integer
      Condicao As String
      Titulo As String
      Comando As String
      Editavel As String
      SQLWhereCondition As String
      Campo As configurador_campo.Campo

      Sub New()
         MyBase.New("FiltroCampo")
         me.Campo = Null
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodFiltro = TCfgRow.AsInteger(pJson.GetString("codfiltro"))
         me.CodCampo = TCfgRow.AsInteger(pJson.GetString("codcampo"))
         me.ValorPadrao = TCfgRow.AsString(pJson.GetString("valorpadrao"))
         me.Visivel = TCfgRow.AsString(pJson.GetString("visivel"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
         me.Ordem = TCfgRow.AsInteger(pJson.GetString("ordem"))
         me.Condicao = TCfgRow.AsString(pJson.GetString("condicao"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.Comando = TCfgRow.AsString(pJson.GetString("comando"))
         me.Editavel = TCfgRow.AsString(pJson.GetString("editavel"))
         me.SQLWhereCondition = TCfgRow.AsString(pJson.GetString("sqlwherecondition"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodFiltro = pQuery.Field("codfiltro").AsInteger
         me.CodCampo = pQuery.Field("codcampo").AsInteger
         me.ValorPadrao = pQuery.Field("valorpadrao").AsString
         me.Visivel = pQuery.Field("visivel").AsString
         me.Proprietario = pQuery.Field("proprietario").AsString
         me.Ordem = pQuery.Field("ordem").AsInteger
         me.Condicao = pQuery.Field("condicao").AsString
         me.Titulo = pQuery.Field("titulo").AsString
         me.Comando = pQuery.Field("comando").AsString
         me.Editavel = pQuery.Field("editavel").AsString
         me.SQLWhereCondition = pQuery.Field("sqlwherecondition").AsString
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodFiltro", me.CodFiltro)
            .Prop("CodCampo", me.CodCampo)
            .Prop("ValorPadrao", me.ValorPadrao)
            .Prop("Visivel", me.Visivel)
            .Prop("Proprietario", me.Proprietario)
            .Prop("Ordem", me.Ordem)
            .Prop("Condicao", me.Condicao)
            .Prop("Titulo", me.Titulo)
            .Prop("Comando", me.Comando)
            .Prop("Editavel", me.Editavel)
            .Prop("SQLWhereCondition", me.SQLWhereCondition)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codcampo") As TTList<FiltroCampo>
         Dim query As SQL.Command = TCfgDb.Abrir("", "CampoFiltro", pWhere, pOrder)
         Dim lista[] As FiltroCampo = []
         While Not query.Eof
            Dim item As New FiltroCampo()
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

   Class Filtro
      Inherits TCfgBase

      CodTabela As Integer
      CodFiltro As Integer
      Nome As String
      Proprietario As String
      CamposFiltro[] As FiltroCampo

      Sub New()
         MyBase.New("Filtro")
         me.CamposFiltro = []
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodFiltro = TCfgRow.AsInteger(pJson.GetString("codfiltro"))
         me.Nome = TCfgRow.AsString(pJson.GetString("nome"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodFiltro = pQuery.Field("codfiltro").AsInteger
         me.Nome = pQuery.Field("nome").AsString
         me.Proprietario = pQuery.Field("proprietario").AsString
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodFiltro)
      End Function 

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodFiltro", me.CodFiltro)
            .Prop("Nome", me.Nome)
            .Prop("Proprietario", me.Proprietario)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codfiltro") As TTList<Filtro>
         Dim query As SQL.Command = TCfgDb.Abrir("", "Filtro", pWhere, pOrder)
         Dim lista[] As Filtro = []
         While Not query.Eof
            Dim item As New Filtro()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Filtro>
         FetchByTabela = Filtro.Fetch(TCfgSql.Tabela(pCodTabela))
      End Function

      Overrides Sub Dispose()
         If Assigned(me.CamposFiltro) Then
            me.CamposFiltro.Free()
            me.CamposFiltro = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
