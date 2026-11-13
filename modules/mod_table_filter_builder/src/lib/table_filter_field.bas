Imports mod_tobject

Namespace table_filter_field

   Class TFilterField
      Inherits TTObject

      Nome As String
      Titulo As String
      Tipo As String
      CodPesquisa As Integer
      ListaOpcoes As String
      DecimalPlaces As Integer
      Formula As String

      Sub New()
         MyBase.New()
         me.Nome = ""
         me.Titulo = ""
         me.Tipo = ""
         me.CodPesquisa = 0
         me.ListaOpcoes = ""
         me.DecimalPlaces = 0
         me.Formula = ""
      End Sub

      Overrides Function GetID() As String
         GetID = me.Nome
      End Function

      Overrides Function Clone() As TFilterField
         Dim copy As New TFilterField()
         copy.Nome = me.Nome
         copy.Titulo = me.Titulo
         copy.Tipo = me.Tipo
         copy.CodPesquisa = me.CodPesquisa
         copy.ListaOpcoes = me.ListaOpcoes
         copy.DecimalPlaces = me.DecimalPlaces
         copy.Formula = me.Formula
         Clone = copy
      End Function

      Function Kind() As String
         If me.CodPesquisa > 0 Then
            Kind = "search"
            Exit Function
         End If
         If Trim(me.ListaOpcoes) <> "" Then
            Kind = "combo"
            Exit Function
         End If
         Dim tipo As String = UCase(Trim(me.Tipo))
         If (tipo = "D") Or (tipo = "DATE") Or (tipo = "DATA") Then
            Kind = "date"
         ElseIf (tipo = "DT") Or (tipo = "DATETIME") Or (tipo = "TIMESTAMP") Then
            Kind = "datetime"
         ElseIf (tipo = "T") Or (tipo = "H") Or (tipo = "TIME") Or (tipo = "HORA") Then
            Kind = "time"
         ElseIf (tipo = "L") Or (tipo = "BOOL") Or (tipo = "BOOLEAN") Or (tipo = "LOGICO") Then
            Kind = "check"
         ElseIf (tipo = "I") Or (tipo = "INT") Or (tipo = "INTEGER") Or (tipo = "INTEIRO") Then
            Kind = "integer"
         ElseIf (tipo = "N") Or (tipo = "F") Or (tipo = "FLOAT") Or (tipo = "NUMERIC") Or (tipo = "NUMERICO") Or (tipo = "VALOR") Or (tipo = "MOEDA") Or (tipo = "DECIMAL") Then
            Kind = "number"
         ElseIf (tipo = "M") Or (tipo = "MEMO") Then
            Kind = "memo"
         Else
            Kind = "text"
         End If
      End Function

      Function IsNumericKind() As Boolean
         Dim k As String = me.Kind()
         IsNumericKind = (k = "integer") Or (k = "number") Or (k = "search")
      End Function

      Function IsDateKind() As Boolean
         Dim k As String = me.Kind()
         IsDateKind = (k = "date") Or (k = "datetime") Or (k = "time")
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
