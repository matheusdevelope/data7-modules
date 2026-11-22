Imports http_client
Imports http_enums
Imports http_headers
Imports http_body
Imports http_response
Imports mod_tobject
Imports google_drive_config
Imports google_drive_endpoints
Imports google_drive_errors

Namespace google_drive_http

   Class GoogleDriveHttp
      Inherits TTObject

      Private _client As HttpClient
      Private _ownsClient As Boolean
      Private _endpoints As GoogleDriveEndpoints
      Private _config As GoogleDriveConfig

      Sub New(pClient As HttpClient, pEndpoints As GoogleDriveEndpoints, pConfig As GoogleDriveConfig, pOwnsClient As Boolean = True)
         MyBase.New()
         If Not Assigned(pClient) Then
            Throw New Exception(GoogleDriveErrors.HttpRequired())
         End If
         If Not Assigned(pEndpoints) Then
            Throw New Exception(GoogleDriveErrors.EndpointsRequired())
         End If
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleDriveErrors.ConfigRequired())
         End If
         me._client = pClient
         me._endpoints = pEndpoints
         me._config = pConfig
         me._ownsClient = pOwnsClient
         me._client.ContentType = "application/json"
         me._client.Accept = "application/json"
         me._client.Timeout = pConfig.Timeout
         me._client.RetryCount = pConfig.RetryCount
         me._client.RetryBaseDelayMs = pConfig.RetryBaseDelayMs
         me._client.Certificate.Use = False
      End Sub

      Function Client() As HttpClient
         Client = me._client
      End Function

      Function Endpoints() As GoogleDriveEndpoints
         Endpoints = me._endpoints
      End Function

      Function Config() As GoogleDriveConfig
         Config = me._config
      End Function

      Function GetJson(pPath As String, pQuery As HttpParams) As TJSONObject
         Dim url As String = me._endpoints.WithQuery(pPath, pQuery)
         Dim response As HttpResponse = me.Send(HttpMethod.Gett(), url, Null, Null)
         GetJson = me.ReadJson(response)
      End Function

      Function PostJson(pPath As String, pQuery As HttpParams, pJson As TJSONObject) As TJSONObject
         Dim url As String = me._endpoints.WithQuery(pPath, pQuery)
         Dim body As HttpBody = HttpBody.FromJson(pJson.ToString())
         Dim response As HttpResponse = me.Send(HttpMethod.Post(), url, body, Null)
         body.Free()
         PostJson = me.ReadJson(response)
      End Function

      Function PatchJson(pPath As String, pQuery As HttpParams, pJson As TJSONObject) As TJSONObject
         Dim url As String = me._endpoints.WithQuery(pPath, pQuery)
         Dim body As HttpBody = HttpBody.FromJson(pJson.ToString())
         Dim response As HttpResponse = me.Send(HttpMethod.Patch(), url, body, Null)
         body.Free()
         PatchJson = me.ReadJson(response)
      End Function

      Sub Delete(pPath As String, pQuery As HttpParams)
         Dim url As String = me._endpoints.WithQuery(pPath, pQuery)
         Dim response As HttpResponse = me.Send(HttpMethod.Delete(), url, Null, Null)
         If Not response.IsSuccessful Then
            me.ThrowFailed(response)
         End If
         response.Free()
      End Sub

      Function Send(pMethod As HttpMethod, pEndpoint As String, pBody As HttpBody, pExtra As HttpHeaders, pWantText As Boolean = True) As HttpResponse
         Dim savedWant As Boolean = me._client.WantText
         Dim response As HttpResponse = Null
         me._client.WantText = pWantText
         Try
            If Assigned(pBody) Then
               response = me._client.Request(pMethod, pEndpoint, pBody, pExtra)
            ElseIf Assigned(pExtra) Then
               response = me._client.Request(pMethod, pEndpoint, pExtra)
            Else
               response = me._client.Request(pMethod, pEndpoint)
            End If
         Catch ex As Exception
            me._client.WantText = savedWant
            Throw ex
         End Try
         me._client.WantText = savedWant
         Send = response
      End Function

      Function ReadJson(pResponse As HttpResponse) As TJSONObject
         If Not Assigned(pResponse) Then
            Throw New Exception(GoogleDriveErrors.RequestFailed(0, "empty response"))
         End If
         If Not pResponse.IsSuccessful Then
            me.ThrowFailed(pResponse)
         End If
         If (Not Assigned(pResponse.Body)) Or (Trim(pResponse.Body.AsText) = "") Then
            Dim emptyJson As New TJSONObject()
            pResponse.Free()
            ReadJson = emptyJson
            Exit Function
         End If
         Dim parsed As TJSONObject = pResponse.Body.AsJson
         pResponse.Free()
         ReadJson = parsed
      End Function

      Sub ThrowFailed(pResponse As HttpResponse)
         Dim status As Integer = 0
         Dim detail As String = ""
         If Assigned(pResponse) Then
            status = pResponse.Status
            If Assigned(pResponse.Body) Then
               detail = pResponse.Body.AsText
            End If
            pResponse.Free()
         End If
         Throw New Exception(GoogleDriveErrors.RequestFailed(status, me.FormatError(detail)))
      End Sub

      Function FormatError(pBody As String) As String
         Dim text As String = Trim(pBody)
         If text = "" Then
            FormatError = ""
            Exit Function
         End If
         Try
            Dim json As TJSONObject = New TJSONObject(text)
            If json.Has("error") Then
               Dim errObj As TJSONObject = json.GetJSONObject("error")
               Dim message As String = ""
               If Assigned(errObj) Then
                  If errObj.Has("message") Then
                     message = errObj.GetString("message")
                  End If
               End If
               Dim reason As String = ""
               If Assigned(errObj) Then
                  If errObj.Has("errors") Then
                     Dim arr As TJSONArray = errObj.GetArray("errors")
                     If Assigned(arr) Then
                        If arr.Length() > 0 Then
                           Dim firstErr As TJSONObject = arr.GetJSONObject(0)
                           If Assigned(firstErr) Then
                              If firstErr.Has("reason") Then
                                 reason = firstErr.GetString("reason")
                              End If
                           End If
                        End If
                     End If
                  End If
               End If
               json.Free()
               If reason <> "" Then
                  FormatError = reason & ": " & message
                  Exit Function
               End If
               FormatError = message
               Exit Function
            End If
            json.Free()
         Catch ex As Exception
            Return text
         End Try
         FormatError = text
      End Function

      Overrides Sub Dispose()
         If me._ownsClient And Assigned(me._client) Then
            me._client.Free()
         End If
         me._client = Null
         me._endpoints = Null
         me._config = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
