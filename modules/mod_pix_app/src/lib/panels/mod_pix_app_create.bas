Imports Forms
Imports mod_tobject
Imports mod_editors
Imports mod_editors_text
Imports mod_editors_memo
Imports mod_editors_value
Imports mod_editors_integer
Imports mod_pix_cobranca
Imports mod_pix_config
Imports mod_pix_app_adapters
Imports mod_pix_app_session

Namespace mod_pix_app_create

   Class PixAppCreatePanel
      Inherits TTObject

      Private _session As PixAppSession
      Private _frame As PixAppGroup
      Private _host As PageControl
      Private _txid As TTextEditor
      Private _valor As TValueEditor
      Private _exp As TIntegerEditor
      Private _chave As TTextEditor
      Private _solic As TMemoEditor
      Private _nome As TTextEditor
      Private _cpf As TTextEditor
      Private _cnpj As TTextEditor
      Private _bar As PageControl
      Private _registrar As CommandButton

      OnRegistrar As TNotifyEvent

      Sub New(pParent As TWinControl, pSession As PixAppSession)
         MyBase.New()
         me._session = pSession
         me._frame = New PixAppGroup(pParent, "Dados da cobrança", alClient)
         me._host = me._frame.Host

         me._bar = PixAppSurface.Page(me._host, alBottom, 40)
         me._registrar = New CommandButton(me._bar)
         me._registrar.Align = alRight
         me._registrar.Width = 160
         me._registrar.Caption = "Registrar cobrança"
         me._registrar.OnClick = me._onRegistrar

         me._txid = me._text("TxId")
         me._valor = New TValueEditor(me._host, "Valor")
         me._layout(me._valor)
         me._valor.DecimalPlaces = 2
         me._valor.DisplayFormat = "0.00"
         me._exp = New TIntegerEditor(me._host, "Expiração (s)")
         me._layout(me._exp)
         me._exp.DecimalPlaces = 0
         me._exp.DisplayFormat = "0"
         me._chave = me._text("Chave PIX")
         me._solic = New TMemoEditor(me._host, "Solicitação")
         me._solic.Align = alTop
         me._solic.LabelPlacement = TLabelPlacement.Left()
         me._solic.LabelWidth = 110
         me._solic.EditorHeight = 48
         me._solic.WordWrap = True
         me._nome = me._text("Devedor")
         me._cpf = me._text("CPF")
         me._cnpj = me._text("CNPJ")
         me.FillSample()
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Sub Sync()
         If Assigned(me._frame) Then
            me._frame.Sync()
         End If
      End Sub

      Sub ApplyChave()
         If Trim(me._chave.Text) <> "" Then
            Exit Sub
         End If
         If Not Assigned(me._session) Then
            Exit Sub
         End If
         Dim config As PixConfig = me._session.Config()
         If Assigned(config) Then
            me._chave.Text = config.ChavePix
         End If
      End Sub

      Sub FillSample()
         Dim factory As New PixAppSampleFactory()
         Dim cob As PixCobranca = factory.Cobranca()
         Dim config As PixConfig
         factory.Free()
         me._txid.Text = cob.TxId
         me._valor.AsDouble = cob.Valor.Original
         me._exp.AsInteger = cob.Calendario.Expiracao
         me._solic.Text = cob.SolicitacaoPagador
         me._nome.Text = cob.Devedor.Nome
         me._cpf.Text = cob.Devedor.CPF
         me._cnpj.Text = cob.Devedor.CNPJ
         me._chave.Text = ""
         If Assigned(me._session) Then
            config = me._session.Config()
            If Assigned(config) Then
               me._chave.Text = config.ChavePix
            End If
         End If
         cob.Free()
      End Sub

      Function ReadCobranca() As PixCobranca
         Dim cob As New PixCobranca()
         cob.TxId = Trim(me._txid.Text)
         cob.Chave = Trim(me._chave.Text)
         cob.Valor.Original = me._valor.AsDouble
         cob.Calendario.Expiracao = me._exp.AsInteger
         cob.SolicitacaoPagador = Trim(me._solic.Text)
         cob.Devedor.Nome = Trim(me._nome.Text)
         cob.Devedor.CPF = Trim(me._cpf.Text)
         cob.Devedor.CNPJ = Trim(me._cnpj.Text)
         ReadCobranca = cob
      End Function

      Private Function _text(pCaption As String) As TTextEditor
         Dim editor As New TTextEditor(me._host, pCaption)
         me._layout(editor)
         _text = editor
      End Function

      Private Sub _layout(pEditor As TLabeledEditorBase)
         pEditor.Align = alTop
         pEditor.LabelPlacement = TLabelPlacement.Left()
         pEditor.LabelWidth = 110
      End Sub

      Private Sub _onRegistrar(pSender As TObject)
         If me.OnRegistrar <> NULL Then
            me.OnRegistrar(me)
         End If
      End Sub

      Overrides Sub Dispose()
         me.OnRegistrar = Null
         If Assigned(me._txid) Then
            me._txid.Free()
         End If
         If Assigned(me._valor) Then
            me._valor.Free()
         End If
         If Assigned(me._exp) Then
            me._exp.Free()
         End If
         If Assigned(me._chave) Then
            me._chave.Free()
         End If
         If Assigned(me._solic) Then
            me._solic.Free()
         End If
         If Assigned(me._nome) Then
            me._nome.Free()
         End If
         If Assigned(me._cpf) Then
            me._cpf.Free()
         End If
         If Assigned(me._cnpj) Then
            me._cnpj.Free()
         End If
         If Assigned(me._frame) Then
            me._frame.Free()
         End If
         me._registrar = Null
         me._bar = Null
         me._session = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
