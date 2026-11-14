Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_editors_cnpj
Imports mod_validators

Namespace mod_editors_cpf_cnpj

   Class TCPFCnpjEditor
      Inherits TCNPJEditor

      Private _personType As String

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me._personType = ""
         me._applyCnpjMode(False)
      End Sub

      Property PersonType As String
         Get
            PersonType = me._personType
         End Get
         Set(pValue As String)
            me._setPersonType(pValue)
         End Set
      End Property

      Private Sub _setPersonType(pValue As String)
         Dim _kind As String = UCase(Trim(pValue))
         If _kind = "FISICA" Then
            _kind = "F"
         ElseIf _kind = "JURIDICA" Then
            _kind = "J"
         ElseIf Len(_kind) > 0 Then
            _kind = _kind.Left(1)
         End If
         If (_kind <> "F") And (_kind <> "J") Then
            _kind = ""
         End If
         me._personType = _kind
         If _kind = "J" Then
            me._applyCnpjMode(True)
         ElseIf _kind = "F" Then
            me._applyCnpjMode(False)
         Else
            me._applyCnpjMode(me._isCnpjValue(me.Text, False))
         End If
      End Sub

      Function DocumentError() As String
         DocumentError = me.CheckDocument()
      End Function

      Overrides Sub SetBoundText(pValue As String)
         If me._personType = "J" Then
            me._applyCnpjMode(True)
         ElseIf me._personType = "F" Then
            me._applyCnpjMode(False)
         Else
            me._applyCnpjMode(me._isCnpjValue(pValue, False))
         End If
         MyBase.SetBoundText(pValue)
      End Sub

      Protected Overrides Sub OnEditorKeyPress(ByRef pKey As Char)
         If me._personType = "F" Then
            me._applyCnpjMode(False)
            Exit Sub
         End If
         If me._personType = "J" Then
            me._applyCnpjMode(True)
            Exit Sub
         End If
         Dim code As Integer = CInt(Asc(pKey))
         Dim isDigit As Boolean
         Dim isLetter As Boolean
         isDigit = CBool((code >= 48) And (code <= 57))
         isLetter = CBool(((code >= 65) And (code <= 90)) Or ((code >= 97) And (code <= 122)))
         If Not (isDigit Or isLetter) Then
            Exit Sub
         End If
         me._applyCnpjMode(me._isCnpjValue(me.Text, isLetter) Or (Len(TText.OnlyAlphaNum(me.Text)) >= 11))
      End Sub

      Protected Overrides Sub OnEditorBeforeMask()
         If me._personType = "J" Then
            me._applyCnpjMode(True)
         ElseIf me._personType = "F" Then
            me._applyCnpjMode(False)
         Else
            me._applyCnpjMode(me._isCnpjValue(me.Text, False))
         End If
      End Sub

      Private Function _isCnpjValue(pValue As String, pLetter As Boolean) As Boolean
         If pLetter Then
            _isCnpjValue = True
            Exit Function
         End If
         Dim raw As String = TText.OnlyAlphaNum(pValue)
         Dim digits As String = TText.OnlyDigits(raw)
         _isCnpjValue = CBool((Len(raw) > 11) Or (Len(digits) <> Len(raw)))
      End Function

      Private Sub _applyCnpjMode(pCnpj As Boolean)
         If pCnpj Then
            me.Mascara = "CC.CCC.CCC/CCCC-99"
            me.MaxLength = 18
            me.ButtonVisible = True
         Else
            me.Mascara = "999.999.999-99"
            me.MaxLength = 14
            me.ButtonVisible = False
         End If
      End Sub

      Protected Overrides Function CheckDocument() As String
         Dim raw As String = Trim(me.Text)
         If raw = "" Then
            CheckDocument = ""
            Exit Function
         End If
         If me._personType = "F" Then
            If TDocs.IsValidCPF(raw) Then
               CheckDocument = ""
            Else
               CheckDocument = "Formato inválido. Pessoa física deve informar um CPF."
            End If
            Exit Function
         End If
         If me._personType = "J" Then
            If TDocs.IsValidCNPJ(raw) Then
               CheckDocument = ""
            Else
               CheckDocument = "Formato inválido. Pessoa jurídica deve informar um CNPJ."
            End If
            Exit Function
         End If
         If TDocs.IsValidCPFCnpj(raw) Then
            CheckDocument = ""
         Else
            CheckDocument = "CPF/CNPJ inválido. Use 11 dígitos (CPF) ou 14 caracteres (CNPJ, inclusive alfanumérico) com verificadores corretos."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
