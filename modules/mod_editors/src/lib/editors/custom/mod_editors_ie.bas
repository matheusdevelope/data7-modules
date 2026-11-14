Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_ie

   Class TIEEditor
      Inherits TDocEditor

      Private _uf As String

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.CharCase = CharCaseFromCode("U")
         me.Mascara = "CCCCCCCCCCCCCC"
         me.MaxLength = 14
         me.TextHint = "Informe a UF antes de validar"
      End Sub

      Property UF As String
         Get
            UF = me._uf
         End Get
         Set(pValue As String)
            me._setUF(pValue)
         End Set
      End Property

      Private Sub _setUF(pValue As String)
         me._uf = UCase(Trim(pValue))
      End Sub

      Protected Overrides Function ValidateValue() As String
         If Trim(me._uf) = "" Then
            ValidateValue = "Informe a UF para validar a Inscrição Estadual."
            Exit Function
         End If
         If TDocs.IsValidIE(me.Text, me._uf) Then
            ValidateValue = ""
         Else
            ValidateValue = "Inscrição Estadual inválida para a UF " + me._uf + "."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
