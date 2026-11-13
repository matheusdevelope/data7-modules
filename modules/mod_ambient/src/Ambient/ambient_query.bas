Imports ambient_context
Imports ambient_json
Imports Collections
Imports TablesSql
Imports configurador_sql
' Imports TablesMigration

' data7:disable qualified-private-shared-access

Namespace ambient_query

   Class TAmbientQuery

   ' Private Shared Function SqlIxLogSistemaSessao() As String
   '    Dim d As TSqlDialect = TSql.Dialect()
   '    Dim idx As String = d.QuoteIdent("IX_LogSistema_SessaoApp_Otimizado")
   '    Dim tbl As String = d.QuoteIdent("LogSistema")
   '    Dim keys As String = d.QuoteIdent("ID_Empresa") & ", " & d.QuoteIdent("ID_Filial") & ", " & d.QuoteIdent("TipoLog") & ", " & d.QuoteIdent("UsuarioWindows") & ", " & d.QuoteIdent("NomeComputador") & ", " & d.QuoteIdent("NomeUsuario") & ", " & d.QuoteIdent("CodLogSistema") & " DESC"
   '    Dim incl As String = d.QuoteIdent("Data") & ", " & d.QuoteIdent("Hora")
   '    Select Case SQL.Connection.RDBMS
   '       Case dbPostgreSQL
   '          SqlIxLogSistemaSessao = "CREATE INDEX " & idx & " ON " & tbl & " (" & keys & ") INCLUDE (" & incl & ")"
   '       Case dbASA
   '          SqlIxLogSistemaSessao = "CREATE INDEX " & idx & " ON " & tbl & " (" & keys & ", " & incl & ")"
   '       Case Else
   '          SqlIxLogSistemaSessao = "CREATE NONCLUSTERED INDEX " & idx & " ON " & tbl & " (" & keys & ") INCLUDE (" & incl & ")"
   '    End Select
   ' End Function

   ' Private Shared Sub MigrateIndexLogSistema()
   '    Dim runner As New TMigrationRunner()
   '    Dim d As TSqlDialect = TSql.Dialect()
   '    Dim migIdx As New TScriptMigration("20260922_ix_logsistema_sessao", TAmbientQuery.SqlIxLogSistemaSessao())
   '    migIdx.RawSqlDown = d.SqlDropIndexOnTable("IX_LogSistema_SessaoApp_Otimizado", "LogSistema")
   '    runner.Registerr(migIdx)
   '    runner.Execute()
   ' End Sub

      Shared Sub Load(pCtx As TContext)
         Dim sqlText As String = TAmbientQuery.Build(pCtx)
         Using query As New SQL.Command()
            query.CommandText = sqlText
            Try
               query.Open()
            Catch ex As Exception
               Throw New Exception("Erro ao obter dados do ambiente:" & CHAR(13) & ex._GetMessage() & CHAR(13) & sqlText)
            End Try
            If query.Eof Then
               Throw New Exception("Nenhum registro de ambiente encontrado para empresa/filial/usuario informados.")
            End If
            If pCtx.LoadAmbient Then
               TAmbientJson.Fill(pCtx.Sistema, query.Field("sistema").AsString)
               TAmbientJson.Fill(pCtx.Empresa, query.Field("empresa").AsString)
               If pCtx.Empresa.CodEmpresa <= 0 Then
                  Throw New Exception("Nenhum registro de ambiente encontrado para empresa/filial/usuario informados.")
               End If
               TAmbientJson.Fill(pCtx.Filial, query.Field("filial").AsString)
               TAmbientJson.Fill(pCtx.Usuario, query.Field("usuario").AsString)
               TAmbientJson.Fill(pCtx.Sessao, query.Field("sessao").AsString)
               TAmbientJson.Fill(pCtx.Periodo, query.Field("periodo").AsString)
               TAmbientJson.Fill(pCtx.Estacao, query.Field("estacao").AsString)
               TAmbientQuery.FillDatabase(pCtx, query)
            End If
            TAmbientJson.Fill(pCtx.Menu, query.Field("menu").AsString)
            TAmbientJson.Fill(pCtx.MenuPai, query.Field("menupai").AsString)
            TAmbientJson.Fill(pCtx.Processo, query.Field("processo").AsString)
         End Using
      End Sub

      Private Shared Function Build(pCtx As TContext) As String
         Using _sql As New StringList()
            If pCtx.LoadAmbient Then
               _sql.Add("WITH sessao AS (")
               _sql.Add(TAmbientJson.LimitOne(TAmbientQuery.SqlSession(pCtx)))
               _sql.Add("),")
               _sql.Add("menu_log AS (")
            Else
               _sql.Add("WITH menu_log AS (")
            End If
            _sql.Add(TAmbientJson.LimitOne(TAmbientQuery.SqlMenuLog(pCtx)))
            _sql.Add(")")
            _sql.Add("SELECT")
            Using parts As New StringList()
               If pCtx.LoadAmbient Then
                  parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Sistema, "")), "sistema"))
                  parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Empresa, "CodEmpresa = " & TCfgSql.Int(pCtx.CodEmpresa))), "empresa"))
                  parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Filial, "CodEmpresa = " & TCfgSql.Int(pCtx.CodEmpresa) & " AND CodFilial = " & TCfgSql.Int(pCtx.CodFilial))), "filial"))
                  parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Usuario, "CodUsuario = " & TCfgSql.Int(pCtx.CodUsuario))), "usuario"))
                  parts.Add(TAmbientJson.SqlJson(TAmbientJson.SelectColumns(pCtx.Sessao, "sessao", ""), "sessao"))
                  parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Periodo, TAmbientQuery.SqlPeriodoWhere(pCtx))), "periodo"))
                  parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Estacao, TAmbientQuery.SqlEstacaoWhere(pCtx))), "estacao"))
                  parts.Add(TAmbientQuery.SqlDatabase())
               End If
               parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Menu, TAmbientQuery.SqlMenuWhere(pCtx))), "menu"))
               parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.MenuPai, TAmbientQuery.SqlMenuPaiWhere(pCtx))), "menupai"))
               parts.Add(TAmbientJson.SqlJson(TAmbientJson.LimitOne(TAmbientJson.SelectFromTable(pCtx.Processo, TAmbientQuery.SqlProcessoWhere(pCtx))), "processo"))
               Dim i As Integer
               Dim last As Integer = parts.Count - 1
               For i = 0 To last
                  Dim expr As String = parts.Strings(i)
                  If i < last Then
                     expr = expr & ","
                  End If
                  _sql.Add(expr)
               Next
            End Using
            Build = _sql.Text
         End Using
      End Function

      Private Shared Function SqlModuloExpr(pCtx As TContext) As String
         If pCtx.LoadAmbient Then
            SqlModuloExpr = "(SELECT CodModulo FROM sessao)"
         Else
            SqlModuloExpr = TCfgSql.Int(pCtx.Sessao.CodModulo)
         End If
      End Function

      Private Shared Function SqlPeriodoWhere(pCtx As TContext) As String
         If pCtx.LoadAmbient Then
            SqlPeriodoWhere = "CodEmpresa = (SELECT CodEmpresa FROM sessao) AND CodPeriodoCaixa = (SELECT CodPeriodoCaixa FROM sessao)"
         Else
            SqlPeriodoWhere = "CodEmpresa = " & TCfgSql.Int(pCtx.Sessao.CodEmpresa) & " AND CodPeriodoCaixa = " & TCfgSql.Int(pCtx.Sessao.CodPeriodoCaixa)
         End If
      End Function

      Private Shared Function SqlEstacaoWhere(pCtx As TContext) As String
         If pCtx.LoadAmbient Then
            SqlEstacaoWhere = "CodEstacao = (SELECT CodEstacaoTrabalho FROM sessao)"
         Else
            SqlEstacaoWhere = "CodEstacao = " & TCfgSql.Int(pCtx.Sessao.CodEstacaoTrabalho)
         End If
      End Function

      Private Shared Function SqlProcessoWhere(pCtx As TContext) As String
         If pCtx.CodProcessoTabela > 0 Then
            If pCtx.CodTabela > 0 Then
               SqlProcessoWhere = "CodTabela = " & TCfgSql.Int(pCtx.CodTabela) & " AND CodProcessoTabela = " & TCfgSql.Int(pCtx.CodProcessoTabela)
            Else
               SqlProcessoWhere = "CodProcessoTabela = " & TCfgSql.Int(pCtx.CodProcessoTabela)
            End If
         ElseIf (Trim(pCtx.TituloProcessoTabela) <> "") And (pCtx.CodTabela > 0) Then
            SqlProcessoWhere = "CodTabela = " & TCfgSql.Int(pCtx.CodTabela) & " AND " & TAmbientJson.Cmp("Titulo", TCfgSql.Str(pCtx.TituloProcessoTabela))
         Else
            SqlProcessoWhere = "1 = 0"
         End If
      End Function

      Private Shared Function SqlMenuWhere(pCtx As TContext) As String
         SqlMenuWhere = "CodModulo = " & TAmbientQuery.SqlModuloExpr(pCtx) & " AND CodMenu = (SELECT CAST(codmenu AS INTEGER) FROM menu_log)"
      End Function

      Private Shared Function SqlMenuPaiWhere(pCtx As TContext) As String
         Dim moduloExpr As String = TAmbientQuery.SqlModuloExpr(pCtx)
         SqlMenuPaiWhere = "CodModulo = " & moduloExpr & " AND CodMenu = (SELECT CodMenuPai FROM " & TSql.Dialect().QuoteTable("", "Menu") & " WHERE CodModulo = " & moduloExpr & " AND CodMenu = (SELECT CAST(codmenu AS INTEGER) FROM menu_log))"
      End Function

      Private Shared Function SqlSession(pCtx As TContext) As String
         Dim schemaName As String = TSql.Dialect().DefaultSchema()
         SqlSession = "SELECT * FROM " & TSql.Dialect().QuoteTable("", "SessaoConexao") & " WHERE CodUsuario = " & TCfgSql.Int(pCtx.CodUsuario) & " AND COALESCE(CodEmpresa, " & TCfgSql.Int(pCtx.CodEmpresa) & ") = " & TCfgSql.Int(pCtx.CodEmpresa) & " AND COALESCE(CodFilial, " & TCfgSql.Int(pCtx.CodFilial) & ") = " & TCfgSql.Int(pCtx.CodFilial) & " AND CodSessaoConexao = " & schemaName & ".CodSessaoConexao()"
      End Function

      Private Shared Function RecentLogs() As String
         Dim inner As String = "SELECT * FROM LogSistema ORDER BY CodLogSistema DESC"
         RecentLogs = "(" & TSql.Dialect().ApplyLimit(inner, 10) & ") LS"
      End Function

      Private Shared Function SqlMenuLog(pCtx As TContext) As String
          SqlMenuLog = "SELECT LD.Valor AS codmenu FROM " & TAmbientQuery.RecentLogs() & " JOIN LogSistemaDetalhe LD ON LD.ID_LogSistema = LS.CodLogSistema JOIN Usuario LU ON " & TAmbientJson.Cmp("LU.NomeLegivel", "LS.NomeUsuario") & " WHERE " & TAmbientJson.Cmp("LS.TipoLog", TCfgSql.Str("AMENU")) & " AND " & TAmbientJson.CmpCI("LS.UsuarioWindows", TCfgSql.Str(pCtx.StationUser)) & " AND " & TAmbientJson.CmpCI("LS.NomeComputador", TCfgSql.Str(pCtx.StationName)) & " AND LS.ID_Empresa = " & TCfgSql.Int(pCtx.CodEmpresa) & " AND LS.ID_Filial = " & TCfgSql.Int(pCtx.CodFilial) & " AND LU.CodUsuario = " & TCfgSql.Int(pCtx.CodUsuario) & " AND UPPER(LD.Nome) = 'CÓDIGO' ORDER BY LS.CodLogSistema DESC"
         'SqlMenuLog = "SELECT LD.Valor AS codmenu FROM LogSistema LS JOIN LogSistemaDetalhe LD ON LD.ID_LogSistema = LS.CodLogSistema JOIN Usuario LU ON " & TAmbientJson.Cmp("LU.NomeLegivel", "LS.NomeUsuario") & " WHERE " & TAmbientJson.Cmp("LS.TipoLog", TCfgSql.Str("AMENU")) & " AND " & TAmbientJson.CmpCI("LS.UsuarioWindows", TCfgSql.Str(pCtx.StationUser)) & " AND " & TAmbientJson.CmpCI("LS.NomeComputador", TCfgSql.Str(pCtx.StationName)) & " AND LS.ID_Empresa = " & TCfgSql.Int(pCtx.CodEmpresa) & " AND LS.ID_Filial = " & TCfgSql.Int(pCtx.CodFilial) & " AND LU.CodUsuario = " & TCfgSql.Int(pCtx.CodUsuario) & " AND " & TAmbientJson.CmpCI("LD.Nome", TCfgSql.Str("CÓDIGO")) & " ORDER BY LS.CodLogSistema DESC"
      End Function

      Private Shared Function SqlDatabase() As String
         Dim rdbms As TRDBMS = SQL.Connection.RDBMS
         Dim sqlText As String = ""
         If rdbms = dbPostgreSQL Then
            sqlText = "current_database() AS Database_Nome, CAST(COALESCE(CAST(inet_server_addr() AS VARCHAR), '') AS VARCHAR) AS Database_Host, CAST(COALESCE(CAST(inet_server_port() AS VARCHAR), '') AS VARCHAR) AS Database_Porta, CURRENT_USER AS Database_Usuario, "
         Else
            sqlText = "DB_NAME() AS Database_Nome, "
            If rdbms = dbASA Then
               sqlText = sqlText & "CAST(PROPERTY('MachineName') AS VARCHAR) AS Database_Host, TRIM(REPLACE((SELECT row_value FROM sa_split_list(PROPERTY('CommandLine'), '=') WHERE line_num = 2), ')', '')) AS Database_Porta, suser_name() AS Database_Usuario, "
            Else
               sqlText = sqlText & "CAST(SERVERPROPERTY('MachineName') AS VARCHAR) AS Database_Host, CAST(COALESCE(CONNECTIONPROPERTY('local_tcp_port'), ' ') AS VARCHAR) AS Database_Porta, SYSTEM_USER AS Database_Usuario, "
            End If
         End If
         Dim password As String = "SELECT COALESCE(NULLIF(" & TAmbientJson.CastC("VP.Valor") & ", " & TAmbientJson.CastC("''") & "), " & TAmbientJson.CastC("P.ValorPadrao") & ") FROM Parametro P JOIN ValorParametro VP ON VP.CodParametro = P.CodParametro WHERE " & TAmbientJson.Cmp("P.Nome", TCfgSql.Str("Backup_SenhaBancoDados"))
         sqlText = sqlText & "(" & TAmbientJson.LimitOne(password) & ") AS Database_Senha"
         SqlDatabase = sqlText
      End Function

      Private Shared Sub FillDatabase(pCtx As TContext, pQuery As SQL.Command)
         pCtx.Database.Description = pQuery.Field("Database_Nome").AsString
         pCtx.Database.Name = pQuery.Field("Database_Nome").AsString
         pCtx.Database.Host = pQuery.Field("Database_Host").AsString
         pCtx.Database.Port = pQuery.Field("Database_Porta").AsInteger
         pCtx.Database.User = pQuery.Field("Database_Usuario").AsString
         pCtx.Database.Pass = pQuery.Field("Database_Senha").AsString
         pCtx.Database.RDBMS = SQL.Connection.RDBMS()
         pCtx.Database.Schema = TSql.Dialect().DefaultSchema()
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
