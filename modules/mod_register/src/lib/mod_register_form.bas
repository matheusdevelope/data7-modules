Imports Forms
Imports Collections
Imports mod_tlist
Imports mod_editors
Imports mod_editors_cep
Imports mod_editors_cnpj
Imports mod_editors_cpf_cnpj
Imports mod_editors_search
Imports mod_forms
Imports TablesSql
Imports mod_register_eval
Imports mod_register_config
Imports mod_register_factory
Imports mod_register_layout
Imports mod_register_validation

Namespace mod_register_form

   Class TRegisterKept
      FieldName As String
      FieldText As String

      Sub New(pName As String, pText As String)
         MyBase.New()
         me.FieldName = pName
         me.FieldText = pText
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TRegisterForm
      Inherits TFormsWorkspace

      Private _config As TRegisterFormConfig
      Private _mode As TRegisterMode
      Private _layout As TRegisterLayout
      Private _editors As StringList
      Private _ownsConfig As Boolean
      Private _built As Boolean
      Private _confirmed As Boolean
      Private _commitAccepted As Boolean
      Private _headerHost As PageControl
      Private _tabsHost As PageControl
      Private _folderSheets As StringList
      Private _kept As TTList<TRegisterKept>

      OnCommit As TNotifyEvent
      OnBuildFolder As TNotifyEvent

      Sub New(pConfig As TRegisterFormConfig)
         MyBase.New("", TFormsKind.Dialog())
         me._boot(pConfig, TRegisterMode.Incluir())
      End Sub

      Sub New(pConfig As TRegisterFormConfig, pMode As TRegisterMode)
         MyBase.New("", TFormsKind.Dialog())
         me._boot(pConfig, pMode)
      End Sub

      Private Sub _boot(pConfig As TRegisterFormConfig, pMode As TRegisterMode)
         me.CloseOnOk = False
         me.Footer.Visible = False
         me._ownsConfig = True
         me._editors = New StringList()
         me._editors.OwnsObjects = False
         me._folderSheets = New StringList()
         me._folderSheets.OwnsObjects = False
         If Assigned(pConfig) Then
            me._config = pConfig
         Else
            me._config = New TRegisterFormConfig()
         End If
         If Assigned(pMode) Then
            me._mode = pMode
         Else
            me._mode = TRegisterMode.Incluir()
         End If
         me._layout = New TRegisterLayout(me._config)
         me.Width.Value = me._layout.LayoutWidth
         ' me.Width.CanGrow = False
         me._applyCaption()
         me.Mount()
      End Sub

      Property Config As TRegisterFormConfig
         Get
            Config = me._config
         End Get
      End Property

      Property Mode As TRegisterMode
         Get
            Mode = me._mode
         End Get
         Set(pValue As TRegisterMode)
            me._setMode(pValue)
         End Set
      End Property

      Private Sub _setMode(pValue As TRegisterMode)
         If Assigned(pValue) Then
            me._mode = pValue
         End If
         me._applyCaption()
         me.ApplyMode()
      End Sub

      Property OwnsConfig As Boolean
         Get
            OwnsConfig = me._ownsConfig
         End Get
         Set(pValue As Boolean)
            me._ownsConfig = pValue
         End Set
      End Property

      Property Confirmed As Boolean
         Get
            Confirmed = me._confirmed
         End Get
      End Property

      Sub AcceptCommit()
         me._commitAccepted = True
      End Sub

      Property Layout As TRegisterLayout
         Get
            Layout = me._layout
         End Get
      End Property

      Function Editor(pName As String) As TLabeledEditorBase
         Dim idx As Integer = me._editors.IndexOf(UCase(Trim(pName)))
         If idx >= 0 Then
            Editor = CType(me._editors.Objects(idx), TLabeledEditorBase)
         Else
            Editor = Null
         End If
      End Function

      Function Value(pName As String) As String
         Dim item As TLabeledEditorBase = me.Editor(pName)
         If Assigned(item) Then
            Value = item.Text
         Else
            Value = ""
         End If
      End Function

      Sub SetValue(pName As String, pValue As String)
         Dim item As TLabeledEditorBase = me.Editor(pName)
         If Assigned(item) Then
            item.Text = pValue
         End If
      End Sub

      Function Values() As StringList
         Dim map As New StringList()
         Dim i As Integer
         Dim n As Integer = me._editors.Count - 1
         For i = 0 To n
            Dim editor As TLabeledEditorBase = CType(me._editors.Objects(i), TLabeledEditorBase)
            If Assigned(editor) Then
               Dim key As String = me._editors.Strings(i)
               map.Add(key & "=" & editor.Text)
            End If
         Next
         Values = map
      End Function

      Sub LoadValues(pValues As StringList)
         If Not Assigned(pValues) Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = pValues.Count - 1
         For i = 0 To n
            Dim key As String = pValues.Names(i)
            If Trim(key) = "" Then
               key = pValues.Strings(i)
            End If
            me.SetValue(key, pValues.Values(key))
         Next
         me._syncCnpjCpfByPersonType()
      End Sub

      Sub Mount()
         If me._built Then
            Exit Sub
         End If
         me._built = True
         me._buildHeader()
         me._buildTabs()
         me._fitHeight()
         me.ApplyMode()
         me.ApplyDefaults()
         me._syncCnpjCpfByPersonType()
         me.AfterBuild()
      End Sub

      Protected Overridable Sub AfterBuild()
      End Sub

      Protected Overrides Sub AfterShow()
         MyBase.AfterShow()
         me._selectFirstFolder()
         me._focusFirstActive()
      End Sub

      Protected Overridable Function CreateEditor(pParent As TWinControl, pField As TRegisterField) As TLabeledEditorBase
         Dim editor As TLabeledEditorBase = TRegisterFactory.CreateEditor(pParent, pField)
         If UCase(Trim(editor.Text)) = UCase(Trim(pField.Name)) Then
            editor.Clear()
         End If
         editor.FieldName = pField.Name
         editor.Required = TRegisterEval.IsRequired(pField)
         me._registerEditor(pField, editor)
         me._bindActionEditor(pField, editor)
         CreateEditor = editor
      End Function

      Private Function _boundCreate(pParent As TWinControl, pField As TRegisterField) As TLabeledEditorBase
         _boundCreate = me.CreateEditor(pParent, pField)
      End Function

      Protected Overridable Sub BuildSubCadastro(pParent As TWinControl, pFolder As TRegisterFolder)
      End Sub

      Protected Overridable Function ValidateField(pField As TRegisterField, pEditor As TLabeledEditorBase) As String
         ValidateField = ""
      End Function

      Function Validate() As Boolean
         Dim fields As TTList<TRegisterField> = me._config.FocusFields()
         Dim i As Integer
         Dim n As Integer = fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = fields.Take(i)
            Dim editor As TLabeledEditorBase = me.Editor(field.Name)
            If Assigned(editor) Then
               If TRegisterEval.IsRequired(field) Then
                  If Trim(editor.Text) = "" Then
                     Forms.MessageBox.Show(me._requiredMessage(field))
                     me._focusEditor(field, editor)
                     fields.OwnsObjects = False
                     fields.Free()
                     Validate = False
                     Exit Function
                  End If
               End If
               Dim docErr As String = me._personDocError(field, editor)
               If Trim(docErr) <> "" Then
                  Forms.MessageBox.Show(docErr)
                  me._focusEditor(field, editor)
                  fields.OwnsObjects = False
                  fields.Free()
                  Validate = False
                  Exit Function
               End If
               Dim err As String = me.ValidateField(field, editor)
               If Trim(err) <> "" Then
                  Forms.MessageBox.Show(err)
                  me._focusEditor(field, editor)
                  fields.OwnsObjects = False
                  fields.Free()
                  Validate = False
                  Exit Function
               End If
            End If
         Next
         fields.OwnsObjects = False
         fields.Free()
         Validate = me._runProcValidations()
      End Function

      Private Function _runProcValidations() As Boolean
         Dim editorValues As StringList = me.Values()
         Dim i As Integer
         Dim n As Integer = me._config.Fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = me._config.Fields.Take(i)
            If Not me._runProcValidation(field, field.ValidacaoSistema, editorValues) Then
               editorValues.Free()
               _runProcValidations = False
               Exit Function
            End If
            If Not me._runProcValidation(field, field.ValidacaoUsuario, editorValues) Then
               editorValues.Free()
               _runProcValidations = False
               Exit Function
            End If
         Next
         editorValues.Free()
         _runProcValidations = True
      End Function

      Private Function _runProcValidation(pField As TRegisterField, pSpec As String, pValues As StringList) As Boolean
         If Trim(pSpec) = "" Then
            _runProcValidation = True
            Exit Function
         End If
         Dim result As TRegisterProcResult = TRegisterValidation.Execute(pSpec, me._config, pValues)
         Dim acao As String = UCase(Trim(result.Acao))
         Dim msg As String = Trim(result.Mensagem)
         result.Free()
         If acao = "A" Then
            If msg <> "" Then
               Forms.MessageBox.Show(msg)
            End If
            _runProcValidation = True
         ElseIf acao = "P" Then
            If msg = "" Then
               _runProcValidation = True
            ElseIf Forms.MessageBox.Confirmation(msg) Then
               _runProcValidation = True
            Else
               me._focusEditor(pField, me.Editor(pField.Name))
               _runProcValidation = False
            End If
         ElseIf acao = "B" Then
            If msg <> "" Then
               Forms.MessageBox.Show(msg)
            End If
            me._focusEditor(pField, me.Editor(pField.Name))
            _runProcValidation = False
         Else
            _runProcValidation = True
         End If
      End Function

      Sub ApplyMode()
         Dim modeKey As String = me._modeKey()
         Dim readOnlyAll As Boolean = CBool((modeKey = "VISUALIZAR") Or (modeKey = "EXCLUIR"))
         Dim i As Integer
         Dim n As Integer = me._config.Fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = me._config.Fields.Take(i)
            Dim editor As TLabeledEditorBase = me.Editor(field.Name)
            If Assigned(editor) Then
               editor.OnlyRead = TRegisterEval.IsReadOnly(field, modeKey, readOnlyAll)
               editor.Required = TRegisterEval.IsRequired(field)
               If modeKey = "COPIAR" Then
                  If field.IsKey Or field.AutoIncrement Then
                     Dim copyDefault As String = TRegisterEval.ResolveDefault(field)
                     If Trim(copyDefault) <> "" Then
                        editor.Text = copyDefault
                     Else
                        editor.Clear()
                     End If
                  End If
               End If
            End If
         Next
         If Assigned(me.TopBar) Then
            If Assigned(me.TopBar.Ok) Then
               If modeKey = "VISUALIZAR" Then
                  me.TopBar.Ok.Caption = "Fechar"
               ElseIf modeKey = "EXCLUIR" Then
                  me.TopBar.Ok.Caption = "Excluir"
               Else
                  me.TopBar.Ok.Caption = "&Ok"
               End If
            End If
         End If
         me._applyTabOrder()
         me._syncCnpjCpfByPersonType()
      End Sub

      Sub ResetFor(pMode As TRegisterMode)
         me._confirmed = False
         me._commitAccepted = False
         me._clearEditors()
         me.Mode = pMode
         me._selectFirstFolder()
      End Sub

      Sub RememberContent()
         me._dropKept()
         me._kept = []
         me._kept.OwnsObjects = True
         Dim i As Integer
         Dim n As Integer = me._config.Fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = me._config.Fields.Take(i)
            If field.KeepContent Then
               me._kept.Push(New TRegisterKept(field.Name, me.Value(field.Name)))
            End If
         Next
      End Sub

      Sub RestoreContent()
         If Not Assigned(me._kept) Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = me._kept.Length - 1
         For i = 0 To n
            Dim item As TRegisterKept = me._kept.Take(i)
            me.SetValue(item.FieldName, item.FieldText)
         Next
      End Sub

      Function ExportKept() As StringList
         Dim list As New StringList()
         list.OwnsObjects = False
         If Not Assigned(me._kept) Then
            ExportKept = list
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = me._kept.Length - 1
         For i = 0 To n
            Dim item As TRegisterKept = me._kept.Take(i)
            list.Add(item.FieldName & Chr(1) & item.FieldText)
         Next
         ExportKept = list
      End Function

      Private Sub _dropKept()
         If Assigned(me._kept) Then
            me._kept.Free()
            me._kept = Null
         End If
      End Sub

      Private Sub _clearEditors()
         Dim i As Integer
         Dim n As Integer = me._config.Fields.Length - 1
         For i = 0 To n
            me.SetValue(me._config.Fields.Take(i).Name, "")
         Next
      End Sub

      Sub ApplyCopyDefaults()
         Dim i As Integer
         Dim n As Integer = me._config.Fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = me._config.Fields.Take(i)
            If (Not field.AutoIncrement) And TRegisterEval.IsReadOnly(field, "INCLUIR", False) Then
               me.SetValue(field.Name, TRegisterEval.ResolveDefault(field))
            End If
         Next
      End Sub

      Sub ApplyDefaults()
         Dim modeKey As String = me._modeKey()
         If (modeKey <> "INCLUIR") And (modeKey <> "COPIAR") Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = me._config.Fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = me._config.Fields.Take(i)
            Dim editor As TLabeledEditorBase = me.Editor(field.Name)
            If Assigned(editor) Then
               If TRegisterEval.ShouldFillDefault(editor.Text, field.Name) Then
                  Dim resolved As String = TRegisterEval.ResolveDefault(field)
                  If TRegisterEval.TextOf(resolved) <> "" Then
                     editor.Text = resolved
                  End If
               End If
            End If
         Next
      End Sub

      Protected Overrides Sub HandleOk(pSender As TObject)
         Dim modeKey As String = me._modeKey()
         If modeKey = "VISUALIZAR" Then
            me._confirmed = True
            me.Close(True)
            Exit Sub
         End If
         If modeKey <> "EXCLUIR" Then
            If Not me.Validate() Then
               Exit Sub
            End If
         End If
         me._commitAccepted = False
         Try
            If me.OnCommit <> Null Then
               me.OnCommit(me)
            End If
         Catch ex As Exception
            Throw New Exception(ex.Message)
         End Try
         If Not me._commitAccepted Then
            Exit Sub
         End If
         If modeKey = "INCLUIR" Then
            me.RememberContent()
         End If
         me._confirmed = True
         me.Close(True)
      End Sub

      Protected Overrides Sub Build()
      End Sub

      Private Sub _applyCaption()
         Dim title As String = Trim(me._config.Title)
         Dim modeText As String = me._mode.AsString
         If title = "" Then
            me.Caption = modeText
         Else
            me.Caption = title & " - " & modeText
         End If
      End Sub

      Private Function _modeKey() As String
         If Assigned(me._mode) Then
            _modeKey = UCase(me._mode.AsString)
         Else
            _modeKey = "INCLUIR"
         End If
      End Function

      Private Function _requiredMessage(pField As TRegisterField) As String
         Dim caption As String = Trim(pField.Caption)
         If caption = "" Then
            caption = pField.Name
         End If
         If Right(caption, 1) = ":" Then
            caption = Left(caption, Len(caption) - 1)
         End If
         _requiredMessage = caption & " é obrigatório."
      End Function

      Private Sub _registerEditor(pField As TRegisterField, pEditor As TLabeledEditorBase)
         If Not Assigned(pEditor) Then
            Exit Sub
         End If
         Dim key As String = UCase(Trim(pField.Name))
         If key = "" Then
            Exit Sub
         End If
         Dim idx As Integer = me._editors.IndexOf(key)
         If idx >= 0 Then
            me._editors.Objects(idx) = pEditor
         Else
            me._editors.AddObject(key, pEditor)
         End If
      End Sub

      Private Sub _bindActionEditor(pField As TRegisterField, pEditor As TLabeledEditorBase)
         If (Not Assigned(pField)) Or (Not Assigned(pEditor)) Then
            Exit Sub
         End If
         If me._isCepKind(pField) Then
            Dim cepEd As TCEPEditor = CType(pEditor, TCEPEditor)
            cepEd.OnLoadData = me._onCepLoaded
         ElseIf me._isCnpjKind(pField) Then
            Dim cnpjEd As TCNPJEditor = CType(pEditor, TCNPJEditor)
            cnpjEd.OnLoadData = me._onCnpjLoaded
         End If
         If UCase(Trim(pField.Name)) = "TIPOPESSOA" Then
            pEditor.OnChange = me._onTipoPessoaChanged
         End If
      End Sub

      Private Function _isCepKind(pField As TRegisterField) As Boolean
         _isCepKind = CBool(UCase(pField.KindKey()) = "CEP")
      End Function

      Private Function _isCnpjKind(pField As TRegisterField) As Boolean
         Dim kind As String = UCase(pField.KindKey())
         _isCnpjKind = CBool((kind = "CNPJ") Or (kind = "CPFCNPJ") Or (kind = "CPF_CNPJ") Or (kind = "CPF-CNPJ"))
      End Function

      Private Function _isSearchKind(pField As TRegisterField) As Boolean
         Dim kind As String = UCase(pField.KindKey())
         _isSearchKind = CBool((kind = "SEARCH") Or (kind = "LOOKUP") Or (kind = "PESQUISA"))
      End Function

      Private Function _isCpfCnpjKind(pField As TRegisterField) As Boolean
         Dim kind As String = UCase(pField.KindKey())
         _isCpfCnpjKind = CBool((kind = "CPFCNPJ") Or (kind = "CPF_CNPJ") Or (kind = "CPF-CNPJ"))
      End Function

      Private Sub _onTipoPessoaChanged(pSender As TObject)
         me._syncCnpjCpfByPersonType()
      End Sub

      Sub SyncPersonType()
         me._syncCnpjCpfByPersonType()
      End Sub

      Private Sub _syncCnpjCpfByPersonType()
         Dim tipoEd As TLabeledEditorBase = me.Editor("TipoPessoa")
         Dim docEd As TLabeledEditorBase = me.Editor("CNPJ_CPF")
         If (Not Assigned(tipoEd)) Or (Not Assigned(docEd)) Then
            Exit Sub
         End If
         Dim field As TRegisterField = me._config.FieldByName("CNPJ_CPF")
         If Not Assigned(field) Then
            Exit Sub
         End If
         If Not me._isCpfCnpjKind(field) Then
            Exit Sub
         End If
         Dim cpfCnpj As TCPFCnpjEditor = CType(docEd, TCPFCnpjEditor)
         cpfCnpj.PersonType = tipoEd.Text
      End Sub

      Private Function _personDocError(pField As TRegisterField, pEditor As TLabeledEditorBase) As String
         If UCase(Trim(pField.Name)) <> "CNPJ_CPF" Then
            _personDocError = ""
            Exit Function
         End If
         If Not Assigned(pEditor) Then
            _personDocError = ""
            Exit Function
         End If
         If Trim(pEditor.Text) = "" Then
            _personDocError = ""
            Exit Function
         End If
         If Not me._isCpfCnpjKind(pField) Then
            _personDocError = ""
            Exit Function
         End If
         If Not Assigned(me.Editor("TipoPessoa")) Then
            _personDocError = ""
            Exit Function
         End If
         me._syncCnpjCpfByPersonType()
         Dim cpfCnpj As TCPFCnpjEditor = CType(pEditor, TCPFCnpjEditor)
         _personDocError = cpfCnpj.DocumentError()
      End Function

      Private Sub _onCepLoaded(pSender As TObject)
         Dim cepEd As TCEPEditor = CType(pSender, TCEPEditor)
         Dim prefix As String = me._prefixBySuffix(cepEd.FieldName, "CEP")
         me._applyCepData(prefix, cepEd.Data)
      End Sub

      Private Sub _onCnpjLoaded(pSender As TObject)
         Dim cnpjEd As TCNPJEditor = CType(pSender, TCNPJEditor)
         If Not cnpjEd.Data.Loaded Then
            Exit Sub
         End If
         Dim prefix As String = ""
         If Not me._tryCnpjPrefix(cnpjEd.FieldName, prefix) Then
            Exit Sub
         End If
         me._applyCnpjData(prefix, cnpjEd.Data)
      End Sub

      Private Function _prefixBySuffix(pName As String, pSuffix As String) As String
         Dim nome As String = Trim(pName)
         Dim suf As String = UCase(Trim(pSuffix))
         If (Len(nome) >= Len(suf)) And (Len(suf) > 0) Then
            If UCase(Right(nome, Len(suf))) = suf Then
               _prefixBySuffix = Left(nome, Len(nome) - Len(suf))
               Exit Function
            End If
         End If
         _prefixBySuffix = ""
      End Function

      Private Function _tryCnpjPrefix(pName As String, ByRef pPrefix As String) As Boolean
         If me._matchSuffix(pName, "CNPJ_CPF", pPrefix) Then
            _tryCnpjPrefix = True
         ElseIf me._matchSuffix(pName, "CPF_CNPJ", pPrefix) Then
            _tryCnpjPrefix = True
         ElseIf me._matchSuffix(pName, "CPFCNPJ", pPrefix) Then
            _tryCnpjPrefix = True
         ElseIf me._matchSuffix(pName, "CPF-CNPJ", pPrefix) Then
            _tryCnpjPrefix = True
         ElseIf me._matchSuffix(pName, "CNPJ", pPrefix) Then
            _tryCnpjPrefix = True
         Else
            pPrefix = ""
            _tryCnpjPrefix = False
         End If
      End Function

      Private Function _matchSuffix(pName As String, pSuffix As String, ByRef pPrefix As String) As Boolean
         Dim nome As String = Trim(pName)
         Dim suf As String = UCase(Trim(pSuffix))
         If (Len(nome) >= Len(suf)) And (Len(suf) > 0) Then
            If UCase(Right(nome, Len(suf))) = suf Then
               pPrefix = Left(nome, Len(nome) - Len(suf))
               _matchSuffix = True
               Exit Function
            End If
         End If
         pPrefix = ""
         _matchSuffix = False
      End Function

      Private Sub _applyCepData(pPrefix As String, pInfo As TCEPEditorData)
         me._fillPair(pPrefix, "Endereco", "Logradouro", pInfo.Logradouro)
         me._writeByName(pPrefix & "Bairro", pInfo.Bairro)
         me._writeByName(pPrefix & "Complemento", pInfo.Complemento)
         me._fillMunicipio(pPrefix, pInfo.IBGE)
      End Sub

      Private Sub _applyCnpjData(pPrefix As String, pInfo As TCNPJData)
         me._fillPair(pPrefix, "Nome", "RazaoSocial", pInfo.RazaoSocial)
         me._writeByName(pPrefix & "NomeFantasia", pInfo.NomeFantasia)
         me._fillPair(pPrefix, "Email", "EMail", pInfo.Email)
         me._fillPair(pPrefix, "Telefone", "Fone", pInfo.Telefone)
         me._fillPair(pPrefix, "Endereco", "Logradouro", pInfo.Logradouro)
         me._writeByName(pPrefix & "Numero", pInfo.Numero)
         me._writeByName(pPrefix & "Bairro", pInfo.Bairro)
         me._writeByName(pPrefix & "Complemento", pInfo.Complemento)
         Dim cepName As String = pPrefix & "CEP"
         Dim cepItem As TLabeledEditorBase = me.Editor(cepName)
         If Assigned(cepItem) Then
            If Trim(pInfo.CEP) <> "" Then
               cepItem.Text = pInfo.CEP
            End If
            Dim cepField As TRegisterField = me._config.FieldByName(cepName)
            If Assigned(cepField) Then
               If me._isCepKind(cepField) Then
                  Dim cepEd As TCEPEditor = CType(cepItem, TCEPEditor)
                  cepEd.Consultar()
                  Exit Sub
               End If
            End If
         End If
         me._fillMunicipio(pPrefix, TCEPEditor.LookupIbge(pInfo.CEP))
      End Sub

      Private Sub _fillPair(pPrefix As String, pFirst As String, pSecond As String, pValue As String)
         If me._writeByName(pPrefix & pFirst, pValue) Then
            Exit Sub
         End If
         me._writeByName(pPrefix & pSecond, pValue)
      End Sub

      Private Function _writeByName(pName As String, pValue As String) As Boolean
         If Trim(pValue) = "" Then
            _writeByName = False
            Exit Function
         End If
         Dim item As TLabeledEditorBase = me.Editor(pName)
         If Not Assigned(item) Then
            _writeByName = False
            Exit Function
         End If
         item.Text = pValue
         Dim field As TRegisterField = me._config.FieldByName(pName)
         If Assigned(field) Then
            If me._isSearchKind(field) Then
               Dim searchEd As TSearchEditor = CType(item, TSearchEditor)
               searchEd.Validate()
            End If
         End If
         _writeByName = True
      End Function

      Private Sub _fillMunicipio(pPrefix As String, pIbge As String)
         Dim digits As String = me._onlyDigits(pIbge)
         If digits = "" Then
            Exit Sub
         End If
         Dim cod As Integer = 0
         Try
            cod = TSql.ExecScalarV("SELECT CodMunicipio FROM Municipio WHERE CodigoIBGE = " & digits, "CodMunicipio", 0)
         Catch ex As Exception
            cod = 0
         End Try
         If cod > 0 Then
            me._writeByName(pPrefix & "CodMunicipio", CStr(cod))
         End If
      End Sub

      Private Function _onlyDigits(pValue As String) As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = Len(pValue)
         For i = 1 To n
            Dim ch As String = Mid(pValue, i, 1)
            If (ch >= "0") And (ch <= "9") Then
               result = result & ch
            End If
         Next
         _onlyDigits = result
      End Function

      Private Sub _applyTabOrder()
         Dim fields As TTList<TRegisterField> = me._config.FocusFields()
         Dim i As Integer
         Dim n As Integer = fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = fields.Take(i)
            field.TabOrder = i
            Dim editor As TLabeledEditorBase = me.Editor(field.Name)
            If Assigned(editor) Then
               editor.TabOrder = i
               editor.TabStop = me._tabStopFor(field, editor)
            End If
         Next
         fields.OwnsObjects = False
         fields.Free()
         If Assigned(me._headerHost) Then
            me._headerHost.TabOrder = 0
         End If
         If Assigned(me._tabsHost) Then
            If Assigned(me._headerHost) Then
               me._tabsHost.TabOrder = 1
            Else
               me._tabsHost.TabOrder = 0
            End If
         End If
      End Sub

      Private Function _tabStopFor(pField As TRegisterField, pEditor As TLabeledEditorBase) As Boolean
         If Not Assigned(pEditor) Then
            _tabStopFor = False
            Exit Function
         End If
         If (Not pField.Visible) Or (Not pEditor.Visible) Then
            _tabStopFor = False
            Exit Function
         End If
         If Not pEditor.Enabled Then
            _tabStopFor = False
            Exit Function
         End If
         If pEditor.OnlyRead Then
            _tabStopFor = False
            Exit Function
         End If
         Dim kind As String = UCase(pField.KindKey())
         If (kind = "IMAGE") Or (kind = "IMAGEM") Or (kind = "FOTO") Or (kind = "BUTTON") Or (kind = "BOTAO") Then
            _tabStopFor = False
            Exit Function
         End If
         _tabStopFor = True
      End Function

      Private Function _isEditMode() As Boolean
         Dim modeKey As String = me._modeKey()
         _isEditMode = CBool((modeKey = "INCLUIR") Or (modeKey = "ALTERAR") Or (modeKey = "COPIAR"))
      End Function

      Private Sub _focusFirstActive()
         If Not me._isEditMode() Then
            Exit Sub
         End If
         Dim fields As TTList<TRegisterField> = me._config.FocusFields()
         Dim i As Integer
         Dim n As Integer = fields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = fields.Take(i)
            Dim editor As TLabeledEditorBase = me.Editor(field.Name)
            If me._tabStopFor(field, editor) Then
               me._focusEditor(field, editor)
               fields.OwnsObjects = False
               fields.Free()
               Exit Sub
            End If
         Next
         fields.OwnsObjects = False
         fields.Free()
      End Sub

      Private Sub _focusEditor(pField As TRegisterField, pEditor As TLabeledEditorBase)
         If Not Assigned(pEditor) Then
            Exit Sub
         End If
         me._revealField(pField)
         If pEditor.Visible Then
            pEditor.SetFocus()
         End If
      End Sub

      Private Sub _revealField(pField As TRegisterField)
         If Assigned(pField) Then
            me._revealFolder(pField.FolderId)
         End If
      End Sub

      Private Sub _selectFirstFolder()
         If Assigned(me._tabsHost) Then
            If me._tabsHost.PageCount > 0 Then
               me._tabsHost.ActivePageIndex = 0
            End If
         End If
         If Not Assigned(me._folderSheets) Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = me._folderSheets.Count - 1
         For i = 0 To n
            Dim sheet As TabSheet = CType(me._folderSheets.Objects(i), TabSheet)
            If Assigned(sheet) Then
               Dim pages As PageControl = sheet.PageControl
               If Assigned(pages) Then
                  If pages.PageCount > 0 Then
                     pages.ActivePageIndex = 0
                  End If
               End If
            End If
         Next
      End Sub

      Private Sub _revealFolder(pId As String)
         Dim id As String = Trim(pId)
         If id = "" Then
            Exit Sub
         End If
         Dim parentId As String = ""
         If Assigned(me._config) Then
            Dim folder As TRegisterFolder = me._config.FolderById(id)
            If Assigned(folder) Then
               parentId = Trim(folder.ParentId)
            End If
         End If
         If parentId = "" Then
            parentId = TRegisterFormConfig.ParentFolderId(id)
         End If
         If (parentId <> "") And (parentId <> id) Then
            me._revealFolder(parentId)
         End If
         If Not Assigned(me._folderSheets) Then
            Exit Sub
         End If
         Dim idx As Integer = me._folderSheets.IndexOf(id)
         If idx < 0 Then
            Exit Sub
         End If
         Dim sheet As TabSheet = CType(me._folderSheets.Objects(idx), TabSheet)
         If Assigned(sheet) Then
            Dim pages As PageControl = sheet.PageControl
            If Assigned(pages) Then
               pages.ActivePageIndex = sheet.PageIndex
            End If
         End If
      End Sub

      Private Sub _rememberSheet(pFolder As TRegisterFolder, pSheet As TabSheet)
         If (Not Assigned(pFolder)) Or (Not Assigned(pSheet)) Then
            Exit Sub
         End If
         If Not Assigned(me._folderSheets) Then
            Exit Sub
         End If
         Dim key As String = Trim(pFolder.Id)
         If key = "" Then
            Exit Sub
         End If
         Dim idx As Integer = me._folderSheets.IndexOf(key)
         If idx >= 0 Then
            me._folderSheets.Objects(idx) = pSheet
         Else
            me._folderSheets.AddObject(key, pSheet)
         End If
      End Sub

      Private Function _host(pParent As TWinControl, pAlign As TAlign, pHeight As Integer, pTabs As Boolean) As PageControl
         Dim box As PageControl = New PageControl(pParent)
         box.Align = pAlign
         box.TabStop = False
         If Not pTabs Then
            box.ShowCardFrame = False
            box.ShowShadow = False
         Else
            box.ShowShadow = False
         End If
         If pHeight > 0 Then
            box.Height = pHeight
         End If
         _host = box
      End Function

      Private Sub _pad(pBox As PageControl, pMargin As Integer)
         Dim m As Integer = pMargin
         If m <= 0 Then
            m = me._config.ContentMargin
         End If
         If m > 0 Then
            pBox.AlignWithMargins = True
            pBox.Margins.Left = m
            pBox.Margins.Top = m
            pBox.Margins.Right = m
            pBox.Margins.Bottom = 4
         End If
      End Sub

      Private Sub _buildHeader()
         Dim fields As TTList<TRegisterField> = me._config.SortedHeaderFields()
         If fields.Length <= 0 Then
            If Assigned(fields) Then
               fields.OwnsObjects = False
               fields.Free()
            End If
            Exit Sub
         End If
         me._headerHost = me._host(me.Content, alTop, 0, False)
         me._pad(me._headerHost, me._config.ContentMargin)
         Dim h As Integer = me._layout.Place(me._headerHost, fields, me._boundCreate)
         me._headerHost.Height = h
         fields.OwnsObjects = False
         fields.Free()
      End Sub

      Private Sub _buildTabs()
         Dim roots As TTList<TRegisterFolder> = TRegisterFormConfig.SortFolders(me._config.Folders)
         If roots.Length <= 0 Then
            If Assigned(roots) Then
               roots.OwnsObjects = False
               roots.Free()
            End If
            Exit Sub
         End If
         me._tabsHost = me._host(me.Content, alClient, 0, True)
         me._pad(me._tabsHost, 4)
         me._fillPages(me._tabsHost, roots)
         roots.OwnsObjects = False
         roots.Free()
      End Sub

      Private Sub _fillPages(pPages As PageControl, pFolders As TTList<TRegisterFolder>)
         Dim list As TTList<TRegisterFolder> = TRegisterFormConfig.SortFolders(pFolders)
         Dim i As Integer
         Dim n As Integer = list.Length - 1
         Dim added As Integer = 0
         For i = 0 To n
            Dim folder As TRegisterFolder = list.Take(i)
            If folder.Visible Then
               ' data7:disable-next-line unknown-member
               pPages.UseColoredTabs = True
               pPages.Color = RGB(200, 213, 223)
               Dim sheet As TabSheet = New TabSheet(pPages)
               sheet.Caption = folder.Title
               me._rememberSheet(folder, sheet)
               me._buildFolderBody(sheet, folder)
               added = added + 1
            End If
         Next
         If added > 0 Then
            pPages.ActivePageIndex = 0
         End If
         list.OwnsObjects = False
         list.Free()
      End Sub

      Private Sub _buildFolderBody(pSheet As TabSheet, pFolder As TRegisterFolder)
         Dim body As PageControl = me._host(pSheet, alClient, 0, False)
         Dim margin As Integer = pFolder.Margin
         If margin <= 0 Then
            margin = me._config.ContentMargin
         End If
         me._pad(body, margin)
         If pFolder.SubCadastro Then
            me.BuildSubCadastro(body, pFolder)
            If pFolder.ContentHeight <= 0 Then
               pFolder.ContentHeight = 200
            End If
            If me.OnBuildFolder <> Null Then
               me.OnBuildFolder(pFolder)
            End If
            Exit Sub
         End If
         Dim hasChildren As Boolean = pFolder.HasChildren()
         Dim hasFields As Boolean = pFolder.HasFields()
         Dim fieldsH As Integer = 0
         If hasFields Then
            Dim alignFields As TAlign = alClient
            If hasChildren Then
               alignFields = alTop
            End If
            Dim fieldsHost As PageControl = me._host(body, alignFields, 0, False)
            fieldsHost.TabOrder = 0
            Dim sorted As TTList<TRegisterField> = TRegisterFormConfig.SortFields(pFolder.Fields)
            fieldsH = me._layout.Place(fieldsHost, sorted, me._boundCreate)
            If hasChildren Then
               fieldsHost.Height = fieldsH
            End If
            sorted.OwnsObjects = False
            sorted.Free()
         End If
         Dim nestedH As Integer = 0
         If hasChildren Then
            Dim nested As PageControl = me._host(body, alClient, 0, True)
            If hasFields Then
               nested.TabOrder = 1
            Else
               nested.TabOrder = 0
            End If
            me._fillPages(nested, pFolder.Folders)
            nestedH = me._layout.TabHeaderHeight + me._maxFolderHeight(pFolder.Folders)
         End If
         pFolder.ContentHeight = fieldsH + nestedH
         If body.AlignWithMargins Then
            pFolder.ContentHeight = pFolder.ContentHeight + body.Margins.Top + body.Margins.Bottom
         End If
         If me.OnBuildFolder <> Null Then
            me.OnBuildFolder(pFolder)
         End If
      End Sub

      Private Function _maxFolderHeight(pFolders As TTList<TRegisterFolder>) As Integer
         Dim best As Integer = 0
         If Not Assigned(pFolders) Then
            _maxFolderHeight = 0
            Exit Function
         End If
         Dim list As TTList<TRegisterFolder> = TRegisterFormConfig.SortFolders(pFolders)
         Dim i As Integer
         Dim n As Integer = list.Length - 1
         For i = 0 To n
            Dim folder As TRegisterFolder = list.Take(i)
            If folder.Visible Then
               If folder.ContentHeight > best Then
                  best = folder.ContentHeight
               End If
            End If
         Next
         list.OwnsObjects = False
         list.Free()
         _maxFolderHeight = best
      End Function

      Private Function _outerHeight(pBox As PageControl) As Integer
         Dim h As Integer = pBox.Height
         If pBox.AlignWithMargins Then
            h = h + pBox.Margins.Top + pBox.Margins.Bottom
         End If
         _outerHeight = h
      End Function

      Private Function _windowChrome() As Integer
         Dim extra As Integer = 40
         If Assigned(me.TopBar) Then
            If me.TopBar.Visible Then
               extra = extra + me.TopBar.Height
            End If
         End If
         _windowChrome = extra
      End Function

      Private Sub _fitHeight()
         Dim body As Integer = 0
         If Assigned(me._headerHost) Then
            body = body + me._outerHeight(me._headerHost)
         End If
         If Assigned(me._tabsHost) Then
            body = body + me._layout.TabHeaderHeight + me._maxFolderHeight(me._config.Folders)
            If me._tabsHost.AlignWithMargins Then
               body = body + me._tabsHost.Margins.Top + me._tabsHost.Margins.Bottom
            End If
         End If
         me.Height.Value = body + me._windowChrome()
      End Sub

      Sub Free()
         If Assigned(me._folderSheets) Then
            me._folderSheets.Free()
            me._folderSheets = Null
         End If
         If Assigned(me._editors) Then
            Dim i As Integer
            Dim n As Integer = me._editors.Count - 1
            For i = 0 To n
               Dim editor As TLabeledEditorBase = CType(me._editors.Objects(i), TLabeledEditorBase)
               If Assigned(editor) Then
                  editor.Free()
               End If
            Next
            me._editors.Free()
            me._editors = Null
         End If
         If Assigned(me._layout) Then
            me._layout.Free()
            me._layout = Null
         End If
         If me._ownsConfig Then
            If Assigned(me._config) Then
               me._config.Free()
               me._config = Null
            End If
         End If
         me._dropKept()
         MyBase.Free()
      End Sub

   End Class

End Namespace
