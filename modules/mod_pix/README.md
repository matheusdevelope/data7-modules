# mod_pix

PIX cob (immediate charge) client for Data7: PSP HTTP adapters (Sicredi, Sicoob, Itaú, Santander, Bradesco), an in-memory client, Bacen-shaped JSON models, validation, optional `MovimentoPix` persistence, and a `PixService` facade. It does **not** display QR codes, send WhatsApp, host webhook listeners, implement cobrança com vencimento (`cobv`), outbound PIX payment, or Banco do Brasil — those stay in the consumer (the last three exist as blocked slots). Version **1.0.2.0**. Dependencies (`data7.json`): `mod_http` `2.0`, `mod_table` `1.0.0.6`, `mod_validators` `1.0.0.0`.

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Open a `.bas` file only to confirm a detail that is not stated here.

## Quick Start (Minimal)

```basic
Imports mod_pix_runtime
Imports mod_pix_config
Imports mod_pix_cobranca
Imports mod_pix_cobranca_completa
Imports mod_pix_recebimento
Imports mod_pix_devolucao
Imports mod_pix_utils
Imports mod_pix_memory

' Banco=Memory, Version=1, Sandbox=True, TimeZoneHours=0, ChavePix="teste-chave-pix"
Dim config As PixConfig = PixConfig.Memory()
' Factory: PixClientMemory. CodEmpresa=0 → PixNullLedger (no DB write).
Dim pix As PixService = PixService.Load(config)

Dim cob As New PixCobranca()
cob.Valor.Original = 1.5
cob.Calendario.Expiracao = 3600
' Chave "" → config.ChavePix. TxId "" → GenerateTxID() (26..35 chars).

Dim registered As PixCobrancaCompleta = pix.Cobranca.Registrar(cob)
' Status ATIVA. Location + PixCopiaECola filled.

Dim mem As PixClientMemory = CType(pix.Client(), PixClientMemory)
' Memory-only: marks cob CONCLUIDA and stores a PixRecebimento (E2eId = "E" & TxId).
Dim pagamento As PixRecebimento = mem.SimulatePayment(registered.TxId)

Dim rtid As String = GenerateIDDevolucao()   ' 20 chars
Dim dev As PixDevolucao = pix.Devolucao.Registrar(registered.TxId, pagamento.E2eId, rtid, registered.Valor.Original)

registered.Free()
pagamento.Free()
dev.Free()
cob.Free()
pix.Free()
config.Free()
```

ERP account (live PSP): `PixErp.FromContaFinanceira("SIC")` then `PixService.Load(config)`. `Load` throws if `ChavePix` is `""`.

---

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/core/mod_pix_enums.bas` | `mod_pix_enums` | `PixBanco`, `PixStatusCobranca`, `PixStatusDevolucao`, `PixModalidadeAlteracao` |
| `src/lib/core/mod_pix_capabilities.bas` | `mod_pix_capabilities` | `PixCapabilities` |
| `src/lib/core/mod_pix_contracts.bas` | `mod_pix_contracts` | `PixClient` |
| `src/lib/config/mod_pix_config.bas` | `mod_pix_config` | `PixConfig` |
| `src/lib/psp/mod_pix_psp.bas` | `mod_pix_psp` | `PixPsp` |
| `src/lib/runtime/mod_pix_runtime.bas` | `mod_pix_runtime` | `PixResource`, `PixCobrancaResource`, `PixRecebimentoResource`, `PixDevolucaoResource`, `PixCobrancaVencimentoResource`, `PixPagamentoResource`, `PixWebhookResource`, `PixService` |
| `src/lib/models/mod_pix_credentials.bas` | `mod_pix_credentials` | `PixCredentials` |
| `src/lib/models/mod_pix_certificate.bas` | `mod_pix_certificate` | `PixCertificate` |
| `src/lib/models/mod_pix_valor.bas` | `mod_pix_valor` | `PixValor` |
| `src/lib/models/mod_pix_calendario.bas` | `mod_pix_calendario` | `PixCalendario` |
| `src/lib/models/mod_pix_horario.bas` | `mod_pix_horario` | `PixHorario` |
| `src/lib/models/mod_pix_devedor.bas` | `mod_pix_devedor` | `PixDevedor` |
| `src/lib/models/mod_pix_info_adicional.bas` | `mod_pix_info_adicional` | `PixInfoAdicional`, `PixInfoAdicionalList` |
| `src/lib/models/mod_pix_paginacao.bas` | `mod_pix_paginacao` | `PixPaginacao` |
| `src/lib/models/mod_pix_filtro.bas` | `mod_pix_filtro` | `PixFiltroFormatter`, `PixFiltro` |
| `src/lib/models/mod_pix_cobranca.bas` | `mod_pix_cobranca` | `PixCobranca` |
| `src/lib/models/mod_pix_cobranca_completa.bas` | `mod_pix_cobranca_completa` | `PixCobrancaCompleta`, `PixCobrancaList` |
| `src/lib/models/mod_pix_cobrancas.bas` | `mod_pix_cobrancas` | `PixCobrancas` |
| `src/lib/models/mod_pix_recebimento.bas` | `mod_pix_recebimento` | `PixRecebimento`, `PixRecebimentoList` |
| `src/lib/models/mod_pix_recebimentos.bas` | `mod_pix_recebimentos` | `PixRecebimentos` |
| `src/lib/models/mod_pix_devolucao.bas` | `mod_pix_devolucao` | `PixDevolucao`, `PixDevolucaoList` |
| `src/lib/validation/mod_pix_validation.bas` | `mod_pix_validation` | `PixValidator` |
| `src/lib/utils/mod_pix_utils.bas` | `mod_pix_utils` | functions (no class) |
| `src/lib/http/mod_pix_http.bas` | `mod_pix_http` | `PixAccessToken`, `PixHttpPairs`, `PixHttpAuthRequest`, `PixHttp` |
| `src/lib/providers/bacen/mod_pix_client_bacen.bas` | `mod_pix_bacen` | `PixClientBacen` |
| `src/lib/providers/memory/mod_pix_client_memory.bas` | `mod_pix_memory` | `PixClientMemory` |
| `src/lib/providers/sicredi/mod_pix_client_sicredi.bas` | `mod_pix_sicredi` | `PixPspSicredi`, `PixClientSicredi` |
| `src/lib/providers/sicredi/mod_pix_http_sicredi.bas` | `mod_pix_http_sicredi` | `PixHttpSicredi` |
| `src/lib/providers/sicoob/mod_pix_client_sicoob.bas` | `mod_pix_sicoob` | `PixPspSicoob`, `PixClientSicoob` |
| `src/lib/providers/sicoob/mod_pix_http_sicoob.bas` | `mod_pix_http_sicoob` | `PixHttpSicoob` |
| `src/lib/providers/itau/mod_pix_client_itau.bas` | `mod_pix_itau` | `PixPspItau`, `PixClientItau` |
| `src/lib/providers/itau/mod_pix_http_itau.bas` | `mod_pix_http_itau` | `PixHttpItau` |
| `src/lib/providers/santander/mod_pix_client_santander.bas` | `mod_pix_santander` | `PixPspSantander`, `PixClientSantander` |
| `src/lib/providers/santander/mod_pix_http_santander.bas` | `mod_pix_http_santander` | `PixHttpSantander` |
| `src/lib/providers/bradesco/mod_pix_client_bradesco.bas` | `mod_pix_bradesco` | `PixPspBradesco`, `PixFiltroFormatterBradesco`, `PixClientBradesco` |
| `src/lib/providers/bradesco/mod_pix_http_bradesco.bas` | `mod_pix_http_bradesco` | `PixHttpBradesco` |
| `src/lib/ledger/mod_pix_ledger.bas` | `mod_pix_ledger` | `PixLedger`, `PixNullLedger` |
| `src/lib/ledger/mod_pix_ledger_movimento.bas` | `mod_pix_ledger` | `PixMovimentoLedger` |
| `src/lib/ledger/mod_pix_movimento.bas` | `mod_pix_ledger` | `MovimentoPix` |
| `src/lib/erp/mod_pix_erp.bas` | `mod_pix_erp` | `PixErp` |
| `src/tests/mod_pix_tests.bas` | `mod_pix_tests` | `PixTests` |
| `src/tests/mod_pix_live_tests.bas` | `mod_pix_tests` | `PixLiveTests` |

`src/Principal.bas` has no namespace. It calls `PixTests.RunAll()` then `PixLiveTests.Run` for contas `BRA`, `SIC`, `SICA`, `BI`, `SAN`. HTTP types (`HttpClient`, `HttpRequest`, `HttpResponse`, `HttpMethod`, `HttpBaseList`, `HttpParams`) come from `mod_http`. `TDocs` comes from `mod_validators`. `TTableOf` / `TTableSchema` come from `mod_table`.

---

## Enums

```basic
Enun PixBanco
   Memory = "0"
   BBrasil = "1"       ' declared; PixService.CreateClient throws for this value
   Bradesco = "237"
   Itau = "341"
   Santander = "033"
   Sicoob = "756"
   Sicredi = "748"
End Enun

Enun PixStatusCobranca
   Ativa = "ATIVA"
   Concluida = "CONCLUIDA"
   RemovidaPeloUsuario = "REMOVIDA_PELO_USUARIO_RECEBEDOR"
   RemovidaPeloPsp = "REMOVIDA_PELO_PSP"
End Enun

Enun PixStatusDevolucao
   EmProcessamento = "EM_PROCESSAMENTO"
   Devolvido = "DEVOLVIDO"
   NaoRealizado = "NAO_REALIZADO"
End Enun

Enun PixModalidadeAlteracao
   Nao = "NAO"
   Sim = "SIM"
End Enun
```

`PixErp.FromContaFinanceira` loads `PixBanco` from `ContaFinanceira.NumeroBanco` (literals above). `PixValor.ToJson` writes `modalidadeAlteracao` as integer (`AsInteger`); `FromJson` reads `GetInteger`.

---

## Runtime (`PixService`)

Facade: validates, checks capabilities, delegates to `PixClient`, and optionally persists via `PixLedger`. Resources are built in the constructor and owned by the service.

```basic
Sub New(pClient As PixClient, pOwnsClient As Boolean = True)
   ' throws "PixService requer um PixClient" if pClient is not Assigned
   ' validator = New PixValidator() (owned)
   ' ledger = New PixNullLedger() (owned)
End Sub

Sub New(pClient As PixClient, pLedger As PixLedger, pOwnsClient As Boolean = True, pOwnsLedger As Boolean = False)
   ' throws if pClient or pLedger is not Assigned
End Sub

Shared Function Load(pConfig As PixConfig) As PixService
   ' throws if pConfig.ChavePix = ""
   ' client = CreateClient(pConfig) (owned)
   ' CodEmpresa > 0 → PixMovimentoLedger(pConfig); else PixNullLedger
   ' owns both client and ledger
End Function

Shared Function CreateClient(pConfig As PixConfig) As PixClient
   ' Memory / Sicredi / Sicoob / Itau / Santander / Bradesco
   ' else throws "Banco não suportado: " & Banco.AsString
End Function

Function Client() As PixClient
Function Config() As PixConfig          ' same object as Client.GetConfig(); not a clone
Function Validator() As PixValidator
Function Ledger() As PixLedger
Function Capabilities() As PixCapabilities

Sub EnsureCapability(pAllowed As Boolean, pFeature As String)
   ' if not pAllowed: "O cliente [{GetName()}] não suporta o recurso: {pFeature}"
End Sub
```

| Property | Type | Role |
|---|---|---|
| `Cobranca` | `PixCobrancaResource` | cob register / alter / cancel / get / list |
| `Recebimento` | `PixRecebimentoResource` | PIX get / list |
| `Devolucao` | `PixDevolucaoResource` | refund register / get |
| `CobrancaVencimento` | `PixCobrancaVencimentoResource` | cobv (capability off in stock clients) |
| `Pagamento` | `PixPagamentoResource` | outbound pay (capability off) |
| `Webhook` | `PixWebhookResource` | webhook URL (capability off) |

`Dispose` frees resources, then owned validator / ledger / client. `Config` is not freed here; the client owns its clone.

### `PixResource`

Base for the six resource classes. Constructor throws `"PixResource requer PixService"` if `pService` is not Assigned. `Dispose` nulls the service pointer (does not free it).

### `PixCobrancaResource`

```basic
Function Registrar(pDados As PixCobranca) As PixCobrancaCompleta
   ' 1. EnsureCapability(CanCobrancaRegistrar, "registrar cobrança")
   ' 2. Chave "" → Config.ChavePix
   ' 3. TxId "" → GenerateTxID()
   ' 4. Validator.EnsureCobranca
   ' 5. Client.CobrancaRegistrar → Ledger.SaveCobranca
End Function

Function Alterar(pDados As PixCobranca) As PixCobrancaCompleta
   ' 1. EnsureCapability(CanCobrancaAlterar, "alterar cobrança")
   ' 2. Chave "" → Config.ChavePix
   ' 3. Revisao = Revisao + 1
   ' 4. EnsureCobranca
   ' 5. Client.CobrancaConsultar; NULL → "Cobrança não encontrada"
   ' 6. not IsActive → "Cobrança não está ativa e não pode ser alterada"
   ' 7. Client.CobrancaAlterar → Ledger.SaveCobranca
End Function

Function Cancelar(pTxId As String) As PixCobrancaCompleta
   ' EnsureCapability(..., "cancelar cobrança"); EnsureTxId
   ' Client.CobrancaCancelar → Ledger.SaveCobranca(cob, DateTime())  ' cancel timestamp
End Function

Function Consultar(pTxId As String) As PixCobrancaCompleta
   ' EnsureCapability(..., "consultar cobrança"); EnsureTxId; no ledger write
End Function

Function Listar(pFiltros As PixFiltro) As PixCobrancas
   ' EnsureCapability(..., "listar cobranças"); EnsureFiltro; no ledger write
End Function
```

### `PixRecebimentoResource`

```basic
Function Consultar(pEndToEndId As String) As PixRecebimento
   ' EnsureCapability(CanPixConsultar, "consultar PIX"); EnsureE2eId
End Function

Function Listar(pFiltros As PixFiltro) As PixRecebimentos
   ' EnsureCapability(CanPixListar, "listar PIX"); EnsureFiltro
End Function
```

### `PixDevolucaoResource`

```basic
Function Registrar(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency) As PixDevolucao
   ' EnsureCapability(..., "registrar devolução"); EnsureDevolucao
   ' Cobranca.Consultar(pTxId); NULL → "Não existe cobrança para o TxId informado, verifique!"
   ' Client.DevolucaoRegistrar then Ledger.SaveCobranca(cob) of that consult (not the new PixDevolucao)
End Function

Function Consultar(pEndToEndId As String, pIdDevolucao As String) As PixDevolucao
   ' EnsureCapability(..., "consultar devolução"); EnsureE2eId
   ' pIdDevolucao "" → "Id da devolução é obrigatório"
End Function
```

### Blocked slots (stock capabilities)

```basic
Function PixCobrancaVencimentoResource.Registrar(pDados As PixCobranca) As PixCobrancaCompleta
   ' EnsureCapability(CanCobrancaVencimento, "cobrança com vencimento (cobv)")
End Function

Function PixPagamentoResource.Enviar(pChave As String, pValor As Currency) As PixRecebimento
   ' EnsureCapability(CanPagamento, "pagamento PIX")
End Function

Function PixWebhookResource.Configurar(pUrl As String) As String
   ' EnsureCapability(CanWebhook, "webhook")
End Function
```

`FullRecebimento` leaves `CanCobrancaVencimento`, `CanPagamento`, and `CanWebhook` at `False`. The service throws before the client method.

---

## Client contract and capabilities

### `PixClient`

Must-inherit PSP adapter. Default operation methods throw `"<Feature> não suportado por " & GetName()` (e.g. `"Cobranca.Registrar não suportado por Memory"`).

```basic
MustOverride Function GetName() As String
MustOverride Function GetCapabilities() As PixCapabilities
MustOverride Function GetConfig() As PixConfig

Overridable Function FormatFiltro(pFiltros As PixFiltro) As String
   ' PixFiltro.ToParamsString(GetConfig().TimeZoneHours)
End Function

Overridable Function CobrancaRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
Overridable Function CobrancaAlterar(pDados As PixCobranca) As PixCobrancaCompleta
Overridable Function CobrancaCancelar(pTxId As String) As PixCobrancaCompleta
Overridable Function CobrancaConsultar(pTxId As String) As PixCobrancaCompleta
Overridable Function CobrancaListar(pFiltros As PixFiltro) As PixCobrancas
Overridable Function PixConsultar(pEndToEndId As String) As PixRecebimento
Overridable Function PixListar(pFiltros As PixFiltro) As PixRecebimentos
Overridable Function DevolucaoRegistrar(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency) As PixDevolucao
Overridable Function DevolucaoConsultar(pEndToEndId As String, pIdDevolucao As String) As PixDevolucao
Overridable Function CobrancaVencimentoRegistrar(pDados As PixCobranca) As PixCobrancaCompleta
Overridable Function PagamentoEnviar(pChave As String, pValor As Currency) As PixRecebimento
Overridable Function WebhookConfigurar(pUrl As String) As String
```

### `PixCapabilities`

Boolean flags. Constructor leaves every flag `False`.

| Field | Set by `FullRecebimento()` |
|---|---|
| `CanCobrancaRegistrar` | `True` |
| `CanCobrancaAlterar` | `True` |
| `CanCobrancaCancelar` | `True` |
| `CanCobrancaConsultar` | `True` |
| `CanCobrancaListar` | `True` |
| `CanPixConsultar` | `True` |
| `CanPixListar` | `True` |
| `CanDevolucaoRegistrar` | `True` |
| `CanDevolucaoConsultar` | `True` |
| `CanCobrancaVencimento` | remains `False` |
| `CanPagamento` | remains `False` |
| `CanWebhook` | remains `False` |

```basic
Shared Function FullRecebimento() As PixCapabilities
Shared Function Memory() As PixCapabilities   ' alias of FullRecebimento
```

Santander then sets `CanCobrancaListar = False` and `CanPixConsultar = False`.

---

## Config, credentials, PSP

### `PixConfig`

| Field | Type | Default |
|---|---|---|
| `CodEmpresa` | `Integer` | `0` |
| `CodFilial` | `Integer` | `0` |
| `CodContaFinanceira` | `String` | `""` |
| `Banco` | `PixBanco` | unset |
| `Credentials` | `PixCredentials` | `New` (`Type="Basic"`) |
| `Certificate` | `PixCertificate` | `New` |
| `ChavePix` | `String` | `""` |
| `Sandbox` | `Boolean` | `False` |
| `Timeout` | `Integer` | `10000` (ms) |
| `Version` | `Integer` | `0` / ctor arg |
| `Psp` | `PixPsp` | unset until a live client `ApplyProfile` |
| `TimeZoneHours` | `Integer` | `0` |

```basic
Sub New()
Sub New(pBanco As PixBanco, pVersion As Integer = 0)

Shared Function Memory(pChavePix As String = "teste-chave-pix") As PixConfig
   ' Banco=Memory, Version=1, Sandbox=True, TimeZoneHours=0
End Function

Sub Assign(pValue As PixConfig)
   ' no-op if pValue is not Assigned; clones Credentials, Certificate, Psp
End Sub
```

`Dispose` frees `Credentials`, `Certificate`, `Psp`. Bank clients clone this object; the original passed to `Load` stays with the consumer.

### `PixCredentials`

| Field | Default |
|---|---|
| `Id` | `""` |
| `Secret` | `""` |
| `Type` | `"Basic"` |

```basic
Function AsAuthorization() As String
   ' Type & " " & Base64(Id & ":" & Secret) with CR, LF, and spaces stripped from the token
End Function
```

`Assign` is a no-op if `pValue` is not Assigned. `ToString` logs `Id` and `Type`, not `Secret`.

### `PixCertificate`

| Field | Role |
|---|---|
| `Path` | `.pfx` path (`PixHttp.LoadCertificate` → `Certificate.Load`) |
| `Pass` | password |

`Assign` is a no-op if `pValue` is not Assigned.

### `PixPsp`

URL/scope table for one bank version. `AuthUrl` / `BaseUrl` index: `Sandbox=False` → production (second `Add`); `Sandbox=True` → homolog (first `Add`).

```basic
Sub New(pBanco As PixBanco, pVersion As Integer, pVersionAuth As Integer = -1)
   ' pVersionAuth = -1 → same as pVersion
End Sub

Property Banco As PixBanco          ' get only
Property Version As Integer         ' get only
Property VersionAuth As Integer     ' get only

Function AuthUrl(pSandBox As Boolean) As String
Function BaseUrl(pSandBox As Boolean) As String
Function VersionedBaseUrl(pSandBox As Boolean, pVersion As Integer) As String
   ' Replace "/api/v" & Version with "/api/v" & pVersion on BaseUrl
   ' no-op on hosts that do not contain "/api/v" (Itaú, Bradesco)
End Function

Function Scopes(pSeparator As String = "+") As String
   ' Scope list joined with pSeparator
End Function

Overridable Sub FillScopes()
   ' cob.read, cob.write, pix.write, pix.read, webhook.read, webhook.write,
   ' payloadlocation.read, payloadlocation.write
End Sub

Overridable Sub FillUrls()          ' empty in the base class
Overridable Function Clone() As PixPsp
```

Default `Scopes()`:

```text
cob.read+cob.write+pix.write+pix.read+webhook.read+webhook.write+payloadlocation.read+payloadlocation.write
```

Santander overrides to `cob.read+cob.write+pix.read+pix.write`.

---

## Domain models

JSON omit rules (write path): empty string, `Revisao = -1`, `Expiracao = -1`, `Valor.Original = 0`, empty `calendario`/`devedor` object `{}`, empty `infoAdicionais`. Integer fields default to `0`, so `revisao: 0` and `expiracao: 0` **are** serialized unless a provider sets `-1`.

`GetID` (used by list `FindById` / `IndexOf`): `PixCobranca`/`PixCobrancaCompleta` → `TxId`; `PixRecebimento` → `E2eId`; `PixDevolucao` → `Id`; `PixInfoAdicional` → `Nome`. Missing → `NULL`. Empty list `First()` → `NULL`.

### `PixValor`

| Field | Default |
|---|---|
| `Original` | `0` |
| `ModalidadeAlteracao` | `PixModalidadeAlteracao.Nao()` |

JSON keys: `original` (string `"10.50"`), `modalidadeAlteracao` (integer).

### `PixCalendario`

| Field | Role |
|---|---|
| `Criacao` | creation instant |
| `Expiracao` | seconds |

```basic
Function DataExpiracao() As TDateTime   ' Criacao.AddSeconds(Expiracao)
Function IsExpired() As Boolean         ' DateTime() > DataExpiracao()
```

`FromJson` parses `criacao` ISO-8601 then `AddHours(pTimeZoneHours)`. `ToJson` skips empty `Criacao` (`IsEmptyDate`) and `Expiracao = -1`. JSON keys: `criacao`, `expiracao`.

### `PixHorario`

| Field | JSON |
|---|---|
| `Liquidacao` | `liquidacao` |
| `Solicitacao` | `solicitacao` |

`FromJson` applies `pTimeZoneHours`. Empty dates omitted on write.

### `PixDevedor`

| Field | JSON |
|---|---|
| `CPF` | `cpf` |
| `CNPJ` | `cnpj` |
| `Nome` | `nome` |

```basic
Function IsEmpty() As Boolean   ' all three ""
```

### `PixInfoAdicional` / `PixInfoAdicionalList`

```basic
Sub New()
Sub New(pNome As String, pValor As String)

Shared Function FromJson(pJson As TJSONObject) As PixInfoAdicional
Function ToJson() As TJSONObject          ' keys nome, valor

Shared Function PixInfoAdicionalList.FromJson(pJson As TJSONArray) As PixInfoAdicionalList
Function ToJson() As TJSONArray
Function CopyItems() As PixInfoAdicionalList   ' clones; caller owns the copy
```

### `PixCobranca`

| Field | Type | Notes |
|---|---|---|
| `TxId` | `String` | JSON `txid` unless `ToJson(pTxIdKey)` |
| `Chave` | `String` | `chave` |
| `Revisao` | `Integer` | omitted when `-1` |
| `SolicitacaoPagador` | `String` | `solicitacaoPagador` |
| `Valor` | `PixValor` | owned |
| `Calendario` | `PixCalendario` | owned |
| `Devedor` | `PixDevedor` | owned |
| `InfoAdicionais` | `PixInfoAdicionalList` | owned |

```basic
Shared Function FromJson(pJson As TJSONObject) As PixCobranca
Function ToJson() As TJSONObject
Function ToJson(pTxIdKey As String) As TJSONObject   ' Santander/Bradesco create use "txID"
```

`Assign` is a no-op if `pValue` is not Assigned; nested objects are cloned.

### `PixCobrancaCompleta`

Extends `PixCobranca`.

| Field | Type | Notes |
|---|---|---|
| `CodMovimentoPix` | `Integer` | written back by `PixMovimentoLedger` |
| `PixCopiaECola` | `String` | JSON `pixCopiaECola` or `brcode` |
| `Status` | `PixStatusCobranca` | `status` |
| `Location` | `String` | `location`, or `loc.location` |
| `Recebimentos` | `PixRecebimentoList` | JSON array `pix` |

```basic
Function IsActive() As Boolean     ' Status = ATIVA
Function IsDone() As Boolean       ' Status = CONCLUIDA
Function IsCancelled() As Boolean  ' Status Assigned and not active and not done

Shared Function FromJson(pJson As TJSONObject, pTimeZoneHours As Integer = 0) As PixCobrancaCompleta
   ' if PixCopiaECola "" and Location <> "" → GerarPixCopiaECola(Location)
   ' loc.location read is inside Try; missing loc is ignored
End Function
```

`AssignCompleta` copies completa fields and clones `Recebimentos`. `Clone` uses `AssignCompleta`.

### `PixCobrancaList`

```basic
Shared Function FromJson(pJson As TJSONArray, pTimeZoneHours As Integer = 0) As PixCobrancaList
Function CopyItems() As PixCobrancaList
Function Count() As Integer
Function First() As PixCobrancaCompleta          ' NULL if empty
Function FindById(pTxId As String) As PixCobrancaCompleta   ' NULL if IndexOf < 0
```

### `PixCobrancas`

List envelope. `FromJson` reads `cobs` into `Cobrancas` and `parametros.paginacao` into `Paginacao`. Filter fields inside `parametros` are not copied onto `Parametros`.

| Field | Type |
|---|---|
| `Parametros` | `PixFiltro` |
| `Paginacao` | `PixPaginacao` |
| `Cobrancas` | `PixCobrancaList` |

### `PixRecebimento`

| Field | JSON / source |
|---|---|
| `E2eId` | `endToEndId` |
| `TxId` | `txid` |
| `Chave` | `chave` |
| `Valor` | `valor` string |
| `ValorCobranca` | `componentesValor.original.valor`; if `0`, copied from `Valor` |
| `ValorDevolvido` | `Devolucoes.ValorTotal()` after parse |
| `Horario` | `horario` ISO-8601 + timezone |
| `Devolucoes` | `devolucoes` |

### `PixRecebimentoList`

Same list helpers as cobranca: `FromJson`, `CopyItems`, `Count`, `First` (`NULL`), `FindById(pE2e)` (`NULL`).

### `PixRecebimentos`

| Field | Type | JSON |
|---|---|---|
| `Parametros` | `PixFiltro` | not hydrated |
| `Paginacao` | `PixPaginacao` | `parametros.paginacao` |
| `Pix` | `PixRecebimentoList` | `pix` |

### `PixDevolucao`

| Field | JSON |
|---|---|
| `Id` | `id` |
| `RtrId` | `rtrId` |
| `Valor` | `valor` (always written) |
| `Status` | `status` |
| `Motivo` | `motivo` |
| `Horario` | `horario` object |

### `PixDevolucaoList`

```basic
Function ValorTotal() As Double    ' sum of item.Valor
Function FindById(pId As String) As PixDevolucao   ' NULL if missing
Function CopyItems() As PixDevolucaoList
Function ToJson() As TJSONArray
```

### `PixPaginacao`

| Field | JSON keys (first match) |
|---|---|
| `PaginaAtual` | `paginaAtual` |
| `ItensPorPagina` | `itensPorPagina` |
| `QuantidadePaginas` | `quantidadeDePaginas` else `quantidadePaginas` |
| `TotalItens` | `quantidadeTotalDeItens` else `quantidadeDeItens` |

### `PixFiltro` / `PixFiltroFormatter`

| Field | Query param |
|---|---|
| `CPF` | `cpf=` if `<> ""` |
| `CNPJ` | `cnpj=` if `<> ""` |
| `DataInicio` | `inicio=` if `> 0` (URL-encoded) |
| `DataFim` | `fim=` if `> 0` (URL-encoded) |
| `Status` | `status=` `AsString` if Assigned |
| `Pagina` | `paginacao.paginaAtual=` if `> 0` |
| `ItensPorPagina` | `paginacao.itensPorPagina=` if `> 0` after default |

```basic
Overridable Function FormatDate(pDate As TDateTime, pTimeZoneHours As Integer) As String
   ' DateToQueryParam → yyyy-mm-ddThh:nn:ssZ
End Function

Overridable Function PaginaParamName() As String
   ' "paginacao.paginaAtual"
End Function

Overridable Function DefaultItensPorPagina() As Integer
   ' 0 → omit itensPorPagina. Bradesco override: 100
End Function

Function ToParamsString(pFiltro As PixFiltro, pTimeZoneHours As Integer = 0) As String
Function PixFiltro.ToParamsString(pTimeZoneHours As Integer = 0) As String
```

Literal examples:

```text
cpf=52998224725&inicio=2026-10-01T04%3A00%3A00Z&fim=2026-10-03T04%3A00%3A00Z
inicio=2026-10-01T00%3A00%3A00.000Z&fim=2026-10-03T00%3A00%3A00.000Z&paginacao.itensPorPagina=100
inicio=...&fim=...&paginacao.paginaAtual=1&paginacao.itensPorPagina=5
...&status=ATIVA
```

`DataInicio`/`DataFim` in the query use `> 0`, not `IsEmptyDate`. `EnsureFiltro` (list operations) uses `IsEmptyDate`.

`PixFiltroFormatterBradesco.FormatDate` uses `DateToISO8601Millis` (`yyyy-mm-ddThh:nn:ss.xxxZ`).

---

## Validation (`PixValidator`)

`Validate*` return a newline-joined error string (`""` = ok). `Ensure*` throw.

```basic
Function ValidateValue(pValor As Double) As String
   ' pValor <= 0 → "[Valor] tem que ser maior que 0"
   ' more than 2 decimal places → "[Valor] deve conter exatamente 2 casas decimais"
End Function

Function ValidateCobranca(pDados As PixCobranca) As String
   ' TxId length not in 26..35 → "TxID inválido"
   ' ValidateValue(Valor.Original)
   ' Chave "" → "Chave PIX não informada [Chave], verifique!"
   ' Calendario.Expiracao <= 0 → "Expiração igual ou menor que zero, ..."
   ' both CPF and CNPJ → "Informe apenas um Devedor: [Devedor.cnpj] ou [Devedor.cpf]"
   ' CPF: 11 numeric digits then TDocs.IsValidCPF
   ' CNPJ: 14 numeric digits then TDocs.IsValidCNPJ
   ' Nome set without CPF/CNPJ → "Ao informar um [Devedor.Nome], ..."
   ' InfoAdicionais item with Nome or Valor "" → both fields obrigatórios
   ' if any error, appends "Conteúdo Cobrança:" + pDados.ToString()
End Function

Sub EnsureCobranca(pDados As PixCobranca)
   ' throws CHAR(13) & "Dados Cobrança Inválido:" & CHAR(13) & errors
End Sub

Sub EnsureTxId(pTxId As String)          ' "" → "TxId é obrigatório"
Sub EnsureE2eId(pEndToEndId As String)   ' "" → "EndToEndId é obrigatório"

Sub EnsureFiltro(pFiltros As PixFiltro)
   ' empty DataInicio or DataFim (IsEmptyDate) → "Intervalo de datas inválido, é necessário informar uma data inicial e final para consulta"
   ' DataInicio > DataFim → "Intervalo de datas inválido, data inicial é maior que a data final"
End Sub

Sub EnsureDevolucao(pTxId As String, pEndToEndId As String, pIdDevolucao As String, pValor As Currency)
   ' EnsureTxId, EnsureE2eId; Id "" → "Id da devolução é obrigatório"; ValidateValue
End Sub
```

Devedor is optional when CPF, CNPJ, and Nome are all `""`.

---

## HTTP (`PixHttp`)

`PixHttp` extends `HttpClient` (`mod_http`). Constructor: `Http.DefaultTransport()` + `Psp.BaseUrl(Sandbox)`, `Timeout = config.Timeout`.

Throws `"PixHttp requer PixConfig"` / `"PixHttp requer PixPsp na configuração"` from `ResolveBaseUrl`.

Transport selection is `mod_http`: project parameter `Customizado_Projeto_ClientePadraoModuloHttp` = `CURL` selects CURL (needed on hosts that cannot open TLS via WinHttp).

```basic
Shared Function UrlEncode(pValue As String) As String    ' http_url.Encode

Shared Function DownloadToFile(pUrl As String, pPath As String) As String
   ' GET without client certificate; not 2xx → throw response.ToString()
   ' success: SaveToFile(pPath), returns pPath
End Function

Function RequestJson(pMethod As String, pEndpoint As String, pPayload As String = "") As TJSONObject
   ' GET / POST / PUT / PATCH / DELETE (UCase). else "Método HTTP não suportado: ..."
   ' empty payload → Request(method, endpoint); else Request(method, endpoint, payload)
   ' returns response.Data.AsJson; frees the HttpResponse
End Function

Sub LoadCertificate()
   ' once: Certificate.Load(config.Certificate.Path, Pass)
End Sub

Function AccessToken() As PixAccessToken
```

**Request pipeline**

1. `OnRequest`: `LoadCertificate`, `Authenticate`, header `Authorization` = token `AsAuthorization`.
2. `AfterRequest`: `Params.Clear()`; if status not in `200..299`, `CheckResponse` throws `response + request + "Request Body:" + body`.

**Token (`LoadToken`)** — `client_credentials` POST to `Psp.AuthUrl(Sandbox)`:

1. Separate `HttpClient` with the same certificate (`CleanOnFree = False`).
2. Default headers: `Authorization` = credentials Basic, plus `grant_type` / `client_id` / `client_secret`.
3. Default body: `grant_type=client_credentials&scope={Scopes()}&client_id=...&client_secret=...`.
4. `LoadToken_PreRequest` (bank hook) may replace headers/params/body.
5. Status must be `200` (not any 2xx). Parses `access_token`, `token_type`, `scope`, `expires_in`.
6. `LoadToken_PostRequest`.
7. Failure wraps as `"Erro ao obter token de autenticação PIX:"`.

`Authenticate` reloads when `_token` is `NULL` or `IsExpired` (`DateTime() > ExpiresAt`). A fresh `PixAccessToken` has `ExpiresIn = 0`, so the first request always loads.

### `PixAccessToken`

| Field | Notes |
|---|---|
| `Token` | `access_token` |
| `Type` | `token_type` |
| `Scopes` | `scope` |
| `CreatedAt` | set in ctor (read-only) |
| `ExpiresAt` | `CreatedAt.AddSeconds(ExpiresIn)` when `ExpiresIn` is set |
| `ExpiresIn` | `expires_in` |

```basic
Function AsAuthorization() As String   ' Type & " " & Token
Function IsExpired() As Boolean
Shared Function FromJson(pJson As TJSONObject) As PixAccessToken
```

### `PixHttpPairs` / `PixHttpAuthRequest`

Thin wrappers so token hooks can `Clear` / `Define` on the auth client's headers/params and set `ContentType` / `Accept`.

### HTTP overridable hooks

| Hook | Purpose |
|---|---|
| `CheckResponse` | throw on non-2xx (default) |
| `Authenticate` | refresh expired token |
| `LoadToken` | full token POST |
| `LoadToken_PreRequest` | mutate auth request/body (default no-op) |
| `LoadToken_PostRequest` | mutate parsed token (default no-op) |

`PixHttp` does not own `PixConfig` (`Free` nulls it).

---

## Providers

### `PixClientBacen`

Must-inherit HTTP client. Clones `pConfig`, calls `ApplyProfile`, `CreateCapabilities` (`FullRecebimento`), `CreateHttp` (`New PixHttp`). Throws `"PixClientBacen requer PixConfig"`.

```basic
MustOverride Sub ApplyProfile(pConfig As PixConfig)
Overridable Function CreateHttp() As PixHttp
Overridable Function CreateCapabilities() As PixCapabilities
Overridable Function CreateFiltroFormatter() As PixFiltroFormatter

Protected Function Execute(pMethod As String, pEndpoint As String, pPayload As String = "") As TJSONObject
Protected Function ParseCobranca(pData As TJSONObject) As PixCobrancaCompleta
   ' FromJson(..., TimeZoneHours) then pData.Free()
End Function
```

Default cob/pix endpoints (payload `ToJson()` unless noted):

| Method | HTTP |
|---|---|
| `CobrancaRegistrar` | `PUT /cob/{TxId}` |
| `CobrancaAlterar` | `PATCH /cob/{TxId}` |
| `CobrancaCancelar` | `PATCH /cob/{TxId}` body `{"status":"REMOVIDA_PELO_USUARIO_RECEBEDOR"}` |
| `CobrancaConsultar` | `GET /cob/{TxId}` |
| `CobrancaListar` | `GET /cob?{FilterQuery}` |
| `PixConsultar` | `GET /pix/{e2e}` |
| `PixListar` | `GET /pix?{FilterQuery}` |
| `DevolucaoRegistrar` | `PUT /pix/{e2e}/devolucao/{id}` body `e2eid`, `id`, `valor` |
| `DevolucaoConsultar` | `GET /pix/{e2e}/devolucao/{id}` |

`FormatFiltro` = `CreateFiltroFormatter().ToParamsString(filtros, TimeZoneHours)`.

### Bank profiles

`ApplyProfile` overwrites `TimeZoneHours`, sometimes `Version`, and always replaces `Psp`. `GetName` literals: `Sicredi`, `Sicoob`, `Itau`, `Santander`, `Bradesco`, `Memory`.

| Client | TZ | API / auth | Homolog base (Sandbox=`True`) | Production base (Sandbox=`False`) | Token hook |
|---|---|---|---|---|---|
| `PixClientSicredi` | `-4` | forces v2 / v2 | `https://api-pix-h.sicredi.com.br/api/v2` | `https://api-pix.sicredi.com.br/api/v2` | query `grant_type`, `client_id`, `client_secret`, `scope`; **empty body** |
| `PixClientSicoob` | `-4` | `pConfig.Version` | `https://sandbox.sicoob.com.br/sicoob/sandbox/pix/api/v{Version}` | `https://api.sicoob.com.br/pix/api/v{Version}` | clear headers/params; form content-type |
| `PixClientItau` | `-1` | `pConfig.Version`; sandbox path uses `VersionAuth` | `https://sandbox.devportal.itau.com.br/itau-ep9-gtw-pix-recebimentos-ext-v2/v{VersionAuth}` | `https://pix-pj.api.itau.com/regulatorio-pix/v{Version}` | clear headers/params; form content-type |
| `PixClientSantander` | `-1` | forces v1 / auth v2 | `https://trust-pix-h.santander.com.br/api/v1` | `https://trust-pix.santander.com.br/api/v1` | query `grant_type` only; post-request `Type="Bearer"` |
| `PixClientBradesco` | `-4` | forces v2 / v2 | `https://qrpix-h.bradesco.com.br/v2` | `https://qrpix.bradesco.com.br/v2` | Basic `Authorization` header; body `grant_type=client_credentials` |

Auth URLs:

```text
Sicredi homolog: https://api-pix-h.sicredi.com.br/oauth/token
Sicredi prod:    https://api-pix.sicredi.com.br/oauth/token
Sicoob both:     https://auth.sicoob.com.br/auth/realms/cooperado/protocol/openid-connect/token
Itaú both:       https://sts.itau.com.br/api/oauth/token
Santander both:  https://trust-pix.santander.com.br/oauth/token
Bradesco homolog: https://qrpix-h.bradesco.com.br/oauth/token
Bradesco prod:    https://qrpix.bradesco.com.br/oauth/token
```

**Itaú `CobrancaAlterar`:** `CobrancaConsultar` then `BuildPatch(atual, novo)` then base PATCH. Unchanged fields are blanked so `ToJson` omits them: `Chave`/`SolicitacaoPagador`/`Devedor.*` → `""`; `Valor.Original` → `0`; `ModalidadeAlteracao` → `NULL`; `Expiracao` → `-1`.

**Santander:** `CanCobrancaListar` / `CanPixConsultar` false. `CobrancaListar` / `PixConsultar` still throw PSP messages if called on the client directly. Registrar uses `ToJson("txID")`. Alter/cancel PATCH absolute URL `VersionedBaseUrl(Sandbox, 2) & "/cob/" & TxId` (v2 host). `BuildPatch` sets `TxId=""` and `Revisao=-1`.

**Bradesco:** `BuildCreate` sets `Revisao=-1` and registrar uses `ToJson("txID")`. `BuildPatch` sets `TxId=""`, `Revisao=-1`. `DevolucaoRegistrar` body is only `{"valor":"..."}` (no `e2eid`/`id`). Filter via `PixFiltroFormatterBradesco` (millis + default 100 items). Shared `FilterQuery(pFiltros, pTimeZoneHours)` is the same formatter.

### `PixClientMemory`

In-process store. Clones config. Caps = `PixCapabilities.Memory()`. Throws `"PixClientMemory requer PixConfig"`.

| Operation | Behavior |
|---|---|
| `CobrancaRegistrar` | duplicate TxId → `"Já existe cobrança com TxId ..."`. Status `ATIVA`, `Revisao=0`, `Criacao=DateTime()`, `Location="pix.memory.local/cob/" & TxId`, EMV from location. Returns **clone**. |
| `CobrancaAlterar` | not active → `"Cobrança não está ativa e não pode ser alterada"` |
| `CobrancaCancelar` | not active → `"Somente cobrança ativa pode ser cancelada"` → status `REMOVIDA_PELO_USUARIO_RECEBEDOR` |
| `CobrancaConsultar` / missing | `"Cobrança não encontrada: " & TxId` |
| `CobrancaListar` | `Status` if Assigned; `Criacao` in `[DataInicio, DataFim]`. Does **not** filter CPF/CNPJ. Copies `Pagina`/`ItensPorPagina` without slicing. |
| `PixConsultar` | `"PIX não encontrado: "` |
| `PixListar` | `Horario` in `[DataInicio, DataFim]` only |
| `DevolucaoRegistrar` | PIX missing / TxId mismatch; status `DEVOLVIDO`; `RtrId="D" & id` |
| `DevolucaoConsultar` | PIX or id missing |

```basic
Function SimulatePayment(pTxId As String, pValor As Double = 0) As PixRecebimento
   ' not active → "Somente cobrança ativa pode ser paga"
   ' pValor <= 0 → cob.Valor.Original
   ' E2eId = "E" & TxId; cob → CONCLUIDA; returns clone
End Function
```

Returned objects are clones; the consumer owns them. Internal lists stay inside the client until `Dispose`.

---

## Ledger

### `PixLedger` / `PixNullLedger`

```basic
Overridable Sub SaveCobranca(pCobranca As PixCobrancaCompleta, pDataCancelamento As TDateTime = 0)
   ' base / PixNullLedger: no-op
End Sub
```

### `PixMovimentoLedger`

Throws `"PixMovimentoLedger requer PixConfig"`. Stores `CodEmpresa`, `CodFilial`, `CodContaFinanceira` from config.

`SaveCobranca` no-op if `pCobranca` is not Assigned. Lookup: `CodMovimentoPix > 0` then `TxID`. Insert fills empresa/filial/conta/TxID. Always writes copia-e-cola, valor, status string, `DataCriacao`, `DataExpiracao`, `DataCancelamento`. If `Recebimentos.Length > 0`, takes **index 0** only (`EndToEndID`, valor, first devolucao id/status/date). `Devolvido` → `Horario.Liquidacao`, else `Solicitacao`. `Upsert`, then `pCobranca.CodMovimentoPix = mov.CodMovimentoPix`.

### `MovimentoPix`

`TTableOf<MovimentoPix>` table `Financeiro.MovimentoPix`. PK `CodEmpresa` + `CodMovimentoPix`. `GetID` = `CodEmpresa|CodMovimentoPix`.

```basic
Sub New()
Sub New(pValue As MovimentoPix)
Shared Function Initilized(pCodEmpresa As Integer, pCodFilial As Integer, pCodMovimentoPix As Integer = 0) As MovimentoPix
   ' typo in source: Initilized. EnsureIdentity.
End Function

Overrides Sub BeforeInsert()
Overrides Sub BeforeMerge()
Sub Fill(pValue As MovimentoPix)
Function Copy() As MovimentoPix
```

`EnsureIdentity`: `CodMovimentoPix=0` → `Data7.ProximoCodigo("MovimentoPix", CodEmpresa)`; empty `Hora` → `Data=DateTime()`, `Hora=hh:nn:ss`; empty `NomeUsuario` → `Data7.NomeUsuario`; empty `EstacaoTrabalho` → `Environment.MachineName`. `CodFilial`, `CodContaFinanceira`, `TxID`, `Data`, `Hora`, `NomeUsuario`, `EstacaoTrabalho` are `NotUpdatable`.

| Property | Column | Max |
|---|---|---|
| `CodEmpresa` | PK int | |
| `CodMovimentoPix` | PK int | |
| `CodFilial` | int | |
| `CodContaFinanceira` | string | 50 |
| `TxID` | string | 35 |
| `EndToEndID` | string | 32 |
| `IDDevolucao` | string | 35 |
| `PixCopiaECola` | string | 1000 |
| `Valor` | float (`Extended`) | |
| `Status` | string | 50 |
| `StatusDevolucao` | string | 50 |
| `DataCriacao` / `DataExpiracao` / `DataCancelamento` / `DataDevolucao` / `Data` | datetime | |
| `Hora` | string | 8 |
| `NomeUsuario` / `EstacaoTrabalho` | string | 100 |

---

## ERP (`PixErp`)

```basic
Shared Function FromContaFinanceira(pCodContaFinanceira As String) As PixConfig
```

SQL: `ContaFinanceira` ⋈ `Geral.ParametroApi` ⋈ `CertificadoDigital` where `CodContaFinanceira = :CodContaFinanceira`.

Throws:

- query error: `"Erro ao carregar configurações PIX da conta financeira [{id}]: ..."`
- no row: `"Nenhuma conta financeira válida encontrada para o parâmetro de busca: [{id}]"`
- empty `NumeroBanco`: `"Número do banco não informado na conta financeira [{id}]."`
- `PixBanco.Load` fail: `"O banco [{NumeroBanco}] não é suportado. Informe um número de banco válido."`

Writes PFX to `TPath.GetTempPath() & "\" & CertificadoDigital.ID & ".pfx"`. Maps `ClientID`/`ClientSecret`, `ChavePix`, `VersaoApi`, `CodEmpresa`, `CodFilial=Data7.CodFilial()`, `Sandbox = UCase(Ambiente) <> "PRODUCAO"`.

---

## Utils (`mod_pix_utils`)

```basic
Function GenerateTxID(pLenght As Integer = 35) As String
   ' cap 35; Data7.Criptografar(DateTime string).Right(pLenght)
End Function

Function GenerateIDDevolucao() As String
   ' GenerateTxID(20)
End Function

Function FormatValueToString(pValor As Double) As String   ' "10.50" (dot decimal)
Function FormatValueToDouble(pValor As String) As Double     ' "." → "," then CDbl

Function IsEmptyDate(pDate As TDateTime) As Boolean          ' ToInt32() = 18991230

Function DateToUTC(pDate As TDateTime, pTimeZoneHours As Integer = 0) As TDateTime
   ' AddHours(-pTimeZoneHours)  ' tz -4 → UTC = local + 4 hours
End Function

Function DateToISO8601(pDate As TDateTime, pTimeZoneHours As Integer = 0) As String
   ' yyyy-mm-ddThh:nn:ss.zzZ
End Function

Function DateToQueryParam(pDate As TDateTime, pTimeZoneHours As Integer = 0) As String
   ' yyyy-mm-ddThh:nn:ssZ
End Function

Function DateToISO8601Millis(pDate As TDateTime, pTimeZoneHours As Integer = 0) As String
   ' yyyy-mm-ddThh:nn:ss.xxxZ  (3-digit ms)
End Function

Function ParseISO8601(pValue As String) As TDateTime
   ' positions 1..10 date, 12..16 time; optional :ss and .fraction
End Function

Function GerarPixCopiaECola(pLocation As String) As String
   ' strips leading "https://"; EMV 00/26(GUI br.gov.bcb.pix + 25 url)/52/53=986/58=BR/59=PIX/60=Cidade/62=0503***/63=CRC16
End Function

Function BuildFieldEMV(pId As String, pValue As String) As String
Function CRC16CCITT(pData As String) As String   ' 4 hex chars
```

---

## Extending (Consumer Project)

There is no `Add` / `Make` / `MakeByName` catalog. There are no forms in this module.

To add a PSP:

1. Inherit `PixPsp` — override `FillUrls` (homolog `Add` first, production second) and optionally `FillScopes` / `Clone`.
2. Inherit `PixHttp` — override `LoadToken_PreRequest` / `LoadToken_PostRequest` if the token POST is not the default form body.
3. Inherit `PixClientBacen` (or `PixClient`) — implement `ApplyProfile` and `GetName`; override `CreateHttp`, `CreateCapabilities`, `CreateFiltroFormatter`, and cob/pix methods when the JSON/URL differs.
4. Construct it and wrap:

```basic
Dim client As PixClient = New PixClientMeuBanco(config)
Dim pix As PixService = New PixService(client, True)
' or persist: New PixService(client, New PixMovimentoLedger(config), True, True)
```

`PixService.Load` / `CreateClient` only dispatch Memory / Sicredi / Sicoob / Itau / Santander / Bradesco. A new bank is not picked up until the consumer constructs the client (or the module adds a branch).

Custom ledger: inherit `PixLedger`, override `SaveCobranca`. Custom filter dates: inherit `PixFiltroFormatter`. Capability-gated features (`cobv`, pagamento, webhook) stay off until `CreateCapabilities` sets the flags **and** the client implements the methods.

---

## Tests

`PixTests.RunAll()` — in-memory / pure tests: capabilities (Santander vs full, cobv/pagamento/webhook off), TxId/devolucao id length, money + ISO-8601 + EMV CRC, filtro query (including UTC `-4` → `04%3A00%3A00Z`), cobranca JSON roundtrip, validator (short TxId, missing chave, bad CPF, valid payload), Memory register/alter/list/cancel/pay/refund and reject alter-when-concluida, bank `ApplyProfile` (Sicredi/Santander/Bradesco URLs and scopes), factory names/timezones, Santander capability blocks, Itaú/Santander/Bradesco patch JSON omit rules, Bradesco millis filter + default page size 100, Basic authorization without line breaks, blocked cobv/pagamento/webhook slots.

`PixLiveTests.Run(pContaFinanceira, pTelefone)` — `PixErp.FromContaFinanceira` + `PixService.Load`, logs capabilities, asserts cobv/pagamento/webhook blocked, rejects inverted dates, lists PIX/cob (skips when caps are off), cob register/consult/alter/cancel, and a payment/refund cycle that waits for operator confirmation. `pTelefone` is stored for a commented WhatsApp path. `RunHomologados(pTelefone)` runs `SIC`, `SICA`, `BI`, `SAN`.

---

## Module Notes

- `PixService.Load` clones config inside the client; the consumer still owns the `PixConfig` passed in. `pix.Config()` is the client's clone, not a third copy.
- Lists and `Consultar`/`Registrar` results are owned by the caller (`Memory` returns clones). Nested `Valor` / `Calendario` / `Devedor` / `InfoAdicionais` / `Recebimentos` / `Devolucoes` are owned by the parent model.
- Ledger writes on cob `Registrar` / `Alterar` / `Cancelar` (cancel passes `DateTime()` as `pDataCancelamento`) and on devolucao `Registrar` using the **pre-refund** cob consult. `Consultar` / `Listar` do not persist. `CodEmpresa = 0` → `PixNullLedger` no-op.
- JSON sentinels: omit when `""`, `Revisao = -1`, `Expiracao = -1`, `Original = 0`. Itaú/Santander/Bradesco patches rely on those sentinels. Default integers are `0`, so they serialize unless a builder sets `-1`.
- `PixBanco.BBrasil = "1"` is not wired in `CreateClient`. Stock `CanCobrancaVencimento` / `CanPagamento` / `CanWebhook` are `False`.
- `PixPsp` URL lists: first `Add` = sandbox, second = production. `Timeout` default is 10 seconds. Certificate is loaded once per `PixHttp` instance.
- Memory list filters cob by status + `Criacao` range and PIX by `Horario` range; it does not paginate or match CPF/CNPJ.
- Canonical tests: `PixTests.RunAll()`. Live PSP: `PixLiveTests.Run` with an ERP `CodContaFinanceira`.
