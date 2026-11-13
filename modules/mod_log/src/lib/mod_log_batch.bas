
Imports Collections
Imports mod_tobject
Imports TablesSequence
Imports TablesSql
Imports TablesTable
Imports table_logsistema
Imports table_logsistemadetalhe
Imports mod_log
Imports mod_log_item
Imports mod_log_context

Namespace mod_log_batch

   Private Dim _sequenceName As String

   ' Collects several logs and writes them through TTable inserts.
   ' Codes come from NextValue (a loop when the batch has two or more).
   ' ALTER SEQUENCE is used only when the sequence is behind MAX(CodLogSistema),
   ' and the prepared-statement pool is cleared afterwards.
   Class LogBatch
      Inherits TTObject

      Context As LogContext
      Private _logs[] As Logg
      Private _sequence As TSequence
      Private _lease As TSequenceLease
      Private _saved As Boolean
      Private _template As Logg
      Private _wheres As StringList
      Private _codes As StringList
      Private _itemLog As StringList
      Private _itemSeq As StringList
      Private _itemNome As StringList
      Private _itemOld As StringList
      Private _itemNew As StringList
      Private _curSeq As Integer

      Sub New(pOwnsLogs As Boolean = True)
         MyBase.New()
         me.Context = NULL
         me._logs = []
         me._logs.OwnsObjects = pOwnsLogs
         me._sequence = NULL
         me._lease = NULL
         me._saved = False
         me._template = NULL
         me._wheres = New StringList()
         me._codes = New StringList()
         me._itemLog = New StringList()
         me._itemSeq = New StringList()
         me._itemNome = New StringList()
         me._itemOld = New StringList()
         me._itemNew = New StringList()
         me._curSeq = 0
      End Sub

      Function NewLog() As Logg
         me.RequireOpen()
         Dim entry As New Logg()
         me._logs.Push(entry)
         NewLog = entry
      End Function

      Function Add(pLog As Logg) As Logg
         me.RequireOpen()
         If Not Assigned(pLog) Then
            Throw New Exception("Log is required")
         End If
         me._logs.Push(pLog)
         Add = pLog
      End Function

      Function Count() As Integer
         If me._wheres.Count > 0 Then
            Count = me._wheres.Count
         Else
            Count = me._logs.Length
         End If
      End Function

      Sub SetTemplate(pLog As Logg)
         me.RequireOpen()
         If Assigned(me._template) Then
            me._template.Free()
         End If
         me._template = pLog
      End Sub

      Sub AddWhere(pWhere As String)
         me.RequireOpen()
         me._wheres.Add(pWhere)
         me._curSeq = 0
      End Sub

      Sub AddCompactItem(pNome As String, pOld As String, pNew As String)
         If me._wheres.Count <= 0 Then
            Throw New Exception("Log where is required")
         End If
         me._curSeq = me._curSeq + 1
         me._itemLog.Add(CStr(me._wheres.Count - 1))
         me._itemSeq.Add(CStr(me._curSeq))
         me._itemNome.Add(pNome)
         me._itemOld.Add(pOld)
         me._itemNew.Add(pNew)
      End Sub

      Shared Sub SaveOne(pEntry As Logg)
         If Not Assigned(pEntry) Then
            Throw New Exception("Log is required")
         End If
         Dim batch As New LogBatch(False)
         batch.Add(pEntry)
         batch.Save()
         batch.Free()
      End Sub

      Sub Save()
         me.SaveInternal(True)
      End Sub

      Sub SaveFast()
         me.SaveInternal(False)
      End Sub

      Private Sub SaveInternal(pValidate As Boolean)
         If me._saved Then
            Throw New Exception("Log batch already saved")
         End If
         If me._wheres.Count > 0 Then
            me.SaveCompact()
            Exit Sub
         End If
         If me._logs.Length = 0 Then
            Exit Sub
         End If
         Dim i As Integer
         Dim total As Integer = me._logs.Length
         If pValidate Then
            Dim ctx As LogContext = me.ResolveContext()
            Dim _now As TDateTime = DateTime()
            For i = 0 To total - 1
               Dim entry As Logg = me._logs.Take(i)
               me.Apply(entry, ctx, _now)
               me.Validate(entry)
            Next
            me.NumberItems()
         End If
         Try
            me.ReserveCodes()
            me.WriteRows()
            If Assigned(me._lease) Then
               me._lease.Commit()
            End If
            For i = 0 To total - 1
               me._logs.Take(i).MarkSaved()
            Next
            me._saved = True
         Catch ex As Exception
            If Assigned(me._lease) Then
               me._lease.Rollback()
            End If
            For i = 0 To total - 1
               me._logs.Take(i).RevertCode()
            Next
            me.ReleaseSequence()
            Throw New Exception("Error saving LogSistema: " & me.ExceptionText(ex))
         End Try
         me.ReleaseSequence()
      End Sub

      Private Sub SaveCompact()
         If Not Assigned(me._template) Then
            Throw New Exception("Log template is required")
         End If
         Try
            me.ReserveCompactCodes()
            me.WriteCompactRows()
            If Assigned(me._lease) Then
               me._lease.Commit()
            End If
            me._saved = True
         Catch ex As Exception
            If Assigned(me._lease) Then
               me._lease.Rollback()
            End If
            me.ReleaseSequence()
            Throw New Exception("Error saving LogSistema: " & me.ExceptionText(ex))
         End Try
         me.ReleaseSequence()
      End Sub

      Private Sub ReserveCompactCodes()
         Dim pending As Integer = me._wheres.Count
         If pending <= 0 Then
            Exit Sub
         End If
         me._codes.Clear()
         Dim first As Integer = me.NextLogBlock(pending)
         Dim i As Integer
         For i = 0 To pending - 1
            me._codes.Add(CStr(first + i))
         Next
      End Sub

      Private Function NextLogBlock(pPending As Integer) As Integer
         If pPending <= 0 Then
            NextLogBlock = 0
            Exit Function
         End If
         me._sequence = me.OpenSequence()
         Dim dialect As TSqlDialect = TSql.Dialect()
         Dim sqlMax As String = "SELECT COALESCE(MAX(CodLogSistema), 0) AS v FROM " & dialect.QuoteTable("", "LogSistema")
         Dim mx As Integer = TSql.ExecScalarV(sqlMax, "v", 0)
         Dim first As Integer = me._sequence.NextValue()
         If first <= 0 Then
            Throw New Exception("Não foi possível obter o próximo código de LogSistema.")
         End If
         If first <= mx Then
            first = mx + 1
            me.RestartSequenceRaw(first + pPending)
         Else
            Dim extra As Integer
            For extra = 1 To pPending - 1
               Dim nxt As Integer = me._sequence.NextValue()
               If nxt <= 0 Then
                  Throw New Exception("Não foi possível obter o próximo código de LogSistema.")
               End If
            Next
         End If
         NextLogBlock = first
      End Function

      Private Sub RestartSequenceRaw(pNext As Integer)
         Dim sqlText As String = TSql.Dialect().SqlRestartSequence(me._sequence.Name, pNext)
         If Trim(sqlText) = "" Then
            Exit Sub
         End If
         Dim query As SQL.Command = New SQL.Command()
         query.CommandText = sqlText
         Try
            query.ExecSQL()
            If query.Active Then
               query.Close()
            End If
         Catch ex As Exception
            If query.Active Then
               query.Close()
            End If
            query.Free()
            TSql.ClearPool()
            Throw New Exception(me.ExceptionText(ex))
         End Try
         query.Free()
         TSql.ClearPool()
      End Sub

      Private Sub WriteCompactRows()
         Dim ownTx As Boolean = False
         If Not SQL.Connection.InTransaction() Then
            SQL.Connection.StartTransaction()
            ownTx = True
         End If
         Try
            Dim i As Integer
            Dim total As Integer = me._wheres.Count
            For i = 0 To total - 1
               Dim header As New TLogSistemaSave()
               me.FillHeader(header, me._template)
               header.CodLogSistema = CInt(me._codes.Strings(i))
               me.AssignText(header, "ClausulaWhere", me._wheres.Strings(i))
               header.Insert()
               header.Free()
            Next
            Dim itemTotal As Integer = me._itemNome.Count
            For i = 0 To itemTotal - 1
               Dim logIdx As Integer = CInt(me._itemLog.Strings(i))
               Dim detail As New TLogSistemaDetalhe()
               detail.CodLogSistema = CInt(me._codes.Strings(logIdx))
               detail.Sequencia = CInt(me._itemSeq.Strings(i))
               me.AssignText(detail, "Nome", me._itemNome.Strings(i))
               me.AssignText(detail, "ValorAntigo", me._itemOld.Strings(i))
               me.AssignText(detail, "Valor", me._itemNew.Strings(i))
               detail.Insert()
               detail.Free()
            Next
            If ownTx And SQL.Connection.InTransaction() Then
               SQL.Connection.Commit()
            End If
         Catch ex As Exception
            If ownTx And SQL.Connection.InTransaction() Then
               SQL.Connection.RollBack()
            End If
            Throw New Exception(me.ExceptionText(ex))
         End Try
      End Sub

      Private Sub RequireOpen()
         If me._saved Then
            Throw New Exception("Log batch already saved")
         End If
      End Sub

      Private Function ResolveContext() As LogContext
         If Assigned(me.Context) Then
            ResolveContext = me.Context
         Else
            Dim _current As LogContext = LogContext.Current()
            _current.Capture()
            ResolveContext = _current
         End If
      End Function

      Private Sub Apply(pLog As Logg, pCtx As LogContext, pNow As TDateTime)
         If pLog.CodEmpresa <= 0 Then
            pLog.CodEmpresa = pCtx.CodEmpresa
         End If
         If pLog.CodFilial <= 0 Then
            pLog.CodFilial = pCtx.CodFilial
         End If
         If pLog.CodUsuario <= 0 Then
            pLog.CodUsuario = pCtx.CodUsuario
         End If
         If Trim(pLog.NomeUsuario) = "" Then
            pLog.NomeUsuario = pCtx.NomeUsuario
         End If
         If Trim(pLog.NomeComputador) = "" Then
            pLog.NomeComputador = pCtx.NomeComputador
         End If
         If Trim(pLog.UsuarioWindows) = "" Then
            pLog.UsuarioWindows = pCtx.UsuarioWindows
         End If
         If Trim(pLog.NomeSistema) = "" Then
            pLog.NomeSistema = pCtx.NomeSistema
         End If
         If Trim(pLog.NomeSchema) = "" Then
            pLog.NomeSchema = pCtx.NomeSchema
         End If
         If Trim(pLog.VersaoSistema) = "" Then
            pLog.VersaoSistema = pCtx.Version()
         End If
         If pLog.CodPeriodoCaixa <= 0 Then
            pLog.CodPeriodoCaixa = pCtx.Period()
         End If
         If Not pLog.HasDate() Then
            pLog.Data = Date()
         End If
         If Trim(pLog.Hora) = "" Then
            pLog.Hora = pNow.ToString("hh:nn:ss")
         End If
         pLog.NomeComputador = me.Clip(pLog.NomeComputador, 100)
         pLog.NomeUsuario = me.Clip(pLog.NomeUsuario, 100)
         pLog.UsuarioWindows = me.Clip(pLog.UsuarioWindows, 30)
         pLog.NomeSistema = me.Clip(pLog.NomeSistema, 100)
         pLog.NomeSchema = me.Clip(pLog.NomeSchema, 50)
         pLog.VersaoSistema = me.Clip(pLog.VersaoSistema, 100)
         pLog.Hora = me.Clip(pLog.Hora, 12)
      End Sub

      Private Sub Validate(pLog As Logg)
         If pLog.IsSaved() Then
            Throw New Exception("Log already saved: " & pLog.Nome)
         End If
         If Trim(pLog.Nome) = "" Then
            Throw New Exception("Log without Nome")
         End If
         If Trim(pLog.TipoLog) = "" Then
            Throw New Exception("Log " & pLog.Nome & " without TipoLog")
         End If
         If pLog.CodEmpresa <= 0 Then
            Throw New Exception("Log " & pLog.Nome & " without CodEmpresa")
         End If
         If pLog.CodFilial <= 0 Then
            Throw New Exception("Log " & pLog.Nome & " without CodFilial")
         End If
         If pLog.CodUsuario <= 0 Then
            Throw New Exception("Log " & pLog.Nome & " without CodUsuario")
         End If
         me.RequireLength("Nome", pLog.Nome, 200)
         me.RequireLength("TipoLog", pLog.TipoLog, 5)
         me.RequireLength("NomeRotina", pLog.NomeRotina, 100)
         me.RequireLength("Observacao", pLog.Observacao, 2000)
         me.RequireLength("ClausulaWhere", pLog.ClausulaWhere, 2000)
         Dim i As Integer
         Dim total As Integer = pLog.Items.Length
         For i = 0 To total - 1
            Dim item As LogItem = pLog.Items.Take(i)
            If Trim(item.Nome) = "" Then
               Throw New Exception("Item of log " & pLog.Nome & " without Nome")
            End If
            me.RequireLength("Item.Nome", item.Nome, 200)
            me.RequireLength("Item.ValorAntigo", item.ValorAntigo, 2000)
            me.RequireLength("Item.Valor", item.Valor, 2000)
            me.RequireLength("Item.Observacao", item.Observacao, 2000)
         Next
      End Sub

      Private Sub ReserveCodes()
         Dim pending As Integer = 0
         Dim i As Integer
         Dim total As Integer = me._logs.Length
         For i = 0 To total - 1
            If me._logs.Take(i).CodLogSistema <= 0 Then
               pending = pending + 1
            End If
         Next
         If pending = 0 Then
            Exit Sub
         End If
         Dim first As Integer = me.NextLogBlock(pending)
         Dim n As Integer = 0
         Dim entry As Logg = NULL
         For i = 0 To total - 1
            entry = me._logs.Take(i)
            If entry.CodLogSistema <= 0 Then
               entry.AssignCode(first + n, True)
               n = n + 1
            End If
         Next
      End Sub

      Private Function OpenSequence() As TSequence
         If _sequenceName = "" Then
            Dim probe As New TLogSistema()
            Dim loaded As TSequence = TSequence.Load(probe.Schema, 0)
            _sequenceName = loaded.Name
            loaded.Free()
            probe.Free()
         End If
         OpenSequence = New TSequence(_sequenceName)
      End Function

      Private Sub NumberItems()
         Dim i As Integer
         Dim total As Integer = me._logs.Length
         For i = 0 To total - 1
            Dim entry As Logg = me._logs.Take(i)
            Dim j As Integer
            Dim itemCount As Integer = entry.Items.Length
            For j = 0 To itemCount - 1
               entry.Items.Take(j).Sequencia = j + 1
            Next
         Next
      End Sub

      Private Sub WriteRows()
         Dim ownTx As Boolean = False
         If Not SQL.Connection.InTransaction() Then
            SQL.Connection.StartTransaction()
            ownTx = True
         End If
         Try
            Dim i As Integer
            Dim total As Integer = me._logs.Length
            For i = 0 To total - 1
               Dim entry As Logg = me._logs.Take(i)
               Dim header As New TLogSistemaSave()
               me.FillHeader(header, entry)
               header.Insert()
               header.Free()
               Dim j As Integer
               Dim itemCount As Integer = entry.Items.Length
               For j = 0 To itemCount - 1
                  Dim detail As New TLogSistemaDetalhe()
                  me.FillDetail(detail, entry.CodLogSistema, entry.Items.Take(j))
                  detail.Insert()
                  detail.Free()
               Next
            Next
            If ownTx And SQL.Connection.InTransaction() Then
               SQL.Connection.Commit()
            End If
         Catch ex As Exception
            If ownTx And SQL.Connection.InTransaction() Then
               SQL.Connection.RollBack()
            End If
            Throw New Exception(me.ExceptionText(ex))
         End Try
      End Sub

      Private Sub FillHeader(pRow As TLogSistemaSave, pLog As Logg)
         pRow.CodLogSistema = pLog.CodLogSistema
         pRow.CodUsuario = pLog.CodUsuario
         If pLog.HasDate() Then
            pRow.Data = pLog.Data
         Else
            pRow.Data = Date()
         End If
         pRow.CodEmpresa = pLog.CodEmpresa
         pRow.CodFilial = pLog.CodFilial
         me.AssignText(pRow, "Nome", pLog.Nome)
         me.AssignText(pRow, "Hora", pLog.Hora)
         me.AssignText(pRow, "TipoLog", pLog.TipoLog)
         me.AssignText(pRow, "NomeComputador", pLog.NomeComputador)
         me.AssignText(pRow, "NomeUsuario", pLog.NomeUsuario)
         me.AssignText(pRow, "NomeSistema", pLog.NomeSistema)
         me.AssignText(pRow, "NomeRotina", pLog.NomeRotina)
         me.AssignText(pRow, "VersaoSistema", pLog.VersaoSistema)
         me.AssignText(pRow, "Observacao", pLog.Observacao)
         me.AssignText(pRow, "ClausulaWhere", pLog.ClausulaWhere)
         me.AssignText(pRow, "UsuarioWindows", pLog.UsuarioWindows)
         me.AssignText(pRow, "NomeSchema", pLog.NomeSchema)
         If pLog.CodPeriodoCaixa > 0 Then
            pRow.CodPeriodoCaixa = pLog.CodPeriodoCaixa
         End If
         If pLog.CodTabela > 0 Then
            pRow.CodTabela = pLog.CodTabela
         End If
      End Sub

      Private Sub FillDetail(pRow As TLogSistemaDetalhe, pCodLog As Integer, pItem As LogItem)
         pRow.CodLogSistema = pCodLog
         pRow.Sequencia = pItem.Sequencia
         me.AssignText(pRow, "Nome", pItem.Nome)
         me.AssignText(pRow, "ValorAntigo", pItem.ValorAntigo)
         me.AssignText(pRow, "Valor", pItem.Valor)
         me.AssignText(pRow, "Observacao", pItem.Observacao)
      End Sub

      Private Sub AssignText(pRow As TTable, pName As String, pValue As String)
         ' data7:disable-next-line unknown-member
         If (Trim(pValue) = "") And pRow.Field(pName).Def.NullIfEmpty Then
            Exit Sub
         End If
         pRow.SetString(pName, pValue)
      End Sub

      Private Function ExceptionText(pEx As Exception) As String
         Dim text As String = ""
         If Assigned(pEx) Then
            text = Trim(pEx._GetMessage())
         End If
         If text = "" Then
            text = "Falha ao gravar LogSistema."
         End If
         ExceptionText = text
      End Function

      Private Function Clip(pValue As String, pMax As Integer) As String
         If pValue.Length <= pMax Then
            Clip = pValue
         Else
            Clip = pValue.Left(pMax)
         End If
      End Function

      Private Sub RequireLength(pField As String, pValue As String, pMax As Integer)
         If pValue.Length > pMax Then
            Throw New Exception(pField & " exceeds " & CStr(pMax) & " characters")
         End If
      End Sub

      Private Sub ReleaseSequence()
         If Assigned(me._lease) Then
            me._lease.Free()
            me._lease = NULL
         End If
         If Assigned(me._sequence) Then
            me._sequence.Free()
            me._sequence = NULL
         End If
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New LogBatch(False)
      End Function

      Overrides Sub Dispose()
         me.ReleaseSequence()
         If Assigned(me._logs) Then
            me._logs.Free()
            me._logs = NULL
         End If
         If Assigned(me._template) Then
            me._template.Free()
            me._template = NULL
         End If
         If Assigned(me._wheres) Then
            me._wheres.Free()
            me._wheres = NULL
         End If
         If Assigned(me._codes) Then
            me._codes.Free()
            me._codes = NULL
         End If
         If Assigned(me._itemLog) Then
            me._itemLog.Free()
            me._itemLog = NULL
         End If
         If Assigned(me._itemSeq) Then
            me._itemSeq.Free()
            me._itemSeq = NULL
         End If
         If Assigned(me._itemNome) Then
            me._itemNome.Free()
            me._itemNome = NULL
         End If
         If Assigned(me._itemOld) Then
            me._itemOld.Free()
            me._itemOld = NULL
         End If
         If Assigned(me._itemNew) Then
            me._itemNew.Free()
            me._itemNew = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
