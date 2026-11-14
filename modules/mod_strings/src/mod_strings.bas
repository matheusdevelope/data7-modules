Imports Collections
Imports mod_regex

' Helpers de string para o ERP Data7.
' Processamento de texto via TRegExp (VBScript.RegExp); loops ficam só em
' listas, máscaras curtas e JSON (onde regex não distingue string de estrutura).

Namespace mod_strings

   Private Declare Function CharLowerBuffW Lib "user32.dll" Alias "CharLowerBuffW" (ByVal lpsz As String, ByVal cchLength As Long) As Long
   Private Declare Function CharUpperBuffW Lib "user32.dll" Alias "CharUpperBuffW" (ByVal lpsz As String, ByVal cchLength As Long) As Long

   Private Dim _rxCache As StringList

   Private Const LATIN = "A-Za-zÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüýÿ"

   Private Function _rx(pPattern As String, pIgnoreCase As Boolean = True) As TRegExp
      If Not Assigned(_rxCache) Then
         _rxCache = New StringList()
         _rxCache.OwnsObjects = True
         _rxCache.CaseSensitive = True
      End If
      Dim flag As String = "g"
      If pIgnoreCase Then
         flag = flag + "i"
      End If
      Dim key As String = "/" + pPattern + "/" + flag
      Dim idx As Integer = _rxCache.IndexOf(key)
      If idx < 0 Then
         Dim engine As TRegExp = New TRegExp(pPattern, pIgnoreCase, True, False)
         _rxCache.AddObject(key, engine)
         _rx = engine
      Else
         _rx = CType(_rxCache.Objects(idx), TRegExp)
      End If
   End Function

   Private Function _replace(pText As String, pPattern As String, pReplacement As String, pIgnoreCase As Boolean = True) As String
      Dim rx As TRegExp = _rx(pPattern, pIgnoreCase)
      _replace = rx.Replace(pText, pReplacement)
   End Function

   Private Function _test(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As Boolean
      Dim rx As TRegExp = _rx(pPattern, pIgnoreCase)
      _test = rx.Test(pText)
   End Function

   Private Function _values(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As StringList
      Dim rx As TRegExp = _rx(pPattern, pIgnoreCase)
      _values = rx.Values(pText)
   End Function

   Private Function _unique(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As StringList
      Dim rx As TRegExp = _rx(pPattern, pIgnoreCase)
      _unique = rx.UniqueValues(pText)
   End Function

   Private Function _splitRx(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As StringList
      Dim parts As StringList
      Using rx As New TRegExp(pPattern, pIgnoreCase, True, False)
         parts = rx.Split(pText)
      End Using
      _splitRx = parts
   End Function

   Private Function _toLower(pStr As String) As String
      Dim buffer As String = pStr + ""
      Dim n As Long = Len(buffer)
      If n > 0 Then
         CharLowerBuffW(buffer, n)
      End If
      _toLower = buffer
   End Function

   Private Function _toUpper(pStr As String) As String
      Dim buffer As String = pStr + ""
      Dim n As Long = Len(buffer)
      If n > 0 Then
         CharUpperBuffW(buffer, n)
      End If
      _toUpper = buffer
   End Function

   Function IsEmptyString(pStr As String) As Boolean
      IsEmptyString = (pStr = "")
   End Function

   Function IsBlank(pStr As String) As Boolean
      IsBlank = (pStr.Trim() = "")
   End Function

   Function IsNotEmptyString(pStr As String) As Boolean
      IsNotEmptyString = (pStr <> "")
   End Function

   Function IsNumericString(pStr As String) As Boolean
      Dim trimmed As String = pStr.Trim()
      If trimmed = "" Then
         IsNumericString = False
         Exit Function
      End If
      IsNumericString = _test(trimmed, "^[+-]?(\d+[.,]?\d*|[.,]\d+)$", False)
   End Function

   Function IfEmpty(pStr As String, pFallback As String) As String
      If pStr = "" Then
         IfEmpty = pFallback
      Else
         IfEmpty = pStr
      End If
   End Function

   Function IfBlank(pStr As String, pFallback As String) As String
      If pStr.Trim() = "" Then
         IfBlank = pFallback
      Else
         IfBlank = pStr
      End If
   End Function

   Function Coalesce(pStr1 As String, pStr2 As String, pValueCoalesce As String = "") As String
      If pStr1.Trim() = "" Or pStr1 = pValueCoalesce Then
         Coalesce = pStr2.Trim()
         Exit Function
      End If
      Coalesce = pStr1
   End Function

   Function FirstNonEmpty(pStr1 As String, pStr2 As String, pStr3 As String = "") As String
      If pStr1.Trim() <> "" Then
         FirstNonEmpty = pStr1
         Exit Function
      End If
      If pStr2.Trim() <> "" Then
         FirstNonEmpty = pStr2
         Exit Function
      End If
      FirstNonEmpty = pStr3
   End Function

   Function DefaultIfEmpty(pStr As String, pFallback As String = "") As String
      DefaultIfEmpty = IfEmpty(pStr, pFallback)
   End Function

   Function EqualsIgnoreCase(pLeft As String, pRight As String) As Boolean
      EqualsIgnoreCase = (_toLower(pLeft) = _toLower(pRight))
   End Function

   Function ContainsIgnoreCase(pStr As String, pSearch As String) As Boolean
      Dim haystack As String = _toLower(pStr)
      Dim needle As String = _toLower(pSearch)
      ContainsIgnoreCase = haystack.Contains(needle)
   End Function

   Function StartsWithIgnoreCase(pStr As String, pPrefix As String) As Boolean
      Dim haystack As String = _toLower(pStr)
      Dim prefix As String = _toLower(pPrefix)
      StartsWithIgnoreCase = haystack.StartsWith(prefix)
   End Function

   Function EndsWithIgnoreCase(pStr As String, pSuffix As String) As Boolean
      Dim haystack As String = _toLower(pStr)
      Dim suffix As String = _toLower(pSuffix)
      EndsWithIgnoreCase = haystack.EndsWith(suffix)
   End Function

   Function ToLowerCase(pStr As String) As String
      ToLowerCase = _toLower(pStr)
   End Function

   Function ToUpperCase(pStr As String) As String
      ToUpperCase = _toUpper(pStr)
   End Function

   Function Repeat(pStr As String, pCount As Integer) As String
      If pCount <= 0 Or pStr = "" Then
         Repeat = ""
         Exit Function
      End If
      Dim result As String = ""
      Dim i As Integer
      For i = 1 To pCount
         result = result + pStr
      Next
      Repeat = result
   End Function

   Function OnlyNumbers(pStr As String) As String
      OnlyNumbers = _replace(pStr, "\D", "")
   End Function

   Function OnlyLetters(pStr As String) As String
      OnlyLetters = _replace(pStr, "[^" + LATIN + "]", "")
   End Function

   Function OnlyAlphanumeric(pStr As String) As String
      OnlyAlphanumeric = _replace(pStr, "[^" + LATIN + "0-9]", "")
   End Function

   Function RemoveNumbers(pStr As String) As String
      RemoveNumbers = _replace(pStr, "\d", "")
   End Function

   Function RemoveLetters(pStr As String) As String
      RemoveLetters = _replace(pStr, "[" + LATIN + "]", "")
   End Function

   Function RemoveWhitespace(pStr As String) As String
      RemoveWhitespace = _replace(pStr, "\s", "")
   End Function

   Function CollapseWhitespace(pStr As String) As String
      CollapseWhitespace = _replace(pStr.Trim(), "\s+", " ")
   End Function

   Function NormalizeNewlines(pStr As String, pNewline As String = "") As String
      Dim nl As String = pNewline
      If nl = "" Then
         nl = Chr(13) + Chr(10)
      End If
      Dim unified As String = _replace(pStr, "\r\n|\r", Chr(10))
      If nl = Chr(10) Then
         NormalizeNewlines = unified
      Else
         NormalizeNewlines = _replace(unified, Chr(10), nl)
      End If
   End Function

   Function GetListNumbers(pText As String) As StringList
      GetListNumbers = _values(pText, "\d+")
   End Function

   Function GetListStringFromPattern(pText As String, pPattern As String) As StringList
      GetListStringFromPattern = _unique(pText, pPattern)
   End Function

   Function ExtractAll(pText As String, pPattern As String, pUnique As Boolean = False) As StringList
      If pUnique Then
         ExtractAll = _unique(pText, pPattern)
      Else
         ExtractAll = _values(pText, pPattern)
      End If
   End Function

   Function IsMatch(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As Boolean
      IsMatch = _test(pText, pPattern, pIgnoreCase)
   End Function

   Function ReplacePattern(pText As String, pPattern As String, pReplacement As String, pIgnoreCase As Boolean = True) As String
      ReplacePattern = _replace(pText, pPattern, pReplacement, pIgnoreCase)
   End Function

   Function ReplaceIgnoreCase(pText As String, pSearch As String, pReplacement As String) As String
      ReplaceIgnoreCase = _replace(pText, TRegExp.Escape(pSearch), pReplacement, True)
   End Function

   Function ReplaceFirst(pText As String, pSearch As String, pReplacement As String, pIsRegex As Boolean = False) As String
      Dim pattern As String = pSearch
      If Not pIsRegex Then
         pattern = TRegExp.Escape(pSearch)
      End If
      Dim result As String
      Using rx As New TRegExp(pattern, True, False, False)
         result = rx.Replace(pText, pReplacement)
      End Using
      ReplaceFirst = result
   End Function

   Function RemovePattern(pText As String, pPattern As String) As String
      RemovePattern = _replace(pText, pPattern, "")
   End Function

   Function CountMatches(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As Integer
      Dim rx As TRegExp = _rx(pPattern, pIgnoreCase)
      Dim list As TRegExpMatchList = rx.Execute(pText)
      Dim n As Integer = list.Count
      list.Free()
      CountMatches = n
   End Function

   Function WordCount(pStr As String) As Integer
      If pStr.Trim() = "" Then
         WordCount = 0
         Exit Function
      End If
      WordCount = CountMatches(pStr, "\S+")
   End Function

   Function RemoveSpecialCharacters(pStr As String) As String
      RemoveSpecialCharacters = _replace(pStr, "[^" + LATIN + "0-9_\s]", "")
   End Function

   Function RemoveAccentuation(pText As String) As String
      Dim result As String = pText
      result = _replace(result, "[áàãâäåăą]", "a", False)
      result = _replace(result, "[ÁÀÃÂÄÅĂĄ]", "A", False)
      result = _replace(result, "[éèêëěę]", "e", False)
      result = _replace(result, "[ÉÈÊËĚĘ]", "E", False)
      result = _replace(result, "[íìîïį]", "i", False)
      result = _replace(result, "[ÍÌÎÏĮ]", "I", False)
      result = _replace(result, "[óòôõöőø]", "o", False)
      result = _replace(result, "[ÓÒÔÕÖŐØ]", "O", False)
      result = _replace(result, "[úùûüůű]", "u", False)
      result = _replace(result, "[ÚÙÛÜŮŰ]", "U", False)
      result = _replace(result, "[çćč]", "c", False)
      result = _replace(result, "[ÇĆČ]", "C", False)
      result = _replace(result, "[ñń]", "n", False)
      result = _replace(result, "[ÑŃ]", "N", False)
      result = _replace(result, "[ýÿ]", "y", False)
      result = _replace(result, "[ÝŸ]", "Y", False)
      RemoveAccentuation = result
   End Function

   Function ConvertSpecialCharacters(pStr As String) As String
      Dim result As String = RemoveAccentuation(pStr)
      result = _replace(result, "[^" + LATIN + "0-9_\s]", " ")
      ConvertSpecialCharacters = CollapseWhitespace(result)
   End Function

   Function Slugify(pStr As String) As String
      Dim folded As String = RemoveAccentuation(pStr)
      Dim result As String = _toLower(folded)
      result = _replace(result, "[^a-z0-9]+", "-")
      result = TrimAround(result, "-")
      Slugify = result
   End Function

   Function SanitizeFileName(pName As String) As String
      Dim result As String = _replace(pName, "[" + Chr(60) + Chr(62) + ":""/\\|?*]", "_")
      result = CollapseWhitespace(result)
      result = TrimAround(result, ".")
      result = TrimAround(result, " ")
      If result = "" Then
         result = "arquivo"
      End If
      SanitizeFileName = result
   End Function

   Function StripHtml(pStr As String) As String
      Dim lt As String = Chr(60)
      Dim gt As String = Chr(62)
      Dim result As String = _replace(pStr, lt + "[^" + gt + "]+" + gt, "")
      StripHtml = CollapseWhitespace(result)
   End Function

   Function EscapeHtml(pStr As String) As String
      Dim amp As String = "&"
      Dim lt As String = Chr(60)
      Dim gt As String = Chr(62)
      Dim result As String = pStr.Replace(amp, amp + "amp;")
      result = result.Replace(lt, amp + "lt;")
      result = result.Replace(gt, amp + "gt;")
      result = result.Replace(Chr(34), amp + "quot;")
      result = result.Replace(Chr(39), amp + "#39;")
      EscapeHtml = result
   End Function

   Function UnescapeHtml(pStr As String) As String
      Dim amp As String = "&"
      Dim result As String = pStr.Replace(amp + "quot;", Chr(34))
      result = result.Replace(amp + "#39;", Chr(39))
      result = result.Replace(amp + "lt;", Chr(60))
      result = result.Replace(amp + "gt;", Chr(62))
      result = result.Replace(amp + "amp;", amp)
      UnescapeHtml = result
   End Function

   Function EscapeSql(pStr As String) As String
      EscapeSql = pStr.Replace(Chr(39), Chr(39) + Chr(39))
   End Function

   Function QuoteSql(pStr As String) As String
      QuoteSql = Chr(39) + EscapeSql(pStr) + Chr(39)
   End Function

   Function DbQuote(pStr As String) As String
      DbQuote = Chr(34) + pStr + Chr(34)
   End Function

   Function SgQuote(pStr As String) As String
      SgQuote = Chr(39) + pStr + Chr(39)
   End Function

   Function Surround(pStr As String, pLeft As String, pRight As String = "") As String
      Dim suffix As String = pRight
      If suffix = "" Then
         suffix = pLeft
      End If
      Surround = pLeft + pStr + suffix
   End Function

   Function TrimAround(pStr As String, pValueToTrim As String = "") As String
      If pValueToTrim = "" Then
         TrimAround = pStr.Trim()
         Exit Function
      End If
      Dim escaped As String = TRegExp.Escape(pValueToTrim)
      Dim stripped As String = _replace(pStr, "^(" + escaped + ")+|(" + escaped + ")+$", "")
      TrimAround = stripped.Trim()
   End Function

   Function TrimLeading(pStr As String, pValueToTrim As String = "") As String
      If pValueToTrim = "" Then
         TrimLeading = pStr.TrimLeft()
         Exit Function
      End If
      TrimLeading = _replace(pStr, "^(" + TRegExp.Escape(pValueToTrim) + ")+", "")
   End Function

   Function TrimTrailing(pStr As String, pValueToTrim As String = "") As String
      If pValueToTrim = "" Then
         TrimTrailing = pStr.TrimRight()
         Exit Function
      End If
      TrimTrailing = _replace(pStr, "(" + TRegExp.Escape(pValueToTrim) + ")+$", "")
   End Function

   Function FillLeft(pStr As String, pValueToFill As String, pLength As Integer) As String
      FillLeft = Right(pValueToFill + pStr, pLength)
   End Function

   Function FillRight(pStr As String, pValueToFill As String, pLength As Integer) As String
      FillRight = Left(pStr + pValueToFill, pLength)
   End Function

   Function PadStart(pStr As String, pLength As Integer, pPad As String = "0") As String
      If pStr.Length >= pLength Then
         PadStart = pStr
         Exit Function
      End If
      Dim ch As String = " "
      If pPad <> "" Then
         ch = pPad.Left(1)
      End If
      PadStart = Repeat(ch, pLength - pStr.Length) + pStr
   End Function

   Function PadEnd(pStr As String, pLength As Integer, pPad As String = " ") As String
      If pStr.Length >= pLength Then
         PadEnd = pStr
         Exit Function
      End If
      Dim ch As String = " "
      If pPad <> "" Then
         ch = pPad.Left(1)
      End If
      PadEnd = pStr + Repeat(ch, pLength - pStr.Length)
   End Function

   Function PadCenter(pStr As String, pLength As Integer, pPad As String = " ") As String
      If pStr.Length >= pLength Then
         PadCenter = pStr
         Exit Function
      End If
      Dim ch As String = " "
      If pPad <> "" Then
         ch = pPad.Left(1)
      End If
      Dim total As Integer = pLength - pStr.Length
      Dim leftPad As Integer = Int(total / 2)
      Dim rightPad As Integer = total - leftPad
      PadCenter = Repeat(ch, leftPad) + pStr + Repeat(ch, rightPad)
   End Function

   Function Capitalize(pStr As String) As String
      If pStr = "" Then
         Capitalize = ""
         Exit Function
      End If
      Dim first As String = pStr.Left(1)
      Dim rest As String = pStr.Right(pStr.Length - 1)
      Capitalize = _toUpper(first) + _toLower(rest)
   End Function

   Function ToTitleCase(pStr As String) As String
      Dim parts As StringList = _splitRx(CollapseWhitespace(pStr), "\s+")
      Dim result As String = ""
      Dim i As Integer
      Dim n As Integer = parts.Count
      For i = 0 To n - 1
         Dim word As String = parts.Strings(i)
         If word <> "" Then
            If result <> "" Then
               result = result + " "
            End If
            result = result + Capitalize(word)
         End If
      Next
      parts.Free()
      ToTitleCase = result
   End Function

   Function ToPascalCase(pStr As String) As String
      Dim cleaned As String = RemoveAccentuation(pStr)
      Dim parts As StringList = _splitRx(cleaned, "[^A-Za-z0-9]+")
      Dim result As String = ""
      Dim i As Integer
      Dim n As Integer = parts.Count
      For i = 0 To n - 1
         Dim word As String = parts.Strings(i)
         If word <> "" Then
            result = result + Capitalize(word)
         End If
      Next
      parts.Free()
      ToPascalCase = result
   End Function

   Function ToCamelCase(pStr As String) As String
      Dim _pascal As String = ToPascalCase(pStr)
      If _pascal = "" Then
         ToCamelCase = ""
         Exit Function
      End If
      Dim first As String = _pascal.Left(1)
      ToCamelCase = _toLower(first) + _pascal.Right(_pascal.Length - 1)
   End Function

   Function ToSnakeCase(pStr As String) As String
      Dim result As String = RemoveAccentuation(pStr)
      result = _replace(result, "([a-z0-9])([A-Z])", "$1_$2", False)
      result = _replace(result, "[^A-Za-z0-9]+", "_")
      Dim trimmed As String = TrimAround(result, "_")
      result = _toLower(trimmed)
      result = _replace(result, "_+", "_")
      ToSnakeCase = result
   End Function

   Function ToKebabCase(pStr As String) As String
      Dim snake As String = ToSnakeCase(pStr)
      ToKebabCase = snake.Replace("_", "-")
   End Function

   Function Humanize(pStr As String) As String
      Dim result As String = pStr.Replace("_", " ")
      result = result.Replace("-", " ")
      result = _replace(result, "([a-z0-9])([A-Z])", "$1 $2", False)
      Humanize = ToTitleCase(result)
   End Function

   Function Initials(pStr As String, pMax As Integer = 2) As String
      Dim parts As StringList = _splitRx(CollapseWhitespace(pStr), "\s+")
      Dim result As String = ""
      Dim i As Integer
      Dim n As Integer = parts.Count
      For i = 0 To n - 1
         If result.Length >= pMax Then
            Exit For
         End If
         Dim word As String = parts.Strings(i)
         Dim lower As String = _toLower(word)
         Dim particle As Boolean = (lower = "da" Or lower = "de" Or lower = "do" Or lower = "das" Or lower = "dos" Or lower = "e" Or lower = "a" Or lower = "o" Or lower = "em")
         If word <> "" And Not particle Then
            Dim initial As String = word.Left(1)
            result = result + _toUpper(initial)
         End If
      Next
      parts.Free()
      Initials = result
   End Function

   Function SplitToList(pStr As String, pDelimiter As String, pIsRegex As Boolean = False) As StringList
      Dim result As StringList
      If pStr = "" Then
         result = New StringList()
         SplitToList = result
         Exit Function
      End If
      Dim pattern As String = pDelimiter
      If Not pIsRegex Then
         pattern = TRegExp.Escape(pDelimiter)
      End If
      result = _splitRx(pStr, pattern, False)
      SplitToList = result
   End Function

   Function Lines(pStr As String) As StringList
      Lines = _splitRx(NormalizeNewlines(pStr, Chr(10)), Chr(10), False)
   End Function

   Function JoinList(pList As StringList, pStrToJoin As String) As String
      If Not Assigned(pList) Then
         JoinList = ""
         Exit Function
      End If
      If pList.Count = 0 Then
         JoinList = ""
         Exit Function
      End If
      Dim txt As String = pList.Strings(0)
      Dim i As Integer
      Dim n As Integer = pList.Count
      For i = 1 To n - 1
         txt = txt + pStrToJoin + pList.Strings(i)
      Next
      JoinList = txt
   End Function

   Function JoinListWithQuote(pList As StringList, pStrToJoin As String, pQuote As String = "'") As String
      If Not Assigned(pList) Then
         JoinListWithQuote = ""
         Exit Function
      End If
      If pList.Count = 0 Then
         JoinListWithQuote = ""
         Exit Function
      End If
      Dim txt As String = pQuote + pList.Strings(0) + pQuote
      Dim i As Integer
      Dim n As Integer = pList.Count
      For i = 1 To n - 1
         txt = txt + pStrToJoin + pQuote + pList.Strings(i) + pQuote
      Next
      JoinListWithQuote = txt
   End Function

   Function Before(pStr As String, pSep As String) As String
      Dim idx As Integer = pStr.IndexOf(pSep)
      If idx < 0 Then
         Before = pStr
         Exit Function
      End If
      Before = pStr.Left(idx)
   End Function

   Function After(pStr As String, pSep As String) As String
      Dim idx As Integer = pStr.IndexOf(pSep)
      If idx < 0 Then
         After = pStr
         Exit Function
      End If
      After = pStr.Right(pStr.Length - idx - pSep.Length)
   End Function

   Function BeforeLast(pStr As String, pSep As String) As String
      If pSep = "" Or pStr.IndexOf(pSep) < 0 Then
         BeforeLast = pStr
         Exit Function
      End If
      Dim m As TRegExpMatch
      Using rx As New TRegExp("^(.*)" + TRegExp.Escape(pSep), False, False, False)
         m = rx.Match(pStr)
      End Using
      Dim result As String = pStr
      If m.Success Then
         result = m.Group(1)
      End If
      m.Free()
      BeforeLast = result
   End Function

   Function AfterLast(pStr As String, pSep As String) As String
      If pSep = "" Or pStr.IndexOf(pSep) < 0 Then
         AfterLast = pStr
         Exit Function
      End If
      AfterLast = _replace(pStr, "^.*" + TRegExp.Escape(pSep), "", False)
   End Function

   Function Between(pStr As String, pStart As String, pEnd As String) As String
      Dim idx As Integer = pStr.IndexOf(pStart)
      If idx < 0 Then
         Between = ""
         Exit Function
      End If
      Dim rest As String = pStr.Right(pStr.Length - idx - pStart.Length)
      Dim endIdx As Integer = rest.IndexOf(pEnd)
      If endIdx < 0 Then
         Between = rest
         Exit Function
      End If
      Between = rest.Left(endIdx)
   End Function

   Function RemovePrefix(pStr As String, pPrefix As String) As String
      If pPrefix <> "" And pStr.StartsWith(pPrefix) Then
         RemovePrefix = pStr.Right(pStr.Length - pPrefix.Length)
         Exit Function
      End If
      RemovePrefix = pStr
   End Function

   Function RemoveSuffix(pStr As String, pSuffix As String) As String
      If pSuffix <> "" And pStr.EndsWith(pSuffix) Then
         RemoveSuffix = pStr.Left(pStr.Length - pSuffix.Length)
         Exit Function
      End If
      RemoveSuffix = pStr
   End Function

   Function EnsurePrefix(pStr As String, pPrefix As String) As String
      If pPrefix = "" Or pStr.StartsWith(pPrefix) Then
         EnsurePrefix = pStr
         Exit Function
      End If
      EnsurePrefix = pPrefix + pStr
   End Function

   Function EnsureSuffix(pStr As String, pSuffix As String) As String
      If pSuffix = "" Or pStr.EndsWith(pSuffix) Then
         EnsureSuffix = pStr
         Exit Function
      End If
      EnsureSuffix = pStr + pSuffix
   End Function

   Function Truncate(pStr As String, pMax As Integer, pSuffix As String = "...") As String
      If pStr.Length <= pMax Then
         Truncate = pStr
         Exit Function
      End If
      If pMax <= pSuffix.Length Then
         Truncate = pStr.Left(pMax)
         Exit Function
      End If
      Truncate = pStr.Left(pMax - pSuffix.Length) + pSuffix
   End Function

   Function TruncateWords(pStr As String, pMaxWords As Integer, pSuffix As String = "...") As String
      If pMaxWords <= 0 Then
         TruncateWords = ""
         Exit Function
      End If
      Dim parts As StringList = _splitRx(CollapseWhitespace(pStr), "\s+")
      If parts.Count <= pMaxWords Then
         Dim full As String = JoinList(parts, " ")
         parts.Free()
         TruncateWords = full
         Exit Function
      End If
      Dim kept As New StringList()
      Dim i As Integer
      For i = 0 To pMaxWords - 1
         kept.Add(parts.Strings(i))
      Next
      Dim result As String = JoinList(kept, " ") + pSuffix
      kept.Free()
      parts.Free()
      TruncateWords = result
   End Function

   Function Indent(pStr As String, pCount As Integer = 2, pPad As String = " ") As String
      Dim pad As String = Repeat(pPad, pCount)
      Dim unified As String = NormalizeNewlines(pStr, Chr(10))
      Dim result As String
      Using rx As New TRegExp("^", False, True, True)
         result = rx.Replace(unified, pad)
      End Using
      Indent = result
   End Function

   Function Template(pTemplate As String, pValues As StringList) As String
      Dim result As String = pTemplate
      If Not Assigned(pValues) Then
         Template = result
         Exit Function
      End If
      Dim i As Integer
      Dim n As Integer = pValues.Count
      For i = 0 To n - 1
         Dim name As String = pValues.Names(i)
         If name <> "" Then
            result = result.Replace("{" + name + "}", pValues.Values(name))
         End If
         result = result.Replace("{" + CStr(i) + "}", pValues.Strings(i))
      Next
      Template = result
   End Function

   Function ToBool(pValue As String) As Boolean
      Dim trimmed As String = pValue.Trim()
      Dim v As String = _toLower(trimmed)
      ToBool = (v = "s" Or v = "sim" Or v = "1" Or v = "true" Or v = "t" Or v = "y" Or v = "yes")
   End Function

   Function BoolToSN(pValue As Boolean) As String
      If pValue Then
         BoolToSN = "S"
         Exit Function
      End If
      BoolToSN = "N"
   End Function

   Function SNToBool(pValue As String) As Boolean
      Dim trimmed As String = pValue.Trim()
      SNToBool = (_toUpper(trimmed) = "S")
   End Function

   Function BoolToSNO(pSelected As Boolean, pOpcional As Boolean) As String
      If pSelected And pOpcional Then
         BoolToSNO = "SO"
         Exit Function
      End If
      If Not pSelected And pOpcional Then
         BoolToSNO = "NO"
         Exit Function
      End If
      If pSelected And Not pOpcional Then
         BoolToSNO = "S"
         Exit Function
      End If
      BoolToSNO = "N"
   End Function

   Function SNOToBool(pValue As String, pField As String) As Boolean
      Dim trimmed As String = pValue.Trim()
      Dim txt As String = _toLower(trimmed)
      Dim field As String = _toLower(pField)
      Dim selectedFlag As String = FillRight(txt, "nn", 2)
      Dim selectedChar As String = _toLower(selectedFlag)
      If field = "selecionado" And Mid(selectedChar, 1, 1) = "s" Then
         SNOToBool = True
         Exit Function
      End If
      Dim optionalFlag As String = FillLeft(txt, "nn", 2)
      If field = "ativo" And Mid(optionalFlag, 2, 1) = "o" Then
         SNOToBool = True
         Exit Function
      End If
      SNOToBool = False
   End Function

   Function GetNumberFromWord(pWord As Word) As String
      Dim code As Integer = CInt(pWord)
      If code >= 48 And code <= 57 Then
         GetNumberFromWord = Chr(code)
         Exit Function
      End If
      If code >= 96 And code <= 105 Then
         GetNumberFromWord = Chr(code - 48)
         Exit Function
      End If
      GetNumberFromWord = ""
   End Function

   Function GenerateUUID() As String
      Dim value As String
      value = DateUtils.ToStringFormat("dd/mm/yyyy hh:nn:ss.zzz", Now())
      value = Data7.Criptografar(value)
      value = value.Insert("-", 9)
      value = value.Insert("-", 14)
      value = value.Insert("-", 19)
      value = value.Insert("-", 24)
      GenerateUUID = value.Left(36)
   End Function

   Function FormatJson(json As TJSONObject, indent As Integer = 4, maxStringLength As Integer = -1) As String
      FormatJson = FormatJson(json.ToString(), indent, maxStringLength)
   End Function

   Function FormatJson(jsonString As String, indent As Integer = 4, maxStringLength As Integer = -1) As String
      Dim result As String = ""
      Dim depth As Integer = 0
      Dim count As Integer = Len(jsonString)
      Dim vbCrLf As String = Chr(13) + Chr(10)
      Dim c As String
      Dim i As Integer = 1
      Dim startStrIndex As Integer
      Dim strLength As Integer
      Dim currentIndent As Integer
      Dim space As String = " "
      While i <= count
         c = Mid(jsonString, i, 1)
         If c = Chr(34) Then
            result = result + c
            i = i + 1
            startStrIndex = i
            While i <= count
               If Mid(jsonString, i, 1) = Chr(34) And Mid(jsonString, i - 1, 1) <> "\" Then
                  Exit While
               End If
               i = i + 1
            End While
            strLength = i - startStrIndex
            If maxStringLength > 0 And strLength > maxStringLength Then
               result = result + Mid(jsonString, startStrIndex, maxStringLength)
               result = result + "...[TRUNCADO P/ VISUALIZACAO]"
            ElseIf strLength > 0 Then
               result = result + Mid(jsonString, startStrIndex, strLength)
            End If
            If i <= count Then
               result = result + Chr(34)
            End If
         Else
            Select Case c
               Case "{", "["
                  depth = depth + 1
                  result = result + c + vbCrLf + space.StringOfChar(" ", depth * indent)
               Case "}", "]"
                  depth = depth - 1
                  currentIndent = depth * indent
                  If currentIndent < 0 Then
                     currentIndent = 0
                  End If
                  result = result + vbCrLf + space.StringOfChar(" ", currentIndent) + c
               Case ","
                  result = result + c + vbCrLf + space.StringOfChar(" ", depth * indent)
               Case ":"
                  result = result + ": "
               Case " ", Chr(13), Chr(10), Chr(9)
               Case Else
                  result = result + c
            End Select
         End If
         i = i + 1
      End While
      FormatJson = result
   End Function

End Namespace
