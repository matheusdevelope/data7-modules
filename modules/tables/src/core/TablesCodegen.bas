Imports Collections
Imports IO
Imports mod_tobject
Imports mod_tlist
Imports TablesField
Imports TablesSql

Namespace TablesCodegen

   Class TTableGenerator
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Shared Function Render(pTable As String, pSchema As String = "") As String
         Dim gen As New TTableGenerator()
         Dim body As String = gen.Build(pTable, pSchema)
         gen.Free()
         Render = body
      End Function

      Shared Function Save(pFolder As String, pTable As String, pSchema As String = "", pFileName As String = "") As String
         Dim gen As New TTableGenerator()
         Dim fullName As String = gen.WriteFile(pFolder, pTable, pSchema, pFileName)
         gen.Free()
         Save = fullName
      End Function

      Shared Function SaveMany(pFolder As String, pTables As StringList, pSchema As String = "") As StringList
         Dim gen As New TTableGenerator()
         Dim saved As StringList = gen.WriteMany(pFolder, pTables, pSchema)
         gen.Free()
         SaveMany = saved
      End Function

      Function NamespaceName(pSchemaName As String, pTable As String) As String
         Dim ns As String = me.ToSnake(pTable)
         While ns.StartsWith("_")
            ns = ns.Right(ns.Length - 1)
         Wend
         If Not TSql.Dialect().IsDefaultSchema(pSchemaName) Then
            ns = me.ToSnake(pSchemaName) & "_" & ns
         End If
         NamespaceName = "table_" & ns
      End Function

      Function ClassNameOf(pSchemaName As String, pTable As String) As String
         Dim n As String = "T"
         If Not TSql.Dialect().IsDefaultSchema(pSchemaName) Then
            n = n & me.ToPascal(pSchemaName)
         End If
         n = n & me.ToPascal(pTable)
         ClassNameOf = n
      End Function

      Function FileNameOf(pSchemaName As String, pTable As String) As String
         FileNameOf = me.NamespaceName(pSchemaName, pTable) & ".bas"
      End Function

      Function Build(pTable As String, pSchema As String = "") As String
         Dim lines As StringList = me.BuildLines(pTable, pSchema)
         Dim body As String = lines.Text
         lines.Free()
         Build = body
      End Function

      Function BuildLines(pTable As String, pSchema As String = "") As StringList
         Dim schemaName As String = ""
         Dim tableName As String = ""
         me.ParseName(pTable, pSchema, schemaName, tableName)
         Dim sqlDialect As TSqlDialect = TSql.Dialect()
         Dim cols[] As TColumnInfo = TSql.DescribeColumns(schemaName, tableName)
         Dim ns As String = me.NamespaceName(schemaName, tableName)
         Dim className As String = me.ClassNameOf(schemaName, tableName)
         Dim nPk As Integer = me.PkCountOf(cols)
         Dim hasEmpresaPk As Boolean = me.HasCodEmpresaPk(cols)
         Dim i As Integer
         Dim lines As New StringList()
         lines.Add("Imports TablesSchema")
         lines.Add("Imports TablesTable")
         lines.Add("")
         lines.Add("Namespace " & ns)
         lines.Add("")
         lines.Add("   Class " & className)
         lines.Add("      Inherits TTable")
         lines.Add("")
         lines.Add("      Sub New()")
         lines.Add("         MyBase.New(""" & className & """)")
         lines.Add("      End Sub")
         lines.Add("")
         lines.Add("      Overrides Sub DefineSchema(pSchema As TTableSchema)")
         If Not sqlDialect.IsDefaultSchema(schemaName) Then
            lines.Add("         pSchema.SchemaName = """ & schemaName & """")
         End If
         lines.Add("         pSchema.TableName = """ & tableName & """")
         Dim seenFields As New StringList()
         For i = 0 To cols.Length - 1
            Dim col As TColumnInfo = cols.Take(i)
            If me.KeepName(seenFields, col.Name) Then
               Dim kind As TKindField = sqlDialect.MapFieldKind(col.NativeType)
               Dim autoCode As Boolean = me.DecideAutoCode(col, kind, nPk, hasEmpresaPk)
               lines.Add(me.FieldLine(col, kind, autoCode))
            End If
         Next
         seenFields.Free()
         lines.Add("      End Sub")
         lines.Add("")
         lines.Add("      Overrides Function CreateInstance() As TTable")
         lines.Add("         CreateInstance = New " & className & "()")
         lines.Add("      End Function")
         lines.Add("")
         lines.Add("      Overrides Function GetID() As String")
         lines.Add("         " & me.GetIdBody(cols, className))
         lines.Add("      End Function")
         Dim seenProps As New StringList()
         For i = 0 To cols.Length - 1
            Dim col2 As TColumnInfo = cols.Take(i)
            Dim propName As String = me.PropertyNameOf(col2.Name, className)
            If me.KeepName(seenProps, propName) Then
               Dim kind2 As TKindField = sqlDialect.MapFieldKind(col2.NativeType)
               me.AddProperty(lines, col2.Name, propName, kind2)
            End If
         Next
         seenProps.Free()
         lines.Add("")
         lines.Add("      Sub Free()")
         lines.Add("         MyBase.Free()")
         lines.Add("      End Sub")
         lines.Add("   End Class")
         lines.Add("")
         lines.Add("End Namespace")
         cols.OwnsObjects = True
         cols.Free()
         BuildLines = lines
      End Function

      Function WriteFile(pFolder As String, pTable As String, pSchema As String = "", pFileName As String = "") As String
         Dim schemaName As String = ""
         Dim tableName As String = ""
         me.ParseName(pTable, pSchema, schemaName, tableName)
         Dim lines As StringList = me.BuildLines(pTable, pSchema)
         Dim fileName As String = Trim(pFileName)
         If fileName = "" Then
            fileName = me.FileNameOf(schemaName, tableName)
         Else
            fileName = me.WithBas(fileName)
         End If
         If Not Directory.Exists(pFolder) Then
            Directory.Create(pFolder)
         End If
         Dim fullName As String = me.JoinFolder(pFolder, fileName)
         lines.SaveToFile(fullName)
         lines.Free()
         WriteFile = fullName
      End Function

      Function WriteMany(pFolder As String, pTables As StringList, pSchema As String = "") As StringList
         Dim saved As New StringList()
         Dim i As Integer
         For i = 0 To pTables.Count - 1
            Dim spec As String = Trim(pTables.Strings(i))
            If spec <> "" Then
               saved.Add(me.WriteFile(pFolder, spec, pSchema, ""))
            End If
         Next
         WriteMany = saved
      End Function

      Sub ParseName(pSpec As String, pDefaultSchema As String, ByRef pSchemaName As String, ByRef pTable As String)
         Dim spec As String = Trim(pSpec)
         Dim dotAt As Integer = -1
         Dim i As Integer
         For i = 0 To spec.Length - 1
            If spec.Right(spec.Length - i).StartsWith(".") Then
               dotAt = i
               Exit For
            End If
         Next
         If dotAt >= 0 Then
            pSchemaName = Trim(spec.Left(dotAt))
            pTable = Trim(spec.Right(spec.Length - dotAt - 1))
         Else
            pSchemaName = Trim(pDefaultSchema)
            pTable = spec
         End If
      End Sub

      Function IsCodEmpresaName(pName As String) As Boolean
         IsCodEmpresaName = (UCase(Trim(pName)) = "CODEMPRESA")
      End Function

      Function HasCodEmpresaPk(pCols[] As TColumnInfo) As Boolean
         Dim i As Integer
         For i = 0 To pCols.Length - 1
            Dim col As TColumnInfo = pCols.Take(i)
            If col.PrimaryKey Then
               If me.IsCodEmpresaName(col.Name) Then
                  HasCodEmpresaPk = True
                  Exit Function
               End If
            End If
         Next
         HasCodEmpresaPk = False
      End Function

      Function PkCountOf(pCols[] As TColumnInfo) As Integer
         Dim n As Integer = 0
         Dim seen As New StringList()
         Dim i As Integer
         For i = 0 To pCols.Length - 1
            Dim col As TColumnInfo = pCols.Take(i)
            If col.PrimaryKey Then
               If me.KeepName(seen, col.Name) Then
                  n = n + 1
               End If
            End If
         Next
         seen.Free()
         PkCountOf = n
      End Function

      Function KeepName(pSeen As StringList, pName As String) As Boolean
         Dim k As String = UCase(Trim(pName))
         If pSeen.IndexOf(k) >= 0 Then
            KeepName = False
         Else
            pSeen.Add(k)
            KeepName = True
         End If
      End Function

      Function IsAutoCode(pCol As TColumnInfo, pKind As TKindField, pCols[] As TColumnInfo) As Boolean
         IsAutoCode = me.DecideAutoCode(pCol, pKind, me.PkCountOf(pCols), me.HasCodEmpresaPk(pCols))
      End Function

      Function DecideAutoCode(pCol As TColumnInfo, pKind As TKindField, pPkCount As Integer, pHasEmpresaPk As Boolean) As Boolean
         If me.IsCodEmpresaName(pCol.Name) Then
            DecideAutoCode = False
            Exit Function
         End If
         If Not (pKind = TFieldCache.KindInteger()) Then
            DecideAutoCode = False
            Exit Function
         End If
         If pCol.Identity Then
            DecideAutoCode = True
            Exit Function
         End If
         If Not pCol.PrimaryKey Then
            DecideAutoCode = False
            Exit Function
         End If
         If pPkCount = 1 Then
            DecideAutoCode = True
         ElseIf (pPkCount = 2) And pHasEmpresaPk Then
            DecideAutoCode = True
         Else
            DecideAutoCode = False
         End If
      End Function

      Function FieldLine(pCol As TColumnInfo, pKind As TKindField, pAutoCode As Boolean) As String
         Dim line As String = "         pSchema.Field(""" & pCol.Name & """)"
         Select pKind
            Case TFieldCache.KindInteger()
               line = line & ".AsInteger()"
            Case TFieldCache.KindFloat()
               line = line & ".AsFloat()"
               If pCol.Precision > 0 Then
                  line = line & ".NumericPrec(" & CStr(pCol.Precision) & ", " & CStr(pCol.Scale) & ")"
               End If
            Case TFieldCache.KindBoolean()
               line = line & ".AsBoolean()"
            Case TFieldCache.KindDate()
               line = line & ".AsDate()"
            Case TFieldCache.KindDateTime()
               line = line & ".AsDateTime()"
            Case Else
               line = line & ".AsString()"
               Dim n As Integer = pCol.MaxLength
               If n <= 0 Then
                  n = 255
               End If
               line = line & ".MaxLen(" & CStr(n) & ")"
         End Select
         If pAutoCode Then
            line = line & ".AutoCodeField()"
         ElseIf pCol.PrimaryKey Then
            line = line & ".PrimaryKeyField()"
         End If
         If Not pCol.PrimaryKey Then
            If Not pCol.Nullable Then
               line = line & ".RequiredField()"
            End If
         End If
         FieldLine = line
      End Function

      Function GetIdBody(pCols[] As TColumnInfo, pClassName As String) As String
         Dim body As String = "GetID = "
         Dim first As Boolean = True
         Dim seenPk As New StringList()
         Dim i As Integer
         For i = 0 To pCols.Length - 1
            Dim col As TColumnInfo = pCols.Take(i)
            If col.PrimaryKey Then
               If me.KeepName(seenPk, col.Name) Then
                  Dim kind As TKindField = TSql.Dialect().MapFieldKind(col.NativeType)
                  Dim propName As String = me.PropertyNameOf(col.Name, pClassName)
                  Dim expr As String
                  If kind = TFieldCache.KindInteger() Then
                     expr = "CStr(me." & propName & ")"
                  Else
                     expr = "me." & propName
                  End If
                  If Not first Then
                     body = body & " & ""|"" & "
                  End If
                  first = False
                  body = body & expr
               End If
            End If
         Next
         seenPk.Free()
         If first Then
            GetIdBody = "GetID = """""
         Else
            GetIdBody = body
         End If
      End Function

      Sub AddProperty(pLines As StringList, pColName As String, pPropName As String, pKind As TKindField)
         pLines.Add("")
         Select pKind
            Case TFieldCache.KindInteger()
               pLines.Add("      Property " & pPropName & " As Integer")
               pLines.Add("         Get")
               pLines.Add("            " & pPropName & " = me.GetInteger(""" & pColName & """)")
               pLines.Add("         End Get")
               pLines.Add("         Set(pValue As Integer)")
               pLines.Add("            me.SetInteger(""" & pColName & """, pValue)")
               pLines.Add("         End Set")
               pLines.Add("      End Property")
            Case TFieldCache.KindFloat()
               pLines.Add("      Property " & pPropName & " As Extended")
               pLines.Add("         Get")
               pLines.Add("            " & pPropName & " = me.GetFloat(""" & pColName & """)")
               pLines.Add("         End Get")
               pLines.Add("         Set(pValue As Extended)")
               pLines.Add("            me.SetFloat(""" & pColName & """, pValue)")
               pLines.Add("         End Set")
               pLines.Add("      End Property")
            Case TFieldCache.KindBoolean()
               pLines.Add("      Property " & pPropName & " As Boolean")
               pLines.Add("         Get")
               pLines.Add("            " & pPropName & " = me.GetBoolean(""" & pColName & """)")
               pLines.Add("         End Get")
               pLines.Add("         Set(pValue As Boolean)")
               pLines.Add("            me.SetBoolean(""" & pColName & """, pValue)")
               pLines.Add("         End Set")
               pLines.Add("      End Property")
            Case TFieldCache.KindDate() , TFieldCache.KindDateTime()
               pLines.Add("      Property " & pPropName & " As TDateTime")
               pLines.Add("         Get")
               pLines.Add("            " & pPropName & " = me.GetDateTime(""" & pColName & """)")
               pLines.Add("         End Get")
               pLines.Add("         Set(pValue As TDateTime)")
               pLines.Add("            me.SetDateTime(""" & pColName & """, pValue)")
               pLines.Add("         End Set")
               pLines.Add("      End Property")
            Case Else
               pLines.Add("      Property " & pPropName & " As String")
               pLines.Add("         Get")
               pLines.Add("            " & pPropName & " = me.GetString(""" & pColName & """)")
               pLines.Add("         End Get")
               pLines.Add("         Set(pValue As String)")
               pLines.Add("            me.SetString(""" & pColName & """, pValue)")
               pLines.Add("         End Set")
               pLines.Add("      End Property")
         End Select
      End Sub

      Function PropertyNameOf(pColName As String, pClassName As String) As String
         Dim n As String = me.IdentOf(pColName)
         If me.IsReservedIdent(n) Then
            n = "C" & n
         End If
         If UCase(n) = UCase(pClassName) Then
            n = n & "Col"
         End If
         PropertyNameOf = n
      End Function

      Function IdentOf(pRaw As String) As String
         Dim raw As String = Trim(pRaw)
         Dim result As String = ""
         Dim i As Integer
         For i = 0 To raw.Length - 1
            Dim ch As String = raw.Right(raw.Length - i).Left(1)
            If me.IsIdentChar(ch) Or (ch = "_") Then
               result = result & ch
            End If
         Next
         If result.Length = 0 Then
            IdentOf = "Col"
            Exit Function
         End If
         Dim first As String = result.Left(1)
         If (first >= "0") And (first <= "9") Then
            result = "C" & result
         End If
         IdentOf = result
      End Function

      Function IsReservedIdent(pName As String) As Boolean
         Dim u As String = UCase(Trim(pName))
         If u = "SCHEMA" Or u = "FIELDS" Or u = "INSERT" Or u = "UPDATE" Or u = "DELETE" Or u = "MERGE" Or u = "UPSERT" Then
            IsReservedIdent = True
         ElseIf u = "LOAD" Or u = "FETCH" Or u = "EXISTS" Or u = "CLONE" Or u = "FREE" Or u = "FIELD" Or u = "VALIDATE" Then
            IsReservedIdent = True
         ElseIf u = "SQL" Or u = "CMD" Or u = "COMMAND" Or u = "CONNECTION" Or u = "PARAM" Or u = "DEF" Or u = "LIST" Or u = "PATH" Then
            IsReservedIdent = True
         ElseIf u = "NEW" Or u = "CLASS" Or u = "END" Or u = "SUB" Or u = "FUNCTION" Or u = "PROPERTY" Or u = "ME" Then
            IsReservedIdent = True
         ElseIf u = "GETFIELD" Or u = "HASFIELD" Or u = "ADDFIELD" Or u = "SETFIELD" Then
            IsReservedIdent = True
         ElseIf u = "GETINTEGER" Or u = "SETINTEGER" Or u = "GETSTRING" Or u = "SETSTRING" Then
            IsReservedIdent = True
         ElseIf u = "GETFLOAT" Or u = "SETFLOAT" Or u = "GETBOOLEAN" Or u = "SETBOOLEAN" Then
            IsReservedIdent = True
         ElseIf u = "GETDATETIME" Or u = "SETDATETIME" Then
            IsReservedIdent = True
         Else
            IsReservedIdent = False
         End If
      End Function

      Function IsIdentChar(pCh As String) As Boolean
         Dim u As String = UCase(pCh)
         If (u >= "A") And (u <= "Z") Then
            IsIdentChar = True
         ElseIf (pCh >= "0") And (pCh <= "9") Then
            IsIdentChar = True
         Else
            IsIdentChar = False
         End If
      End Function

      Function ToPascal(pRaw As String) As String
         Dim raw As String = Trim(pRaw)
         If raw.Length = 0 Then
            ToPascal = ""
            Exit Function
         End If
         If (raw.IndexOf("_") < 0) And (raw.IndexOf(" ") < 0) And (raw.IndexOf("-") < 0) Then
            If raw.Length = 1 Then
               ToPascal = UCase(raw)
            Else
               ToPascal = UCase(raw.Left(1)) & raw.Right(raw.Length - 1)
            End If
            Exit Function
         End If
         Dim result As String = ""
         Dim buf As String = ""
         Dim hadSplit As Boolean = False
         Dim i As Integer
         For i = 0 To raw.Length - 1
            Dim ch As String = raw.Right(raw.Length - i).Left(1)
            If me.IsIdentChar(ch) Then
               buf = buf & ch
            Else
               If buf.Length > 0 Then
                  hadSplit = True
                  result = result & me.PascalPart(buf)
                  buf = ""
               End If
            End If
         Next
         If buf.Length > 0 Then
            If hadSplit Then
               result = result & me.PascalPart(buf)
            ElseIf buf.Length = 1 Then
               result = UCase(buf)
            Else
               result = UCase(buf.Left(1)) & buf.Right(buf.Length - 1)
            End If
         End If
         ToPascal = result
      End Function

      Function PascalPart(pPart As String) As String
         If pPart.Length = 0 Then
            PascalPart = ""
         ElseIf pPart.Length = 1 Then
            PascalPart = UCase(pPart)
         Else
            PascalPart = UCase(pPart.Left(1)) & LCase(pPart.Right(pPart.Length - 1))
         End If
      End Function

      Function ToSnake(pRaw As String) As String
         Dim raw As String = Trim(pRaw)
         If raw.Length = 0 Then
            ToSnake = ""
            Exit Function
         End If
         If (raw.IndexOf("_") < 0) And (raw.IndexOf(" ") < 0) And (raw.IndexOf("-") < 0) Then
            ToSnake = LCase(raw)
            Exit Function
         End If
         Dim result As String = ""
         Dim buf As String = ""
         Dim i As Integer
         For i = 0 To raw.Length - 1
            Dim ch As String = raw.Right(raw.Length - i).Left(1)
            If me.IsIdentChar(ch) Then
               buf = buf & ch
            Else
               If buf.Length > 0 Then
                  If result <> "" Then
                     result = result & "_"
                  End If
                  result = result & LCase(buf)
                  buf = ""
               End If
            End If
         Next
         If buf.Length > 0 Then
            If result <> "" Then
               result = result & "_"
            End If
            result = result & LCase(buf)
         End If
         ToSnake = result
      End Function

      Function WithBas(pName As String) As String
         Dim n As String = Trim(pName)
         If n.Length >= 4 Then
            If LCase(n.Right(4)) = ".bas" Then
               WithBas = n
               Exit Function
            End If
         End If
         WithBas = n & ".bas"
      End Function

      Function JoinFolder(pFolder As String, pFile As String) As String
         Dim folder As String = Trim(pFolder)
         If folder.Length = 0 Then
            JoinFolder = pFile
            Exit Function
         End If
         Dim last As String = folder.Right(1)
         If (last = "\") Or (last = "/") Then
            JoinFolder = folder & pFile
         Else
            JoinFolder = folder & "\" & pFile
         End If
      End Function

      Overrides Function Clone() As TTObject
         Clone = New TTableGenerator()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
