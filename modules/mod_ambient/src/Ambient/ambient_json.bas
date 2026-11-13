Imports TablesSql
Imports TablesTable
Imports Collections
Imports TablesField
Imports configurador_lote

' data7:disable qualified-private-shared-access

Namespace ambient_json

   Class TAmbientJson

      Shared Function CastC(pExpr As String) As String
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            CastC = "(CAST(" & pExpr & " AS TEXT) COLLATE ""C"")"
         Else
            CastC = pExpr
         End If
      End Function

      Shared Function Cmp(pLeft As String, pRight As String) As String
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            Cmp = TAmbientJson.CastC(pLeft) & " = " & TAmbientJson.CastC(pRight)
         Else
            Cmp = pLeft & " = " & pRight
         End If
      End Function

      Shared Function CmpCI(pLeft As String, pRight As String) As String
         CmpCI = "UPPER(" & TAmbientJson.CastC(pLeft) & ") = UPPER(" & TAmbientJson.CastC(pRight) & ")"
      End Function

      Shared Function SqlNow() As String
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            SqlNow = "CURRENT_TIMESTAMP"
         Else
            SqlNow = "GETDATE()"
         End If
      End Function

      Shared Function SqlSecondsAgo(pSeconds As String) As String
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            SqlSecondsAgo = "(CURRENT_TIMESTAMP - (" & pSeconds & " * INTERVAL '1 second'))"
         Else
            SqlSecondsAgo = "DATEADD(SECOND, -" & pSeconds & ", GETDATE())"
         End If
      End Function

      Shared Function KeySeparator() As String
         If SQL.Connection.RDBMS = dbMSSQL Then
            KeySeparator = " + '-' + "
         Else
            KeySeparator = " || '-' || "
         End If
      End Function

      Shared Function LimitOne(pSql As String) As String
         LimitOne = TSql.Dialect().ApplyLimit(pSql, 1)
      End Function

      Shared Function SqlJson(pInner As String, pAlias As String) As String
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            SqlJson = "(SELECT convert_to(CAST(json_agg(_j) AS text), 'WIN1252') FROM (" & pInner & ") _j) AS " & pAlias
         ElseIf SQL.Connection.RDBMS = dbMSSQL Then
            SqlJson = "CAST(CAST((" & pInner & " FOR JSON AUTO) AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS " & pAlias
         Else
            SqlJson = "CSCONVERT(CAST((" & pInner & " FOR JSON RAW) AS LONG VARCHAR), 'windows-1252', 'utf-8') AS " & pAlias
         End If
      End Function

      Shared Function SelectColumns(pTable As TTable, pFrom As String, pWhere As String) As String
         Dim dialect As TSqlDialect = TSql.Dialect()
         Using parts As New StringList()
            parts.LineBreak = ", "
            Dim i As Integer
            Dim last As Integer = pTable.Schema.Fields.Count - 1
            For i = 0 To last
               Dim fieldDef As TFieldDef = CType(pTable.Schema.Fields.Objects(i), TFieldDef)
               If fieldDef.IncludeInSelect And TAmbientJson.IsSafeIdent(fieldDef.DbName) Then
                  Dim src As String
                  If Trim(fieldDef.SelectExpr) <> "" Then
                     src = fieldDef.SelectExpr
                  Else
                     src = fieldDef.DbName
                  End If
                  parts.Add(src & " AS " & LCase(fieldDef.DbName))
               End If
            Next
            Dim sqlText As String = "SELECT " & dialect.JoinComma(parts) & " FROM " & pFrom
            Dim filter As String = Trim(pWhere)
            If filter <> "" Then
               sqlText = sqlText & " WHERE " & filter
            End If
            SelectColumns = sqlText
         End Using
      End Function

      Shared Function SelectFromTable(pTable As TTable, pWhere As String) As String
         Dim fromSql As String = TSql.Dialect().QuoteTable(pTable.Schema.SchemaName, pTable.Schema.TableName)
         SelectFromTable = TAmbientJson.SelectColumns(pTable, fromSql, pWhere)
      End Function

      Shared Sub Fill(pTable As TTable, pJson As String)
         Dim arr As TJSONArray = TCfgLoad.AbrirArray(pJson)
         If Not Assigned(arr) Then
            Exit Sub
         End If
         If arr.Length() <= 0 Then
            arr.Free()
            Exit Sub
         End If
         Dim obj As TJSONObject = arr.GetJSONObject(0)
         pTable.BeforeLoad()
         Dim i As Integer
         Dim last As Integer = pTable.Fields.Count - 1
         For i = 0 To last
            Dim field As TField = pTable.GetField(i)
            TAmbientJson.ReadField(field, obj)
         Next
         pTable.AfterLoad()
         arr.Free()
      End Sub

      Private Shared Sub ReadField(pField As TField, pObj As TJSONObject)
         Dim key As String = LCase(pField.Def.DbName)
         If Not pObj.Has(key) Then
            key = pField.Def.DbName
         End If
         If Not pObj.Has(key) Then
            Exit Sub
         End If
         Dim text As String = LCase(Trim(pObj.GetString(key)))
         If (text = "") Or (text = "null") Then
            Exit Sub
         End If
         Dim kindId As Integer = pField.Def.KindId
         If kindId = 1 Then
            pField.Value = pObj.GetInteger(key)
         ElseIf kindId = 2 Then
            pField.Value = pObj.GetDouble(key)
         ElseIf kindId = 3 Then
            pField.Value = pField.Def.ParseBoolText(pObj.GetString(key))
            'ElseIf kindId = 4 Then
            '   pField.Value = pObj.GetDate(key)
            'ElseIf kindId = 5 Then
            '   If text.Contains("-") Or text.Contains("t") Then
            '      pField.Value = pObj.GetDate(key)
            '   Else
            '       pField.Value = pObj.GetTime(key)
            '    End If
         Else
            pField.Value = pObj.GetString(key)
         End If
      End Sub

      Private Shared Function IsSafeIdent(pName As String) As Boolean
         Dim name As String = Trim(pName)
         If name = "" Then
            IsSafeIdent = False
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = name.Length
         For i = 1 To n
            Dim ch As String = Mid(name, i, 1)
            Dim code As Integer = CInt(Asc(ch.LastChar()))
            Dim ok As Boolean = ((code >= 65) And (code <= 90)) Or ((code >= 97) And (code <= 122)) Or ((code >= 48) And (code <= 57)) Or (code = 95)
            If (i = 1) And (code >= 48) And (code <= 57) Then
               ok = False
            End If
            If Not ok Then
               IsSafeIdent = False
               Exit Function
            End If
         Next
         IsSafeIdent = True
      End Function
      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
