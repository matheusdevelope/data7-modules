Imports Collections
Imports IO
Imports mod_remote_exe

' Ex zip por URL:
' Imports mod_zip_exe
' Class TFfmpeg
'    Inherits TZipPortableExe
'    Sub New()
'       MyBase.New()
'       me.DownloadUrl = "https://exemplo.com/ffmpeg.zip"
'       me.ExeFileName = "ffmpeg.exe"
'       me.InstallFolder = "ffmpeg"
'       me.ArchiveName = "ffmpeg.zip"
'    End Sub
' End Class
'
' Ex zip local:
'    me.ZipPath = "C:\Temp\ffmpeg.zip"
'    me.ExeFileName = "ffmpeg.exe"
'
' Ex zip em base64:
'    me.ZipBase64 = "UEsD..."
'    me.ExeFileName = "ffmpeg.exe"

Namespace mod_zip_exe

   Class TZipPortableExe
      Inherits TRemotePortableExe

      Private _archiveName As String
      Private _zipPath As String
      Private _zipBase64 As String
      Private _searchRecursive As Boolean
      Private _deleteArchive As Boolean
      Private _createdArchive As Boolean

      Sub New()
         MyBase.New()
         me._archiveName = ""
         me._zipPath = ""
         me._zipBase64 = ""
         me._searchRecursive = True
         me._deleteArchive = True
         me._createdArchive = False
      End Sub

      Property ZipPath As String
         Get
            ZipPath = me._zipPath
         End Get
         Set(pValue As String)
            me._zipPath = pValue
         End Set
      End Property

      Property ZipBase64 As String
         Get
            ZipBase64 = me._zipBase64
         End Get
         Set(pValue As String)
            me._zipBase64 = pValue
         End Set
      End Property

      Property ArchiveName As String
         Get
            ArchiveName = me._archiveName
         End Get
         Set(pValue As String)
            me._archiveName = pValue
         End Set
      End Property

      Property SearchRecursive As Boolean
         Get
            SearchRecursive = me._searchRecursive
         End Get
         Set(pValue As Boolean)
            me._searchRecursive = pValue
         End Set
      End Property

      Property DeleteArchive As Boolean
         Get
            DeleteArchive = me._deleteArchive
         End Get
         Set(pValue As Boolean)
            me._deleteArchive = pValue
         End Set
      End Property

      Function ResolveZipPath() As String
         If me._zipPath <> "" Then
            ResolveZipPath = me._zipPath
            Exit Function
         End If
         ResolveZipPath = me.ResolveDownloadPath()
      End Function

      Overrides Sub EnsureExe()
         Dim target As String
         Dim zipPath As String
         me._createdArchive = False
         If me.TryReuseExe() Then
            Exit Sub
         End If
         target = me.InstalledExePath()
         zipPath = me.ResolveZipPath()
         If Not TFile.Exists(zipPath) Then
            me.EnsureDirectory(TPath.GetDirectoryName(zipPath))
            If me._zipBase64 <> "" Then
               Base64ToFile(me._zipBase64, zipPath)
               me._createdArchive = True
            ElseIf me.DownloadUrl <> "" Then
               me.DownloadTo(zipPath)
               me._createdArchive = True
            Else
               Throw New Exception("No zip source for " & me.ExeFileName & ": set ZipPath, ZipBase64 or DownloadUrl")
            End If
         End If

         If Not TFile.Exists(zipPath) Then
            Throw New Exception("Zip not found: " & zipPath)
         End If

         me.EnsureDirectory(TPath.GetDirectoryName(target))
         me.AfterDownload(zipPath, target)
         me._createdArchive = False

         If Not TFile.Exists(target) Then
            Throw New Exception("Executable not found after install: " & target)
         End If
         me.CacheExePath(target)
      End Sub

      Overrides Function ResolveDownloadPath() As String
         Dim zipName As String
         zipName = me._archiveName
         If zipName = "" Then
            If me.InstallFolder <> "" Then
               zipName = me.InstallFolder & ".zip"
            Else
               zipName = TPath.ChangeExtension(me.ExeFileName, ".zip")
            End If
         End If
         ResolveDownloadPath = TPath.Combine(me.AppDir(), zipName)
      End Function

      Overrides Sub AfterDownload(pDownloaded As String, pTarget As String)
         Dim extractDir As String
         Dim foundPath As String
         extractDir = TPath.GetDirectoryName(pTarget)
         me.EnsureDirectory(extractDir)
         me.UnzipArchive(pDownloaded, extractDir)
         If me._deleteArchive And me._createdArchive Then
            If TFile.Exists(pDownloaded) Then
               TFile.Delete(pDownloaded)
            End If
         End If

         If TFile.Exists(pTarget) Then
            Exit Sub
         End If
         If Not me._searchRecursive Then
            Exit Sub
         End If

         foundPath = me.FindFile(extractDir, me.ExeFileName)
         If foundPath = "" Then
            Throw New Exception(me.ExeFileName & " not found after extraction.")
         End If
         TFile.Copy(foundPath, pTarget, True)
      End Sub

      Private Sub UnzipArchive(pZipPath As String, pExtractDir As String)
         With New IO.File.ZipFile()
            .Unzip(pZipPath, pExtractDir)
            .Free()
         End With
      End Sub

      Private Function FindFile(pFolder As String, pName As String) As String
         Dim files As StringList
         Dim dirs As StringList
         Dim i As Integer
         Dim fullPath As String
         Dim nested As String
         Dim itemName As String
         Dim wantName As String
         files = TDirectory.GetFiles(pFolder)
         wantName = pName.ToLower()

         For i = 0 To files.Count - 1
            fullPath = files.Strings(i)
            itemName = TPath.GetFileName(fullPath)
            If itemName.ToLower() = wantName Then
               files.Free()
               FindFile = fullPath
               Exit Function
            End If
         Next
         files.Free()

         dirs = TDirectory.GetDirectories(pFolder)
         For i = 0 To dirs.Count - 1
            nested = me.FindFile(dirs.Strings(i), pName)
            If nested <> "" Then
               dirs.Free()
               FindFile = nested
               Exit Function
            End If
         Next
         dirs.Free()
         FindFile = ""
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
