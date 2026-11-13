Imports TablesSchema
Imports TablesTable

Namespace table_usuario

   Class TUsuario
      Inherits TTableOf<TUsuario>

      Sub New()
         MyBase.New("TUsuario")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Usuario"
         pSchema.Field("CodUsuario").AsInteger().AutoCodeField()
         pSchema.Field("Nome").AsString().MaxLen(500).RequiredField()
         pSchema.Field("NomeLegivel").AsString().MaxLen(500).RequiredField()
         pSchema.Field("NomeCompleto").AsString().MaxLen(2000).RequiredField()
         pSchema.Field("Senha").AsString().MaxLen(200).RequiredField()
         pSchema.Field("Bloqueado").AsString().MaxLen(200).RequiredField()
         pSchema.Field("DataValidade").AsString().MaxLen(200)
         pSchema.Field("PodeAlterarSenha").AsString().MaxLen(200).RequiredField()
         pSchema.Field("AlterarSenhaProximoLogin").AsString().MaxLen(200).RequiredField()
         pSchema.Field("Departamento").AsString().MaxLen(200)
         pSchema.Field("Cargo").AsString().MaxLen(200)
         pSchema.Field("E_MAIL").AsString().MaxLen(200)
         pSchema.Field("NomeSuperior").AsString().MaxLen(200)
         pSchema.Field("Domingo_Inicio").AsString().MaxLen(5)
         pSchema.Field("Domingo_Fim").AsString().MaxLen(5)
         pSchema.Field("Segunda_Inicio").AsString().MaxLen(5)
         pSchema.Field("Segunda_Fim").AsString().MaxLen(5)
         pSchema.Field("Terca_Inicio").AsString().MaxLen(5)
         pSchema.Field("Terca_Fim").AsString().MaxLen(5)
         pSchema.Field("Quarta_Inicio").AsString().MaxLen(5)
         pSchema.Field("Quarta_Fim").AsString().MaxLen(5)
         pSchema.Field("Quinta_Inicio").AsString().MaxLen(5)
         pSchema.Field("Quinta_Fim").AsString().MaxLen(5)
         pSchema.Field("Sexta_Inicio").AsString().MaxLen(5)
         pSchema.Field("Sexta_Fim").AsString().MaxLen(5)
         pSchema.Field("Sabado_Inicio").AsString().MaxLen(5)
         pSchema.Field("Sabado_Fim").AsString().MaxLen(5)
         pSchema.Field("Grupo").AsString().MaxLen(1)
         pSchema.Field("Documento").AsString().MaxLen(200)
         pSchema.Field("CodCentroCusto").AsInteger()
         pSchema.Field("LogProcessosAtivo").AsString().MaxLen(1)
         pSchema.Field("LogInclusaoAtivo").AsString().MaxLen(1)
         pSchema.Field("LogAlteracaoAtivo").AsString().MaxLen(1)
         pSchema.Field("LogExclusaoAtivo").AsString().MaxLen(1)
         pSchema.Field("LogRelatorioAtivo").AsString().MaxLen(1)
         pSchema.Field("LogTransacaoAtivo").AsString().MaxLen(1)
         pSchema.Field("LogRespostaParametroAtivo").AsString().MaxLen(1)
         pSchema.Field("MenuUsuarioHabilitado").AsString().MaxLen(1)
         pSchema.Field("AcessoFrenteLoja").AsString().MaxLen(10).RequiredField()
         pSchema.Field("PercentualDescontoFrenteLoja").AsString().MaxLen(10).RequiredField()
         pSchema.Field("CodConfiguracaoEnvioEmail").AsInteger()
         pSchema.Field("PercentualDescontoContaReceberFrenteLoja").AsString().MaxLen(10)
         pSchema.Field("AcessoSupervisorFrenteLoja").AsString().MaxLen(10)
         pSchema.Field("AssinaturaMensagem").AsString().MaxLen(2000)
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodUsuario)
      End Function

      Property CodUsuario As Integer
         Get
            CodUsuario = me.GetInteger("CodUsuario")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodUsuario", pValue)
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

      Property NomeLegivel As String
         Get
            NomeLegivel = me.GetString("NomeLegivel")
         End Get
         Set(pValue As String)
            me.SetString("NomeLegivel", pValue)
         End Set
      End Property

      Property NomeCompleto As String
         Get
            NomeCompleto = me.GetString("NomeCompleto")
         End Get
         Set(pValue As String)
            me.SetString("NomeCompleto", pValue)
         End Set
      End Property

      Property Senha As String
         Get
            Senha = me.GetString("Senha")
         End Get
         Set(pValue As String)
            me.SetString("Senha", pValue)
         End Set
      End Property

      Property Bloqueado As String
         Get
            Bloqueado = me.GetString("Bloqueado")
         End Get
         Set(pValue As String)
            me.SetString("Bloqueado", pValue)
         End Set
      End Property

      Property DataValidade As String
         Get
            DataValidade = me.GetString("DataValidade")
         End Get
         Set(pValue As String)
            me.SetString("DataValidade", pValue)
         End Set
      End Property

      Property PodeAlterarSenha As String
         Get
            PodeAlterarSenha = me.GetString("PodeAlterarSenha")
         End Get
         Set(pValue As String)
            me.SetString("PodeAlterarSenha", pValue)
         End Set
      End Property

      Property AlterarSenhaProximoLogin As String
         Get
            AlterarSenhaProximoLogin = me.GetString("AlterarSenhaProximoLogin")
         End Get
         Set(pValue As String)
            me.SetString("AlterarSenhaProximoLogin", pValue)
         End Set
      End Property

      Property Departamento As String
         Get
            Departamento = me.GetString("Departamento")
         End Get
         Set(pValue As String)
            me.SetString("Departamento", pValue)
         End Set
      End Property

      Property Cargo As String
         Get
            Cargo = me.GetString("Cargo")
         End Get
         Set(pValue As String)
            me.SetString("Cargo", pValue)
         End Set
      End Property

      Property E_MAIL As String
         Get
            E_MAIL = me.GetString("E_MAIL")
         End Get
         Set(pValue As String)
            me.SetString("E_MAIL", pValue)
         End Set
      End Property

      Property NomeSuperior As String
         Get
            NomeSuperior = me.GetString("NomeSuperior")
         End Get
         Set(pValue As String)
            me.SetString("NomeSuperior", pValue)
         End Set
      End Property

      Property Domingo_Inicio As String
         Get
            Domingo_Inicio = me.GetString("Domingo_Inicio")
         End Get
         Set(pValue As String)
            me.SetString("Domingo_Inicio", pValue)
         End Set
      End Property

      Property Domingo_Fim As String
         Get
            Domingo_Fim = me.GetString("Domingo_Fim")
         End Get
         Set(pValue As String)
            me.SetString("Domingo_Fim", pValue)
         End Set
      End Property

      Property Segunda_Inicio As String
         Get
            Segunda_Inicio = me.GetString("Segunda_Inicio")
         End Get
         Set(pValue As String)
            me.SetString("Segunda_Inicio", pValue)
         End Set
      End Property

      Property Segunda_Fim As String
         Get
            Segunda_Fim = me.GetString("Segunda_Fim")
         End Get
         Set(pValue As String)
            me.SetString("Segunda_Fim", pValue)
         End Set
      End Property

      Property Terca_Inicio As String
         Get
            Terca_Inicio = me.GetString("Terca_Inicio")
         End Get
         Set(pValue As String)
            me.SetString("Terca_Inicio", pValue)
         End Set
      End Property

      Property Terca_Fim As String
         Get
            Terca_Fim = me.GetString("Terca_Fim")
         End Get
         Set(pValue As String)
            me.SetString("Terca_Fim", pValue)
         End Set
      End Property

      Property Quarta_Inicio As String
         Get
            Quarta_Inicio = me.GetString("Quarta_Inicio")
         End Get
         Set(pValue As String)
            me.SetString("Quarta_Inicio", pValue)
         End Set
      End Property

      Property Quarta_Fim As String
         Get
            Quarta_Fim = me.GetString("Quarta_Fim")
         End Get
         Set(pValue As String)
            me.SetString("Quarta_Fim", pValue)
         End Set
      End Property

      Property Quinta_Inicio As String
         Get
            Quinta_Inicio = me.GetString("Quinta_Inicio")
         End Get
         Set(pValue As String)
            me.SetString("Quinta_Inicio", pValue)
         End Set
      End Property

      Property Quinta_Fim As String
         Get
            Quinta_Fim = me.GetString("Quinta_Fim")
         End Get
         Set(pValue As String)
            me.SetString("Quinta_Fim", pValue)
         End Set
      End Property

      Property Sexta_Inicio As String
         Get
            Sexta_Inicio = me.GetString("Sexta_Inicio")
         End Get
         Set(pValue As String)
            me.SetString("Sexta_Inicio", pValue)
         End Set
      End Property

      Property Sexta_Fim As String
         Get
            Sexta_Fim = me.GetString("Sexta_Fim")
         End Get
         Set(pValue As String)
            me.SetString("Sexta_Fim", pValue)
         End Set
      End Property

      Property Sabado_Inicio As String
         Get
            Sabado_Inicio = me.GetString("Sabado_Inicio")
         End Get
         Set(pValue As String)
            me.SetString("Sabado_Inicio", pValue)
         End Set
      End Property

      Property Sabado_Fim As String
         Get
            Sabado_Fim = me.GetString("Sabado_Fim")
         End Get
         Set(pValue As String)
            me.SetString("Sabado_Fim", pValue)
         End Set
      End Property

      Property Grupo As String
         Get
            Grupo = me.GetString("Grupo")
         End Get
         Set(pValue As String)
            me.SetString("Grupo", pValue)
         End Set
      End Property

      Property Documento As String
         Get
            Documento = me.GetString("Documento")
         End Get
         Set(pValue As String)
            me.SetString("Documento", pValue)
         End Set
      End Property

      Property CodCentroCusto As Integer
         Get
            CodCentroCusto = me.GetInteger("CodCentroCusto")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCentroCusto", pValue)
         End Set
      End Property

      Property LogProcessosAtivo As String
         Get
            LogProcessosAtivo = me.GetString("LogProcessosAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogProcessosAtivo", pValue)
         End Set
      End Property

      Property LogInclusaoAtivo As String
         Get
            LogInclusaoAtivo = me.GetString("LogInclusaoAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogInclusaoAtivo", pValue)
         End Set
      End Property

      Property LogAlteracaoAtivo As String
         Get
            LogAlteracaoAtivo = me.GetString("LogAlteracaoAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogAlteracaoAtivo", pValue)
         End Set
      End Property

      Property LogExclusaoAtivo As String
         Get
            LogExclusaoAtivo = me.GetString("LogExclusaoAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogExclusaoAtivo", pValue)
         End Set
      End Property

      Property LogRelatorioAtivo As String
         Get
            LogRelatorioAtivo = me.GetString("LogRelatorioAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogRelatorioAtivo", pValue)
         End Set
      End Property

      Property LogTransacaoAtivo As String
         Get
            LogTransacaoAtivo = me.GetString("LogTransacaoAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogTransacaoAtivo", pValue)
         End Set
      End Property

      Property LogRespostaParametroAtivo As String
         Get
            LogRespostaParametroAtivo = me.GetString("LogRespostaParametroAtivo")
         End Get
         Set(pValue As String)
            me.SetString("LogRespostaParametroAtivo", pValue)
         End Set
      End Property

      Property MenuUsuarioHabilitado As String
         Get
            MenuUsuarioHabilitado = me.GetString("MenuUsuarioHabilitado")
         End Get
         Set(pValue As String)
            me.SetString("MenuUsuarioHabilitado", pValue)
         End Set
      End Property

      Property AcessoFrenteLoja As String
         Get
            AcessoFrenteLoja = me.GetString("AcessoFrenteLoja")
         End Get
         Set(pValue As String)
            me.SetString("AcessoFrenteLoja", pValue)
         End Set
      End Property

      Property PercentualDescontoFrenteLoja As String
         Get
            PercentualDescontoFrenteLoja = me.GetString("PercentualDescontoFrenteLoja")
         End Get
         Set(pValue As String)
            me.SetString("PercentualDescontoFrenteLoja", pValue)
         End Set
      End Property

      Property CodConfiguracaoEnvioEmail As Integer
         Get
            CodConfiguracaoEnvioEmail = me.GetInteger("CodConfiguracaoEnvioEmail")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodConfiguracaoEnvioEmail", pValue)
         End Set
      End Property

      Property PercentualDescontoContaReceberFrenteLoja As String
         Get
            PercentualDescontoContaReceberFrenteLoja = me.GetString("PercentualDescontoContaReceberFrenteLoja")
         End Get
         Set(pValue As String)
            me.SetString("PercentualDescontoContaReceberFrenteLoja", pValue)
         End Set
      End Property

      Property AcessoSupervisorFrenteLoja As String
         Get
            AcessoSupervisorFrenteLoja = me.GetString("AcessoSupervisorFrenteLoja")
         End Get
         Set(pValue As String)
            me.SetString("AcessoSupervisorFrenteLoja", pValue)
         End Set
      End Property

      Property AssinaturaMensagem As String
         Get
            AssinaturaMensagem = me.GetString("AssinaturaMensagem")
         End Get
         Set(pValue As String)
            me.SetString("AssinaturaMensagem", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
