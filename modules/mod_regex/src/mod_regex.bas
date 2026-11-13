Imports Collections

' Wrapper tipado de VBScript.RegExp
' COM: VBScript.RegExp
'   IRegExp2     — Pattern, IgnoreCase, Global, Multiline, Test, Execute, Replace
'   IMatchCollection2 — Count, Item
'   IMatch2      — Value, FirstIndex, Length, SubMatches
'   ISubMatches  — Count, Item (grupos de captura, base 0)

Namespace mod_regex

   Class TRegExpMatch
      Private _success As Boolean
      Private _value As String
      Private _firstIndex As Integer
      Private _length As Integer
      Private _subMatches As StringList

      Sub New()
         MyBase.New()
         me._success = False
         me._value = ""
         me._firstIndex = 0
         me._length = 0
         me._subMatches = New StringList()
      End Sub

      Sub New(pComMatch As Variant)
         MyBase.New()
         me._subMatches = New StringList()
         me._loadFromCom(pComMatch)
      End Sub

      Private Sub _loadFromCom(pComMatch As Variant)
         me._success = True
         me._value = CStr(pComMatch.Value)
         me._firstIndex = CInt(pComMatch.FirstIndex)
         me._length = CInt(pComMatch.Length)
         Dim comGroups As Variant = pComMatch.SubMatches
         Dim i As Integer
         Dim n As Integer = CInt(comGroups.Count)
         For i = 0 To n - 1
            me._subMatches.Add(CStr(comGroups.Item(i)))
         Next
         comGroups = Unassigned
      End Sub

      Property Success As Boolean
         Get
            Success = me._success
         End Get
      End Property

      Property Value As String
         Get
            Value = me._value
         End Get
      End Property

      Property FirstIndex As Integer
         Get
            FirstIndex = me._firstIndex
         End Get
      End Property

      Property Length As Integer
         Get
            Length = me._length
         End Get
      End Property

      Property SubMatches As StringList
         Get
            SubMatches = me._subMatches
         End Get
      End Property

      Property GroupCount As Integer
         Get
            GroupCount = me._subMatches.Count
         End Get
      End Property

      Function Group(pIndex As Integer) As String
         If pIndex = 0 Then
            Group = me._value
         ElseIf pIndex > 0 And pIndex <= me._subMatches.Count Then
            Group = me._subMatches.Strings(pIndex - 1)
         Else
            Group = ""
         End If
      End Function

      Function Clone() As TRegExpMatch
         Dim copy As New TRegExpMatch()
         copy._success = me._success
         copy._value = me._value
         copy._firstIndex = me._firstIndex
         copy._length = me._length
         Dim i As Integer
         Dim n As Integer = me._subMatches.Count
         For i = 0 To n - 1
            copy._subMatches.Add(me._subMatches.Strings(i))
         Next
         Clone = copy
      End Function

      Function ToString() As String
         If me._success Then
            ToString = me._value + " @ " + CStr(me._firstIndex)
         Else
            ToString = "(sem match)"
         End If
      End Function

      Sub Free()
         If Assigned(me._subMatches) Then
            me._subMatches.Free()
            me._subMatches = Null
         End If
         MyBase.Free()
      End Sub
   End Class

   Class TRegExpMatchList
      Private _items As StringList

      Sub New()
         MyBase.New()
         me._items = New StringList()
         me._items.OwnsObjects = True
      End Sub

      Property Count As Integer
         Get
            Count = me._items.Count
         End Get
      End Property

      Property Item(pIndex As Integer) As TRegExpMatch
         Get
            Item = CType(me._items.Objects(pIndex), TRegExpMatch)
         End Get
      End Property

      Sub Add(pMatch As TRegExpMatch)
         me._items.AddObject(pMatch.Value, pMatch)
      End Sub

      Function Values() As StringList
         Dim result As New StringList()
         Dim i As Integer
         Dim n As Integer = me._items.Count
         For i = 0 To n - 1
            result.Add(me.Item(i).Value)
         Next
         Values = result
      End Function

      Function UniqueValues() As StringList
         Dim result As New StringList()
         Dim i As Integer
         Dim n As Integer = me._items.Count
         For i = 0 To n - 1
            Dim itemValue As String = me.Item(i).Value
            If result.IndexOf(itemValue) < 0 Then
               result.Add(itemValue)
            End If
         Next
         UniqueValues = result
      End Function

      Function ToString() As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = me._items.Count
         For i = 0 To n - 1
            If i > 0 Then
               result = result + ", "
            End If
            result = result + me.Item(i).Value
         Next
         ToString = result
      End Function

      Sub Free()
         If Assigned(me._items) Then
            me._items.Free()
            me._items = Null
         End If
         MyBase.Free()
      End Sub
   End Class

   Class TRegExp
      Private _engine As Variant
      Private _disposed As Boolean

      Sub New(pPattern As String = "", pIgnoreCase As Boolean = True, pGlobal As Boolean = True, pMultiline As Boolean = False)
         MyBase.New()
         me._disposed = False
         me._createEngine()
         me._setIsGlobal(pGlobal)
         me._setIgnoreCase(pIgnoreCase)
         me._setMultiline(pMultiline)
         If pPattern <> "" Then
            me._setPattern(pPattern)
         End If
      End Sub

      Shared Function Compile(pPattern As String, pIgnoreCase As Boolean = True, pGlobal As Boolean = True, pMultiline As Boolean = False) As TRegExp
         Dim rx As New TRegExp(pPattern, pIgnoreCase, pGlobal, pMultiline)
         Compile = rx
      End Function

      Shared Function Escape(pText As String) As String
         Dim work As String = pText
         work = work.Replace("\", "\\")
         work = work.Replace("^", "\^")
         work = work.Replace("$", "\$")
         work = work.Replace(".", "\.")
         work = work.Replace("|", "\|")
         work = work.Replace("?", "\?")
         work = work.Replace("*", "\*")
         work = work.Replace("+", "\+")
         work = work.Replace("(", "\(")
         work = work.Replace(")", "\)")
         work = work.Replace("[", "\[")
         work = work.Replace("]", "\]")
         work = work.Replace("{", "\{")
         work = work.Replace("}", "\}")
         Escape = work
      End Function

      Shared Function IsMatch(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As Boolean
         Dim rx As New TRegExp(pPattern, pIgnoreCase, False, False)
         Dim ok As Boolean
         ok = rx.Test(pText)
         rx.Free()
         IsMatch = ok
      End Function

      Private Sub _createEngine()
         Dim engine As Variant = CreateObject("VBScript.RegExp")
         me._engine = engine
      End Sub

      Private Sub _ensureAlive()
         If me._disposed Then
            Throw New Exception("TRegExp já foi liberado.")
         End If
         If IsEmpty(me._engine) Then
            me._createEngine()
         End If
      End Sub

      Private Function _engineRef() As Variant
         me._ensureAlive()
         _engineRef = me._engine
      End Function

      Private Sub _setPattern(pValue As String)
         Dim engine As Variant = me._engineRef()
         engine.Pattern = pValue
      End Sub

      Private Sub _setIgnoreCase(pValue As Boolean)
         Dim engine As Variant = me._engineRef()
         engine.IgnoreCase = pValue
      End Sub

      Private Sub _setIsGlobal(pValue As Boolean)
         Dim engine As Variant = me._engineRef()
         engine.Global = pValue
      End Sub

      Private Sub _setMultiline(pValue As Boolean)
         Dim engine As Variant = me._engineRef()
         engine.Multiline = pValue
      End Sub

      Property Pattern As String
         Get
            Dim engine As Variant = me._engineRef()
            Pattern = CStr(engine.Pattern)
         End Get
         Set(pValue As String)
            me._setPattern(pValue)
         End Set
      End Property

      Property IgnoreCase As Boolean
         Get
            Dim engine As Variant = me._engineRef()
            IgnoreCase = CBool(engine.IgnoreCase)
         End Get
         Set(pValue As Boolean)
            me._setIgnoreCase(pValue)
         End Set
      End Property

      Property IsGlobal As Boolean
         Get
            Dim engine As Variant = me._engineRef()
            IsGlobal = CBool(engine.Global)
         End Get
         Set(pValue As Boolean)
            me._setIsGlobal(pValue)
         End Set
      End Property

      Property Multiline As Boolean
         Get
            Dim engine As Variant = me._engineRef()
            Multiline = CBool(engine.Multiline)
         End Get
         Set(pValue As Boolean)
            me._setMultiline(pValue)
         End Set
      End Property

      Property Disposed As Boolean
         Get
            Disposed = me._disposed
         End Get
      End Property

      Function Test(pText As String) As Boolean
         Dim engine As Variant = me._engineRef()
         Dim ok As Boolean
         ok = CBool(engine.Test(pText))
         Test = ok
      End Function

      Function Execute(pText As String) As TRegExpMatchList
         Dim engine As Variant = me._engineRef()
         Dim comMatches As Variant
         Dim list As New TRegExpMatchList()
         comMatches = engine.Execute(pText)
         Dim i As Integer
         Dim n As Integer = CInt(comMatches.Count)
         For i = 0 To n - 1
            Dim comMatch As Variant = comMatches.Item(i)
            list.Add(New TRegExpMatch(comMatch))
            comMatch = Unassigned
         Next
         comMatches = Unassigned
         Execute = list
      End Function

      Function Match(pText As String) As TRegExpMatch
         Dim list As TRegExpMatchList = me.Execute(pText)
         Dim result As TRegExpMatch
         If list.Count = 0 Then
            result = New TRegExpMatch()
         Else
            result = list.Item(0).Clone()
         End If
         list.Free()
         Match = result
      End Function

      Function Replace(pText As String, pReplacement As String) As String
         Dim engine As Variant = me._engineRef()
         Dim result As String
         result = CStr(engine.Replace(pText, pReplacement))
         Replace = result
      End Function

      Function Values(pText As String) As StringList
         Dim list As TRegExpMatchList = me.Execute(pText)
         Dim result As StringList = list.Values()
         list.Free()
         Values = result
      End Function

      Function UniqueValues(pText As String) As StringList
         Dim list As TRegExpMatchList = me.Execute(pText)
         Dim result As StringList = list.UniqueValues()
         list.Free()
         UniqueValues = result
      End Function

      Function Split(pText As String) As StringList
         Dim parts As New StringList()
         If me.Pattern = "" Then
            parts.Add(pText)
            Split = parts
            Exit Function
         End If
         Dim wasGlobal As Boolean = me.IsGlobal
         me.IsGlobal = True
         Dim list As TRegExpMatchList
         Try
            list = me.Execute(pText)
         Catch ex As Exception
            me.IsGlobal = wasGlobal
            Throw New Exception(ex.Message)
         End Try
         me.IsGlobal = wasGlobal
         Dim lastPos As Integer = 0
         Dim i As Integer
         Dim n As Integer = list.Count
         For i = 0 To n - 1
            Dim m As TRegExpMatch = list.Item(i)
            Dim pieceLen As Integer = m.FirstIndex - lastPos
            If pieceLen < 0 Then
               pieceLen = 0
            End If
            If pieceLen = 0 Then
               parts.Add("")
            Else
               parts.Add(Mid(pText, lastPos + 1, pieceLen))
            End If
            lastPos = m.FirstIndex + m.Length
         Next
         If lastPos >= pText.Length Then
            parts.Add("")
         Else
            parts.Add(Mid(pText, lastPos + 1, pText.Length - lastPos))
         End If
         list.Free()
         Split = parts
      End Function

      Function Clone() As TRegExp
         Dim rx As New TRegExp(me.Pattern, me.IgnoreCase, me.IsGlobal, me.Multiline)
         Clone = rx
      End Function

      Function ToString() As String
         Dim flags As String = ""
         If me.IgnoreCase Then
            flags = flags + "i"
         End If
         If me.IsGlobal Then
            flags = flags + "g"
         End If
         If me.Multiline Then
            flags = flags + "m"
         End If
         ToString = "/" + me.Pattern + "/" + flags
      End Function

      Sub Dispose()
         If Not me._disposed Then
            me._engine = Unassigned
            me._disposed = True
         End If
      End Sub

      Sub Free()
         me.Dispose()
         MyBase.Free()
      End Sub
   End Class

End Namespace
