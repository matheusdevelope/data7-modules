Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_grupotabela

   Class GrupoTabela
      Inherits TCfgBase

      CodGrupoTabela As Integer
      Nome As String
      Proprietario As String

      Sub New()
         MyBase.New("GrupoTabela")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodGrupoTabela = TCfgRow.AsInteger(pJson.GetString("codgrupotabela"))
         me.Nome = TCfgRow.AsString(pJson.GetString("nome"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodGrupoTabela = pQuery.Field("codgrupotabela").AsInteger
         me.Nome = pQuery.Field("nome").AsString
         me.Proprietario = pQuery.Field("proprietario").AsString
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodGrupoTabela)
      End Function 

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodGrupoTabela", me.CodGrupoTabela)
            .Prop("Nome", me.Nome)
            .Prop("Proprietario", me.Proprietario)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Find(pCodGrupoTabela As Integer) As GrupoTabela
         Dim query As SQL.Command = TCfgDb.Abrir("", "GrupoTabela", TCfgSql.EqInt("codgrupotabela", pCodGrupoTabela), "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New GrupoTabela()
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
