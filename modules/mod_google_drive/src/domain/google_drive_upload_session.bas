Imports TFile
Imports mod_tobject
Imports google_drive_json

Namespace google_drive_upload_session

   Class GoogleDriveUploadSession
      Inherits TTObject

      SessionUri As String
      FilePath As String
      BytesSent As Int64
      TotalBytes As Int64
      DriveFileId As String
      MimeType As String
      Name As String
      ParentId As String

      Sub New()
         MyBase.New()
         me.BytesSent = GoogleDriveJson.Zero64()
         me.TotalBytes = GoogleDriveJson.Zero64()
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As GoogleDriveUploadSession
         Dim value As New GoogleDriveUploadSession()
         If Not Assigned(pJson) Then
            FromJson = value
            Exit Function
         End If
         If pJson.Has("session_uri") Then
            value.SessionUri = pJson.GetString("session_uri")
         End If
         If pJson.Has("file_path") Then
            value.FilePath = pJson.GetString("file_path")
         End If
         If pJson.Has("bytes_sent") Then
            value.BytesSent = GoogleDriveJson.ParseInt64(pJson.GetString("bytes_sent"))
         End If
         If pJson.Has("total_bytes") Then
            value.TotalBytes = GoogleDriveJson.ParseInt64(pJson.GetString("total_bytes"))
         End If
         If pJson.Has("drive_file_id") Then
            value.DriveFileId = pJson.GetString("drive_file_id")
         End If
         If pJson.Has("mime_type") Then
            value.MimeType = pJson.GetString("mime_type")
         End If
         If pJson.Has("name") Then
            value.Name = pJson.GetString("name")
         End If
         If pJson.Has("parent_id") Then
            value.ParentId = pJson.GetString("parent_id")
         End If
         FromJson = value
      End Function

      Shared Function FromFile(pPath As String) As GoogleDriveUploadSession
         If Not TFile.Exists(pPath) Then
            FromFile = New GoogleDriveUploadSession()
            Exit Function
         End If
         Dim raw As String = TFile.ReadAllText(pPath)
         If Trim(raw) = "" Then
            FromFile = New GoogleDriveUploadSession()
            Exit Function
         End If
         Dim parsed As TJSONObject
         Dim parseFailed As Boolean = False
         Try
            parsed = New TJSONObject(raw)
         Catch parseEx As Exception
            parseFailed = True
         End Try
         If parseFailed Then
            FromFile = New GoogleDriveUploadSession()
            Exit Function
         End If
         Dim value As GoogleDriveUploadSession = GoogleDriveUploadSession.FromJson(parsed)
         parsed.Free()
         FromFile = value
      End Function

      Function ToJson() As TJSONObject
         Dim json As New TJSONObject()
         json.PutString("session_uri", me.SessionUri)
         json.PutString("file_path", me.FilePath)
         json.PutString("bytes_sent", GoogleDriveJson.Int64Text(me.BytesSent))
         json.PutString("total_bytes", GoogleDriveJson.Int64Text(me.TotalBytes))
         json.PutString("drive_file_id", me.DriveFileId)
         json.PutString("mime_type", me.MimeType)
         json.PutString("name", me.Name)
         json.PutString("parent_id", me.ParentId)
         ToJson = json
      End Function

      Sub ToFile(pPath As String)
         If Trim(pPath) = "" Then
            Exit Sub
         End If
         Dim json As TJSONObject = me.ToJson()
         json.SaveToFile(pPath)
         json.Free()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
