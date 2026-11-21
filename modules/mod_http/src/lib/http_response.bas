Imports Collections
Imports http_headers
Imports http_file_io
Imports mod_strings
Imports mod_tobject
Imports mod_data7_utils_file_stream
Imports TFile

Namespace http_response

   Class HttpResponseData
      Inherits TTObject

      Private _text As String
      Private _data As Variant
      Private _contentType As String
      Private _contentLength As Integer

      Sub New(pText As String, pData As Variant, pContentType As String, pContentLength As Integer)
         MyBase.New()
         me._text = pText
         me._data = pData
         me._contentType = pContentType
         me._contentLength = pContentLength
      End Sub

      Property ContentType As String
         Get
            ContentType = me._contentType
         End Get
      End Property

      Property ContentLength As Integer
         Get
            ContentLength = me._contentLength
         End Get
      End Property

      Property IsJson As Boolean
         Get
            IsJson = me._text.Trim().StartsWith("{") And me._text.Trim().EndsWith("}")
         End Get
      End Property

      Property IsArray As Boolean
         Get
            IsArray = me._text.Trim().StartsWith("[") And me._text.Trim().EndsWith("]")
         End Get
      End Property

      Property AsText As String
         Get
            AsText = me._text
         End Get
      End Property

      Property AsJson As TJSONObject
         Get
            If Not me.IsJson Then
               Throw New Exception("Response is not a valid JSON Object")
            End If
            AsJson = New TJSONObject(me._text)
         End Get
      End Property

      Property AsArray As TJSONArray
         Get
            If Not me.IsArray Then
               Throw New Exception("Response is not a valid JSON Array")
            End If
            AsArray = New TJSONArray(me._text)
         End Get
      End Property

      Function Raw() As Variant
         Raw = me._data
      End Function

      Function SaveToFile(pPath As String, pOverWrite As Boolean = True, pAppend As Boolean = False) As String
         Dim destFile As TFileStream = Null
         Dim saveFailed As Boolean = False
         Dim saveErr As String = ""
         Try
            If pAppend Then
               destFile = HttpFileIo.OpenForWrite(pPath, True)
            ElseIf pOverWrite Then
               destFile = HttpFileIo.OpenForWrite(pPath, False)
            Else
               destFile = HttpFileIo.OpenCreateNew(pPath)
            End If
            me.WritePayload(destFile)
         Catch ex As Exception
            saveFailed = True
            saveErr = ex._GetMessage()
         End Try
         HttpFileIo.Release(destFile)
         If saveFailed Then
            Throw New Exception("Failed to save response to file: " & saveErr)
         End If
         SaveToFile = pPath
      End Function

      Private Sub WritePayload(pDestFile As TFileStream)
         If TypeName(me._data) = "String" Then
            If me.IsTextualContent() Then
               HttpFileIo.WriteUtf8Text(pDestFile, CStr(me._data))
            Else
               HttpFileIo.WritePayload(pDestFile, me._data)
            End If
         Else
            HttpFileIo.WritePayload(pDestFile, me._data)
         End If
      End Sub

      Private Function IsTextualContent() As Boolean
         Dim raw As String = LCase(Trim(me._contentType))
         If raw = "" Then
            IsTextualContent = False
            Exit Function
         End If
         IsTextualContent = raw.StartsWith("text/") Or raw.Contains("json") Or raw.Contains("xml") Or raw.Contains("javascript") Or raw.Contains("html")
      End Function

      Overrides Function ToString() As String
         Dim ttext As String = "Unprintable content"
         Dim jsonPretty As String = ""
         Dim arrayText As String = ""
         Dim part1 As String = ""
         Dim part2 As String = ""
         If me.ContentType.Contains("/") Then
            part1 = me.ContentType.Split("/")[0].ToUpper()
            part2 = me.ContentType.Split("/")[1].ToUpper()
         End If
         If part1 = "TEXT" Or part2 = "JSON" Or part2 = "HTML" Or part2 = "JAVASCRIPT" Then
            ttext = me.AsText
         End If
         If me.IsJson Then
            jsonPretty = FormatJson(me.AsText)
         End If
         If me.IsArray Then
            arrayText = FormatJson(me.AsText)
         End If
         With me.BuildLogger("Http Response Data")
            .Prop("ContentType", me.ContentType)
            .Prop("ContentLength", me.ContentLength)
            .Prop("AsText", ttext)
            .Prop("IsJson", me.IsJson)
            .Prop("AsJson", jsonPretty)
            .Prop("IsArray", me.IsArray)
            .Prop("AsArray", arrayText)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         me._text = ""
         me._data = Unassigned
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class HttpResponse
      Inherits TTObject

      Private _status As Integer
      Private _statusText As String
      Private _contentType As String
      Private _contentLength As Integer
      Private _contentLengthText As String
      Private _data As HttpResponseData
      Private _headers As HttpHeaders

      Sub New(pStatus As Integer, pStatusText As String, pHeaders As String, pBodyText As String, pBodyData As Variant)
         MyBase.New()
         me._status = pStatus
         me._statusText = pStatusText
         me._contentLengthText = ""
         me._headers = New HttpHeaders(pHeaders)
         If me._headers.Has("Content-Type") Then
            me._contentType = me._headers.Value("Content-Type")
         End If
         If me._headers.Has("Content-Length") Then
            me._contentLengthText = Trim(me._headers.Value("Content-Length"))
            me._contentLength = me.ParseContentLength(me._contentLengthText)
         Else
            me._contentLengthText = CStr(pBodyText.Length)
            me._contentLength = pBodyText.Length
         End If
         me._data = New HttpResponseData(pBodyText, pBodyData, me._contentType, me._contentLength)
      End Sub

      Property Status As Integer
         Get
            Status = me._status
         End Get
      End Property

      Property StatusText As String
         Get
            StatusText = me._statusText
         End Get
      End Property

      Property IsSuccessful As Boolean
         Get
            IsSuccessful = me._status >= 200 And me._status < 300
         End Get
      End Property

      Property IsResumeIncomplete As Boolean
         Get
            IsResumeIncomplete = me._status = 308
         End Get
      End Property

      Property ContentLengthText As String
         Get
            ContentLengthText = me._contentLengthText
         End Get
      End Property

      Property ContentLength As Integer
         Get
            ContentLength = me._contentLength
         End Get
      End Property

      Property Headers As HttpHeaders
         Get
            Headers = me._headers
         End Get
      End Property

      Property ContentType As String
         Get
            ContentType = me._contentType
         End Get
      End Property

      Property Body As HttpResponseData
         Get
            Body = me._data
         End Get
      End Property

      Property Data As HttpResponseData
         Get
            Data = me._data
         End Get
      End Property

      Overrides Function ToString() As String
         With me.BuildLogger("Http Response")
            .Prop("Status", me.Status)
            .Prop("StatusText", me.StatusText)
            .Prop("IsSuccessful", me.IsSuccessful)
            If Assigned(me.Headers) Then
               .Prop("Headers", me.Headers.ToString())
            End If
            If Assigned(me.Body) Then
               .Prop("Body", me.Body.ToString())
            End If
            ToString = .Text()
            .Free()
         End With
      End Function

      Private Function ParseContentLength(pText As String) As Integer
         Dim _length As Integer = 0
         If Not TryStrToInt(Trim(pText), _length) Then
            _length = 0
         End If
         ParseContentLength = _length
      End Function

      Overrides Sub Dispose()
         me._status = 0
         me._statusText = ""
         If Assigned(me._headers) Then
            me._headers.Free()
            me._headers = Null
         End If
         If Assigned(me._data) Then
            me._data.Free()
            me._data = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
