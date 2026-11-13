# mod_whatsapp

WhatsApp integration for Data7: a `WaClient` strategy, a `WaService` facade (`Send` / `Instance` / `User` / `Message` / `Chat` / `Group`), typed send/management DTOs, message layout/planning, and a `WaCompose` send dialog. It does **not** host WhatsApp itself, persist conversations, or choose credentials — the consumer supplies host, tokens, instances, recipients, and which client to run. Version **1.0.0.0** (`opcoes.versao` `1.0.0.0`). Dependencies (`data7.json`): `mod_io` `1.0.0.0`, `mod_forms` `1.0.0.0`, `mod_editors` `1.0.0.1`, `mod_winapi` `1.0.0.0`, `mod_clipboard_manager` `1.0.0.0`.

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Open a `.bas` file only to confirm a detail that is not stated here.

## Quick Start (Minimal)

```basic
Imports mod_wa_evolution_go_options
Imports mod_wa_client_evolution_go
Imports mod_wa_service
Imports mod_wa_message
Imports mod_wa_send_result

' Combined token is master@instance. Third arg is the default instance name.
Dim opts As WaEvolutionGoOptions = WaEvolutionGoOptions.FromCombinedToken("https://api.example.com", "master@instance", "loja-1")
' True: client frees opts.
Dim client As New WaClientEvolutionGo(opts, True)
' True: service frees client.
Dim wa As New WaService(client, True)

Dim msg As New WaMessage()
msg.Recipient = "5566999050312"
msg.Subject = "Pedido 1001"
msg.Content = "Seu pedido saiu para entrega."
msg.Signature = "Equipe Loja"

' Validates recipient + text/attachments, then dispatches the formatter plan.
Dim result As WaSendResult = wa.Send.Message(msg)
If result.Success Then
   ' Provider accepted every plan step.
End If

result.Free()
msg.Free()
wa.Free()
```

Compose dialog (multi-client):

```basic
Imports mod_wa_compose
Imports mod_wa_client_desktop
Imports mod_wa_desktop_options

Dim desktopOpts As New WaDesktopOptions()
Dim desktop As New WaClientDesktop(desktopOpts)
Dim compose As New WaCompose()
' True: compose owns and frees the client with Options.Clients.
compose.RegisterClient(desktop, "Desktop", "", True)
compose.Options.CanChangeClient = True
compose.Options.DefaultClient = "Desktop"
compose.Options.Message.Recipient = "66999050312"
compose.Options.Message.Content = "Olá"

If compose.Show() Then
   ' LastResult.Success after the user confirmed send.
End If
compose.Free()
```

## Namespace Map

| File | Namespace | Types / members |
| --- | --- | --- |
| `src/core/contracts/wa_contracts.bas` | `mod_wa_contracts` | `WaClient` |
| `src/core/models/wa_capabilities.bas` | `mod_wa_capabilities` | `WaCapabilities` |
| `src/core/models/wa_message.bas` | `mod_wa_message` | `WaMessage`, `WaMessageList` |
| `src/core/models/wa_message_format.bas` | `mod_wa_message` | `WaTextPart`, `WaAttachmentTextMode`, `WaFormatTextDelegate`, `WaBuildPlanDelegate`, `WaMessageLayout`, `WaSendStep`, `WaSendPlan`, `WaMessageFormatter` |
| `src/core/models/wa_attachment.bas` | `mod_wa_attachment` | `WaAttachment`, `WaAttachmentList` |
| `src/core/models/wa_contact.bas` | `mod_wa_contact` | `WaContact`, `WaContactList` |
| `src/core/models/wa_instance.bas` | `mod_wa_instance` | `WaInstance`, `WaInstanceList` |
| `src/core/models/wa_api_result.bas` | `mod_wa_api_result` | `WaApiResult` |
| `src/core/models/wa_send_result.bas` | `mod_wa_send_result` | `WaSendResult` |
| `src/core/validation/wa_validators.bas` | `mod_wa_validators` | `WaPhoneValidator`, `WaMessageValidator` |
| `src/core/auth/wa_auth.bas` | `mod_wa_auth` | `WaAuth`, `WaAuthNone`, `WaAuthApiKey`, `WaAuthDualToken` |
| `src/core/infra/wa_http.bas` | `mod_wa_http` | `WaHttp` |
| `src/core/dto/wa_dto_instance.bas` | `mod_wa_dto_instance` | `WaInstanceCreateRequest` |
| `src/core/dto/wa_dto_send.bas` | `mod_wa_dto_send` | `WaDtoSendStringListToJsonArray`, `WaSendTextRequest`, `WaSendMediaRequest`, `WaSendLocationRequest`, `WaSendContactRequest`, `WaSendStickerRequest`, `WaSendPollRequest`, `WaSendButtonsRequest`, `WaSendListRequest` |
| `src/core/dto/wa_dto_message.bas` | `mod_wa_dto_message` | `WaDtoMessageStringListToJsonArray`, `WaMessageKey`, `WaMessageReactRequest`, `WaMessageMarkReadRequest`, `WaMessageDeleteRequest`, `WaMessageEditRequest`, `WaMessagePresenceRequest` |
| `src/core/dto/wa_dto_user.bas` | `mod_wa_dto_user` | `WaDtoUserStringListToJsonArray`, `WaUserLookupRequest`, `WaUserProfileNameRequest`, `WaUserProfileStatusRequest`, `WaUserBlockRequest` |
| `src/core/dto/wa_dto_chat.bas` | `mod_wa_dto_chat` | `WaDtoChatStringListToJsonArray`, `WaChatActionRequest`, `WaCheckNumbersRequest`, `WaFindFilterRequest` |
| `src/core/dto/wa_dto_group.bas` | `mod_wa_dto_group` | `WaDtoGroupStringListToJsonArray`, `WaGroupCreateRequest`, `WaGroupInfoRequest`, `WaGroupParticipantRequest`, `WaGroupUpdateTextRequest`, `WaGroupInviteRequest` |
| `src/core/services/wa_resource_base.bas` | `mod_wa_service` | `WaResource` |
| `src/core/services/wa_service.bas` | `mod_wa_service` | `WaService` |
| `src/core/services/wa_send_resource.bas` | `mod_wa_service` | `WaSendResource` |
| `src/core/services/wa_instance_resource.bas` | `mod_wa_service` | `WaInstanceResource` |
| `src/core/services/wa_user_resource.bas` | `mod_wa_service` | `WaUserResource` |
| `src/core/services/wa_message_resource.bas` | `mod_wa_service` | `WaMessageResource` |
| `src/core/services/wa_chat_resource.bas` | `mod_wa_service` | `WaChatResource` |
| `src/core/services/wa_group_resource.bas` | `mod_wa_service` | `WaGroupResource` |
| `src/clients/evolution/wa_evolution_options.bas` | `mod_wa_evolution_options` | `WaEvolutionOptions` |
| `src/clients/evolution/wa_client_evolution.bas` | `mod_wa_client_evolution` | `WaClientEvolution` |
| `src/clients/evolution_go/wa_evolution_go_options.bas` | `mod_wa_evolution_go_options` | `WaEvolutionGoOptions` |
| `src/clients/evolution_go/wa_client_evolution_go.bas` | `mod_wa_client_evolution_go` | `WaClientEvolutionGo` |
| `src/clients/desktop/wa_desktop_options.bas` | `mod_wa_desktop_options` | `WaDesktopOptions` |
| `src/clients/desktop/wa_client_desktop.bas` | `mod_wa_client_desktop` | `WaClientDesktop` |
| `src/clients/devstudio/wa_devstudio_options.bas` | `mod_wa_devstudio_options` | `WaDevStudioOptions` |
| `src/clients/devstudio/wa_client_devstudio.bas` | `mod_wa_client_devstudio` | `WaClientDevStudio` |
| `src/ui/compose/wa_compose.bas` | `mod_wa_compose` | `WaCompose` |
| `src/ui/compose/wa_compose_options.bas` | `mod_wa_compose_options` | `WaCanDelegate`, `WaChangeDelegate`, `WaBeforeSendDelegate`, `WaIndexDelegate`, `WaInstancesDelegate`, `WaComposeOptions` |
| `src/ui/compose/wa_compose_client.bas` | `mod_wa_compose_client` | `WaComposeClient`, `WaComposeClientList` |
| `src/ui/compose/wa_compose_form.bas` | `mod_wa_compose_form` | `WaComposeForm` |
| `src/ui/compose/wa_compose_rules.bas` | `mod_wa_compose_rules` | `WaComposeRules` |
| `src/ui/compose/wa_compose_events.bas` | `mod_wa_compose_events` | `WaComposeEvents` |
| `src/ui/helpers/wa_phone_mask.bas` | `mod_wa_phone_mask` | `WaPhoneMask` |
| `src/ui/helpers/wa_form_helper.bas` | `mod_wa_form_helper` | `WaFormHelper` |

## Capabilities

`WaCapabilities` is the feature bitmap each `WaClient.GetCapabilities()` returns. `WaService` reads it before every resource call.

| Flag | Default (`New`) | `LimitedSend()` | `FullApi()` | `Deprecated()` |
| --- | --- | --- | --- | --- |
| `CanSendText` | `False` | `True` | `True` | `False` |
| `CanSendMedia` | `False` | `True` | `True` | `False` |
| `CanSendButtons` | `False` | `False` | `True` | `False` |
| `CanSendPoll` | `False` | `False` | `True` | `False` |
| `CanSendList` | `False` | `False` | `True` | `False` |
| `CanSendLocation` | `False` | `False` | `True` | `False` |
| `CanSendContact` | `False` | `False` | `True` | `False` |
| `CanSendSticker` | `False` | `False` | `True` | `False` |
| `CanManageInstances` | `False` | `False` | `True` | `False` |
| `CanManageContacts` | `False` | `False` | `True` | `False` |
| `CanManageGroups` | `False` | `False` | `True` | `False` |
| `CanManageChats` | `False` | `False` | `True` | `False` |
| `CanManageMessages` | `False` | `False` | `True` | `False` |
| `CanValidatePhone` | `False` | `False` | `True` | `False` |
| `NeedsSender` | `False` | `False` | `False` | `False` |
| `IsDeprecated` | `False` | `False` | `False` | `True` |

`WaClientEvolution` starts from `FullApi()` then sets `NeedsSender = True`. `WaClientEvolutionGo` is `FullApi()`. `WaClientDesktop` is `LimitedSend()`. `WaClientDevStudio` is `Deprecated()`.

**Throws (via `WaService.EnsureNotDeprecated` / `EnsureCapability`):**

- `"O cliente [{name}] está marcado como Deprecated e não pode ser utilizado. Use Evolution, EvolutionGO ou Desktop."`
- `"O cliente [{name}] não suporta o recurso: {feature}"` — `{feature}` is the Portuguese label of the resource method (see Service facade).

## Domain models

### `WaMessage`

Payload for high-level send (`wa.Send.Message`).

| Member | Default | Notes |
| --- | --- | --- |
| `Recipient` | `""` | Required by `WaMessageValidator` |
| `Sender` | `""` | Instance name/id for Evolution (`NeedsSender`) |
| `Subject` / `Content` / `Signature` | `""` | Layout parts |
| `Attachments` | owned `WaAttachmentList` | Freed with the message |
| `Formatter` | `NULL` | Not owned; `Dispose` only nulls it |

```basic
Function HasText() As Boolean
   ' True if Subject, Content, or Signature is non-blank after Trim.

Function AsText() As String
   ' Formatter.FormatText when assigned; else a temporary WaMessageLayout.Render.
```

`GetID` is `Recipient + "|" + Sender`.

### `WaMessageList`

Owned list of `WaMessage`.

```basic
Sub Add(pMessage As WaMessage)
Function Take(pIndex As Integer) As WaMessage
Function Count() As Integer
```

### `WaAttachment`

| Member | Default | Notes |
| --- | --- | --- |
| `Path` | `""` | File path; `GetID` prefers Path then Filename |
| `Filename` | `""` | Set from `File.ExtractName(pPath)` in path constructors |
| `Caption` | `""` | Per-file caption in the send plan |
| `MimeType` | `""` | Copied onto media DTOs |
| `Base64Data` | `""` | Cached by `ToBase64` |

```basic
Sub New()
Sub New(pPath As String)
Sub New(pPath As String, pCaption As String)

Function ToBase64() As String
   ' Returns Base64Data if already set.
   ' Else reads Path as text, encodes, caches in Base64Data.
   ' Throws "Anexo inválido ou arquivo não encontrado: {Path}" when Path is empty or missing.
```

### `WaAttachmentList`

Owned list. `IndexOfPath` returns **-1** when empty or not found.

```basic
Sub Add(pAttachment As WaAttachment)
Sub Add(pPath As String)
Sub Add(pPath As String, pCaption As String)
Function Take(pIndex As Integer) As WaAttachment
Function Count() As Integer
Function IndexOfPath(pPath As String) As Integer
Sub RemoveAt(pIndex As Integer)          ' no-op if index out of range; frees the extracted item
Sub Clean()                              ' clears owned items
```

### `WaContact` / `WaContactList`

| Member | Notes |
| --- | --- |
| `Id` | `GetID` prefers Id then Phone |
| `Phone` | Digit string used by `IndexOfPhone` (exact match) |
| `Name` | Display |
| `Exists` | Set `True` when parsed from provider contact lists |
| `ProfileImageUrl` | Evolution fetch |

```basic
Sub Add(pContact As WaContact)
Function Take(pIndex As Integer) As WaContact
Function Count() As Integer
Function IndexOfPhone(pPhone As String) As Integer   ' -1 if empty/not found
```

### `WaInstance` / `WaInstanceList`

| Member | Notes |
| --- | --- |
| `Id` | `GetID`: Id, else Phone, else Name |
| `Name` | Used by `NameContains` / `KeepNameContains` |
| `Phone` | Provider JID local part |
| `Connected` / `Authenticated` | Evolution GO copies Connected onto Authenticated |
| `ProfileName` / `ProfileImageUrl` | Evolution fetch |

```basic
Function NameContains(pFilter As String) As Boolean
   ' Trim empty → True. Else Name.ToUpper.Contains(UCase(pFilter)).

Function Take(pIndex As Integer) As WaInstance
Function Take(pId As String) As WaInstance            ' TTObjectList key = GetID
Sub KeepNameContains(pFilter As String)               ' no-op if Trim(filter) = ""
Sub RemoveAt(pIndex As Integer)                       ' no-op if out of range
```

### Layout, plan, formatter

```basic
Enun WaTextPart
   Subject = "Subject"
   Content = "Content"
   Signature = "Signature"
   Blank = "Blank"
End Enun

Enun WaAttachmentTextMode
   SeparateBefore = "SeparateBefore"
   SeparateAfter = "SeparateAfter"
   CaptionFirst = "CaptionFirst"
   CaptionLast = "CaptionLast"
   CaptionEach = "CaptionEach"
End Enun

Delegate Function WaFormatTextDelegate(pMessage As WaMessage) As String
Delegate Function WaBuildPlanDelegate(pMessage As WaMessage) As WaSendPlan
```

#### `WaMessageLayout`

Default constructor: `AttachmentTextMode = CaptionLast()`, `SendCaption = True`, `IncludeEmptyParts = True`, `AttachmentsReversed = False`, parts = `Subject`, `Content`, `Blank`, `Blank`, `Signature`.

Fluent setters return `me`. `AddBlank(pCount)` clamps `pCount < 1` to **1**.

| Method | Effect |
| --- | --- |
| `UseDefaultParts()` | Resets the five default parts |
| `ClearParts()` / `AddPart` / `AddSubject` / `AddContent` / `AddSignature` / `AddBlank` | Part list |
| `SeparateTextBefore()` / `SeparateTextAfter()` / `CaptionOnFirst()` / `CaptionOnLast()` / `CaptionOnEach()` | Mode |
| `WithSendCaption(pValue)` / `ReverseAttachments()` / `KeepEmptyParts(pValue)` | Flags |
| `IsCaptionLast()` | `ModeName() = "CaptionLast"` |
| `ModeName()` | Enum `AsString`, or `"CaptionLast"` if mode is NULL |
| `EffectiveModeName()` | If `SendCaption` is False and mode is CaptionFirst/Last/Each → `"SeparateBefore"` |
| `PartCount()` / `PartAt(pIndex)` | Part list |
| `Render(pMessage)` | Joins parts; `Blank` → empty line; empty Subject/Content/Signature skipped when `IncludeEmptyParts` is False; result is Trim of the joined text |

`CreateDefault()` is `New WaMessageLayout()`.

#### `WaSendStep` / `WaSendPlan`

```basic
Shared Function TextStep(pText As String) As WaSendStep     ' IsMedia = False
Shared Function MediaStep(pAttachment As WaAttachment, pCaption As String) As WaSendStep
   ' IsMedia = True; Attachment is a reference (not owned).

Sub AddText(pText As String)                                ' no-op if Trim = ""
Sub AddMedia(pAttachment As WaAttachment, pCaption As String)
Function Take(pIndex As Integer) As WaSendStep
Function Count() As Integer
```

#### `WaMessageFormatter`

Owns a default layout unless constructed with `pOwnsLayout` or a `Layout` setter (setter does **not** take ownership of the new layout; NULL layout is replaced by a new owned default).

```basic
Sub New()
Sub New(pLayout As WaMessageLayout, pOwnsLayout As Boolean = False)
Shared Function CreateDefault() As WaMessageFormatter

Function InterceptText(pHandler As WaFormatTextDelegate) As WaMessageFormatter
Function InterceptPlan(pHandler As WaBuildPlanDelegate) As WaMessageFormatter
Function FormatText(pMessage As WaMessage) As String
   ' OnFormatText if set, else Layout.Render; always Trim.
Function BuildText(pMessage As WaMessage) As String
   ' Layout.Render only.
Function BuildPlan(pMessage As WaMessage) As WaSendPlan
   ' OnBuildPlan if it returns non-NULL; else default plan.
```

**Default plan**

1. No attachments → one text step (`FormatText`), empty text is skipped by `AddText`.
2. `SeparateBefore` → text step, then each media (caption = attachment.Caption when `SendCaption`).
3. `CaptionEach` / `CaptionFirst` (first file) / `CaptionLast` (last file) → that media step uses formatted text as caption when text is non-empty.
4. `SeparateAfter` → media steps, then text step.
5. `AttachmentsReversed` walks the list backwards.

## Validation

### `WaPhoneValidator`

```basic
Sub New(pRequireCountryCode55 As Boolean = True)
Function Normalize(pPhone As String) As String
   ' Trim, then strip space, "-", "(", ")".
Sub Validate(pPhone As String)
   ' Normalize first.
   ' Throws "Número de telefone é obrigatório" if empty.
   ' When RequireCountryCode55: must StartsWith "55" else "O número de telefone deve iniciar com 55".
   ' Length must be 12 or 13 else "O número de telefone deve ter 12 ou 13 dígitos".
```

### `WaMessageValidator`

Used by `WaService` (constructed as `New WaMessageValidator()` → country code 55 on, format on).

```basic
Sub New(pRequireCountryCode55 As Boolean = True, pValidatePhoneFormat As Boolean = True)
Sub Validate(pMessage As WaMessage)
   ' NULL → "Mensagem é obrigatória"
   ' Recipient Trim "" → "Destinatário (Recipient) é obrigatório"
   ' If format on: WaPhoneValidator.Validate(Recipient)
   ' No HasText and no attachments → "Mensagem deve conter texto e/ou anexos"
Function NormalizeRecipient(pMessage As WaMessage) As String
```

`wa.Send.Message` assigns `pMessage.Recipient = Validator.NormalizeRecipient(pMessage)` after validate.

## Results

### `WaApiResult`

Low-level HTTP/API outcome. Constructor: `Success = False`, `StatusCode = 0`.

```basic
Shared Function Ok(pClient As String, pRaw As String, pStatus As Integer = 200) As WaApiResult
   ' Success True, Message "OK"
Shared Function Fail(pClient As String, pMessage As String, pStatus As Integer = 0, pRaw As String = "") As WaApiResult
Function AsJson() As TJSONObject
   ' New TJSONObject(Raw) when Raw <> ""; else empty object. Parse errors → empty object.
```

### `WaSendResult`

High-level send outcome. Constructor: `Success = False`.

```basic
Shared Function Ok(pClientName As String, pRecipient As String, pMessage As String = "Mensagem enviada") As WaSendResult
Shared Function Fail(pClientName As String, pRecipient As String, pMessage As String) As WaSendResult
```

## Contract (`WaClient`)

Must-inherit strategy. Defaults for optional operations **throw** `" {Method} não suportado por " + GetName()`.

```basic
MustOverride Function GetName() As String
MustOverride Function GetCapabilities() As WaCapabilities
MustOverride Function SendMessage(pMessage As WaMessage) As WaSendResult

Overridable Function Online() As Boolean                    ' default True
Overridable Function GetFormatter() As WaMessageFormatter   ' lazy CreateDefault, owned by the client
Function ResolveFormatter(pMessage As WaMessage) As WaMessageFormatter
   ' pMessage.Formatter if assigned, else GetFormatter.
```

Optional overridables (all throw unless a client implements them):

```basic
Function InstanceCreate(pReq As WaInstanceCreateRequest) As WaApiResult
Function InstanceAll() As WaInstanceList
Function InstanceInfo(pId As String) As WaInstance
Function InstanceConnect(pId As String = "") As WaApiResult
Function InstanceStatus(pId As String = "") As WaApiResult
Function InstanceRestart(pId As String = "") As WaApiResult
Function InstanceLogout(pId As String = "") As WaApiResult
Function InstanceDelete(pId As String = "") As WaApiResult
Function InstanceQr(pId As String = "") As WaApiResult

Function SendText(pReq As WaSendTextRequest) As WaApiResult
Function SendMedia(pReq As WaSendMediaRequest) As WaApiResult
Function SendButtons(pReq As WaSendButtonsRequest) As WaApiResult
Function SendPoll(pReq As WaSendPollRequest) As WaApiResult
Function SendList(pReq As WaSendListRequest) As WaApiResult
Function SendLocation(pReq As WaSendLocationRequest) As WaApiResult
Function SendContact(pReq As WaSendContactRequest) As WaApiResult
Function SendSticker(pReq As WaSendStickerRequest) As WaApiResult

Function MessageReact(pReq As WaMessageReactRequest) As WaApiResult
Function MessageMarkRead(pReq As WaMessageMarkReadRequest) As WaApiResult
Function MessageDelete(pReq As WaMessageDeleteRequest) As WaApiResult
Function MessageEdit(pReq As WaMessageEditRequest) As WaApiResult
Function MessagePresence(pReq As WaMessagePresenceRequest) As WaApiResult

Function UserInfo(pReq As WaUserLookupRequest) As WaApiResult
Function UserCheck(pReq As WaUserLookupRequest) As WaApiResult
Function UserContacts(pInstance As String = "") As WaContactList
Function UserAvatar(pPhone As String, pInstance As String = "") As WaApiResult
Function UserBlock(pReq As WaUserBlockRequest) As WaApiResult
Function UserUnblock(pReq As WaUserBlockRequest) As WaApiResult
Function UserSetProfileName(pReq As WaUserProfileNameRequest) As WaApiResult
Function UserSetProfileStatus(pReq As WaUserProfileStatusRequest) As WaApiResult
Function ValidatePhone(pInstance As String, pPhone As String) As Boolean
Function GetContact(pInstance As String, pPhone As String) As WaContact
Function ListContacts(pInstance As String) As WaContactList     ' UserContacts
Function ListInstances() As WaInstanceList                      ' InstanceAll
Function GetInstance(pId As String) As WaInstance               ' InstanceInfo

Function ChatFind(pReq As WaFindFilterRequest) As WaApiResult
Function ChatFindMessages(pReq As WaFindFilterRequest) As WaApiResult
Function ChatFindContacts(pReq As WaFindFilterRequest) As WaApiResult
Function ChatArchive(pReq As WaChatActionRequest) As WaApiResult
Function ChatPin(pReq As WaChatActionRequest) As WaApiResult
Function ChatUnpin(pReq As WaChatActionRequest) As WaApiResult
Function ChatMute(pReq As WaChatActionRequest) As WaApiResult
Function ChatUnmute(pReq As WaChatActionRequest) As WaApiResult
Function ChatCheckNumbers(pReq As WaCheckNumbersRequest) As WaApiResult

Function GroupCreate(pReq As WaGroupCreateRequest) As WaApiResult
Function GroupList(pInstance As String = "") As WaApiResult
Function GroupInfo(pReq As WaGroupInfoRequest) As WaApiResult
Function GroupParticipants(pReq As WaGroupInfoRequest) As WaApiResult
Function GroupUpdateParticipant(pReq As WaGroupParticipantRequest) As WaApiResult
Function GroupInviteLink(pReq As WaGroupInviteRequest) As WaApiResult
Function GroupLeave(pReq As WaGroupInfoRequest) As WaApiResult
Function GroupUpdateSubject(pReq As WaGroupUpdateTextRequest) As WaApiResult
Function GroupUpdateDescription(pReq As WaGroupUpdateTextRequest) As WaApiResult
```

## Service facade

`WaService` owns six resources built in `BuildResources`. Callers use `wa.Send.*`, `wa.Instance.*`, `wa.User.*`, `wa.Message.*`, `wa.Chat.*`, `wa.Group.*`.

```basic
Sub New()                                                    ' no client; owns a WaMessageValidator
Sub New(pClient As WaClient, pOwnsClient As Boolean = True)  ' NULL client throws "WaService requer um WaClient injetado"
Sub New(pClient As WaClient, pValidator As WaMessageValidator, pOwnsClient As Boolean = True, pOwnsValidator As Boolean = False)

Function HasClient() As Boolean
Function Client() As WaClient
Sub SetClient(pClient As WaClient)                           ' NULL throws "WaService requer um WaClient"
Function Validator() As WaMessageValidator
Function Capabilities() As WaCapabilities                    ' requires a client
Sub EnsureNotDeprecated()
Sub EnsureCapability(pAllowed As Boolean, pFeature As String)
```

No client: `Client()` is NULL; `Capabilities` / resource calls throw `"WaService não tem um WaClient ativo. Defina um client com SetClient ou registre clients no WaCompose."`

`WaResource` is the must-inherit base (`New` throws `"WaResource requer WaService"` if service is NULL). Consumers do not instantiate it.

### `WaSendResource` (`wa.Send`)

```basic
Function Message(pMessage As WaMessage) As WaSendResult
   ' Validate, EnsureCanSend, normalize Recipient, Client.SendMessage.
Function Message(pMessages As WaMessageList) As Boolean
   ' Calls Message per item. First failure: frees that WaSendResult and throws Exception(result.Message).
   ' Returns True when every item succeeds.

Function Text(pReq As WaSendTextRequest) As WaApiResult                 ' "envio de texto"
Function Media(pReq As WaSendMediaRequest) As WaApiResult               ' "envio de mídia"
Function Button(pReq As WaSendButtonsRequest) As WaApiResult            ' "envio de botões"
Function Poll(pReq As WaSendPollRequest) As WaApiResult                 ' "envio de enquete"
Function List(pReq As WaSendListRequest) As WaApiResult                 ' "envio de lista"
Function Location(pReq As WaSendLocationRequest) As WaApiResult         ' "envio de localização"
Function Contact(pReq As WaSendContactRequest) As WaApiResult           ' "envio de contato"
Function Sticker(pReq As WaSendStickerRequest) As WaApiResult           ' "envio de sticker"
```

`Message(WaMessage)` capability: `EnsureReady`; then `CanSendText` if `HasText`; `CanSendMedia` if attachments (`"envio de mídia/anexos"`).

### `WaInstanceResource` (`wa.Instance`) — all gated by `CanManageInstances`

```basic
Function All() As WaInstanceList                                        ' "listar instâncias"
Function Info(pId As String) As WaInstance                              ' "obter instância"
Function Status(pId As String = "") As WaApiResult                      ' "status da instância"
Function Online() As Boolean                                            ' EnsureReady only; Client.Online
Function Add(pReq As WaInstanceCreateRequest) As WaApiResult            ' "criar instância"
Function Connect(pId As String = "") As WaApiResult                     ' "conectar instância"
Function Restart(pId As String = "") As WaApiResult                     ' "reiniciar instância"
Function Logout(pId As String = "") As WaApiResult                      ' "logout da instância"
Function Delete(pId As String = "") As WaApiResult                      ' "excluir instância"
Function Qr(pId As String = "") As WaApiResult                          ' "QR Code da instância"
```

### `WaUserResource` (`wa.User`)

```basic
Function Contacts(pInstance As String = "") As WaContactList            ' CanManageContacts, "listar contatos"
Function Info(pReq As WaUserLookupRequest) As WaApiResult               ' CanManageContacts, "info de usuário"
Function Info(pInstance As String, pPhone As String) As WaContact       ' CanManageContacts, "obter contato"
Function Check(pReq As WaUserLookupRequest) As WaApiResult              ' CanValidatePhone, "checar usuário no WhatsApp"
Function ValidatePhone(pInstance As String, pPhone As String) As Boolean ' CanValidatePhone, "validar telefone no provider"
Function Avatar(pPhone As String, pInstance As String = "") As WaApiResult ' CanManageContacts, "avatar do usuário"
Function Block(pReq As WaUserBlockRequest) As WaApiResult               ' "bloquear usuário"
Function Unblock(pReq As WaUserBlockRequest) As WaApiResult             ' "desbloquear usuário"
Function SetProfileName(pReq As WaUserProfileNameRequest) As WaApiResult ' "atualizar nome do perfil"
Function SetProfileStatus(pReq As WaUserProfileStatusRequest) As WaApiResult ' "atualizar status do perfil"
```

### `WaMessageResource` (`wa.Message`) — `CanManageMessages`

```basic
Function React(pReq As WaMessageReactRequest) As WaApiResult            ' "reagir a mensagem"
Function MarkRead(pReq As WaMessageMarkReadRequest) As WaApiResult      ' "marcar mensagem como lida"
Function Delete(pReq As WaMessageDeleteRequest) As WaApiResult          ' "apagar mensagem"
Function Edit(pReq As WaMessageEditRequest) As WaApiResult              ' "editar mensagem"
Function Presence(pReq As WaMessagePresenceRequest) As WaApiResult      ' "enviar presence"
```

### `WaChatResource` (`wa.Chat`)

```basic
Function Find(pReq As WaFindFilterRequest) As WaApiResult               ' CanManageChats, "listar chats"
Function FindMessages(pReq As WaFindFilterRequest) As WaApiResult       ' "buscar mensagens"
Function FindContacts(pReq As WaFindFilterRequest) As WaApiResult       ' "buscar contatos no chat"
Function Archive(pReq As WaChatActionRequest) As WaApiResult            ' "arquivar chat"
Function Pin(pReq As WaChatActionRequest) As WaApiResult                ' "fixar chat"
Function Unpin(pReq As WaChatActionRequest) As WaApiResult              ' "desafixar chat"
Function Mute(pReq As WaChatActionRequest) As WaApiResult               ' "silenciar chat"
Function Unmute(pReq As WaChatActionRequest) As WaApiResult             ' "ativar som do chat"
Function CheckNumbers(pReq As WaCheckNumbersRequest) As WaApiResult     ' CanValidatePhone, "verificar números no WhatsApp"
```

### `WaGroupResource` (`wa.Group`) — `CanManageGroups`

```basic
Function Add(pReq As WaGroupCreateRequest) As WaApiResult               ' "criar grupo"
Function All(pInstance As String = "") As WaApiResult                   ' "listar grupos"
Function Info(pReq As WaGroupInfoRequest) As WaApiResult                ' "info do grupo"
Function Participants(pReq As WaGroupInfoRequest) As WaApiResult        ' "participantes do grupo"
Function UpdateParticipant(pReq As WaGroupParticipantRequest) As WaApiResult ' "atualizar participante"
Function InviteLink(pReq As WaGroupInviteRequest) As WaApiResult        ' "link de convite"
Function Leave(pReq As WaGroupInfoRequest) As WaApiResult               ' "sair do grupo"
Function UpdateSubject(pReq As WaGroupUpdateTextRequest) As WaApiResult ' "atualizar assunto do grupo"
Function UpdateDescription(pReq As WaGroupUpdateTextRequest) As WaApiResult ' "atualizar descrição do grupo"
```

## DTOs

Each DTO is a `TTObject` with `ToJsonEvolution` / `ToJsonEvolutionGo` (or a single `ToJson`) used by the two REST clients. Empty optional strings are omitted unless noted. `Delay` is emitted on Evolution only when `> 0`; Evolution GO always emits `delay`.

Namespace helpers (quoted JSON arrays): `WaDtoSendStringListToJsonArray`, `WaDtoMessageStringListToJsonArray`, `WaDtoUserStringListToJsonArray`, `WaDtoChatStringListToJsonArray`, `WaDtoGroupStringListToJsonArray`. Empty/NULL list → `"[]"`. Example: `["5511999","5511888"]`.

### Instance

`WaInstanceCreateRequest` — `QrCode = True`, `Integration = "WHATSAPP-BAILEYS"`.

| Field | Evolution JSON | Evolution GO JSON |
| --- | --- | --- |
| `InstanceName` | `instanceName` | `name` and, if non-empty, `instanceId` |
| `Token` | `token` if non-empty | `token` if non-empty |
| `Number` | `number` if non-empty | (not sent) |
| `QrCode` | `qrcode` | (not sent) |
| `Integration` | `integration` if non-empty | (not sent) |

### Send

`WaSendTextRequest` — `LinkPreview = True`, `Delay = 0`. Evolution: `number`, `text`, `linkPreview`, optional `delay`. GO: `number`, `text`, `delay`.

`WaSendMediaRequest` — `Delay = 0`. Evolution: `number`, optional `mediatype` / `mimetype` / `caption` / `fileName`, required `media`, optional `delay`. GO: `type` from `GoType` else `MediaType`, `url` = `Media`, always `delay`.

`WaSendLocationRequest` — `Delay = 0`. `number`, optional `name`/`address`, `latitude`, `longitude`.

`WaSendContactRequest` — `Delay = 0`. Evolution wraps one contact (`fullName`, `wuid`/`phoneNumber`, `organization`, `email`, `url`) in `contact` array. GO: `vcard` object (`fullName`, `phone`, `organization`).

`WaSendStickerRequest` — `Delay = 0`. `number`, `sticker`.

`WaSendPollRequest` — `SelectableCount = 1`, `MaxAnswer = 1`, owned `Values` `StringList`, `Delay = 0`. Evolution: `name` (falls back to `Question`), `selectableCount`, `values`. GO: `question` (falls back to `Name`), `maxAnswer` (if `<= 0` uses `SelectableCount`), `options`.

`WaSendButtonsRequest` — `Delay = 0`, `ButtonsJson = "[]"` (empty string treated as `"[]"`). Fields: `number`, optional `title`/`description`/`footer`, `buttons` array. GO uses the same JSON as Evolution.

`WaSendListRequest` — `Delay = 0`, `SectionsJson = "[]"`. Fields: `number`, optional `title`/`description`/`buttonText`/`footerText`, `sections` array. GO uses the same JSON as Evolution.

`Instance` on send DTOs is **not** serialized; Evolution clients resolve it as the path instance via `ResolveInstance(pReq.Instance)`.

### Message ops

`WaMessageKey` — `FromMe = False`. JSON object: optional `remoteJid`/`id`/`participant`, always `fromMe`.

`WaMessageReactRequest` — owns a `WaMessageKey`. Evolution: `{ key, reaction }`. GO: `number` (or `Key.RemoteJid`), `id` (`Key.Id`), `reaction`.

`WaMessageMarkReadRequest` — `FromMe = False`, owned `MessageIds`. Evolution: `readMessages` array of key objects (`Id` alone, or one key per `MessageIds` entry). GO: if `MessageIds` is empty and `Id <> ""`, appends `Id`; body `{ number, messageIds }`.

`WaMessageDeleteRequest` — `FromMe = True`. Chat = `Chat` else `RemoteJid`. Id = `MessageId` else `Id`. Evolution: `{ id, remoteJid, fromMe }`. GO: `{ chat, messageId, fromMe }`.

`WaMessageEditRequest`. Evolution: `{ number: Chat, key: { remoteJid: Chat, fromMe: True, id: MessageId }, text: NewText }`. GO: `{ chat, messageId, text }`.

`WaMessagePresenceRequest` — `Presence = "composing"`, `Delay = 0`. Body `{ number, presence, delay? }`.

### User / chat / group

`WaUserLookupRequest` — owned `Numbers`. Evolution `{ numbers: [...] }`. GO `{ formatJid: True, number: [...] }`.

`WaUserProfileNameRequest` / `WaUserProfileStatusRequest` / `WaUserBlockRequest` — `{ name }` / `{ status }` / `{ number }`.

`WaChatActionRequest` — `Archive = False`, `HasArchive = False`. `SetArchive(pArchive)` sets both. JSON `{ chat, archive? }` only when `HasArchive`.

`WaCheckNumbersRequest` — owned `Numbers`. Same JSON shape as `WaUserLookupRequest`.

`WaFindFilterRequest` — `WhereJson = "{}"`. `ToJson()` returns `"{}"` if empty.

`WaGroupCreateRequest` — owned `Participants`. Subject = `Subject` else `GroupName`. Evolution `{ subject, participants, description? }`. GO `{ groupName, participants, description? }`.

`WaGroupInfoRequest` / `WaGroupInviteRequest` — `{ groupJid }`.

`WaGroupParticipantRequest` — owned `Participants`, `Action = "add"`. Evolution `{ participants, action? }` (no groupJid). GO also sends `groupJid`.

`WaGroupUpdateTextRequest`. Evolution `{ subject: Text }` (no groupJid). GO `{ groupJid, text }`.

## Auth and HTTP

### `WaAuth`

```basic
MustOverride Sub Apply(ByRef pHeaders As StringList)
```

`WaAuthNone.Apply` is a no-op.

`WaAuthApiKey(pApiKey, pHeaderName = "apikey")` upserts that header.

`WaAuthDualToken(pMasterToken, pInstanceToken, pHeaderName = "apikey")` starts on master (`UseMaster`). `UseInstance` switches to the instance token.

```basic
Shared Function FromCombinedToken(pToken As String, pHeaderName As String = "apikey") As WaAuthDualToken
   ' Throws "Token Dual deve estar no formato master@instance" when "@" is missing.
   ' Split("@")[0] = master, [1] = instance.
```

### `WaHttp`

JSON transport (`Accept`/`ContentType` `application/json`, TLS 1.2). NULL auth throws `"WaHttp requer um WaAuth injetado"`. Trailing `/` is stripped from the base URL. Paths starting with `http://` or `https://` are used as-is; other paths get a leading `/` and are appended to the base.

```basic
Sub New(pBaseUrl As String, pAuth As WaAuth, pOwnsAuth As Boolean = True)
Function Auth() As WaAuth
Function Gett(pPath As String) As String
Function Post(pPath As String, pBody As String) As String
Function Post(pPath As String, pBody As TJSONObject) As String
Function Put(pPath As String, pBody As String) As String
Function Put(pPath As String, pBody As TJSONObject) As String
Function Deletee(pPath As String, pBody As String = "") As String
   ' POST plus header "X-HTTP-Method-Override: DELETE"
Function StatusCode() As Integer
Function StatusText() As String
Function ResponseText() As String
Function ResponseAsJson() As TJSONObject     ' throws if body empty or not "{"
Function ResponseAsArray() As TJSONArray     ' throws if body empty or not "["
Function IsSuccess() As Boolean              ' 200..299
```

Empty body: `"Resposta HTTP vazia (status {code} {text})"`. Wrong shape: `"Resposta HTTP não é um objeto/array JSON (status {code}): {raw}"`.

## Clients

Instance resolution (Evolution + Evolution GO): override string if Trim non-empty, else `Options.Instance`. High-level `SendMessage` uses `pMessage.Sender` as that override.

HTTP helpers return `WaApiResult.Ok`/`Fail`; caught exceptions become `Fail(GetName(), ex._GetMessage())`.

### `WaEvolutionOptions` / `WaClientEvolution`

`GetName` = `"Evolution"`. REST v2, `WaAuthApiKey(Token)` header `apikey`. `Online`: GET `/` status **200**.

```basic
Sub New()
Sub New(pHost As String, pToken As String, pInstance As String = "")
Sub Validate()
   ' Host Trim "" → "WaEvolutionOptions.Host é obrigatório"
   ' Token Trim "" → "WaEvolutionOptions.Token (apikey) é obrigatório"
```

| Member | Default | Notes |
| --- | --- | --- |
| `Host` / `Token` / `Instance` | `""` | |
| `ValidatePhoneOnProvider` | `True` | `SendMessage` calls `ValidatePhone` first |
| `Formatter` | `CreateDefault()` | owned |
| `Layout` | formatter layout | |
| `MessageWithLastAttachment` | True while layout is CaptionLast | True → `CaptionOnLast`; False → `SeparateTextBefore` |
| `SendCaption` | layout flag | |

Client constructor: NULL options throws `"WaClientEvolution requer WaEvolutionOptions"`; then `Validate()`. `GetFormatter` is `Options.Formatter`.

`SendMessage`: empty resolved instance → `WaSendResult.Fail(..., "Instance/Sender é obrigatório na Evolution")`. Then optional provider phone check, then formatter plan. Text steps call `SendText`; media steps send `MediaType = "document"` and `Media = attachment.ToBase64()`. Empty text steps are skipped. Plan NULL is a no-op success.

**Endpoints (instance in the path, from `ResolveInstance`):**

| Method | HTTP |
| --- | --- |
| `InstanceCreate` | POST `/instance/create` |
| `InstanceAll` | GET `/instance/fetchInstances` — array; `connectionStatus` `"OPEN"` → Connected; phone = `ownerJid` before `@` |
| `InstanceInfo` | scan `InstanceAll` (case-insensitive Id/Name); else GET `/instance/connectionState/{id}` (`instance.state` `"OPEN"`) |
| `InstanceConnect` | GET `/instance/connect/{id}` |
| `InstanceStatus` | GET `/instance/connectionState/{id}` |
| `InstanceRestart` | POST `/instance/restart/{id}` `{}` |
| `InstanceLogout` | DELETE `/instance/logout/{id}` |
| `InstanceDelete` | DELETE `/instance/delete/{id}` |
| `InstanceQr` | **not overridden** — base throw |
| `SendText` | POST `/message/sendText/{instance}` |
| `SendMedia` | POST `/message/sendMedia/{instance}` |
| `SendButtons` | POST `/message/sendButtons/{instance}` |
| `SendPoll` | POST `/message/sendPoll/{instance}` |
| `SendList` | POST `/message/sendList/{instance}` |
| `SendLocation` | POST `/message/sendLocation/{instance}` |
| `SendContact` | POST `/message/sendContact/{instance}` |
| `SendSticker` | POST `/message/sendSticker/{instance}` |
| `MessageReact` | POST `/message/sendReaction/{instance}` |
| `MessageMarkRead` | POST `/chat/markMessageAsRead/{instance}` |
| `MessageDelete` | DELETE `/chat/deleteMessageForEveryone/{instance}` with body |
| `MessageEdit` | POST `/chat/updateMessage/{instance}` |
| `MessagePresence` | POST `/chat/sendPresence/{instance}` |
| `UserInfo` | POST `/chat/whatsappNumbers/{instance}` |
| `UserCheck` | same as `UserInfo` |
| `UserContacts` | POST `/chat/findContacts/{instance}` body `{"where":{}}`; failure/exception returns an empty list (not throw) |
| `UserAvatar` | POST `/chat/fetchProfilePictureUrl/{instance}` `{"number":"..."}` |
| `UserBlock` / `UserUnblock` | POST `/message/updateBlockStatus/{instance}` `status` `"block"` / `"unblock"` |
| `UserSetProfileName` | POST `/chat/updateProfileName/{instance}` |
| `UserSetProfileStatus` | POST `/chat/updateProfileStatus/{instance}` |
| `ValidatePhone` | POST `/chat/whatsappNumbers/{instance}`; empty array or `exists=false` throws `"Número inválido no WhatsApp: {phone}"` |
| `GetContact` | `ValidatePhone` then a `WaContact` with `Exists True` |
| `ChatFind` | POST `/chat/findChats/{instance}` with `WhereJson` |
| `ChatFindMessages` | POST `/chat/findMessages/{instance}` |
| `ChatFindContacts` | POST `/chat/findContacts/{instance}` |
| `ChatArchive` | POST `/chat/archiveChat/{instance}` |
| `ChatPin` / `Unpin` / `Mute` / `Unmute` | `WaApiResult.Fail(..., "ChatPin/… não disponível na Evolution API v2")` |
| `ChatCheckNumbers` | POST `/chat/whatsappNumbers/{instance}` |
| `GroupCreate` | POST `/group/create/{instance}` |
| `GroupList` | GET `/group/fetchAllGroups/{instance}?getParticipants=false` |
| `GroupInfo` | GET `/group/findGroupInfos/{instance}?groupJid={GroupJid}` |
| `GroupParticipants` | GET `/group/participants/{instance}?groupJid={GroupJid}` |
| `GroupUpdateParticipant` | POST `/group/updateParticipant/{instance}?groupJid={GroupJid}` |
| `GroupInviteLink` | GET `/group/inviteCode/{instance}?groupJid={GroupJid}` |
| `GroupLeave` | DELETE `/group/leaveGroup/{instance}?groupJid={GroupJid}` |
| `GroupUpdateSubject` | POST `/group/updateGroupSubject/{instance}?groupJid={GroupJid}` |
| `GroupUpdateDescription` | POST `/group/updateGroupDescription/{instance}?groupJid={GroupJid}` body `{"description":Text}` |

### `WaEvolutionGoOptions` / `WaClientEvolutionGo`

`GetName` = `"EvolutionGO"`. Dual token: master for instance create/list/info/delete; instance token for send and instance connect/status/qr. `Online`: master GET `/instance/all`, `IsSuccess` (false on exception).

```basic
Sub New()
Sub New(pHost As String, pMasterToken As String, pInstanceToken As String, pInstance As String = "")
Shared Function FromCombinedToken(pHost As String, pCombinedToken As String, pInstance As String = "") As WaEvolutionGoOptions
   ' Throws "Token EvolutionGO deve estar no formato master@instance"
Sub Validate()
   ' Host empty → "WaEvolutionGoOptions.Host é obrigatório"
   ' Master or instance empty → "WaEvolutionGoOptions.MasterToken e InstanceToken são obrigatórios"
```

Same layout properties as Evolution options, plus `Filter` (`""`). `InstanceAll` keeps rows whose `name` contains `Filter` (case-insensitive); empty filter keeps all. Id/Name = JSON `name`; Phone = `jid` before `:`; Connected from JSON.

`SendMessage` does not require Sender if `Options.Instance` is set. Media plan steps set `GoType = "document"` and `Media = ToBase64()`. `ChatFind` / `FindMessages` / `FindContacts` return `Fail(..., "ChatFind não disponível no Evolution GO")` (same pattern for the three names). `ChatArchive` posts `/chat/archive` unless `HasArchive And Not Archive` → `/chat/unarchive`.

`InstanceConnect` / `Status` / `Restart` / `Logout` / `Qr` ignore `pId` (instance token). `InstanceDelete` is master DELETE `/instance/delete/{pId}`. `InstanceCreate` is master POST `/instance/create`.

| Method | HTTP |
| --- | --- |
| `InstanceAll` | GET `/instance/all` (master), array at `data` |
| `InstanceInfo` | GET `/instance/info/{pId}` (master), object or `data` |
| `InstanceConnect` | POST `/instance/connect` `{}` |
| `InstanceStatus` | GET `/instance/status` |
| `InstanceRestart` | POST `/instance/reconnect` `{}` |
| `InstanceLogout` | DELETE `/instance/logout` |
| `InstanceQr` | GET `/instance/qr` |
| Send | POST `/send/text|media|button|poll|list|location|contact|sticker` |
| Message | POST `/message/react|markread|delete|edit|presence` |
| User | POST `/user/info|check|avatar|block|unblock|profileName|profileStatus`; GET `/user/contacts` |
| Chat | POST `/chat/archive|unarchive|pin|unpin|mute|unmute`; check numbers = `/user/check` |
| Group | POST `/group/create`, `/group/info` (`GroupParticipants` is the same call), `/group/participant`, `/group/invitelink`, `/group/leave`, `/group/name`, `/group/description`; GET `/group/list` |

`UserContacts` accepts a JSON array or `{ data: [...] }`. Id from `id` else `jid`; Phone = Id before `@`; Name from `name` else `notify` else `pushname`; `Exists = True`.

`ValidatePhone` throws `"Número inválido no WhatsApp: {phone}"` when the check fails.

### `WaDesktopOptions` / `WaClientDesktop`

`GetName` = `"Desktop"`. `LimitedSend` only. `Online` is True when a visible window matches `WindowTitle` (`FindByTitle`, else `FindContains`).

| Member | Default | Notes |
| --- | --- | --- |
| `WindowTitle` | `"WhatsApp"` | `Validate` replaces Trim empty with `"WhatsApp"` |
| `AutoSend` | `True` | ENTER / click send |
| `OpenWaitMs` | `1500` | Negative clamped to 0 |
| `PasteWaitMs` | `1500` | Before and after Ctrl+V |
| `EnterWaitMs` | `400` | After ENTER |
| `RestoreFocus` | `True` | Restores previous foreground after AutoSend |

NULL options throws `"WaClientDesktop requer WaDesktopOptions"`.

`SendMessage` flow:

1. Require WhatsApp window; missing → `"O WhatsApp não está aberto. Abra o aplicativo e tente novamente."`
2. Format text; open `whatsapp://send?phone={digits}` (`&text=` URI-encoded when text is non-empty). Empty digits → `"Informe um destinatário válido para o WhatsApp Desktop."` Shell failure (`<= 32`) → `"Não foi possível abrir a conversa no WhatsApp Desktop."`
3. If layout `EffectiveModeName = "SeparateBefore"` and there are attachments and text, confirm-send the URI text first.
4. Existing attachment paths are copied with `ClipboardManager.SetFiles`; failure → `"Não foi possível copiar os arquivos para a área de transferência."` Then Ctrl+V. `AttachmentsReversed` reverses paste order. Missing paths are skipped.
5. If `AutoSend`, click near the bottom-right of the window and `{ENTER}`.

### `WaDevStudioOptions` / `WaClientDevStudio`

`GetName` = `"DevStudio"`. `Deprecated()`. `Validate` is a no-op. Parameterless constructor owns a new `WaDevStudioOptions`. `SendMessage` maps onto native `WhatsappSend` / `WhatsappMessage` (Recipient/Subject/Content/Signature + attachment paths). Native False → `Fail(..., "WhatsappSend.SendMessage retornou False")`.

`WaService` / `WaCompose` send path refuses this client (`IsDeprecated`).

## Compose UI

### Delegates (`mod_wa_compose_options`)

```basic
Delegate Sub WaCanDelegate(ByRef pCan As Boolean)
Delegate Sub WaChangeDelegate(pPropChanged As String, pOptions As WaComposeOptions)
Delegate Sub WaBeforeSendDelegate(pMessage As WaMessage, ByRef pSend As Boolean, ByRef pClose As Boolean)
Delegate Sub WaIndexDelegate(pIndex As Integer)
Delegate Sub WaInstancesDelegate(ByRef pInstances As WaInstanceList)
```

### `WaComposeOptions`

| Property | Default | Notes |
| --- | --- | --- |
| `Title` | `"Envio WhatsApp"` | Form caption |
| `DefaultDDD` | `"66"` | Local area code for masks |
| `CountryCode` | `"55"` | Prefixed on OK |
| `CloseAfterSend` | `True` | Close form after successful send |
| `CanChangeRecipient` / `CanChangeSender` | `True` | Enable editors |
| `CanChangeClient` | `False` | Combo visible only with `HasClients` |
| `RequiresSender` | `False` | Overwritten from `NeedsSender` when compose binds the client |
| `ClientName` / `ClientFeatures` | `""` | Info tab; features like `"Texto, Mídia"` or `"Envio básico"` |
| `DefaultClient` | `""` | Key/label/`GetName` lookup |
| `SenderNameFilter` | `""` | `KeepNameContains` on loaded instances |
| `MessageOnExit` | `""` | Close confirmation when Trim non-empty |
| `Message` | owned `WaMessage` | Setter frees the previous message |
| `Senders` / `Recipients` | owned `WaContactList` | |
| `Clients` | owned `WaComposeClientList` | |
| `Formatter` | `NULL` until `EnsureFormatter` | Setter does not take ownership |
| `Layout` / `OnFormatText` / `OnBuildPlan` | via formatter | |
| `OnChange` | `NULL` | Fired when `Notify` is True |
| `OnFilterInstances` | `NULL` | Extra instance filter after `SenderNameFilter` |
| `Notify` | `True` | |

```basic
Function EnsureFormatter() As WaMessageFormatter    ' lazy CreateDefault, owned
Sub ApplyFormatterTo(pMessage As WaMessage)         ' assigns formatter reference if both assigned
Function HasSenders() As Boolean
Function HasClients() As Boolean
Function ShowSender() As Boolean                    ' RequiresSender And HasSenders
Function ShowClient() As Boolean                    ' CanChangeClient And HasClients
```

Property names dispatched to `OnChange`: `Title`, `DefaultDDD`, `CountryCode`, `CloseAfterSend`, `CanChangeRecipient`, `CanChangeSender`, `CanChangeClient`, `RequiresSender`, `ClientName`, `ClientFeatures`, `DefaultClient`, `SenderNameFilter`, `MessageOnExit`, `Message`, `Senders`, `Recipients`, `Clients`, `Formatter`, `Layout`, `OnFormatText`, `OnBuildPlan`.

### `WaComposeClient` / `WaComposeClientList`

```basic
Sub New(pClient As WaClient, pLabel As String = "", pKey As String = "", pOwnsClient As Boolean = False)
   ' NULL client throws "WaComposeClient requer um WaClient".
   ' Empty Key → Client.GetName(); empty Label → Key.
Function Matches(pValue As String) As Boolean
   ' False if Trim empty. True if Key, Label, or Client.GetName equals pValue.
```

`GetID` is `Key`. `Dispose` frees `Client` only when `OwnsClient`.

```basic
Sub Add(pEntry As WaComposeClient)
   ' NULL entry: no-op. Duplicate Client pointer: if OwnsClient, clears it, frees entry, no-op.
Sub Add(pClient As WaClient, pLabel As String = "", pKey As String = "", pOwnsClient As Boolean = False)
Function Take(pIndex As Integer) As WaComposeClient
Function Count() As Integer
Function IndexOfClient(pClient As WaClient) As Integer   ' -1 if NULL/empty/not found
Function IndexOfKey(pValue As String) As Integer         ' Matches(); -1 if Trim empty
Function Find(pValue As String) As WaComposeClient       ' NULL when IndexOfKey < 0
```

### `WaCompose`

```basic
Sub New()
Sub New(pClient As WaClient, pOwnsClient As Boolean = True)
Sub New(pService As WaService, pOwnsService As Boolean = False)
Sub New(pService As WaService, pOptions As WaComposeOptions, pOwnsService As Boolean = False, pOwnsOptions As Boolean = False)
   ' NULL client/service/options throw "WaCompose requer um WaClient" / "… WaService injetado" / "… WaComposeOptions"

Function Message() As WaMessage
Function Sent() As Boolean
Function LastResult() As WaSendResult                    ' NULL until a send attempt
Function Service() As WaService
Sub RegisterClient(pClient As WaClient, pLabel As String = "", pKey As String = "", pOwnsClient As Boolean = False)
   ' NULL: no-op. If pClient is already Service.Client, OwnsClient is forced False.
   ' First registered client becomes Service.Client when none is set.
Function Show() As Boolean                               ' returns Sent
Sub Close()                                              ' no-op if form missing or not IsOpen
Function SendMessage() As Boolean
```

**`Show`**

1. Ensure the current `WaService` client is in `Options.Clients` (not owned).
2. `DefaultClient` → `Clients.Find`; else current service client; else `Take(0)`. Missing client throws `"WaCompose requer ao menos um WaClient. Use RegisterClient."`
3. Bind `ClientName`, `ClientFeatures`, `RequiresSender` from capabilities.
4. If `RequiresSender` and no senders and `CanManageInstances`: `Instance.All()`, `KeepNameContains(SenderNameFilter)`, then `Options.OnFilterInstances` and `Compose.OnFilterInstances` (if a handler replaces the list, the previous list is freed). Each instance becomes a `WaContact` (`Id` = instance Id else Name; `Name` = ProfileName else Name; `Phone`). If `Message.Sender` is still empty, it becomes first sender Id else Name. Load errors show `"Não foi possível carregar os remetentes, verifique!"`.
5. Rebuild form/rules/events. `OnCanShow` may set `pCanShow` False (form stays closed). `Show` return value is `Sent` (False unless the user already sent in that session).

**`SendMessage`**

1. `OnBeforeSend(Message, pSend, pClose)` with `pClose = CloseAfterSend`. `pSend False` → return False (no-op send).
2. `ApplyFormatterTo(Message)` then `Service.Send.Message`. Failure shows `"Erro ao enviar mensagem, verifique!"` plus result/exception text.
3. On success and `pClose`, `MessageOnExit` is cleared and the form closes.

**Close guard:** `OnCanClose` if set; else if a send is in flight, confirmation `"A mensagem está sendo enviada, deseja realmente cancelar?"`; else if `MessageOnExit` Trim non-empty, that confirmation.

Client combo change activates that client, clears senders, and reloads them.

### Form OK rules (`WaComposeRules.HandlerOnBtnOk`)

Returns False (focus stays on the form) when:

- `ShowSender` and Sender Trim empty → `"Informe um remetente para prosseguir, verifique."`
- Recipient digits length **< 10** → `"Informe um destinatário válido para prosseguir, verifique."`
- Content Trim empty **and** no attachments → `"Informe uma mensagem ou um arquivo em anexo para envio, verifique."`

On success, Recipient is rewritten with `WaPhoneMask.WithCountryCode(..., CountryCode, DefaultDDD)`.

**Attachments:** `AddAttachment` no-op if path empty, file missing, or `IndexOfPath >= 0`. Empty caption becomes filename without extension. Grid col 0 is `"true"`/`"false"` (selected); double-click toggles membership in `Message.Attachments`. File dialog filter: `"Todos os arquivos|*.*"`.

### `WaComposeForm`

`TFormsSimple` titled `"Envio WhatsApp"`. `IsOpen` is set by show/close handlers. `ApplyAppRow(pShowClient, pShowSender)` hides the app row when both are False.

### `WaComposeEvents`

Wires form controls to `WaComposeRules`. Recipient mask on key-down: temporary `"(99) 9999999999"` then `GetMaskPhone`.

## Helpers

### `WaPhoneMask`

```basic
Shared Function OnlyNumbers(pValue As String) As String          ' "" if Length = 0
Shared Function Apply(pPhone As String, pDefaultDDD As String) As String
   ' Strips country (12/13 digits → drop first 2).
   ' 11 → "(AA) XXXXX-XXXX"; 10 → "(AA) XXXX-XXXX"; 9 → "(DDD) XXXXX-XXXX"; else "(DDD) XXXX-XXXX"
Shared Function GetMask(pPhone As String) As String
   ' Length < 11 → "(99) 9999-9999" else "(99) 99999-9999"
Shared Function DigitFromKey(pKey As Integer) As String
   ' 48..57 main digits, 96..105 numpad; else ""
Shared Function WithCountryCode(pPhone As String, pCountryCode As String, pDefaultDDD As String) As String
   ' Already country+12/13 → unchanged. 8/9 digits get DefaultDDD first, then CountryCode prefix if missing.
```

Example: `Apply("5566999050312", "66")` → `"(66) 99905-0312"`; `WithCountryCode("999050312", "55", "66")` → `"5566999050312"`.

### `WaFormHelper`

Layout helpers used by the compose form. `IsDevStudio` is True when `devstudio.exe` sits next to `Data7.NomeArquivoExecutavel`. `SizeHeaderForm` = **35** (DevStudio) / **27**. `SizeBorderForm(pMultiplicator = 1)` = (4 or 2) × multiplier. Required labels use font color RGB(0,0,255).

```basic
Shared Sub BuildControlGroup(pTitle As String, pParent As Forms.TWinControl, pTop As Integer, pHeight As Integer, pWidth As Integer)
Shared Function BuildLabel(...) As Forms.StaticText
Shared Function BuildLabelOnTop(...) As Forms.StaticText
Shared Function BuildTextField(...) As Forms.TextBox
Shared Function BuildComboBox(...) As Forms.HComboBox
Shared Function SizeHeaderForm() As Integer
Shared Function SizeBorderForm(pMultiplicator As Integer = 1) As Integer
Shared Function IsDevStudio() As Boolean
```

## Extending (Consumer Project)

```basic
Class TMyWaClient
   Inherits WaClient

   Overrides Function GetName() As String
      GetName = "MyProvider"
   End Function

   Overrides Function GetCapabilities() As WaCapabilities
      GetCapabilities = WaCapabilities.LimitedSend()
   End Function

   Overrides Function SendMessage(pMessage As WaMessage) As WaSendResult
      SendMessage = WaSendResult.Ok(me.GetName(), pMessage.Recipient)
   End Function
End Class

Dim mine As New TMyWaClient()
Dim wa As New WaService(mine, True)
' Optional typed APIs: override SendText, InstanceAll, GroupCreate, … on TMyWaClient.
' Unimplemented members keep the base throw "{Method} não suportado por MyProvider".

Dim compose As New WaCompose()
compose.RegisterClient(mine, "Meu app", "my", True)
compose.Show()
```

`WaComposeOptions.OnFormatText` / `OnBuildPlan` intercept layout without a new client. `OnFilterInstances` can replace or shrink the `WaInstanceList` used as senders.

## Module Notes

- Resource lists (`WaMessageList`, `WaAttachmentList`, `WaContactList`, `WaInstanceList`, `WaComposeClientList`, `WaSendPlan`) own their items (`TTObjectList` owns=True). `WaSendStep.Attachment` and `WaMessage.Formatter` are references.
- `WaService` owns resources and, when constructed that way, the client and/or validator. `WaCompose` owns its internal `WaService`/`WaComposeOptions` unless injected with `pOwns* = False`. `RegisterClient(..., True)` is the usual client ownership for compose.
- `WaClientEvolutionGo.Filter` and `WaComposeOptions.SenderNameFilter` are independent name substring filters (case-insensitive). Empty string = no filter.
- Evolution GO `InstanceConnect`/`Status`/`Restart`/`Logout`/`Qr` use the instance token, not `pId`. Evolution `InstanceQr` is unimplemented. Evolution pin/mute APIs return `WaApiResult.Fail`. Evolution GO chat-find APIs return `Fail`.
- High-level Evolution/GO send always uses media type `"document"` and `ToBase64()`; typed `wa.Send.Media` sends the DTO as-is (`url` vs `media` depends on `ToJsonEvolutionGo` / `ToJsonEvolution`).
- Desktop send requires a running WhatsApp window titled (default) `"WhatsApp"` and uses `whatsapp://send?phone=` plus clipboard file paste. `AutoSend False` leaves the chat open without ENTER.
- `WaClientDevStudio` is `Deprecated`: the compose form can register it, but `WaService` send/resource calls throw. There is no `TXxxxTests.RunAll` in this module; `src/Principal.bas` is a compose demo, not a test suite.
