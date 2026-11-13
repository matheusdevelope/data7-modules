Imports Collections
Imports mod_validators

Namespace tests

   Class TValidatorsTest
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
         Using suite As New TValidatorsTest()
            suite.Run()
         End Using
      End Sub

      Sub Run()
         print("==== TValidators ====")
         me.TestOnlyDigits()
         me.TestOnlyAlphaNum()
         me.TestDigitAt()
         me.TestAllSameDigits()
         me.TestFormatCPF()
         me.TestFormatCNPJ()
         me.TestFormatCEP()
         me.TestIsValidCEP()
         me.TestIsValidCPF()
         me.TestIsValidCNPJ()
         me.TestIsValidCPFCnpj()
         me.TestIsValidCNH()
         me.TestIsValidRenavam()
         me.TestIsValidSuframa()
         me.TestIsValidGTIN()
         me.TestIsValidEmail()
         me.TestIsValidSite()
         me.TestIsValidPlaca()
         me.TestIsValidIE()
         me.TestPhone()
         me.TestEmailFormat()
         me.TestUrl()
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

      Sub AssertIE(pValue As String, pUF As String, pWant As Boolean, pMsg As String)
         me.AssertEqBool(TDocs.IsValidIE(pValue, pUF), pWant, pMsg)
      End Sub

      Sub TestOnlyDigits()
         print("-- OnlyDigits")
         me.AssertEq(TText.OnlyDigits("A1B2C3"), "123", "mantém só dígitos")
         me.AssertEq(TText.OnlyDigits("529.982.247-25"), "52998224725", "CPF formatado")
         me.AssertEq(TText.OnlyDigits("(11) 98888-0000"), "11988880000", "telefone")
         me.AssertEq(TText.OnlyDigits("abc"), "", "sem dígitos devolve vazio")
         me.AssertEq(TText.OnlyDigits(""), "", "string vazia")
      End Sub

      Sub TestOnlyAlphaNum()
         print("-- OnlyAlphaNum")
         me.AssertEq(TText.OnlyAlphaNum("12.abc.345/01de-35"), "12ABC34501DE35", "uppercase e remove pontuação")
         me.AssertEq(TText.OnlyAlphaNum("a-b_c 1"), "ABC1", "ignora hífen, underscore e espaço")
         me.AssertEq(TText.OnlyAlphaNum("***"), "", "sem alfanumérico devolve vazio")
         me.AssertEq(TText.OnlyAlphaNum(""), "", "string vazia")
      End Sub

      Sub TestDigitAt()
         print("-- DigitAt")
         me.AssertEqInt(TText.DigitAt("52998224725", 1), 5, "primeiro dígito")
         me.AssertEqInt(TText.DigitAt("52998224725", 10), 2, "dígito 10")
         me.AssertEqInt(TText.DigitAt("52998224725", 11), 5, "último dígito")
         me.AssertEqInt(TText.DigitAt("0", 1), 0, "zero")
      End Sub

      Sub TestAllSameDigits()
         print("-- AllSameDigits")
         me.AssertEqBool(TText.AllSameDigits("11111111111"), True, "todos iguais")
         me.AssertEqBool(TText.AllSameDigits("00000000000"), True, "todos zeros")
         me.AssertEqBool(TText.AllSameDigits("0"), True, "um dígito")
         me.AssertEqBool(TText.AllSameDigits(""), True, "vazio é True")
         me.AssertEqBool(TText.AllSameDigits("11111111112"), False, "último diferente")
         me.AssertEqBool(TText.AllSameDigits("121"), False, "meio diferente")
      End Sub

      Sub TestFormatCPF()
         print("-- FormatCPF")
         me.AssertEq(TDocs.FormatCPF("52998224725"), "529.982.247-25", "11 dígitos")
         me.AssertEq(TDocs.FormatCPF("529.982.247-25"), "529.982.247-25", "já formatado")
         me.AssertEq(TDocs.FormatCPF("11111111111"), "111.111.111-11", "formata mesmo inválido")
         me.AssertEq(TDocs.FormatCPF("123"), "123", "tamanho errado devolve original")
         me.AssertEq(TDocs.FormatCPF(""), "", "vazio devolve original")
      End Sub

      Sub TestFormatCNPJ()
         print("-- FormatCNPJ")
         me.AssertEq(TDocs.FormatCNPJ("11222333000181"), "11.222.333/0001-81", "14 dígitos")
         me.AssertEq(TDocs.FormatCNPJ("11.222.333/0001-81"), "11.222.333/0001-81", "já formatado")
         me.AssertEq(TDocs.FormatCNPJ("12ABC34501DE35"), "12.ABC.345/01DE-35", "alfanumérico")
         me.AssertEq(TDocs.FormatCNPJ("12.abc.345/01de-35"), "12.ABC.345/01DE-35", "alfanumérico minúsculo")
         me.AssertEq(TDocs.FormatCNPJ("123"), "123", "tamanho errado devolve original")
      End Sub

      Sub TestFormatCEP()
         print("-- FormatCEP")
         me.AssertEq(TDocs.FormatCEP("01310100"), "01310-100", "8 dígitos")
         me.AssertEq(TDocs.FormatCEP("01310-100"), "01310-100", "já formatado")
         me.AssertEq(TDocs.FormatCEP("123"), "123", "tamanho errado devolve original")
         me.AssertEq(TDocs.FormatCEP(""), "", "vazio devolve original")
      End Sub

      Sub TestIsValidCEP()
         print("-- IsValidCEP")
         me.AssertEqBool(TDocs.IsValidCEP("01310-100"), True, "formatado")
         me.AssertEqBool(TDocs.IsValidCEP("01310100"), True, "só dígitos")
         me.AssertEqBool(TDocs.IsValidCEP("00000000"), True, "zeros (só checa 8 dígitos)")
         me.AssertEqBool(TDocs.IsValidCEP("123"), False, "tamanho errado")
         me.AssertEqBool(TDocs.IsValidCEP(""), False, "vazio")
         me.AssertEqBool(TDocs.IsValidCEP("abcdefgh"), False, "sem dígitos")
      End Sub

      Sub TestIsValidCPF()
         print("-- IsValidCPF")
         me.AssertEqBool(TDocs.IsValidCPF("52998224725"), True, "válido só dígitos")
         me.AssertEqBool(TDocs.IsValidCPF("529.982.247-25"), True, "válido formatado")
         me.AssertEqBool(TDocs.IsValidCPF("11144477735"), True, "válido 11144477735")
         me.AssertEqBool(TDocs.IsValidCPF("00000000191"), True, "válido com zeros à esquerda")
         me.AssertEqBool(TDocs.IsValidCPF("11111111111"), False, "todos iguais")
         me.AssertEqBool(TDocs.IsValidCPF("00000000000"), False, "todos zeros")
         me.AssertEqBool(TDocs.IsValidCPF("52998224726"), False, "DV inválido")
         me.AssertEqBool(TDocs.IsValidCPF("12345678909"), True, "válido 12345678909")
         me.AssertEqBool(TDocs.IsValidCPF("12345678900"), False, "DV2 inválido")
         me.AssertEqBool(TDocs.IsValidCPF("123"), False, "tamanho errado")
         me.AssertEqBool(TDocs.IsValidCPF(""), False, "vazio")
      End Sub

      Sub TestIsValidCNPJ()
         print("-- IsValidCNPJ")
         me.AssertEqBool(TDocs.IsValidCNPJ("11222333000181"), True, "válido numérico")
         me.AssertEqBool(TDocs.IsValidCNPJ("11.222.333/0001-81"), True, "válido formatado")
         me.AssertEqBool(TDocs.IsValidCNPJ("12345678000195"), True, "válido 12345678000195")
         me.AssertEqBool(TDocs.IsValidCNPJ("12ABC34501DE35"), True, "válido alfanumérico")
         me.AssertEqBool(TDocs.IsValidCNPJ("12.abc.345/01de-35"), True, "alfanumérico minúsculo/formatado")
         me.AssertEqBool(TDocs.IsValidCNPJ("ABCDEFGHIJKL80"), True, "válido só letras + DV")
         me.AssertEqBool(TDocs.IsValidCNPJ("00000000000191"), True, "raiz zeros com filial 0001")
         me.AssertEqBool(TDocs.IsValidCNPJ("00000000000000"), False, "todos zeros")
         me.AssertEqBool(TDocs.IsValidCNPJ("11111111111111"), False, "todos iguais")
         me.AssertEqBool(TDocs.IsValidCNPJ("11222333000182"), False, "DV inválido")
         me.AssertEqBool(TDocs.IsValidCNPJ("12ABC34501DE3A"), False, "DV não numérico")
         me.AssertEqBool(TDocs.IsValidCNPJ("123"), False, "tamanho errado")
         me.AssertEqBool(TDocs.IsValidCNPJ(""), False, "vazio")
      End Sub

      Sub TestIsValidCPFCnpj()
         print("-- IsValidCPFCnpj")
         me.AssertEqBool(TDocs.IsValidCPFCnpj("529.982.247-25"), True, "CPF formatado")
         me.AssertEqBool(TDocs.IsValidCPFCnpj("11.222.333/0001-81"), True, "CNPJ formatado")
         me.AssertEqBool(TDocs.IsValidCPFCnpj("12ABC34501DE35"), True, "CNPJ alfanumérico")
         me.AssertEqBool(TDocs.IsValidCPFCnpj("1234567890A"), False, "11 chars com letra não é CPF")
         me.AssertEqBool(TDocs.IsValidCPFCnpj("11111111111"), False, "CPF inválido")
         me.AssertEqBool(TDocs.IsValidCPFCnpj("11222333000182"), False, "CNPJ inválido")
         me.AssertEqBool(TDocs.IsValidCPFCnpj("1234567890"), False, "tamanho 10")
         me.AssertEqBool(TDocs.IsValidCPFCnpj(""), False, "vazio")
      End Sub

      Sub TestIsValidCNH()
         print("-- IsValidCNH")
         me.AssertEqBool(TDocs.IsValidCNH("02191549110"), True, "válida")
         me.AssertEqBool(TDocs.IsValidCNH("021.915.491-10"), True, "formatada")
         me.AssertEqBool(TDocs.IsValidCNH("12345678900"), True, "válida 12345678900")
         me.AssertEqBool(TDocs.IsValidCNH("00000001801"), True, "DV1>9 aplica dsc=2")
         me.AssertEqBool(TDocs.IsValidCNH("11144477753"), True, "válida 11144477753")
         me.AssertEqBool(TDocs.IsValidCNH("11111111111"), False, "todos iguais")
         me.AssertEqBool(TDocs.IsValidCNH("02191549111"), False, "DV inválido")
         me.AssertEqBool(TDocs.IsValidCNH("123"), False, "tamanho errado")
         me.AssertEqBool(TDocs.IsValidCNH(""), False, "vazio")
      End Sub

      Sub TestIsValidRenavam()
         print("-- IsValidRenavam")
         me.AssertEqBool(TDocs.IsValidRenavam("00639844960"), True, "11 dígitos")
         me.AssertEqBool(TDocs.IsValidRenavam("0639844960"), True, "10 dígitos (pad à esquerda)")
         me.AssertEqBool(TDocs.IsValidRenavam("639844960"), True, "9 dígitos (pad à esquerda)")
         me.AssertEqBool(TDocs.IsValidRenavam("12345678900"), True, "válido 12345678900")
         me.AssertEqBool(TDocs.IsValidRenavam("00639844961"), False, "DV inválido")
         me.AssertEqBool(TDocs.IsValidRenavam("12345678"), False, "8 dígitos")
         me.AssertEqBool(TDocs.IsValidRenavam("123456789012"), False, "12 dígitos")
         me.AssertEqBool(TDocs.IsValidRenavam(""), False, "vazio")
      End Sub

      Sub TestIsValidSuframa()
         print("-- IsValidSuframa")
         me.AssertEqBool(TDocs.IsValidSuframa("100000100"), True, "válido")
         me.AssertEqBool(TDocs.IsValidSuframa("201234564"), True, "válido 201234564")
         me.AssertEqBool(TDocs.IsValidSuframa("123456789"), True, "válido 123456789")
         me.AssertEqBool(TDocs.IsValidSuframa("100000101"), False, "DV inválido")
         me.AssertEqBool(TDocs.IsValidSuframa("12345678"), False, "8 dígitos")
         me.AssertEqBool(TDocs.IsValidSuframa(""), False, "vazio")
      End Sub

      Sub TestIsValidGTIN()
         print("-- IsValidGTIN")
         me.AssertEqBool(TDocs.IsValidGTIN("12345670"), True, "GTIN-8")
         me.AssertEqBool(TDocs.IsValidGTIN("123456789012"), True, "GTIN-12")
         me.AssertEqBool(TDocs.IsValidGTIN("7891234567895"), True, "GTIN-13")
         me.AssertEqBool(TDocs.IsValidGTIN("17891234567892"), True, "GTIN-14")
         me.AssertEqBool(TDocs.IsValidGTIN("7891000100103"), True, "EAN conhecido")
         me.AssertEqBool(TDocs.IsValidGTIN("12345671"), False, "GTIN-8 DV inválido")
         me.AssertEqBool(TDocs.IsValidGTIN("123456789"), False, "9 dígitos")
         me.AssertEqBool(TDocs.IsValidGTIN(""), False, "vazio")
      End Sub

      Sub TestIsValidEmail()
         print("-- IsValidEmail")
         me.AssertEqBool(TEmail.IsValid("user@example.com"), True, "simples")
         me.AssertEqBool(TEmail.IsValid("USER@EXAMPLE.COM"), True, "maiúsculas")
         me.AssertEqBool(TEmail.IsValid("user.name+tag@sub.example.com"), True, "plus e subdomínio")
         me.AssertEqBool(TEmail.IsValid("a@b.co"), True, "TLD com 2 letras")
         me.AssertEqBool(TEmail.IsValid("a@b.com; c@d.com"), True, "lista com ponto-e-vírgula")
         me.AssertEqBool(TEmail.IsValid(";user@example.com;"), True, "peças vazias são ignoradas")
         me.AssertEqBool(TEmail.IsValid("a@b.c"), False, "TLD com 1 letra")
         me.AssertEqBool(TEmail.IsValid("user@localhost"), False, "sem ponto no domínio")
         me.AssertEqBool(TEmail.IsValid("a@b.com;invalid"), False, "um inválido na lista")
         me.AssertEqBool(TEmail.IsValid(";;"), False, "só separadores")
         me.AssertEqBool(TEmail.IsValid(""), False, "vazio")
         me.AssertEqBool(TEmail.IsValid("   "), False, "só espaços")
      End Sub

      Sub TestIsValidSite()
         print("-- IsValidSite")
         me.AssertEqBool(TUrl.IsValid("https://example.com"), True, "https")
         me.AssertEqBool(TUrl.IsValid("http://example.com"), True, "http")
         me.AssertEqBool(TUrl.IsValid("example.com"), True, "sem protocolo")
         me.AssertEqBool(TUrl.IsValid("HTTPS://WWW.EXAMPLE.COM/path"), True, "path e maiúsculas")
         me.AssertEqBool(TUrl.IsValid("https://example.com/foo?bar=1"), True, "query string")
         me.AssertEqBool(TUrl.IsValid("http://localhost"), False, "localhost sem TLD")
         me.AssertEqBool(TUrl.IsValid("example.c"), False, "TLD curto")
         me.AssertEqBool(TUrl.IsValid("not a site"), False, "texto livre")
         me.AssertEqBool(TUrl.IsValid(""), False, "vazio")
      End Sub

      Sub TestIsValidPlaca()
         print("-- IsValidPlaca")
         me.AssertEqBool(TDocs.IsValidPlaca("ABC1234"), True, "padrão antigo")
         me.AssertEqBool(TDocs.IsValidPlaca("ABC1D23"), True, "Mercosul")
         me.AssertEqBool(TDocs.IsValidPlaca("abc1234"), True, "minúsculas")
         me.AssertEqBool(TDocs.IsValidPlaca("ABC-1234"), True, "com hífen")
         me.AssertEqBool(TDocs.IsValidPlaca("ABC1A23"), True, "Mercosul outra letra")
         me.AssertEqBool(TDocs.IsValidPlaca("AB12345"), False, "2 letras")
         me.AssertEqBool(TDocs.IsValidPlaca("ABCD123"), False, "4 letras no início")
         me.AssertEqBool(TDocs.IsValidPlaca("ABC12D3"), False, "não antigo nem Mercosul")
         me.AssertEqBool(TDocs.IsValidPlaca("ABC123"), False, "6 chars")
         me.AssertEqBool(TDocs.IsValidPlaca(""), False, "vazio")
      End Sub

      Sub TestIsValidIE()
         print("-- IsValidIE")
         me.AssertIE("ISENTO", "SP", True, "ISENTO é válido em qualquer UF")
         me.AssertIE("isento", "RJ", True, "ISENTO case-insensitive")
         me.AssertIE(" ISENTO ", "MG", True, "ISENTO com espaços")
         me.AssertIE("110042490011", "", False, "UF vazia")
         me.AssertIE("1234567", "SP", False, "menos de 8 dígitos")
         me.AssertIE("123456789012345", "SP", False, "mais de 14 dígitos")
         me.AssertIE("110042490011", "XX", False, "UF desconhecida")
         me.AssertIE("", "SP", False, "valor vazio")

         me.AssertIE("0101234567869", "AC", True, "AC válido")
         me.AssertIE("01.012.345/678-69", "AC", True, "AC formatado")
         me.AssertIE("0101234567860", "AC", False, "AC DV inválido")
         me.AssertIE("0201234567869", "AC", False, "AC prefixo diferente de 01")

         me.AssertIE("240000048", "AL", True, "AL válido")
         me.AssertIE("250000048", "AL", False, "AL prefixo diferente de 24")

         me.AssertIE("901234567", "AM", True, "AM válido")
         me.AssertIE("801234567", "AM", False, "AM prefixo diferente de 9")

         me.AssertIE("030000012", "AP", True, "AP faixa p=5")
         me.AssertIE("030170010", "AP", True, "AP faixa p=9")
         me.AssertIE("030190230", "AP", True, "AP faixa padrão p=0")
         me.AssertIE("040000012", "AP", False, "AP prefixo diferente de 03")

         me.AssertIE("12345663", "BA", True, "BA 8 dígitos módulo 10")
         me.AssertIE("61234557", "BA", True, "BA 8 dígitos módulo 11")
         me.AssertIE("123456748", "BA", True, "BA 9 dígitos módulo 10")
         me.AssertIE("612345607", "BA", True, "BA 9 dígitos módulo 11")
         me.AssertIE("12345664", "BA", False, "BA DV inválido")
         me.AssertIE("1234567", "BA", False, "BA tamanho 7")

         me.AssertIE("060000015", "CE", True, "CE válido")
         me.AssertIE("0730000100109", "DF", True, "DF válido")
         me.AssertIE("080000010", "ES", True, "ES válido")
         me.AssertIE("100000010", "GO", True, "GO válido")
         me.AssertIE("120000016", "MA", True, "MA válido")
         me.AssertIE("110000016", "MA", False, "MA prefixo diferente de 12")

         me.AssertIE("0623079040080", "MG", True, "MG válido")
         me.AssertIE("062.307.904/0080", "mg", True, "MG formatado e UF minúscula")
         me.AssertIE("0623079040081", "MG", False, "MG DV inválido")

         me.AssertIE("280000014", "MS", True, "MS válido")
         me.AssertIE("270000014", "MS", False, "MS prefixo diferente de 28")
         me.AssertIE("00130000019", "MT", True, "MT válido")
         me.AssertIE("150000014", "PA", True, "PA válido")
         me.AssertIE("160000017", "PB", True, "PB válido")

         me.AssertIE("032141840", "PE", True, "PE 9 dígitos")
         me.AssertIE("18100100000043", "PE", True, "PE 14 dígitos")
         me.AssertIE("032141841", "PE", False, "PE DV inválido")
         me.AssertIE("03214184", "PE", False, "PE tamanho 8")

         me.AssertIE("190000015", "PI", True, "PI válido")
         me.AssertIE("1234567850", "PR", True, "PR válido")
         me.AssertIE("1234567851", "PR", False, "PR DV inválido")
         me.AssertIE("10000009", "RJ", True, "RJ válido")
         me.AssertIE("10000008", "RJ", False, "RJ DV inválido")

         me.AssertIE("200400401", "RN", True, "RN 9 dígitos")
         me.AssertIE("2000400400", "RN", True, "RN 10 dígitos")
         me.AssertIE("210400401", "RN", False, "RN prefixo diferente de 20")

         me.AssertIE("101625210", "RO", True, "RO 9 dígitos")
         me.AssertIE("00000000625213", "RO", True, "RO 14 dígitos")
         me.AssertIE("101625211", "RO", False, "RO DV inválido")

         me.AssertIE("240066281", "RR", True, "RR válido")
         me.AssertIE("250066281", "RR", False, "RR prefixo diferente de 24")
         me.AssertIE("2243658792", "RS", True, "RS válido")
         me.AssertIE("2243658793", "RS", False, "RS DV inválido")
         me.AssertIE("251040852", "SC", True, "SC válido")
         me.AssertIE("271234563", "SE", True, "SE válido")

         me.AssertIE("110042490011", "SP", True, "SP válido")
         me.AssertIE("110.042.490.011", "SP", True, "SP formatado")
         me.AssertIE("110042490012", "SP", False, "SP DV inválido")
         me.AssertIE("11004249001", "SP", False, "SP tamanho 11")

         me.AssertIE("29010227836", "TO", True, "TO válido")
         me.AssertIE("29010227837", "TO", False, "TO DV inválido")
      End Sub


      Sub TestPhone()
         print("-- TPhone")
         me.AssertEqBool(TPhone.IsValid("11988880000"), True, "celular 11 dígitos")
         me.AssertEqBool(TPhone.IsValid("(11) 3333-4444"), True, "fixo 10 dígitos")
         me.AssertEqBool(TPhone.IsValid("5511988880000"), True, "com código do país")
         me.AssertEqBool(TPhone.IsValid("123"), False, "tamanho curto")
         me.AssertEqBool(TPhone.IsValid(""), False, "vazio")
         me.AssertEq(TPhone.Format("11987654321"), "(11) 98765-4321", "celular 11 dígitos")
         me.AssertEq(TPhone.Format("1133334444"), "(11) 3333-4444", "fixo 10 dígitos")
         me.AssertEq(TPhone.Format("987654321", "11", "55"), "+55 (11) 98765-4321", "local com DDD/país")
         me.AssertEq(TPhone.Mask("11987654321"), "(99) 99999-9999", "máscara celular")
         me.AssertEq(TPhone.Mask("1133334444"), "(99) 9999-9999", "máscara fixo")
      End Sub

      Sub TestEmailFormat()
         print("-- TEmail.Format")
         me.AssertEq(TEmail.Format("  USER@EXAMPLE.COM  "), "user@example.com", "trim e lowercase")
         me.AssertEq(TEmail.Format(""), "", "vazio devolve original")
         me.AssertEq(TEmail.Format("   "), "   ", "blank devolve original")
      End Sub

      Sub TestUrl()
         print("-- TUrl")
         me.AssertEqBool(TUrl.IsValidHttp("https://example.com"), True, "http(s) absoluto")
         me.AssertEqBool(TUrl.IsValidHttp("example.com"), False, "sem protocolo não é absoluto")
         me.AssertEqBool(TUrl.IsValidHttp(""), False, "vazio")
         me.AssertEq(TUrl.Format("example.com"), "https://example.com", "preenche https")
         me.AssertEq(TUrl.Format("HTTP://EXAMPLE.COM"), "HTTP://EXAMPLE.COM", "já tem protocolo")
         me.AssertEq(TUrl.Format("https://example.com/path"), "https://example.com/path", "https preservado")
         me.AssertEq(TUrl.Format(""), "", "vazio devolve original")
      End Sub

      Sub PrintSummary()
         print("==== resultado: " + CStr(me.Passed) + " ok, " + CStr(me.Failed) + " falha(s) ====")
         If me.Failed > 0 Then
            Dim i As Integer
            Dim n As Integer = me._failures.Count
            For i = 0 To n - 1
               print("  - " + me._failures.Strings(i))
            Next
            Throw New Exception("TValidators: " + CStr(me.Failed) + " teste(s) falharam")
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
