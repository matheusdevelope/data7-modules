# mod_strings

`mod_strings` is a Data7 namespace of string helpers. It filters, splits, pads, case-folds, slugs, quotes, and templates text. Regex work goes through `mod_regex.TRegExp` (VBScript.RegExp). Unicode upper/lower uses Windows `CharUpperBuffW` / `CharLowerBuffW`.

This module does **not** validate or mask documents, phones, emails, or URLs. That belongs in a consumer module. It does **not** expose a class to instantiate: call `mod_strings.<Function>(...)`.

Version `1.0.0.0` (`data7.json`). Dependency: `mod_regex` `1.0.0.0`.

This file is the module contract. Consumers must be able to call the API from this README alone. Do not open `.bas` files to use the module; open them only to confirm a detail that is not stated here.

## Quick Start (Minimal)

```basic
Imports Collections

' Happy path: slug, numeric check, split. Qualify every call.
Dim slug As String = mod_strings.Slugify("Pão de Açúcar!")
' slug = "pao-de-acucar"

Dim okNum As Boolean = mod_strings.IsNumericString("12,50")
' okNum = True (comma or dot as a single decimal separator)

Dim parts As StringList = mod_strings.SplitToList("a,b,c", ",")
' caller owns the returned list
Dim joined As String = mod_strings.JoinList(parts, ";")
' joined = "a;b;c"
parts.Free()
```

Canonical tests: `tests.TStrTest.RunAll()` (wired from `src/Principal.bas`). Covers empty/coalesce, extract/filter/`IsNumericString`, accents/sanitize, trim/pad/quote, case/slug, split/join, slice/replace, ERP SN/SNO, HTML/SQL/JSON/UUID.

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_strings.bas` | `mod_strings` | none (public functions only) |
| `src/tests/mod_strings_tests.bas` | `tests` | `TStrTest` |
| `src/Principal.bas` | — | script entry: `tests.TStrTest.RunAll()` |

Call helpers as `mod_strings.Name(...)`. Names were chosen so they do not collide with native `Trim`, `Split`, `PadLeft`, `PadRight`, `IsEmpty`, `IsNumeric`.

---

## Empty, blank, coalesce

Predicates and fallbacks for `""` vs whitespace.

```basic
Function IsEmptyString(pStr As String) As Boolean
   ' True iff pStr = "" (does not trim)
Function IsBlank(pStr As String) As Boolean
   ' True iff pStr.Trim() = ""
Function IsNotEmptyString(pStr As String) As Boolean
   ' True iff pStr <> ""
Function IsNumericString(pStr As String) As Boolean
   ' Trim then match ^[+-]?(\d+[.,]?\d*|[.,]\d+)$. Empty after trim → False.
   ' Accepts "123", " -12,50 ", "+3.14", ".5". Rejects "12a", "1.2.3", "&H10", "1e10", "-".
Function IfEmpty(pStr As String, pFallback As String) As String
   ' pStr = "" → pFallback, else pStr
Function IfBlank(pStr As String, pFallback As String) As String
   ' Trim empty → pFallback, else original pStr
Function Coalesce(pStr1 As String, pStr2 As String, pValueCoalesce As String = "") As String
   ' If Trim(pStr1) = "" Or pStr1 = pValueCoalesce → Trim(pStr2), else pStr1
Function FirstNonEmpty(pStr1 As String, pStr2 As String, pStr3 As String = "") As String
   ' First of pStr1, pStr2 whose Trim() <> ""; else pStr3 as-is
Function DefaultIfEmpty(pStr As String, pFallback As String = "") As String
   ' Alias of IfEmpty
```

**Defaults / sentinels:** `Coalesce` sentinel `pValueCoalesce` default `""`. `FirstNonEmpty` / `DefaultIfEmpty` third/fallback default `""`.

**No-op / False:** `IsNumericString("")` and whitespace-only → `False`. `IfEmpty`/`IfBlank` return `pStr` when the empty/blank test fails.

---

## Ignore-case compare

Comparison uses the module Unicode fold (`ToLowerCase` path), not native `ToLower`.

```basic
Function EqualsIgnoreCase(pLeft As String, pRight As String) As Boolean
Function ContainsIgnoreCase(pStr As String, pSearch As String) As Boolean
Function StartsWithIgnoreCase(pStr As String, pPrefix As String) As Boolean
Function EndsWithIgnoreCase(pStr As String, pSuffix As String) As Boolean
```

---

## Case fold and repeat

```basic
Function ToLowerCase(pStr As String) As String
   ' Unicode fold, including Latin accents (É → é)
Function ToUpperCase(pStr As String) As String
   ' Unicode fold (é → É)
Function Repeat(pStr As String, pCount As Integer) As String
   ' Concatenate pStr pCount times. pCount <= 0 or pStr = "" → ""
```

---

## Filter, extract, regex

Letter class used by letter/alphanumeric/special filters (private `LATIN`):  
`A-Za-z` plus `ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüýÿ`.

```basic
Function OnlyNumbers(pStr As String) As String
   ' Keep \d only. "A1B2" → "12". "(11) 98888-0000" → "11988880000"
Function OnlyLetters(pStr As String) As String
   ' Keep LATIN letters. "A1B-ç" → "ABç"
Function OnlyAlphanumeric(pStr As String) As String
   ' Keep LATIN + 0-9. "A_1!" → "A1"
Function RemoveNumbers(pStr As String) As String
Function RemoveLetters(pStr As String) As String
Function RemoveWhitespace(pStr As String) As String
   ' Strip \s
Function CollapseWhitespace(pStr As String) As String
   ' Trim then \s+ → single space. "A   B\nC" → "A B C"
Function NormalizeNewlines(pStr As String, pNewline As String = "") As String
   ' Unify \r\n|\r to LF, then LF → pNewline. Default pNewline = Chr(13)+Chr(10).
   ' Pass Chr(10) to keep LF.

Function GetListNumbers(pText As String) As StringList
   ' All \d+ runs, duplicates kept. Caller Free.
Function GetListStringFromPattern(pText As String, pPattern As String) As StringList
   ' Unique matches of pPattern. Caller Free.
Function ExtractAll(pText As String, pPattern As String, pUnique As Boolean = False) As StringList
   ' pUnique False → all matches; True → unique. Caller Free.

Function IsMatch(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As Boolean
   ' TRegExp.Test (substring unless the pattern uses ^ $)
Function ReplacePattern(pText As String, pPattern As String, pReplacement As String, pIgnoreCase As Boolean = True) As String
Function ReplaceIgnoreCase(pText As String, pSearch As String, pReplacement As String) As String
   ' Literal pSearch (escaped), ignore-case, all occurrences
Function ReplaceFirst(pText As String, pSearch As String, pReplacement As String, pIsRegex As Boolean = False) As String
   ' First match only, always ignore-case. pIsRegex False → escape as literal.
Function RemovePattern(pText As String, pPattern As String) As String
   ' ReplacePattern with ""
Function CountMatches(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As Integer
Function WordCount(pStr As String) As Integer
   ' Count of \S+ after trim. Blank → 0
```

**Defaults:** `IsMatch` / `ReplacePattern` / `CountMatches` / `ExtractAll` ignore-case default `True`. `ExtractAll` `pUnique` default `False`. `ReplaceFirst` `pIsRegex` default `False`.

**Ownership:** every `StringList` return above is owned by the caller (`Free`).

---

## Accents, slug, file name, HTML

```basic
Function RemoveSpecialCharacters(pStr As String) As String
   ' Keep LATIN, 0-9, _, whitespace. "A#B_C 1!" → "AB_C 1". Keeps "José".
Function RemoveAccentuation(pText As String) As String
   ' Case-preserving fold (á→a, Á→A) for a/e/i/o/u/c/n/y families including ç/ñ.
Function ConvertSpecialCharacters(pStr As String) As String
   ' RemoveAccentuation, then non (LATIN|0-9|_|\s) → space, then CollapseWhitespace.
   ' "José!" → "Jose"
Function Slugify(pStr As String) As String
   ' Accent-fold, lower, [^a-z0-9]+ → "-", trim "-". "Pão de Açúcar!" → "pao-de-acucar"
Function SanitizeFileName(pName As String) As String
   ' Replace <>:"/\|?* with "_", CollapseWhitespace, trim "." then " ".
   ' Empty result → "arquivo"
Function StripHtml(pStr As String) As String
   ' Remove <...> tags, then CollapseWhitespace
Function EscapeHtml(pStr As String) As String
   ' & → &amp; then < > " ' → &lt; &gt; &quot; &#39;
Function UnescapeHtml(pStr As String) As String
   ' Reverse of EscapeHtml (&quot; &#39; &lt; &gt; then &amp;)
```

**Sentinel:** `SanitizeFileName` empty → `"arquivo"`.

**HTML string contract (compile-safe literals):** build tags with `Chr(60)` / `Chr(62)` and entities as `"&"+"lt;"`. Example: `StripHtml(Chr(60)+"b"+Chr(62)+"Oi"+Chr(60)+"/b"+Chr(62)+" mundo")` → `"Oi mundo"`.

---

## SQL / quotes / surround / trim / pad

```basic
Function EscapeSql(pStr As String) As String
   ' ' → ''
Function QuoteSql(pStr As String) As String
   ' "'" + EscapeSql(pStr) + "'". "O'Hara" → "'O''Hara'"
Function DbQuote(pStr As String) As String
   ' Wrap with Chr(34); does not escape inner quotes
Function SgQuote(pStr As String) As String
   ' Wrap with '; does not escape inner quotes
Function Surround(pStr As String, pLeft As String, pRight As String = "") As String
   ' pRight = "" → use pLeft on both sides. Surround("a","[","]") → "[a]"

Function TrimAround(pStr As String, pValueToTrim As String = "") As String
   ' pValueToTrim = "" → native Trim(). Else strip repeated token at both ends, then Trim().
Function TrimLeading(pStr As String, pValueToTrim As String = "") As String
   ' "" → TrimLeft(); else strip repeated token at start
Function TrimTrailing(pStr As String, pValueToTrim As String = "") As String
   ' "" → TrimRight(); else strip repeated token at end

Function FillLeft(pStr As String, pValueToFill As String, pLength As Integer) As String
   ' Right(pValueToFill + pStr, pLength). One prepend, then truncate. "12"+"0000",4 → "0012"
Function FillRight(pStr As String, pValueToFill As String, pLength As Integer) As String
   ' Left(pStr + pValueToFill, pLength). One append, then truncate. "12"+"xxxx",4 → "12xx"

Function PadStart(pStr As String, pLength As Integer, pPad As String = "0") As String
   ' Repeat first char of pPad until length. If already >= pLength, return pStr (no truncate).
   ' pPad = "" → pad with space.
Function PadEnd(pStr As String, pLength As Integer, pPad As String = " ") As String
   ' Same as PadStart, on the right. Default pad " ".
Function PadCenter(pStr As String, pLength As Integer, pPad As String = " ") As String
   ' Extra pad goes to the right when odd. "A",5,"-" → "--A--"
```

**Defaults:** `PadStart` pad `"0"`; `PadEnd` / `PadCenter` pad `" "`. `Surround` `pRight` default `""` (mirror `pLeft`). Trim token default `""` (whitespace trim).

**No-op:** `Pad*` when `pStr.Length >= pLength`. `FillLeft`/`FillRight` still slice to `pLength` (may truncate).

---

## Case conversion, initials

```basic
Function Capitalize(pStr As String) As String
   ' First char upper, rest lower (Unicode). "" → "". "jOSÉ" → "José"
Function ToTitleCase(pStr As String) As String
   ' CollapseWhitespace, Capitalize each space-separated word. Does not skip particles.
Function ToPascalCase(pStr As String) As String
   ' RemoveAccentuation, split on [^A-Za-z0-9]+, Capitalize and concat. "pão-de-açúcar" → "PaoDeAcucar"
Function ToCamelCase(pStr As String) As String
   ' ToPascalCase then lower first char. "" → ""
Function ToSnakeCase(pStr As String) As String
   ' Accent-fold, insert _ before capitals, non-alnum → _, trim _, lower, collapse _.
Function ToKebabCase(pStr As String) As String
   ' ToSnakeCase with _ → -
Function Humanize(pStr As String) As String
   ' _ and - to space, split camel, ToTitleCase. "pao_de_acucar" → "Pao De Acucar"
Function Initials(pStr As String, pMax As Integer = 2) As String
   ' First letters of whitespace words, skipping particles:
   ' "da","de","do","das","dos","e","a","o","em" (Unicode-lowered).
   ' "João da Silva" → "JS". pMax default 2.
```

**Default:** `Initials` `pMax = 2`.

---

## Split, join, slice

```basic
Function SplitToList(pStr As String, pDelimiter As String, pIsRegex As Boolean = False) As StringList
   ' pStr = "" → new empty StringList. pIsRegex False → delimiter is literal (escaped).
   ' Split is case-sensitive. Caller Free.
Function Lines(pStr As String) As StringList
   ' NormalizeNewlines to LF, then split on Chr(10). Caller Free.
Function JoinList(pList As StringList, pStrToJoin As String) As String
   ' Not Assigned or Count = 0 → "". Does not Free pList.
Function JoinListWithQuote(pList As StringList, pStrToJoin As String, pQuote As String = "'") As String
   ' Same empty/Null → "". Wraps each item with pQuote. Default pQuote = "'".
   ' JoinListWithQuote(list, ",") → "'a','b','c'"

Function Before(pStr As String, pSep As String) As String
   ' First pSep. Not found → pStr.
Function After(pStr As String, pSep As String) As String
   ' After first pSep. Not found → pStr.
Function BeforeLast(pStr As String, pSep As String) As String
   ' pSep = "" or not found → pStr.
Function AfterLast(pStr As String, pSep As String) As String
   ' pSep = "" or not found → pStr.
Function Between(pStr As String, pStart As String, pEnd As String) As String
   ' pStart missing → "". pEnd missing → remainder after pStart.

Function RemovePrefix(pStr As String, pPrefix As String) As String
   ' No-op if pPrefix = "" or not StartsWith
Function RemoveSuffix(pStr As String, pSuffix As String) As String
   ' No-op if pSuffix = "" or not EndsWith
Function EnsurePrefix(pStr As String, pPrefix As String) As String
   ' No-op if pPrefix = "" or already present
Function EnsureSuffix(pStr As String, pSuffix As String) As String
   ' No-op if pSuffix = "" or already present
```

**NULL:** `JoinList` / `JoinListWithQuote` on unassigned list → `""` (not Null). `SplitToList` / `Lines` never return Null.

---

## Truncate, indent, template

```basic
Function Truncate(pStr As String, pMax As Integer, pSuffix As String = "...") As String
   ' Length <= pMax → pStr.
   ' pMax <= Len(pSuffix) → Left(pStr, pMax) (no suffix).
   ' Else Left(pMax - Len(suffix)) + suffix. "abcdefgh",5 → "ab..."
Function TruncateWords(pStr As String, pMaxWords As Integer, pSuffix As String = "...") As String
   ' pMaxWords <= 0 → "". Else first N whitespace words + suffix if truncated.
Function Indent(pStr As String, pCount As Integer = 2, pPad As String = " ") As String
   ' pad = Repeat(pPad, pCount); newlines unified to LF; pad inserted at each line start.
   ' Result stays LF (not converted back to CRLF).
Function Template(pTemplate As String, pValues As StringList) As String
   ' For each i: if Names(i) <> "" replace "{name}" with Values(name);
   ' always replace "{i}" with Strings(i).
   ' pValues not Assigned → return pTemplate unchanged.
```

**Template contract:** list entries as `Name=Value`, placeholders `{nome}` and `{0}`:

```basic
Dim vars As New StringList()
vars.Add("nome=Ana")
vars.Add("id=7")
' Template("Oi {nome} #{id}", vars) → "Oi Ana #7"
vars.Free()
```

**Defaults:** `Truncate` / `TruncateWords` suffix `"..."`. `Indent` `pCount = 2`, `pPad = " "`. `FormatJson` indent `4` (below). `maxStringLength = -1` means no string truncation.

---

## ERP conversions

```basic
Function ToBool(pValue As String) As Boolean
   ' Trim + Unicode lower. True iff "s"|"sim"|"1"|"true"|"t"|"y"|"yes"
Function BoolToSN(pValue As Boolean) As String
   ' True → "S", False → "N"
Function SNToBool(pValue As String) As Boolean
   ' Trim + Unicode upper. True iff "S" (so "s" works; "sim" does not)
Function BoolToSNO(pSelected As Boolean, pOpcional As Boolean) As String
   ' True,True → "SO" | False,True → "NO" | True,False → "S" | False,False → "N"
Function SNOToBool(pValue As String, pField As String) As Boolean
   ' pField compared Unicode-lowered:
   '   "selecionado" → True when first char of 2-char padded value is "s"
   '   "ativo"       → True when second char of 2-char padded value is "o"
   ' else False. Padding uses FillRight/FillLeft with "nn" to length 2.
Function GetNumberFromWord(pWord As Word) As String
   ' Keyboard 48..57 → Chr(code). Numpad 96..105 → digit Chr(code-48). Else "".
```

**Literal field contract for `SNOToBool`:** `"selecionado"`, `"ativo"`.  
**Literal SN/SNO alphabet:** `"S"`, `"N"`, `"SO"`, `"NO"`.  
**Literal `ToBool` truths:** `"s"`, `"sim"`, `"1"`, `"true"`, `"t"`, `"y"`, `"yes"`.

---

## UUID and JSON

```basic
Function GenerateUUID() As String
   ' Not RFC 4122. Now() formatted "dd/mm/yyyy hh:nn:ss.zzz", Data7.Criptografar,
   ' dashes inserted at 9/14/19/24, then Left(36). Length always 36 with those hyphens.

Function FormatJson(json As TJSONObject, indent As Integer = 4, maxStringLength As Integer = -1) As String
   ' Delegates to FormatJson(json.ToString(), indent, maxStringLength)
Function FormatJson(jsonString As String, indent As Integer = 4, maxStringLength As Integer = -1) As String
   ' Char scan (regex cannot tell JSON string from structure):
   ' 1. Copy quoted strings; if maxStringLength > 0 and inner length exceeds it,
   '    keep that many chars and append "...[TRUNCADO P/ VISUALIZACAO]".
   ' 2. { [ increase depth, then CRLF + spaces.
   ' 3. } ] decrease depth, CRLF + spaces (depth floor 0) + brace.
   ' 4. comma → "," + CRLF + indent; colon → ": ".
   ' 5. Outer whitespace dropped. Does not validate JSON.
```

**Sentinel:** `maxStringLength = -1` → do not truncate string values. Truncation marker literal: `...[TRUNCADO P/ VISUALIZACAO]`.

---

## Extending (Consumer Project)

There is no public class, Enun, or registration hook in `mod_strings`. Consume it as a `data7.json` dependency and call `mod_strings.<Function>`.

To add CPF/CNPJ/phone/email/URL mask or validation, put that in a **separate** consumer module. Do not add those APIs here and do not redeclare native names (`Trim`, `Split`, `IsNumeric`, `IsEmpty`, `PadLeft`, `PadRight`).

`tests.TStrTest` is the in-repo suite, not an extension point.

---

## Module Notes

- Callers own every `StringList` returned by `GetListNumbers`, `GetListStringFromPattern`, `ExtractAll`, `SplitToList`, and `Lines`. `JoinList` / `JoinListWithQuote` / `Template` do not take ownership of the input list.
- Regex engines are cached privately (`OwnsObjects`, case-sensitive keys `"/"+pattern+"/"+flags`). `SplitToList` / `Lines` / `Indent` / `ReplaceFirst` / `BeforeLast` allocate a dedicated `TRegExp` so cached `Global`/`Multiline` are not mutated.
- `ToLowerCase` / `ToUpperCase` (and all ignore-case helpers) fold Latin accents via `user32` `CharLowerBuffW` / `CharUpperBuffW`, not native `String.ToLower` / `ToUpper`.
- `FillLeft` / `FillRight` prepend or append **once** then slice to `pLength`. `PadStart` / `PadEnd` / `PadCenter` repeat a single pad character and never truncate a longer input.
- `IsNumericString` is the replacement for native `IsNumeric`: one optional sign, digits, at most one `.` or `,`. Hex and scientific notation are not numeric.
- `GenerateUUID` is a dashed `Data7.Criptografar` stamp, not RFC 4122. `FormatJson` pretty-prints; it does not parse.
- Public names that would collide with natives are `IsEmptyString`, `IsNotEmptyString`, `IsNumericString`, `TrimAround`, `TrimLeading`, `TrimTrailing`, `SplitToList`, `PadStart`, `PadEnd`.
- Canonical coverage: `tests.TStrTest.RunAll()`. On failure it throws `Exception` with the fail count after printing the summary.
