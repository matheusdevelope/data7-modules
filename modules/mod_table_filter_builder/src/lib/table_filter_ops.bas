Namespace table_filter_ops

   ' data7:disable-next-line missing-mybase-free
   Class TFilterOps

      Shared Function Equal() As String
         Equal = "EQ"
      End Function

      Shared Function NotEqual() As String
         NotEqual = "NE"
      End Function

      Shared Function InList() As String
         InList = "IN"
      End Function

      Shared Function NotInList() As String
         NotInList = "NIN"
      End Function

      Shared Function Less() As String
         Less = "LT"
      End Function

      Shared Function LessEqual() As String
         LessEqual = "LE"
      End Function

      Shared Function Greater() As String
         Greater = "GT"
      End Function

      Shared Function GreaterEqual() As String
         GreaterEqual = "GE"
      End Function

      Shared Function Between() As String
         Between = "BW"
      End Function

      Shared Function NotBetween() As String
         NotBetween = "NBW"
      End Function

      Shared Function StartsWith() As String
         StartsWith = "SW"
      End Function

      Shared Function NotStartsWith() As String
         NotStartsWith = "NSW"
      End Function

      Shared Function Contains() As String
         Contains = "CT"
      End Function

      Shared Function NotContains() As String
         NotContains = "NCT"
      End Function

      Shared Function Empty() As String
         Empty = "NL"
      End Function

      Shared Function NotEmpty() As String
         NotEmpty = "NN"
      End Function

      Shared Function SqlQuery() As String
         SqlQuery = "SQL"
      End Function

      Shared Function AllowsSqlQuery() As Boolean
         AllowsSqlQuery = Data7.NomeUsuario().ToUpper() = "ADMINISTRADOR"
      End Function

      Shared Function ListaOpcoes() As String
         Dim list As String = ""
         list = list & "Igual a=EQ".Quoted() & ";"
         list = list & "não igual a=NE".Quoted() & ";"
         list = list & "seja vazio=NL".Quoted() & ";"
         list = list & "não seja vazio=NN".Quoted() & ";"
         list = list & "seja um entre=IN".Quoted() & ";"
         list = list & "não seja um entre=NIN".Quoted() & ";"
         list = list & "seja menor que=LT".Quoted() & ";"
         list = list & "seja menor que ou igual a=LE".Quoted() & ";"
         list = list & "seja maior que=GT".Quoted() & ";"
         list = list & "seja maior que ou igual a=GE".Quoted() & ";"
         list = list & "esteja entre=BW".Quoted() & ";"
         list = list & "não esteja entre=NBW".Quoted() & ";"
         list = list & "inicie com=SW".Quoted() & ";"
         list = list & "não inicie com=NSW".Quoted() & ";"
         list = list & "contenha=CT".Quoted() & ";"
         list = list & "não Contenha=NCT".Quoted()
         If TFilterOps.AllowsSqlQuery() Then
            list = list & ";" & "SQL Query=SQL".Quoted()
         End If
         ListaOpcoes = list
      End Function

      Shared Function TitleOf(pOp As String) As String
         Dim op As String = UCase(Trim(pOp))
         If op = "EQ" Then
            TitleOf = "Igual a"
         ElseIf op = "NE" Then
            TitleOf = "não igual a"
         ElseIf op = "NL" Then
            TitleOf = "seja vazio"
         ElseIf op = "NN" Then
            TitleOf = "não seja vazio"
         ElseIf op = "IN" Then
            TitleOf = "seja um entre"
         ElseIf op = "NIN" Then
            TitleOf = "não seja um entre"
         ElseIf op = "LT" Then
            TitleOf = "seja menor que"
         ElseIf op = "LE" Then
            TitleOf = "seja menor que ou igual a"
         ElseIf op = "GE" Then
            TitleOf = "seja maior que ou igual a"
         ElseIf op = "GT" Then
            TitleOf = "seja maior que"
         ElseIf op = "BW" Then
            TitleOf = "esteja entre"
         ElseIf op = "NBW" Then
            TitleOf = "não esteja entre"
         ElseIf op = "SW" Then
            TitleOf = "inicie com"
         ElseIf op = "NSW" Then
            TitleOf = "não inicie com"
         ElseIf op = "CT" Then
            TitleOf = "contenha"
         ElseIf op = "NCT" Then
            TitleOf = "não Contenha"
         ElseIf op = "SQL" Then
            TitleOf = "SQL Query"
         Else
            TitleOf = pOp
         End If
      End Function

      Shared Function IsList(pOp As String) As Boolean
         Dim op As String = UCase(Trim(pOp))
         IsList = (op = "IN") Or (op = "NIN")
      End Function

      Shared Function IsRange(pOp As String) As Boolean
         Dim op As String = UCase(Trim(pOp))
         IsRange = (op = "BW") Or (op = "NBW")
      End Function

      Shared Function IsSql(pOp As String) As Boolean
         IsSql = (UCase(Trim(pOp)) = "SQL") And TFilterOps.AllowsSqlQuery()
      End Function

      Shared Function IsEmpty(pOp As String) As Boolean
         Dim op As String = UCase(Trim(pOp))
         IsEmpty = (op = "NL") Or (op = "NN")
      End Function

      Shared Function AllowsBlankValue(pOp As String) As Boolean
         AllowsBlankValue = (Not TFilterOps.IsEmpty(pOp)) And (Not TFilterOps.IsSql(pOp))
      End Function

      Shared Function IsLike(pOp As String) As Boolean
         Dim op As String = UCase(Trim(pOp))
         IsLike = (op = "SW") Or (op = "NSW") Or (op = "CT") Or (op = "NCT")
      End Function

      Shared Function Arity(pOp As String) As Integer
         If TFilterOps.IsList(pOp) Then
            Arity = -1
         ElseIf TFilterOps.IsRange(pOp) Then
            Arity = 2
         ElseIf TFilterOps.IsEmpty(pOp) Then
            Arity = 0
         Else
            Arity = 1
         End If
      End Function

   End Class

End Namespace
