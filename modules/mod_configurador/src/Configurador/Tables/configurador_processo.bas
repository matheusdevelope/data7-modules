Imports configurador_sql
Imports configurador_tcfgbase
Imports configurador_acesso_processo

Namespace configurador_processo

   Class Processo
      Inherits TCfgBase

      CodTabela As Integer
      CodProcessoTabela As Integer
      Titulo As String
      Imagem As String
      Ordem As Integer
      LocalExibir As String
      Proprietario As String
      ShortCut As Integer
      Acao As String
      ValorAcao As String
      Bloquear As String
      VerificarBloqueio As String
      Validacao As String
      Status As String
      CodWhatsAppConfiguracoesEnvio As Integer
      Acesso As AcessoProcesso

      Sub New()
         MyBase.New("Processo")
         me.Acesso = New AcessoProcesso()
      End Sub

      Sub PrepararAcesso()
         If Not Assigned(me.Acesso) Then
            me.Acesso = New AcessoProcesso()
         End If
         me.Acesso.CodTabela = me.CodTabela
         me.Acesso.CodProcessoTabela = me.CodProcessoTabela
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodProcessoTabela = TCfgRow.AsInteger(pJson.GetString("codprocessotabela"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.Imagem = TCfgRow.AsString(pJson.GetString("imagem"))
         me.Ordem = TCfgRow.AsInteger(pJson.GetString("ordem"))
         me.LocalExibir = TCfgRow.AsString(pJson.GetString("localexibir"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
         me.ShortCut = TCfgRow.AsInteger(pJson.GetString("shortcut"))
         me.Acao = TCfgRow.AsString(pJson.GetString("acao"))
         me.ValorAcao = TCfgRow.AsString(pJson.GetString("valoracao"))
         me.Bloquear = TCfgRow.AsString(pJson.GetString("bloquear"))
         me.VerificarBloqueio = TCfgRow.AsString(pJson.GetString("verificarbloqueio"))
         me.Validacao = TCfgRow.AsString(pJson.GetString("validacao"))
         me.Status = TCfgRow.AsString(pJson.GetString("status"))
         me.CodWhatsAppConfiguracoesEnvio = TCfgRow.AsInteger(pJson.GetString("codwhatsappconfiguracoesenvio"))
         me.PrepararAcesso()
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodProcessoTabela = pQuery.Field("codprocessotabela").AsInteger
         me.Titulo = pQuery.Field("titulo").AsString
         me.Imagem = pQuery.Field("imagem").AsString
         me.Ordem = pQuery.Field("ordem").AsInteger
         me.LocalExibir = pQuery.Field("localexibir").AsString
         me.Proprietario = pQuery.Field("proprietario").AsString
         me.ShortCut = pQuery.Field("shortcut").AsInteger
         me.Acao = pQuery.Field("acao").AsString
         me.ValorAcao = pQuery.Field("valoracao").AsString
         me.Bloquear = pQuery.Field("bloquear").AsString
         me.VerificarBloqueio = pQuery.Field("verificarbloqueio").AsString
         me.Validacao = pQuery.Field("validacao").AsString
         me.Status = pQuery.Field("status").AsString
         me.CodWhatsAppConfiguracoesEnvio = pQuery.Field("codwhatsappconfiguracoesenvio").AsInteger
         me.PrepararAcesso()
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodProcessoTabela)
      End Function 

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodProcessoTabela", me.CodProcessoTabela)
            .Prop("Titulo", me.Titulo)
            .Prop("Imagem", me.Imagem)
            .Prop("Ordem", me.Ordem)
            .Prop("LocalExibir", me.LocalExibir)
            .Prop("Proprietario", me.Proprietario)
            .Prop("ShortCut", me.ShortCut)
            .Prop("Acao", me.Acao)
            .Prop("ValorAcao", me.ValorAcao)
            .Prop("Bloquear", me.Bloquear)
            .Prop("VerificarBloqueio", me.VerificarBloqueio)
            .Prop("Validacao", me.Validacao)
            .Prop("Status", me.Status)
            .Prop("CodWhatsAppConfiguracoesEnvio", me.CodWhatsAppConfiguracoesEnvio)
            ToString = .Text
            .Free()
         End With
      End Function

      Sub AplicarAcesso(pRow As AcessoProcesso, pCodUsuario As Integer)
         Dim antigo As AcessoProcesso = me.Acesso
         If Assigned(pRow) Then
            me.Acesso = pRow
         Else
            me.Acesso = New AcessoProcesso()
            me.Acesso.CodTabela = me.CodTabela
            me.Acesso.CodProcessoTabela = me.CodProcessoTabela
            me.Acesso.CodUsuario = pCodUsuario
         End If
         If Assigned(antigo) And (antigo <> pRow) Then
            antigo.Free()
         End If
      End Sub

      Sub CarregarAcesso(pCodUsuario As Integer)
         me.AplicarAcesso(AcessoProcesso.Find(me.CodTabela, me.CodProcessoTabela, pCodUsuario), pCodUsuario)
      End Sub

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, codprocessotabela") As TTList<Processo>
         Dim query As SQL.Command = TCfgDb.Abrir("", "ProcessoTabela", pWhere, pOrder)
         Dim lista[] As Processo = []
         While Not query.Eof
            Dim item As New Processo()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Processo>
         FetchByTabela = Processo.Fetch(TCfgSql.Tabela(pCodTabela))
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Acesso) Then
            me.Acesso.Free()
            me.Acesso = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
