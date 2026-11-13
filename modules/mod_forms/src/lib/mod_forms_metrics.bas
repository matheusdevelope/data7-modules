' data7:disable shared-return-global-function
Imports Forms
Imports mod_forms_screen


Namespace mod_forms_metrics

   Delegate Sub TFormsAxisNotify(pAxis As TFormsAxis, pField As String)

   Class TFormsAxis

      Private _name As String
      Private _value As Integer = -1
      Private _min As Integer = -1
      Private _max As Integer = -1
      Private _canGrow As Boolean = True
      Private _silent As Boolean

      OnChange As TFormsAxisNotify

      Sub New(pName As String)
         MyBase.New()
         me._name = pName
      End Sub

      Property Name As String
         Get
            Name = me._name
         End Get
      End Property

      Property Value As Integer
         Get
            Value = me._value
         End Get
         Set(pValue As Integer)
            me._value = pValue
            me._notify("Value")
         End Set
      End Property

      Property Min As Integer
         Get
            Min = me._min
         End Get
         Set(pValue As Integer)
            me._min = pValue
            me._notify("Min")
         End Set
      End Property

      Property Max As Integer
         Get
            Max = me._max
         End Get
         Set(pValue As Integer)
            me._max = pValue
            me._notify("Max")
         End Set
      End Property

      Property CanGrow As Boolean
         Get
            CanGrow = me._canGrow
         End Get
         Set(pValue As Boolean)
            me._canGrow = pValue
            me._notify("CanGrow")
         End Set
      End Property

      Sub Suspend()
         me._silent = True
      End Sub

      Sub Resumee()
         me._silent = False
      End Sub

      Private Sub _notify(pField As String)
         If me._silent Then
            Exit Sub
         End If
         If me.OnChange <> NULL Then
            me.OnChange(me, pField)
         End If
      End Sub

      Function Clamp(pLast As Integer, pValue As Integer) As Integer
         If Not me._canGrow Then
            Clamp = pLast
            Exit Function
         End If
         Dim nextValue As Integer = pValue
         If me._min >= 0 And nextValue < me._min Then
            nextValue = me._min
         End If
         If me._max >= 0 And nextValue > me._max Then
            nextValue = me._max
         End If
         Clamp = nextValue
      End Function

      Sub Free()
         me.OnChange = NULL
         MyBase.Free()
      End Sub

   End Class

   Class TFormsSize

      Private _width As TFormsAxis
      Private _height As TFormsAxis

      OnChange As TFormsAxisNotify

      Sub New()
         MyBase.New()
         me._width = New TFormsAxis("SizeWidth")
         me._height = New TFormsAxis("SizeHeight")
         me._width.OnChange = me._onAxisChange
         me._height.OnChange = me._onAxisChange
      End Sub

      Property Width As TFormsAxis
         Get
            Width = me._width
         End Get
      End Property

      Property Height As TFormsAxis
         Get
            Height = me._height
         End Get
      End Property

      Property Value As Integer
         Get
            Value = me._width.Value
         End Get
         Set(pValue As Integer)
            me._setValue(pValue)
         End Set
      End Property

      Property Min As Integer
         Get
            Min = me._width.Min
         End Get
         Set(pValue As Integer)
            me._setMin(pValue)
         End Set
      End Property

      Property Max As Integer
         Get
            Max = me._width.Max
         End Get
         Set(pValue As Integer)
            me._setMax(pValue)
         End Set
      End Property

      Property CanGrow As Boolean
         Get
            CanGrow = me._width.CanGrow And me._height.CanGrow
         End Get
         Set(pValue As Boolean)
            me._setCanGrow(pValue)
         End Set
      End Property

      Function ClampedWidth() As Integer
         ClampedWidth = me._clampAxis(me._width)
      End Function

      Function ClampedHeight() As Integer
         ClampedHeight = me._clampAxis(me._height)
      End Function

      Private Sub _setValue(pValue As Integer)
         me._checkPercent(pValue)
         me._width.Suspend()
         me._height.Suspend()
         me._width.Value = pValue
         me._height.Value = pValue
         me._width.Resumee()
         me._height.Resumee()
         me._emit(me._width, "Value")
      End Sub

      Private Sub _setMin(pValue As Integer)
         me._checkPercent(pValue)
         me._width.Suspend()
         me._height.Suspend()
         me._width.Min = pValue
         me._height.Min = pValue
         me._width.Resumee()
         me._height.Resumee()
         me._emit(me._width, "Min")
      End Sub

      Private Sub _setMax(pValue As Integer)
         me._checkPercent(pValue)
         me._width.Suspend()
         me._height.Suspend()
         me._width.Max = pValue
         me._height.Max = pValue
         me._width.Resumee()
         me._height.Resumee()
         me._emit(me._width, "Max")
      End Sub

      Private Sub _setCanGrow(pValue As Boolean)
         me._width.Suspend()
         me._height.Suspend()
         me._width.CanGrow = pValue
         me._height.CanGrow = pValue
         me._width.Resumee()
         me._height.Resumee()
         me._emit(me._width, "CanGrow")
      End Sub

      Private Sub _checkPercent(pValue As Integer)
         If pValue < 1 Or pValue > 100 Then
            Throw New Exception("Size percent must be 1-100, got " & CStr(pValue))
         End If
      End Sub

      Private Function _clampAxis(pAxis As TFormsAxis) As Integer
         Dim p As Integer = pAxis.Value
         If p < 1 Then
            _clampAxis = 0
            Exit Function
         End If
         If pAxis.Min >= 1 And p < pAxis.Min Then
            p = pAxis.Min
         End If
         If pAxis.Max >= 1 And p > pAxis.Max Then
            p = pAxis.Max
         End If
         If p > 100 Then
            p = 100
         End If
         _clampAxis = p
      End Function

      Private Sub _onAxisChange(pAxis As TFormsAxis, pField As String)
         me._emit(pAxis, pField)
      End Sub

      Private Sub _emit(pAxis As TFormsAxis, pField As String)
         If me.OnChange <> NULL Then
            me.OnChange(pAxis, pField)
         End If
      End Sub

      Sub Free()
         me.OnChange = NULL
         If me._width <> NULL Then
            me._width.Free()
         End If
         If me._height <> NULL Then
            me._height.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

   Class TFormsMetrics

      Private _form As Form
      Private _monitor As TFormsMonitor
      Private _width As TFormsAxis
      Private _height As TFormsAxis
      Private _size As TFormsSize
      Private _lastWidth As Integer
      Private _lastHeight As Integer
      Private _marginWidth As Integer = 5
      Private _marginHeight As Integer = 5
      Private _maximized As Boolean
      Private _restoreWidth As Integer
      Private _restoreHeight As Integer
      Private _restoreLeft As Integer
      Private _restoreTop As Integer

      Sub New(pForm As Form)
         MyBase.New()
         me._form = pForm
         me._width = New TFormsAxis("Width")
         me._height = New TFormsAxis("Height")
         me._size = New TFormsSize()
         me._width.OnChange = me._onAxisChange
         me._height.OnChange = me._onAxisChange
         me._size.OnChange = me._onSizeChange
         me._lastWidth = pForm.Width
         me._lastHeight = pForm.Height
         me.RefreshMonitor()
      End Sub

      Property Width As TFormsAxis
         Get
            Width = me._width
         End Get
      End Property

      Property Height As TFormsAxis
         Get
            Height = me._height
         End Get
      End Property

      Property Monitor As TFormsMonitor
         Get
            Monitor = me._monitor
         End Get
      End Property

      Property CanResize As Boolean
         Get
            CanResize = me._width.CanGrow And me._height.CanGrow
         End Get
         Set(pValue As Boolean)
            me._setCanResize(pValue)
         End Set
      End Property

      Property Margin As Integer
         Set(pValue As Integer)
            me._setMargin(pValue, True, True)
         End Set
      End Property

      Property MarginWidth As Integer
         Get
            MarginWidth = me._marginWidth
         End Get
         Set(pValue As Integer)
            me._setMargin(pValue, True, False)
         End Set
      End Property

      Property MarginHeight As Integer
         Get
            MarginHeight = me._marginHeight
         End Get
         Set(pValue As Integer)
            me._setMargin(pValue, False, True)
         End Set
      End Property

      Property Size As TFormsSize
         Get
            Size = me._size
         End Get
      End Property

      Property SizeWidth As Integer
         Get
            SizeWidth = me._size.Width.Value
         End Get
         Set(pValue As Integer)
            me._setSizeWidth(pValue)
         End Set
      End Property

      Property SizeHeight As Integer
         Get
            SizeHeight = me._size.Height.Value
         End Get
         Set(pValue As Integer)
            me._setSizeHeight(pValue)
         End Set
      End Property

      Property Maximized As Boolean
         Get
            Maximized = me._maximized
         End Get
         Set(pValue As Boolean)
            If me._maximized <> pValue Then
               me.ToggleMaximized()
            End If
         End Set
      End Property

      Sub RefreshMonitor()
         If me._monitor <> NULL Then
            me._monitor.Free()
         End If
         me._monitor = New TFormsMonitor()
      End Sub

      Sub EnsureWorkAreaMax()
         If me._monitor = NULL Then
            Exit Sub
         End If
         Dim safeW As Integer = me._monitor.SafeWidth(me._marginWidth)
         Dim safeH As Integer = me._monitor.SafeHeight(me._marginHeight)
         If me._width.Max < 0 Or me._width.Max > safeW Then
            me._width.Suspend()
            me._width.Max = safeW
            me._width.Resumee()
         End If
         If me._height.Max < 0 Or me._height.Max > safeH Then
            me._height.Suspend()
            me._height.Max = safeH
            me._height.Resumee()
         End If
      End Sub

      Function ClampWidth(pValue As Integer) As Integer
         ClampWidth = me._width.Clamp(me._lastWidth, pValue)
      End Function

      Function ClampHeight(pValue As Integer) As Integer
         ClampHeight = me._height.Clamp(me._lastHeight, pValue)
      End Function

      Sub Apply(pWidth As Integer, pHeight As Integer)
         me._form.Width = me.ClampWidth(pWidth)
         me._form.Height = me.ClampHeight(pHeight)
      End Sub

      Sub SyncFromForm()
         me._lastWidth = me._form.Width
         me._lastHeight = me._form.Height
         me._width.Suspend()
         me._width.Value = me._lastWidth
         me._width.Resumee()
         me._height.Suspend()
         me._height.Value = me._lastHeight
         me._height.Resumee()
      End Sub

      Sub ToggleMaximized()
         If me._maximized Then
            me._form.Width = me._restoreWidth
            me._form.Height = me._restoreHeight
            me._form.Left = me._restoreLeft
            me._form.Top = me._restoreTop
            me._maximized = False
            Exit Sub
         End If
         me._restoreWidth = me._form.Width
         me._restoreHeight = me._form.Height
         me._restoreLeft = me._form.Left
         me._restoreTop = me._form.Top
         me.RefreshMonitor()
         me.EnsureWorkAreaMax()
         me._size.Value = 100
         me._placeInWorkArea()
         me._maximized = True
      End Sub

      Private Sub _placeInWorkArea()
         If me._monitor = NULL Then
            Exit Sub
         End If
         me._form.Left = me._monitor.CenterLeft(me._form.Width)
         me._form.Top = me._monitor.CenterTop(me._form.Height)
      End Sub

      Private Sub _setCanResize(pValue As Boolean)
         me._width.CanGrow = pValue
         me._height.CanGrow = pValue
      End Sub

      Private Sub _setSizeWidth(pValue As Integer)
         If pValue < 1 Or pValue > 100 Then
            Throw New Exception("Size percent must be 1-100, got " & CStr(pValue))
         End If
         me._size.Width.Value = pValue
      End Sub

      Private Sub _setSizeHeight(pValue As Integer)
         If pValue < 1 Or pValue > 100 Then
            Throw New Exception("Size percent must be 1-100, got " & CStr(pValue))
         End If
         me._size.Height.Value = pValue
      End Sub

      Sub ApplyPercent()
         me.Apply(me._widthFromPercent(), me._heightFromPercent())
      End Sub

      Private Sub _setMargin(pValue As Integer, pWidth As Boolean, pHeight As Boolean)
         If pValue < 0 Or pValue > 100 Then
            Throw New Exception("Safe-area margin must be 0-100, got " & Cstr(pValue))
         End If
         If pWidth Then
            me._marginWidth = pValue
         End If
         If pHeight Then
            me._marginHeight = pValue
         End If
         me.EnsureWorkAreaMax()
         me.ApplyPercent()
      End Sub

      Private Function _widthFromPercent() As Integer
         Dim p As Integer = me._size.ClampedWidth()
         If p <= 0 Then
            _widthFromPercent = me._form.Width
            Exit Function
         End If
         If me._monitor = NULL Then
            _widthFromPercent = me._form.Width
            Exit Function
         End If
         _widthFromPercent = CInt(me._monitor.SafeWidth(me._marginWidth) * (p / 100))
      End Function

      Private Function _heightFromPercent() As Integer
         Dim p As Integer = me._size.ClampedHeight()
         If p <= 0 Then
            _heightFromPercent = me._form.Height
            Exit Function
         End If
         If me._monitor = NULL Then
            _heightFromPercent = me._form.Height
            Exit Function
         End If
         _heightFromPercent = CInt(me._monitor.SafeHeight(me._marginHeight) * (p / 100))
      End Function

      Private Sub _onSizeChange(pAxis As TFormsAxis, pField As String)
         me.ApplyPercent()
      End Sub

      Private Sub _onAxisChange(pAxis As TFormsAxis, pField As String)
         If pField = "Min" Or pField = "Max" Then
            me.EnsureWorkAreaMax()
         End If
         Dim w As Integer = me._form.Width
         Dim h As Integer = me._form.Height
         If pAxis.Name = "Width" And pField = "Value" Then
            w = pAxis.Value
         End If
         If pAxis.Name = "Height" And pField = "Value" Then
            h = pAxis.Value
         End If
         me.Apply(w, h)
      End Sub

      Sub Free()
         If me._width <> NULL Then
            me._width.Free()
         End If
         If me._height <> NULL Then
            me._height.Free()
         End If
         If me._size <> NULL Then
            me._size.Free()
         End If
         If me._monitor <> NULL Then
            me._monitor.Free()
         End If
         MyBase.Free()
      End Sub

   End Class

End Namespace
