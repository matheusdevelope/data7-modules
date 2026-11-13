# mod_pix_app_whatsapp_sharer

WhatsApp sharer for the Pix app: builds a Pix Copia e Cola text, opens `WaCompose` with Evolution GO (optional) and WhatsApp Desktop, and lets the operator pick a recipient and send. It does not load the cobrança, watch payment status, print or copy the QR, attach the QR image, or send without the compose UI — that stays in `mod_pix_app` / the operator.

Version: `1.0.2.0`. Dependencies (`data7.json`): `mod_whatsapp` `1.0.0.0`, `mod_pix_app` `1.0.2.0`.

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## Quick Start (Minimal)

```bas
Imports mod_pix_config
Imports mod_pix_erp
Imports mod_pix_runtime
Imports mod_pix_cobranca_completa
Imports mod_pix_app_qrcode
Imports mod_pix_app_whatsapp_sharer

Dim _config As PixConfig = PixErp.FromContaFinanceira("SIC")
Dim _service As PixService = PixService.Load(_config)
Dim _cob As PixCobrancaCompleta = _service.Cobranca.Consultar("27DFA64AF8A8A8B84EB147DFB7995FB6AE7")
Dim _form As New PixAppQrCode(_service, "Pagamento com Pix", New PixAppWhatsappSharer())
' 3rd arg: this sharer → Btn3 + Hint + Ctrl+W. Null = no WhatsApp button.
_form.Show(_cob)
_form.Free()
_cob.Free()
_service.Free()
_config.Free()
```

Call `Share` yourself when there is no QR dialog:

```bas
Imports mod_pix_app_share
Imports mod_pix_app_whatsapp_sharer

Dim _sharer As New PixAppWhatsappSharer()
Dim _req As New PixAppShareRequest(_cob)   ' QrCodePath default ""
_sharer.Share(_req)                         ' opens WaCompose; this module ignores QrCodePath
_req.Free()
_sharer.Free()
```

---

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_pix_app_whatsapp_sharer.bas` | `mod_pix_app_whatsapp_sharer` | `DelegateOnBeforeShare`, `PixAppWhatsappSharer` |

`src/Principal.bas` declares no namespace: demo entrypoint (consult a cobrança → `PixAppQrCode` with `PixAppWhatsappSharer`). There is no `TXxxTests.RunAll`.

---

## Sharer

`PixAppWhatsappSharer` is a `PixAppSharer`: the Pix QR dialog stores it, paints Btn3 from `IconBase64()`, uses `Hint()` as the tooltip, and calls `Share` from Btn3 or Ctrl + `ShortcutKey()`.

### `DelegateOnBeforeShare`

Hook after the message is filled and before `WaCompose.Show`. Both arguments are `ByRef`.

```bas
Delegate Sub DelegateOnBeforeShare(ByRef pCompose As WaCompose, ByRef pCanShare As Boolean)
   ' in/out: pCompose already has clients, Title, Content
   ' in/out: pCanShare starts True; set False to skip Show (compose is still Freed)
End Sub
```

`OnBeforeShare = Null` → skip the hook.

### `PixAppWhatsappSharer`

Concrete WhatsApp implementation of `PixAppSharer`.

| Member | Type | Default | Role |
|---|---|---|---|
| `OnBeforeShare` | `DelegateOnBeforeShare` | `Null` | mutate compose or cancel `Show` |

```bas
Sub New()
   ' no parameters
End Sub

Overrides Function Hint() As String
   ' out: "Enviar Pix&Cola pelo WhatsApp (Ctrl + W)"
End Function

Overrides Function IconBase64() As String
   ' out: embedded 24×24 PNG (WhatsApp-style), used by PixAppQrCode.Btn3.LoadFromBase64
End Function

Overrides Function ShortcutKey() As Integer
   ' out: 87 (W). PixAppQrCode fires Share on Ctrl + this key when value > 0
End Function

Overrides Sub Share(pRequest As PixAppShareRequest)
   ' in: pRequest.Cobranca (required for tokens). pRequest.QrCodePath is ignored
   ' 1. New WaCompose; register Evolution GO if ERP host+token are set; always register Desktop
   ' 2. Message().Content = template with tokens from pRequest.ApplyTokens
   ' 3. OnBeforeShare(compose, canShare) if assigned; canShare starts True
   ' 4. If canShare Then compose.Show()
   ' 5. compose.Free() always (owns registered clients)
End Sub
```

Does not return `Null`. `Share` is a `Sub`.

**No-op:** `OnBeforeShare` unset; `pCanShare = False` after the hook (`Show` skipped). Missing Evolution credentials skip that client only — Desktop still opens.

**Throws (this module):** Evolution GO construction is wrapped in `Try`/`Catch` and becomes a skip, not a throw. `Share` does not catch `Show`, `ApplyTokens`, or a throwing `OnBeforeShare`. A `Null` `pRequest` / `Cobranca` fails at token replace.

---

## Share flow

`Share` always builds a fresh `WaCompose` and frees it when `Show` returns.

1. **Evolution GO** (optional). Reads `Trim(Data7.Parametro(...))`. Both empty → no Evolution client. Otherwise `WaEvolutionGoOptions.FromCombinedToken(host, token, "")` and `New WaClientEvolutionGo(options, True)`. Any exception (bad token shape, `Validate`, HTTP setup) → skip Evolution.
2. **Desktop** (always). `New WaClientDesktop(New WaDesktopOptions(), True)` — default window title `"WhatsApp"`, `AutoSend = True`.
3. **Defaults on compose.** `Title = "PIX via WhatsApp"`, `CanChangeClient = True`. `DefaultClient` is `"EvolutionGO"` when that client exists, else `"Desktop"`.
4. **Message.** `compose.Message().Content` = ERP template or built-in text, then `pRequest.ApplyTokens`.
5. **Hook / show.** `OnBeforeShare` may change recipients, content, client, or set `pCanShare = False`. This module does not set `Recipient`. The operator sends from the compose UI.

Registered clients:

| UI label | Client key (`GetName()`) | When |
|---|---|---|
| `"Evolution GO"` | `"EvolutionGO"` | host and token both non-empty after `Trim`, and construction succeeds |
| `"WhatsApp Desktop"` | `"Desktop"` | always |

`RegisterClient(..., pOwnsClient = True)`: `compose.Free()` frees both clients (and their options).

---

## Message template and tokens

ERP string `Customizado_Projeto_Pix_ConteudoMensagemWhatsapp`. After `Trim`, empty → this built-in text (WhatsApp `*bold*`):

```text
Pagamento via PIX


Segue abaixo os dados para pagamento do Pix no valor de:
*R$ @Valor*
*Obs:* @SolicitacaoPagador

Copie o código abaixo e cole no seu aplicativo de banco.

*Pix Copia e Cola:*
@PixCopiaECola
```

Example ERP override:

```text
Pix R$ @Valor
@Nome (@CNPJ_CPF)
@PixCopiaECola
```

Tokens come from `PixAppShareRequest.ApplyTokens` → `ReplaceTokens` on `Cobranca`:

| Token | Source |
|---|---|
| `@TxId` | `Cobranca.TxId` |
| `@Revisao` | `Cobranca.Revisao.ToString()` |
| `@SolicitacaoPagador` | `Cobranca.SolicitacaoPagador` |
| `@Chave` | `Cobranca.Chave` |
| `@PixCopiaECola` | `Cobranca.PixCopiaECola` |
| `@Status` | `Cobranca.Status.AsString` |
| `@Location` | `Cobranca.Location` |
| `@Valor` | `Cobranca.Valor.Original.ToString()` |
| `@ModalidadeAlteracao` | `Cobranca.Valor.ModalidadeAlteracao.AsString` |
| `@Nome` | `Cobranca.Devedor.Nome` |
| `@CPF` | `Cobranca.Devedor.CPF` |
| `@CNPJ` | `Cobranca.Devedor.CNPJ` |
| `@CNPJ_CPF` | CPF if non-empty, else CNPJ if non-empty; **if both `""` the token is left as `@CNPJ_CPF`** |
| `@Data` | `Cobranca.Calendario.Criacao` `"dd/mm/yyyy"` |
| `@Hora` | `Cobranca.Calendario.Criacao` `"hh:nn:ss"` |
| `@Expiracao` | `Cobranca.Calendario.Expiracao.ToString()` |
| `@DataExpiracao` | `Cobranca.Calendario.DataExpiracao()` `"dd/mm/yyyy"` |
| `@HoraExpiracao` | `Cobranca.Calendario.DataExpiracao()` `"hh:nn:ss"` |

Unknown tokens are not stripped.

---

## ERP parameters

| `Data7.Parametro` | Contract |
|---|---|
| `Customizado_Projeto_Pix_ConteudoMensagemWhatsapp` | message body; `Trim` empty → built-in template |
| `WHATSAPP_HOSTDATA7MANAGER` | Evolution GO host; `Trim` empty → skip Evolution |
| `WHATSAPP_TOKENDATA7MANAGER` | combined token `master@instance` (must contain `@`); `Trim` empty → skip Evolution |

Evolution instance name is passed as `""`. `FromCombinedToken` splits the token on the first `@` into master token and instance token. Missing `@` throws inside Evolution setup and is caught → Desktop only.

---

## Extending (Consumer Project)

This module has no UI of its own. Wire it by passing an instance into `PixAppQrCode` (`pSharer`), or by calling `Share`. There is no catalog / `MakeByName`.

Inherit to change hint, icon, shortcut, or the whole share body. Assign `OnBeforeShare` to tweak compose without subclassing.

```bas
Imports mod_wa_compose
Imports mod_pix_app_whatsapp_sharer

Class MyPixWhatsappSharer
   Inherits PixAppWhatsappSharer

   Sub New()
      MyBase.New()
      me.OnBeforeShare = me.HandleBeforeShare
   End Sub

   Overrides Function Hint() As String
      Hint = "Enviar Pix pelo WhatsApp"
   End Function

   Overrides Function ShortcutKey() As Integer
      ShortcutKey = 0   ' 0 = PixAppQrCode does not bind Ctrl+key
   End Function

   Private Sub HandleBeforeShare(ByRef pCompose As WaCompose, ByRef pCanShare As Boolean)
      pCompose.Message().Recipient = "5566999999999"
      ' pCanShare = False  ' skip Show
   End Sub
End Class
```

Overridable hooks (no bodies here): `Hint`, `IconBase64`, `ShortcutKey`, `Share`. Plus field `OnBeforeShare`.

To replace WhatsApp entirely, inherit `PixAppSharer` in the consumer — that is a different sharer, not this module.

---

## Module Notes

- `Share` owns the `WaCompose` it creates: `Free` after `Show`, including when `pCanShare` is `False`. Clients are registered with `pOwnsClient = True`.
- Evolution GO is best-effort. Empty `WHATSAPP_HOSTDATA7MANAGER` / `WHATSAPP_TOKENDATA7MANAGER`, or any construction error, leaves only Desktop. Desktop is never skipped.
- `QrCodePath` on `PixAppShareRequest` is unused. No attachment is added; only `Message().Content` is set.
- Compose is not persisted. Each `Share` starts with `Title = "PIX via WhatsApp"`, `CanChangeClient = True`, and `DefaultClient` `"EvolutionGO"` or `"Desktop"`.
- `ShortcutKey = 87` is the virtual-key for W. The Ctrl chord is implemented by `PixAppQrCode`, not by this class. Return `0` in a subclass to disable it.
- `@CNPJ_CPF` is the only token that may remain in the text (`CPF` and `CNPJ` both empty). Other listed tokens always replace.
- Consumer owns `PixAppWhatsappSharer`, the `PixAppShareRequest` if you construct it, and the cobrança / `PixService` lifetime. This module does not `Free` `pRequest` or `Cobranca`.
- No unit-test type. `Principal.bas` is the runnable demo: ERP conta `"SIC"` + `PixAppQrCode` + this sharer.
