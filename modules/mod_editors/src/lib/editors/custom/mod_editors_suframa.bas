Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_suframa

   Class TSuframaEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.Mascara = "99999999-9"
         me.MaxLength = 10
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TDocs.IsValidSuframa(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "Inscrição SUFRAMA inválida. Informe 9 dígitos com verificador módulo 11."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
