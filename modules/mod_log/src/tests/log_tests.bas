Imports mod_tobject
Imports TablesSql
Imports table_logsistema
Imports table_logsistemadetalhe
Imports mod_log
Imports mod_log_type
Imports mod_log_item
Imports mod_log_context
Imports mod_log_batch

Namespace mod_log_tests

   Private Dim _suite As TLogTest

   ' Writes real LogSistema rows and deletes only the codes it created.
   ' Product rows follow docs/logssitema-inclusão-de-produto.csv.
   Class TLogTest
      Inherits TTObject

      Passed As Integer
      Failed As Integer

      Private _ids[] As Integer
      Private _lastError As String

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._ids = []
         me._lastError = ""
      End Sub

      Shared Function Suite() As TLogTest
         If Not Assigned(_suite) Then
            _suite = New TLogTest()
         End If
         Suite = _suite
      End Function

      Shared Sub Setup()
         TLogTest.Suite().DoSetup()
      End Sub

      Shared Sub StageSession()
         TLogTest.Suite().DoSession()
      End Sub

      Shared Sub StageProductInsert()
         TLogTest.Suite().DoProductInsert()
      End Sub

      Shared Sub StageProductUpdate()
         TLogTest.Suite().DoProductUpdate()
      End Sub

      Shared Sub StageBatch()
         TLogTest.Suite().DoBatch()
      End Sub

      Shared Sub StageEdges()
         TLogTest.Suite().DoEdges()
      End Sub

      Shared Sub Cleanup()
         TLogTest.Suite().DoCleanup()
      End Sub

      Shared Sub Teardown()
         TLogTest.Suite().DoTeardown()
      End Sub

      Sub DoSetup()
         me.Passed = 0
         me.Failed = 0
         me._lastError = ""
         If Not Assigned(me._ids) Then
            me._ids = []
         End If
         me.DoCleanup()
         mod_logger.TimeStart("log-suite")
      End Sub

      Sub DoTeardown()
         me.DoCleanup()
         mod_logger.TimeEnd("log-suite")
         mod_logger.Info("Result: " & CStr(me.Passed) & " ok, " & CStr(me.Failed) & " failed")
         If me.Failed > 0 Then
            Throw New Exception("Logg test suite failed: " & CStr(me.Failed) & " assertion(s)")
         End If
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            mod_logger.Info("OK  " & pMsg)
         Else
            me.Failed = me.Failed + 1
            mod_logger.Info("FAIL  " & pMsg)
            Throw New Exception("FAIL: " & pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg & " (got=[" & pGot & "] want=[" & pWant & "])")
      End Sub

      Sub AssertEqInt(pGot As Integer, pWant As Integer, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg & " (got=" & CStr(pGot) & " want=" & CStr(pWant) & ")")
      End Sub

      Function Clip(pValue As String, pMax As Integer) As String
         If pValue.Length <= pMax Then
            Clip = pValue
         Else
            Clip = pValue.Left(pMax)
         End If
      End Function

      Function Quote(pName As String) As String
         Quote = TSql.Dialect().QuoteIdent(pName)
      End Function

      Sub Track(pLog As Logg)
         me._ids.Push(pLog.CodLogSistema)
      End Sub

      Function IdList() As String
         Dim text As String = ""
         Dim i As Integer
         Dim total As Integer = me._ids.Length
         For i = 0 To total - 1
            If i > 0 Then
               text = text & ", "
            End If
            text = text & CStr(me._ids.Take(i))
         Next
         IdList = text
      End Function

      Sub DeleteIds(pIds As String)
         If Trim(pIds) = "" Then
            Exit Sub
         End If
         Dim dialect As TSqlDialect = TSql.Dialect()
         TSql.ExecScript("DELETE FROM " & dialect.QuoteTable("", "LogSistemaDetalhe") & " WHERE " & dialect.QuoteIdent("Id_LogSistema") & " IN (" & pIds & ")")
         TSql.ExecScript("DELETE FROM " & dialect.QuoteTable("", "LogSistema") & " WHERE " & dialect.QuoteIdent("CodLogSistema") & " IN (" & pIds & ")")
      End Sub

      Sub DoCleanup()
         Dim ids As String = me.IdList()
         me.DeleteIds(ids)
         me._ids = []
      End Sub

      Function SaveFailed(pLog As Logg) As Boolean
         me._lastError = ""
         Try
            LogBatch.SaveOne(pLog)
            SaveFailed = False
         Catch ex As Exception
            me._lastError = ex.Message
            Return True
         End Try
      End Function

      Function LoadHeader(pId As Integer) As TLogSistema
         LoadHeader = TLogSistema.Find(me.Quote("CodLogSistema") & " = " & CStr(pId))
      End Function

      Function CountBetween(pFrom As Integer, pTo As Integer) As Integer
         Dim dialect As TSqlDialect = TSql.Dialect()
         Dim sqlText As String = "SELECT CAST(COUNT(*) AS INTEGER) AS ok FROM " & dialect.QuoteTable("", "LogSistema") & " WHERE " & dialect.QuoteIdent("CodLogSistema") & " BETWEEN " & CStr(pFrom) & " AND " & CStr(pTo)
         CountBetween = TSql.ExecScalarInteger(sqlText, 0)
      End Function

      Function NewProductLog(pType As TLogType) As Logg
         Dim created As New Logg()
         created.Nome = "Produto"
         created.SetType(pType)
         created.NomeRotina = "Cadastro"
         created.CodTabela = 35
         NewProductLog = created
      End Function

      Sub FillInsertItems(pLog As Logg)
         pLog.AddItem("Ativo", "", "'S'")
         pLog.AddItem("CodProduto", "", "706")
         pLog.AddItem("Nome", "", "'JOGO DE NAMORADEIRA'")
         pLog.AddItem("CodigoFornecedor", "", "'706'")
         pLog.AddItem("Endereco", "", "null")
         pLog.AddItem("PesoBruto", "", "0")
         pLog.AddItem("CodTipoProduto", "", "'ME'")
         pLog.AddItem("CodMarca", "", "95")
         pLog.AddItem("PercentualCSLL", "", "1.08")
         pLog.AddItem("NCM", "", "'63090010'")
         pLog.AddItem("OrigemMercadoria", "", "'Nacional'")
         pLog.AddItem("DataCadastro", "", "'01/10/2025'")
         pLog.AddItem("PrecoVenda", "", "0.00")
         pLog.AddItem("PermiteVenda", "", "'N'")
      End Sub

      Sub FillUpdateItems(pLog As Logg)
         pLog.AddItem("Ativo", "'S'", "'N'")
         pLog.AddItem("Nome", "'JOGO DE NAMORADEIRA'", "'JOGO DE NAMORADEIRA PLUS'")
         pLog.AddItem("PrecoVenda", "0.00", "19.90", "tabela de preco")
         pLog.AddItem("CodMarca", "95", "120")
         pLog.AddItem("NCM", "'63090010'", "'63090090'")
         pLog.AddItem("CodTipoProduto", "'ME'", "'PA'")
         pLog.AddItem("PermiteVenda", "'N'", "'S'")
         pLog.AddItem("PercentualCSLL", "1.08", "1.65")
         pLog.AddItem("Observacao", "null", "'ajuste via teste'")
         pLog.AddItem("DataCadastro", "'01/10/2025'", "'26/09/2026'")
      End Sub

      Sub AssertSession(pRow As TLogSistema)
         me.AssertEqInt(pRow.CodEmpresa, Data7.CodEmpresa, "CodEmpresa from session")
         me.AssertEqInt(pRow.CodFilial, Data7.CodFilial, "CodFilial from session")
         me.AssertEqInt(pRow.CodUsuario, Data7.CodUsuario, "CodUsuario from session")
         me.AssertEq(pRow.NomeUsuario, me.Clip(Data7.NomeUsuario, 100), "NomeUsuario from session")
         me.AssertEq(pRow.NomeComputador, me.Clip(Environment.MachineName, 100), "NomeComputador from session")
         me.AssertEq(pRow.UsuarioWindows, me.Clip(Environment.UserName, 30), "UsuarioWindows from session")
         me.AssertEq(pRow.NomeSistema, "Data7", "NomeSistema default")
         me.AssertTrue(Trim(pRow.VersaoSistema) <> "", "VersaoSistema read from Sistema")
      End Sub

      Sub AssertHeader(pLog As Logg, pRow As TLogSistema)
         me.AssertEqInt(pRow.CodLogSistema, pLog.CodLogSistema, "CodLogSistema")
         me.AssertEq(pRow.Nome, pLog.Nome, "Nome")
         me.AssertEq(pRow.TipoLog, pLog.TipoLog, "TipoLog")
         me.AssertEq(pRow.NomeRotina, pLog.NomeRotina, "NomeRotina")
         me.AssertEq(pRow.Hora, pLog.Hora, "Hora")
         me.AssertEq(pRow.Data.ToString("yyyy-mm-dd"), pLog.Data.ToString("yyyy-mm-dd"), "Data")
         me.AssertEq(pRow.Observacao, pLog.Observacao, "Observacao")
         me.AssertEq(pRow.ClausulaWhere, pLog.ClausulaWhere, "ClausulaWhere")
         me.AssertEq(pRow.VersaoSistema, pLog.VersaoSistema, "VersaoSistema")
         me.AssertEq(pRow.NomeSchema, pLog.NomeSchema, "NomeSchema")
         me.AssertEqInt(pRow.CodTabela, pLog.CodTabela, "CodTabela")
         me.AssertEqInt(pRow.CodPeriodoCaixa, pLog.CodPeriodoCaixa, "CodPeriodoCaixa")
         me.AssertEqInt(pRow.CodUsuario, pLog.CodUsuario, "CodUsuario")
         me.AssertEqInt(pRow.CodEmpresa, pLog.CodEmpresa, "CodEmpresa")
         me.AssertEqInt(pRow.CodFilial, pLog.CodFilial, "CodFilial")
      End Sub

      Sub AssertDetail(pRow As TLogSistemaDetalhe, pItem As LogItem, pMsg As String)
         me.AssertEqInt(pRow.Sequencia, pItem.Sequencia, pMsg & " Sequencia")
         me.AssertEq(pRow.Nome, pItem.Nome, pMsg & " Nome")
         me.AssertEq(pRow.ValorAntigo, pItem.ValorAntigo, pMsg & " ValorAntigo")
         me.AssertEq(pRow.Valor, pItem.Valor, pMsg & " Valor")
         me.AssertEq(pRow.Observacao, pItem.Observacao, pMsg & " Observacao")
      End Sub

      Sub AssertRoundtrip(pLog As Logg)
         Dim header As TLogSistema = me.LoadHeader(pLog.CodLogSistema)
         me.AssertTrue(Assigned(header), "header loaded " & CStr(pLog.CodLogSistema))
         me.AssertHeader(pLog, header)
         header.Free()
         Dim details[] As TLogSistemaDetalhe = TLogSistemaDetalhe.Fetch(me.Quote("Id_LogSistema") & " = " & CStr(pLog.CodLogSistema), me.Quote("Sequencia"), 0)
         me.AssertEqInt(details.Length, pLog.Items.Length, "detail count " & pLog.TipoLog)
         Dim i As Integer
         Dim total As Integer = pLog.Items.Length
         For i = 0 To total - 1
            me.AssertDetail(details.Take(i), pLog.Items.Take(i), pLog.Nome & "[" & CStr(i) & "]")
         Next
         details.OwnsObjects = True
         details.Free()
      End Sub

      Sub DoSession()
         mod_logger.TimeStart("session")
         Dim entry As New Logg()
         entry.Nome = "Produto"
         entry.SetType(TLogType.ltInsert())
         entry.NomeRotina = "Cadastro"
         entry.CodTabela = 35
         entry.AddItem("PrecoVenda", "1.00", "2.00")
         LogBatch.SaveOne(entry)
         me.AssertTrue(entry.IsSaved(), "single log is saved")
         me.AssertTrue(entry.CodLogSistema > 0, "single log received a code")
         me.Track(entry)
         Dim header As TLogSistema = me.LoadHeader(entry.CodLogSistema)
         me.AssertTrue(Assigned(header), "single header exists")
         me.AssertSession(header)
         me.AssertHeader(entry, header)
         header.Free()
         me.AssertRoundtrip(entry)
         me.AssertTrue(me.SaveFailed(entry), "second Save is rejected")
         me.AssertTrue(me._lastError.IndexOf("already saved") >= 0, "second Save explains why")
         LogContext.Invalidate()
         Dim again As New Logg()
         again.Nome = "Produto"
         again.SetType(TLogType.ltInsert())
         again.NomeRotina = "Cadastro"
         LogBatch.SaveOne(again)
         me.AssertTrue(again.CodLogSistema > entry.CodLogSistema, "code after Invalidate still advances")
         me.Track(again)
         again.Free()
         entry.Free()
         mod_logger.TimeEnd("session")
      End Sub

      Sub DoProductInsert()
         mod_logger.TimeStart("product-insert")
         Dim entry As Logg = me.NewProductLog(TLogType.ltInsert())
         me.FillInsertItems(entry)
         LogBatch.SaveOne(entry)
         me.Track(entry)
         me.AssertEq(entry.TipoLog, "I", "insert stores TipoLog I")
         me.AssertEqInt(entry.Items.Length, 14, "insert has the sample fields")
         me.AssertEq(entry.Items.Take(0).ValorAntigo, "", "insert leaves ValorAntigo empty")
         me.AssertEqInt(entry.Items.Take(0).Sequencia, 1, "first Sequencia is 1")
         me.AssertEqInt(entry.Items.Take(13).Sequencia, 14, "last Sequencia follows the list")
         me.AssertRoundtrip(entry)
         entry.Free()
         mod_logger.TimeEnd("product-insert")
      End Sub

      Sub DoProductUpdate()
         mod_logger.TimeStart("product-update")
         Dim entry As Logg = me.NewProductLog(TLogType.ltUpdate())
         entry.ClausulaWhere = "CodProduto = 706"
         entry.NomeUsuario = "Nubia"
         entry.NomeComputador = "DESKTOP-GHAB3EF"
         entry.UsuarioWindows = "Vendas1"
         entry.Hora = "11:27:24"
         entry.VersaoSistema = "1.2.574.92"
         entry.NomeSistema = "Data7"
         entry.NomeSchema = "dbo"
         me.FillUpdateItems(entry)
         Dim tampered As LogItem = entry.Items.Take(0)
         tampered.Sequencia = 50
         LogBatch.SaveOne(entry)
         me.Track(entry)
         me.AssertEq(entry.TipoLog, "A", "update stores TipoLog A")
         me.AssertEqInt(entry.Items.Take(0).Sequencia, 1, "save renumbers Sequencia")
         me.AssertEq(entry.NomeUsuario, "Nubia", "caller NomeUsuario is kept")
         me.AssertEq(entry.Hora, "11:27:24", "caller Hora is kept")
         me.AssertEq(entry.VersaoSistema, "1.2.574.92", "caller VersaoSistema skips the Sistema query")
         me.AssertEq(entry.Items.Take(2).Observacao, "tabela de preco", "item Observacao is kept")
         me.AssertRoundtrip(entry)
         entry.Free()
         mod_logger.TimeEnd("product-update")
      End Sub

      Sub DoBatch()
         mod_logger.TimeStart("batch-45")
         Dim batch As New LogBatch()
         Dim logs[] As Logg = []
         logs.OwnsObjects = False
         Dim i As Integer
         For i = 1 To 45
            Dim created As Logg = batch.NewLog()
            created.Nome = "Produto"
            created.NomeRotina = "Cadastro"
            created.CodTabela = 35
            created.ClausulaWhere = "CodProduto = " & CStr(700 + i)
            Dim slot As Integer = i Mod 3
            If slot = 1 Then
               created.SetType(TLogType.ltUpdate())
               created.AddItem("PrecoVenda", "1.00", CStr(i) & ".50")
            ElseIf slot = 2 Then
               created.SetType(TLogType.ltDelete())
               created.AddItem("Ativo", "'S'", "'N'")
            Else
               created.SetType(TLogType.ltInsert())
               created.AddItem("CodProduto", "", CStr(700 + i))
            End If
            created.AddItem("Nome", "'ITEM'", "'ITEM " & CStr(i) & "'")
            logs.Push(created)
         Next
         me.AssertEqInt(batch.Count(), 45, "batch holds 45 logs")
         batch.Save()
         Dim firstCode As Integer = logs.Take(0).CodLogSistema
         Dim sharedVersion As String = logs.Take(0).VersaoSistema
         me.AssertTrue(firstCode > 0, "batch assigned the first code")
         me.AssertTrue(Trim(sharedVersion) <> "", "batch resolved VersaoSistema")
         For i = 0 To logs.Length - 1
            Dim saved As Logg = logs.Take(i)
            me.AssertTrue(saved.IsSaved(), "batch log saved " & CStr(i))
            me.AssertEqInt(saved.CodLogSistema, firstCode + i, "batch codes are contiguous")
            me.AssertEq(saved.VersaoSistema, sharedVersion, "batch shares one VersaoSistema")
            me.AssertEqInt(saved.CodUsuario, logs.Take(0).CodUsuario, "batch shares CodUsuario")
            me.AssertEqInt(saved.Items.Length, 2, "batch log has 2 items")
            me.AssertEqInt(saved.Items.Take(0).Sequencia, 1, "batch item 1")
            me.AssertEqInt(saved.Items.Take(1).Sequencia, 2, "batch item 2")
            me.Track(saved)
         Next
         Dim lastCode As Integer = logs.Take(44).CodLogSistema
         me.AssertEqInt(me.CountBetween(firstCode, lastCode), 45, "both header chunks were inserted")
         me.AssertRoundtrip(logs.Take(0))
         me.AssertRoundtrip(logs.Take(39))
         me.AssertRoundtrip(logs.Take(40))
         me.AssertRoundtrip(logs.Take(44))
         me.AssertTrue(me.SaveFailed(logs.Take(0)), "saved batch log cannot be saved again")
         logs.Free()
         batch.Free()
         mod_logger.TimeEnd("batch-45")
      End Sub

      Sub DoEdges()
         mod_logger.TimeStart("edges")
         Dim emptyBatch As New LogBatch()
         emptyBatch.Save()
         me.AssertEqInt(emptyBatch.Count(), 0, "empty batch does nothing")
         emptyBatch.Free()

         Dim missingName As New Logg()
         missingName.SetType(TLogType.ltInsert())
         me.AssertTrue(me.SaveFailed(missingName), "Nome is required")
         me.AssertTrue(me._lastError.IndexOf("without Nome") >= 0, "missing Nome message")
         missingName.Free()

         Dim missingType As New Logg()
         missingType.Nome = "Produto"
         me.AssertTrue(me.SaveFailed(missingType), "TipoLog is required")
         me.AssertTrue(me._lastError.IndexOf("without TipoLog") >= 0, "missing TipoLog message")
         missingType.Free()

         Dim blankItem As Logg = me.NewProductLog(TLogType.ltInsert())
         blankItem.AddItem("   ", "", "1")
         me.AssertTrue(me.SaveFailed(blankItem), "item Nome is required")
         me.AssertTrue(me._lastError.IndexOf("without Nome") >= 0, "blank item message")
         blankItem.Free()

         Dim huge As String = ""
         Dim n As Integer
         For n = 1 To 201
            huge = huge & "A"
         Next
         Dim tooLong As Logg = me.NewProductLog(TLogType.ltInsert())
         tooLong.Nome = huge
         me.AssertTrue(me.SaveFailed(tooLong), "Nome over 200 is rejected")
         me.AssertTrue(me._lastError.IndexOf("exceeds") >= 0, "length message")
         tooLong.Free()

         Dim quoted As Logg = me.NewProductLog(TLogType.ltUpdate())
         quoted.Nome = "D'agua"
         quoted.AddItem("Nome", "'JOGO'", "'JOGO D'AGUA'")
         LogBatch.SaveOne(quoted)
         me.Track(quoted)
         me.AssertRoundtrip(quoted)
         quoted.Free()

         Dim noTable As New Logg()
         noTable.Nome = "Produto"
         noTable.SetType(TLogType.ltInsert())
         noTable.NomeRotina = "Cadastro"
         LogBatch.SaveOne(noTable)
         me.Track(noTable)
         me.AssertEqInt(noTable.CodTabela, 0, "omitted CodTabela stays empty")
         me.AssertRoundtrip(noTable)
         noTable.Free()

         Dim headerOnly As Logg = me.NewProductLog(TLogType.ltDelete())
         headerOnly.ClausulaWhere = "CodProduto = 706"
         headerOnly.TipoLog = "X"
         LogBatch.SaveOne(headerOnly)
         me.Track(headerOnly)
         me.AssertEq(headerOnly.TipoLog, "X", "custom TipoLog is stored")
         me.AssertEqInt(headerOnly.Items.Length, 0, "header without items")
         me.AssertRoundtrip(headerOnly)
         headerOnly.Free()

         Dim template As Logg = me.NewProductLog(TLogType.ltInsert())
         template.AddItem("Ativo", "", "'S'")
         Dim leftLog As Logg = template.Copy()
         Dim rightLog As Logg = template.Copy()
         leftLog.AddItem("CodProduto", "", "801")
         rightLog.AddItem("CodProduto", "", "802")
         me.AssertEqInt(template.Items.Length, 1, "Copy does not share items")
         me.AssertTrue(Not template.IsSaved(), "Copy leaves the template unsaved")
         Dim copies As New LogBatch()
         copies.Add(leftLog)
         copies.Add(rightLog)
         copies.Save()
         me.AssertEqInt(rightLog.CodLogSistema, leftLog.CodLogSistema + 1, "two-log batch uses one block")
         me.AssertEq(leftLog.Items.Take(1).Valor, "801", "left copy kept its item")
         me.AssertEq(rightLog.Items.Take(1).Valor, "802", "right copy kept its item")
         me.Track(leftLog)
         me.Track(rightLog)
         me.AssertRoundtrip(leftLog)
         me.AssertRoundtrip(rightLog)
         copies.Free()
         template.Free()

         Dim presetSource As Logg = me.NewProductLog(TLogType.ltInsert())
         presetSource.AddItem("CodProduto", "", "900")
         LogBatch.SaveOne(presetSource)
         Dim reusedCode As Integer = presetSource.CodLogSistema
         me.Track(presetSource)
         me.DeleteIds(CStr(reusedCode))
         Dim preset As Logg = me.NewProductLog(TLogType.ltUpdate())
         preset.CodLogSistema = reusedCode
         preset.AddItem("PrecoVenda", "1.00", "3.00")
         Dim neighborA As Logg = me.NewProductLog(TLogType.ltInsert())
         neighborA.AddItem("CodProduto", "", "901")
         Dim neighborB As Logg = me.NewProductLog(TLogType.ltInsert())
         neighborB.AddItem("CodProduto", "", "902")
         Dim mixed As New LogBatch(False)
         mixed.Add(neighborA)
         mixed.Add(preset)
         mixed.Add(neighborB)
         mixed.Save()
         me.AssertEqInt(preset.CodLogSistema, reusedCode, "preset CodLogSistema is kept")
         me.AssertEqInt(neighborB.CodLogSistema, neighborA.CodLogSistema + 1, "only logs without a code consume the block")
         me.AssertTrue(neighborA.CodLogSistema <> reusedCode, "generated code differs from the preset")
         me.Track(neighborA)
         me.Track(neighborB)
         me.AssertRoundtrip(preset)
         mixed.Free()
         preset.Free()
         neighborA.Free()
         neighborB.Free()
         presetSource.Free()
         mod_logger.TimeEnd("edges")
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New TLogTest()
      End Function

      Overrides Sub Dispose()
         If Assigned(me._ids) Then
            me._ids.Free()
            me._ids = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
