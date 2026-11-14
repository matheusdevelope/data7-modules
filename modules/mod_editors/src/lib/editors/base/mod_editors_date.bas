Imports Forms
Imports mod_editors
Imports mod_editors_datetime

Namespace mod_editors_date

   Class TDateEditor
      Inherits TDateTimeEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Protected Overrides Function KeepTime() As Boolean
         KeepTime = False
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
