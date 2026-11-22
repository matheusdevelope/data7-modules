Imports Collections
Imports Forms
Imports TFile
Imports TPath
Imports TDirectory
Imports TDialogs
Imports mod_tobject
Imports google_auth
Imports google_auth_config
Imports google_auth_store
Imports google_auth_stores
Imports google_auth_token_set
Imports google_drive
Imports google_drive_config
Imports google_drive_about
Imports google_drive_about_resource
Imports google_drive_user
Imports google_drive_file
Imports google_drive_file_list
Imports google_drive_files
Imports google_drive_list_options
Imports google_drive_query
Imports google_drive_scopes
Imports google_drive_upload_options
Imports google_drive_download_options
Imports google_drive_progress
Imports google_drive_json
Imports google_drive_integrity
Imports google_drive_live_coverage

Namespace google_drive_live

   Class GoogleDriveLive
      Inherits TTObject

      Private _lastPercent As Integer

      Shared Sub Run()
         Dim runner As New GoogleDriveLive()
         runner.UploadSample()
         runner.Free()
      End Sub

      Sub New()
         MyBase.New()
         me._lastPercent = -1
      End Sub

      Sub UploadSample()
         me.LogLine("==== upload real Google Drive ====")
         Dim workDir As String = TDirectory.GetCurrentDirectory()
         Dim oauthPath As String = me.ResolveLocalPath(workDir, "google-oauth.json")
         Dim tokensPath As String = me.ResolveLocalPath(workDir, "google-tokens.json")
         Dim livePath As String = me.ResolveLocalPath(workDir, "google-drive-live.json")
         Dim sessionPath As String = me.ResolveLocalPath(workDir, "google-drive-upload-session.json")
         Dim folderName As String = "mod_google_drive"
         Dim parentId As String = ""
         Dim sourcePath As String = ""
         Dim liveCfg As TJSONObject
         If TFile.Exists(livePath) Then
            liveCfg = New TJSONObject()
            liveCfg.LoadFromFile(livePath)
            If liveCfg.Has("oauth_file") Then
               If Trim(liveCfg.GetString("oauth_file")) <> "" Then
                  oauthPath = me.ResolveLocalPath(workDir, Trim(liveCfg.GetString("oauth_file")))
               End If
            End If
            If liveCfg.Has("tokens_file") Then
               If Trim(liveCfg.GetString("tokens_file")) <> "" Then
                  tokensPath = me.ResolveLocalPath(workDir, Trim(liveCfg.GetString("tokens_file")))
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
            If liveCfg.Has("source_path") Then
               sourcePath = me.ResolveLocalPath(workDir, Trim(liveCfg.GetString("source_path")))
            End If
            liveCfg.Free()
         End If
         If Not TFile.Exists(oauthPath) Then
            me.LogLine("Arquivo OAuth nao encontrado: " & oauthPath)
            me.LogLine("Coloque o JSON do cliente OAuth em google-oauth.json ou informe oauth_file em google-drive-live.json.")
            Exit Sub
         End If
         If Forms.MessageBox.Confirmation("Deseja selecionar um arquivo para enviar ao Google Drive?") Then
            Dim filterMask As String = "Todos os arquivos (*.*)|*.*|Compactados (*.zip;*.7z)|*.zip;*.7z|Texto (*.txt)|*.txt"
            Dim startDir As String = "" 'workDir
            If Trim(sourcePath) <> "" Then
               Dim parentDir As String = TPath.GetDirectoryName(sourcePath)
               If Trim(parentDir) <> "" Then
                  startDir = parentDir
               End If
            End If
            Dim chosenPath As String = TDialogs.OpenFile("Selecione o arquivo para upload", filterMask, startDir)
            TDirectory.SetCurrentDirectory(workDir)
            If Trim(chosenPath) = "" Then
               me.LogLine("Selecao de arquivo cancelada.")
               Exit Sub
            End If
            sourcePath = chosenPath
         End If
         If Trim(sourcePath) = "" Then
            sourcePath = TPath.Combine(workDir, "live-upload-sample.txt")
            Dim sampleLines As New StringList()
            sampleLines.Add("Upload de teste do modulo mod_google_drive.")
            sampleLines.SaveToFile(sourcePath)
            sampleLines.Free()
         End If
         If Not TFile.Exists(sourcePath) Then
            me.LogLine("Arquivo local nao encontrado: " & sourcePath)
            Exit Sub
         End If
         me.LogLine("OAuth: " & oauthPath)
         me.LogLine("Arquivo: " & sourcePath)
         Dim cfg As GoogleAuthConfig = GoogleAuthConfig.FromFile(oauthPath)
         Dim scopeUrl As String = GoogleDriveScopes.Drive()
         cfg.Scopes.Add(scopeUrl)
         cfg.Prompt = "consent"
         me.LogLine("Escopos: " & cfg.Scopes.AsQuery())
         Dim tokenStore As GoogleTokenStore = GoogleTokenStores.Json(tokensPath)
         Dim auth As GoogleAuthService = GoogleAuthService.Load(cfg, tokenStore)
         Dim needsConsent As Boolean = me.EnsureDriveConsent(auth, cfg, tokenStore, tokensPath)
         me.LogLine("Se o navegador abrir, autorize o Google Drive e marque o acesso aos arquivos.")
         Dim token As String = ""
         If needsConsent Then
            Dim granted As GoogleTokenSet = auth.Authorize()
            token = granted.AccessToken
            me.LogLine("Escopo concedido: " & granted.Scope)
            If Trim(granted.Scope) <> "" Then
               If Not me.HasDriveScope(granted.Scope) Then
                  me.LogLine("Google nao concedeu o escopo Drive. Ative a Google Drive API no Cloud Console e autorize de novo.")
                  granted.Free()
                  auth.Free()
                  cfg.ApiVersion = Null
                  cfg.GrantType = Null
                  cfg.ConsentKind = Null
                  cfg.Free()
                  Exit Sub
               End If
            End If
            granted.Free()
         Else
            token = auth.GetAccessToken()
         End If
         If Trim(token) = "" Then
            me.LogLine("Falha ao obter access token.")
            auth.Free()
            cfg.ApiVersion = Null
            cfg.GrantType = Null
            cfg.ConsentKind = Null
            cfg.Free()
            Exit Sub
         End If
         Dim driveCfg As New GoogleDriveConfig()
         driveCfg.AdaptiveChunkSize = True
         driveCfg.ChunkSizeBytes = 268435456
         Dim driveService As GoogleDriveService = GoogleDriveService.Load(auth, driveCfg)
         me.LogLine("Transporte HTTP: WinHTTP (TFileStream + FromStreamWindow por chunk)")
         me.LogLine("Chunk adaptativo upload: inicio " & CStr(GoogleDriveJson.DefaultChunkBytes()) & " bytes, teto " & CStr(driveCfg.ChunkSizeBytes))
         me.LogLine("Chunk adaptativo download: inicio " & CStr(GoogleDriveJson.DefaultChunkBytes()) & " bytes, teto " & CStr(GoogleDriveJson.MaxDownloadChunkBytes()) & " (WinHTTP ResponseBody; 128 MiB max)")
         Dim info As GoogleDriveAbout = driveService.About().Gett()
         me.LogLine("Conta: " & info.DriveUser.DisplayName & " <" & info.DriveUser.EmailAddress & ">")
         info.Free()
         Dim driveFolder As GoogleDriveFile = me.FindOrCreateFolder(driveService.Files(), folderName, parentId)
         me.LogLine("Pasta: " & driveFolder.Name & " (" & driveFolder.Id & ")")
         Dim uploadOptions As New GoogleDriveUploadOptions()
         uploadOptions.Name = TPath.GetFileName(sourcePath)
         uploadOptions.ParentId = driveFolder.Id
         uploadOptions.SessionFile = sessionPath
         uploadOptions.OnProgress = me.ReportUploadProgress
         me._lastPercent = -1
         me.LogLine("Enviando: 0%")
         Dim startedAt As TDateTime = DateTime()
         Dim uploadedFile As GoogleDriveFile = driveService.Files().Upload(sourcePath, uploadOptions)
         If Not Assigned(uploadedFile) Then
            me.LogLine("Upload terminou sem metadados do arquivo.")
            uploadOptions.Free()
            driveFolder.Free()
            driveService.Free()
            driveCfg.Free()
            auth.Free()
            cfg.ApiVersion = Null
            cfg.GrantType = Null
            cfg.ConsentKind = Null
            cfg.Free()
            Exit Sub
         End If
         me.LogLine("Upload OK em " & GoogleDriveJson.ElapsedText(startedAt, DateTime()))
         me.LogLine("  id: " & uploadedFile.Id)
         me.LogLine("  nome: " & uploadedFile.Name)
         If Trim(uploadedFile.SizeText) <> "" Then
            me.LogLine("  tamanho: " & uploadedFile.SizeText & " bytes")
         End If
         driveService.Files().VerifyUpload(sourcePath, uploadedFile)
         If Trim(uploadedFile.Md5Checksum) <> "" Then
            me.LogLine("  md5: " & uploadedFile.Md5Checksum)
         End If
         me.LogLine("  integridade: OK")
         Dim downloadPath As String = TPath.GetTempFileName()
         Dim downloadOptions As New GoogleDriveDownloadOptions()
         downloadOptions.DestinationPath = downloadPath
         downloadOptions.OnProgress = me.ReportDownloadProgress
         me._lastPercent = -1
         me.LogLine("Baixando para: " & downloadPath)
         me.LogLine("Baixando: 0%")
         startedAt = DateTime()
         driveService.Files().DownloadFile(uploadedFile, downloadOptions)
         me.LogLine("Download OK em " & GoogleDriveJson.ElapsedText(startedAt, DateTime()))
         If GoogleDriveIntegrity.HashesMatch(GoogleDriveIntegrity.HashLocal(downloadPath), uploadedFile.Md5Checksum) Then
            me.LogLine("  download: integridade OK")
         Else
            me.LogLine("  download: hash divergente")
         End If
         downloadOptions.Free()
         If TFile.Exists(downloadPath) Then
            TFile.Delete(downloadPath)
         End If
         If Trim(uploadedFile.WebViewLink) <> "" Then
            me.LogLine("  link: " & uploadedFile.WebViewLink)
         End If
         GoogleDriveLiveCoverage.Run(driveService, auth, driveFolder, uploadedFile)
         uploadedFile.Free()
         uploadOptions.Free()
         driveFolder.Free()
         driveService.Free()
         driveCfg.Free()
         auth.Free()
         cfg.ApiVersion = Null
         cfg.GrantType = Null
         cfg.ConsentKind = Null
         cfg.Free()
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

      Function EnsureDriveConsent(pAuth As GoogleAuthService, pCfg As GoogleAuthConfig, pTokenStore As GoogleTokenStore, pTokensPath As String) As Boolean
         Dim existing As GoogleTokenSet = pAuth.CurrentTokens()
         If Not Assigned(existing) Then
            EnsureDriveConsent = True
            Exit Function
         End If
         If me.HasDriveScope(existing.Scope) Then
            existing.Free()
            EnsureDriveConsent = False
            Exit Function
         End If
         me.LogLine("Token salvo sem escopo do Drive. Apagando google-tokens.json e pedindo autorizacao.")
         existing.Free()
         pTokenStore.Clear(pCfg.StoreKey())
         If TFile.Exists(pTokensPath) Then
            TFile.Delete(pTokensPath)
         End If
         EnsureDriveConsent = True
      End Function

      Sub LogLine(pText As String)
         Dim stamp As TDateTime = DateTime()
         Dim line As String = pText
         line = line.Replace(CHAR(13), " ")
         line = line.Replace(CHAR(10), " ")
         print(stamp.ToString("hh:mm:ss.zzz") & "  " & line)
      End Sub

      Sub ReportUploadProgress(pBytesSent As Int64, pTotalBytes As Int64)
         me.ReportTransferProgress("Enviando", pBytesSent, pTotalBytes)
      End Sub

      Sub ReportDownloadProgress(pBytesSent As Int64, pTotalBytes As Int64)
         me.ReportTransferProgress("Baixando", pBytesSent, pTotalBytes)
      End Sub

      Sub ReportTransferProgress(pVerb As String, pBytesSent As Int64, pTotalBytes As Int64)
         Dim sentText As String = GoogleDriveJson.Int64Text(pBytesSent)
         Dim totalText As String = GoogleDriveJson.Int64Text(pTotalBytes)
         Dim pct As Integer = 0
         If pTotalBytes > GoogleDriveJson.Zero64() Then
            Dim sentNum As Double = CDbl(sentText)
            Dim totalNum As Double = CDbl(totalText)
            pct = CInt((sentNum * 100) / totalNum)
            If (pct >= 100) And (pBytesSent < pTotalBytes) Then
               pct = 99
            End If
            If pBytesSent = pTotalBytes Then
               pct = 100
            End If
         Else
            pct = 100
         End If
         If pct > 100 Then
            pct = 100
         End If
         If (pct = me._lastPercent) And (pBytesSent < pTotalBytes) Then
            Exit Sub
         End If
         me._lastPercent = pct
         me.LogLine(pVerb & ": " & CStr(pct) & "% (" & sentText & " / " & totalText & " bytes)")
      End Sub

      Function HasDriveScope(pScopeText As String) As Boolean
         Dim padded As String = " " & LCase(Trim(pScopeText)) & " "
         Dim fullDrive As String = " " & LCase(GoogleDriveScopes.Drive()) & " "
         HasDriveScope = InStr(padded, fullDrive) > 0
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

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
