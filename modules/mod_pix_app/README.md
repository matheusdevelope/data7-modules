# mod_pix_app

Desktop UI for listing, consulting, registering, refunding, and cancelling PIX charges against a financial account already configured in the ERP (`CodParametroApi IS NOT NULL`). Version **1.0.2.0**. It does **not** implement PSP HTTP clients, PIX domain types, or a share/send channel: those come from `mod_pix` and from the consumer. Opening a PIX account is done through `PixErp.FromContaFinanceira` / `PixService.Load`; this module only binds that service to the form.

Declared dependencies in `data7.json`: `mod_pix` 1.0.2.0, `mod_http` 2.0, `mod_grid` 1.0.0.2, `mod_forms` 1.0.0.0, `mod_editors` 1.0.0.1.

This file is the module contract. Consumers can assemble, extend, and call the API from it. Open a `.bas` file only to confirm a detail that is not stated here.

## Quick Start (Minimal)

```bas
Imports mod_pix_app
Imports mod_pix_app_qrcode
Imports mod_pix_app_share
Imports mod_pix_runtime
Imports mod_pix_cobranca_completa

' Empty workspace: user picks the account and searches.
PixApp.Run()

' CONSULTAR process: bind account and consult TxId as soon as the account opens.
PixApp.Run("123", "E12345678901234567890123456789012")

' Optional: QR screen with a consumer-owned sharer (workspace itself never injects one).
Dim sharer As New MeuPixSharer()
Dim qr As New PixAppQrCode(service, "Pagamento com Pix", sharer)
Dim cob As PixCobrancaCompleta = qr.Show(cobranca)
qr.Free()
sharer.Free()
```

`src/Principal.bas` is the ERP table-process entry (not a test runner). There is no `TXxxTests.RunAll` in this module.

```bas
Imports mod_pix_app

' @data7:keep-name
Dim CodContaFinanceira As String
' @data7:keep-name
Dim TxID As String
' @data7:keep-name
Dim TituloProcessoTabela As String

If TituloProcessoTabela.Trim.ToUpper() = "CONSULTAR" Or TituloProcessoTabela.ToUpper() = "CONSULTAR PIX" Then
   PixApp.Run(CodContaFinanceira, TxID)
Else
   PixApp.Run()
End If
```

## Namespace Map

| File | Namespace | Types |
| --- | --- | --- |
| `src/lib/mod_pix_app.bas` | `mod_pix_app` | `PixApp` |
| `src/lib/form/mod_pix_app_workspace.bas` | `mod_pix_app_workspace` | `PixAppAction`, `PixAppWorkspace` |
| `src/lib/session/mod_pix_app_session.bas` | `mod_pix_app_session` | `PixAppStatusNotify`, `PixAppSession` |
| `src/lib/dialogs/mod_pix_app_share.bas` | `mod_pix_app_share` | `PixAppShareRequest`, `PixAppSharer` |
| `src/lib/dialogs/mod_pix_app_qrcode.bas` | `mod_pix_app_qrcode` | `PixAppQrCode`, `PixForm`, `DelegateOnShowClose`, `DelegateCan`, `DelegateOnKeyDown` |
| `src/lib/dialogs/mod_pix_app_refund.bas` | `mod_pix_app_refund` | `PixAppRefundDialog` |
| `src/lib/adapters/mod_pix_app_adapters.bas` | `mod_pix_app_adapters` | `PixAppSurface`, `PixAppGroup`, `PixAppFormat`, `PixAppServiceAdapter`, `PixAppFilterMapper`, `PixAppGridMapper`, `PixAppSampleFactory` |
| `src/lib/panels/mod_pix_app_account.bas` | `mod_pix_app_account` | `PixAppAccountPanel` |
| `src/lib/panels/mod_pix_app_browse.bas` | `mod_pix_app_browse` | `PixAppBrowsePage` |
| `src/lib/panels/mod_pix_app_filters.bas` | `mod_pix_app_filters` | `PixAppFilterPanel` |
| `src/lib/panels/mod_pix_app_list.bas` | `mod_pix_app_list` | `PixAppListPanel` |
| `src/lib/panels/mod_pix_app_detail.bas` | `mod_pix_app_detail` | `PixAppDetailPanel` |
| `src/lib/panels/mod_pix_app_pager.bas` | `mod_pix_app_pager` | `PixAppPager` |
| `src/lib/panels/mod_pix_app_create.bas` | `mod_pix_app_create` | `PixAppCreatePanel` |

## Entry and workspace

### `PixApp`

Facade. Owns the workspace for the duration of `Show()`.

```bas
Shared Sub Run(pCodContaFinanceira As String = "", pTxId As String = "")
   ' in: optional ERP account code and TxId (both Trim'd inside the workspace)
   ' out: modal PIX workspace; always Free'd after Show returns
End Sub
```

| Call | Effect |
| --- | --- |
| `Run()` | Empty UI. User must pick a financial account. |
| `Run(conta, "")` | Prefills the account search and binds the PIX service. No consult. |
| `Run("", txId)` | Prefills Cobranças TxId. Status asks the user to pick an account. Consult runs when the account binds. |
| `Run(conta, txId)` | Binds the account; if the service opens, consults that TxId immediately. |

Invalid account: the account panel shows `"Não foi possível abrir a conta financeira:"` plus the exception message, then unbinds. TxId stays in the filter.

### `PixAppAction`

```bas
Delegate Sub PixAppAction()
```

Used internally by `PixAppWorkspace` to run a busy action. Consumers do not register this.

### `PixAppWorkspace`

`TFormsWorkspace` titled `"PIX"`. Size 95% of the work area, header 38px, footer 26px, `CloseOnOk = False`, Cancel caption `"Fechar"`, Ok hidden.

```bas
Sub New(pCodContaFinanceira As String = "", pTxId As String = "")
```

Show the form with inherited `Show()`. After show:

1. Sync layout.
2. If TxId is non-empty, write it into Cobranças `SetLookupId`.
3. If account is non-empty, `PixAppAccountPanel.SetCodigo`.
4. Focus the account editor.

Tabs (index): `0` Cobranças (`"cob"`), `1` Recebimentos (`"pix"`), `2` Devoluções (`"dev"`), `3` Nova cobrança (`"new"`).

Top-bar actions (id / shortcut). Enabled only when a service is bound, the UI is not busy, and `PixCapabilities` allows the operation:

| Id | Caption | Shortcut | Enabled when |
| --- | --- | --- | --- |
| `buscar` | Buscar | F5 | list or consult capability of the active browse tab |
| `gerar` | Gerar | F4 | `CanCobrancaRegistrar` |
| `registrar` | Registrar | F7 | create tab + `CanCobrancaRegistrar` |
| `consultar` | Consultar | F2 | selected cob/pix/dev + matching consult capability |
| `qrcode` | QR Code | F6 | selected cobranca with `PixCopiaECola <> ""` |
| `devolver` | Devolver | F8 | `CanDevolucaoRegistrar` and (cobranca has recebimentos, or pix has `TxId <> ""`) |
| `cancelar` | Cancelar | F3 | selected active cobranca + `CanCobrancaCancelar` |

Busy wrapper `_run`: no-op if already busy; if no service, `"Selecione uma conta financeira antes de continuar."` Exceptions become `MessageBox` plus status `"Falha: " & message`.

Lookup vs list on Buscar:

- Cobranças, `LookupId <> ""` → `Service.Cobranca.Consultar(lookup)`. Missing cobranca: empty list and `"Nenhuma cobrança encontrada para o TxId informado."`
- Recebimentos, `LookupId <> ""` → `Service.Recebimento.Consultar(lookup)`
- Devoluções, E2E and Id → `Service.Devolucao.Consultar`; E2E only → consult that recebimento; else list recebimentos and count nested devoluções

Workspace QR path constructs `PixAppQrCode(service, "Pagamento com Pix")` with **no sharer**.

Registrar: `ReadCobranca` → `Cobranca.Registrar` → `AdoptCobranca` → switch to Cobranças. If `PixCopiaECola <> ""`, asks `"Cobrança registrada. Abrir o QR Code para pagamento?"`.

Cancelar asks `"Cancelar a cobrança " & TxId & "?"`.

## Session

### `PixAppStatusNotify`

```bas
Delegate Sub PixAppStatusNotify(pText As String)
```

### `PixAppSession`

In-memory PIX session for one workspace. Default mode `"cob"`.

Events (assign before `BindService`):

| Field | Type | Fired when |
| --- | --- | --- |
| `OnAccountChanged` | `TNotifyEvent` | `BindService` / `Unbind` |
| `OnListChanged` | `TNotifyEvent` | list replace / adopt / `RefreshUi` |
| `OnSelectionChanged` | `TNotifyEvent` | selection, mode change, list replace |
| `OnStatus` | `PixAppStatusNotify` | `SetStatus` (no-op if unassigned) |

```bas
Function HasService() As Boolean
Function Service() As PixService                  ' Null until BindService with a live service
Function Config() As PixConfig                    ' Null if no service
Function Capabilities() As PixCapabilities        ' Null if no service
Function Conta() As String                        ' "" if unbound
Function Mode() As String                         ' "cob" | "pix" | "dev" | "new"
Function IsCobrancaMode() As Boolean
Function IsPixMode() As Boolean
Function IsDevolucaoMode() As Boolean
Function IsCreateMode() As Boolean
Function ListaCobrancas() As PixCobrancas         ' Null until ReplaceCobrancas
Function ListaPix() As PixRecebimentos
Function ListaDevPix() As PixRecebimentos
Function Cobranca() As PixCobrancaCompleta        ' Null if none selected
Function Pix() As PixRecebimento
Function Devolucao() As PixDevolucao
Function DevE2e() As String
Function DevTxId() As String
Function PaginacaoCobrancas() As PixPaginacao     ' Null if no list
Function PaginacaoPix() As PixPaginacao
Function PaginacaoDev() As PixPaginacao

Sub SetStatus(pText As String)
Sub BindService(pService As PixService, pConta As String, pOwnsService As Boolean = True)
Sub Unbind()                                      ' BindService(Null, "", True)
Sub SetMode(pMode As String)                      ' Trim+LCase; "" → "cob"; no-op if unchanged
Sub ReplaceCobrancas(pLista As PixCobrancas)      ' Frees previous list; clears cobranca selection
Sub ReplacePix(pLista As PixRecebimentos)
Sub ReplaceDevPix(pLista As PixRecebimentos)      ' also clears DevE2e / DevTxId
Sub SelectCobranca(pTxId As String)               ' FindById in current list; does not own
Sub SelectPix(pE2eId As String)
Sub SelectDevolucao(pE2e As String, pId As String)
Sub AdoptCobranca(pCobranca As PixCobrancaCompleta)  ' session owns pCobranca and will Free it
Sub AdoptPix(pPix As PixRecebimento)
Sub AdoptDevolucao(pDevolucao As PixDevolucao, pE2e As String, pTxId As String)
Sub RefreshUi()
```

`BindService` releases the previous service when `_ownsService` is True, clears lists and selection, then emits account/list/selection. Status: `"Conta " & pConta & " conectada (" & Client.GetName() & ")."` or `"Selecione uma conta financeira para começar."`.

`Select*` no-op when the same non-owned item is already selected. Missing id leaves the pointer Null.

`Adopt*` upserts into the matching list (clone if new row, `AssignCompleta` / `Assign` if present).

## Share contract and QR

### `PixAppShareRequest`

Payload passed to a sharer. Does not own `Cobranca`.

```bas
Cobranca As PixCobrancaCompleta
QrCodePath As String

Sub New(pCobranca As PixCobrancaCompleta, pQrCodePath As String = "")
Function ApplyTokens(pText As String) As String
Shared Function ReplaceTokens(pCobranca As PixCobrancaCompleta, pText As String) As String
```

Literal tokens replaced in `pText`:

```
@TxId
@Revisao
@SolicitacaoPagador
@Chave
@PixCopiaECola
@Status
@Location
@Valor
@ModalidadeAlteracao
@Nome
@CPF
@CNPJ
@CNPJ_CPF
@Data
@Hora
@Expiracao
@DataExpiracao
@HoraExpiracao
```

`@CNPJ_CPF` becomes CPF if `Devedor.CPF <> ""`, else CNPJ if `Devedor.CNPJ <> ""`, else the token is left as-is. Dates use `dd/mm/yyyy` and `hh:nn:ss`. `@Valor` is `Valor.Original.ToString()` (not the `0.00` formatter).

### `PixAppSharer`

Consumer-owned send channel. The QR dialog never constructs or Frees a sharer.

```bas
MustOverride Function Hint() As String
MustOverride Function IconBase64() As String
Overridable Function ShortcutKey() As Integer     ' default 0 = no Ctrl+key
MustOverride Sub Share(pRequest As PixAppShareRequest)
```

If `ShortcutKey() > 0`, Ctrl + that key (same as `Word`) calls `Share` while the QR form is open.

### `PixAppQrCode`

Modal QR monitor. Polls `Service.Cobranca.Consultar(TxId)` every `IntervalMonitor` ms.

```bas
Size As Integer = 233
DelayOnClose As Integer = 500
IntervalMonitor As Integer = 3000
ShowMessageOnShow As Boolean = False
CancelOnExpired As Boolean = True
CancelOnExit As Boolean = True
SaveMovimentoPixOnExit As Boolean = True

Property Path As String                           ' temp PNG after the QR is downloaded
Property Sharer As PixAppSharer                   ' get-only; Null if omitted

Sub New(pService As PixService, pTitle As String = "Pagamento com Pix", pSharer As PixAppSharer = Null)
Function Show(pCobranca As PixCobrancaCompleta) As PixCobrancaCompleta
Sub Close()
Sub Printe()
Sub CopyPix()
Sub Share()                                       ' no-op if Sharer is Null
Function _getContentCopy() As String
```

`Show`:

1. Stores `pCobranca.CodMovimentoPix` and consults the live cobranca.
2. If not active or calendar expired: message (`"Essa cobrança já foi recebida."` when done) and `Close`; does not show the form.
3. Else downloads QR from `https://api.qrserver.com/v1/create-qr-code/?size={Size}x{Size}&data={PixCopiaECola}` into a temp PNG and shows the form titled `"Pagamento com Pix - R$ "` + `Valor.Original` formatted `0.00`.
4. Returns the last consulted `PixCobrancaCompleta`.

`Close`: stops the timer; if `SaveMovimentoPixOnExit` then `Service.Ledger().SaveCobranca`; sleeps `DelayOnClose`; if `ShowMessageOnShow` shows `_message`; closes the form.

On can-close: if `CancelOnExpired` and still active and expired → `Cobranca.Cancelar`. Else if `CancelOnExit` and not done → `"Deseja cancelar a cobrança?"` then cancel. Always allows close.

Unknown cobranca status throws `"Status desconhecido: " & Status.AsString`.

`CopyPix` copies `_getContentCopy()`: `Data7.Parametro("Customizado_Projeto_Pix_ConteudoCopiaECola")`, or `"@PixCopiaECola"` when that parameter is blank, then `ReplaceTokens`.

`Printe` uses `Data7.Parametro("Recebimento_Pix_Api_CodRelatorio_QrCode")` as `CodRelatorio`, params `CodEmpresa` and `CodMovimentoPix`.

Share button (Btn3) exists only when `pSharer` is Assigned. Print = Ctrl+P, Copy = Ctrl+C.

### `PixForm`

Chrome used by `PixAppQrCode`. Fixed size 550×509; resize denied.

```bas
Btn1 As Forms.Imagem
Btn2 As Forms.Imagem
Btn3 As Forms.Imagem
OnCanShow As DelegateCan
OnShow As DelegateOnShowClose
OnCanClose As DelegateCan
OnClose As DelegateOnShowClose
OnKeyDown As DelegateOnKeyDown
OnKeyUp As DelegateOnKeyDown
Property Showing As Boolean

Sub New(pTitle As String, pSizeImage As Integer = 233)
Sub LayoutActionButtons(pShowShare As Boolean)    ' 2 buttons, or 3 when True; Btn3.Visible = pShowShare
Sub SetImage(pPath As String)
Sub SetLabel(pLabel As String)
Sub Show(pTitle As String = "")                   ' empty title keeps the constructor caption; OnCanShow can abort
Sub Close()
```

Delegates:

```bas
Delegate Sub DelegateOnShowClose(pSender As TObject)
Delegate Sub DelegateCan(pSender As TObject, ByRef pCan As Boolean)
Delegate Sub DelegateOnKeyDown(ByRef pKey As Word, pShift As Forms.TShiftState)
```

## Refund dialog

### `PixAppRefundDialog`

`TFormsDialog` `"Registrar devolução"`, `CloseOnOk = False`, size 42×38.

```bas
Accepted As Boolean
TxId As String
EndToEndId As String
Valor As Currency
IdDevolucao As String

Sub New(pCobranca As PixCobrancaCompleta)         ' ListaOpcoes from cob.Recebimentos E2E; default valor = first pix.Valor - ValorDevolvido, else cob.Valor.Original
Sub New(pPix As PixRecebimento)                   ' single option pix.E2eId=pix.E2eId; valor = pix.Valor - pix.ValorDevolvido
```

Ok validation (dialog stays open, `Accepted = False`):

- empty E2E → `"Selecione o recebimento que será devolvido."`
- `Valor <= 0` → `"Informe um valor maior que zero para a devolução."`
- empty Id → `GenerateIDDevolucao()` then accept

`ListaOpcoes` example for two recebimentos: `E2EAAA=E2EAAA;E2EBBB=E2EBBB`.

Id seed is `GenerateIDDevolucao()` in both constructors.

Workspace then calls `Service.Devolucao.Registrar(TxId, EndToEndId, IdDevolucao, Valor)` and reconsults the cobranca or pix.

## Adapters

### `PixAppSurface`

```bas
Shared Function Page(pParent As TWinControl, pAlign As TAlign, pHeight As Integer = 0, pWidth As Integer = 0) As PageControl
   ' ShowCardFrame = False, ShowShadow = False, TabStop = False; Height/Width applied only when > 0
Shared Function Caption(pParent As TWinControl, pText As String, pAlign As TAlign = alTop) As StaticText
   ' Height 18, bold, AutoSize False
Shared Function Hint(pParent As TWinControl, pText As String, pAlign As TAlign = alClient) As StaticText
Shared Sub Show(pHost As TWinControl, pVisible As Boolean, pAlign As TAlign)
   ' no-op if Visible already equals pVisible; Align is set only when showing
Shared Function Tabs(pParent As TWinControl) As PageControl
   ' alClient, ShowCardFrame True
Shared Function Sheet(pTabs As PageControl, pCaption As String) As TabSheet
Shared Function ScrollHost(pParent As TWinControl) As TForm
   ' nested form, OcultarBordas True, OnCloseQuery = OnDenyClose
Shared Sub OnDenyClose(pSender As TObject, ByRef pCanClose As Boolean)
   ' always pCanClose = False
```

### `PixAppGroup`

Captioned `ControlGroup` (`alClient`) over a margined shell. Host is a client `PageControl` with margins Left/Right/Bottom 2 and Top 18.

```bas
Sub New(pParent As TWinControl, pCaption As String, pAlign As TAlign, pHeight As Integer = 0, pWidth As Integer = 0)
Property Shell As PageControl
Property Host As PageControl
Property Caption As String
Sub Sync()                                        ' keeps ControlGroup.Align = alClient
```

Shell outer margins are 2px. Align is applied after margins.

### `PixAppFormat`

```bas
Shared Function Money(pValue As Double) As String                          ' "0.00"
Shared Function DateTimeText(pValue As TDateTime) As String                ' "" if empty date, else "dd/mm/yyyy hh:nn:ss"
Shared Function StatusText(pStatus As PixStatusCobranca) As String         ' "" if Null
Shared Function DevolucaoStatus(pStatus As PixStatusDevolucao) As String   ' "" if Null
Shared Function Devedor(pCobranca As PixCobrancaCompleta) As String        ' "" if Null cob/devedor; "Nome (doc)" / nome / CPF-or-CNPJ
Shared Function EndOfDay(pDate As TDateTime) As TDateTime                  ' empty in → empty out; else 23:59:59
Shared Function StartOfDay(pDate As TDateTime) As TDateTime                ' empty in → empty out; else 00:00:00
Shared Function DevRowId(pE2e As String, pId As String) As String          ' e2e & "|" & id
Shared Function DevRowE2e(pRowId As String) As String                      ' left of "|", or whole string if no pipe
Shared Function DevRowDevId(pRowId As String) As String                    ' right of "|", or ""
Shared Function PagerText(pPageIndex As Integer, pPageCount As Integer, pTotal As Integer, pReturned As Integer, pById As Boolean) As String
Shared Function PageCountOf(pPageCount As Integer, pTotal As Integer, pPageSize As Integer, pReturned As Integer) As Integer
```

`PagerText` (`pPageIndex` is 0-based; displayed page is index+1, minimum 1):

- `pById` → `"Consulta por identificador · N registro(s)"`
- `pPageCount > 1` → `"Página X de Y · T item(ns)"`
- `pPageCount = 1` → `"Página 1 de 1 · T item(ns)"`
- else if `pReturned > 0` → `"Página X · N item(ns) nesta página · pode haver mais"`
- else `"Nenhum item nesta página"`

`PageCountOf`: uses `pPageCount` when `> 0`; else ceil(`pTotal`/`pPageSize`) when both `> 0`; else `0` when `pReturned >= pPageSize And pPageSize > 0`; else `1`.

### `PixAppServiceAdapter`

```bas
Function OpenConta(pCodContaFinanceira As String) As PixService
   ' PixService.Load(PixErp.FromContaFinanceira(pCodContaFinanceira))
```

### `PixAppFilterMapper`

```bas
Function ToFiltro(pInicio As TDateTime, pFim As TDateTime, pStatus As String, pCpf As String, pCnpj As String, pPagina As Integer, pItens As Integer) As PixFiltro
```

- empty dates skipped
- Fim that is **today** → `DataFim = DateTime()` (now); other non-empty Fim → `EndOfDay`
- `Trim(pStatus) = ""` → status not set; else `PixStatusCobranca.Load`
- `pPagina` applied only when `> 0` (page index `0` leaves `PixFiltro.Pagina` at its domain default)
- `pItens` applied only when `> 0`

Caller owns the returned `PixFiltro`.

### `PixAppGridMapper`

Readonly grids. `PrepareReadonly(pGrid, pShowItem = True)`: item column size 3, `OnlyRead`, no mark-for-delete, stretch last column.

Column ids:

| Binder | Columns |
| --- | --- |
| `BindCobrancaColumns` | `txid`, `status`, `valor`, `devedor`, `criacao`, `chave` |
| `BindPixColumns` | `e2e`, `txid`, `valor`, `horario`, `chave` |
| `BindRecebimentoColumns` | `e2e`, `valor`, `horario`, `devolvido` |
| `BindDevolucaoColumns` | `id`, `valor`, `status`, `e2e`, `txid` |
| `BindInfoColumns` | `nome`, `valor` |

```bas
Sub ClearRows(pGrid As TGridView)
Sub FillCobrancas(pGrid As TGridView, pLista As PixCobrancas)                 ' Null lista → empty grid; row.ID = TxId
Sub FillPix(pGrid As TGridView, pLista As PixRecebimentos)                    ' row.ID = E2eId
Sub FillRecebimentos(pGrid As TGridView, pCobranca As PixCobrancaCompleta)
Sub FillDevolucoes(pGrid As TGridView, pCobranca As PixCobrancaCompleta, pPix As PixRecebimento)
   ' pPix wins; else all cob.Recebimentos devoluções; row.ID = devolucao.Id
Sub FillInfos(pGrid As TGridView, pCobranca As PixCobrancaCompleta)
Sub FillDevolucoesFromPix(pGrid As TGridView, pLista As PixRecebimentos)      ' row.ID = DevRowId(e2e, id)
Sub FillDevolucao(pGrid As TGridView, pItem As PixDevolucao, pE2e As String, pTxId As String)
Function CountOfCobrancas(pLista As PixCobrancas) As Integer                  ' 0 if Null
Function CountOfPix(pLista As PixRecebimentos) As Integer
Function CountOfDevolucoes(pLista As PixRecebimentos) As Integer              ' sum of nested Devolucoes
Function RowId(pGrid As TGridView, pNativeRow As Integer) As String           ' "" if ToDataIndex < 0 or row Null
```

### `PixAppSampleFactory`

```bas
Function Cobranca() As PixCobranca
```

Defaults: `TxId = GenerateTxID()`, `Valor.Original` in `{1.25, 2.25, …, 8.25}` from `1 + (SecondOf() Mod 8)`, `Calendario.Expiracao = 3600`, `SolicitacaoPagador = "Teste PIX " & now`, two `PixInfoAdicional`: `origem=pix-app`, `amostra=aleatoria`. Caller Frees the cobranca.

## Panels

Kind string is `LCase(Trim(pKind))`. Browse/list/detail/filter treat `"cob"`, `"pix"`, and anything else as devolução (`"dev"`).

### `PixAppAccountPanel`

Required search editor `"Conta financeira"`. Pesquisa `Data7.PesquisaPadrao("MovContaFinanceira", "CodContaFinanceira")`. Extra filter always:

```
CodParametroApi IS NOT NULL
```

appended with ` AND ` when `ExpressaoFiltro` is already non-empty.

```bas
Property Host As PageControl
Function Codigo() As String                       ' Trim(search text)
Sub SetCodigo(pCodigo As String)                  ' Trim; "" is no-op; Validate then OpenConta + BindService
Sub Focus()
```

`SetCodigo` / Exit / Validate: if code equals `Session.Conta()` do not reopen; empty code `Unbind`s only when a conta was bound. Open failure Unbinds and shows the message above.

### `PixAppBrowsePage`

```bas
OnPageChange As TNotifyEvent

Sub New(pParent As TWinControl, pSession As PixAppSession, pKind As String)
Function Kind() As String
Function Filters() As PixAppFilterPanel
Sub Sync(pTotalWidth As Integer)                  ' filters + detail.Fit + list
Sub Reload()                                      ' list.Reload + BindPager
Sub Bind()                                        ' detail.Bind
Sub BindPager()
```

Pager `byId` is `Filters.HasLookup()`. Devolução returned count uses `CountOfDevolucoes`, or `1` if that is 0 and `Session.Devolucao()` is Assigned.

### `PixAppFilterPanel`

Frame height 68, caption `"Filtros"`.

```bas
Property Host As PageControl
Function Kind() As String
Sub Sync()
Function Filtro() As PixFiltro                    ' caller Frees
Function PageIndex() As Integer                   ' 0-based; default 0
Sub SetPageIndex(pValue As Integer)               ' < 0 → 0
Function Itens() As Integer                       ' editor value, or 50 if <= 0
Function LookupId() As String                     ' TxId or E2E; "" if widget missing
Sub SetLookupId(pValue As String)
Function LookupDevId() As String                  ' devolução Id only
Function HasLookup() As Boolean                   ' LookupId() <> ""  (Id alone does not count)
Sub ResetDefaults()
```

Cobranças status `ListaOpcoes` (literal):

```
Todos=;Ativa=ATIVA;Concluída=CONCLUIDA;Removida pelo usuário=REMOVIDA_PELO_USUARIO_RECEBEDOR;Removida pelo PSP=REMOVIDA_PELO_PSP
```

`ResetDefaults`: Início = today−7, Fim = today, status `""` (Todos), empty CPF/CNPJ/lookups, page 0, itens 50.

Fields by kind:

| Kind | Editors |
| --- | --- |
| `cob` | Início, Fim, Status, CPF, CNPJ, TxId, Itens |
| `pix` | Início, Fim, CPF, CNPJ, E2E, Itens |
| other | Início, Fim, E2E, Id, Itens |

### `PixAppListPanel`

Caption `"Resultados"`. Click / dbl-click selects via row id (`SelectCobranca` / `SelectPix` / `SelectDevolucao` using `DevRowE2e` + `DevRowDevId`). `Reload` fills from the session list; if nothing is selected, selects row 0.

### `PixAppDetailPanel`

Caption `"Detalhes"`, `alRight`, initial width 430.

```bas
Property Host As PageControl
Sub Fit(pTotalWidth As Integer)                   ' 38% of width, clamped 360..520; no-op if width unchanged
Sub Sync()
Sub Bind()                                        ' from session current cob/pix/dev; Clear if Null
Sub Clear()
```

Kind layout:

- `pix`: hides copia e cola, recebimentos, informações adicionais; shows devoluções; labels TxId / E2E / Chave / Devolvido / Horário
- `dev`: shows copia as RtrId; hides recebimentos and info; labels TxId / Status / E2E / Id / Horário / Motivo
- else (`cob`): all groups visible

### `PixAppPager`

Host `alBottom` height 34. `OnChange As TNotifyEvent`.

```bas
Property Host As PageControl
Function PageIndex() As Integer
Sub Bind(pPageIndex As Integer, pPageCount As Integer, pTotal As Integer, pReturned As Integer, pPageSize As Integer, pById As Boolean)
```

`pById` True: both buttons disabled. Anterior enabled when index `> 0`. Próxima: `(index + 1) < pages` when `pages > 0`, else `(pReturned >= pPageSize) And pPageSize > 0`. Next does not clamp to last page.

### `PixAppCreatePanel`

```bas
OnRegistrar As TNotifyEvent

Property Host As PageControl
Sub Sync()
Sub ApplyChave()                                  ' no-op if chave already non-empty; else Config.ChavePix
Sub FillSample()                                  ' PixAppSampleFactory + Config.ChavePix when present
Function ReadCobranca() As PixCobranca            ' caller Frees
```

`FillSample` always clears chave first, then copies `config.ChavePix` when the session has config.

## Internal flows (usage)

**Open-by-TxId**

1. `PixApp.Run(conta, txId)` stores trimmed values on the workspace.
2. `AfterShow` writes TxId into Cobranças filters.
3. `SetCodigo(conta)` opens `PixService` and `BindService`.
4. `OnAccountChanged`: if `_initialTxId <> ""` and `HasService`, switch to Cobranças, set lookup, `Cobranca.Consultar` once, then clear `_initialTxId`.
5. If only TxId was passed, wait for a later account change.

**Buscar with identifier vs period**

`HasLookup()` true (TxId/E2E filled) short-circuits list APIs. Period filter uses Início `StartOfDay`, Fim as now when the date is today. Page index `0` is **not** written into `PixFiltro.Pagina`.

**QR lifecycle**

Active + not expired → download QR, poll. Done / cancelled / expired → stop, optional ledger save, optional cancel. Workspace never passes a `PixAppSharer`.

**Copy template**

Parameter `Customizado_Projeto_Pix_ConteudoCopiaECola` is a token string, e.g. `"Pagamento PIX @Valor @PixCopiaECola"`. Blank parameter → `"@PixCopiaECola"`.

## Extending (Consumer Project)

**Inject a sharer** (this module ships no WhatsApp/email implementation):

```bas
Imports mod_pix_app_share
Imports mod_pix_app_qrcode

Class MeuPixSharer
   Inherits PixAppSharer

   Overrides Function Hint() As String
      Hint = "Enviar QR Code"
   End Function

   Overrides Function IconBase64() As String
      IconBase64 = "..." ' PNG base64 for Btn3
   End Function

   Overrides Function ShortcutKey() As Integer
      ShortcutKey = 87   ' optional Ctrl+W; 0 disables
   End Function

   Overrides Sub Share(pRequest As PixAppShareRequest)
      Dim texto As String = pRequest.ApplyTokens("PIX @Valor @PixCopiaECola")
      ' send texto and/or pRequest.QrCodePath
   End Sub
End Class
```

Pass it as the third argument of `PixAppQrCode`. Free the sharer in the consumer. `PixApp.Run` / `PixAppWorkspace` will still open QR without a send button.

**Reuse the workspace** if the consumer needs a different chrome: construct `PixAppWorkspace` and call `Show` instead of `PixApp.Run`. Initial account/TxId still apply.

**Do not** put sender wiring inside this module. Account opening stays `PixAppServiceAdapter.OpenConta`.

## Module Notes

- `PixAppSession` Frees the PIX service only when `BindService` was called with `pOwnsService = True` (the workspace always uses True). Adopted cobranca/pix/devolução objects are owned; selected-from-list objects are not.
- `Replace*` Frees the previous list. Passing Null is valid and leaves the getter Null.
- Account lookup is `MovContaFinanceira` / `CodContaFinanceira` plus `CodParametroApi IS NOT NULL`. Accounts without API parameters never appear.
- Workspace QR does not inject `PixAppSharer`. Share UI exists only on `PixAppQrCode` constructed by the consumer.
- Copy/print ERP contracts: `Customizado_Projeto_Pix_ConteudoCopiaECola` (token template) and `Recebimento_Pix_Api_CodRelatorio_QrCode` (integer report id).
- Filter page index is 0-based in the UI; `ToFiltro` ignores `0`, so the first page relies on `PixFiltro` domain defaults.
- `PixAppSampleFactory` values are random-ish (`SecondOf` mod 8) and always tag `origem=pix-app`.
- No automated test entrypoint lives in `src`. `Principal.bas` is the ERP process trampoline (`CONSULTAR` / `CONSULTAR PIX` vs default `Run()`).
