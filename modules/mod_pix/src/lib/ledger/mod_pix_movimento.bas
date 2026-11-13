Imports TablesSchema
Imports TablesTable

Namespace mod_pix_ledger

   Class MovimentoPix
      Inherits TTableOf<MovimentoPix>

      Sub New()
         MyBase.New("MovimentoPix")
      End Sub

      Sub New(pValue As MovimentoPix)
         MyBase.New("MovimentoPix")
         If Assigned(pValue) Then
            me.AssignFrom(pValue)
         End If
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.SchemaName = "Financeiro"
         pSchema.TableName = "MovimentoPix"
         pSchema.Field("CodEmpresa").AsInteger().PrimaryKeyField()
         pSchema.Field("CodMovimentoPix").AsInteger().PrimaryKeyField()
         pSchema.Field("CodFilial").AsInteger().NotUpdatable()
         pSchema.Field("CodContaFinanceira").AsString().MaxLen(50).NotUpdatable()
         pSchema.Field("TxID").AsString().MaxLen(35).NotUpdatable()
         pSchema.Field("EndToEndID").AsString().MaxLen(32)
         pSchema.Field("IDDevolucao").AsString().MaxLen(35)
         pSchema.Field("PixCopiaECola").AsString().MaxLen(1000)
         pSchema.Field("Valor").AsFloat()
         pSchema.Field("Status").AsString().MaxLen(50)
         pSchema.Field("StatusDevolucao").AsString().MaxLen(50)
         pSchema.Field("DataCriacao").AsDateTime()
         pSchema.Field("DataExpiracao").AsDateTime()
         pSchema.Field("DataCancelamento").AsDateTime()
         pSchema.Field("DataDevolucao").AsDateTime()
         pSchema.Field("Data").AsDateTime().NotUpdatable()
         pSchema.Field("Hora").AsString().MaxLen(8).NotUpdatable()
         pSchema.Field("NomeUsuario").AsString().MaxLen(100).NotUpdatable()
         pSchema.Field("EstacaoTrabalho").AsString().MaxLen(100).NotUpdatable()
      End Sub

      Shared Function Initilized(pCodEmpresa As Integer, pCodFilial As Integer, pCodMovimentoPix As Integer = 0) As MovimentoPix
         Dim row As New MovimentoPix()
         row.CodEmpresa = pCodEmpresa
         row.CodFilial = pCodFilial
         If pCodMovimentoPix > 0 Then
            row.CodMovimentoPix = pCodMovimentoPix
         End If
         row.EnsureIdentity()
         Initilized = row
      End Function

      Overrides Sub BeforeInsert()
         me.EnsureIdentity()
      End Sub

      Overrides Sub BeforeMerge()
         me.EnsureIdentity()
      End Sub

      Private Sub EnsureIdentity()
         If me.CodMovimentoPix = 0 Then
            me.CodMovimentoPix = Data7.ProximoCodigo("MovimentoPix", me.CodEmpresa)
         End If
         If Trim(me.Hora) = "" Then
            me.Data = DateTime()
            me.Hora = me.Data.ToString("hh:nn:ss")
         End If
         If Trim(me.NomeUsuario) = "" Then
            me.NomeUsuario = Data7.NomeUsuario
         End If
         If Trim(me.EstacaoTrabalho) = "" Then
            me.EstacaoTrabalho = Environment.MachineName
         End If
      End Sub

      Sub Fill(pValue As MovimentoPix)
         If Assigned(pValue) Then
            me.AssignFrom(pValue)
         End If
      End Sub

      Function Copy() As MovimentoPix
         Copy = MovimentoPix(me.Clone())
      End Function

      Overrides Function GetID() As String
         GetID = CStr(me.CodEmpresa) & "|" & CStr(me.CodMovimentoPix)
      End Function

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me.GetInteger("CodEmpresa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodEmpresa", pValue)
         End Set
      End Property

      Property CodMovimentoPix As Integer
         Get
            CodMovimentoPix = me.GetInteger("CodMovimentoPix")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodMovimentoPix", pValue)
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

      Property CodContaFinanceira As String
         Get
            CodContaFinanceira = me.GetString("CodContaFinanceira")
         End Get
         Set(pValue As String)
            me.SetString("CodContaFinanceira", pValue)
         End Set
      End Property

      Property TxID As String
         Get
            TxID = me.GetString("TxID")
         End Get
         Set(pValue As String)
            me.SetString("TxID", pValue)
         End Set
      End Property

      Property EndToEndID As String
         Get
            EndToEndID = me.GetString("EndToEndID")
         End Get
         Set(pValue As String)
            me.SetString("EndToEndID", pValue)
         End Set
      End Property

      Property IDDevolucao As String
         Get
            IDDevolucao = me.GetString("IDDevolucao")
         End Get
         Set(pValue As String)
            me.SetString("IDDevolucao", pValue)
         End Set
      End Property

      Property PixCopiaECola As String
         Get
            PixCopiaECola = me.GetString("PixCopiaECola")
         End Get
         Set(pValue As String)
            me.SetString("PixCopiaECola", pValue)
         End Set
      End Property

      Property Valor As Extended
         Get
            Valor = me.GetFloat("Valor")
         End Get
         Set(pValue As Extended)
            me.SetFloat("Valor", pValue)
         End Set
      End Property

      Property Status As String
         Get
            Status = me.GetString("Status")
         End Get
         Set(pValue As String)
            me.SetString("Status", pValue)
         End Set
      End Property

      Property StatusDevolucao As String
         Get
            StatusDevolucao = me.GetString("StatusDevolucao")
         End Get
         Set(pValue As String)
            me.SetString("StatusDevolucao", pValue)
         End Set
      End Property

      Property DataCriacao As TDateTime
         Get
            DataCriacao = me.GetDateTime("DataCriacao")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("DataCriacao", pValue)
         End Set
      End Property

      Property DataExpiracao As TDateTime
         Get
            DataExpiracao = me.GetDateTime("DataExpiracao")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("DataExpiracao", pValue)
         End Set
      End Property

      Property DataCancelamento As TDateTime
         Get
            DataCancelamento = me.GetDateTime("DataCancelamento")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("DataCancelamento", pValue)
         End Set
      End Property

      Property DataDevolucao As TDateTime
         Get
            DataDevolucao = me.GetDateTime("DataDevolucao")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("DataDevolucao", pValue)
         End Set
      End Property

      Property Data As TDateTime
         Get
            Data = me.GetDateTime("Data")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("Data", pValue)
         End Set
      End Property

      Property Hora As String
         Get
            Hora = me.GetString("Hora")
         End Get
         Set(pValue As String)
            me.SetString("Hora", pValue)
         End Set
      End Property

      Property NomeUsuario As String
         Get
            NomeUsuario = me.GetString("NomeUsuario")
         End Get
         Set(pValue As String)
            me.SetString("NomeUsuario", pValue)
         End Set
      End Property

      Property EstacaoTrabalho As String
         Get
            EstacaoTrabalho = me.GetString("EstacaoTrabalho")
         End Get
         Set(pValue As String)
            me.SetString("EstacaoTrabalho", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
