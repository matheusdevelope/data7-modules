Imports Forms
Imports Collections
Imports mod_editors

Namespace mod_editors_combo

   Class TComboEditor
      Inherits TLabeledEditor<HComboBox>

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Property ListaOpcoes As String
         Get
            ListaOpcoes = me.Control.ListaOpcoes
         End Get
         Set(pValue As String)
            me._setListaOpcoes(pValue)
         End Set
      End Property

      Private Sub _setListaOpcoes(pValue As String)
         me.Control.ListaOpcoes = pValue
      End Sub

      Property ValueList As TStringList
         Get
            ValueList = me.Control.ValueList
         End Get
         Set(pValue As TStringList)
            me._setValueList(pValue)
         End Set
      End Property

      Private Sub _setValueList(pValue As TStringList)
         me.Control.ValueList.Text = pValue.Text
      End Sub

      Property ValueSelect As String
         Get
            ValueSelect = me.Control.ValueSelect
         End Get
         Set(pValue As String)
            me._setValueSelect(pValue)
         End Set
      End Property

      Private Sub _setValueSelect(pValue As String)
         me.Control.ValueSelect = pValue
      End Sub

      Property SelectedItem As Integer
         Get
            SelectedItem = me.Control.SelectedItem
         End Get
         Set(pValue As Integer)
            me._setSelectedItem(pValue)
         End Set
      End Property

      Private Sub _setSelectedItem(pValue As Integer)
         me.Control.SelectedItem = pValue
      End Sub

      Property ItemIndex As Integer
         Get
            ItemIndex = me.Control.ItemIndex
         End Get
         Set(pValue As Integer)
            me._setItemIndex(pValue)
         End Set
      End Property

      Private Sub _setItemIndex(pValue As Integer)
         me.Control.ItemIndex = pValue
      End Sub

      Property Items As TStrings
         Get
            Items = me.Control.Items
         End Get
         Set(pValue As TStrings)
            me._setItems(pValue)
         End Set
      End Property

      Private Sub _setItems(pValue As TStrings)
         me.Control.Items = pValue
      End Sub

      Property NameSelect As String
         Get
            If me.Control.Items <> NULL Then
               If me.Control.Items.Count > 0 And me.Control.SelectedItem >= 0 And me.Control.SelectedItem < me.Control.Items.Count Then
                  NameSelect = me.Control.Items.Strings(me.Control.SelectedItem)
               End If
            End If
         End Get
      End Property

      Protected Overrides Function GetText() As String
         GetText = me.Control.ValueSelect
      End Function

      Protected Overrides Sub SetText(pValue As String)
         me.Control.ValueSelect = pValue
      End Sub

      Protected Overrides Sub OnApply(pProps As TEditorProps)
         If pProps.ListaOpcoes <> "" Then
            me.ListaOpcoes = pProps.ListaOpcoes
         End If
      End Sub

      Overrides Sub SetFocus()
         me.Control.SetFocus()
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
