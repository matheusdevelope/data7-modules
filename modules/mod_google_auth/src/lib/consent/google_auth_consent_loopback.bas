Imports mod_winapi
Imports http_callback
Imports google_auth_consent
Imports google_auth_code
Imports google_auth_config
Imports google_auth_errors

Namespace google_auth_consent_loopback

   Class GoogleConsentLoopback
      Inherits GoogleConsentHandler

      Private _port As Integer
      Private _callback As HttpCallback
      Private _cancelled As Boolean

      Sub New(pPort As Integer)
         MyBase.New()
         me._port = pPort
         me._cancelled = False
         If me._port <= 0 Then
            me._port = 8085
         End If
      End Sub

      Shared Function FromConfig(pConfig As GoogleAuthConfig) As GoogleConsentLoopback
         FromConfig = New GoogleConsentLoopback(pConfig.CallbackPort)
      End Function

      Overrides Function RequestCode(pAuthUrl As String) As GoogleAuthCode
         me._cancelled = False
         If Assigned(me._callback) Then
            me._callback.Free()
            me._callback = Null
         End If
         me._callback = New HttpCallback()
         print("Google OAuth URL: " & pAuthUrl)
         WinAPI.Execute(pAuthUrl, "", False, SW_SHOWNORMAL)
         me._callback.Start(me._port, False)
         If me._cancelled Then
            Throw New Exception(GoogleAuthErrors.ConsentCancelled())
         End If
         Dim raw As String = me._callback.Output
         If Trim(raw) = "" Then
            Throw New Exception("No authorization response was received on localhost.")
         End If
         RequestCode = me.ParseCallback(raw)
      End Function

      Overrides Sub Cancel()
         me._cancelled = True
         If Assigned(me._callback) Then
            me._callback.Stopp()
         End If
      End Sub

      Overrides Function WasCancelled() As Boolean
         WasCancelled = me._cancelled
      End Function

      Private Function ParseCallback(pRaw As String) As GoogleAuthCode
         Dim fromUrl As String = Trim(pRaw)
         If Left(fromUrl, 1) = "{" Then
            Dim payload As TJSONObject = New TJSONObject(fromUrl)
            fromUrl = ""
            If payload.Has("url") Then
               fromUrl = payload.GetString("url")
            End If
            If fromUrl = "" And payload.Has("query") Then
               Dim query As TJSONObject = payload.GetJSONObject("query")
               Dim rebuilt As String = "http://localhost/?"
               If query.Has("code") Then
                  rebuilt = rebuilt & "code=" & query.GetString("code")
               End If
               If query.Has("state") Then
                  rebuilt = rebuilt & "&state=" & query.GetString("state")
               End If
               If query.Has("error") Then
                  rebuilt = rebuilt & "&error=" & query.GetString("error")
               End If
               fromUrl = rebuilt
               query.Free()
            End If
            payload.Free()
         End If
         ParseCallback = GoogleAuthCode.ExtractFromUrl(fromUrl)
      End Function

      Overrides Sub Dispose()
         me.Cancel()
         If Assigned(me._callback) Then
            me._callback.Free()
            me._callback = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
