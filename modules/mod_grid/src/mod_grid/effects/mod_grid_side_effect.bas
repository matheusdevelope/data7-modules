Imports Forms
Imports mod_tobject
Imports mod_grid_row
Namespace mod_grid_side_effect
   Delegate Sub TGridSideEffect(pData As TObject, pRow As TGridRow, pCol As mod_grid_col.TGridCol, ByRef pValue As Variant, ByRef pValid As Boolean, pNative As Grid)
   Class TGridSideEffectChain
      Inherits TTObject
      Private _handlers[] As TGridSideEffect
      Sub New()
         MyBase.New()
         me._handlers = []
      End Sub
      Sub New(pValue As TGridSideEffectChain)
         MyBase.New()
         me._handlers = []
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridSideEffectChain)
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
      Overrides Function Clone() As TGridSideEffectChain
         Clone = New TGridSideEffectChain(me)
      End Function
      Sub Add(ByRef pEffect As TGridSideEffect)
         If pEffect <> NULL Then
            me._handlers.Push(pEffect)
         End If
      End Sub
      Sub Apply(pData As TObject, pRow As TGridRow, pCol As mod_grid_col.TGridCol, ByRef pValue As Variant, ByRef pValid As Boolean, pNative As Grid)
         Dim i As Integer
         For i = 0 To me._handlers.Length - 1
            Dim _handler As TGridSideEffect = me._handlers.GetItem(i)
            _handler(pData, pRow, pCol, pValue, pValid, pNative)
         Next
      End Sub
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
