Imports Forms
Imports mod_editors

Namespace mod_editors_mask

   Class TMaskEditor
      Inherits TLabeledEditor<MaskTextBox>

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Property Mascara As String
         Get
            Mascara = me.Control.Mascara
         End Get
         Set(pValue As String)
            me._setMascara(pValue)
         End Set
      End Property

      Private Sub _setMascara(pValue As String)
         me.Control.Mascara = pValue
      End Sub

      Property Mask As String
         Get
            Mask = me.Mascara
         End Get
         Set(pValue As String)
            me._setMask(pValue)
         End Set
      End Property

      Private Sub _setMask(pValue As String)
         me.Mascara = pValue
      End Sub

      Protected Overrides Sub OnApply(pProps As TEditorProps)
         If pProps.Mask <> "" Then
            me.Mascara = pProps.Mask
         End If
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
