Imports http_headers
Imports mod_tobject
Imports google_drive_http
Imports google_drive_about
Imports google_drive_errors
Imports google_drive_json

Namespace google_drive_about_resource

   Class GoogleDriveAboutResource
      Inherits TTObject

      Private _http As GoogleDriveHttp

      Sub New(pHttp As GoogleDriveHttp)
         MyBase.New()
         If Not Assigned(pHttp) Then
            Throw New Exception(GoogleDriveErrors.HttpRequired())
         End If
         me._http = pHttp
      End Sub

      Function Gett() As GoogleDriveAbout
         Dim query As New HttpParams()
         query.Define("fields", me._http.Config().AboutFields)
         Dim json As TJSONObject = me._http.GetJson(me._http.Endpoints().AboutPath(), query)
         query.Free()
         Dim info As GoogleDriveAbout = GoogleDriveAbout.FromJson(json)
         json.Free()
         Gett = info
      End Function

      Sub EnsureCanUpload(pSize As Integer)
         ' data7:disable-next-line type-mismatch
         me.EnsureCanUpload(GoogleDriveJson.FromInteger(pSize))
      End Sub

      Sub EnsureCanUpload(pSize As Int64)
         Dim info As GoogleDriveAbout = me.Gett()
         ' data7:disable-next-line type-mismatch
         info.EnsureCanUpload(pSize)
         info.Free()
      End Sub

      Overrides Sub Dispose()
         me._http = Null
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
