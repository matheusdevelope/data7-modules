Imports http_headers

Namespace http_url

   Function Encode(pValue As String) As String
      Dim engine As Variant = CreateObject("MSScriptControl.ScriptControl")
      engine.Language = "JScript"
      Encode = engine.Run("encodeURIComponent", pValue)
      engine = ""
   End Function

   Function Decode(pValue As String) As String
      Dim engine As Variant = CreateObject("MSScriptControl.ScriptControl")
      engine.Language = "JScript"
      Decode = engine.Run("decodeURIComponent", pValue)
      engine = ""
   End Function

   Function IsAbsolute(pUrl As String) As Boolean
      Dim lower As String = pUrl.Trim().ToLower()
      IsAbsolute = lower.StartsWith("http://") Or lower.StartsWith("https://")
   End Function

   Function NormalizePath(pPath As String) As String
      Dim path As String = pPath.Trim()
      While path.Trim().StartsWith("/")
         path = path.Right(path.Length - 1).Trim()
      End While
      While path.EndsWith("/")
         path = path.Left(path.Length - 1).Trim()
      End While
      NormalizePath = path
   End Function

   Function Join(pBaseUrl As String, pEndpoint As String) As String
      If IsAbsolute(pEndpoint) Then
         Join = pEndpoint.Trim()
         Exit Function
      End If
      Dim baseUrl As String = NormalizePath(pBaseUrl)
      Dim endpoint As String = NormalizePath(pEndpoint)
      If baseUrl <> "" And endpoint <> "" Then
         Join = baseUrl & "/" & endpoint
      ElseIf baseUrl <> "" Then
         Join = baseUrl
      Else
         Join = endpoint
      End If
   End Function

   Function WithQuery(pUrl As String, pParams As HttpParams) As String
      Dim query As String = ""
      If Assigned(pParams) Then
         Dim i As Integer
         Dim count As Integer = pParams.Count
         For i = 0 To count - 1
            If i > 0 Then
               query = query & "&"
            End If
            query = query & Encode(pParams.Name(i)) & "=" & Encode(pParams.Value(i))
         Next
      End If
      If query <> "" Then
         WithQuery = pUrl & "?" & query
      Else
         WithQuery = pUrl
      End If
   End Function

   Function Build(pBaseUrl As String, pEndpoint As String, pParams As HttpParams) As String
      Dim url As String = Join(pBaseUrl, pEndpoint)
      Dim path As String = url
      Dim queryFromUrl As String = ""
      Dim idx As Integer = InStr(url, "?")
      If idx > 0 Then
         path = Left(url, idx - 1)
         queryFromUrl = Mid(url, idx + 1)
      End If

      Dim merged As New HttpParams()
      If Assigned(pParams) Then
         merged.Join(pParams)
      End If
      If queryFromUrl <> "" Then
         Dim extra As New HttpParams(queryFromUrl)
         Dim i As Integer
         Dim count As Integer = extra.Count
         For i = 0 To count - 1
            merged.Define(Decode(extra.Name(i)), Decode(extra.Value(i)))
         Next
         extra.Free()
      End If

      Build = WithQuery(path, merged)
      merged.Free()
   End Function

End Namespace
