# mod_share_contract

Opens the native Windows Share UI over a consumer form `HWND`, with optional title, message text, and file paths. It does **not** pick the share target, send the payload, or own the calling form — that stays with the consumer. Version `1.0.0.0`. Depends on `mod_portable_exe` `1.0.0.0` and `mod_winapi` `1.0.0.0` (`data7.json`).

This file is the module contract. Use `TShareContract` from here; do not open `.bas` files to consume the API.

## Quick Start (Minimal)

```basic
Imports Forms
Imports mod_share_contract

Dim share As New TShareContract()
share.Title = "Boleto e NF-e"   ' share sheet title (optional; default already set)
share.Text = "Olá, segue em anexo a nota fiscal e o boleto referente ao mês atual."  ' message / description
share.Files.Add("C:\temp\boleto_123.pdf")  ' absolute path; repeat Add for more files
share.Files.Add("C:\temp\nfe_123.xml")

Dim _form As New Forms.Form()
' ... show the form that owns the share ...

share.Share(_form.Handle)  ' blocks until the share UI closes; HWND is required
share.Free()
```

## Namespace Map

| File | Namespace | Types |
|------|-----------|--------|
| `src/mod_share_contract.bas` | `mod_share_contract` | `TShareContract` |
| `src/Principal.bas` | *(none — demo entrypoint)* | — |

## Share session

### `TShareContract`

Opens Windows Share for the current process over a parent window handle. Inherits `TPortableExe` (`mod_portable_exe`) to extract and run the embedded helper `mod_share_contract_winrt.exe`.

```basic
Sub New()
   ' 1. ExeFileName = "mod_share_contract_winrt.exe"
   ' 2. Title = "Compartilhamento do ERP"
   ' 3. Text = ""
   ' 4. Files = New StringList()
End Sub
```

| Member | Type | In / out |
|--------|------|----------|
| `Title` | `String` | Share sheet title. Default `"Compartilhamento do ERP"`. `Trim` empty → omitted from the helper. |
| `Text` | `String` | Message body. Default `""`. `Trim` empty → omitted. With files, used as description (not as standalone text). |
| `Files` | `StringList` | Absolute file paths. Default a new empty list. `Trim` empty entries are skipped. Example: `"C:\temp\boleto_123.pdf"`. |

```basic
Function IsSupported() As Boolean
   ' out: True on Windows 10 or Windows 11 (WinAPI.OS.IsWindows10 Or IsWindows11)

Sub Share(pParentHandle As Integer)
   ' in: parent form HWND (e.g. _form.Handle). 0 is rejected.
   ' 1. If not IsSupported → Throw
   ' 2. If pParentHandle = 0 → print requirement, Exit Sub
   ' 3. EnsureExe (extract helper beside the host exe if missing)
   ' 4. Start helper: -hwnd <handle> [-title "..."] [-text "..."] [-file "..."]*
   ' 5. While IsRunning: Sleep(2); Forms.ProcessMessages
   ' 6. StopProcess("")

Sub Free()
   ' Frees Files when Assigned, then the portable-exe base
```

**Throws:** `Share` throws `Exception` `"Esse recurso só está disponível no Windows 10/11, processo abortado."` when `IsSupported` is `False`.

**No-op:** `Share` with `pParentHandle = 0` prints `"TShareContract.Share requer o handle da janela pai."` and returns without starting the helper.

**Blocking:** `Share` does not return until the helper process exits (share canceled, share completed, UI failed to appear within ~12s, or ~180s safety timeout). The calling form keeps pumping messages during the wait.

**Payload rules (helper):** at least one non-empty `Text` or `Files` entry should be set, or the helper exits immediately. File extensions (e.g. `.pdf`, `.xml`) are advertised so file targets such as WhatsApp can appear. When `Files` is non-empty, `Text` is description only — it is not also published as `SetText`.

## Extending (Consumer Project)

Inherit `TShareContract` if the consumer needs extra fields or a wrapper around `Share`. This module has no UI types and no catalog/`MakeByName` registration.

`EnsureExe` is overridable on the `TPortableExe` base (extracts `mod_share_contract_winrt.exe` next to the host executable when `InstallFolder` is left empty). Override only if the consumer must change where the helper is materialized.

## Tests / demo

`src/Principal.bas` is the interactive entrypoint: a form with one button that calls `TShareContract.Share` with sample title, text, and PDF paths. There is no `RunAll` test type.

## Module Notes

- `Files` is owned by `TShareContract`; `Free` releases that list. Do not `Free` the list separately while the instance still owns it.
- `Share` is synchronous and pumps `Forms.ProcessMessages` so the parent window stays painted while the share sheet is open.
- `pParentHandle = 0` never launches the helper; unsupported OS throws instead of opening UI.
- Blank `Title` / `Text` / file paths (after `Trim`) are dropped from the command line; they are not sent as empty quotes.
- The helper is embedded as base64 and written as `mod_share_contract_winrt.exe` beside the host exe on first `EnsureExe` (typical path: `Share` → `EnsureExe`).
- File share advertises lowercase extensions from the paths (`C:\temp\nfe_123.xml` → `.xml`). Text-only share publishes `Text` as share text.
- `StopProcess("")` after the wait does not write an `exit` line to the helper stdin; the process is expected to have already quit with the share UI.
- Rebuild of `lib/share_winrt.cpp` is a maintainer step (`lib/readme.txt`); consumers only set `Title` / `Text` / `Files` and call `Share`.
