Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_email

   Class TEmailEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.CharCase = CharCaseFromCode("L")
         me.MaxLength = 1024
         me.TextHint = "nome@dominio.com; outro@dominio.com"
         me.EditorFont.Color = RGB(0, 0, 255)
         me.EditorFont.Underline = True
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TEmail.IsValid(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "E-mail inválido. Informe um ou mais endereços separados por ; no formato nome@dominio.com."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
