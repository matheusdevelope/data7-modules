' data7:disable qualified-private-shared-access
Imports Collections
Imports mod_tlist
Imports configurador_campo
Imports configurador_tabela
Imports TablesField
Imports TablesSchema
Imports TablesSql
Imports TablesTable

Namespace mod_register_record

   Class TRegisterRecord
      Inherits TTable

      Private _bound As StringList
      Private _identityWhere As String

      Sub New(pCacheKey As String)
         MyBase.New(pCacheKey)
         me._bound = Null
         me._identityWhere = ""
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         Dim defTable As Tabela = Ambient.Tabela()
         If Not Assigned(defTable) Then
            Throw New Exception("Tabela do ambiente não carregada.")
         End If
         pSchema.TableName = Trim(defTable.Nome)
         pSchema.SchemaName = Trim(defTable.NomeSchema)
         Dim cols As TTList<TColumnInfo> = TRegisterRecord._describe(defTable.NomeSchema, defTable.Nome)
         Dim i As Integer
         Dim last As Integer = defTable.Campos.Length - 1
         For i = 0 To last
            Dim source As Campo = defTable.Campos.Take(i)
            If TRegisterRecord._keep(source) Then
               TRegisterRecord._define(pSchema, source, defTable.CodCampoAutoIncremento, TRegisterRecord._nativeOf(cols, source.Nome))
            End If
         Next
         If Assigned(cols) Then
            cols.Free()
         End If
      End Sub

      Overrides Function CreateInstance() As TTable
         CreateInstance = New TRegisterRecord(me.Schema.CacheKey)
      End Function

      Sub BeginBind()
         If Assigned(me._bound) Then
            me._bound.Clear()
         Else
            me._bound = New StringList()
            me._bound.OwnsObjects = False
         End If
      End Sub

      Sub Mark(pName As String)
         If Not Assigned(me._bound) Then
            me.BeginBind()
         End If
         Dim key As String = UCase(Trim(pName))
         If key = "" Then
            Exit Sub
         End If
         If me._bound.IndexOf(key) < 0 Then
            me._bound.Add(key)
         End If
      End Sub

      Overrides Function IncludeField(pOp As TTableOp, pDef As TFieldDef) As Boolean
         If Not MyBase.IncludeField(pOp, pDef) Then
            IncludeField = False
            Exit Function
         End If
         Dim opName As String = UCase(pOp.AsString)
         If (opName <> "INSERT") And (opName <> "UPDATE") Then
            IncludeField = True
            Exit Function
         End If
         If pDef.PrimaryKey Then
            IncludeField = True
            Exit Function
         End If
         If Not Assigned(me._bound) Then
            IncludeField = True
            Exit Function
         End If
         IncludeField = me._bound.IndexOf(UCase(pDef.Name)) >= 0
      End Function

      Function UpdateWhere(pWhere As String) As Integer
         UpdateWhere = me._execIdentity(TFieldCache.OpUpdate(), pWhere)
      End Function

      Function DeleteWhere(pWhere As String) As Integer
         DeleteWhere = me._execIdentity(TFieldCache.OpDelete(), pWhere)
      End Function

      Function BuildPkWhereSql() As String
         If Trim(me._identityWhere) <> "" Then
            BuildPkWhereSql = TSql.Dialect().NormalizeWhere(me._identityWhere)
         Else
            BuildPkWhereSql = MyBase.BuildPkWhereSql()
         End If
      End Function

      Overrides Sub ReadField(pField As TField, pSrc As SQL.TField)
         Try
            MyBase.ReadField(pField, pSrc)
         Catch ex As Exception
            TRegisterRecord.RaiseTypeError(pField.Name, ex, pField)
         End Try
      End Sub

      Overrides Sub BindField(pCmd As SQL.Command, pField As TField)
         Try
            MyBase.BindField(pCmd, pField)
         Catch ex As Exception
            TRegisterRecord.RaiseTypeError(pField.Name, ex, pField)
         End Try
      End Sub

      Overrides Sub Bind(pCmd As SQL.Command, pOp As TTableOp)
         If Trim(me._identityWhere) = "" Then
            MyBase.Bind(pCmd, pOp)
            Exit Sub
         End If
         If UCase(pOp.AsString) = "DELETE" Then
            Exit Sub
         End If
         Dim i As Integer
         For i = 0 To me.Fields.Count - 1
            Dim f As TField = me.GetField(i)
            If (Not f.Def.PrimaryKey) And me.IncludeField(pOp, f.Def) Then
               me.PrepareValue(pOp, f)
               If Not me.FieldUsesExpr(pOp, f.Def) Then
                  me.BindField(pCmd, f)
               End If
            End If
         Next
      End Sub

      Shared Function TypeErrorText(pName As String, pEx As Exception) As String
         TypeErrorText = TRegisterRecord.TypeErrorText(pName, pEx, Null)
      End Function

      Shared Function TypeErrorText(pName As String, pEx As Exception, pField As TField) As String
         Dim nome As String = Trim(pName)
         Dim titulo As String = ""
         Dim tipo As String = ""
         Dim campoItem As Campo = TRegisterRecord._campo(nome)
         If Assigned(campoItem) Then
            titulo = Trim(campoItem.TituloEdicao)
            If titulo = "" Then
               titulo = Trim(campoItem.Titulo)
            End If
            tipo = Trim(campoItem.Tipo)
         End If
         If (tipo = "") And Assigned(pField) Then
            If Assigned(pField.Def) Then
               tipo = Trim(pField.Def.Kind.AsString)
            End If
         End If
         If titulo = "" Then
            titulo = nome
         End If
         If tipo = "" Then
            tipo = "?"
         End If
         Dim detail As String = ""
         If Assigned(pEx) Then
            detail = Trim(pEx.Message)
         End If
         TypeErrorText = "Campo com tipo divergente entre o Configurador e o banco de dados." & Char(13) & Char(13) & "Nome: " & nome & Char(13) & "Título: " & titulo & Char(13) & "Tipo: " & tipo & Char(13) & "Exceção: " & detail
      End Function

      Shared Sub RaiseTypeError(pName As String, pEx As Exception, pField As TField)
         Dim msg As String = TRegisterRecord.TypeErrorText(pName, pEx, pField)
         If Assigned(pEx) Then
            If pEx.Message.Pos("Campo com tipo divergente") > 0 Then
               msg = Trim(pEx.Message)
            End If
         End If
         Throw New Exception(msg)
      End Sub

      Private Function _execIdentity(pOp As TTableOp, pWhere As String) As Integer
         Dim whereText As String = Trim(pWhere)
         If whereText = "" Then
            Throw New Exception("Não foi possível montar a chave do registro.")
         End If
         me._identityWhere = whereText
         Dim sqlText As String
         If UCase(pOp.AsString) = "UPDATE" Then
            sqlText = me.BuildUpdateSql()
         Else
            sqlText = me.BuildDeleteSql()
         End If
         Dim __query As New SQL.Command()
         __query.CommandText = sqlText
         Dim _result As Integer
         Try
            _result = me.ApplyDml(pOp, __query)
         Catch ex As Exception
            me._identityWhere = ""
            __query.Free()
            Throw New Exception(ex.Message)
         End Try
         me._identityWhere = ""
         __query.Free()
         _execIdentity = _result
      End Function

      Function AutoFieldName() As String
         Dim ac As TFieldDef = me.Schema.CachedAutoCode
         If Assigned(ac) Then
            AutoFieldName = ac.Name
         Else
            AutoFieldName = ""
         End If
      End Function

      Private Shared Function _binaryKind(pKind As String) As Boolean
         _binaryKind = (pKind = "B") Or (pKind = "IM") Or (pKind = "IMG") Or (pKind = "IMA") Or (pKind = "PIC") Or (pKind = "IMAGE") Or (pKind = "BLOB") Or (pKind = "FOTO")
      End Function

      Private Shared Function _keep(pSource As Campo) As Boolean
         If Not Assigned(pSource) Then
            _keep = False
            Exit Function
         End If
         If Trim(pSource.Nome) = "" Then
            _keep = False
            Exit Function
         End If
         If pSource.Extra Then
            _keep = False
            Exit Function
         End If
         If UCase(Trim(pSource.Contexto)) <> "R" Then
            _keep = False
            Exit Function
         End If
         _keep = True
      End Function

      Private Shared Function _describe(pSchemaName As String, pTable As String) As TTList<TColumnInfo>
         Try
            Return TSql.DescribeColumns(Trim(pSchemaName), Trim(pTable))
         Catch ex As Exception
            Return Null
         End Try
      End Function

      Private Shared Function _campo(pName As String) As Campo
         Dim defTable As Tabela = Ambient.Tabela()
         If (Not Assigned(defTable)) Or (Not Assigned(defTable.Campos)) Then
            _campo = Null
            Exit Function
         End If
         Dim alvo As String = UCase(Trim(pName))
         Dim i As Integer
         Dim last As Integer = defTable.Campos.Length - 1
         For i = 0 To last
            Dim item As Campo = defTable.Campos.Take(i)
            If Assigned(item) Then
               If UCase(Trim(item.Nome)) = alvo Then
                  _campo = item
                  Exit Function
               End If
            End If
         Next
         _campo = Null
      End Function

      Private Shared Function _nativeOf(pCols As TTList<TColumnInfo>, pName As String) As String
         _nativeOf = ""
         If Not Assigned(pCols) Then
            Exit Function
         End If
         Dim target As String = UCase(Trim(pName))
         Dim i As Integer
         Dim last As Integer = pCols.Length - 1
         For i = 0 To last
            Dim info As TColumnInfo = pCols.Take(i)
            If UCase(Trim(info.Name)) = target Then
               _nativeOf = UCase(Trim(info.NativeType))
               Exit Function
            End If
         Next
      End Function

      Private Shared Sub _define(pSchema As TTableSchema, pSource As Campo, pAutoCod As Integer, pNative As String)
         Dim def As TFieldDef = pSchema.Field(pSource.Nome)
         Dim kind As String = UCase(Trim(pSource.Tipo))
         If (kind = "I") Or (kind = "INT") Or (kind = "INTEGER") Then
            def.AsInteger()
         ElseIf (kind = "N") Or (kind = "NUM") Or (kind = "FLOAT") Or (kind = "DOUBLE") Then
            If pSource.CasasDecimal > 0 Then
               Dim prec As Integer = pSource.Tamanho
               If prec <= 0 Then
                  prec = 18
               End If
               def.AsNumeric(prec, pSource.CasasDecimal)
            Else
               def.AsInteger()
            End If
         ElseIf (kind = "D") Or (kind = "DAT") Or (kind = "DATE") Then
            def.AsDate()
         ElseIf (kind = "T") Or (kind = "H") Or (kind = "HOR") Or (kind = "TIME") Then
            def.AsTime()
         ElseIf (kind = "DT") Or (kind = "DH") Or (kind = "DATETIME") Then
            def.AsDateTime()
         ElseIf (kind = "L") Then
            def.AsInteger()
         ElseIf (kind = "LOG") Or (kind = "BOL") Or (kind = "BOOL") Then
            def.AsBoolean()
         ElseIf TRegisterRecord._binaryKind(kind) Then
            def.AsString()
         Else
            def.AsString()
            If pSource.Tamanho > 0 Then
               def.MaxLen(pSource.Tamanho)
            End If
         End If
         TSql.ApplyNative(def, pNative)
         If TRegisterRecord._binaryKind(kind) And (def.KindId = 0) Then
            TSql.ApplyBinaryColumn(def)
         End If
         If (pAutoCod > 0) And (pSource.CodCampo = pAutoCod) Then
            def.AutoCodeField()
         ElseIf pSource.Chave Then
            def.PrimaryKeyField()
         End If
      End Sub

      Sub Free()
         If Assigned(me._bound) Then
            me._bound.Free()
            me._bound = Null
         End If
         MyBase.Free()
      End Sub
   End Class

End Namespace
