Imports mod_data7_utils_stream
Imports mod_data7_utils_stream_enums

Namespace mod_data7_utils_file_stream

   Class TFileStream
      Inherits TStream

      Sub New()
         MyBase.New("Data7Utils.FileStream")
      End Sub

      Sub Open(pPath As String)
         me.COM.Open(pPath, TUtilsFileMode.OpenFile.AsInteger, TUtilsFileAccess.Read.AsInteger)
      End Sub

      Sub Open(pPath As String, pMode As TUtilsFileMode)
         me.COM.Open(pPath, pMode.AsInteger, TUtilsFileAccess.Read.AsInteger)
      End Sub

      Sub Open(pPath As String, pMode As TUtilsFileMode, pAccess As TUtilsFileAccess)
         me.COM.Open(pPath, pMode.AsInteger, pAccess.AsInteger)
      End Sub

      Sub Open(pPath As String, pMode As Integer)
         me.COM.Open(pPath, pMode, TUtilsFileAccess.Read.AsInteger)
      End Sub

      Sub Open(pPath As String, pMode As Integer, pAccess As Integer)
         me.COM.Open(pPath, pMode, pAccess)
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
