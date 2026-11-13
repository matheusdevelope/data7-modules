Imports http_form
Imports mod_tobject

Namespace http_body

   Class HttpBody
      Inherits TTObject

      Private _kind As String
      Private _text As String
      Private _bytes As Variant
      Private _form As FormData
      Private _contentType As String
      Private _ownsForm As Boolean

      Sub New()
         MyBase.New()
         me._kind = "empty"
         me._contentType = ""
         me._ownsForm = False
      End Sub

      Shared Function FromText(pText As String, pContentType As String = "text/plain") As HttpBody
         Dim body As New HttpBody()
         body._kind = "text"
         body._text = pText
         body._contentType = pContentType
         FromText = body
      End Function

      Shared Function FromJson(pJson As String) As HttpBody
         Dim body As HttpBody = HttpBody.FromText(pJson, "application/json")
         body._kind = "json"
         FromJson = body
      End Function

      Shared Function FromJson(pJson As TJSONObject) As HttpBody
         Dim jsonText As String = pJson.ToString()
         Dim body As HttpBody = HttpBody.FromJson(jsonText)
         FromJson = body
      End Function

      Shared Function FromBytes(pBytes As Variant, pContentType As String = "application/octet-stream") As HttpBody
         Dim body As New HttpBody()
         body._kind = "bytes"
         body._bytes = pBytes
         body._contentType = pContentType
         FromBytes = body
      End Function

      Shared Function FromForm(pForm As FormData, pOwnsForm As Boolean = False) As HttpBody
         Dim body As New HttpBody()
         body._kind = "form"
         body._form = pForm
         body._ownsForm = pOwnsForm
         body._contentType = pForm.ContentTypeHeader
         FromForm = body
      End Function

      Property Kind As String
         Get
            Kind = me._kind
         End Get
      End Property

      Property ContentType As String
         Get
            ContentType = me._contentType
         End Get
      End Property

      Property IsEmpty As Boolean
         Get
            IsEmpty = me._kind = "empty"
         End Get
      End Property

      Property IsText As Boolean
         Get
            IsText = me._kind = "text" Or me._kind = "json"
         End Get
      End Property

      Property IsJson As Boolean
         Get
            IsJson = me._kind = "json" Or (me.IsText And me.AsText().Trim().StartsWith("{") And me.AsText().Trim().EndsWith("}"))
         End Get
      End Property

      Property IsBytes As Boolean
         Get
            IsBytes = me._kind = "bytes"
         End Get
      End Property

      Property IsForm As Boolean
         Get
            IsForm = me._kind = "form"
         End Get
      End Property

      Property Form As FormData
         Get
            Form = me._form
         End Get
      End Property

      Function AsText() As String
         If me._kind = "bytes" Then
            AsText = ""
            Exit Function
         End If
         If me._kind = "form" Then
            AsText = ""
            Exit Function
         End If
         AsText = me._text
      End Function

      Function AsJson() As TJSONObject
         If Not me.IsJson Then
            Throw New Exception("Body is not a valid JSON Object")
         End If
         AsJson = New TJSONObject(me.AsText())
      End Function

      Function Raw() As Variant
         If me._kind = "form" Then
            Raw = me._form.Data()
         ElseIf me._kind = "bytes" Then
            Raw = me._bytes
         Else
            Raw = me._text
         End If
      End Function

      Overrides Function ToString() As String
         Dim asText As String
         If me.IsText Then
            asText = me.AsText()
         Else
            asText = "(binary/form)"
         End If
         With me.BuildLogger("Http Body")
            .Prop("Kind", me._kind)
            .Prop("ContentType", me._contentType)
            .Prop("AsText", asText)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If me._ownsForm And Assigned(me._form) Then
            me._form.Free()
            me._form = NULL
         End If
         me._text = ""
         me._bytes = ""
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
