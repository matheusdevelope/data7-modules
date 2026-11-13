Imports mod_tobject
Imports mod_grid_validator
Namespace mod_grid_validators_builtin
   Class TGridValidators
      Inherits TTObject
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridValidators)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridValidators)
      End Sub
      Overrides Function Clone() As TGridValidators
         Clone = New TGridValidators(me)
      End Function
      Shared Function Custom(pHandler As TGridCellValidator) As TGridCellValidator
         Custom = pHandler
      End Function
      Shared Function Required(pRow As Integer, pCol As Integer, pValue As String, ByRef pMessage As String) As Boolean
         If Trim(pValue) = "" Then
            pMessage = "Campo obrigatório."
            Required = False
         Else
            Required = True
         End If
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
