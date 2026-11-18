Imports Data7
Imports TFile
Imports mod_tobject
Imports google_auth_enums
Imports google_auth_credentials
Imports google_auth_scopes
Imports google_auth_errors

Namespace google_auth_config

   Class GoogleAuthConfig
      Inherits TTObject

      Credentials As GoogleAuthCredentials
      Scopes As GoogleAuthScopes
      AccountId As String
      RedirectUri As String
      CallbackPort As Integer
      AccessType As String
      Prompt As String
      ExpirySkewSeconds As Integer
      Timeout As Integer
      ApiVersion As GoogleAuthApiVersion
      GrantType As GoogleAuthGrantType
      ConsentKind As GoogleAuthConsentKind

      Sub New()
         MyBase.New()
         me.Credentials = New GoogleAuthCredentials()
         me.Scopes = New GoogleAuthScopes()
         me.CallbackPort = 8085
         me.AccessType = "offline"
         me.Prompt = "consent"
         me.ExpirySkewSeconds = 60
         me.Timeout = 30000
         me.ApiVersion = GoogleAuthApiVersion.V2()
         me.GrantType = GoogleAuthGrantType.AuthorizationCode()
         me.ConsentKind = GoogleAuthConsentKind.Loopback()
      End Sub

      Function StoreKey() As String
         Dim account As String = Trim(me.AccountId)
         StoreKey = Trim(me.Credentials.ClientId) & "|" & account
      End Function

      Function ResolveRedirectUri() As String
         If Trim(me.RedirectUri) <> "" Then
            ResolveRedirectUri = Trim(me.RedirectUri)
            Exit Function
         End If
         ResolveRedirectUri = "http://localhost:" & CStr(me.CallbackPort) & "/"
      End Function

      Shared Function FromFile(pPath As String) As GoogleAuthConfig
         If Not TFile.Exists(pPath) Then
            Throw New Exception("GoogleAuthConfig file not found: " & pPath)
         End If
         Dim json As TJSONObject = New TJSONObject()
         json.LoadFromFile(pPath)
         Dim cfg As GoogleAuthConfig = GoogleAuthConfig.FromJson(json)
         json.Free()
         FromFile = cfg
      End Function

      Shared Function FromJson(pJson As TJSONObject) As GoogleAuthConfig
         Dim cfg As New GoogleAuthConfig()
         If Not Assigned(pJson) Then
            FromJson = cfg
            Exit Function
         End If
         Dim source As TJSONObject = pJson
         Dim nested As TJSONObject = Null
         If pJson.Has("installed") Then
            nested = pJson.GetJSONObject("installed")
            source = nested
         ElseIf pJson.Has("web") Then
            nested = pJson.GetJSONObject("web")
            source = nested
         End If
         If source.Has("client_id") Then
            cfg.Credentials.ClientId = source.GetString("client_id")
         End If
         If source.Has("client_secret") Then
            cfg.Credentials.ClientSecret = GoogleAuthConfig.ReadSecret(source.GetString("client_secret"))
         End If
         If source.Has("redirect_uri") Then
            cfg.RedirectUri = source.GetString("redirect_uri")
         ElseIf source.Has("redirect_uris") Then
            Dim uris As TJSONArray = source.GetArray("redirect_uris")
            If Assigned(uris) Then
               If uris.Length() > 0 Then
                  cfg.RedirectUri = uris.GetString(0)
               End If
               uris.Free()
            End If
         End If
         If pJson.Has("account_id") Then
            cfg.AccountId = pJson.GetString("account_id")
         End If
         If pJson.Has("callback_port") Then
            cfg.CallbackPort = pJson.GetInteger("callback_port")
         End If
         If pJson.Has("access_type") Then
            cfg.AccessType = pJson.GetString("access_type")
         End If
         If pJson.Has("prompt") Then
            cfg.Prompt = pJson.GetString("prompt")
         End If
         If pJson.Has("expiry_skew_seconds") Then
            cfg.ExpirySkewSeconds = pJson.GetInteger("expiry_skew_seconds")
         End If
         If pJson.Has("timeout") Then
            cfg.Timeout = pJson.GetInteger("timeout")
         End If
         If pJson.Has("api_version") Then
            cfg.ApiVersion = GoogleAuthApiVersion.V2()
            Dim versionName As String = UCase(Trim(pJson.GetString("api_version")))
            If versionName <> "V2" And versionName <> "" Then
               Throw New Exception(GoogleAuthErrors.UnknownApiVersion(versionName))
            End If
         End If
         If pJson.Has("grant_type") Then
            Dim grantName As String = LCase(Trim(pJson.GetString("grant_type")))
            If grantName = "service_account" Then
               cfg.GrantType = GoogleAuthGrantType.ServiceAccount()
            ElseIf grantName = "refresh_token" Then
               cfg.GrantType = GoogleAuthGrantType.RefreshToken()
            Else
               cfg.GrantType = GoogleAuthGrantType.AuthorizationCode()
            End If
         End If
         If pJson.Has("consent_kind") Then
            If LCase(Trim(pJson.GetString("consent_kind"))) = "manual" Then
               cfg.ConsentKind = GoogleAuthConsentKind.Manual()
            Else
               cfg.ConsentKind = GoogleAuthConsentKind.Loopback()
            End If
         End If
         If pJson.Has("scopes") Then
            cfg.Scopes.AddMany(pJson.GetString("scopes"))
         End If
         If source.Has("scopes") And cfg.Scopes.Count() = 0 Then
            cfg.Scopes.AddMany(source.GetString("scopes"))
         End If
         If Assigned(nested) Then
            nested.Free()
         End If
         FromJson = cfg
      End Function

      Shared Function ReadSecret(pValue As String) As String
         Dim secretValue As String = Trim(pValue)
         If secretValue = "" Then
            ReadSecret = ""
            Exit Function
         End If
         Dim decrypted As String
         Try
            decrypted = Data7.Descriptografar(secretValue)
         Catch ex As Exception
            decrypted = secretValue
         End Try
         ReadSecret = decrypted
      End Function

      Shared Function WriteSecret(pValue As String) As String
         Dim secretValue As String = Trim(pValue)
         If secretValue = "" Then
            WriteSecret = ""
            Exit Function
         End If
         Dim encrypted As String
         encrypted = Data7.Criptografar(secretValue)
         WriteSecret = encrypted
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         json.PutString("client_id", me.Credentials.ClientId)
         json.PutString("client_secret", GoogleAuthConfig.WriteSecret(me.Credentials.ClientSecret))
         json.PutString("account_id", me.AccountId)
         json.PutString("redirect_uri", me.RedirectUri)
         json.PutInteger("callback_port", me.CallbackPort)
         json.PutString("access_type", me.AccessType)
         json.PutString("prompt", me.Prompt)
         json.PutInteger("expiry_skew_seconds", me.ExpirySkewSeconds)
         json.PutInteger("timeout", me.Timeout)
         json.PutString("api_version", me.ApiVersion.AsString)
         json.PutString("grant_type", me.GrantType.AsString)
         json.PutString("consent_kind", me.ConsentKind.AsString)
         json.PutString("scopes", me.Scopes.AsQuery())
         ToJson = json
      End Function

      Sub ToFile(pPath As String)
         Dim json As TJSONObject = me.ToJson()
         json.SaveToFile(pPath)
         json.Free()
      End Sub

      Sub Assign(pValue As GoogleAuthConfig)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         If Assigned(me.Credentials) Then
            me.Credentials.Free()
         End If
         me.Credentials = pValue.Credentials.Clone()
         If Assigned(me.Scopes) Then
            me.Scopes.Free()
         End If
         me.Scopes = pValue.Scopes.Clone()
         me.AccountId = pValue.AccountId
         me.RedirectUri = pValue.RedirectUri
         me.CallbackPort = pValue.CallbackPort
         me.AccessType = pValue.AccessType
         me.Prompt = pValue.Prompt
         me.ExpirySkewSeconds = pValue.ExpirySkewSeconds
         me.Timeout = pValue.Timeout
         me.ApiVersion = pValue.ApiVersion
         me.GrantType = pValue.GrantType
         me.ConsentKind = pValue.ConsentKind
      End Sub

      Overrides Function Clone() As GoogleAuthConfig
         Dim copy As New GoogleAuthConfig()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleAuthConfig")
            .Prop("ClientId", me.Credentials.ClientId)
            .Prop("AccountId", me.AccountId)
            .Prop("RedirectUri", me.ResolveRedirectUri())
            .Prop("Scopes", me.Scopes.AsQuery())
            .Prop("ApiVersion", me.ApiVersion.AsString)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Credentials) Then
            me.Credentials.Free()
            me.Credentials = Null
         End If
         If Assigned(me.Scopes) Then
            me.Scopes.Free()
            me.Scopes = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
