Imports Forms
Imports TFile
Imports TPath
Imports TDirectory
Imports http_client
Imports http_enums
Imports http_headers
Imports http_response
Imports http_download_options
Imports http_range
Imports http_transfer_control
Imports http_file_io
Imports mod_data7_utils_file_stream
Imports mod_tobject

Namespace http_download

   Class HttpDownload
      Inherits TTObject

      Shared Function ToFile(pClient As HttpClient, pEndpoint As String, pOptions As HttpDownloadOptions) As String
         Dim dest As String = ""
         Dim folder As String = ""
         Dim chunkSize As Integer = 0
         Dim total As Int64 = HttpRange.Zero64()
         Dim sent As Int64 = HttpRange.Zero64()
         Dim remaining As Int64 = HttpRange.Zero64()
         Dim take As Integer = 0
         Dim endInclusive As Int64 = HttpRange.Zero64()
         Dim extra As HttpHeaders = Null
         Dim response As HttpResponse = Null
         Dim savedWant As Boolean = True
         Dim destFile As TFileStream = Null
         Dim parsedTotal As Int64 = HttpRange.Zero64()
         If Not Assigned(pClient) Then
            Throw New Exception("HttpDownload.ToFile requires an HttpClient.")
         End If
         If Not Assigned(pOptions) Then
            Throw New Exception("HttpDownload.ToFile requires HttpDownloadOptions.")
         End If
         dest = Trim(pOptions.DestinationPath)
         If dest = "" Then
            Throw New Exception("Download destination path is required.")
         End If
         folder = TPath.GetDirectoryName(dest)
         If (folder <> "") And (Not TDirectory.Exists(folder)) Then
            TDirectory.CreateDirectory(folder)
         End If
         chunkSize = pOptions.ChunkSizeBytes
         If chunkSize <= 0 Then
            chunkSize = HttpRange.DefaultChunkBytes()
         End If
         total = pOptions.TotalBytes
         If pOptions.ResumePartial And TFile.Exists(dest) Then
            sent = HttpDownload.LocalBytes(dest)
         ElseIf TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         savedWant = pClient.WantText
         pClient.WantText = False
         destFile = HttpFileIo.OpenForWrite(dest, pOptions.ResumePartial And TFile.Exists(dest))
         Dim alreadyDone As Boolean = False
         Try
            If Not (sent < total) Then
               If total > HttpRange.Zero64() Then
                  If pOptions.OnProgress <> Null Then
                     pOptions.OnProgress(sent, total)
                  End If
                  alreadyDone = True
               End If
            End If
            If Not alreadyDone Then
            While True
               HttpDownload.ApplyHalt(pOptions, pClient, savedWant, dest, destFile)
               If (total > HttpRange.Zero64()) And (Not (sent < total)) Then
                  Exit While
               End If
               If total > HttpRange.Zero64() Then
                  remaining = total - sent
                  take = HttpRange.ChunkTake(remaining, chunkSize)
               Else
                  take = chunkSize
               End If
               endInclusive = sent + take - 1
               extra = New HttpHeaders()
               extra.Define("Range", HttpRange.Download(sent, endInclusive))
               response = pClient.Request(HttpMethod.Gett(), pEndpoint, extra)
               extra.Free()
               extra = Null
               If Assigned(response.Headers) Then
                  If response.Headers.Has("Content-Range") Then
                     parsedTotal = HttpRange.ParseTotal(response.Headers.Value("Content-Range"))
                     If parsedTotal >= HttpRange.Zero64() Then
                        total = parsedTotal
                     End If
                  ElseIf (total <= HttpRange.Zero64()) And response.Headers.Has("Content-Length") Then
                     total = HttpRange.ParseInt64(response.Headers.Value("Content-Length"))
                  End If
               End If
               HttpDownload.AppendPayload(destFile, response)
               If total > HttpRange.Zero64() Then
                  sent = endInclusive + 1
                  If sent > total Then
                     sent = total
                  End If
               Else
                  sent = sent + take
               End If
               If pOptions.OnProgress <> Null Then
                  pOptions.OnProgress(sent, total)
               End If
               HttpDownload.ApplyHalt(pOptions, pClient, savedWant, dest, destFile)
               If response.Status = 200 Then
                  response.Free()
                  response = Null
                  Exit While
               End If
               response.Free()
               response = Null
               If total <= HttpRange.Zero64() Then
                  Exit While
               End If
               If Not (sent < total) Then
                  Exit While
               End If
            End While
            End If
            HttpFileIo.Release(destFile)
            pClient.WantText = savedWant
         Catch ex As Exception
            If Assigned(response) Then
               response.Free()
            End If
            HttpFileIo.Release(destFile)
            pClient.WantText = savedWant
            Throw ex
         End Try
         ToFile = dest
      End Function

      Shared Sub AppendPayload(pDestFile As TFileStream, pResponse As HttpResponse)
         Dim payload As Variant
         If Assigned(pResponse.Body) Then
            payload = pResponse.Body.Raw()
         Else
            payload = pResponse.Data.Raw()
         End If
         HttpFileIo.WritePayload(pDestFile, payload)
         payload = Unassigned
      End Sub

      Shared Sub ApplyHalt(pOptions As HttpDownloadOptions, pClient As HttpClient, pSavedWant As Boolean, pDest As String, ByRef pDestFile As TFileStream)
         Dim gate As HttpTransferControl = Null
         If Not Assigned(pOptions) Then
            Exit Sub
         End If
         gate = pOptions.TransferControl
         If Not Assigned(gate) Then
            Exit Sub
         End If
         HttpDownload.HonorHalt(gate, pClient, pSavedWant, pDest, pDestFile)
         Try
            Forms.ProcessMessages()
         Catch pumpEx As Exception
         End Try
         HttpDownload.HonorHalt(gate, pClient, pSavedWant, pDest, pDestFile)
      End Sub

      Shared Sub HonorHalt(pGate As HttpTransferControl, pClient As HttpClient, pSavedWant As Boolean, pDest As String, ByRef pDestFile As TFileStream)
         If pGate.CancelRequested() Then
            pGate.MarkCancelled()
            HttpFileIo.Release(pDestFile)
            If TFile.Exists(pDest) Then
               TFile.Delete(pDest)
            End If
            pClient.WantText = pSavedWant
            Throw New Exception(HttpDownload.CancelledMessage())
         End If
         If pGate.PauseRequested() Then
            pGate.MarkPaused()
            HttpFileIo.Release(pDestFile)
            pClient.WantText = pSavedWant
            Throw New Exception(HttpDownload.PausedMessage())
         End If
      End Sub

      Shared Function PausedMessage() As String
         PausedMessage = "Download paused. Partial file was kept; call ToFile again with ResumePartial=True to continue."
      End Function

      Shared Function CancelledMessage() As String
         CancelledMessage = "Download cancelled. Partial file was discarded."
      End Function

      Shared Function LocalBytes(pPath As String) As Int64
         LocalBytes = HttpFileIo.SizeOf(pPath)
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
