Imports mod_tobject
Imports mod_wa_contracts
Imports mod_wa_capabilities
Imports mod_wa_validators

Namespace mod_wa_service

   ' Base dos recursos semânticos (Send / Instance / User).
   ' Compartilha acesso ao client, validator e guardas de Capability.
   MustInherit Class WaResource
      Inherits TTObject

      Protected _service As WaService

      Sub New(pService As WaService)
         MyBase.New()
         If pService = NULL Then
            Throw New Exception("WaResource requer WaService")
         End If
         me._service = pService
      End Sub

      Protected Function Client() As WaClient
         Client = me._service.Client()
      End Function

      Protected Function Caps() As WaCapabilities
         Caps = me._service.Capabilities()
      End Function

      Protected Function Validator() As WaMessageValidator
         Validator = me._service.Validator()
      End Function

      Protected Sub EnsureCapability(pAllowed As Boolean, pFeature As String)
         me._service.EnsureCapability(pAllowed, pFeature)
      End Sub

      Protected Sub EnsureReady()
         me._service.EnsureNotDeprecated()
      End Sub

      Overrides Sub Dispose()
         me._service = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
