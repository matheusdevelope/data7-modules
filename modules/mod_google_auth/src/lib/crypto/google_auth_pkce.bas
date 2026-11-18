Imports mod_tobject
Imports google_auth_crypto

Namespace google_auth_pkce

   Class GoogleAuthPkce
      Inherits TTObject

      Verifier As String
      Challenge As String
      Method As String

      Sub New()
         MyBase.New()
         me.Method = "S256"
      End Sub

      Shared Function Generate() As GoogleAuthPkce
         Generate = GoogleAuthPkce.FromVerifier(RandomUnreserved(64))
      End Function

      Shared Function FromVerifier(pVerifier As String) As GoogleAuthPkce
         Dim pkce As New GoogleAuthPkce()
         pkce.Verifier = Trim(pVerifier)
         pkce.Challenge = Sha256Base64Url(pkce.Verifier)
         pkce.Method = "S256"
         FromVerifier = pkce
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleAuthPkce")
            .Prop("Method", me.Method)
            .Prop("Challenge", me.Challenge)
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
