Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_renavam

   Class TRenavamEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.Mascara = "99999999999"
         me.MaxLength = 11
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TDocs.IsValidRenavam(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "RENAVAM inválido. Informe 9 ou 11 dígitos com verificador módulo 11."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
