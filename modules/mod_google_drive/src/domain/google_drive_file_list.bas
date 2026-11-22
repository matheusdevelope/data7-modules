Imports mod_tlist
Imports mod_tobject
Imports google_drive_file

Namespace google_drive_file_list

   Class GoogleDriveFileList
      Inherits TTObject

      Kind As String
      NextPageToken As String
      IncompleteSearch As Boolean
      Files As TTList<GoogleDriveFile>

      Sub New()
         MyBase.New()
         me.Files = New TTList<GoogleDriveFile>()
      End Sub

      Shared Function FromJson(pJson As TJSONObject) As GoogleDriveFileList
         Dim listing As New GoogleDriveFileList()
         If Not Assigned(pJson) Then
            FromJson = listing
            Exit Function
         End If
         If pJson.Has("kind") Then
            listing.Kind = pJson.GetString("kind")
         End If
         If pJson.Has("nextPageToken") Then
            listing.NextPageToken = pJson.GetString("nextPageToken")
         End If
         If pJson.Has("incompleteSearch") Then
            listing.IncompleteSearch = pJson.GetBoolean("incompleteSearch")
         End If
         If pJson.Has("files") Then
            Dim arr As TJSONArray = pJson.GetArray("files")
            If Assigned(arr) Then
               Dim i As Integer
               Dim last As Integer = arr.Length() - 1
               For i = 0 To last
                  Dim itemJson As TJSONObject = arr.GetJSONObject(i)
                  listing.Files.Push(GoogleDriveFile.FromJson(itemJson))
                  If Assigned(itemJson) Then
                     itemJson.Free()
                  End If
               Next
               arr.Free()
            End If
         End If
         FromJson = listing
      End Function

      Function HasMore() As Boolean
         HasMore = Trim(me.NextPageToken) <> ""
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("GoogleDriveFileList")
            .Prop("Count", me.Files.Length)
            .Prop("NextPageToken", me.NextPageToken)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Files) Then
            me.Files.Free()
            me.Files = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
