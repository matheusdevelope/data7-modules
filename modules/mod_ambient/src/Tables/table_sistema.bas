Imports TablesSchema
Imports TablesTable

Namespace table_sistema

   Class TSistema
      Inherits TTableOf<TSistema>

      Sub New()
         MyBase.New("TSistema")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Sistema"
         pSchema.Field("Versao").AsInteger()
         pSchema.Field("ReleaseDaVersao").AsInteger()
         pSchema.Field("BuilderDaVersao").AsInteger()
         pSchema.Field("NomeComercialPAF").AsString().MaxLen(80)
         pSchema.Field("VersaoPAF").AsString().MaxLen(150)
         pSchema.Field("RazaoSocial").AsString().MaxLen(40)
         pSchema.Field("CNPJ").AsString().MaxLen(20)
         pSchema.Field("Endereco").AsString().MaxLen(60)
         pSchema.Field("Telefone").AsString().MaxLen(15)
         pSchema.Field("Contato").AsString().MaxLen(35)
         pSchema.Field("NumeroLaudo").AsString().MaxLen(15)
         pSchema.Field("DataVersao").AsDate()
         pSchema.Field("HoraVersao").AsString().MaxLen(8)
         pSchema.Field("MenorVersao").AsInteger()
         pSchema.Field("MD5").AsString().MaxLen(50)
         pSchema.Field("MD5Sistema").AsString().MaxLen(50)
         pSchema.Field("HashAtualizaVersao").AsString().MaxLen(60)
      End Sub

      Overrides Function GetID() As String
         GetID = ""
      End Function

      Property Version As String
         Get
            Version = (me.Versao & "." & me.MenorVersao & "." & me.ReleaseDaVersao & "." & me.BuilderDaVersao  )
         End Get
      End Property

      Property Versao As Integer
         Get
            Versao = me.GetInteger("Versao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Versao", pValue)
         End Set
      End Property

      Property ReleaseDaVersao As Integer
         Get
            ReleaseDaVersao = me.GetInteger("ReleaseDaVersao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("ReleaseDaVersao", pValue)
         End Set
      End Property

      Property BuilderDaVersao As Integer
         Get
            BuilderDaVersao = me.GetInteger("BuilderDaVersao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("BuilderDaVersao", pValue)
         End Set
      End Property

      Property NomeComercialPAF As String
         Get
            NomeComercialPAF = me.GetString("NomeComercialPAF")
         End Get
         Set(pValue As String)
            me.SetString("NomeComercialPAF", pValue)
         End Set
      End Property

      Property VersaoPAF As String
         Get
            VersaoPAF = me.GetString("VersaoPAF")
         End Get
         Set(pValue As String)
            me.SetString("VersaoPAF", pValue)
         End Set
      End Property

      Property RazaoSocial As String
         Get
            RazaoSocial = me.GetString("RazaoSocial")
         End Get
         Set(pValue As String)
            me.SetString("RazaoSocial", pValue)
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

      Property Endereco As String
         Get
            Endereco = me.GetString("Endereco")
         End Get
         Set(pValue As String)
            me.SetString("Endereco", pValue)
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

      Property Contato As String
         Get
            Contato = me.GetString("Contato")
         End Get
         Set(pValue As String)
            me.SetString("Contato", pValue)
         End Set
      End Property

      Property NumeroLaudo As String
         Get
            NumeroLaudo = me.GetString("NumeroLaudo")
         End Get
         Set(pValue As String)
            me.SetString("NumeroLaudo", pValue)
         End Set
      End Property

      Property DataVersao As TDateTime
         Get
            DataVersao = me.GetDateTime("DataVersao")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("DataVersao", pValue)
         End Set
      End Property

      Property HoraVersao As String
         Get
            HoraVersao = me.GetString("HoraVersao")
         End Get
         Set(pValue As String)
            me.SetString("HoraVersao", pValue)
         End Set
      End Property

      Property MenorVersao As Integer
         Get
            MenorVersao = me.GetInteger("MenorVersao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("MenorVersao", pValue)
         End Set
      End Property

      Property MD5 As String
         Get
            MD5 = me.GetString("MD5")
         End Get
         Set(pValue As String)
            me.SetString("MD5", pValue)
         End Set
      End Property

      Property MD5Sistema As String
         Get
            MD5Sistema = me.GetString("MD5Sistema")
         End Get
         Set(pValue As String)
            me.SetString("MD5Sistema", pValue)
         End Set
      End Property

      Property HashAtualizaVersao As String
         Get
            HashAtualizaVersao = me.GetString("HashAtualizaVersao")
         End Get
         Set(pValue As String)
            me.SetString("HashAtualizaVersao", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
