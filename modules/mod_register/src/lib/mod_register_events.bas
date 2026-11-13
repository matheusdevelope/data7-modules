Imports mod_register_config
Imports mod_register_form
Imports mod_register_record

Namespace mod_register_events

   Class TRegisterContext
      Mode As TRegisterMode
      Form As TRegisterForm
      Record As TRegisterRecord
      RecordWhere As String
      ReservedCode As Integer
      CancelMessage As String
      Allow As Boolean

      Sub New()
         MyBase.New()
         me.RecordWhere = ""
         me.ReservedCode = 0
         me.CancelMessage = ""
         me.Allow = True
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Delegate Sub TRegisterGate(pContext As TRegisterContext)
   Delegate Sub TRegisterHook(pContext As TRegisterContext)

   Class TRegisterEvents
      OnBeforeLoad As TRegisterGate
      OnAfterLoad As TRegisterHook
      OnBeforeReserve As TRegisterGate
      OnAfterReserve As TRegisterHook
      OnBeforeConfirm As TRegisterGate
      OnBeforeSave As TRegisterGate
      OnAfterSave As TRegisterHook
      OnBeforeDelete As TRegisterGate
      OnAfterDelete As TRegisterHook
      OnCancel As TRegisterHook

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
