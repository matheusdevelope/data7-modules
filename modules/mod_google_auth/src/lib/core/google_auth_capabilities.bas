Imports mod_tobject

Namespace google_auth_capabilities

   Class GoogleAuthCapabilities
      Inherits TTObject

      CanAuthorizationCode As Boolean
      CanRefreshToken As Boolean
      CanRevoke As Boolean
      CanServiceAccount As Boolean

      Sub New()
         MyBase.New()
      End Sub

      Shared Function UserOAuth() As GoogleAuthCapabilities
         Dim caps As New GoogleAuthCapabilities()
         caps.CanAuthorizationCode = True
         caps.CanRefreshToken = True
         caps.CanRevoke = True
         caps.CanServiceAccount = False
         UserOAuth = caps
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleAuthCapabilities")
            .Prop("CanAuthorizationCode", me.CanAuthorizationCode)
            .Prop("CanRefreshToken", me.CanRefreshToken)
            .Prop("CanRevoke", me.CanRevoke)
            .Prop("CanServiceAccount", me.CanServiceAccount)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
