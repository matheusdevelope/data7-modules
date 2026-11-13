Imports http_request
Imports http_response

Namespace http_transport

   Class IHttpTransport

      Sub New()
         MyBase.New()
      End Sub

      Overridable Function Send(pReq As HttpRequest) As HttpResponse
         Throw New Exception("Send must be implemented by the transport.")
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
