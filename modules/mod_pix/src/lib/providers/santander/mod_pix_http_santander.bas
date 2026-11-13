Imports mod_pix_http
Imports mod_pix_config

Namespace mod_pix_http_santander

   Class PixHttpSantander
      Inherits PixHttp

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub LoadToken_PreRequest(ByRef pRequest As PixHttpAuthRequest, ByRef pBody As String)
         pRequest.Params.Clear()
         pRequest.Params.Define("grant_type", "client_credentials")
      End Sub

      Overrides Sub LoadToken_PostRequest(ByRef pToken As PixAccessToken)
         pToken.Type = "Bearer"
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
