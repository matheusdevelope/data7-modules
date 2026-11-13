Imports Forms
Imports mod_tobject
Imports mod_editors
Imports mod_editors_date
Imports mod_editors_combo
Imports mod_editors_text
Imports mod_editors_integer
Imports mod_pix_filtro
Imports mod_pix_app_adapters
Imports mod_pix_app_session

Namespace mod_pix_app_filters

   Class PixAppFilterPanel
      Inherits TTObject

      Private _kind As String
      Private _pageIndex As Integer
      Private _frame As PixAppGroup
      Private _host As PageControl
      Private _row As PageControl
      Private _inicio As TDateEditor
      Private _fim As TDateEditor
      Private _status As TComboEditor
      Private _cpf As TTextEditor
      Private _cnpj As TTextEditor
      Private _lookup As TTextEditor
      Private _lookup2 As TTextEditor
      Private _itens As TIntegerEditor
      Private _session As PixAppSession
      Private _mapper As PixAppFilterMapper

      Sub New(pParent As TWinControl, pSession As PixAppSession, pKind As String)
         MyBase.New()
         me._session = pSession
         me._kind = LCase(Trim(pKind))
         me._pageIndex = 0
         me._mapper = New PixAppFilterMapper()
         me._frame = New PixAppGroup(pParent, "Filtros", alTop, 68)
         me._host = me._frame.Host
         me._row = PixAppSurface.Page(me._host, alClient)
         me._inicio = me._date(me._row, "Início", 128)
         me._fim = me._date(me._row, "Fim", 128)
         If me._kind = "cob" Then
            me._status = me._combo(me._row, "Status", 180, """Todos="";""Ativa=ATIVA"";""Concluída=CONCLUIDA"";""Removida pelo usuário=REMOVIDA_PELO_USUARIO_RECEBEDOR"";""Removida pelo PSP=REMOVIDA_PELO_PSP""")
            me._cpf = me._text(me._row, "CPF", 120)
            me._cnpj = me._text(me._row, "CNPJ", 140)
            me._lookup = me._text(me._row, "TxId", 200)
         ElseIf me._kind = "pix" Then
            me._cpf = me._text(me._row, "CPF", 120)
            me._cnpj = me._text(me._row, "CNPJ", 140)
            me._lookup = me._text(me._row, "E2E", 220)
         Else
            me._lookup = me._text(me._row, "E2E", 220)
            me._lookup2 = me._text(me._row, "Id", 140)
         End If
         me._itens = me._int(me._row, "Itens", 80)
         me.ResetDefaults()
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Function Kind() As String
         Kind = me._kind
      End Function

      Sub Sync()
         If Assigned(me._frame) Then
            me._frame.Sync()
         End If
      End Sub

      Function Filtro() As PixFiltro
         Dim status As String = ""
         Dim cpf As String = ""
         Dim cnpj As String = ""
         If Assigned(me._status) Then
            status = me._status.ValueSelect
         End If
         If Assigned(me._cpf) Then
            cpf = me._cpf.Text
         End If
         If Assigned(me._cnpj) Then
            cnpj = me._cnpj.Text
         End If
         Filtro = me._mapper.ToFiltro(me._inicio.AsDateTime, me._fim.AsDateTime, status, cpf, cnpj, me._pageIndex, me._itens.AsInteger)
      End Function

      Function PageIndex() As Integer
         PageIndex = me._pageIndex
      End Function

      Sub SetPageIndex(pValue As Integer)
         If pValue < 0 Then
            me._pageIndex = 0
         Else
            me._pageIndex = pValue
         End If
      End Sub

      Function Itens() As Integer
         Dim value As Integer = me._itens.AsInteger
         If value <= 0 Then
            Itens = 50
         Else
            Itens = value
         End If
      End Function

      Function LookupId() As String
         If Assigned(me._lookup) Then
            LookupId = Trim(me._lookup.Text)
         Else
            LookupId = ""
         End If
      End Function

      Sub SetLookupId(pValue As String)
         If Assigned(me._lookup) Then
            me._lookup.Text = Trim(pValue)
         End If
      End Sub

      Function LookupDevId() As String
         If Assigned(me._lookup2) Then
            LookupDevId = Trim(me._lookup2.Text)
         Else
            LookupDevId = ""
         End If
      End Function

      Function HasLookup() As Boolean
         HasLookup = me.LookupId() <> ""
      End Function

      Sub ResetDefaults()
         me._inicio.AsDateTime = DateTime().AddDays(-7)
         me._fim.AsDateTime = DateTime()
         If Assigned(me._status) Then
            me._status.ValueSelect = ""
         End If
         If Assigned(me._cpf) Then
            me._cpf.Text = ""
         End If
         If Assigned(me._cnpj) Then
            me._cnpj.Text = ""
         End If
         If Assigned(me._lookup) Then
            me._lookup.Text = ""
         End If
         If Assigned(me._lookup2) Then
            me._lookup2.Text = ""
         End If
         me._pageIndex = 0
         me._itens.AsInteger = 50
      End Sub

      Private Function _date(pParent As TWinControl, pCaption As String, pWidth As Integer) As TDateEditor
         Dim editor As New TDateEditor(pParent, pCaption)
         me._layout(editor, pWidth)
         _date = editor
      End Function

      Private Function _combo(pParent As TWinControl, pCaption As String, pWidth As Integer, pLista As String) As TComboEditor
         Dim editor As New TComboEditor(pParent, pCaption)
         me._layout(editor, pWidth)
         editor.ListaOpcoes = pLista
         _combo = editor
      End Function

      Private Function _text(pParent As TWinControl, pCaption As String, pWidth As Integer) As TTextEditor
         Dim editor As New TTextEditor(pParent, pCaption)
         me._layout(editor, pWidth)
         _text = editor
      End Function

      Private Function _int(pParent As TWinControl, pCaption As String, pWidth As Integer) As TIntegerEditor
         Dim editor As New TIntegerEditor(pParent, pCaption)
         me._layout(editor, pWidth)
         editor.DecimalPlaces = 0
         editor.DisplayFormat = "0"
         _int = editor
      End Function

      Private Sub _layout(pEditor As TLabeledEditorBase, pWidth As Integer)
         pEditor.Align = alLeft
         pEditor.Width = pWidth
         pEditor.LabelPlacement = TLabelPlacement.Top()
         pEditor.LabelWidth = pWidth - 8
         pEditor.AlignWithMargins = True
         pEditor.Host.Margins.Left = 4
         pEditor.Host.Margins.Right = 4
         pEditor.Host.Margins.Top = 2
         pEditor.Host.Margins.Bottom = 2
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._inicio) Then
            me._inicio.Free()
         End If
         If Assigned(me._fim) Then
            me._fim.Free()
         End If
         If Assigned(me._status) Then
            me._status.Free()
         End If
         If Assigned(me._cpf) Then
            me._cpf.Free()
         End If
         If Assigned(me._cnpj) Then
            me._cnpj.Free()
         End If
         If Assigned(me._lookup) Then
            me._lookup.Free()
         End If
         If Assigned(me._lookup2) Then
            me._lookup2.Free()
         End If
         If Assigned(me._itens) Then
            me._itens.Free()
         End If
         If Assigned(me._mapper) Then
            me._mapper.Free()
         End If
         If Assigned(me._frame) Then
            me._frame.Free()
         End If
         me._session = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
