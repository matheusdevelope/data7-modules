Imports Forms


Namespace mod_forms_chrome

   Class TFormsChrome

      Private _host As PageControl
      Private _header As PageControl
      Private _headerLine As Line
      Private _content As PageControl
      Private _footerLine As Line
      Private _footer As PageControl

      Sub New(pForm As Form)
         MyBase.New()
         me._host = me._panel(pForm, alClient, 0)
         me._header = me._panel(me._host, alTop, 40)
         me._headerLine = me._divider(me._host, alTop)
         me._footer = me._panel(me._host, alBottom, 20)
         me._footerLine = me._divider(me._host, alBottom)
         me._content = me._panel(me._host, alClient, 0)
         me.ShowContentOnly()
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Property Header As PageControl
         Get
            Header = me._header
         End Get
      End Property

      Property HeaderLine As Line
         Get
            HeaderLine = me._headerLine
         End Get
      End Property

      Property Content As PageControl
         Get
            Content = me._content
         End Get
      End Property

      Property FooterLine As Line
         Get
            FooterLine = me._footerLine
         End Get
      End Property

      Property Footer As PageControl
         Get
            Footer = me._footer
         End Get
      End Property

      Sub ShowContentOnly()
         me._setRegions(False, True, False)
      End Sub

      Sub ShowWorkspace()
         me._setRegions(True, True, True)
      End Sub

      Private Sub _setRegions(pHeader As Boolean, pContent As Boolean, pFooter As Boolean)
         me._header.Visible = pHeader
         me._headerLine.Visible = pHeader
         me._content.Visible = pContent
         me._footer.Visible = pFooter
         me._footerLine.Visible = pFooter
      End Sub

      Private Function _panel(pParent As TWinControl, pAlign As TAlign, pHeight As Integer) As PageControl
         Dim _page As Forms.PageControl = New Forms.PageControl(pParent)
         _page.Align = pAlign
         _page.ShowCardFrame = False
         _page.ShowShadow = False
         _page.TabStop = False
         If pHeight > 0 Then
            _page.Height = pHeight
         End If
         _panel = _page
      End Function

      Private Function _divider(pParent As TWinControl, pAlign As TAlign) As Line
         Dim _edge As Forms.Line = New Forms.Line(pParent)
         Dim _rgb As Integer = RGB(192, 192, 192)
         _edge.Align = pAlign
         _edge.Height = 2
         _edge.Pen.Color = _rgb
         _edge.Brush.Color = _rgb
         _divider = _edge
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
