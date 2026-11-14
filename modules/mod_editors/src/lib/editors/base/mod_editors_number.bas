Imports Forms
Imports mod_editors

Namespace mod_editors_number

   Class TNumberEditor
      Inherits TLabeledEditor<NumberTextBox>

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Property AsDouble As Extended
         Get
            AsDouble = CDbl(me.Text)
         End Get
         Set(pValue As Extended)
            me._setAsDouble(pValue)
         End Set
      End Property

      Private Sub _setAsDouble(pValue As Extended)
         me.Text = CStr(pValue)
      End Sub

      Protected Overrides Sub SetText(pValue As String)
         ' data7:disable-next-line unknown-member
         me.Control.Value = CDbl(pValue)
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
