Imports mod_tobject
Imports mod_wa_message

Namespace mod_wa_evolution_go_options

   Class WaEvolutionGoOptions
      Inherits TTObject

      Host As String
      MasterToken As String
      InstanceToken As String
      Instance As String
      Filter As String
      ValidatePhoneOnProvider As Boolean
      Formatter As WaMessageFormatter

      Sub New()
         MyBase.New()
         me.InitDefaults()
      End Sub

      Sub New(pHost As String, pMasterToken As String, pInstanceToken As String, pInstance As String = "")
         MyBase.New()
         me.Host = pHost
         me.MasterToken = pMasterToken
         me.InstanceToken = pInstanceToken
         me.Instance = pInstance
         me.InitDefaults()
      End Sub

      Private Sub InitDefaults()
         me.ValidatePhoneOnProvider = True
         me.Formatter = WaMessageFormatter.CreateDefault()
      End Sub

      ' Atalho: token no formato master@instance
      Shared Function FromCombinedToken(pHost As String, pCombinedToken As String, pInstance As String = "") As WaEvolutionGoOptions
         If Not pCombinedToken.Contains("@") Then
            Throw New Exception("Token EvolutionGO deve estar no formato master@instance")
         End If
         FromCombinedToken = New WaEvolutionGoOptions(pHost, pCombinedToken.Split("@")[0], pCombinedToken.Split("@")[1], pInstance)
      End Function

      Property Layout As WaMessageLayout
         Get
            Layout = me.Formatter.Layout
         End Get
         Set(pValue As WaMessageLayout)
            me._setFormatterLayout(pValue)
         End Set
      End Property

      Private Sub _setFormatterLayout(pValue As WaMessageLayout)
         me.Formatter.Layout = pValue
      End Sub

      Property MessageWithLastAttachment As Boolean
         Get
            MessageWithLastAttachment = me.Formatter.Layout.IsCaptionLast()
         End Get
         Set(pValue As Boolean)
            If pValue Then
               me.Formatter.Layout.CaptionOnLast()
            Else
               me.Formatter.Layout.SeparateTextBefore()
            End If
         End Set
      End Property

      Property SendCaption As Boolean
         Get
            SendCaption = me.Formatter.Layout.SendCaption
         End Get
         Set(pValue As Boolean)
            me._setFormatterLayoutSendCaption(pValue)
         End Set
      End Property

      Private Sub _setFormatterLayoutSendCaption(pValue As Boolean)
         me.Formatter.Layout.SendCaption = pValue
      End Sub

      Sub Validate()
         If me.Host.Trim() = "" Then
            Throw New Exception("WaEvolutionGoOptions.Host é obrigatório")
         End If
         If me.MasterToken.Trim() = "" Or me.InstanceToken.Trim() = "" Then
            Throw New Exception("WaEvolutionGoOptions.MasterToken e InstanceToken são obrigatórios")
         End If
      End Sub

      Overrides Sub Dispose()
         If Assigned(me.Formatter) Then
            me.Formatter.Free()
            me.Formatter = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
