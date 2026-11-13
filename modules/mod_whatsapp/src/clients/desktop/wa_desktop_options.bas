Imports mod_tobject

Namespace mod_wa_desktop_options

   Class WaDesktopOptions
      Inherits TTObject

      WindowTitle As String
      AutoSend As Boolean
      OpenWaitMs As Integer
      PasteWaitMs As Integer
      EnterWaitMs As Integer
      RestoreFocus As Boolean

      Sub New()
         MyBase.New()
         me.WindowTitle = "WhatsApp"
         me.AutoSend = True
         me.OpenWaitMs = 1500
         me.PasteWaitMs = 1500
         me.EnterWaitMs = 400
         me.RestoreFocus = True
      End Sub

      Sub Validate()
         If Trim(me.WindowTitle) = "" Then
            me.WindowTitle = "WhatsApp"
         End If
         If me.OpenWaitMs < 0 Then
            me.OpenWaitMs = 0
         End If
         If me.PasteWaitMs < 0 Then
            me.PasteWaitMs = 0
         End If
         If me.EnterWaitMs < 0 Then
            me.EnterWaitMs = 0
         End If
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("WaDesktopOptions")
            .Prop("WindowTitle", me.WindowTitle)
            .Prop("AutoSend", me.AutoSend)
            .Prop("OpenWaitMs", me.OpenWaitMs)
            .Prop("PasteWaitMs", me.PasteWaitMs)
            .Prop("EnterWaitMs", me.EnterWaitMs)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
