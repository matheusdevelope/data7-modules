Imports mod_tobject
Imports mod_pix_config
Imports mod_pix_enums

Namespace mod_pix_erp

   Class PixErp
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromContaFinanceira(pCodContaFinanceira As String) As PixConfig
         Dim query As New SQL.Command()
         Try
            With query.SQL
               .Add("SELECT")
               .Add("   CF.CodEmpresa,")
               .Add("   CF.CodContaFinanceira,")
               .Add("   CF.NumeroBanco,")
               .Add("   CF.ChavePix,")
               .Add("   PA.ClientID,")
               .Add("   PA.ClientSecret,")
               .Add("   PA.Ambiente,")
               .Add("   PA.VersaoApi,")
               .Add("   CD.ID,")
               .Add("   CD.ArquivoFisico,")
               .Add("   CD.Senha")
               .Add("FROM ContaFinanceira CF")
               .Add("JOIN Geral.ParametroApi PA ON PA.CodParametroApi = CF.CodParametroApi")
               .Add("JOIN CertificadoDigital CD ON CD.ID = PA.CertificadoDigitalID")
               .Add("WHERE CF.CodContaFinanceira = :CodContaFinanceira")
            End With
            query.Param("CodContaFinanceira").AsString = pCodContaFinanceira
            query.Open()
         Catch ex As Exception
            query.Free()
            Throw New Exception("Erro ao carregar configurações PIX da conta financeira [" & pCodContaFinanceira & "]:" & CHAR(13) & ex._GetMessage())
         End Try

         If query.RowsAffected <= 0 Then
            query.Free()
            Throw New Exception("Nenhuma conta financeira válida encontrada para o parâmetro de busca: [" & pCodContaFinanceira & "]")
         End If

         Dim bankNumber As String = query.Field("NumeroBanco").AsString
         If bankNumber = "" Then
            query.Free()
            Throw New Exception("Número do banco não informado na conta financeira [" & pCodContaFinanceira & "].")
         End If

         Dim banco As PixBanco
         Try
            banco = PixBanco.Load(bankNumber)
         Catch ex As Exception
            query.Free()
            Throw New Exception("O banco [" & bankNumber & "] não é suportado. Informe um número de banco válido.")
         End Try

         Dim pathCertificate As String = TPath.GetTempPath() & "\" & query.Field("ID").AsString & ".pfx"
         query.Field("ArquivoFisico").SaveToFile(pathCertificate)

         Dim config As New PixConfig(banco, query.Field("VersaoApi").AsInteger)
         With config
            .CodEmpresa = query.Field("CodEmpresa").AsInteger
            .CodFilial = Data7.CodFilial()
            .CodContaFinanceira = query.Field("CodContaFinanceira").AsString
            .Credentials.Id = query.Field("ClientID").AsString
            .Credentials.Secret = query.Field("ClientSecret").AsString
            .Certificate.Path = pathCertificate
            .Certificate.Pass = query.Field("Senha").AsString
            .ChavePix = query.Field("ChavePix").AsString
            .Sandbox = UCase(query.Field("Ambiente").AsString) <> "PRODUCAO"
         End With

         query.Free()
         FromContaFinanceira = config
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
