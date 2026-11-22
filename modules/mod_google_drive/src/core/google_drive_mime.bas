Imports TPath
Imports mod_tobject

Namespace google_drive_mime

   Class GoogleDriveMime
      Inherits TTObject

      Shared Function FolderType() As String
         FolderType = "application/vnd.google-apps.folder"
      End Function

      Shared Function NativeDocument() As String
         NativeDocument = "application/vnd.google-apps.document"
      End Function

      Shared Function NativeSpreadsheet() As String
         NativeSpreadsheet = "application/vnd.google-apps.spreadsheet"
      End Function

      Shared Function NativePresentation() As String
         NativePresentation = "application/vnd.google-apps.presentation"
      End Function

      Shared Function OctetStream() As String
         OctetStream = "application/octet-stream"
      End Function

      Shared Function Pdf() As String
         Pdf = "application/pdf"
      End Function

      Shared Function ExcelXls() As String
         ExcelXls = "application/vnd.ms-excel"
      End Function

      Shared Function ExcelXlsx() As String
         ExcelXlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      End Function

      Shared Function WordDoc() As String
         WordDoc = "application/msword"
      End Function

      Shared Function WordDocx() As String
         WordDocx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      End Function

      Shared Function PowerPointPpt() As String
         PowerPointPpt = "application/vnd.ms-powerpoint"
      End Function

      Shared Function PowerPointPptx() As String
         PowerPointPptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      End Function

      Shared Function IsWorkspace(pMime As String) As Boolean
         Dim mime As String = LCase(Trim(pMime))
         If mime = "" Then
            IsWorkspace = False
            Exit Function
         End If
         If mime = LCase(GoogleDriveMime.FolderType()) Then
            IsWorkspace = False
            Exit Function
         End If
         If InStr(mime, "application/vnd.google-apps.") = 1 Then
            IsWorkspace = True
         Else
            IsWorkspace = False
         End If
      End Function

      Shared Function ExportMimeFor(pGoogleMime As String) As String
         Dim mime As String = LCase(Trim(pGoogleMime))
         If mime = LCase(GoogleDriveMime.NativeSpreadsheet()) Then
            ExportMimeFor = GoogleDriveMime.ExcelXlsx()
            Exit Function
         End If
         If mime = LCase(GoogleDriveMime.NativeDocument()) Then
            ExportMimeFor = GoogleDriveMime.WordDocx()
            Exit Function
         End If
         If mime = LCase(GoogleDriveMime.NativePresentation()) Then
            ExportMimeFor = GoogleDriveMime.PowerPointPptx()
            Exit Function
         End If
         ExportMimeFor = GoogleDriveMime.Pdf()
      End Function

      Shared Function FromPath(pPath As String) As String
         Dim ext As String = LCase(Trim(TPath.GetExtension(pPath)))
         If ext = ".zip" Then
            FromPath = "application/zip"
            Exit Function
         End If
         If ext = ".pdf" Then
            FromPath = GoogleDriveMime.Pdf()
            Exit Function
         End If
         If (ext = ".txt") Or (ext = ".log") Then
            FromPath = "text/plain"
            Exit Function
         End If
         If ext = ".csv" Then
            FromPath = "text/csv"
            Exit Function
         End If
         If ext = ".json" Then
            FromPath = "application/json"
            Exit Function
         End If
         If (ext = ".jpg") Or (ext = ".jpeg") Then
            FromPath = "image/jpeg"
            Exit Function
         End If
         If ext = ".png" Then
            FromPath = "image/png"
            Exit Function
         End If
         If ext = ".xlsx" Then
            FromPath = GoogleDriveMime.ExcelXlsx()
            Exit Function
         End If
         If ext = ".xls" Then
            FromPath = GoogleDriveMime.ExcelXls()
            Exit Function
         End If
         If ext = ".docx" Then
            FromPath = GoogleDriveMime.WordDocx()
            Exit Function
         End If
         If ext = ".doc" Then
            FromPath = GoogleDriveMime.WordDoc()
            Exit Function
         End If
         If ext = ".pptx" Then
            FromPath = GoogleDriveMime.PowerPointPptx()
            Exit Function
         End If
         If ext = ".ppt" Then
            FromPath = GoogleDriveMime.PowerPointPpt()
            Exit Function
         End If
         If ext = ".7z" Then
            FromPath = "application/x-7z-compressed"
            Exit Function
         End If
         If ext = ".gz" Then
            FromPath = "application/gzip"
            Exit Function
         End If
         FromPath = GoogleDriveMime.OctetStream()
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
