Imports Collections
Imports Forms
Imports mod_tlist


Namespace mod_forms_shortcut

   Private Dim _vkMap As StringList

   Class TFormsHotkey

      Private _key As Integer
      Private _ctrl As Boolean
      Private _shift As Boolean
      Private _alt As Boolean
      Private _win As Boolean
      Private _text As String
      Private _code As Long

      Private _ctrlMask As Long = 16384
      Private _shiftMask As Long = 8192
      Private _altMask As Long = 32768
      Private _winMask As Long = 4096

      Action As TNotifyEvent

      Sub New()
         MyBase.New()
         _ensureMap()
      End Sub

      Sub New(pShortcut As String)
         MyBase.New()
         _ensureMap()
         me.Text = pShortcut
      End Sub

      Sub New(pCode As Long)
         MyBase.New()
         _ensureMap()
         me.Code = pCode
      End Sub

      Sub New(pSource As TFormsHotkey)
         MyBase.New()
         _ensureMap()
         If pSource <> NULL Then
            me.Code = pSource.Code
            me.Action = pSource.Action
         End If
      End Sub

      Property Key As Integer
         Get
            Key = me._key
         End Get
         Set(pValue As Integer)
            me._key = pValue
            me._rebuild()
         End Set
      End Property

      Property Ctrl As Boolean
         Get
            Ctrl = me._ctrl
         End Get
         Set(pValue As Boolean)
            me._ctrl = pValue
            me._rebuild()
         End Set
      End Property

      Property Shift As Boolean
         Get
            Shift = me._shift
         End Get
         Set(pValue As Boolean)
            me._shift = pValue
            me._rebuild()
         End Set
      End Property

      Property Alt As Boolean
         Get
            Alt = me._alt
         End Get
         Set(pValue As Boolean)
            me._alt = pValue
            me._rebuild()
         End Set
      End Property

      Property Win As Boolean
         Get
            Win = me._win
         End Get
         Set(pValue As Boolean)
            me._win = pValue
            me._rebuild()
         End Set
      End Property

      Property Text As String
         Get
            Text = me._text
         End Get
         Set(pValue As String)
            me._parseText(pValue)
         End Set
      End Property

      Property Code As Long
         Get
            Code = me._code
         End Get
         Set(pValue As Long)
            me._parseCode(pValue)
         End Set
      End Property

      Shared Function Parse(pShortcut As String) As TFormsHotkey
         Parse = New TFormsHotkey(pShortcut)
      End Function

      Shared Function Encode(pKey As Integer, pCtrl As Boolean, pShift As Boolean, pAlt As Boolean, pWin As Boolean) As Long
         Dim code As Long = pKey
         If pCtrl Then
            code = code + 16384
         End If
         If pShift Then
            code = code + 8192
         End If
         If pAlt Then
            code = code + 32768
         End If
         If pWin Then
            code = code + 4096
         End If
         Encode = code
      End Function

      Function Clone() As TFormsHotkey
         Clone = New TFormsHotkey(me)
      End Function

      Function IsBound() As Boolean
         IsBound = me._code > 0
      End Function

      Private Sub _rebuild()
         me._code = TFormsHotkey.Encode(me._key, me._ctrl, me._shift, me._alt, me._win)
         With New StringList()
            If me._ctrl Then
               .Add("Ctrl")
            End If
            If me._shift Then
               .Add("Shift")
            End If
            If me._alt Then
               .Add("Alt")
            End If
            If me._win Then
               .Add("Win")
            End If
            Dim keyName As String = me._keyName(me._key)
            If keyName <> "" Then
               .Add(keyName)
            End If
            me._text = .Text.Trim.Replace(.LineBreak, "+")
            .Free()
         End With
      End Sub

      Private Sub _parseText(pShortcut As String)
         Dim keyToken As String
         With New StringList()
            .LineBreak = "+"
            .Text = UCase(Trim(pShortcut))
            me._ctrl = .IndexOf("CTRL") >= 0
            me._shift = .IndexOf("SHIFT") >= 0
            me._alt = .IndexOf("ALT") >= 0
            me._win = .IndexOf("WIN") >= 0
            If .Count > 0 Then
               keyToken = Trim(.Strings(.Count - 1))
            End If
            me._key = me._keyCode(keyToken)
            .Free()
         End With
         me._rebuild()
      End Sub

      Private Sub _parseCode(pCode As Long)
         me._ctrl = (pCode And me._ctrlMask) <> 0
         me._shift = (pCode And me._shiftMask) <> 0
         me._alt = (pCode And me._altMask) <> 0
         me._win = (pCode And me._winMask) <> 0
         me._key = CInt(pCode And Not (me._ctrlMask Or me._shiftMask Or me._altMask Or me._winMask))
         me._rebuild()
      End Sub

      Private Function _keyCode(pName As String) As Integer
         pName = UCase(Trim(pName))
         If pName = "" Then
            _keyCode = 0
            Exit Function
         End If
         If _vkMap.IndexOfName(pName) >= 0 Then
            _keyCode = CInt(_vkMap.Values(pName))
            Exit Function
         End If
         If Len(pName) = 1 Then
            _keyCode = CInt(Asc(pName.LastChar()))
            Exit Function
         End If
         _keyCode = 0
      End Function

      Private Function _keyName(pKey As Integer) As String
         Dim i As Integer
         For i = 0 To _vkMap.Count - 1
            Dim name As String = UCase(_vkMap.Names(i))
            If CInt(_vkMap.Values(name)) = pKey Then
               _keyName = name
               Exit Function
            End If
         Next
         If pKey >= 32 And pKey <= 126 Then
            _keyName = Chr(pKey)
            Exit Function
         End If
         _keyName = ""
      End Function

      Private Shared Sub _ensureMap()
         If _vkMap <> NULL Then
            Exit Sub
         End If
         _vkMap = New StringList()
         Dim i As Integer
         For i = 0 To 11
            _vkMap.Add($"F{i + 1}={112 + i}")
         Next
         With _vkMap
            .Add("CTRL=17")
            .Add("SHIFT=16")
            .Add("ALT=18")
            .Add("ESC=27")
            .Add("TAB=9")
            .Add("ENTER=13")
            .Add("RETURN=13")
            .Add("SPACE=32")
            .Add("DEL=46")
            .Add("DELETE=46")
            .Add("HOME=36")
            .Add("END=35")
            .Add("PGUP=33")
            .Add("PAGEUP=33")
            .Add("PGDN=34")
            .Add("PAGEDOWN=34")
            .Add("INS=45")
            .Add("INSERT=45")
            .Add("LEFT=37")
            .Add("UP=38")
            .Add("RIGHT=39")
            .Add("DOWN=40")
            .Add("WIN=91")
         End With
      End Sub

      Sub Free()
         me.Action = NULL
         MyBase.Free()
      End Sub

   End Class

   Class TFormsHotkeys

      Private _ctrl As Boolean
      Private _shift As Boolean
      Private _alt As Boolean
      Private _win As Boolean
      Private _esc As Boolean
      Private _items[] As TFormsHotkey = []

      OnKeyDown As TKeyEvent
      OnKeyUp As TKeyEvent
      OnAction As TNotifyEvent

      Sub New()
         MyBase.New()
      End Sub

      Property Ctrl As Boolean
         Get
            Ctrl = me._ctrl
         End Get
      End Property

      Property Shift As Boolean
         Get
            Shift = me._shift
         End Get
      End Property

      Property Alt As Boolean
         Get
            Alt = me._alt
         End Get
      End Property

      Property Win As Boolean
         Get
            Win = me._win
         End Get
      End Property

      Property Esc As Boolean
         Get
            Esc = me._esc
         End Get
      End Property

      Sub Assign(pHotkey As TFormsHotkey)
         If pHotkey = NULL Then
            Exit Sub
         End If
         If Not pHotkey.IsBound() Then
            Exit Sub
         End If
         me.Unassign(pHotkey)
         me._items.Push(pHotkey.Clone())
      End Sub

      Sub Assign(pHotkey As TFormsHotkey, pAction As TNotifyEvent)
         If pHotkey = NULL Then
            Exit Sub
         End If
         pHotkey.Action = pAction
         me.Assign(pHotkey)
      End Sub

      Sub Assign(pShortcut As String, pAction As TNotifyEvent)
         me.Assign(TFormsHotkey.Parse(pShortcut), pAction)
      End Sub

      Sub Unassign(pHotkey As TFormsHotkey)
         If pHotkey = NULL Then
            Exit Sub
         End If
         Dim idx As Integer = me._items.IndexOf(
            Function(pItem As TFormsHotkey, pIdx As Integer, extra As Variant) As Boolean
               Return pItem.Code = CLng(extra)
            End Function,
            pHotkey.Code
         )
         If idx >= 0 Then
            me._items.Splice(idx, 1)
         End If
      End Sub

      Sub HandleKeyDown(pSender As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
         me._track(pKey, True)
         If me._isModifier(pKey) Then
            If me.OnKeyDown <> NULL Then
               me.OnKeyDown(pSender, pKey, pShift)
            End If
            Exit Sub
         End If
         Dim code As Long = TFormsHotkey.Encode(CInt(pKey), me._ctrl, me._shift, me._alt, me._win)
         Dim hit As TFormsHotkey = me._items.Find(
            Function(pItem As TFormsHotkey, pIdx As Integer, extra As Variant) As Boolean
               Return pItem.Code = CLng(extra)
            End Function,
            code
         )
         If hit <> NULL Then
            If hit.Action <> NULL Then
               hit.Action(hit)
            End If
            If me.OnAction <> NULL Then
               me.OnAction(hit)
            End If
         End If
         If me.OnKeyDown <> NULL Then
            me.OnKeyDown(pSender, pKey, pShift)
         End If
      End Sub

      Sub HandleKeyUp(pSender As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
         me._track(pKey, False)
         If me.OnKeyUp <> NULL Then
            me.OnKeyUp(pSender, pKey, pShift)
         End If
      End Sub

      Private Sub _track(pKey As Word, pDown As Boolean)
         Select pKey
            Case 17
               me._ctrl = pDown
            Case 16
               me._shift = pDown
            Case 18
               me._alt = pDown
            Case 27
               me._esc = pDown
            Case 91, 92
               me._win = pDown
         End Select
      End Sub

      Private Function _isModifier(pKey As Word) As Boolean
         _isModifier = (pKey = 16 Or pKey = 17 Or pKey = 18 Or pKey = 91 Or pKey = 92)
      End Function

      Sub Free()
         If me._items <> NULL Then
            me._items.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
