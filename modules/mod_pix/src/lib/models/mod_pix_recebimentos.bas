Imports mod_tobject
Imports mod_pix_filtro
Imports mod_pix_paginacao
Imports mod_pix_recebimento

Namespace mod_pix_recebimentos

   Class PixRecebimentos
      Inherits TTObject

      Parametros As PixFiltro
      Paginacao As PixPaginacao
      Pix As PixRecebimentoList

      Sub New()
         MyBase.New()
         me.Parametros = New PixFiltro()
         me.Paginacao = New PixPaginacao()
         me.Pix = New PixRecebimentoList()
      End Sub

      Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixRecebimentos
         Dim value As New PixRecebimentos()
         If pJson.Has("parametros") Then
            Dim parametros As TJSONObject = pJson.GetJSONObject("parametros")
            If parametros.Has("paginacao") Then
               value.Paginacao.Free()
               value.Paginacao = PixPaginacao.FromJson(parametros.GetJSONObject("paginacao"))
            End If
         End If
         If pJson.Has("pix") Then
            value.Pix.Free()
            value.Pix = PixRecebimentoList.FromJson(pJson.GetArray("pix"), pTimeZoneHours)
         End If
         FromJson = value
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixRecebimentos")
            .Prop("Count", me.Pix.Length)
            .Prop("Parametros", me.Parametros.ToString())
            .Prop("Paginacao", me.Paginacao.ToString())
            .Prop("Pix", me.Pix.ToString())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Parametros) Then
            me.Parametros.Free()
            me.Parametros = Null
         End If
         If Assigned(me.Paginacao) Then
            me.Paginacao.Free()
            me.Paginacao = Null
         End If
         If Assigned(me.Pix) Then
            me.Pix.Free()
            me.Pix = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
