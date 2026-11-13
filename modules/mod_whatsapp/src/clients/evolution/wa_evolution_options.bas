Imports mod_tobject
Imports mod_wa_message

Namespace mod_wa_evolution_options

   Class WaEvolutionOptions
      Inherits TTObject

      Host As String
      Token As String
      Instance As String
      ValidatePhoneOnProvider As Boolean
      Formatter As WaMessageFormatter

      Sub New()
         MyBase.New()
         me.InitDefaults()
      End Sub

      Sub New(pHost As String, pToken As String, pInstance As String = "")
         MyBase.New()
         me.Host = pHost
         me.Token = pToken
         me.Instance = pInstance
         me.InitDefaults()
      End Sub

      Private Sub InitDefaults()
         me.ValidatePhoneOnProvider = True
         me.Formatter = WaMessageFormatter.CreateDefault()
      End Sub

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
            Throw New Exception("WaEvolutionOptions.Host é obrigatório")
         End If
         If me.Token.Trim() = "" Then
            Throw New Exception("WaEvolutionOptions.Token (apikey) é obrigatório")
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
