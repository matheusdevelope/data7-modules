Imports Forms
Imports mod_editors

Namespace mod_editors_search

   Class TSearchEditor
      Inherits TLabeledEditor<SearchTextBox>

      Private _descricao As MemoTextBox
      PesquisaIncremental As Boolean
      TipoPesquisa As String

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
         me.Control.Width = 58
      End Sub

      Property CodPesquisa As Integer
         Get
            CodPesquisa = me.Control.CodPesquisa
         End Get
         Set(pValue As Integer)
            me._setCodPesquisa(pValue)
         End Set
      End Property

      Private Sub _setCodPesquisa(pValue As Integer)
         me.Control.CodPesquisa = pValue
      End Sub

      Property ExpressaoFiltro As String
         Get
            ExpressaoFiltro = me.Control.ExpressaoFiltro
         End Get
         Set(pValue As String)
            me._setExpressaoFiltro(pValue)
         End Set
      End Property

      Private Sub _setExpressaoFiltro(pValue As String)
         me.Control.ExpressaoFiltro = pValue
      End Sub

      Property Descricao As String
         Get
            Descricao = me._descricao.Lines.Text
         End Get
         Set(pValue As String)
            me._setDescricao(pValue)
         End Set
      End Property

      Private Sub _setDescricao(pValue As String)
         me._descricao.Lines.Text = pValue
      End Sub

      Property AsInteger As Integer
         Get
            AsInteger = me.Control.AsInteger
         End Get
         Set(pValue As Integer)
            me._setAsInteger(pValue)
         End Set
      End Property

      Private Sub _setAsInteger(pValue As Integer)
         me.Control.AsInteger = pValue
      End Sub

      Property EditorDescricao As MemoTextBox
         Get
            EditorDescricao = me._descricao
         End Get
      End Property

      Protected Overrides Sub CreateControl()
         me._control = New SearchTextBox(me._slot)
         me._control.Align = alLeft
         me._control.Width = 90
         me._descricao = New MemoTextBox(me._slot)
         me._descricao.Align = alClient
         me._descricao.ReadOnly = True
         me._descricao.TabStop = False
         me._control.EditorDescricao = me._descricao
      End Sub

      Protected Overrides Function GetText() As String
         GetText = me.Control.AsString
      End Function

      Protected Overrides Sub SetText(pValue As String)
         me.Control.AsString = pValue
      End Sub

      Protected Overrides Sub OnApply(pProps As TEditorProps)
         If pProps.CodPesquisa > 0 Then
            me.CodPesquisa = pProps.CodPesquisa
         End If
         If pProps.ExpressaoFiltro <> "" Then
            me.ExpressaoFiltro = pProps.ExpressaoFiltro
         End If
         me.PesquisaIncremental = pProps.PesquisaIncremental
         If pProps.TipoPesquisa <> "" Then
            me.TipoPesquisa = pProps.TipoPesquisa
         End If
      End Sub

      Overridable Function Validate() As Boolean
         ' data7:disable-next-line unknown-member
         me.Control.Valida()
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
