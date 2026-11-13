Imports mod_tobject
Namespace mod_grid_validator
   Delegate Function TGridCellValidator(pRow As Integer, pCol As Integer, pValue As String, ByRef pMessage As String) As Boolean
   Class TGridValidatorChain
      Inherits TTObject
      Private _handlers[] As TGridCellValidator
      Sub New()
         MyBase.New()
         me._handlers = []
      End Sub
      Sub New(pValue As TGridValidatorChain)
         MyBase.New()
         me._handlers = []
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridValidatorChain)
         If Assigned(pValue) Then
            If Assigned(me._handlers) Then
               me._handlers.Free()
            End If
            If Assigned(pValue._handlers) Then
               me._handlers = pValue._handlers.Clone()
            Else
               me._handlers = []
            End If
         End If
      End Sub
      Overrides Function Clone() As TGridValidatorChain
         Clone = New TGridValidatorChain(me)
      End Function
      Sub Add(ByRef pValidator As TGridCellValidator)
         If pValidator <> NULL Then
            me._handlers.Push(pValidator)
         End If
      End Sub
      Function Validate(pRow As Integer, pCol As Integer, pValue As String, ByRef pMessage As String) As Boolean
         Dim _ok As Boolean = True
         Dim i As Integer
         For i = 0 To me._handlers.Length - 1
            If _ok Then
               Dim _handler As TGridCellValidator = me._handlers.GetItem(i)
               If Not _handler(pRow, pCol, pValue, pMessage) Then
                  _ok = False
               End If
            End If
         Next
         Validate = _ok
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            .Prop("Count", me._handlers.Length)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         If Assigned(me._handlers) Then
            me._handlers.Free()
            me._handlers = Null
         End If
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
