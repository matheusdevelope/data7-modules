Imports mod_pix_bacen
Imports mod_pix_config
Imports mod_pix_http
Imports mod_pix_http_sicredi
Imports mod_pix_psp
Imports mod_pix_enums

Namespace mod_pix_sicredi

   Class PixPspSicredi
      Inherits PixPsp

      Sub New(pVersion As Integer = 2, pVersionAuth As Integer = 2)
         MyBase.New(PixBanco.Sicredi(), pVersion, pVersionAuth)
      End Sub

      Overrides Sub FillUrls()
         me.AuthUrls.Add("https://api-pix-h.sicredi.com.br/oauth/token")
         me.AuthUrls.Add("https://api-pix.sicredi.com.br/oauth/token")
         me.BaseUrls.Add("https://api-pix-h.sicredi.com.br/api/v" & CStr(me.Version))
         me.BaseUrls.Add("https://api-pix.sicredi.com.br/api/v" & CStr(me.Version))
      End Sub

      Overrides Function Clone() As PixPsp
         Clone = New PixPspSicredi(me._version, me._version_auth)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixClientSicredi
      Inherits PixClientBacen

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub ApplyProfile(pConfig As PixConfig)
         pConfig.TimeZoneHours = -4
         pConfig.Version = 2
         If Assigned(pConfig.Psp) Then
            pConfig.Psp.Free()
         End If
         pConfig.Psp = New PixPspSicredi(2, 2)
      End Sub

      Overrides Function GetName() As String
         GetName = "Sicredi"
      End Function

      Overrides Function CreateHttp() As PixHttp
         CreateHttp = New PixHttpSicredi(me._config)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
