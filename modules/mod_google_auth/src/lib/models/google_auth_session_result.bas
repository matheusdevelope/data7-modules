Imports mod_tobject
Imports google_auth_token_set

Namespace google_auth_session_result

   Class GoogleAuthSessionResult
      Inherits TTObject

      Succeeded As Boolean
      Cancelled As Boolean
      Email As String
      Name As String
      ErrorMessage As String

      Private _tokens As GoogleTokenSet

      Sub New()
         MyBase.New()
         me.Succeeded = False
         me.Cancelled = False
         me.Email = ""
         me.Name = ""
         me.ErrorMessage = ""
      End Sub

      Sub AttachTokens(pTokens As GoogleTokenSet)
         If Assigned(me._tokens) Then
            me._tokens.Free()
            me._tokens = Null
         End If
         If Assigned(pTokens) Then
            me._tokens = pTokens.Clone()
         End If
      End Sub

      Function Tokens() As GoogleTokenSet
         If Assigned(me._tokens) Then
            Tokens = me._tokens.Clone()
         Else
            Tokens = Null
         End If
      End Function

      Function HasTokens() As Boolean
         If Not Assigned(me._tokens) Then
            HasTokens = False
            Exit Function
         End If
         HasTokens = me._tokens.HasAccessToken() Or me._tokens.HasRefreshToken()
      End Function

      Overrides Sub Dispose()
         If Assigned(me._tokens) Then
            me._tokens.Free()
            me._tokens = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
