Imports mod_tobject
Imports google_auth_config
Imports google_auth_errors
Imports google_auth_enums

Namespace google_auth_validation

   Class GoogleAuthValidator
      Inherits TTObject

      Shared Sub Validate(pConfig As GoogleAuthConfig)
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleAuthErrors.ConfigRequired())
         End If
         If Not Assigned(pConfig.Credentials) Then
            Throw New Exception(GoogleAuthErrors.ClientIdRequired())
         End If
         If Trim(pConfig.Credentials.ClientId) = "" Then
            Throw New Exception(GoogleAuthErrors.ClientIdRequired())
         End If
         If Trim(pConfig.Credentials.ClientSecret) = "" Then
            Throw New Exception(GoogleAuthErrors.ClientSecretRequired())
         End If
         If Not Assigned(pConfig.Scopes) Then
            Throw New Exception(GoogleAuthErrors.ScopeRequired())
         End If
         If pConfig.Scopes.Count() = 0 Then
            Throw New Exception(GoogleAuthErrors.ScopeRequired())
         End If
         If Trim(pConfig.ResolveRedirectUri()) = "" Then
            Throw New Exception(GoogleAuthErrors.RedirectRequired())
         End If
         If pConfig.GrantType.AsString = GoogleAuthGrantType.ServiceAccount().AsString Then
            Throw New Exception(GoogleAuthErrors.ServiceAccountUnsupported())
         End If
      End Sub

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
