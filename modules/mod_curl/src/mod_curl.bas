
Imports IO
Imports Collections
Imports mod_zip_exe

Namespace mod_curl

   Class Curl
      Inherits TZipPortableExe

      Private _method As String
      Private _url As String
      Private _headers As StringList
      Private _formParts As StringList
      Private _extraOptions As StringList
      Private _ownedTemps As StringList

      Private _cert As String
      Private _certType As String
      Private _key As String
      Private _pass As String
      Private _outputFile As String
      Private _dataFile As String
      Private _timeoutMs As Integer
      Private _followRedirects As Boolean
      Private _insecure As Boolean

      Private _tempOutput As String
      Private _tempHeaders As String
      Private _tempStderr As String

      Sub New()
         MyBase.New()
         me.DownloadUrl = "https://curl.se/windows/latest.cgi?p=win64-mingw.zip"
         me.DownloadTimeoutMs = 120000
         me.InstallFolder = "curl"
         me.ExeFileName = "curl.exe"
         me.ArchiveName = "curl.zip"
         me.SearchRecursive = True
         me._headers = New StringList()
         me._formParts = New StringList()
         me._extraOptions = New StringList()
         me._ownedTemps = New StringList()
         me._followRedirects = True
         me._insecure = False
         me._timeoutMs = 0
      End Sub

      Property Method As String
         Get
            Method = me._method
         End Get
         Set(value As String)
            me._method = value
         End Set
      End Property

      Property Url As String
         Get
            Url = me._url
         End Get
         Set(value As String)
            me._url = value
         End Set
      End Property

      Property Cert As String
         Get
            Cert = me._cert
         End Get
         Set(value As String)
            me._cert = value
         End Set
      End Property

      Property CertType As String
         Get
            CertType = me._certType
         End Get
         Set(value As String)
            me._certType = value
         End Set
      End Property

      Property Key As String
         Get
            Key = me._key
         End Get
         Set(value As String)
            me._key = value
         End Set
      End Property

      Property Pass As String
         Get
            Pass = me._pass
         End Get
         Set(value As String)
            me._pass = value
         End Set
      End Property

      Property Output As String
         Get
            Output = me._outputFile
         End Get
         Set(value As String)
            me._outputFile = value
         End Set
      End Property

      Property TimeoutMs As Integer
         Get
            TimeoutMs = me._timeoutMs
         End Get
         Set(value As Integer)
            me._timeoutMs = value
         End Set
      End Property

      Property FollowRedirects As Boolean
         Get
            FollowRedirects = me._followRedirects
         End Get
         Set(value As Boolean)
            me._followRedirects = value
         End Set
      End Property

      Property Insecure As Boolean
         Get
            Insecure = me._insecure
         End Get
         Set(value As Boolean)
            me._insecure = value
         End Set
      End Property

      Sub UsePfx(pPath As String, pPass As String)
         me._cert = pPath
         me._certType = "P12"
         me._key = ""
         me._pass = pPass
      End Sub

      Sub AddHeader(pName As String, pValue As String)
         me._headers.Add(Trim(pName) & ": " & Trim(pValue))
      End Sub

      Sub AddBody(pText As String)
         Dim bodyFile As String = me.GetTempFilePath("curlb", ".bin")
         me.WriteUtf8NoBom(bodyFile, pText)
         me.TrackTemp(bodyFile)
         me._dataFile = bodyFile
      End Sub

      Sub AddFormPart(pValue As String)
         me._formParts.Add(pValue)
      End Sub

      Sub AddOption(pValue As String)
         me._extraOptions.Add(pValue)
      End Sub

      Sub AddDataBinaryFile(pPath As String)
         me._dataFile = pPath
      End Sub

      Sub TrackTemp(pPath As String)
         If pPath <> "" Then
            me._ownedTemps.Add(pPath)
         End If
      End Sub

      Function Exec() As CurlOutput
         me._tempHeaders = me.GetTempFilePath("curlh", ".txt")
         me._tempStderr = me.GetTempFilePath("curle", ".txt")
         If me._outputFile = "" Then
            me._tempOutput = me.GetTempFilePath("curlo", ".bin")
         Else
            me._tempOutput = me._outputFile
         End If
         me.TrackTemp(me._tempHeaders)
         me.TrackTemp(me._tempStderr)
         If me._outputFile = "" Then
            me.TrackTemp(me._tempOutput)
         End If

         Dim code As Integer = me.RunWait(me.BuildCurlArgs())
         If code <> 0 Then
            Dim errText As String = me.ReadTextFile(me._tempStderr)
            Throw New Exception("curl failed (" & CStr(code) & "): " & errText)
         End If

         Dim parsed As New CurlOutput(me._tempHeaders, me._tempOutput)
         me.CleanTemps()
         Exec = parsed
      End Function

      Private Function BuildCurlArgs() As String
         Dim sl As New StringList()
         Dim i As Integer

         sl.Add("-sS")
         sl.Add("--globoff")

         If me._followRedirects Then
            sl.Add("-L")
            sl.Add("--max-redirs 10")
         End If
         If me._insecure Then
            sl.Add("-k")
         End If

         If me._timeoutMs > 0 Then
            Dim secs As Integer = Int(me._timeoutMs / 1000)
            If secs < 1 Then
               secs = 1
            End If
            sl.Add("--max-time " & CStr(secs))
            sl.Add("--connect-timeout " & CStr(secs))
         End If

         If me._method <> "" Then
            sl.Add("-X " & me.ArgQuote(me._method))
         End If

         If me._url <> "" Then
            sl.Add("--url " & me.ArgQuote(me._url))
         End If

         For i = 0 To me._headers.Count - 1
            sl.Add("-H " & me.ArgQuote(me._headers.Strings(i)))
         Next

         If me._dataFile <> "" Or me._formParts.Count > 0 Then
            sl.Add("-H " & me.ArgQuote("Expect:"))
         End If

         If me._dataFile <> "" Then
            sl.Add("--data-binary " & me.ArgQuote("@" & me._dataFile))
         End If

         For i = 0 To me._formParts.Count - 1
            sl.Add("-F " & me.ArgQuote(me._formParts.Strings(i)))
         Next

         If UCase(Trim(me._certType)) = "P12" Then
            sl.Add("--cert-type P12")
         End If
         If me._cert <> "" Then
            sl.Add("--cert " & me.ArgQuote(me._cert))
         End If
         If me._key <> "" Then
            sl.Add("--key " & me.ArgQuote(me._key))
         End If
         If me._pass <> "" Then
            sl.Add("--config " & me.ArgQuote(me.WritePassConfig()))
         End If

         For i = 0 To me._extraOptions.Count - 1
            sl.Add(me._extraOptions.Strings(i))
         Next

         sl.Add("--dump-header " & me.ArgQuote(me._tempHeaders))
         sl.Add("--output " & me.ArgQuote(me._tempOutput))
         sl.Add("--stderr " & me.ArgQuote(me._tempStderr))

         BuildCurlArgs = sl.Text.Trim.Replace(sl.LineBreak, " ")
         sl.Free()
      End Function

      Private Function WritePassConfig() As String
         Dim cfgPath As String = me.GetTempFilePath("curlc", ".cfg")
         Dim line As String = "pass = " & me.ArgQuote(me._pass)
         me.WriteUtf8NoBom(cfgPath, line & CHAR(13) & CHAR(10))
         me.TrackTemp(cfgPath)
         WritePassConfig = cfgPath
      End Function

      Private Function ArgQuote(pValue As String) As String
         ArgQuote = pValue.Quoted()
      End Function

      Private Sub WriteUtf8NoBom(pPath As String, pText As String)
         Dim src As Variant = CreateObject("ADODB.Stream")
         src.Type = 2
         src.Charset = "UTF-8"
         src.Open()
         src.WriteText(pText)
         src.Position = 0
         src.Type = 1
         If src.Size >= 3 Then
            src.Position = 3
         End If
         Dim payload As Variant = src.Read
         src.Close()
         src = Unassigned

         Dim dest As Variant = CreateObject("ADODB.Stream")
         dest.Type = 1
         dest.Open()
         If Not IsEmpty(payload) Then
            dest.Write(payload)
         End If
         dest.SaveToFile(pPath, 2)
         dest.Close()
         dest = Unassigned
      End Sub

      Private Function ReadTextFile(pPath As String) As String
         If Not IO.File.Exists(pPath) Then
            ReadTextFile = ""
            Exit Function
         End If
         Dim lines As New StringList()
         lines.LoadFromFile(pPath)
         ReadTextFile = lines.Text
         lines.Free()
      End Function

      Private Sub DeleteQuiet(pPath As String)
         If pPath = "" Then
            Exit Sub
         End If
         If IO.File.Exists(pPath) Then
            Try
               IO.File.Delete(pPath)
            Catch
            End Try
         End If
      End Sub

      Private Sub CleanTemps()
         Dim i As Integer
         For i = 0 To me._ownedTemps.Count - 1
            me.DeleteQuiet(me._ownedTemps.Strings(i))
         Next
         me._ownedTemps.Clear()
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("Curl")
            .Prop("Method", me.Method)
            .Prop("Url", me.Url)
            .Prop("Cert", me.Cert)
            .Prop("CertType", me.CertType)
            .Prop("TimeoutMs", me.TimeoutMs)
            .Prop("FollowRedirects", me.FollowRedirects)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         me.CleanTemps()
         If Assigned(me._headers) Then
            me._headers.Free()
         End If
         If Assigned(me._formParts) Then
            me._formParts.Free()
         End If
         If Assigned(me._extraOptions) Then
            me._extraOptions.Free()
         End If
         If Assigned(me._ownedTemps) Then
            me._ownedTemps.Free()
         End If
         me._pass = ""
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class CurlOutput

      ReadOnly StatusCode As Integer
      ReadOnly StatusText As String
      ReadOnly HttpVersion As String
      ReadOnly ContentType As String
      ReadOnly Charset As String
      ReadOnly ContentLength As Long
      ReadOnly Headers As StringList = New StringList()
      ReadOnly ResponseData As Variant
      ReadOnly ResponseText As String

      Sub New(headersFile As String, bodyFile As String)
         MyBase.New()
         me.ParseHeaders(headersFile)
         me.LoadResponseData(bodyFile)
         me.LoadResponseText(bodyFile)
      End Sub

      Private Sub ParseHeaders(pPath As String)
         If Not IO.File.Exists(pPath) Then
            Throw New Exception("Header file not found.")
         End If

         Dim sl As New StringList()
         sl.LoadFromFile(pPath)
         If sl.Count = 0 Then
            sl.Free()
            Throw New Exception("Header file is empty.")
         End If

         Dim i As Integer
         For i = 0 To sl.Count - 1
            Dim line As String = sl.Strings(i).Trim()
            If me.IsHttpStatusLine(line) Then
               me.ApplyStatusLine(line)
               me.Headers.Clear()
            ElseIf line <> "" Then
               me.Headers.Add(line)
            End If
         Next
         sl.Free()
         me.ExtractContentType()
         me.ExtractContentLength()
      End Sub

      Private Function IsHttpStatusLine(pLine As String) As Boolean
         IsHttpStatusLine = UCase(Left(pLine, 5)) = "HTTP/"
      End Function

      Private Sub ApplyStatusLine(pLine As String)
         Dim sp1 As Integer = InStr(pLine, " ")
         If sp1 <= 0 Then
            me.HttpVersion = pLine
            Exit Sub
         End If
         me.HttpVersion = Left(pLine, sp1 - 1)
         Dim rest As String = Trim(Mid(pLine, sp1 + 1))
         Dim sp2 As Integer = InStr(rest, " ")
         Try
            If sp2 > 0 Then
               me.StatusCode = CInt(Left(rest, sp2 - 1))
               me.StatusText = Trim(Mid(rest, sp2 + 1))
            Else
               me.StatusCode = CInt(rest)
               me.StatusText = ""
            End If
         Catch
            me.StatusCode = 0
            me.StatusText = rest
         End Try
      End Sub

      Private Sub LoadResponseData(pPath As String)
         If Not IO.File.Exists(pPath) Then
            Exit Sub
         End If
         Dim binStream As Variant = CreateObject("ADODB.Stream")
         binStream.Type = 1
         binStream.Open()
         binStream.LoadFromFile(pPath)
         me.ResponseData = binStream.Read
         binStream.Close()
         binStream = Unassigned
      End Sub

      Private Sub LoadResponseText(pPath As String)
         If Not IO.File.Exists(pPath) Then
            Exit Sub
         End If
         Dim lines As New StringList()
         lines.LoadFromFile(pPath)
         me.ResponseText = lines.Text
         lines.Free()
      End Sub

      Private Function HeaderValue(pName As String) As String
         Dim needle As String = UCase(Trim(pName))
         Dim i As Integer
         For i = 0 To me.Headers.Count - 1
            Dim line As String = me.Headers.Strings(i)
            Dim sep As Integer = InStr(line, ":")
            If sep > 0 Then
               If UCase(Trim(Left(line, sep - 1))) = needle Then
                  HeaderValue = Trim(Mid(line, sep + 1))
                  Exit Function
               End If
            End If
         Next
         HeaderValue = ""
      End Function

      Private Sub ExtractContentType()
         Dim raw As String = me.HeaderValue("Content-Type")
         If raw = "" Then
            Exit Sub
         End If
         me.ContentType = raw
         Dim lower As String = LCase(raw)
         Dim pos As Integer = InStr(lower, "charset=")
         If pos <= 0 Then
            Exit Sub
         End If
         Dim cs As String = Trim(Mid(raw, pos + 8))
         Dim semi As Integer = InStr(cs, ";")
         If semi > 0 Then
            cs = Left(cs, semi - 1)
         End If
         me.Charset = Trim(cs.Replace("""", ""))
      End Sub

      Private Sub ExtractContentLength()
         Dim raw As String = me.HeaderValue("Content-Length")
         If raw = "" Then
            Exit Sub
         End If
         Try
            me.ContentLength = CLng(Trim(raw))
         Catch
            me.ContentLength = 0
         End Try
      End Sub

      Sub Free()
         me.StatusCode = 0
         me.StatusText = ""
         me.HttpVersion = ""
         me.ContentType = ""
         me.Charset = ""
         me.ContentLength = 0
         If Assigned(me.Headers) Then
            me.Headers.Free()
         End If
         me.ResponseData = ""
         me.ResponseText = ""
         MyBase.Free()
      End Sub

   End Class

End Namespace
