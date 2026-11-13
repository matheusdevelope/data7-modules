Imports Collections

Namespace http_form

   Class FormDataPart

      Name As String
      Value As String
      ValueRaw As Variant
      ContentType As String
      CharSet As String
      Filename As String
      IsFile As Boolean

      Sub New(pName As String, pValue As String, pContentType As String, pCharSet As String, pIsFile As Boolean, pFilename As String = "")
         MyBase.New()
         me.Name = pName
         me.Value = pValue
         me.ContentType = pContentType
         me.CharSet = pCharSet
         me.Filename = pFilename
         me.IsFile = pIsFile
      End Sub

      Sub New(pName As String, pValue As Variant, pContentType As String, pFilename As String)
         MyBase.New()
         me.Name = pName
         me.ValueRaw = pValue
         me.ContentType = pContentType
         me.Filename = pFilename
         me.IsFile = True
      End Sub

      Sub Free()
         me.Name = ""
         me.Value = ""
         me.ValueRaw = ""
         me.ContentType = ""
         me.CharSet = ""
         me.IsFile = False
         MyBase.Free()
      End Sub

   End Class

   Class FormData

      Private _parts As StringList
      Private _boundary As String
      Private _charset As String

      Sub New()
         MyBase.New()
         me._parts = New StringList()
         me._parts.OwnsObjects = True
         me._boundary = Data7.Criptografar(me.GetHashCode.ToString())
         me._charset = "ascii"
      End Sub

      Property Boundary As String
         Get
            Boundary = me._boundary
         End Get
         Set(pValue As String)
            me._boundary = pValue
         End Set
      End Property

      Property Charset As String
         Get
            Charset = me._charset
         End Get
         Set(pValue As String)
            me._charset = pValue
         End Set
      End Property

      Property ContentTypeHeader As String
         Get
            ContentTypeHeader = "multipart/form-data; boundary=" & me._boundary
         End Get
      End Property

      Sub Append(pName As String, pValue As String, pContentType As String = "plain/text", pCharSet As String = "")
         me.Add(New FormDataPart(pName, pValue, pContentType, pCharSet, False))
      End Sub

      Sub AppendFile(pName As String, pValue As String, pContentType As String, pFilename As String = "")
         me.Add(New FormDataPart(pName, pValue, pContentType, "", True, pFilename))
      End Sub

      Sub AppendFile(pName As String, pValue As Variant, pContentType As String, pFilename As String)
         me.Add(New FormDataPart(pName, pValue, pContentType, pFilename))
      End Sub

      Sub Sett(pName As String, pValue As String, pContentType As String = "plain/text", pCharSet As String = "")
         me.Delete(pName)
         me.Add(New FormDataPart(pName, pValue, pContentType, pCharSet, False))
      End Sub

      Sub SetFile(pName As String, pValue As String, pContentType As String, pFilename As String = "")
         me.Delete(pName)
         me.Add(New FormDataPart(pName, pValue, pContentType, "", True, pFilename))
      End Sub

      Sub SetFile(pName As String, pValue As Variant, pContentType As String, pFilename As String)
         me.Delete(pName)
         me.Add(New FormDataPart(pName, pValue, pContentType, pFilename))
      End Sub

      Private Sub Add(pPart As FormDataPart)
         me._parts.AddObject(pPart.Name, pPart)
      End Sub

      Function Gett(pName As String) As FormDataPart
         Dim idx As Integer = me._parts.IndexOf(pName)
         If idx >= 0 Then
            Gett = CType(me._parts.Objects(idx), FormDataPart)
            Exit Function
         End If
         Gett = NULL
      End Function

      Function GetAll(pName As String) As StringList
         Dim list As New StringList()
         Dim i As Integer
         Dim count As Integer = me.Count()
         For i = 0 To count - 1
            Dim part As FormDataPart = CType(me._parts.Objects(i), FormDataPart)
            If part.Name = pName Then
               list.AddObject(part.Name, part)
            End If
         Next
         GetAll = list
      End Function

      Sub Delete(pName As String)
         Dim i As Integer = me._parts.Count - 1
         Do While i >= 0
            Dim part As FormDataPart = CType(me._parts.Objects(i), FormDataPart)
            If part.Name = pName Then
               me._parts.Delete(i)
            End If
            i -= 1
         Loop
      End Sub

      Function Has(pName As String) As Boolean
         Has = me._parts.IndexOf(pName) >= 0
      End Function

      Function Entries() As StringList
         Entries = me._parts
      End Function

      Function Keys() As StringList
         Dim list As New StringList()
         Dim i As Integer
         Dim count As Integer = me.Count()
         For i = 0 To count - 1
            list.Add(FormDataPart(me._parts.Objects(i)).Name)
         Next
         Keys = list
      End Function

      Function Count() As Integer
         Count = me._parts.Count
      End Function

      Function Data() As Variant
         Dim vbCrLf As String = CHAR(13) + CHAR(10)
         Dim delimiter As String = "--" & me._boundary
         Dim closingDelimiter As String = delimiter & "--"
         Dim result As Variant
         Dim i As Integer
         For i = 0 To me._parts.Count - 1
            Dim part As FormDataPart = CType(me._parts.Objects(i), FormDataPart)
            Dim header As String = delimiter & vbCrLf
            header = header & "Content-Disposition: form-data; name=""" & part.Name & """"
            If part.IsFile Then
               Dim filename As String
               If part.Filename <> "" Then
                  filename = part.Filename
               Else
                  filename = Mid(part.Value, InStrRev(part.Value, "\") + 1)
               End If
               header = header & "; filename=""" & filename & """" & vbCrLf
               header = header & "Content-Type: " & part.ContentType & vbCrLf & vbCrLf
               Dim fileBytes As Variant
               If IsEmpty(part.ValueRaw) Then
                  fileBytes = me.LoadFileBytes(part.Value)
               Else
                  fileBytes = part.ValueRaw
               End If
               result = me.ConcatBytes(result, me.StringToBytes(header))
               result = me.ConcatBytes(result, fileBytes)
               result = me.ConcatBytes(result, me.StringToBytes(vbCrLf))
            Else
               header = header & vbCrLf
               If part.ContentType <> "" Then
                  header = header & "Content-Type: " & part.ContentType
                  If part.CharSet <> "" Then
                     header = header & "; charset=" & part.CharSet
                  End If
                  header = header & vbCrLf
               End If
               header = header & vbCrLf
               result = me.ConcatBytes(result, me.StringToBytes(header))
               result = me.ConcatBytes(result, me.StringToBytes(part.Value))
               result = me.ConcatBytes(result, me.StringToBytes(vbCrLf))
            End If
         Next
         result = me.ConcatBytes(result, me.StringToBytes(closingDelimiter))
         Data = result
      End Function

      Function StringToBytes(pText As String) As Variant
         Dim stream As Variant = CreateObject("ADODB.Stream")
         With stream
            .Type = 2
            .Charset = me._charset
            .Open()
            .WriteText(pText)
            .Position = 0
            .Type = 1
            StringToBytes = .Read
            .Close()
         End With
         stream = ""
      End Function

      Private Function ConcatBytes(arr1 As Variant, arr2 As Variant) As Variant
         Dim stream As Variant = CreateObject("ADODB.Stream")
         With stream
            .Type = 1
            .Open()
            If Not IsEmpty(arr1) Then
               .Write(arr1)
            End If
            If Not IsEmpty(arr2) Then
               .Write(arr2)
            End If
            .Position = 0
            ConcatBytes = .Read
            .Close()
         End With
         stream = ""
      End Function

      Private Function LoadFileBytes(pPath As String) As Variant
         Dim stream As Variant = CreateObject("ADODB.Stream")
         With stream
            .Type = 1
            .Open()
            .LoadFromFile(pPath)
            .Position = 0
            LoadFileBytes = .Read
            .Close()
         End With
         stream = ""
      End Function

      Sub Free()
         me._parts.Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
