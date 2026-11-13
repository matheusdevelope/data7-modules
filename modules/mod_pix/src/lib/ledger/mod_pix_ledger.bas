Imports mod_tobject
Imports mod_pix_cobranca_completa

Namespace mod_pix_ledger

   MustInherit Class PixLedger
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Overridable Sub SaveCobranca(pCobranca As PixCobrancaCompleta, pDataCancelamento As TDateTime = 0)
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class PixNullLedger
      Inherits PixLedger

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
