Imports TablesSchema
Imports TablesTable

Namespace table_estacao

   Class TEstacao
      Inherits TTableOf<TEstacao>

      Sub New()
         MyBase.New("TEstacao")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Estacao"
         pSchema.Field("CodImpressoraFiscal").AsInteger()
         pSchema.Field("LeitorCMC7_AtrasoLeitura").AsInteger()
         pSchema.Field("LeitorCMC7_BitsDados").AsInteger()
         pSchema.Field("LeitorCMC7_BitsSegundo").AsInteger()
         pSchema.Field("CodBalanca").AsInteger()
         pSchema.Field("TEF_Comprovante_Vias").AsInteger()
         pSchema.Field("ImpressoraCupom").AsInteger()
         pSchema.Field("ImpressoraCheque").AsInteger()
         pSchema.Field("CodEstacao").AsInteger().AutoCodeField()
         pSchema.Field("LeitorCMC7_BitsPorParada").AsFloat().NumericPrec(2, 1)
         pSchema.Field("TEF_Comprovante_Impressora").AsString().MaxLen(1)
         pSchema.Field("TEF_Tipo").AsString().MaxLen(1)
         pSchema.Field("ImpressoraCheque_Modelo").AsString().MaxLen(30)
         pSchema.Field("ImpressoraCheque_Marca").AsString().MaxLen(30)
         pSchema.Field("LeitorCMC7_ControleFluxo").AsString().MaxLen(1)
         pSchema.Field("LeitorCMC7_Paridade").AsString().MaxLen(1)
         pSchema.Field("LeitorCMC7_Modelo").AsString().MaxLen(30)
         pSchema.Field("LeitorCMC7_Marca").AsString().MaxLen(30)
         pSchema.Field("LeitorCMC7_Porta").AsString().MaxLen(5)
         pSchema.Field("MensagemCupomFiscal").AsString().MaxLen(100)
         pSchema.Field("ImpressoraCodigoBarra_Porta").AsString().MaxLen(5)
         pSchema.Field("ImpressoraCodigoBarra_Modelo").AsString().MaxLen(20)
         pSchema.Field("TEF_Pasta_Recepcao").AsString().MaxLen(100)
         pSchema.Field("TEF_Pasta_Transmissao").AsString().MaxLen(100)
         pSchema.Field("Gaveta_Porta").AsString().MaxLen(10)
         pSchema.Field("Gaveta_Modelo").AsString().MaxLen(30)
         pSchema.Field("CartaoMagnetico_Porta").AsString().MaxLen(10)
         pSchema.Field("CartaoMagnetico_Modelo").AsString().MaxLen(30)
         pSchema.Field("CodigoBarra_Porta").AsString().MaxLen(10)
         pSchema.Field("CodigoBarra_Modelo").AsString().MaxLen(30)
         pSchema.Field("PinPad_Mensagem").AsString().MaxLen(20)
         pSchema.Field("PinPad_Porta").AsString().MaxLen(10)
         pSchema.Field("PinPad_Modelo").AsString().MaxLen(30)
         pSchema.Field("ImpressoraCupom_Porta").AsString().MaxLen(10)
         pSchema.Field("ImpressoraCheque_Porta").AsString().MaxLen(10)
         pSchema.Field("ImpressoraFiscal_Serie").AsString().MaxLen(4)
         pSchema.Field("ImpressoraFiscal_Numero").AsString().MaxLen(15)
         pSchema.Field("ImpressoraFiscal_Porta").AsString().MaxLen(10)
         pSchema.Field("ImpressoraFiscal").AsString().MaxLen(2)
         pSchema.Field("Nome").AsString().MaxLen(40).RequiredField()
         pSchema.Field("PinPad_NumeroSerie").AsString().MaxLen(60)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodEstacao)
      End Function

      Property CodImpressoraFiscal As Integer
         Get
            CodImpressoraFiscal = me.GetInteger("CodImpressoraFiscal")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodImpressoraFiscal", pValue)
         End Set
      End Property

      Property LeitorCMC7_AtrasoLeitura As Integer
         Get
            LeitorCMC7_AtrasoLeitura = me.GetInteger("LeitorCMC7_AtrasoLeitura")
         End Get
         Set(pValue As Integer)
            me.SetInteger("LeitorCMC7_AtrasoLeitura", pValue)
         End Set
      End Property

      Property LeitorCMC7_BitsDados As Integer
         Get
            LeitorCMC7_BitsDados = me.GetInteger("LeitorCMC7_BitsDados")
         End Get
         Set(pValue As Integer)
            me.SetInteger("LeitorCMC7_BitsDados", pValue)
         End Set
      End Property

      Property LeitorCMC7_BitsSegundo As Integer
         Get
            LeitorCMC7_BitsSegundo = me.GetInteger("LeitorCMC7_BitsSegundo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("LeitorCMC7_BitsSegundo", pValue)
         End Set
      End Property

      Property CodBalanca As Integer
         Get
            CodBalanca = me.GetInteger("CodBalanca")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodBalanca", pValue)
         End Set
      End Property

      Property TEF_Comprovante_Vias As Integer
         Get
            TEF_Comprovante_Vias = me.GetInteger("TEF_Comprovante_Vias")
         End Get
         Set(pValue As Integer)
            me.SetInteger("TEF_Comprovante_Vias", pValue)
         End Set
      End Property

      Property ImpressoraCupom As Integer
         Get
            ImpressoraCupom = me.GetInteger("ImpressoraCupom")
         End Get
         Set(pValue As Integer)
            me.SetInteger("ImpressoraCupom", pValue)
         End Set
      End Property

      Property ImpressoraCheque As Integer
         Get
            ImpressoraCheque = me.GetInteger("ImpressoraCheque")
         End Get
         Set(pValue As Integer)
            me.SetInteger("ImpressoraCheque", pValue)
         End Set
      End Property

      Property CodEstacao As Integer
         Get
            CodEstacao = me.GetInteger("CodEstacao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEstacao", pValue)
         End Set
      End Property

      Property LeitorCMC7_BitsPorParada As Extended
         Get
            LeitorCMC7_BitsPorParada = me.GetFloat("LeitorCMC7_BitsPorParada")
         End Get
         Set(pValue As Extended)
            me.SetFloat("LeitorCMC7_BitsPorParada", pValue)
         End Set
      End Property

      Property TEF_Comprovante_Impressora As String
         Get
            TEF_Comprovante_Impressora = me.GetString("TEF_Comprovante_Impressora")
         End Get
         Set(pValue As String)
            me.SetString("TEF_Comprovante_Impressora", pValue)
         End Set
      End Property

      Property TEF_Tipo As String
         Get
            TEF_Tipo = me.GetString("TEF_Tipo")
         End Get
         Set(pValue As String)
            me.SetString("TEF_Tipo", pValue)
         End Set
      End Property

      Property ImpressoraCheque_Modelo As String
         Get
            ImpressoraCheque_Modelo = me.GetString("ImpressoraCheque_Modelo")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraCheque_Modelo", pValue)
         End Set
      End Property

      Property ImpressoraCheque_Marca As String
         Get
            ImpressoraCheque_Marca = me.GetString("ImpressoraCheque_Marca")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraCheque_Marca", pValue)
         End Set
      End Property

      Property LeitorCMC7_ControleFluxo As String
         Get
            LeitorCMC7_ControleFluxo = me.GetString("LeitorCMC7_ControleFluxo")
         End Get
         Set(pValue As String)
            me.SetString("LeitorCMC7_ControleFluxo", pValue)
         End Set
      End Property

      Property LeitorCMC7_Paridade As String
         Get
            LeitorCMC7_Paridade = me.GetString("LeitorCMC7_Paridade")
         End Get
         Set(pValue As String)
            me.SetString("LeitorCMC7_Paridade", pValue)
         End Set
      End Property

      Property LeitorCMC7_Modelo As String
         Get
            LeitorCMC7_Modelo = me.GetString("LeitorCMC7_Modelo")
         End Get
         Set(pValue As String)
            me.SetString("LeitorCMC7_Modelo", pValue)
         End Set
      End Property

      Property LeitorCMC7_Marca As String
         Get
            LeitorCMC7_Marca = me.GetString("LeitorCMC7_Marca")
         End Get
         Set(pValue As String)
            me.SetString("LeitorCMC7_Marca", pValue)
         End Set
      End Property

      Property LeitorCMC7_Porta As String
         Get
            LeitorCMC7_Porta = me.GetString("LeitorCMC7_Porta")
         End Get
         Set(pValue As String)
            me.SetString("LeitorCMC7_Porta", pValue)
         End Set
      End Property

      Property MensagemCupomFiscal As String
         Get
            MensagemCupomFiscal = me.GetString("MensagemCupomFiscal")
         End Get
         Set(pValue As String)
            me.SetString("MensagemCupomFiscal", pValue)
         End Set
      End Property

      Property ImpressoraCodigoBarra_Porta As String
         Get
            ImpressoraCodigoBarra_Porta = me.GetString("ImpressoraCodigoBarra_Porta")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraCodigoBarra_Porta", pValue)
         End Set
      End Property

      Property ImpressoraCodigoBarra_Modelo As String
         Get
            ImpressoraCodigoBarra_Modelo = me.GetString("ImpressoraCodigoBarra_Modelo")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraCodigoBarra_Modelo", pValue)
         End Set
      End Property

      Property TEF_Pasta_Recepcao As String
         Get
            TEF_Pasta_Recepcao = me.GetString("TEF_Pasta_Recepcao")
         End Get
         Set(pValue As String)
            me.SetString("TEF_Pasta_Recepcao", pValue)
         End Set
      End Property

      Property TEF_Pasta_Transmissao As String
         Get
            TEF_Pasta_Transmissao = me.GetString("TEF_Pasta_Transmissao")
         End Get
         Set(pValue As String)
            me.SetString("TEF_Pasta_Transmissao", pValue)
         End Set
      End Property

      Property Gaveta_Porta As String
         Get
            Gaveta_Porta = me.GetString("Gaveta_Porta")
         End Get
         Set(pValue As String)
            me.SetString("Gaveta_Porta", pValue)
         End Set
      End Property

      Property Gaveta_Modelo As String
         Get
            Gaveta_Modelo = me.GetString("Gaveta_Modelo")
         End Get
         Set(pValue As String)
            me.SetString("Gaveta_Modelo", pValue)
         End Set
      End Property

      Property CartaoMagnetico_Porta As String
         Get
            CartaoMagnetico_Porta = me.GetString("CartaoMagnetico_Porta")
         End Get
         Set(pValue As String)
            me.SetString("CartaoMagnetico_Porta", pValue)
         End Set
      End Property

      Property CartaoMagnetico_Modelo As String
         Get
            CartaoMagnetico_Modelo = me.GetString("CartaoMagnetico_Modelo")
         End Get
         Set(pValue As String)
            me.SetString("CartaoMagnetico_Modelo", pValue)
         End Set
      End Property

      Property CodigoBarra_Porta As String
         Get
            CodigoBarra_Porta = me.GetString("CodigoBarra_Porta")
         End Get
         Set(pValue As String)
            me.SetString("CodigoBarra_Porta", pValue)
         End Set
      End Property

      Property CodigoBarra_Modelo As String
         Get
            CodigoBarra_Modelo = me.GetString("CodigoBarra_Modelo")
         End Get
         Set(pValue As String)
            me.SetString("CodigoBarra_Modelo", pValue)
         End Set
      End Property

      Property PinPad_Mensagem As String
         Get
            PinPad_Mensagem = me.GetString("PinPad_Mensagem")
         End Get
         Set(pValue As String)
            me.SetString("PinPad_Mensagem", pValue)
         End Set
      End Property

      Property PinPad_Porta As String
         Get
            PinPad_Porta = me.GetString("PinPad_Porta")
         End Get
         Set(pValue As String)
            me.SetString("PinPad_Porta", pValue)
         End Set
      End Property

      Property PinPad_Modelo As String
         Get
            PinPad_Modelo = me.GetString("PinPad_Modelo")
         End Get
         Set(pValue As String)
            me.SetString("PinPad_Modelo", pValue)
         End Set
      End Property

      Property ImpressoraCupom_Porta As String
         Get
            ImpressoraCupom_Porta = me.GetString("ImpressoraCupom_Porta")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraCupom_Porta", pValue)
         End Set
      End Property

      Property ImpressoraCheque_Porta As String
         Get
            ImpressoraCheque_Porta = me.GetString("ImpressoraCheque_Porta")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraCheque_Porta", pValue)
         End Set
      End Property

      Property ImpressoraFiscal_Serie As String
         Get
            ImpressoraFiscal_Serie = me.GetString("ImpressoraFiscal_Serie")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraFiscal_Serie", pValue)
         End Set
      End Property

      Property ImpressoraFiscal_Numero As String
         Get
            ImpressoraFiscal_Numero = me.GetString("ImpressoraFiscal_Numero")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraFiscal_Numero", pValue)
         End Set
      End Property

      Property ImpressoraFiscal_Porta As String
         Get
            ImpressoraFiscal_Porta = me.GetString("ImpressoraFiscal_Porta")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraFiscal_Porta", pValue)
         End Set
      End Property

      Property ImpressoraFiscal As String
         Get
            ImpressoraFiscal = me.GetString("ImpressoraFiscal")
         End Get
         Set(pValue As String)
            me.SetString("ImpressoraFiscal", pValue)
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

      Property PinPad_NumeroSerie As String
         Get
            PinPad_NumeroSerie = me.GetString("PinPad_NumeroSerie")
         End Get
         Set(pValue As String)
            me.SetString("PinPad_NumeroSerie", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
