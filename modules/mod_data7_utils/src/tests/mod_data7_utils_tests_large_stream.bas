Imports Collections
Imports IO
Imports mod_data7_utils_stream
Imports mod_data7_utils_stream_enums
Imports mod_data7_utils_int64
Imports mod_data7_utils_file_stream
Imports mod_data7_utils_memory_stream

Namespace mod_data7_utils_tests_large_stream

   ' 64 KiB chunks * 512 = 32 MiB. Big enough that ReadAll/ToArray/MemoryStream
   ' would dominate RAM; small enough for a DevStudio run.
   Const LargeChunkBytes = 65536
   Const LargeChunkCount = 512

   ' 1 MiB chunks * 3072 = 3 GiB. Crosses the 2 GiB Data7 Long limit.
   Const GbChunkBytes = 1048576
   Const GbChunkCount = 3072
   Const GbMemSampleEvery = 768
   Const GbMemLimitMiB = 128

   Class TLargeStreamTests

      Passed As Integer
      Failed As Integer
      Private _failures As StringList
      Private _tempDir As String
      Private _sourcePath As String
      Private _copyPath As String
      Private _chunk As String
      Private _expectedSize As Int64
      Private _gbSourcePath As String
      Private _gbCopyPath As String
      Private _gbPayload As Variant
      Private _gbExpectedSize As Int64
      Private _memStart As Long
      Private _memPeak As Long

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
         me._tempDir = ""
         me._sourcePath = ""
         me._copyPath = ""
         me._chunk = ""
         me._expectedSize = UtilsZero64()
         me._gbSourcePath = ""
         me._gbCopyPath = ""
         me._gbPayload = Unassigned
         me._gbExpectedSize = UtilsZero64()
         me._memStart = 0
         me._memPeak = 0
      End Sub

      Sub Run(pTempDir As String)
         print("-- large file stream (32 MiB, 64 KiB chunks, no ReadAll)")
         me._tempDir = pTempDir
         me._sourcePath = pTempDir & "\large-source.bin"
         me._copyPath = pTempDir & "\large-copy.bin"
         me._chunk = "".StringOfChar("A", LargeChunkBytes)
         me._expectedSize = UtilsParseInt64(CStr(LargeChunkBytes * LargeChunkCount))
         me.TestDownloadWriteChunks()
         me.TestUploadReadChunks()
         me.TestUploadBinaryReadChunks()
         me.TestCopyToFileToFile()
         me.TestSeekRangeRead()
         me.CleanupLargeFiles()
      End Sub

      Sub RunThreeGb(pTempDir As String)
         Dim chunkSize As Int64
         Dim chunkCount As Int64
         print("-- 3 GiB file stream (1 MiB chunks, working-set samples)")
         print("  note  writes ~6 GiB to temp; Size must stay Int64 past 2 GiB")
         me._tempDir = pTempDir
         me._gbSourcePath = pTempDir & "\gb-source.bin"
         me._gbCopyPath = pTempDir & "\gb-copy.bin"
         chunkSize = UtilsFromInteger(GbChunkBytes)
         chunkCount = UtilsFromInteger(GbChunkCount)
         me._gbExpectedSize = chunkSize * chunkCount
         me.PrepareGbPayload()
         me._memStart = me.CurrentWorkingSet()
         me._memPeak = me._memStart
         me.SampleMem("start")
         me.TestGbDownloadWriteChunks()
         me.TestGbUploadBinaryReadChunks()
         me.TestGbCopyToFileToFile()
         me.TestGbSeekLastChunk()
         me.AssertWorkingSetStable()
         me.CleanupGbFiles()
         me._gbPayload = Unassigned
         me.SampleMem("after cleanup")
      End Sub

      Function FailureText() As String
         FailureText = me._failures.Text
      End Function

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

      Sub Free()
         If me._failures <> NULL Then
            me._failures.Free()
         End If
         MyBase.Free()
      End Sub

      Private Sub TestDownloadWriteChunks()
         Dim writer As TFileStream = New TFileStream()
         Dim i As Integer
         writer.StreamKind = TUtilsStreamKind.Text
         writer.Charset = TUtilsCharset.ASCII
         writer.Open(me._sourcePath, TUtilsFileMode.CreateFile, TUtilsFileAccess.Write)
         For i = 1 To LargeChunkCount
            writer.WriteText(me._chunk)
         Next
         writer.Flush()
         writer.Free()
         me.AssertTrue(IO.File.Exists(me._sourcePath), "download write created file")
      End Sub

      Private Sub TestUploadReadChunks()
         Dim reader As TFileStream = New TFileStream()
         Dim piece As String
         Dim totalRead As Int64
         Dim mismatch As Boolean
         Dim reads As Integer
         totalRead = UtilsZero64()
         mismatch = False
         reads = 0
         reader.StreamKind = TUtilsStreamKind.Text
         reader.Charset = TUtilsCharset.ASCII
         reader.Open(me._sourcePath)
         me.AssertTrue(reader.Size = me._expectedSize, "upload source size 32 MiB (obtido=" + UtilsInt64Text(reader.Size) + ")")
         While Not reader.EOF
            piece = reader.ReadText(LargeChunkBytes)
            reads = reads + 1
            totalRead = totalRead + UtilsFromInteger(piece.Length)
            If piece <> me._chunk Then
               mismatch = True
            End If
         End While
         reader.Free()
         me.AssertTrue(reads = LargeChunkCount, "upload read 512 chunks (obtido=" + CStr(reads) + ")")
         me.AssertTrue(totalRead = me._expectedSize, "upload bytes equal size (obtido=" + UtilsInt64Text(totalRead) + ")")
         me.AssertTrue(Not mismatch, "upload every chunk matches pattern")
      End Sub

      Private Sub TestUploadBinaryReadChunks()
         Dim reader As TFileStream = New TFileStream()
         Dim buf As Variant
         Dim totalRead As Int64
         Dim n As Integer
         Dim reads As Integer
         totalRead = UtilsZero64()
         reads = 0
         reader.Open(me._sourcePath)
         While Not reader.EOF
            buf = reader.Read(LargeChunkBytes)
            reads = reads + 1
            n = UBound(buf) - LBound(buf) + 1
            totalRead = totalRead + UtilsFromInteger(n)
            buf = Unassigned
         End While
         reader.Free()
         me.AssertTrue(reads = LargeChunkCount, "binary upload 512 chunks (obtido=" + CStr(reads) + ")")
         me.AssertTrue(totalRead = me._expectedSize, "binary upload bytes equal size (obtido=" + UtilsInt64Text(totalRead) + ")")
      End Sub

      Private Sub TestCopyToFileToFile()
         Dim sourceFile As TFileStream = New TFileStream()
         Dim destFile As TFileStream = New TFileStream()
         sourceFile.Open(me._sourcePath)
         destFile.Open(me._copyPath, TUtilsFileMode.CreateFile, TUtilsFileAccess.Write)
         sourceFile.CopyTo(destFile, LargeChunkBytes)
         destFile.Free()
         sourceFile.Free()
         me.AssertTrue(IO.File.Exists(me._copyPath), "copyto dest created")

         Dim verifyFile As TFileStream = New TFileStream()
         verifyFile.Open(me._copyPath)
         me.AssertTrue(verifyFile.Size = me._expectedSize, "copyto dest size 32 MiB (obtido=" + UtilsInt64Text(verifyFile.Size) + ")")
         verifyFile.Free()
      End Sub

      Private Sub TestSeekRangeRead()
         Dim reader As TFileStream = New TFileStream()
         Dim piece As String
         reader.StreamKind = TUtilsStreamKind.Text
         reader.Charset = TUtilsCharset.ASCII
         reader.Open(me._copyPath)
         reader.Seek(UtilsFromInteger(LargeChunkBytes * 100), TUtilsSeekOrigin.Begin)
         piece = reader.ReadText(LargeChunkBytes)
         me.AssertTrue(piece = me._chunk, "range read middle chunk")
         reader.Seek(me._expectedSize - UtilsFromInteger(LargeChunkBytes), TUtilsSeekOrigin.Begin)
         piece = reader.ReadText(LargeChunkBytes)
         me.AssertTrue(piece = me._chunk, "range read last chunk")
         me.AssertTrue(reader.EOF, "eof after last chunk")
         reader.Free()
      End Sub

      Private Sub PrepareGbPayload()
         Dim seed As TMemoryStream = New TMemoryStream()
         seed.StreamKind = TUtilsStreamKind.Text
         seed.Charset = TUtilsCharset.ASCII
         seed.Open()
         seed.WriteText("".StringOfChar("B", GbChunkBytes))
         me._gbPayload = seed.ToArray()
         seed.Free()
      End Sub

      Private Sub TestGbDownloadWriteChunks()
         Dim writer As TFileStream = New TFileStream()
         Dim i As Integer
         writer.Open(me._gbSourcePath, TUtilsFileMode.CreateFile, TUtilsFileAccess.Write)
         For i = 1 To GbChunkCount
            writer.Write(me._gbPayload)
            If (i Mod GbMemSampleEvery) = 0 Then
               me.SampleMem("write " + CStr(i * 100 / GbChunkCount) + "%")
            End If
         Next
         writer.Flush()
         writer.Free()
         me.AssertTrue(IO.File.Exists(me._gbSourcePath), "3 GiB download write created file")
         Dim checkFile As TFileStream = New TFileStream()
         checkFile.Open(me._gbSourcePath)
         me.AssertTrue(checkFile.Size = me._gbExpectedSize, "3 GiB source size (obtido=" + UtilsInt64Text(checkFile.Size) + ")")
         checkFile.Free()
      End Sub

      Private Sub TestGbUploadBinaryReadChunks()
         Dim reader As TFileStream = New TFileStream()
         Dim buf As Variant
         Dim totalRead As Int64
         Dim n As Integer
         Dim reads As Integer
         totalRead = UtilsZero64()
         reads = 0
         reader.Open(me._gbSourcePath)
         While Not reader.EOF
            buf = reader.Read(GbChunkBytes)
            reads = reads + 1
            n = UBound(buf) - LBound(buf) + 1
            totalRead = totalRead + UtilsFromInteger(n)
            buf = Unassigned
            If (reads Mod GbMemSampleEvery) = 0 Then
               me.SampleMem("read " + CStr(reads * 100 / GbChunkCount) + "%")
            End If
         End While
         reader.Free()
         me.AssertTrue(reads = GbChunkCount, "3 GiB binary read 3072 chunks (obtido=" + CStr(reads) + ")")
         me.AssertTrue(totalRead = me._gbExpectedSize, "3 GiB binary bytes equal size (obtido=" + UtilsInt64Text(totalRead) + ")")
      End Sub

      Private Sub TestGbCopyToFileToFile()
         Dim sourceFile As TFileStream = New TFileStream()
         Dim destFile As TFileStream = New TFileStream()
         sourceFile.Open(me._gbSourcePath)
         destFile.Open(me._gbCopyPath, TUtilsFileMode.CreateFile, TUtilsFileAccess.Write)
         sourceFile.CopyTo(destFile, GbChunkBytes)
         destFile.Free()
         sourceFile.Free()
         me.SampleMem("copyto done")
         me.AssertTrue(IO.File.Exists(me._gbCopyPath), "3 GiB copyto dest created")
         Dim verifyFile As TFileStream = New TFileStream()
         verifyFile.Open(me._gbCopyPath)
         me.AssertTrue(verifyFile.Size = me._gbExpectedSize, "3 GiB copyto dest size (obtido=" + UtilsInt64Text(verifyFile.Size) + ")")
         verifyFile.Free()
      End Sub

      Private Sub TestGbSeekLastChunk()
         Dim reader As TFileStream = New TFileStream()
         Dim buf As Variant
         Dim n As Integer
         reader.Open(me._gbCopyPath)
         reader.Seek(me._gbExpectedSize - UtilsFromInteger(GbChunkBytes), TUtilsSeekOrigin.Begin)
         buf = reader.Read(GbChunkBytes)
         n = UBound(buf) - LBound(buf) + 1
         buf = Unassigned
         me.AssertTrue(n = GbChunkBytes, "3 GiB last chunk size (obtido=" + CStr(n) + ")")
         me.AssertTrue(reader.EOF, "3 GiB eof after last chunk")
         reader.Free()
      End Sub

      Private Sub AssertWorkingSetStable()
         Dim delta As Long
         delta = me._memPeak - me._memStart
         If Not (me._memStart > 0) Then
            print("  skip  working set (WMI unavailable)")
            Exit Sub
         End If
         me.AssertTrue(Not (delta > GbMemLimitMiB), "working set delta under 128 MiB (peak-start=" + CStr(delta) + " MiB)")
      End Sub

      Private Sub SampleMem(pLabel As String)
         Dim ws As Long
         ws = me.CurrentWorkingSet()
         If ws > me._memPeak Then
            me._memPeak = ws
         End If
         print("  mem   " + pLabel + "  " + CStr(ws) + " MiB")
      End Sub

      Private Function GetWMIService() As Variant
         Dim locator As Variant = CreateObject("WbemScripting.SWbemLocator")
         Dim svc As Variant = locator.ConnectServer("localhost", "root\CIMV2", "", "")
         GetWMIService = svc
         locator = ""
      End Function

      Private Function CurrentWorkingSet() As Long
         Dim ws As Long
         Dim svc As Variant
         Dim procs As Variant
         Dim i As Integer
         Dim procRow As Variant
         Dim exePath As String
         Dim exeName As String
         Dim path As String
         ws = 0
         exePath = Data7.NomeArquivoExecutavel()
         exeName = IO.File.ExtractName(exePath)
         If exeName = "" Then
            CurrentWorkingSet = 0
            Exit Function
         End If
         Try
            svc = me.GetWMIService()
            procs = svc.ExecQuery("SELECT ExecutablePath, WorkingSetSize FROM Win32_Process WHERE Name='" + exeName + "'")
            For i = 0 To procs.Count - 1
               procRow = procs.ItemIndex(i)
               path = procRow.ExecutablePath
               If path <> "" Then
                  If path.ToLower() = exePath.ToLower() Then
                     ws = CLng(procRow.WorkingSetSize) / 1048576
                  End If
               End If
            Next
         Catch ex As Exception
            ws = 0
         End Try
         procs = ""
         svc = ""
         CurrentWorkingSet = ws
      End Function

      Private Sub CleanupGbFiles()
         If me._gbSourcePath <> "" Then
            If IO.File.Exists(me._gbSourcePath) Then
               IO.File.Delete(me._gbSourcePath)
            End If
         End If
         If me._gbCopyPath <> "" Then
            If IO.File.Exists(me._gbCopyPath) Then
               IO.File.Delete(me._gbCopyPath)
            End If
         End If
      End Sub

      Private Sub CleanupLargeFiles()
         If IO.File.Exists(me._sourcePath) Then
            IO.File.Delete(me._sourcePath)
         End If
         If IO.File.Exists(me._copyPath) Then
            IO.File.Delete(me._copyPath)
         End If
      End Sub

   End Class

End Namespace
