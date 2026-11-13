Imports mod_tobject
Imports TablesSchema
Imports TablesSql

Namespace TablesSequence

   Class TSequenceLease
      Inherits TTObject

      SequenceName As String
      NextBefore As Integer
      FirstCode As Integer
      LastCode As Integer
      Private _cursor As Integer
      Private _committed As Boolean
      Private _rolled As Boolean

      Sub New(pName As String, pNextBefore As Integer, pCount As Integer)
         MyBase.New()
         me.SequenceName = pName
         me.NextBefore = pNextBefore
         me.FirstCode = pNextBefore
         me.LastCode = pNextBefore + pCount - 1
         me._cursor = pNextBefore
         me._committed = False
         me._rolled = False
      End Sub

      Function Take() As Integer
         If me._cursor > me.LastCode Then
            Throw New Exception("TSequenceLease esgotado: " & me.SequenceName)
         End If
         Take = me._cursor
         me._cursor = me._cursor + 1
      End Function

      Sub Commit()
         me._committed = True
      End Sub

      Sub Rollback()
         If me._rolled Or me._committed Then
            Exit Sub
         End If
         Dim seq As New TSequence(me.SequenceName)
         seq.RestartWith(me.NextBefore)
         seq.Free()
         me._rolled = True
      End Sub

      Overrides Function GetID() As String
         GetID = me.SequenceName
      End Function

      Overrides Function Clone() As TTObject
         Clone = New TSequenceLease(me.SequenceName, me.NextBefore, me.LastCode - me.FirstCode + 1)
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class TSequence
      Inherits TTObject

      Private _tableName As String
      Private _schemaName As String
      Private _codEmpresa As Integer
      Private _literalName As String

      Sub New(pName As String)
         MyBase.New()
         me._tableName = ""
         me._schemaName = ""
         me._codEmpresa = 0
         me._literalName = ""
         me.Name = pName
      End Sub

      Sub New(pName As String, pCodEmpresa As Integer)
         MyBase.New()
         me._tableName = ""
         me._schemaName = ""
         me._codEmpresa = 0
         me._literalName = ""
         me.Name = pName
         If pCodEmpresa > 0 Then
            me.CodEmpresa = pCodEmpresa
         End If
      End Sub

      Sub New(pTableName As String, pSchemaName As String, pCodEmpresa As Integer)
         MyBase.New()
         me._literalName = ""
         me._tableName = Trim(pTableName)
         me._schemaName = Trim(pSchemaName)
         me._codEmpresa = pCodEmpresa
         If me._codEmpresa < 0 Then
            me._codEmpresa = 0
         End If
      End Sub

      Property TableName As String
         Get
            TableName = me._tableName
         End Get
         Set(pValue As String)
            me._tableName = Trim(pValue)
            me._literalName = ""
         End Set
      End Property

      Property SchemaName As String
         Get
            SchemaName = me._schemaName
         End Get
         Set(pValue As String)
            me._schemaName = Trim(pValue)
            me._literalName = ""
         End Set
      End Property

      Property CodEmpresa As Integer
         Get
            CodEmpresa = me._codEmpresa
         End Get
         Set(pValue As Integer)
            If pValue < 0 Then
               me._codEmpresa = 0
            Else
               me._codEmpresa = pValue
            End If
         End Set
      End Property

      Property Name As String
         Get
            If me._literalName <> "" Then
               Name = me._literalName
            Else
               Name = TSql.StandardSequenceName(me._schemaName, me._tableName, me._codEmpresa > 0, me._codEmpresa)
            End If
         End Get
         Set(pValue As String)
            me.ApplyName(Trim(pValue))
         End Set
      End Property

      Private Function SliceAt(pText As String, pAt As Integer, pLen As Integer) As String
         If (pAt < 0) Or (pLen <= 0) Or (pText.Length < pAt + pLen) Then
            SliceAt = ""
            Exit Function
         End If
         SliceAt = pText.Right(pText.Length - pAt).Left(pLen)
      End Function

      Private Function IsDigits(pText As String) As Boolean
         If pText = "" Then
            IsDigits = False
            Exit Function
         End If
         Dim i As Integer
         For i = 1 To pText.Length
            Dim ch As String = pText.Left(i).Right(1)
            If (ch < "0") Or (ch > "9") Then
               IsDigits = False
               Exit Function
            End If
         Next
         IsDigits = True
      End Function

      Private Sub ApplyName(pName As String)
         Dim marker As String = "_Sequencia"
         Dim at As Integer = pName.IndexOf(marker)
         If me.SliceAt(pName, at, marker.Length) <> marker Then
            me._literalName = pName
            me._tableName = pName
            me._schemaName = ""
            me._codEmpresa = 0
            Exit Sub
         End If
         Dim tailLen As Integer = pName.Length - at - marker.Length
         Dim tail As String = ""
         If tailLen > 0 Then
            tail = pName.Right(tailLen)
         End If
         Dim empresa As Integer = 0
         If tail <> "" Then
            If tail.Left(1) <> "_" Then
               me._literalName = pName
               me._tableName = pName
               me._schemaName = ""
               me._codEmpresa = 0
               Exit Sub
            End If
            Dim digits As String = tail.Right(tail.Length - 1)
            If Not me.IsDigits(digits) Then
               me._literalName = pName
               me._tableName = pName
               me._schemaName = ""
               me._codEmpresa = 0
               Exit Sub
            End If
            empresa = CInt(digits)
         End If
         Dim body As String = pName.Left(at)
         Dim dot As Integer = body.IndexOf(".")
         me._literalName = ""
         me._codEmpresa = empresa
         If me.SliceAt(body, dot, 1) <> "." Then
            me._schemaName = ""
            me._tableName = body
         Else
            me._schemaName = body.Left(dot)
            me._tableName = body.Right(body.Length - dot - 1)
         End If
      End Sub

      Shared Function Load(pSchema As TTableSchema, pCodEmpresa As Integer = 0) As TSequence
         Dim explicitName As String = TSql.ExplicitSequenceName(pSchema)
         If explicitName <> "" Then
            Load = New TSequence(explicitName)
         Else
            Load = New TSequence(pSchema.TableName, pSchema.SchemaName, pCodEmpresa)
         End If
      End Function

      Function Exists() As Boolean
         Exists = TSql.ExistsFlag(TSql.Dialect().SqlSequenceExists(me.Name))
      End Function

      Sub CreateIfMissing()
         If Not me.Exists() Then
            TSql.ExecScript(TSql.Dialect().SqlCreateSequence(me.Name))
         End If
      End Sub

      Sub DropIfExists()
         If TSql.Dialect().SupportsDropIfExists() Then
            TSql.ExecScript(TSql.Dialect().SqlDropSequence(me.Name))
         ElseIf me.Exists() Then
            TSql.ExecScript(TSql.Dialect().SqlDropSequence(me.Name))
         End If
      End Sub

      Function CurrentValue() As Integer
         CurrentValue = TSql.ExecScalarV(TSql.Dialect().SqlPeekSequence(me.Name), "v", 0)
      End Function

      Function NextValue() As Integer
         NextValue = TSql.ExecScalarV(TSql.Dialect().SqlNextSequence(me.Name), "v", 0)
      End Function

      Sub SetValue(pNext As Integer)
         me.RestartWith(pNext)
      End Sub

      Sub RestartWith(pNext As Integer)
         me.CreateIfMissing()
         TSql.ExecScript(TSql.Dialect().SqlRestartSequence(me.Name, pNext))
      End Sub

      Sub SyncFromMax(pTable As String, pPk As String)
         Dim sqlText As String = "SELECT COALESCE(MAX(" & pPk & "), 0) AS v FROM " & TSql.Dialect().QuoteIdent(pTable)
         Dim mx As Integer = TSql.ExecScalarV(sqlText, "v", 0)
         me.RestartWith(mx + 1)
      End Sub

      Function AllocateBlock(pCount As Integer) As TSequenceLease
         If pCount <= 0 Then
            Throw New Exception("AllocateBlock requer count > 0")
         End If
         me.CreateIfMissing()
         Dim lastIssued As Integer = me.CurrentValue()
         Dim nextBefore As Integer = lastIssued + 1
         Dim lastCode As Integer = lastIssued + pCount
         me.RestartWith(lastCode + 1)
         AllocateBlock = New TSequenceLease(me.Name, nextBefore, pCount)
      End Function

      Overrides Function GetID() As String
         GetID = me.Name
      End Function

      Overrides Function Clone() As TTObject
         Clone = New TSequence(me.Name, me._codEmpresa)
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
