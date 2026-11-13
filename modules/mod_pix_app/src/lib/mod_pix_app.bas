Imports mod_pix_app_workspace

Namespace mod_pix_app

   ' data7:disable-next-line missing-mybase-free
   Class PixApp

      Shared Sub Run(pCodContaFinanceira As String = "", pTxId As String = "")
         Dim workspace As New PixAppWorkspace(pCodContaFinanceira, pTxId)
         workspace.Show()
         workspace.Free()
      End Sub

   End Class

End Namespace
