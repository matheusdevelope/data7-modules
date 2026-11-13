Imports TablesSchema
Imports TablesTable

Namespace table_filial

   Class TFilial
      Inherits TTableOf<TFilial>

      Sub New()
         MyBase.New("TFilial")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Filial"
         pSchema.Field("Contato").AsString().MaxLen(60)
         pSchema.Field("CodContador").AsInteger()
         pSchema.Field("CodEmpresa").AsInteger().PrimaryKeyField()
         pSchema.Field("CodFilial").AsInteger().AutoCodeField()
         pSchema.Field("Identificacao").AsString().MaxLen(60)
         pSchema.Field("Nome").AsString().MaxLen(60).RequiredField()
         pSchema.Field("NomeFantasia").AsString().MaxLen(50).RequiredField()
         pSchema.Field("CNPJ").AsString().MaxLen(20)
         pSchema.Field("InscricaoEstadual").AsString().MaxLen(20)
         pSchema.Field("CodMunicipio").AsInteger().RequiredField()
         pSchema.Field("Logradouro").AsString().MaxLen(80)
         pSchema.Field("NumeroLogradouro").AsString().MaxLen(10)
         pSchema.Field("Complemento").AsString().MaxLen(80)
         pSchema.Field("PontoReferencia").AsString().MaxLen(80)
         pSchema.Field("Bairro").AsString().MaxLen(30)
         pSchema.Field("CEP").AsString().MaxLen(15)
         pSchema.Field("InscricaoMunicipal").AsString().MaxLen(20)
         pSchema.Field("InscricaoSuframa").AsString().MaxLen(20)
         pSchema.Field("PerfilEFD").AsString().MaxLen(1)
         pSchema.Field("IndicadorAtividadeEFD").AsString().MaxLen(5)
         pSchema.Field("Telefone").AsString().MaxLen(30)
         pSchema.Field("Fax").AsString().MaxLen(30)
         pSchema.Field("EMail").AsString().MaxLen(100)
         pSchema.Field("Liberacao").AsString().MaxLen(8000)
         pSchema.Field("CertificadoDigital").AsString().MaxLen(250)
         pSchema.Field("SenhaCertificadoDigital").AsString().MaxLen(40)
         pSchema.Field("Licenca").AsString().MaxLen(8000)
         pSchema.Field("RegimeTributario").AsString().MaxLen(30)
         pSchema.Field("CST_Pis").AsString().MaxLen(3)
         pSchema.Field("CST_Cofins").AsString().MaxLen(3)
         pSchema.Field("CodSerieNFe").AsString().MaxLen(10)
         pSchema.Field("CNAE").AsString().MaxLen(7)
         pSchema.Field("PercentualCustoFixo").AsFloat().NumericPrec(5, 2)
         pSchema.Field("AliquotaIcmsOperacoesInternas").AsFloat().NumericPrec(25, 10)
         pSchema.Field("CodigoAutorizacaoCODIF").AsString().MaxLen(21)
         pSchema.Field("CodTabelaPreco").AsInteger()
         pSchema.Field("AliquotaSimplesNacional").AsFloat().NumericPrec(25, 10)
         pSchema.Field("NaturezaPessoaJuridica").AsString().MaxLen(24)
         pSchema.Field("AtividadePreponderante").AsString().MaxLen(34)
         pSchema.Field("RegimeApuracao").AsString().MaxLen(30)
         pSchema.Field("Enquadramento").AsString().MaxLen(22)
         pSchema.Field("CodColigadas").AsInteger()
         pSchema.Field("TokenID").AsString().MaxLen(6)
         pSchema.Field("Token").AsString().MaxLen(36)
         pSchema.Field("AliquotaIRRF").AsFloat().NumericPrec(25, 10)
         pSchema.Field("AliquotaCSLL").AsFloat().NumericPrec(25, 10)
         pSchema.Field("LicencaForcaVenda").AsString().MaxLen(60)
         pSchema.Field("MensagemNotaFiscal").AsString().MaxLen(2000)
         pSchema.Field("AliquotaISS").AsFloat().NumericPrec(25, 10)
         pSchema.Field("ChaveDigital").AsString().MaxLen(100)
         pSchema.Field("CodigoAtividadeEconomica").AsString().MaxLen(20)
         pSchema.Field("TokenDeOlhoNoImposto").AsString().MaxLen(100)
         pSchema.Field("ProvedorNfse").AsString().MaxLen(20)
         pSchema.Field("IssTributavelValorFixo").AsString().MaxLen(3)
         pSchema.Field("IncidenciaTributaria").AsString().MaxLen(30)
         pSchema.Field("ContribuicaoApurada").AsString().MaxLen(20)
         pSchema.Field("AliquotaEstimativaSimplificada").AsFloat().NumericPrec(25, 10)
         pSchema.Field("EstimativaSimplificada").AsString().MaxLen(3)
         pSchema.Field("UsuarioProvedorNFSe").AsString().MaxLen(50)
         pSchema.Field("SenhaProvedorNFSe").AsString().MaxLen(30)
         pSchema.Field("ClassificacaoContribuinteIPI").AsString().MaxLen(2)
         pSchema.Field("CodLocalArmazenagem").AsInteger()
         pSchema.Field("AliquotaInss").AsFloat().NumericPrec(25, 10)
         pSchema.Field("AliquotaFunRural").AsFloat().NumericPrec(25, 10)
         pSchema.Field("CadastroImovelRural").AsString().MaxLen(8)
         pSchema.Field("AtividadeEconomicaPessoaFisica").AsString().MaxLen(14)
         pSchema.Field("TipoExploracaoImovelRural").AsString().MaxLen(20)
         pSchema.Field("ParticipacaoImovelRural").AsFloat().NumericPrec(25, 10)
         pSchema.Field("Ativo").AsString().MaxLen(1)
         pSchema.Field("LiberacaoFrenteLoja").AsString().MaxLen(8000)
         pSchema.Field("CodTipoNFSe").AsInteger()
         pSchema.Field("AliquotaCBS").AsFloat().NumericPrec(25, 10)
         pSchema.Field("FaixaEnquadramentoSimplesNacional").AsString().MaxLen(20)
         pSchema.Field("CNAESecundario").AsString().MaxLen(7)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodEmpresa) & "|" & CStr(me.CodFilial)
      End Function

      Property Contato As String
         Get
            Contato = me.GetString("Contato")
         End Get
         Set(pValue As String)
            me.SetString("Contato", pValue)
         End Set
      End Property

      Property CodContador As Integer
         Get
            CodContador = me.GetInteger("CodContador")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodContador", pValue)
         End Set
      End Property

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("CodEmpresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEmpresa", pValue)
         End Set
      End Property

      Property CodFilial As Integer
         Get
            CodFilial = me.GetInteger("CodFilial")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodFilial", pValue)
         End Set
      End Property

      Property Identificacao As String
         Get
            Identificacao = me.GetString("Identificacao")
         End Get
         Set(pValue As String)
            me.SetString("Identificacao", pValue)
         End Set
      End Property

      Property Nome As String
         Get
            Nome = me.GetString("Nome")
         End Get
         Set(pValue As String)
            me.SetString("Nome", pValue)
         End Set
      End Property

      Property NomeFantasia As String
         Get
            NomeFantasia = me.GetString("NomeFantasia")
         End Get
         Set(pValue As String)
            me.SetString("NomeFantasia", pValue)
         End Set
      End Property

      Property CNPJ As String
         Get
            CNPJ = me.GetString("CNPJ")
         End Get
         Set(pValue As String)
            me.SetString("CNPJ", pValue)
         End Set
      End Property

      Property InscricaoEstadual As String
         Get
            InscricaoEstadual = me.GetString("InscricaoEstadual")
         End Get
         Set(pValue As String)
            me.SetString("InscricaoEstadual", pValue)
         End Set
      End Property

      Property CodMunicipio As Integer
         Get
            CodMunicipio = me.GetInteger("CodMunicipio")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodMunicipio", pValue)
         End Set
      End Property

      Property Logradouro As String
         Get
            Logradouro = me.GetString("Logradouro")
         End Get
         Set(pValue As String)
            me.SetString("Logradouro", pValue)
         End Set
      End Property

      Property NumeroLogradouro As String
         Get
            NumeroLogradouro = me.GetString("NumeroLogradouro")
         End Get
         Set(pValue As String)
            me.SetString("NumeroLogradouro", pValue)
         End Set
      End Property

      Property Complemento As String
         Get
            Complemento = me.GetString("Complemento")
         End Get
         Set(pValue As String)
            me.SetString("Complemento", pValue)
         End Set
      End Property

      Property PontoReferencia As String
         Get
            PontoReferencia = me.GetString("PontoReferencia")
         End Get
         Set(pValue As String)
            me.SetString("PontoReferencia", pValue)
         End Set
      End Property

      Property Bairro As String
         Get
            Bairro = me.GetString("Bairro")
         End Get
         Set(pValue As String)
            me.SetString("Bairro", pValue)
         End Set
      End Property

      Property CEP As String
         Get
            CEP = me.GetString("CEP")
         End Get
         Set(pValue As String)
            me.SetString("CEP", pValue)
         End Set
      End Property

      Property InscricaoMunicipal As String
         Get
            InscricaoMunicipal = me.GetString("InscricaoMunicipal")
         End Get
         Set(pValue As String)
            me.SetString("InscricaoMunicipal", pValue)
         End Set
      End Property

      Property InscricaoSuframa As String
         Get
            InscricaoSuframa = me.GetString("InscricaoSuframa")
         End Get
         Set(pValue As String)
            me.SetString("InscricaoSuframa", pValue)
         End Set
      End Property

      Property PerfilEFD As String
         Get
            PerfilEFD = me.GetString("PerfilEFD")
         End Get
         Set(pValue As String)
            me.SetString("PerfilEFD", pValue)
         End Set
      End Property

      Property IndicadorAtividadeEFD As String
         Get
            IndicadorAtividadeEFD = me.GetString("IndicadorAtividadeEFD")
         End Get
         Set(pValue As String)
            me.SetString("IndicadorAtividadeEFD", pValue)
         End Set
      End Property

      Property Telefone As String
         Get
            Telefone = me.GetString("Telefone")
         End Get
         Set(pValue As String)
            me.SetString("Telefone", pValue)
         End Set
      End Property

      Property Fax As String
         Get
            Fax = me.GetString("Fax")
         End Get
         Set(pValue As String)
            me.SetString("Fax", pValue)
         End Set
      End Property

      Property EMail As String
         Get
            EMail = me.GetString("EMail")
         End Get
         Set(pValue As String)
            me.SetString("EMail", pValue)
         End Set
      End Property

      Property Liberacao As String
         Get
            Liberacao = me.GetString("Liberacao")
         End Get
         Set(pValue As String)
            me.SetString("Liberacao", pValue)
         End Set
      End Property

      Property CertificadoDigital As String
         Get
            CertificadoDigital = me.GetString("CertificadoDigital")
         End Get
         Set(pValue As String)
            me.SetString("CertificadoDigital", pValue)
         End Set
      End Property

      Property SenhaCertificadoDigital As String
         Get
            SenhaCertificadoDigital = me.GetString("SenhaCertificadoDigital")
         End Get
         Set(pValue As String)
            me.SetString("SenhaCertificadoDigital", pValue)
         End Set
      End Property

      Property Licenca As String
         Get
            Licenca = me.GetString("Licenca")
         End Get
         Set(pValue As String)
            me.SetString("Licenca", pValue)
         End Set
      End Property

      Property RegimeTributario As String
         Get
            RegimeTributario = me.GetString("RegimeTributario")
         End Get
         Set(pValue As String)
            me.SetString("RegimeTributario", pValue)
         End Set
      End Property

      Property CST_Pis As String
         Get
            CST_Pis = me.GetString("CST_Pis")
         End Get
         Set(pValue As String)
            me.SetString("CST_Pis", pValue)
         End Set
      End Property

      Property CST_Cofins As String
         Get
            CST_Cofins = me.GetString("CST_Cofins")
         End Get
         Set(pValue As String)
            me.SetString("CST_Cofins", pValue)
         End Set
      End Property

      Property CodSerieNFe As String
         Get
            CodSerieNFe = me.GetString("CodSerieNFe")
         End Get
         Set(pValue As String)
            me.SetString("CodSerieNFe", pValue)
         End Set
      End Property

      Property CNAE As String
         Get
            CNAE = me.GetString("CNAE")
         End Get
         Set(pValue As String)
            me.SetString("CNAE", pValue)
         End Set
      End Property

      Property PercentualCustoFixo As Extended
         Get
            PercentualCustoFixo = me.GetFloat("PercentualCustoFixo")
         End Get
         Set(pValue As Extended)
            me.SetFloat("PercentualCustoFixo", pValue)
         End Set
      End Property

      Property AliquotaIcmsOperacoesInternas As Extended
         Get
            AliquotaIcmsOperacoesInternas = me.GetFloat("AliquotaIcmsOperacoesInternas")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaIcmsOperacoesInternas", pValue)
         End Set
      End Property

      Property CodigoAutorizacaoCODIF As String
         Get
            CodigoAutorizacaoCODIF = me.GetString("CodigoAutorizacaoCODIF")
         End Get
         Set(pValue As String)
            me.SetString("CodigoAutorizacaoCODIF", pValue)
         End Set
      End Property

      Property CodTabelaPreco As Integer
         Get
            CodTabelaPreco = me.GetInteger("CodTabelaPreco")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabelaPreco", pValue)
         End Set
      End Property

      Property AliquotaSimplesNacional As Extended
         Get
            AliquotaSimplesNacional = me.GetFloat("AliquotaSimplesNacional")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaSimplesNacional", pValue)
         End Set
      End Property

      Property NaturezaPessoaJuridica As String
         Get
            NaturezaPessoaJuridica = me.GetString("NaturezaPessoaJuridica")
         End Get
         Set(pValue As String)
            me.SetString("NaturezaPessoaJuridica", pValue)
         End Set
      End Property

      Property AtividadePreponderante As String
         Get
            AtividadePreponderante = me.GetString("AtividadePreponderante")
         End Get
         Set(pValue As String)
            me.SetString("AtividadePreponderante", pValue)
         End Set
      End Property

      Property RegimeApuracao As String
         Get
            RegimeApuracao = me.GetString("RegimeApuracao")
         End Get
         Set(pValue As String)
            me.SetString("RegimeApuracao", pValue)
         End Set
      End Property

      Property Enquadramento As String
         Get
            Enquadramento = me.GetString("Enquadramento")
         End Get
         Set(pValue As String)
            me.SetString("Enquadramento", pValue)
         End Set
      End Property

      Property CodColigadas As Integer
         Get
            CodColigadas = me.GetInteger("CodColigadas")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodColigadas", pValue)
         End Set
      End Property

      Property TokenID As String
         Get
            TokenID = me.GetString("TokenID")
         End Get
         Set(pValue As String)
            me.SetString("TokenID", pValue)
         End Set
      End Property

      Property Token As String
         Get
            Token = me.GetString("Token")
         End Get
         Set(pValue As String)
            me.SetString("Token", pValue)
         End Set
      End Property

      Property AliquotaIRRF As Extended
         Get
            AliquotaIRRF = me.GetFloat("AliquotaIRRF")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaIRRF", pValue)
         End Set
      End Property

      Property AliquotaCSLL As Extended
         Get
            AliquotaCSLL = me.GetFloat("AliquotaCSLL")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaCSLL", pValue)
         End Set
      End Property

      Property LicencaForcaVenda As String
         Get
            LicencaForcaVenda = me.GetString("LicencaForcaVenda")
         End Get
         Set(pValue As String)
            me.SetString("LicencaForcaVenda", pValue)
         End Set
      End Property

      Property MensagemNotaFiscal As String
         Get
            MensagemNotaFiscal = me.GetString("MensagemNotaFiscal")
         End Get
         Set(pValue As String)
            me.SetString("MensagemNotaFiscal", pValue)
         End Set
      End Property

      Property AliquotaISS As Extended
         Get
            AliquotaISS = me.GetFloat("AliquotaISS")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaISS", pValue)
         End Set
      End Property

      Property ChaveDigital As String
         Get
            ChaveDigital = me.GetString("ChaveDigital")
         End Get
         Set(pValue As String)
            me.SetString("ChaveDigital", pValue)
         End Set
      End Property

      Property CodigoAtividadeEconomica As String
         Get
            CodigoAtividadeEconomica = me.GetString("CodigoAtividadeEconomica")
         End Get
         Set(pValue As String)
            me.SetString("CodigoAtividadeEconomica", pValue)
         End Set
      End Property

      Property TokenDeOlhoNoImposto As String
         Get
            TokenDeOlhoNoImposto = me.GetString("TokenDeOlhoNoImposto")
         End Get
         Set(pValue As String)
            me.SetString("TokenDeOlhoNoImposto", pValue)
         End Set
      End Property

      Property ProvedorNfse As String
         Get
            ProvedorNfse = me.GetString("ProvedorNfse")
         End Get
         Set(pValue As String)
            me.SetString("ProvedorNfse", pValue)
         End Set
      End Property

      Property IssTributavelValorFixo As String
         Get
            IssTributavelValorFixo = me.GetString("IssTributavelValorFixo")
         End Get
         Set(pValue As String)
            me.SetString("IssTributavelValorFixo", pValue)
         End Set
      End Property

      Property IncidenciaTributaria As String
         Get
            IncidenciaTributaria = me.GetString("IncidenciaTributaria")
         End Get
         Set(pValue As String)
            me.SetString("IncidenciaTributaria", pValue)
         End Set
      End Property

      Property ContribuicaoApurada As String
         Get
            ContribuicaoApurada = me.GetString("ContribuicaoApurada")
         End Get
         Set(pValue As String)
            me.SetString("ContribuicaoApurada", pValue)
         End Set
      End Property

      Property AliquotaEstimativaSimplificada As Extended
         Get
            AliquotaEstimativaSimplificada = me.GetFloat("AliquotaEstimativaSimplificada")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaEstimativaSimplificada", pValue)
         End Set
      End Property

      Property EstimativaSimplificada As String
         Get
            EstimativaSimplificada = me.GetString("EstimativaSimplificada")
         End Get
         Set(pValue As String)
            me.SetString("EstimativaSimplificada", pValue)
         End Set
      End Property

      Property UsuarioProvedorNFSe As String
         Get
            UsuarioProvedorNFSe = me.GetString("UsuarioProvedorNFSe")
         End Get
         Set(pValue As String)
            me.SetString("UsuarioProvedorNFSe", pValue)
         End Set
      End Property

      Property SenhaProvedorNFSe As String
         Get
            SenhaProvedorNFSe = me.GetString("SenhaProvedorNFSe")
         End Get
         Set(pValue As String)
            me.SetString("SenhaProvedorNFSe", pValue)
         End Set
      End Property

      Property ClassificacaoContribuinteIPI As String
         Get
            ClassificacaoContribuinteIPI = me.GetString("ClassificacaoContribuinteIPI")
         End Get
         Set(pValue As String)
            me.SetString("ClassificacaoContribuinteIPI", pValue)
         End Set
      End Property

      Property CodLocalArmazenagem As Integer
         Get
            CodLocalArmazenagem = me.GetInteger("CodLocalArmazenagem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodLocalArmazenagem", pValue)
         End Set
      End Property

      Property AliquotaInss As Extended
         Get
            AliquotaInss = me.GetFloat("AliquotaInss")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaInss", pValue)
         End Set
      End Property

      Property AliquotaFunRural As Extended
         Get
            AliquotaFunRural = me.GetFloat("AliquotaFunRural")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaFunRural", pValue)
         End Set
      End Property

      Property CadastroImovelRural As String
         Get
            CadastroImovelRural = me.GetString("CadastroImovelRural")
         End Get
         Set(pValue As String)
            me.SetString("CadastroImovelRural", pValue)
         End Set
      End Property

      Property AtividadeEconomicaPessoaFisica As String
         Get
            AtividadeEconomicaPessoaFisica = me.GetString("AtividadeEconomicaPessoaFisica")
         End Get
         Set(pValue As String)
            me.SetString("AtividadeEconomicaPessoaFisica", pValue)
         End Set
      End Property

      Property TipoExploracaoImovelRural As String
         Get
            TipoExploracaoImovelRural = me.GetString("TipoExploracaoImovelRural")
         End Get
         Set(pValue As String)
            me.SetString("TipoExploracaoImovelRural", pValue)
         End Set
      End Property

      Property ParticipacaoImovelRural As Extended
         Get
            ParticipacaoImovelRural = me.GetFloat("ParticipacaoImovelRural")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ParticipacaoImovelRural", pValue)
         End Set
      End Property

      Property Ativo As String
         Get
            Ativo = me.GetString("Ativo")
         End Get
         Set(pValue As String)
            me.SetString("Ativo", pValue)
         End Set
      End Property

      Property LiberacaoFrenteLoja As String
         Get
            LiberacaoFrenteLoja = me.GetString("LiberacaoFrenteLoja")
         End Get
         Set(pValue As String)
            me.SetString("LiberacaoFrenteLoja", pValue)
         End Set
      End Property

      Property CodTipoNFSe As Integer
         Get
            CodTipoNFSe = me.GetInteger("CodTipoNFSe")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTipoNFSe", pValue)
         End Set
      End Property

      Property AliquotaCBS As Extended
         Get
            AliquotaCBS = me.GetFloat("AliquotaCBS")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaCBS", pValue)
         End Set
      End Property

      Property FaixaEnquadramentoSimplesNacional As String
         Get
            FaixaEnquadramentoSimplesNacional = me.GetString("FaixaEnquadramentoSimplesNacional")
         End Get
         Set(pValue As String)
            me.SetString("FaixaEnquadramentoSimplesNacional", pValue)
         End Set
      End Property

      Property CNAESecundario As String
         Get
            CNAESecundario = me.GetString("CNAESecundario")
         End Get
         Set(pValue As String)
            me.SetString("CNAESecundario", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
