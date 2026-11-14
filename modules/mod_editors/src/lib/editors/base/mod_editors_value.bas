Imports Forms
Imports mod_editors

Namespace mod_editors_value

   Class TValueEditor
      Inherits TLabeledEditor<ValueTextBox>

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = NULL)
         MyBase.New(pParent, pCaption, pProps)
      End Sub

      Property DecimalPlaces As Integer
         Get
            DecimalPlaces = me.Control.DecimalPlaces
         End Get
         Set(pValue As Integer)
            me._setDecimalPlaces(pValue)
         End Set
      End Property

      Private Sub _setDecimalPlaces(pValue As Integer)
         me.Control.DecimalPlaces = pValue
      End Sub

      Property DisplayFormat As String
         Get
            DisplayFormat = me.Control.DisplayFormat
         End Get
         Set(pValue As String)
            me._setDisplayFormat(pValue)
         End Set
      End Property

      Private Sub _setDisplayFormat(pValue As String)
         me.Control.DisplayFormat = pValue
      End Sub

      Property AsInteger As Integer
         Get
            AsInteger = me.Control.AsInteger
         End Get
         Set(pValue As Integer)
            me._setAsInteger(pValue)
         End Set
      End Property

      Private Sub _setAsInteger(pValue As Integer)
         me.Control.AsInteger = pValue
      End Sub

      Property AsDouble As Extended
         Get
            AsDouble = me.Control.AsFloat
         End Get
         Set(pValue As Extended)
            me._setAsDouble(pValue)
         End Set
      End Property

      Private Sub _setAsDouble(pValue As Extended)
         me.Control.AsFloat = pValue
      End Sub

      Protected Overrides Function GetText() As String
         If me.Control.DecimalPlaces = 0 Then
            GetText = CStr(me.Control.AsInteger)
         Else
            GetText = CStr(me.Control.AsFloat)
         End If
      End Function

      Protected Overrides Sub SetText(pValue As String)
         If Trim(pValue) = "" Then
            me.Control.AsFloat = 0
         Else
            me.Control.AsFloat = CDbl(pValue)
         End If
      End Sub

      Protected Overrides Sub OnApply(pProps As TEditorProps)
         If pProps.DecimalPlaces >= 0 Then
            me.DecimalPlaces = pProps.DecimalPlaces
         End If
         If pProps.DisplayFormat <> "" Then
            me.DisplayFormat = pProps.DisplayFormat
         End If
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
