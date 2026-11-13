' data7:disable qualified-private-shared-access
Imports TablesSql
Imports TablesField
Imports mod_tlist
Imports table_filter_field
Imports table_filter_item
Imports table_filter_ops
Imports table_filter_table

Namespace table_filter_sql

   Class TFilterSql

      Shared Function Build(pTabela As TFilterTable, pItems[] As TFilterItem, pQualify As Boolean = True) As String
         Dim sqlText As String = ""
         If Not Assigned(pTabela) Then
            Build = ""
            Exit Function
         End If
         If Not Assigned(pItems) Then
            Build = ""
            Exit Function
         End If
         Dim i As Integer
         Dim last As Integer = pItems.Length - 1
         For i = 0 To last
            Dim item As TFilterItem = pItems.Take(i)
            Dim pred As String = TFilterSql.Predicate(pTabela, item, pQualify)
            If pred <> "" Then
               If sqlText = "" Then
                  sqlText = pred
               Else
                  sqlText = sqlText & " " & item.LogicalOp & " " & pred
               End If
            End If
         Next
         Build = sqlText
      End Function

      Shared Function BuildWhere(pTabela As TFilterTable, pItems[] As TFilterItem, pQualify As Boolean = True) As String
         Dim body As String = TFilterSql.Build(pTabela, pItems, pQualify)
         If Trim(body) = "" Then
            BuildWhere = ""
         Else
            BuildWhere = "WHERE " & body
         End If
      End Function

      Shared Function Predicate(pTabela As TFilterTable, pItem As TFilterItem, pQualify As Boolean) As String
         If Not Assigned(pItem) Then
            Predicate = ""
            Exit Function
         End If
         Dim op As String = UCase(Trim(pItem.Condition))
         If TFilterOps.IsSql(op) Then
            Predicate = TFilterSql.SqlFragment(pItem)
            Exit Function
         End If
         Dim field As TFilterField = pTabela.FindByName(pItem.FieldName)
         Dim col As String = TFilterSql.ColumnRef(pTabela, pItem.FieldName, pQualify, field)
         If col = "" Then
            Predicate = ""
            Exit Function
         End If
         If op = "NL" Then
            Predicate = "(" & col & " IS NULL)"
         ElseIf op = "NN" Then
            Predicate = "(" & col & " IS NOT NULL)"
         ElseIf op = "IN" Then
            Predicate = TFilterSql.InClause(col, pItem, field, False)
         ElseIf op = "NIN" Then
            Predicate = TFilterSql.InClause(col, pItem, field, True)
         ElseIf op = "BW" Then
            Predicate = TFilterSql.BetweenClause(col, pItem, field, False)
         ElseIf op = "NBW" Then
            Predicate = TFilterSql.BetweenClause(col, pItem, field, True)
         ElseIf op = "SW" Then
            Predicate = TFilterSql.LikeClause(col, pItem, True, False, False)
         ElseIf op = "NSW" Then
            Predicate = TFilterSql.LikeClause(col, pItem, True, False, True)
         ElseIf op = "CT" Then
            Predicate = TFilterSql.LikeClause(col, pItem, True, True, False)
         ElseIf op = "NCT" Then
            Predicate = TFilterSql.LikeClause(col, pItem, True, True, True)
         Else
            Predicate = TFilterSql.CompareClause(col, op, pItem, field)
         End If
      End Function

      Private Shared Function ColumnRef(pTabela As TFilterTable, pFieldName As String, pQualify As Boolean, pField As TFilterField) As String
         If Assigned(pField) Then
            Dim formula As String = Trim(pField.Formula)
            If formula <> "" Then
               ColumnRef = "(" & formula & ")"
               Exit Function
            End If
         End If
         Dim fieldName As String = Trim(pFieldName)
         If fieldName = "" Then
            ColumnRef = ""
            Exit Function
         End If
         Dim dialect As TSqlDialect = TSql.Dialect()
         Dim quotedField As String = dialect.QuoteIdent(fieldName)
         If Not pQualify Then
            ColumnRef = quotedField
            Exit Function
         End If
         If Trim(pTabela.Nome) = "" Then
            ColumnRef = quotedField
         Else
            ColumnRef = dialect.QuoteTable(pTabela.Schema, pTabela.Nome) & "." & quotedField
         End If
      End Function

      Private Shared Function SqlFragment(pItem As TFilterItem) As String
         Dim sqlText As String = ""
         If pItem.Values.Length > 0 Then
            sqlText = Trim(pItem.Values.Take(0))
         End If
         If sqlText = "" Then
            SqlFragment = ""
         Else
            SqlFragment = "(" & sqlText & ")"
         End If
      End Function

      Private Shared Function CompareClause(pCol As String, pOp As String, pItem As TFilterItem, pField As TFilterField) As String
         If pItem.Values.Length = 0 Then
            CompareClause = ""
            Exit Function
         End If
         Dim raw As String = Trim(pItem.Values.Take(0))
         Dim token As String = TFilterSql.Literal(raw, pField)
         Dim sqlOp As String = "="
         If pOp = "NE" Then
            sqlOp = "<>"
         ElseIf pOp = "LT" Then
            sqlOp = "<"
         ElseIf pOp = "LE" Then
            sqlOp = "<="
         ElseIf pOp = "GT" Then
            sqlOp = ">"
         ElseIf pOp = "GE" Then
            sqlOp = ">="
         End If
         CompareClause = "(" & pCol & " " & sqlOp & " " & token & ")"
      End Function

      Private Shared Function InClause(pCol As String, pItem As TFilterItem, pField As TFilterField, pNot As Boolean) As String
         Dim list As String = ""
         Dim i As Integer
         Dim last As Integer = pItem.Values.Length - 1
         For i = 0 To last
            Dim raw As String = Trim(pItem.Values.Take(i))
            If list <> "" Then
               list = list & ", "
            End If
            list = list & TFilterSql.Literal(raw, pField)
         Next
         If list = "" Then
            InClause = ""
            Exit Function
         End If
         If pNot Then
            InClause = "(" & pCol & " NOT IN (" & list & "))"
         Else
            InClause = "(" & pCol & " IN (" & list & "))"
         End If
      End Function

      Private Shared Function BetweenClause(pCol As String, pItem As TFilterItem, pField As TFilterField, pNot As Boolean) As String
         If pItem.Values.Length < 2 Then
            BetweenClause = ""
            Exit Function
         End If
         Dim leftVal As String = Trim(pItem.Values.Take(0))
         Dim rightVal As String = Trim(pItem.Values.Take(1))
         Dim leftLit As String = TFilterSql.Literal(leftVal, pField)
         Dim rightLit As String = TFilterSql.Literal(rightVal, pField)
         If pNot Then
            BetweenClause = "(" & pCol & " NOT BETWEEN " & leftLit & " AND " & rightLit & ")"
         Else
            BetweenClause = "(" & pCol & " BETWEEN " & leftLit & " AND " & rightLit & ")"
         End If
      End Function

      Private Shared Function LikeClause(pCol As String, pItem As TFilterItem, pPrefix As Boolean, pContains As Boolean, pNot As Boolean) As String
         If pItem.Values.Length = 0 Then
            LikeClause = ""
            Exit Function
         End If
         Dim raw As String = Trim(pItem.Values.Take(0))
         Dim pattern As String = TFilterSql.EscapeLike(raw)
         If pContains Then
            pattern = "%" & pattern & "%"
         ElseIf pPrefix Then
            pattern = pattern & "%"
         End If
         Dim sqlOp As String = "LIKE"
         If pNot Then
            sqlOp = "NOT LIKE"
         End If
         LikeClause = "(" & pCol & " " & sqlOp & " " & TFilterSql.QuoteStr(pattern) & ")"
      End Function

      Private Shared Function Literal(pValue As String, pField As TFilterField) As String
         Dim raw As String = Trim(pValue)
         If Not Assigned(pField) Then
            Literal = TFilterSql.QuoteOrNumber(raw)
            Exit Function
         End If
         Dim kind As String = pField.Kind()
         If kind = "date" Then
            Literal = TFilterSql.DateLiteral(raw, False)
         ElseIf kind = "datetime" Then
            Literal = TFilterSql.DateLiteral(raw, True)
         ElseIf kind = "time" Then
            Literal = TFilterSql.TimeLiteral(raw)
         ElseIf (kind = "integer") Or (kind = "number") Or (kind = "search") Then
            If TFilterSql.IsNumber(raw) Then
               Literal = raw
            Else
               Literal = TFilterSql.QuoteStr(raw)
            End If
         ElseIf kind = "check" Then
            Literal = TFilterSql.QuoteStr(TFilterSql.BoolToken(raw))
         Else
            Literal = TFilterSql.QuoteStr(raw)
         End If
      End Function

      Private Shared Function DateLiteral(pValue As String, pWithTime As Boolean) As String
         Dim parsed As TDateTime
         Dim ok As Boolean
         If pWithTime Then
            ok = TField.TryParseDateTime(pValue, parsed)
         Else
            ok = TField.TryParseDate(pValue, parsed)
         End If
         If ok Then
            DateLiteral = TSql.LiteralDate(parsed, pWithTime)
         Else
            DateLiteral = TFilterSql.QuoteStr(pValue)
         End If
      End Function

      Private Shared Function TimeLiteral(pValue As String) As String
         Dim parsed As TDateTime
         If TField.TryParseTime(pValue, parsed) Then
            TimeLiteral = TSql.LiteralTime(parsed)
         Else
            TimeLiteral = TFilterSql.QuoteStr(pValue)
         End If
      End Function

      Private Shared Function BoolToken(pValue As String) As String
         Dim flag As String = UCase(Trim(pValue))
         If (flag = "S") Or (flag = "SIM") Or (flag = "TRUE") Or (flag = "1") Or (flag = "Y") Then
            BoolToken = "S"
         Else
            BoolToken = "N"
         End If
      End Function

      Private Shared Function QuoteOrNumber(pValue As String) As String
         If TFilterSql.IsNumber(pValue) Then
            QuoteOrNumber = pValue
         Else
            QuoteOrNumber = TFilterSql.QuoteStr(pValue)
         End If
      End Function

      Private Shared Function QuoteStr(pValue As String) As String
         QuoteStr = "'" & Replace(pValue, "'", "''") & "'"
      End Function

      Private Shared Function EscapeLike(pValue As String) As String
         EscapeLike = Replace(pValue, "'", "''")
      End Function

      Private Shared Function IsNumber(pValue As String) As Boolean
         Dim text As String = Trim(pValue)
         If text = "" Then
            IsNumber = False
            Exit Function
         End If
         Dim ok As Boolean
         Try
            Dim parsed As Double = CDbl(text)
            ok = (parsed = parsed)
         Catch ex As Exception
            ok = False
         End Try
         IsNumber = ok
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
