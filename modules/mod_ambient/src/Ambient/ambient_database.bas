Imports mod_tobject

Namespace ambient_database

   Class TDatabase
      Inherits TTObject

      Description As String
      Name As String
      Host As String
      Port As Integer
      User As String
      Pass As String
      RDBMS As TRDBMS
      Schema As String

      Sub New()
         MyBase.New()
      End Sub

      Function RDBMSAsString() As String
         If me.RDBMS = dbMSSQL Then
            RDBMSAsString = "Sql Server"
         ElseIf me.RDBMS = dbASA Then
            RDBMSAsString = "Sybase"
         ElseIf me.RDBMS = dbPostgreSQL Then
            RDBMSAsString = "PostgreSql"
         End If
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("Database")
            .Prop("Description", me.Description)
            .Prop("Name", me.Name)
            .Prop("Host", me.Host)
            .Prop("Port", me.Port)
            .Prop("User", me.User)
            .Prop("Pass", me.Pass)
            .Prop("RDBMS", me.RDBMSAsString())
            .Prop("Schema", me.Schema)
            ToString = .Text
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
