Imports TablesSchema
Imports TablesTable

Namespace table_periodocaixa

   Class TPeriodoCaixa
      Inherits TTableOf<TPeriodoCaixa>

      Sub New()
         MyBase.New("TPeriodoCaixa")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "PeriodoCaixa"
         pSchema.Field("CodEmpresa").AsInteger().PrimaryKeyField()
         pSchema.Field("CodPeriodoCaixa").AsInteger().AutoCodeField()
         pSchema.Field("CodContaFinanceira").AsString().MaxLen(6).RequiredField()
         pSchema.Field("CodUsuarioAbertura").AsInteger().RequiredField()
         pSchema.Field("NomeUsuarioAbertura").AsString().MaxLen(20).RequiredField()
         pSchema.Field("DataAbertura").AsDate().RequiredField()
         pSchema.Field("HoraAbertura").AsDateTime().RequiredField()
         pSchema.Field("DataFechamento").AsDate()
         pSchema.Field("HoraFechamento").AsDateTime()
         pSchema.Field("SaldoAbertura").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("TrocoAbertura").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("EstacaoTrabalhoAbertura").AsString().MaxLen(20).RequiredField()
         pSchema.Field("CodUsuarioFechamento").AsInteger()
         pSchema.Field("NomeUsuarioFechamento").AsString().MaxLen(20)
         pSchema.Field("SaldoAntesFechamento").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("EstacaoTrabalhoFechamento").AsString().MaxLen(20)
         pSchema.Field("QtdaMoeda01").AsInteger().RequiredField()
         pSchema.Field("QtdaMoeda05").AsInteger().RequiredField()
         pSchema.Field("QtdaMoeda10").AsInteger().RequiredField()
         pSchema.Field("QtdaMoeda25").AsInteger().RequiredField()
         pSchema.Field("QtdaMoeda50").AsInteger().RequiredField()
         pSchema.Field("QtdaMoeda1").AsInteger().RequiredField()
         pSchema.Field("QtdaTotalMoeda").AsInteger().RequiredField()
         pSchema.Field("ValorTotalMoeda").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaNota1").AsInteger().RequiredField()
         pSchema.Field("QtdaNota2").AsInteger().RequiredField()
         pSchema.Field("QtdaNota5").AsInteger().RequiredField()
         pSchema.Field("QtdaNota10").AsInteger().RequiredField()
         pSchema.Field("QtdaNota20").AsInteger().RequiredField()
         pSchema.Field("QtdaNota50").AsInteger().RequiredField()
         pSchema.Field("QtdaNota100").AsInteger().RequiredField()
         pSchema.Field("QtdaTotalNota").AsInteger().RequiredField()
         pSchema.Field("ValorTotalNota").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaCheque").AsInteger().RequiredField()
         pSchema.Field("ValorCheque").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaCartaoCredito").AsInteger().RequiredField()
         pSchema.Field("ValorCartaoCredito").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaCartaoDebito").AsInteger().RequiredField()
         pSchema.Field("ValorCartaoDebito").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaVale").AsInteger().RequiredField()
         pSchema.Field("ValorVale").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaTicket").AsInteger().RequiredField()
         pSchema.Field("ValorTicket").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaNotaCliente").AsInteger().RequiredField()
         pSchema.Field("ValorNotaCliente").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaOutros").AsInteger().RequiredField()
         pSchema.Field("ValorOutros").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("QtdaTotalOutros").AsInteger().RequiredField()
         pSchema.Field("ValorTotalOutros").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("SaldoContagem").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("DiferencaSaldo").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("SaldoAposFechamento").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("ValorSangria").AsFloat().NumericPrec(25, 10).RequiredField()
         pSchema.Field("CodContaFinanceiraTransferencia").AsString().MaxLen(6)
         pSchema.Field("TipoTransferencia").AsString().MaxLen(1)
         pSchema.Field("CodLocalArmazenagem").AsInteger()
         pSchema.Field("QtdaNota200").AsInteger()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodEmpresa) & "|" & CStr(me.CodPeriodoCaixa)
      End Function

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("CodEmpresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEmpresa", pValue)
         End Set
      End Property

      Property CodPeriodoCaixa As Integer
         Get
            CodPeriodoCaixa = me.GetInteger("CodPeriodoCaixa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPeriodoCaixa", pValue)
         End Set
      End Property

      Property CodContaFinanceira As String
         Get
            CodContaFinanceira = me.GetString("CodContaFinanceira")
         End Get
         Set(pValue As String)
            me.SetString("CodContaFinanceira", pValue)
         End Set
      End Property

      Property CodUsuarioAbertura As Integer
         Get
            CodUsuarioAbertura = me.GetInteger("CodUsuarioAbertura")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodUsuarioAbertura", pValue)
         End Set
      End Property

      Property NomeUsuarioAbertura As String
         Get
            NomeUsuarioAbertura = me.GetString("NomeUsuarioAbertura")
         End Get
         Set(pValue As String)
            me.SetString("NomeUsuarioAbertura", pValue)
         End Set
      End Property

      Property DataAbertura As TDateTime
         Get
            DataAbertura = me.GetDateTime("DataAbertura")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("DataAbertura", pValue)
         End Set
      End Property

      Property HoraAbertura As TDateTime
         Get
            HoraAbertura = me.GetDateTime("HoraAbertura")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("HoraAbertura", pValue)
         End Set
      End Property

      Property DataFechamento As TDateTime
         Get
            DataFechamento = me.GetDateTime("DataFechamento")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("DataFechamento", pValue)
         End Set
      End Property

      Property HoraFechamento As TDateTime
         Get
            HoraFechamento = me.GetDateTime("HoraFechamento")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("HoraFechamento", pValue)
         End Set
      End Property

      Property SaldoAbertura As Extended
         Get
            SaldoAbertura = me.GetFloat("SaldoAbertura")
         End Get
         Set(pValue As Extended)
            me.SetFloat("SaldoAbertura", pValue)
         End Set
      End Property

      Property TrocoAbertura As Extended
         Get
            TrocoAbertura = me.GetFloat("TrocoAbertura")
         End Get
         Set(pValue As Extended)
            me.SetFloat("TrocoAbertura", pValue)
         End Set
      End Property

      Property EstacaoTrabalhoAbertura As String
         Get
            EstacaoTrabalhoAbertura = me.GetString("EstacaoTrabalhoAbertura")
         End Get
         Set(pValue As String)
            me.SetString("EstacaoTrabalhoAbertura", pValue)
         End Set
      End Property

      Property CodUsuarioFechamento As Integer
         Get
            CodUsuarioFechamento = me.GetInteger("CodUsuarioFechamento")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodUsuarioFechamento", pValue)
         End Set
      End Property

      Property NomeUsuarioFechamento As String
         Get
            NomeUsuarioFechamento = me.GetString("NomeUsuarioFechamento")
         End Get
         Set(pValue As String)
            me.SetString("NomeUsuarioFechamento", pValue)
         End Set
      End Property

      Property SaldoAntesFechamento As Extended
         Get
            SaldoAntesFechamento = me.GetFloat("SaldoAntesFechamento")
         End Get
         Set(pValue As Extended)
            me.SetFloat("SaldoAntesFechamento", pValue)
         End Set
      End Property

      Property EstacaoTrabalhoFechamento As String
         Get
            EstacaoTrabalhoFechamento = me.GetString("EstacaoTrabalhoFechamento")
         End Get
         Set(pValue As String)
            me.SetString("EstacaoTrabalhoFechamento", pValue)
         End Set
      End Property

      Property QtdaMoeda01 As Integer
         Get
            QtdaMoeda01 = me.GetInteger("QtdaMoeda01")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaMoeda01", pValue)
         End Set
      End Property

      Property QtdaMoeda05 As Integer
         Get
            QtdaMoeda05 = me.GetInteger("QtdaMoeda05")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaMoeda05", pValue)
         End Set
      End Property

      Property QtdaMoeda10 As Integer
         Get
            QtdaMoeda10 = me.GetInteger("QtdaMoeda10")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaMoeda10", pValue)
         End Set
      End Property

      Property QtdaMoeda25 As Integer
         Get
            QtdaMoeda25 = me.GetInteger("QtdaMoeda25")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaMoeda25", pValue)
         End Set
      End Property

      Property QtdaMoeda50 As Integer
         Get
            QtdaMoeda50 = me.GetInteger("QtdaMoeda50")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaMoeda50", pValue)
         End Set
      End Property

      Property QtdaMoeda1 As Integer
         Get
            QtdaMoeda1 = me.GetInteger("QtdaMoeda1")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaMoeda1", pValue)
         End Set
      End Property

      Property QtdaTotalMoeda As Integer
         Get
            QtdaTotalMoeda = me.GetInteger("QtdaTotalMoeda")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaTotalMoeda", pValue)
         End Set
      End Property

      Property ValorTotalMoeda As Extended
         Get
            ValorTotalMoeda = me.GetFloat("ValorTotalMoeda")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorTotalMoeda", pValue)
         End Set
      End Property

      Property QtdaNota1 As Integer
         Get
            QtdaNota1 = me.GetInteger("QtdaNota1")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota1", pValue)
         End Set
      End Property

      Property QtdaNota2 As Integer
         Get
            QtdaNota2 = me.GetInteger("QtdaNota2")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota2", pValue)
         End Set
      End Property

      Property QtdaNota5 As Integer
         Get
            QtdaNota5 = me.GetInteger("QtdaNota5")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota5", pValue)
         End Set
      End Property

      Property QtdaNota10 As Integer
         Get
            QtdaNota10 = me.GetInteger("QtdaNota10")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota10", pValue)
         End Set
      End Property

      Property QtdaNota20 As Integer
         Get
            QtdaNota20 = me.GetInteger("QtdaNota20")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota20", pValue)
         End Set
      End Property

      Property QtdaNota50 As Integer
         Get
            QtdaNota50 = me.GetInteger("QtdaNota50")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota50", pValue)
         End Set
      End Property

      Property QtdaNota100 As Integer
         Get
            QtdaNota100 = me.GetInteger("QtdaNota100")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota100", pValue)
         End Set
      End Property

      Property QtdaTotalNota As Integer
         Get
            QtdaTotalNota = me.GetInteger("QtdaTotalNota")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaTotalNota", pValue)
         End Set
      End Property

      Property ValorTotalNota As Extended
         Get
            ValorTotalNota = me.GetFloat("ValorTotalNota")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorTotalNota", pValue)
         End Set
      End Property

      Property QtdaCheque As Integer
         Get
            QtdaCheque = me.GetInteger("QtdaCheque")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaCheque", pValue)
         End Set
      End Property

      Property ValorCheque As Extended
         Get
            ValorCheque = me.GetFloat("ValorCheque")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorCheque", pValue)
         End Set
      End Property

      Property QtdaCartaoCredito As Integer
         Get
            QtdaCartaoCredito = me.GetInteger("QtdaCartaoCredito")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaCartaoCredito", pValue)
         End Set
      End Property

      Property ValorCartaoCredito As Extended
         Get
            ValorCartaoCredito = me.GetFloat("ValorCartaoCredito")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorCartaoCredito", pValue)
         End Set
      End Property

      Property QtdaCartaoDebito As Integer
         Get
            QtdaCartaoDebito = me.GetInteger("QtdaCartaoDebito")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaCartaoDebito", pValue)
         End Set
      End Property

      Property ValorCartaoDebito As Extended
         Get
            ValorCartaoDebito = me.GetFloat("ValorCartaoDebito")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorCartaoDebito", pValue)
         End Set
      End Property

      Property QtdaVale As Integer
         Get
            QtdaVale = me.GetInteger("QtdaVale")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaVale", pValue)
         End Set
      End Property

      Property ValorVale As Extended
         Get
            ValorVale = me.GetFloat("ValorVale")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorVale", pValue)
         End Set
      End Property

      Property QtdaTicket As Integer
         Get
            QtdaTicket = me.GetInteger("QtdaTicket")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaTicket", pValue)
         End Set
      End Property

      Property ValorTicket As Extended
         Get
            ValorTicket = me.GetFloat("ValorTicket")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorTicket", pValue)
         End Set
      End Property

      Property QtdaNotaCliente As Integer
         Get
            QtdaNotaCliente = me.GetInteger("QtdaNotaCliente")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNotaCliente", pValue)
         End Set
      End Property

      Property ValorNotaCliente As Extended
         Get
            ValorNotaCliente = me.GetFloat("ValorNotaCliente")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorNotaCliente", pValue)
         End Set
      End Property

      Property QtdaOutros As Integer
         Get
            QtdaOutros = me.GetInteger("QtdaOutros")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaOutros", pValue)
         End Set
      End Property

      Property ValorOutros As Extended
         Get
            ValorOutros = me.GetFloat("ValorOutros")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorOutros", pValue)
         End Set
      End Property

      Property QtdaTotalOutros As Integer
         Get
            QtdaTotalOutros = me.GetInteger("QtdaTotalOutros")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaTotalOutros", pValue)
         End Set
      End Property

      Property ValorTotalOutros As Extended
         Get
            ValorTotalOutros = me.GetFloat("ValorTotalOutros")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorTotalOutros", pValue)
         End Set
      End Property

      Property SaldoContagem As Extended
         Get
            SaldoContagem = me.GetFloat("SaldoContagem")
         End Get
         Set(pValue As Extended)
            me.SetFloat("SaldoContagem", pValue)
         End Set
      End Property

      Property DiferencaSaldo As Extended
         Get
            DiferencaSaldo = me.GetFloat("DiferencaSaldo")
         End Get
         Set(pValue As Extended)
            me.SetFloat("DiferencaSaldo", pValue)
         End Set
      End Property

      Property SaldoAposFechamento As Extended
         Get
            SaldoAposFechamento = me.GetFloat("SaldoAposFechamento")
         End Get
         Set(pValue As Extended)
            me.SetFloat("SaldoAposFechamento", pValue)
         End Set
      End Property

      Property ValorSangria As Extended
         Get
            ValorSangria = me.GetFloat("ValorSangria")
         End Get
         Set(pValue As Extended)
            me.SetFloat("ValorSangria", pValue)
         End Set
      End Property

      Property CodContaFinanceiraTransferencia As String
         Get
            CodContaFinanceiraTransferencia = me.GetString("CodContaFinanceiraTransferencia")
         End Get
         Set(pValue As String)
            me.SetString("CodContaFinanceiraTransferencia", pValue)
         End Set
      End Property

      Property TipoTransferencia As String
         Get
            TipoTransferencia = me.GetString("TipoTransferencia")
         End Get
         Set(pValue As String)
            me.SetString("TipoTransferencia", pValue)
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

      Property QtdaNota200 As Integer
         Get
            QtdaNota200 = me.GetInteger("QtdaNota200")
         End Get
         Set(pValue As Integer)
            me.SetInteger("QtdaNota200", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
