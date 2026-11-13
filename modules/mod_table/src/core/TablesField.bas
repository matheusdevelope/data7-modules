' data7:disable type-mismatch
' data7:external-type TFieldType scope=file
Imports Collections
Imports mod_tobject
Imports mod_tenum

Namespace TablesField

   Private Declare Function CharUpperBuffW Lib "user32" (ByVal lpsz As String, ByVal cchLength As Long) As Long

   Enun TKindField
      StringKind = "String"
      IntegerKind = "Integer"
      FloatKind = "Float"
      BooleanKind = "Boolean"
      DateKind = "Date"
      DateTimeKind = "DateTime"
      TimeKind = "Time"
      Base64Kind = "Base64"
   End Enun

   Enun TTableOp
      OpSelect = "Select"
      OpInsert = "Insert"
      OpUpdate = "Update"
      OpDelete = "Delete"
      OpUpsert = "Upsert"
      OpMerge = "Merge"
      OpCustom = "Custom"
   End Enun

   Enun TResourceKind
      Trigger
      Procedure
      Func = "Function"
      View
      Index
   End Enun

   Enun TDdlOpKind
      CreateTable
      DropTable
      AddColumn
      DropColumn
      RenameColumn
      AlterColumn
      EnsureSequence
      DropSequence
      CustomSql
      CreateOrAlterRoutine
      DropRoutine
   End Enun

   Enun TCommitMode
      SingleTransaction
      PerBatch
      PerStatement
      JoinExisting
   End Enun

   Enun TAlterColumnMode
      InPlace
      Rebuild
      Automatic
   End Enun

   Private Dim _enumReady As Boolean
   Private Dim _kindString As TKindField
   Private Dim _kindInteger As TKindField
   Private Dim _kindFloat As TKindField
   Private Dim _kindBoolean As TKindField
   Private Dim _kindDate As TKindField
   Private Dim _kindDateTime As TKindField
   Private Dim _kindTime As TKindField
   Private Dim _kindBase64 As TKindField
   Private Dim _opSelect As TTableOp
   Private Dim _opInsert As TTableOp
   Private Dim _opUpdate As TTableOp
   Private Dim _opDelete As TTableOp
   Private Dim _opUpsert As TTableOp
   Private Dim _opMerge As TTableOp
   Private Dim _opCustom As TTableOp
   Private Dim _alterInPlace As TAlterColumnMode
   Private Dim _alterRebuild As TAlterColumnMode
   Private Dim _alterAutomatic As TAlterColumnMode
   Private Dim _commitSingle As TCommitMode
   Private Dim _commitPerBatch As TCommitMode
   Private Dim _commitPerStatement As TCommitMode
   Private Dim _commitJoinExisting As TCommitMode
   Private Dim _resTrigger As TResourceKind
   Private Dim _resProcedure As TResourceKind
   Private Dim _resFunc As TResourceKind
   Private Dim _resView As TResourceKind
   Private Dim _resIndex As TResourceKind
   Private Dim _ddlCreateTable As TDdlOpKind
   Private Dim _ddlDropTable As TDdlOpKind
   Private Dim _ddlAddColumn As TDdlOpKind
   Private Dim _ddlDropColumn As TDdlOpKind
   Private Dim _ddlRenameColumn As TDdlOpKind
   Private Dim _ddlAlterColumn As TDdlOpKind
   Private Dim _ddlEnsureSequence As TDdlOpKind
   Private Dim _ddlDropSequence As TDdlOpKind
   Private Dim _ddlCustomSql As TDdlOpKind
   Private Dim _ddlCreateOrAlterRoutine As TDdlOpKind
   Private Dim _ddlDropRoutine As TDdlOpKind

   Class TFieldCache

      Sub New()
         MyBase.New()
      End Sub

      Shared Sub Ensure()
         If Not _enumReady Then
            _kindString = TKindField.StringKind()
            _kindInteger = TKindField.IntegerKind()
            _kindFloat = TKindField.FloatKind()
            _kindBoolean = TKindField.BooleanKind()
            _kindDate = TKindField.DateKind()
            _kindDateTime = TKindField.DateTimeKind()
            _kindTime = TKindField.TimeKind()
            _kindBase64 = TKindField.Base64Kind()
            _opSelect = TTableOp.OpSelect()
            _opInsert = TTableOp.OpInsert()
            _opUpdate = TTableOp.OpUpdate()
            _opDelete = TTableOp.OpDelete()
            _opUpsert = TTableOp.OpUpsert()
            _opMerge = TTableOp.OpMerge()
            _opCustom = TTableOp.OpCustom()
            _alterInPlace = TAlterColumnMode.InPlace()
            _alterRebuild = TAlterColumnMode.Rebuild()
            _alterAutomatic = TAlterColumnMode.Automatic()
            _commitSingle = TCommitMode.SingleTransaction()
            _commitPerBatch = TCommitMode.PerBatch()
            _commitPerStatement = TCommitMode.PerStatement()
            _commitJoinExisting = TCommitMode.JoinExisting()
            _resTrigger = TResourceKind.Trigger()
            _resProcedure = TResourceKind.Procedure()
            _resFunc = TResourceKind.Func()
            _resView = TResourceKind.View()
            _resIndex = TResourceKind.Index()
            _ddlCreateTable = TDdlOpKind.CreateTable()
            _ddlDropTable = TDdlOpKind.DropTable()
            _ddlAddColumn = TDdlOpKind.AddColumn()
            _ddlDropColumn = TDdlOpKind.DropColumn()
            _ddlRenameColumn = TDdlOpKind.RenameColumn()
            _ddlAlterColumn = TDdlOpKind.AlterColumn()
            _ddlEnsureSequence = TDdlOpKind.EnsureSequence()
            _ddlDropSequence = TDdlOpKind.DropSequence()
            _ddlCustomSql = TDdlOpKind.CustomSql()
            _ddlCreateOrAlterRoutine = TDdlOpKind.CreateOrAlterRoutine()
            _ddlDropRoutine = TDdlOpKind.DropRoutine()
            _enumReady = True
         End If
      End Sub

      Shared Function KindString() As TKindField
         TFieldCache.Ensure()
         KindString = _kindString
      End Function

      Shared Function KindInteger() As TKindField
         TFieldCache.Ensure()
         KindInteger = _kindInteger
      End Function

      Shared Function KindFloat() As TKindField
         TFieldCache.Ensure()
         KindFloat = _kindFloat
      End Function

      Shared Function KindBoolean() As TKindField
         TFieldCache.Ensure()
         KindBoolean = _kindBoolean
      End Function

      Shared Function KindDate() As TKindField
         TFieldCache.Ensure()
         KindDate = _kindDate
      End Function

      Shared Function KindDateTime() As TKindField
         TFieldCache.Ensure()
         KindDateTime = _kindDateTime
      End Function

      Shared Function KindTime() As TKindField
         TFieldCache.Ensure()
         KindTime = _kindTime
      End Function

      Shared Function KindBase64() As TKindField
         TFieldCache.Ensure()
         KindBase64 = _kindBase64
      End Function

      Shared Function OpSelect() As TTableOp
         TFieldCache.Ensure()
         OpSelect = _opSelect
      End Function

      Shared Function OpInsert() As TTableOp
         TFieldCache.Ensure()
         OpInsert = _opInsert
      End Function

      Shared Function OpUpdate() As TTableOp
         TFieldCache.Ensure()
         OpUpdate = _opUpdate
      End Function

      Shared Function OpDelete() As TTableOp
         TFieldCache.Ensure()
         OpDelete = _opDelete
      End Function

      Shared Function OpUpsert() As TTableOp
         TFieldCache.Ensure()
         OpUpsert = _opUpsert
      End Function

      Shared Function OpMerge() As TTableOp
         TFieldCache.Ensure()
         OpMerge = _opMerge
      End Function

      Shared Function OpCustom() As TTableOp
         TFieldCache.Ensure()
         OpCustom = _opCustom
      End Function

      Shared Function AlterInPlace() As TAlterColumnMode
         TFieldCache.Ensure()
         AlterInPlace = _alterInPlace
      End Function

      Shared Function AlterRebuild() As TAlterColumnMode
         TFieldCache.Ensure()
         AlterRebuild = _alterRebuild
      End Function

      Shared Function AlterAutomatic() As TAlterColumnMode
         TFieldCache.Ensure()
         AlterAutomatic = _alterAutomatic
      End Function

      Shared Function CommitSingle() As TCommitMode
         TFieldCache.Ensure()
         CommitSingle = _commitSingle
      End Function

      Shared Function CommitPerBatch() As TCommitMode
         TFieldCache.Ensure()
         CommitPerBatch = _commitPerBatch
      End Function

      Shared Function CommitPerStatement() As TCommitMode
         TFieldCache.Ensure()
         CommitPerStatement = _commitPerStatement
      End Function

      Shared Function CommitJoinExisting() As TCommitMode
         TFieldCache.Ensure()
         CommitJoinExisting = _commitJoinExisting
      End Function

      Shared Function ResourceTrigger() As TResourceKind
         TFieldCache.Ensure()
         ResourceTrigger = _resTrigger
      End Function

      Shared Function ResourceProcedure() As TResourceKind
         TFieldCache.Ensure()
         ResourceProcedure = _resProcedure
      End Function

      Shared Function ResourceFunc() As TResourceKind
         TFieldCache.Ensure()
         ResourceFunc = _resFunc
      End Function

      Shared Function ResourceView() As TResourceKind
         TFieldCache.Ensure()
         ResourceView = _resView
      End Function

      Shared Function ResourceIndex() As TResourceKind
         TFieldCache.Ensure()
         ResourceIndex = _resIndex
      End Function

      Shared Function DdlCreateTable() As TDdlOpKind
         TFieldCache.Ensure()
         DdlCreateTable = _ddlCreateTable
      End Function

      Shared Function DdlDropTable() As TDdlOpKind
         TFieldCache.Ensure()
         DdlDropTable = _ddlDropTable
      End Function

      Shared Function DdlAddColumn() As TDdlOpKind
         TFieldCache.Ensure()
         DdlAddColumn = _ddlAddColumn
      End Function

      Shared Function DdlDropColumn() As TDdlOpKind
         TFieldCache.Ensure()
         DdlDropColumn = _ddlDropColumn
      End Function

      Shared Function DdlRenameColumn() As TDdlOpKind
         TFieldCache.Ensure()
         DdlRenameColumn = _ddlRenameColumn
      End Function

      Shared Function DdlAlterColumn() As TDdlOpKind
         TFieldCache.Ensure()
         DdlAlterColumn = _ddlAlterColumn
      End Function

      Shared Function DdlEnsureSequence() As TDdlOpKind
         TFieldCache.Ensure()
         DdlEnsureSequence = _ddlEnsureSequence
      End Function

      Shared Function DdlDropSequence() As TDdlOpKind
         TFieldCache.Ensure()
         DdlDropSequence = _ddlDropSequence
      End Function

      Shared Function DdlCustomSql() As TDdlOpKind
         TFieldCache.Ensure()
         DdlCustomSql = _ddlCustomSql
      End Function

      Shared Function DdlCreateOrAlterRoutine() As TDdlOpKind
         TFieldCache.Ensure()
         DdlCreateOrAlterRoutine = _ddlCreateOrAlterRoutine
      End Function

      Shared Function DdlDropRoutine() As TDdlOpKind
         TFieldCache.Ensure()
         DdlDropRoutine = _ddlDropRoutine
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TFieldDef
      Inherits TTObject

      Name As String
      DbName As String
      ParamName As String
      Kind As TKindField
      KindId As Integer
      DbType As String
      MaxLength As Integer
      Precision As Integer
      Scale As Integer
      DefaultValue As Variant
      PrimaryKey As Boolean
      AutoCode As Boolean
      SequenceName As String
      Persist As Boolean
      Insertable As Boolean
      Updatable As Boolean
      SelectOnly As Boolean
      SelectExpr As String
      InsertExpr As String
      UpdateExpr As String
      NullIfEmpty As Boolean
      Required As Boolean
      IncludeInSelect As Boolean
      BoolTrue As String
      BoolFalse As String

      Sub New(pName As String)
         MyBase.New()
         TFieldCache.Ensure()
         me.Name = pName
         me.DbName = pName
         me.ParamName = pName
         me.Kind = _kindString
         me.KindId = 0
         me.DbType = ""
         me.MaxLength = 255
         me.Precision = 0
         me.Scale = 0
         me.DefaultValue = Unassigned
         me.PrimaryKey = False
         me.AutoCode = False
         me.SequenceName = ""
         me.Persist = True
         me.Insertable = True
         me.Updatable = True
         me.SelectOnly = False
         me.SelectExpr = ""
         me.InsertExpr = ""
         me.UpdateExpr = ""
         me.NullIfEmpty = True
         me.Required = False
         me.IncludeInSelect = True
         me.BoolTrue = ""
         me.BoolFalse = ""
      End Sub

      Overrides Function GetID() As String
         GetID = me.Name
      End Function

      Function AsString() As TFieldDef
         me.Kind = _kindString
         me.KindId = 0
         AsString = me
      End Function

      Function AsInteger() As TFieldDef
         me.Kind = _kindInteger
         me.KindId = 1
         AsInteger = me
      End Function

      Function AsFloat() As TFieldDef
         me.Kind = _kindFloat
         me.KindId = 2
         AsFloat = me
      End Function

      Function AsNumeric(pPrecision As Integer, pScale As Integer = 0) As TFieldDef
         me.Kind = _kindFloat
         me.KindId = 2
         me.Precision = pPrecision
         me.Scale = pScale
         AsNumeric = me
      End Function

      Function AsBoolean() As TFieldDef
         Dim wasBool As Boolean = (me.KindId = 3)
         me.Kind = _kindBoolean
         me.KindId = 3
         If Trim(me.BoolTrue) = "" Then
            me.BoolTrue = "S"
         End If
         If Trim(me.BoolFalse) = "" Then
            me.BoolFalse = "N"
         End If
         If Not wasBool Then
            If me.MaxLength = 255 Then
               me.MaxLength = 0
            End If
         End If
         me.EnsureBoolLen()
         AsBoolean = me
      End Function

      Function TrueValue(pValue As String) As TFieldDef
         me.BoolTrue = pValue
         me.EnsureBoolLen()
         TrueValue = me
      End Function

      Function FalseValue(pValue As String) As TFieldDef
         me.BoolFalse = pValue
         me.EnsureBoolLen()
         FalseValue = me
      End Function

      Sub EnsureBoolLen()
         Dim n As Integer = Trim(me.BoolTrue).Length
         Dim nFalse As Integer = Trim(me.BoolFalse).Length
         If nFalse > n Then
            n = nFalse
         End If
         If n < 1 Then
            n = 1
         End If
         If me.MaxLength < n Then
            me.MaxLength = n
         End If
      End Sub

      Function FoldBoolToken(pText As String) As String
         pText = Trim(pText)
         CharUpperBuffW(pText, Len(pText))
         FoldBoolToken = pText
      End Function

      Function IsTrueToken(pFolded As String) As Boolean
         IsTrueToken = (pFolded = "S") Or (pFolded = "SIM") Or (pFolded = "TRUE") Or (pFolded = "T") Or (pFolded = "1") Or (pFolded = "-1") Or (pFolded = "Y") Or (pFolded = "YES") Or (pFolded = "V") Or (pFolded = "VERDADEIRO")
      End Function

      Function ParseBoolText(pText As String) As Boolean
         Dim folded As String = me.FoldBoolToken(pText)
         If folded = "" Then
            ParseBoolText = False
            Exit Function
         End If
         If folded = me.FoldBoolToken(me.BoolTrue) Then
            ParseBoolText = True
            Exit Function
         End If
         If folded = me.FoldBoolToken(me.BoolFalse) Then
            ParseBoolText = False
            Exit Function
         End If
         ParseBoolText = me.IsTrueToken(folded)
      End Function

      Function ParseBoolValue(pValue As Variant) As Boolean
         If IsEmpty(pValue) Then
            ParseBoolValue = False
            Exit Function
         End If
         ParseBoolValue = me.ParseBoolText(CStr(pValue))
      End Function

      Function BoolDbText(pValue As Boolean) As String
         If pValue Then
            BoolDbText = me.BoolTrue
         Else
            BoolDbText = me.BoolFalse
         End If
      End Function

      Function AsDate() As TFieldDef
         me.Kind = _kindDate
         me.KindId = 4
         AsDate = me
      End Function

      Function AsDateTime() As TFieldDef
         me.Kind = _kindDateTime
         me.KindId = 5
         AsDateTime = me
      End Function

      Function AsTime() As TFieldDef
         me.Kind = _kindTime
         me.KindId = 6
         AsTime = me
      End Function

      Function AsBase64() As TFieldDef
         me.Kind = _kindBase64
         me.KindId = 7
         If me.MaxLength = 255 Then
            me.MaxLength = 0
         End If
         AsBase64 = me
      End Function

      Function PrimaryKeyField() As TFieldDef
         me.PrimaryKey = True
         me.Required = True
         me.NullIfEmpty = False
         PrimaryKeyField = me
      End Function

      Function AutoCodeField() As TFieldDef
         me.AutoCode = True
         me.PrimaryKey = True
         me.NullIfEmpty = False
         AutoCodeField = me
      End Function

      Function RequiredField() As TFieldDef
         me.Required = True
         RequiredField = me
      End Function

      Function MaxLen(pValue As Integer) As TFieldDef
         me.MaxLength = pValue
         MaxLen = me
      End Function

      Function NumericPrec(pPrecision As Integer, pScale As Integer = 0) As TFieldDef
         me.Precision = pPrecision
         me.Scale = pScale
         NumericPrec = me
      End Function

      Function DefaultVal(pValue As Variant) As TFieldDef
         me.DefaultValue = pValue
         DefaultVal = me
      End Function

      Function NullIfEmptyField(pValue As Boolean = True) As TFieldDef
         me.NullIfEmpty = pValue
         NullIfEmptyField = me
      End Function

      Function SelectOnlyField() As TFieldDef
         me.SelectOnly = True
         me.Persist = False
         me.Insertable = False
         me.Updatable = False
         SelectOnlyField = me
      End Function

      Function SelExpr(pExpression As String) As TFieldDef
         me.SelectExpr = pExpression
         SelExpr = me
      End Function

      Function InsExpr(pExpression As String) As TFieldDef
         me.InsertExpr = pExpression
         InsExpr = me
      End Function

      Function UpdExpr(pExpression As String) As TFieldDef
         me.UpdateExpr = pExpression
         UpdExpr = me
      End Function

      Function InsertableField(pValue As Boolean = True) As TFieldDef
         me.Insertable = pValue
         InsertableField = me
      End Function

      Function UpdatableField(pValue As Boolean = True) As TFieldDef
         me.Updatable = pValue
         UpdatableField = me
      End Function

      Function NotUpdatable() As TFieldDef
         me.Updatable = False
         NotUpdatable = me
      End Function

      Function WithDbType(pType As String) As TFieldDef
         me.DbType = pType
         WithDbType = me
      End Function

      Function WithSequence(pName As String) As TFieldDef
         me.SequenceName = pName
         WithSequence = me
      End Function

      Overrides Function Clone() As TFieldDef
         Dim n As New TFieldDef(me.Name)
         n.DbName = me.DbName
         n.ParamName = me.ParamName
         n.Kind = me.Kind
         n.KindId = me.KindId
         n.DbType = me.DbType
         n.MaxLength = me.MaxLength
         n.Precision = me.Precision
         n.Scale = me.Scale
         n.DefaultValue = me.DefaultValue
         n.PrimaryKey = me.PrimaryKey
         n.AutoCode = me.AutoCode
         n.SequenceName = me.SequenceName
         n.Persist = me.Persist
         n.Insertable = me.Insertable
         n.Updatable = me.Updatable
         n.SelectOnly = me.SelectOnly
         n.SelectExpr = me.SelectExpr
         n.InsertExpr = me.InsertExpr
         n.UpdateExpr = me.UpdateExpr
         n.NullIfEmpty = me.NullIfEmpty
         n.Required = me.Required
         n.IncludeInSelect = me.IncludeInSelect
         n.BoolTrue = me.BoolTrue
         n.BoolFalse = me.BoolFalse
         Clone = n
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TField

      Def As TFieldDef
      Name As String
      Value As Variant

      Sub New(pDef As TFieldDef, pValue As Variant)
         MyBase.New()
         me.Def = pDef
         me.Name = pDef.Name
         me.Value = pValue
      End Sub

      Function EffectiveValue() As Variant
         If IsEmpty(me.Value) Then
            EffectiveValue = me.Def.DefaultValue
         Else
            EffectiveValue = me.Value
         End If
      End Function

      Shared Function TypeErrorMarker() As String
         TypeErrorMarker = "Falha de tipo no campo "
      End Function

      Function WrapTypeError(pEx As Exception) As String
         Dim detail As String = ""
         If Assigned(pEx) Then
            detail = Trim(pEx.Message)
            If detail.Pos(TField.TypeErrorMarker()) > 0 Then
               WrapTypeError = detail
               Exit Function
            End If
         End If
         Dim nome As String = Trim(me.Name)
         Dim tipo As String = ""
         If Assigned(me.Def) Then
            tipo = Trim(me.Def.Kind.AsString)
         End If
         WrapTypeError = TField.TypeErrorMarker() & nome & "." & Char(13) & Char(13) & "Nome: " & nome & Char(13) & "Tipo: " & tipo & Char(13) & "Exceção: " & detail
      End Function

      Shared Function IsBlankDate(pDate As TDateTime) As Boolean
         IsBlankDate = (pDate = 0) Or (pDate = Unassigned)
      End Function

      Shared Function Pad2(pValue As Integer) As String
         Dim s As String = CStr(pValue)
         If Len(s) < 2 Then
            Pad2 = "0" & s
         Else
            Pad2 = s
         End If
      End Function

      Shared Function Pad4(pValue As Integer) As String
         Dim s As String = CStr(pValue)
         If Len(s) = 1 Then
            Pad4 = "000" & s
         ElseIf Len(s) = 2 Then
            Pad4 = "00" & s
         ElseIf Len(s) = 3 Then
            Pad4 = "0" & s
         Else
            Pad4 = s
         End If
      End Function

      Shared Function HasChar(pText As String, pChar As String) As Boolean
         HasChar = pText.Pos(pChar) > 0
      End Function

      Shared Function IsDigits(pText As String) As Boolean
         Dim i As Integer
         Dim n As Integer = Len(pText)
         If n = 0 Then
            IsDigits = False
            Exit Function
         End If
         For i = 1 To n
            Dim ch As String = Mid(pText, i, 1)
            If (ch < "0") Or (ch > "9") Then
               IsDigits = False
               Exit Function
            End If
         Next
         IsDigits = True
      End Function

      Shared Function OnlyDigits(pText As String) As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = Len(pText)
         For i = 1 To n
            Dim ch As String = Mid(pText, i, 1)
            If (ch >= "0") And (ch <= "9") Then
               result = result & ch
            End If
         Next
         OnlyDigits = result
      End Function

      Shared Function ToLocalDateText(pText As String) As String
         Dim s As String = Trim(pText)
         ToLocalDateText = s
         If Len(s) < 10 Then
            Exit Function
         End If
         If (Mid(s, 5, 1) <> "-") Or (Mid(s, 8, 1) <> "-") Then
            Exit Function
         End If
         Dim yearText As String = Left(s, 4)
         Dim monthText As String = Mid(s, 6, 2)
         Dim dayText As String = Mid(s, 9, 2)
         Dim rest As String = ""
         If Len(s) > 10 Then
            rest = Mid(s, 11, Len(s) - 10)
         End If
         ToLocalDateText = dayText & "/" & monthText & "/" & yearText & rest
      End Function

      Shared Function SqlDate(pDate As TDateTime) As String
         SqlDate = TField.Pad4(pDate.YearOf) & "-" & TField.Pad2(pDate.MonthOf) & "-" & TField.Pad2(pDate.DayOf)
      End Function

      Shared Function SqlDateTime(pDate As TDateTime) As String
         SqlDateTime = TField.SqlDate(pDate) & " " & pDate.ToString("hh:nn:ss")
      End Function

      Shared Function TryParseCompact(pText As String, ByRef pDate As TDateTime) As Boolean
         Dim raw As String = Trim(pText)
         Dim probe As TDateTime = DateTime()
         TryParseCompact = False
         If (Len(raw) = 8) And TField.IsDigits(raw) Then
            pDate = probe.EncodeDate(CInt(Left(raw, 4)), CInt(Mid(raw, 5, 2)), CInt(Right(raw, 2)))
            TryParseCompact = Not TField.IsBlankDate(pDate)
         ElseIf ((Len(raw) = 14) Or (Len(raw) = 17)) And TField.IsDigits(raw) Then
            Dim msec As Integer = 0
            If Len(raw) = 17 Then
               msec = CInt(Right(raw, 3))
            End If
            pDate = probe.EncodeDateTime(CInt(Left(raw, 4)), CInt(Mid(raw, 5, 2)), CInt(Mid(raw, 7, 2)), CInt(Mid(raw, 9, 2)), CInt(Mid(raw, 11, 2)), CInt(Mid(raw, 13, 2)), msec)
            TryParseCompact = Not TField.IsBlankDate(pDate)
         End If
      End Function

      Shared Function TryParseDate(pText As String, ByRef pDate As TDateTime) As Boolean
         Dim raw As String = Trim(pText)
         If raw = "" Then
            TryParseDate = False
            Exit Function
         End If
         If TField.TryParseCompact(raw, pDate) Then
            pDate = pDate.Date()
            TryParseDate = Not TField.IsBlankDate(pDate)
            Exit Function
         End If
         raw = TField.ToLocalDateText(raw)
         Dim parsed As TDateTime
         If TryStrToDate(raw, parsed) Then
            pDate = parsed.Date()
            TryParseDate = Not TField.IsBlankDate(pDate)
            Exit Function
         End If
         Dim _result As Boolean
         Try
            parsed = StrToDateTime(raw)
            pDate = parsed.Date()
            _result = Not TField.IsBlankDate(pDate)
         Catch ex As Exception
            _result = False
         End Try
         TryParseDate = _result
      End Function

      Shared Function TryParseDateTime(pText As String, ByRef pDate As TDateTime) As Boolean
         Dim raw As String = Trim(pText)
         If raw = "" Then
            TryParseDateTime = False
            Exit Function
         End If
         If TField.TryParseCompact(raw, pDate) Then
            TryParseDateTime = True
            Exit Function
         End If
         raw = TField.ToLocalDateText(raw)
         Try
            pDate = StrToDateTime(raw)
            ' data7:disable-next-line shared-return-assignment-in-try
            TryParseDateTime = Not TField.IsBlankDate(pDate)
            Exit Function
         Catch ex As Exception
         End Try
         Dim parsed As TDateTime
         If TryStrToDate(raw, parsed) Then
            pDate = parsed.Date()
            TryParseDateTime = Not TField.IsBlankDate(pDate)
         Else
            TryParseDateTime = False
         End If
      End Function

      Shared Function TryParseTime(pText As String, ByRef pDate As TDateTime) As Boolean
         Dim raw As String = Trim(pText)
         If raw = "" Then
            TryParseTime = False
            Exit Function
         End If
         Dim digits As String = TField.OnlyDigits(raw)
         Dim probe As TDateTime = DateTime()
         If Len(digits) = 6 Then
            Dim workHour As Integer = CInt(Left(digits, 2))
            Dim workMin As Integer = CInt(Mid(digits, 3, 2))
            Dim workSec As Integer = CInt(Right(digits, 2))
            If (workHour >= 0) And (workHour <= 23) And (workMin >= 0) And (workMin <= 59) And (workSec >= 0) And (workSec <= 59) Then
               pDate = probe.EncodeTime(workHour, workMin, workSec, 0)
               TryParseTime = Not TField.IsBlankDate(pDate)
               Exit Function
            End If
         ElseIf Len(digits) = 4 Then
            Dim shortHour As Integer = CInt(Left(digits, 2))
            Dim shortMin As Integer = CInt(Right(digits, 2))
            If (shortHour >= 0) And (shortHour <= 23) And (shortMin >= 0) And (shortMin <= 59) Then
               pDate = probe.EncodeTime(shortHour, shortMin, 0, 0)
               TryParseTime = Not TField.IsBlankDate(pDate)
               Exit Function
            End If
         End If
         Dim parsed As TDateTime
         If TField.TryParseDateTime(raw, parsed) Then
            If parsed.IsDate() And (Not TField.HasChar(raw, ":")) Then
               TryParseTime = False
            Else
               pDate = probe.EncodeTime(parsed.HourOf, parsed.MinuteOf, parsed.SecondOf, 0)
               TryParseTime = Not TField.IsBlankDate(pDate)
            End If
         Else
            TryParseTime = False
         End If
      End Function

      Function IsDateKind() As Boolean
         Dim kindId As Integer = me.Def.KindId
         IsDateKind = (kindId = 4) Or (kindId = 5) Or (kindId = 6)
      End Function

      Sub NormalizeDate()
         If Not me.IsDateKind() Then
            Exit Sub
         End If
         If IsEmpty(me.Value) Then
            Exit Sub
         End If
         Dim kindId As Integer = me.Def.KindId
         Dim dt As TDateTime = me.Value
         If Not TField.IsBlankDate(dt) Then
            If kindId = 4 Then
               me.Value = dt.Date()
            End If
            Exit Sub
         End If
         Dim parsed As TDateTime
         Dim ok As Boolean
         If kindId = 4 Then
            ok = TField.TryParseDate(CStr(me.Value), parsed)
         ElseIf kindId = 6 Then
            ok = TField.TryParseTime(CStr(me.Value), parsed)
         Else
            ok = TField.TryParseDateTime(CStr(me.Value), parsed)
         End If
         If ok Then
            me.Value = parsed
         Else
            me.Value = Unassigned
         End If
      End Sub

      Function IsNull() As Boolean
         If Not me.Def.NullIfEmpty Then
            IsNull = False
            Exit Function
         End If
         Dim v As Variant = me.EffectiveValue()
         If IsEmpty(v) Then
            IsNull = True
            Exit Function
         End If
         If me.IsDateKind() Then
            IsNull = TField.IsBlankDate(me.AsDateTime)
         ElseIf ((me.Def.KindId = 0) Or (me.Def.KindId = 7)) And (Trim(CStr(v)) = "") Then
            IsNull = True
         Else
            IsNull = False
         End If
      End Function

      Property AsInteger As Integer
         Get
            Try
               Dim _value As Variant = me.EffectiveValue()
               If IsEmpty(_value) Then
                  AsInteger = 0
               Else
                  AsInteger = CInt(_value)
               End If
            Catch ex As Exception
               Throw New Exception(me.WrapTypeError(ex))
            End Try
         End Get
         Set(pValue As Integer)
            me.Value = pValue
         End Set
      End Property

      Property AsString As String
         Get
            Dim kindId As Integer = me.Def.KindId
            If (kindId = 4) Or (kindId = 5) Or (kindId = 6) Then
               Dim dt As TDateTime = me.AsDateTime
               If TField.IsBlankDate(dt) Then
                  AsString = ""
               ElseIf kindId = 4 Then
                  AsString = dt.Date().ToString()
               ElseIf kindId = 6 Then
                  AsString = dt.ToString("hh:nn:ss")
               Else
                  AsString = dt.ToString()
               End If
            Else
               Dim _value As Variant = me.EffectiveValue()
               If IsEmpty(_value) Then
                  AsString = ""
               Else
                  AsString = CStr(_value)
               End If
            End If
         End Get
         Set(pValue As String)
            me._setAsString(pValue)
         End Set
      End Property

      Private Sub _setAsString(pValue As String)
         Dim text As String = Trim(pValue)
         Dim kindId As Integer = me.Def.KindId
         If text = "" Then
            me.Value = Unassigned
            Exit Sub
         End If
         Dim parsed As TDateTime
         If kindId = 4 Then
            If TField.TryParseDate(text, parsed) Then
               me.Value = parsed
            Else
               me.Value = Unassigned
            End If
         ElseIf kindId = 5 Then
            If TField.TryParseDateTime(text, parsed) Then
               me.Value = parsed
            Else
               me.Value = Unassigned
            End If
         ElseIf kindId = 6 Then
            If TField.TryParseTime(text, parsed) Then
               me.Value = parsed
            Else
               me.Value = Unassigned
            End If
         Else
            me.Value = pValue
         End If
      End Sub

      Property AsFloat As Extended
         Get
            Try
               Dim _value As Variant = me.EffectiveValue()
               If IsEmpty(_value) Then
                  AsFloat = 0
               Else
                  AsFloat = CDbl(_value)
               End If
            Catch ex As Exception
               Throw New Exception(me.WrapTypeError(ex))
            End Try
         End Get
         Set(pValue As Extended)
            me.Value = pValue
         End Set
      End Property

      Property AsBoolean As Boolean
         Get
            Dim _value As Variant = me.EffectiveValue()
            If IsEmpty(_value) Then
               AsBoolean = False
            Else
               AsBoolean = me.Def.ParseBoolValue(_value)
            End If
         End Get
         Set(pValue As Boolean)
            me.Value = pValue
         End Set
      End Property

      Property AsDateTime As TDateTime
         Get
            Try
               Dim _value As Variant = me.EffectiveValue()
               If IsEmpty(_value) Then
                  AsDateTime = Unassigned
               Else
                  AsDateTime = _value
               End If
            Catch ex As Exception
               Throw New Exception(me.WrapTypeError(ex))
            End Try
         End Get
         Set(pValue As TDateTime)
            me._setAsDateTime(pValue)
         End Set
      End Property

      Private Sub _setAsDateTime(pValue As TDateTime)
         If TField.IsBlankDate(pValue) Then
            me.Value = Unassigned
         ElseIf me.Def.KindId = 4 Then
            me.Value = pValue.Date()
         Else
            me.Value = pValue
         End If
      End Sub

      Property AsBase64 As String
         Get
            Dim _value As Variant = me.EffectiveValue()
            If IsEmpty(_value) Then
               AsBase64 = ""
            Else
               AsBase64 = CStr(_value)
            End If
         End Get
         Set(pValue As String)
            If Trim(pValue) = "" Then
               me.Value = Unassigned
            Else
               me.Value = pValue
            End If
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TFields
      Inherits TTObject

      Fields As StringList

      Sub New()
         MyBase.New()
         me.Fields = New StringList()
         me.Fields.OwnsObjects = True
      End Sub

      Function HasField(pID As String) As Boolean
         HasField = me.Fields.IndexOf(UCase(pID)) >= 0
      End Function

      Function GetField(pIndex As Integer) As TField
         GetField = CType(me.Fields.Objects(pIndex), TField)
      End Function

      Function GetField(pID As String) As TField
         Dim idx As Integer = me.Fields.IndexOf(UCase(pID))
         If idx < 0 Then
            Throw New Exception("Campo inexistente: " & pID)
         End If
         GetField = CType(me.Fields.Objects(idx), TField)
      End Function

      Sub AddField(pField As TField)
         me.Fields.AddObject(UCase(pField.Name), pField)
      End Sub

      Sub AddField(pID As String, pField As TField)
         me.Fields.AddObject(UCase(pID), pField)
      End Sub

      Sub SetField(pID As String, pField As TField)
         pID = UCase(pID)
         Dim idx As Integer = me.Fields.IndexOf(pID)
         If idx >= 0 Then
            me.Fields.Objects(idx) = pField
         Else
            me.Fields.AddObject(pID, pField)
         End If
      End Sub

      Function GetInteger(pName As String) As Integer
         GetInteger = me.GetField(pName).AsInteger
      End Function

      Sub SetInteger(pName As String, pValue As Integer)
         me.GetField(pName).AsInteger = pValue
      End Sub

      Function GetString(pName As String) As String
         GetString = me.GetField(pName).AsString
      End Function

      Sub SetString(pName As String, pValue As String)
         me.GetField(pName).AsString = pValue
      End Sub

      Function GetFloat(pName As String) As Double
         GetFloat = me.GetField(pName).AsFloat
      End Function

      Sub SetFloat(pName As String, pValue As Double)
         me.GetField(pName).AsFloat = pValue
      End Sub

      Function GetBoolean(pName As String) As Boolean
         GetBoolean = me.GetField(pName).AsBoolean
      End Function

      Sub SetBoolean(pName As String, pValue As Boolean)
         me.GetField(pName).AsBoolean = pValue
      End Sub

      Function GetDateTime(pName As String) As TDateTime
         GetDateTime = me.GetField(pName).AsDateTime
      End Function

      Sub SetDateTime(pName As String, pValue As TDateTime)
         me.GetField(pName).AsDateTime = pValue
      End Sub

      Function GetBase64(pName As String) As String
         GetBase64 = me.GetField(pName).AsBase64
      End Function

      Sub SetBase64(pName As String, pValue As String)
         me.GetField(pName).AsBase64 = pValue
      End Sub

      Function GetFieldList() As String
         GetFieldList = me.Fields.Text.Trim.Replace(me.Fields.LineBreak, ",")
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Fields) Then
            me.Fields.Free()
            me.Fields = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TDdlOp
      Inherits TTObject

      Kind As TDdlOpKind
      TableName As String
      ColumnName As String
      ColumnNameTo As String
      FieldDef As TFieldDef
      SequenceName As String
      SqlText As String
      ResourceKind As TResourceKind
      ResourceName As String
      ResourceBody As String
      AlterMode As TAlterColumnMode

      Sub New(pKind As TDdlOpKind)
         MyBase.New()
         me.Kind = pKind
         me.TableName = ""
         me.ColumnName = ""
         me.ColumnNameTo = ""
         me.SequenceName = ""
         me.SqlText = ""
         me.ResourceName = ""
         me.ResourceBody = ""
         me.AlterMode = TFieldCache.AlterAutomatic()
      End Sub

      Overrides Function GetID() As String
         GetID = me.Kind.AsString & "|" & me.TableName & "|" & me.ColumnName & "|" & me.SequenceName & "|" & me.ResourceName
      End Function

      Overrides Function Clone() As TTObject
         Dim n As New TDdlOp(me.Kind)
         n.TableName = me.TableName
         n.ColumnName = me.ColumnName
         n.ColumnNameTo = me.ColumnNameTo
         n.FieldDef = me.FieldDef
         n.SequenceName = me.SequenceName
         n.SqlText = me.SqlText
         n.ResourceKind = me.ResourceKind
         n.ResourceName = me.ResourceName
         n.ResourceBody = me.ResourceBody
         n.AlterMode = me.AlterMode
         Clone = n
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TResource
      Inherits TTObject

      Kind As TResourceKind
      Name As String
      SqlText As String
      DropOnDown As Boolean

      Sub New(pKind As TResourceKind, pName As String, pSql As String)
         MyBase.New()
         me.Kind = pKind
         me.Name = pName
         me.SqlText = pSql
         me.DropOnDown = True
      End Sub

      Overrides Function GetID() As String
         GetID = me.Kind.AsString & "|" & me.Name
      End Function

      Overrides Function Clone() As TTObject
         Dim n As New TResource(me.Kind, me.Name, me.SqlText)
         n.DropOnDown = me.DropOnDown
         Clone = n
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TColumnInfo
      Inherits TTObject

      Name As String
      NativeType As String
      MaxLength As Integer
      Precision As Integer
      Scale As Integer
      Nullable As Boolean
      PrimaryKey As Boolean
      Identity As Boolean

      Sub New()
         MyBase.New()
         me.Name = ""
         me.NativeType = ""
         me.MaxLength = 0
         me.Precision = 0
         me.Scale = 0
         me.Nullable = True
         me.PrimaryKey = False
         me.Identity = False
      End Sub

      Overrides Function GetID() As String
         GetID = me.Name
      End Function

      Overrides Function Clone() As TTObject
         Dim n As New TColumnInfo()
         n.Name = me.Name
         n.NativeType = me.NativeType
         n.MaxLength = me.MaxLength
         n.Precision = me.Precision
         n.Scale = me.Scale
         n.Nullable = me.Nullable
         n.PrimaryKey = me.PrimaryKey
         n.Identity = me.Identity
         Clone = n
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
