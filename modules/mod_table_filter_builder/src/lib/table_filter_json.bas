' data7:disable qualified-private-shared-access
Imports mod_tlist
Imports table_filter_field
Imports table_filter_item
Imports table_filter_ops
Imports table_filter_table

Namespace table_filter_json

   ' data7:disable-next-line missing-mybase-free
   Class TFilterJson

      Shared Function Build(pTabela As TFilterTable, pItems As TTList<TFilterItem>, pQualify As Boolean) As String
         Dim root As New TJSONObject()
         root.PutInteger("version", 1)
         Dim schema As String = ""
         Dim nome As String = ""
         If Assigned(pTabela) Then
            schema = pTabela.Schema
            nome = pTabela.Nome
         End If
         root.PutString("schema", schema)
         root.PutString("table", nome)
         root.PutBoolean("qualify", pQualify)
         Dim items As New TJSONArray()
         If Assigned(pItems) Then
            Dim i As Integer
            Dim last As Integer = pItems.Length - 1
            For i = 0 To last
               items.PutObject(TFilterJson.ItemObject(pItems.Take(i)))
            Next
         End If
         root.PutArray("items", items)
         Build = root.ToString()
         root.Free()
      End Function

      Shared Function TryLoad(pJson As String, pTabela As TFilterTable, pItems As TTList<TFilterItem>, ByRef pQualify As Boolean) As Boolean
         If Not Assigned(pItems) Then
            TryLoad = False
            Exit Function
         End If
         pItems.Clean()
         Dim texto As String = Trim(pJson)
         If texto = "" Then
            TryLoad = False
            Exit Function
         End If
         Dim ok As Boolean = False
         Try
            Dim root As New TJSONObject(texto)
            If Assigned(root) Then
               If root.Has("qualify") Then
                  pQualify = root.GetBoolean("qualify")
               End If
               If root.Has("items") Then
                  Dim arr As TJSONArray = root.GetArray("items")
                  If Assigned(arr) Then
                     Dim i As Integer
                     Dim last As Integer = arr.Length() - 1
                     For i = 0 To last
                        Dim item As TFilterItem = TFilterJson.ItemFromObject(arr.GetJSONObject(i), pTabela)
                        If Assigned(item) Then
                           pItems.Push(item)
                        End If
                     Next
                  End If
               End If
               root.Free()
               ok = True
            End If
         Catch ex As Exception
            pItems.Clean()
            Throw New Exception(ex.Message)
         End Try
         TryLoad = ok
      End Function

      Private Shared Function ItemObject(pItem As TFilterItem) As TJSONObject
         Dim obj As New TJSONObject()
         If Not Assigned(pItem) Then
            ItemObject = obj
            Exit Function
         End If
         obj.PutString("id", pItem.GetID())
         obj.PutString("logicalOp", pItem.LogicalOp)
         obj.PutString("fieldName", pItem.FieldName)
         obj.PutString("fieldTitle", pItem.FieldTitle)
         obj.PutString("fieldTipo", pItem.FieldTipo)
         obj.PutString("fieldKind", pItem.FieldKind)
         obj.PutString("condition", pItem.Condition)
         obj.PutString("conditionTitle", pItem.ConditionTitle)
         obj.PutString("displayValue", pItem.DisplayValue)
         Dim values As New TJSONArray()
         Dim i As Integer
         Dim last As Integer = pItem.Values.Length - 1
         For i = 0 To last
            Dim one As New TJSONObject()
            one.PutString("value", pItem.Values.Take(i))
            values.PutObject(one)
         Next
         obj.PutArray("values", values)
         ItemObject = obj
      End Function

      Private Shared Function ItemFromObject(pObj As TJSONObject, pTabela As TFilterTable) As TFilterItem
         If Not Assigned(pObj) Then
            ItemFromObject = Null
            Exit Function
         End If
         Dim condition As String = UCase(Trim(TFilterJson.ReadString(pObj, "condition")))
         If condition = "" Then
            condition = TFilterOps.Equal()
         End If
         If TFilterOps.IsSql(condition) Then
            If Not TFilterOps.AllowsSqlQuery() Then
               ItemFromObject = Null
               Exit Function
            End If
         End If
         Dim item As New TFilterItem()
         item.SetID(TFilterJson.ReadString(pObj, "id"))
         item.LogicalOp = UCase(Trim(TFilterJson.ReadString(pObj, "logicalOp")))
         If (item.LogicalOp <> "AND") And (item.LogicalOp <> "OR") Then
            item.LogicalOp = "AND"
         End If
         item.FieldName = Trim(TFilterJson.ReadString(pObj, "fieldName"))
         item.FieldTitle = TFilterJson.ReadString(pObj, "fieldTitle")
         item.FieldTipo = TFilterJson.ReadString(pObj, "fieldTipo")
         item.FieldKind = TFilterJson.ReadString(pObj, "fieldKind")
         item.Condition = condition
         item.ConditionTitle = TFilterOps.TitleOf(condition)
         item.DisplayValue = TFilterJson.ReadString(pObj, "displayValue")
         If pObj.Has("values") Then
            Dim arr As TJSONArray = pObj.GetArray("values")
            If Assigned(arr) Then
               Dim i As Integer
               Dim last As Integer = arr.Length() - 1
               For i = 0 To last
                  Dim one As TJSONObject = arr.GetJSONObject(i)
                  item.Values.Push(TFilterJson.ReadString(one, "value"))
               Next
            End If
         End If
         If Assigned(pTabela) Then
            Dim field As TFilterField = pTabela.FindByName(item.FieldName)
            If Assigned(field) Then
               item.FieldTitle = field.Titulo
               item.FieldTipo = field.Tipo
               item.FieldKind = field.Kind()
            End If
         End If
         If Trim(item.FieldTitle) = "" Then
            item.FieldTitle = item.FieldName
         End If
         ItemFromObject = item
      End Function

      Private Shared Function ReadString(pObj As TJSONObject, pKey As String) As String
         If Assigned(pObj) Then
            If pObj.Has(pKey) Then
               ReadString = pObj.GetString(pKey)
               Exit Function
            End If
         End If
         ReadString = ""
      End Function

   End Class

End Namespace
