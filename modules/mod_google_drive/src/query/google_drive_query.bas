Imports mod_tobject
Imports google_drive_mime

Namespace google_drive_query

   Class GoogleDriveQuery
      Inherits TTObject

      Private _parts As String
      Private _started As Boolean

      Sub New()
         MyBase.New()
         me._parts = ""
         me._started = False
      End Sub

      Function NameEquals(pName As String) As GoogleDriveQuery
         me.AndTerm("name = " & me.Quote(pName))
         NameEquals = me
      End Function

      Function NameContains(pName As String) As GoogleDriveQuery
         me.AndTerm("name contains " & me.Quote(pName))
         NameContains = me
      End Function

      Function MimeTypeEquals(pMime As String) As GoogleDriveQuery
         me.AndTerm("mimeType = " & me.Quote(pMime))
         MimeTypeEquals = me
      End Function

      Function IsFolder() As GoogleDriveQuery
         me.MimeTypeEquals(GoogleDriveMime.FolderType())
         IsFolder = me
      End Function

      Function ParentsIn(pParentId As String) As GoogleDriveQuery
         me.AndTerm(me.Quote(pParentId) & " in parents")
         ParentsIn = me
      End Function

      Function Trashed(pValue As Boolean) As GoogleDriveQuery
         If pValue Then
            me.AndTerm("trashed = true")
         Else
            me.AndTerm("trashed = false")
         End If
         Trashed = me
      End Function

      Function SharedWithMe() As GoogleDriveQuery
         me.AndTerm("sharedWithMe = true")
         SharedWithMe = me
      End Function

      Function OwnedByMe() As GoogleDriveQuery
         me.AndTerm("'me' in owners")
         OwnedByMe = me
      End Function

      Function Starred() As GoogleDriveQuery
         me.AndTerm("starred = true")
         Starred = me
      End Function

      Function Raw(pTerm As String) As GoogleDriveQuery
         me.AndTerm(Trim(pTerm))
         Raw = me
      End Function

      Function AsString() As String
         AsString = me._parts
      End Function

      Private Sub AndTerm(pTerm As String)
         Dim term As String = Trim(pTerm)
         If term = "" Then
            Exit Sub
         End If
         If me._started Then
            me._parts = me._parts & " and " & term
         Else
            me._parts = term
            me._started = True
         End If
      End Sub

      Private Function Quote(pValue As String) As String
         Dim text As String = pValue
         text = text.Replace("\", "\\")
         text = text.Replace("'", "\'")
         Quote = "'" & text & "'"
      End Function

      Overrides Function ToString() As String
         ToString = me.AsString()
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
