Imports http_form
Imports mod_tobject

Namespace http_body

   Class HttpBody
      Inherits TTObject

      Private _kind As String
      Private _text As String
      Private _bytes As Variant
      Private _filePath As String
      Private _payloadStream As Variant
      Private _form As FormData
      Private _contentType As String
      Private _ownsForm As Boolean
      Private _ownsStream As Boolean

      Sub New()
         MyBase.New()
         me._kind = "empty"
         me._contentType = ""
         me._ownsForm = False
         me._ownsStream = False
         me._payloadStream = Unassigned
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

      Shared Function FromFile(pPath As String, pContentType As String = "application/octet-stream") As HttpBody
         Dim body As New HttpBody()
         body._kind = "file"
         body._filePath = pPath
         body._contentType = pContentType
         FromFile = body
      End Function

      Shared Function FromStream(pStream As Variant, pContentType As String = "application/octet-stream", pOwnsStream As Boolean = False) As HttpBody
         Dim body As New HttpBody()
         body._kind = "stream"
         body._payloadStream = pStream
         body._ownsStream = pOwnsStream
         body._contentType = pContentType
         FromStream = body
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

      Property IsFile As Boolean
         Get
            IsFile = me._kind = "file"
         End Get
      End Property

      Property IsStream As Boolean
         Get
            IsStream = me._kind = "stream"
         End Get
      End Property

      Property FilePath As String
         Get
            FilePath = me._filePath
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
         If me._kind = "file" Then
            AsText = ""
            Exit Function
         End If
         If me._kind = "stream" Then
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
         ElseIf me._kind = "file" Then
            Raw = me._filePath
         ElseIf me._kind = "stream" Then
            Raw = me._payloadStream
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
         me.ReleaseStream()
         me._text = ""
         me._bytes = Unassigned
         me._filePath = ""
      End Sub

      Private Sub ReleaseStream()
         If me._ownsStream Then
            Dim kind As String = TypeName(me._payloadStream)
            If (kind <> "Empty") And (kind <> "Null") And (kind <> "Unassigned") Then
               Try
                  me._payloadStream.Close()
               Catch ex As Exception
               End Try
            End If
         End If
         me._payloadStream = Unassigned
         me._ownsStream = False
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
