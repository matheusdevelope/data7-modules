Imports IO
Imports mod_portable_exe

' Ex .exe direto:
' Imports mod_remote_exe
' Class TFfmpeg
'    Inherits TRemotePortableExe
'    Sub New()
'       MyBase.New()
'       me.DownloadUrl = "https://exemplo.com/ffmpeg.exe"
'       me.ExeFileName = "ffmpeg.exe"
'       me.InstallFolder = "ffmpeg"
'    End Sub
' End Class

Namespace mod_remote_exe

   Class TRemotePortableExe
      Inherits TPortableExe

      Private _downloadUrl As String
      Private _downloadTimeoutMs As Integer

      Sub New()
         MyBase.New()
         me._downloadUrl = ""
         me._downloadTimeoutMs = 8000
      End Sub

      Property DownloadUrl As String
         Get
            DownloadUrl = me._downloadUrl
         End Get
         Set(pValue As String)
            me._downloadUrl = pValue
         End Set
      End Property

      Property DownloadTimeoutMs As Integer
         Get
            DownloadTimeoutMs = me._downloadTimeoutMs
         End Get
         Set(pValue As Integer)
            me._downloadTimeoutMs = pValue
         End Set
      End Property

      Overridable Function ResolveDownloadPath() As String
         ResolveDownloadPath = me.InstalledExePath()
      End Function

      Overridable Sub AfterDownload(pDownloaded As String, pTarget As String)
         If LCase(pDownloaded) <> LCase(pTarget) Then
            If IO.File.Exists(pDownloaded) Then
               TFile.Copy(pDownloaded, pTarget, True)
            End If
         End If
      End Sub

      Overrides Sub EnsureExe()
         Dim target As String = me.InstalledExePath()
         If IO.File.Exists(target) Then
            me.ExePath = target
            Exit Sub
         End If
         If me._downloadUrl = "" Then
            Throw New Exception("DownloadUrl is empty for " & me.ExeFileName)
         End If

         Dim downloaded As String = me.ResolveDownloadPath()
         me.EnsureDirectory(IO.File.ExtractDir(target))
         me.EnsureDirectory(IO.File.ExtractDir(downloaded))
         me.DownloadTo(downloaded)
         me.AfterDownload(downloaded, target)

         If Not IO.File.Exists(target) Then
            Throw New Exception("Executable not found after install: " & target)
         End If
         me.ExePath = target
      End Sub

      Protected Sub DownloadTo(pDest As String)
         Dim winHttpReq As Variant = CreateObject("WinHttp.WinHttpRequest.5.1")
         Dim binStream As Variant = CreateObject("ADODB.Stream")
         Dim timeoutMs As Integer = me._downloadTimeoutMs

         winHttpReq.SetTimeouts(timeoutMs, timeoutMs, timeoutMs, timeoutMs)
         winHttpReq.Open("GET", me._downloadUrl, False)
         winHttpReq.Send()

         If winHttpReq.Status <> 200 Then
            Throw New Exception("Error downloading " & me.ExeFileName & ": " & winHttpReq.Status)
         End If

         binStream.Type = 1
         binStream.Open()
         binStream.Write(winHttpReq.responseBody)
         binStream.SaveToFile(pDest, 2)
         binStream.Close()
         binStream = Unassigned
         winHttpReq = Unassigned
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
