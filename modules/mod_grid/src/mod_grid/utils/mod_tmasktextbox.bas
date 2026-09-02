Imports Forms
Namespace mod_tmasktextbox

   Const PT_LITERAL = 0
   Const PT_DIGIT = 1
   Const PT_DIGIT_OPTIONAL = 2
   Const PT_DIGIT_SIGN = 3
   Const PT_LETTER = 4
   Const PT_LETTER_OPTIONAL = 5
   Const PT_ALPHANUMERIC = 6
   Const PT_ALPHANUMERIC_OPTIONAL = 7
   Const PT_ANY = 8
   Const PT_ANY_OPTIONAL = 9

   Class TMaskTextBoxPosition

      Sub New()
         MyBase.New()
      End Sub

      Kind As Integer
      Literal As String
      Value As String
      Required As Boolean
      Editable As Boolean
      UpperCase As Boolean
      LowerCase As Boolean

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class TMaskTextBox
      Inherits TextBox

      _mask As String
      _blankChar As String
      _saveLiterals As Boolean
      _updating As Boolean
      _positions[] As TMaskTextBoxPosition
      _positionCount As Integer
      _cursor As Integer
      _anchor As Integer
      _lastRenderedText As String
      _lastValue As String
      _caseUpper As Boolean
      _caseLower As Boolean

      Private Sub _clearPositions()
         me._positions = []
         me._positionCount = 0
      End Sub

      Private Sub _addLiteral(pChar As String)
         Dim p As New TMaskTextBoxPosition()
         p.Kind = PT_LITERAL
         p.Literal = pChar
         p.Value = ""
         p.Editable = False
         p.Required = False
         p.UpperCase = False
         p.LowerCase = False
         me._positions.push(p)
         me._positionCount = me._positionCount + 1
      End Sub

      Private Sub _addEditable(pKind As Integer, pRequired As Boolean)
         Dim p As New TMaskTextBoxPosition()
         p.Kind = pKind
         p.Literal = ""
         p.Value = ""
         p.Editable = True
         p.Required = pRequired
         p.UpperCase = me._caseUpper
         p.LowerCase = me._caseLower
         me._positions.push(p)
         me._positionCount = me._positionCount + 1
      End Sub

      Private Sub _parseMask()
         me._clearPositions()
         me._blankChar = "_"
         me._saveLiterals = False
         me._caseUpper = False
         me._caseLower = False
         If me._mask = "" Then
            Exit Sub
         End If
         Dim m As String = me._mask
         Dim maskPart As String = ""
         Dim semicolon As Integer = 0
         Dim i As Integer
         For i = 1 To Len(m)
            If Mid(m, i, 1) = ";" Then
               semicolon = i
               Exit For
            End If
         Next
         If semicolon = 0 Then
            maskPart = m
         Else
            maskPart = Mid(m, 1, semicolon - 1)
            Dim rest As String = Mid(m, semicolon + 1)
            Dim secondSemi As Integer = 0
            For i = 1 To Len(rest)
               If Mid(rest, i, 1) = ";" Then
                  secondSemi = i
                  Exit For
               End If
            Next
            If secondSemi = 0 Then
               If rest = "1" Then
                  me._saveLiterals = True
               ElseIf rest = "0" Then
                  me._saveLiterals = False
               End If
            Else
               Dim savePart As String
               savePart = Mid(rest, 1, secondSemi - 1)
               If savePart = "1" Then
                  me._saveLiterals = True
               Else
                  me._saveLiterals = False
               End If
               Dim blankPart As String
               blankPart = Mid(rest, secondSemi + 1)
               If blankPart <> "" Then
                  me._blankChar = Mid(blankPart, 1, 1)
               End If
            End If
         End If
         Dim escaped As Boolean = False
         For i = 1 To Len(maskPart)
            Dim c As String
            c = Mid(maskPart, i, 1)
            If escaped Then
               me._addLiteral(c)
               escaped = False
               Continue
            End If
            If c = "\" Then
               escaped = True
               Continue
            End If
            If c = ">" Then
               me._caseUpper = True
               me._caseLower = False
               Continue
            End If
            If c = "<" Then
               me._caseUpper = False
               me._caseLower = True
               Continue
            End If
            Select Case c
               Case "0"
                  me._addEditable(PT_DIGIT, True)
               Case "9"
                  me._addEditable(PT_DIGIT_OPTIONAL, False)
               Case "#"
                  me._addEditable(PT_DIGIT_SIGN, False)
               Case "L"
                  me._addEditable(PT_LETTER, True)
               Case "l"
                  me._addEditable(PT_LETTER_OPTIONAL, False)
               Case "A"
                  me._addEditable(PT_ALPHANUMERIC, True)
               Case "a"
                  me._addEditable(PT_ALPHANUMERIC_OPTIONAL, False)
               Case "C"
                  me._addEditable(PT_ANY, True)
               Case "c"
                  me._addEditable(PT_ANY_OPTIONAL, False)
               Case Else
                  me._addLiteral(c)
            End Select
         Next
         If escaped Then
            me._addLiteral("\")
         End If
      End Sub

      Private Function _getPosition(pIndex As Integer) As TMaskTextBoxPosition
         If pIndex < 0 Then
            _getPosition = Null
            Exit Function
         End If
         If pIndex >= me._positionCount Then
            _getPosition = Null
            Exit Function
         End If
         _getPosition = me._positions[pIndex]
      End Function

      Private Function _isEditable(pIndex As Integer) As Boolean
         Dim p As TMaskTextBoxPosition
         p = me._getPosition(pIndex)
         If p = Null Then
            _isEditable = False
            Exit Function
         End If
         _isEditable = p.Editable
      End Function

      Private Function _isLiteral(pIndex As Integer) As Boolean
         Dim p As TMaskTextBoxPosition
         p = me._getPosition(pIndex)
         If p = Null Then
            _isLiteral = False
            Exit Function
         End If
         _isLiteral = Not p.Editable
      End Function

      Private Function _nextEditable(pIndex As Integer) As Integer
         Dim i As Integer
         If pIndex < 0 Then
            pIndex = 0
         End If
         For i = pIndex To me._positionCount - 1
            If me._isEditable(i) Then
               _nextEditable = i
               Exit Function
            End If
         Next
         _nextEditable = -1
      End Function

      Private Function _previousEditable(pIndex As Integer) As Integer
         Dim i As Integer
         If pIndex >= me._positionCount Then
            pIndex = me._positionCount - 1
         End If

         i = pIndex
         While i >= 0
            If me._isEditable(i) Then
               _previousEditable = i
               Exit Function
            End If
            i = i - 1
         End While

         _previousEditable = -1
      End Function

      Private Function _isDigit(pChar As String) As Boolean
         If pChar = "" Then
            _isDigit = False
            Exit Function
         End If
         Dim n As Integer
         n = Asc(pChar.LastChar())
         _isDigit = ((n >= Asc("0")) And (n <= Asc("9")))
      End Function

      Private Function _isLetter(pChar As String) As Boolean
         If pChar = "" Then
            _isLetter = False
            Exit Function
         End If
         Dim n As Integer
         n = Asc(pChar.LastChar())
         _isLetter = (((n >= Asc("A")) And (n <= Asc("Z"))) Or ((n >= Asc("a")) And (n <= Asc("z"))))
      End Function

      Private Function _isAlphaNumeric(pChar As String) As Boolean
         _isAlphaNumeric = (me._isDigit(pChar) Or me._isLetter(pChar))
      End Function

      Private Function _validateChar(pIndex As Integer, pChar As String) As Boolean
         Dim p As TMaskTextBoxPosition
         p = me._getPosition(pIndex)
         If p = Null Then
            _validateChar = False
            Exit Function
         End If
         If Not p.Editable Then
            _validateChar = False
            Exit Function
         End If
         Select Case p.Kind
            Case PT_DIGIT
               _validateChar = me._isDigit(pChar)
            Case PT_DIGIT_OPTIONAL
               _validateChar = me._isDigit(pChar)
            Case PT_DIGIT_SIGN
               _validateChar = (me._isDigit(pChar) Or pChar = "+" Or pChar = "-")
            Case PT_LETTER
               _validateChar = me._isLetter(pChar)
            Case PT_LETTER_OPTIONAL
               _validateChar = me._isLetter(pChar)
            Case PT_ALPHANUMERIC
               _validateChar = me._isAlphaNumeric(pChar)
            Case PT_ALPHANUMERIC_OPTIONAL
               _validateChar = me._isAlphaNumeric(pChar)
            Case PT_ANY
               _validateChar = True
            Case PT_ANY_OPTIONAL
               _validateChar = True
            Case Else
               _validateChar = False
         End Select
      End Function

      Private Function _normalizeChar(pIndex As Integer, pChar As String) As String
         Dim p As TMaskTextBoxPosition
         p = me._getPosition(pIndex)
         If p = Null Then
            _normalizeChar = pChar
            Exit Function
         End If
         If p.UpperCase Then
            _normalizeChar = UCase(pChar)
            Exit Function
         End If
         If p.LowerCase Then
            _normalizeChar = LCase(pChar)
            Exit Function
         End If
         _normalizeChar = pChar
      End Function

      Private Function _render() As String
         Dim result As String = ""
         Dim i As Integer
         For i = 0 To me._positionCount - 1
            Dim p As TMaskTextBoxPosition
            p = me._getPosition(i)
            If p = Null Then
               Continue
            End If
            If p.Editable Then
               If p.Value <> "" Then
                  result = result & p.Value
               Else
                  result = result & me._blankChar
               End If
            Else
               result = result & p.Literal
            End If
         Next
         _render = result
      End Function

      Private Sub _renderControl()
         If me._updating Then
         End If
         Dim text As String
         text = me._render()
         me._lastRenderedText = text
         If TextBox(me).Text <> text Then
            TextBox(me).Text = text
         End If
      End Sub

      Private Function _textPositionToMaskPosition(pPosition As Integer) As Integer
         If pPosition <= 0 Then
            _textPositionToMaskPosition = 0
            Exit Function
         End If
         If pPosition >= me._positionCount Then
            _textPositionToMaskPosition = me._positionCount
            Exit Function
         End If
         _textPositionToMaskPosition = pPosition
      End Function

      Private Function _maskPositionToTextPosition(pPosition As Integer) As Integer
         If pPosition <= 0 Then
            _maskPositionToTextPosition = 0
            Exit Function
         End If
         If pPosition >= me._positionCount Then
            _maskPositionToTextPosition = Len(me._lastRenderedText)
            Exit Function
         End If
         _maskPositionToTextPosition = pPosition
      End Function

      Private Sub _setCursor(pPosition As Integer)
         If pPosition < 0 Then
            pPosition = 0
         End If
         If pPosition > me._positionCount Then
            pPosition = me._positionCount
         End If
         me._cursor = pPosition
         me.SelStart = me._maskPositionToTextPosition(pPosition)
         me.SelLength = 0
      End Sub

      Private Sub _moveLeft()
         Dim p As Integer
         p = me._previousEditable(me._cursor - 1)
         If p >= 0 Then
            me._setCursor(p)
         Else
            me._setCursor(0)
         End If
      End Sub

      Private Sub _moveRight()
         Dim p As Integer
         p = me._nextEditable(me._cursor + 1)
         If p >= 0 Then
            me._setCursor(p)
         Else
            me._setCursor(me._positionCount)
         End If
      End Sub

      Private Sub _moveHome()
         Dim p As Integer
         p = me._nextEditable(0)
         If p < 0 Then
            p = 0
         End If
         me._setCursor(p)
      End Sub

      Private Sub _moveEnd()
         Dim p As Integer
         p = me._previousEditable(me._positionCount - 1)
         If p < 0 Then
            me._setCursor(me._positionCount)
            Exit Sub
         End If
         Dim i As Integer
         For i = me._positionCount - 1 To 0 Step -1
            Dim pos As TMaskTextBoxPosition
            pos = me._getPosition(i)
            If pos.Editable Then
               If pos.Value <> "" Then
                  me._setCursor(me._nextEditable(i + 1))
                  If me._cursor < 0 Then
                     me._setCursor(me._positionCount)
                  End If
                  Exit Sub
               End If
            End If
         Next
         me._setCursor(me._nextEditable(0))
      End Sub

      Private Function _selectionStart() As Integer
         If me.SelStart < 0 Then
            _selectionStart = 0
            Exit Function
         End If
         _selectionStart = me._textPositionToMaskPosition(me.SelStart)
      End Function

      Private Function _selectionEnd() As Integer
         _selectionEnd = me._textPositionToMaskPosition(me.SelStart + me.SelLength)
      End Function

      Private Function _hasSelection() As Boolean
         _hasSelection = (me.SelLength > 0)
      End Function

      Private Sub _clearSelection()
         Dim startPos As Integer
         Dim endPos As Integer
         startPos = me._selectionStart()
         endPos = me._selectionEnd()
         Dim i As Integer
         For i = startPos To endPos - 1
            If me._isEditable(i) Then
               Dim p As TMaskTextBoxPosition
               p = me._getPosition(i)
               p.Value = ""
            End If
         Next

         Dim nextPos As Integer
         nextPos = me._nextEditable(startPos)
         If nextPos < 0 Then
            nextPos = startPos
         End If
         me._setCursor(nextPos)
      End Sub

      Private Sub _deleteSelection()
         If Not me._hasSelection() Then
            Exit Sub
         End If
         Dim startPos As Integer
         startPos = me._selectionStart()
         me._clearSelection()
         me._renderControl()
         me._setCursor(me._nextEditable(startPos))
      End Sub

      Private Function _insertChar(pChar As String) As Boolean
         Dim p As Integer
         p = me._cursor
         p = me._nextEditable(p)
         If p < 0 Then
            _insertChar = False
            Exit Function
         End If
         If Not me._validateChar(p, pChar) Then
            _insertChar = False
            Exit Function
         End If
         Dim c As String
         c = me._normalizeChar(p, pChar)
         Dim pos As TMaskTextBoxPosition
         pos = me._getPosition(p)
         pos.Value = c
         me._cursor = me._nextEditable(p + 1)
         If me._cursor < 0 Then
            me._cursor = me._positionCount
         End If
         _insertChar = True
      End Function

      Private Function _backspace() As Boolean
         If me._hasSelection() Then
            me._deleteSelection()
            _backspace = True
            Exit Function
         End If

         me._cursor = me._textPositionToMaskPosition(me.SelStart)

         Dim searchPos As Integer
         searchPos = me._cursor - 1

         Dim p As Integer
         Dim pos As TMaskTextBoxPosition

         While searchPos >= 0
            p = me._previousEditable(searchPos)
            If p < 0 Then
               Exit While
            End If

            pos = me._getPosition(p)
            If pos.Value <> "" Then
               pos.Value = ""
               me._cursor = p
               _backspace = True
               Exit Function
            End If

            searchPos = p - 1
         End While

         p = me._previousEditable(me._cursor - 1)
         If p >= 0 Then
            me._cursor = p
            _backspace = True
         Else
            _backspace = False
         End If
      End Function

      Private Function _delete() As Boolean
         If me._hasSelection() Then
            me._deleteSelection()
            _delete = True
            Exit Function
         End If

         me._cursor = me._textPositionToMaskPosition(me.SelStart)

         Dim p As Integer
         p = me._nextEditable(me._cursor)

         If p < 0 Then
            _delete = False
            Exit Function
         End If

         Dim pos As TMaskTextBoxPosition
         pos = me._getPosition(p)
         pos.Value = ""
         me._cursor = p
         _delete = True
      End Function

      Private Function _getValue() As String
         Dim result As String = ""
         Dim i As Integer
         For i = 0 To me._positionCount - 1
            Dim p As TMaskTextBoxPosition
            p = me._getPosition(i)
            If p.Editable Then
               If p.Value <> "" Then
                  result = result & p.Value
               End If
            Else
               If me._saveLiterals Then
                  result = result & p.Literal
               End If
            End If
         Next
         _getValue = result
      End Function

      Private Sub _setValue(pValue As String)
         If me._updating Then
            Exit Sub
         End If
         me._updating = True
         Dim i As Integer
         For i = 0 To me._positionCount - 1
            Dim p As TMaskTextBoxPosition
            p = me._getPosition(i)
            If p.Editable Then
               p.Value = ""
            End If
         Next
         Dim valueIndex As Integer = 1
         Dim pIndex As Integer
         For pIndex = 0 To me._positionCount - 1
            If valueIndex > Len(pValue) Then
               Exit For
            End If
            If me._isEditable(pIndex) Then
               Dim c As String
               c = Mid(pValue, valueIndex, 1)
               If me._validateChar(pIndex, c) Then
                  Dim pos As TMaskTextBoxPosition
                  pos = me._getPosition(pIndex)
                  pos.Value = me._normalizeChar(pIndex, c)
                  valueIndex = valueIndex + 1
               End If
            End If
         Next
         me._cursor = me._nextEditable(0)
         If me._cursor < 0 Then
            me._cursor = me._positionCount
         End If
         me._renderControl()
         me._setCursor(me._cursor)
         me._updating = False
      End Sub

      Private Sub _setText(pText As String)
         If me._updating Then
            Exit Sub
         End If
         me._updating = True
         Dim i As Integer
         For i = 0 To me._positionCount - 1
            Dim p As TMaskTextBoxPosition
            p = me._getPosition(i)
            If p.Editable Then
               p.Value = ""
            End If
         Next
         Dim textIndex As Integer = 1
         Dim maskIndex As Integer
         For maskIndex = 0 To me._positionCount - 1
            If textIndex > Len(pText) Then
               Exit For
            End If
            Dim pos As TMaskTextBoxPosition
            pos = me._getPosition(maskIndex)
            If Not pos.Editable Then
               Dim literal As String
               literal = pos.Literal
               If Mid(pText, textIndex, 1) = literal Then
                  textIndex = textIndex + 1
               End If
            Else
               Dim c As String
               c = Mid(pText, textIndex, 1)
               If me._validateChar(maskIndex, c) Then
                  pos.Value = me._normalizeChar(maskIndex, c)
                  textIndex = textIndex + 1
               End If
            End If
         Next
         me._renderControl()
         me._cursor = me._nextEditable(0)
         If me._cursor < 0 Then
            me._cursor = me._positionCount
         End If
         me._setCursor(me._cursor)
         me._updating = False
      End Sub

      Private Sub _handleKeyPress(pSender As TObject, ByRef pKey As Char)
         If me._updating Then
            Exit Sub
         End If

         If Asc(pKey) = 8 Then
            me._updating = True

            If me._backspace() Then
               me._renderControl()
               me._setCursor(me._cursor)
            End If

            pKey = Chr(0)
            me._updating = False
            Exit Sub
         End If

         If Asc(pKey) < 32 Then
            Exit Sub
         End If

         me._updating = True

         me._cursor = me._textPositionToMaskPosition(me.SelStart)

         If me._hasSelection() Then
            me._deleteSelection()
         End If

         If me._insertChar(pKey) Then
            me._renderControl()
            me._setCursor(me._cursor)
         End If

         pKey = Chr(0)
         me._updating = False
      End Sub

      Private Sub _handleChange(pSender As TObject)

         If me._updating Then
            Exit Sub
         End If

         Dim externalText As String
         externalText = TextBox(me).Text

         If externalText = me._lastRenderedText Then
            Exit Sub
         End If

         me._setText(externalText)

      End Sub

      Sub New(pControl As TWinControl)
      ' data7:disable-next-line unknown-member         
         MyBase.New(Null)
         me.Parent = pControl
         me._mask = ""
         me._blankChar = "_"
         me._saveLiterals = False
         me._updating = False
         me._positions = []
         me._positionCount = 0
         me._cursor = 0
         me._anchor = 0
         me._caseUpper = False
         me._caseLower = False
         me.OnKeyPress = me._handleKeyPress
         me.OnChange = me._handleChange
      End Sub

      Property Mascara As String
         Get
            Mascara = me._mask
         End Get
         Set(pValue As String)
            If me._mask = pValue Then
               Exit Sub
            End If
            me._mask = pValue
            me._parseMask()
            me._setText("")
         End Set
      End Property

      Property AsString As String
         Get
            AsString = me._lastRenderedText
         End Get
         Set(pValue As String)
            me._setText(pValue)
         End Set
      End Property

      Property Value As String
         Get
            Value = me._getValue
         End Get
         Set(pValue As String)
            me._setValue(pValue)
         End Set
      End Property

      Sub Clear()
         If me._updating Then
            Exit Sub
         End If
         me._updating = True
         Dim i As Integer
         For i = 0 To me._positionCount - 1
            Dim p As TMaskTextBoxPosition
            p = me._getPosition(i)
            If p.Editable Then
               p.Value = ""
            End If
         Next
         me._cursor = me._nextEditable(0)
         If me._cursor < 0 Then
            me._cursor = 0
         End If
         me._anchor = me._cursor
         me._renderControl()
         me._updating = False
      End Sub

      Sub Free()
         me._clearPositions()
         MyBase.Free()
      End Sub

   End Class
   
End Namespace