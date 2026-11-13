Imports Collections
Imports mod_tobject
Imports mod_pix_cobranca
Imports mod_pix_filtro
Imports mod_pix_utils
Imports mod_pix_info_adicional
Imports mod_validators

Namespace mod_pix_validation

   Class PixValidator
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Function ValidateValue(pValor As Double) As String
         Dim errors As New StringList()
         If pValor <= 0 Then
            errors.Add("[Valor] tem que ser maior que 0")
         End If
         Dim vlrStr As String = Math.Truncate(pValor, 2).ToString()
         Dim vlrRaw As String = pValor.ToString()
         If vlrStr <> vlrRaw Then
            errors.Add("[Valor] deve conter exatamente 2 casas decimais")
         End If
         ValidateValue = errors.Text.Trim()
         errors.Free()
      End Function

      Function ValidateCobranca(pDados As PixCobranca) As String
         Dim errors As New StringList()
         If Len(pDados.TxId) < 26 Or Len(pDados.TxId) > 35 Then
            errors.Add("TxID inválido")
         End If
         Dim errorValor As String = me.ValidateValue(pDados.Valor.Original)
         If errorValor <> "" Then
            errors.Add(errorValor)
         End If
         If pDados.Chave = "" Then
            errors.Add("Chave PIX não informada [Chave], verifique!")
         End If
         If pDados.Calendario.Expiracao <= 0 Then
            errors.Add("Expiração igual ou menor que zero, informe uma expiração para a cobrança [Calendario.Expiracao]")
         End If
         If pDados.Devedor.CPF <> "" And pDados.Devedor.CNPJ <> "" Then
            errors.Add("Informe apenas um Devedor: [Devedor.cnpj] ou [Devedor.cpf]")
         End If
         If pDados.Devedor.CPF <> "" Then
            If Not mod_strings.IsNumericString(pDados.Devedor.CPF) Or Len(pDados.Devedor.CPF) <> 11 Then
               errors.Add("[Devedor.CPF] inválido: deve conter 11 dígitos numéricos")
            ElseIf Not TDocs.IsValidCPF(pDados.Devedor.CPF) Then
               errors.Add("[Devedor.CPF] inválido")
            End If
         End If
         If pDados.Devedor.CNPJ <> "" Then
            If Not mod_strings.IsNumericString(pDados.Devedor.CNPJ) Or Len(pDados.Devedor.CNPJ) <> 14 Then
               errors.Add("[Devedor.CNPJ] inválido: deve conter 14 dígitos numéricos")
            ElseIf Not TDocs.IsValidCNPJ(pDados.Devedor.CNPJ) Then
               errors.Add("[Devedor.CNPJ] inválido")
            End If
         End If
         If pDados.Devedor.Nome <> "" Then
            If pDados.Devedor.CPF = "" And pDados.Devedor.CNPJ = "" Then
               errors.Add("Ao informar um [Devedor.Nome], o [Devedor.CPF] ou [Devedor.CNPJ] é obrigatório")
            End If
         End If
         If pDados.InfoAdicionais.Length > 0 Then
            Dim i As Integer
            Dim count As Integer = pDados.InfoAdicionais.Length - 1
            For i = 0 To count
               Dim item As PixInfoAdicional = pDados.InfoAdicionais.Take(i)
               If item.Nome = "" Or item.Valor = "" Then
                  errors.Add("Campos [InfoAdicionais.Nome] e [InfoAdicionais.Valor] são obrigatórios")
               End If
            Next
         End If
      If errors.Count > 0 Then
         errors.Add("")
         errors.Add("Conteúdo Cobrança:")
         errors.Add(pDados.ToString())
      End If         
         ValidateCobranca = errors.Text.Trim()
         errors.Free()
      End Function

      Sub EnsureCobranca(pDados As PixCobranca)
         Dim errors As String = me.ValidateCobranca(pDados)
         If errors <> "" Then
            Throw New Exception(CHAR(13) & "Dados Cobrança Inválido:" & CHAR(13) & errors & CHAR(13))
         End If
      End Sub

      Sub EnsureTxId(pTxId As String)
         If pTxId = "" Then
            Throw New Exception("TxId é obrigatório")
         End If
      End Sub

      Sub EnsureE2eId(pEndToEndId As String)
         If pEndToEndId = "" Then
            Throw New Exception("EndToEndId é obrigatório")
         End If
      End Sub

      Sub EnsureFiltro(pFiltros As PixFiltro)
         If IsEmptyDate(pFiltros.DataInicio) Or IsEmptyDate(pFiltros.DataFim) Then
            Throw New Exception("Intervalo de datas inválido, é necessário informar uma data inicial e final para consulta")
         End If
         If pFiltros.DataInicio > pFiltros.DataFim Then
            Throw New Exception("Intervalo de datas inválido, data inicial é maior que a data final")
         End If
      End Sub

      Sub EnsureDevolucao(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency)
         me.EnsureTxId(pTxId)
         me.EnsureE2eId(pEndToEndId)
         If pIdDevolucao = "" Then
            Throw New Exception("Id da devolução é obrigatório")
         End If
         Dim errorValor As String = me.ValidateValue(pValor)
         If errorValor <> "" Then
            Throw New Exception(errorValor)
         End If
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
