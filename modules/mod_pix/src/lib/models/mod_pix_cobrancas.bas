Imports mod_tobject
Imports mod_pix_filtro
Imports mod_pix_paginacao
Imports mod_pix_cobranca_completa

Namespace mod_pix_cobrancas

   Class PixCobrancas
      Inherits TTObject

      Parametros As PixFiltro
      Paginacao As PixPaginacao
      Cobrancas As PixCobrancaList

      Sub New()
         MyBase.New()
         me.Parametros = New PixFiltro()
         me.Paginacao = New PixPaginacao()
         me.Cobrancas = New PixCobrancaList()
      End Sub

      Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixCobrancas
         Dim value As New PixCobrancas()
         If pJson.Has("parametros") Then
            Dim parametros As TJSONObject = pJson.GetJSONObject("parametros")
            value.Parametros.Free()
            value.Parametros = New PixFiltro()
            If parametros.Has("paginacao") Then
               value.Paginacao.Free()
               value.Paginacao = PixPaginacao.FromJson(parametros.GetJSONObject("paginacao"))
            End If
         End If
         If pJson.Has("cobs") Then
            value.Cobrancas.Free()
            value.Cobrancas = PixCobrancaList.FromJson(pJson.GetArray("cobs"), pTimeZoneHours)
         End If
         FromJson = value
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixCobrancas")
            .Prop("Count", me.Cobrancas.Length)
            .Prop("Parametros", me.Parametros.ToString())
            .Prop("Paginacao", me.Paginacao.ToString())
            .Prop("Cobrancas", me.Cobrancas.ToString())
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
         If Assigned(me.Cobrancas) Then
            me.Cobrancas.Free()
            me.Cobrancas = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
