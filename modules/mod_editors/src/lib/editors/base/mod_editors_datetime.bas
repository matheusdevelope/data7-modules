Imports Forms
Imports mod_editors

Namespace mod_editors_datetime

   Class TDateTimeEditor
      Inherits TLabeledEditor<DateTextBox>

      Private _stored As TDateTime

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Protected Overridable Function KeepTime() As Boolean
         KeepTime = True
      End Function

      Property AsDateTime As TDateTime
         Get
            AsDateTime = me._current()
         End Get
         Set(pValue As TDateTime)
            me._setAsDateTime(pValue)
         End Set
      End Property

      Private Sub _setAsDateTime(pValue As TDateTime)
         me._commit(pValue)
      End Sub

      Property AsDate As TDateTime
         Get
            AsDate = me._readDate()
         End Get
         Set(pValue As TDateTime)
            me._setAsDate(pValue)
         End Set
      End Property

      Private Sub _setAsDate(pValue As TDateTime)
         If me._isBlank(pValue) Or me._isTimeOnly(pValue) Then
            If me.KeepTime() And me._hasClock(me._current()) Then
               me._commit(me._clockOf(me._current()))
            Else
               me._commit(Unassigned)
            End If
            Exit Sub
         End If
         If me.KeepTime() And me._hasClock(me._current()) Then
            me._commit(me._combine(pValue, me._current()))
         Else
            me._commit(me._dateOf(pValue))
         End If
      End Sub

      Property AsTime As TDateTime
         Get
            AsTime = me._readTime()
         End Get
         Set(pValue As TDateTime)
            me._setAsTime(pValue)
         End Set
      End Property

      Private Sub _setAsTime(pValue As TDateTime)
         If Not me.KeepTime() Then
            Exit Sub
         End If
         Dim cur As TDateTime = me._current()
         If me._isBlank(pValue) Then
            If me._isBlank(cur) Or me._isTimeOnly(cur) Then
               me._commit(Unassigned)
            Else
               me._commit(me._dateOf(cur))
            End If
            Exit Sub
         End If
         If me._isBlank(cur) Or me._isTimeOnly(cur) Then
            me._commit(me._clockOf(pValue))
         Else
            me._commit(me._combine(cur, pValue))
         End If
      End Sub

      Protected Overrides Function GetText() As String
         GetText = me._formatValue(me._current())
      End Function

      Protected Overrides Sub SetText(pValue As String)
         me._commit(me._parseString(pValue))
      End Sub

      Protected Overrides Sub OnBuilt()
         MyBase.OnBuilt()
         me._applyShowTime()
      End Sub

      Private Sub _applyShowTime()
         'me.Control.Properties.ShowTime = me.KeepTime()
      End Sub

      Private Function _current() As TDateTime
         If me._emptyControl() Then
            _current = Unassigned
            Exit Function
         End If
         Dim fromCtrl As TDateTime = me.Control.AsDate
         If me._isBlank(fromCtrl) Then
            _current = Unassigned
            Exit Function
         End If
         If Not me.KeepTime() Then
            If me._isTimeOnly(fromCtrl) Then
               _current = Unassigned
            Else
               _current = me._dateOf(fromCtrl)
            End If
            Exit Function
         End If
         If me._hasClock(fromCtrl) Then
            _current = fromCtrl
            Exit Function
         End If
         If me._hasClock(me._stored) Then
            _current = me._combine(fromCtrl, me._stored)
         Else
            _current = me._dateOf(fromCtrl)
         End If
      End Function

      Private Function _readDate() As TDateTime
         Dim cur As TDateTime = me._current()
         If me._isBlank(cur) Or me._isTimeOnly(cur) Then
            _readDate = Unassigned
         Else
            _readDate = me._dateOf(cur)
         End If
      End Function

      Private Function _readTime() As TDateTime
         Dim cur As TDateTime = me._current()
         If me._isBlank(cur) Or (Not me._hasClock(cur)) Then
            _readTime = Unassigned
         Else
            _readTime = me._clockOf(cur)
         End If
      End Function

      Private Sub _commit(pValue As TDateTime)
         Dim stored As TDateTime = pValue
         If me._isBlank(pValue) Then
            me._stored = Unassigned
            me.Control.EditValue = Unassigned
            Exit Sub
         End If
         If Not me.KeepTime() Then
            If me._isTimeOnly(pValue) Then
               me._stored = Unassigned
               me.Control.EditValue = Unassigned
               Exit Sub
            End If
            stored = me._dateOf(pValue)
         End If
         me._stored = stored
         me.Control.AsDate = stored
      End Sub

      Private Function _emptyControl() As Boolean
         If IsEmpty(me.Control.EditValue) Then
            _emptyControl = True
            Exit Function
         End If
         If me._maskText(me.Control.Text) Then
            _emptyControl = True
            Exit Function
         End If
         _emptyControl = me._isBlank(me.Control.AsDate)
      End Function

      Private Function _isBlank(pValue As TDateTime) As Boolean
         If pValue = 0 Then
            _isBlank = True
         ElseIf pValue = Unassigned Then
            _isBlank = True
         Else
            _isBlank = False
         End If
      End Function

      Private Function _isTimeOnly(pValue As TDateTime) As Boolean
         If me._isBlank(pValue) Then
            _isTimeOnly = False
         ElseIf (pValue.YearOf = 1899) And (pValue.MonthOf = 12) And (pValue.DayOf = 30) Then
            _isTimeOnly = True
         Else
            _isTimeOnly = False
         End If
      End Function

      Private Function _hasClock(pValue As TDateTime) As Boolean
         If me._isBlank(pValue) Then
            _hasClock = False
         ElseIf pValue.IsDate() Then
            _hasClock = False
         Else
            _hasClock = True
         End If
      End Function

      Private Function _dateOf(pValue As TDateTime) As TDateTime
         Dim helper As TDateTime = DateTime()
         _dateOf = helper.EncodeDate(pValue.YearOf(), pValue.MonthOf(), pValue.DayOf())
      End Function

      Private Function _clockOf(pValue As TDateTime) As TDateTime
         Dim helper As TDateTime = DateTime()
         _clockOf = helper.EncodeTime(pValue.HourOf, pValue.MinuteOf, pValue.SecondOf, pValue.MilliSecondOf)
      End Function

      Private Function _combine(pDate As TDateTime, pTime As TDateTime) As TDateTime
         Dim helper As TDateTime = DateTime()
         _combine = helper.EncodeDateTime(pDate.YearOf, pDate.MonthOf, pDate.DayOf, pTime.HourOf, pTime.MinuteOf, pTime.SecondOf, pTime.MilliSecondOf)
      End Function

      Private Function _formatValue(pValue As TDateTime) As String
         If me._isBlank(pValue) Then
            _formatValue = ""
         ElseIf me._isTimeOnly(pValue) Then
            _formatValue = me._two(pValue.HourOf) & ":" & me._two(pValue.MinuteOf) & ":" & me._two(pValue.SecondOf)
         ElseIf pValue.IsDate() Then
            _formatValue = me._two(pValue.DayOf) & "/" & me._two(pValue.MonthOf) & "/" & CStr(pValue.YearOf)
         Else
            _formatValue = me._two(pValue.DayOf) & "/" & me._two(pValue.MonthOf) & "/" & CStr(pValue.YearOf) & " " & me._two(pValue.HourOf) & ":" & me._two(pValue.MinuteOf) & ":" & me._two(pValue.SecondOf)
         End If
      End Function

      Private Function _two(pValue As Integer) As String
         Dim raw As String = CStr(pValue)
         If Len(raw) < 2 Then
            _two = "0" & raw
         Else
            _two = raw
         End If
      End Function

      Private Function _parseString(pValue As String) As TDateTime
         Dim work As String = me._normalizeInput(pValue)
         Dim parsed As TDateTime
         If (work = "") Or (work = "0") Or me._maskText(work) Then
            _parseString = Unassigned
            Exit Function
         End If
         If me._tryParseIsoDash(work, parsed) Then
            _parseString = parsed
         ElseIf me._tryParseBr(work, parsed) Then
            _parseString = parsed
         ElseIf me._tryParseClock(work, parsed) Then
            _parseString = parsed
         ElseIf me._tryParseIsoCompact(work, parsed) Then
            _parseString = parsed
         Else
            _parseString = Unassigned
         End If
      End Function

      Private Function _normalizeInput(pValue As String) As String
         Dim work As String = Trim(pValue)
         Dim i As Integer
         work = work.Replace("T", " ")
         For i = 1 To 20
            If work.Pos("  ") = 0 Then
               Exit For
            End If
            work = work.Replace("  ", " ")
         Next
         _normalizeInput = work
      End Function

      Private Function _tryParseIsoDash(pText As String, ByRef pOut As TDateTime) As Boolean
         Dim datePart As String
         Dim timePart As String
         Dim hasTime As Boolean
         Dim workYear As Integer
         Dim workMonth As Integer
         Dim workDay As Integer
         me._splitDateAndTime(pText, datePart, timePart, hasTime)
         If Not me._readIsoDate(datePart, workYear, workMonth, workDay) Then
            _tryParseIsoDash = False
            Exit Function
         End If
         _tryParseIsoDash = me._finishParts(workYear, workMonth, workDay, timePart, hasTime, pOut)
      End Function

      Private Function _tryParseBr(pText As String, ByRef pOut As TDateTime) As Boolean
         Dim datePart As String
         Dim timePart As String
         Dim hasTime As Boolean
         Dim workYear As Integer
         Dim workMonth As Integer
         Dim workDay As Integer
         me._splitDateAndTime(pText, datePart, timePart, hasTime)
         If Not me._readBrDate(datePart, workYear, workMonth, workDay) Then
            _tryParseBr = False
            Exit Function
         End If
         _tryParseBr = me._finishParts(workYear, workMonth, workDay, timePart, hasTime, pOut)
      End Function

      Private Function _tryParseClock(pText As String, ByRef pOut As TDateTime) As Boolean
         Dim workHour As Integer
         Dim workMin As Integer
         Dim workSec As Integer
         Dim workMsec As Integer
         If pText.Pos("/") > 0 Then
            _tryParseClock = False
            Exit Function
         End If
         If pText.Pos(":") = 0 Then
            _tryParseClock = False
            Exit Function
         End If
         If Not me._readClock(pText, workHour, workMin, workSec, workMsec) Then
            _tryParseClock = False
            Exit Function
         End If
         pOut = me._encodeClock(workHour, workMin, workSec, workMsec)
         _tryParseClock = True
      End Function

      Private Function _tryParseIsoCompact(pText As String, ByRef pOut As TDateTime) As Boolean
         Dim digits As String = me._onlyDigits(pText)
         Dim n As Integer = Len(digits)
         Dim workYear As Integer
         Dim workMonth As Integer
         Dim workDay As Integer
         Dim workHour As Integer
         Dim workMin As Integer
         Dim workSec As Integer
         Dim workMsec As Integer
         If (pText.Pos("/") > 0) Or (pText.Pos("-") > 0) Or (pText.Pos(":") > 0) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         If (n <> 8) And (n <> 14) And (n <> 17) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         If Not me._readInt(digits.Left(4), workYear) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         If Not me._readInt(Mid(digits, 5, 2), workMonth) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         If Not me._readInt(Mid(digits, 7, 2), workDay) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         If n = 8 Then
            _tryParseIsoCompact = me._buildDate(workYear, workMonth, workDay, pOut)
            Exit Function
         End If
         If Not me._readInt(Mid(digits, 9, 2), workHour) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         If Not me._readInt(Mid(digits, 11, 2), workMin) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         If Not me._readInt(Mid(digits, 13, 2), workSec) Then
            _tryParseIsoCompact = False
            Exit Function
         End If
         workMsec = 0
         If n = 17 Then
            If Not me._readInt(Right(digits, 3), workMsec) Then
               _tryParseIsoCompact = False
               Exit Function
            End If
         End If
         _tryParseIsoCompact = me._buildDateTime(workYear, workMonth, workDay, workHour, workMin, workSec, workMsec, pOut)
      End Function

      Private Function _finishParts(pYear As Integer, pMonth As Integer, pDay As Integer, pTimePart As String, pHasTime As Boolean, ByRef pOut As TDateTime) As Boolean
         Dim workHour As Integer
         Dim workMin As Integer
         Dim workSec As Integer
         Dim workMsec As Integer
         If Not pHasTime Then
            _finishParts = me._buildDate(pYear, pMonth, pDay, pOut)
            Exit Function
         End If
         If Not me._readClock(pTimePart, workHour, workMin, workSec, workMsec) Then
            _finishParts = False
            Exit Function
         End If
         _finishParts = me._buildDateTime(pYear, pMonth, pDay, workHour, workMin, workSec, workMsec, pOut)
      End Function

      Private Function _buildDate(pYear As Integer, pMonth As Integer, pDay As Integer, ByRef pOut As TDateTime) As Boolean
         If me._isEpoch(pYear, pMonth, pDay) Then
            pOut = Unassigned
            _buildDate = True
            Exit Function
         End If
         If Not me._validYmd(pYear, pMonth, pDay) Then
            _buildDate = False
            Exit Function
         End If
         pOut = me._encodeDate(pYear, pMonth, pDay)
         _buildDate = True
      End Function

      Private Function _buildDateTime(pYear As Integer, pMonth As Integer, pDay As Integer, pHour As Integer, pMin As Integer, pSec As Integer, pMsec As Integer, ByRef pOut As TDateTime) As Boolean
         If Not me._validHms(pHour, pMin, pSec, pMsec) Then
            _buildDateTime = False
            Exit Function
         End If
         If me._isEpoch(pYear, pMonth, pDay) Then
            If (pHour = 0) And (pMin = 0) And (pSec = 0) And (pMsec = 0) Then
               pOut = Unassigned
            Else
               pOut = me._encodeClock(pHour, pMin, pSec, pMsec)
            End If
            _buildDateTime = True
            Exit Function
         End If
         If Not me._validYmd(pYear, pMonth, pDay) Then
            _buildDateTime = False
            Exit Function
         End If
         If (pHour = 0) And (pMin = 0) And (pSec = 0) And (pMsec = 0) Then
            pOut = me._encodeDate(pYear, pMonth, pDay)
         Else
            pOut = me._encodeDateTime(pYear, pMonth, pDay, pHour, pMin, pSec, pMsec)
         End If
         _buildDateTime = True
      End Function

      Private Function _readIsoDate(pText As String, ByRef pYear As Integer, ByRef pMonth As Integer, ByRef pDay As Integer) As Boolean
         Dim partYear As String
         Dim partMonth As String
         Dim partDay As String
         If Not me._split3(pText, "-", partYear, partMonth, partDay) Then
            _readIsoDate = False
            Exit Function
         End If
         If Len(partYear) <> 4 Then
            _readIsoDate = False
            Exit Function
         End If
         If Not me._readInt(partYear, pYear) Then
            _readIsoDate = False
            Exit Function
         End If
         If Not me._readInt(partMonth, pMonth) Then
            _readIsoDate = False
            Exit Function
         End If
         If Not me._readInt(partDay, pDay) Then
            _readIsoDate = False
            Exit Function
         End If
         _readIsoDate = True
      End Function

      Private Function _readBrDate(pText As String, ByRef pYear As Integer, ByRef pMonth As Integer, ByRef pDay As Integer) As Boolean
         Dim partDay As String
         Dim partMonth As String
         Dim partYear As String
         Dim sep As String
         If pText.Pos("/") > 0 Then
            sep = "/"
         ElseIf (pText.Pos("-") > 0) And (pText.Pos("-") <> 5) Then
            sep = "-"
         ElseIf pText.Pos(".") > 0 Then
            sep = "."
         Else
            _readBrDate = False
            Exit Function
         End If
         If Not me._split3(pText, sep, partDay, partMonth, partYear) Then
            _readBrDate = False
            Exit Function
         End If
         If Not me._readInt(partDay, pDay) Then
            _readBrDate = False
            Exit Function
         End If
         If Not me._readInt(partMonth, pMonth) Then
            _readBrDate = False
            Exit Function
         End If
         If Not me._readInt(partYear, pYear) Then
            _readBrDate = False
            Exit Function
         End If
         pYear = me._expandYear(pYear)
         _readBrDate = True
      End Function

      Private Function _readClock(pText As String, ByRef pHour As Integer, ByRef pMin As Integer, ByRef pSec As Integer, ByRef pMsec As Integer) As Boolean
         Dim clockText As String = Trim(pText)
         Dim partHour As String
         Dim partMin As String
         Dim partSec As String
         pSec = 0
         pMsec = 0
         If me._split3(clockText, ":", partHour, partMin, partSec) Then
            If Not me._readInt(partHour, pHour) Then
               _readClock = False
               Exit Function
            End If
            If Not me._readInt(partMin, pMin) Then
               _readClock = False
               Exit Function
            End If
            If Not me._readSeconds(partSec, pSec, pMsec) Then
               _readClock = False
               Exit Function
            End If
         ElseIf me._split2(clockText, ":", partHour, partMin) Then
            If Not me._readInt(partHour, pHour) Then
               _readClock = False
               Exit Function
            End If
            If Not me._readInt(partMin, pMin) Then
               _readClock = False
               Exit Function
            End If
         Else
            _readClock = False
            Exit Function
         End If
         _readClock = me._validHms(pHour, pMin, pSec, pMsec)
      End Function

      Private Function _readSeconds(pText As String, ByRef pSec As Integer, ByRef pMsec As Integer) As Boolean
         Dim secPart As String
         Dim msecPart As String
         Dim fracPos As Integer
         Dim n As Integer
         pMsec = 0
         fracPos = pText.Pos(".")
         If fracPos = 0 Then
            fracPos = pText.Pos(",")
         End If
         If fracPos = 0 Then
            _readSeconds = me._readInt(pText, pSec)
            Exit Function
         End If
         secPart = pText.Left(fracPos - 1)
         msecPart = Mid(pText, fracPos + 1)
         If Not me._readInt(secPart, pSec) Then
            _readSeconds = False
            Exit Function
         End If
         If Not me._readInt(msecPart, pMsec) Then
            _readSeconds = False
            Exit Function
         End If
         n = Len(msecPart)
         If n = 1 Then
            pMsec = pMsec * 100
         ElseIf n = 2 Then
            pMsec = pMsec * 10
         ElseIf n > 3 Then
            _readSeconds = False
            Exit Function
         End If
         _readSeconds = True
      End Function

      Private Sub _splitDateAndTime(pText As String, ByRef pDatePart As String, ByRef pTimePart As String, ByRef pHasTime As Boolean)
         Dim sp As Integer = pText.Pos(" ")
         If sp = 0 Then
            pDatePart = pText
            pTimePart = ""
            pHasTime = False
         Else
            pDatePart = pText.Left(sp - 1)
            pTimePart = Trim(Mid(pText, sp + 1))
            If pTimePart = "" Then
               pHasTime = False
            Else
               pHasTime = True
            End If
         End If
      End Sub

      Private Function _split3(pText As String, pSep As String, ByRef pA As String, ByRef pB As String, ByRef pC As String) As Boolean
         Dim p1 As Integer = pText.Pos(pSep)
         Dim rest As String
         Dim p2 As Integer
         If p1 <= 1 Then
            _split3 = False
            Exit Function
         End If
         pA = Trim(pText.Left(p1 - 1))
         rest = Mid(pText, p1 + 1)
         p2 = rest.Pos(pSep)
         If p2 <= 1 Then
            _split3 = False
            Exit Function
         End If
         pB = Trim(rest.Left(p2 - 1))
         pC = Trim(Mid(rest, p2 + 1))
         If pC.Pos(pSep) > 0 Then
            _split3 = False
            Exit Function
         End If
         If (pA = "") Or (pB = "") Or (pC = "") Then
            _split3 = False
         Else
            _split3 = True
         End If
      End Function

      Private Function _split2(pText As String, pSep As String, ByRef pA As String, ByRef pB As String) As Boolean
         Dim p1 As Integer = pText.Pos(pSep)
         If p1 <= 1 Then
            _split2 = False
            Exit Function
         End If
         pA = Trim(pText.Left(p1 - 1))
         pB = Trim(Mid(pText, p1 + 1))
         If pB.Pos(pSep) > 0 Then
            _split2 = False
            Exit Function
         End If
         If (pA = "") Or (pB = "") Then
            _split2 = False
         Else
            _split2 = True
         End If
      End Function

      Private Function _expandYear(pYear As Integer) As Integer
         If (pYear >= 0) And (pYear < 100) Then
            If pYear < 50 Then
               _expandYear = pYear + 2000
            Else
               _expandYear = pYear + 1900
            End If
         Else
            _expandYear = pYear
         End If
      End Function

      Private Function _readInt(pText As String, ByRef pOut As Integer) As Boolean
         Dim text As String = Trim(pText)
         Dim i As Integer
         Dim n As Integer = Len(text)
         If n = 0 Then
            _readInt = False
            Exit Function
         End If
         For i = 1 To n
            Dim ch As String = Mid(text, i, 1)
            If (ch < "0") Or (ch > "9") Then
               _readInt = False
               Exit Function
            End If
         Next
         pOut = CInt(text)
         _readInt = True
      End Function

      Private Function _encodeDate(pYear As Integer, pMonth As Integer, pDay As Integer) As TDateTime
         Dim helper As TDateTime = DateTime()
         helper = helper.EncodeDateTime(pYear, pMonth, pDay, 0, 0, 0, 0)
         _encodeDate = helper.EncodeDate(helper.YearOf(), helper.MonthOf(), helper.DayOf())
      End Function

      Private Function _encodeDateTime(pYear As Integer, pMonth As Integer, pDay As Integer, pHour As Integer, pMin As Integer, pSec As Integer, pMsec As Integer) As TDateTime
         Dim helper As TDateTime = DateTime()
         _encodeDateTime = helper.EncodeDateTime(pYear, pMonth, pDay, pHour, pMin, pSec, pMsec)
      End Function

      Private Function _encodeClock(pHour As Integer, pMin As Integer, pSec As Integer, pMsec As Integer) As TDateTime
         Dim helper As TDateTime = DateTime()
         _encodeClock = helper.EncodeTime(pHour, pMin, pSec, pMsec)
      End Function

      Private Function _isEpoch(pYear As Integer, pMonth As Integer, pDay As Integer) As Boolean
         If (pYear = 1899) And (pMonth = 12) And (pDay = 30) Then
            _isEpoch = True
         Else
            _isEpoch = False
         End If
      End Function

      Private Function _validYmd(pYear As Integer, pMonth As Integer, pDay As Integer) As Boolean
         If (pYear < 1900) Or (pYear > 9999) Then
            _validYmd = False
            Exit Function
         End If
         If (pMonth < 1) Or (pMonth > 12) Then
            _validYmd = False
            Exit Function
         End If
         If (pDay < 1) Or (pDay > me._daysInMonth(pYear, pMonth)) Then
            _validYmd = False
         Else
            _validYmd = True
         End If
      End Function

      Private Function _validHms(pHour As Integer, pMin As Integer, pSec As Integer, pMsec As Integer) As Boolean
         If (pHour < 0) Or (pHour > 23) Then
            _validHms = False
         ElseIf (pMin < 0) Or (pMin > 59) Then
            _validHms = False
         ElseIf (pSec < 0) Or (pSec > 59) Then
            _validHms = False
         ElseIf (pMsec < 0) Or (pMsec > 999) Then
            _validHms = False
         Else
            _validHms = True
         End If
      End Function

      Private Function _daysInMonth(pYear As Integer, pMonth As Integer) As Integer
         If (pMonth = 1) Or (pMonth = 3) Or (pMonth = 5) Or (pMonth = 7) Or (pMonth = 8) Or (pMonth = 10) Or (pMonth = 12) Then
            _daysInMonth = 31
         ElseIf (pMonth = 4) Or (pMonth = 6) Or (pMonth = 9) Or (pMonth = 11) Then
            _daysInMonth = 30
         ElseIf pMonth = 2 Then
            If me._leap(pYear) Then
               _daysInMonth = 29
            Else
               _daysInMonth = 28
            End If
         Else
            _daysInMonth = 0
         End If
      End Function

      Private Function _leap(pYear As Integer) As Boolean
         If (pYear Mod 400) = 0 Then
            _leap = True
         ElseIf (pYear Mod 100) = 0 Then
            _leap = False
         ElseIf (pYear Mod 4) = 0 Then
            _leap = True
         Else
            _leap = False
         End If
      End Function

      Private Function _maskText(pText As String) As Boolean
         Dim raw As String = UCase(Trim(pText))
         If raw = "" Then
            _maskText = True
         Else
            _maskText = raw.Contains("DD") Or raw.Contains("YY") Or raw.Contains("HH") Or raw.Contains("NN") Or raw.Contains("SS")
         End If
      End Function

      Private Function _onlyDigits(pValue As String) As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = Len(pValue)
         For i = 1 To n
            Dim ch As String = Mid(pValue, i, 1)
            If (ch >= "0") And (ch <= "9") Then
               result = result & ch
            End If
         Next
         _onlyDigits = result
      End Function

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
