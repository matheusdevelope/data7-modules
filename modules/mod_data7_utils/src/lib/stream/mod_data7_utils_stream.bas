Imports mod_data7_utils_runtime
Imports mod_data7_utils_stream_enums
Imports mod_data7_utils_int64

Namespace mod_data7_utils_stream

   Class TStream
      Inherits TComRuntime

      Sub New(pProgId As String)
         MyBase.New(pProgId)
      End Sub

      Property Position As Int64
         Get
            Position = UtilsParseInt64(CStr(me.COM.PositionText))
         End Get
         Set(pValue As Int64)
            me.SetPosition(pValue)
         End Set
      End Property

      Private Sub SetPosition(pValue As Int64)
         me.COM.PositionText = UtilsInt64Text(pValue)
      End Sub

      Property EOF As Boolean
         Get
            Return me.COM.EOF
         End Get
      End Property

      Property Size As Int64
         Get
            Size = UtilsParseInt64(CStr(me.COM.LengthText))
         End Get
      End Property

      Property StreamKind As TUtilsStreamKind
         Get
            StreamKind = TUtilsStreamKind.Load(CInt(me.COM.Type))
         End Get
         Set(pValue As TUtilsStreamKind)
            me.SetStreamKind(pValue)
         End Set
      End Property

      Property Charset As TUtilsCharset
         Get
            Charset = TUtilsCharset.Load(CInt(me.COM.Charset))
         End Get
         Set(pValue As TUtilsCharset)
            me.SetCharset(pValue)
         End Set
      End Property

      Private Sub SetStreamKind(pValue As TUtilsStreamKind)
         me.COM.Type = pValue.AsInteger
      End Sub

      Private Sub SetCharset(pValue As TUtilsCharset)
         me.COM.Charset = pValue.AsInteger
      End Sub

      Sub Seek(pOffset As Int64, pOrigin As TUtilsSeekOrigin)
         me.COM.SeekText(UtilsInt64Text(pOffset), pOrigin.AsInteger)
      End Sub

      Function Read(pSize As Integer) As Variant
         Read = me.COM.Read(pSize)
      End Function

      Function ReadAll() As Variant
         ReadAll = me.COM.ReadAll
      End Function

      Function ReadText(pSize As Integer) As String
         ReadText = me.COM.ReadText(pSize)
      End Function

      Function ReadTextAll() As String
         ReadTextAll = me.COM.ReadAllText
      End Function

      Sub Write(pData As Variant)
         me.COM.Write(pData)
      End Sub

      Sub WriteText(pText As String)
         me.COM.WriteText(pText)
      End Sub

      Sub Flush()
         me.COM.Flush()
      End Sub

      Sub Close()
         me.COM.Close()
      End Sub

      Sub CopyTo(pStream As TStream, pChunkSize As Integer = -1)
         me.COM.CopyTo(pStream.ComHandle(), pChunkSize)
      End Sub

      Sub Free()
         If Not IsEmpty(me.COM) Then
            me.Close()
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
