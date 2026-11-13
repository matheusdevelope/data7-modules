Imports mod_tobject
Imports mod_tlist
Imports mod_pix_enums
Imports mod_pix_utils
Imports mod_pix_horario

Namespace mod_pix_devolucao

   Class PixDevolucao
      Inherits TTObject

      Id As String
      RtrId As String
      Valor As Double
      Status As PixStatusDevolucao
      Motivo As String
      Horario As PixHorario

      Sub New()
         MyBase.New()
         me.Horario = New PixHorario()
      End Sub

      Overrides Function GetID() As String
         GetID = me.Id
      End Function

      Sub Assign(pValue As PixDevolucao)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Id = pValue.Id
         me.RtrId = pValue.RtrId
         me.Valor = pValue.Valor
         me.Status = pValue.Status
         me.Motivo = pValue.Motivo
         If Assigned(me.Horario) Then
            me.Horario.Free()
         End If
         me.Horario = pValue.Horario.Clone()
      End Sub

      Overrides Function Clone() As PixDevolucao
         Dim copy As New PixDevolucao()
         copy.Assign(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixDevolucao
         Dim value As New PixDevolucao()
         If pJson.Has("id") Then
            value.Id = pJson.GetString("id")
         End If
         If pJson.Has("rtrId") Then
            value.RtrId = pJson.GetString("rtrId")
         End If
         If pJson.Has("valor") Then
            value.Valor = FormatValueToDouble(pJson.GetString("valor"))
         End If
         If pJson.Has("status") Then
            value.Status = PixStatusDevolucao.Load(pJson.GetString("status"))
         End If
         If pJson.Has("motivo") Then
            value.Motivo = pJson.GetString("motivo")
         End If
         If pJson.Has("horario") Then
            value.Horario.Free()
            value.Horario = PixHorario.FromJson(pJson.GetJSONObject("horario"), pTimeZoneHours)
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         If me.Id <> "" Then
            json.PutString("id", me.Id)
         End If
         If me.RtrId <> "" Then
            json.PutString("rtrId", me.RtrId)
         End If
         json.PutString("valor", FormatValueToString(me.Valor))
         If Assigned(me.Status) Then
            json.PutString("status", me.Status.AsString)
         End If
         If me.Motivo <> "" Then
            json.PutString("motivo", me.Motivo)
         End If
         If Assigned(me.Horario) Then
            json.PutObject("horario", me.Horario.ToJson())
         End If
         ToJson = json
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixDevolucao")
            .Prop("Id", me.Id)
            .Prop("RtrId", me.RtrId)
            .Prop("Valor", me.Valor.ToString())
            .Prop("Status", me.Status.AsString)
            .Prop("Motivo", me.Motivo)
            .Prop("Horario", me.Horario.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Horario) Then
            me.Horario.Free()
            me.Horario = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixDevolucaoList
      Inherits TTList<PixDevolucao>

      Sub New()
         MyBase.New()
      End Sub

      Function ValorTotal() As Double
         Dim total As Double = 0
         Dim i As Integer
         Dim count As Integer = me.Length - 1
         For i = 0 To count
            total = total + me.Take(i).Valor
         Next
         ValorTotal = total
      End Function

      Shared Function FromJson(pJson As TJSONArray, pTimeZoneHours As Integer = 0) As PixDevolucaoList
         Dim list As New PixDevolucaoList()
         Dim i As Integer
         Dim count As Integer = pJson.Length() - 1
         For i = 0 To count
            list.Push(PixDevolucao.FromJson(pJson.GetJSONObject(i), pTimeZoneHours))
         Next
         FromJson = list
      End Function

      Function ToJson() As TJSONArray
         Dim json As New TJSONArray()
         Dim i As Integer
         Dim count As Integer = me.Length - 1
         For i = 0 To count
            json.PutObject(me.Take(i).ToJson())
         Next
         ToJson = json
      End Function

      Function CopyItems() As PixDevolucaoList
         Dim list As New PixDevolucaoList()
         Dim i As Integer
         Dim count As Integer = me.Length - 1
         For i = 0 To count
            list.Push(me.Take(i).Clone())
         Next
         CopyItems = list
      End Function

      Function FindById(pId As String) As PixDevolucao
         Dim idx As Integer = me.IndexOf(pId)
         If idx < 0 Then
            FindById = Null
         Else
            FindById = me.Take(idx)
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
