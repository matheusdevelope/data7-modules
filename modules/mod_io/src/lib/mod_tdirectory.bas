Namespace TDirectory

    Private Declare Function CreateDirectoryW Lib "kernel32.dll" (lpPathName As String, lpSecurityAttributes As Integer) As Boolean
    Private Declare Function GetCurrentDirectoryW Lib "kernel32.dll" (nBufferLength As Integer, lpBuffer As String) As Integer
    Private Declare Function SetCurrentDirectoryW Lib "kernel32.dll" (lpPathName As String) As Boolean
    Private Declare Function GetFileAttributesW Lib "kernel32.dll" (lpFileName As String) As Integer
    Private Declare Function SetFileAttributesW Lib "kernel32.dll" (lpFileName As String, dwFileAttributes As Integer) As Boolean
    Private Declare Function GetLogicalDriveStringsW Lib "kernel32.dll" (nBufferLength As Integer, lpBuffer As String) As Integer

    Private Function NormalizeFolderPath(Path As String) As String
        Dim folderPath As String = Trim(Path).Replace("/", "\")
        Dim lastChar As String
        If folderPath = "" Then
            NormalizeFolderPath = ""
            Exit Function
        End If
        lastChar = Mid(folderPath, Len(folderPath), 1)
        If lastChar = "\" Then
            If Len(folderPath) = 3 And InStr(folderPath, ":") = 2 Then
                NormalizeFolderPath = folderPath
                Exit Function
            End If
            folderPath = folderPath.Left(Len(folderPath) - 1)
        End If
        NormalizeFolderPath = folderPath
    End Function

    Sub CreateDirectory(Path As String, pRecursive As Boolean = False)
        Dim folderPath As String
        Dim parentPath As String
        If Not pRecursive Then
            CreateDirectoryW(Path, 0)
            Exit Sub
        End If
        folderPath = NormalizeFolderPath(Path)
        If folderPath = "" Then
            Exit Sub
        End If
        If Exists(folderPath) Then
            Exit Sub
        End If
        parentPath = GetParent(folderPath)
        If parentPath <> "" Then
            If Not Exists(parentPath) Then
                CreateDirectory(parentPath, True)
            End If
        End If
        CreateDirectoryW(folderPath, 0)
    End Sub

    Sub EnsureDirectory(Path As String)
        CreateDirectory(Path, True)
    End Sub

    Function Exists(Path As String) As Boolean
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Exists = fso.FolderExists(Path)
        fso = Unassigned
    End Function

    Sub Delete(Path As String, Recursive As Boolean)
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        If fso.FolderExists(Path) Then
            fso.DeleteFolder(Path, Recursive)
        End If
        fso = Unassigned
    End Sub

    Sub Copy(SourceDirName As String, DestDirName As String, Overwrite As Boolean)
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        fso.CopyFolder(SourceDirName, DestDirName, Overwrite)
        fso = Unassigned
    End Sub

    Sub Move(SourceDirName As String, DestDirName As String)
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        fso.MoveFolder(SourceDirName, DestDirName)
        fso = Unassigned
    End Sub

    Function IsEmpty(Path As String) As Boolean
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        If Not fso.FolderExists(Path) Then
            fso = Unassigned
            IsEmpty = True
            Exit Function
        End If
        Dim folder As Variant = fso.GetFolder(Path)
        IsEmpty = (folder.Files.Count = 0 And folder.SubFolders.Count = 0)
        fso = Unassigned
    End Function

    Function GetCurrentDirectory() As String
        Dim buffer As String = Space(4096)
        Dim n As Integer = GetCurrentDirectoryW(4096, buffer)
        If n > 0 Then
            GetCurrentDirectory = buffer.Left(n)
            Exit Function
        End If
        GetCurrentDirectory = ""
    End Function

    Sub SetCurrentDirectory(Path As String)
        SetCurrentDirectoryW(Path)
    End Sub

    Function GetAttributes(Path As String) As Integer
        GetAttributes = GetFileAttributesW(Path)
    End Function

    Sub SetAttributes(Path As String, Attributes As Integer)
        SetFileAttributesW(Path, Attributes)
    End Sub

    Function GetLogicalDrives() As Collections.StringList
        Dim lista As Collections.StringList = New Collections.StringList()
        Dim buffer As String = Space(1024)
        Dim n As Integer = GetLogicalDriveStringsW(1024, buffer)

        If n > 0 Then
            Dim drives As String = buffer.Left(n)
            Dim arr As Variant = Split(drives, Chr(0))
            Dim i As Integer

            For i = LBound(arr) To UBound(arr)
                ' data7:disable-next-line unknown-symbol
                If arr(i) <> "" Then
                    ' data7:disable-next-line unknown-symbol
                    lista.Add(arr(i))
                End If
            Next
        End If

        GetLogicalDrives = lista
    End Function



    Private Sub AppendFolderListing(pFolder As Variant, pList As Collections.StringList, pIncludeFiles As Boolean, pIncludeDirs As Boolean, pRecursive As Boolean)
        Dim filesCol As Variant
        Dim dirsCol As Variant
        Dim child As Variant
        Dim i As Integer
        Dim n As Integer

        If pIncludeFiles Then
            filesCol = pFolder.Files
            n = filesCol.Count
            For i = 1 To n
                pList.Add(filesCol.Item(i).Path)
            Next
        End If

        dirsCol = pFolder.SubFolders
        n = dirsCol.Count
        For i = 1 To n
            child = dirsCol.Item(i)
            If pIncludeDirs Then
                pList.Add(child.Path)
            End If
            If pRecursive Then
                AppendFolderListing(child, pList, pIncludeFiles, pIncludeDirs, True)
            End If
        Next

        filesCol = Unassigned
        dirsCol = Unassigned
        child = Unassigned
    End Sub

    Private Function ListFolder(Path As String, pIncludeFiles As Boolean, pIncludeDirs As Boolean, pRecursive As Boolean) As Collections.StringList
        Dim lista As New Collections.StringList()
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Dim folder As Variant
        Dim absPath As String
        Dim shellApp As Variant
        Dim items As Variant
        Dim i As Integer
        Dim count As Integer
        Dim itemPath As String

        If Not fso.FolderExists(Path) Then
            fso = Unassigned
            ListFolder = lista
            Exit Function
        End If

        If pRecursive Then
            folder = fso.GetFolder(Path)
            AppendFolderListing(folder, lista, pIncludeFiles, pIncludeDirs, True)
            folder = Unassigned
            fso = Unassigned
            ListFolder = lista
            Exit Function
        End If

        absPath = fso.GetAbsolutePathName(Path)
        shellApp = CreateObject("Shell.Application")
        folder = shellApp.Namespace(absPath)
        items = folder.Items
        count = items.Count
        For i = 0 To count - 1
            itemPath = items.Item(i).Path
            If pIncludeFiles And pIncludeDirs Then
                lista.Add(itemPath)
            ElseIf pIncludeFiles Then
                If Not fso.FolderExists(itemPath) Then
                    lista.Add(itemPath)
                End If
            ElseIf pIncludeDirs Then
                If fso.FolderExists(itemPath) Then
                    lista.Add(itemPath)
                End If
            End If
        Next

        shellApp = Unassigned
        fso = Unassigned
        ListFolder = lista
    End Function

    Function GetFiles(Path As String, pRecursive As Boolean = False) As Collections.StringList
        GetFiles = ListFolder(Path, True, False, pRecursive)
    End Function

    Function GetDirectories(Path As String, pRecursive As Boolean = False) As Collections.StringList
        GetDirectories = ListFolder(Path, False, True, pRecursive)
    End Function

    Function GetFileSystemEntries(Path As String, pRecursive As Boolean = False) As Collections.StringList
        GetFileSystemEntries = ListFolder(Path, True, True, pRecursive)
    End Function




    Function GetCreationTime(Path As String) As String
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Dim folder As Variant = fso.GetFolder(Path)
        GetCreationTime = folder.DateCreated
        fso = Unassigned
    End Function

    Function GetLastAccessTime(Path As String) As String
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Dim folder As Variant = fso.GetFolder(Path)
        GetLastAccessTime = folder.DateLastAccessed
        fso = Unassigned
    End Function

    Function GetLastWriteTime(Path As String) As String
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Dim folder As Variant = fso.GetFolder(Path)
        GetLastWriteTime = folder.DateLastModified
        fso = Unassigned
    End Function




    Function GetParent(Path As String) As String
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        GetParent = fso.GetParentFolderName(Path)
        fso = Unassigned
    End Function

    Function GetDirectoryRoot(Path As String) As String
        Dim p As String = Path.Replace("/", "\")
        If p.IndexOf(":") = 1 Then
            GetDirectoryRoot = p.Left(3)
            Exit Function
        End If
        GetDirectoryRoot = ""
    End Function

End Namespace