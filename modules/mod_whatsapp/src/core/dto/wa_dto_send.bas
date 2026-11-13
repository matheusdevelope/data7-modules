Imports Collections
Imports mod_tobject

Namespace mod_wa_dto_send

   Function WaDtoSendStringListToJsonArray(pList As StringList) As String
      Dim s As String = "["
      If Assigned(pList) Then
         Dim i As Integer
         For i = 0 To pList.Count - 1
            If i > 0 Then
               s = s + ","
            End If
            s = s + pList.Strings(i).Quoted()
         Next
      End If
      s = s + "]"
      WaDtoSendStringListToJsonArray = s
   End Function

   Class WaSendTextRequest
      Inherits TTObject

      Number As String
      Text As String
      LinkPreview As Boolean
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.LinkPreview = True
         me.Delay = 0
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("text", me.Text)
         _json.PutBoolean("linkPreview", me.LinkPreview)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("text", me.Text)
         _json.PutInteger("delay", me.Delay)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendMediaRequest
      Inherits TTObject

      Number As String
      MediaType As String
      MimeType As String
      Caption As String
      Media As String
      FileName As String
      GoType As String
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.Delay = 0
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         If me.MediaType <> "" Then
            _json.PutString("mediatype", me.MediaType)
         End If
         If me.MimeType <> "" Then
            _json.PutString("mimetype", me.MimeType)
         End If
         If me.Caption <> "" Then
            _json.PutString("caption", me.Caption)
         End If
         _json.PutString("media", me.Media)
         If me.FileName <> "" Then
            _json.PutString("fileName", me.FileName)
         End If
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         If me.GoType <> "" Then
            _json.PutString("type", me.GoType)
         ElseIf me.MediaType <> "" Then
            _json.PutString("type", me.MediaType)
         End If
         If me.Caption <> "" Then
            _json.PutString("caption", me.Caption)
         End If
         If me.FileName <> "" Then
            _json.PutString("fileName", me.FileName)
         End If
         _json.PutString("url", me.Media)
         _json.PutInteger("delay", me.Delay)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendLocationRequest
      Inherits TTObject

      Number As String
      Name As String
      Address As String
      Latitude As Double
      Longitude As Double
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.Delay = 0
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         If me.Name <> "" Then
            _json.PutString("name", me.Name)
         End If
         If me.Address <> "" Then
            _json.PutString("address", me.Address)
         End If
         _json.PutDouble("latitude", me.Latitude)
         _json.PutDouble("longitude", me.Longitude)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         If me.Name <> "" Then
            _json.PutString("name", me.Name)
         End If
         If me.Address <> "" Then
            _json.PutString("address", me.Address)
         End If
         _json.PutDouble("latitude", me.Latitude)
         _json.PutDouble("longitude", me.Longitude)
         _json.PutInteger("delay", me.Delay)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendContactRequest
      Inherits TTObject

      Number As String
      FullName As String
      Phone As String
      Organization As String
      Email As String
      Url As String
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.Delay = 0
      End Sub

      Function ToJsonEvolution() As String
         Dim _item As New TJSONObject()
         _item.PutString("fullName", me.FullName)
         If me.Phone <> "" Then
            _item.PutString("wuid", me.Phone)
            _item.PutString("phoneNumber", me.Phone)
         End If
         If me.Organization <> "" Then
            _item.PutString("organization", me.Organization)
         End If
         If me.Email <> "" Then
            _item.PutString("email", me.Email)
         End If
         If me.Url <> "" Then
            _item.PutString("url", me.Url)
         End If

         Dim _arr As TJSONArray =New TJSONArray("[" + _item.ToString() + "]")
         _item.Free()

         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutArray("contact", _arr)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _vcard As New TJSONObject()
         _vcard.PutString("fullName", me.FullName)
         If me.Phone <> "" Then
            _vcard.PutString("phone", me.Phone)
         End If
         If me.Organization <> "" Then
            _vcard.PutString("organization", me.Organization)
         End If

         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutObject("vcard", _vcard)
         _json.PutInteger("delay", me.Delay)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendStickerRequest
      Inherits TTObject

      Number As String
      Sticker As String
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.Delay = 0
      End Sub

      Function ToJsonEvolution() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("sticker", me.Sticker)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("sticker", me.Sticker)
         _json.PutInteger("delay", me.Delay)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendPollRequest
      Inherits TTObject

      Number As String
      Name As String
      Question As String
      SelectableCount As Integer
      MaxAnswer As Integer
      Values As StringList
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.SelectableCount = 1
         me.MaxAnswer = 1
         me.Delay = 0
         me.Values = New StringList()
      End Sub

      Function ToJsonEvolution() As String
         Dim _name As String = me.Name
         If _name = "" Then
            _name = me.Question
         End If
         Dim _arr As TJSONArray =New TJSONArray(WaDtoSendStringListToJsonArray(me.Values))
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("name", _name)
         _json.PutInteger("selectableCount", me.SelectableCount)
         _json.PutArray("values", _arr)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         Dim _question As String = me.Question
         If _question = "" Then
            _question = me.Name
         End If
         Dim _max As Integer = me.MaxAnswer
         If _max <= 0 Then
            _max = me.SelectableCount
         End If
         Dim _arr As TJSONArray =New TJSONArray(WaDtoSendStringListToJsonArray(me.Values))
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         _json.PutString("question", _question)
         _json.PutInteger("maxAnswer", _max)
         _json.PutArray("options", _arr)
         _json.PutInteger("delay", me.Delay)
         ToJsonEvolutionGo = _json.ToString()
         _json.Free()
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Values) Then
            me.Values.Free()
            me.Values = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendButtonsRequest
      Inherits TTObject

      Number As String
      Title As String
      Description As String
      Footer As String
      ButtonsJson As String
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.Delay = 0
         me.ButtonsJson = "[]"
      End Sub

      Function ToJsonEvolution() As String
         Dim _buttons As String = me.ButtonsJson
         If _buttons = "" Then
            _buttons = "[]"
         End If
         Dim _arr As TJSONArray =New TJSONArray(_buttons)
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         If me.Title <> "" Then
            _json.PutString("title", me.Title)
         End If
         If me.Description <> "" Then
            _json.PutString("description", me.Description)
         End If
         If me.Footer <> "" Then
            _json.PutString("footer", me.Footer)
         End If
         _json.PutArray("buttons", _arr)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         ToJsonEvolutionGo = me.ToJsonEvolution()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendListRequest
      Inherits TTObject

      Number As String
      Title As String
      Description As String
      ButtonText As String
      FooterText As String
      SectionsJson As String
      Delay As Integer
      Instance As String

      Sub New()
         MyBase.New()
         me.Delay = 0
         me.SectionsJson = "[]"
      End Sub

      Function ToJsonEvolution() As String
         Dim _sections As String = me.SectionsJson
         If _sections = "" Then
            _sections = "[]"
         End If
         Dim _arr As TJSONArray =New TJSONArray(_sections)
         Dim _json As New TJSONObject()
         _json.PutString("number", me.Number)
         If me.Title <> "" Then
            _json.PutString("title", me.Title)
         End If
         If me.Description <> "" Then
            _json.PutString("description", me.Description)
         End If
         If me.ButtonText <> "" Then
            _json.PutString("buttonText", me.ButtonText)
         End If
         If me.FooterText <> "" Then
            _json.PutString("footerText", me.FooterText)
         End If
         _json.PutArray("sections", _arr)
         If me.Delay > 0 Then
            _json.PutInteger("delay", me.Delay)
         End If
         ToJsonEvolution = _json.ToString()
         _json.Free()
      End Function

      Function ToJsonEvolutionGo() As String
         ToJsonEvolutionGo = me.ToJsonEvolution()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
