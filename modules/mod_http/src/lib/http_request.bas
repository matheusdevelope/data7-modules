Imports mod_tobject
Imports http_enums
Imports http_headers
Imports http_body
Imports mod_certificate

Namespace http_request

   Class HttpRequest
      Inherits TTObject

      Method As HttpMethod
      Url As String
      Timeout As Integer = 10000
      ReadOnly Headers As HttpHeaders
      ReadOnly Body As HttpBody
      Certificate As TCertificate

      Sub New(pMethod As HttpMethod, pUrl As String, pHeaders As HttpHeaders, pBody As HttpBody, pCertificate As TCertificate, pTimeout As Integer)
         MyBase.New()
         me.Method = pMethod
         me.Url = pUrl
         me.Headers = pHeaders
         me.Body = pBody
         me.Certificate = pCertificate
         me.Timeout = pTimeout
      End Sub

      Property Verb As String
         Get
            If Assigned(me.Method) Then
               Verb = me.Method.AsString
            Else
               Verb = "GET"
            End If
         End Get
      End Property

      Overrides Function ToString() As String
         With me.BuildLogger("Http Request")
            .Prop("Method", me.Verb)
            .Prop("Url", me.Url)
            .Prop("Timeout", me.Timeout)
            If Assigned(me.Headers) Then
               .Prop("Headers", me.Headers.ToString())
            End If
            If Assigned(me.Body) Then
               .Prop("Body", me.Body.ToString())
            End If
            If Assigned(me.Certificate) Then
               .Prop("Certificate", me.Certificate.ToString())
            End If
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Headers) Then
            me.Headers.Free()
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
