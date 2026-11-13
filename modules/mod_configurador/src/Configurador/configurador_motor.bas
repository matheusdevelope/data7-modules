Imports Collections
Imports mod_tobject
Imports mod_tlist
Imports configurador_tabela
Imports configurador_relatorio

Namespace configurador_motor

   Class Motor
      Shared Function CarregarTabela(pCodTabela As Integer) As Tabela
         CarregarTabela = New Tabela(pCodTabela)
      End Function

      Shared Function CarregarTabela(pNome As String, pSchema As String = "") As Tabela
         CarregarTabela = New Tabela(pNome, pSchema)
      End Function

      Shared Function CarregarRelatorio(pCodRelatorio As Integer) As Relatorio
         CarregarRelatorio = New Relatorio(pCodRelatorio)
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
