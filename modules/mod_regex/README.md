# mod_regex

Typed wrapper around COM `VBScript.RegExp` (`IRegExp2` / `IMatchCollection2` / `IMatch2` / `ISubMatches`). It compiles a pattern, tests/extracts/replaces/splits strings, and returns owned match objects with 0-based indexes and capturing groups. It does **not** parse files, validate input, apply masks, or own the `StringList` results of `Values` / `UniqueValues` / `Split` — that is the consumer. Version **1.0.0.0** (`data7.json`). Runtime dependency: COM `VBScript.RegExp`. `data7.json` `dependencies` is empty; `StringList` comes from `Collections`.

This file is the module contract. Do not open `.bas` files to use the API.

## Quick Start (Minimal)

```bas
Imports Collections
Imports mod_regex

Using rx As New TRegExp("(\d{4})-(\d{2})-(\d{2})", True, True, False)
   ' Pattern with 3 groups; IgnoreCase=True; IsGlobal=True; Multiline=False
   Dim ok As Boolean = rx.Test("data 2026-09-08")
   Dim first As TRegExpMatch = rx.Match("data 2026-09-08")
   ' first.Success, .Value="2026-09-08", .Group(1)="2026"
   first.Free()

   Dim all As TRegExpMatchList = rx.Execute("2026-09-08 e 2025-01-01")
   ' all.Count=2; all.Item(0).Value / all.Item(1).Value
   all.Free()

   Dim swapped As String = rx.Replace("2026-09-08", "$3/$2/$1")
   ' swapped = "08/09/2026"
End Using

Dim hasDigit As Boolean = TRegExp.IsMatch("pedido-42", "\d+")
Dim literal As String = TRegExp.Escape("a+b")
' literal = "a\+b" — safe to use as Pattern
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_regex.bas` | `mod_regex` | `TRegExpMatch`, `TRegExpMatchList`, `TRegExp` |
| `src/tests/mod_regex_tests.bas` | `tests` | `TRegExpTest` |
| `src/Principal.bas` | *(none)* | calls `TRegExpTest.RunAll()` |

## Engine

`TRegExp` is the reusable COM engine. Pattern dialect is **VBScript.RegExp** (ECMA-262 / JavaScript), not PCRE or .NET. Flags map to COM `IgnoreCase`, `Global` (exposed as `IsGlobal`), and `Multiline`. Instances do not share state.

### `TRegExp`

One COM `VBScript.RegExp` per instance. Caller owns the object (`Using` or `Free`).

```bas
Sub New(pPattern As String = "", pIgnoreCase As Boolean = True, pGlobal As Boolean = True, pMultiline As Boolean = False)
   ' empty Pattern is legal; flags applied before Pattern
End Sub

Shared Function Compile(pPattern As String, pIgnoreCase As Boolean = True, pGlobal As Boolean = True, pMultiline As Boolean = False) As TRegExp
   ' same as New; caller owns the returned instance
End Function

Shared Function Escape(pText As String) As String
   ' prefix \ before each of: \ ^ $ . | ? * + ( ) [ ] { }
End Function

Shared Function IsMatch(pText As String, pPattern As String, pIgnoreCase As Boolean = True) As Boolean
   ' one-shot Test; internal engine uses IsGlobal=False, Multiline=False, then Free
End Function

Function Test(pText As String) As Boolean
   ' True if Pattern matches anywhere in pText
End Function

Function Execute(pText As String) As TRegExpMatchList
   ' all matches when IsGlobal=True; first only when False; caller owns the list
End Function

Function Match(pText As String) As TRegExpMatch
   ' first match, or a miss object (Success=False); never NULL; caller owns the result
End Function

Function Replace(pText As String, pReplacement As String) As String
   ' COM Replace; $1 $2 … = groups, $& = whole match
End Function

Function Values(pText As String) As StringList
   ' Execute then match .Value of each item, including duplicates; caller owns the list
End Function

Function UniqueValues(pText As String) As StringList
   ' same as Values, first occurrence kept (IndexOf); caller owns the list
End Function

Function Split(pText As String) As StringList
   ' see Split flow below; caller owns the list
End Function

Function Clone() As TRegExp
   ' independent engine with the same Pattern / IgnoreCase / IsGlobal / Multiline
End Function
```

| Property | Type | Get/Set | Default | Notes |
|---|---|---|---|---|
| `Pattern` | `String` | both | `""` | COM pattern string, e.g. `"\d+"`, `"(\d{4})-(\d{2})-(\d{2})"`, `"foo(?=bar)"` |
| `IgnoreCase` | `Boolean` | both | `True` | COM `IgnoreCase` |
| `IsGlobal` | `Boolean` | both | `True` | COM `Global`; `True` = all matches / all replacements |
| `Multiline` | `Boolean` | both | `False` | `True` makes `^` / `$` match line boundaries (`Chr(10)`) |
| `Disposed` | `Boolean` | get | `False` | `True` after `Dispose` / `Free` |

**Sentinels / defaults**

- `New TRegExp()` → `Pattern=""`, `IgnoreCase=True`, `IsGlobal=True`, `Multiline=False`, `Disposed=False`.
- `ToString` → `"/<Pattern>/<flags>"` with flags `i` / `g` / `m` in that order when set, e.g. `"/[a-z]+/ig"`.
- `Replace` with no match returns `pText` unchanged.

**Throws**

- Any use of `Pattern` / flags / `Test` / `Execute` / `Replace` / `Split` / `Clone` / `ToString` after `Dispose`: `Exception` `"TRegExp já foi liberado."`
- Invalid pattern (e.g. `Pattern = "[invalid"`) throws from COM on **use** (`Test`, `Execute`, …), not necessarily on the assignment.
- `Split`: if `Execute` throws, `IsGlobal` is restored, then the exception is rethrown.

**NULL / no-op**

- Never returns `NULL` for matches; a miss is `TRegExpMatch` with `Success=False`.
- `Dispose` when already disposed is a no-op (`Disposed` stays `True`).
- `Split` with `Pattern=""` does not run the engine: returns a one-item `StringList` containing `pText`.

**`Free` / `Dispose`**

- `Dispose` releases the COM engine (`Unassigned`) and sets `Disposed=True`.
- `Free` calls `Dispose` then the base destructor.

### Split flow

1. If `Pattern = ""`, return `[pText]`.
2. Remember `IsGlobal`, force `IsGlobal=True` for the duration of `Execute`.
3. For each match, append the slice `[lastPos, FirstIndex)`. If that length is `0` (delimiter at that position), append `""`.
4. Append the tail after the last match; if the last match reaches `pText.Length`, append `""`.
5. Restore the previous `IsGlobal`.

Examples: `","` on `"a,b,c"` → `a` `b` `c`; `","` on `",a"` → `""` `a`; `"\s+"` on `"um  dois   tres"` → `um` `dois` `tres`.

### Execute / Match / IsGlobal

- `Execute` forwards to COM `Execute`. `IsGlobal=True` yields every match; `False` yields at most one.
- `Match` always clones `Execute` item `0`, or a default miss object if `Count=0`. The temporary list is freed inside `Match`.
- `IsMatch` is a shared `Test` with `IsGlobal=False` and `Multiline=False`.

## Matches

### `TRegExpMatch`

One match (or a miss sentinel). Produced by `TRegExp.Match` / `TRegExp.Execute`. `Group` is 1-based for captures; `0` is the whole match.

```bas
Sub New()
   ' miss sentinel: Success=False
End Sub

Sub New(pComMatch As Variant)
   ' wrap COM IMatch2; Success=True; used internally by Execute
End Sub

Function Group(pIndex As Integer) As String
   ' 0 = Value; 1..GroupCount = SubMatches(pIndex-1); else ""
End Function

Function Clone() As TRegExpMatch
   ' independent copy of Success, Value, FirstIndex, Length, and SubMatches strings
End Function
```

| Property | Type | Get/Set | Default (miss) | Notes |
|---|---|---|---|---|
| `Success` | `Boolean` | get | `False` | `True` only when loaded from a COM match |
| `Value` | `String` | get | `""` | whole match text |
| `FirstIndex` | `Integer` | get | `0` | **0-based** start in the source string |
| `Length` | `Integer` | get | `0` | character length of `Value` |
| `SubMatches` | `StringList` | get | empty | capturing groups only (not group 0); owned by this match |
| `GroupCount` | `Integer` | get | `0` | `SubMatches.Count` |

**Sentinels**

- Miss: `Success=False`, `Value=""`, `FirstIndex=0`, `Length=0`, `GroupCount=0`, `Group(n)=""`, `ToString="(sem match)"`.
- Hit `ToString`: `"<Value> @ <FirstIndex>"`, e.g. `"123 @ 6"`.
- `Group(0)` = `Value`. Example `"(\d{4})-(\d{2})-(\d{2})"` on `"data 2026-09-08 fim"`: `Group(1)="2026"`, `Group(2)="09"`, `Group(3)="08"`, `Group(9)=""`.
- `SubMatches.Strings(0)` is group 1.

**NULL / no-op**

- Constructors never return `NULL`.
- Out-of-range `Group` returns `""` (no throw).

**`Free`**

- Frees the owned `SubMatches` `StringList`. Do not keep that list after `Free`.

### `TRegExpMatchList`

Ordered list of `TRegExpMatch`. `Execute` returns a new list; the list **owns** its matches (`OwnsObjects=True`).

```bas
Sub New()
   ' empty list; owns added TRegExpMatch objects
End Sub

Sub Add(pMatch As TRegExpMatch)
   ' stores pMatch keyed by pMatch.Value; list takes ownership
End Sub

Function Values() As StringList
   ' new list of .Value in order, duplicates kept; caller owns the result
End Function

Function UniqueValues() As StringList
   ' new list, first occurrence of each .Value kept; caller owns the result
End Function
```

| Property | Type | Get/Set | Default | Notes |
|---|---|---|---|---|
| `Count` | `Integer` | get | `0` | number of matches |
| `Item(pIndex)` | `TRegExpMatch` | get | — | 0-based; no extra bounds check in this module |

**Sentinels**

- No matches / empty input: `Count=0` (not `NULL`).
- `ToString`: comma-space joined values, e.g. `"10, 20, 10"`. Empty list → `""`.
- `UniqueValues` on `"a10 b20 c10"` with `"\d+"` → `"10"`, `"20"`.

**`Free`**

- Frees the inner list and therefore every owned `TRegExpMatch`. `Values` / `UniqueValues` results stay with the caller.

## Extending (Consumer Project)

This module has no UI, no type catalog, and no overridable hooks. Consume it with `Imports mod_regex` and `New TRegExp` / `TRegExp.Compile`.

To add domain helpers, wrap `TRegExp` in the consumer (do not import `tests`). Patterns already exercised by the suite:

```bas
' digits only: Pattern "\D", Replace with ""
' number list: Pattern "\d+", Values(text)          → e.g. "nfe 123 item 45 item 123" → 123,45,123
' unique hits: Pattern "\d+", UniqueValues(text)    → same input → 123,45
' strip punctuation: Pattern "[^\w\s]", Replace ""  → "A#B_C 1!" → "AB_C 1"
```

Phone-mask recipe (tests only): digits via `"\D"`; then `"(\d{2})(\d{2})(\d{4,5})(\d{4})"` → `"+$1 ($2) $3-$4"`, or `"(\d{2})(\d{4,5})(\d{4})"` → `"($1) $2-$3"`, or `"(\d{4,5})(\d{4})"` → `"$1-$2"`. Examples: `"11987654321"` → `"(11) 98765-4321"`; `"1133334444"` → `"(11) 3333-4444"`; `"987654321"` with DDD `"11"` and country `"55"` → `"+55 (11) 98765-4321"`.

## Tests

Entrypoint: `TRegExpTest.RunAll()` (`src/Principal.bas`). Covers defaults and flag round-trips, `Test` / `IsMatch`, `Execute` / `Match` hit and miss, `FirstIndex` / `Length`, capturing groups, pattern backref `(.)\1`, lookahead `foo(?=bar)` / `foo(?!bar)`, `Replace` literals and `$1`/`$&`, `Values` / `UniqueValues`, `Split` (including empty `Pattern` and leading delimiter), `Escape`, empty input, invalid pattern, instance isolation, `Clone`, `Compile`, Pattern reuse, `Dispose` (use-after-dispose throws; second `Dispose` is idempotent), and the recipes above.

## Module Notes

- Pattern language is COM `VBScript.RegExp` (lookahead and `$n` / `$&` replacement work; PCRE features are out of scope).
- `TRegExpMatchList` owns its `TRegExpMatch` objects; `TRegExpMatch` owns `SubMatches`; `TRegExp.Values` / `UniqueValues` / `Split` and `TRegExpMatchList.Values` / `UniqueValues` return **new** `StringList` instances the caller must `Free`.
- `Match` never returns `NULL`; a miss is `Success=False`, `Value=""`, `FirstIndex=0`.
- `FirstIndex` is 0-based; `Group(0)` is the whole match; `Group` out of range is `""`.
- `IsGlobal` defaults to `True` (all matches / all replacements). `TRegExp.IsMatch` forces `IsGlobal=False`. `Split` temporarily forces `IsGlobal=True` and restores it, including on exception.
- `UniqueValues` uniqueness is `StringList.IndexOf` (first win, case-sensitive as stored).
- After `Dispose`, the instance is dead (`Disposed=True`); a second `Dispose` does nothing. `Free` always `Dispose`s first.
- Engines are isolated: changing `Pattern` on one `TRegExp` does not affect another; `Clone` is a separate COM instance.
