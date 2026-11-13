Namespace TFile

    Private Declare Function CopyFileW Lib "kernel32.dll" (lpExistingFileName As String, lpNewFileName As String, bFailIfExists As Boolean) As Boolean
    Private Declare Function MoveFileW Lib "kernel32.dll" (lpExistingFileName As String, lpNewFileName As String) As Boolean
    Private Declare Function GetFileAttributesW Lib "kernel32.dll" (lpFileName As String) As Integer
    Private Declare Function SetFileAttributesW Lib "kernel32.dll" (lpFileName As String, dwFileAttributes As Integer) As Boolean

    Private Declare Function CreateSymbolicLinkW Lib "kernel32.dll" (lpSymlinkFileName As String, lpTargetFileName As String, dwFlags As Integer) As Boolean
    Private Declare Function EncryptFileW Lib "advapi32.dll" (lpFileName As String) As Boolean
    Private Declare Function DecryptFileW Lib "advapi32.dll" (lpFileName As String, dwReserved As Integer) As Boolean
    Private Declare Function ReplaceFileW Lib "kernel32.dll" (lpReplacedFileName As String, lpReplacementFileName As String, lpBackupFileName As String, dwReplaceFlags As Integer, lpExclude As Integer, lpReserved As Integer) As Boolean

    Function Delete(Path As String) As Boolean
        Delete = IO.File.Delete(Path)
    End Function

    Sub Copy(Source As String, Dest As String, Overwrite As Boolean)
        CopyFileW(Source, Dest, Not Overwrite)
    End Sub

    Sub Move(Source As String, Dest As String)
        MoveFileW(Source, Dest)
    End Sub

    Function Exists(Path As String) As Boolean
        Exists = IO.File.Exists(Path)
    End Function

    Function GetAttributes(Path As String) As Integer
        GetAttributes = GetFileAttributesW(Path)
    End Function

    Sub SetAttributes(Path As String, Attributes As Integer)
        SetFileAttributesW(Path, Attributes)
    End Sub

    Function FileAttributesToInteger(Attributes As Integer) As Integer
        FileAttributesToInteger = Attributes
    End Function

    Function IntegerToFileAttributes(Attributes As Integer) As Integer
        IntegerToFileAttributes = Attributes
    End Function

    Function ReadAllText(Path As String) As String
        Dim stream As Variant
        Dim content As String = ""
        stream = CreateObject("ADODB.Stream")
        stream.Type = 2
        stream.Charset = "utf-8"
        stream.Open()
        stream.LoadFromFile(Path)
        content = stream.ReadText(-1)
        stream.Close()
        stream = Unassigned
        ReadAllText = content
    End Function

    Sub WriteAllText(Path As String, Contents As String)
        Dim stream As Variant
        stream = CreateObject("ADODB.Stream")
        stream.Type = 2
        stream.Charset = "utf-8"
        stream.Open()
        stream.WriteText(Contents)
        stream.SaveToFile(Path, 2)
        stream.Close()
        stream = Unassigned
    End Sub

    Sub AppendAllText(Path As String, Contents As String)
        Dim stream As Variant
        Dim content As String = ReadAllText(Path)
        WriteAllText(Path, content + Contents)
        stream = Unassigned
    End Sub

    Function ReadAllLines(Path As String) As Variant
        Throw New Exception("Not implemented")
    End Function

    Sub WriteAllLines(Path As String, Contents As Variant)
        Dim text As String = Join(Contents, Chr(13) + Chr(10))
        WriteAllText(Path, text)
    End Sub

    Function ReadAllBytes(Path As String) As Variant
        Dim stream As Variant = CreateObject("ADODB.Stream")
        stream.Open()
        stream.LoadFromFile(Path)
        ReadAllBytes = stream.Read
        stream.Close()
        stream = Unassigned
    End Function

    Sub WriteAllBytes(Path As String, Bytes As Variant)
        Dim stream As Variant = CreateObject("ADODB.Stream")
        stream.Open()
        stream.Write(Bytes)
        stream.SaveToFile(Path, 2)
        stream.Close()
        stream = Unassigned
    End Sub

    Function CreateText(Path As String) As Variant
        Dim stream As Variant = CreateObject("ADODB.Stream")
        stream.Type = 2
        stream.Charset = "utf-8"
        stream.Open()
    End Function

    Function OpenRead(Path As String) As Variant
        Dim stream As Variant = CreateObject("ADODB.Stream")
        stream.Open()
        stream.LoadFromFile(Path)
        stream.Position = 0
        OpenRead = stream
    End Function

    Function OpenWrite(Path As String) As Variant
        Dim stream As Variant = CreateObject("ADODB.Stream")
        stream.Type = 1
        stream.Open()
        If Exists(Path) Then
            stream.LoadFromFile(Path)
        End If
        OpenWrite = stream
    End Function

    Sub Replace(SourceFileName As String, DestinationFileName As String, DestinationBackupFileName As String)
        ReplaceFileW(DestinationFileName, SourceFileName, DestinationBackupFileName, 2, 0, 0)
    End Sub

    Function CreateSymLink(Link As String, Target As String) As Boolean
        CreateSymLink = CreateSymbolicLinkW(Link, Target, 0)
    End Function

    Sub Encrypt(Path As String)
        EncryptFileW(Path)
    End Sub

    Sub Decrypt(Path As String)
        DecryptFileW(Path, 0)
    End Sub

    Function GetCreationTime(Path As String) As Variant
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Dim f As Variant = fso.GetFile(Path)
        GetCreationTime = f.DateCreated
        fso = Unassigned
    End Function

    Function GetLastAccessTime(Path As String) As Variant
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Dim f As Variant = fso.GetFile(Path)
        GetLastAccessTime = f.DateLastAccessed
        fso = Unassigned
    End Function

    Function GetLastWriteTime(Path As String) As Variant
        Dim fso As Variant = CreateObject("Scripting.FileSystemObject")
        Dim f As Variant = fso.GetFile(Path)
        GetLastWriteTime = f.DateLastModified
        fso = Unassigned
    End Function

    Function GetExtensionByMagicBytes(Path As String) As String
        Dim _stream As Variant
        Dim _binaryData As Variant
        Dim _hexSignature As String = ""
        Dim _xml As Variant
        Dim _node As Variant

        _stream = CreateObject("ADODB.Stream")
        _stream.Type = 1 ' adTypeBinary
        _stream.Open()
        _stream.LoadFromFile(Path)
        _binaryData = _stream.Read(16)
        _stream.Close()
        _stream = Unassigned

        _xml = CreateObject("MSXML2.DOMDocument")
        _node = _xml.createElement("hex")
        _node.DataType = "bin.hex"
        _node.NodeTypedValue = _binaryData
        _hexSignature = UCase(_node.Text)
        _node = Unassigned
        _xml = Unassigned

        GetExtensionByMagicBytes = GetExtensionFromHexSignature(_hexSignature)
    End Function

' =======================================================
    ' MÉTODO 2: Lê a string Base64 e descobre a extensão
    ' =======================================================
    Function GetExtensionByBase64(Base64String As String) As String
        Dim hexSignature As String = ""
        Dim _xml As Variant
        Dim nodeB64 As Variant
        Dim nodeHex As Variant
        Dim binaryData As Variant
        Dim base64Chunk As String
        Dim commaPos As Integer

        commaPos = InStr(Base64String, ",")
        If commaPos > 0 Then
            base64Chunk = Mid(Base64String, commaPos + 1)
        Else
            base64Chunk = Base64String
        End If

        ' Garante que a string cortada seja múltipla de 4 para evitar erro no decode do Base64
        If Len(base64Chunk) > 32 Then
            base64Chunk = Left(base64Chunk, 32)
        End If

        _xml = CreateObject("MSXML2.DOMDocument")
        
        ' 1. Nó independente para decodificar o Base64
        nodeB64 = _xml.createElement("b64")
        nodeB64.DataType = "bin.base64"
        nodeB64.Text = base64Chunk
        binaryData = nodeB64.NodeTypedValue
        
        ' 2. Nó independente (limpo) para transcrever para Hexadecimal
        nodeHex = _xml.createElement("hex")
        nodeHex.DataType = "bin.hex"
        nodeHex.NodeTypedValue = binaryData
        hexSignature = UCase(nodeHex.Text)
        
        ' Limpeza de memória
        nodeB64 = Unassigned
        nodeHex = Unassigned
        _xml = Unassigned

        GetExtensionByBase64 = GetExtensionFromHexSignature(hexSignature)
    End Function

    Function GetExtensionFromHexSignature(hexSignature As String) As String
        ' IMAGENS
        If Left(hexSignature, 4) = "FFD8" Then
            GetExtensionFromHexSignature = ".jpg"
        ElseIf Left(hexSignature, 16) = "89504E470D0A1A0A" Then
            GetExtensionFromHexSignature = ".png"
        ElseIf Left(hexSignature, 8) = "47494638" Then ' GIF8
            GetExtensionFromHexSignature = ".gif"
        ElseIf Left(hexSignature, 8) = "52494646" And Mid(hexSignature, 17, 8) = "57454250" Then
            GetExtensionFromHexSignature = ".webp"
        ElseIf Mid(hexSignature, 9, 8) = "66747970" And (Mid(hexSignature, 17, 8) = "68656963" Or Mid(hexSignature, 17, 8) = "6D696631") Then
            GetExtensionFromHexSignature = ".heic"
        ElseIf Mid(hexSignature, 9, 8) = "66747970" And Mid(hexSignature, 17, 8) = "61766966" Then
            GetExtensionFromHexSignature = ".avif"
        ElseIf Left(hexSignature, 4) = "424D" Then ' BM
            GetExtensionFromHexSignature = ".bmp"
        ElseIf Left(hexSignature, 8) = "49492A00" Or Left(hexSignature, 8) = "4D4D002A" Then
            GetExtensionFromHexSignature = ".tiff"
        ElseIf Left(hexSignature, 8) = "00000100" Then
            GetExtensionFromHexSignature = ".ico"
        ElseIf Left(hexSignature, 8) = "00000200" Then
            GetExtensionFromHexSignature = ".cur"
        ElseIf Left(hexSignature, 8) = "38425053" Then ' 8BPS
            GetExtensionFromHexSignature = ".psd"
        ElseIf Left(hexSignature, 8) = "3C737667" Then ' <svg
            GetExtensionFromHexSignature = ".svg"

            ' VÍDEO E ÁUDIO
        ElseIf Left(hexSignature, 8) = "52494646" And Mid(hexSignature, 17, 8) = "41564920" Then
            GetExtensionFromHexSignature = ".avi"
        ElseIf Left(hexSignature, 8) = "52494646" And Mid(hexSignature, 17, 8) = "57415645" Then
            GetExtensionFromHexSignature = ".wav"
        ElseIf Mid(hexSignature, 9, 8) = "66747970" And (Mid(hexSignature, 17, 8) = "69736F6D" Or Mid(hexSignature, 17, 8) = "6D703432") Then
            GetExtensionFromHexSignature = ".mp4"
        ElseIf Left(hexSignature, 6) = "494433" Or Left(hexSignature, 4) = "FFFB" Then
            GetExtensionFromHexSignature = ".mp3"
        ElseIf Left(hexSignature, 8) = "4F676753" Then ' OggS
            GetExtensionFromHexSignature = ".ogg"

            ' COMPACTADORES
        ElseIf Left(hexSignature, 8) = "504B0304" Then ' PK..
            GetExtensionFromHexSignature = ".zip"
        ElseIf Left(hexSignature, 14) = "526172211A0700" Or Left(hexSignature, 16) = "526172211A070100" Then
            GetExtensionFromHexSignature = ".rar"
        ElseIf Left(hexSignature, 12) = "377ABCAF271C" Then
            GetExtensionFromHexSignature = ".7z"
        ElseIf Left(hexSignature, 6) = "1F8B08" Then
            GetExtensionFromHexSignature = ".gz"

            ' DOCUMENTOS E EXECUTÁVEIS
        ElseIf Left(hexSignature, 8) = "25504446" Then ' %PDF
            GetExtensionFromHexSignature = ".pdf"
        ElseIf Left(hexSignature, 10) = "7B5C727466" Then ' {\rtf
            GetExtensionFromHexSignature = ".rtf"
        ElseIf Left(hexSignature, 4) = "4D5A" Then ' MZ
            GetExtensionFromHexSignature = ".exe"
        ElseIf Left(hexSignature, 8) = "3C3F786D" Then ' <?xm
            GetExtensionFromHexSignature = ".xml"
        ElseIf Left(hexSignature, 6) = "EFBBBF" Then ' UTF-8 BOM
            GetExtensionFromHexSignature = ".txt"

            ' FALLBACK
        Else
            GetExtensionFromHexSignature = ".bin"
        End If
    End Function

End Namespace