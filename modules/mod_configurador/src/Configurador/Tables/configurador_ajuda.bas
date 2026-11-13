Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_ajuda

   Class Ajuda
      Inherits TCfgBase
      
      CodTabela As Integer
      CodCampo As Integer
      Conteudo As String
      CodAjuda As Integer
      CodAjudaPai As Integer
      Descricao As String
      CodRelatorio As Integer
      CodProcessoTabela As Integer
      CodFiltro As Integer
      CodLegendaTabela As Integer
      CodModulo As Integer
      CodPesquisaPadrao As Integer
      CodMensagem As String
      NomeParametro As String
      CodGatilho As Integer
      CodRegraValidacao As Integer
      CodProcedureFunction As Integer

      Sub New()
         MyBase.New("Ajuda")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodCampo = TCfgRow.AsInteger(pJson.GetString("codcampo"))
         me.Conteudo = TCfgRow.AsString(pJson.GetString("conteudo"))
         me.CodAjuda = TCfgRow.AsInteger(pJson.GetString("codajuda"))
         me.CodAjudaPai = TCfgRow.AsInteger(pJson.GetString("codajudaPai"))
         me.Descricao = TCfgRow.AsString(pJson.GetString("descricao"))
         me.CodRelatorio = TCfgRow.AsInteger(pJson.GetString("codrelatorio"))
         me.CodProcessoTabela = TCfgRow.AsInteger(pJson.GetString("codprocessotabela"))
         me.CodFiltro = TCfgRow.AsInteger(pJson.GetString("codfiltro"))
         me.CodLegendaTabela = TCfgRow.AsInteger(pJson.GetString("codlegendatabela"))
         me.CodModulo = TCfgRow.AsInteger(pJson.GetString("codmodulo"))
         me.CodPesquisaPadrao = TCfgRow.AsInteger(pJson.GetString("codpesquisapadrao"))
         me.CodMensagem = TCfgRow.AsString(pJson.GetString("codmensagem"))
         me.NomeParametro = TCfgRow.AsString(pJson.GetString("nomeparametro"))
         me.CodGatilho = TCfgRow.AsInteger(pJson.GetString("codgatilho"))
         me.CodRegraValidacao = TCfgRow.AsInteger(pJson.GetString("codregravalidacao"))
         me.CodProcedureFunction = TCfgRow.AsInteger(pJson.GetString("codprocedurefunction"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodCampo = pQuery.Field("codcampo").AsInteger
         me.Conteudo = pQuery.Field("conteudo").AsString
         me.CodAjuda = pQuery.Field("codajuda").AsInteger
         me.CodAjudaPai = pQuery.Field("codajudaPai").AsInteger
         me.Descricao = pQuery.Field("descricao").AsString
         me.CodRelatorio = pQuery.Field("codrelatorio").AsInteger
         me.CodProcessoTabela = pQuery.Field("codprocessotabela").AsInteger
         me.CodFiltro = pQuery.Field("codfiltro").AsInteger
         me.CodLegendaTabela = pQuery.Field("codlegendatabela").AsInteger
         me.CodModulo = pQuery.Field("codmodulo").AsInteger
         me.CodPesquisaPadrao = pQuery.Field("codpesquisapadrao").AsInteger
         me.CodMensagem = pQuery.Field("codmensagem").AsString
         me.NomeParametro = pQuery.Field("nomeparametro").AsString
         me.CodGatilho = pQuery.Field("codgatilho").AsInteger
         me.CodRegraValidacao = pQuery.Field("codregravalidacao").AsInteger
         me.CodProcedureFunction = pQuery.Field("codprocedurefunction").AsInteger
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodAjuda)
      End Function   

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodCampo", me.CodCampo)
            .Prop("Conteudo", me.Conteudo)
            .Prop("CodAjuda", me.CodAjuda)
            .Prop("CodAjudaPai", me.CodAjudaPai)
            .Prop("Descricao", me.Descricao)
            .Prop("CodRelatorio", me.CodRelatorio)
            .Prop("CodProcessoTabela", me.CodProcessoTabela)
            .Prop("CodFiltro", me.CodFiltro)
            .Prop("CodLegendaTabela", me.CodLegendaTabela)
            .Prop("CodModulo", me.CodModulo)
            .Prop("CodPesquisaPadrao", me.CodPesquisaPadrao)
            .Prop("CodMensagem", me.CodMensagem)
            .Prop("NomeParametro", me.NomeParametro)
            .Prop("CodGatilho", me.CodGatilho)
            .Prop("CodRegraValidacao", me.CodRegraValidacao)
            .Prop("CodProcedureFunction", me.CodProcedureFunction)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codajuda") As TTList<Ajuda>
         Dim query As SQL.Command = TCfgDb.Abrir("", "Ajuda", pWhere, pOrder)
         Dim lista[] As Ajuda = []
         While Not query.Eof
            Dim item As New Ajuda()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class


End Namespace
