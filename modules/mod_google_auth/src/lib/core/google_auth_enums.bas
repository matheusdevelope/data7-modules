Imports mod_tenum

Namespace google_auth_enums

   Enun GoogleAuthApiVersion
      V2 = "V2"
   End Enun

   Enun GoogleAuthGrantType
      AuthorizationCode = "authorization_code"
      RefreshToken = "refresh_token"
      ServiceAccount = "service_account"
   End Enun

   Enun GoogleAuthConsentKind
      Loopback = "loopback"
      Manual = "manual"
   End Enun

   Enun GoogleAuthTokenType
      Bearer = "Bearer"
   End Enun

   Enun GoogleAuthUiMode
      Headless = "headless"
      Locked = "locked"
      Editable = "editable"
   End Enun

End Namespace
