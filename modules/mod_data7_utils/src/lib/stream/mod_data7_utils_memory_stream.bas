Imports mod_data7_utils_stream
Imports mod_data7_utils_stream_enums

Namespace mod_data7_utils_memory_stream

   Class TMemoryStream
      Inherits TStream

      Sub New()
         MyBase.New("Data7Utils.MemoryStream")
      End Sub

      Sub Open()
         me.COM.Open()
      End Sub

      Sub Open(pData As Variant)
         me.COM.Open(pData)
      End Sub

      Sub LoadFromFile(pPath As String)
         me.COM.LoadFromFile(pPath, TUtilsFileMode.OpenFile.AsInteger, TUtilsFileAccess.Read.AsInteger)
      End Sub

      Sub LoadFromFile(pPath As String, pMode As TUtilsFileMode)
         me.COM.LoadFromFile(pPath, pMode.AsInteger, TUtilsFileAccess.Read.AsInteger)
      End Sub

      Sub LoadFromFile(pPath As String, pMode As TUtilsFileMode, pAccess As TUtilsFileAccess)
         me.COM.LoadFromFile(pPath, pMode.AsInteger, pAccess.AsInteger)
      End Sub

      Sub LoadFromFile(pPath As String, pMode As Integer)
         me.COM.LoadFromFile(pPath, pMode, TUtilsFileAccess.Read.AsInteger)
      End Sub

      Sub LoadFromFile(pPath As String, pMode As Integer, pAccess As Integer)
         me.COM.LoadFromFile(pPath, pMode, pAccess)
      End Sub

      Sub SaveToFile(pPath As String)
         me.COM.SaveToFile(pPath)
      End Sub

      Function ToArray() As Variant
         ToArray = me.COM.ToArray
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
