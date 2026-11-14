Imports Forms
Imports mod_editors
Imports mod_editors_value

Namespace mod_editors_integer

   Class TIntegerEditor
      Inherits TValueEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
         me.DecimalPlaces = 0
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
