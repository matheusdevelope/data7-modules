Imports Collections
Imports mod_tobject

Namespace mod_wa_api_result

   Class WaApiResult
      Inherits TTObject

      Success As Boolean
      StatusCode As Integer
      Message As String
      Raw As String
      ClientName As String

      Sub New()
         MyBase.New()
         me.Success = False
         me.StatusCode = 0
      End Sub

      Shared Function Ok(pClient As String, pRaw As String, pStatus As Integer = 200) As WaApiResult
         Dim _result As New WaApiResult()
         _result.Success = True
         _result.ClientName = pClient
         _result.Raw = pRaw
         _result.StatusCode = pStatus
         _result.Message = "OK"
         Ok = _result
      End Function

      Shared Function Fail(pClient As String, pMessage As String, pStatus As Integer = 0, pRaw As String = "") As WaApiResult
         Dim _result As New WaApiResult()
         _result.Success = False
         _result.ClientName = pClient
         _result.Message = pMessage
         _result.StatusCode = pStatus
         _result.Raw = pRaw
         Fail = _result
      End Function

      Function AsJson() As TJSONObject
         Try
            If me.Raw <> "" Then
               AsJson = New TJSONObject(me.Raw)
            Else
               AsJson = New TJSONObject()
            End If
         Catch ex As Exception
            Return New TJSONObject()
         End Try
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaApiResult")
            .Prop("Success", me.Success)
            .Prop("StatusCode", me.StatusCode)
            .Prop("ClientName", me.ClientName)
            .Prop("Message", me.Message)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
