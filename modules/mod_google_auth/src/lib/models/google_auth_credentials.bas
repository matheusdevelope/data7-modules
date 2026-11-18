Imports mod_tobject

Namespace google_auth_credentials

   Class GoogleAuthCredentials
      Inherits TTObject

      ClientId As String
      ClientSecret As String

      Sub New()
         MyBase.New()
      End Sub

      Sub New(pClientId As String, pClientSecret As String)
         MyBase.New()
         me.ClientId = Trim(pClientId)
         me.ClientSecret = Trim(pClientSecret)
      End Sub

      Function IsComplete() As Boolean
         IsComplete = Trim(me.ClientId) <> ""
      End Function

      Sub Assign(pValue As GoogleAuthCredentials)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.ClientId = pValue.ClientId
         me.ClientSecret = pValue.ClientSecret
      End Sub

      Overrides Function Clone() As GoogleAuthCredentials
         Dim copy As New GoogleAuthCredentials()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleAuthCredentials")
            .Prop("ClientId", me.ClientId)
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
