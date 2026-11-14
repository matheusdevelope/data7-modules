Imports Collections

Namespace tests

   Class TStrTest
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
         Using suite As New TStrTest()
            suite.Run()
         End Using
      End Sub

      Sub Run()
         print("==== mod_strings ====")
         me.TestEmptyAndCoalesce()
         me.TestExtractAndFilter()
         me.TestAccentAndSanitize()
         me.TestTrimPadQuote()
         me.TestCaseAndSlug()
         me.TestSplitJoin()
         me.TestSliceAndReplace()
         me.TestErpConversions()
         me.TestHtmlSqlJsonUuid()
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

      Function JoinSL(pList As StringList) As String
         Dim result As String = ""
         Dim i As Integer
         Dim n As Integer = pList.Count
         For i = 0 To n - 1
            If i > 0 Then
               result = result + ","
            End If
            result = result + pList.Strings(i)
         Next
         JoinSL = result
      End Function

      Sub TestEmptyAndCoalesce()
         print("-- vazio / coalescência")
         me.AssertEqBool(mod_strings.IsEmptyString(""), True, "IsEmptyString vazio")
         me.AssertEqBool(mod_strings.IsEmptyString("a"), False, "IsEmptyString texto")
         me.AssertEqBool(mod_strings.IsBlank("  "), True, "IsBlank espaços")
         me.AssertEqBool(mod_strings.IsNotEmptyString("x"), True, "IsNotEmptyString")
         me.AssertEq(mod_strings.IfEmpty("", "n/a"), "n/a", "IfEmpty")
         me.AssertEq(mod_strings.IfBlank("  ", "n/a"), "n/a", "IfBlank")
         me.AssertEq(mod_strings.Coalesce("", "b"), "b", "Coalesce vazio")
         me.AssertEq(mod_strings.Coalesce("a", "b"), "a", "Coalesce preenchido")
         me.AssertEq(mod_strings.Coalesce("x", "b", "x"), "b", "Coalesce sentinela")
         me.AssertEq(mod_strings.FirstNonEmpty("", "  ", "ok"), "ok", "FirstNonEmpty")
         me.AssertEqBool(mod_strings.EqualsIgnoreCase("Aa", "aA"), True, "EqualsIgnoreCase")
         me.AssertEqBool(mod_strings.ContainsIgnoreCase("Abc", "B"), True, "ContainsIgnoreCase")
         me.AssertEqBool(mod_strings.StartsWithIgnoreCase("Abc", "ab"), True, "StartsWithIgnoreCase")
         me.AssertEqBool(mod_strings.EndsWithIgnoreCase("Abc", "BC"), True, "EndsWithIgnoreCase")
      End Sub

      Sub TestExtractAndFilter()
         print("-- extração / filtro")
         me.AssertEq(mod_strings.OnlyNumbers("A1B2C3"), "123", "OnlyNumbers")
         me.AssertEq(mod_strings.OnlyNumbers("(11) 98888-0000"), "11988880000", "OnlyNumbers telefone")
         me.AssertEq(mod_strings.OnlyLetters("A1B-ç"), "ABç", "OnlyLetters")
         me.AssertEq(mod_strings.OnlyAlphanumeric("A_1!"), "A1", "OnlyAlphanumeric")
         me.AssertEq(mod_strings.RemoveNumbers("A1B2"), "AB", "RemoveNumbers")
         me.AssertEq(mod_strings.RemoveLetters("A1B2"), "12", "RemoveLetters")
         me.AssertEq(mod_strings.RemoveWhitespace("A B" + Chr(9) + "C"), "ABC", "RemoveWhitespace")
         me.AssertEq(mod_strings.CollapseWhitespace("A   B" + Chr(10) + "C"), "A B C", "CollapseWhitespace")
         Dim nums As StringList = mod_strings.GetListNumbers("nfe 123 item 45 item 123")
         me.AssertEq(me.JoinSL(nums), "123,45,123", "GetListNumbers preserva repetidos")
         nums.Free()
         Dim vars As StringList = mod_strings.GetListStringFromPattern("nfe 123 item 45 item 123", "\d+")
         me.AssertEq(me.JoinSL(vars), "123,45", "GetListStringFromPattern único")
         vars.Free()
         me.AssertEqInt(mod_strings.CountMatches("a1b22c", "\d+"), 2, "CountMatches")
         me.AssertEqInt(mod_strings.WordCount("  um dois  três "), 3, "WordCount")
         me.AssertEqBool(mod_strings.IsMatch("ABC-99", "^[A-Z]+-\d+$"), True, "IsMatch")
         me.AssertEqBool(mod_strings.IsNumericString("123"), True, "IsNumericString inteiro")
         me.AssertEqBool(mod_strings.IsNumericString("  -12,50  "), True, "IsNumericString decimal BR")
         me.AssertEqBool(mod_strings.IsNumericString("+3.14"), True, "IsNumericString decimal US")
         me.AssertEqBool(mod_strings.IsNumericString(".5"), True, "IsNumericString só fração")
         me.AssertEqBool(mod_strings.IsNumericString(""), False, "IsNumericString vazio")
         me.AssertEqBool(mod_strings.IsNumericString("12a"), False, "IsNumericString com letra")
         me.AssertEqBool(mod_strings.IsNumericString("1.2.3"), False, "IsNumericString dois pontos")
         me.AssertEqBool(mod_strings.IsNumericString("&H10"), False, "IsNumericString hex")
         me.AssertEqBool(mod_strings.IsNumericString("1e10"), False, "IsNumericString científico")
         me.AssertEqBool(mod_strings.IsNumericString("-"), False, "IsNumericString só sinal")
      End Sub

      Sub TestAccentAndSanitize()
         print("-- acentos / sanitização")
         me.AssertEq(mod_strings.RemoveAccentuation("José Açúcar"), "Jose Acucar", "RemoveAccentuation preserva caso")
         me.AssertEq(mod_strings.RemoveAccentuation("ÁÉÍÓÚÇ"), "AEIOUC", "RemoveAccentuation maiúsculas")
         me.AssertEq(mod_strings.ConvertSpecialCharacters("José!"), "Jose", "ConvertSpecialCharacters")
         me.AssertEq(mod_strings.RemoveSpecialCharacters("A#B_C 1!"), "AB_C 1", "RemoveSpecialCharacters")
         me.AssertEq(mod_strings.RemoveSpecialCharacters("José"), "José", "RemoveSpecialCharacters mantém acento")
         me.AssertEq(mod_strings.Slugify("Pão de Açúcar!"), "pao-de-acucar", "Slugify")
         me.AssertEq(mod_strings.SanitizeFileName("rel" + Chr(60) + "fin" + Chr(62) + ".txt"), "rel_fin_.txt", "SanitizeFileName")
         me.AssertEq(mod_strings.StripHtml(Chr(60) + "b" + Chr(62) + "Oi" + Chr(60) + "/b" + Chr(62) + " mundo"), "Oi mundo", "StripHtml")
      End Sub

      Sub TestTrimPadQuote()
         print("-- trim / pad / quote")
         me.AssertEq(mod_strings.TrimAround("  abc  "), "abc", "TrimAround whitespace")
         me.AssertEq(mod_strings.TrimAround("xxABCxx", "xx"), "ABC", "TrimAround substring")
         me.AssertEq(mod_strings.TrimLeading("--abc", "--"), "abc", "TrimLeading")
         me.AssertEq(mod_strings.TrimTrailing("abc--", "--"), "abc", "TrimTrailing")
         me.AssertEq(mod_strings.FillLeft("12", "0000", 4), "0012", "FillLeft")
         me.AssertEq(mod_strings.FillRight("12", "xxxx", 4), "12xx", "FillRight")
         me.AssertEq(mod_strings.PadStart("12", 4, "0"), "0012", "PadStart")
         me.AssertEq(mod_strings.PadEnd("12", 4, "x"), "12xx", "PadEnd")
         me.AssertEq(mod_strings.PadCenter("A", 5, "-"), "--A--", "PadCenter")
         me.AssertEq(mod_strings.Repeat("ab", 3), "ababab", "Repeat")
         me.AssertEq(mod_strings.DbQuote("a"), Chr(34) + "a" + Chr(34), "DbQuote")
         me.AssertEq(mod_strings.SgQuote("a"), "'a'", "SgQuote")
         me.AssertEq(mod_strings.Surround("a", "[", "]"), "[a]", "Surround")
         me.AssertEq(mod_strings.QuoteSql("O'Hara"), "'O''Hara'", "QuoteSql")
      End Sub

      Sub TestCaseAndSlug()
         print("-- case / slug")
         me.AssertEq(mod_strings.Capitalize("jOSÉ"), "José", "Capitalize")
         me.AssertEq(mod_strings.ToLowerCase("ÁÉÍÓÚÇ"), "áéíóúç", "ToLowerCase Unicode")
         me.AssertEq(mod_strings.ToUpperCase("áéíóúç"), "ÁÉÍÓÚÇ", "ToUpperCase Unicode")
         me.AssertEq(mod_strings.ToTitleCase("pão de açúcar"), "Pão De Açúcar", "ToTitleCase")
         me.AssertEq(mod_strings.ToPascalCase("pão-de-açúcar"), "PaoDeAcucar", "ToPascalCase")
         me.AssertEq(mod_strings.ToCamelCase("pão-de-açúcar"), "paoDeAcucar", "ToCamelCase")
         me.AssertEq(mod_strings.ToSnakeCase("PaoDeAcucar"), "pao_de_acucar", "ToSnakeCase")
         me.AssertEq(mod_strings.ToKebabCase("PaoDeAcucar"), "pao-de-acucar", "ToKebabCase")
         me.AssertEq(mod_strings.Humanize("pao_de_acucar"), "Pao De Acucar", "Humanize")
         me.AssertEq(mod_strings.Initials("João da Silva"), "JS", "Initials")
         me.AssertEq(mod_strings.Initials("João Carlos Silva", 3), "JCS", "Initials 3")
      End Sub

      Sub TestSplitJoin()
         print("-- split / join")
         Dim parts As StringList = mod_strings.SplitToList("a,b,c", ",")
         me.AssertEq(me.JoinSL(parts), "a,b,c", "SplitToList vírgula")
         parts.Free()
         Dim emptyParts As StringList = mod_strings.SplitToList("", ",")
         me.AssertEqInt(emptyParts.Count, 0, "SplitToList vazio")
         emptyParts.Free()
         Dim rxParts As StringList = mod_strings.SplitToList("a  b	c", "\s+", True)
         me.AssertEq(me.JoinSL(rxParts), "a,b,c", "SplitToList regex")
         rxParts.Free()
         Dim list As New StringList()
         list.Add("a")
         list.Add("b")
         list.Add("c")
         me.AssertEq(mod_strings.JoinList(list, ";"), "a;b;c", "JoinList")
         me.AssertEq(mod_strings.JoinListWithQuote(list, ","), "'a','b','c'", "JoinListWithQuote")
         list.Free()
         Dim linhas As StringList = mod_strings.Lines("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c")
         me.AssertEq(me.JoinSL(linhas), "a,b,c", "Lines")
         linhas.Free()
      End Sub

      Sub TestSliceAndReplace()
         print("-- recorte / replace")
         me.AssertEq(mod_strings.Before("a/b/c", "/"), "a", "Before")
         me.AssertEq(mod_strings.After("a/b/c", "/"), "b/c", "After")
         me.AssertEq(mod_strings.BeforeLast("a/b/c", "/"), "a/b", "BeforeLast")
         me.AssertEq(mod_strings.AfterLast("a/b/c", "/"), "c", "AfterLast")
         me.AssertEq(mod_strings.Between(Chr(60) + "a" + Chr(62) + "valor" + Chr(60) + "/a" + Chr(62), Chr(60) + "a" + Chr(62), Chr(60) + "/a" + Chr(62)), "valor", "Between")
         me.AssertEq(mod_strings.RemovePrefix("abc", "ab"), "c", "RemovePrefix")
         me.AssertEq(mod_strings.RemoveSuffix("abc", "bc"), "a", "RemoveSuffix")
         me.AssertEq(mod_strings.EnsurePrefix("c", "ab"), "abc", "EnsurePrefix")
         me.AssertEq(mod_strings.EnsureSuffix("ab", "c"), "abc", "EnsureSuffix")
         me.AssertEq(mod_strings.Truncate("abcdefgh", 5), "ab...", "Truncate")
         me.AssertEq(mod_strings.TruncateWords("um dois três quatro", 2), "um dois...", "TruncateWords")
         me.AssertEq(mod_strings.ReplaceIgnoreCase("AbcAbc", "abc", "X"), "XX", "ReplaceIgnoreCase")
         me.AssertEq(mod_strings.ReplaceFirst("aaa", "a", "b"), "baa", "ReplaceFirst")
         me.AssertEq(mod_strings.ReplacePattern("a1b2", "\d", "-"), "a-b-", "ReplacePattern")
         me.AssertEq(mod_strings.RemovePattern("a1b2", "\d"), "ab", "RemovePattern")
         me.AssertEq(mod_strings.Indent("a" + Chr(10) + "b", 2, " "), "  a" + Chr(10) + "  b", "Indent")
         Dim vars As New StringList()
         vars.Add("nome=Ana")
         vars.Add("id=7")
         me.AssertEq(mod_strings.Template("Oi {nome} #{id}", vars), "Oi Ana #7", "Template")
         vars.Free()
      End Sub

      Sub TestErpConversions()
         print("-- conversões ERP")
         me.AssertEq(mod_strings.BoolToSN(True), "S", "BoolToSN True")
         me.AssertEq(mod_strings.BoolToSN(False), "N", "BoolToSN False")
         me.AssertEqBool(mod_strings.SNToBool("s"), True, "SNToBool")
         me.AssertEq(mod_strings.BoolToSNO(True, True), "SO", "BoolToSNO SO")
         me.AssertEq(mod_strings.BoolToSNO(False, True), "NO", "BoolToSNO NO")
         me.AssertEq(mod_strings.BoolToSNO(True, False), "S", "BoolToSNO S")
         me.AssertEq(mod_strings.BoolToSNO(False, False), "N", "BoolToSNO N")
         me.AssertEqBool(mod_strings.SNOToBool("SO", "selecionado"), True, "SNOToBool selecionado")
         me.AssertEqBool(mod_strings.SNOToBool("NO", "selecionado"), False, "SNOToBool não selecionado")
         me.AssertEqBool(mod_strings.SNOToBool("SO", "ativo"), True, "SNOToBool opcional")
         me.AssertEqBool(mod_strings.ToBool("sim"), True, "ToBool sim")
         me.AssertEqBool(mod_strings.ToBool("nao"), False, "ToBool nao")
         me.AssertEq(mod_strings.GetNumberFromWord(48), "0", "GetNumberFromWord teclado")
         me.AssertEq(mod_strings.GetNumberFromWord(96), "0", "GetNumberFromWord numpad")
         me.AssertEq(mod_strings.GetNumberFromWord(12), "", "GetNumberFromWord fora")
      End Sub

      Sub TestHtmlSqlJsonUuid()
         print("-- html / sql / json / uuid")
         Dim lt As String = Chr(60)
         Dim gt As String = Chr(62)
         Dim ampLt As String = "&" + "lt;"
         Dim ampGt As String = "&" + "gt;"
         me.AssertEq(mod_strings.EscapeHtml(lt + "a" + gt), ampLt + "a" + ampGt, "EscapeHtml")
         me.AssertEq(mod_strings.UnescapeHtml(ampLt + "a" + ampGt), lt + "a" + gt, "UnescapeHtml")
         Dim pretty As String = mod_strings.FormatJson("{""a"":1,""b"":""x""}", 2)
         me.AssertTrue(pretty.Contains(Chr(13) + Chr(10)), "FormatJson quebra linha")
         me.AssertTrue(pretty.Contains(": "), "FormatJson espaço após :")
         Dim uuid As String = mod_strings.GenerateUUID()
         me.AssertEqInt(uuid.Length, 36, "GenerateUUID tamanho")
         me.AssertEq(Mid(uuid, 9, 1), "-", "GenerateUUID hífen 9")
         me.AssertEq(Mid(uuid, 14, 1), "-", "GenerateUUID hífen 14")
         me.AssertEq(Mid(uuid, 19, 1), "-", "GenerateUUID hífen 19")
         me.AssertEq(Mid(uuid, 24, 1), "-", "GenerateUUID hífen 24")
      End Sub

      Sub PrintSummary()
         print("==== resultado: " + CStr(me.Passed) + " ok, " + CStr(me.Failed) + " falha(s) ====")
         If me.Failed > 0 Then
            Dim i As Integer
            Dim n As Integer = me._failures.Count
            For i = 0 To n - 1
               print("  - " + me._failures.Strings(i))
            Next
            Throw New Exception("mod_strings: " + CStr(me.Failed) + " teste(s) falharam")
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
