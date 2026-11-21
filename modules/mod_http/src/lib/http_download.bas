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
         Dim destStream As Variant = Unassigned
         Dim parsedTotal As Int64 = HttpRange.Zero64()
         Dim streamKind As String = ""
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
         destStream = CreateObject("ADODB.Stream")
         destStream.Type = 1
         destStream.Open()
         If pOptions.ResumePartial And TFile.Exists(dest) Then
            destStream.LoadFromFile(dest)
            destStream.Position = destStream.Size
         End If
         Try
            If Not (sent < total) Then
               If total > HttpRange.Zero64() Then
                  If pOptions.OnProgress <> Null Then
                     pOptions.OnProgress(sent, total)
                  End If
                  destStream.SaveToFile(dest, 2)
                  destStream.Close()
                  destStream = Unassigned
                  pClient.WantText = savedWant
                  ' data7:disable-next-line shared-return-assignment-in-try
                  ToFile = dest
                  Exit Function
               End If
            End If
            While True
               HttpDownload.ApplyHalt(pOptions, pClient, savedWant, dest, destStream)
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
               HttpDownload.AppendPayload(destStream, response)
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
               HttpDownload.ApplyHalt(pOptions, pClient, savedWant, dest, destStream)
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
            destStream.SaveToFile(dest, 2)
            destStream.Close()
            destStream = Unassigned
            pClient.WantText = savedWant
         Catch ex As Exception
            If Assigned(response) Then
               response.Free()
            End If
            streamKind = TypeName(destStream)
            If (streamKind <> "Empty") And (streamKind <> "Null") And (streamKind <> "Unassigned") Then
               Try
                  destStream.Close()
               Catch closeEx As Exception
               End Try
               destStream = Unassigned
            End If
            pClient.WantText = savedWant
            Throw ex
         End Try
         ToFile = dest
      End Function

      Shared Sub AppendPayload(pDestStream As Variant, pResponse As HttpResponse)
         Dim payload As Variant
         Dim chunkBytes As Variant
         Dim textStream As Variant
         If Assigned(pResponse.Body) Then
            payload = pResponse.Body.Raw()
         Else
            payload = pResponse.Data.Raw()
         End If
         pDestStream.Position = pDestStream.Size
         If TypeName(payload) = "String" Then
            textStream = CreateObject("ADODB.Stream")
            textStream.Type = 2
            textStream.Charset = "iso-8859-1"
            textStream.Open()
            textStream.WriteText(payload)
            textStream.Position = 0
            textStream.Type = 1
            If textStream.Size > 0 Then
               chunkBytes = textStream.Read
               pDestStream.Write(chunkBytes)
            End If
            textStream.Close()
            textStream = Unassigned
         Else
            pDestStream.Write(payload)
         End If
      End Sub

      Shared Sub ApplyHalt(pOptions As HttpDownloadOptions, pClient As HttpClient, pSavedWant As Boolean, pDest As String, ByRef pDestStream As Variant)
         Dim gate As HttpTransferControl = Null
         If Not Assigned(pOptions) Then
            Exit Sub
         End If
         gate = pOptions.TransferControl
         If Not Assigned(gate) Then
            Exit Sub
         End If
         Forms.ProcessMessages()
         If gate.CancelRequested() Then
            gate.MarkCancelled()
            HttpDownload.CloseDestStream(pDestStream)
            If TFile.Exists(pDest) Then
               TFile.Delete(pDest)
            End If
            pClient.WantText = pSavedWant
            Throw New Exception(HttpDownload.CancelledMessage())
         End If
         If gate.PauseRequested() Then
            gate.MarkPaused()
            HttpDownload.FinishDestStream(pDest, pDestStream)
            pClient.WantText = pSavedWant
            Throw New Exception(HttpDownload.PausedMessage())
         End If
      End Sub

      Shared Sub FinishDestStream(pDest As String, ByRef pDestStream As Variant)
         Dim kind As String = TypeName(pDestStream)
         If (kind = "Empty") Or (kind = "Null") Or (kind = "Unassigned") Then
            Exit Sub
         End If
         pDestStream.SaveToFile(pDest, 2)
         HttpDownload.CloseDestStream(pDestStream)
      End Sub

      Shared Sub CloseDestStream(ByRef pDestStream As Variant)
         Dim kind As String = TypeName(pDestStream)
         If (kind = "Empty") Or (kind = "Null") Or (kind = "Unassigned") Then
            Exit Sub
         End If
         Try
            pDestStream.Close()
         Catch ex As Exception
         End Try
         pDestStream = Unassigned
      End Sub

      Shared Function PausedMessage() As String
         PausedMessage = "Download paused. Partial file was kept; call ToFile again with ResumePartial=True to continue."
      End Function

      Shared Function CancelledMessage() As String
         CancelledMessage = "Download cancelled. Partial file was discarded."
      End Function

      Shared Function LocalBytes(pPath As String) As Int64
         Dim stream As Variant
         If Not TFile.Exists(pPath) Then
            LocalBytes = HttpRange.Zero64()
            Exit Function
         End If
         stream = CreateObject("ADODB.Stream")
         stream.Type = 1
         stream.Open()
         stream.LoadFromFile(pPath)
         LocalBytes = HttpRange.ParseInt64(CStr(stream.Size))
         stream.Close()
         stream = Unassigned
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
