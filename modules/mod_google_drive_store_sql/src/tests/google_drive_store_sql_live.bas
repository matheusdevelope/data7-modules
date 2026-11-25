Imports TFile
Imports TPath
Imports TDirectory
Imports mod_tobject
Imports google_auth
Imports google_auth_config
Imports google_drive
Imports google_drive_config
Imports google_drive_about
Imports google_drive_file
Imports google_drive_file_list
Imports google_drive_files
Imports google_drive_list_options
Imports google_drive_query
Imports google_drive_sql_stores
Imports configuracao_google_drive

Namespace google_drive_store_sql_live

   Class GoogleDriveStoreSqlLive
      Inherits TTObject

      Shared Sub Run()
         Dim runner As New GoogleDriveStoreSqlLive()
         runner.ListFolder()
         runner.Free()
      End Sub

      Sub New()
         MyBase.New()
      End Sub

      Sub ListFolder()
         me.LogLine("==== live Google Drive + store SQL ====")
         GoogleDriveSqlStores.Migrate()
         Dim workDir As String = TDirectory.GetCurrentDirectory()
         Dim livePath As String = me.ResolveLocalPath(workDir, "google-drive-live.json")
         Dim titleValue As String = "Google Drive"
         Dim folderName As String = "mod_google_drive"
         Dim parentId As String = ""
         Dim liveCfg As TJSONObject
         If TFile.Exists(livePath) Then
            liveCfg = New TJSONObject()
            liveCfg.LoadFromFile(livePath)
            If liveCfg.Has("connection_title") Then
               If Trim(liveCfg.GetString("connection_title")) <> "" Then
                  titleValue = Trim(liveCfg.GetString("connection_title"))
               End If
            End If
            If liveCfg.Has("folder_name") Then
               If Trim(liveCfg.GetString("folder_name")) <> "" Then
                  folderName = Trim(liveCfg.GetString("folder_name"))
               End If
            End If
            If liveCfg.Has("folder_id") Then
               parentId = Trim(liveCfg.GetString("folder_id"))
            End If
            liveCfg.Free()
         End If
         Dim auth As GoogleAuthService = Null
         Dim rows[] As TConfiguracaoGoogleDrive
         Dim i As Integer
         Dim row As TConfiguracaoGoogleDrive
         Dim connectCod As Integer
         connectCod = 0
         Try
            me.LogLine("ConnectKey/Add: SQL + GoogleAuthConnect (formulario so se faltar token/credencial).")
            rows = GoogleDriveSqlStores.ListConnections()
            For i = 0 To rows.Length - 1
               row = rows[i]
               If row.HasTokens() Then
                  connectCod = row.CodConfiguracaoGoogleDrive
                  Exit For
               End If
            Next
            rows.Free()
            If connectCod > 0 Then
               auth = GoogleDriveSqlStores.ConnectKey(connectCod, titleValue)
            Else
               auth = GoogleDriveSqlStores.Add(titleValue)
            End If
         Catch ex As Exception
            me.LogLine("Connect falhou: " & ex._GetMessage())
            Exit Sub
         End Try
         Dim cfg As GoogleAuthConfig = auth.Config()
         me.LogLine("Configuracao SQL: " & titleValue)
         me.LogLine("Escopos: " & cfg.Scopes.AsQuery())
         Dim token As String = auth.GetAccessToken()
         If Trim(token) = "" Then
            me.LogLine("Falha ao obter access token.")
            auth.Free()
            GoogleDriveSqlStores.DropConfig(cfg)
            Exit Sub
         End If
         me.LogLine("Access token obtido (nao exibido).")
         Dim driveCfg As New GoogleDriveConfig()
         Dim driveService As GoogleDriveService = GoogleDriveService.Load(auth, driveCfg)
         Dim info As GoogleDriveAbout = driveService.About().Gett()
         me.LogLine("Conta: " & info.DriveUser.DisplayName & " <" & info.DriveUser.EmailAddress & ">")
         GoogleDriveSqlStores.ApplyProfile(info.DriveUser.EmailAddress, info.DriveUser.DisplayName)
         info.Free()
         row = TConfiguracaoGoogleDrive.CurrentRow()
         If Assigned(row) Then
            me.LogLine("Linha SQL: Titulo=" & row.Titulo & " Email=" & row.Email & " hasRefresh=" & CStr(Trim(row.RefreshToken) <> ""))
            row.Free()
         End If
         Dim driveFolder As GoogleDriveFile = me.FindOrCreateFolder(driveService.Files(), folderName, parentId)
         me.LogLine("Pasta: " & driveFolder.Name & " (" & driveFolder.Id & ")")
         me.ListFolderContents(driveService.Files(), driveFolder.Id)
         driveFolder.Free()
         driveService.Free()
         driveCfg.Free()
         auth.Free()
         GoogleDriveSqlStores.DropConfig(cfg)
      End Sub

      Sub ListFolderContents(pFiles As GoogleDriveFiles, pFolderId As String)
         Dim listOptions As New GoogleDriveListOptions()
         Dim q As New GoogleDriveQuery()
         q.ParentsIn(pFolderId)
         q.Trashed(False)
         listOptions.Query = q.AsString()
         q.Free()
         Dim listing As GoogleDriveFileList
         Dim pageToken As String = ""
         Dim page As Integer = 0
         Dim shown As Integer = 0
         Dim driveFile As GoogleDriveFile
         Dim i As Integer
         me.LogLine("Arquivos na pasta:")
         While page < 3
            listOptions.PageToken = pageToken
            listing = pFiles.List(listOptions)
            If listing.Files.Length = 0 Then
               If shown = 0 Then
                  me.LogLine("  (pasta vazia)")
               End If
               listing.Free()
               Exit While
            End If
            For i = 0 To listing.Files.Length - 1
               driveFile = listing.Files.Take(i)
               shown = shown + 1
               me.LogLine("  " & CStr(shown) & ". " & driveFile.Name & " [" & driveFile.MimeType & "] id=" & driveFile.Id)
               If Trim(driveFile.SizeText) <> "" Then
                  me.LogLine("     tamanho: " & driveFile.SizeText & " bytes")
               End If
            Next
            pageToken = listing.NextPageToken
            listing.Free()
            If Trim(pageToken) = "" Then
               Exit While
            End If
            page = page + 1
         End While
         me.LogLine("Total listado: " & CStr(shown))
         listOptions.Free()
      End Sub

      Function FindOrCreateFolder(pFiles As GoogleDriveFiles, pName As String, pFolderId As String) As GoogleDriveFile
         If Trim(pFolderId) <> "" Then
            FindOrCreateFolder = pFiles.Gett(Trim(pFolderId))
            Exit Function
         End If
         Dim listOptions As New GoogleDriveListOptions()
         Dim q As New GoogleDriveQuery()
         q.NameEquals(pName)
         q.IsFolder()
         q.Trashed(False)
         listOptions.Query = q.AsString()
         q.Free()
         Dim listing As GoogleDriveFileList = pFiles.List(listOptions)
         listOptions.Free()
         Dim foundId As String = ""
         If listing.Files.Length > 0 Then
            foundId = listing.Files.Take(0).Id
         End If
         listing.Free()
         If Trim(foundId) <> "" Then
            FindOrCreateFolder = pFiles.Gett(foundId)
            Exit Function
         End If
         me.LogLine("Criando pasta: " & pName)
         FindOrCreateFolder = pFiles.CreateFolder(pName)
      End Function

      Function ResolveLocalPath(pWorkDir As String, pPath As String) As String
         Dim trimmed As String = Trim(pPath)
         If trimmed = "" Then
            ResolveLocalPath = ""
            Exit Function
         End If
         If TPath.IsDriveRooted(trimmed) Then
            ResolveLocalPath = trimmed
            Exit Function
         End If
         If TPath.GetPathRoot(trimmed) <> "" Then
            ResolveLocalPath = trimmed
            Exit Function
         End If
         ResolveLocalPath = TPath.Combine(pWorkDir, trimmed)
      End Function

      Sub LogLine(pText As String)
         Dim stamp As TDateTime = DateTime()
         Dim line As String = pText
         line = line.Replace(CHAR(13), " ")
         line = line.Replace(CHAR(10), " ")
         print(stamp.ToString("hh:mm:ss.zzz") & "  " & line)
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
