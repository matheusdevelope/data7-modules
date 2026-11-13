Imports mod_pix_http
Imports mod_pix_config

Namespace mod_pix_http_sicredi

   Class PixHttpSicredi
      Inherits PixHttp

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub LoadToken_PreRequest(ByRef pRequest As PixHttpAuthRequest, ByRef pBody As String)
         pRequest.Params.Clear()
         pRequest.Params.Define("grant_type", "client_credentials")
         pRequest.Params.Define("client_id", me._config.Credentials.Id)
         pRequest.Params.Define("client_secret", me._config.Credentials.Secret)
         pRequest.Params.Define("scope", me._config.Psp.Scopes())
         pBody = ""
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
