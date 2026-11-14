Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_gtin

   Class TGTINEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.Mascara = "99999999999999"
         me.MaxLength = 14
         me.TextHint = "8, 12, 13 ou 14 dígitos"
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TDocs.IsValidGTIN(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "GTIN inválido. Informe 8, 12, 13 ou 14 dígitos com verificador módulo 10."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
