Imports Collections
Imports Forms
Imports IO
Imports mod_portable_exe
' Ex:
' Imports mod_camera
' Dim cam As New TCamera()
' cam.Width = 1920
' cam.Height = 1080
' cam.Quality = 100
' cam.Format = ".jpg"
' cam.Mirror = True
' ' Padrão: devolve o path do arquivo
' ' cam.OutputPath = "C:\Temp\foto.jpg"
' ' Base64 pela flag da classe:
' ' cam.OutputAsBase64 = True
' Dim foto As String = cam.Capture()
' ' Ou só nesta chamada:
' ' Dim foto As String = cam.Capture(True)
' If foto <> "" Then
'    print("Captura concluída: " & foto)
' Else
'    print("Captura cancelada pelo usuário.")
' End If
' cam.Free()

Namespace mod_camera

   Class TCamera
      Inherits TPortableExe
      Private _exeBase64 As String = "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fKIAAFihAAAAAAAAAAAAAAAAAACJogAAbKEAAAAAAAAAAAAAAAAAAJOiAAB0oQAAAAAAAAAAAAAAAAAAoKIAAHyhAAAAAAAAAAAAAAAAAACrogAAhKEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvKIAAAAAAADCogAAAAAAAMiiAAAAAAAA3qIAAAAAAADwogAAAAAAAPaiAAAAAAAAAqMAAAAAAAAKowAAAAAAADKjAAAUowAAIqMAAECjAAAAAAAAUKMAAAAAAAAJAACAAAAAAGCjAAAAAAAAaqMAAAAAAABhcGktbXMtd2luLWNydC1jb252ZXJ0LWwxLTEtMC5kbGwAYXBpLW1zLXdpbi1jcnQtaGVhcC1sMS0xLTAuZGxsAGFwaS1tcy13aW4tY3J0LWxvY2FsZS1sMS0xLTAuZGxsAGFwaS1tcy13aW4tY3J0LW1hdGgtbDEtMS0wLmRsbABhcGktbXMtd2luLWNydC1ydW50aW1lLWwxLTEtMC5kbGwAYXBpLW1zLXdpbi1jcnQtc3RkaW8tbDEtMS0wLmRsbABhcGktbXMtd2luLWNydC1zdHJpbmctbDEtMS0wLmRsbABnZGlwbHVzLmRsbABLRVJORUwzMi5ETEwAb2xlMzIuZGxsAE9MRUFVVDMyLmRsbABVU0VSMzIuZGxsAFZDUlVOVElNRTE0MC5kbGwAAABhdG9pAABmcmVlAABfY29uZmlndGhyZWFkbG9jYWxlAAAAX19zZXR1c2VybWF0aGVycgAAZXhpdAAAX3NldF9mbW9kZQAAc3RyY21wAABHZGlwRnJlZQAARXhpdFByb2Nlc3MAAABHZXRQcm9jQWRkcmVzcwAATG9hZExpYnJhcnlBAABWaXJ0dWFsUHJvdGVjdAAAQ29UYXNrTWVtRnJlZQAAAFNldFRpbWVyAABtZW1jbXAAAACAAAAUAAAAgj2IP4w/lD/sPwAAAJAAAAwAAAAEMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      Width As Integer
      Height As Integer
      Quality As Integer
      Mirror As Boolean
      Format As String
      OutputAsBase64 As Boolean
      OutputPath As String

      Sub New()
         MyBase.New()
         me.ExeBase64 = me._exeBase64
         me.ExeFileName = "mod_camera_cam_ds.exe"
         me.Width = 1920
         me.Height = 1080
         me.Quality = 100
         me.Mirror = False
         me.Format = ".jpg"
         me.OutputAsBase64 = False
         me.OutputPath = ""
      End Sub

      Function Capture(pOutputAsBase64 As Boolean = False) As String
         me.EnsureExe()
         Dim ui As New TFormCamera(me)
         ui.Show()
         Dim capturedPath As String = ui.ResultPath
         ui.Free()
         If capturedPath = "" Then
            Capture = ""
            Exit Function
         End If
         If me.OutputAsBase64 Or pOutputAsBase64 Then
            Capture = Replace(Replace(FileToBase64(capturedPath), Char(10), ""), Char(13), "")
            If me.OutputPath = "" Then
               If File.Exists(capturedPath) Then
                  File.Delete(capturedPath)
               End If
            End If
         Else
            Capture = capturedPath
         End If
      End Function

      Function ResolveOutputPath() As String
         If me.OutputPath <> "" Then
            ResolveOutputPath = me.OutputPath
            Exit Function
         End If
         ResolveOutputPath = me.GetTempFilePath("mod_camera_", me.Format)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TFormCamera
      Private _form As Forms.Form
      Private _preview As Forms.PageControl
      Private _footer As Forms.PageControl
      Private _comboCameras As Forms.HComboBox
      Private _btnConfig As Forms.CommandButton
      Private _btnInverter As Forms.CommandButton
      Private _btnCapturar As Forms.CommandButton
      Private _config As TCamera

      ResultPath As String

      Sub New(pConfig As TCamera)
         MyBase.New()
         me._config = pConfig
         me.ResultPath = ""
         me._build()
      End Sub

      Private Sub _build()
         me._form = New Forms.Form()
         me._form.Width = 640
         me._form.Height = 560
         me._form.Caption = "Captura de Câmera"
         me._form.OnShow = me._handleShow
         me._form.OnClose = me._handleClose
         me._footer = New Forms.PageControl(me._form)
         me._footer.Align = alBottom
         me._footer.Height = 44
         me._applyMargins(me._footer)
         me._preview = New Forms.PageControl(me._form)
         me._preview.Align = alClient
         me._applyMargins(me._preview)
         me._btnCapturar = New Forms.CommandButton(me._footer)
         me._btnCapturar.Align = alRight
         me._btnCapturar.Width = 120
         me._btnCapturar.Caption = "Capturar"
         me._btnCapturar.OnClick = me._handleCapturar
         me._applyMargins(me._btnCapturar)
         me._btnInverter = New Forms.CommandButton(me._footer)
         me._btnInverter.Align = alRight
         me._btnInverter.Width = 80
         me._btnInverter.Caption = "Inverter"
         me._btnInverter.OnClick = me._handleInverter
         me._applyMargins(me._btnInverter)
         me._btnConfig = New Forms.CommandButton(me._footer)
         me._btnConfig.Align = alRight
         me._btnConfig.Width = 80
         me._btnConfig.Caption = "Config"
         me._btnConfig.OnClick = me._handleConfig
         me._applyMargins(me._btnConfig)
         me._comboCameras = New Forms.HComboBox(me._footer)
         me._comboCameras.Align = alClient
         me._comboCameras.OnChange = me._handleComboChange
         me._applyMargins(me._comboCameras)
      End Sub

      Private Sub _applyMargins(pControl As TControl)
         pControl.AlignWithMargins = True
         pControl.Margins.Left = 3
         pControl.Margins.Top = 3
         pControl.Margins.Right = 3
         pControl.Margins.Bottom = 3
      End Sub

      Function Show() As Boolean
         me._form.Show()
         Show = True
      End Function

      Private Function _resolveCameraIndex(pText As String) As Integer
         Dim startIdx As Integer = InStr(pText, "[")
         Dim endIdx As Integer = InStr(pText, "]")
         If startIdx > 0 And endIdx > startIdx Then
            _resolveCameraIndex = CInt(Mid(pText, startIdx + 1, endIdx - startIdx - 1))
            Exit Function
         End If
         _resolveCameraIndex = 0
      End Function

      Private Function _getCameraList() As StringList
         _getCameraList = me._config.ExecReadLines("-list")
      End Function

      Private Sub _startPreview(pCamIndex As Integer)
         Try
            If me._config.IsRunning() Then
               me._config.WriteLine("change " & CStr(pCamIndex))
               Exit Sub
            End If
            Dim args As String = "-hwnd " & CStr(me._preview.Handle) & " -d " & CStr(pCamIndex)
            If me._config.Width > 0 Then
               args = args & " -w " & CStr(me._config.Width)
            End If
            If me._config.Height > 0 Then
               args = args & " -h " & CStr(me._config.Height)
            End If
            If me._config.Quality > 0 Then
               args = args & " -q " & CStr(me._config.Quality)
            End If
            If me._config.Mirror Then
               args = args & " -mirror"
            End If
            me._config.StartProcess(args)
         Catch ex As Exception
            print("Erro ao iniciar câmera: " & ex.Message)
         End Try
      End Sub

      Private Sub _handleShow(pSender As TObject)
         Dim lista As StringList = me._getCameraList()
         me._comboCameras.Items.Clear()
         If lista.Count > 0 Then
            me._comboCameras.Items.AddStrings(lista)
            me._comboCameras.ItemIndex = 0
            me._startPreview(me._resolveCameraIndex(me._comboCameras.Items(0)))
         Else
            me._comboCameras.Items.Add("Nenhuma câmera encontrada")
            me._comboCameras.ItemIndex = 0
         End If
         lista.Free()
      End Sub

      Private Sub _handleComboChange(pSender As TObject)
         If me._comboCameras.ItemIndex >= 0 Then
            If me._comboCameras.Items(0) <> "Nenhuma câmera encontrada" Then
               Dim txtSelect As String = me._comboCameras.Items(me._comboCameras.ItemIndex)
               me._startPreview(me._resolveCameraIndex(txtSelect))
            End If
         End If
      End Sub

      Private Sub _handleConfig(pSender As TObject)
         If me._config.IsRunning() Then
            me._config.WriteLine("settings")
         End If
      End Sub

      Private Sub _handleInverter(pSender As TObject)
         If me._config.IsRunning() Then
            me._config.Mirror = Not me._config.Mirror
            If me._config.Mirror Then
               me._config.WriteLine("mirror 1")
            Else
               me._config.WriteLine("mirror 0")
            End If
         End If
      End Sub

      Private Sub _handleCapturar(pSender As TObject)
         Dim savePath As String = me._config.ResolveOutputPath()
         me._btnCapturar.Caption = "Processando..."
         If me._config.IsRunning() Then
            Try
               me._config.WriteLine("capture " & savePath)
               Dim outLine As String = me._config.WaitForOutput("captured:", "erro:")
               If InStr(outLine, "captured:") > 0 Then
                  me.ResultPath = savePath
                  me._form.Close()
                  Exit Sub
               End If
               If InStr(outLine, "erro:") > 0 Then
                  print("Erro C++: " & outLine)
               End If
            Catch ex As Exception
               print("Erro na comunicação IPC: " & ex.Message)
            End Try
         End If
         print("Erro ao tentar capturar o frame.")
         me._btnCapturar.Caption = "Capturar"
      End Sub

      Private Sub _handleClose(pSender As TObject, pAction As TCloseAction)
         me._config.StopProcess()
      End Sub

      Sub Free()
         me._form.Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace