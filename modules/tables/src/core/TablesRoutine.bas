Imports mod_tobject
Imports TablesField
Imports TablesSql

Namespace TablesRoutine

   Class TRoutine
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Function Exists(pKind As TResourceKind, pName As String) As Boolean
         Exists = TSql.ExistsFlag(TSql.Dialect().SqlRoutineExists(pKind, pName))
      End Function

      Sub CreateOrAlter(pKind As TResourceKind, pName As String, pBody As String)
         TSql.ExecScript(TSql.Dialect().SqlCreateOrAlter(pKind, pName, pBody))
      End Sub

      Sub Drop(pKind As TResourceKind, pName As String)
         If TSql.Dialect().SupportsDropIfExists() Then
            TSql.ExecScript(TSql.Dialect().SqlDropRoutine(pKind, pName))
         ElseIf me.Exists(pKind, pName) Then
            TSql.ExecScript(TSql.Dialect().SqlDropRoutine(pKind, pName))
         End If
      End Sub

      Sub DropIndexOnTable(pIndex As String, pTable As String)
         If TSql.Dialect().SupportsDropIfExists() Then
            TSql.ExecScript(TSql.Dialect().SqlDropIndexOnTable(pIndex, pTable))
         ElseIf me.Exists(TResourceKind.Index(), pIndex) Then
            TSql.ExecScript(TSql.Dialect().SqlDropIndexOnTable(pIndex, pTable))
         End If
      End Sub

      Sub ApplyResource(pRes As TResource)
         If Trim(pRes.SqlText) = "" Then
            me.Drop(pRes.Kind, pRes.Name)
         Else
            me.CreateOrAlter(pRes.Kind, pRes.Name, pRes.SqlText)
         End If
      End Sub

      Overrides Sub Dispose()
      End Sub

      Overrides Function Clone() As TTObject
         Clone = New TRoutine()
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
