Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_acesso_tabela

   Class AcessoTabela
      Inherits TCfgBase

      CodUsuario As Integer
      CodTabela As Integer
      PermitidoExcluir As Boolean
      PermitidoIncluir As Boolean
      PermitidoAlterar As Boolean
      PermitidoVisualizar As Boolean
      PermitidoConsultar As Boolean
      PermitidoExportar As Boolean
      PermitidoAnaliseGerencial As Boolean
      PermitidoOpcoesColuna As Boolean
      PermitidoIncluirAnexo As Boolean
      PermitidoAlterarAnexo As Boolean
      PermitidoExcluirAnexo As Boolean
      PermitidoVisualizarAnexo As Boolean
      PermitidoSalvarAnexo As Boolean

      Sub New()
         MyBase.New("AcessoTabela")
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodUsuario = pQuery.Field("codusuario").AsInteger
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.PermitidoExcluir = me.GetFlagAsBoolean(pQuery.Field("permitidoexcluir").AsString)
         me.PermitidoIncluir = me.GetFlagAsBoolean(pQuery.Field("permitidoincluir").AsString)
         me.PermitidoAlterar = me.GetFlagAsBoolean(pQuery.Field("permitidoalterar").AsString)
         me.PermitidoVisualizar = me.GetFlagAsBoolean(pQuery.Field("permitidovisualizar").AsString)
         me.PermitidoConsultar = me.GetFlagAsBoolean(pQuery.Field("permitidoconsultar").AsString)
         me.PermitidoExportar = me.GetFlagAsBoolean(pQuery.Field("permitidoexportar").AsString)
         me.PermitidoAnaliseGerencial = me.GetFlagAsBoolean(pQuery.Field("permitidoanalisegerencial").AsString)
         me.PermitidoOpcoesColuna = me.GetFlagAsBoolean(pQuery.Field("permitidoopcoescoluna").AsString)
         me.PermitidoIncluirAnexo = me.GetFlagAsBoolean(pQuery.Field("permitidoincluiranexo").AsString)
         me.PermitidoAlterarAnexo = me.GetFlagAsBoolean(pQuery.Field("permitidoalteraranexo").AsString)
         me.PermitidoExcluirAnexo = me.GetFlagAsBoolean(pQuery.Field("permitidoexcluiranexo").AsString)
         me.PermitidoVisualizarAnexo = me.GetFlagAsBoolean(pQuery.Field("permitidovisualizaranexo").AsString)
         me.PermitidoSalvarAnexo = me.GetFlagAsBoolean(pQuery.Field("permitidosalvaranexo").AsString)
         me._loaded = True
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodUsuario = TCfgRow.AsInteger(pJson.GetString("codusuario"))
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.PermitidoExcluir = me.GetFlagAsBoolean(pJson.GetString("permitidoexcluir"))
         me.PermitidoIncluir = me.GetFlagAsBoolean(pJson.GetString("permitidoincluir"))
         me.PermitidoAlterar = me.GetFlagAsBoolean(pJson.GetString("permitidoalterar"))
         me.PermitidoVisualizar = me.GetFlagAsBoolean(pJson.GetString("permitidovisualizar"))
         me.PermitidoConsultar = me.GetFlagAsBoolean(pJson.GetString("permitidoconsultar"))
         me.PermitidoExportar = me.GetFlagAsBoolean(pJson.GetString("permitidoexportar"))
         me.PermitidoAnaliseGerencial = me.GetFlagAsBoolean(pJson.GetString("permitidoanalisegerencial"))
         me.PermitidoOpcoesColuna = me.GetFlagAsBoolean(pJson.GetString("permitidoopcoescoluna"))
         me.PermitidoIncluirAnexo = me.GetFlagAsBoolean(pJson.GetString("permitidoincluiranexo"))
         me.PermitidoAlterarAnexo = me.GetFlagAsBoolean(pJson.GetString("permitidoalteraranexo"))
         me.PermitidoExcluirAnexo = me.GetFlagAsBoolean(pJson.GetString("permitidoexcluiranexo"))
         me.PermitidoVisualizarAnexo = me.GetFlagAsBoolean(pJson.GetString("permitidovisualizaranexo"))
         me.PermitidoSalvarAnexo = me.GetFlagAsBoolean(pJson.GetString("permitidosalvaranexo"))
         me._loaded = True
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodTabela) & "-" & CStr(me.CodUsuario)
      End Function   

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodUsuario", me.CodUsuario)
            .Prop("CodTabela", me.CodTabela)
            .Prop("PermitidoExcluir", me.PermitidoExcluir)
            .Prop("PermitidoIncluir", me.PermitidoIncluir)
            .Prop("PermitidoAlterar", me.PermitidoAlterar)
            .Prop("PermitidoVisualizar", me.PermitidoVisualizar)
            .Prop("PermitidoConsultar", me.PermitidoConsultar)
            .Prop("PermitidoExportar", me.PermitidoExportar)
            .Prop("PermitidoAnaliseGerencial", me.PermitidoAnaliseGerencial)
            .Prop("PermitidoOpcoesColuna", me.PermitidoOpcoesColuna)
            .Prop("PermitidoIncluirAnexo", me.PermitidoIncluirAnexo)
            .Prop("PermitidoAlterarAnexo", me.PermitidoAlterarAnexo)
            .Prop("PermitidoExcluirAnexo", me.PermitidoExcluirAnexo)
            .Prop("PermitidoVisualizarAnexo", me.PermitidoVisualizarAnexo)
            .Prop("PermitidoSalvarAnexo", me.PermitidoSalvarAnexo)
            ToString = .Text
            .Free()
         End With
      End Function


      Shared Function Find(pCodTabela As Integer, pCodUsuario As Integer) As AcessoTabela
         Dim whereTexto As String = TCfgSql.Tabela(pCodTabela) & " AND " & TCfgSql.Usuario(pCodUsuario)
         Dim query As SQL.Command = TCfgDb.Abrir("", "AcessoTabela", whereTexto, "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New AcessoTabela()
            item.Fill(query)
            query.Close()
            query.Free()
            Find = item
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
