Imports mod_tobject
Imports mod_wa_contracts
Imports mod_wa_validators
Imports mod_wa_capabilities

Namespace mod_wa_service

   ' Facade raiz:
   '   wa.Send.* / wa.Instance.* / wa.User.* / wa.Message.* / wa.Chat.* / wa.Group.*
   Class WaService
      Inherits TTObject

      Private _client As WaClient
      Private _ownedClient As WaClient
      Private _validator As WaMessageValidator
      Private _ownsClient As Boolean
      Private _ownsValidator As Boolean

      Send As WaSendResource
      Instance As WaInstanceResource
      User As WaUserResource
      Message As WaMessageResource
      Chat As WaChatResource
      Group As WaGroupResource

      Sub New()
         MyBase.New()
         me._validator = New WaMessageValidator()
         me._ownsValidator = True
         me.BuildResources()
      End Sub

      Sub New(pClient As WaClient, pOwnsClient As Boolean = True)
         MyBase.New()
         If pClient = NULL Then
            Throw New Exception("WaService requer um WaClient injetado")
         End If
         me._client = pClient
         me._ownsClient = pOwnsClient
         If pOwnsClient Then
            me._ownedClient = pClient
         End If
         me._validator = New WaMessageValidator()
         me._ownsValidator = True
         me.BuildResources()
      End Sub

      Sub New(pClient As WaClient, pValidator As WaMessageValidator, pOwnsClient As Boolean = True, pOwnsValidator As Boolean = False)
         MyBase.New()
         If pClient = NULL Then
            Throw New Exception("WaService requer um WaClient injetado")
         End If
         If pValidator = NULL Then
            Throw New Exception("WaService requer um WaMessageValidator injetado")
         End If
         me._client = pClient
         me._validator = pValidator
         me._ownsClient = pOwnsClient
         If pOwnsClient Then
            me._ownedClient = pClient
         End If
         me._ownsValidator = pOwnsValidator
         me.BuildResources()
      End Sub

      Private Sub BuildResources()
         me.Send = New WaSendResource(me)
         me.Instance = New WaInstanceResource(me)
         me.User = New WaUserResource(me)
         me.Message = New WaMessageResource(me)
         me.Chat = New WaChatResource(me)
         me.Group = New WaGroupResource(me)
      End Sub

      Function HasClient() As Boolean
         HasClient = Assigned(me._client)
      End Function

      Function Client() As WaClient
         Client = me._client
      End Function

      Sub SetClient(pClient As WaClient)
         If pClient = NULL Then
            Throw New Exception("WaService requer um WaClient")
         End If
         me._client = pClient
      End Sub

      Function Validator() As WaMessageValidator
         Validator = me._validator
      End Function

      Function Capabilities() As WaCapabilities
         me.EnsureHasClient()
         Capabilities = me._client.GetCapabilities()
      End Function

      Sub EnsureNotDeprecated()
         me.EnsureHasClient()
         Dim _caps As WaCapabilities = me.Capabilities()
         If _caps.IsDeprecated Then
            Throw New Exception("O cliente [" + me._client.GetName() + "] está marcado como Deprecated e não pode ser utilizado. Use Evolution, EvolutionGO ou Desktop.")
         End If
      End Sub

      Sub EnsureCapability(pAllowed As Boolean, pFeature As String)
         me.EnsureNotDeprecated()
         If Not pAllowed Then
            Throw New Exception("O cliente [" + me._client.GetName() + "] não suporta o recurso: " + pFeature)
         End If
      End Sub

      Private Sub EnsureHasClient()
         If me._client = NULL Then
            Throw New Exception("WaService não tem um WaClient ativo. Defina um client com SetClient ou registre clients no WaCompose.")
         End If
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("WaService")
            If Assigned(me._client) Then
               .Prop("Client", me._client.GetName())
               .Prop("Capabilities", me.Capabilities())
            Else
               Dim _null As String = "NULL"
               .Prop("Client", _null)
            End If
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Send) Then
            me.Send.Free()
            me.Send = NULL
         End If
         If Assigned(me.Instance) Then
            me.Instance.Free()
            me.Instance = NULL
         End If
         If Assigned(me.User) Then
            me.User.Free()
            me.User = NULL
         End If
         If Assigned(me.Message) Then
            me.Message.Free()
            me.Message = NULL
         End If
         If Assigned(me.Chat) Then
            me.Chat.Free()
            me.Chat = NULL
         End If
         If Assigned(me.Group) Then
            me.Group.Free()
            me.Group = NULL
         End If
         If me._ownsValidator And Assigned(me._validator) Then
            me._validator.Free()
         End If
         me._validator = NULL
         If me._ownsClient And Assigned(me._ownedClient) Then
            me._ownedClient.Free()
         End If
         me._ownedClient = NULL
         me._client = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
