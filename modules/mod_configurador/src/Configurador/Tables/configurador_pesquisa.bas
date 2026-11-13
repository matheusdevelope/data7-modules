Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_pesquisa

   Class Pesquisa
      Inherits TCfgBase

      CodTabela As Integer
      CodPesquisaPadrao As Integer
      CodCampoDescricao As Integer
      Titulo As String
      Proprietario As String
      PermiteExcluir As String
      PermiteIncluir As String
      AbrirPosicionado As String
      ExpressaoFiltro As String
      CodImagem As Integer
      CodCampoChave As Integer
      DllFormPesquisa As String
      ExibirDesativado As String
      CodScripter As Integer
      ManterUltimoFiltro As String
      PermiteCadastroDireto As String
      CodTabelaCadastroDireto As Integer
      PermiteInclusaoCadastroDireto As String
      PermiteAlteracaoCadastroDireto As String
      PermiteVisualizarCadastroDireto As String
      AtalhoAbrirPesquisa As String
      AtalhoInclusao As String
      AtalhoAlteracao As String
      AtalhoVisualizacao As String
      ExibeBotaoInclusao As String
      ExibeBotaoAlteracao As String
      ExibeBotaoVisualizacao As String
      CamposBusca[] As configurador_campo_busca.CampoBusca
      CampoChave As configurador_campo.Campo
      CampoDescricao As configurador_campo.Campo

      Sub New()
         MyBase.New("Pesquisa")
         me.CamposBusca = []
         me.CampoChave = Null
         me.CampoDescricao = Null
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodPesquisaPadrao = TCfgRow.AsInteger(pJson.GetString("codpesquisapadrao"))
         me.CodCampoDescricao = TCfgRow.AsInteger(pJson.GetString("codcampodescricao"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
         me.PermiteExcluir = TCfgRow.AsString(pJson.GetString("permiteexcluir"))
         me.PermiteIncluir = TCfgRow.AsString(pJson.GetString("permiteincluir"))
         me.AbrirPosicionado = TCfgRow.AsString(pJson.GetString("abrirposicionado"))
         me.ExpressaoFiltro = TCfgRow.AsString(pJson.GetString("expressaofiltro"))
         me.CodImagem = TCfgRow.AsInteger(pJson.GetString("codimagem"))
         me.CodCampoChave = TCfgRow.AsInteger(pJson.GetString("codcampochave"))
         me.DllFormPesquisa = TCfgRow.AsString(pJson.GetString("dllformpesquisa"))
         me.ExibirDesativado = TCfgRow.AsString(pJson.GetString("exibirdesativado"))
         me.CodScripter = TCfgRow.AsInteger(pJson.GetString("codscripter"))
         me.ManterUltimoFiltro = TCfgRow.AsString(pJson.GetString("manterultimofiltro"))
         me.PermiteCadastroDireto = TCfgRow.AsString(pJson.GetString("permitecadastrodireto"))
         me.CodTabelaCadastroDireto = TCfgRow.AsInteger(pJson.GetString("codtabelacadastrodireto"))
         me.PermiteInclusaoCadastroDireto = TCfgRow.AsString(pJson.GetString("permiteinclusaocadastrodireto"))
         me.PermiteAlteracaoCadastroDireto = TCfgRow.AsString(pJson.GetString("permitealteracaocadastrodireto"))
         me.PermiteVisualizarCadastroDireto = TCfgRow.AsString(pJson.GetString("permitevisualizarcadastrodireto"))
         me.AtalhoAbrirPesquisa = TCfgRow.AsString(pJson.GetString("atalhoabrirpesquisa"))
         me.AtalhoInclusao = TCfgRow.AsString(pJson.GetString("atalhoinclusao"))
         me.AtalhoAlteracao = TCfgRow.AsString(pJson.GetString("atalhoalteracao"))
         me.AtalhoVisualizacao = TCfgRow.AsString(pJson.GetString("atalhovisualizacao"))
         me.ExibeBotaoInclusao = TCfgRow.AsString(pJson.GetString("exibebotaoinclusao"))
         me.ExibeBotaoAlteracao = TCfgRow.AsString(pJson.GetString("exibebotaoalteracao"))
         me.ExibeBotaoVisualizacao = TCfgRow.AsString(pJson.GetString("exibebotaovisualizacao"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodPesquisaPadrao = pQuery.Field("codpesquisapadrao").AsInteger
         me.CodCampoDescricao = pQuery.Field("codcampodescricao").AsInteger
         me.Titulo = pQuery.Field("titulo").AsString
         me.Proprietario = pQuery.Field("proprietario").AsString
         me.PermiteExcluir = pQuery.Field("permiteexcluir").AsString
         me.PermiteIncluir = pQuery.Field("permiteincluir").AsString
         me.AbrirPosicionado = pQuery.Field("abrirposicionado").AsString
         me.ExpressaoFiltro = pQuery.Field("expressaofiltro").AsString
         me.CodImagem = pQuery.Field("codimagem").AsInteger
         me.CodCampoChave = pQuery.Field("codcampochave").AsInteger
         me.DllFormPesquisa = pQuery.Field("dllformpesquisa").AsString
         me.ExibirDesativado = pQuery.Field("exibirdesativado").AsString
         me.CodScripter = pQuery.Field("codscripter").AsInteger
         me.ManterUltimoFiltro = pQuery.Field("manterultimofiltro").AsString
         me.PermiteCadastroDireto = pQuery.Field("permitecadastrodireto").AsString
         me.CodTabelaCadastroDireto = pQuery.Field("codtabelacadastrodireto").AsInteger
         me.PermiteInclusaoCadastroDireto = pQuery.Field("permiteinclusaocadastrodireto").AsString
         me.PermiteAlteracaoCadastroDireto = pQuery.Field("permitealteracaocadastrodireto").AsString
         me.PermiteVisualizarCadastroDireto = pQuery.Field("permitevisualizarcadastrodireto").AsString
         me.AtalhoAbrirPesquisa = pQuery.Field("atalhoabrirpesquisa").AsString
         me.AtalhoInclusao = pQuery.Field("atalhoinclusao").AsString
         me.AtalhoAlteracao = pQuery.Field("atalhoalteracao").AsString
         me.AtalhoVisualizacao = pQuery.Field("atalhovisualizacao").AsString
         me.ExibeBotaoInclusao = pQuery.Field("exibebotaoinclusao").AsString
         me.ExibeBotaoAlteracao = pQuery.Field("exibebotaoalteracao").AsString
         me.ExibeBotaoVisualizacao = pQuery.Field("exibebotaovisualizacao").AsString
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodPesquisaPadrao)
      End Function 

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodPesquisaPadrao", me.CodPesquisaPadrao)
            .Prop("CodCampoDescricao", me.CodCampoDescricao)
            .Prop("Titulo", me.Titulo)
            .Prop("Proprietario", me.Proprietario)
            .Prop("PermiteExcluir", me.PermiteExcluir)
            .Prop("PermiteIncluir", me.PermiteIncluir)
            .Prop("AbrirPosicionado", me.AbrirPosicionado)
            .Prop("ExpressaoFiltro", me.ExpressaoFiltro)
            .Prop("CodImagem", me.CodImagem)
            .Prop("CodCampoChave", me.CodCampoChave)
            .Prop("DllFormPesquisa", me.DllFormPesquisa)
            .Prop("ExibirDesativado", me.ExibirDesativado)
            .Prop("CodScripter", me.CodScripter)
            .Prop("ManterUltimoFiltro", me.ManterUltimoFiltro)
            .Prop("PermiteCadastroDireto", me.PermiteCadastroDireto)
            .Prop("CodTabelaCadastroDireto", me.CodTabelaCadastroDireto)
            .Prop("PermiteInclusaoCadastroDireto", me.PermiteInclusaoCadastroDireto)
            .Prop("PermiteAlteracaoCadastroDireto", me.PermiteAlteracaoCadastroDireto)
            .Prop("PermiteVisualizarCadastroDireto", me.PermiteVisualizarCadastroDireto)
            .Prop("AtalhoAbrirPesquisa", me.AtalhoAbrirPesquisa)
            .Prop("AtalhoInclusao", me.AtalhoInclusao)
            .Prop("AtalhoAlteracao", me.AtalhoAlteracao)
            .Prop("AtalhoVisualizacao", me.AtalhoVisualizacao)
            .Prop("ExibeBotaoInclusao", me.ExibeBotaoInclusao)
            .Prop("ExibeBotaoAlteracao", me.ExibeBotaoAlteracao)
            .Prop("ExibeBotaoVisualizacao", me.ExibeBotaoVisualizacao)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY titulo") As TTList<Pesquisa>
         Dim query As SQL.Command = TCfgDb.Abrir("", "PesquisaPadrao", pWhere, pOrder)
         Dim lista[] As Pesquisa = []
         While Not query.Eof
            Dim item As New Pesquisa()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Pesquisa>
         FetchByTabela = Pesquisa.Fetch(TCfgSql.Tabela(pCodTabela))
      End Function

      Shared Function Find(pCodPesquisaPadrao As Integer) As Pesquisa
         Dim query As SQL.Command = TCfgDb.Abrir("", "PesquisaPadrao", TCfgSql.EqInt("codpesquisapadrao", pCodPesquisaPadrao), "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New Pesquisa()
            item.Fill(query)
            query.Close()
            query.Free()
            Find = item
         End If
      End Function

      Overrides Sub Dispose()
         me.CampoChave = Null
         me.CampoDescricao = Null
         If Assigned(me.CamposBusca) Then
            me.CamposBusca.Free()
            me.CamposBusca = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
