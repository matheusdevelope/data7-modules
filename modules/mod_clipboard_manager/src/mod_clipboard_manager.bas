Imports Collections

Namespace mod_clipboard_manager
    ' =========================================================================
    ' DECLARAÇÕES DA API WIN32 (Textos, Imagens, Arquivos e Memória)
    ' =========================================================================

    ' Constantes do Clipboard
    Private Const CF_TEXT = 1
    Private Const CF_BITMAP = 2
    Private Const CF_UNICODETEXT = 13
    Private Const CF_HDROP = 15 ' Formato para Arquivos (Windows Explorer)
    Private Const IMAGE_BITMAP = 0
    Private Const GMEM_MOVEABLE = 2
    Private Const GHND = 66 ' GMEM_MOVEABLE (2) + GMEM_ZEROINIT (64) - Aloca memória já zerada

    ' Estruturas GDI+ (Imagens)
    Private Structure TGdiplusStartupInput
        GdiplusVersion As Long
        DebugEventCallback As Long
        SuppressBackgroundThread As Long
        SuppressExternalCodecs As Long
    End Structure

    Private Structure TGUID
        L1 As Long
        L2 As Long
        L3 As Long
        L4 As Long
    End Structure

    ' Estrutura de Drop de Arquivos (Win32 DROPFILES)
    Private Structure DROPFILES
        pFiles As Long
        ptX As Long
        ptY As Long
        fNC As Long
        fWide As Long
    End Structure

    ' Clipboard (user32.dll)
    Private Declare Function _OpenClipboard Lib "user32.dll" Alias "OpenClipboard" (pHwnd As Long) As Long
    Private Declare Function _CloseClipboard Lib "user32.dll" Alias "CloseClipboard" () As Long
    Private Declare Function _EmptyClipboard Lib "user32.dll" Alias "EmptyClipboard" () As Long
    Private Declare Function _SetClipboardData Lib "user32.dll" Alias "SetClipboardData" (pFormat As Long, pHandle As Long) As Long
    Private Declare Function _GetClipboardData Lib "user32.dll" Alias "GetClipboardData" (pFormat As Long) As Long
    Private Declare Function _IsClipboardFormatAvailable Lib "user32.dll" Alias "IsClipboardFormatAvailable" (pFormat As Long) As Long
    Private Declare Function _CopyImage Lib "user32.dll" Alias "CopyImage" (ByVal hImage As Long, ByVal uType As Long, ByVal cxDesired As Long, ByVal cyDesired As Long, ByVal fuFlags As Long) As Long

    ' Memória e Textos (kernel32.dll)
    Private Declare Function _GlobalAlloc Lib "kernel32" Alias "GlobalAlloc" (ByVal wFlags As Long, ByVal dwBytes As Long) As Long
    Private Declare Function _GlobalLock Lib "kernel32" Alias "GlobalLock" (ByVal hMem As Long) As Long
    Private Declare Function _GlobalUnlock Lib "kernel32" Alias "GlobalUnlock" (ByVal hMem As Long) As Long
    Private Declare Function _GlobalSize Lib "kernel32" Alias "GlobalSize" (ByVal hMem As Long) As Long
    Private Declare Function _GlobalFree Lib "kernel32" Alias "GlobalFree" (ByVal hMem As Long) As Long
    Private Declare Function _lstrcpyWWrite Lib "kernel32" Alias "lstrcpyW" (ByVal lpString1 As Long, ByVal lpString2 As String) As Long
    Private Declare Function _lstrcpyWRead Lib "kernel32" Alias "lstrcpyW" (ByVal lpString1 As String, ByVal lpString2 As Long) As Long
    Private Declare Sub _CopyMemoryDropFiles Lib "kernel32.dll" Alias "RtlMoveMemory" (ByVal dest As Long, ByRef src As DROPFILES, ByVal length As Long)

    ' Motor de Arquivos (shell32.dll)
    Private Declare Function _DragQueryFileW Lib "shell32.dll" Alias "DragQueryFileW" (ByVal hDrop As Long, ByVal iFile As Long, ByVal lpszFile As String, ByVal cch As Long) As Long

    ' Objetos Gráficos (gdi32.dll)
    Private Declare Function _DeleteObject Lib "gdi32.dll" Alias "DeleteObject" (ByVal hObject As Long) As Long

    ' Motor GDI+ (gdiplus.dll)
    Private Declare Function _GdiplusStartup Lib "gdiplus.dll" Alias "GdiplusStartup" (ByRef token As Long, ByRef inputBuf As TGdiplusStartupInput, ByVal outputBuf As Long) As Long
    Private Declare Function _GdiplusShutdown Lib "gdiplus.dll" Alias "GdiplusShutdown" (ByVal token As Long) As Long
    Private Declare Function _GdipLoadImageFromFile Lib "gdiplus.dll" Alias "GdipLoadImageFromFile" (ByVal filename As String, ByRef image As Long) As Long
    Private Declare Function _GdipCreateHBITMAPFromBitmap Lib "gdiplus.dll" Alias "GdipCreateHBITMAPFromBitmap" (ByVal bitmap As Long, ByRef hbmReturn As Long, ByVal background As Long) As Long
    Private Declare Function _GdipCreateBitmapFromHBITMAP Lib "gdiplus.dll" Alias "GdipCreateBitmapFromHBITMAP" (ByVal hbm As Long, ByVal hpal As Long, ByRef bitmap As Long) As Long
    Private Declare Function _GdipSaveImageToFile Lib "gdiplus.dll" Alias "GdipSaveImageToFile" (ByVal image As Long, ByVal filename As String, ByRef clsidEncoder As TGUID, ByVal encoderParams As Long) As Long
    Private Declare Function _GdipDisposeImage Lib "gdiplus.dll" Alias "GdipDisposeImage" (ByVal image As Long) As Long


    Class ClipboardManager

        ' ---------------------------------------------------------------------
        ' 1. ARQUIVOS (WINDOWS EXPLORER)
        ' ---------------------------------------------------------------------

        Shared Function HasFiles() As Boolean
            HasFiles = (_IsClipboardFormatAvailable(CF_HDROP) <> 0)
        End Function

        ' Retorna os caminhos dos arquivos copiados como um objeto StringList
        Shared Function GetFiles() As StringList
            Dim result As New StringList()

            If _IsClipboardFormatAvailable(CF_HDROP) <> 0 Then
                If _OpenClipboard(0) <> 0 Then
                    Dim hDrop As Long = _GetClipboardData(CF_HDROP)

                    If hDrop <> 0 Then
                        ' Passar -1 no iFile retorna a quantidade de arquivos no clipboard
                        Dim fileCount As Long = _DragQueryFileW(hDrop, -1, "", 0)
                        Dim i As Long

                        For i = 0 To fileCount - 1
                            Dim buffer As String = Space(512)
                            ' Extrai o caminho de cada arquivo usando a Shell do Windows
                            Dim pathLen As Long = _DragQueryFileW(hDrop, i, buffer, 512)

                            If pathLen > 0 Then
                                ' Adiciona o arquivo diretamente na StringList
                                result.Add(Left(buffer, pathLen))
                            End If
                        Next
                    End If
                    _CloseClipboard()
                End If
            End If

            GetFiles = result
        End Function

        ' Envia arquivos para o Clipboard recebendo um objeto StringList
        Shared Function SetFiles(pFiles As StringList) As Boolean
            Dim success As Boolean = False

            ' Validação de segurança básica
            If Not Assigned(pFiles) Then
                SetFiles = False
                Exit Function
            End If

            If pFiles.Count = 0 Then
                SetFiles = False
                Exit Function
            End If

            ' Calcula o tamanho da memória necessária
            Dim structSize As Long = 20 ' Tamanho da estrutura DROPFILES
            Dim stringsSize As Long = 0
            Dim i As Integer

            For i = 0 To pFiles.Count - 1
                Dim path As String = Trim(pFiles(i))
                If path <> "" Then
                    stringsSize = stringsSize + (Len(path) * 2) + 2 ' Cada char é 2 bytes + 2 bytes do terminador nulo
                End If
            Next
            stringsSize = stringsSize + 2 ' Duplo terminador nulo que avisa o Windows que a lista acabou

            ' Aloca a memória já zerada (GHND)
            Dim hMem As Long = _GlobalAlloc(GHND, structSize + stringsSize)
            If hMem <> 0 Then
                Dim pMem As Long = _GlobalLock(hMem)
                If pMem <> 0 Then

                    ' 1. Cria e escreve o cabeçalho (DROPFILES)
                    Dim df As DROPFILES
                    df.pFiles = 20 ' Os caminhos de texto começam 20 bytes à frente
                    df.ptX = 0
                    df.ptY = 0
                    df.fNC = 0
                    df.fWide = 1 ' Avisa o Windows que os caminhos são Unicode

                    _CopyMemoryDropFiles(pMem, df, 20)

                    ' 2. Escreve os caminhos reais na sequência
                    Dim pStr As Long = pMem + 20
                    For i = 0 To pFiles.Count - 1
                        Dim _path As String = Trim(pFiles(i))
                        If _path <> "" Then
                            _lstrcpyWWrite(pStr, _path)
                            pStr = pStr + (Len(_path) * 2) + 2 ' Pula o cursor de memória pro próximo arquivo
                        End If
                    Next

                    _GlobalUnlock(hMem)

                    ' 3. Confirma o pacote no Clipboard
                    If _OpenClipboard(0) <> 0 Then
                        _EmptyClipboard()
                        If _SetClipboardData(CF_HDROP, hMem) <> 0 Then
                            success = True
                        End If
                        _CloseClipboard()
                    End If
                End If
            End If

            SetFiles = success
        End Function

        Shared Function SetImageAndFile(pFilePath As String) As Boolean
            Dim path As String = Trim(pFilePath)
            If (path = "") Or (Not IO.File.Exists(path)) Then
                SetImageAndFile = False
                Exit Function
            End If

            Dim hBitmap As Long = 0
            Dim hBitmapSrc As Long = 0
            Dim gdiToken As Long = 0
            Dim gdiImage As Long = 0
            Dim gdiInput As TGdiplusStartupInput
            gdiInput.GdiplusVersion = 1
            gdiInput.DebugEventCallback = 0
            gdiInput.SuppressBackgroundThread = 0
            gdiInput.SuppressExternalCodecs = 0

            If _GdiplusStartup(gdiToken, gdiInput, 0) = 0 Then
                If _GdipLoadImageFromFile(path, gdiImage) = 0 Then
                    If _GdipCreateHBITMAPFromBitmap(gdiImage, hBitmapSrc, -1) = 0 Then
                        hBitmap = _CopyImage(hBitmapSrc, IMAGE_BITMAP, 0, 0, 0)
                        If hBitmap <> 0 Then
                            _DeleteObject(hBitmapSrc)
                            hBitmapSrc = 0
                        Else
                            hBitmap = hBitmapSrc
                            hBitmapSrc = 0
                        End If
                    End If
                    _GdipDisposeImage(gdiImage)
                End If
                _GdiplusShutdown(gdiToken)
            End If

            Dim structSize As Long = 20
            Dim stringsSize As Long = (Len(path) * 2) + 4
            Dim hMem As Long = _GlobalAlloc(GHND, structSize + stringsSize)
            If hMem <> 0 Then
                Dim pMem As Long = _GlobalLock(hMem)
                If pMem <> 0 Then
                    Dim df As DROPFILES
                    df.pFiles = 20
                    df.ptX = 0
                    df.ptY = 0
                    df.fNC = 0
                    df.fWide = 1
                    _CopyMemoryDropFiles(pMem, df, 20)
                    _lstrcpyWWrite(pMem + 20, path)
                    _GlobalUnlock(hMem)
                Else
                    _GlobalFree(hMem)
                    hMem = 0
                End If
            End If

            Dim success As Boolean = False
            If _OpenClipboard(0) <> 0 Then
                _EmptyClipboard()
                If hBitmap <> 0 Then
                    If _SetClipboardData(CF_BITMAP, hBitmap) <> 0 Then
                        success = True
                        hBitmap = 0
                    End If
                End If
                If hMem <> 0 Then
                    If _SetClipboardData(CF_HDROP, hMem) <> 0 Then
                        success = True
                        hMem = 0
                    End If
                End If
                _CloseClipboard()
            End If

            If hBitmap <> 0 Then
                _DeleteObject(hBitmap)
            End If
            If hMem <> 0 Then
                _GlobalFree(hMem)
            End If
            SetImageAndFile = success
        End Function
        Shared Function HasText() As Boolean
            HasText = (_IsClipboardFormatAvailable(CF_UNICODETEXT) <> 0) Or (_IsClipboardFormatAvailable(CF_TEXT) <> 0)
        End Function

        Shared Function SetText(pText As String) As Boolean
            Dim success As Boolean = False
            Dim bytes As Long = (Len(pText) + 1) * 2
            Dim hMem As Long = _GlobalAlloc(GMEM_MOVEABLE, bytes)

            If hMem <> 0 Then
                Dim pMem As Long = _GlobalLock(hMem)
                If pMem <> 0 Then
                    _lstrcpyWWrite(pMem, pText)
                    _GlobalUnlock(hMem)

                    If _OpenClipboard(0) <> 0 Then
                        _EmptyClipboard()
                        If _SetClipboardData(CF_UNICODETEXT, hMem) <> 0 Then
                            success = True
                        End If
                        _CloseClipboard()
                    End If
                End If
            End If
            SetText = success
        End Function

        Shared Function GetText() As String
            Dim result As String = ""
            If _IsClipboardFormatAvailable(CF_UNICODETEXT) <> 0 Then
                If _OpenClipboard(0) <> 0 Then
                    Dim hMem As Long = _GetClipboardData(CF_UNICODETEXT)
                    If hMem <> 0 Then
                        Dim pMem As Long = _GlobalLock(hMem)
                        If pMem <> 0 Then
                            Dim memSize As Long = _GlobalSize(hMem)
                            result = Space(CInt(memSize / 2))
                            _lstrcpyWRead(result, pMem)

                            Dim nullPos As Integer = InStr(result, Chr(0))
                            If nullPos > 0 Then
                                result = Left(result, nullPos - 1)
                            End If

                            _GlobalUnlock(hMem)
                        End If
                    End If
                    _CloseClipboard()
                End If
            End If
            GetText = result
        End Function

        Shared Function HasImage() As Boolean
            HasImage = (_IsClipboardFormatAvailable(CF_BITMAP) <> 0)
        End Function

        Shared Function SetImageFromFile(pFilePath As String) As Boolean
            Dim success As Boolean = False
            Dim gdiToken As Long = 0
            Dim gdiInput As TGdiplusStartupInput
            gdiInput.GdiplusVersion = 1
            gdiInput.DebugEventCallback = 0
            gdiInput.SuppressBackgroundThread = 0
            gdiInput.SuppressExternalCodecs = 0

            If _GdiplusStartup(gdiToken, gdiInput, 0) = 0 Then
                Dim gdiImage As Long = 0

                If _GdipLoadImageFromFile(pFilePath, gdiImage) = 0 Then
                    Dim hBitmapGDI As Long = 0
                    ' Usa -1 (Branco) para evitar o bug do canal Alpha (problema no MS Paint)
                    If _GdipCreateHBITMAPFromBitmap(gdiImage, hBitmapGDI, -1) = 0 Then

                        ' Purifica o bitmap para o padrão absoluto do Windows
                        Dim hBitmapLimpo As Long = _CopyImage(hBitmapGDI, IMAGE_BITMAP, 0, 0, 0)

                        If hBitmapLimpo <> 0 Then
                            If _OpenClipboard(0) <> 0 Then
                                _EmptyClipboard()
                                If _SetClipboardData(CF_BITMAP, hBitmapLimpo) <> 0 Then
                                    success = True
                                End If
                                _CloseClipboard()
                            End If
                            _DeleteObject(hBitmapGDI)
                        Else
                            If _OpenClipboard(0) <> 0 Then
                                _EmptyClipboard()
                                If _SetClipboardData(CF_BITMAP, hBitmapGDI) <> 0 Then
                                    success = True
                                End If
                                _CloseClipboard()
                            End If
                        End If
                    End If
                    _GdipDisposeImage(gdiImage)
                End If
                _GdiplusShutdown(gdiToken)
            End If
            SetImageFromFile = success
        End Function

        Shared Function GetImageAsFile(pFilePath As String) As Boolean
            Dim success As Boolean = False
            Dim gdiToken As Long = 0
            Dim gdiInput As TGdiplusStartupInput
            gdiInput.GdiplusVersion = 1
            gdiInput.DebugEventCallback = 0
            gdiInput.SuppressBackgroundThread = 0
            gdiInput.SuppressExternalCodecs = 0

            If _GdiplusStartup(gdiToken, gdiInput, 0) = 0 Then
                If _IsClipboardFormatAvailable(CF_BITMAP) <> 0 Then
                    If _OpenClipboard(0) <> 0 Then
                        Dim hBitmap As Long = _GetClipboardData(CF_BITMAP)
                        If hBitmap <> 0 Then
                            Dim gdiBitmap As Long = 0
                            If _GdipCreateBitmapFromHBITMAP(hBitmap, 0, gdiBitmap) = 0 Then
                                _CloseClipboard()

                                Dim clsidEnc As TGUID
                                Dim ext As String = LCase(pFilePath)

                                ' Detecta a extensão para usar o codificador (Encoder) GDI+ correto
                                If InStr(ext, ".jpg") > 0 Or InStr(ext, ".jpeg") > 0 Then
                                    ' ID Codificador JPG: {557CF401-1A04-11D3-9A73-0000F81EF32E}
                                    clsidEnc.L1 = 1434252289
                                ElseIf InStr(ext, ".bmp") > 0 Then
                                    ' ID Codificador BMP: {557CF400-1A04-11D3-9A73-0000F81EF32E}
                                    clsidEnc.L1 = 1434252288
                                Else
                                    ' ID Codificador PNG (Padrão para .png ou qualquer outra coisa): {557CF406-...}
                                    clsidEnc.L1 = 1434252294
                                End If

                                ' As partes finais do CLSID são idênticas para todos os codificadores de imagem
                                clsidEnc.L2 = 299047428
                                clsidEnc.L3 = 29594
                                clsidEnc.L4 = 787685112

                                If _GdipSaveImageToFile(gdiBitmap, pFilePath, clsidEnc, 0) = 0 Then
                                    success = True
                                End If
                                _GdipDisposeImage(gdiBitmap)
                            Else
                                _CloseClipboard()
                            End If
                        Else
                            _CloseClipboard()
                        End If
                    End If
                End If
                _GdiplusShutdown(gdiToken)
            End If
            GetImageAsFile = success
        End Function

        Shared Function SetImageFromBase64(pBase64 As String) As Boolean
            Dim success As Boolean = False
            Dim tempPath As String = GetTempPath()
            Base64ToFile(pBase64, tempPath)
            success = ClipboardManager.SetImageFromFile(tempPath)
            IO.File.Delete(tempPath)
            SetImageFromBase64 = success
        End Function

        Shared Function GetImageAsBase64() As String
            Dim resultBase64 As String = ""
            Dim tempPath As String = GetTempPath()

            If ClipboardManager.GetImageAsFile(tempPath) Then
                If IO.File.Exists(tempPath) Then
                    resultBase64 = Replace(Replace(FileToBase64(tempPath), Chr(10), ""), Chr(13), "")

                End If
            End If
            IO.File.Delete(tempPath)

            GetImageAsBase64 = resultBase64
        End Function

        Shared Sub Clear()
            If _OpenClipboard(0) <> 0 Then
                _EmptyClipboard()
                _CloseClipboard()
            End If
        End Sub

        Shared Private Function GetTempPath() As String
            Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
            Dim tempName As String = fso.GetTempName
            Dim _tempFolder As String = fso.GetSpecialFolder(2)
            GetTempPath =  _tempFolder & "\" & tempName & ".png"
            fso = Unassigned
        End Function

        Sub New()
            MyBase.New()
        End Sub

        Sub Free()
            MyBase.Free()
        End Sub

    End Class

End Namespace