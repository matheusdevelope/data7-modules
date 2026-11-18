Imports mod_tobject
Imports google_auth_endpoints
Imports google_auth_enums
Imports google_auth_errors

Namespace google_auth_endpoints_v2

   Class GoogleOAuthEndpointsV2
      Inherits GoogleOAuthEndpoints

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function AuthorizationUrl() As String
         AuthorizationUrl = "https://accounts.google.com/o/oauth2/v2/auth"
      End Function

      Overrides Function TokenUrl() As String
         TokenUrl = "https://oauth2.googleapis.com/token"
      End Function

      Overrides Function RevokeUrl() As String
         RevokeUrl = "https://oauth2.googleapis.com/revoke"
      End Function

      Overrides Function UserInfoUrl() As String
         UserInfoUrl = "https://www.googleapis.com/oauth2/v3/userinfo"
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class GoogleOAuthEndpointCatalog
      Inherits TTObject

      Shared Function Make(pVersion As GoogleAuthApiVersion) As GoogleOAuthEndpoints
         If Not Assigned(pVersion) Then
            Make = New GoogleOAuthEndpointsV2()
            Exit Function
         End If
         Make = GoogleOAuthEndpointCatalog.MakeByName(pVersion.AsString)
      End Function

      Shared Function MakeByName(pName As String) As GoogleOAuthEndpoints
         Dim name As String = UCase(Trim(pName))
         If (name = "") Or (name = "V2") Then
            MakeByName = New GoogleOAuthEndpointsV2()
            Exit Function
         End If
         Throw New Exception(GoogleAuthErrors.UnknownApiVersion(pName))
      End Function

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
