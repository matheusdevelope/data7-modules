Imports Collections
Imports mod_regex

Namespace tests

   Function OnlyNumbers(pStr As String) As String
      Dim result As String
      Using rx As New TRegExp("\D", True, True, False)
         result = rx.Replace(pStr, "")
      End Using
      OnlyNumbers = result
   End Function

   Function GetListNumbers(pText As String) As StringList
      Dim result As StringList
      Using rx As New TRegExp("\d+", True, True, False)
         result = rx.Values(pText)
      End Using
      GetListNumbers = result
   End Function

   Function GetListStringFromPattern(pText As String, pPattern As String) As StringList
      Dim result As StringList
      Using rx As New TRegExp(pPattern, True, True, False)
         result = rx.UniqueValues(pText)
      End Using
      GetListStringFromPattern = result
   End Function

   Function RemoveSpecialCharacters(pStr As String) As String
      Dim result As String
      Using rx As New TRegExp("[^\w\s]", True, True, False)
         result = rx.Replace(pStr, "")
      End Using
      RemoveSpecialCharacters = result
   End Function

   Function ApplyPhoneMask(pPhone As String, DefaultDDD As String = "", DefaultCodPais As String = "") As String
      pPhone = OnlyNumbers(pPhone)
      DefaultDDD = OnlyNumbers(DefaultDDD)
      DefaultCodPais = OnlyNumbers(DefaultCodPais)
      pPhone = pPhone.Left(13)
      Dim mask As String = "+$1 ($2) $3-$4"
      Dim pattern As String = "(\d{2})(\d{2})(\d{4,5})(\d{4})"
      If Len(pPhone) = 11 Or Len(pPhone) = 10 Then
         pPhone = DefaultCodPais.Left(2) + pPhone
      End If
      If Len(pPhone) = 9 Or Len(pPhone) = 8 Then
         pPhone = DefaultCodPais.Left(2) + DefaultDDD.Left(2) + pPhone
      End If
      If Len(pPhone) = 11 Or Len(pPhone) = 10 Then
         pattern = "(\d{2})(\d{4,5})(\d{4})"
         mask = "($1) $2-$3"
      End If
      If Len(pPhone) = 9 Or Len(pPhone) = 8 Then
         pattern = "(\d{4,5})(\d{4})"
         mask = "$1-$2"
      End If
      Dim masked As String = pPhone
      Using rx As New TRegExp(pattern, True, True, False)
         If rx.Test(pPhone) Then
            masked = rx.Replace(pPhone, mask)
         End If
      End Using
      ApplyPhoneMask = masked
   End Function

   Class TRegExpTest
      Passed As Integer
      Failed As Integer
      Private _failures As StringList

      Sub New()
         MyBase.New()
         me.Passed = 0
         me.Failed = 0
         me._failures = New StringList()
      End Sub

      Shared Sub RunAll()
         Using suite As New TRegExpTest()
            suite.Run()
         End Using
      End Sub

      Sub Run()
         print("==== TRegExp ====")
         me.TestDefaults()
         me.TestPatternRoundtrip()
         me.TestIgnoreCase()
         me.TestIsGlobal()
         me.TestMultiline()
         me.TestTestMethod()
         me.TestSharedIsMatch()
         me.TestExecuteValues()
         me.TestFirstIndexAndLength()
         me.TestCapturingGroups()
         me.TestPatternBackref()
         me.TestLookahead()
         me.TestMatchFirst()
         me.TestMatchMiss()
         me.TestReplaceLiteral()
         me.TestReplaceBackrefs()
         me.TestValuesAndUnique()
         me.TestSplit()
         me.TestEscape()
         me.TestEmptyAndNoMatch()
         me.TestInvalidPattern()
         me.TestInstanceIsolation()
         me.TestClone()
         me.TestCompile()
         me.TestReusePattern()
         me.TestDispose()
         me.TestOnlyNumbers()
         me.TestGetListNumbers()
         me.TestUniquePattern()
         me.TestRemoveSpecial()
         me.TestPhoneMask()
         me.PrintSummary()
      End Sub

      Sub AssertTrue(pOk As Boolean, pMsg As String)
         If pOk Then
            me.Passed = me.Passed + 1
            print("  OK    " + pMsg)
         Else
            me.Failed = me.Failed + 1
            me._failures.Add(pMsg)
            print("  FAIL  " + pMsg)
         End If
      End Sub

      Sub AssertEq(pGot As String, pWant As String, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=[" + pGot + "] esperado=[" + pWant + "])")
      End Sub

      Sub AssertEqInt(pGot As Integer, pWant As Integer, pMsg As String)
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=" + CStr(pGot) + " esperado=" + CStr(pWant) + ")")
      End Sub

      Sub AssertEqBool(pGot As Boolean, pWant As Boolean, pMsg As String)
         Dim gotTxt As String = "False"
         Dim wantTxt As String = "False"
         If pGot Then
            gotTxt = "True"
         End If
         If pWant Then
            wantTxt = "True"
         End If
         me.AssertTrue(pGot = pWant, pMsg + " (obtido=" + gotTxt + " esperado=" + wantTxt + ")")
      End Sub

      Function JoinList(pList As StringList) As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = pList.Count
         For i = 0 To n - 1
            If i > 0 Then
               result = result + ","
            End If
            result = result + pList.Strings(i)
         Next
         JoinList = result
      End Function

      Sub TestDefaults()
         print("-- defaults")
         Using rx As New TRegExp()
            me.AssertEq(rx.Pattern, "", "Pattern inicial vazio")
            me.AssertEqBool(rx.IgnoreCase, True, "IgnoreCase padrão True")
            me.AssertEqBool(rx.IsGlobal, True, "IsGlobal padrão True")
            me.AssertEqBool(rx.Multiline, False, "Multiline padrão False")
            me.AssertEqBool(rx.Disposed, False, "Disposed False após New")
         End Using
      End Sub

      Sub TestPatternRoundtrip()
         print("-- Pattern")
         Using rx As New TRegExp("\d+")
            me.AssertEq(rx.Pattern, "\d+", "construtor define Pattern")
            rx.Pattern = "[a-z]+"
            me.AssertEq(rx.Pattern, "[a-z]+", "Pattern get/set")
         End Using
      End Sub

      Sub TestIgnoreCase()
         print("-- IgnoreCase")
         Using rx As New TRegExp("ABC", True, True, False)
            me.AssertEqBool(rx.Test("abc"), True, "IgnoreCase True casa abc")
            rx.IgnoreCase = False
            me.AssertEqBool(rx.IgnoreCase, False, "IgnoreCase set False")
            me.AssertEqBool(rx.Test("abc"), False, "IgnoreCase False não casa abc")
            me.AssertEqBool(rx.Test("ABC"), True, "IgnoreCase False casa ABC")
         End Using
      End Sub

      Sub TestIsGlobal()
         print("-- IsGlobal")
         Using rx As New TRegExp("\d", True, True, False)
            me.AssertEq(rx.Replace("a1b2c3", "X"), "aXbXcX", "IsGlobal True substitui todos")
            rx.IsGlobal = False
            me.AssertEqBool(rx.IsGlobal, False, "IsGlobal set False")
            me.AssertEq(rx.Replace("a1b2c3", "X"), "aXb2c3", "IsGlobal False substitui só o primeiro")
            Dim list As TRegExpMatchList = rx.Execute("a1b2c3")
            me.AssertEqInt(list.Count, 1, "IsGlobal False Execute devolve 1 match")
            list.Free()
         End Using
      End Sub

      Sub TestMultiline()
         print("-- Multiline")
         Dim nl As String = Chr(10)
         Dim text As String = "abc" + nl + "def"
         Using rx As New TRegExp("^def", True, True, False)
            me.AssertEqBool(rx.Test(text), False, "Multiline False ^ não casa linha interna")
            rx.Multiline = True
            me.AssertEqBool(rx.Multiline, True, "Multiline set True")
            me.AssertEqBool(rx.Test(text), True, "Multiline True ^ casa início de linha")
         End Using
      End Sub

      Sub TestTestMethod()
         print("-- Test")
         Using rx As New TRegExp("\d{3}")
            me.AssertEqBool(rx.Test("ab12cd"), False, "Test sem match")
            me.AssertEqBool(rx.Test("ab123cd"), True, "Test com match")
            me.AssertEqBool(rx.Test(""), False, "Test texto vazio")
         End Using
      End Sub

      Sub TestSharedIsMatch()
         print("-- TRegExp.IsMatch")
         me.AssertEqBool(TRegExp.IsMatch("pedido-42", "\d+"), True, "IsMatch estático encontra dígitos")
         me.AssertEqBool(TRegExp.IsMatch("pedido", "\d+"), False, "IsMatch estático sem dígitos")
         me.AssertEqBool(TRegExp.IsMatch("ABC", "abc", False), False, "IsMatch estático respeita IgnoreCase")
      End Sub

      Sub TestExecuteValues()
         print("-- Execute")
         Using rx As New TRegExp("\d+")
            Dim list As TRegExpMatchList = rx.Execute("a10 b20 c10")
            me.AssertEqInt(list.Count, 3, "Execute Count")
            me.AssertEq(list.Item(0).Value, "10", "Execute Item(0)")
            me.AssertEq(list.Item(1).Value, "20", "Execute Item(1)")
            me.AssertEq(list.Item(2).Value, "10", "Execute Item(2)")
            me.AssertEq(list.ToString(), "10, 20, 10", "MatchList.ToString")
            list.Free()
         End Using
      End Sub

      Sub TestFirstIndexAndLength()
         print("-- FirstIndex/Length")
         Using rx As New TRegExp("\d+")
            Dim m As TRegExpMatch = rx.Match("hello 123!")
            me.AssertEqBool(m.Success, True, "Match Success")
            me.AssertEq(m.Value, "123", "Match Value")
            me.AssertEqInt(m.FirstIndex, 6, "FirstIndex 0-based")
            me.AssertEqInt(m.Length, 3, "Length do match")
            m.Free()
         End Using
      End Sub

      Sub TestCapturingGroups()
         print("-- SubMatches")
         Using rx As New TRegExp("(\d{4})-(\d{2})-(\d{2})")
            Dim m As TRegExpMatch = rx.Match("data 2026-09-08 fim")
            me.AssertEq(m.Value, "2026-09-08", "Value é o match completo")
            me.AssertEqInt(m.GroupCount, 3, "3 grupos de captura")
            me.AssertEq(m.Group(0), "2026-09-08", "Group(0) = Value")
            me.AssertEq(m.Group(1), "2026", "Group(1) ano")
            me.AssertEq(m.Group(2), "09", "Group(2) mês")
            me.AssertEq(m.Group(3), "08", "Group(3) dia")
            me.AssertEq(m.SubMatches.Strings(0), "2026", "SubMatches[0] primeiro grupo")
            me.AssertEq(m.Group(9), "", "Group inexistente devolve vazio")
            m.Free()
         End Using
      End Sub

      Sub TestPatternBackref()
         print("-- backref no padrão")
         Using rx As New TRegExp("(.)\1")
            me.AssertEqBool(rx.Test("book"), True, "(.)\\1 casa oo em book")
            Dim m As TRegExpMatch = rx.Match("book")
            me.AssertEq(m.Value, "oo", "backref Value")
            me.AssertEq(m.Group(1), "o", "backref grupo 1")
            m.Free()
            me.AssertEqBool(rx.Test("box"), False, "sem letra repetida")
         End Using
      End Sub

      Sub TestLookahead()
         print("-- lookahead")
         Using rx As New TRegExp("foo(?=bar)")
            me.AssertEqBool(rx.Test("foobar"), True, "lookahead positivo foobar")
            me.AssertEqBool(rx.Test("foobaz"), False, "lookahead positivo foobaz")
         End Using
         Using rx2 As New TRegExp("foo(?!bar)")
            me.AssertEqBool(rx2.Test("foobaz"), True, "lookahead negativo foobaz")
            me.AssertEqBool(rx2.Test("foobar"), False, "lookahead negativo foobar")
         End Using
      End Sub

      Sub TestMatchFirst()
         print("-- Match primeiro")
         Using rx As New TRegExp("\d+")
            Dim m As TRegExpMatch = rx.Match("a10 b20")
            me.AssertEq(m.Value, "10", "Match devolve só o primeiro")
            me.AssertEqBool(m.Success, True, "primeiro Match Success")
            m.Free()
         End Using
      End Sub

      Sub TestMatchMiss()
         print("-- Match miss")
         Using rx As New TRegExp("[0-9]+")
            Dim m As TRegExpMatch = rx.Match("sem-numero")
            me.AssertEqBool(m.Success, False, "sem match Success=False")
            me.AssertEq(m.Value, "", "sem match Value vazio")
            me.AssertEqInt(m.FirstIndex, 0, "sem match FirstIndex 0")
            me.AssertEq(m.ToString(), "(sem match)", "ToString sem match")
            m.Free()
         End Using
      End Sub

      Sub TestReplaceLiteral()
         print("-- Replace literal")
         Using rx As New TRegExp("\D")
            me.AssertEq(rx.Replace("A1B2C3", ""), "123", "Remove não-dígitos")
         End Using
      End Sub

      Sub TestReplaceBackrefs()
         print("-- Replace $1 $&")
         Using rx As New TRegExp("(\d{4})-(\d{2})-(\d{2})")
            me.AssertEq(rx.Replace("2026-09-08", "$3/$2/$1"), "08/09/2026", "backrefs $1 $2 $3")
         End Using
         Using rx2 As New TRegExp("\d+")
            me.AssertEq(rx2.Replace("id-12", "[$&]"), "id-[12]", "backref $& match inteiro")
         End Using
      End Sub

      Sub TestValuesAndUnique()
         print("-- Values / UniqueValues")
         Using rx As New TRegExp("\d+")
            Dim all As StringList = rx.Values("a10 b20 c10")
            me.AssertEq(me.JoinList(all), "10,20,10", "Values preserva repetidos")
            all.Free()
            Dim unique As StringList = rx.UniqueValues("a10 b20 c10")
            me.AssertEq(me.JoinList(unique), "10,20", "UniqueValues remove repetidos")
            unique.Free()
         End Using
      End Sub

      Sub TestSplit()
         print("-- Split")
         Using rx As New TRegExp(",")
            Dim parts As StringList = rx.Split("a,b,c")
            me.AssertEq(me.JoinList(parts), "a,b,c", "Split por vírgula")
            parts.Free()
            Dim leading As StringList = rx.Split(",a")
            me.AssertEq(me.JoinList(leading), ",a", "Split com delimitador no início")
            leading.Free()
         End Using
         Using rx2 As New TRegExp("\s+")
            Dim words As StringList = rx2.Split("um  dois   tres")
            me.AssertEq(me.JoinList(words), "um,dois,tres", "Split por espaços")
            words.Free()
         End Using
         Using rx3 As New TRegExp()
            Dim one As StringList = rx3.Split("abc")
            me.AssertEq(me.JoinList(one), "abc", "Split com Pattern vazio devolve o texto")
            one.Free()
         End Using
      End Sub

      Sub TestEscape()
         print("-- Escape")
         Dim escaped As String = TRegExp.Escape("a+b")
         me.AssertEq(escaped, "a\+b", "Escape de +")
         Using rx As New TRegExp(TRegExp.Escape("a+b"), False, True, False)
            me.AssertEqBool(rx.Test("a+b"), True, "padrão escapado casa literal")
            me.AssertEqBool(rx.Test("aab"), False, "padrão escapado não usa + como quantifier")
         End Using
         Dim dots As String = TRegExp.Escape("file.txt")
         Using rx2 As New TRegExp(dots, False, True, False)
            me.AssertEqBool(rx2.Test("file.txt"), True, "Escape de ponto")
            me.AssertEqBool(rx2.Test("fileXtxt"), False, "ponto escapado não é coringa")
         End Using
      End Sub

      Sub TestEmptyAndNoMatch()
         print("-- vazio / sem match")
         Using rx As New TRegExp("\d+")
            Dim list As TRegExpMatchList = rx.Execute("sem-numero")
            me.AssertEqInt(list.Count, 0, "Execute sem match Count=0")
            list.Free()
            Dim emptyList As TRegExpMatchList = rx.Execute("")
            me.AssertEqInt(emptyList.Count, 0, "Execute texto vazio Count=0")
            emptyList.Free()
            me.AssertEq(rx.Replace("abc", "X"), "abc", "Replace sem match devolve original")
         End Using
      End Sub

      Sub TestInvalidPattern()
         print("-- padrão inválido")
         Dim threw As Boolean = False
         Dim rx As TRegExp
         Try
            rx = New TRegExp()
            rx.Pattern = "[invalid"
            rx.Test("a")
         Catch ex As Exception
            threw = True
         End Try
         If Assigned(rx) Then
            rx.Free()
         End If
         me.AssertTrue(threw, "padrão inválido lança exceção")
      End Sub

      Sub TestInstanceIsolation()
         print("-- isolamento entre instâncias")
         Using rx1 As New TRegExp("\d+", True, True, False)
            Using rx2 As New TRegExp("[a-z]+", True, True, False)
               me.AssertEq(rx1.Replace("A1B2", ""), "AB", "rx1 \\d+ remove dígitos")
               me.AssertEq(rx2.Replace("A1B2", ""), "12", "rx2 [a-z]+ remove letras")
               rx1.Pattern = "X"
               me.AssertEq(rx2.Pattern, "[a-z]+", "mudar Pattern de rx1 não altera rx2")
            End Using
         End Using
      End Sub

      Sub TestClone()
         print("-- Clone")
         Using rx As New TRegExp("\d+", False, False, True)
            Dim copy As TRegExp = rx.Clone()
            me.AssertEq(copy.Pattern, "\d+", "Clone Pattern")
            me.AssertEqBool(copy.IgnoreCase, False, "Clone IgnoreCase")
            me.AssertEqBool(copy.IsGlobal, False, "Clone IsGlobal")
            me.AssertEqBool(copy.Multiline, True, "Clone Multiline")
            copy.Pattern = "abc"
            me.AssertEq(rx.Pattern, "\d+", "Clone é instância independente")
            copy.Free()
         End Using
      End Sub

      Sub TestCompile()
         print("-- Compile")
         Dim rx As TRegExp = TRegExp.Compile("[A-Z]+", False, True, False)
         me.AssertEq(rx.Pattern, "[A-Z]+", "Compile Pattern")
         me.AssertEqBool(rx.IgnoreCase, False, "Compile IgnoreCase")
         me.AssertEqBool(rx.IsGlobal, True, "Compile IsGlobal")
         me.AssertEqBool(rx.Test("abc"), False, "Compile case-sensitive")
         me.AssertEqBool(rx.Test("ABC"), True, "Compile casa maiúsculas")
         rx.Free()
      End Sub

      Sub TestReusePattern()
         print("-- reuso da mesma instância")
         Using rx As New TRegExp("\d+")
            me.AssertEq(rx.Replace("a1b", ""), "ab", "primeiro Pattern")
            rx.Pattern = "[a-z]+"
            me.AssertEq(rx.Replace("a1b", ""), "1", "mesmo engine com outro Pattern")
            me.AssertEq(rx.ToString(), "/[a-z]+/ig", "ToString flags")
         End Using
      End Sub

      Sub TestDispose()
         print("-- Dispose")
         Dim rx As New TRegExp("\d+")
         rx.Dispose()
         me.AssertEqBool(rx.Disposed, True, "Disposed True após Dispose")
         Dim threw As Boolean = False
         Try
            rx.Test("1")
         Catch ex As Exception
            threw = True
         End Try
         me.AssertTrue(threw, "uso após Dispose lança")
         rx.Dispose()
         me.AssertEqBool(rx.Disposed, True, "Dispose é idempotente")
         rx.Free()
      End Sub

      Sub TestOnlyNumbers()
         print("-- OnlyNumbers")
         me.AssertEq(OnlyNumbers("A1B2C3"), "123", "OnlyNumbers")
         me.AssertEq(OnlyNumbers("(11) 98888-0000"), "11988880000", "OnlyNumbers telefone")
      End Sub

      Sub TestGetListNumbers()
         print("-- GetListNumbers")
         Dim nums As StringList = GetListNumbers("nfe 123 item 45 item 123")
         me.AssertEq(me.JoinList(nums), "123,45,123", "GetListNumbers preserva repetidos")
         nums.Free()
      End Sub

      Sub TestUniquePattern()
         print("-- UniqueValues via padrão")
         Dim vars As StringList = GetListStringFromPattern("nfe 123 item 45 item 123", "\d+")
         me.AssertEq(me.JoinList(vars), "123,45", "GetListStringFromPattern único")
         vars.Free()
      End Sub

      Sub TestRemoveSpecial()
         print("-- RemoveSpecialCharacters")
         me.AssertEq(RemoveSpecialCharacters("A#B_C 1!"), "AB_C 1", "RemoveSpecialCharacters")
      End Sub

      Sub TestPhoneMask()
         print("-- ApplyPhoneMask")
         me.AssertEq(ApplyPhoneMask("11987654321"), "(11) 98765-4321", "celular 11 dígitos")
         me.AssertEq(ApplyPhoneMask("1133334444"), "(11) 3333-4444", "fixo 10 dígitos")
         me.AssertEq(ApplyPhoneMask("987654321", "11", "55"), "+55 (11) 98765-4321", "local com DDD/país")
      End Sub

      Sub PrintSummary()
         print("==== resultado: " + CStr(me.Passed) + " ok, " + CStr(me.Failed) + " falha(s) ====")
         If me.Failed > 0 Then
            Dim i As Integer
            Dim n As Integer = me._failures.Count
            For i = 0 To n - 1
               print("  - " + me._failures.Strings(i))
            Next
            Throw New Exception("TRegExp: " + CStr(me.Failed) + " teste(s) falharam")
         End If
      End Sub

      Sub Free()
         If Assigned(me._failures) Then
            me._failures.Free()
            me._failures = Null
         End If
         MyBase.Free()
      End Sub
   End Class

End Namespace
