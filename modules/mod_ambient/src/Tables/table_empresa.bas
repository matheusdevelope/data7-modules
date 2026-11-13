Imports TablesSchema
Imports TablesTable

Namespace table_empresa

   Class TEmpresa
      Inherits TTableOf<TEmpresa>

      Sub New()
         MyBase.New("TEmpresa")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Empresa"
         pSchema.Field("CodigoRemoto").AsInteger()
         pSchema.Field("CodTabelaPreco").AsInteger()
         pSchema.Field("CodLocalArmazenagem").AsInteger()
         pSchema.Field("CodMunicipio").AsInteger()
         pSchema.Field("CodEmpresa").AsInteger().PrimaryKeyField()
         pSchema.Field("PercentualCustoFixo").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("AliquotaSimples").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("Validador").AsString().MaxLen(100)
         pSchema.Field("Contato").AsString().MaxLen(100)
         pSchema.Field("Old_SenhaCertificadoDigital").AsString().MaxLen(40)
         pSchema.Field("Old_CertificadoDigital").AsString().MaxLen(250)
         pSchema.Field("CNAE").AsString().MaxLen(10)
         pSchema.Field("RegimeTributario").AsString().MaxLen(5).RequiredField()
         pSchema.Field("UF").AsString().MaxLen(2)
         pSchema.Field("FTP").AsString().MaxLen(50)
         pSchema.Field("HomePage").AsString().MaxLen(50)
         pSchema.Field("EMail").AsString().MaxLen(50)
         pSchema.Field("FAX").AsString().MaxLen(30)
         pSchema.Field("Telefone").AsString().MaxLen(30)
         pSchema.Field("DDD").AsString().MaxLen(3)
         pSchema.Field("InscricaoMunicipal").AsString().MaxLen(20)
         pSchema.Field("RG").AsString().MaxLen(20)
         pSchema.Field("InscricaoEstadual").AsString().MaxLen(20)
         pSchema.Field("CNPJ_CPF").AsString().MaxLen(20)
         pSchema.Field("TipoPessoa").AsString().MaxLen(1)
         pSchema.Field("CaixaPostal").AsString().MaxLen(6)
         pSchema.Field("Bairro").AsString().MaxLen(50)
         pSchema.Field("Complemento").AsString().MaxLen(40)
         pSchema.Field("Numero").AsString().MaxLen(6)
         pSchema.Field("Endereco").AsString().MaxLen(60)
         pSchema.Field("CEP").AsString().MaxLen(10)
         pSchema.Field("NomeFantasia").AsString().MaxLen(40).RequiredField()
         pSchema.Field("Nome").AsString().MaxLen(60).RequiredField()
         pSchema.Field("NFEmsgContribuinte").AsString().MaxLen(40)
         pSchema.Field("ResponsavelLegal").AsString().MaxLen(60)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodEmpresa)
      End Function

      Property CodigoRemoto As Integer
         Get
            CodigoRemoto = me.GetInteger("CodigoRemoto")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodigoRemoto", pValue)
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

      Property CodLocalArmazenagem As Integer
         Get
            CodLocalArmazenagem = me.GetInteger("CodLocalArmazenagem")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodLocalArmazenagem", pValue)
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

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("CodEmpresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEmpresa", pValue)
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

      Property AliquotaSimples As Extended
         Get
            AliquotaSimples = me.GetFloat("AliquotaSimples")
         End Get
         Set(pValue As Extended)
            me.SetFloat("AliquotaSimples", pValue)
         End Set
      End Property

      Property Validador As String
         Get
            Validador = me.GetString("Validador")
         End Get
         Set(pValue As String)
            me.SetString("Validador", pValue)
         End Set
      End Property

      Property Contato As String
         Get
            Contato = me.GetString("Contato")
         End Get
         Set(pValue As String)
            me.SetString("Contato", pValue)
         End Set
      End Property

      Property Old_SenhaCertificadoDigital As String
         Get
            Old_SenhaCertificadoDigital = me.GetString("Old_SenhaCertificadoDigital")
         End Get
         Set(pValue As String)
            me.SetString("Old_SenhaCertificadoDigital", pValue)
         End Set
      End Property

      Property Old_CertificadoDigital As String
         Get
            Old_CertificadoDigital = me.GetString("Old_CertificadoDigital")
         End Get
         Set(pValue As String)
            me.SetString("Old_CertificadoDigital", pValue)
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

      Property RegimeTributario As String
         Get
            RegimeTributario = me.GetString("RegimeTributario")
         End Get
         Set(pValue As String)
            me.SetString("RegimeTributario", pValue)
         End Set
      End Property

      Property UF As String
         Get
            UF = me.GetString("UF")
         End Get
         Set(pValue As String)
            me.SetString("UF", pValue)
         End Set
      End Property

      Property FTP As String
         Get
            FTP = me.GetString("FTP")
         End Get
         Set(pValue As String)
            me.SetString("FTP", pValue)
         End Set
      End Property

      Property HomePage As String
         Get
            HomePage = me.GetString("HomePage")
         End Get
         Set(pValue As String)
            me.SetString("HomePage", pValue)
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

      Property FAX As String
         Get
            FAX = me.GetString("FAX")
         End Get
         Set(pValue As String)
            me.SetString("FAX", pValue)
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

      Property DDD As String
         Get
            DDD = me.GetString("DDD")
         End Get
         Set(pValue As String)
            me.SetString("DDD", pValue)
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

      Property RG As String
         Get
            RG = me.GetString("RG")
         End Get
         Set(pValue As String)
            me.SetString("RG", pValue)
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

      Property CNPJ_CPF As String
         Get
            CNPJ_CPF = me.GetString("CNPJ_CPF")
         End Get
         Set(pValue As String)
            me.SetString("CNPJ_CPF", pValue)
         End Set
      End Property

      Property TipoPessoa As String
         Get
            TipoPessoa = me.GetString("TipoPessoa")
         End Get
         Set(pValue As String)
            me.SetString("TipoPessoa", pValue)
         End Set
      End Property

      Property CaixaPostal As String
         Get
            CaixaPostal = me.GetString("CaixaPostal")
         End Get
         Set(pValue As String)
            me.SetString("CaixaPostal", pValue)
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

      Property Complemento As String
         Get
            Complemento = me.GetString("Complemento")
         End Get
         Set(pValue As String)
            me.SetString("Complemento", pValue)
         End Set
      End Property

      Property Numero As String
         Get
            Numero = me.GetString("Numero")
         End Get
         Set(pValue As String)
            me.SetString("Numero", pValue)
         End Set
      End Property

      Property Endereco As String
         Get
            Endereco = me.GetString("Endereco")
         End Get
         Set(pValue As String)
            me.SetString("Endereco", pValue)
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

      Property NomeFantasia As String
         Get
            NomeFantasia = me.GetString("NomeFantasia")
         End Get
         Set(pValue As String)
            me.SetString("NomeFantasia", pValue)
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

      Property NFEmsgContribuinte As String
         Get
            NFEmsgContribuinte = me.GetString("NFEmsgContribuinte")
         End Get
         Set(pValue As String)
            me.SetString("NFEmsgContribuinte", pValue)
         End Set
      End Property

      Property ResponsavelLegal As String
         Get
            ResponsavelLegal = me.GetString("ResponsavelLegal")
         End Get
         Set(pValue As String)
            me.SetString("ResponsavelLegal", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
