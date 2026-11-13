' data7:disable qualified-private-shared-access
Imports Collections
Imports Data7
Imports TablesSql
Imports TablesField
Imports configurador_sql
Imports mod_register_config

Namespace mod_register_validation

   Class TRegisterProcSpec
      ProcedureName As String
      Params As StringList

      Sub New()
         MyBase.New()
         me.ProcedureName = ""
         me.Params = New StringList()
         me.Params.OwnsObjects = False
      End Sub

      Sub Free()
         If Assigned(me.Params) Then
            me.Params.Free()
            me.Params = Null
         End If
         MyBase.Free()
      End Sub
   End Class

   Class TRegisterProcResult
      Acao As String
      Mensagem As String

      Sub New()
         MyBase.New()
         me.Acao = ""
         me.Mensagem = ""
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TRegisterValidation

      Sub New()
         MyBase.New()
      End Sub

      Shared Function Parse(pSpec As String) As TRegisterProcSpec
         Dim spec As New TRegisterProcSpec()
         Dim raw As String = Trim(pSpec)
         If raw = "" Then
            Parse = spec
            Exit Function
         End If
         If raw.Contains("(") Then
            Dim paren As Integer = TRegisterValidation._find(raw, "(")
            spec.ProcedureName = Trim(TRegisterValidation._slice(raw, 0, paren))
            Dim closeAt As Integer = TRegisterValidation._findLast(raw, ")")
            Dim inner As String = ""
            If closeAt > paren Then
               inner = TRegisterValidation._slice(raw, paren + 1, closeAt - paren - 1)
            Else
               inner = TRegisterValidation._from(raw, paren + 1)
            End If
            TRegisterValidation._splitParams(inner, spec.Params)
         Else
            Dim sp As Integer = TRegisterValidation._findSpace(raw)
            If sp >= 0 Then
               spec.ProcedureName = Trim(TRegisterValidation._slice(raw, 0, sp))
               TRegisterValidation._splitParams(TRegisterValidation._from(raw, sp + 1), spec.Params)
            Else
               spec.ProcedureName = raw
            End If
         End If
         Parse = spec
      End Function

      Shared Function Execute(pSpec As String, pConfig As TRegisterFormConfig, pValues As StringList) As TRegisterProcResult
         Dim result As New TRegisterProcResult()
         Dim spec As TRegisterProcSpec = TRegisterValidation.Parse(pSpec)
         If Trim(spec.ProcedureName) = "" Then
            spec.Free()
            Execute = result
            Exit Function
         End If
         Dim sqlText As String = TRegisterValidation._buildSql(spec, pConfig, pValues)
         Dim query As SQL.Command = Null
         Try
            query = TSql.OpenQuery(sqlText)
            If Not query.Eof Then
               result.Acao = UCase(Trim(query.Field("Acao").AsString))
               result.Mensagem = query.Field("Mensagem").AsString
            End If
            query.Close()
            query.Free()
         Catch ex As Exception
            If Assigned(query) Then
               query.Close()
               query.Free()
            End If
            spec.Free()
            Throw ex
         End Try
         spec.Free()
         Execute = result
      End Function

      Private Shared Function _buildSql(pSpec As TRegisterProcSpec, pConfig As TRegisterFormConfig, pValues As StringList) As String
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            _buildSql = TRegisterValidation._sqlPostgres(pSpec, pConfig, pValues)
         ElseIf SQL.Connection.RDBMS = dbASA Then
            _buildSql = TRegisterValidation._sqlAsa(pSpec, pConfig, pValues)
         Else
            _buildSql = TRegisterValidation._sqlMssql(pSpec, pConfig, pValues)
         End If
      End Function

      Private Shared Function _sqlMssql(pSpec As TRegisterProcSpec, pConfig As TRegisterFormConfig, pValues As StringList) As String
         Dim nl As String = Char(13)
         Dim sqlText As String = TRegisterValidation._declareMssql(pSpec, pConfig)
         sqlText = sqlText & TRegisterValidation._setVars(pSpec, pConfig, pValues, "@", nl)
         sqlText = sqlText & "EXECUTE " & pSpec.ProcedureName & " " & TRegisterValidation._callArgs(pSpec, "@", " output") & ";" & nl
         sqlText = sqlText & "SELECT Upper(@Acao) as Acao, @Mensagem as Mensagem"
         _sqlMssql = sqlText
      End Function

      Private Shared Function _sqlAsa(pSpec As TRegisterProcSpec, pConfig As TRegisterFormConfig, pValues As StringList) As String
         Dim nl As String = Char(13)
         Dim sqlText As String = "BEGIN" & nl
         sqlText = sqlText & TRegisterValidation._declareAsa(pSpec, pConfig)
         sqlText = sqlText & TRegisterValidation._setVars(pSpec, pConfig, pValues, "", nl)
         sqlText = sqlText & "CALL " & pSpec.ProcedureName & "(" & TRegisterValidation._callArgs(pSpec, "", "") & ");" & nl
         sqlText = sqlText & "SELECT UPPER(Acao) AS Acao, Mensagem AS Mensagem;" & nl
         sqlText = sqlText & "END"
         _sqlAsa = sqlText
      End Function

      Private Shared Function _sqlPostgres(pSpec As TRegisterProcSpec, pConfig As TRegisterFormConfig, pValues As StringList) As String
         Dim args As String = ""
         Dim first As Boolean = True
         Dim i As Integer
         Dim n As Integer = pSpec.Params.Count - 1
         For i = 0 To n
            Dim paramName As String = pSpec.Params.Strings(i)
            If Not TRegisterValidation._isOutParam(paramName) Then
               If Not first Then
                  args = args & ", "
               End If
               first = False
               args = args & TRegisterValidation._sqlLiteral(pConfig, pValues, paramName)
            End If
         Next
         _sqlPostgres = "SELECT * FROM " & pSpec.ProcedureName & "(" & args & ") AS q(acao, mensagem);"
      End Function

      Private Shared Function _declareMssql(pSpec As TRegisterProcSpec, pConfig As TRegisterFormConfig) As String
         Dim nl As String = Char(13)
         Dim sqlText As String = ""
         Dim seen As New StringList()
         seen.OwnsObjects = False
         Dim i As Integer
         Dim n As Integer = pSpec.Params.Count - 1
         For i = 0 To n
            Dim paramName As String = pSpec.Params.Strings(i)
            Dim key As String = UCase(Trim(paramName))
            If (key <> "") And (seen.IndexOf(key) < 0) Then
               seen.Add(key)
               sqlText = sqlText & "DECLARE @" & paramName & " " & TRegisterValidation._varType(paramName, pConfig) & ";" & nl
            End If
         Next
         If seen.IndexOf("ACAO") < 0 Then
            sqlText = sqlText & "DECLARE @Acao char(1);" & nl
         End If
         If seen.IndexOf("MENSAGEM") < 0 Then
            sqlText = sqlText & "DECLARE @Mensagem varchar(2000);" & nl
         End If
         seen.Free()
         _declareMssql = sqlText
      End Function

      Private Shared Function _declareAsa(pSpec As TRegisterProcSpec, pConfig As TRegisterFormConfig) As String
         Dim nl As String = Char(13)
         Dim sqlText As String = ""
         Dim seen As New StringList()
         seen.OwnsObjects = False
         Dim i As Integer
         Dim n As Integer = pSpec.Params.Count - 1
         For i = 0 To n
            Dim paramName As String = pSpec.Params.Strings(i)
            Dim key As String = UCase(Trim(paramName))
            If (key <> "") And (seen.IndexOf(key) < 0) Then
               seen.Add(key)
               sqlText = sqlText & "DECLARE " & paramName & " " & TRegisterValidation._varType(paramName, pConfig) & ";" & nl
            End If
         Next
         If seen.IndexOf("ACAO") < 0 Then
            sqlText = sqlText & "DECLARE Acao CHAR(1);" & nl
         End If
         If seen.IndexOf("MENSAGEM") < 0 Then
            sqlText = sqlText & "DECLARE Mensagem VARCHAR(2000);" & nl
         End If
         seen.Free()
         _declareAsa = sqlText
      End Function

      Private Shared Function _setVars(pSpec As TRegisterProcSpec, pConfig As TRegisterFormConfig, pValues As StringList, pPrefix As String, pNl As String) As String
         Dim sqlText As String = ""
         Dim seen As New StringList()
         seen.OwnsObjects = False
         Dim i As Integer
         Dim n As Integer = pSpec.Params.Count - 1
         For i = 0 To n
            Dim paramName As String = pSpec.Params.Strings(i)
            Dim key As String = UCase(Trim(paramName))
            If (key <> "") And (Not TRegisterValidation._isOutParam(paramName)) And (seen.IndexOf(key) < 0) Then
               seen.Add(key)
               sqlText = sqlText & "SET " & pPrefix & paramName & " = " & TRegisterValidation._sqlLiteral(pConfig, pValues, paramName) & ";" & pNl
            End If
         Next
         seen.Free()
         _setVars = sqlText
      End Function

      Private Shared Function _callArgs(pSpec As TRegisterProcSpec, pPrefix As String, pOutSuffix As String) As String
         Dim args As String = ""
         Dim first As Boolean = True
         Dim hasAcao As Boolean = False
         Dim hasMensagem As Boolean = False
         Dim i As Integer
         Dim n As Integer = pSpec.Params.Count - 1
         For i = 0 To n
            Dim paramName As String = pSpec.Params.Strings(i)
            Dim key As String = UCase(Trim(paramName))
            If key = "ACAO" Then
               hasAcao = True
            ElseIf key = "MENSAGEM" Then
               hasMensagem = True
            End If
            If Not first Then
               args = args & ", "
            End If
            first = False
            args = args & pPrefix & paramName
            If TRegisterValidation._isOutParam(paramName) Then
               args = args & pOutSuffix
            End If
         Next
         If Not hasAcao Then
            If Not first Then
               args = args & ", "
            End If
            first = False
            args = args & pPrefix & "Acao" & pOutSuffix
         End If
         If Not hasMensagem Then
            If Not first Then
               args = args & ", "
            End If
            args = args & pPrefix & "Mensagem" & pOutSuffix
         End If
         _callArgs = args
      End Function

      Private Shared Function _varType(pName As String, pConfig As TRegisterFormConfig) As String
         If UCase(Trim(pName)) = "ACAO" Then
            _varType = "char(1)"
            Exit Function
         End If
         If UCase(Trim(pName)) = "MENSAGEM" Then
            _varType = "varchar(2000)"
            Exit Function
         End If
         Dim field As TRegisterField = Null
         If Assigned(pConfig) Then
            field = pConfig.FieldByName(pName)
         End If
         If Not Assigned(field) Then
            _varType = "VARCHAR(255)"
            Exit Function
         End If
         If TRegisterValidation._isInteger(field) Then
            _varType = "INTEGER"
         ElseIf TRegisterValidation._isNumber(field) Then
            Dim prec As Integer = field.MaxLength
            If prec <= 0 Then
               prec = 18
            End If
            Dim scale As Integer = field.DecimalPlaces
            If scale < 0 Then
               scale = 2
            End If
            _varType = "NUMERIC(" & CStr(prec) & ", " & CStr(scale) & ")"
         ElseIf TRegisterValidation._isDateTime(field) Then
            If SQL.Connection.RDBMS = dbASA Then
               _varType = "TIMESTAMP"
            Else
               _varType = "DATETIME"
            End If
         ElseIf TRegisterValidation._isTime(field) Then
            If SQL.Connection.RDBMS = dbASA Then
               _varType = "TIME"
            Else
               _varType = "DATETIME"
            End If
         ElseIf TRegisterValidation._isDate(field) Then
            If SQL.Connection.RDBMS = dbASA Then
               _varType = "DATE"
            Else
               _varType = "DATETIME"
            End If
         ElseIf TRegisterValidation._isCheck(field) Then
            _varType = "VARCHAR(1)"
         Else
            Dim size As Integer = field.MaxLength
            If TRegisterValidation._isMemo(field) Then
               size = 2000
            ElseIf size <= 0 Then
               size = 255
            ElseIf size > 8000 Then
               size = 8000
            End If
            _varType = "VARCHAR(" & CStr(size) & ")"
         End If
      End Function

      Private Shared Function _sqlLiteral(pConfig As TRegisterFormConfig, pValues As StringList, pName As String) As String
         Dim field As TRegisterField = Null
         If Assigned(pConfig) Then
            field = pConfig.FieldByName(pName)
         End If
         If TRegisterValidation._isImage(field) Then
            _sqlLiteral = "NULL"
            Exit Function
         End If
         Dim text As String = TRegisterValidation._valueOf(pValues, pName)
         If TRegisterValidation._isInteger(field) Then
            _sqlLiteral = TRegisterValidation._sqlInt(text)
         ElseIf TRegisterValidation._isNumber(field) Then
            _sqlLiteral = TRegisterValidation._sqlNum(text)
         ElseIf TRegisterValidation._isDateTime(field) Then
            _sqlLiteral = TRegisterValidation._sqlDate(text, True)
         ElseIf TRegisterValidation._isTime(field) Then
            _sqlLiteral = TRegisterValidation._sqlTime(text)
         ElseIf TRegisterValidation._isDate(field) Then
            _sqlLiteral = TRegisterValidation._sqlDate(text, False)
         ElseIf Trim(text) = "" Then
            _sqlLiteral = "''"
         Else
            _sqlLiteral = TCfgSql.Str(text)
         End If
      End Function

      Private Shared Function _valueOf(pValues As StringList, pName As String) As String
         Dim key As String = UCase(Trim(pName))
         Dim text As String = ""
         If Assigned(pValues) Then
            text = pValues.Values(key)
         End If
         If Trim(text) <> "" Then
            _valueOf = text
            Exit Function
         End If
         Dim fallback As String = text
         Try
            If key = "CODEMPRESA" Then
               fallback = CStr(Ambient.CodEmpresa())
            ElseIf key = "CODFILIAL" Then
               fallback = CStr(Ambient.CodFilial())
            ElseIf key = "CODUSUARIO" Then
               fallback = CStr(Ambient.CodUsuario())
            End If
         Catch ex As Exception
            fallback = text
         End Try
         _valueOf = fallback
      End Function

      Private Shared Function _sqlInt(pText As String) As String
         Dim raw As String = Trim(pText)
         If raw = "" Then
            _sqlInt = "NULL"
            Exit Function
         End If
         Dim number As Integer
         If TryStrToInt(raw, number) Then
            _sqlInt = CStr(number)
         Else
            _sqlInt = "NULL"
         End If
      End Function

      Private Shared Function _sqlNum(pText As String) As String
         Dim raw As String = Trim(pText)
         If raw = "" Then
            _sqlNum = "NULL"
            Exit Function
         End If
         Dim literal As String = "NULL"
         Try
            Dim work As String = raw
            If work.Contains(",") Then
               work = work.Replace(".", "")
               work = work.Replace(",", ".")
            End If
            Dim n As Extended = CDbl(work)
            literal = CStr(n).Replace(",", ".")
         Catch ex As Exception
            literal = "NULL"
         End Try
         _sqlNum = literal
      End Function

      Private Shared Function _sqlDate(pText As String, pWithTime As Boolean) As String
         Dim raw As String = Trim(pText)
         If raw = "" Then
            _sqlDate = "NULL"
            Exit Function
         End If
         Dim parsed As TDateTime
         If pWithTime Then
            If TField.TryParseDateTime(raw, parsed) Then
               _sqlDate = TSql.LiteralDate(parsed, True)
            Else
               _sqlDate = "NULL"
            End If
         ElseIf TField.TryParseDate(raw, parsed) Then
            _sqlDate = TSql.LiteralDate(parsed, False)
         Else
            _sqlDate = "NULL"
         End If
      End Function

      Private Shared Function _sqlTime(pText As String) As String
         Dim raw As String = Trim(pText)
         If raw = "" Then
            _sqlTime = "NULL"
            Exit Function
         End If
         Dim parsed As TDateTime
         If TField.TryParseTime(raw, parsed) Then
            _sqlTime = TSql.LiteralTime(parsed)
         Else
            _sqlTime = "NULL"
         End If
      End Function

      Private Shared Function _isOutParam(pName As String) As Boolean
         Dim key As String = UCase(Trim(pName))
         _isOutParam = CBool((key = "ACAO") Or (key = "MENSAGEM"))
      End Function

      Private Shared Function _isInteger(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isInteger = False
            Exit Function
         End If
         Dim tipo As String = UCase(Trim(pField.Tipo))
         Dim kind As String = UCase(pField.KindKey())
         _isInteger = CBool((tipo = "I") Or (tipo = "L") Or (kind = "INTEGER"))
      End Function

      Private Shared Function _isNumber(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isNumber = False
            Exit Function
         End If
         Dim tipo As String = UCase(Trim(pField.Tipo))
         Dim kind As String = UCase(pField.KindKey())
         _isNumber = CBool((tipo = "N") Or (kind = "NUMBER") Or (kind = "VALUE"))
      End Function

      Private Shared Function _isDate(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isDate = False
            Exit Function
         End If
         Dim tipo As String = UCase(Trim(pField.Tipo))
         Dim kind As String = UCase(pField.KindKey())
         _isDate = CBool((tipo = "D") Or (kind = "DATE"))
      End Function

      Private Shared Function _isTime(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isTime = False
            Exit Function
         End If
         Dim tipo As String = UCase(Trim(pField.Tipo))
         Dim kind As String = UCase(pField.KindKey())
         _isTime = CBool((tipo = "T") Or (kind = "TIME"))
      End Function

      Private Shared Function _isDateTime(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isDateTime = False
            Exit Function
         End If
         Dim tipo As String = UCase(Trim(pField.Tipo))
         Dim kind As String = UCase(pField.KindKey())
         _isDateTime = CBool((tipo = "DT") Or (kind = "DATETIME"))
      End Function

      Private Shared Function _isMemo(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isMemo = False
            Exit Function
         End If
         Dim kind As String = UCase(pField.KindKey())
         _isMemo = CBool((kind = "MEMO") Or (kind = "TEXTO"))
      End Function

      Private Shared Function _isCheck(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isCheck = False
            Exit Function
         End If
         _isCheck = CBool(UCase(pField.KindKey()) = "CHECK")
      End Function

      Private Shared Function _isImage(pField As TRegisterField) As Boolean
         If Not Assigned(pField) Then
            _isImage = False
            Exit Function
         End If
         Dim tipo As String = UCase(Trim(pField.Tipo))
         Dim kind As String = UCase(pField.KindKey())
         _isImage = CBool((tipo = "IM") Or (kind = "IMAGE") Or (kind = "IMAGEM") Or (kind = "FOTO"))
      End Function

      Private Shared Sub _splitParams(pText As String, pDest As StringList)
         Dim raw As String = Trim(pText)
         If raw = "" Then
            Exit Sub
         End If
         Dim startAt As Integer = 0
         Dim i As Integer
         Dim n As Integer = raw.Length
         For i = 0 To n - 1
            If TRegisterValidation._slice(raw, i, 1) = "," Then
               Dim piece As String = TRegisterValidation._cleanParam(TRegisterValidation._slice(raw, startAt, i - startAt))
               If piece <> "" Then
                  pDest.Add(piece)
               End If
               startAt = i + 1
            End If
         Next
         Dim lastPiece As String = TRegisterValidation._cleanParam(TRegisterValidation._from(raw, startAt))
         If lastPiece <> "" Then
            pDest.Add(lastPiece)
         End If
      End Sub

      Private Shared Function _cleanParam(pRaw As String) As String
         Dim s As String = Trim(pRaw)
         If s.StartsWith("@") Then
            s = Trim(s.Right(s.Length - 1))
         End If
         Dim u As String = UCase(s)
         If u.EndsWith(" OUTPUT") Then
            s = Trim(s.Left(s.Length - 7))
         ElseIf u.EndsWith(" OUT") Then
            s = Trim(s.Left(s.Length - 4))
         End If
         _cleanParam = s
      End Function

      Private Shared Function _find(pText As String, pToken As String) As Integer
         Dim tLen As Integer = pToken.Length
         If tLen <= 0 Then
            _find = -1
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pText.Length - tLen
         For i = 0 To n
            If TRegisterValidation._slice(pText, i, tLen) = pToken Then
               _find = i
               Exit Function
            End If
         Next
         _find = -1
      End Function

      Private Shared Function _findLast(pText As String, pToken As String) As Integer
         Dim last As Integer = -1
         Dim tLen As Integer = pToken.Length
         If tLen <= 0 Then
            _findLast = -1
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pText.Length - tLen
         For i = 0 To n
            If TRegisterValidation._slice(pText, i, tLen) = pToken Then
               last = i
            End If
         Next
         _findLast = last
      End Function

      Private Shared Function _findSpace(pText As String) As Integer
         Dim i As Integer
         Dim n As Integer = pText.Length - 1
         For i = 0 To n
            Dim ch As String = TRegisterValidation._slice(pText, i, 1)
            If (ch = " ") Or (ch = Char(9)) Then
               _findSpace = i
               Exit Function
            End If
         Next
         _findSpace = -1
      End Function

      Private Shared Function _slice(pText As String, pStart As Integer, pCount As Integer) As String
         If (pStart < 0) Or (pCount <= 0) Or (pStart >= pText.Length) Then
            _slice = ""
            Exit Function
         End If
         Dim rest As String = pText.Right(pText.Length - pStart)
         If rest.Length <= pCount Then
            _slice = rest
         Else
            _slice = rest.Left(pCount)
         End If
      End Function

      Private Shared Function _from(pText As String, pStart As Integer) As String
         If pStart <= 0 Then
            _from = pText
         ElseIf pStart >= pText.Length Then
            _from = ""
         Else
            _from = pText.Right(pText.Length - pStart)
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
