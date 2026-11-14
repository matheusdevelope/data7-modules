Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_cpf

   Class TCPFEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.Mascara = "999.999.999-99"
         me.MaxLength = 14
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TDocs.IsValidCPF(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "CPF inválido. Informe 11 dígitos com dígitos verificadores corretos."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
