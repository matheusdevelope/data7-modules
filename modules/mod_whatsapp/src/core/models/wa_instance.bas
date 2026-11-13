Imports Collections
Imports mod_tobject

Namespace mod_wa_instance

   Class WaInstance
      Inherits TTObject

      Id As String
      Name As String
      Phone As String
      Connected As Boolean
      Authenticated As Boolean
      ProfileName As String
      ProfileImageUrl As String

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function GetID() As String
         If me.Id <> "" Then
            GetID = me.Id
         ElseIf me.Phone <> "" Then
            GetID = me.Phone
         Else
            GetID = me.Name
         End If
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaInstance")
            .Prop("Id", me.Id)
            .Prop("Name", me.Name)
            .Prop("Phone", me.Phone)
            .Prop("Connected", me.Connected)
            .Prop("Authenticated", me.Authenticated)
            .Prop("ProfileName", me.ProfileName)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Function NameContains(pFilter As String) As Boolean
         Dim _key As String = Trim(pFilter)
         If _key = "" Then
            NameContains = True
            Exit Function
         End If
         NameContains = me.Name.ToUpper.Contains(UCase(pFilter))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaInstanceList
      Inherits TTObject

      Private _list As TTObjectList

      Sub New()
         MyBase.New()
         me._list = New TTObjectList("WaInstanceList", True)
      End Sub

      Sub Add(pInstance As WaInstance)
         me._list.Push(pInstance)
      End Sub

      Function Take(pIndex As Integer) As WaInstance
         Take = WaInstance(me._list.Take(pIndex))
      End Function

      Function Take(pId As String) As WaInstance
         Take = WaInstance(me._list.Take(pId))
      End Function

      Function Count() As Integer
         Count = me._list.Length()
      End Function

      Sub RemoveAt(pIndex As Integer)
         If pIndex < 0 Or pIndex >= me.Count() Then
            Exit Sub
         End If
         Dim _item As WaInstance = WaInstance(me._list.Extract(pIndex))
         If Assigned(_item) Then
            _item.Free()
         End If
      End Sub

      Sub KeepNameContains(pFilter As String)
         Dim _key As String = Trim(pFilter)
         If _key = "" Then
            Exit Sub
         End If
         Dim _total As Integer = me.Count()
         Dim _scan As Integer = 0
         Dim i As Integer
         For i = 1 To _total
            If _scan >= me.Count() Then
               Exit For
            End If
            If me.Take(_scan).NameContains(_key) Then
               _scan = _scan + 1
            Else
               me.RemoveAt(_scan)
            End If
         Next
      End Sub

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
