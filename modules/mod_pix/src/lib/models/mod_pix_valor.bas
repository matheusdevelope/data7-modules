Imports mod_tobject
Imports mod_pix_enums
Imports mod_pix_utils

Namespace mod_pix_valor

   Class PixValor
      Inherits TTObject

      Original As Double
      ModalidadeAlteracao As PixModalidadeAlteracao

      Sub New()
         MyBase.New()
         me.ModalidadeAlteracao = PixModalidadeAlteracao.Nao()
      End Sub

      Sub Assign(pValue As PixValor)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Original = pValue.Original
         me.ModalidadeAlteracao = pValue.ModalidadeAlteracao
      End Sub

      Overrides Function Clone() As PixValor
         Dim copy As New PixValor()
         copy.Assign(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject) As PixValor
         Dim value As New PixValor()
         If pJson.Has("original") Then
            value.Original = FormatValueToDouble(pJson.GetString("original"))
         End If
         If pJson.Has("modalidadeAlteracao") Then
            value.ModalidadeAlteracao = PixModalidadeAlteracao.Load(pJson.GetInteger("modalidadeAlteracao"))
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         If me.Original > 0 Then
            json.PutString("original", FormatValueToString(me.Original))
         End If
         If Assigned(me.ModalidadeAlteracao) Then
            json.PutInteger("modalidadeAlteracao", me.ModalidadeAlteracao.AsInteger)
         End If
         ToJson = json
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixValor")
            .Prop("Original", me.Original)
            .Prop("ModalidadeAlteracao", me.ModalidadeAlteracao.AsString)
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
