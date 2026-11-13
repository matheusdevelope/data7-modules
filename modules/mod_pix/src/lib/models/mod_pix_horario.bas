Imports mod_tobject
Imports mod_pix_utils

Namespace mod_pix_horario

   Class PixHorario
      Inherits TTObject

      Liquidacao As TDateTime
      Solicitacao As TDateTime

      Sub New()
         MyBase.New()
      End Sub

      Sub Assign(pValue As PixHorario)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Liquidacao = pValue.Liquidacao
         me.Solicitacao = pValue.Solicitacao
      End Sub

      Overrides Function Clone() As PixHorario
         Dim copy As New PixHorario()
         copy.Assign(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixHorario
         Dim value As New PixHorario()
         If pJson.Has("liquidacao") Then
            Dim _liquidacao As TDateTime = ParseISO8601(pJson.GetString("liquidacao"))
            value.Liquidacao = _liquidacao.AddHours(pTimeZoneHours)
         End If
         If pJson.Has("solicitacao") Then
            Dim _solicitacao As TDateTime = ParseISO8601(pJson.GetString("solicitacao"))
            value.Solicitacao = _solicitacao.AddHours(pTimeZoneHours)
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         If Not IsEmptyDate(me.Liquidacao) Then
            json.PutString("liquidacao", DateToISO8601(me.Liquidacao))
         End If
         If Not IsEmptyDate(me.Solicitacao) Then
            json.PutString("solicitacao", DateToISO8601(me.Solicitacao))
         End If
         ToJson = json
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixHorario")
            .Prop("Liquidacao", DateToISO8601(me.Liquidacao))
            .Prop("Solicitacao", DateToISO8601(me.Solicitacao))
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
