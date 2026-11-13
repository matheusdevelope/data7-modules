' data7:disable qualified-private-shared-access
Imports mod_tlist
Imports mod_editors
Imports mod_editors_text
Imports mod_editors_integer
Imports mod_editors_number
Imports mod_editors_value
Imports mod_editors_date
Imports mod_editors_combo
Imports mod_editors_search
Imports mod_editors_memo
Imports mod_editors_check
Imports mod_editors_mask
Imports mod_editors_password
Imports mod_editors_image
Imports mod_editors_button
Imports mod_editors_cep
Imports mod_editors_cpf
Imports mod_editors_cnpj
Imports mod_editors_cpf_cnpj
Imports mod_editors_email
Imports mod_editors_site
Imports mod_editors_ie
Imports mod_editors_placa
Imports mod_editors_gtin
Imports mod_editors_cnh
Imports mod_editors_renavam
Imports mod_editors_suframa
Imports mod_register_config
Imports mod_editors_time

Namespace mod_register_factory

   Class TRegisterKindBinder
      Key As String
      Factory As TRegisterEditorCreate

      Sub New(pKey As String, pCreate As TRegisterEditorCreate)
         MyBase.New()
         me.Key = UCase(Trim(pKey))
         me.Factory = pCreate
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Private Dim _binders[] As TRegisterKindBinder
   Private Dim _ready As Boolean

   Class TRegisterFactory

      Shared Sub RegisterKind(pKind As String, pCreate As TRegisterEditorCreate)
         TRegisterFactory._ensure()
         Dim key As String = UCase(Trim(pKind))
         Dim i As Integer
         Dim n As Integer = _binders.Length - 1
         For i = 0 To n
            Dim item As TRegisterKindBinder = _binders.Take(i)
            If item.Key = key Then
               item.Factory = pCreate
               Exit Sub
            End If
         Next
         _binders.Push(New TRegisterKindBinder(key, pCreate))
      End Sub

      Shared Function CreateEditor(pParent As Forms.TWinControl, pField As TRegisterField) As TLabeledEditorBase
         If pField.Factory <> Null Then
            CreateEditor = pField.Factory(pParent, pField)
            Exit Function
         End If
         Dim custom As TLabeledEditorBase = TRegisterFactory._createCustom(pParent, pField)
         If Assigned(custom) Then
            CreateEditor = custom
            Exit Function
         End If
         CreateEditor = TRegisterFactory.CreateDefault(pParent, pField)
      End Function

      Shared Function CreateDefault(pParent As Forms.TWinControl, pField As TRegisterField) As TLabeledEditorBase
         Dim props As TEditorProps = pField.ToProps()
         Dim key As String = UCase(pField.KindKey())
         Dim _editor As TLabeledEditorBase
         Select Case key
            Case "INTEGER", "INT", "INTEIRO"
               _editor = New TIntegerEditor(pParent, pField.Caption, props)
            Case "NUMBER", "NUM", "DECIMAL", "FLOAT"
               _editor = New TNumberEditor(pParent, pField.Caption, props)
            Case "VALUE", "VALOR"
               _editor = New TValueEditor(pParent, pField.Caption, props)
            Case "DATE", "DATA"
               _editor = New TDateEditor(pParent, pField.Caption, props)
            Case "TIME", "HORA"
               _editor = New TTimeEditor(pParent, pField.Caption, props)
            Case "DATETIME", "DATAHORA"
               _editor = New TDateEditor(pParent, pField.Caption, props)
            Case "COMBO", "LISTA", "COMBOBOX"
               _editor = New TComboEditor(pParent, pField.Caption, props)
            Case "SEARCH", "LOOKUP", "PESQUISA"
               _editor = New TSearchEditor(pParent, pField.Caption, props)
            Case "MEMO", "TEXTO"
               _editor = New TMemoEditor(pParent, pField.Caption, props)
            Case "CHECK", "BOOLEAN", "LOGICO"
               _editor = New TCheckEditor(pParent, pField.Caption, props)
            Case "MASK", "MASCARA"
               _editor = New TMaskEditor(pParent, pField.Caption, props)
            Case "PASSWORD", "SENHA"
               _editor = New TPasswordEditor(pParent, pField.Caption, props)
            Case "IMAGE", "IMAGEM", "FOTO"
               _editor = New TImageEditor(pParent, pField.Caption, props)
            Case "BUTTON", "BOTAO"
               _editor = New TButtonEditor(pParent, pField.Caption, props)
            Case "CEP"
               _editor = New TCEPEditor(pParent, pField.Caption, props)
            Case "CPF"
               _editor = New TCPFEditor(pParent, pField.Caption, props)
            Case "CNPJ"
               _editor = New TCNPJEditor(pParent, pField.Caption, props)
            Case "CPFCNPJ", "CPF_CNPJ", "CPF-CNPJ"
               _editor = New TCPFCnpjEditor(pParent, pField.Caption, props)
            Case "EMAIL"
               _editor = New TEmailEditor(pParent, pField.Caption, props)
            Case "SITE", "URL"
               _editor = New TSiteEditor(pParent, pField.Caption, props)
            Case "IE", "INSCRICAO"
               _editor = New TIEEditor(pParent, pField.Caption, props)
            Case "PLACA"
               _editor = New TPlacaEditor(pParent, pField.Caption, props)
            Case "GTIN", "EAN"
               _editor = New TGTINEditor(pParent, pField.Caption, props)
            Case "CNH"
               _editor = New TCNHEditor(pParent, pField.Caption, props)
            Case "RENAVAM"
               _editor = New TRenavamEditor(pParent, pField.Caption, props)
            Case "SUFRAMA"
               _editor = New TSuframaEditor(pParent, pField.Caption, props)
            Case Else
               _editor = New TTextEditor(pParent, pField.Caption, props)
         End Select
         If Assigned(props) Then
            props.Free()
         End If
         CreateDefault = _editor
      End Function



      Private Shared Sub _ensure()
         If Not _ready Then
            _binders = []
            _binders.OwnsObjects = True
            _ready = True
         End If
      End Sub

      Private Shared Function _createCustom(pParent As Forms.TWinControl, pField As TRegisterField) As TLabeledEditorBase
         TRegisterFactory._ensure()
         Dim key As String = UCase(pField.KindKey())
         Dim i As Integer
         Dim n As Integer = _binders.Length - 1
         For i = 0 To n
            Dim item As TRegisterKindBinder = _binders.Take(i)
            If item.Key = key Then
               If item.Factory <> Null Then
                  _createCustom = item.Factory(pParent, pField)
                  Exit Function
               End If
            End If
         Next
         _createCustom = Null
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
