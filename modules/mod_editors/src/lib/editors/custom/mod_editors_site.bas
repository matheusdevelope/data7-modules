Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_site

   Class TSiteEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.CharCase = CharCaseFromCode("L")
         me.MaxLength = 2048
         me.TextHint = "https://www.exemplo.com.br"
         me.EditorFont.Color = RGB(0, 0, 255)
         me.EditorFont.Underline = True
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TUrl.IsValid(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "Site inválido. Informe um domínio válido, com ou sem http(s)://."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
