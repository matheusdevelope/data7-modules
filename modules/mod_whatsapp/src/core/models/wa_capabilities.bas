Imports mod_tobject

Namespace mod_wa_capabilities

   Class WaCapabilities
      Inherits TTObject

      CanSendText As Boolean
      CanSendMedia As Boolean
      CanSendButtons As Boolean
      CanSendPoll As Boolean
      CanSendList As Boolean
      CanSendLocation As Boolean
      CanSendContact As Boolean
      CanSendSticker As Boolean
      CanManageInstances As Boolean
      CanManageContacts As Boolean
      CanManageGroups As Boolean
      CanManageChats As Boolean
      CanManageMessages As Boolean
      CanValidatePhone As Boolean
      NeedsSender As Boolean
      IsDeprecated As Boolean

      Sub New()
         MyBase.New()
      End Sub

      Shared Function LimitedSend() As WaCapabilities
         Dim _caps As New WaCapabilities()
         _caps.CanSendText = True
         _caps.CanSendMedia = True
         LimitedSend = _caps
      End Function

      Shared Function FullApi() As WaCapabilities
         Dim _caps As New WaCapabilities()
         _caps.CanSendText = True
         _caps.CanSendMedia = True
         _caps.CanSendButtons = True
         _caps.CanSendPoll = True
         _caps.CanSendList = True
         _caps.CanSendLocation = True
         _caps.CanSendContact = True
         _caps.CanSendSticker = True
         _caps.CanManageInstances = True
         _caps.CanManageContacts = True
         _caps.CanManageGroups = True
         _caps.CanManageChats = True
         _caps.CanManageMessages = True
         _caps.CanValidatePhone = True
         FullApi = _caps
      End Function

      Shared Function Deprecated() As WaCapabilities
         Dim _caps As New WaCapabilities()
         _caps.IsDeprecated = True
         Deprecated = _caps
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaCapabilities")
            .Prop("CanSendText", me.CanSendText)
            .Prop("CanSendMedia", me.CanSendMedia)
            .Prop("CanSendButtons", me.CanSendButtons)
            .Prop("CanManageInstances", me.CanManageInstances)
            .Prop("CanManageContacts", me.CanManageContacts)
            .Prop("CanManageGroups", me.CanManageGroups)
            .Prop("CanManageChats", me.CanManageChats)
            .Prop("CanManageMessages", me.CanManageMessages)
            .Prop("CanValidatePhone", me.CanValidatePhone)
            .Prop("NeedsSender", me.NeedsSender)
            .Prop("IsDeprecated", me.IsDeprecated)
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
