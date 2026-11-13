Namespace TPath

    Private Declare Function GetFileAttributesW Lib "kernel32.dll" (lpFileName As String) As Integer
    Private Declare Function GetTempPathW Lib "kernel32.dll" (nBufferLength As Integer, lpBuffer As String) As Integer
    Private Declare Function GetTempFileNameW Lib "kernel32.dll" (lpPathName As String, lpPrefixString As String, uUnique As Integer, lpTempFileName As String) As Integer
    Private Declare Function SHGetFolderPathW Lib "shell32.dll" (hwndOwner As Integer, nFolder As Integer, hToken As Integer, dwFlags As Integer, pszPath As String) As Integer
    Private Declare Function PathMatchSpecW Lib "shlwapi.dll" (pszFile As String, pszSpec As String) As Boolean

    Private Const CSIDL_DESKTOP = &H0
    Private Const CSIDL_PERSONAL = &H5
    Private Const CSIDL_MYMUSIC = &H0D
    Private Const CSIDL_MYVIDEO = &H0E
    Private Const CSIDL_APPDATA = &H1A
    Private Const CSIDL_MYPICTURES = &H27

    Function Exists(Path As String) As Boolean
        Dim attr As Integer = GetFileAttributesW(Path)
        Exists = attr <> -1
    End Function

    Function DriveExists(Path As String) As Boolean
        DriveExists = Exists(GetPathRoot(Path))
    End Function

    Function GetFileName(Path As String) As String
        Dim p As String = Path.Replace("/", "\")
        Dim idx As Integer = p.LastDelimiter("\")
        If idx > 0 Then
            GetFileName = Mid(Path, idx + 1)
            Exit Function
        End If
        GetFileName = Path
    End Function

    Function GetDirectoryName(Path As String) As String
        Dim p As String = Path.Replace("/", "\")
        Dim idx As Integer = p.LastDelimiter("\")
        If idx > 0 Then
            If idx = 3 And InStr(p, ":") = 2 Then
                GetDirectoryName = Path.Left(3)
                Exit Function
            Else
                GetDirectoryName = Path.Left(idx - 1)
                Exit Function
            End If
        End If
        GetDirectoryName = ""
    End Function

    Function GetExtension(Path As String) As String
        Dim fName As String = GetFileName(Path)
        Dim idx As Integer = fName.LastDelimiter(".")
        If idx > 0 Then
            GetExtension = Mid(fName, idx)
            Exit Function
        End If
        GetExtension = ""
    End Function

    Function GetFileNameWithoutExtension(Path As String) As String
        Dim fName As String = GetFileName(Path)
        Dim idx As Integer = fName.LastDelimiter(".")
        If idx > 0 Then
            GetFileNameWithoutExtension = fName.Left(idx - 1)
            Exit Function
        End If
        GetFileNameWithoutExtension = fName
    End Function

    Function ChangeExtension(Path As String, Extension As String) As String
        Dim dir As String = GetDirectoryName(Path)
        Dim fName As String = GetFileNameWithoutExtension(Path)

        Dim finalExt As String = Extension
        If finalExt <> "" And InStr(finalExt, ".") <> 1 Then
            finalExt = "." + finalExt
        End If

        Dim novoNome As String = fName + finalExt
        If dir = "" Then
            ChangeExtension = novoNome
            Exit Function
        End If
        ChangeExtension = Combine(dir, novoNome)
    End Function

    Function HasExtension(Path As String) As Boolean
        HasExtension = GetExtension(Path) <> ""
    End Function

    Function GetPathRoot(Path As String) As String
        Dim p As String = Path.Replace("/", "\")

        If p.IndexOf(":") = 1 Then
            GetPathRoot = p.Left(3)
            Exit Function
        ElseIf p.IndexOf("\\") = 0 Then
            Dim temp As String = Mid(p, 3)
            Dim idxUNC As Integer = temp.IndexOf("\")
            If idxUNC >= 0 Then
                GetPathRoot = p.Left(idxUNC + 2)
                Exit Function
            End If
        End If
        GetPathRoot = ""
    End Function

    Function Combine(Path1 As String, Path2 As String) As String
        If Path1 = "" Then
            Combine = Path2
            Exit Function
        End If
        If Path2 = "" Then
            Combine = Path1
            Exit Function
        End If

        Dim p1 As String = Path1.Replace("/", "\")
        Dim p2 As String = Path2.Replace("/", "\")

        Dim lastChar As String = Mid(p1, Len(p1), 1)
        If lastChar = "\" Then
            p1 = p1.Left(Len(p1) - 1)
        End If

        Dim firstChar As String = p2.Left(1)
        If firstChar = "\" Then
            p2 = Mid(p2, 2)
        End If

        Combine = p1 + "\" + p2
    End Function

    Private Function PegarPastaEspecial(CSIDL As Integer) As String
        Dim buffer As String = Space(4096)
        If SHGetFolderPathW(0, CSIDL, 0, 0, buffer) = 0 Then
            Dim nullIdx As Integer = buffer.IndexOf(Chr(0))
            If nullIdx >= 0 Then
                PegarPastaEspecial = buffer.Left(nullIdx).Trim()
                Exit Function
            End If
            PegarPastaEspecial = buffer.Trim()
            Exit Function
        End If
        PegarPastaEspecial = ""
    End Function

    Function GetTempPath() As String
        Dim buffer As String = Space(4096)
        Dim n As Integer = GetTempPathW(4096, buffer)
        If n > 0 Then
            GetTempPath = buffer.Left(n)
            Exit Function
        End If
        GetTempPath = ""
    End Function

    Function GetTempFileName() As String
        Dim buffer As String = Space(4096)
        Dim pastaTemp As String = GetTempPath()
        If GetTempFileNameW(pastaTemp, "TMP", 0, buffer) <> 0 Then
            Dim nullIdx As Integer = buffer.IndexOf(Chr(0))
            If nullIdx >= 0 Then
                GetTempFileName = buffer.Left(nullIdx).Trim()
                Exit Function
            End If
            GetTempFileName = buffer.Trim()
            Exit Function
        End If
        GetTempFileName = ""
    End Function

    Function GetDesktopPath() As String
        GetDesktopPath = PegarPastaEspecial(CSIDL_DESKTOP)
    End Function

    Function GetDocumentsPath() As String
        GetDocumentsPath = PegarPastaEspecial(CSIDL_PERSONAL)
    End Function

    Function GetPicturesPath() As String
        GetPicturesPath = PegarPastaEspecial(CSIDL_MYPICTURES)
    End Function

    Function GetMusicPath() As String
        GetMusicPath = PegarPastaEspecial(CSIDL_MYMUSIC)
    End Function

    Function GetMoviesPath() As String
        GetMoviesPath = PegarPastaEspecial(CSIDL_MYVIDEO)
    End Function

    Function GetAppPath() As String
        GetAppPath = PegarPastaEspecial(CSIDL_APPDATA)
    End Function

    Function GetInvalidFileNameChars() As String
        GetInvalidFileNameChars = Chr(34) + "<>|:*?\" + "/"
    End Function

    Function IsValidFileNameChar(AChar As String) As Boolean
        Dim invalids As String = GetInvalidFileNameChars()
        IsValidFileNameChar = InStr(invalids, AChar) = 0
    End Function

    Function IsDriveRooted(Path As String) As Boolean
        IsDriveRooted = InStr(Path, ":") = 2
    End Function

    Function MatchesPattern(FileName As String, Pattern As String) As Boolean
        If FileName = "" Or Pattern = "" Then
            MatchesPattern = False
            Exit Function
        End If
        MatchesPattern = PathMatchSpecW(FileName, Pattern)
    End Function

End Namespace