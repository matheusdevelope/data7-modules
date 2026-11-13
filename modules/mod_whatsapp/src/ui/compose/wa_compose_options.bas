Imports mod_tobject
Imports mod_wa_message
Imports mod_wa_contact
Imports mod_wa_compose_client
Imports mod_wa_instance

Namespace mod_wa_compose_options

   Delegate Sub WaCanDelegate(ByRef pCan As Boolean)
   Delegate Sub WaChangeDelegate(pPropChanged As String, pOptions As WaComposeOptions)
   Delegate Sub WaBeforeSendDelegate(pMessage As WaMessage, ByRef pSend As Boolean, ByRef pClose As Boolean)
   Delegate Sub WaIndexDelegate(pIndex As Integer)
   Delegate Sub WaInstancesDelegate(ByRef pInstances As WaInstanceList)

   Class WaComposeOptions
      Inherits TTObject

      Private _title As String = "Envio WhatsApp"
      Private _defaultDDD As String = "66"
      Private _countryCode As String = "55"
      Private _closeAfterSend As Boolean = True
      Private _canChangeRecipient As Boolean = True
      Private _canChangeSender As Boolean = True
      Private _canChangeClient As Boolean
      Private _requiresSender As Boolean
      Private _clientName As String
      Private _clientFeatures As String
      Private _defaultClient As String
      Private _senderNameFilter As String
      Private _messageOnExit As String
      Private _message As WaMessage
      Private _senders As WaContactList
      Private _recipients As WaContactList
      Private _clients As WaComposeClientList
      Private _formatter As WaMessageFormatter
      Private _ownsFormatter As Boolean

      OnChange As WaChangeDelegate
      OnFilterInstances As WaInstancesDelegate
      Notify As Boolean = True

      Sub New()
         MyBase.New()
         me._message = New WaMessage()
         me._senders = New WaContactList()
         me._recipients = New WaContactList()
         me._clients = New WaComposeClientList()
      End Sub

      Property Title As String
         Get
            Title = me._title
         End Get
         Set(pValue As String)
            me._title = pValue
            me.DispatchChanges("Title")
         End Set
      End Property

      Property DefaultDDD As String
         Get
            DefaultDDD = me._defaultDDD
         End Get
         Set(pValue As String)
            me._defaultDDD = pValue
            me.DispatchChanges("DefaultDDD")
         End Set
      End Property

      Property CountryCode As String
         Get
            CountryCode = me._countryCode
         End Get
         Set(pValue As String)
            me._countryCode = pValue
            me.DispatchChanges("CountryCode")
         End Set
      End Property

      Property CloseAfterSend As Boolean
         Get
            CloseAfterSend = me._closeAfterSend
         End Get
         Set(pValue As Boolean)
            me._closeAfterSend = pValue
            me.DispatchChanges("CloseAfterSend")
         End Set
      End Property

      Property CanChangeRecipient As Boolean
         Get
            CanChangeRecipient = me._canChangeRecipient
         End Get
         Set(pValue As Boolean)
            me._canChangeRecipient = pValue
            me.DispatchChanges("CanChangeRecipient")
         End Set
      End Property

      Property CanChangeSender As Boolean
         Get
            CanChangeSender = me._canChangeSender
         End Get
         Set(pValue As Boolean)
            me._canChangeSender = pValue
            me.DispatchChanges("CanChangeSender")
         End Set
      End Property

      Property CanChangeClient As Boolean
         Get
            CanChangeClient = me._canChangeClient
         End Get
         Set(pValue As Boolean)
            me._canChangeClient = pValue
            me.DispatchChanges("CanChangeClient")
         End Set
      End Property

      Property RequiresSender As Boolean
         Get
            RequiresSender = me._requiresSender
         End Get
         Set(pValue As Boolean)
            me._requiresSender = pValue
            me.DispatchChanges("RequiresSender")
         End Set
      End Property

      Property ClientName As String
         Get
            ClientName = me._clientName
         End Get
         Set(pValue As String)
            me._clientName = pValue
            me.DispatchChanges("ClientName")
         End Set
      End Property

      Property ClientFeatures As String
         Get
            ClientFeatures = me._clientFeatures
         End Get
         Set(pValue As String)
            me._clientFeatures = pValue
            me.DispatchChanges("ClientFeatures")
         End Set
      End Property

      Property DefaultClient As String
         Get
            DefaultClient = me._defaultClient
         End Get
         Set(pValue As String)
            me._defaultClient = pValue
            me.DispatchChanges("DefaultClient")
         End Set
      End Property

      Property SenderNameFilter As String
         Get
            SenderNameFilter = me._senderNameFilter
         End Get
         Set(pValue As String)
            me._senderNameFilter = pValue
            me.DispatchChanges("SenderNameFilter")
         End Set
      End Property

      Property MessageOnExit As String
         Get
            MessageOnExit = me._messageOnExit
         End Get
         Set(pValue As String)
            me._messageOnExit = pValue
            me.DispatchChanges("MessageOnExit")
         End Set
      End Property

      Property Message As WaMessage
         Get
            Message = me._message
         End Get
         Set(pValue As WaMessage)
            If Assigned(me._message) And me._message <> pValue Then
               me._message.Free()
            End If
            me._message = pValue
            me.DispatchChanges("Message")
         End Set
      End Property

      Property Senders As WaContactList
         Get
            Senders = me._senders
         End Get
         Set(pValue As WaContactList)
            If Assigned(me._senders) And me._senders <> pValue Then
               me._senders.Free()
            End If
            me._senders = pValue
            me.DispatchChanges("Senders")
         End Set
      End Property

      Property Recipients As WaContactList
         Get
            Recipients = me._recipients
         End Get
         Set(pValue As WaContactList)
            If Assigned(me._recipients) And me._recipients <> pValue Then
               me._recipients.Free()
            End If
            me._recipients = pValue
            me.DispatchChanges("Recipients")
         End Set
      End Property

      Property Clients As WaComposeClientList
         Get
            Clients = me._clients
         End Get
         Set(pValue As WaComposeClientList)
            If Assigned(me._clients) And me._clients <> pValue Then
               me._clients.Free()
            End If
            me._clients = pValue
            me.DispatchChanges("Clients")
         End Set
      End Property

      Property Formatter As WaMessageFormatter
         Get
            Formatter = me._formatter
         End Get
         Set(pValue As WaMessageFormatter)
            If me._ownsFormatter And Assigned(me._formatter) And me._formatter <> pValue Then
               me._formatter.Free()
            End If
            me._formatter = pValue
            me._ownsFormatter = False
            me.DispatchChanges("Formatter")
         End Set
      End Property

      Property Layout As WaMessageLayout
         Get
            me.EnsureFormatter()
            Layout = me._formatter.Layout
         End Get
         Set(pValue As WaMessageLayout)
            me._setLayout(pValue)
            me.DispatchChanges("Layout")
         End Set
      End Property

      Private Sub _setLayout(pValue As WaMessageLayout)
         me.EnsureFormatter()
         me._formatter.Layout = pValue
      End Sub

      Property OnFormatText As WaFormatTextDelegate
         Get
            If Assigned(me._formatter) Then
               OnFormatText = me._formatter.OnFormatText
            Else
               OnFormatText = NULL
            End If
         End Get
         Set(pValue As WaFormatTextDelegate)
            me._setOnFormatText(pValue)
            me.DispatchChanges("OnFormatText")
         End Set
      End Property

      Private Sub _setOnFormatText(pValue As WaFormatTextDelegate)
         me.EnsureFormatter()
         me._formatter.OnFormatText = pValue
      End Sub

      Property OnBuildPlan As WaBuildPlanDelegate
         Get
            If Assigned(me._formatter) Then
               OnBuildPlan = me._formatter.OnBuildPlan
            Else
               OnBuildPlan = NULL
            End If
         End Get
         Set(pValue As WaBuildPlanDelegate)
            me._setOnBuildPlan(pValue)
            me.DispatchChanges("OnBuildPlan")
         End Set
      End Property

      Private Sub _setOnBuildPlan(pValue As WaBuildPlanDelegate)
         me.EnsureFormatter()
         me._formatter.OnBuildPlan = pValue
      End Sub

      Function EnsureFormatter() As WaMessageFormatter
         If me._formatter = NULL Then
            me._formatter = WaMessageFormatter.CreateDefault()
            me._ownsFormatter = True
         End If
         EnsureFormatter = me._formatter
      End Function

      Sub ApplyFormatterTo(pMessage As WaMessage)
         If Assigned(pMessage) And Assigned(me._formatter) Then
            pMessage.Formatter = me._formatter
         End If
      End Sub

      Function HasSenders() As Boolean
         HasSenders = Assigned(me._senders) And me._senders.Count() > 0
      End Function

      Function HasClients() As Boolean
         HasClients = Assigned(me._clients) And me._clients.Count() > 0
      End Function

      Function ShowSender() As Boolean
         ShowSender = me._requiresSender And me.HasSenders()
      End Function

      Function ShowClient() As Boolean
         ShowClient = me._canChangeClient And me.HasClients()
      End Function

      Private Sub DispatchChanges(pPropChanged As String)
         If me.Notify And me.OnChange <> NULL Then
            me.OnChange(pPropChanged, me)
         End If
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("WaComposeOptions")
            .Prop("Title", me._title)
            .Prop("ClientName", me._clientName)
            .Prop("DefaultDDD", me._defaultDDD)
            .Prop("CountryCode", me._countryCode)
            .Prop("SenderNameFilter", me._senderNameFilter)
            .Prop("CloseAfterSend", me._closeAfterSend)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me._message) Then
            me._message.Formatter = NULL
            me._message.Free()
            me._message = NULL
         End If
         If Assigned(me._senders) Then
            me._senders.Free()
            me._senders = NULL
         End If
         If Assigned(me._recipients) Then
            me._recipients.Free()
            me._recipients = NULL
         End If
         If Assigned(me._clients) Then
            me._clients.Free()
            me._clients = NULL
         End If
         If me._ownsFormatter And Assigned(me._formatter) Then
            me._formatter.Free()
         End If
         me._formatter = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
