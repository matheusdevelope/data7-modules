Imports mod_tobject
Imports google_drive_chunk_source
Imports google_drive_json

Namespace google_drive_memory_stream

   Class GoogleDriveMemoryStream
      Inherits GoogleDriveChunkSource

      Private _data As Variant
      Private _size As Int64

      Sub New(pData As Variant)
         MyBase.New()
         me._data = pData
         me._size = me.Measure(pData)
      End Sub

      Overrides Function Size() As Int64
         Size = me._size
      End Function

      Overrides Function ReadChunk(pOffset As Int64, pLength As Integer) As Variant
         If pOffset <= 0 And (GoogleDriveJson.FromInteger(pLength) >= me._size) Then
            ReadChunk = me._data
            Exit Function
         End If
         Dim stream As Variant = CreateObject("ADODB.Stream")
         stream.Type = 1
         stream.Open()
         If TypeName(me._data) = "String" Then
            stream.Type = 2
            stream.Charset = "iso-8859-1"
            stream.WriteText(me._data)
            stream.Position = 0
            stream.Type = 1
         Else
            stream.Write(me._data)
            stream.Position = 0
         End If
         stream.Position = pOffset
         ReadChunk = stream.Read(pLength)
         stream.Close()
         stream = Unassigned
      End Function

      Overrides Sub CopyChunkToStream(pOffset As Int64, pLength As Integer, pDestStream As Variant)
         If pLength <= 0 Then
            Exit Sub
         End If
         Dim source As Variant = CreateObject("ADODB.Stream")
         source.Type = 1
         source.Open()
         If TypeName(me._data) = "String" Then
            source.Type = 2
            source.Charset = "iso-8859-1"
            source.WriteText(me._data)
            source.Position = 0
            source.Type = 1
         Else
            source.Write(me._data)
            source.Position = 0
         End If
         source.Position = CDbl(GoogleDriveJson.Int64Text(pOffset))
         pDestStream.Position = 0
         pDestStream.SetEOS()
         source.CopyTo(pDestStream, pLength)
         source.Close()
         source = Unassigned
      End Sub

      Private Function Measure(pData As Variant) As Int64
         If TypeName(pData) = "String" Then
            Measure = GoogleDriveJson.FromInteger(Len(pData))
            Exit Function
         End If
         Dim stream As Variant = CreateObject("ADODB.Stream")
         stream.Type = 1
         stream.Open()
         stream.Write(pData)
         Measure = GoogleDriveJson.ParseInt64(CStr(stream.Size))
         stream.Close()
         stream = Unassigned
      End Function

      Overrides Sub Dispose()
         me._data = Unassigned
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
