Imports mod_tobject

Namespace mod_pix_certificate

   Class PixCertificate
      Inherits TTObject

      Path As String
      Pass As String

      Sub New()
         MyBase.New()
      End Sub

      Sub Assign(pValue As PixCertificate)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Path = pValue.Path
         me.Pass = pValue.Pass
      End Sub

      Overrides Function Clone() As PixCertificate
         Dim copy As New PixCertificate()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixCertificate")
            .Prop("Path", me.Path)
            .Prop("Pass", me.Pass)
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
