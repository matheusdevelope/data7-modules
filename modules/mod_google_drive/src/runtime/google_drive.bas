Imports http_client
Imports google_auth_client
Imports google_auth_bearer
Imports google_drive_client
Imports google_drive_config
Imports google_drive_validation
Imports google_drive_endpoints
Imports google_drive_endpoints_v3
Imports google_drive_http
Imports google_drive_files
Imports google_drive_permissions
Imports google_drive_about_resource
Imports google_drive_uploader
Imports google_drive_downloader
Imports google_drive_capabilities
Imports google_drive_errors
Imports google_drive_enums

Namespace google_drive

   Class GoogleDriveService
      Inherits GoogleDriveClient

      Private _auth As GoogleAuthClient
      Private _http As GoogleDriveHttp
      Private _config As GoogleDriveConfig
      Private _endpoints As GoogleDriveEndpoints
      Private _files As GoogleDriveFiles
      Private _permissions As GoogleDrivePermissions
      Private _about As GoogleDriveAboutResource
      Private _uploader As GoogleDriveUploader
      Private _downloader As GoogleDriveDownloader
      Private _ownsHttp As Boolean
      Private _ownsAuth As Boolean
      Private _ownsConfig As Boolean
      Private _ownsEndpoints As Boolean

      Sub New(pAuth As GoogleAuthClient, pHttp As GoogleDriveHttp, pConfig As GoogleDriveConfig, pOwnsAuth As Boolean = False, pOwnsHttp As Boolean = True, pOwnsConfig As Boolean = False)
         MyBase.New()
         me.Attach(pAuth, pHttp, pConfig, pOwnsAuth, pOwnsHttp, pOwnsConfig, False)
      End Sub

      Private Sub Attach(pAuth As GoogleAuthClient, pHttp As GoogleDriveHttp, pConfig As GoogleDriveConfig, pOwnsAuth As Boolean, pOwnsHttp As Boolean, pOwnsConfig As Boolean, pOwnsEndpoints As Boolean)
         If Not Assigned(pHttp) Then
            Throw New Exception(GoogleDriveErrors.HttpRequired())
         End If
         If Not Assigned(pConfig) Then
            Throw New Exception(GoogleDriveErrors.ConfigRequired())
         End If
         GoogleDriveValidator.Validate(pConfig)
         me._auth = pAuth
         me._http = pHttp
         me._config = pConfig
         me._endpoints = pHttp.Endpoints()
         me._ownsAuth = pOwnsAuth
         me._ownsHttp = pOwnsHttp
         me._ownsConfig = pOwnsConfig
         me._ownsEndpoints = pOwnsEndpoints
         me._about = New GoogleDriveAboutResource(pHttp)
         me._uploader = New GoogleDriveUploader(pHttp)
         me._downloader = New GoogleDriveDownloader(pHttp)
         me._files = New GoogleDriveFiles(pHttp, me._uploader, me._downloader, me._about)
         me._permissions = New GoogleDrivePermissions(pHttp)
      End Sub

      Shared Function Load(pAuth As GoogleAuthClient, pConfig As GoogleDriveConfig = Null) As GoogleDriveService
         If Not Assigned(pAuth) Then
            Throw New Exception(GoogleDriveErrors.AuthRequired())
         End If
         Dim cfg As GoogleDriveConfig = pConfig
         Dim ownsConfig As Boolean = False
         If Not Assigned(cfg) Then
            cfg = New GoogleDriveConfig()
            ownsConfig = True
         End If
         GoogleDriveValidator.Validate(cfg)
         Dim endpoints As GoogleDriveEndpoints = GoogleDriveEndpointCatalog.Make(cfg.ApiVersion)
         Dim apiClient As HttpClient = Http.WinHttp(endpoints.BaseUrl())
         apiClient.Timeout = cfg.Timeout
         apiClient.FollowRedirects = False
         apiClient.Use(New GoogleBearerInterceptor(pAuth))
         Dim httpLayer As New GoogleDriveHttp(apiClient, endpoints, cfg, True)
         Dim service As New GoogleDriveService(pAuth, httpLayer, cfg, False, True, ownsConfig)
         service._ownsEndpoints = True
         Load = service
      End Function

      Shared Function FromHttp(pHttp As GoogleDriveHttp, pConfig As GoogleDriveConfig, pOwnsHttp As Boolean = True) As GoogleDriveService
         FromHttp = New GoogleDriveService(Null, pHttp, pConfig, False, pOwnsHttp, False)
      End Function

      Overrides Function ApiVersionName() As String
         ApiVersionName = me._config.ApiVersion.AsString
      End Function

      Function Capabilities() As GoogleDriveCapabilities
         Capabilities = GoogleDriveCapabilities.CoreBackup()
      End Function

      Function Config() As GoogleDriveConfig
         Config = me._config
      End Function

      Function Files() As GoogleDriveFiles
         Files = me._files
      End Function

      Function Permissions() As GoogleDrivePermissions
         Permissions = me._permissions
      End Function

      Function About() As GoogleDriveAboutResource
         About = me._about
      End Function

      Function HttpLayer() As GoogleDriveHttp
         HttpLayer = me._http
      End Function

      Overrides Sub Dispose()
         If Assigned(me._files) Then
            me._files.Free()
            me._files = Null
         End If
         If Assigned(me._permissions) Then
            me._permissions.Free()
            me._permissions = Null
         End If
         If Assigned(me._about) Then
            me._about.Free()
            me._about = Null
         End If
         If Assigned(me._uploader) Then
            me._uploader.Free()
            me._uploader = Null
         End If
         If Assigned(me._downloader) Then
            me._downloader.Free()
            me._downloader = Null
         End If
         If me._ownsHttp And Assigned(me._http) Then
            me._http.Free()
         End If
         me._http = Null
         If me._ownsEndpoints And Assigned(me._endpoints) Then
            me._endpoints.Free()
         End If
         me._endpoints = Null
         If me._ownsConfig And Assigned(me._config) Then
            me._config.Free()
         End If
         me._config = Null
         If me._ownsAuth And Assigned(me._auth) Then
            me._auth.Free()
         End If
         me._auth = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
