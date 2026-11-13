Imports Collections
Imports mod_tobject
Imports mod_wa_contracts

Namespace mod_wa_compose_client

   Class WaComposeClient
      Inherits TTObject

      Key As String
      Label As String
      Client As WaClient
      OwnsClient As Boolean

      Sub New()
         MyBase.New()
      End Sub

      Sub New(pClient As WaClient, pLabel As String = "", pKey As String = "", pOwnsClient As Boolean = False)
         MyBase.New()
         If pClient = NULL Then
            Throw New Exception("WaComposeClient requer um WaClient")
         End If
         me.Client = pClient
         me.OwnsClient = pOwnsClient
         If pKey.Trim() <> "" Then
            me.Key = pKey.Trim()
         Else
            me.Key = pClient.GetName()
         End If
         If pLabel.Trim() <> "" Then
            me.Label = pLabel.Trim()
         Else
            me.Label = me.Key
         End If
      End Sub

      Function Matches(pValue As String) As Boolean
         Dim _key As String = pValue.Trim()
         Dim _ok As Boolean
         If _key = "" Then
            Matches = False
            Exit Function
         End If
         _ok = me.Key = _key Or me.Label = _key
         If Not _ok And Assigned(me.Client) Then
            _ok = me.Client.GetName() = _key
         End If
         Matches = _ok
      End Function

      Overrides Function GetID() As String
         GetID = me.Key
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaComposeClient")
            .Prop("Key", me.Key)
            .Prop("Label", me.Label)
            If Assigned(me.Client) Then
               .Prop("Client", me.Client.GetName())
            End If
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If me.OwnsClient And Assigned(me.Client) Then
            me.Client.Free()
         End If
         me.Client = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaComposeClientList
      Inherits TTObject

      Private _list As TTObjectList

      Sub New()
         MyBase.New()
         me._list = New TTObjectList("WaComposeClientList", True)
      End Sub

      Sub Add(pEntry As WaComposeClient)
         If pEntry = NULL Then
            Exit Sub
         End If
         If Assigned(pEntry.Client) Then
            If me.IndexOfClient(pEntry.Client) >= 0 Then
               If pEntry.OwnsClient Then
                  pEntry.OwnsClient = False
               End If
               pEntry.Free()
               Exit Sub
            End If
         End If
         me._list.Push(pEntry)
      End Sub

      Sub Add(pClient As WaClient, pLabel As String = "", pKey As String = "", pOwnsClient As Boolean = False)
         me.Add(New WaComposeClient(pClient, pLabel, pKey, pOwnsClient))
      End Sub

      Function Take(pIndex As Integer) As WaComposeClient
         Take = WaComposeClient(me._list.Take(pIndex))
      End Function

      Function Count() As Integer
         Count = me._list.Length()
      End Function

      Function IndexOfClient(pClient As WaClient) As Integer
         If pClient = NULL Or me.Count() = 0 Then
            IndexOfClient = -1
            Exit Function
         End If
         Dim i As Integer
         For i = 0 To me.Count() - 1
            If me.Take(i).Client = pClient Then
               IndexOfClient = i
               Exit Function
            End If
         Next
         IndexOfClient = -1
      End Function

      Function IndexOfKey(pValue As String) As Integer
         Dim _key As String = pValue.Trim()
         If _key = "" Or me.Count() = 0 Then
            IndexOfKey = -1
            Exit Function
         End If
         Dim i As Integer
         For i = 0 To me.Count() - 1
            If me.Take(i).Matches(_key) Then
               IndexOfKey = i
               Exit Function
            End If
         Next
         IndexOfKey = -1
      End Function

      Function Find(pValue As String) As WaComposeClient
         Dim _idx As Integer = me.IndexOfKey(pValue)
         If _idx < 0 Then
            Find = NULL
         Else
            Find = me.Take(_idx)
         End If
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
