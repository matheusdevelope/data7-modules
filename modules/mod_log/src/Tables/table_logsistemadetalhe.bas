Imports TablesSchema
Imports TablesTable

Namespace table_logsistemadetalhe

   Class TLogSistemaDetalhe
      Inherits TTableOf<TLogSistemaDetalhe>

      Sub New()
         MyBase.New("TLogSistemaDetalhe")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "LogSistemaDetalhe"
         pSchema.Field("Id_LogSistema").AsInteger().PrimaryKeyField()
         pSchema.Field("Sequencia").AsInteger().PrimaryKeyField()
         pSchema.Field("Nome").AsString().MaxLen(200).RequiredField()
         pSchema.Field("ValorAntigo").AsString().MaxLen(2000).NullIfEmptyField()
         pSchema.Field("Valor").AsString().MaxLen(2000).NullIfEmptyField()
         pSchema.Field("Observacao").AsString().MaxLen(2000).NullIfEmptyField()
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodLogSistema) & "|" & CStr(me.Sequencia)
      End Function

      Property CodLogSistema As Integer
         Get
            CodLogSistema = me.GetInteger("Id_LogSistema")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Id_LogSistema", pValue)
         End Set
      End Property

      Property Sequencia As Integer
         Get
            Sequencia = me.GetInteger("Sequencia")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Sequencia", pValue)
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

      Property ValorAntigo As String
         Get
            ValorAntigo = me.GetString("ValorAntigo")
         End Get
         Set(pValue As String)
            me.SetString("ValorAntigo", pValue)
         End Set
      End Property

      Property Valor As String
         Get
            Valor = me.GetString("Valor")
         End Get
         Set(pValue As String)
            me.SetString("Valor", pValue)
         End Set
      End Property

      Property Observacao As String
         Get
            Observacao = me.GetString("Observacao")
         End Get
         Set(pValue As String)
            me.SetString("Observacao", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
