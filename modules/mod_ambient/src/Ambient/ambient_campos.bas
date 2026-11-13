Imports ambient_campo
Imports configurador_campo
Imports TablesField
Imports TablesSql
Imports Collections

Namespace ambient_campos

   Structure TCamposConfig
      Calculated As Boolean = False
      IncludeHidden As Boolean = False
      FilterEmpresa As Boolean = True
      FilterFilial As Boolean = False
      ThrowExceptionInvalidTable As Boolean = False
   End Structure

   Class TCampoList
      Inherits TTList<TCampoValue>

      Config As TCamposConfig
      CodEmpresa As Integer
      CodFilial As Integer
      CodTabela As Integer
      SchemaTabela As String
      NomeTabela As String
      AppliedWhere As String
      Ready As Boolean

      Sub New()
         MyBase.New()
         me.OwnsObjects = True
         me.Ready = False
         me.AppliedWhere = ""
      End Sub

      Function Count() As Integer
         Count = me.Length
      End Function

      Function CountKeys() As Integer
         Dim total As Integer = 0
         Dim i As Integer
         Dim last As Integer = me.Length - 1
         For i = 0 To last
            If me.Take(i).IsPrimaryKey Then
               total = total + 1
            End If
         Next
         CountKeys = total
      End Function

      Function Has(pName As String) As Boolean
         Has = Assigned(me.FindByNameCI(pName))
      End Function

      Function FindByNameCI(pName As String) As TCampoValue
         Dim target As String = UCase(Trim(pName))
         If target = "" Then
            FindByNameCI = Null
            Exit Function
         End If
         Dim i As Integer
         Dim last As Integer = me.Length - 1
         For i = 0 To last
            Dim item As TCampoValue = me.Take(i)
            If UCase(Trim(item.Nome)) = target Then
               FindByNameCI = item
               Exit Function
            End If
         Next
         FindByNameCI = Null
      End Function

      Sub Build(pTabela As configurador_tabela.Tabela)
         me.CodTabela = pTabela.CodTabela
         me.NomeTabela = pTabela.Nome
         me.SchemaTabela = pTabela.NomeSchema
         Dim i As Integer
         Dim last As Integer = pTabela.Campos.Length - 1
         For i = 0 To last
            Dim source As Campo = pTabela.Campos.Take(i)
            Dim ctx As String = UCase(Trim(source.Contexto))
            Dim formula As String = Trim(source.FormulaCalculoValor)
            Dim calculated As Boolean = (ctx <> "R") And (formula <> "")
            Dim includeField As Boolean = source.Exists Or source.Extra Or calculated
            If includeField And (Trim(source.Nome) <> "") Then
               Dim field As New TCampoValue()
               field.CodTabela = source.CodTabela
               If me.CodTabela <= 0 Then
                  me.CodTabela = source.CodTabela
               End If
               field.CodCampo = source.CodCampo
               field.Nome = source.Nome
               field.Titulo = source.Titulo
               field.Tipo = UCase(Trim(source.Tipo))
               field.Contexto = source.Contexto
               field.FormulaCalculoValor = source.FormulaCalculoValor
               field.OrdemGrade = source.OrdemGrade
               field.CondicaoVisivelGrade = source.CondicaoVisivelGrade
               field.IsPhysical = source.Exists Or source.Extra
               field.IsPrimaryKey = False
               If field.Tipo = "I" Then
                  field.TipoDB = "INT4"
               Else
                  field.TipoDB = "VARCHAR"
               End If
               me.Push(field)
            End If
         Next
         me.ApplyPhysicalPrimaryKeys()
      End Sub

      Sub BuildPhysical(pSchema As String, pName As String)
         If Trim(pName) = "" Then
            Exit Sub
         End If
         Dim cols[] As TColumnInfo = TSql.DescribeColumns(pSchema, pName)
         Dim i As Integer
         Dim last As Integer = cols.Length - 1
         For i = 0 To last
            Dim col As TColumnInfo = cols.Take(i)
            If Trim(col.Name) <> "" Then
               Dim field As New TCampoValue()
               field.Nome = col.Name
               field.Titulo = col.Name
               field.Contexto = "R"
               field.IsPhysical = True
               field.IsPrimaryKey = col.PrimaryKey
               field.TipoDB = UCase(Trim(col.NativeType))
               field.CondicaoVisivelGrade = "O"
               me.Push(field)
            End If
         Next
         cols.Free()
      End Sub

      Private Sub ApplyPhysicalPrimaryKeys()
         If Trim(me.NomeTabela) = "" Then
            Exit Sub
         End If
         Dim cols[] As TColumnInfo = TSql.DescribeColumns(me.SchemaTabela, me.NomeTabela)
         Dim i As Integer
         Dim last As Integer = me.Length - 1
         For i = 0 To last
            me.Take(i).IsPrimaryKey = False
         Next
         last = cols.Length - 1
         For i = 0 To last
            Dim col As TColumnInfo = cols.Take(i)
            If Trim(col.Name) <> "" Then
               Dim field As TCampoValue = me.FindByNameCI(col.Name)
               If Assigned(field) Then
                  field.IsPrimaryKey = col.PrimaryKey
                  If Trim(col.NativeType) <> "" Then
                     field.TipoDB = UCase(Trim(col.NativeType))
                  End If
               End If
            End If
         Next
         cols.Free()
      End Sub

      Function ApplyWhere(pWhere As String) As String
         Dim clause As String = Trim(pWhere)
         If clause = "" Then
            ApplyWhere = me.AppliedWhere
            Exit Function
         End If
         me.AppliedWhere = clause
         ApplyWhere = me.AppliedWhere
      End Function

      Sub LoadValues(pWhere As String = "")
         Dim clause As String = Trim(pWhere)
         If clause = "" Then
            clause = Trim(me.AppliedWhere)
         End If
         If clause = "" Then
            Exit Sub
         End If
         If me.Config.ThrowExceptionInvalidTable Then
            me.Check()
         ElseIf Trim(me.NomeTabela) = "" Then
            Exit Sub
         End If
         me.ClearValues()
         me.AppliedWhere = clause
         Dim dialect As TSqlDialect = TSql.Dialect()
         Dim fields As StringList = me.BuildSelect()
         If fields.Count = 0 Then
            fields.Free()
            Exit Sub
         End If
         Dim sqlText As String = "SELECT " & dialect.JoinComma(fields) & " FROM " & dialect.QuoteTable(me.SchemaTabela, me.NomeTabela) & " WHERE " & me.AppliedWhere
         sqlText = dialect.ApplyLimit(sqlText, 1)
         Using query As New SQL.Command()
            query.CommandText = sqlText
            Try
               query.Open()
            Catch ex As Exception
               Throw New Exception("Erro ao obter valores dos campos de ambiente no banco de dados:" & CHAR(13) & ex._GetMessage() & CHAR(13) & sqlText)
            End Try
            If Not query.Eof Then
               me.FillValues(query)
            End If
         End Using
         fields.Free()
      End Sub

      Private Sub Check()
         If Not me.Ready Then
            Throw New Exception("Ambiente não inicializado, execute Ambient.Initialize primeiro!")
         End If
         If Trim(me.NomeTabela) = "" Then
            Throw New Exception("Tabela não informada para carregar os valores.")
         End If
      End Sub

      Private Function BuildSelect() As StringList
         Dim dialect As TSqlDialect = TSql.Dialect()
         Dim list As New StringList()
         list.LineBreak = "," & CHAR(13)
         Dim i As Integer
         Dim last As Integer = me.Length - 1
         For i = 0 To last
            Dim field As TCampoValue = me.Take(i)
            If field.IsVisible() Or me.Config.IncludeHidden Then
               Dim line As String = ""
               If field.IsPhysical Then
                  line = dialect.QuoteIdent(field.Nome)
               ElseIf me.Config.Calculated And field.IsCalculated() Then
                  line = "(" & field.FormulaCalculoValor & ") AS " & dialect.QuoteIdent(field.Nome)
               End If
               If line <> "" Then
                  list.Add(line)
               End If
            End If
         Next
         BuildSelect = list
      End Function

      Private Sub ClearValues()
         Dim i As Integer
         Dim last As Integer = me.Length - 1
         For i = 0 To last
            me.Take(i).Value = Unassigned
         Next
      End Sub

      Private Sub FillValues(pQuery As SQL.Command)
         Dim i As Integer
         Dim last As Integer = me.Length - 1
         For i = 0 To last
            Dim field As TCampoValue = me.Take(i)
            If field.IsVisible() Or me.Config.IncludeHidden Then
               If field.IsPhysical Or (me.Config.Calculated And field.IsCalculated()) Then
                  field.Value = pQuery.Field(field.Nome).AsVariant
               End If
            End If
         Next
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
