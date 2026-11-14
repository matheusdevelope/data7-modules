Imports Forms
Imports mod_editors
Imports mod_editors_button

Namespace mod_editors_docs

   MustInherit Class TDocEditor
      Inherits TButtonEditor

      Private _validateBusy As Boolean

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.ButtonVisible = False
         me.OnValidate = me._handleValidate
      End Sub

      Protected Overridable Function AllowEmpty() As Boolean
         AllowEmpty = Not me.Required
      End Function

      Protected MustOverride Overridable Function ValidateValue() As String
      End Function

      Private Sub _handleValidate(pSender As TObject)
         If me._validateBusy Then
            Exit Sub
         End If
         If me.Chrome.Updating Then
            Exit Sub
         End If
         If me.Chrome.InChange Then
            Exit Sub
         End If
         If me.AllowEmpty() Then
            If Trim(me.Text) = "" Then
               Exit Sub
            End If
         End If
         me._validateBusy = True
         Dim err As String = me.ValidateValue()
         If err <> "" Then
            me._rejectLeave = True
            Forms.MessageBox.Show(err)
            me._validateBusy = False
            me.SetFocus()
            Exit Sub
         End If
         me._validateBusy = False
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
