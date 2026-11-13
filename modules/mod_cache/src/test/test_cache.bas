' data7:disable missing-mybase-free
' data7:disable qualified-private-shared-access
Imports mod_cache
Imports mod_tobject

' Caso pequeno do cache. Não importa o Ambient.

Namespace test_cache

   Class TSample
      Inherits TTObject

      Name As String

      Sub New(pName As String)
         MyBase.New()
         me.Name = pName
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   ' data7:disable-next-line missing-mybase-new
   Class TCacheTest

      Private Shared _failed As Integer

      Private Shared Sub Check(pTitle As String, pOk As Boolean)
         If pOk Then
            print(pTitle & " OK")
         Else
            _failed = _failed + 1
            print(pTitle & " FALHOU")
         End If
      End Sub

      Shared Sub Execute(pCodTabela As Integer)
         Dim _key As String = "main-" & pCodTabela.ToString()
         Dim _form As Forms.Form = Cache.Find<Forms.Form>("Form", _key)
         If Not Assigned(_form) Then
            _form = New Forms.Form()
            _form.Caption = pCodTabela.ToString() & " - " & DateTime().ToString("dd/MM/yyyy hh:nn:ss.zzz")
            Dim _txt As Forms.TextBox = New Forms.TextBox(_form)
            Cache.Put("Form", _key, _form)
         End If
         _form.Show()
      End Sub

      Shared Sub Run()
         _failed = 0
         Cache.Clear()

         Dim alpha As New TSample("alpha")
         Dim beta As New TSample("beta")
         Dim other As New TSample("other")
         Cache.Put("Sample", "a", alpha)
         Cache.Put("sample", "B", beta)
         Cache.Put("Other", "a", other)

         Dim found As TSample = Cache.Find<TSample>("SAMPLE", "A")
         TCacheTest.Check("Find mesma instancia", Assigned(found) And (found.Name = "alpha"))
         TCacheTest.Check("Contains chave", Cache.Contains("Sample", "b"))
         TCacheTest.Check("Contains ausente", Not Cache.Contains("Sample", "z"))
         TCacheTest.Check("ContainsObject", Cache.ContainsObject("Sample", beta))
         TCacheTest.Check("PoolCount 2", Cache.PoolCount() = 2)
         TCacheTest.Check("Count Sample 2", Cache.Count("Sample") = 2)
         TCacheTest.Check("Count Other 1", Cache.Count("Other") = 1)
         TCacheTest.Check("NameAt 0", Cache.NameAt(0) = "SAMPLE")
         TCacheTest.Check("NameAt 1", Cache.NameAt(1) = "OTHER")

         Dim replaced As New TSample("replaced")
         Cache.Put("Sample", "a", replaced)
         found = Cache.Find<TSample>("Sample", "a")
         TCacheTest.Check("Put substitui", Assigned(found) And (found.Name = "replaced"))
         TCacheTest.Check("Count apos replace", Cache.Count("Sample") = 2)

         Cache.Remove("Sample", "b")
         TCacheTest.Check("Remove", Not Cache.Contains("Sample", "b"))
         TCacheTest.Check("Count apos remove", Cache.Count("Sample") = 1)

         Cache.ClearPool("Other")
         TCacheTest.Check("ClearPool", Cache.PoolCount() = 1)
         TCacheTest.Check("Other vazio", Cache.Count("Other") = 0)

         Cache.Clear()
         TCacheTest.Check("Clear", Cache.PoolCount() = 0)
         TCacheTest.Check("Find apos clear", Not Assigned(Cache.Find<TSample>("Sample", "a")))

         Dim again As New TSample("again")
         Cache.Put("Sample", "a", again)
         found = Cache.Find<TSample>("Sample", "a")
         TCacheTest.Check("Put apos clear", Assigned(found) And (found.Name = "again"))

         Cache.Clear()
         If _failed = 0 Then
            print("Cache: todos os testes passaram")
         Else
            print("Cache: " & CStr(_failed) & " teste(s) falharam")
         End If
      End Sub

   End Class

End Namespace
