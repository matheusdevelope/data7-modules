Imports Forms
Imports TFile
Imports TPath
Imports TDirectory
Imports http_enums
Imports http_headers
Imports http_response
Imports http_file_io
Imports mod_tobject
Imports mod_data7_utils_file_stream
Imports google_drive_http
Imports google_drive_config
Imports google_drive_endpoints
Imports google_drive_file
Imports google_drive_download_options
Imports google_drive_upload_control
Imports google_drive_errors
Imports google_drive_json

Namespace google_drive_downloader

   Class GoogleDriveDownloader
      Inherits TTObject

      Private _http As GoogleDriveHttp
      Private _config As GoogleDriveConfig
      Private _endpoints As GoogleDriveEndpoints

      Sub New(pHttp As GoogleDriveHttp)
         MyBase.New()
         If Not Assigned(pHttp) Then
            Throw New Exception(GoogleDriveErrors.HttpRequired())
         End If
         me._http = pHttp
         me._config = pHttp.Config()
         me._endpoints = pHttp.Endpoints()
      End Sub

      Function Download(pDriveFile As GoogleDriveFile, pOptions As GoogleDriveDownloadOptions) As String
         If Not Assigned(pDriveFile) Then
            Throw New Exception(GoogleDriveErrors.FileIdRequired())
         End If
         If Trim(pDriveFile.Id) = "" Then
            Throw New Exception(GoogleDriveErrors.FileIdRequired())
         End If
         If Not Assigned(pOptions) Then
            Throw New Exception(GoogleDriveErrors.DownloadPathRequired())
         End If
         If Trim(pOptions.DestinationPath) = "" Then
            Throw New Exception(GoogleDriveErrors.DownloadPathRequired())
         End If
         Dim dest As String = pOptions.DestinationPath
         Dim folder As String = TPath.GetDirectoryName(dest)
         If (folder <> "") And (Not TDirectory.Exists(folder)) Then
            TDirectory.CreateDirectory(folder)
         End If
         Dim total As Int64 = pDriveFile.SizeBytes
         Dim maxChunk As Integer = GoogleDriveJson.CapDownloadChunkBytes(me._config.ChunkSizeBytes, GoogleDriveJson.MaxDownloadChunkBytes())
         Dim chunkSize As Integer = me.ResolveChunkSize(pOptions)
         Dim sent As Int64 = GoogleDriveJson.Zero64()
         Dim remaining As Int64 = GoogleDriveJson.Zero64()
         Dim take As Integer = 0
         Dim endInclusive As Int64 = GoogleDriveJson.Zero64()
         Dim destFile As TFileStream = Null
         Dim getStarted As TDateTime
         Dim getEnded As TDateTime
         Dim elapsedSec As Integer = 0
         Dim getFailed As Boolean = False
         Dim previousChunk As Integer = 0
         Dim getErr As String = ""
         If pOptions.ResumePartial And TFile.Exists(dest) Then
            sent = me.LocalBytes(dest)
         ElseIf TFile.Exists(dest) Then
            TFile.Delete(dest)
         End If
         me.ApplyHalt(pOptions, dest, destFile)
         If Not (total > GoogleDriveJson.Zero64()) Then
            me.DownloadOnce(pDriveFile.Id, dest)
            me.Notify(pOptions, GoogleDriveJson.Zero64(), GoogleDriveJson.Zero64())
            Download = dest
            Exit Function
         End If
         If Not (sent < total) Then
            me.Notify(pOptions, sent, total)
            Download = dest
            Exit Function
         End If
         destFile = HttpFileIo.OpenForWrite(dest, pOptions.ResumePartial And TFile.Exists(dest))
         Try
            While sent < total
               me.ApplyHalt(pOptions, dest, destFile)
               remaining = total - sent
               take = GoogleDriveJson.ChunkTake(remaining, chunkSize)
               endInclusive = sent + take - 1
               getStarted = DateTime()
               getFailed = False
               getErr = ""
               Try
                  me.DownloadRange(pDriveFile.Id, destFile, sent, endInclusive)
               Catch getEx As Exception
                  getFailed = True
                  getErr = getEx._GetMessage()
               End Try
               If getFailed Then
                  previousChunk = chunkSize
                  If GoogleDriveJson.IsMemoryError(getErr) Then
                     chunkSize = GoogleDriveJson.ShrinkChunkBytes(chunkSize)
                     If chunkSize < previousChunk Then
                        maxChunk = chunkSize
                     End If
                  End If
                  If (Not GoogleDriveJson.IsMemoryError(getErr)) Or (chunkSize >= previousChunk) Then
                     Throw New Exception(getErr)
                  End If
               Else
                  getEnded = DateTime()
                  sent = endInclusive + 1
                  me.Notify(pOptions, sent, total)
                  If me._config.AdaptiveChunkSize Then
                     elapsedSec = GoogleDriveJson.ElapsedSeconds(getStarted, getEnded)
                     If elapsedSec < 5 Then
                        chunkSize = GoogleDriveJson.GrowChunkBytes(chunkSize, maxChunk)
                     ElseIf elapsedSec > 20 Then
                        chunkSize = GoogleDriveJson.ShrinkChunkBytes(chunkSize)
                     End If
                  End If
               End If
            End While
            HttpFileIo.Release(destFile)
         Catch ex As Exception
            HttpFileIo.Release(destFile)
            Throw ex
         End Try
         Download = dest
      End Function

      Function Export(pFileId As String, pDest As String, pExportMime As String, pOptions As GoogleDriveDownloadOptions) As String
         If Trim(pFileId) = "" Then
            Throw New Exception(GoogleDriveErrors.FileIdRequired())
         End If
         If Trim(pDest) = "" Then
            Throw New Exception(GoogleDriveErrors.DownloadPathRequired())
         End If
         If Trim(pExportMime) = "" Then
            Throw New Exception(GoogleDriveErrors.ExportMimeRequired())
         End If
         Dim folder As String = TPath.GetDirectoryName(pDest)
         If (folder <> "") And (Not TDirectory.Exists(folder)) Then
            TDirectory.CreateDirectory(folder)
         End If
         If TFile.Exists(pDest) Then
            TFile.Delete(pDest)
         End If
         Dim unusedFile As TFileStream = Null
         If Assigned(pOptions) Then
            me.ApplyHalt(pOptions, pDest, unusedFile)
         End If
         Dim query As New HttpParams()
         query.Define("mimeType", Trim(pExportMime))
         me.ApplyDriveFlags(query)
         Dim url As String = me._endpoints.WithQuery(me._endpoints.FileExportPath(pFileId), query)
         query.Free()
         Dim response As HttpResponse = me._http.Send(HttpMethod.Gett(), url, Null, Null, False)
         If Not response.IsSuccessful Then
            me._http.ThrowFailed(response)
         End If
         me.WriteBody(pDest, response, False)
         response.Free()
         If Assigned(pOptions) Then
            me.Notify(pOptions, GoogleDriveJson.Zero64(), GoogleDriveJson.Zero64())
         End If
         Export = pDest
      End Function

      Function ResolveChunkSize(pOptions As GoogleDriveDownloadOptions) As Integer
         Dim maxChunk As Integer = GoogleDriveJson.CapDownloadChunkBytes(me._config.ChunkSizeBytes, GoogleDriveJson.MaxDownloadChunkBytes())
         Dim requested As Integer = 0
         If maxChunk <= 0 Then
            maxChunk = GoogleDriveJson.MaxDownloadChunkBytes()
         End If
         If Assigned(pOptions) Then
            requested = pOptions.ChunkSizeBytes
         End If
         If requested <= 0 Then
            requested = maxChunk
         End If
         If requested = GoogleDriveJson.DefaultChunkBytes() Then
            requested = maxChunk
         End If
         If requested < GoogleDriveJson.MinChunkBytes() Then
            ResolveChunkSize = requested
            Exit Function
         End If
         If me._config.AdaptiveChunkSize Then
            ResolveChunkSize = GoogleDriveJson.AlignChunkBytes(GoogleDriveJson.DefaultChunkBytes(), maxChunk)
            Exit Function
         End If
         If requested < maxChunk Then
            ResolveChunkSize = GoogleDriveJson.AlignChunkBytes(requested, maxChunk)
         Else
            ResolveChunkSize = GoogleDriveJson.AlignChunkBytes(maxChunk, maxChunk)
         End If
      End Function

      Sub DownloadOnce(pFileId As String, pDest As String)
         Dim query As New HttpParams()
         query.Define("alt", "media")
         me.ApplyDriveFlags(query)
         Dim url As String = me._endpoints.WithQuery(me._endpoints.FilePath(pFileId), query)
         query.Free()
         Dim response As HttpResponse = me._http.Send(HttpMethod.Gett(), url, Null, Null, False)
         If Not response.IsSuccessful Then
            me._http.ThrowFailed(response)
         End If
         me.WriteBody(pDest, response, False)
         response.Free()
      End Sub

      Sub DownloadRange(pFileId As String, pDestFile As TFileStream, pStart As Int64, pEndInclusive As Int64)
         Dim query As New HttpParams()
         query.Define("alt", "media")
         me.ApplyDriveFlags(query)
         Dim url As String = me._endpoints.WithQuery(me._endpoints.FilePath(pFileId), query)
         query.Free()
         Dim rangeSpec As String = GoogleDriveJson.BuildDownloadRange(pStart, pEndInclusive)
         Dim extra As New HttpHeaders()
         extra.Define("Range", rangeSpec)
         Dim response As HttpResponse = Null
         Try
            response = me._http.Send(HttpMethod.Gett(), url, Null, extra, False)
            extra.Free()
            extra = Null
            If Not response.IsSuccessful Then
               me._http.ThrowFailed(response)
            End If
            me.AppendPayload(pDestFile, response)
            response.Free()
            response = Null
         Catch rangeEx As Exception
            If Assigned(extra) Then
               extra.Free()
               extra = Null
            End If
            If Assigned(response) Then
               response.Free()
               response = Null
            End If
            Throw rangeEx
         End Try
      End Sub

      Sub AppendPayload(pDestFile As TFileStream, pResponse As HttpResponse)
         Dim payload As Variant
         If Assigned(pResponse.Body) Then
            payload = pResponse.Body.Raw()
         Else
            payload = pResponse.Data.Raw()
         End If
         HttpFileIo.WritePayload(pDestFile, payload)
         payload = Unassigned
      End Sub

      Sub WriteBody(pDest As String, pResponse As HttpResponse, pAppend As Boolean)
         Dim destFile As TFileStream = HttpFileIo.OpenForWrite(pDest, pAppend And TFile.Exists(pDest))
         me.AppendPayload(destFile, pResponse)
         HttpFileIo.Release(destFile)
      End Sub

      Function LocalBytes(pPath As String) As Int64
         LocalBytes = HttpFileIo.SizeOf(pPath)
      End Function

      Sub ApplyHalt(pOptions As GoogleDriveDownloadOptions, pDest As String, ByRef pDestFile As TFileStream)
         Dim gate As GoogleDriveUploadControl
         If Not Assigned(pOptions) Then
            Exit Sub
         End If
         gate = pOptions.DownloadControl
         If Not Assigned(gate) Then
            Exit Sub
         End If
         me.HonorHalt(gate, pDest, pDestFile)
         Try
            Forms.ProcessMessages()
         Catch pumpEx As Exception
         End Try
         me.HonorHalt(gate, pDest, pDestFile)
      End Sub

      Sub HonorHalt(pGate As GoogleDriveUploadControl, pDest As String, ByRef pDestFile As TFileStream)
         If pGate.CancelRequested() Then
            pGate.MarkCancelled()
            HttpFileIo.Release(pDestFile)
            If TFile.Exists(pDest) Then
               TFile.Delete(pDest)
            End If
            Throw New Exception(GoogleDriveErrors.DownloadCancelled())
         End If
         If pGate.PauseRequested() Then
            pGate.MarkPaused()
            HttpFileIo.Release(pDestFile)
            Throw New Exception(GoogleDriveErrors.DownloadPaused())
         End If
      End Sub

      Sub Notify(pOptions As GoogleDriveDownloadOptions, pSent As Int64, pTotal As Int64)
         If Not Assigned(pOptions) Then
            Exit Sub
         End If
         If pOptions.OnProgress <> Null Then
            pOptions.OnProgress(pSent, pTotal)
         End If
      End Sub

      Sub ApplyDriveFlags(pQuery As HttpParams)
         If me._config.SupportsAllDrives Then
            pQuery.Define("supportsAllDrives", "true")
         End If
      End Sub

      Overrides Sub Dispose()
         me._http = Null
         me._config = Null
         me._endpoints = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
