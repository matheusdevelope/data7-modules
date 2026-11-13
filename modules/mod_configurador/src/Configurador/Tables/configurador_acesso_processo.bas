Imports configurador_sql
Imports configurador_tcfgbase


Namespace configurador_acesso_processo

   Class AcessoProcesso
      Inherits TCfgBase

      CodUsuario As Integer
      CodTabela As Integer
      CodProcessoTabela As Integer
      Permitido As Boolean

      Sub New()
         MyBase.New("AcessoProcesso")
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodUsuario = pQuery.Field("codusuario").AsInteger
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodProcessoTabela = pQuery.Field("codprocessotabela").AsInteger
         me.Permitido = me.GetFlagAsBoolean(pQuery.Field("permitido").AsString)
         me._loaded = True
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodUsuario = TCfgRow.AsInteger(pJson.GetString("codusuario"))
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodProcessoTabela = TCfgRow.AsInteger(pJson.GetString("codprocessotabela"))
         me.Permitido = me.GetFlagAsBoolean(pJson.GetString("permitido"))
         me._loaded = True
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodProcessoTabela)
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodUsuario", me.CodUsuario)
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodProcessoTabela", me.CodProcessoTabela)
            .Prop("Permitido", me.Permitido)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function FetchByUsuario(pCodTabela As Integer, pCodUsuario As Integer) As TTList<AcessoProcesso>
         Dim whereTexto As String = TCfgSql.Tabela(pCodTabela) & " AND " & TCfgSql.Usuario(pCodUsuario)
         Dim query As SQL.Command = TCfgDb.Abrir("", "AcessoProcessoTabela", whereTexto, "")
         Dim lista[] As AcessoProcesso = []
         While Not query.Eof
            Dim item As New AcessoProcesso()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         FetchByUsuario = lista
      End Function

      Shared Function Find(pCodTabela As Integer, pCodProcessoTabela As Integer, pCodUsuario As Integer) As AcessoProcesso
         Dim whereTexto As String = TCfgSql.AndInt(TCfgSql.Tabela(pCodTabela), "codprocessotabela", pCodProcessoTabela) & " AND " & TCfgSql.Usuario(pCodUsuario)
         Dim query As SQL.Command = TCfgDb.Abrir("", "AcessoProcessoTabela", whereTexto, "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New AcessoProcesso()
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
