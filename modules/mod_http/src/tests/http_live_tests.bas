Imports http_client
Imports http_response

Namespace tests_live

   ' Suíte opcional com rede. Não entra em tests.THttpTest.RunAll().
   ' Chame tests_live.THttpLiveTest.RunAll() quando quiser validar WinHttp/CURL contra httpbin.

   Class THttpLiveTest
      Passed As Integer
      Failed As Integer

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
      End Sub

      Shared Sub RunAll()
         Dim suite As New THttpLiveTest()
         suite.Run()
         suite.Free()
      End Sub

      Sub Run()
         print("==== mod_http live ====")
         me.TestWinHttpGet()
         me.TestCurlGet()
         print("==== live: " + CStr(me.Passed) + " ok, " + CStr(me.Failed) + " fail ====")
         If me.Failed > 0 Then
            Throw New Exception("http live tests failed: " + CStr(me.Failed))
         End If
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            print("  OK    " + pMsg)
         Else
            me.Failed = me.Failed + 1
            print("  FAIL  " + pMsg)
         End If
      End Sub

      Sub TestWinHttpGet()
         print("-- winhttp httpbin")
         Dim client As HttpClient = Http.WinHttp()
         Dim res As HttpResponse = client.Gett("https://httpbin.org/get")
         me.AssertTrue(res.IsSuccessful, "WinHttp GET httpbin")
         me.AssertTrue(res.Body.AsText.Contains("httpbin"), "WinHttp body mentions httpbin")
         res.Free()
         client.Free()
      End Sub

      Sub TestCurlGet()
         print("-- curl httpbin")
         Dim client As HttpClient = Http.Curl()
         Dim res As HttpResponse = client.Gett("https://httpbin.org/get")
         me.AssertTrue(res.IsSuccessful, "Curl GET httpbin")
         me.AssertTrue(res.Body.AsText.Contains("httpbin"), "Curl body mentions httpbin")
         res.Free()
         client.Free()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
