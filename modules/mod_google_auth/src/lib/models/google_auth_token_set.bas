Imports mod_tobject
Imports google_auth_enums

Namespace google_auth_token_set

   Class GoogleTokenSet
      Inherits TTObject

      AccessToken As String
      RefreshToken As String
      IdToken As String
      Scope As String
      TokenType As String
      CreatedAt As TDateTime
      ExpiresAt As TDateTime

      Private _expiresIn As Integer

      Sub New()
         MyBase.New()
         me.Initialize()
      End Sub

      Private Sub Initialize()
         me.TokenType = GoogleAuthTokenType.Bearer().AsString
         me.CreatedAt = DateTime()
         me._expiresIn = 0
      End Sub

      Property ExpiresIn As Integer
         Get
            ExpiresIn = me._expiresIn
         End Get
         Set(pValue As Integer)
            me._expiresIn = pValue
            me.ExpiresAt = me.CreatedAt.AddSeconds(me._expiresIn)
         End Set
      End Property

      Function HasAccessToken() As Boolean
         HasAccessToken = Trim(me.AccessToken) <> ""
      End Function

      Function HasRefreshToken() As Boolean
         HasRefreshToken = Trim(me.RefreshToken) <> ""
      End Function

      Function IsExpired(pSkewSeconds As Integer = 0) As Boolean
         If Not me.HasAccessToken() Then
            IsExpired = True
            Exit Function
         End If
         If me.ExpiresAt = 0 Then
            IsExpired = True
            Exit Function
         End If
         Dim nowTime As TDateTime = DateTime()
         Dim limit As TDateTime = me.ExpiresAt
         If pSkewSeconds > 0 Then
            limit = me.ExpiresAt.AddSeconds(-pSkewSeconds)
         End If
         IsExpired = nowTime >= limit
      End Function

      Function AsAuthorization() As String
         Dim kind As String = Trim(me.TokenType)
         If kind = "" Then
            kind = GoogleAuthTokenType.Bearer().AsString
         End If
         AsAuthorization = kind & " " & me.AccessToken
      End Function

      Sub ApplyRefresh(pFresh As GoogleTokenSet)
         If Not Assigned(pFresh) Then
            Exit Sub
         End If
         me.AccessToken = pFresh.AccessToken
         me.TokenType = pFresh.TokenType
         me.CreatedAt = pFresh.CreatedAt
         me.ExpiresIn = pFresh.ExpiresIn
         If Trim(pFresh.Scope) <> "" Then
            me.Scope = pFresh.Scope
         End If
         If Trim(pFresh.IdToken) <> "" Then
            me.IdToken = pFresh.IdToken
         End If
         If pFresh.HasRefreshToken() Then
            me.RefreshToken = pFresh.RefreshToken
         End If
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As GoogleTokenSet
         Dim value As New GoogleTokenSet()
         If Not Assigned(pJson) Then
            FromJson = value
            Exit Function
         End If
         If pJson.Has("access_token") Then
            value.AccessToken = pJson.GetString("access_token")
         End If
         If pJson.Has("refresh_token") Then
            value.RefreshToken = pJson.GetString("refresh_token")
         End If
         If pJson.Has("id_token") Then
            value.IdToken = pJson.GetString("id_token")
         End If
         If pJson.Has("scope") Then
            value.Scope = pJson.GetString("scope")
         End If
         If pJson.Has("token_type") Then
            value.TokenType = pJson.GetString("token_type")
         End If
         If pJson.Has("created_at") Then
            value.CreatedAt = GoogleTokenSet.ReadDateTime(pJson.GetString("created_at"))
         End If
         If pJson.Has("expires_in") Then
            value.ExpiresIn = pJson.GetInteger("expires_in")
         ElseIf pJson.Has("expires_at") Then
            value.ExpiresAt = GoogleTokenSet.ReadDateTime(pJson.GetString("expires_at"))
         End If
         FromJson = value
      End Function

      Shared Function ReadDateTime(pValue As String) As TDateTime
         Dim raw As String = Trim(pValue)
         If raw = "" Then
            ReadDateTime = 0
            Exit Function
         End If
         Dim normalized As String = raw.Replace("T", " ")
         If (Len(normalized) >= 19) And (Mid(normalized, 5, 1) = "-") Then
            Dim yearValue As Integer = CInt(Mid(normalized, 1, 4))
            Dim monthValue As Integer = CInt(Mid(normalized, 6, 2))
            Dim dayValue As Integer = CInt(Mid(normalized, 9, 2))
            Dim hourValue As Integer = CInt(Mid(normalized, 12, 2))
            Dim minuteValue As Integer = CInt(Mid(normalized, 15, 2))
            Dim secondValue As Integer = CInt(Mid(normalized, 18, 2))
            Dim stamp As TDateTime = DateTime()
            ReadDateTime = stamp.EncodeDateTime(yearValue, monthValue, dayValue, hourValue, minuteValue, secondValue, 0)
            Exit Function
         End If
         ReadDateTime = StrToDateTime(raw)
      End Function

      Function DateTimeAsText(pValue As TDateTime) As String
         If pValue = 0 Then
            DateTimeAsText = ""
            Exit Function
         End If
         DateTimeAsText = pValue.ToString("yyyy-mm-dd hh:nn:ss")
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         json.PutString("access_token", me.AccessToken)
         json.PutString("refresh_token", me.RefreshToken)
         json.PutString("id_token", me.IdToken)
         json.PutString("scope", me.Scope)
         json.PutString("token_type", me.TokenType)
         json.PutInteger("expires_in", me._expiresIn)
         json.PutString("created_at", me.DateTimeAsText(me.CreatedAt))
         json.PutString("expires_at", me.DateTimeAsText(me.ExpiresAt))
         ToJson = json
      End Function

      Sub Assign(pValue As GoogleTokenSet)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.AccessToken = pValue.AccessToken
         me.RefreshToken = pValue.RefreshToken
         me.IdToken = pValue.IdToken
         me.Scope = pValue.Scope
         me.TokenType = pValue.TokenType
         me.CreatedAt = pValue.CreatedAt
         me._expiresIn = pValue.ExpiresIn
         me.ExpiresAt = pValue.ExpiresAt
      End Sub

      Overrides Function Clone() As GoogleTokenSet
         Dim copy As New GoogleTokenSet()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleTokenSet")
            .Prop("TokenType", me.TokenType)
            .Prop("HasAccessToken", me.HasAccessToken())
            .Prop("HasRefreshToken", me.HasRefreshToken())
            .Prop("Scope", me.Scope)
            .Prop("ExpiresIn", me._expiresIn)
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
