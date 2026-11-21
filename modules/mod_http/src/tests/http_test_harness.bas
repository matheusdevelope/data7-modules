Imports Collections
Imports http_client
Imports http_enums
Imports http_url
Imports http_headers
Imports http_body
Imports http_form
Imports mod_certificate
Imports mod_curl
Imports http_request
Imports http_response
Imports http_interceptor
Imports http_mock
Imports http_transport
Imports http_range
Imports http_download
Imports http_download_options
Imports http_transfer_control
Imports TFile
Imports TPath

Namespace tests

   Class THookClient
      Inherits HttpClient

      OnRequestCount As Integer = 0
      AfterRequestCount As Integer = 0
      LastUrl As String

      Sub New(pTransport As IHttpTransport)
         MyBase.New(pTransport, "https://api.example.com")
      End Sub

      Overrides Sub OnRequest(pReq As HttpRequest)
         me.OnRequestCount = me.OnRequestCount + 1
         me.LastUrl = pReq.Url
         pReq.Headers.Define("X-Hook", "on")
      End Sub

      Overrides Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
         me.AfterRequestCount = me.AfterRequestCount + 1
         AfterRequest = pRes
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TReplace401
      Inherits HttpInterceptor

      Sub New()
         MyBase.New()
      End Sub

      Overrides Function AfterRequest(pReq As HttpRequest, pRes As HttpResponse) As HttpResponse
         If pRes.Status = 401 Then
            AfterRequest = New HttpResponse(200, "OK", "Content-Type: application/json", "{ok:true}", "{ok:true}")
         Else
            AfterRequest = pRes
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class THttpTest
      Passed As Integer
      Failed As Integer
      Private _failures As StringList
      Private _progressTicks As Integer
      Private _haltGate As HttpTransferControl

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
         me._progressTicks = 0
      End Sub

      Shared Sub RunAll()
         Dim suite As New THttpTest()
         suite.Run()
         suite.Free()
      End Sub

      Sub Run()
         print("==== mod_http ====")
         me.TestEnums()
         me.TestUrlJoin()
         me.TestUrlEncode()
         me.TestHeaders()
         me.TestFollowRedirects()
         me.TestParams()
         me.TestBody()
         me.TestFormData()
         me.TestCertificateDefaults()
         me.TestCurlOutputParse()
         me.TestResponse()
         me.TestMockGetPost()
         me.TestMockRecordsRequest()
         me.TestMockQueue()
         me.TestBearerInterceptor()
         me.TestBasicInterceptor()
         me.TestReplace401()
         me.TestClientSubclassHooks()
         me.TestHttpFactories()
         me.TestHeaderCaseAndInt64()
         me.TestExtraHeaders()
         me.TestWantText()
         me.TestRetry()
         me.TestHttpRange()
         me.TestContentLengthText()
         me.TestDownloadToFile()
         me.TestDownloadPauseCancelResume()
         me.PrintSummary()
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            print("  OK    " + pMsg)
         Else
            me.Failed = me.Failed + 1
            me._failures.Add(pMsg)
            print("  FAIL  " + pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=[" + pGot + "] esperado=[" + pWant + "])")
      End Sub

      Sub AssertEqInt(pGot As Integer, pWant As Integer, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=" + CStr(pGot) + " esperado=" + CStr(pWant) + ")")
      End Sub

      Sub AssertEqBool(pGot As Boolean, pWant As Boolean, pMsg As String)
         Dim gotTxt As String = "False"
         Dim wantTxt As String = "False"
         If pGot Then
            gotTxt = "True"
         End If
         If pWant Then
            wantTxt = "True"
         End If
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=" + gotTxt + " esperado=" + wantTxt + ")")
      End Sub

      Sub TestEnums()
         print("-- enums")
         me.AssertEq(HttpMethod.Gett().AsString, "GET", "HttpMethod.Gett")
         me.AssertEq(HttpMethod.Post().AsString, "POST", "HttpMethod.Post")
         me.AssertEq(HttpMethod.Patch().AsString, "PATCH", "HttpMethod.Patch")
         me.AssertEq(HttpMethod.Delete().AsString, "DELETE", "HttpMethod.Delete")
         me.AssertEq(HttpClientKind.WinHttp().AsString, "WINHTTP", "HttpClientKind.WinHttp")
         me.AssertEq(HttpClientKind.Curl().AsString, "CURL", "HttpClientKind.Curl")
      End Sub

      Sub TestUrlJoin()
         print("-- url join")
         me.AssertEq(http_url.Join("https://api.example.com/", "/v1/users"), "https://api.example.com/v1/users", "Join base+endpoint")
         me.AssertEq(http_url.Join("", "https://abs.example.com/x"), "https://abs.example.com/x", "Join absolute endpoint")
         me.AssertEq(http_url.NormalizePath("/foo/"), "foo", "NormalizePath")
         Dim queryParams As New HttpParams()
         queryParams.Define("q", "abc")
         me.AssertEq(http_url.Build("https://api.example.com", "users", queryParams), "https://api.example.com/users?q=abc", "Build with query")
         queryParams.Free()
         Dim merged As New HttpParams()
         merged.Define("page", "2")
         me.AssertTrue(http_url.Build("https://api.example.com", "users?q=abc", merged).Contains("page=2"), "Build merges endpoint query")
         merged.Free()
      End Sub

      Sub TestUrlEncode()
         print("-- url encode")
         me.AssertEq(http_url.Encode("a b"), "a%20b", "Encode space")
         me.AssertEq(http_url.Decode("a%20b"), "a b", "Decode space")
         Dim queryParams As New HttpParams()
         queryParams.Define("q", "a b")
         Dim url As String = http_url.WithQuery("https://api.example.com/s", queryParams)
         me.AssertTrue(url.Contains("q=a%20b"), "WithQuery encodes params")
         queryParams.Free()
      End Sub

      Sub TestHeaders()
         print("-- headers")
         Dim headers As New HttpHeaders()
         headers.Define("Accept", "application/json")
         headers.Define("X-App", "erp")
         me.AssertEqBool(headers.Has("Accept"), True, "Has Accept")
         me.AssertEq(headers.Value("X-App"), "erp", "Value X-App")
         me.AssertEqInt(headers.Count, 2, "Count")
         headers.Define("Accept", "text/plain")
         me.AssertEq(headers.Value("Accept"), "text/plain", "Define overwrites")
         Dim copiedHeaders As HttpHeaders = headers.Copy()
         me.AssertEq(copiedHeaders.Value("X-App"), "erp", "Copy")
         headers.Remove("X-App")
         me.AssertEqBool(headers.Has("X-App"), False, "Remove")
         copiedHeaders.Free()
         headers.Define("Content-Range", "bytes 0-8388607/5497558138880")
         me.AssertEq(headers.Value("Content-Range"), "bytes 0-8388607/5497558138880", "Define Content-Range string")
         headers.Free()
      End Sub

      Sub TestFollowRedirects()
         print("-- follow redirects")
         Dim client As HttpClient = Http.Mock()
         me.AssertEqBool(client.FollowRedirects, True, "default FollowRedirects")
         Dim res As HttpResponse = client.Gett("/ok")
         Dim recorded As MockTransport = MockTransport(client.Transport)
         me.AssertEqBool(recorded.LastFollowRedirects, True, "request copies True")
         res.Free()
         client.FollowRedirects = False
         Dim second As HttpResponse = client.Gett("/ok")
         me.AssertEqBool(recorded.LastFollowRedirects, False, "request copies False")
         second.Free()
         client.Free()
      End Sub

      Sub TestParams()
         print("-- params")
         Dim queryParams As New HttpParams("?a=1&b=2")
         me.AssertEqBool(queryParams.Has("a"), True, "Load has a")
         me.AssertEq(queryParams.Value("b"), "2", "Load value b")
         me.AssertTrue(queryParams.AsText().Contains("a=1"), "AsText")
         queryParams.Free()
      End Sub

      Sub TestBody()
         print("-- body")
         Dim _empty As New HttpBody()
         me.AssertEqBool(_empty.IsEmpty, True, "Empty")
         _empty.Free()
         Dim text As HttpBody = HttpBody.FromText("hello", "text/plain")
         me.AssertEq(text.AsText(), "hello", "FromText")
         me.AssertEq(text.ContentType, "text/plain", "FromText content-type")
         text.Free()
         Dim jsonBody As HttpBody = HttpBody.FromJson("{id:1}")
         me.AssertEqBool(jsonBody.IsJson, True, "FromJson")
         jsonBody.Free()
         Dim diskBody As HttpBody = HttpBody.FromFile("C:\temp\chunk.bin", "application/octet-stream")
         me.AssertEqBool(diskBody.IsFile, True, "FromFile kind")
         me.AssertEq(diskBody.FilePath, "C:\temp\chunk.bin", "FromFile path")
         diskBody.Free()
         Dim binStream As Variant = CreateObject("ADODB.Stream")
         binStream.Type = 1
         binStream.Open()
         Dim streamBody As HttpBody = HttpBody.FromStream(binStream, "application/octet-stream")
         me.AssertEqBool(streamBody.IsStream, True, "FromStream kind")
         me.AssertTrue(TypeName(streamBody.Raw()) <> "Empty", "FromStream payload")
         streamBody.Free()
         binStream.Close()
         binStream = Unassigned
      End Sub

      Sub TestFormData()
         print("-- form data")
         Dim form As New FormData()
         form.Boundary = "test-boundary"
         form.Append("name", "matheus")
         me.AssertEqBool(form.Has("name"), True, "Has name")
         me.AssertEq(form.Gett("name").Value, "matheus", "Gett value")
         me.AssertEqInt(form.Count(), 1, "Count")
         me.AssertEq(form.ContentTypeHeader, "multipart/form-data; boundary=test-boundary", "ContentTypeHeader")
         Dim bytes As Variant = form.Data()
         me.AssertEqBool(IsEmpty(bytes), False, "Data not empty")
         Dim body As HttpBody = HttpBody.FromForm(form)
         me.AssertEqBool(body.IsForm, True, "HttpBody.FromForm")
         body.Free()
         form.Free()
      End Sub

      Sub TestCertificateDefaults()
         print("-- certificate")
         Dim certItem As New TCertificate()
         me.AssertEqBool(certItem.Use, True, "Use default")
         me.AssertEqBool(certItem.Installed, False, "Installed default")
         me.AssertEq(certItem.Locator, "", "Locator empty")
         Dim copiedCert As TCertificate = certItem.Copy()
         me.AssertEqBool(copiedCert.Use, True, "Copy Use")
         me.AssertEqBool(copiedCert.CleanOnFree, False, "Copy does not own store cleanup")
         copiedCert.Free()
         certItem.Free()
      End Sub

      Sub TestCurlOutputParse()
         print("-- curl output parse")
         Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
         Dim hdrPath As String = fso.GetSpecialFolder(2) & "\" & fso.GetTempName
         Dim bodyPath As String = fso.GetSpecialFolder(2) & "\" & fso.GetTempName
         fso = Unassigned
         With New StringList()
            .Add("HTTP/1.1 301 Moved Permanently")
            .Add("Location: /x")
            .Add("")
            .Add("HTTP/1.1 200 OK")
            .Add("Content-Type: application/json; charset=utf-8")
            .Add("Content-Length: 2")
            .Add("")
            .SaveToFile(hdrPath)
            .Free()
         End With
         With New StringList()
            .Add("{}")
            .SaveToFile(bodyPath)
            .Free()
         End With
         Dim parsedOut As New CurlOutput(hdrPath, bodyPath)
         me.AssertEqInt(parsedOut.StatusCode, 200, "last status after redirect")
         me.AssertEq(parsedOut.StatusText, "OK", "status text remainder")
         me.AssertEq(parsedOut.HttpVersion, "HTTP/1.1", "http version")
         me.AssertTrue(LCase(parsedOut.ContentType).Contains("application/json"), "content-type")
         me.AssertEq(LCase(parsedOut.Charset), "utf-8", "charset")
         parsedOut.Free()
         If IO.File.Exists(hdrPath) Then
            IO.File.Delete(hdrPath)
         End If
         If IO.File.Exists(bodyPath) Then
            IO.File.Delete(bodyPath)
         End If
      End Sub

      Sub TestResponse()
         print("-- response")
         Dim res As New HttpResponse(200, "OK", "Content-Type: application/json" & CHAR(13) & CHAR(10) & "Content-Length: 9", "{ok:1}", "{ok:1}")
         me.AssertEqInt(res.Status, 200, "Status")
         me.AssertEqBool(res.IsSuccessful, True, "IsSuccessful")
         me.AssertEqBool(res.Body.IsJson, True, "Body.IsJson")
         me.AssertEq(res.Body.AsText, "{ok:1}", "Body.AsText")
         me.AssertEqBool(res.Headers.Has("Content-Type"), True, "Headers Content-Type")
         Dim fail As New HttpResponse(404, "Not Found", "", "missing", "missing")
         me.AssertEqBool(fail.IsSuccessful, False, "404 not successful")
         fail.Free()
         res.Free()
      End Sub

      Sub TestMockGetPost()
         print("-- mock get/post")
         Dim client As HttpClient = Http.Mock(200, "{n:1}")
         Dim res As HttpResponse = client.Gett("/ping")
         me.AssertEqInt(res.Status, 200, "GET status")
         me.AssertEq(res.Body.AsText, "{n:1}", "GET body")
         res.Free()
         Dim posted As HttpResponse = client.Post("/items", "{a:1}")
         me.AssertEqInt(posted.Status, 200, "POST status")
         posted.Free()
         Dim patched As HttpResponse = client.Patch("/items/1", "{a:2}")
         me.AssertEqInt(patched.Status, 200, "PATCH status")
         patched.Free()
         Dim deleted As HttpResponse = client.Delete("/items/1")
         me.AssertEqInt(deleted.Status, 200, "DELETE status")
         deleted.Free()
         client.Free()
      End Sub

      Sub TestMockRecordsRequest()
         print("-- mock records request")
         Dim client As HttpClient = Http.Mock()
         client.Params.Define("q", "abc")
         client.Headers.Define("X-App", "erp")
         Dim res As HttpResponse = client.Gett("/users")
         Dim recorded As MockTransport = MockTransport(client.Transport)
         me.AssertEq(recorded.LastMethod, "GET", "LastMethod GET")
         me.AssertTrue(recorded.LastUrl.Contains("users"), "LastUrl has endpoint")
         me.AssertTrue(recorded.LastUrl.Contains("q=abc"), "LastUrl query")
         me.AssertTrue(recorded.LastHeadersText.Contains("X-App"), "LastHeaders X-App")
         me.AssertEqInt(recorded.CallCount, 1, "CallCount")
         res.Free()
         Dim postRes As HttpResponse = client.Post("/users", "{n:x}")
         me.AssertEq(recorded.LastMethod, "POST", "LastMethod POST")
         me.AssertEq(recorded.LastBodyText, "{n:x}", "LastBodyText")
         postRes.Free()
         client.Free()
      End Sub

      Sub TestMockQueue()
         print("-- mock queue")
         Dim transport As New MockTransport()
         transport.Enqueue(201, "{id:1}", "Content-Type: application/json", "Created")
         transport.Enqueue(204, "", "", "No Content")
         Dim client As HttpClient = Http.FromTransport(transport)
         Dim first As HttpResponse = client.Post("/x", "{}")
         me.AssertEqInt(first.Status, 201, "Queue 201")
         first.Free()
         Dim second As HttpResponse = client.Delete("/x")
         me.AssertEqInt(second.Status, 204, "Queue 204")
         second.Free()
         client.Free()
      End Sub

      Sub TestBearerInterceptor()
         print("-- bearer interceptor")
         Dim client As HttpClient = Http.Mock()
         client.Use(New BearerAuth("tok-123"))
         Dim res As HttpResponse = client.Gett("/secure")
         Dim bearerTransport As MockTransport = MockTransport(client.Transport)
         me.AssertTrue(bearerTransport.LastHeadersText.Contains("Bearer tok-123"), "Bearer header")
         res.Free()
         client.Free()
      End Sub

      Sub TestBasicInterceptor()
         print("-- basic interceptor")
         Dim client As HttpClient = Http.Mock()
         client.Use(New BasicAuth("user", "pass"))
         Dim res As HttpResponse = client.Gett("/secure")
         Dim basicTransport As MockTransport = MockTransport(client.Transport)
         me.AssertTrue(basicTransport.LastHeadersText.Contains("Basic "), "Basic header prefix")
         res.Free()
         client.Free()
      End Sub

      Sub TestReplace401()
         print("-- interceptor 401")
         Dim transport As New MockTransport()
         transport.Enqueue(401, "{err:auth}", "Content-Type: application/json", "Unauthorized")
         Dim client As HttpClient = Http.FromTransport(transport)
         client.Use(New TReplace401())
         Dim res As HttpResponse = client.Gett("/secure")
         me.AssertEqInt(res.Status, 200, "401 replaced with 200")
         me.AssertEqBool(res.Body.IsJson, True, "replaced json")
         res.Free()
         client.Free()
      End Sub

      Sub TestClientSubclassHooks()
         print("-- subclass hooks")
         Dim transport As New MockTransport()
         Dim client As New THookClient(transport)
         Dim res As HttpResponse = client.Gett("/hooked")
         me.AssertEqInt(client.OnRequestCount, 1, "OnRequest called")
         me.AssertEqInt(client.AfterRequestCount, 1, "AfterRequest called")
         me.AssertTrue(client.LastUrl.Contains("/hooked"), "hook saw url")
         me.AssertTrue(transport.LastHeadersText.Contains("X-Hook"), "hook header")
         res.Free()
         client.Free()
      End Sub

      Sub CountDownloadProgress(pBytesReceived As Int64, pTotalBytes As Int64)
         me._progressTicks = me._progressTicks + 1
      End Sub

      Sub TestHeaderCaseAndInt64()
         print("-- header case and int64")
         Dim headers As New HttpHeaders()
         headers.Define("Content-Type", "application/octet-stream")
         me.AssertEqBool(headers.Has("content-type"), True, "Has case-insensitive")
         me.AssertEq(headers.Value("CONTENT-TYPE"), "application/octet-stream", "Value case-insensitive")
         Dim sizeValue As Int64 = HttpRange.ParseInt64("5497558138880")
         ' data7:disable-next-line type-mismatch
         headers.Define("X-Size", sizeValue)
         me.AssertEq(headers.Value("X-Size"), "5497558138880", "Define Int64")
         headers.Free()
      End Sub

      Sub TestExtraHeaders()
         print("-- extra headers")
         Dim client As HttpClient = Http.Mock()
         client.Headers.Define("X-App", "erp")
         Dim extra As New HttpHeaders()
         extra.Define("Range", "bytes=0-7")
         Dim res As HttpResponse = client.Gett("/bin", extra)
         Dim recorded As MockTransport = MockTransport(client.Transport)
         me.AssertTrue(recorded.LastHeadersText.Contains("Range"), "request has Range")
         me.AssertTrue(recorded.LastHeadersText.Contains("X-App"), "request keeps session header")
         me.AssertEqBool(client.Headers.Has("Range"), False, "session headers unchanged")
         extra.Free()
         res.Free()
         client.Free()
      End Sub

      Sub TestWantText()
         print("-- want text")
         Dim client As HttpClient = Http.Mock()
         me.AssertEqBool(client.WantText, True, "WantText default")
         Dim res As HttpResponse = client.Gett("/json")
         Dim recorded As MockTransport = MockTransport(client.Transport)
         me.AssertEqBool(recorded.LastWantText, True, "request WantText true")
         res.Free()
         client.WantText = False
         Dim binaryRes As HttpResponse = client.Gett("/bin")
         me.AssertEqBool(recorded.LastWantText, False, "request WantText false")
         binaryRes.Free()
         client.Free()
      End Sub

      Sub TestRetry()
         print("-- retry")
         Dim transport As New MockTransport()
         transport.Enqueue(503, "busy", "Retry-After: 0", "Service Unavailable")
         transport.Enqueue(200, "{ok:1}")
         Dim client As HttpClient = Http.FromTransport(transport)
         client.RetryCount = 2
         client.RetryBaseDelayMs = 1
         Dim res As HttpResponse = client.Gett("/flaky")
         me.AssertEqInt(res.Status, 200, "retry then 200")
         me.AssertEqInt(transport.CallCount, 2, "retried once")
         res.Free()
         client.Free()
         Dim resumeTransport As New MockTransport()
         resumeTransport.Enqueue(308, "", "Range: bytes=0-5")
         Dim resumeClient As HttpClient = Http.FromTransport(resumeTransport)
         resumeClient.RetryCount = 3
         resumeClient.RetryBaseDelayMs = 1
         Dim incomplete As HttpResponse = resumeClient.Gett("/upload")
         me.AssertEqBool(incomplete.IsResumeIncomplete, True, "308 is resume incomplete")
         me.AssertEqInt(resumeTransport.CallCount, 1, "308 is not retried")
         incomplete.Free()
         resumeClient.Free()
      End Sub

      Sub TestHttpRange()
         print("-- http range")
         Dim startOff As Int64 = HttpRange.Zero64()
         Dim endOff As Int64 = HttpRange.FromInteger(7)
         Dim total As Int64 = HttpRange.FromInteger(100)
         me.AssertEq(HttpRange.Download(startOff, endOff), "bytes=0-7", "download range")
         me.AssertEq(HttpRange.ContentRange(startOff, endOff, total), "bytes 0-7/100", "content-range")
         me.AssertEq(HttpRange.ResumeProbe(total), "bytes */100", "resume probe")
         me.AssertEq(HttpRange.ParseEnd("bytes 0-5").ToString(), "5", "parse end")
         me.AssertEq(HttpRange.ParseEnd("bytes 0-4/10").ToString(), "4", "parse end with total")
         me.AssertEq(HttpRange.ParseTotal("bytes 0-4/10").ToString(), "10", "parse total")
      End Sub

      Sub TestContentLengthText()
         print("-- content length text")
         Dim res As New HttpResponse(200, "OK", "Content-Length: 5497558138880", "", "")
         me.AssertEq(res.ContentLengthText, "5497558138880", "ContentLengthText keeps Int64")
         me.AssertEqInt(res.ContentLength, 0, "ContentLength Integer overflows to 0")
         res.Free()
      End Sub

      Sub TestDownloadToFile()
         print("-- download to file")
         Dim transport As New MockTransport()
         transport.Enqueue(206, "HELLO", "Content-Range: bytes 0-4/10" & CHAR(13) & CHAR(10) & "Content-Type: application/octet-stream")
         transport.Enqueue(206, "WORLD", "Content-Range: bytes 5-9/10" & CHAR(13) & CHAR(10) & "Content-Type: application/octet-stream")
         Dim client As HttpClient = Http.FromTransport(transport)
         Dim dest As String = TPath.GetTempFileName()
         Dim options As New HttpDownloadOptions()
         options.DestinationPath = dest
         options.ChunkSizeBytes = 5
         options.TotalBytes = HttpRange.FromInteger(10)
         me._progressTicks = 0
         options.OnProgress = me.CountDownloadProgress
         Dim saved As String = HttpDownload.ToFile(client, "/file.bin", options)
         me.AssertEq(saved, dest, "download path")
         me.AssertEq(TFile.ReadAllText(dest), "HELLOWORLD", "ranged body")
         me.AssertTrue(me._progressTicks > 0, "download progress")
         me.AssertEqBool(client.WantText, True, "WantText restored")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         options.Free()
         client.Free()
      End Sub

      Sub RequestPauseOnProgress(pBytesSent As Int64, pTotalBytes As Int64)
         me._progressTicks = me._progressTicks + 1
         If Assigned(me._haltGate) Then
            me._haltGate.RequestPause()
         End If
      End Sub

      Sub TestDownloadPauseCancelResume()
         print("-- download pause cancel resume")
         Dim transport As New MockTransport()
         transport.Enqueue(206, "HELLO", "Content-Range: bytes 0-4/10" & CHAR(13) & CHAR(10) & "Content-Type: application/octet-stream")
         Dim client As HttpClient = Http.FromTransport(transport)
         Dim dest As String = TPath.GetTempFileName()
         Dim gate As New HttpTransferControl()
         me._haltGate = gate
         Dim options As New HttpDownloadOptions()
         options.DestinationPath = dest
         options.ChunkSizeBytes = 5
         options.TotalBytes = HttpRange.FromInteger(10)
         options.TransferControl = gate
         options.OnProgress = me.RequestPauseOnProgress
         Dim paused As Boolean = False
         Try
            HttpDownload.ToFile(client, "/file.bin", options)
         Catch ex As Exception
            paused = InStr(ex._GetMessage(), "paused") > 0
         End Try
         me._haltGate = Null
         me.AssertTrue(paused, "download pause throws")
         me.AssertTrue(gate.WasPaused(), "download was paused")
         me.AssertTrue(TFile.Exists(dest), "partial download kept")
         me.AssertEq(TFile.ReadAllText(dest), "HELLO", "paused body")
         transport.Enqueue(206, "WORLD", "Content-Range: bytes 5-9/10" & CHAR(13) & CHAR(10) & "Content-Type: application/octet-stream")
         options.ResumePartial = True
         options.OnProgress = Null
         options.TransferControl = Null
         HttpDownload.ToFile(client, "/file.bin", options)
         me.AssertEq(TFile.ReadAllText(dest), "HELLOWORLD", "resumed body")
         Dim cancelDest As String = TPath.GetTempFileName()
         TFile.WriteAllText(cancelDest, "partial")
         Dim cancelGate As New HttpTransferControl()
         cancelGate.RequestCancel()
         Dim cancelOptions As New HttpDownloadOptions()
         cancelOptions.DestinationPath = cancelDest
         cancelOptions.TransferControl = cancelGate
         Dim cancelled As Boolean = False
         Try
            HttpDownload.ToFile(client, "/file.bin", cancelOptions)
         Catch ex As Exception
            cancelled = InStr(ex._GetMessage(), "cancelled") > 0
         End Try
         me.AssertTrue(cancelled, "download cancel throws")
         me.AssertTrue(Not TFile.Exists(cancelDest), "partial download discarded")
         If TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         options.Free()
         gate.Free()
         cancelOptions.Free()
         cancelGate.Free()
         client.Free()
      End Sub

      Sub TestHttpFactories()
         print("-- factories")
         Dim mockClient As HttpClient = Http.Mock(200, "{}")
         me.AssertTrue(Assigned(mockClient), "Http.Mock")
         Dim factoryTransport As MockTransport = MockTransport(mockClient.Transport)
         me.AssertTrue(Assigned(factoryTransport), "Transport is Mock")
         mockClient.Free()
         Dim created As HttpClient = Http.FromTransport(New MockTransport(), "https://x")
         me.AssertEq(created.BaseUrl, "https://x", "Http.FromTransport baseUrl")
         created.Free()
      End Sub

      Sub PrintSummary()
         print("==== resultado: " + CStr(me.Passed) + " ok, " + CStr(me.Failed) + " fail ====")
         If me.Failed > 0 Then
            Dim i As Integer
            For i = 0 To me._failures.Count - 1
               print("  - " + me._failures.Strings(i))
            Next
            Throw New Exception("http tests failed: " + CStr(me.Failed))
         End If
      End Sub

      Sub Free()
         If Assigned(me._failures) Then
            me._failures.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
