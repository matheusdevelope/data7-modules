Imports mod_pix_http
Imports mod_pix_config

Namespace mod_pix_http_itau

   Class PixHttpItau
      Inherits PixHttp

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub LoadToken_PreRequest(ByRef pRequest As PixHttpAuthRequest, ByRef pBody As String)
         pRequest.Headers.Clear()
         pRequest.Params.Clear()
         pRequest.ContentType = "application/x-www-form-urlencoded"
         pRequest.Accept = "application/json"
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
