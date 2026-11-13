Imports Collections
Imports mod_tobject

Namespace mod_wa_auth

   ' Contrato de autenticação — cada provider implementa como prepara as requests.
   MustInherit Class WaAuth
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      ' Aplica credenciais no transporte (headers, tokens, etc.).
      MustOverride Overridable Sub Apply(ByRef pHeaders As StringList)
      End Sub

      Protected Sub UpsertHeader(ByRef pHeaders As StringList, pName As String, pValue As String)
         Dim _idx As Integer = pHeaders.IndexOfName(pName)
         If _idx >= 0 Then
            pHeaders.Delete(_idx)
         End If
         pHeaders.Add(pName + pHeaders.NameValueSeparator + pValue)
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaAuthNone
      Inherits WaAuth

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Apply(ByRef pHeaders As StringList)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   ' Evolution / APIs com apikey fixa.
   Class WaAuthApiKey
      Inherits WaAuth

      Private _headerName As String
      Private _apiKey As String

      Sub New(pApiKey As String, pHeaderName As String = "apikey")
         MyBase.New()
         me._apiKey = pApiKey
         me._headerName = pHeaderName
      End Sub

      Overrides Sub Apply(ByRef pHeaders As StringList)
         me.UpsertHeader(pHeaders, me._headerName, me._apiKey)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   ' Evolution GO: master para gestão, instance para envio.
   Class WaAuthDualToken
      Inherits WaAuth

      Private _headerName As String
      Private _masterToken As String
      Private _instanceToken As String
      Private _useInstance As Boolean

      Sub New(pMasterToken As String, pInstanceToken As String, pHeaderName As String = "apikey")
         MyBase.New()
         me._masterToken = pMasterToken
         me._instanceToken = pInstanceToken
         me._headerName = pHeaderName
         me._useInstance = False
      End Sub

      Shared Function FromCombinedToken(pToken As String, pHeaderName As String = "apikey") As WaAuthDualToken
         If Not pToken.Contains("@") Then
            Throw New Exception("Token Dual deve estar no formato master@instance")
         End If
         FromCombinedToken = New WaAuthDualToken(pToken.Split("@")[0], pToken.Split("@")[1], pHeaderName)
      End Function

      Sub UseMaster()
         me._useInstance = False
      End Sub

      Sub UseInstance()
         me._useInstance = True
      End Sub

      Overrides Sub Apply(ByRef pHeaders As StringList)
         If me._useInstance Then
            me.UpsertHeader(pHeaders, me._headerName, me._instanceToken)
         Else
            me.UpsertHeader(pHeaders, me._headerName, me._masterToken)
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
