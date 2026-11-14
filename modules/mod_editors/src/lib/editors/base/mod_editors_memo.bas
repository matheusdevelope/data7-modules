Imports Forms
Imports Collections
Imports mod_editors

Namespace mod_editors_memo

   Class TMemoEditor
      Inherits TLabeledEditor<MemoTextBox>

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Property Lines As TStrings
         Get
            Lines = me.Control.Lines
         End Get
      End Property

      Property WordWrap As Boolean
         Get
            WordWrap = me.Control.WordWrap
         End Get
         Set(pValue As Boolean)
            me._setWordWrap(pValue)
         End Set
      End Property

      Private Sub _setWordWrap(pValue As Boolean)
         me.Control.WordWrap = pValue
      End Sub

      Protected Overrides Sub OnBuilt()
         me.EditorHeight = 70
         me.Control.Align = alClient
      End Sub

      Protected Overrides Function GetText() As String
         GetText = me.Control.Lines.Text
      End Function

      Protected Overrides Sub SetText(pValue As String)
         me.Control.Lines.Text = pValue
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
