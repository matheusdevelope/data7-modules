Imports TablesSql
Imports Data7

Namespace configurador_sql

   Private Dim _CodPeriodocaixa As String

   Class TCfgSql
      Sub New()
         MyBase.New()
      End Sub

      Shared Function Str(pValue As String) As String
         Str = "'" & Trim(pValue).Replace("'", "''") & "'"
      End Function

      Shared Function Int(pValue As Integer) As String
         Int = CStr(pValue)
      End Function

      Shared Function EqInt(pField As String, pValue As Integer) As String
         EqInt = pField & " = " & CStr(pValue)
      End Function

      Shared Function EqStr(pField As String, pValue As String) As String
         EqStr = pField & " = " & TCfgSql.Str(pValue)
      End Function

      Shared Function EqStrCI(pField As String, pValue As String) As String
         EqStrCI = "UPPER(" & pField & ") = " & TCfgSql.Str(UCase(Trim(pValue)))
      End Function

      Shared Function AndInt(pLeft As String, pField As String, pValue As Integer) As String
         AndInt = pLeft & " AND " & TCfgSql.EqInt(pField, pValue)
      End Function

      Shared Function Tabela(pCodTabela As Integer) As String
         Tabela = TCfgSql.EqInt("codtabela", pCodTabela)
      End Function

      Shared Function Usuario(pCodUsuario As Integer) As String
         Usuario = TCfgSql.EqInt("codusuario", pCodUsuario)
      End Function

      Shared Function NomeSchema(pNome As String, pSchema As String) As String
         Dim schemaName As String = Trim(pSchema)
         If schemaName = "" Then
            schemaName = TSql.Dialect().DefaultSchema()
         End If
         NomeSchema = TCfgSql.EqStrCI("nome", pNome) & " AND " & TCfgSql.EqSchema("NomeSchema", schemaName)
      End Function

      Shared Function EqSchema(pField As String, pSchema As String) As String
         Dim padrao As String = TCfgSql.Str(TSql.Dialect().DefaultSchema())
         Dim expr As String
         If SQL.Connection.RDBMS = dbPostgreSQL Then
            expr = "COALESCE(NULLIF(" & pField & ", ''), " & padrao & ")"
         Else
            expr = "ISNULL(NULLIF(" & pField & ", ''), " & padrao & ")"
         End If
         EqSchema = "UPPER(" & expr & ") = " & TCfgSql.Str(UCase(Trim(pSchema)))
      End Function

      Shared Function AvaliarCondicao(pExpr As String, pVazio As Boolean = False) As Boolean
         Dim v As String = Trim(pExpr & "")
         If v = "" Then
            AvaliarCondicao = pVazio
            Exit Function
         End If
         If TCfgFlag.Sim(v) Then
            AvaliarCondicao = True
            Exit Function
         End If
         If TCfgFlag.Nao(v) Then
            AvaliarCondicao = False
            Exit Function
         End If
         AvaliarCondicao = (TSql.ExecScalarInteger("SELECT CASE WHEN (" & v & ") THEN 1 ELSE 0 END AS ok", 0) <> 0)
      End Function

      Shared Function AvaliarValorPadrao(pTipo As String, pFormula As String) As String
         Dim tipo As String = UCase(Trim(pTipo & ""))
         Dim formula As String = Trim(pFormula & "")
         If tipo = "FIXO" Then
            AvaliarValorPadrao = formula
         ElseIf (tipo = "VARIAVEL") Or (tipo = "VARIÁVEL") Then
            AvaliarValorPadrao = TCfgSql.AvaliarValorPadraoVariavel(formula)
         ElseIf (tipo = "FORMULA") Or (tipo = "FÓRMULA") Or (tipo = "SQL") Then
            AvaliarValorPadrao = TCfgSql.AvaliarFormula(formula)
         ElseIf formula = "" Then
            AvaliarValorPadrao = ""
         Else
            Dim variavel As String = TCfgSql.AvaliarValorPadraoVariavel(formula)
            If variavel <> "" Then
               AvaliarValorPadrao = variavel
            Else
               AvaliarValorPadrao = TCfgSql.AvaliarFormula(formula)
            End If
         End If
      End Function
      Shared Function AvaliarValorPadraoVariavel(pFormula As String) As String
         Select UCase(Trim(pFormula))
            Case "CODEMPRESA"
               AvaliarValorPadraoVariavel = CStr(Data7.CodEmpresa())
            Case "CODFILIAL"
               AvaliarValorPadraoVariavel = CStr(Data7.CodFilial())
            Case "CODUSUARIO"
               AvaliarValorPadraoVariavel = CStr(Data7.CodUsuario())
            Case "NOMEUSUARIO"
               AvaliarValorPadraoVariavel = Data7.NomeUsuario()
            Case "CODPERIODOCAIXA"
               If _CodPeriodoCaixa = "" Then
                  _CodPeriodoCaixa = CStr(Data7.CodPeriodoCaixa())
               End If
               AvaliarValorPadraoVariavel = _CodPeriodoCaixa
            Case "NOMECOMPUTADOR"
               AvaliarValorPadraoVariavel = Environment.MachineName()
            Case "DATAATUAL"
               AvaliarValorPadraoVariavel = DateTime().ToString("dd/mm/yyyy")
            Case "HORAATUAL"
               AvaliarValorPadraoVariavel = DateTime().ToString("hh:nn:ss.zzz")
            Case "DATAHORAATUAL"
               AvaliarValorPadraoVariavel = DateTime().ToString("dd/mm/yyyy hh:nn:ss.zzz")
            Case "MESATUAL"
               AvaliarValorPadraoVariavel = DateTime().ToString("mm")
            Case "ANOATUAL"
               AvaliarValorPadraoVariavel = DateTime().ToString("yyyy")
            Case Else
               AvaliarValorPadraoVariavel = ""
         End Select
      End Function

      Shared Function AvaliarValor(pConAsString As String, pFormula As String, pNomeCampo As String = "", pQueryBase As String = "") As String
         Dim formula As String = Trim(pFormula)
         If (Trim(pConAsString) <> "C") Or (formula = "") Then
            AvaliarValor = ""
            Exit Function
         End If
         Dim queryBase As String = Trim(pQueryBase)
         If queryBase = "" Then
            AvaliarValor = TCfgSql.AvaliarFormula(formula)
            Exit Function
         End If
         Dim nome As String = Trim(pNomeCampo)
         Dim sqlText As String = queryBase.Replace(":" & nome, "(" & formula & ") AS " & nome)
         AvaliarValor = TCfgSql.ExecutarColuna(sqlText, nome)
      End Function

      Shared Function AvaliarFormula(pFormula As String) As String
         Dim formula As String = Trim(pFormula)
         If formula = "" Then
            AvaliarFormula = ""
         Else
            AvaliarFormula = TSql.ExecSelect(formula)
         End If
      End Function

      Shared Function ExecutarColuna(pSql As String, pCampo As String) As String
         Dim query As SQL.Command = TSql.OpenQuery(pSql)
         If query.Eof Then
            ExecutarColuna = ""
         Else
            ExecutarColuna = query.Field(pCampo).AsString
         End If
         query.Close()
         query.Free()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TCfgDb
      Sub New()
         MyBase.New()
      End Sub

      Shared Function FromSql(pSchema As String, pTabela As String) As String
         FromSql = TSql.Dialect().QuoteTable(pSchema, pTabela)
      End Function

      Shared Function SelectAll(pSchema As String, pTabela As String, pWhere As String, pOrder As String) As String
         Dim d As TSqlDialect = TSql.Dialect()
         SelectAll = "SELECT * FROM " & d.QuoteTable(pSchema, pTabela) & d.NormalizeWhere(pWhere) & d.NormalizeOrderBy(pOrder)
      End Function

      Shared Function Abrir(pSchema As String, pTabela As String, pWhere As String, pOrder As String) As SQL.Command
         Abrir = TSql.OpenQuery(TCfgDb.SelectAll(pSchema, pTabela, pWhere, pOrder))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TCfgRow
      Sub New()
         MyBase.New()
      End Sub

      Shared Function AsString(pValue As String) As String
         Dim token As String = LCase(Trim(pValue))
         If (token = "") Or (token = "null") Then
            AsString = Unassigned
         Else
            AsString = pValue
         End If
      End Function

      Shared Function AsInteger(pValue As String) As Integer
         pValue = LCase(Trim(pValue))
         If pValue = "" Then
            AsInteger = Unassigned
         ElseIf pValue = "null" Then
            AsInteger = Unassigned
         Else
            AsInteger = CInt(pValue)
         End If
      End Function

      Shared Function Flag(pJson As TJSONObject, pNome As String) As Boolean
         Flag = TCfgFlag.Sim(TCfgRow.AsString(pJson.GetString(pNome)))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TCfgFlag
      Sub New()
         MyBase.New()
      End Sub

      Shared Function Sim(pValue As String) As Boolean
         Dim v As String = UCase(Trim(pValue))
         Sim = (v = "S") Or (v = "SIM") Or (v = "1") Or (v = "T") Or (v = "TRUE") Or (v = "NOT IS FALSE")
      End Function

      Shared Function Nao(pValue As String) As Boolean
         Dim v As String = UCase(Trim(pValue & ""))
         Nao = (v = "") Or (v = "N") Or (v = "NAO") Or (v = "NÃO") Or (v = "0") Or (v = "F") Or (v = "FALSE") Or (v = "FALSO") Or (v = "NOT IS TRUE")
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
