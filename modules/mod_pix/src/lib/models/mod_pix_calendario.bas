Imports mod_tobject
Imports mod_pix_utils

Namespace mod_pix_calendario

   Class PixCalendario
      Inherits TTObject

      Criacao As TDateTime
      Expiracao As Integer

      Sub New()
         MyBase.New()
      End Sub

      Function DataExpiracao() As TDateTime
         DataExpiracao = me.Criacao.AddSeconds(me.Expiracao)
      End Function

      Function IsExpired() As Boolean
         IsExpired = DateTime() > me.DataExpiracao()
      End Function

      Sub Assign(pValue As PixCalendario)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Criacao = pValue.Criacao
         me.Expiracao = pValue.Expiracao
      End Sub

      Overrides Function Clone() As PixCalendario
         Dim copy As New PixCalendario()
         copy.Assign(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixCalendario
         Dim value As New PixCalendario()
         If pJson.Has("criacao") Then
            value.Criacao = ParseISO8601(pJson.GetString("criacao"))
            value.Criacao = value.Criacao.AddHours(pTimeZoneHours)
         End If
         If pJson.Has("expiracao") Then
            value.Expiracao = pJson.GetInteger("expiracao")
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         If Not IsEmptyDate(me.Criacao) Then
            json.PutString("criacao", DateToISO8601(me.Criacao))
         End If
         If me.Expiracao <> -1 Then
            json.PutInteger("expiracao", me.Expiracao)
         End If
         ToJson = json
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixCalendario")
            .Prop("Criacao", DateToISO8601(me.Criacao))
            .Prop("Expiracao", me.Expiracao)
            .Prop("DataExpiracao", DateToISO8601(me.DataExpiracao()))
            .Prop("IsExpired", me.IsExpired())
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
