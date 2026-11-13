Imports Collections
Imports mod_tobject
Imports mod_pix_enums

Namespace mod_pix_psp

   Class PixPsp
      Inherits TTObject

      Protected _banco As PixBanco
      Protected _version As Integer
      Protected _version_auth As Integer
      Protected Scope As StringList
      Protected AuthUrls As StringList
      Protected BaseUrls As StringList

      Sub New(pBanco As PixBanco, pVersion As Integer, pVersionAuth As Integer = -1)
         MyBase.New()
         me._banco = pBanco
         me._version = pVersion
         me._version_auth = pVersionAuth
         If pVersionAuth = -1 Then
            me._version_auth = pVersion
         End If
         me.Scope = New StringList()
         me.AuthUrls = New StringList()
         me.BaseUrls = New StringList()
         me.FillScopes()
         me.FillUrls()
      End Sub

      Property Banco As PixBanco
         Get
            Banco = me._banco
         End Get
      End Property

      Property Version As Integer
         Get
            Version = me._version
         End Get
      End Property

      Property VersionAuth As Integer
         Get
            VersionAuth = me._version_auth
         End Get
      End Property

      Function AuthUrl(pSandBox As Boolean) As String
         AuthUrl = me.AuthUrls.Strings(CInt(pSandBox) + 1)
      End Function

      Function BaseUrl(pSandBox As Boolean) As String
         BaseUrl = me.BaseUrls.Strings(CInt(pSandBox) + 1)
      End Function

      Function VersionedBaseUrl(pSandBox As Boolean, pVersion As Integer) As String
         Dim url As String = me.BaseUrl(pSandBox)
         VersionedBaseUrl = url.Replace("/api/v" & CStr(me.Version), "/api/v" & CStr(pVersion))
      End Function

      Function Scopes(pSeparator As String = "+") As String
         Scopes = me.Scope.Text.Trim.Replace(me.Scope.LineBreak, pSeparator)
      End Function

      Overridable Sub FillScopes()
         me.Scope.Add("cob.read")
         me.Scope.Add("cob.write")
         me.Scope.Add("pix.write")
         me.Scope.Add("pix.read")
         me.Scope.Add("webhook.read")
         me.Scope.Add("webhook.write")
         me.Scope.Add("payloadlocation.read")
         me.Scope.Add("payloadlocation.write")
      End Sub

      Overridable Sub FillUrls()
      End Sub

      Overridable Overrides Function Clone() As PixPsp
         Clone = New PixPsp(me._banco, me._version, me._version_auth)
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixPsp")
            .Prop("Banco", me._banco.AsString)
            .Prop("Version", me._version)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Scope) Then
            me.Scope.Free()
            me.Scope = Null
         End If
         If Assigned(me.AuthUrls) Then
            me.AuthUrls.Free()
            me.AuthUrls = Null
         End If
         If Assigned(me.BaseUrls) Then
            me.BaseUrls.Free()
            me.BaseUrls = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
