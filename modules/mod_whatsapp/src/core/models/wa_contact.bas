Imports Collections
Imports mod_tobject

Namespace mod_wa_contact

   Class WaContact
      Inherits TTObject

      Id As String
      Phone As String
      Name As String
      Exists As Boolean
      ProfileImageUrl As String

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function GetID() As String
         If me.Id <> "" Then
            GetID = me.Id
         Else
            GetID = me.Phone
         End If
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaContact")
            .Prop("Phone", me.Phone)
            .Prop("Name", me.Name)
            .Prop("Exists", me.Exists)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaContactList
      Inherits TTObject

      Private _list As TTObjectList

      Sub New()
         MyBase.New()
         me._list = New TTObjectList("WaContactList", True)
      End Sub

      Sub Add(pContact As WaContact)
         me._list.Push(pContact)
      End Sub

      Function Take(pIndex As Integer) As WaContact
         Take = WaContact(me._list.Take(pIndex))
      End Function

      Function Count() As Integer
         Count = me._list.Length()
      End Function

      Function IndexOfPhone(pPhone As String) As Integer
         If me.Count() = 0 Then
            IndexOfPhone = -1
            Exit Function
         End If
         Dim i As Integer
         For i = 0 To me.Count() - 1
            If me.Take(i).Phone = pPhone Then
               IndexOfPhone = i
               Exit Function
            End If
         Next
         IndexOfPhone = -1
      End Function

      Overrides Sub Dispose()
         If Assigned(me._list) Then
            me._list.Free()
            me._list = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
