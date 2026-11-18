Imports http_headers
Imports http_url
Imports mod_tobject
Imports google_auth_errors

Namespace google_auth_code

   Class GoogleAuthCode
      Inherits TTObject

      Value As String
      State As String
      ErrorCode As String
      ErrorDescription As String

      Sub New()
         MyBase.New()
      End Sub

      Sub New(pValue As String, pState As String)
         MyBase.New()
         me.Value = Trim(pValue)
         me.State = Trim(pState)
      End Sub

      Function IsError() As Boolean
         IsError = Trim(me.ErrorCode) <> ""
      End Function

      Function IsEmpty() As Boolean
         IsEmpty = Trim(me.Value) = ""
      End Function

      Shared Function ExtractFromUrl(pUrl As String) As GoogleAuthCode
         Dim result As New GoogleAuthCode()
         Dim raw As String = Trim(pUrl)
         If raw = "" Then
            ExtractFromUrl = result
            Exit Function
         End If
         If InStr(raw, "=") = 0 Then
            result.Value = raw
            ExtractFromUrl = result
            Exit Function
         End If
         Dim query As New HttpParams(raw)
         If query.Has("error") Then
            result.ErrorCode = query.Value("error")
         End If
         If query.Has("error_description") Then
            result.ErrorDescription = http_url.Decode(query.Value("error_description"))
         End If
         If query.Has("state") Then
            result.State = query.Value("state")
         End If
         If query.Has("code") Then
            result.Value = http_url.Decode(query.Value("code"))
         ElseIf Not result.IsError() Then
            result.Value = raw
         End If
         query.Free()
         ExtractFromUrl = result
      End Function

      Function EnsureValid() As GoogleAuthCode
         If me.IsError() Then
            Throw New Exception(GoogleAuthErrors.ConsentDenied(me.ErrorCode))
         End If
         If me.IsEmpty() Then
            Throw New Exception(GoogleAuthErrors.AuthorizationCodeRequired())
         End If
         EnsureValid = me
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
