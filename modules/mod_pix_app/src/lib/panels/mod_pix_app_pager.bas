Imports Forms
Imports mod_tobject
Imports mod_pix_app_adapters

Namespace mod_pix_app_pager

   Class PixAppPager
      Inherits TTObject

      Private _host As PageControl
      Private _prev As CommandButton
      Private _next As CommandButton
      Private _info As StaticText
      Private _pageIndex As Integer
      Private _byId As Boolean

      OnChange As TNotifyEvent

      Sub New(pParent As TWinControl)
         MyBase.New()
         me._host = PixAppSurface.Page(pParent, alBottom, 34)
         me._host.AlignWithMargins = True
         me._host.Margins.Left = 4
         me._host.Margins.Right = 4
         me._host.Margins.Top = 2
         me._host.Margins.Bottom = 4

         me._next = New CommandButton(me._host)
         me._next.Align = alRight
         me._next.Width = 100
         me._next.Caption = "Próxima"
         me._next.OnClick = me._onNext

         me._prev = New CommandButton(me._host)
         me._prev.Align = alLeft
         me._prev.Width = 100
         me._prev.Caption = "Anterior"
         me._prev.OnClick = me._onPrev

         me._info = PixAppSurface.Hint(me._host, "Página 1", alClient)
         me._info.Alignment = taCenter
         me.Bind(0, 1, 0, 0, 50, False)
      End Sub

      Property Host As PageControl
         Get
            Host = me._host
         End Get
      End Property

      Function PageIndex() As Integer
         PageIndex = me._pageIndex
      End Function

      Sub Bind(pPageIndex As Integer, pPageCount As Integer, pTotal As Integer, pReturned As Integer, pPageSize As Integer, pById As Boolean)
         Dim pages As Integer = PixAppFormat.PageCountOf(pPageCount, pTotal, pPageSize, pReturned)
         Dim index As Integer = pPageIndex
         If index < 0 Then
            index = 0
         End If
         me._pageIndex = index
         me._byId = pById
         me._info.Text = PixAppFormat.PagerText(index, pages, pTotal, pReturned, pById)
         me._prev.Enabled = (Not pById) And (index > 0)
         If pById Then
            me._next.Enabled = False
         ElseIf pages > 0 Then
            me._next.Enabled = (index + 1) < pages
         Else
            me._next.Enabled = (pReturned >= pPageSize) And (pPageSize > 0)
         End If
      End Sub

      Private Sub _onPrev(pSender As TObject)
         If me._byId Then
            Exit Sub
         End If
         If me._pageIndex <= 0 Then
            Exit Sub
         End If
         me._pageIndex = me._pageIndex - 1
         me._fire()
      End Sub

      Private Sub _onNext(pSender As TObject)
         If me._byId Then
            Exit Sub
         End If
         me._pageIndex = me._pageIndex + 1
         me._fire()
      End Sub

      Private Sub _fire()
         If me.OnChange <> NULL Then
            me.OnChange(me)
         End If
      End Sub

      Overrides Sub Dispose()
         me.OnChange = Null
         me._info = Null
         me._prev = Null
         me._next = Null
         me._host = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
