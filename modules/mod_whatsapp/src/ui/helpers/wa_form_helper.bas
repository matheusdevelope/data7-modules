Imports Forms
Imports IO

Namespace mod_wa_form_helper

   Class WaFormHelper

      Shared Sub BuildControlGroup(pTitle As String, pParent As Forms.TWinControl, pTop As Integer, pHeight As Integer, pWidth As Integer)
         Dim _group As New Forms.ControlGroup(pParent)
         _group.Left = 4
         _group.Top = pTop
         _group.Caption = pTitle
         _group.Height = pHeight
         _group.Width = pWidth
      End Sub

      Shared Function BuildLabel(pParent As Forms.TWinControl, pText As String, pTop As Integer, pRight As Integer, pRequired As Boolean = False) As Forms.StaticText
         Dim _label As New Forms.StaticText(pParent)
         _label.Text = pText
         _label.Top = pTop
         _label.Left = pRight - _label.Width - 1
         If pRequired Then
            _label.Font.Color = RGB(0, 0, 255)
         End If
         BuildLabel = _label
      End Function

      Shared Function BuildLabelOnTop(pParent As Forms.TWinControl, pText As String, pTop As Integer, pLeft As Integer, pRequired As Boolean = False) As Forms.StaticText
         Dim _label As New Forms.StaticText(pParent)
         _label.Text = pText
         _label.Top = pTop
         _label.Left = pLeft
         If pRequired Then
            _label.Font.Color = RGB(0, 0, 255)
         End If
         BuildLabelOnTop = _label
      End Function

      Shared Function BuildTextField(pParent As Forms.TWinControl, pTop As Integer, pLeft As Integer, pWidth As Integer) As Forms.TextBox
         Dim _field As New Forms.TextBox(pParent)
         _field.Left = pLeft
         _field.Top = pTop
         _field.Width = pWidth
         BuildTextField = _field
      End Function

      Shared Function BuildComboBox(pParent As Forms.TWinControl, pTop As Integer, pLeft As Integer, pWidth As Integer) As Forms.HComboBox
         Dim _combo As New Forms.HComboBox(pParent)
         _combo.Top = pTop
         _combo.Left = pLeft
         _combo.Width = pWidth
         BuildComboBox = _combo
      End Function

      Shared Function SizeHeaderForm() As Integer
         SizeHeaderForm = WaFormHelper.IsDevStudio() ? 35 : 27
      End Function

      Shared Function SizeBorderForm(pMultiplicator As Integer = 1) As Integer
         Dim _base As Integer = WaFormHelper.IsDevStudio() ? 4 : 2
         SizeBorderForm = _base * pMultiplicator
      End Function

      Shared Function IsDevStudio() As Boolean
         Dim _path As String = Data7.NomeArquivoExecutavel.ToLower()
         IsDevStudio = File.Exists(_path.Replace(File.ExtractName(_path), "devstudio.exe"))
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
