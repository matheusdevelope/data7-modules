Imports Forms
Imports TFile
Imports TDirectory
Imports mod_tobject
Imports http_client
Imports http_response
Imports google_auth
Imports google_auth_config
Imports google_auth_store
Imports google_auth_stores
Imports google_auth_enums
Imports google_auth_errors
Imports google_auth_session_result
Imports google_auth_token_set

Namespace google_auth_form

   Class GoogleAuthForm
      Inherits TTObject

      Private _title As String
      Private _auth As GoogleAuthService
      Private _cfg As GoogleAuthConfig
      Private _suppliedConfig As GoogleAuthConfig
      Private _injectedStore As GoogleTokenStore
      Private _uiMode As GoogleAuthUiMode
      Private _storePath As String
      Private _ownsAuth As Boolean
      Private _ownsCfg As Boolean
      Private _ownsInjectedStore As Boolean
      Private _busy As Boolean
      Private _pastedRedirect As String
      Private _sessionResult As GoogleAuthSessionResult

      Host As Forms.Form
      TxtClientId As Forms.PasswordTextBox
      TxtClientSecret As Forms.PasswordTextBox
      TxtScopes As Forms.TextBox
      TxtCallbackUrl As Forms.TextBox
      LblRedirect As Forms.StaticText
      LblStatus As Forms.StaticText
      BtnAuth As Forms.CommandButton
      BtnCheck As Forms.CommandButton
      BtnRevoke As Forms.CommandButton
      BtnExtract As Forms.CommandButton

      Sub New(pTitle As String = "Autenticação Google")
         MyBase.New()
         me._title = pTitle
         me._uiMode = GoogleAuthUiMode.Editable()
         me._storePath = "google-tokens.json"
         me._busy = False
         me._pastedRedirect = ""
         me._ownsAuth = False
         me._ownsCfg = False
         me._ownsInjectedStore = False
         me.Build()
         me.LoadSavedConfig()
         me.ApplyModeUi()
      End Sub

      Shared Function ForSetup(pTitle As String = "Autenticação Google") As GoogleAuthForm
         ForSetup = New GoogleAuthForm(pTitle)
      End Function

      Shared Function ForConsent(pConfig As GoogleAuthConfig, pStorePath As String = "google-tokens.json", pTitle As String = "Autenticação Google") As GoogleAuthForm
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleAuthErrors.ConfigRequired())
         End If
         Dim setupForm As New GoogleAuthForm(pTitle)
         setupForm.Configure(GoogleAuthUiMode.Locked(), pConfig, pStorePath, Null, False)
         ForConsent = setupForm
      End Function

      Shared Function RunHeadless(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pOwnsStore As Boolean = True) As GoogleAuthSessionResult
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleAuthErrors.ConfigRequired())
         End If
         If Not Assigned(pStore) Then
            Throw New Exception(GoogleAuthErrors.StoreRequired())
         End If
         Dim setupForm As New GoogleAuthForm()
         setupForm.Configure(GoogleAuthUiMode.Headless(), pConfig, "", pStore, pOwnsStore)
         RunHeadless = setupForm.Execute()
         setupForm.Free()
      End Function

      Private Sub Configure(pMode As GoogleAuthUiMode, pConfig As GoogleAuthConfig, pStorePath As String, pStore As GoogleTokenStore, pOwnsStore As Boolean)
         me._uiMode = pMode
         me._suppliedConfig = pConfig
         me._storePath = Trim(pStorePath)
         me._injectedStore = pStore
         me._ownsInjectedStore = pOwnsStore
         If Trim(me._storePath) = "" Then
            me._storePath = "google-tokens.json"
         End If
         me.ApplyConfigToFields()
         me.ApplyModeUi()
      End Sub

      Private Sub Build()
         me.Host = New Forms.Form()
         me.Host.Caption = me._title
         me.Host.Width = 540
         me.Host.Height = 530
         me.Host.Font.Size = 10
         me.Host.OnClose = me.OnHostClose

         Dim topPos As Integer = 12
         me.AddLabel("Client ID:", 12, topPos)
         topPos = topPos + 16
         me.TxtClientId = New Forms.PasswordTextBox(me.Host)
         me.TxtClientId.Left = 12
         me.TxtClientId.Top = topPos
         me.TxtClientId.Width = 500
         me.TxtClientId.Height = 24
         topPos = topPos + 36

         me.AddLabel("Client Secret (obrigatório):", 12, topPos)
         topPos = topPos + 16
         me.TxtClientSecret = New Forms.PasswordTextBox(me.Host)
         me.TxtClientSecret.Left = 12
         me.TxtClientSecret.Top = topPos
         me.TxtClientSecret.Width = 500
         me.TxtClientSecret.Height = 24
         topPos = topPos + 36

         me.AddLabel("Escopos (separados por espaço):", 12, topPos)
         topPos = topPos + 16
         me.TxtScopes = me.AddField(topPos)
         me.TxtScopes.Text = "openid email profile"
         topPos = topPos + 36

         me.LblRedirect = me.AddLabel("Redirect URI: http://localhost:8085/", 12, topPos)
         topPos = topPos + 36

         me.BtnAuth = New Forms.CommandButton(me.Host)
         me.BtnAuth.Left = 12
         me.BtnAuth.Top = topPos
         me.BtnAuth.Width = 156
         me.BtnAuth.Height = 28
         me.BtnAuth.Text = "Autorizar"
         me.BtnAuth.OnClick = me.OnAuthorize

         me.BtnCheck = New Forms.CommandButton(me.Host)
         me.BtnCheck.Left = 176
         me.BtnCheck.Top = topPos
         me.BtnCheck.Width = 156
         me.BtnCheck.Height = 28
         me.BtnCheck.Text = "Verificar"
         me.BtnCheck.OnClick = me.OnVerify

         me.BtnRevoke = New Forms.CommandButton(me.Host)
         me.BtnRevoke.Left = 340
         me.BtnRevoke.Top = topPos
         me.BtnRevoke.Width = 156
         me.BtnRevoke.Height = 28
         me.BtnRevoke.Text = "Revogar"
         me.BtnRevoke.OnClick = me.OnRevoke
         topPos = topPos + 40

         me.AddLabel("URL de redirecionamento (se o listener falhar):", 12, topPos)
         topPos = topPos + 16
         me.TxtCallbackUrl = me.AddField(topPos)
         me.TxtCallbackUrl.Height = 40
         topPos = topPos + 48

         me.BtnExtract = New Forms.CommandButton(me.Host)
         me.BtnExtract.Left = 12
         me.BtnExtract.Top = topPos
         me.BtnExtract.Width = 500
         me.BtnExtract.Height = 28
         me.BtnExtract.Text = "Extrair token da URL"
         me.BtnExtract.OnClick = me.OnExtract
         topPos = topPos + 40

         me.LblStatus = New Forms.StaticText(me.Host)
         me.LblStatus.Left = 12
         me.LblStatus.Top = topPos
         me.LblStatus.Width = 500
         me.LblStatus.Height = 64
         me.LblStatus.Text = "Status: informe o Client ID (tipo Web Application) e clique em Autorizar."
      End Sub

      Private Function AddLabel(pText As String, pLeft As Integer, pTop As Integer) As Forms.StaticText
         Dim lbl As Forms.StaticText = New Forms.StaticText(me.Host)
         lbl.Left = pLeft
         lbl.Top = pTop
         lbl.Width = 500
         lbl.Height = 16
         lbl.Text = pText
         AddLabel = lbl
      End Function

      Private Function AddField(pTop As Integer) As Forms.TextBox
         Dim inputBox As Forms.TextBox = New Forms.TextBox(me.Host)
         inputBox.Left = 12
         inputBox.Top = pTop
         inputBox.Width = 500
         inputBox.Height = 24
         AddField = inputBox
      End Function

      Private Function IsEditable() As Boolean
         IsEditable = me._uiMode.AsString = GoogleAuthUiMode.Editable().AsString
      End Function

      Private Function IsLocked() As Boolean
         IsLocked = me._uiMode.AsString = GoogleAuthUiMode.Locked().AsString
      End Function

      Private Function IsHeadless() As Boolean
         IsHeadless = me._uiMode.AsString = GoogleAuthUiMode.Headless().AsString
      End Function

      Private Sub ApplyConfigToFields()
         If Not Assigned(me._suppliedConfig) Then
            Exit Sub
         End If
         If Not Assigned(me.TxtClientId) Then
            Exit Sub
         End If
         me.TxtClientId.Text = me._suppliedConfig.Credentials.ClientId
         me.TxtClientSecret.Text = me._suppliedConfig.Credentials.ClientSecret
         If me._suppliedConfig.Scopes.Count() > 0 Then
            me.TxtScopes.Text = me._suppliedConfig.Scopes.AsQuery()
         End If
         me.LblRedirect.Text = "Redirect URI: " & me._suppliedConfig.ResolveRedirectUri()
      End Sub

      Private Sub ApplyModeUi()
         If Not Assigned(me.Host) Then
            Exit Sub
         End If
         If me.IsHeadless() Then
            me.Host.Visible = False
            Exit Sub
         End If
         If me.IsLocked() Then
            me.SetStatus("Status: dados preenchidos pelo aplicativo. Clique em Autorizar.")
         End If
         me.ApplyFieldLock()
      End Sub

      Private Sub ApplyFieldLock()
         If Not Assigned(me.TxtClientId) Then
            Exit Sub
         End If
         Dim canEdit As Boolean = me.IsEditable() And Not me._busy
         me.TxtClientId.Enabled = canEdit
         me.TxtClientSecret.Enabled = canEdit
         me.TxtScopes.Enabled = canEdit
      End Sub

      Private Function ConfigFilePath() As String
         Dim folder As String = TDirectory.GetCurrentDirectory()
         If Trim(folder) = "" Then
            ConfigFilePath = "google-oauth.json"
         Else
            ConfigFilePath = folder & "\google-oauth.json"
         End If
      End Function

      Private Sub LoadSavedConfig()
         Dim cfgPath As String = me.ConfigFilePath()
         If Not TFile.Exists(cfgPath) Then
            If TFile.Exists("google-oauth.json") Then
               cfgPath = "google-oauth.json"
            Else
               Exit Sub
            End If
         End If
         Dim loaded As GoogleAuthConfig = GoogleAuthConfig.FromFile(cfgPath)
         me.TxtClientId.Text = loaded.Credentials.ClientId
         me.TxtClientSecret.Text = loaded.Credentials.ClientSecret
         If loaded.Scopes.Count() > 0 Then
            me.TxtScopes.Text = loaded.Scopes.AsQuery()
         End If
         me.LblRedirect.Text = "Redirect URI: " & loaded.ResolveRedirectUri()
         loaded.Free()
      End Sub

      Private Function BuildConfig() As GoogleAuthConfig
         Dim cfg As New GoogleAuthConfig()
         cfg.Credentials.ClientId = Trim(me.TxtClientId.Text)
         cfg.Credentials.ClientSecret = Trim(me.TxtClientSecret.Text)
         cfg.Scopes.AddMany(me.TxtScopes.Text)
         cfg.CallbackPort = 8085
         cfg.RedirectUri = "http://localhost:8085/"
         BuildConfig = cfg
      End Function

      Private Sub EnsureAuth()
         If Assigned(me._auth) Then
            If me._ownsAuth Then
               me._auth.Free()
            End If
            me._auth = Null
         End If
         If me._ownsCfg Then
            If Assigned(me._cfg) Then
               me._cfg.Free()
            End If
            me._cfg = Null
         End If
         If me.IsEditable() Or Not Assigned(me._suppliedConfig) Then
            me._cfg = me.BuildConfig()
            me._ownsCfg = True
         Else
            me._cfg = me._suppliedConfig
            me._ownsCfg = False
         End If
         Dim store As GoogleTokenStore
         Dim ownsStore As Boolean
         If Assigned(me._injectedStore) Then
            store = me._injectedStore
            ownsStore = me._ownsInjectedStore
         Else
            store = GoogleTokenStores.Json(me._storePath)
            ownsStore = True
         End If
         me._auth = GoogleAuthService.Load(me._cfg, store, ownsStore)
         me._ownsAuth = True
      End Sub

      Private Sub SetBusyUi(pBusy As Boolean)
         If Assigned(me.BtnAuth) Then
            If pBusy Then
               me.BtnAuth.Text = "Parar autorização"
            Else
               me.BtnAuth.Text = "Autorizar"
            End If
         End If
         If Assigned(me.BtnCheck) Then
            me.BtnCheck.Enabled = Not pBusy
         End If
         If Assigned(me.BtnRevoke) Then
            me.BtnRevoke.Enabled = Not pBusy
         End If
         me.ApplyFieldLock()
      End Sub

      Private Sub FinishBusy()
         me._busy = False
         me.SetBusyUi(False)
      End Sub

      Private Sub SetStatus(pText As String)
         If Assigned(me.LblStatus) Then
            me.LblStatus.Text = pText
         End If
      End Sub

      Private Sub ShowAlert(pText As String)
         If me.IsHeadless() Then
            print(pText)
            Exit Sub
         End If
         Forms.MessageBox.Show(pText)
      End Sub

      Private Sub NotifyStayOpenAuthorization()
         If Not me.IsEditable() Then
            Exit Sub
         End If
         If Assigned(me._sessionResult) Then
            If me._sessionResult.Succeeded Then
               Dim account As String = Trim(me._sessionResult.Name & " " & me._sessionResult.Email)
               If account = "" Then
                  Forms.MessageBox.Show("Autorização concluída com sucesso.")
               Else
                  Forms.MessageBox.Show("Autorização concluída com sucesso." & CHAR(13) & account)
               End If
               Exit Sub
            End If
            If Trim(me._sessionResult.ErrorMessage) <> "" Then
               Forms.MessageBox.Show("Não foi possível concluir a autorização." & CHAR(13) & me._sessionResult.ErrorMessage)
            End If
         End If
      End Sub

      Private Sub EnsureSessionResult()
         If Not Assigned(me._sessionResult) Then
            me._sessionResult = New GoogleAuthSessionResult()
         End If
      End Sub

      Private Sub CaptureSuccess()
         me.EnsureSessionResult()
         me._sessionResult.Succeeded = True
         me._sessionResult.Cancelled = False
         me._sessionResult.ErrorMessage = ""
         If Assigned(me._auth) Then
            Dim tokens As GoogleTokenSet = me._auth.CurrentTokens()
            me._sessionResult.AttachTokens(tokens)
            If Assigned(tokens) Then
               tokens.Free()
            End If
         End If
      End Sub

      Private Sub CaptureError(pMessage As String)
         me.EnsureSessionResult()
         If me._sessionResult.Succeeded Then
            Exit Sub
         End If
         me._sessionResult.ErrorMessage = pMessage
      End Sub

      Private Sub PersistAndShowUser()
         If me.IsEditable() Then
            If Assigned(me._cfg) Then
               me._cfg.ToFile(me.ConfigFilePath())
            End If
         End If
         me.ShowUserInfo()
         me.NotifyStayOpenAuthorization()
         If me.IsLocked() Then
            If Assigned(me._sessionResult) Then
               If me._sessionResult.Succeeded Then
                  If Assigned(me.Host) Then
                     me.Host.Close()
                  End If
               End If
            End If
         End If
      End Sub

      Private Function TryCompleteFromPastedUrl() As Boolean
         TryCompleteFromPastedUrl = False
         If Not Assigned(me._auth) Then
            Exit Function
         End If
         If Trim(me._pastedRedirect) = "" Then
            Exit Function
         End If
         me._auth.CompleteFromRedirectUrl(me._pastedRedirect)
         me._pastedRedirect = ""
         me.PersistAndShowUser()
         TryCompleteFromPastedUrl = True
      End Function

      Private Sub RunSilent()
         Try
            me.EnsureAuth()
            me._auth.Authorize()
            me.ShowUserInfo()
         Catch ex As Exception
            me.EnsureSessionResult()
            If Assigned(me._auth) Then
               If me._auth.WasCancelled() Then
                  me._sessionResult.Cancelled = True
                  me._sessionResult.ErrorMessage = ""
                  Exit Sub
               End If
            End If
            me._sessionResult.Succeeded = False
            me._sessionResult.ErrorMessage = ex._GetMessage()
            print("Google auth error: " & ex._GetMessage())
         End Try
      End Sub

      Function Execute() As GoogleAuthSessionResult
         If Assigned(me._sessionResult) Then
            me._sessionResult.Free()
            me._sessionResult = Null
         End If
         me._sessionResult = New GoogleAuthSessionResult()
         If me.IsHeadless() Then
            me.RunSilent()
         Else
            me.ApplyModeUi()
            me.Host.Show()
         End If
         Execute = me._sessionResult
         me._sessionResult = Null
      End Function

      Private Sub OnAuthorize(pSender As TObject)
         If me._busy Then
            me.OnStopAuthorize(pSender)
            Exit Sub
         End If
         me._busy = True
         me._pastedRedirect = ""
         me.SetBusyUi(True)
         me.EnsureSessionResult()
         Try
            me.SetStatus("Status: abrindo o navegador... conceda o acesso e aguarde o retorno em localhost:8085")
            me.EnsureAuth()
            me._auth.Authorize()
            me.PersistAndShowUser()
         Catch ex As Exception
            Dim recovered As Boolean = False
            Try
               recovered = me.TryCompleteFromPastedUrl()
            Catch extractEx As Exception
               me.SetStatus("Status: erro ao extrair da URL")
               print("Google auth extract error: " & extractEx._GetMessage())
               me.ShowAlert("Não foi possível extrair o token da URL." & CHAR(13) & extractEx._GetMessage())
               me.CaptureError(extractEx._GetMessage())
               recovered = True
            End Try
            If Not recovered Then
               If Assigned(me._auth) Then
                  If me._auth.WasCancelled() Then
                     me.SetStatus("Status: autorização interrompida")
                     me._sessionResult.Cancelled = True
                     recovered = True
                  End If
               End If
            End If
            If Not recovered Then
               me.SetStatus("Status: erro")
               print("Google auth error: " & ex._GetMessage())
               me.ShowAlert("Não foi possível autorizar." & CHAR(13) & ex._GetMessage())
               me.CaptureError(ex._GetMessage())
            End If
         End Try
         me.FinishBusy()
      End Sub

      Private Sub OnStopAuthorize(pSender As TObject)
         If Not Forms.MessageBox.Confirmation("Interromper a autorização e o listener agora?") Then
            Exit Sub
         End If
         If Assigned(me._auth) Then
            me._auth.CancelConsent()
         End If
         me.SetStatus("Status: interrompendo o listener...")
      End Sub

      Private Sub OnExtract(pSender As TObject)
         Dim pasted As String = Trim(me.TxtCallbackUrl.Text)
         If pasted = "" Then
            me.ShowAlert("Cole a URL completa de redirecionamento (a que contém ?code=) e tente novamente.")
            Exit Sub
         End If
         If me._busy Then
            me._pastedRedirect = pasted
            If Assigned(me._auth) Then
               me._auth.CancelConsent()
            End If
            me.SetStatus("Status: extraindo o token da URL colada...")
            Exit Sub
         End If
         If Not Assigned(me._auth) Then
            me.ShowAlert("Clique em Autorizar primeiro. Se o navegador não voltar sozinho, cole a URL aqui e extraia o token.")
            Exit Sub
         End If
         If Not me._auth.HasPendingAuthorization() Then
            me.ShowAlert("Clique em Autorizar primeiro. A extração usa o PKCE gerado nessa tentativa.")
            Exit Sub
         End If
         Try
            me._auth.CompleteFromRedirectUrl(pasted)
            me.PersistAndShowUser()
         Catch ex As Exception
            me.SetStatus("Status: erro")
            print("Google auth extract error: " & ex._GetMessage())
            me.ShowAlert("Não foi possível extrair o token da URL." & CHAR(13) & ex._GetMessage())
            me.CaptureError(ex._GetMessage())
         End Try
      End Sub

      Private Sub OnVerify(pSender As TObject)
         If me._busy Then
            Exit Sub
         End If
         Try
            me.EnsureAuth()
            me.ShowUserInfo()
         Catch ex As Exception
            me.SetStatus("Status: erro")
            print("Google verify error: " & ex._GetMessage())
            me.ShowAlert("Não foi possível verificar o token." & CHAR(13) & ex._GetMessage())
         End Try
      End Sub

      Private Sub OnRevoke(pSender As TObject)
         If me._busy Then
            Exit Sub
         End If
         Try
            me.EnsureAuth()
            me._auth.Revoke()
            me.SetStatus("Status: revogado")
         Catch ex As Exception
            me.SetStatus("Status: erro")
            me.ShowAlert("Não foi possível revogar o acesso." & CHAR(13) & ex._GetMessage())
         End Try
      End Sub

      Private Sub ShowUserInfo()
         If Not me._auth.IsAuthorized() Then
            me.SetStatus("Status: não autorizado")
            Exit Sub
         End If
         me.CaptureSuccess()
         Dim apiClient As HttpClient = Http.WinHttp("https://www.googleapis.com")
         apiClient.Certificate.Use = False
         apiClient.Use(me._auth.CreateBearerInterceptor())
         Dim res As HttpResponse = apiClient.Gett("/oauth2/v3/userinfo")
         If res.IsSuccessful Then
            Dim json As TJSONObject = res.Body.AsJson
            Dim email As String = ""
            Dim name As String = ""
            If json.Has("email") Then
               email = json.GetString("email")
            End If
            If json.Has("name") Then
               name = json.GetString("name")
            End If
            If email = "" And json.Has("sub") Then
               email = json.GetString("sub")
            End If
            json.Free()
            me.EnsureSessionResult()
            me._sessionResult.Email = email
            me._sessionResult.Name = name
            me.SetStatus("Status: autorizado — " & Trim(name & " " & email))
            print("Google userinfo OK: " & Trim(name & " " & email))
         Else
            me.SetStatus("Status: token obtido, mas userinfo falhou (" & CStr(res.Status) & ")")
            print("Google userinfo failed: " & res.Body.AsText)
         End If
         res.Free()
         apiClient.Free()
      End Sub

      Private Sub OnHostClose(pSender As TObject, pAction As TCloseAction)
         If me._busy Then
            If Assigned(me._auth) Then
               me._auth.CancelConsent()
            End If
         End If
         me.EnsureSessionResult()
         If Not me._sessionResult.Succeeded Then
            If Trim(me._sessionResult.ErrorMessage) = "" Then
               me._sessionResult.Cancelled = True
            End If
         End If
      End Sub

      Sub Show()
         me.ApplyModeUi()
         me.Host.Show()
      End Sub

      Sub Close()
         If Assigned(me.Host) Then
            me.Host.Close()
         End If
      End Sub

      Overrides Sub Dispose()
         If me._busy Then
            If Assigned(me._auth) Then
               me._auth.CancelConsent()
            End If
         End If
         If me._ownsAuth And Assigned(me._auth) Then
            me._auth.Free()
            me._auth = Null
         End If
         If me._ownsCfg And Assigned(me._cfg) Then
            me._cfg.Free()
         End If
         me._cfg = Null
         me._suppliedConfig = Null
         me._injectedStore = Null
         If Assigned(me._sessionResult) Then
            me._sessionResult.Free()
            me._sessionResult = Null
         End If
         If Assigned(me.Host) Then
            me.Host.Free()
            me.Host = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
