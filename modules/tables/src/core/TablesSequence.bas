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

      Name As String

      Sub New(pName As String)
         MyBase.New()
         me.Name = pName
      End Sub

      Shared Function FromName(pName As String) As TSequence
         FromName = New TSequence(pName)
      End Function

      Shared Function FromSchema(pSchema As TTableSchema, pHasEmpresa As Boolean, pCodEmpresa As Integer) As TSequence
         FromSchema = New TSequence(TSql.ResolvedSequenceName(pSchema, pHasEmpresa, pCodEmpresa))
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
         NextValue = Data7.ProximoCodigo(me.Name)
      End Function

      Function NextValueForEmpresa(pCodEmpresa As Integer) As Integer
         NextValueForEmpresa = Data7.ProximoCodigo(me.Name, pCodEmpresa)
      End Function

      Sub SetValue(pNext As Integer)
         me.RestartWith(pNext)
      End Sub

      Sub RestartWith(pNext As Integer)
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
         Clone = New TSequence(me.Name)
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
