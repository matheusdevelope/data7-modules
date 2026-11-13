Namespace TDirectory

    Private Declare Function CreateDirectoryW Lib "kernel32.dll" (lpPathName As String, lpSecurityAttributes As Integer) As Boolean
    Private Declare Function GetCurrentDirectoryW Lib "kernel32.dll" (nBufferLength As Integer, lpBuffer As String) As Integer
    Private Declare Function SetCurrentDirectoryW Lib "kernel32.dll" (lpPathName As String) As Boolean
    Private Declare Function GetFileAttributesW Lib "kernel32.dll" (lpFileName As String) As Integer
    Private Declare Function SetFileAttributesW Lib "kernel32.dll" (lpFileName As String, dwFileAttributes As Integer) As Boolean
    Private Declare Function GetLogicalDriveStringsW Lib "kernel32.dll" (nBufferLength As Integer, lpBuffer As String) As Integer

    Sub CreateDirectory(Path As String)
        CreateDirectoryW(Path, 0)
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



    Function GetFiles(Path As String) As Collections.StringList
        Dim lista As New Collections.StringList()
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")

        If Not fso.FolderExists(Path) Then
            GetFiles = lista
            Exit Function
        End If

        Dim absPath As String = fso.GetAbsolutePathName(Path)

        Dim shellApp As Variant = CreateObject("Shell.Application")
        Dim folder As Variant = shellApp.Namespace(absPath)

        Dim items As Variant = folder.Items
        Dim i As Integer, count As Integer = items.Count

        For i = 0 To count - 1
            Dim itemPath As String = items.Item(i).Path
            If Not fso.FolderExists(itemPath) Then
                lista.Add(itemPath)
            End If
        Next

        shellApp = Unassigned
        fso = Unassigned
        GetFiles = lista
    End Function

    Function GetDirectories(Path As String) As Collections.StringList
        Dim lista As New Collections.StringList()
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")

        If Not fso.FolderExists(Path) Then
            GetDirectories = lista
            Exit Function
        End If

        Dim absPath As String = fso.GetAbsolutePathName(Path)

        Dim shellApp As Variant = CreateObject("Shell.Application")
        Dim folder As Variant = shellApp.Namespace(absPath)

        Dim items As Variant = folder.Items
        Dim i As Integer, count As Integer = items.Count

        For i = 0 To count - 1
            Dim itemPath As String = items.Item(i).Path
            If fso.FolderExists(itemPath) Then
                lista.Add(itemPath)
            End If
        Next

        shellApp = Unassigned
        fso = Unassigned
        GetDirectories = lista
    End Function

    Function GetFileSystemEntries(Path As String) As Collections.StringList
        Dim lista As New Collections.StringList()
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")

        If Not fso.FolderExists(Path) Then
            GetFileSystemEntries = lista
            Exit Function
        End If

        Dim absPath As String = fso.GetAbsolutePathName(Path)

        Dim shellApp As Variant = CreateObject("Shell.Application")
        Dim folder As Variant = shellApp.Namespace(absPath)

        Dim items As Variant = folder.Items
        Dim i As Integer, count As Integer = items.Count

        For i = 0 To count - 1
            lista.Add(items.Item(i).Path)
        Next

        shellApp = Unassigned
        fso = Unassigned
        GetFileSystemEntries = lista
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