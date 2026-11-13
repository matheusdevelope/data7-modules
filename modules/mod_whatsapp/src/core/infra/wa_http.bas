Imports Collections
Imports mod_tobject
Imports mod_wa_auth

Namespace mod_wa_http

   ' Transporte HTTP puro. Auth injetada (DIP) e aplicada antes de cada request.
   Class WaHttp
      Inherits TTObject

      Private _baseUrl As String
      Private _auth As WaAuth
      Private _ownsAuth As Boolean
      Private _headers As StringList
      Private _http As THTTP
      Private _lastBody As String

      Sub New(pBaseUrl As String, pAuth As WaAuth, pOwnsAuth As Boolean = True)
         MyBase.New()
         If pAuth = NULL Then
            Throw New Exception("WaHttp requer um WaAuth injetado")
         End If
         me._baseUrl = me.NormalizeBaseUrl(pBaseUrl)
         me._auth = pAuth
         me._ownsAuth = pOwnsAuth
         me._headers = New StringList()
         me._headers.NameValueSeparator = "="
         me._lastBody = ""
         me.RebuildNative()
      End Sub

      Function Auth() As WaAuth
         Auth = me._auth
      End Function

      Private Function NormalizeBaseUrl(pUrl As String) As String
         Dim _url As String = pUrl.Trim()
         If _url.EndsWith("/") Then
            _url = _url.Left(_url.Length - 1)
         End If
         NormalizeBaseUrl = _url
      End Function

      Private Function BuildUrl(pPath As String) As String
         If pPath.StartsWith("http://") Or pPath.StartsWith("https://") Then
            BuildUrl = pPath
            Exit Function
         End If
         If Not pPath.StartsWith("/") Then
            pPath = "/" + pPath
         End If
         BuildUrl = me._baseUrl + pPath
      End Function

      Private Sub RebuildNative()
         If Assigned(me._http) Then
            me._http.Free()
         End If
         me._http = New THTTP()
         me._http.Accept = "application/json"
         me._http.ContentType = "application/json"
         me._http.SslVersion = TLSv1_2
      End Sub

      Private Sub PrepareRequest()
         me._auth.Apply(me._headers)
         me.RebuildNative()
         Dim i As Integer
         For i = 0 To me._headers.Count - 1
            Dim _name As String = me._headers.Names(i)
            Dim _value As String = me._headers.Values(_name)
            If _name <> "" And _value <> "" Then
               me._http.AddCustomHeader(_name + ": " + _value)
            End If
         Next
      End Sub

      Function Gett(pPath As String) As String
         me.PrepareRequest()
         me._lastBody = me._http.Get(me.BuildUrl(pPath))
         Gett = me._lastBody
      End Function

      Function Post(pPath As String, pBody As String) As String
         me.PrepareRequest()
         me._http.Body = pBody
         me._lastBody = me._http.Post(me.BuildUrl(pPath))
         Post = me._lastBody
      End Function

      Function Post(pPath As String, pBody As TJSONObject) As String
         Post = me.Post(pPath, pBody.ToString())
      End Function

      Function Put(pPath As String, pBody As String) As String
         me.PrepareRequest()
         me._http.Body = pBody
         me._lastBody = me._http.Put(me.BuildUrl(pPath))
         Put = me._lastBody
      End Function

      Function Put(pPath As String, pBody As TJSONObject) As String
         Put = me.Put(pPath, pBody.ToString())
      End Function

      ' THTTP nativo não expõe Delete — usa Method-Override sobre POST.
      Function Deletee(pPath As String, pBody As String = "") As String
         me.PrepareRequest()
         me._http.AddCustomHeader("X-HTTP-Method-Override: DELETE")
         me._http.Body = pBody
         me._lastBody = me._http.Post(me.BuildUrl(pPath))
         Deletee = me._lastBody
      End Function

      Function StatusCode() As Integer
         StatusCode = me._http.ResponseCode
      End Function

      Function StatusText() As String
         StatusText = me._http.ResponseText
      End Function

      Function ResponseText() As String
         ResponseText = me._lastBody
      End Function

      Private Function EnsureJsonPayload(pExpectArray As Boolean) As String
         Dim _raw As String = me._lastBody.Trim()
         If _raw = "" Then
            Throw New Exception("Resposta HTTP vazia (status " + me.StatusCode().ToString() + " " + me.StatusText() + ")")
         End If
         If pExpectArray Then
            If Not _raw.StartsWith("[") Then
               Throw New Exception("Resposta HTTP não é um array JSON (status " + me.StatusCode().ToString() + "): " + _raw)
            End If
         Else
            If Not _raw.StartsWith("{") Then
               Throw New Exception("Resposta HTTP não é um objeto JSON (status " + me.StatusCode().ToString() + "): " + _raw)
            End If
         End If
         EnsureJsonPayload = _raw
      End Function

      Function ResponseAsJson() As TJSONObject
         ResponseAsJson = New TJSONObject(me.EnsureJsonPayload(False))
      End Function

      Function ResponseAsArray() As TJSONArray
         ResponseAsArray = New TJSONArray(me.EnsureJsonPayload(True))
      End Function

      Function IsSuccess() As Boolean
         IsSuccess = me._http.ResponseCode >= 200 And me._http.ResponseCode < 300
      End Function

      Overrides Sub Dispose()
         If Assigned(me._http) Then
            me._http.Free()
            me._http = NULL
         End If
         If Assigned(me._headers) Then
            me._headers.Free()
            me._headers = NULL
         End If
         If me._ownsAuth And Assigned(me._auth) Then
            me._auth.Free()
         End If
         me._auth = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
