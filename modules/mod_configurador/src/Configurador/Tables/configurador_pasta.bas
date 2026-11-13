Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_pasta

   Class Pasta
      Inherits TCfgBase

      CodTabela As Integer
      CodPasta As Integer
      Titulo As String
      Proprietario As String
      Status As String
      Estrutura As String
      MargemEditor As Integer
      SubCadastro As String
      Campos[] As configurador_campo.Campo

      Sub New()
         MyBase.New("Pasta")
         me.Campos = []
         me.Campos.OwnsObjects = False
      End Sub

      Function EhSubcadastro() As Boolean
         EhSubcadastro = me.GetFlagAsBoolean(me.SubCadastro)
      End Function

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodPasta = TCfgRow.AsInteger(pJson.GetString("codpasta"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
         me.Status = TCfgRow.AsString(pJson.GetString("status"))
         me.Estrutura = TCfgRow.AsString(pJson.GetString("estrutura"))
         me.MargemEditor = TCfgRow.AsInteger(pJson.GetString("margemeditor"))
         me.SubCadastro = TCfgRow.AsString(pJson.GetString("subcadastro"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodPasta = pQuery.Field("codpasta").AsInteger
         me.Titulo = pQuery.Field("titulo").AsString
         me.Proprietario = pQuery.Field("proprietario").AsString
         me.Status = pQuery.Field("status").AsString
         me.Estrutura = pQuery.Field("estrutura").AsString
         me.MargemEditor = pQuery.Field("margemeditor").AsInteger
         me.SubCadastro = pQuery.Field("subcadastro").AsString
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodPasta)
      End Function       

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodPasta", me.CodPasta)
            .Prop("Titulo", me.Titulo)
            .Prop("Proprietario", me.Proprietario)
            .Prop("Status", me.Status)
            .Prop("Estrutura", me.Estrutura)
            .Prop("MargemEditor", me.MargemEditor)
            .Prop("SubCadastro", me.SubCadastro)
            ToString = .Text
            .Free()
         End With
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codpasta") As TTList<Pasta>
         Dim query As SQL.Command = TCfgDb.Abrir("", "Pasta", pWhere, pOrder)
         Dim lista[] As Pasta = []
         While Not query.Eof
            Dim item As New Pasta()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Pasta>
         FetchByTabela = Pasta.Fetch(TCfgSql.Tabela(pCodTabela))
      End Function

      Shared Function Find(pCodTabela As Integer, pCodPasta As Integer) As Pasta
         Dim whereTexto As String = TCfgSql.AndInt(TCfgSql.Tabela(pCodTabela), "codpasta", pCodPasta)
         Dim query As SQL.Command = TCfgDb.Abrir("", "Pasta", whereTexto, "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New Pasta()
            item.Fill(query)
            query.Close()
            query.Free()
            Find = item
         End If
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Campos) Then
            me.Campos.OwnsObjects = False
            me.Campos.Free()
            me.Campos = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
