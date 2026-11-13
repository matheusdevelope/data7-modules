Imports Forms
Imports configurador_sql
Imports configurador_tabela
Imports configurador_campo
Imports mod_register_config
Imports mod_register_eval
Imports mod_register_tabela

Namespace mod_register_eval_tests

   Class TRegisterEvalTests

      Private _passed As Integer
      Private _failed As Integer
      Private _log As String

      Sub New()
         MyBase.New()
         me._passed = 0
         me._failed = 0
         me._log = ""
      End Sub

      Shared Sub Run()
         Dim suite As New TRegisterEvalTests()
         suite.Execute()
         suite.Free()
      End Sub

      Sub Execute()
         me._line("=== TRegisterEval (sem formulario) ===")
         me._stageSql()
         me._stageSynthetic()
         me._stageTabela()
         me._line("")
         me._line("Passou: " & CStr(me._passed) & "  Falhou: " & CStr(me._failed))
         print(me._log)
         Forms.MessageBox.Show(me._log)
      End Sub

      Private Sub _stageSql()
         me._line("")
         me._line("-- TCfgSql --")
         Dim one As String = TCfgSql.AvaliarValorPadrao("FORMULA", "1")
         me._check("FORMULA 1 retorna valor", TRegisterEval.TextOf(one) <> "")
         me._line("  valor=[" & one & "] len=" & CStr(Len(one)))

         Dim emptyTipo As String = TCfgSql.AvaliarValorPadrao("", "1")
         me._check("tipo vazio + formula 1 retorna valor", TRegisterEval.TextOf(emptyTipo) <> "")
         me._line("  valor=[" & emptyTipo & "]")

         Dim fixo As String = TCfgSql.AvaliarValorPadrao("FIXO", "ABC")
         me._check("FIXO ABC", TRegisterEval.TextOf(fixo) = "ABC")

         me._check("condicao 1=1", TCfgSql.AvaliarCondicao("1=1", False))
         me._check("condicao S", TCfgSql.AvaliarCondicao("S", False))
         me._check("obrigatorio vazio = nao", Not TCfgSql.AvaliarCondicao("", False))
         me._check("editar vazio = sim", TCfgSql.AvaliarCondicao("", True))
         me._check("condicao 1=0", Not TCfgSql.AvaliarCondicao("1=0", False))
      End Sub

      Private Sub _stageSynthetic()
         me._line("")
         me._line("-- TRegisterField sintetico --")
         Dim defField As New TRegisterField()
         defField.Name = "DataInicio"
         defField.CanEditInsert = True
         defField.CanEditUpdate = True
         defField.TipoValorPadrao = "FORMULA"
         defField.FormulaValorPadrao = "1"
         Dim applied As String = TRegisterEval.ApplyDefaultTo("", defField)
         me._check("default em texto vazio", TRegisterEval.TextOf(applied) <> "")
         me._line("  aplicado=[" & applied & "]")
         Dim skipped As String = TRegisterEval.ApplyDefaultTo("ja preenchido", defField)
         me._check("nao sobrescreve texto", skipped = "ja preenchido")
         Dim fromName As String = TRegisterEval.ApplyDefaultTo("DataInicio", defField)
         me._check("placeholder nome recebe default", TRegisterEval.TextOf(fromName) <> "")
         defField.Free()

         Dim reqField As New TRegisterField()
         reqField.Name = "Nome"
         reqField.CondicaoObrigatorio = "S"
         me._check("obrigatorio S", TRegisterEval.IsRequired(reqField))
         reqField.CondicaoObrigatorio = ""
         me._check("obrigatorio vazio", Not TRegisterEval.IsRequired(reqField))
         reqField.CondicaoObrigatorio = "1=1"
         me._check("obrigatorio 1=1", TRegisterEval.IsRequired(reqField))
         reqField.Free()

         Dim editField As New TRegisterField()
         editField.Name = "Obs"
         editField.CanEditInsert = True
         editField.CanEditUpdate = True
         editField.CondicaoEditarInclusao = ""
         me._check("editar vazio permanece editavel", Not TRegisterEval.IsReadOnly(editField, "INCLUIR", False))
         editField.CondicaoEditarInclusao = "1=1"
         me._check("editar 1=1 editavel", Not TRegisterEval.IsReadOnly(editField, "INCLUIR", False))
         editField.CondicaoEditarInclusao = "1=0"
         me._check("editar 1=0 bloqueado", TRegisterEval.IsReadOnly(editField, "INCLUIR", False))
         editField.CondicaoEditarAlteracao = "1=0"
         me._check("alterar 1=0 bloqueado", TRegisterEval.IsReadOnly(editField, "ALTERAR", False))
         editField.Free()
      End Sub

      Private Sub _stageTabela()
         me._line("")
         me._line("-- Catalogo Ambient.Tabela / FromTabela --")
         Dim tabelaItem As Tabela = Ambient.Tabela()
         If Not Assigned(tabelaItem) Then
            me._check("Ambient.Tabela", False)
            Exit Sub
         End If
         me._line("tabela=" & tabelaItem.Nome & " campos=" & CStr(tabelaItem.Campos.Length))
         me._dumpCampos(tabelaItem)
         Dim cfg As TRegisterFormConfig = TRegisterTabela.FromTabela(tabelaItem)
         me._dumpMapped(cfg)
         cfg.Free()
      End Sub

      Private Sub _dumpCampos(pTabela As Tabela)
         Dim i As Integer
         Dim n As Integer = pTabela.Campos.Length - 1
         Dim nFormula As Integer = 0
         Dim nInc As Integer = 0
         Dim nAlt As Integer = 0
         Dim nObr As Integer = 0
         For i = 0 To n
            Dim campoItem As Campo = pTabela.Campos.Take(i)
            If Assigned(campoItem) Then
               Dim formula As String = TRegisterEval.TextOf(campoItem.FormulaValorPadrao)
               Dim tipo As String = TRegisterEval.TextOf(campoItem.TipoValorPadrao)
               Dim inc As String = TRegisterEval.TextOf(campoItem.CondicaoEditarInclusao)
               Dim alt As String = TRegisterEval.TextOf(campoItem.CondicaoEditarAlteracao)
               Dim obr As String = TRegisterEval.TextOf(campoItem.CondicaoObrigatorio)
               If formula <> "" Then
                  nFormula = nFormula + 1
               End If
               If inc <> "" Then
                  nInc = nInc + 1
               End If
               If alt <> "" Then
                  nAlt = nAlt + 1
               End If
               If obr <> "" Then
                  nObr = nObr + 1
               End If
               If (formula <> "") Or (inc <> "") Or (alt <> "") Or (obr <> "") Then
                  me._line("CAMPO " & campoItem.Nome & " tipoVP=[" & tipo & "] formula=[" & formula & "] inc=[" & inc & "] alt=[" & alt & "] obr=[" & obr & "]")
               End If
            End If
         Next
         me._line("raw formula=" & CStr(nFormula) & " inc=" & CStr(nInc) & " alt=" & CStr(nAlt) & " obr=" & CStr(nObr))
         me._check("catalogo tem formula ou condicao", CBool((nFormula + nInc + nAlt + nObr) > 0))
      End Sub

      Private Sub _dumpMapped(pCfg As TRegisterFormConfig)
         Dim i As Integer
         Dim n As Integer = pCfg.Fields.Length - 1
         Dim nFilled As Integer = 0
         Dim nReq As Integer = 0
         Dim nBlocked As Integer = 0
         For i = 0 To n
            Dim field As TRegisterField = pCfg.Fields.Take(i)
            Dim formula As String = TRegisterEval.TextOf(field.FormulaValorPadrao)
            Dim inc As String = TRegisterEval.TextOf(field.CondicaoEditarInclusao)
            Dim alt As String = TRegisterEval.TextOf(field.CondicaoEditarAlteracao)
            Dim obr As String = TRegisterEval.TextOf(field.CondicaoObrigatorio)
            If (formula <> "") Or (inc <> "") Or (alt <> "") Or (obr <> "") Then
               Dim resolved As String = TRegisterEval.ResolveDefault(field)
               Dim applied As String = TRegisterEval.ApplyDefaultTo("", field)
               Dim required As Boolean = TRegisterEval.IsRequired(field)
               Dim blockedInc As Boolean = TRegisterEval.IsReadOnly(field, "INCLUIR", False)
               Dim blockedAlt As Boolean = TRegisterEval.IsReadOnly(field, "ALTERAR", False)
               If TRegisterEval.TextOf(applied) <> "" Then
                  nFilled = nFilled + 1
               End If
               If required Then
                  nReq = nReq + 1
               End If
               If blockedInc Or blockedAlt Then
                  nBlocked = nBlocked + 1
               End If
               me._line("MAP " & field.Name & " tipoVP=[" & TRegisterEval.TextOf(field.TipoValorPadrao) & "] resolved=[" & resolved & "] applied=[" & applied & "] req=" & me._bool(required) & " roInc=" & me._bool(blockedInc) & " roAlt=" & me._bool(blockedAlt))
            End If
         Next
         me._line("mapped default aplicado=" & CStr(nFilled) & " obrigatorio=" & CStr(nReq) & " bloqueado=" & CStr(nBlocked))
      End Sub

      Private Function _bool(pValue As Boolean) As String
         If pValue Then
            _bool = "S"
         Else
            _bool = "N"
         End If
      End Function

      Private Sub _check(pTitle As String, pOk As Boolean)
         If pOk Then
            me._passed = me._passed + 1
            me._line("OK  " & pTitle)
         Else
            me._failed = me._failed + 1
            me._line("FALHOU  " & pTitle)
         End If
      End Sub

      Private Sub _line(pText As String)
         If me._log = "" Then
            me._log = pText
         Else
            me._log = me._log & Char(13) & pText
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
