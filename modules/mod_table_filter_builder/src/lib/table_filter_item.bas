Imports mod_tlist
Imports mod_tobject

Namespace table_filter_item

   Class TFilterItem
      Inherits TTObject

      Private _id As String
      LogicalOp As String
      FieldName As String
      FieldTitle As String
      FieldTipo As String
      FieldKind As String
      Condition As String
      ConditionTitle As String
      Values[] As String = []
      DisplayValue As String

      Sub New()
         MyBase.New()
         me._id = ""
         me.LogicalOp = "AND"
         me.FieldName = ""
         me.FieldTitle = ""
         me.FieldTipo = ""
         me.FieldKind = ""
         me.Condition = "EQ"
         me.ConditionTitle = ""
         me.DisplayValue = ""
         me.Values = []
      End Sub

      Sub SetID(pID As String)
         me._id = pID
      End Sub

      Overrides Function GetID() As String
         If me._id <> "" Then
            GetID = me._id
         Else
            GetID = me.FieldName & ":" & me.Condition
         End If
      End Function

      Overrides Function Clone() As TFilterItem
         Dim copy As New TFilterItem()
         copy.SetID(me._id)
         copy.LogicalOp = me.LogicalOp
         copy.FieldName = me.FieldName
         copy.FieldTitle = me.FieldTitle
         copy.FieldTipo = me.FieldTipo
         copy.FieldKind = me.FieldKind
         copy.Condition = me.Condition
         copy.ConditionTitle = me.ConditionTitle
         copy.DisplayValue = me.DisplayValue
         Dim i As Integer
         Dim last As Integer = me.Values.Length - 1
         For i = 0 To last
            copy.Values.Push(me.Values.Take(i))
         Next
         Clone = copy
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Values) Then
            me.Values.Free()
            me.Values = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
