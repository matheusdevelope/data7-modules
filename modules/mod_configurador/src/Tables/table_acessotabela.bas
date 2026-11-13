Imports TablesSchema
Imports TablesTable

Namespace table_acessotabela

   Class TAcessoTabela
      Inherits TTableOf<TAcessoTabela>

      Sub New()
         MyBase.New("TAcessoTabela")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "AcessoTabela"
         pSchema.Field("CodUsuario").AsInteger().PrimaryKeyField()
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("PermitidoExcluir").AsBoolean().RequiredField()
         pSchema.Field("PermitidoIncluir").AsBoolean().RequiredField()
         pSchema.Field("PermitidoAlterar").AsBoolean().RequiredField()
         pSchema.Field("PermitidoVisualizar").AsBoolean().RequiredField()
         pSchema.Field("PermitidoConsultar").AsBoolean().RequiredField()
         pSchema.Field("PermitidoExportar").AsBoolean()
         pSchema.Field("PermitidoAnaliseGerencial").AsBoolean()
         pSchema.Field("PermitidoOpcoesColuna").AsBoolean()
         pSchema.Field("PermitidoIncluirAnexo").AsBoolean()
         pSchema.Field("PermitidoAlterarAnexo").AsBoolean()
         pSchema.Field("PermitidoExcluirAnexo").AsBoolean()
         pSchema.Field("PermitidoVisualizarAnexo").AsBoolean()
         pSchema.Field("PermitidoSalvarAnexo").AsBoolean()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodUsuario) & "|" & CStr(me.CodTabela)
      End Function

      Property CodUsuario As Integer
         Get
            CodUsuario = me.GetInteger("CodUsuario")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodUsuario", pValue)
         End Set
      End Property

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
         End Set
      End Property

      Property PermitidoExcluir As Boolean
         Get
            PermitidoExcluir = me.GetBoolean("PermitidoExcluir")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoExcluir", pValue)
         End Set
      End Property

      Property PermitidoIncluir As Boolean
         Get
            PermitidoIncluir = me.GetBoolean("PermitidoIncluir")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoIncluir", pValue)
         End Set
      End Property

      Property PermitidoAlterar As Boolean
         Get
            PermitidoAlterar = me.GetBoolean("PermitidoAlterar")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoAlterar", pValue)
         End Set
      End Property

      Property PermitidoVisualizar As Boolean
         Get
            PermitidoVisualizar = me.GetBoolean("PermitidoVisualizar")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoVisualizar", pValue)
         End Set
      End Property

      Property PermitidoConsultar As Boolean
         Get
            PermitidoConsultar = me.GetBoolean("PermitidoConsultar")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoConsultar", pValue)
         End Set
      End Property

      Property PermitidoExportar As Boolean
         Get
            PermitidoExportar = me.GetBoolean("PermitidoExportar")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoExportar", pValue)
         End Set
      End Property

      Property PermitidoAnaliseGerencial As Boolean
         Get
            PermitidoAnaliseGerencial = me.GetBoolean("PermitidoAnaliseGerencial")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoAnaliseGerencial", pValue)
         End Set
      End Property

      Property PermitidoOpcoesColuna As Boolean
         Get
            PermitidoOpcoesColuna = me.GetBoolean("PermitidoOpcoesColuna")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoOpcoesColuna", pValue)
         End Set
      End Property

      Property PermitidoIncluirAnexo As Boolean
         Get
            PermitidoIncluirAnexo = me.GetBoolean("PermitidoIncluirAnexo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoIncluirAnexo", pValue)
         End Set
      End Property

      Property PermitidoAlterarAnexo As Boolean
         Get
            PermitidoAlterarAnexo = me.GetBoolean("PermitidoAlterarAnexo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoAlterarAnexo", pValue)
         End Set
      End Property

      Property PermitidoExcluirAnexo As Boolean
         Get
            PermitidoExcluirAnexo = me.GetBoolean("PermitidoExcluirAnexo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoExcluirAnexo", pValue)
         End Set
      End Property

      Property PermitidoVisualizarAnexo As Boolean
         Get
            PermitidoVisualizarAnexo = me.GetBoolean("PermitidoVisualizarAnexo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoVisualizarAnexo", pValue)
         End Set
      End Property

      Property PermitidoSalvarAnexo As Boolean
         Get
            PermitidoSalvarAnexo = me.GetBoolean("PermitidoSalvarAnexo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PermitidoSalvarAnexo", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
