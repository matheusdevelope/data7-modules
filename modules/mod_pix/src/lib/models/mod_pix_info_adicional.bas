Imports mod_tobject
Imports mod_tlist

Namespace mod_pix_info_adicional

   Class PixInfoAdicional
      Inherits TTObject

      Nome As String
      Valor As String

      Sub New()
         MyBase.New()
      End Sub

      Sub New(pNome As String, pValor As String)
         MyBase.New()
         me.Nome = pNome
         me.Valor = pValor
      End Sub

      Sub Assign(pValue As PixInfoAdicional)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Nome = pValue.Nome
         me.Valor = pValue.Valor
      End Sub

      Overrides Function Clone() As PixInfoAdicional
         Clone = New PixInfoAdicional(me.Nome, me.Valor)
      End Function

      Overrides Function GetID() As String
         GetID = me.Nome
      End Function

      Shared Function FromJson(pJson As TJSONObject) As PixInfoAdicional
         Dim value As New PixInfoAdicional()
         If pJson.Has("nome") Then
            value.Nome = pJson.GetString("nome")
         End If
         If pJson.Has("valor") Then
            value.Valor = pJson.GetString("valor")
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         If me.Nome <> "" Then
            json.PutString("nome", me.Nome)
         End If
         If me.Valor <> "" Then
            json.PutString("valor", me.Valor)
         End If
         ToJson = json
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixInfoAdicional")
            .Prop("Nome", me.Nome)
            .Prop("Valor", me.Valor)
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

   Class PixInfoAdicionalList
      Inherits TTList<PixInfoAdicional>

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromJson(pJson As TJSONArray) As PixInfoAdicionalList
         Dim list As New PixInfoAdicionalList()
         Dim i As Integer
         Dim count As Integer = pJson.Length() - 1
         For i = 0 To count
            list.Push(PixInfoAdicional.FromJson(pJson.GetJSONObject(i)))
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

      Function CopyItems() As PixInfoAdicionalList
         Dim list As New PixInfoAdicionalList()
         Dim i As Integer
         Dim count As Integer = me.Length - 1
         For i = 0 To count
            list.Push(me.Take(i).Clone())
         Next
         CopyItems = list
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
