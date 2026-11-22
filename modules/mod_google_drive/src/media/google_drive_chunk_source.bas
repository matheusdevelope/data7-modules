Imports mod_tobject
Imports mod_data7_utils_file_stream

Namespace google_drive_chunk_source

   MustInherit Class GoogleDriveChunkSource
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function Size() As Int64
         Throw New Exception("Size must be implemented.")
      End Function

      Overridable Function SourcePath() As String
         SourcePath = ""
      End Function

      Overridable Function DiskFile() As TFileStream
         DiskFile = Null
      End Function

      Overridable Function ReadChunk(pOffset As Int64, pLength As Integer) As Variant
         Throw New Exception("ReadChunk must be implemented.")
      End Function

      Overridable Sub CopyChunkToStream(pOffset As Int64, pLength As Integer, pDestStream As Variant)
         Throw New Exception("CopyChunkToStream must be implemented.")
      End Sub

      Overridable Sub WriteChunkToFile(pOffset As Int64, pLength As Integer, pDestPath As String)
         Throw New Exception("WriteChunkToFile must be implemented.")
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
