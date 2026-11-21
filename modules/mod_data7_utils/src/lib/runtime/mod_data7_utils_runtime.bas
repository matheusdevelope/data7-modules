Imports IO
Imports mod_data7_utils_payload

Namespace mod_data7_utils_runtime

   Private Dim _extracted As Boolean
   Private Dim _runtimeDir As String
   Private Dim _manifestPath As String
   Private Dim _dllPath As String

   Function RuntimeDir() As String
      If _runtimeDir <> "" Then
         RuntimeDir = _runtimeDir
         Exit Function
      End If
      RuntimeDir = IO.File.ExtractDir(Data7.NomeArquivoExecutavel()) & "\data7utils\" & PayloadVersion
   End Function

   Function ManifestPath() As String
      If _manifestPath <> "" Then
         ManifestPath = _manifestPath
         Exit Function
      End If
      ManifestPath = RuntimeDir() & "\Data7Utils.dll.manifest"
   End Function

   Function DllPath() As String
      If _dllPath <> "" Then
         DllPath = _dllPath
         Exit Function
      End If
      DllPath = RuntimeDir() & "\Data7Utils.dll"
   End Function

   Function HostDir() As String
      HostDir = IO.File.ExtractDir(Data7.NomeArquivoExecutavel())
   End Function

   Function HostVersionStampPath() As String
      HostVersionStampPath = HostDir() & "\Data7Utils.version"
   End Function

   Function HostIsCurrentVersion() As Boolean
      Dim stampPath As String = HostVersionStampPath()
      Dim hostDll As String = HostDir() & "\Data7Utils.dll"
      Dim hostMan As String = HostDir() & "\Data7Utils.dll.manifest"
      Dim text As String
      Dim fso As Variant
      Dim reader As Variant
      If Not IO.File.Exists(hostDll) Then
         HostIsCurrentVersion = False
         Exit Function
      End If
      If Not IO.File.Exists(hostMan) Then
         HostIsCurrentVersion = False
         Exit Function
      End If
      If Not IO.File.Exists(stampPath) Then
         HostIsCurrentVersion = False
         Exit Function
      End If
      fso = CreateObject("Scripting.FileSystemObject")
      reader = fso.OpenTextFile(stampPath, 1)
      text = Trim(reader.ReadAll)
      reader.Close()
      reader = Unassigned
      fso = Unassigned
      HostIsCurrentVersion = (text = PayloadVersion)
   End Function

   Sub WriteHostVersionStamp()
      Dim stampPath As String = HostVersionStampPath()
      Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
      Dim writer As Variant = fso.CreateTextFile(stampPath, True)
      writer.Write(PayloadVersion)
      writer.Close()
      writer = Unassigned
      fso = Unassigned
   End Sub

   Sub RefreshHostComFiles()
      Dim hostDll As String = HostDir() & "\Data7Utils.dll"
      Dim hostMan As String = HostDir() & "\Data7Utils.dll.manifest"
      If HostIsCurrentVersion() Then
         Exit Sub
      End If
      Try
         If IO.File.Exists(hostDll) Then
            IO.File.Delete(hostDll)
         End If
         If IO.File.Exists(hostMan) Then
            IO.File.Delete(hostMan)
         End If
         IO.File.Copy(_dllPath, hostDll)
         IO.File.Copy(_manifestPath, hostMan)
         WriteHostVersionStamp()
      Catch ex As Exception
         Throw New Exception("Cannot refresh Data7Utils.dll next to the host for version " & PayloadVersion & ". Close Data7 DevStudio and run again. " & ex._GetMessage())
      End Try
   End Sub

   Class TComRuntime

      Private _progId As String
      Protected COM As Variant

      Sub New(pProgId As String)
         MyBase.New()
         me._progId = pProgId
         TComRuntime.EnsureExtracted()
         me.COM = TComRuntime.CreateCom(pProgId)
      End Sub

      Shared Sub EnsureExtracted()
         If _extracted Then
            Exit Sub
         End If

         _runtimeDir = RuntimeDir()
         _dllPath = DllPath()
         _manifestPath = ManifestPath()

         If Not IO.File.Exists(_dllPath) Or Not IO.File.Exists(_manifestPath) Then
            Dim payload As String = ZipBase64()
            If payload = "" Then
               Throw New Exception("Data7Utils COM payload is empty. Run scripts/Update-ComPayload.ps1.")
            End If
            If payload.Left(5) <> "UEsDB" Then
               Throw New Exception("Data7Utils COM payload is not a ZIP archive. Run scripts/Update-ComPayload.ps1.")
            End If

            Dim packDir As String = IO.File.ExtractDir(_runtimeDir)
            If Not IO.Directory.Exists(packDir) Then
               IO.Directory.Create(packDir)
            End If
            If Not IO.Directory.Exists(_runtimeDir) Then
               IO.Directory.Create(_runtimeDir)
            End If
            Dim zipPath As String = _runtimeDir & "\Data7Utils.zip"
            Base64ToFile(payload, zipPath)

            Dim archive As IO.File.ZipFile = New IO.File.ZipFile()
            archive.Unzip(zipPath, _runtimeDir)
            archive.Free()
            IO.File.Delete(zipPath)

            If Not IO.File.Exists(_dllPath) Or Not IO.File.Exists(_manifestPath) Then
               Throw New Exception("Failed to extract Data7Utils.dll and manifest to " & _runtimeDir)
            End If
         End If

         RefreshHostComFiles()
         _extracted = True
      End Sub

      Shared Function CreateCom(pProgId As String) As Variant
         TComRuntime.EnsureExtracted()
         Dim comObject As Variant
         Try
            comObject = CreateFromManifest(pProgId)
         Catch ex As Exception
            Try
               comObject = CreateObject(pProgId)
            Catch fallbackEx As Exception
               Throw New Exception("Erro ao carregar lib " & pProgId & CHAR(13) & "ActCtx: " & ex._GetMessage() & CHAR(13) & fallbackEx._GetMessage())
            End Try
         End Try
         CreateCom = comObject
      End Function

      Protected Function ComHandle() As Variant
         ComHandle = me.COM
      End Function

      Protected Function ProgId() As String
         ProgId = me._progId
      End Function

      Sub Free()
         me.COM = Unassigned
         MyBase.Free()
      End Sub

      Private Shared Function CreateFromManifest(pProgId As String) As Variant
         Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
         Dim manifestAbs As String = fso.GetAbsolutePathName(HostDir() & "\Data7Utils.dll.manifest")
         fso = Unassigned
         Dim context As Variant = CreateObject("Microsoft.Windows.ActCtx")
         Dim created As Variant
         context.Manifest = manifestAbs
         created = context.CreateObject(pProgId)
         context = Unassigned
         CreateFromManifest = created
      End Function

   End Class

End Namespace
