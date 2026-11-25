Namespace TDialogs

    Private Structure OPENFILENAME
        lStructSize As Integer
        hwndOwner As Integer
        hInstance As Integer
        lpstrFilter As String
        lpstrCustomFilter As String
        nMaxCustFilter As Integer
        nFilterIndex As Integer
        lpstrFile As String
        nMaxFile As Integer
        lpstrFileTitle As String
        nMaxFileTitle As Integer
        lpstrInitialDir As String
        lpstrTitle As String
        Flags As Integer
        nOffsets As Integer
        lpstrDefExt As String
        lCustData As Integer
        lpfnHook As Integer
        lpTemplateName As String
        pvReserved As Integer
        dwReserved As Integer
        FlagsEx As Integer
    End Structure

    Private Declare Function GetOpenFileNameW Lib "comdlg32.dll" (ByRef ofn As OPENFILENAME) As Boolean
    Private Declare Function GetSaveFileNameW Lib "comdlg32.dll" (ByRef ofn As OPENFILENAME) As Boolean

    Private Const OFN_FILEMUSTEXIST    = &H1000
    Private Const OFN_PATHMUSTEXIST    = &H800
    Private Const OFN_HIDEREADONLY     = &H4
    Private Const OFN_OVERWRITEPROMPT  = &H2
    Private Const OFN_ALLOWMULTISELECT = &H200
    Private Const OFN_EXPLORER         = &H80000

    Private Const BIF_RETURNONLYFSDIRS = &H1
    Private Const BIF_NEWDIALOGSTYLE   = &H40
    Private Const BFFM_INITIALIZED     = 1
    Private Const BFFM_SETSELECTIONW   = &H467
    Private Const BFFM_SETEXPANDED     = &H46A

    Private Structure BROWSEINFO
        hwndOwner As Integer
        pidlRoot As Integer
        pszDisplayName As String
        lpszTitle As String
        ulFlags As Integer
        lpfn As Integer
        lParam As Integer
        iImage As Integer
    End Structure

    Private Declare Function SHBrowseForFolderW Lib "shell32.dll" (ByRef lpbi As BROWSEINFO) As Integer
    Private Declare Function SHGetPathFromIDListW Lib "shell32.dll" (pidl As Integer, pszPath As String) As Integer
    Private Declare Sub CoTaskMemFree Lib "ole32.dll" (pv As Integer)
    Private Declare Function SendMessageW Lib "user32.dll" (hWnd As Integer, Msg As Integer, wParam As Integer, ByVal lParam As String) As Integer

    Private Dim _folderStartDir As String

    Private Function FolderBrowseCallback(hwnd As Integer, uMsg As Integer, lParam As Integer, lpData As Integer) As Integer
        If uMsg = BFFM_INITIALIZED Then
            If _folderStartDir <> "" Then
                SendMessageW(hwnd, BFFM_SETSELECTIONW, 1, _folderStartDir)
                SendMessageW(hwnd, BFFM_SETEXPANDED, 1, _folderStartDir)
            End If
        End If
        FolderBrowseCallback = 0
    End Function

    Private Function ReadPidlPath(pidl As Integer) As String
        Dim pathBuf As String = Space(4096)
        Dim nullIndex As Integer
        ReadPidlPath = ""
        If pidl = 0 Then
            Exit Function
        End If
        If SHGetPathFromIDListW(pidl, pathBuf) = 0 Then
            Exit Function
        End If
        nullIndex = pathBuf.IndexOf(Chr(0))
        If nullIndex >= 0 Then
            ReadPidlPath = pathBuf.Left(nullIndex).Trim()
            Exit Function
        End If
        ReadPidlPath = pathBuf.Trim()
    End Function

    Private Function SelectFolderFree(Title As String, pInitialDir As String) As String
        Dim bi As BROWSEINFO
        Dim displayName As String = Space(1024)
        Dim pidl As Integer
        Dim outPath As String = ""

        _folderStartDir = Trim(pInitialDir)
        bi.hwndOwner = 0
        bi.pidlRoot = 0
        bi.pszDisplayName = displayName
        bi.lpszTitle = Title
        bi.ulFlags = BIF_RETURNONLYFSDIRS Or BIF_NEWDIALOGSTYLE
        bi.lParam = 0
        bi.iImage = 0
        bi.lpfn = AddressOf FolderBrowseCallback

        pidl = SHBrowseForFolderW(bi)
        If pidl <> 0 Then
            outPath = ReadPidlPath(pidl)
            CoTaskMemFree(pidl)
        End If

        _folderStartDir = ""
        SelectFolderFree = outPath
    End Function

    Private Function SelectFolderLocked(Title As String, pRootDir As String) As String
        Dim shellApp As Variant = CreateObject("Shell.Application")
        Dim folderFlags As Integer = BIF_RETURNONLYFSDIRS Or BIF_NEWDIALOGSTYLE
        Dim folder As Variant = shellApp.BrowseForFolder(0, Title, folderFlags, pRootDir)
        Dim outPath As String = ""

        Try
            outPath = folder.Self.Path
        Catch ex As Exception
            outPath = ""
        End Try

        shellApp = Unassigned
        SelectFolderLocked = outPath
    End Function

    Function OpenFile(Title As String, Filter As String, InitialDir As String) As String
        Dim ofn As OPENFILENAME
        Dim buffer As String = Space(4096)
        Dim filtroConvertido As String = ""

        If Filter <> "" Then
            filtroConvertido = Filter.Replace("|", Chr(0)) + Chr(0) + Chr(0)
        End If

        ofn.lpstrFilter = filtroConvertido
        ofn.lpstrCustomFilter = ""
        ofn.lpstrFileTitle = ""
        ofn.lpstrInitialDir = InitialDir
        ofn.lpstrDefExt = ""
        ofn.lpTemplateName = ""
        ofn.hwndOwner = 0
        ofn.hInstance = 0
        ofn.nMaxCustFilter = 0
        ofn.nFilterIndex = 1
        ofn.nMaxFileTitle = 0
        ofn.nOffsets = 0
        ofn.lCustData = 0
        ofn.lpfnHook = 0
        ofn.pvReserved = 0
        ofn.dwReserved = 0
        ofn.FlagsEx = 0
        ofn.lStructSize = 88
        ofn.lpstrFile = buffer
        ofn.nMaxFile = Len(buffer)
        ofn.lpstrTitle = Title
        ofn.Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY

        If GetOpenFileNameW(ofn) Then
            Dim resultado As String = ofn.lpstrFile
            Dim nullIndex As Integer = resultado.IndexOf(Chr(0))
            If nullIndex >= 0 Then
                OpenFile = resultado.Left(nullIndex).Trim()
                Exit Function
            End If
            OpenFile = resultado.Trim()
            Exit Function
        End If

        OpenFile = ""
    End Function

    Function OpenFiles(Title As String, Filter As String, InitialDir As String) As Collections.StringList
        Dim lista As New Collections.StringList()
        Dim ofn As OPENFILENAME
        Dim buffer As String = Space(32768)
        Dim filtroConvertido As String = ""

        If Filter <> "" Then
            filtroConvertido = Filter.Replace("|", Chr(0)) + Chr(0) + Chr(0)
        End If

        ofn.lpstrFilter = filtroConvertido
        ofn.lpstrCustomFilter = ""
        ofn.lpstrFileTitle = ""
        ofn.lpstrInitialDir = InitialDir
        ofn.lpstrDefExt = ""
        ofn.lpTemplateName = ""
        ofn.hwndOwner = 0
        ofn.hInstance = 0
        ofn.nMaxCustFilter = 0
        ofn.nFilterIndex = 1
        ofn.nMaxFileTitle = 0
        ofn.nOffsets = 0
        ofn.lCustData = 0
        ofn.lpfnHook = 0
        ofn.pvReserved = 0
        ofn.dwReserved = 0
        ofn.FlagsEx = 0
        ofn.lStructSize = 88
        ofn.lpstrFile = buffer
        ofn.nMaxFile = Len(buffer)
        ofn.lpstrTitle = Title
        ofn.Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY Or OFN_ALLOWMULTISELECT Or OFN_EXPLORER

        If GetOpenFileNameW(ofn) Then
            Dim resultado As String = ofn.lpstrFile
            Dim nullIdx As Integer = resultado.IndexOf(Chr(0))

            If nullIdx < 0 Then
                lista.Add(resultado.Trim())
            Else
                Dim diretorio As String = resultado.Left(nullIdx).Trim()
                Dim resto As String = Mid(resultado, nullIdx + 2)

                While Len(resto) > 0
                    Dim proxIdx As Integer = resto.IndexOf(Chr(0))
                    Dim nomeArquivo As String

                    If proxIdx >= 0 Then
                        nomeArquivo = resto.Left(proxIdx).Trim()
                        resto = Mid(resto, proxIdx + 2)
                    Else
                        nomeArquivo = resto.Trim()
                        resto = ""
                    End If

                    If nomeArquivo <> "" Then
                        Dim caminhoCheio As String = Replace(diretorio + "\" + nomeArquivo, "\\", "")
                        lista.Add(caminhoCheio)
                    End If
                End While

                If lista.Count = 0 Then
                    lista.Add(diretorio)
                End If
            End If
        End If

        OpenFiles = lista
    End Function

    Function SaveFile(Title As String, Filter As String, InitialDir As String, DefExt As String, DefaultFileName As String = "") As String
        Dim ofn As OPENFILENAME
        Dim buffer As String
        Dim filtroConvertido As String = ""
        Dim nomePadrao As String = Trim(DefaultFileName)

        If nomePadrao <> "" Then
            buffer = nomePadrao + Chr(0) + Space(4096)
        Else
            buffer = Space(4096)
        End If

        If Filter <> "" Then
            filtroConvertido = Filter.Replace("|", Chr(0)) + Chr(0) + Chr(0)
        End If

        ofn.lpstrFilter = filtroConvertido
        ofn.lpstrCustomFilter = ""
        ofn.lpstrFileTitle = ""
        ofn.lpstrInitialDir = InitialDir
        ofn.lpstrDefExt = DefExt
        ofn.lpTemplateName = ""
        ofn.hwndOwner = 0
        ofn.hInstance = 0
        ofn.nMaxCustFilter = 0
        ofn.nFilterIndex = 1
        ofn.nMaxFileTitle = 0
        ofn.nOffsets = 0
        ofn.lCustData = 0
        ofn.lpfnHook = 0
        ofn.pvReserved = 0
        ofn.dwReserved = 0
        ofn.FlagsEx = 0
        ofn.lStructSize = 88
        ofn.lpstrFile = buffer
        ofn.nMaxFile = Len(buffer)
        ofn.lpstrTitle = Title
        ofn.Flags = OFN_OVERWRITEPROMPT Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY

        If GetSaveFileNameW(ofn) Then
            Dim nullIndex As Integer = ofn.lpstrFile.IndexOf(Chr(0))
            If nullIndex >= 0 Then
                SaveFile = ofn.lpstrFile.Left(nullIndex).Trim()
                Exit Function
            End If
            SaveFile = ofn.lpstrFile.Trim()
            Exit Function
        End If

        SaveFile = ""
    End Function

    Function SelectFolder(Title As String, pInitialDir As String = "", pLockRoot As Boolean = False) As String
        If pLockRoot Then
            SelectFolder = SelectFolderLocked(Title, pInitialDir)
            Exit Function
        End If
        SelectFolder = SelectFolderFree(Title, pInitialDir)
    End Function

End Namespace