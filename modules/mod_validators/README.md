# mod_validators

Shared validation and formatting for Brazilian documents (CPF, CNPJ, CEP, CNH, RENAVAM, SUFRAMA, GTIN, vehicle plate, state IE), plus phone, email, and URL helpers. It does **not** persist data, look up CEP/CNPJ on the network, check email MX, generate check digits, or own UI/forms — the consumer decides when to call, what to store, and how to show errors. Version **1.0.0.0**. Dependencies (`data7.json`): `mod_regex` **1.0.0.0**, `mod_strings` **1.0.0.0**.

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Do not open `.bas` files to use the module.

## Quick Start (Minimal)

```basic
Imports mod_validators

' CPF: 11 digits + check digits; punctuation is stripped
If TDocs.IsValidCPF("529.982.247-25") Then
   print(TDocs.FormatCPF("52998224725"))   ' "529.982.247-25"
End If

' CNPJ: 14 chars, letters allowed in the first 12, last 2 are numeric DVs
If TDocs.IsValidCNPJ("12ABC34501DE35") Then
   print(TDocs.FormatCNPJ("12.abc.345/01de-35"))   ' "12.ABC.345/01DE-35"
End If

' Email: semicolon-separated list; blank pieces ignored; all non-blank must match
If TEmail.IsValid("a@b.com; c@d.com") Then
   print(TEmail.Format("  USER@EXAMPLE.COM  "))   ' "user@example.com"
End If

' Phone: 10–13 digits after stripping; Format fills country/DDD when the number is short
If TPhone.IsValid("(11) 98888-0000") Then
   print(TPhone.Format("987654321", "11", "55"))   ' "+55 (11) 98765-4321"
End If

' URL: TLD required; Format prepends https:// when no protocol is present
If TUrl.IsValid("example.com") Then
   print(TUrl.Format("example.com"))   ' "https://example.com"
End If
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_validators.bas` | `mod_validators` | `TText` |
| `src/lib/mod_validators_docs.bas` | `mod_validators` | `TDocs` |
| `src/lib/mod_validators_email.bas` | `mod_validators` | `TEmail` |
| `src/lib/mod_validators_phone.bas` | `mod_validators` | `TPhone` |
| `src/lib/mod_validators_url.bas` | `mod_validators` | `TUrl` |
| `src/tests/mod_validators_tests.bas` | `tests` | `TValidatorsTest` |
| `src/Principal.bas` | — | calls `tests.TValidatorsTest.RunAll()` |

Lib files share namespace `mod_validators`. There is no catalog, no `Add`/`Make`/`MakeByName`, and no UI.

---

## Text helpers — `TText`

Digit and alphanumeric cleanup plus the Mod-11 helper used by document check digits. All members are `Shared`; constructing `TText` is unnecessary.

```basic
Shared Function OnlyDigits(pValue As String) As String
   ' out: digits only (delegates to OnlyNumbers). "" → ""
Shared Function OnlyAlphaNum(pValue As String) As String
   ' out: [A-Za-z0-9] kept, then uppercased. "12.abc-01" → "12ABC01". "" → ""
Shared Function DigitAt(pDigits As String, pIndex As Integer) As Integer
   ' in: 1-based index. out: that digit as Integer
Shared Function Mod11(pBase As String, pWeights As String) As Integer
   ' in: pWeights is a digit string, one weight per 1-based position of pBase
Shared Function AllSameDigits(pValue As String) As Boolean
   ' out: True when every character equals the first (regex "^(.)\1*$")
```

| Member | Default / sentinel | Notes |
|---|---|---|
| `DigitAt` | **0** | `pIndex < 1`, `pIndex > Len(pDigits)`, or empty char → **0**. Does not throw. |
| `Mod11` | **0** | `sum Mod 11 < 2` → **0**, else `11 - rest`. Missing weight digits count as **0**. Empty `pBase` → **0**. |
| `AllSameDigits` | **True** on `""` | `"111"`, `"0"`, `""` → True. `"121"` → False. |
| `OnlyDigits` / `OnlyAlphaNum` | `""` | No match → empty string, not Null. |

No public method throws. None returns Null. `TDocs` uses `DigitAt` / `Mod11` / the same-digit rule internally.

---

## Documents — `TDocs`

Brazilian document formatters and validators. Punctuation is stripped before length/DV checks. Formatters **do not validate**: wrong length returns the **original** `pDigits`/`pValue` unchanged (not cleaned). All members are `Shared`.

### Formatters

```basic
Shared Function FormatCPF(pDigits As String) As String
   ' 11 digits → "NNN.NNN.NNN-NN"; else original
Shared Function FormatCNPJ(pDigits As String) As String
   ' 14 alphanumerics (uppercased) → "AA.AAA.AAA/AAAA-AA"; else original
Shared Function FormatCEP(pDigits As String) As String
   ' 8 digits → "NNNNN-NNN"; else original
```

| Input | Output |
|---|---|
| `FormatCPF("52998224725")` | `"529.982.247-25"` |
| `FormatCPF("123")` / `""` | original (`"123"` / `""`) |
| `FormatCNPJ("12.abc.345/01de-35")` | `"12.ABC.345/01DE-35"` |
| `FormatCEP("01310100")` | `"01310-100"` |

`FormatCPF` / `FormatCEP` keep digits only. `FormatCNPJ` keeps `[A-Za-z0-9]` and uppercases. Invalid CPFs still format (`"11111111111"` → `"111.111.111-11"`).

### Length / DV validators

```basic
Shared Function IsValidCEP(pValue As String) As Boolean
Shared Function IsValidCPF(pValue As String) As Boolean
Shared Function IsValidCNPJ(pValue As String) As Boolean
Shared Function IsValidCPFCnpj(pValue As String) As Boolean
Shared Function IsValidCNH(pValue As String) As Boolean
Shared Function IsValidRenavam(pValue As String) As Boolean
Shared Function IsValidSuframa(pValue As String) As Boolean
Shared Function IsValidGTIN(pValue As String) As Boolean
Shared Function IsValidPlaca(pValue As String) As Boolean
Shared Function IsValidIE(pValue As String, pUF As String) As Boolean
```

| Method | Accepts | Rejects | Canonical True examples |
|---|---|---|---|
| `IsValidCEP` | exactly 8 digits after `OnlyNumbers` | other lengths, no digits | `"01310-100"`, `"00000000"` (zeros are valid — length only) |
| `IsValidCPF` | 11 digits + two Mod-11 DVs | wrong length, all-same (`"11111111111"`), bad DV | `"529.982.247-25"`, `"00000000191"` |
| `IsValidCNPJ` | 14 alphanumerics, last 2 numeric DVs | wrong length, all-same, letter in DV positions, bad DV | `"11.222.333/0001-81"`, `"12ABC34501DE35"` |
| `IsValidCPFCnpj` | 11 all-digits → CPF; 14 → CNPJ | length other than 11/14; 11 chars with a letter | `"529.982.247-25"`, `"12ABC34501DE35"` |
| `IsValidCNH` | 11 digits + CNH DVs | wrong length, all-same, bad DV | `"02191549110"`, `"00000001801"` |
| `IsValidRenavam` | 9, 10, or 11 digits | 8, 12+, empty, bad DV | `"00639844960"`, `"639844960"` (padded) |
| `IsValidSuframa` | 9 digits + Mod-11 DV | other lengths, bad DV | `"100000100"` |
| `IsValidGTIN` | 8 / 12 / 13 / 14 digits + GTIN DV | other lengths, bad DV | `"12345670"`, `"7891000100103"` |
| `IsValidPlaca` | 7 alphanumerics, old or Mercosul | other length / pattern | `"ABC1234"`, `"ABC-1234"`, `"ABC1D23"` |
| `IsValidIE` | `"ISENTO"` or UF-specific digits | blank UF, length `< 8` or `> 14`, unknown UF | see IE section |

**Defaults / sentinels**

- Empty / blank document → **False** (except IE `"ISENTO"`).
- All-same digit strings are **False** for CPF, CNPJ, CNH (empty is treated as all-same internally, but those APIs already fail on length).
- Nothing returns Null. Public `TDocs` methods do not throw.

### CPF

1. `OnlyNumbers`; length must be 11.
2. Reject all-same.
3. DV1 = Mod-11 of digits 1–9 with weights 10..2; DV2 = Mod-11 of digits 1–10 with weights 11..2 (`rest < 2` → 0).

### CNPJ (numeric and alphanumeric)

1. Keep `[A-Za-z0-9]`, uppercase; length must be 14.
2. Positions 1–12: `0–9` or `A–Z`. Positions 13–14: digits only (`"12ABC34501DE3A"` is False).
3. Reject all-same (`"00000000000000"`).
4. Each body character’s weight value is `Asc(char) - 48` (`"0"`→0 … `"9"`→9, `"A"`→17, …). DVs use repeating weights 2..9 from the right.

### RENAVAM

Pad left with `"0"` to 11 digits, then DV with weights `"3298765432"` (`dv` 10 or 11 → 0). `"639844960"` and `"0639844960"` are the same number as `"00639844960"`.

### GTIN

Right-to-left over the body: factor **3** on even offset, **1** on odd. DV = `(10 - (sum Mod 10)) Mod 10`.

### Plate — `IsValidPlaca`

After alphanumeric uppercase, length must be **7**, then either:

- old: `^[A-Z]{3}[0-9]{4}$` → `"ABC1234"`, `"abc1234"`, `"ABC-1234"`
- Mercosul: `^[A-Z]{3}[0-9][A-Z][0-9]{2}$` → `"ABC1D23"`

`"ABC12D3"` is neither pattern → False.

### IE — `IsValidIE`

```basic
Shared Function IsValidIE(pValue As String, pUF As String) As Boolean
   ' pUF: two-letter UF, case-insensitive ("mg" = "MG")
```

**Resolve order**

1. `pValue.Trim()`. If it equals `"ISENTO"` ignoring case (`"isento"`, `" ISENTO "`) → **True** for any UF (including blank). No digit check.
2. `pUF` = uppercase trim. Digits = `OnlyNumbers(pValue)`.
3. Blank UF, or digit length `< 8` or `> 14` → **False**.
4. Dispatch on UF. Unknown (`"XX"`) → **False**.

| UF | Digit length | Prefix / extra | Check |
|---|---|---|---|
| AC | 13 | `"01"` | two Mod-11 DVs, weights `43298765432` then `543298765432` |
| AL | 9 | `"24"` | `(sum*10) Mod 11`, rest 10 → 0 |
| AM | 9 | `"9"` | 9-digit Mod-11, weights `98765432` |
| AP | 9 | `"03"` | `p`/`d` from body range (see below) |
| BA | 8 or 9 | first digit 6/7/9 → modulo 11, else 10 | two DVs, second then first |
| CE, ES, GO, PB, PI, SC, SE | 9 | none | 9-digit Mod-11, weights `98765432` |
| DF | 13 | none | two Mod-11 DVs (same weights as AC, no prefix) |
| MA | 9 | `"12"` | 9-digit Mod-11, weights `98765432` |
| MG | 13 | none | IE intercalary 0 + digit-sum DV, then Mod-11 (`A`=10) |
| MS | 9 | `"28"` | 9-digit Mod-11, weights `98765432` |
| MT | 11 | none | Mod-11 weights `3298765432` |
| PA | 9 | `"15"` | 9-digit Mod-11, weights `98765432` |
| PE | 9 or 14 | none | 9: two Mod-11; 14: one Mod-11 weights `5432987654321` |
| PR | 10 | none | two Mod-11, weights `32765432` then `432765432` |
| RJ | 8 | none | Mod-11 weights `2765432` |
| RN | 9 or 10 | `"20"` | `(sum*10) Mod 11`, rest 10 → 0 |
| RO | 9 or 14 | none | 9: weights `65432987`; 14: `6543298765432` |
| RR | 9 | `"24"` | `(digit * position 1..8) Mod 9` |
| RS | 10 | none | Mod-11 weights `298765432` |
| SP | 12 | none | two DVs, `(sum Mod 11) Mod 10`; weights use `A`=10 |
| TO | 11 | none | Mod-11 on chars 1–2 **plus** 5–10 (skips type digits 3–4) |

AP body `CInt(left 8)`:

- `3000001..3017000` → `p=5`, `d=0`
- `3017001..3019022` → `p=9`, `d=1`
- else → `p=0`, `d=0`

GO/ES/CE have **no** extra range tables in this module — only 9-digit Mod-11. `"ISENTO"` is the only non-numeric success path.

---

## Email — `TEmail`

Validates and normalizes email strings. `IsValid` accepts a **semicolon-separated list**. All members are `Shared`.

```basic
Shared Function IsValid(pValue As String) As Boolean
   ' blank → False; split on ";"; skip blank pieces; every remaining piece must match
Shared Function Format(pValue As String) As String
   ' blank → original (not trimmed); else Trim + lowercase. Does not validate
```

**List contract:** separator is `";"` only. `"a@b.com; c@d.com"` is True. `";user@example.com;"` is True (empty pieces ignored). `"a@b.com;invalid"` is False (one bad piece fails the whole list). `";;"` and `""` / `"   "` are False (no non-blank piece).

**Piece pattern** (case-insensitive): `^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$`

| Input | `IsValid` |
|---|---|
| `"user@example.com"`, `"USER@EXAMPLE.COM"` | True |
| `"user.name+tag@sub.example.com"`, `"a@b.co"` | True |
| `"a@b.c"` (TLD 1 letter), `"user@localhost"` (no dot) | False |

`Format("  USER@EXAMPLE.COM  ")` → `"user@example.com"`. `Format("")` and `Format("   ")` return the original. Does not throw; does not return Null.

---

## Phone — `TPhone`

Brazilian phone length check, display format, and input mask. Digits only after `OnlyNumbers`. All members are `Shared`.

```basic
Shared Function IsValid(pValue As String) As Boolean
   ' True iff digit count is 10, 11, 12, or 13
Shared Function Format(pPhone As String, DefaultDDD As String = "", DefaultCodPais As String = "") As String
   ' in: defaults are "". All three args are reduced to digits; pPhone truncated to 13
Shared Function Mask(pPhone As String) As String
   ' input-mask template, not a formatted number
```

| Digit length | `IsValid` | `Format` mask (after fill) |
|---|---|---|
| 10 or 11 | True | `"($1) $2-$3"` → `"(11) 3333-4444"` / `"(11) 98765-4321"` |
| 12 or 13 | True | `"+$1 ($2) $3-$4"` |
| 8 or 9 after fill failure | — | `"$1-$2"` |
| other | False | digit string unchanged if the chosen regex does not match |

**`Format` fill order** (after `OnlyNumbers` + `Left(13)`):

1. Length 10 or 11 → prepend `DefaultCodPais.Left(2)`.
2. Length 8 or 9 → prepend `DefaultCodPais.Left(2)` + `DefaultDDD.Left(2)`.
3. Pick mask from the table above. If the number does not match the regex, return the digit string (no mask).

`Format("987654321", "11", "55")` → `"+55 (11) 98765-4321"`. Empty defaults on an 11-digit number stay local: `Format("11987654321")` → `"(11) 98765-4321"`.

**`Mask`**

- digit length **< 11** (including `""`) → `"(99) 9999-9999"`
- digit length **≥ 11** → `"(99) 99999-9999"`

No throw, no Null. `IsValid("123")` / `IsValid("")` → False.

---

## URL — `TUrl`

Site-shaped URL check vs absolute http(s) check, plus `https://` fill. All members are `Shared`.

```basic
Shared Function IsValid(pValue As String) As Boolean
   ' trim; blank → False; dotted host + TLD of 2+ letters; protocol optional
Shared Function IsValidHttp(pValue As String) As Boolean
   ' trim; blank → False; must start with http:// or https://
Shared Function Format(pValue As String) As String
   ' blank → original (untrimmed); if already http(s):// return trimmed; else prepend "https://"
```

**`IsValid` pattern** (case-insensitive):

`^(HTTPS?://)?([A-Z0-9-]+\.)+[A-Z]{2,}(/[A-Z0-9._~:/?#@!$&''()*+,;=-]*)?$`

**`IsValidHttp` pattern** (case-insensitive):

`^https?://[^\s<>"']+$`

| Input | `IsValid` | `IsValidHttp` | `Format` |
|---|---|---|---|
| `"https://example.com"` | True | True | unchanged (trimmed) |
| `"example.com"` | True | False | `"https://example.com"` |
| `"HTTP://EXAMPLE.COM"` | True | True | `"HTTP://EXAMPLE.COM"` |
| `"http://localhost"` | False (no TLD) | True | `"http://localhost"` |
| `"example.c"` | False | False | `"https://example.c"` |
| `""` / `"   "` | False | False | original |

`Format` does not validate. `IsValid` and `IsValidHttp` are different predicates — do not substitute one for the other. No throw, no Null.

---

## Extending (Consumer Project)

This core has **no UI** and **no type catalog**. There are no overridable hooks and no `Register`/`Add`/`Make` entry points. After `Imports mod_validators`, call the `Shared` functions on `TText`, `TDocs`, `TEmail`, `TPhone`, and `TUrl`.

To add a consumer-only document or extra rule, declare a new class in the consumer project (optionally inheriting `TDocs` / `TEmail` / …) and put new `Shared` functions there. This module never discovers subclasses. Do not expect instance state: public behavior is entirely in `Shared` methods.

---

## Module Notes

- Every public API method is `Shared`. `New`/`Free` on these classes have no extra semantics; do not allocate them for normal use.
- Formatters never validate and never throw: wrong length returns the **original** string; blank email/URL `Format` also returns the original (spaces preserved).
- `TEmail.IsValid` splits only on `";"`; empty pieces are ignored; the list is False if every piece is empty or any non-blank piece fails the regex.
- `TPhone.Format` truncates to 13 digits and uses `DefaultDDD` / `DefaultCodPais` only when the remaining length is 8–11. `Mask` returns a template (`"(99) …"`), not a formatted value.
- `IsValidCEP` is length-only (8 digits), including `"00000000"`. CPF/CNPJ/CNH reject all-same strings. CNPJ allows `A–Z` in the first 12 positions; DVs must be digits.
- `IsValidIE`: trimmed `"ISENTO"` (any case) is True without looking at `pUF`. Otherwise only digits are scored, length must be 8–14, and unknown UFs are False.
- `IsValidRenavam` left-pads with `"0"` to 11 digits. `TUrl.IsValid` requires a dotted TLD; `TUrl.IsValidHttp` only requires `http://` or `https://` plus no whitespace/`<>"'`.
- Public validators return `Boolean` or `String` only — never Null. Failures are False / original string. The suite `tests.TValidatorsTest.RunAll()` covers `TText` (`OnlyDigits`, `OnlyAlphaNum`, `DigitAt`, `AllSameDigits`), every public `TDocs` formatter/validator (all UFs for IE, including `"ISENTO"`), `TEmail`, `TPhone`, and `TUrl`. `TText.Mod11` is exercised via IE/CNPJ paths, not as its own case. On failure the suite throws `Exception` with the fail count.
