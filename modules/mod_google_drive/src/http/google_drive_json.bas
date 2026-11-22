Imports Collections
Imports http_headers
Imports http_range
Imports mod_tobject

Namespace google_drive_json

   Class GoogleDriveJson
      Inherits TTObject

      Shared Function Zero64() As Int64
         Zero64 = HttpRange.Zero64()
      End Function

      Shared Function FromInteger(pValue As Integer) As Int64
         FromInteger = HttpRange.FromInteger(pValue)
      End Function

      Shared Function ParseInt64(pText As String) As Int64
         ParseInt64 = HttpRange.ParseInt64(pText)
      End Function

      Shared Function Int64Text(pValue As Int64) As String
         Int64Text = HttpRange.Int64Text(pValue)
      End Function

      Shared Function ChunkTake(pRemaining As Int64, pChunkSize As Integer) As Integer
         ChunkTake = HttpRange.ChunkTake(pRemaining, pChunkSize)
      End Function

      Shared Function MinChunkBytes() As Integer
         MinChunkBytes = 262144
      End Function

      Shared Function DefaultChunkBytes() As Integer
         DefaultChunkBytes = HttpRange.DefaultChunkBytes()
      End Function

      Shared Function MaxDownloadChunkBytes() As Integer
         MaxDownloadChunkBytes = 134217728
      End Function

      Shared Function IsMemoryError(pMessage As String) As Boolean
         Dim text As String = UCase(pMessage)
         IsMemoryError = (InStr(text, "MEMORY") > 0) Or (InStr(text, "MEMORIA") > 0)
      End Function

      Shared Function CapDownloadChunkBytes(pSize As Integer, pMax As Integer) As Integer
         Dim cap As Integer = pMax
         If cap <= 0 Then
            cap = GoogleDriveJson.DefaultChunkBytes()
         End If
         If pSize <= 0 Then
            CapDownloadChunkBytes = cap
            Exit Function
         End If
         If pSize > cap Then
            CapDownloadChunkBytes = cap
         Else
            CapDownloadChunkBytes = pSize
         End If
      End Function

      Shared Function AlignChunkBytes(pSize As Integer, pMax As Integer) As Integer
         Dim unit As Integer = GoogleDriveJson.MinChunkBytes()
         Dim aligned As Integer
         Dim leftover As Integer
         Dim ceiling As Integer = pMax
         If ceiling < unit Then
            ceiling = unit
         End If
         If pSize < unit Then
            aligned = unit
         Else
            leftover = pSize Mod unit
            aligned = pSize - leftover
         End If
         If aligned > ceiling Then
            leftover = ceiling Mod unit
            aligned = ceiling - leftover
         End If
         If aligned < unit Then
            aligned = unit
         End If
         AlignChunkBytes = aligned
      End Function

      Shared Function GrowChunkBytes(pSize As Integer, pMax As Integer) As Integer
         Dim nextSize As Integer
         Dim halfCap As Integer = 1073741823
         If pSize >= pMax Then
            GrowChunkBytes = GoogleDriveJson.AlignChunkBytes(pMax, pMax)
            Exit Function
         End If
         If pSize > halfCap Then
            nextSize = pMax
         Else
            nextSize = pSize * 2
         End If
         GrowChunkBytes = GoogleDriveJson.AlignChunkBytes(nextSize, pMax)
      End Function

      Shared Function ShrinkChunkBytes(pSize As Integer) As Integer
         Dim unit As Integer = GoogleDriveJson.MinChunkBytes()
         Dim nextSize As Integer = CInt(pSize / 2)
         Dim leftover As Integer
         If nextSize < unit Then
            nextSize = unit
         End If
         leftover = nextSize Mod unit
         ShrinkChunkBytes = nextSize - leftover
      End Function

      Shared Function TimeOfDayMs(pStamp As TDateTime) As Integer
         Dim hours As Integer = CInt(CStr(pStamp.HourOf))
         Dim minutes As Integer = CInt(CStr(pStamp.MinuteOf))
         Dim seconds As Integer = CInt(CStr(pStamp.SecondOf))
         Dim millis As Integer = CInt(CStr(pStamp.MilliSecondOf))
         TimeOfDayMs = (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + millis
      End Function

      Shared Function ElapsedMs(pStarted As TDateTime, pEnded As TDateTime) As Integer
         Dim startedMs As Integer = GoogleDriveJson.TimeOfDayMs(pStarted)
         Dim endedMs As Integer = GoogleDriveJson.TimeOfDayMs(pEnded)
         Dim deltaMs As Integer = endedMs - startedMs
         If deltaMs < 0 Then
            deltaMs = deltaMs + 86400000
         End If
         ElapsedMs = deltaMs
      End Function

      Shared Function ElapsedSeconds(pStarted As TDateTime, pEnded As TDateTime) As Integer
         Dim ms As Integer = GoogleDriveJson.ElapsedMs(pStarted, pEnded)
         Dim frac As Integer = ms Mod 1000
         ElapsedSeconds = CInt((ms - frac) / 1000)
      End Function

      Shared Function ElapsedText(pStarted As TDateTime, pEnded As TDateTime) As String
         Dim ms As Integer = GoogleDriveJson.ElapsedMs(pStarted, pEnded)
         Dim frac As Integer = ms Mod 1000
         Dim whole As Integer = CInt((ms - frac) / 1000)
         Dim fracText As String = CStr(frac)
         If frac < 10 Then
            fracText = "00" & fracText
         ElseIf frac < 100 Then
            fracText = "0" & fracText
         End If
         ElapsedText = CStr(whole) & "." & fracText & "s"
      End Function

      Shared Function BuildUploadRange(pStart As Int64, pEndInclusive As Int64, pTotal As Int64) As String
         BuildUploadRange = HttpRange.ContentRange(pStart, pEndInclusive, pTotal)
      End Function

      Shared Function BuildResumeRange(pTotal As Int64) As String
         BuildResumeRange = HttpRange.ResumeProbe(pTotal)
      End Function

      Shared Function BuildDownloadRange(pStart As Int64, pEndInclusive As Int64) As String
         BuildDownloadRange = HttpRange.Download(pStart, pEndInclusive)
      End Function

      Shared Sub PutHeader(pHeaders As HttpHeaders, pName As String, pValue As String)
         pHeaders.Define(pName, pValue)
      End Sub

      Shared Function Quote(pValue As String) As String
         Dim text As String = pValue
         text = text.Replace("\", "\\")
         text = text.Replace(CHAR(34), "\" & CHAR(34))
         text = text.Replace(CHAR(13), "\r")
         text = text.Replace(CHAR(10), "\n")
         Quote = CHAR(34) & text & CHAR(34)
      End Function

      Shared Function StringArray(pItems As StringList) As String
         Dim jsonText As String = "["
         If Assigned(pItems) Then
            Dim i As Integer
            For i = 0 To pItems.Count - 1
               If i > 0 Then
                  jsonText = jsonText & ","
               End If
               jsonText = jsonText & GoogleDriveJson.Quote(pItems.Strings(i))
            Next
         End If
         jsonText = jsonText & "]"
         StringArray = jsonText
      End Function

      Shared Function HeaderValue(pHeaders As HttpHeaders, pName As String) As String
         If Not Assigned(pHeaders) Then
            HeaderValue = ""
            Exit Function
         End If
         If pHeaders.Has(pName) Then
            HeaderValue = Trim(pHeaders.Value(pName))
         Else
            HeaderValue = ""
         End If
      End Function

      Shared Function ParseRangeEnd(pRange As String) As Int64
         ParseRangeEnd = HttpRange.ParseEnd(pRange)
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
