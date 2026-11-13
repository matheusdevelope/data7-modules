Imports configurador_sql
Imports mod_register_config

Namespace mod_register_eval

   Class TRegisterEval

      Shared Function TextOf(pValue As String) As String
         TextOf = Trim(pValue & "")
      End Function

      Shared Function ResolveDefault(pField As TRegisterField) As String
         Dim formula As String = TRegisterEval.TextOf(pField.FormulaValorPadrao)
         If formula = "" Then
            ResolveDefault = TRegisterEval.TextOf(pField.DefaultValue)
            Exit Function
         End If
         Dim resolved As String = TCfgSql.AvaliarValorPadrao(pField.TipoValorPadrao, formula)
         If TRegisterEval.TextOf(resolved) = "" Then
            resolved = TRegisterEval.TextOf(pField.DefaultValue)
         End If
         ResolveDefault = resolved
      End Function

      Shared Function IsRequired(pField As TRegisterField) As Boolean
         If TRegisterEval.TextOf(pField.CondicaoObrigatorio) <> "" Then
            IsRequired = TCfgSql.AvaliarCondicao(pField.CondicaoObrigatorio, False)
         Else
            IsRequired = pField.Required
         End If
      End Function

      Shared Function IsReadOnly(pField As TRegisterField, pMode As String, pForce As Boolean) As Boolean
         If pForce Then
            IsReadOnly = True
            Exit Function
         End If
         If pField.Locked Then
            IsReadOnly = True
            Exit Function
         End If
         If pField.AutoIncrement Then
            IsReadOnly = True
            Exit Function
         End If
         Dim modeKey As String = UCase(Trim(pMode))
         If modeKey = "INCLUIR" Then
            IsReadOnly = (Not pField.CanEditInsert) Or (Not TCfgSql.AvaliarCondicao(pField.CondicaoEditarInclusao, True))
            Exit Function
         End If
         If modeKey = "ALTERAR" Then
            If pField.IsKey Then
               IsReadOnly = True
            Else
               IsReadOnly = (Not pField.CanEditUpdate) Or (Not TCfgSql.AvaliarCondicao(pField.CondicaoEditarAlteracao, True))
            End If
            Exit Function
         End If
         If modeKey = "COPIAR" Then
            IsReadOnly = (Not pField.CanEditInsert) Or (Not TCfgSql.AvaliarCondicao(pField.CondicaoEditarInclusao, True))
            Exit Function
         End If
         IsReadOnly = False
      End Function

      Shared Function ShouldFillDefault(pCurrentText As String, pFieldName As String) As Boolean
         Dim current As String = TRegisterEval.TextOf(pCurrentText)
         If current = "" Then
            ShouldFillDefault = True
            Exit Function
         End If
         If UCase(current) = UCase(TRegisterEval.TextOf(pFieldName)) Then
            ShouldFillDefault = True
            Exit Function
         End If
         If Left(current, 10) = "30/12/1899" Then
            ShouldFillDefault = True
            Exit Function
         End If
         ShouldFillDefault = False
      End Function

      Shared Function ApplyDefaultTo(pCurrentText As String, pField As TRegisterField) As String
         If Not TRegisterEval.ShouldFillDefault(pCurrentText, pField.Name) Then
            ApplyDefaultTo = pCurrentText
            Exit Function
         End If
         Dim resolved As String = TRegisterEval.ResolveDefault(pField)
         If TRegisterEval.TextOf(resolved) = "" Then
            ApplyDefaultTo = pCurrentText
         Else
            ApplyDefaultTo = resolved
         End If
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
