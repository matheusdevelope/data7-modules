Imports Forms
Imports mod_tlist
Imports mod_editors

Namespace mod_register_config

   Delegate Function TRegisterEditorCreate(pParent As TWinControl, pField As TRegisterField) As TLabeledEditorBase

   Enun TRegisterMode
      Incluir = "Incluir"
      Alterar = "Alterar"
      Excluir = "Excluir"
      Copiar = "Copiar"
      Visualizar = "Visualizar"
   End Enun

   Enun TRegisterFieldKind
      fkText = "Text"
      fkInteger = "Integer"
      fkNumber = "Number"
      fkValue = "Value"
      fkDate = "Date"
      fkTime = "Time"
      fkDateTime = "DateTime"
      fkCombo = "Combo"
      fkSearch = "Search"
      fkMemo = "Memo"
      fkCheck = "Check"
      fkMask = "Mask"
      fkPassword = "Password"
      fkImage = "Image"
      fkButton = "Button"
      fkCEP = "CEP"
      fkCPF = "CPF"
      fkCNPJ = "CNPJ"
      fkCpfCnpj = "CpfCnpj"
      fkEmail = "Email"
      fkSite = "Site"
      fkIE = "IE"
      fkPlaca = "Placa"
      fkGtin = "Gtin"
      fkCnh = "Cnh"
      fkRenavam = "Renavam"
      fkSuframa = "Suframa"
      fkCustom = "Custom"
   End Enun

   Class TRegisterField

      Owner As TRegisterFormConfig
      Name As String
      Caption As String
      EditorKind As String
      Kind As TRegisterFieldKind
      FolderId As String
      Order As Integer
      MaxLength As Integer
      Width As Integer
      Height As Integer
      LabelWidth As Integer
      LabelSpacing As Integer
      SpanRow As Boolean
      Column As Integer
      Required As Boolean
      Locked As Boolean
      Visible As Boolean
      Enabled As Boolean
      CanEditInsert As Boolean
      CanEditUpdate As Boolean
      IsKey As Boolean
      AutoIncrement As Boolean
      KeepContent As Boolean
      DefaultValue As String
      TipoValorPadrao As String
      FormulaValorPadrao As String
      CondicaoEditarInclusao As String
      CondicaoEditarAlteracao As String
      CondicaoObrigatorio As String
      ListaOpcoes As String
      CodPesquisa As Integer
      TipoPesquisa As String
      PesquisaIncremental As Boolean
      ExpressaoFiltro As String
      Mask As String
      DecimalPlaces As Integer
      DisplayFormat As String
      ShowTime As Boolean
      TimeOnly As Boolean
      CharCase As String
      FontName As String
      FontSize As Integer
      FontColor As Integer
      FontBold As Boolean
      FontItalic As Boolean
      FontUnderline As Boolean
      Hint As String
      Ajuda As String
      Tipo As String
      ValidacaoSistema As String
      ValidacaoUsuario As String
      Alignment As String
      TabOrder As Integer
      Placement As TLabelPlacement
      Factory As TRegisterEditorCreate
      Tag As String

      Sub New()
         MyBase.New()
         me.Kind = TRegisterFieldKind.fkText()
         me.EditorKind = "Text"
         me.Visible = True
         me.Enabled = True
         me.CanEditInsert = True
         me.CanEditUpdate = True
         me.DecimalPlaces = -1
         me.FontColor = -1
         me.TabOrder = -1
         me.LabelWidth = 0
         me.LabelSpacing = 5
         me.Placement = TLabelPlacement.Load("Left")
      End Sub

      Function KindKey() As String
         Dim key As String = Trim(me.EditorKind)
         If key = "" Then
            If Assigned(me.Kind) Then
               key = me.Kind.AsString
            End If
         End If
         If key = "" Then
            key = "Text"
         End If
         KindKey = key
      End Function

      Function SetKind(pKind As TRegisterFieldKind) As TRegisterField
         me.Kind = pKind
         If Assigned(pKind) Then
            me.EditorKind = pKind.AsString
         End If
         SetKind = me
      End Function

      Function SetKind(pKey As String) As TRegisterField
         me.EditorKind = Trim(pKey)
         me.Kind = TRegisterFieldKind.fkCustom()
         SetKind = me
      End Function

      Function UseText() As TRegisterField
         UseText = me.SetKind(TRegisterFieldKind.fkText())
      End Function

      Function UseMemo() As TRegisterField
         me.SpanRow = True
         UseMemo = me.SetKind(TRegisterFieldKind.fkMemo())
      End Function

      Function UseCombo(pLista As String) As TRegisterField
         me.ListaOpcoes = pLista
         UseCombo = me.SetKind(TRegisterFieldKind.fkCombo())
      End Function

      Function UseSearch(pCodPesquisa As Integer) As TRegisterField
         me.CodPesquisa = pCodPesquisa
         UseSearch = me.SetKind(TRegisterFieldKind.fkSearch())
      End Function

      Function UseInteger() As TRegisterField
         me.DecimalPlaces = 0
         me.DisplayFormat = "0"
         UseInteger = me.SetKind(TRegisterFieldKind.fkInteger())
      End Function

      Function UseNumber() As TRegisterField
         UseNumber = me.SetKind(TRegisterFieldKind.fkNumber())
      End Function

      Function UseValue(pDecimals As Integer = 2) As TRegisterField
         me.DecimalPlaces = pDecimals
         UseValue = me.SetKind(TRegisterFieldKind.fkValue())
      End Function

      Function UseDate() As TRegisterField
         me.ShowTime = False
         me.TimeOnly = False
         UseDate = me.SetKind(TRegisterFieldKind.fkDate())
      End Function

      Function UseTime() As TRegisterField
         me.ShowTime = False
         me.TimeOnly = True
         UseTime = me.SetKind(TRegisterFieldKind.fkTime())
      End Function

      Function UseDateTime() As TRegisterField
         me.ShowTime = True
         me.TimeOnly = False
         UseDateTime = me.SetKind(TRegisterFieldKind.fkDateTime())
      End Function

      Function UseCheck() As TRegisterField
         UseCheck = me.SetKind(TRegisterFieldKind.fkCheck())
      End Function

      Function UseMask(pMask As String) As TRegisterField
         me.Mask = pMask
         UseMask = me.SetKind(TRegisterFieldKind.fkMask())
      End Function

      Function UsePassword() As TRegisterField
         UsePassword = me.SetKind(TRegisterFieldKind.fkPassword())
      End Function

      Function UseImage() As TRegisterField
         me.SpanRow = True
         UseImage = me.SetKind(TRegisterFieldKind.fkImage())
      End Function

      Function UseButton() As TRegisterField
         UseButton = me.SetKind(TRegisterFieldKind.fkButton())
      End Function

      Function UseCEP() As TRegisterField
         UseCEP = me.SetKind(TRegisterFieldKind.fkCEP())
      End Function

      Function UseCPF() As TRegisterField
         UseCPF = me.SetKind(TRegisterFieldKind.fkCPF())
      End Function

      Function UseCNPJ() As TRegisterField
         UseCNPJ = me.SetKind(TRegisterFieldKind.fkCNPJ())
      End Function

      Function UseCpfCnpj() As TRegisterField
         UseCpfCnpj = me.SetKind(TRegisterFieldKind.fkCpfCnpj())
      End Function

      Function UseEmail() As TRegisterField
         UseEmail = me.SetKind(TRegisterFieldKind.fkEmail())
      End Function

      Function UseSite() As TRegisterField
         UseSite = me.SetKind(TRegisterFieldKind.fkSite())
      End Function

      Function UseIE() As TRegisterField
         UseIE = me.SetKind(TRegisterFieldKind.fkIE())
      End Function

      Function UsePlaca() As TRegisterField
         UsePlaca = me.SetKind(TRegisterFieldKind.fkPlaca())
      End Function

      Function UseGtin() As TRegisterField
         UseGtin = me.SetKind(TRegisterFieldKind.fkGtin())
      End Function

      Function UseCnh() As TRegisterField
         UseCnh = me.SetKind(TRegisterFieldKind.fkCnh())
      End Function

      Function UseRenavam() As TRegisterField
         UseRenavam = me.SetKind(TRegisterFieldKind.fkRenavam())
      End Function

      Function UseSuframa() As TRegisterField
         UseSuframa = me.SetKind(TRegisterFieldKind.fkSuframa())
      End Function

      Function Require(pValue As Boolean = True) As TRegisterField
         me.Required = pValue
         Require = me
      End Function

      Function MaxLen(pValue As Integer) As TRegisterField
         me.MaxLength = pValue
         MaxLen = me
      End Function

      Function WithWidth(pValue As Integer) As TRegisterField
         me.Width = pValue
         WithWidth = me
      End Function

      Function WithHeight(pValue As Integer) As TRegisterField
         me.Height = pValue
         WithHeight = me
      End Function

      Function WithLabelWidth(pValue As Integer) As TRegisterField
         me.LabelWidth = pValue
         WithLabelWidth = me
      End Function

      Function FullRow(pValue As Boolean = True) As TRegisterField
         me.SpanRow = pValue
         FullRow = me
      End Function

      Function Lock(pValue As Boolean = True) As TRegisterField
         me.Locked = pValue
         Lock = me
      End Function

      Function Hide() As TRegisterField
         me.Visible = False
         Hide = me
      End Function

      Function WithHint(pValue As String) As TRegisterField
         me.Hint = pValue
         WithHint = me
      End Function

      Function WithMask(pValue As String) As TRegisterField
         me.Mask = pValue
         WithMask = me
      End Function

      Function WithOptions(pValue As String) As TRegisterField
         me.ListaOpcoes = pValue
         WithOptions = me
      End Function

      Function DefaultTo(pValue As String) As TRegisterField
         me.DefaultValue = pValue
         DefaultTo = me
      End Function

      Function WithOrder(pValue As Integer) As TRegisterField
         me.Order = pValue
         WithOrder = me
      End Function

      Function KeyField(pValue As Boolean = True) As TRegisterField
         me.IsKey = pValue
         KeyField = me
      End Function

      Function WithFactory(pFactory As TRegisterEditorCreate) As TRegisterField
         me.Factory = pFactory
         me.Kind = TRegisterFieldKind.fkCustom()
         WithFactory = me
      End Function

      Function InFolder(pId As String, pTitle As String = "") As TRegisterField
         If Assigned(me.Owner) Then
            me.Owner.MoveToFolder(me, pId, pTitle)
         Else
            me.FolderId = Trim(pId)
         End If
         InFolder = me
      End Function

      Function ToProps() As TEditorProps
         Dim props As New TEditorProps()
         props.Caption = me.Caption
         props.FieldName = me.Name
         If me.LabelWidth > 0 Then
            props.LabelWidth = me.LabelWidth
         End If
         If me.Height > 0 Then
            props.EditorHeight = me.Height
         End If
         props.LabelSpacing = me.LabelSpacing
         props.Enabled = me.Enabled
         props.Visible = me.Visible
         props.Required = me.Required
         props.OnlyRead = me.Locked
         props.Hint = me.Hint
         props.Ajuda = me.Ajuda
         props.MaxLength = me.MaxLength
         props.Mask = me.Mask
         props.ListaOpcoes = me.ListaOpcoes
         props.CodPesquisa = me.CodPesquisa
         props.TipoPesquisa = me.TipoPesquisa
         props.PesquisaIncremental = me.PesquisaIncremental
         props.ExpressaoFiltro = me.ExpressaoFiltro
         props.DecimalPlaces = me.DecimalPlaces
         props.DisplayFormat = me.DisplayFormat
         props.ShowTime = me.ShowTime
         props.TimeOnly = me.TimeOnly
         props.EditorAlignment = me.Alignment
         props.TabOrder = me.TabOrder
         If Trim(me.CharCase) <> "" Then
            props.CharCase = CharCaseFromCode(me.CharCase)
         End If
         props.EditorName = me.FontName
         props.EditorSize = me.FontSize
         props.EditorColor = me.FontColor
         props.EditorBold = me.FontBold
         props.EditorItalic = me.FontItalic
         props.EditorUnderline = me.FontUnderline
         If Assigned(me.Placement) Then
            props.Placement = me.Placement
         End If
         ToProps = props
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TRegisterFolder

      Owner As TRegisterFormConfig
      Id As String
      Title As String
      ParentId As String
      Estrutura As String
      Visible As Boolean
      SubCadastro As Boolean
      Margin As Integer
      Order As Integer
      ContentHeight As Integer
      Fields[] As TRegisterField
      Folders[] As TRegisterFolder

      Sub New()
         MyBase.New()
         me.Visible = True
         me.Fields = []
         me.Fields.OwnsObjects = False
         me.Folders = []
         me.Folders.OwnsObjects = True
      End Sub

      Function AddField(pName As String, pCaption As String) As TRegisterField
         If Assigned(me.Owner) Then
            AddField = me.Owner.AddField(pName, pCaption).InFolder(me.Id, me.Title)
         Else
            Dim field As New TRegisterField()
            field.Name = pName
            field.Caption = pCaption
            field.FolderId = me.Id
            field.Order = me.Fields.Length
            me.Fields.Push(field)
            AddField = field
         End If
      End Function

      Function AddFolder(pId As String, pTitle As String) As TRegisterFolder
         If Assigned(me.Owner) Then
            AddFolder = me.Owner.AddFolder(pId, pTitle, me.Id)
         Else
            Dim child As New TRegisterFolder()
            child.Id = Trim(pId)
            child.Title = pTitle
            child.ParentId = me.Id
            child.Estrutura = Trim(pId)
            child.Owner = me.Owner
            me.Folders.Push(child)
            AddFolder = child
         End If
      End Function

      Function HasChildren() As Boolean
         HasChildren = me.Folders.Length > 0
      End Function

      Function HasFields() As Boolean
         HasFields = me.Fields.Length > 0
      End Function

      Function FieldByName(pName As String) As TRegisterField
         Dim alvo As String = UCase(Trim(pName))
         Dim i As Integer
         Dim n As Integer = me.Fields.Length - 1
         For i = 0 To n
            Dim item As TRegisterField = me.Fields.Take(i)
            If UCase(Trim(item.Name)) = alvo Then
               FieldByName = item
               Exit Function
            End If
         Next
         FieldByName = Null
      End Function

      Sub Free()
         If Assigned(me.Fields) Then
            me.Fields.OwnsObjects = False
            me.Fields.Free()
            me.Fields = Null
         End If
         If Assigned(me.Folders) Then
            me.Folders.Free()
            me.Folders = Null
         End If
         MyBase.Free()
      End Sub

   End Class

   Class TRegisterFormConfig

      Title As String
      LabelWidth As Integer
      LabelSpacing As Integer
      FullRowChars As Integer
      CharWidth As Integer
      RowHeight As Integer
      Gutter As Integer
      ContentMargin As Integer
      LayoutWidth As Integer
      ConfirmDeleteMessage As String
      Fields[] As TRegisterField
      HeaderFields[] As TRegisterField
      Folders[] As TRegisterFolder

      Sub New()
         MyBase.New()
         me.LabelWidth = 110
         me.LabelSpacing = 5
         me.FullRowChars = 40
         me.CharWidth = 8
         me.RowHeight = 27
         me.Gutter = 8
         me.ContentMargin = 6
         me.LayoutWidth = 808
         me.ConfirmDeleteMessage = "Confirma a exclusão do registro?"
         me.Fields = []
         me.Fields.OwnsObjects = True
         me.HeaderFields = []
         me.HeaderFields.OwnsObjects = False
         me.Folders = []
         me.Folders.OwnsObjects = True
      End Sub

      Function AddField(pName As String, pCaption As String) As TRegisterField
         Dim field As New TRegisterField()
         field.Owner = me
         field.Name = pName
         field.Caption = pCaption
         field.Order = me.Fields.Length
         If field.LabelWidth <= 0 Then
            field.LabelWidth = me.LabelWidth
         End If
         If field.LabelSpacing <= 0 Then
            field.LabelSpacing = me.LabelSpacing
         End If
         me.Fields.Push(field)
         me.HeaderFields.Push(field)
         AddField = field
      End Function

      Function AddFolder(pId As String, pTitle As String) As TRegisterFolder
         AddFolder = me._addFolder(pId, pTitle, me._resolveParentId(pId))
      End Function

      Function AddFolder(pId As String, pTitle As String, pParentId As String) As TRegisterFolder
         AddFolder = me._addFolder(pId, pTitle, pParentId)
      End Function

      Function EnsureFolder(pId As String) As TRegisterFolder
         EnsureFolder = me._ensureFolder(pId, me._resolveParentId(pId))
      End Function

      Function EnsureFolder(pId As String, pParentId As String) As TRegisterFolder
         EnsureFolder = me._ensureFolder(pId, pParentId)
      End Function

      Private Function _addFolder(pId As String, pTitle As String, pParentId As String) As TRegisterFolder
         Dim folder As TRegisterFolder = me._ensureFolder(pId, pParentId)
         If Assigned(folder) Then
            If Trim(pTitle) <> "" Then
               folder.Title = pTitle
            End If
         End If
         _addFolder = folder
      End Function

      Private Function _ensureFolder(pId As String, pParentId As String) As TRegisterFolder
         Dim id As String = Trim(pId)
         If id = "" Then
            _ensureFolder = Null
            Exit Function
         End If
         Dim existing As TRegisterFolder = me.FolderById(id)
         If Assigned(existing) Then
            _ensureFolder = existing
            Exit Function
         End If
         Dim parentId As String = Trim(pParentId)
         If parentId = id Then
            parentId = ""
         End If
         Dim folder As New TRegisterFolder()
         folder.Owner = me
         folder.Id = id
         folder.Title = id
         folder.ParentId = parentId
         If Trim(folder.Estrutura) = "" Then
            folder.Estrutura = id
         End If
         If parentId = "" Then
            folder.Order = me.Folders.Length
            me.Folders.Push(folder)
         Else
            Dim parent As TRegisterFolder = me._ensureFolder(parentId, TRegisterFormConfig.ParentFolderId(parentId))
            If Assigned(parent) Then
               folder.Order = parent.Folders.Length
               parent.Folders.Push(folder)
            Else
               folder.ParentId = ""
               folder.Order = me.Folders.Length
               me.Folders.Push(folder)
            End If
         End If
         _ensureFolder = folder
      End Function

      Sub MoveToFolder(pField As TRegisterField, pId As String, pTitle As String = "")
         me._detachField(pField)
         Dim id As String = Trim(pId)
         If id = "" Then
            pField.FolderId = ""
            me.HeaderFields.Push(pField)
            Exit Sub
         End If
         Dim folder As TRegisterFolder = me.EnsureFolder(id)
         If Trim(pTitle) <> "" Then
            folder.Title = pTitle
         End If
         pField.FolderId = folder.Id
         folder.Fields.Push(pField)
      End Sub

      Function FieldByName(pName As String) As TRegisterField
         Dim alvo As String = UCase(Trim(pName))
         Dim i As Integer
         Dim n As Integer = me.Fields.Length - 1
         For i = 0 To n
            Dim item As TRegisterField = me.Fields.Take(i)
            If UCase(Trim(item.Name)) = alvo Then
               FieldByName = item
               Exit Function
            End If
         Next
         FieldByName = Null
      End Function

      Function FolderById(pId As String) As TRegisterFolder
         FolderById = me._findFolder(me.Folders, Trim(pId))
      End Function

      Function SortedHeaderFields() As TTList<TRegisterField>
         SortedHeaderFields = TRegisterFormConfig.SortFields(me.HeaderFields)
      End Function

      Function FocusFields() As TTList<TRegisterField>
         Dim lista[] As TRegisterField = []
         lista.OwnsObjects = False
         Dim header As TTList<TRegisterField> = me.SortedHeaderFields()
         me._appendFieldList(lista, header)
         If Assigned(header) Then
            header.OwnsObjects = False
            header.Free()
         End If
         me._appendFolderFields(lista, me.Folders)
         FocusFields = lista
      End Function

      Shared Function ParentFolderId(pId As String) As String
         Dim id As String = Trim(pId)
         Dim lastDot As Integer = 0
         Dim i As Integer
         Dim n As Integer = Len(id)
         For i = 1 To n
            If Mid(id, i, 1) = "." Then
               lastDot = i
            End If
         Next
         If lastDot <= 1 Then
            ParentFolderId = ""
         Else
            ParentFolderId = Left(id, lastDot - 1)
         End If
      End Function

      Shared Function IsEstruturaPrefix(pParent As String, pChild As String) As Boolean
         Dim parentEst As String = Trim(pParent)
         Dim childEst As String = Trim(pChild)
         Dim parentLen As Integer = Len(parentEst)
         If (parentEst = "") Or (childEst = "") Or (parentLen >= Len(childEst)) Then
            IsEstruturaPrefix = False
            Exit Function
         End If
         If Left(childEst, parentLen) <> parentEst Then
            IsEstruturaPrefix = False
            Exit Function
         End If
         Dim nextChar As String = Mid(childEst, parentLen + 1, 1)
         If nextChar = "." Then
            IsEstruturaPrefix = True
         ElseIf (parentEst.Pos(".") = 0) And (childEst.Pos(".") = 0) Then
            IsEstruturaPrefix = True
         Else
            IsEstruturaPrefix = False
         End If
      End Function

      Shared Function SortFields(pFields As TTList<TRegisterField>) As TTList<TRegisterField>
         Dim lista[] As TRegisterField = []
         lista.OwnsObjects = False
         If Not Assigned(pFields) Then
            SortFields = lista
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pFields.Length - 1
         For i = 0 To n
            lista.Push(pFields.Take(i))
         Next
         Dim a As Integer
         Dim b As Integer
         Dim last As Integer = lista.Length - 1
         For a = 0 To last
            For b = a + 1 To last
               Dim leftItem As TRegisterField = lista.Take(a)
               Dim rightItem As TRegisterField = lista.Take(b)
               If rightItem.Order < leftItem.Order Then
                  lista.SetItem(a, rightItem)
                  lista.SetItem(b, leftItem)
               End If
            Next
         Next
         SortFields = lista
      End Function

      Shared Function FolderSortKey(pFolder As TRegisterFolder) As String
         Dim key As String = ""
         If Assigned(pFolder) Then
            key = Trim(pFolder.Estrutura)
            If key = "" Then
               key = Trim(pFolder.Id)
            End If
         End If
         FolderSortKey = key
      End Function

      Shared Function SortFolders(pFolders As TTList<TRegisterFolder>) As TTList<TRegisterFolder>
         Dim lista[] As TRegisterFolder = []
         lista.OwnsObjects = False
         If Not Assigned(pFolders) Then
            SortFolders = lista
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pFolders.Length - 1
         For i = 0 To n
            lista.Push(pFolders.Take(i))
         Next
         Dim a As Integer
         Dim b As Integer
         Dim last As Integer = lista.Length - 1
         For a = 0 To last
            For b = a + 1 To last
               Dim leftItem As TRegisterFolder = lista.Take(a)
               Dim rightItem As TRegisterFolder = lista.Take(b)
               Dim leftKey As String = TRegisterFormConfig.FolderSortKey(leftItem)
               Dim rightKey As String = TRegisterFormConfig.FolderSortKey(rightItem)
               If (rightKey < leftKey) Or ((rightKey = leftKey) And (rightItem.Id < leftItem.Id)) Then
                  lista.SetItem(a, rightItem)
                  lista.SetItem(b, leftItem)
               End If
            Next
         Next
         SortFolders = lista
      End Function

      Private Sub _appendFieldList(pDest As TTList<TRegisterField>, pFields As TTList<TRegisterField>)
         If Not Assigned(pDest) Then
            Exit Sub
         End If
         If Not Assigned(pFields) Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = pFields.Length - 1
         For i = 0 To n
            pDest.Push(pFields.Take(i))
         Next
      End Sub

      Private Sub _appendFolderFields(pDest As TTList<TRegisterField>, pFolders As TTList<TRegisterFolder>)
         If Not Assigned(pDest) Then
            Exit Sub
         End If
         Dim list As TTList<TRegisterFolder> = TRegisterFormConfig.SortFolders(pFolders)
         Dim i As Integer
         Dim n As Integer = list.Length - 1
         For i = 0 To n
            Dim folder As TRegisterFolder = list.Take(i)
            If folder.Visible Then
               Dim fields As TTList<TRegisterField> = TRegisterFormConfig.SortFields(folder.Fields)
               me._appendFieldList(pDest, fields)
               If Assigned(fields) Then
                  fields.OwnsObjects = False
                  fields.Free()
               End If
               me._appendFolderFields(pDest, folder.Folders)
            End If
         Next
         If Assigned(list) Then
            list.OwnsObjects = False
            list.Free()
         End If
      End Sub

      Private Function _resolveParentId(pId As String) As String
         Dim existing As TRegisterFolder = me._closestPrefixFolder(me.Folders, Trim(pId))
         If Assigned(existing) Then
            _resolveParentId = existing.Id
         Else
            _resolveParentId = TRegisterFormConfig.ParentFolderId(pId)
         End If
      End Function

      Private Function _closestPrefixFolder(pFolders As TTList<TRegisterFolder>, pChildEst As String) As TRegisterFolder
         Dim best As TRegisterFolder = Null
         Dim bestLen As Integer = 0
         If (Not Assigned(pFolders)) Or (Trim(pChildEst) = "") Then
            _closestPrefixFolder = Null
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pFolders.Length - 1
         For i = 0 To n
            Dim item As TRegisterFolder = pFolders.Take(i)
            Dim key As String = TRegisterFormConfig.FolderSortKey(item)
            If TRegisterFormConfig.IsEstruturaPrefix(key, pChildEst) Then
               Dim keyLen As Integer = Len(key)
               If (Not Assigned(best)) Or (keyLen > bestLen) Then
                  best = item
                  bestLen = keyLen
               End If
            End If
            Dim nested As TRegisterFolder = me._closestPrefixFolder(item.Folders, pChildEst)
            If Assigned(nested) Then
               Dim nestedLen As Integer = Len(TRegisterFormConfig.FolderSortKey(nested))
               If (Not Assigned(best)) Or (nestedLen > bestLen) Then
                  best = nested
                  bestLen = nestedLen
               End If
            End If
         Next
         _closestPrefixFolder = best
      End Function

      Private Function _findFolder(pFolders As TTList<TRegisterFolder>, pId As String) As TRegisterFolder
         If (Not Assigned(pFolders)) Or (pId = "") Then
            _findFolder = Null
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pFolders.Length - 1
         For i = 0 To n
            Dim item As TRegisterFolder = pFolders.Take(i)
            If item.Id = pId Then
               _findFolder = item
               Exit Function
            End If
            Dim nested As TRegisterFolder = me._findFolder(item.Folders, pId)
            If Assigned(nested) Then
               _findFolder = nested
               Exit Function
            End If
         Next
         _findFolder = Null
      End Function

      Private Sub _detachField(pField As TRegisterField)
         me._removeFromList(me.HeaderFields, pField)
         me._detachFromFolders(me.Folders, pField)
      End Sub

      Private Sub _detachFromFolders(pFolders As TTList<TRegisterFolder>, pField As TRegisterField)
         Dim i As Integer
         Dim n As Integer = pFolders.Length - 1
         For i = 0 To n
            Dim folder As TRegisterFolder = pFolders.Take(i)
            me._removeFromList(folder.Fields, pField)
            me._detachFromFolders(folder.Folders, pField)
         Next
      End Sub

      Private Sub _removeFromList(pList As TTList<TRegisterField>, pField As TRegisterField)
         Dim i As Integer
         Dim n As Integer = pList.Length - 1
         For i = 0 To n
            If pList.Take(i) = pField Then
               Dim cut As TTList<TRegisterField> = pList.Splice(i, 1)
               If Assigned(cut) Then
                  cut.OwnsObjects = False
                  cut.Free()
               End If
               Exit Sub
            End If
         Next
      End Sub

      Sub Free()
         If Assigned(me.HeaderFields) Then
            me.HeaderFields.OwnsObjects = False
            me.HeaderFields.Free()
            me.HeaderFields = Null
         End If
         If Assigned(me.Folders) Then
            me.Folders.Free()
            me.Folders = Null
         End If
         If Assigned(me.Fields) Then
            me.Fields.Free()
            me.Fields = Null
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
