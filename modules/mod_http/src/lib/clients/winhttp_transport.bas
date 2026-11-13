Imports Collections
Imports http_transport
Imports http_request
Imports http_response
Imports mod_certificate

Namespace http_winhttp

   Class WinHttpTransport
      Inherits IHttpTransport

      Private _http As Variant

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function Send(pReq As HttpRequest) As HttpResponse
         Try
            If Assigned(pReq.Certificate) Then
               If pReq.Certificate.Use And pReq.Certificate.Path <> "" Then
                  pReq.Certificate.Install()
               End If
            End If

            me._http = CreateObject("WinHttp.WinHttpRequest.5.1")
            me._http.Open(pReq.Verb.ToUpper(), pReq.Url, False)
            me.ApplyClientCertificate(pReq)

            me._http.SetTimeouts(pReq.Timeout, pReq.Timeout, pReq.Timeout, pReq.Timeout)

            Dim i As Integer
            Dim count As Integer = pReq.Headers.Count
            For i = 0 To count - 1
               me._http.SetRequestHeader(pReq.Headers.Name(i), pReq.Headers.Value(i))
            Next

            Dim payload As Variant
            If Assigned(pReq.Body) Then
               payload = pReq.Body.Raw()
            Else
               payload = ""
            End If
            If TypeName(payload) = "Array" Then
               If Not IsEmpty(payload) Then
                  me._http.Send(payload)
               Else
                  me._http.Send()
               End If
            ElseIf TypeName(payload) = "String" Then
               If Trim(payload) <> "" Then
                  me._http.Send(payload)
               Else
                  me._http.Send()
               End If
            Else
               me._http.Send()
            End If

            Dim statusCode As Integer = me._http.Status
            Dim statusText As String = me._http.StatusText
            Dim headersText As String = me._http.GetAllResponseHeaders
            Dim bodyText As String = me._http.ResponseText
            Dim bodyData As Variant = me._http.ResponseBody
            me._http = ""
            Send = New HttpResponse(statusCode, statusText, headersText, bodyText, bodyData)
         Catch ex As Exception
            Throw New Exception("Request failed: " & ex._GetMessage() & CHAR(13) & "URL: " & pReq.Url)
         End Try
      End Function

      Private Sub ApplyClientCertificate(pReq As HttpRequest)
         If Not Assigned(pReq.Certificate) Then
            Exit Sub
         End If
         If Not pReq.Certificate.Use Then
            Exit Sub
         End If
         Dim locators As StringList = pReq.Certificate.WinHttpLocators()
         Dim i As Integer
         For i = 0 To locators.Count - 1
            Try
               me._http.SetClientCertificate(locators.Strings(i))
               locators.Free()
               Exit Sub
            Catch
            End Try
         Next
         locators.Free()
         If pReq.Certificate.Path <> "" Or pReq.Certificate.Locator.Trim() <> "" Then
            Throw New Exception("Não foi possível selecionar o certificado do cliente no WinHttp. Locator=" & pReq.Certificate.Locator & " Name=" & pReq.Certificate.Name)
         End If
      End Sub

      Sub Free()
         me._http = ""
         MyBase.Free()
      End Sub

   End Class

End Namespace
