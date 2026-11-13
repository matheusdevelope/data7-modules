Imports mod_tobject

Namespace mod_pix_credentials

   Class PixCredentials
      Inherits TTObject

      Id As String
      Secret As String
      Type As String

      Sub New()
         MyBase.New()
         me.Type = "Basic"
      End Sub

      Function AsAuthorization() As String
         Dim raw As String = me.Id & ":" & me.Secret
         Dim token As String = raw.ToBase64()
         token = token.Replace(CHAR(13), "").Replace(CHAR(10), "").Replace(" ", "")
         AsAuthorization = me.Type & " " & token
      End Function

      Sub Assign(pValue As PixCredentials)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Id = pValue.Id
         me.Secret = pValue.Secret
         me.Type = pValue.Type
      End Sub

      Overrides Function Clone() As PixCredentials
         Dim copy As New PixCredentials()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixCredentials")
            .Prop("Id", me.Id)
            .Prop("Type", me.Type)
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
