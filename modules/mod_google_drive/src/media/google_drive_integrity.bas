Imports TFile
Imports mod_tobject
Imports mod_certutil
Imports google_drive_file
Imports google_drive_errors

Namespace google_drive_integrity

   Class GoogleDriveIntegrity
      Inherits TTObject

      Shared Function Algorithm() As String
         Algorithm = "MD5"
      End Function

      Shared Function Normalize(pHash As String) As String
         Dim raw As String = LCase(Trim(pHash))
         Dim hexText As String = ""
         Dim i As Integer
         For i = 1 To Len(raw)
            Dim ch As String = Mid(raw, i, 1)
            If InStr("0123456789abcdef", ch) > 0 Then
               hexText = hexText & ch
            ElseIf (ch <> " ") And (ch <> ":") And (ch <> "-") Then
               Exit For
            End If
         Next
         Normalize = hexText
      End Function

      Shared Function HashesMatch(pLeft As String, pRight As String) As Boolean
         Dim leftHash As String = GoogleDriveIntegrity.Normalize(pLeft)
         Dim rightHash As String = GoogleDriveIntegrity.Normalize(pRight)
         If (leftHash = "") Or (rightHash = "") Then
            HashesMatch = False
            Exit Function
         End If
         If leftHash = rightHash Then
            HashesMatch = True
         Else
            HashesMatch = False
         End If
      End Function

      Shared Function HashLocal(pPath As String) As String
         If Trim(pPath) = "" Then
            Throw New Exception(GoogleDriveErrors.PathRequired())
         End If
         If Not TFile.Exists(pPath) Then
            Throw New Exception(GoogleDriveErrors.FileNotFound(pPath))
         End If
         Dim hasher As TCertUtil = TCertUtil.Instance()
         Dim raw As String = hasher.HashFile(pPath, GoogleDriveIntegrity.Algorithm())
         Dim hexText As String = GoogleDriveIntegrity.Normalize(raw)
         If hexText = "" Then
            Throw New Exception(GoogleDriveErrors.LocalChecksumEmpty(pPath))
         End If
         HashLocal = hexText
      End Function

      Shared Sub Verify(pPath As String, pDriveFile As GoogleDriveFile)
         If Not Assigned(pDriveFile) Then
            Throw New Exception(GoogleDriveErrors.DriveFileRequired())
         End If
         Dim remoteHash As String = GoogleDriveIntegrity.Normalize(pDriveFile.Md5Checksum)
         If remoteHash = "" Then
            Throw New Exception(GoogleDriveErrors.ChecksumUnavailable(pDriveFile.Id, pDriveFile.MimeType))
         End If
         Dim localHash As String = GoogleDriveIntegrity.HashLocal(pPath)
         If Not GoogleDriveIntegrity.HashesMatch(localHash, remoteHash) Then
            Throw New Exception(GoogleDriveErrors.ChecksumMismatch(localHash, remoteHash))
         End If
      End Sub

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
