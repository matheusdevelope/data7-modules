Imports Forms
Imports Collections
Imports http_enums
Imports http_headers
Imports http_body
Imports http_response
Imports TFile
Imports mod_tobject
Imports google_drive_http
Imports google_drive_config
Imports google_drive_endpoints
Imports google_drive_file
Imports google_drive_chunk_source
Imports google_drive_upload_options
Imports google_drive_upload_control
Imports google_drive_upload_session
Imports google_drive_json
Imports google_drive_errors
Imports google_drive_mime
Imports mod_data7_utils_file_stream

Namespace google_drive_uploader

   Class GoogleDriveUploader
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

      Function Upload(pSource As GoogleDriveChunkSource, pOptions As GoogleDriveUploadOptions) As GoogleDriveFile
         If Not Assigned(pSource) Then
            Throw New Exception(GoogleDriveErrors.ChunkSourceRequired())
         End If
         Dim options As GoogleDriveUploadOptions = pOptions
         Dim ownsOptions As Boolean = False
         If Not Assigned(options) Then
            options = New GoogleDriveUploadOptions()
            ownsOptions = True
         End If
         Dim total As Int64 = pSource.Size()
         Dim mime As String = Trim(options.MimeType)
         If mime = "" Then
            mime = GoogleDriveMime.FromPath(pSource.SourcePath())
         End If
         Dim sessionUri As String = Trim(options.SessionUri)
         Dim resumeExisting As Boolean = False
         If sessionUri <> "" Then
            resumeExisting = True
         ElseIf Trim(options.SessionFile) <> "" Then
            If TFile.Exists(options.SessionFile) Then
               Dim saved As GoogleDriveUploadSession = GoogleDriveUploadSession.FromFile(options.SessionFile)
               If me.CanResume(saved, pSource, total) Then
                  sessionUri = Trim(saved.SessionUri)
                  resumeExisting = True
               Else
                  me.ClearSession(options)
               End If
               saved.Free()
            End If
         End If
         If Not resumeExisting Then
            sessionUri = me.StartSession(pSource, options, total, mime)
         End If
         Dim sent As Int64 = GoogleDriveJson.Zero64()
         If resumeExisting Then
            sent = me.QueryUploaded(sessionUri, total)
            If Not (sent < total) Then
               me.ClearSession(options)
               sessionUri = me.StartSession(pSource, options, total, mime)
               sent = GoogleDriveJson.Zero64()
               resumeExisting = False
            End If
         End If
         me.Persist(options, pSource, sessionUri, sent, total, mime)
         Dim maxChunk As Integer = me._config.ChunkSizeBytes
         Dim chunkSize As Integer = GoogleDriveJson.AlignChunkBytes(maxChunk, maxChunk)
         If me._config.AdaptiveChunkSize Then
            chunkSize = GoogleDriveJson.AlignChunkBytes(GoogleDriveJson.DefaultChunkBytes(), maxChunk)
         End If
         Dim failStreak As Integer = 0
         Dim putStarted As TDateTime
         Dim putEnded As TDateTime
         Dim elapsedSec As Integer = 0
         Dim previousChunk As Integer = 0
         Dim putFailed As Boolean = False
         Dim resultFile As GoogleDriveFile = Null
         Dim remaining As Int64 = GoogleDriveJson.Zero64()
         Dim take As Integer = 0
         Dim endInclusive As Int64 = GoogleDriveJson.Zero64()
         Dim extra As HttpHeaders
         Dim body As HttpBody
         Dim response As HttpResponse
         Dim rangeHeader As String = ""
         Dim rangeEnd As Int64 = GoogleDriveJson.Zero64()
         Dim json As TJSONObject
         Dim rangeSpec As String = ""
         me.ApplyHalt(options, pSource, sessionUri, sent, total, mime)
         While sent < total
            me.ApplyHalt(options, pSource, sessionUri, sent, total, mime)
            remaining = total - sent
            take = GoogleDriveJson.ChunkTake(remaining, chunkSize)
            endInclusive = sent + take - 1
            rangeSpec = GoogleDriveJson.BuildUploadRange(sent, endInclusive, total)
            extra = New HttpHeaders()
            extra.Define("Content-Range", rangeSpec)
            body = me.ChunkBody(pSource, sent, take, mime)
            putStarted = DateTime()
            putFailed = False
            Try
               response = me._http.Send(HttpMethod.Put(), sessionUri, body, extra)  
            Catch ex As Exception   
               body.Free()
               extra.Free()
               failStreak = failStreak + 1
               previousChunk = chunkSize
               sent = me.QueryUploaded(sessionUri, total)
               me.Persist(options, pSource, sessionUri, sent, total, mime)
               If me._config.AdaptiveChunkSize Then
                  chunkSize = GoogleDriveJson.ShrinkChunkBytes(chunkSize)
                  If (failStreak > 6) Or ((chunkSize = previousChunk) And (failStreak > 2)) Then
                     Throw ex
                  End If
               ElseIf failStreak > 6 Then
                  Throw ex
               End If   
               me.ApplyHalt(options, pSource, sessionUri, sent, total, mime)
               putFailed = True
            End Try
            If Not putFailed Then
               body.Free()
               extra.Free()
               putEnded = DateTime()
               elapsedSec = GoogleDriveJson.ElapsedSeconds(putStarted, putEnded)
               failStreak = 0
               If response.IsResumeIncomplete Then
                  rangeHeader = GoogleDriveJson.HeaderValue(response.Headers, "Range")
                  rangeEnd = GoogleDriveJson.ParseRangeEnd(rangeHeader)
                  If rangeEnd >= 0 Then
                     sent = rangeEnd + 1
                  Else
                     sent = endInclusive + 1
                  End If
                  response.Free()
                  If me._config.AdaptiveChunkSize Then
                     If elapsedSec < 5 Then
                        chunkSize = GoogleDriveJson.GrowChunkBytes(chunkSize, maxChunk)
                     ElseIf elapsedSec > 20 Then
                        chunkSize = GoogleDriveJson.ShrinkChunkBytes(chunkSize)
                     End If
                  End If
                  me.Persist(options, pSource, sessionUri, sent, total, mime)
                  me.Notify(options, sent, total)
               ElseIf response.IsSuccessful Then
                  json = response.Body.AsJson
                  resultFile = GoogleDriveFile.FromJson(json)
                  json.Free()
                  response.Free()
                  sent = total
                  me.Notify(options, sent, total)
                  me.ClearSession(options)
                  Exit While
               Else
                  me._http.ThrowFailed(response)
               End If
            End If
         End While
         If Not Assigned(resultFile) Then
            If total = GoogleDriveJson.Zero64() Then
               resultFile = me.UploadEmpty(options, mime)
            Else
               Throw New Exception(GoogleDriveErrors.UploadIncomplete())
            End If
         End If
         If ownsOptions Then
            options.Free()
         End If
         Upload = resultFile
      End Function

      Function StartSession(pSource As GoogleDriveChunkSource, pOptions As GoogleDriveUploadOptions, pTotal As Int64, pMime As String) As String
         Dim query As New HttpParams()
         query.Define("uploadType", "resumable")
         query.Define("fields", me._config.FileFields)
         me.ApplyDriveFlags(query)
         Dim url As String = me._endpoints.WithQuery(me._endpoints.ResumableUploadUrl(), query)
         If Trim(pOptions.DriveFileId) <> "" Then
            url = me._endpoints.WithQuery(me._endpoints.RootUrl() & Mid(me._endpoints.ResumableUploadPath(), 2) & "/" & Trim(pOptions.DriveFileId), query)
         End If
         query.Free()
         Dim extra As New HttpHeaders()
         extra.Define("X-Upload-Content-Type", pMime)
         ' data7:disable-next-line type-mismatch
         extra.Define("X-Upload-Content-Length", pTotal)
         extra.Define("Content-Type", "application/json; charset=UTF-8")
         Dim meta As TJSONObject = me.MetadataJson(pOptions, pMime)
         Dim body As HttpBody = HttpBody.FromJson(meta.ToString())
         Dim method As HttpMethod = HttpMethod.Post()
         If Trim(pOptions.DriveFileId) <> "" Then
            method = HttpMethod.Patch()
         End If
         Dim response As HttpResponse = me._http.Send(method, url, body, extra)
         body.Free()
         extra.Free()
         meta.Free()
         If Not response.IsSuccessful Then
            me._http.ThrowFailed(response)
         End If
         Dim location As String = GoogleDriveJson.HeaderValue(response.Headers, "Location")
         response.Free()
         If Trim(location) = "" Then
            Throw New Exception(GoogleDriveErrors.LocationMissing())
         End If
         StartSession = location
      End Function

      Function QueryUploaded(pSessionUri As String, pTotal As Int64) As Int64
         Dim resumeSpec As String = GoogleDriveJson.BuildResumeRange(pTotal)
         Dim extra As New HttpHeaders()
         extra.Define("Content-Range", resumeSpec)
         Dim response As HttpResponse = me._http.Send(HttpMethod.Put(), pSessionUri, Null, extra)
         extra.Free()
         If response.IsResumeIncomplete Then
            Dim rangeHeader As String = GoogleDriveJson.HeaderValue(response.Headers, "Range")
            response.Free()
            Dim rangeEnd As Int64 = GoogleDriveJson.ParseRangeEnd(rangeHeader)
            If rangeEnd < 0 Then
               QueryUploaded = GoogleDriveJson.Zero64()
               Exit Function
            End If
            QueryUploaded = rangeEnd + 1
            Exit Function
         End If
         If response.IsSuccessful Then
            response.Free()
            QueryUploaded = pTotal
            Exit Function
         End If
         response.Free()
         QueryUploaded = GoogleDriveJson.Zero64()
      End Function

      Function CanResume(pSaved As GoogleDriveUploadSession, pSource As GoogleDriveChunkSource, pTotal As Int64) As Boolean
         If Not Assigned(pSaved) Then
            CanResume = False
            Exit Function
         End If
         If Trim(pSaved.SessionUri) = "" Then
            CanResume = False
            Exit Function
         End If
         If GoogleDriveJson.Int64Text(pSaved.TotalBytes) <> GoogleDriveJson.Int64Text(pTotal) Then
            CanResume = False
            Exit Function
         End If
         Dim savedPath As String = LCase(Trim(pSaved.FilePath))
         Dim currentPath As String = LCase(Trim(pSource.SourcePath()))
         If (savedPath <> "") And (currentPath <> "") Then
            If savedPath <> currentPath Then
               CanResume = False
               Exit Function
            End If
         End If
         CanResume = True
      End Function

      Function MetadataJson(pOptions As GoogleDriveUploadOptions, pMime As String) As TJSONObject
         Dim jsonText As String = "{"
         jsonText = jsonText & GoogleDriveJson.Quote("name") & ":" & GoogleDriveJson.Quote(pOptions.Name)
         jsonText = jsonText & "," & GoogleDriveJson.Quote("mimeType") & ":" & GoogleDriveJson.Quote(pMime)
         If Trim(pOptions.ParentId) <> "" Then
            Dim parents As New StringList()
            parents.Add(Trim(pOptions.ParentId))
            jsonText = jsonText & "," & GoogleDriveJson.Quote("parents") & ":" & GoogleDriveJson.StringArray(parents)
            parents.Free()
         End If
         jsonText = jsonText & "}"
         MetadataJson = New TJSONObject(jsonText)
      End Function

      Function ChunkBody(pSource As GoogleDriveChunkSource, pOffset As Int64, pLength As Integer, pMime As String) As HttpBody
         Dim disk As TFileStream = pSource.DiskFile()
         Dim payload As Variant
         If Assigned(disk) Then
            ChunkBody = HttpBody.FromStreamWindow(disk, pOffset, pLength, pMime)
            Exit Function
         End If
         payload = pSource.ReadChunk(pOffset, pLength)
         ChunkBody = HttpBody.FromBytes(payload, pMime)
      End Function

      Function UploadEmpty(pOptions As GoogleDriveUploadOptions, pMime As String) As GoogleDriveFile
         Dim query As New HttpParams()
         query.Define("fields", me._config.FileFields)
         me.ApplyDriveFlags(query)
         Dim meta As TJSONObject = me.MetadataJson(pOptions, pMime)
         Dim created As TJSONObject = me._http.PostJson(me._endpoints.FilesPath(), query, meta)
         query.Free()
         meta.Free()
         Dim driveFile As GoogleDriveFile = GoogleDriveFile.FromJson(created)
         created.Free()
         UploadEmpty = driveFile
      End Function

      Sub ApplyDriveFlags(pQuery As HttpParams)
         If me._config.SupportsAllDrives Then
            pQuery.Define("supportsAllDrives", "true")
         End If
      End Sub

      Sub Persist(pOptions As GoogleDriveUploadOptions, pSource As GoogleDriveChunkSource, pSessionUri As String, pSent As Int64, pTotal As Int64, pMime As String)
         If Trim(pOptions.SessionFile) = "" Then
            Exit Sub
         End If
         Dim session As New GoogleDriveUploadSession()
         session.SessionUri = pSessionUri
         session.FilePath = pSource.SourcePath()
         session.BytesSent = pSent
         session.TotalBytes = pTotal
         session.DriveFileId = pOptions.DriveFileId
         session.MimeType = pMime
         session.Name = pOptions.Name
         session.ParentId = pOptions.ParentId
         session.ToFile(pOptions.SessionFile)
         session.Free()
      End Sub

      Sub ClearSession(pOptions As GoogleDriveUploadOptions)
         If Trim(pOptions.SessionFile) = "" Then
            Exit Sub
         End If
         If TFile.Exists(pOptions.SessionFile) Then
            TFile.Delete(pOptions.SessionFile)
         End If
      End Sub

      Sub Notify(pOptions As GoogleDriveUploadOptions, pSent As Int64, pTotal As Int64)
         If pOptions.OnProgress <> Null Then
            pOptions.OnProgress(pSent, pTotal)
         End If
      End Sub

      Function HaltWanted(pGate As GoogleDriveUploadControl) As Integer
         If pGate.CancelRequested() Then
            HaltWanted = 2
            Exit Function
         End If
         If pGate.PauseRequested() Then
            HaltWanted = 1
            Exit Function
         End If
         HaltWanted = 0
      End Function

      Sub ApplyHalt(pOptions As GoogleDriveUploadOptions, pSource As GoogleDriveChunkSource, pSessionUri As String, pSent As Int64, pTotal As Int64, pMime As String)
         Dim gate As GoogleDriveUploadControl
         Dim wanted As Integer
         If Not Assigned(pOptions) Then
            Exit Sub
         End If
         gate = pOptions.DownloadControl
         If Not Assigned(gate) Then
            Exit Sub
         End If
         wanted = me.HaltWanted(gate)
         If wanted = 2 Then
            gate.MarkCancelled()
            me.ClearSession(pOptions)
            Throw New Exception(GoogleDriveErrors.UploadCancelled())
         End If
         If wanted = 1 Then
            gate.MarkPaused()
            me.Persist(pOptions, pSource, pSessionUri, pSent, pTotal, pMime)
            Throw New Exception(GoogleDriveErrors.UploadPaused())
         End If
         Try
            Forms.ProcessMessages()
         Catch pumpEx As Exception
         End Try
         wanted = me.HaltWanted(gate)
         If wanted = 2 Then
            gate.MarkCancelled()
            me.ClearSession(pOptions)
            Throw New Exception(GoogleDriveErrors.UploadCancelled())
         End If
         If wanted = 1 Then
            gate.MarkPaused()
            me.Persist(pOptions, pSource, pSessionUri, pSent, pTotal, pMime)
            Throw New Exception(GoogleDriveErrors.UploadPaused())
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
