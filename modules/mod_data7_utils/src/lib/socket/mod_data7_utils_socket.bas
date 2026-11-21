Imports Forms
Imports mod_data7_utils_runtime
Imports mod_data7_utils_socket_event

Namespace mod_data7_utils_socket

   Delegate Sub TSocketClient_OnConnect(pSender As TObject, pSocketID As String)
   Delegate Sub TSocketClient_OnDisconnect(pSender As TObject, pReason As String)
   Delegate Sub TSocketClient_OnError(pSender As TObject, pError As String)
   Delegate Sub TSocketClient_OnEvent(pSender As TObject, pEvent As TSocketEvent)

   Class TSocketClient
      Inherits TComRuntime

      Private _timer As Timer

      OnConnect As TSocketClient_OnConnect
      OnDisconnect As TSocketClient_OnDisconnect
      OnError As TSocketClient_OnError
      OnEvent As TSocketClient_OnEvent

      Sub New()
         MyBase.New("Data7Utils.SocketClient")
         me._timer = New Forms.Timer(NULL)
         me._timer.Interval = 10
         me._timer.OnTimer = me.HandleOnTimer
         me._timer.Enabled = True
      End Sub

      Property Connected As Boolean
         Get
            Return me.COM.Connected
         End Get
      End Property

      Property SocketId As String
         Get
            Return me.COM.SocketId
         End Get
      End Property

      Property LastError As String
         Get
            Return me.COM.LastError
         End Get
      End Property

      Sub Connect(pHost As String, pNamespace As String, pToken As String = "", pAuthByAuthObject As Boolean = True, pAuthByHeader As Boolean = False, pTransports As String = "websocket,polling", pReconnection As Boolean = True, pReconnectionAttempts As Integer = 100, pReconnectionDelayMax As Integer = 10000, pConnectionTimeout As Integer = 10)
         me.COM.Connect(pHost, pNamespace, pToken, pAuthByAuthObject, pAuthByHeader, pTransports, pReconnection, pReconnectionAttempts, pReconnectionDelayMax, pConnectionTimeout)
      End Sub

      Sub Disconnect()
         me.COM.Disconnect()
      End Sub

      Function Subscribe(pName As String) As String
         Subscribe = me.COM.Subscribe(pName)
      End Function

      Function Unsubscribe(pRequestId As String, pName As String) As Boolean
         Unsubscribe = me.COM.Unsubscribe(pRequestId, pName)
      End Function

      Sub Emit(pName As String, pJsonPayload As String)
         me.COM.Emit(pName, pJsonPayload)
      End Sub

      Sub EmitFile(pName As String, pFilePath As String, pMetadataJson As String)
         me.COM.EmitFile(pName, pFilePath, pMetadataJson)
      End Sub

      Function HasEvents() As Boolean
         HasEvents = me.COM.HasEvents
      End Function

      Function GetNextEvent() As TSocketEvent
         Dim nextEvent As Variant = me.COM.GetNextEvent
         If IsEmpty(nextEvent) Then
            GetNextEvent = NULL
            Exit Function
         End If
         GetNextEvent = New TSocketEvent(nextEvent)
      End Function

      Sub ClearEvents()
         me.COM.ClearEvents()
      End Sub

      Sub Dispose()
         If me._timer <> NULL Then
            me._timer.Enabled = False
            me._timer.Free()
            me._timer = NULL
         End If
         If Not IsEmpty(me.COM) Then
            me.COM.Dispose()
         End If
         me.COM = Unassigned
      End Sub

      Sub Free()
         me.Dispose()
         MyBase.Free()
      End Sub

      Private Sub HandleOnTimer(pSender As TObject)
         Dim sockEvent As TSocketEvent
         While me.HasEvents()
            sockEvent = me.GetNextEvent()
            If sockEvent <> NULL Then
               Select sockEvent.Name
                  Case "connect"
                     If me.OnConnect <> NULL Then
                        me.OnConnect(me, me.SocketId)
                     End If
                  Case "disconnect"
                     If me.OnDisconnect <> NULL Then
                        me.OnDisconnect(me, sockEvent.AsText())
                     End If
                  Case "error", "reconnect_error", "connect_error"
                     If me.OnError <> NULL Then
                        me.OnError(me, sockEvent.AsText())
                     End If
                  Case Else
                     If me.OnEvent <> NULL Then
                        me.OnEvent(me, sockEvent)
                     End If
               End Select
               sockEvent.Free()
            End If
         End While
      End Sub

   End Class

End Namespace
