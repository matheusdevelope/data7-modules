Imports configurador_tabela
Imports mod_cache
Imports mod_register_config
Imports mod_register_events
Imports mod_register_form
Imports mod_register_log
Imports mod_register_record
Imports mod_register_store
Imports mod_register_tabela
Imports Collections

Namespace mod_register_session

   Class TRegisterSession
      Events As TRegisterEvents
      Context As TRegisterContext

      Private _mode As TRegisterMode
      Private _form As TRegisterForm
      Private _accepted As Boolean
      Private _formCached As Boolean
      Private _cacheKey As String
      Private _loaded As StringList

      Sub New(pMode As TRegisterMode)
         MyBase.New()
         me.Events = New TRegisterEvents()
         me.Context = New TRegisterContext()
         me.Context.Mode = pMode
         me.Context.RecordWhere = Trim(Ambient.InternalWhere())
         me._mode = pMode
         me._accepted = False
      End Sub

      Sub Show()
         Dim keepGoing As Boolean = True
         While keepGoing
            keepGoing = False
            me._accepted = False
            Dim opened As Boolean = False
            Try
               opened = me._prepare()
               If opened Then
                  me._form.Show()
                  me._accepted = me._form.Confirmed
               End If
            Catch ex As Exception
               Throw New Exception(ex.Message)
            End Try
            If me._accepted Then
               me.Context.ReservedCode = 0
               me._publishContent()
               me._showIncludeReport()
               If me._repeatInclude() Then
                  me._disposeUi()
                  keepGoing = True
               End If
            Else
               TRegisterStore.Release(me.Context.ReservedCode)
               me.Context.ReservedCode = 0
               me._hook(me.Events.OnCancel)
            End If
         End While
      End Sub

      Private Function _prepare() As Boolean
         If Not Assigned(Ambient.Tabela()) Then
            Throw New Exception("Ambiente não inicializado.")
         End If
         me._openForm()
         
         me.Context.Form = me._form
         me.Context.Record = TRegisterStore.OpenRecord()
         me._form.OnCommit = me._onCommit
         Dim modeKey As String = UCase(me._mode.AsString)
         If modeKey = "INCLUIR" Then
            Dim _rreserve As Boolean = me._reserve()
            _prepare = _rreserve
            If _rreserve Then
               me._form.ApplyMode()
            End If
            Exit Function
         End If
         If Not me._load() Then
            _prepare = False
            Exit Function
         End If
         If modeKey = "COPIAR" Then
            me._form.ApplyCopyDefaults()
            me._clearAuto()
            me._form.ApplyDefaults()
            me._form.ApplyMode()
            _prepare = me._reserve()
            Exit Function
         End If
         me._form.ApplyMode()
         _prepare = True
      End Function

      Private Sub _openForm()
         Dim defTable As Tabela = Ambient.Tabela()
         me._formCached = defTable.UsarCacheDeObjeto
         me._cacheKey = CStr(defTable.CodTabela) & ";" & UCase(Trim(defTable.Nome)) & ";" & UCase(Trim(defTable.NomeSchema))
         me._form = Null
         If me._formCached Then
            me._form = Cache.Find<TRegisterForm>("Register.Form", me._cacheKey)
         End If
         If Assigned(me._form) Then
            me._form.ResetFor(me._mode)
            If UCase(me._mode.AsString) = "INCLUIR" Then
               me._form.ApplyDefaults()
               me._restoreContent()
            End If
            Exit Sub
         End If
         Dim cfg As TRegisterFormConfig = TRegisterTabela.FromTabela(defTable)
         me._form = New TRegisterForm(cfg, me._mode)
         If me._formCached Then
            Cache.Put("Register.Form", me._cacheKey, me._form)
         End If
         If UCase(me._mode.AsString) = "INCLUIR" Then
            me._restoreContent()
         End If
      End Sub

      Private Sub _publishContent()
         If UCase(me._mode.AsString) <> "INCLUIR" Then
            Exit Sub
         End If
         If Not Assigned(me._form) Then
            Exit Sub
         End If
         Cache.Put("Register.Content", me._cacheKey, me._form.ExportKept())
      End Sub

      Private Sub _restoreContent()
         ' data7:disable-next-line generic-constraint-violated
         Dim snap As StringList = Cache.Find<StringList>("Register.Content", me._cacheKey)
         If Not Assigned(snap) Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = snap.Count - 1
         For i = 0 To n
            Dim packed As String = snap.Strings(i)
            Dim cut As Integer = packed.Pos(Chr(1))
            If cut > 0 Then
               me._form.SetValue(packed.Left(cut - 1), packed.Right(packed.Length - cut))
            End If
         Next
      End Sub

      Private Function _load() As Boolean
         If Trim(me.Context.RecordWhere) = "" Then
            Throw New Exception("Registro não informado.")
         End If
         If Not me._allow(me.Events.OnBeforeLoad) Then
            _load = False
            Exit Function
         End If
         If Not TRegisterStore.Locate(me.Context.Record) Then
            Throw New Exception("Registro não encontrado.")
         End If
         TRegisterStore.Push(me._form, me.Context.Record)
         me._captureLoaded()
         me._hook(me.Events.OnAfterLoad)
         _load = True
      End Function

      Private Function _reserve() As Boolean
         If Not me._allow(me.Events.OnBeforeReserve) Then
            _reserve = False
            Exit Function
         End If
         Dim code As Integer = TRegisterStore.Reserve(me.Context.Record)
         me.Context.ReservedCode = code
         Dim fieldName As String = me.Context.Record.AutoFieldName()
         If (code > 0) And (fieldName <> "") Then
            me._form.SetValue(fieldName, CStr(code))
         End If
         me._hook(me.Events.OnAfterReserve)
         _reserve = True
      End Function

      Private Sub _clearAuto()
         Dim fieldName As String = me.Context.Record.AutoFieldName()
         If fieldName <> "" Then
            me._form.SetValue(fieldName, "")
         End If
      End Sub

      Private Sub _onCommit(pSender As TObject)
         If me._commit() Then
            me._form.AcceptCommit()
         End If
      End Sub

      Private Function _commit() As Boolean
         Dim modeKey As String = UCase(me._mode.AsString)
         If Not me._allow(me.Events.OnBeforeConfirm) Then
            _commit = False
            Exit Function
         End If
         If Not me._confirm(modeKey) Then
            _commit = False
            Exit Function
         End If
         If modeKey = "EXCLUIR" Then
            _commit = me._delete()
            Exit Function
         End If
         _commit = me._save(modeKey)
      End Function

      Private Function _confirm(pMode As String) As Boolean
         Dim defTable As Tabela = Ambient.Tabela()
         If pMode = "EXCLUIR" Then
            Dim msg As String = me._form.Config.ConfirmDeleteMessage
            If Trim(msg) = "" Then
               msg = "Confirma a exclusão do registro?"
            End If
            _confirm = Forms.MessageBox.Confirmation(msg)
            Exit Function
         End If
         If pMode = "COPIAR" Then
            _confirm = Forms.MessageBox.Confirmation("Confirma a cópia do registro?")
            Exit Function
         End If
         If (pMode = "INCLUIR") And defTable.ConfirmaInclusao Then
            _confirm = Forms.MessageBox.Confirmation("Confirma a inclusão do registro?")
            Exit Function
         End If
         If (pMode = "ALTERAR") And defTable.ConfirmaAlteracao Then
            _confirm = Forms.MessageBox.Confirmation("Confirma a alteração do registro?")
            Exit Function
         End If
         _confirm = True
      End Function

      Private Function _save(pMode As String) As Boolean
         If Not me._allow(me.Events.OnBeforeSave) Then
            _save = False
            Exit Function
         End If
         TRegisterStore.Pull(me._form, me.Context.Record)
         If (pMode = "INCLUIR") Or (pMode = "COPIAR") Then
            If me.Context.ReservedCode > 0 Then
               me.Context.Record.AssignAutoCode(me.Context.ReservedCode)
               me.Context.Record.Mark(me.Context.Record.AutoFieldName())
            End If
            TRegisterStore.InsertRow(me.Context.Record)
         Else
            TRegisterStore.UpdateRow(me.Context.Record)
         End If
         TRegisterLog.Save(pMode, me._form, me._loaded)
         me._hook(me.Events.OnAfterSave)
         _save = True
      End Function

      Private Function _delete() As Boolean
         If Not me._allow(me.Events.OnBeforeDelete) Then
            _delete = False
            Exit Function
         End If
         TRegisterStore.DeleteRow(me.Context.Record)
         TRegisterLog.Save("EXCLUIR", me._form, me._loaded)
         me._hook(me.Events.OnAfterDelete)
         _delete = True
      End Function

      Private Function _allow(pGate As TRegisterGate) As Boolean
         me.Context.Allow = True
         If pGate <> Null Then
            pGate(me.Context)
         End If
         If (Not me.Context.Allow) And (Trim(me.Context.CancelMessage) <> "") Then
            Forms.MessageBox.Show(me.Context.CancelMessage)
         End If
         _allow = me.Context.Allow
      End Function

      Private Sub _showIncludeReport()
         If UCase(me._mode.AsString) <> "INCLUIR" Then
            Exit Sub
         End If
         Dim defTable As Tabela = Ambient.Tabela()
         If defTable.CodRelatorioInclusao <= 0 Then
            Exit Sub
         End If
         Dim report As New Data7.Report(NULL)
         Dim i As Integer
         Dim last As Integer = me._form.Config.Fields.Length - 1
         For i = 0 To last
            Dim fieldName As String = me._form.Config.Fields.Take(i).Name
            report.AddParam(fieldName, me._form.Value(fieldName))
         Next
         report.Show()
         report.Free()
      End Sub

      Private Function _repeatInclude() As Boolean
         If UCase(me._mode.AsString) <> "INCLUIR" Then
            _repeatInclude = False
            Exit Function
         End If
         _repeatInclude = Ambient.Tabela().InclusaoRecursiva
      End Function

      Private Sub _releaseForm()
         If Not Assigned(me._form) Then
            Exit Sub
         End If
         If me._formCached And Cache.ContainsObject("Register.Form", me._form) Then
            me._form = Null
            me.Context.Form = Null
            Exit Sub
         End If
         me._form.Free()
         me._form = Null
         me.Context.Form = Null
      End Sub

      Private Sub _disposeUi()
         me._releaseForm()
         If Assigned(me.Context.Record) Then
            me.Context.Record.Free()
            me.Context.Record = Null
         End If
      End Sub

      Private Sub _captureLoaded()
         If Assigned(me._loaded) Then
            me._loaded.Clear()
         Else
            me._loaded = New StringList()
            me._loaded.OwnsObjects = False
         End If
         Dim i As Integer
         Dim last As Integer = me._form.Config.Fields.Length - 1
         For i = 0 To last
            Dim fieldName As String = me._form.Config.Fields.Take(i).Name
            me._loaded.Add(UCase(Trim(fieldName)) & Chr(1) & me._form.Value(fieldName))
         Next
      End Sub

      Private Sub _hook(pHook As TRegisterHook)
         If pHook <> Null Then
            pHook(me.Context)
         End If
      End Sub

      Sub Free()
         If Not me._accepted Then
            TRegisterStore.Release(me.Context.ReservedCode)
            me.Context.ReservedCode = 0
         End If
         me._releaseForm()
         If Assigned(me.Context.Record) Then
            me.Context.Record.Free()
            me.Context.Record = Null
         End If
         If Assigned(me._loaded) Then
            me._loaded.Free()
            me._loaded = Null
         End If
         me.Events.Free()
         me.Context.Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
