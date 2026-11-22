Imports mod_tobject
Imports google_auth
Imports google_auth_config
Imports google_auth_store
Imports google_auth_form
Imports google_auth_session_result
Imports google_auth_errors

Namespace google_auth_connect

   Class GoogleAuthConnect
      Inherits TTObject

      Shared Function Run(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pOwnsStore As Boolean = True, pInteractive As Boolean = True, pTitle As String = "Autenticação Google") As GoogleAuthService
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleAuthErrors.ConfigRequired())
         End If
         If Not Assigned(pStore) Then
            Throw New Exception(GoogleAuthErrors.StoreRequired())
         End If
         If GoogleAuthConnect.StoreHasTokens(pConfig, pStore) Then
            Run = GoogleAuthService.Load(pConfig, pStore, pOwnsStore)
            Exit Function
         End If
         If pConfig.HasClientCredentials() Then
            If pInteractive Then
               GoogleAuthConnect.RunConsentForm(pConfig, pStore, pTitle)
            Else
               GoogleAuthConnect.RunSilentConsent(pConfig, pStore)
            End If
         Else
            If Not pInteractive Then
               Throw New Exception(GoogleAuthErrors.ClientIdRequired())
            End If
            GoogleAuthConnect.RunSetupForm(pConfig, pStore, pTitle)
         End If
         Run = GoogleAuthService.Load(pConfig, pStore, pOwnsStore)
      End Function

      Shared Function StoreHasTokens(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore) As Boolean
         If Not Assigned(pConfig) Then
            StoreHasTokens = False
            Exit Function
         End If
         If Not Assigned(pStore) Then
            StoreHasTokens = False
            Exit Function
         End If
         StoreHasTokens = pStore.Exists(pConfig.StoreKey())
      End Function

      Shared Sub RunConsentForm(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pTitle As String)
         Dim consentForm As GoogleAuthForm = GoogleAuthForm.ForConsent(pConfig, pStore, False, pTitle)
         Dim sessionResult As GoogleAuthSessionResult = Null
         Try
            sessionResult = consentForm.Execute()
            GoogleAuthConnect.EnsureSucceeded(sessionResult)
         Catch ex As Exception
            If Assigned(consentForm) Then
               consentForm.Free()
               consentForm = Null
            End If
            If Assigned(sessionResult) Then
               sessionResult.Free()
               sessionResult = Null
            End If
            Throw New Exception(ex._GetMessage())
         End Try
         consentForm.Free()
         sessionResult.Free()
      End Sub

      Shared Sub RunSetupForm(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pTitle As String)
         Dim setupForm As GoogleAuthForm = GoogleAuthForm.ForSetup(pTitle, pStore, False)
         Dim sessionResult As GoogleAuthSessionResult = Null
         Try
            sessionResult = setupForm.Execute()
            GoogleAuthConnect.EnsureSucceeded(sessionResult)
            GoogleAuthConnect.ApplyFormToConfig(setupForm, pConfig)
         Catch ex As Exception
            If Assigned(setupForm) Then
               setupForm.Free()
               setupForm = Null
            End If
            If Assigned(sessionResult) Then
               sessionResult.Free()
               sessionResult = Null
            End If
            Throw New Exception(ex._GetMessage())
         End Try
         setupForm.Free()
         sessionResult.Free()
      End Sub

      Shared Sub RunSilentConsent(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore)
         Dim sessionResult As GoogleAuthSessionResult = GoogleAuthForm.RunHeadless(pConfig, pStore, False)
         Try
            GoogleAuthConnect.EnsureSucceeded(sessionResult)
         Catch ex As Exception
            If Assigned(sessionResult) Then
               sessionResult.Free()
               sessionResult = Null
            End If
            Throw New Exception(ex._GetMessage())
         End Try
         sessionResult.Free()
      End Sub

      Shared Sub ApplyFormToConfig(pForm As GoogleAuthForm, pConfig As GoogleAuthConfig)
         If Not Assigned(pForm) Then
            Exit Sub
         End If
         If Not Assigned(pConfig) Then
            Exit Sub
         End If
         pConfig.Credentials.ClientId = Trim(pForm.TxtClientId.Text)
         pConfig.Credentials.ClientSecret = Trim(pForm.TxtClientSecret.Text)
         pConfig.Scopes.AddMany(pForm.TxtScopes.Text)
      End Sub

      Shared Sub EnsureSucceeded(pResult As GoogleAuthSessionResult)
         If Not Assigned(pResult) Then
            Throw New Exception(GoogleAuthErrors.ConsentCancelled())
         End If
         If pResult.Succeeded Then
            Exit Sub
         End If
         If pResult.Cancelled Then
            Throw New Exception(GoogleAuthErrors.ConsentCancelled())
         End If
         If Trim(pResult.ErrorMessage) <> "" Then
            Throw New Exception(pResult.ErrorMessage)
         End If
         Throw New Exception(GoogleAuthErrors.ConsentCancelled())
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
