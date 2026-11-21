Imports TPath
Imports TFile
Imports mod_tobject
Imports mod_data7_utils_file_stream
Imports mod_data7_utils_stream
Imports mod_data7_utils_stream_enums
Imports http_range

Namespace http_file_io

   Class HttpFileIo
      Inherits TTObject

      Shared Function ChunkBytes() As Integer
         ChunkBytes = 65536
      End Function

      Shared Function OpenForWrite(pPath As String, pAppend As Boolean) As TFileStream
         Dim destFile As New TFileStream()
         destFile.StreamKind = TUtilsStreamKind.Binary()
         If pAppend And TFile.Exists(pPath) Then
            destFile.Open(pPath, TUtilsFileMode.OpenFile(), TUtilsFileAccess.ReadWrite())
            destFile.Seek(HttpRange.Zero64(), TUtilsSeekOrigin.Endd())
         Else
            destFile.Open(pPath, TUtilsFileMode.CreateFile(), TUtilsFileAccess.Write())
         End If
         OpenForWrite = destFile
      End Function

      Shared Function OpenForRead(pPath As String) As TFileStream
         Dim srcFile As New TFileStream()
         srcFile.StreamKind = TUtilsStreamKind.Binary()
         srcFile.Open(pPath, TUtilsFileMode.OpenFile(), TUtilsFileAccess.Read())
         OpenForRead = srcFile
      End Function

      Shared Function MaxAdodbBytes() As Int64
         Dim limitText As String = "2147483647"
         MaxAdodbBytes = HttpRange.ParseInt64(limitText)
      End Function

      Shared Function ToAdodbIStream(pPath As String) As Variant
         Dim srcFile As TFileStream = HttpFileIo.OpenForRead(pPath)
         Dim iStream As Variant
         Try
            iStream = HttpFileIo.ToAdodbIStreamFrom(srcFile)
         Catch ex As Exception
            srcFile.Free()
            Throw New Exception(ex._GetMessage())
         End Try
         srcFile.Free()
         ToAdodbIStream = iStream
      End Function

      Shared Function ToAdodbIStreamFrom(pSource As TStream) As Variant
         If pSource.Size > HttpFileIo.MaxAdodbBytes() Then
            Throw New Exception("WinHTTP upload via ADODB IStream cannot exceed 2 GiB. Use Http.Curl with FromFile.")
         End If
         ToAdodbIStreamFrom = HttpFileIo.CopyAdodbWindow(pSource, HttpRange.Zero64(), pSource.Size)
      End Function

      Shared Function ToAdodbIStreamWindow(pSource As TStream, pOffset As Int64, pLength As Integer) As Variant
         Dim take64 As Int64
         If pLength <= 0 Then
            take64 = HttpRange.Zero64()
         Else
            take64 = HttpRange.FromInteger(pLength)
         End If
         ToAdodbIStreamWindow = HttpFileIo.CopyAdodbWindow(pSource, pOffset, take64)
      End Function

      Shared Function CopyAdodbWindow(pSource As TStream, pOffset As Int64, pLength As Int64) As Variant
         Dim savedPos As Int64 = pSource.Position
         Dim filled As Variant
         Dim copyFailed As Boolean = False
         Dim copyErr As String = ""
         Try
            filled = HttpFileIo.FillAdodb(pSource, pOffset, pLength)
         Catch copyEx As Exception
            copyFailed = True
            copyErr = copyEx._GetMessage()
         End Try
         pSource.Position = savedPos
         If copyFailed Then
            Throw New Exception(copyErr)
         End If
         CopyAdodbWindow = filled
      End Function

      Shared Function FillAdodb(pSource As TStream, pOffset As Int64, pLength As Int64) As Variant
         Dim iStream As Variant = CreateObject("ADODB.Stream")
         Dim chunk As Variant
         Dim remaining As Int64
         Dim take As Integer
         Dim posBefore As Int64
         iStream.Type = 1
         iStream.Open()
         If pLength <= HttpRange.Zero64() Then
            iStream.Position = 0
            FillAdodb = iStream
            Exit Function
         End If
         If pLength > HttpFileIo.MaxAdodbBytes() Then
            HttpFileIo.ReleaseAdodb(iStream)
            Throw New Exception("WinHTTP upload via ADODB IStream cannot exceed 2 GiB. Use Http.Curl with FromFile.")
         End If
         pSource.Seek(pOffset, TUtilsSeekOrigin.Begin())
         remaining = pLength
         While remaining > HttpRange.Zero64()
            If pSource.EOF Then
               Exit While
            End If
            take = HttpRange.ChunkTake(remaining, HttpFileIo.ChunkBytes())
            If take <= 0 Then
               Exit While
            End If
            posBefore = pSource.Position
            chunk = pSource.Read(take)
            If IsEmpty(chunk) Then
               Exit While
            End If
            iStream.Write(chunk)
            remaining = remaining - (pSource.Position - posBefore)
         End While
         iStream.Position = 0
         FillAdodb = iStream
      End Function

      Shared Sub ReleaseAdodb(ByRef pStream As Variant)
         Dim kind As String = TypeName(pStream)
         If (kind = "Empty") Or (kind = "Null") Or (kind = "Unassigned") Then
            Exit Sub
         End If
         Try
            pStream.Close()
         Catch closeEx As Exception
         End Try
         pStream = Unassigned
      End Sub

      Shared Function OpenCreateNew(pPath As String) As TFileStream
         Dim destFile As New TFileStream()
         destFile.StreamKind = TUtilsStreamKind.Binary()
         destFile.Open(pPath, TUtilsFileMode.CreateNew(), TUtilsFileAccess.Write())
         OpenCreateNew = destFile
      End Function

      Shared Function SizeOf(pPath As String) As Int64
         Dim srcFile As TFileStream
         If Not TFile.Exists(pPath) Then
            SizeOf = HttpRange.Zero64()
            Exit Function
         End If
         srcFile = New TFileStream()
         srcFile.StreamKind = TUtilsStreamKind.Binary()
         srcFile.Open(pPath, TUtilsFileMode.OpenFile(), TUtilsFileAccess.Read())
         SizeOf = srcFile.Size
         srcFile.Free()
      End Function

      Shared Sub WritePayload(pDest As TFileStream, pData As Variant)
         Dim kind As String = TypeName(pData)
         If (kind = "Empty") Or (kind = "Null") Or (kind = "Unassigned") Then
            Exit Sub
         End If
         If kind = "String" Then
            If CStr(pData) = "" Then
               Exit Sub
            End If
            pDest.StreamKind = TUtilsStreamKind.Text()
            pDest.Charset = TUtilsCharset.Latin1()
            pDest.WriteText(CStr(pData))
            pDest.StreamKind = TUtilsStreamKind.Binary()
         Else
            pDest.Write(pData)
         End If
         pDest.Flush()
      End Sub

      Shared Sub WriteUtf8Text(pDest As TFileStream, pText As String)
         If pText = "" Then
            Exit Sub
         End If
         pDest.StreamKind = TUtilsStreamKind.Text()
         pDest.Charset = TUtilsCharset.UTF8()
         pDest.WriteText(pText)
         pDest.StreamKind = TUtilsStreamKind.Binary()
         pDest.Flush()
      End Sub

      Shared Function WriteBytesToTemp(pData As Variant) As String
         Dim path As String = TPath.GetTempFileName()
         Dim destFile As TFileStream = HttpFileIo.OpenForWrite(path, False)
         HttpFileIo.WritePayload(destFile, pData)
         HttpFileIo.Release(destFile)
         WriteBytesToTemp = path
      End Function

      Shared Function SpoolToTempFile(pStream As Variant) As String
         Dim path As String = TPath.GetTempFileName()
         Dim destFile As TFileStream = HttpFileIo.OpenForWrite(path, False)
         HttpFileIo.CopyFrom(pStream, destFile)
         HttpFileIo.Release(destFile)
         SpoolToTempFile = path
      End Function

      Shared Function SpoolDisk(pSource As TStream) As String
         Dim path As String = TPath.GetTempFileName()
         Dim destFile As TFileStream = HttpFileIo.OpenForWrite(path, False)
         Dim savedPos As Int64 = pSource.Position
         Dim copyFailed As Boolean = False
         Dim copyErr As String = ""
         Try
            pSource.Seek(HttpRange.Zero64(), TUtilsSeekOrigin.Begin())
            pSource.CopyTo(destFile, HttpFileIo.ChunkBytes())
         Catch copyEx As Exception
            copyFailed = True
            copyErr = copyEx._GetMessage()
         End Try
         pSource.Position = savedPos
         HttpFileIo.Release(destFile)
         If copyFailed Then
            Throw New Exception(copyErr)
         End If
         SpoolDisk = path
      End Function

      Shared Sub CopyFrom(pSource As Variant, pDest As TFileStream)
         Dim kind As String = TypeName(pSource)
         If (kind = "Empty") Or (kind = "Null") Or (kind = "Unassigned") Then
            Exit Sub
         End If
         If (kind = "TFileStream") Or (kind = "TMemoryStream") Then
            Throw New Exception("Spool TFileStream/TMemoryStream with a typed variable via CopyTo, or use HttpBody.FromFile. Variant cannot CType to TFileStream.")
         End If
         HttpFileIo.CopyAdodb(pSource, pDest)
      End Sub

      Shared Sub CopyAdodb(pSource As Variant, pDest As TFileStream)
         Dim chunk As Variant
         pSource.Position = 0
         While True
            If pSource.EOS Then
               Exit While
            End If
            chunk = pSource.Read(HttpFileIo.ChunkBytes())
            If IsEmpty(chunk) Then
               Exit While
            End If
            pDest.Write(chunk)
         End While
         pDest.Flush()
         pSource.Position = 0
      End Sub

      Shared Sub Release(ByRef pDest As TFileStream)
         If Assigned(pDest) Then
            Try
               pDest.Flush()
            Catch flushEx As Exception
            End Try
            pDest.Free()
            pDest = Null
         End If
      End Sub

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
