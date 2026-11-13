Imports mod_pix_cobranca_completa

Namespace mod_pix_app_share

   Class PixAppShareRequest

      Cobranca As PixCobrancaCompleta
      QrCodePath As String

      Sub New(pCobranca As PixCobrancaCompleta, pQrCodePath As String = "")
         MyBase.New()
         me.Cobranca = pCobranca
         me.QrCodePath = pQrCodePath
      End Sub

      Function ApplyTokens(pText As String) As String
         ApplyTokens = PixAppShareRequest.ReplaceTokens(me.Cobranca, pText)
      End Function

      Shared Function ReplaceTokens(pCobranca As PixCobrancaCompleta, pText As String) As String
         pText = pText.Replace("@TxId", pCobranca.TxId)
         pText = pText.Replace("@Revisao", pCobranca.Revisao.ToString())
         pText = pText.Replace("@SolicitacaoPagador", pCobranca.SolicitacaoPagador)
         pText = pText.Replace("@Chave", pCobranca.Chave)
         pText = pText.Replace("@PixCopiaECola", pCobranca.PixCopiaECola)
         pText = pText.Replace("@Status", pCobranca.Status.AsString)
         pText = pText.Replace("@Location", pCobranca.Location)
         pText = pText.Replace("@Valor", pCobranca.Valor.Original.ToString())
         pText = pText.Replace("@ModalidadeAlteracao", pCobranca.Valor.ModalidadeAlteracao.AsString)
         pText = pText.Replace("@Nome", pCobranca.Devedor.Nome)
         pText = pText.Replace("@CPF", pCobranca.Devedor.CPF)
         pText = pText.Replace("@CNPJ", pCobranca.Devedor.CNPJ)
         If pCobranca.Devedor.CPF <> "" Then
            pText = pText.Replace("@CNPJ_CPF", pCobranca.Devedor.CPF)
         ElseIf pCobranca.Devedor.CNPJ <> "" Then
            pText = pText.Replace("@CNPJ_CPF", pCobranca.Devedor.CNPJ)
         End If
         pText = pText.Replace("@Data", pCobranca.Calendario.Criacao.ToString("dd/mm/yyyy"))
         pText = pText.Replace("@Hora", pCobranca.Calendario.Criacao.ToString("hh:nn:ss"))
         pText = pText.Replace("@Expiracao", pCobranca.Calendario.Expiracao.ToString())
         pText = pText.Replace("@DataExpiracao", pCobranca.Calendario.DataExpiracao().ToString("dd/mm/yyyy"))
         pText = pText.Replace("@HoraExpiracao", pCobranca.Calendario.DataExpiracao().ToString("hh:nn:ss"))
         ReplaceTokens = pText
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   MustInherit Class PixAppSharer

      Sub New()
         MyBase.New()
      End Sub

      MustOverride Overridable Function Hint() As String
      End Function

      MustOverride Overridable Function IconBase64() As String
      End Function

      Overridable Function ShortcutKey() As Integer
         ShortcutKey = 0
      End Function

      MustOverride Overridable Sub Share(pRequest As PixAppShareRequest)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
