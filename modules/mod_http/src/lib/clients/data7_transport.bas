Imports http_transport
Imports http_request
Imports http_response

Namespace http_data7

   Class Data7Transport
      Inherits IHttpTransport

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function Send(pReq As HttpRequest) As HttpResponse
         Dim verb As String = UCase(pReq.Verb)
         If verb <> "GET" And verb <> "POST" And verb <> "PUT" Then
            Throw New Exception("Data7 THTTP does not support " & pReq.Verb & ". Use WinHttp or Curl.")
         End If
         If Assigned(pReq.Body) Then
            If pReq.Body.IsBytes Or pReq.Body.IsForm Then
               Throw New Exception("Data7 THTTP does not support binary or multipart bodies.")
            End If
         End If
         If Assigned(pReq.Certificate) Then
            If pReq.Certificate.Use And (pReq.Certificate.Locator.Trim() <> "" Or pReq.Certificate.Path <> "") Then
               Throw New Exception("Data7 THTTP does not support client certificates.")
            End If
         End If

         Try
            Dim native As New THTTP()
            If pReq.Headers.Has("Accept") Then
               native.Accept = pReq.Headers.Value("Accept")
            End If
            If pReq.Headers.Has("Content-Type") Then
               native.ContentType = pReq.Headers.Value("Content-Type")
            End If
            If Assigned(pReq.Body) And Not pReq.Body.IsEmpty Then
               native.Body = pReq.Body.AsText()
            End If

            Dim i As Integer
            Dim count As Integer = pReq.Headers.Count
            For i = 0 To count - 1
               Dim headerName As String = pReq.Headers.Name(i)
               If UCase(headerName) <> "ACCEPT" And UCase(headerName) <> "CONTENT-TYPE" Then
                  native.AddCustomHeader(headerName & ": " & pReq.Headers.Value(i))
               End If
            Next

            Dim bodyText As String
            Select Case verb
               Case "GET"
                  bodyText = native.Get(pReq.Url)
               Case "POST"
                  bodyText = native.Post(pReq.Url)
               Case "PUT"
                  bodyText = native.Put(pReq.Url)
            End Select

            Dim status As Integer = native.ResponseCode
            Dim statusText As String
            If status >= 200 And status < 300 Then
               statusText = "OK"
            Else
               statusText = "Error"
            End If
            Dim headers As String = ""
            If native.ContentType <> "" Then
               headers = "Content-Type: " & native.ContentType
            End If
            Dim responseText As String = bodyText
            If native.ResponseText <> "" Then
               responseText = native.ResponseText
            End If
            native.Free()
            Send = New HttpResponse(status, statusText, headers, responseText, responseText)
         Catch ex As Exception
            Throw New Exception("Request failed: " & ex._GetMessage() & CHAR(13) & "URL: " & pReq.Url)
         End Try
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
