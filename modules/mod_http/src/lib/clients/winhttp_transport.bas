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

            me.EnsureWinHttp()
            me._http.Open(pReq.Verb.ToUpper(), pReq.Url, False)
            me.ApplyRedirectPolicy(pReq)
            me.ApplyClientCertificate(pReq)

            me._http.SetTimeouts(pReq.Timeout, pReq.Timeout, pReq.Timeout, pReq.Timeout)

            Dim i As Integer
            Dim headerCount As Integer = pReq.Headers.Count
            For i = 0 To headerCount - 1
               me._http.SetRequestHeader(pReq.Headers.Name(i), pReq.Headers.Value(i))
            Next

            me.SendBody(pReq)

            Dim statusCode As Integer = me._http.Status
            Dim statusText As String = me._http.StatusText
            Dim headersText As String = me._http.GetAllResponseHeaders
            Dim bodyText As String = ""
            Dim bodyData As Variant
            If pReq.WantText Then
               bodyText = me._http.ResponseText
            End If
            bodyData = me._http.ResponseBody
            Send = New HttpResponse(statusCode, statusText, headersText, bodyText, bodyData)
         Catch ex As Exception
            me.ResetWinHttp()
            Throw New Exception("Request failed: " & ex._GetMessage() & CHAR(13) & "URL: " & pReq.Url)
         End Try
      End Function

      Private Sub EnsureWinHttp()
         Dim kind As String = TypeName(me._http)
         If (kind = "Empty") Or (kind = "Null") Or (kind = "Unassigned") Or (kind = "String") Then
            me._http = CreateObject("WinHttp.WinHttpRequest.5.1")
         End If
      End Sub

      Private Sub ResetWinHttp()
         me._http = Unassigned
      End Sub

      Private Sub SendBody(pReq As HttpRequest)
         If Not Assigned(pReq.Body) Then
            me._http.Send()
            Exit Sub
         End If
         If pReq.Body.IsStream Then
            me.SendBinaryStream(pReq.Body.Raw())
            Exit Sub
         End If
         If pReq.Body.IsFile Then
            me.SendBinaryFile(pReq.Body.FilePath)
            Exit Sub
         End If
         If pReq.Body.IsBytes Then
            me.SendBinary(pReq.Body.Raw())
            Exit Sub
         End If
         Dim payload As Variant = pReq.Body.Raw()
         If TypeName(payload) = "Array" Then
            If Not IsEmpty(payload) Then
               me._http.Send(payload)
            Else
               me._http.Send()
            End If
            Exit Sub
         End If
         If TypeName(payload) = "String" Then
            If Trim(payload) <> "" Then
               me._http.Send(payload)
            Else
               me._http.Send()
            End If
            Exit Sub
         End If
         me._http.Send()
      End Sub

      Private Sub SendBinary(pData As Variant)
         Dim binStream As Variant = CreateObject("ADODB.Stream")
         binStream.Type = 1
         binStream.Open()
         If TypeName(pData) = "String" Then
            Dim textStream As Variant = CreateObject("ADODB.Stream")
            textStream.Type = 2
            textStream.Charset = "iso-8859-1"
            textStream.Open()
            textStream.WriteText(pData)
            textStream.Position = 0
            textStream.Type = 1
            If textStream.Size > 0 Then
               binStream.Write(textStream.Read)
            End If
            textStream.Close()
            textStream = Unassigned
         ElseIf Not IsEmpty(pData) Then
            binStream.Write(pData)
         End If
         binStream.Position = 0
         If binStream.Size > 0 Then
            me._http.Send(binStream)
         Else
            me._http.Send()
         End If
         binStream.Close()
         binStream = Unassigned
      End Sub

      Private Sub SendBinaryStream(pStream As Variant)
         Dim kind As String = TypeName(pStream)
         If (kind = "Empty") Or (kind = "Null") Or (kind = "Unassigned") Then
            me._http.Send()
            Exit Sub
         End If
         pStream.Position = 0
         If pStream.Size > 0 Then
            me._http.Send(pStream)
         Else
            me._http.Send()
         End If
      End Sub

      Private Sub SendBinaryFile(pPath As String)
         Dim binStream As Variant = CreateObject("ADODB.Stream")
         binStream.Type = 1
         binStream.Open()
         binStream.LoadFromFile(pPath)
         binStream.Position = 0
         If binStream.Size > 0 Then
            me._http.Send(binStream)
         Else
            me._http.Send()
         End If
         binStream.Close()
         binStream = Unassigned
      End Sub

      Private Sub ApplyRedirectPolicy(pReq As HttpRequest)
         If pReq.FollowRedirects Then
            Exit Sub
         End If
         Dim enableRedirects As Integer = 6
         Dim maxRedirects As Integer = 14
         me._http.Option(enableRedirects) = False
         me._http.Option(maxRedirects) = 0
      End Sub

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
            Catch ex As Exception
            End Try
         Next
         locators.Free()
         If pReq.Certificate.Path <> "" Or pReq.Certificate.Locator.Trim() <> "" Then
            Throw New Exception("Não foi possível selecionar o certificado do cliente no WinHttp. Locator=" & pReq.Certificate.Locator & " Name=" & pReq.Certificate.Name)
         End If
      End Sub

      Sub Free()
         me.ResetWinHttp()
         MyBase.Free()
      End Sub

   End Class

End Namespace
