Imports Forms
Imports mod_editors
Imports mod_editors_mask

Namespace mod_editors_time

   Class TTimeEditor
      Inherits TMaskEditor

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
         me.Mascara = "99:99:99"
         me.MaxLength = 8
         me.TextHint = "HH:MM:SS (H = hora atual)"
      End Sub

      Sub FillNow()
         Dim nowDt As TDateTime = DateTime()
         me.Text = nowDt.ToString("HH:mm:ss")
      End Sub

      Property AsTime As TDateTime
         Get
            AsTime = me._parseTime(me.Text)
         End Get
         Set(pValue As TDateTime)
            me._setAsTime(pValue)
         End Set
      End Property

      Private Sub _setAsTime(pValue As TDateTime)
         me.Text = pValue.ToString("HH:mm:ss")
      End Sub

      Protected Overrides Sub OnBuilt()
         MyBase.OnBuilt()
         me.Control.OnKeyPress = me._onTimeKeyPress
      End Sub

      Private Sub _onTimeKeyPress(pSender As TObject, ByRef pKey As Char)
         If me._isNowHotkey(pKey) Then
            me.FillNow()
            pKey = Char(0)
            Exit Sub
         End If
         MyBase._handleKeyPress(pSender, pKey)
      End Sub

      Private Function _isNowHotkey(pKey As Char) As Boolean
         Dim code As Integer = CInt(Asc(pKey))
         If (code = 72) Or (code = 104) Then
            _isNowHotkey = True
         Else
            _isNowHotkey = False
         End If
      End Function

      Private Function _parseTime(pValue As String) As TDateTime
         Dim digits As String = me._onlyDigits(pValue)
         Dim dt As TDateTime = DateTime()
         If Len(digits) <> 6 Then
            _parseTime = dt.EncodeTime(0, 0, 0, 0)
            Exit Function
         End If
         Dim workHour As Integer = CInt(digits.Left(2))
         Dim workMin As Integer = CInt(Mid(digits, 3, 2))
         Dim workSec As Integer = CInt(Right(digits, 2))
         If (workHour < 0) Or (workHour > 23) Or (workMin < 0) Or (workMin > 59) Or (workSec < 0) Or (workSec > 59) Then
            _parseTime = dt.EncodeTime(0, 0, 0, 0)
         Else
            _parseTime = dt.EncodeTime(workHour, workMin, workSec, 0)
         End If
      End Function

      Private Function _onlyDigits(pValue As String) As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = Len(pValue)
         For i = 1 To n
            Dim ch As String = Mid(pValue, i, 1)
            If (ch >= "0") And (ch <= "9") Then
               result = result + ch
            End If
         Next
         _onlyDigits = result
      End Function

      Protected Overrides Sub OnApply(pProps As TEditorProps)
         MyBase.OnApply(pProps)
         me.Mascara = "99:99:99"
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
