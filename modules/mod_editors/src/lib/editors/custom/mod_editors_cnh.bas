Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_cnh

   Class TCNHEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.Mascara = "99999999999"
         me.MaxLength = 11
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TDocs.IsValidCNH(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "CNH inválida. Informe 11 dígitos com dígitos verificadores corretos."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
