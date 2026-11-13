Imports Forms
Imports mod_tobject
Imports mod_editors
Imports mod_editors_search
Imports mod_pix_runtime
Imports mod_pix_app_adapters
Imports mod_pix_app_session

Namespace mod_pix_app_account

   Class PixAppAccountPanel
      Inherits TTObject

      Private _host As PageControl
      Private _search As TSearchEditor
      Private _session As PixAppSession
      Private _adapter As PixAppServiceAdapter
      Private _loading As Boolean

      Sub New(pParent As TWinControl, pSession As PixAppSession)
         MyBase.New()
         me._session = pSession
         me._adapter = New PixAppServiceAdapter()
         me._host = PixAppSurface.Page(pParent, alClient)
         me._search = New TSearchEditor(me._host, "Conta financeira")
         me._search.Required = True
         me._search.Align = alTop
         me._search.AlignWithMargins = True
         me._search.LabelPlacement = TLabelPlacement.Left()
         me._search.LabelWidth = 120
         me._search.Host.Margins.Left = 4
         me._search.Host.Margins.Right = 4
         me._search.Host.Margins.Top = 4
         me._search.Host.Margins.Bottom = 4
         me._search.CodPesquisa = Data7.PesquisaPadrao("MovContaFinanceira", "CodContaFinanceira")
         Dim _filtro As String = Trim(me._search.ExpressaoFiltro)
         If _filtro <> "" Then
            _filtro = _filtro & " AND CodParametroApi IS NOT NULL"
         Else
            _filtro = "CodParametroApi IS NOT NULL"
         End If
         me._search.ExpressaoFiltro = _filtro
         me._search.OnExit = me._onExit
         me._search.OnValidate = me._onValidate
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Function Codigo() As String
         Codigo = Trim(me._search.Text)
      End Function

      Sub SetCodigo(pCodigo As String)
         Dim codigo As String = Trim(pCodigo)
         If codigo = "" Then
            Exit Sub
         End If
         me._search.Text = codigo
         me._search.Validate()
         me._applyConta()
      End Sub

      Sub Focus()
         me._search.SetFocus()
      End Sub

      Private Sub _onExit(pSender As TObject)
         me._search.Validate()
         me._applyConta()
      End Sub

      Private Sub _onValidate(pSender As TObject)
         me._applyConta()
      End Sub

      Private Sub _applyConta()
         If me._loading Then
            Exit Sub
         End If
         me._loading = True
         Try
            Dim codigo As String = me.Codigo()
            If codigo = "" Then
               If me._session.Conta() <> "" Then
                  me._session.Unbind()
               End If
            ElseIf codigo <> me._session.Conta() Then
               Dim service As PixService = me._adapter.OpenConta(codigo)
               me._session.BindService(service, codigo, True)
            End If
         Catch ex As Exception
            me._session.Unbind()
            Forms.MessageBox.Show("Não foi possível abrir a conta financeira:" & CHAR(13) & ex._GetMessage())
         End Try
         me._loading = False
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._search) Then
            me._search.Free()
            me._search = Null
         End If
         If Assigned(me._adapter) Then
            me._adapter.Free()
            me._adapter = Null
         End If
         me._session = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
