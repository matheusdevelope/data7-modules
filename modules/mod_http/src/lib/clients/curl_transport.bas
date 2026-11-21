Imports mod_curl
Imports http_transport
Imports http_request
Imports http_response
Imports http_form
Imports http_file_io

Namespace http_curl

   Class CurlTransport
      Inherits IHttpTransport

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function Send(pReq As HttpRequest) As HttpResponse
         Dim curlCli As Curl = NULL
         Dim curlOut As CurlOutput = NULL
         Try
            curlCli = New Curl()
            curlCli.Method = pReq.Verb
            curlCli.Url = pReq.Url
            curlCli.TimeoutMs = pReq.Timeout
            curlCli.FollowRedirects = pReq.FollowRedirects

            If Assigned(pReq.Certificate) Then
               If pReq.Certificate.Use And pReq.Certificate.Path <> "" Then
                  curlCli.UsePfx(pReq.Certificate.Path, pReq.Certificate.Pass)
               End If
            End If

            Dim skipContentType As Boolean = Assigned(pReq.Body) And pReq.Body.IsForm
            Dim i As Integer
            Dim count As Integer = pReq.Headers.Count
            For i = 0 To count - 1
               Dim headerName As String = pReq.Headers.Name(i)
               If Not (skipContentType And UCase(headerName) = "CONTENT-TYPE") Then
                  curlCli.AddHeader(headerName, pReq.Headers.Value(i))
               End If
            Next

            If Assigned(pReq.Body) And Not pReq.Body.IsEmpty Then
               If pReq.Body.IsForm Then
                  me.AddFormParts(curlCli, pReq.Body.Form)
               ElseIf pReq.Body.IsDiskStream Then
                  Dim diskPath As String = HttpFileIo.SpoolDisk(pReq.Body.DiskStream)
                  curlCli.TrackTemp(diskPath)
                  curlCli.AddDataBinaryFile(diskPath)
               ElseIf pReq.Body.IsStream Then
                  Dim streamPath As String = me.WriteTempStream(pReq.Body.Raw())
                  curlCli.TrackTemp(streamPath)
                  curlCli.AddDataBinaryFile(streamPath)
               ElseIf pReq.Body.IsFile Then
                  curlCli.AddDataBinaryFile(pReq.Body.FilePath)
               ElseIf pReq.Body.IsBytes Then
                  Dim binPath As String = me.WriteTempBytes(pReq.Body.Raw())
                  curlCli.TrackTemp(binPath)
                  curlCli.AddDataBinaryFile(binPath)
               Else
                  Dim bodyText As String = pReq.Body.AsText()
                  If Trim(bodyText) <> "" Then
                     curlCli.AddBody(bodyText)
                  End If
               End If
            End If

            curlOut = curlCli.Exec()
            Dim _bodyText As String = ""
            If pReq.WantText Then
               _bodyText = curlOut.ResponseText
            End If
            Send = New HttpResponse(curlOut.StatusCode, curlOut.StatusText, curlOut.Headers.Text, _bodyText, curlOut.ResponseData)
            me.ReleaseCurl(curlCli, curlOut)
         Catch ex As Exception
            me.ReleaseCurl(curlCli, curlOut)
            Throw New Exception("Request failed: " & ex._GetMessage() & CHAR(13) & "URL: " & pReq.Url)
         End Try
      End Function

      Private Sub ReleaseCurl(ByRef pHttp As Curl, ByRef pOutput As CurlOutput)
         If Assigned(pOutput) Then
            pOutput.Free()
            pOutput = NULL
         End If
         If Assigned(pHttp) Then
            pHttp.Free()
            pHttp = NULL
         End If
      End Sub

      Private Sub AddFormParts(pCurl As Curl, pForm As FormData)
         Dim i As Integer
         Dim count As Integer = pForm.Count()
         For i = 0 To count - 1
            Dim part As FormDataPart = CType(pForm.Entries().Objects(i), FormDataPart)
            If part.IsFile Then
               Dim filePath As String = part.Value
               If Not IsEmpty(part.ValueRaw) Then
                  filePath = me.WriteTempBytes(part.ValueRaw)
                  pCurl.TrackTemp(filePath)
               End If
               Dim spec As String = part.Name & "=@" & filePath
               If part.Filename <> "" Then
                  spec = spec & ";filename=" & part.Filename
               End If
               If part.ContentType <> "" Then
                  spec = spec & ";type=" & part.ContentType
               End If
               pCurl.AddFormPart(spec)
            Else
               pCurl.AddFormPart(part.Name & "=" & part.Value)
            End If
         Next
      End Sub

      Private Function WriteTempStream(pStream As Variant) As String
         WriteTempStream = HttpFileIo.SpoolToTempFile(pStream)
      End Function

      Private Function WriteTempBytes(pData As Variant) As String
         WriteTempBytes = HttpFileIo.WriteBytesToTemp(pData)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
