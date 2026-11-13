Imports Collections
Imports mod_tobject
Imports mod_pix_enums
Imports mod_pix_utils
Imports mod_pix_http

Namespace mod_pix_filtro

   Class PixFiltroFormatter
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function FormatDate(pDate As TDateTime, pTimeZoneHours As Integer) As String
         FormatDate = DateToQueryParam(pDate, pTimeZoneHours)
      End Function

      Overridable Function PaginaParamName() As String
         PaginaParamName = "paginacao.paginaAtual"
      End Function

      Overridable Function DefaultItensPorPagina() As Integer
         DefaultItensPorPagina = 0
      End Function

      Function ToParamsString(pFiltro As PixFiltro, pTimeZoneHours As Integer = 0) As String
         Dim params As New StringList()
         If pFiltro.CPF <> "" Then
            params.Add("cpf=" & pFiltro.CPF)
         End If
         If pFiltro.CNPJ <> "" Then
            params.Add("cnpj=" & pFiltro.CNPJ)
         End If
         If pFiltro.DataInicio > 0 Then
            params.Add("inicio=" & PixHttp.UrlEncode(me.FormatDate(pFiltro.DataInicio, pTimeZoneHours)))
         End If
         If pFiltro.DataFim > 0 Then
            params.Add("fim=" & PixHttp.UrlEncode(me.FormatDate(pFiltro.DataFim, pTimeZoneHours)))
         End If
         If Assigned(pFiltro.Status) Then
            params.Add("status=" & pFiltro.Status.AsString)
         End If
         If pFiltro.Pagina > 0 Then
            params.Add(me.PaginaParamName() & "=" & pFiltro.Pagina.ToString())
         End If
         Dim itensPorPagina As Integer = pFiltro.ItensPorPagina
         If itensPorPagina <= 0 Then
            itensPorPagina = me.DefaultItensPorPagina()
         End If
         If itensPorPagina > 0 Then
            params.Add("paginacao.itensPorPagina=" & itensPorPagina.ToString())
         End If
         ToParamsString = params.Text.Trim.Replace(params.LineBreak, "&")
         params.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixFiltro
      Inherits TTObject

      CPF As String
      CNPJ As String
      DataInicio As TDateTime
      DataFim As TDateTime
      Status As PixStatusCobranca
      Pagina As Integer
      ItensPorPagina As Integer

      Sub New()
         MyBase.New()
      End Sub

      Function ToParamsString(pTimeZoneHours As Integer = 0) As String
         Dim formatter As New PixFiltroFormatter()
         ToParamsString = formatter.ToParamsString(me, pTimeZoneHours)
         formatter.Free()
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixFiltro")
            .Prop("CPF", me.CPF)
            .Prop("CNPJ", me.CNPJ)
            .Prop("DataInicio", me.DataInicio)
            .Prop("DataFim", me.DataFim)
            .Prop("Status", me.Status)
            .Prop("Pagina", me.Pagina)
            .Prop("ItensPorPagina", me.ItensPorPagina)
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
