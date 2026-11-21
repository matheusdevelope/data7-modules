Namespace mod_data7_utils_socket_event

   Class TSocketEvent

      Private COM As Variant

      Sub New(pCom As Variant)
         MyBase.New()
         me.COM = pCom
      End Sub

      Property Name As String
         Get
            Return me.COM.EventName
         End Get
      End Property

      Function Data() As Variant
         Data = me.COM.Data
      End Function

      Property HasData As Boolean
         Get
            Return me.COM.HasData
         End Get
      End Property

      Function IsText() As Boolean
         IsText = me.COM.IsText
      End Function

      Function AsText() As String
         AsText = me.COM.AsText
      End Function

      Function IsJson() As Boolean
         IsJson = me.COM.IsJson
      End Function

      Function AsJson() As String
         AsJson = me.COM.AsJson
      End Function

      Function SaveToFile(pFilePath As String) As Boolean
         SaveToFile = me.COM.SaveToFile(pFilePath)
      End Function

      Sub Free()
         me.COM = Unassigned
         MyBase.Free()
      End Sub

   End Class

End Namespace
