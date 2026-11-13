# mod_certificate

Windows client-certificate wrapper around `certutil.exe`. It reads PFX/CER dumps, imports and deletes certificates in CurrentUser/LocalMachine stores, builds WinHTTP locators (`CURRENT_USER\MY\{CN}`), and filters store contents by validity, private key, and text.

This module does **not** send HTTP, does **not** pick a client certificate inside WinHTTP, and does **not** manage Active Directory Certificate Services (backup, revoke, enrollment). The consumer owns mTLS, passwords, and whether a PFX stays in the store after use.

Version `1.0.0.0`. Depends on `mod_portable_exe` `1.0.0.0` (`data7.json`).

This file is the module contract. Consume the API from here. Do not open `.bas` files unless a detail is missing from this document.

## Quick Start (Minimal)

```bas
Imports mod_cert_enums
Imports mod_certificate
Imports mod_certificates
Imports mod_certificate_store

' List CurrentUser\My (Personal) and take the first cert.
Dim store As TCertificateStore = TCertificateStore.Personal()
Dim certs As TCertificates = store.List()
If certs.Length > 0 Then
   Dim cert As TCertificate = certs.Take(0)
   ' Locator is the WinHTTP SetClientCertificate string.
   print(cert.Locator)
End If

' Load a PFX, install into CurrentUser\My, then remove on Free (CleanOnFree defaults True).
Dim pfx As New TCertificate()
pfx.Load("C:\certs\client.pfx", "secret")
pfx.Install()
print(pfx.Locator)
pfx.Free()

certs.Free()
store.Free()
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_cert_enums.bas` | `mod_cert_enums` | `TCertLocation`, `TCertStoreName` |
| `src/lib/mod_cert_dump.bas` | `mod_cert_dump` | `TCertDump` |
| `src/lib/mod_certutil.bas` | `mod_certutil` | `TCertUtil` |
| `src/lib/mod_certificate.bas` | `mod_certificate` | `TCertificate` |
| `src/lib/mod_certificates.bas` | `mod_certificates` | `TCertificates` |
| `src/lib/mod_certificate_store.bas` | `mod_certificate_store` | `TCertificateStore` |

`src/Principal.bas` is the project smoke test (store enum + `My`/`Root` list + `FindByName`). There is no `RunAll` test type.

---

## Locations and store names

### `TCertLocation`

Windows certificate hive used on the `certutil` command line and in locators.

```bas
Enun TCertLocation
   CurrentUser = "CURRENT_USER"       ' Prefixes certutil with -user
   LocalMachine = "LOCAL_MACHINE"     ' No extra flag
   Enterprise = "ENTERPRISE"          ' -enterprise
   GroupPolicy = "GROUP_POLICY"       ' -grouppolicy
End Enun
```

`LocationFlag` also accepts the aliases `USER`, `GP`, and `SERVICE` (`-service`) after stripping underscores. Anything else (including `LOCAL_MACHINE`) yields `""`.

### `TCertStoreName`

Physical store name passed to `-store` / `-importpfx` / `-delstore`. Locator path uses the **uppercase** form (`MY`, `ROOT`).

```bas
Enun TCertStoreName
   My = "My"
   Root = "Root"
   CA = "CA"
   TrustedPeople = "TrustedPeople"
   TrustedPublisher = "TrustedPublisher"
   AuthRoot = "AuthRoot"
   Disallowed = "Disallowed"
   AddressBook = "AddressBook"
End Enun
```

Always pass `.AsString` into a `certutil` argument. Concatenating the enum object is not a store name.

---

## Dump parser

### `TCertDump`

Stateless helpers over `certutil -dump` / `-store` text (`StringList` of non-empty lines). All members below are `Shared`. Instantiating the class is unnecessary.

```bas
Function IsCertHeader(pLine As String) As Boolean
   ' True if line contains "================ Certificado " or "================ Certificate "

Function IsMissingPrivateKeyLine(pLine As String) As Boolean
   ' True for PT "chave privada"+"decod" or EN "private key"+("decrypt"|"cannot find")

Function IsDumpFieldLine(pLine As String) As Boolean
   ' True if "Field Name: value" (name has no "=" / ",", length < 40)

Function DumpField(pLines As StringList, pKey As String) As String
   ' First line whose field name equals pKey (case-insensitive). "" if missing.

Function FirstDumpField(pLines As StringList, pKey1 As String, pKey2 As String = "") As String
   ' DumpField(pKey1), else DumpField(pKey2). "" if both missing.

Function BlockContains(pLines As StringList, pText As String) As Boolean
Function BlockMissingPrivateKey(pLines As StringList) As Boolean

Function ExtractCN(pSubject As String) As String
   ' Value after CN= up to the next comma. Whole string if no CN=.

Function ParseDumpDate(pValue As String) As TDateTime
   ' Tries pValue & ":00" then pValue. Empty / unparseable -> 0.

Function NormalizeHash(pValue As String) As String
   ' Uppercase leading hex; skips space, ":", "-"; stops at first other char.

Function ExtractLeafCert(pLines As StringList) As StringList
   ' Caller owns the returned list.
```

**Defaults / sentinels:** missing field `""`; missing date `0`.

**Throws:** none.

**Continuation rule (DumpField):** after the `Key: value` line, extra lines are appended only when they look like a DN fragment (`=` present) and are not a new field / cert header. Bare certutil messages (`Nenhuma informação de provedor de chave`) are not joined — that keeps SHA1 hashes at 40 hex chars.

**Leaf selection (`ExtractLeafCert`):**

1. Walk `================ Certificado N ================` blocks.
2. Prefer the last block that does **not** contain a missing-private-key line (the PFX end-entity).
3. Else the last block.
4. If there is no header, return a copy of all lines.

---

## certutil runner

### `TCertUtil`

Process wrapper for `%SystemRoot%\System32\certutil.exe`. Use `TCertUtil.Instance()` (process-wide singleton). Do not `Free` the singleton from consumer code.

```bas
Shared Function Instance() As TCertUtil
   ' Creates the singleton on first call.

Function LocationFlag(pLocation As TCertLocation) As String
   ' "-user" | "-enterprise" | "-grouppolicy" | "-service" | ""

Function Prefix(pLocation As TCertLocation, pArgs As String) As String
   ' LocationFlag + " " + pArgs, or just trimmed pArgs when the flag is empty.

Function Exec(pArgs As String) As StringList
   ' certutil pArgs, stdout+stderr lines (blank lines dropped). Caller owns the list.

Function ExecCode(pArgs As String) As Integer
   ' Raw process exit code.

Function ExecChecked(pArgs As String, pError As String) As Integer
   ' Throws pError when exit code <> 0.

Function Help(pVerb As String = "") As StringList
   ' "" -> "-?". Otherwise "-{verb} -?" (adds "-" if missing).

Function HashFile(pPath As String, pAlg As String = "SHA1") As String
   ' First non-title hex line of -hashfile. "" if none.

Function DumpFile(pPath As String, pPass As String = "") As StringList
   ' "-p {pass} -dump {file}" when pass is non-empty, else "-dump {file}".

Function Encode(pInFile As String, pOutFile As String) As Integer
Function Decode(pInFile As String, pOutFile As String) As Integer
Function MergePfx(pInFiles As String, pOutFile As String, pPass As String) As Integer
   ' -MergePFX. pInFiles is the certutil comma-separated PFX list.
```

**Overridable hook:** `EnsureExe` — resolves `certutil.exe` under `%SystemRoot%\System32` and assigns `ExePath`.

**Throws:**

| Call | When |
|---|---|
| `EnsureExe` / first exec | `certutil.exe not found: {path}` |
| `HashFile` / `DumpFile` | `Arquivo nao encontrado: {path}` |
| `ExecChecked` / `Encode` / `Decode` / `MergePfx` | module message when exit code `<> 0` |

**No-op / empty:** `HashFile` returns `""` if certutil printed no hex line. `LocationFlag(LocalMachine)` is `""`.

**Escape hatch:** any verb, e.g. `TCertUtil.Instance().Exec("-user -store My")`.

---

## Certificate entity

### `TCertificate`

One certificate (from a PFX/CER file or from a store dump). Locator format: `{TCertLocation.AsString}\{UCase(store)}\{CN or thumbprint}`, e.g. `CURRENT_USER\MY\FINGER & CIA LTDA:03096070000183`.

#### Fields the consumer sets

| Member | Type | Default | Notes |
|---|---|---|---|
| `Use` | `Boolean` | `True` | Copied by `Assign`. Not used by install/list. |
| `CleanOnFree` | `Boolean` | `True` | If `True` and `Installed`, `Free`/`Dispose` runs `Clean` (deletes from the store). |
| `Locator` | `String` | `""` | Rebuilt when `Location`/`Store`/`Load`/`ApplyDump`/`Install` change identity fields. |
| `Location` | `TCertLocation` | `CurrentUser` | |
| `Store` | `TCertStoreName` | `My` | |

#### Fields the module fills

| Member | Type | Default | Notes |
|---|---|---|---|
| `Path` | `String` | `""` | Get-only. PFX/CER path from `Load`. |
| `Pass` | `String` | `""` | Get-only. Password from `Load`. |
| `Name` | `String` | `""` | CN from `Requerente`/`Subject`. |
| `Serie` | `String` | `""` | Serial as dumped. |
| `Thumbprint` | `String` | `""` | SHA1 hex, uppercase, no separators. |
| `DateStart` / `DateEnd` | `TDateTime` | `0` | Missing/unparsed. |
| `Installed` | `Boolean` | `False` | Set by `Install` / `MarkInstalled`. |
| `Cleaned` | `Boolean` | `False` | Set by `Clean` when it skips or succeeds. |
| `Subject` / `Issuer` | `String` | `""` | Full DN. |
| `IssuerName` | `String` | `""` | CN of issuer. |
| `FriendlyName` | `String` | `""` | `Nome amigável` / `Friendly Name`. |
| `HasPrivateKey` | `Boolean` | `False` | Inverse of missing-private-key dump line. |
| `IsRoot` | `Boolean` | `False` | Dump contains `Certificado raiz` or `Root Certificate`. |
| `IsExpired` | `Boolean` | `False` if `DateEnd = 0` | `DateEnd < DateTime()`. |
| `IsNotYetValid` | `Boolean` | `False` if `DateStart = 0` | `DateStart > DateTime()`. |
| `IsValid` | `Boolean` | `False` if `DateEnd = 0` | not expired, not not-yet-valid, and `DateEnd <> 0`. |

```bas
Sub New()
Sub New(pPath As String, pPass As String)          ' Calls Load.

Function Load(pPath As String, pPass As String = "") As TCertificate
   ' Resets fields, dumps the file, parses the leaf, builds Locator. Returns me.

Function Install(pModifiers As String = "") As TCertificate
   ' -f -p {pass} -importpfx {store} {path} [{modifiers}]. No-op if already Installed.

Sub ApplyDump(pLines As StringList)
   ' Fill identity fields from one certutil cert block.

Shared Function NormalizeHash(pValue As String) As String
   ' Delegates to TCertDump.NormalizeHash.

Sub MarkInstalled()                                 ' Installed=True, Cleaned=False. Does not call certutil.

Function DaysToExpire() As Integer
   ' 0 if DateEnd=0. Negative when already expired.

Function Matches(pQuery As String) As Boolean
   ' Case-insensitive substring on Name, Thumbprint, Serie, Subject, Issuer, FriendlyName, Locator.
   ' Trim(pQuery)="" -> True.

Sub Clean()                                         ' -delstore {store} {thumbprint}. Alias: Delete.
Function Delete()                                   ' Same as Clean.

Function ExportPfx(pOutFile As String, pPass As String, pModifiers As String = "NoRoot") As TCertificate
Function Save(pOutFile As String) As TCertificate   ' Writes a .cer via -store {store} {thumbprint} {file}.
Function Verify() As StringList                     ' -verify {Path} if the file exists, else -verifystore.
Function Dump() As StringList                       ' DumpFile(Path) if the file exists, else -store lookup.

Function Copy() As TCertificate                     ' Assign + CleanOnFree=False. Caller owns the clone.
Function Clone() As TCertificate                    ' Same as Copy.
Sub Assign(pSource As TCertificate)                 ' No-op if pSource is not assigned. Does not copy CleanOnFree.

Function WinHttpLocators() As StringList
   ' Unique candidates: Locator, Name, {loc}\{STORE}\{Name}, Thumbprint, {loc}\{STORE}\{Thumbprint}.
```

**`GetID` (list key):** thumbprint if set, else `Name`, else the base id. `TCertificates` indexes by this.

**`Dispose`:** if `CleanOnFree` then `Clean`. Store-listed certs must keep `CleanOnFree = False` or `Free` will delete them from Windows.

**Throws:**

| Call | Message |
|---|---|
| `Load` | `O path do certificado informado e invalido.` |
| `Load` (parse) | `Erro ao ler certificado: {inner}` |
| `Load` (empty identity) | `Nao foi possivel ler o certificado digital.` |
| `Install` | `Nenhum arquivo PFX carregado para instalar.` |
| `Install` (certutil) | `Nao foi possivel importar o certificado no store do Windows.` |
| `Clean` (certutil) | `Erro ao remover o certificado: {name} [{thumbprint}]` |
| `ExportPfx` / `Save` | `Certificado sem thumbprint para exportar/salvar.` |
| `Verify` / `Dump` | `Nao ha arquivo nem thumbprint para ...` |

**No-op:** `Install` when `Installed` is already True. `Clean` when not `Installed` (sets `Cleaned=True`) or when thumbprint is `""` (returns without setting `Cleaned`). `Assign` when `pSource` is unassigned.

**`Install` vs `ImportPfx` modifiers:** `TCertificate.Install("")` imports the chain as certutil defaults (roots included). `TCertificateStore.ImportPfx` defaults to `"NoRoot"`. Literal examples: `""`, `"NoRoot"`, `"NoChain"`, `"NoRoot,NoChain"`.

---

## Certificate lists

### `TCertificates`

List of `TCertificate`. Filter methods return a **new** list of `Copy()` clones (`CleanOnFree = False`). `Find*` returns the item **owned by this list** — do not `Free` that item while the list is alive.

```bas
Sub New()

Shared Function FromDump(pLines As StringList, pLocation As TCertLocation, pStore As TCertStoreName) As TCertificates
   ' One TCertificate per dump block; CleanOnFree=False; MarkInstalled. Caller owns the list.

Function Expired() As TCertificates
Function Valid() As TCertificates
Function WithPrivateKey() As TCertificates
Function ExpiringWithin(pDays As Integer) As TCertificates
   ' IsValid And DaysToExpire() <= pDays. pDays must be > 0 or this filter is skipped.

Function Search(pQuery As String) As TCertificates
   ' Matches(pQuery) on each item.

Function FindByThumbprint(pHash As String) As TCertificate
   ' Normalized SHA1 equality. Unassigned if none.

Function FindByName(pName As String) As TCertificate
   ' Exact case-insensitive Name, then first Matches(pName). Unassigned if none.

Function FindBySerial(pSerial As String) As TCertificate
   ' Case-insensitive, spaces stripped. Unassigned if none.
```

**`FromDump` with no headers:** if the whole text still has `Requerente`/`Subject` or `Hash Cert(sha1)`/`Cert Hash(sha1)`, it yields a single cert; otherwise an empty list. Never throws.

---

## Certificate store

### `TCertificateStore`

A `(Location, StoreName)` pair. `List` / `Find*` / filters always re-query `certutil`. Filter helpers (`Expired`, `Valid`, …) `Free` the intermediate full list; the caller owns the returned list.

```bas
Sub New()                                           ' CurrentUser + My
Sub New(pLocation As TCertLocation, pStore As TCertStoreName)
   ' Nil location/store fall back to CurrentUser / My.

Shared Function Personal() As TCertificateStore     ' CurrentUser\My
Shared Function Machine() As TCertificateStore      ' LocalMachine\My
Shared Function Roots(pLocation As TCertLocation) As TCertificateStore
```

| Property | Type | Default |
|---|---|---|
| `Location` | `TCertLocation` | `CurrentUser` |
| `Name` | `TCertStoreName` | `My` |

```bas
Function List(pCertId As String = "") As TCertificates
   ' -store {Name} ["{pCertId}"]. Empty pCertId lists the whole store.

Function Find(pCertId As String) As TCertificate
   ' List(pCertId), Copy of first item. Null if Length=0. Caller owns the result.

Function FindByThumbprint(pHash As String) As TCertificate   ' Find(NormalizeHash(pHash))
Function FindByName(pName As String) As TCertificate         ' Find(pName) — certutil CertId match
Function FindBySerial(pSerial As String) As TCertificate     ' Find(pSerial)

Function Expired() As TCertificates
Function Valid() As TCertificates
Function WithPrivateKey() As TCertificates
Function ExpiringWithin(pDays As Integer) As TCertificates
Function Search(pQuery As String) As TCertificates

Shared Function EnumStores(pLocation As TCertLocation) As StringList
   ' NameValueSeparator="=". Lines like My=Pessoal or Memory.

Function ImportPfx(pPath As String, pPass As String, pModifiers As String = "NoRoot") As TCertificate
   ' Load + set Location/Store + Install(pModifiers). Result has CleanOnFree=False.

Function Add(pFile As String) As TCertificateStore
   ' -f -addstore {Name} {file} (.cer/.crt). Returns me.

Sub Delete(pCertId As String)
   ' -delstore {Name} "{pCertId}".

Function ExportPfx(pCertId As String, pOutFile As String, pPass As String, pModifiers As String = "NoRoot") As TCertificateStore
Function SaveCert(pCertId As String, pOutFile As String) As TCertificateStore
Function Verify(pCertId As String = "") As StringList          ' -verifystore
Function Repair(pCertId As String) As Integer                  ' -repairstore
Function Dump(pCertId As String = "") As StringList            ' raw -store dump
```

**`EnumStores` contract (literal):**

```
My=Pessoal
Root=Autoridades de Certificação Raiz Confiáveis
CA=Autoridades de Certificação Intermediárias
Memory
```

Skipped: empty lines, lines starting with `(`, lines containing `CERTUTIL`, lines ending with `:`, names containing a space, and the tokens `LocalMachine` / `CurrentUser` / `Enterprise` / `GroupPolicy` / `Service`.

**`certutil` CertId** (for `List`/`Find`/`Delete`/`ExportPfx`): serial, SHA1, numeric index (`0`, `1`), or subject CN. Example: `"FINGER & CIA LTDA:03096070000183"`, `"B3749A4C34F202827B6E323E1A336DCAA972412B"`, `"01"`.

**Throws:**

| Call | Message |
|---|---|
| `Add` | `Arquivo nao encontrado: {file}` |
| `Add` (certutil) | `Falha ao adicionar certificado no store {Name}` |
| `Delete` (empty id) | `Informe o CertId (thumbprint, CN ou serial) para excluir.` |
| `Delete` / `ExportPfx` / `SaveCert` / `Repair` | `Falha ao ...` |

**Returns `Null`:** `Find` / `FindBy*` when the dump has zero certs.

**`CURRENT_USER\Root` vs `LOCAL_MACHINE\Root`:** user-imported PFX chains land in CurrentUser Root (often one ICP-Brasil cert). OS roots are `TCertificateStore.Roots(TCertLocation.LocalMachine())`.

---

## Internal flows (usage-relevant)

**PFX leaf vs CA chain.** `Load` dumps the file and keeps the block with a private key (last such block). Using the first block would bind the locator to a CA (`Autoridade Certificadora Raiz Brasileira v5`).

**Store list.** `List` runs `-user -store My` (for Personal), `FromDump` splits every `================ Certificado N ================` block, `ApplyDump` on each, `CleanOnFree=False`, `MarkInstalled`.

**WinHTTP.** `SetClientCertificate` matches a **subject substring**, not a thumbprint. Prefer `Locator` / `Name`. `WinHttpLocators` still offers the hash as a fallback candidate.

---

## Extending (Consumer Project)

There is no UI and no type registry.

- Subclass `TCertificate` to add domain fields; call `Load`/`ApplyDump` then read `Locator`.
- Subclass `TCertificateStore` to pin a store (`New TCertificateStore(TCertLocation.LocalMachine(), TCertStoreName.TrustedPeople)`).
- Subclass `TCertUtil` only to replace `EnsureExe` (custom `certutil` path). Consumers should still go through `Instance()` unless they construct their own runner.

```bas
Class TPixCertificate
   Inherits TCertificate
   Function EnsureInstalled(pPath As String, pPass As String) As TCertificate
      me.Load(pPath, pPass)
      me.Install("NoRoot")
      EnsureInstalled = me
   End Function
End Class
```

---

## Module Notes

- `CleanOnFree=True` (default on `New`/`Load`) deletes the cert from Windows on `Free` when `Installed`. Store listings and `Copy`/`FromDump`/`ImportPfx` set it `False`.
- `TCertificates` filter methods clone items; `Find*` on the list returns the live child. `TCertificateStore.Find*` returns a `Copy` the caller must `Free`.
- `Install("")` imports the PFX chain including roots. `ImportPfx` defaults to `NoRoot`.
- Dates use `0` as “unknown”; `IsExpired`/`IsNotYetValid` are False in that case; `IsValid` requires a real `DateEnd`.
- Thumbprints are uppercase SHA1 hex (40 chars). `NormalizeHash` stops at the first non-hex so dump noise is not appended.
- `EnumStores` uses `StringList.NameValueSeparator = "="` (`store.Values("My")` → `Pessoal`).
- `TCertUtil.Instance` is a process singleton; `Dispose` of that instance clears it.
- `src/Principal.bas` enumerates CurrentUser stores, lists `My` and `Root`, and `FindByName("Autoridade Certificadora Raiz Brasileira v5")`.
