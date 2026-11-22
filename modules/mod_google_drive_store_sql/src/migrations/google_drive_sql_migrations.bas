Imports mod_tobject
Imports TablesMigration
Imports TablesSql
Imports TablesSchema
Imports configuracao_google_drive

Namespace google_drive_sql_migrations

   Class TConfiguracaoGoogleDriveMigration
      Inherits TMigration

      Sub New()
         MyBase.New("configuracao_google_drive_customizado_01", New TConfiguracaoGoogleDrive())
      End Sub

      Overrides Sub Up(pCtx As TMigrationContext)
         Dim sch As TTableSchema = me.Table.Schema
         Dim qualified As String = Trim(sch.SchemaName) & "." & sch.TableName
         If Not pCtx.Ddl.TableExists(qualified) Then
            Dim sqlDialect As TSqlDialect = TSql.Dialect()
            Dim createSql As String = sqlDialect.SqlCreateTable(sch)
            Dim fromName As String = "CREATE TABLE " & sqlDialect.QuoteIdent(sch.TableName)
            Dim toName As String = "CREATE TABLE " & sqlDialect.QuoteTable(sch.SchemaName, sch.TableName)
            createSql = createSql.Replace(fromName, toName)
            TSql.ExecScript(createSql)
         End If
         Dim seqName As String = TSql.ResolvedSequenceName(sch, False, 0)
         If seqName <> "" Then
            If Not pCtx.Ddl.SequenceExists(seqName) Then
               pCtx.Ddl.CreateSequence(seqName)
            End If
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class GoogleDriveSqlMigrations
      Inherits TTObject

      Shared Function NewRunner() As TMigrationRunner
         Dim runner As New TMigrationRunner()
         runner.Registerr(New TConfiguracaoGoogleDriveMigration())
         NewRunner = runner
      End Function

      Shared Function Execute() As Integer
         Dim runner As TMigrationRunner = GoogleDriveSqlMigrations.NewRunner()
         Dim applied As Integer
         applied = runner.Execute()
         runner.Free()
         Execute = applied
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
