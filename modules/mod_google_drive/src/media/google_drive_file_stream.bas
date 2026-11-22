Imports TFile
Imports mod_tobject
Imports mod_data7_utils_file_stream
Imports mod_data7_utils_stream_enums
Imports http_file_io
Imports google_drive_chunk_source
Imports google_drive_errors
Imports google_drive_json

Namespace google_drive_file_stream

   Class GoogleDriveFileStream
      Inherits GoogleDriveChunkSource

      Private _path As String
      Private _size As Int64
      Private _diskFile As TFileStream
      Private _opened As Boolean

      Sub New(pPath As String)
         MyBase.New()
         If Trim(pPath) = "" Then
            Throw New Exception(GoogleDriveErrors.PathRequired())
         End If
         If Not TFile.Exists(pPath) Then
            Throw New Exception(GoogleDriveErrors.FileNotFound(pPath))
         End If
         me._path = pPath
         me._size = GoogleDriveJson.Zero64()
         me._diskFile = Null
         me._opened = False
         me.OpenSource()
      End Sub

      Overrides Function Size() As Int64
         Size = me._size
      End Function

      Overrides Function SourcePath() As String
         SourcePath = me._path
      End Function

      Overrides Function DiskFile() As TFileStream
         DiskFile = me._diskFile
      End Function

      Overrides Function ReadChunk(pOffset As Int64, pLength As Integer) As Variant
         If Not me._opened Then
            Throw New Exception(GoogleDriveErrors.FileOpenFailed(me._path))
         End If
         If pLength <= 0 Then
            ReadChunk = Unassigned
            Exit Function
         End If
         me.SeekTo(pOffset)
         ReadChunk = me._diskFile.Read(pLength)
      End Function

      Overrides Sub CopyChunkToStream(pOffset As Int64, pLength As Integer, pDestStream As Variant)
         Dim chunk As Variant
         If Not me._opened Then
            Throw New Exception(GoogleDriveErrors.FileOpenFailed(me._path))
         End If
         If pLength <= 0 Then
            Exit Sub
         End If
         me.SeekTo(pOffset)
         pDestStream.Position = 0
         pDestStream.SetEOS()
         chunk = me._diskFile.Read(pLength)
         If Not IsEmpty(chunk) Then
            pDestStream.Write(chunk)
         End If
      End Sub

      Overrides Sub WriteChunkToFile(pOffset As Int64, pLength As Integer, pDestPath As String)
         Dim destFile As TFileStream = HttpFileIo.OpenForWrite(pDestPath, False)
         Dim chunk As Variant = me.ReadChunk(pOffset, pLength)
         HttpFileIo.WritePayload(destFile, chunk)
         HttpFileIo.Release(destFile)
      End Sub

      Private Sub SeekTo(pOffset As Int64)
         me._diskFile.Seek(pOffset, TUtilsSeekOrigin.Begin())
      End Sub

      Private Sub OpenSource()
         me._diskFile = HttpFileIo.OpenForRead(me._path)
         me._size = me._diskFile.Size
         me._opened = True
      End Sub

      Overrides Sub Dispose()
         If Assigned(me._diskFile) Then
            me._diskFile.Free()
            me._diskFile = Null
         End If
         me._opened = False
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
