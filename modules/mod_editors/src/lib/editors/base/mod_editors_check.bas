Imports Forms
Imports mod_editors

Namespace mod_editors_check

   Class TCheckEditor
      Inherits TLabeledEditor<CheckBox>

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Property Checked As Boolean
         Get
            Checked = me.AsBoolean
         End Get
         Set(pValue As Boolean)
            me._setChecked(pValue)
         End Set
      End Property

      Private Sub _setChecked(pValue As Boolean)
         me.AsBoolean = pValue
      End Sub

      Property AsBoolean As Boolean
         Get
            AsBoolean = me.Control.Checked
         End Get
         Set(pValue As Boolean)
            me._setAsBoolean(pValue)
         End Set
      End Property

      Private Sub _setAsBoolean(pValue As Boolean)
         me.Control.Checked = pValue
      End Sub

      Property AsInteger As Integer
         Get
            AsInteger = CInt(me.AsBoolean)
         End Get
         Set(pValue As Integer)
            me._setAsInteger(pValue)
         End Set
      End Property

      Private Sub _setAsInteger(pValue As Integer)
         me.AsBoolean = CBool(pValue)
      End Sub

      Sub Toggle()
         me.Control.Checked = Not me.Control.Checked
      End Sub

      Protected Overrides Sub CreateControl()
         me._control = New CheckBox(me._slot)
         me._control.Align = alLeft
         me._control.Width = 21
      End Sub

      Protected Overrides Function GetText() As String
         If me.AsBoolean Then
            GetText = "S"
         Else
            GetText = "N"
         End If
      End Function

      Protected Overrides Sub SetText(pValue As String)
         Dim flag As String = UCase(Trim(pValue))
         me.AsBoolean = CBool(flag = "TRUE" Or flag = "S" Or flag = "SIM" Or flag = "Y" Or flag = "YES" Or flag = "1")
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
