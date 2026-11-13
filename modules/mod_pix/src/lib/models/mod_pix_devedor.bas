Imports mod_tobject

Namespace mod_pix_devedor

   Class PixDevedor
      Inherits TTObject

      CPF As String
      CNPJ As String
      Nome As String

      Sub New()
         MyBase.New()
      End Sub

      Function IsEmpty() As Boolean
         IsEmpty = me.CPF = "" And me.CNPJ = "" And me.Nome = ""
      End Function

      Sub Assign(pValue As PixDevedor)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.CPF = pValue.CPF
         me.CNPJ = pValue.CNPJ
         me.Nome = pValue.Nome
      End Sub

      Overrides Function Clone() As PixDevedor
         Dim copy As New PixDevedor()
         copy.Assign(me)
         Clone = copy
      End Function

      Shared Function FromJson(pJson As TJSONObject) As PixDevedor
         Dim value As New PixDevedor()
         If pJson.Has("cpf") Then
            value.CPF = pJson.GetString("cpf")
         End If
         If pJson.Has("cnpj") Then
            value.CNPJ = pJson.GetString("cnpj")
         End If
         If pJson.Has("nome") Then
            value.Nome = pJson.GetString("nome")
         End If
         FromJson = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         If me.CPF <> "" Then
            json.PutString("cpf", me.CPF)
         End If
         If me.CNPJ <> "" Then
            json.PutString("cnpj", me.CNPJ)
         End If
         If me.Nome <> "" Then
            json.PutString("nome", me.Nome)
         End If
         ToJson = json
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixDevedor")
            .Prop("Nome", me.Nome)
            .Prop("CPF", me.CPF)
            .Prop("CNPJ", me.CNPJ)
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
