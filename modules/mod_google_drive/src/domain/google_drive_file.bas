Imports Collections
Imports mod_tobject
Imports google_drive_json
Imports google_drive_mime

Namespace google_drive_file

   Class GoogleDriveFile
      Inherits TTObject

      Id As String
      Name As String
      MimeType As String
      SizeText As String
      SizeBytes As Int64
      Md5Checksum As String
      Trashed As Boolean
      CreatedTime As String
      ModifiedTime As String
      WebViewLink As String
      Kind As String
      Parents As StringList

      Sub New()
         MyBase.New()
         me.Parents = New StringList()
         me.SizeBytes = GoogleDriveJson.Zero64()
      End Sub

      Overrides Function GetID() As String
         If Trim(me.Id) <> "" Then
            GetID = me.Id
            Exit Function
         End If
         GetID = MyBase.GetID()
      End Function

      Function IsFolder() As Boolean
         IsFolder = me.MimeType = GoogleDriveMime.FolderType()
      End Function

      Function IsWorkspace() As Boolean
         IsWorkspace = GoogleDriveMime.IsWorkspace(me.MimeType)
      End Function

      Shared Function FromJson(pJson As TJSONObject) As GoogleDriveFile
         Dim driveFile As New GoogleDriveFile()
         If Not Assigned(pJson) Then
            FromJson = driveFile
            Exit Function
         End If
         If pJson.Has("id") Then
            driveFile.Id = pJson.GetString("id")
         End If
         If pJson.Has("name") Then
            driveFile.Name = pJson.GetString("name")
         End If
         If pJson.Has("mimeType") Then
            driveFile.MimeType = pJson.GetString("mimeType")
         End If
         If pJson.Has("size") Then
            driveFile.SizeText = pJson.GetString("size")
            driveFile.SizeBytes = GoogleDriveJson.ParseInt64(driveFile.SizeText)
         End If
         If pJson.Has("md5Checksum") Then
            driveFile.Md5Checksum = pJson.GetString("md5Checksum")
         End If
         If pJson.Has("trashed") Then
            driveFile.Trashed = pJson.GetBoolean("trashed")
         End If
         If pJson.Has("createdTime") Then
            driveFile.CreatedTime = pJson.GetString("createdTime")
         End If
         If pJson.Has("modifiedTime") Then
            driveFile.ModifiedTime = pJson.GetString("modifiedTime")
         End If
         If pJson.Has("webViewLink") Then
            driveFile.WebViewLink = pJson.GetString("webViewLink")
         End If
         If pJson.Has("kind") Then
            driveFile.Kind = pJson.GetString("kind")
         End If
         If pJson.Has("parents") Then
            Dim arr As TJSONArray = pJson.GetArray("parents")
            If Assigned(arr) Then
               Dim i As Integer
               Dim last As Integer = arr.Length() - 1
               For i = 0 To last
                  driveFile.Parents.Add(arr.GetString(i))
               Next
               arr.Free()
            End If
         End If
         FromJson = driveFile
      End Function

      Function ToJson() As TJSONObject
         Dim jsonText As String = "{"
         jsonText = jsonText & GoogleDriveJson.Quote("name") & ":" & GoogleDriveJson.Quote(me.Name)
         If Trim(me.MimeType) <> "" Then
            jsonText = jsonText & "," & GoogleDriveJson.Quote("mimeType") & ":" & GoogleDriveJson.Quote(me.MimeType)
         End If
         If Assigned(me.Parents) Then
            If me.Parents.Count > 0 Then
               jsonText = jsonText & "," & GoogleDriveJson.Quote("parents") & ":" & GoogleDriveJson.StringArray(me.Parents)
            End If
         End If
         If me.Trashed Then
            jsonText = jsonText & "," & GoogleDriveJson.Quote("trashed") & ":true"
         End If
         jsonText = jsonText & "}"
         ToJson = New TJSONObject(jsonText)
      End Function

      Sub Assign(pValue As GoogleDriveFile)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Id = pValue.Id
         me.Name = pValue.Name
         me.MimeType = pValue.MimeType
         me.SizeText = pValue.SizeText
         me.SizeBytes = pValue.SizeBytes
         me.Md5Checksum = pValue.Md5Checksum
         me.Trashed = pValue.Trashed
         me.CreatedTime = pValue.CreatedTime
         me.ModifiedTime = pValue.ModifiedTime
         me.WebViewLink = pValue.WebViewLink
         me.Kind = pValue.Kind
         me.Parents.Clear()
         If Assigned(pValue.Parents) Then
            Dim i As Integer
            For i = 0 To pValue.Parents.Count - 1
               me.Parents.Add(pValue.Parents.Strings(i))
            Next
         End If
      End Sub

      Overrides Function Clone() As GoogleDriveFile
         Dim copy As New GoogleDriveFile()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDriveFile")
            .Prop("Id", me.Id)
            .Prop("Name", me.Name)
            .Prop("MimeType", me.MimeType)
            .PropStr("SizeBytes", GoogleDriveJson.Int64Text(me.SizeBytes))
            .Prop("Trashed", me.Trashed)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Parents) Then
            me.Parents.Free()
            me.Parents = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
