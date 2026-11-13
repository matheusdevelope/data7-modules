Imports mod_tobject
Imports mod_grid_popup
Namespace mod_grid_popup_checkbox
   Class TGridCheckboxPopup
      Inherits TGridPopup
      Sub New()
         MyBase.New()
      End Sub
      Sub New(pValue As TGridCheckboxPopup)
         MyBase.New()
         me.Assign(pValue)
      End Sub
      Sub Assign(pValue As TGridCheckboxPopup)
      End Sub
      Overrides Function Clone() As TGridCheckboxPopup
         Clone = New TGridCheckboxPopup(me)
      End Function
      Function Show(pIsSelectionColumn As Boolean) As TGridPopupItem
         Dim _result As TGridPopupItem
         Dim _invertTitle As String = "Inverter Marcação"
         If pIsSelectionColumn Then
            _invertTitle = "Inverter Seleção"
         End If
         me.Add(New TGridPopupItem("check-current", "Marcar", Null))
         me.Add(New TGridPopupItem("uncheck-current", "Desmarcar", Null))
         me.Add(New TGridPopupSeparator("sep-current"))
         me.Add(New TGridPopupItem("check-all", "Marcar Todos", Null))
         me.Add(New TGridPopupItem("uncheck-all", "Tirar Marcação de Todos", Null))
         me.Add(New TGridPopupSeparator("sep-invert"))
         me.Add(New TGridPopupItem("invert-all", _invertTitle, Null))
         _result = MyBase.Show()
         Show = _result
      End Function
      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName)
            ToString = .Text()
            .Free()
         End With
      End Function
      Overrides Sub Dispose()
         MyBase.Dispose()
      End Sub
      Sub Free()
         MyBase.Free()
      End Sub
   End Class
End Namespace
