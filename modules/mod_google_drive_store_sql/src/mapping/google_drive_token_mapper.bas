Imports mod_tobject
Imports configuracao_google_drive
Imports google_auth_token_set
Imports google_auth_config

Namespace google_drive_token_mapper

   Class GoogleDriveTokenMapper
      Inherits TTObject

      Shared Sub ApplyTokens(pRow As TConfiguracaoGoogleDrive, pTokens As GoogleTokenSet)
         If Not Assigned(pRow) Then
            Exit Sub
         End If
         If Not Assigned(pTokens) Then
            GoogleDriveTokenMapper.ClearTokens(pRow)
            Exit Sub
         End If
         pRow.AccessToken = pTokens.AccessToken
         pRow.RefreshToken = pTokens.RefreshToken
         pRow.IdToken = pTokens.IdToken
         pRow.TokenType = pTokens.TokenType
         pRow.ExpiresIn = pTokens.ExpiresIn
         pRow.CreatedAt = pTokens.CreatedAt
         pRow.ExpiresAt = pTokens.ExpiresAt
         If Trim(pTokens.Scope) <> "" Then
            pRow.Scopes = pTokens.Scope
         End If
         GoogleDriveTokenMapper.ApplyJwtProfile(pRow, pTokens.IdToken)
      End Sub

      Shared Function ToTokens(pRow As TConfiguracaoGoogleDrive) As GoogleTokenSet
         If Not Assigned(pRow) Then
            ToTokens = Null
            Exit Function
         End If
         Dim tokens As New GoogleTokenSet()
         tokens.AccessToken = pRow.AccessToken
         tokens.RefreshToken = pRow.RefreshToken
         tokens.IdToken = pRow.IdToken
         If Trim(pRow.TokenType) <> "" Then
            tokens.TokenType = pRow.TokenType
         End If
         tokens.Scope = pRow.Scopes
         tokens.CreatedAt = pRow.CreatedAt
         tokens.ExpiresIn = pRow.ExpiresIn
         If pRow.ExpiresAt <> 0 Then
            tokens.ExpiresAt = pRow.ExpiresAt
         End If
         ToTokens = tokens
      End Function

      Shared Sub ClearTokens(pRow As TConfiguracaoGoogleDrive)
         If Not Assigned(pRow) Then
            Exit Sub
         End If
         pRow.AccessToken = ""
         pRow.RefreshToken = ""
         pRow.IdToken = ""
         pRow.TokenType = ""
         pRow.ExpiresIn = 0
         pRow.CreatedAt = 0
         pRow.ExpiresAt = 0
      End Sub

      Shared Sub ApplyConfig(pRow As TConfiguracaoGoogleDrive, pConfig As GoogleAuthConfig)
         If Not Assigned(pRow) Then
            Exit Sub
         End If
         If Not Assigned(pConfig) Then
            Exit Sub
         End If
         pRow.ClientId = pConfig.Credentials.ClientId
         pRow.ClientSecret = pConfig.Credentials.ClientSecret
         pRow.Scopes = pConfig.Scopes.AsQuery()
         If pConfig.CallbackPort > 0 Then
            pRow.CallbackPort = pConfig.CallbackPort
         End If
         pRow.StoreKey = pConfig.StoreKey()
      End Sub

      Shared Function ToConfig(pRow As TConfiguracaoGoogleDrive) As GoogleAuthConfig
         Dim cfg As New GoogleAuthConfig()
         If Not Assigned(pRow) Then
            ToConfig = cfg
            Exit Function
         End If
         cfg.Credentials.ClientId = pRow.ClientId
         cfg.Credentials.ClientSecret = pRow.ClientSecret
         cfg.Scopes.AddMany(pRow.Scopes)
         If Trim(pRow.Email) <> "" Then
            cfg.AccountId = pRow.Email
         End If
         If pRow.CallbackPort > 0 Then
            cfg.CallbackPort = pRow.CallbackPort
         End If
         ToConfig = cfg
      End Function

      Shared Sub ApplyJwtProfile(pRow As TConfiguracaoGoogleDrive, pIdToken As String)
         If Not Assigned(pRow) Then
            Exit Sub
         End If
         If (Trim(pRow.Email) <> "") And (Trim(pRow.Nome) <> "") Then
            Exit Sub
         End If
         Dim raw As String = Trim(pIdToken)
         If raw = "" Then
            Exit Sub
         End If
         Dim firstDot As Integer = InStr(raw, ".")
         If firstDot <= 0 Then
            Exit Sub
         End If
         Dim rest As String = Mid(raw, firstDot + 1)
         Dim secondRel As Integer = InStr(rest, ".")
         If secondRel <= 0 Then
            Exit Sub
         End If
         Dim payload As String = Mid(rest, 1, secondRel - 1)
         If Trim(payload) = "" Then
            Exit Sub
         End If
         payload = payload.Replace("-", "+")
         payload = payload.Replace("_", "/")
         Dim pad As Integer = Len(payload) Mod 4
         If pad = 2 Then
            payload = payload & "=="
         ElseIf pad = 3 Then
            payload = payload & "="
         End If
         Dim jsonText As String = ""
         Try
            jsonText = jsonText.FromBase64(payload)
         Catch decodeEx As Exception
            Exit Sub
         End Try
         If Trim(jsonText) = "" Then
            Exit Sub
         End If
         Dim json As TJSONObject = Null
         Try
            json = New TJSONObject(jsonText)
            If Trim(pRow.Email) = "" Then
               If json.Has("email") Then
                  pRow.Email = json.GetString("email")
               End If
            End If
            If Trim(pRow.Nome) = "" Then
               If json.Has("name") Then
                  pRow.Nome = json.GetString("name")
               End If
            End If
         Catch ex As Exception
         End Try
         If Assigned(json) Then
            json.Free()
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
