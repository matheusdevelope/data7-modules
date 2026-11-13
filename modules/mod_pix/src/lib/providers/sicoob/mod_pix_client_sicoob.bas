Imports mod_pix_bacen
Imports mod_pix_config
Imports mod_pix_http
Imports mod_pix_http_sicoob
Imports mod_pix_psp
Imports mod_pix_enums

Namespace mod_pix_sicoob

   Class PixPspSicoob
      Inherits PixPsp

      Sub New(pVersion As Integer)
         MyBase.New(PixBanco.Sicoob(), pVersion)
      End Sub

      Overrides Sub FillUrls()
         me.AuthUrls.Add("https://auth.sicoob.com.br/auth/realms/cooperado/protocol/openid-connect/token")
         me.AuthUrls.Add("https://auth.sicoob.com.br/auth/realms/cooperado/protocol/openid-connect/token")
         me.BaseUrls.Add("https://sandbox.sicoob.com.br/sicoob/sandbox/pix/api/v" & CStr(me.Version))
         me.BaseUrls.Add("https://api.sicoob.com.br/pix/api/v" & CStr(me.Version))
      End Sub

      Overrides Function Clone() As PixPsp
         Clone = New PixPspSicoob(me._version)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixClientSicoob
      Inherits PixClientBacen

      Sub New(pConfig As PixConfig)
         MyBase.New(pConfig)
      End Sub

      Overrides Sub ApplyProfile(pConfig As PixConfig)
         pConfig.TimeZoneHours = -4
         If Assigned(pConfig.Psp) Then
            pConfig.Psp.Free()
         End If
         pConfig.Psp = New PixPspSicoob(pConfig.Version)
      End Sub

      Overrides Function GetName() As String
         GetName = "Sicoob"
      End Function

      Overrides Function CreateHttp() As PixHttp
         CreateHttp = New PixHttpSicoob(me._config)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
