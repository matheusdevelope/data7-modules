Imports mod_tobject

Namespace mod_pix_paginacao

   Class PixPaginacao
      Inherits TTObject

      PaginaAtual As Integer
      ItensPorPagina As Integer
      QuantidadePaginas As Integer
      TotalItens As Integer

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As PixPaginacao
         Dim value As New PixPaginacao()
         If pJson.Has("paginaAtual") Then
            value.PaginaAtual = pJson.GetInteger("paginaAtual")
         End If
         If pJson.Has("itensPorPagina") Then
            value.ItensPorPagina = pJson.GetInteger("itensPorPagina")
         End If
         If pJson.Has("quantidadeDePaginas") Then
            value.QuantidadePaginas = pJson.GetInteger("quantidadeDePaginas")
         ElseIf pJson.Has("quantidadePaginas") Then
            value.QuantidadePaginas = pJson.GetInteger("quantidadePaginas")
         End If
         If pJson.Has("quantidadeTotalDeItens") Then
            value.TotalItens = pJson.GetInteger("quantidadeTotalDeItens")
         ElseIf pJson.Has("quantidadeDeItens") Then
            value.TotalItens = pJson.GetInteger("quantidadeDeItens")
         End If
         FromJson = value
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixPaginacao")
            .Prop("TotalItens", me.TotalItens)
            .Prop("PaginaAtual", me.PaginaAtual)
            .Prop("ItensPorPagina", me.ItensPorPagina)
            .Prop("QuantidadePaginas", me.QuantidadePaginas)
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
