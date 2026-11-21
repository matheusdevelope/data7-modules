Imports Collections
Imports IO
Imports mod_data7_utils_runtime
Imports mod_data7_utils_payload
Imports mod_data7_utils_stream
Imports mod_data7_utils_stream_enums
Imports mod_data7_utils_int64
Imports mod_data7_utils_file_stream
Imports mod_data7_utils_memory_stream
Imports mod_data7_utils_socket
Imports mod_data7_utils_tests_large_stream

Namespace mod_data7_utils_tests

   Class TData7UtilsTests

      Passed As Integer
      Failed As Integer
      Private _failures As StringList
      Private _tempDir As String
      Private _fixturePath As String

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
         me._tempDir = ""
         me._fixturePath = ""
      End Sub

      Shared Sub RunAll()
         Dim suite As New TData7UtilsTests()
         suite.Run()
         suite.Free()
      End Sub

      Sub Run()
         print("==== mod_data7_utils ====")
         me.PrepareTemp()
         me.TestRuntimeExtract()
         me.TestMemoryStream()
         me.TestFileStreamAndCopyTo()
         me.TestLargeFileStreams()
         me.TestThreeGbFileStreams()
         me.TestSocketIdle()
         me.PrintSummary()
         me.CleanupTemp()
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

      Sub TestRuntimeExtract()
         print("-- runtime")
         TComRuntime.EnsureExtracted()
         me.AssertTrue(IO.File.Exists(DllPath()), "dll extracted")
         me.AssertTrue(IO.File.Exists(ManifestPath()), "manifest extracted")
         me.AssertTrue(IO.File.Exists(HostDir() & "\Data7Utils.dll"), "dll next to host")
         me.AssertTrue(IO.File.Exists(HostDir() & "\Data7Utils.dll.manifest"), "manifest next to host")
         me.AssertTrue(InStr(RuntimeDir(), "data7utils") > 0, "runtime dir versioned")
         me.AssertEq(PayloadVersion, "1.0.0.1", "payload version")
      End Sub

      Sub TestMemoryStream()
         print("-- memory stream")
         Dim mem As TMemoryStream = New TMemoryStream()
         mem.StreamKind = TUtilsStreamKind.Text
         mem.Charset = TUtilsCharset.UTF8
         mem.Open()
         mem.WriteText("hello-data7")
         me.AssertTrue(mem.Size > UtilsZero64(), "memory size after write")
         me.AssertEqBool(mem.EOF, True, "eof after write")
         mem.Seek(UtilsZero64(), TUtilsSeekOrigin.Begin)
         me.AssertEq(mem.ReadTextAll(), "hello-data7", "read all text")
         me.AssertTrue(Not IsEmpty(mem.ToArray()), "to array")
         mem.SaveToFile(me._fixturePath)
         me.AssertTrue(IO.File.Exists(me._fixturePath), "save fixture")
         mem.Free()
      End Sub

      Sub TestFileStreamAndCopyTo()
         print("-- file stream")
         Dim fileStream As TFileStream = New TFileStream()
         Dim mem As TMemoryStream = New TMemoryStream()
         fileStream.Open(me._fixturePath)
         me.AssertTrue(fileStream.Size > UtilsZero64(), "file size")
         mem.Open()
         fileStream.CopyTo(mem)
         me.AssertTrue(mem.Size > UtilsZero64(), "copyto size")
         fileStream.Free()
         mem.Free()
      End Sub

      Sub TestLargeFileStreams()
         Dim large As TLargeStreamTests = New TLargeStreamTests()
         large.Run(me._tempDir)
         me.Passed = me.Passed + large.Passed
         me.Failed = me.Failed + large.Failed
         If large.Failed > 0 Then
            me._failures.Add(large.FailureText())
         End If
         large.Free()
      End Sub

      Sub TestThreeGbFileStreams()
         Dim gb As TLargeStreamTests = New TLargeStreamTests()
         gb.RunThreeGb(me._tempDir)
         me.Passed = me.Passed + gb.Passed
         me.Failed = me.Failed + gb.Failed
         If gb.Failed > 0 Then
            me._failures.Add(gb.FailureText())
         End If
         gb.Free()
      End Sub

      Sub TestSocketIdle()
         print("-- socket idle")
         Dim client As TSocketClient = New TSocketClient()
         me.AssertEqBool(client.Connected, False, "idle connected")
         me.AssertEqBool(client.HasEvents(), False, "idle has events")
         client.Free()
      End Sub

      Sub PrintSummary()
         print("----")
         print("Passed: " + CStr(me.Passed) + "  Failed: " + CStr(me.Failed))
         If me.Failed > 0 Then
            print(me._failures.Text)
         End If
      End Sub

      Sub Free()
         If me._failures <> NULL Then
            me._failures.Free()
         End If
         MyBase.Free()
      End Sub

      Private Sub PrepareTemp()
         Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
         me._tempDir = fso.GetSpecialFolder(2).Path & "\mod_data7_utils_tests"
         If Not fso.FolderExists(me._tempDir) Then
            fso.CreateFolder(me._tempDir)
         End If
         me._fixturePath = me._tempDir & "\fixture.txt"
         fso = Unassigned
      End Sub

      Private Sub CleanupTemp()
         If me._fixturePath <> "" Then
            If IO.File.Exists(me._fixturePath) Then
               IO.File.Delete(me._fixturePath)
            End If
         End If
      End Sub

   End Class

End Namespace
