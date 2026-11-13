Imports Collections
Imports http_transport
Imports http_request
Imports http_response

Namespace http_mock

   Class MockQueuedResponse

      Status As Integer
      StatusText As String
      Headers As String
      Body As String

      Sub New(pStatus As Integer, pStatusText As String, pHeaders As String, pBody As String)
         MyBase.New()
         me.Status = pStatus
         me.StatusText = pStatusText
         me.Headers = pHeaders
         me.Body = pBody
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class MockTransport
      Inherits IHttpTransport

      DefaultStatus As Integer = 200
      DefaultStatusText As String = "OK"
      DefaultHeaders As String = "Content-Type: application/json"
      DefaultBody As String = "{}"

      LastMethod As String
      LastUrl As String
      LastHeadersText As String
      LastBodyText As String
      LastTimeout As Integer
      CallCount As Integer = 0

      Private _queue As StringList

      Sub New()
         MyBase.New()
         me._queue = New StringList()
         me._queue.OwnsObjects = True
      End Sub

      Sub Enqueue(pStatus As Integer, pBody As String, pHeaders As String = "Content-Type: application/json", pStatusText As String = "OK")
         me._queue.AddObject("", New MockQueuedResponse(pStatus, pStatusText, pHeaders, pBody))
      End Sub

      Overrides Function Send(pReq As HttpRequest) As HttpResponse
         me.CallCount = me.CallCount + 1
         me.LastMethod = pReq.Verb
         me.LastUrl = pReq.Url
         me.LastHeadersText = pReq.Headers.AsText()
         If Assigned(pReq.Body) Then
            me.LastBodyText = pReq.Body.AsText()
         Else
            me.LastBodyText = ""
         End If
         me.LastTimeout = pReq.Timeout

         Dim status As Integer = me.DefaultStatus
         Dim statusText As String = me.DefaultStatusText
         Dim headers As String = me.DefaultHeaders
         Dim body As String = me.DefaultBody

         If me._queue.Count > 0 Then
            Dim queued As MockQueuedResponse = CType(me._queue.Objects(0), MockQueuedResponse)
            status = queued.Status
            statusText = queued.StatusText
            headers = queued.Headers
            body = queued.Body
            me._queue.Delete(0)
         End If

         Send = New HttpResponse(status, statusText, headers, body, body)
      End Function

      Sub Free()
         If Assigned(me._queue) Then
            me._queue.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
