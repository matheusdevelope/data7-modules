Imports mod_tobject

Namespace mod_log_item

   ' One LogSistemaDetalhe row. Valor and ValorAntigo are stored
   ' exactly as the caller passed them (number, null, 'text').
   Class LogItem
      Inherits TTObject

      Sequencia As Integer
      Nome As String
      ValorAntigo As String
      Valor As String
      Observacao As String

      Sub New()
         MyBase.New()
         me.Sequencia = 0
         me.Nome = ""
         me.ValorAntigo = ""
         me.Valor = ""
         me.Observacao = ""
      End Sub

      Overrides Function Clone() As TTObject
         Dim copy As New LogItem()
         copy.Sequencia = me.Sequencia
         copy.Nome = me.Nome
         copy.ValorAntigo = me.ValorAntigo
         copy.Valor = me.Valor
         copy.Observacao = me.Observacao
         Clone = copy
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
