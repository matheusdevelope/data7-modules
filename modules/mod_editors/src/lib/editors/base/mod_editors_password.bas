Imports Forms
Imports mod_editors

Namespace mod_editors_password

   Class TPasswordEditor
      Inherits TLabeledEditor<PasswordTextBox>

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
