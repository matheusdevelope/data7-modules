Imports mod_tobject

Namespace http_range

   Class HttpRange
      Inherits TTObject

      Shared Function DefaultChunkBytes() As Integer
         DefaultChunkBytes = 8388608
      End Function

      Shared Function Zero64() As Int64
         Dim zeroText As String = "0"
         Zero64 = zeroText.ToInt64()
      End Function

      Shared Function Int64Text(pValue As Int64) As String
         Int64Text = pValue.ToString()
      End Function

      Shared Function ParseInt64(pText As String) As Int64
         Dim raw As String = Trim(pText)
         Dim parsed As Int64 = HttpRange.Zero64()
         If raw = "" Then
            ParseInt64 = parsed
            Exit Function
         End If
         Try
            parsed = raw.ToInt64()
         Catch ex As Exception
            parsed = HttpRange.Zero64()
         End Try
         ParseInt64 = parsed
      End Function

      Shared Function FromInteger(pValue As Integer) As Int64
         Dim text As String = CStr(pValue)
         FromInteger = text.ToInt64()
      End Function

      Shared Function ChunkTake(pRemaining As Int64, pChunkSize As Integer) As Integer
         Dim chunk As Int64 = HttpRange.FromInteger(pChunkSize)
         If pRemaining < chunk Then
            ChunkTake = CInt(pRemaining.ToString())
         Else
            ChunkTake = pChunkSize
         End If
      End Function

      Shared Function Download(pStart As Int64, pEndInclusive As Int64) As String
         Dim text As String = "bytes="
         text = text & HttpRange.Int64Text(pStart)
         text = text & "-"
         text = text & HttpRange.Int64Text(pEndInclusive)
         Download = text
      End Function

      Shared Function ContentRange(pStart As Int64, pEndInclusive As Int64, pTotal As Int64) As String
         Dim text As String = "bytes "
         text = text & HttpRange.Int64Text(pStart)
         text = text & "-"
         text = text & HttpRange.Int64Text(pEndInclusive)
         text = text & "/"
         text = text & HttpRange.Int64Text(pTotal)
         ContentRange = text
      End Function

      Shared Function ResumeProbe(pTotal As Int64) As String
         Dim text As String = "bytes */"
         text = text & HttpRange.Int64Text(pTotal)
         ResumeProbe = text
      End Function

      Shared Function ParseEnd(pRange As String) As Int64
         Dim text As String = Trim(pRange)
         Dim slashPos As Integer = InStr(text, "/")
         Dim dashPos As Integer = 0
         Dim tail As String = ""
         If slashPos > 0 Then
            text = Trim(Left(text, slashPos - 1))
         End If
         dashPos = InStrRev(text, "-")
         If dashPos <= 0 Then
            ParseEnd = HttpRange.ParseInt64("-1")
            Exit Function
         End If
         tail = Trim(Mid(text, dashPos + 1))
         If tail = "" Then
            ParseEnd = HttpRange.ParseInt64("-1")
            Exit Function
         End If
         ParseEnd = HttpRange.ParseInt64(tail)
      End Function

      Shared Function ParseTotal(pRange As String) As Int64
         Dim text As String = Trim(pRange)
         Dim slashPos As Integer = InStr(text, "/")
         Dim tail As String = ""
         If slashPos <= 0 Then
            ParseTotal = HttpRange.ParseInt64("-1")
            Exit Function
         End If
         tail = Trim(Mid(text, slashPos + 1))
         If (tail = "") Or (tail = "*") Then
            ParseTotal = HttpRange.ParseInt64("-1")
            Exit Function
         End If
         ParseTotal = HttpRange.ParseInt64(tail)
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
