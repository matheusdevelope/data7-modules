Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_placa

   Class TPlacaEditor
      Inherits TDocEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.CharCase = CharCaseFromCode("U")
         me.MaxLength = 8
         me.Mascara = "AAA-CCCC"
         me.TextHint = "ABC-1234 ou ABC-1D23"
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TDocs.IsValidPlaca(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "Placa inválida. Use o padrão antigo (ABC-1234) ou Mercosul (ABC1D23)."
         End If
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
