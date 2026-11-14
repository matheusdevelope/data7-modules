# mod_editors

`mod_editors` is a labeled-editor library for Data7 forms. Each editor is a caption plus a native control (or a small composite) stacked with `Align = alTop` on a parent `TWinControl`. Values move through `Text` / `AsString` (and typed accessors where they exist). Document editors validate with `mod_validators`. Image I/O uses `mod_io`, `mod_camera`, and `mod_clipboard_manager`.

This module does **not** own the parent form, SQL, persistence, or business rules. The consumer creates the parent, constructs editors, sets values, and reacts to events.

Version: **1.0.0.1** (`data7.json`). Dependencies: `mod_regex` 1.0.0.0, `mod_winapi` 1.0.0.0, `mod_clipboard_manager` 1.0.0.0, `mod_camera` 1.0.0.0, `mod_io` 1.0.0.0, `mod_validators` 1.0.0.0.

This file is the module contract. Use the API from here. Do not open `.bas` files to consume the module. Open implementation only to confirm a detail that is not stated below.

## Quick Start (Minimal)

```bas
Imports Forms
Imports mod_editors
Imports mod_editors_text
Imports mod_editors_memo
Imports mod_editors_value
Imports mod_editors_combo
Imports mod_editors_cpf
Imports mod_editors_image

Dim _form As New Form()
_form.Width = 800
_form.Height = 700
Dim _page As New PageControl(_form)
_page.Align = alClient

' optional bag applied in the constructor after the control is built
Dim _topProps As New TEditorProps()
_topProps.Placement = TLabelPlacement.Top()
_topProps.LabelWidth = 120
_topProps.LabelBold = True

Dim _nome As New TTextEditor(_page, "Nome", _topProps)
_nome.Required = True
_nome.Text = "ACME"

Dim _obs As New TMemoEditor(_page, "Observação")
_obs.LabelPlacement = TLabelPlacement.Top()

Dim _valor As New TValueEditor(_page, "Valor")
_valor.DecimalPlaces = 2
_valor.DisplayFormat = ",0.00"

Dim _combo As New TComboEditor(_page, "Situação")
_combo.ListaOpcoes = "A=Ativo,I=Inativo"

Dim _cpf As New TCPFEditor(_page, "CPF")
_cpf.Text = "39053344705"

Dim _imagem As New TImageEditor(_page, "Logomarca")
_imagem.AsString = ""   ' raw Base64 payload, no data-URI prefix

_form.Show()
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_editors.bas` | `mod_editors` | `TLabelPlacement`, `TFontFace`, `TEditorProps`, `CharCaseFromCode`, `TLabeledEditorBase`, `TLabeledEditor<T>` |
| `src/lib/editors/base/mod_editors_text.bas` | `mod_editors_text` | `TTextEditor` |
| `src/lib/editors/base/mod_editors_password.bas` | `mod_editors_password` | `TPasswordEditor` |
| `src/lib/editors/base/mod_editors_mask.bas` | `mod_editors_mask` | `TMaskEditor` |
| `src/lib/editors/base/mod_editors_memo.bas` | `mod_editors_memo` | `TMemoEditor` |
| `src/lib/editors/base/mod_editors_value.bas` | `mod_editors_value` | `TValueEditor` |
| `src/lib/editors/base/mod_editors_integer.bas` | `mod_editors_integer` | `TIntegerEditor` |
| `src/lib/editors/base/mod_editors_number.bas` | `mod_editors_number` | `TNumberEditor` |
| `src/lib/editors/base/mod_editors_search.bas` | `mod_editors_search` | `TSearchEditor` |
| `src/lib/editors/base/mod_editors_combo.bas` | `mod_editors_combo` | `TComboEditor` |
| `src/lib/editors/base/mod_editors_check.bas` | `mod_editors_check` | `TCheckEditor` |
| `src/lib/editors/base/mod_editors_datetime.bas` | `mod_editors_datetime` | `TDateTimeEditor` |
| `src/lib/editors/base/mod_editors_date.bas` | `mod_editors_date` | `TDateEditor` |
| `src/lib/editors/base/mod_editors_time.bas` | `mod_editors_time` | `TTimeEditor` |
| `src/lib/editors/base/mod_editors_button.bas` | `mod_editors_button` | `ButtonedTextBox`, `TButtonEditor` |
| `src/lib/editors/base/mod_editors_image.bas` | `mod_editors_image` | `TImageEditor` |
| `src/lib/editors/custom/mod_editors_docs.bas` | `mod_editors_docs` | `TDocEditor` |
| `src/lib/editors/custom/mod_editors_cpf.bas` | `mod_editors_cpf` | `TCPFEditor` |
| `src/lib/editors/custom/mod_editors_cnpj.bas` | `mod_editors_cnpj` | `TCNPJData`, `TCNPJEditor` |
| `src/lib/editors/custom/mod_editors_cpf_cnpj.bas` | `mod_editors_cpf_cnpj` | `TCPFCnpjEditor` |
| `src/lib/editors/custom/mod_editors_cep.bas` | `mod_editors_cep` | `TCEPEditorData`, `TCEPEditor` |
| `src/lib/editors/custom/mod_editors_email.bas` | `mod_editors_email` | `TEmailEditor` |
| `src/lib/editors/custom/mod_editors_site.bas` | `mod_editors_site` | `TSiteEditor` |
| `src/lib/editors/custom/mod_editors_cnh.bas` | `mod_editors_cnh` | `TCNHEditor` |
| `src/lib/editors/custom/mod_editors_placa.bas` | `mod_editors_placa` | `TPlacaEditor` |
| `src/lib/editors/custom/mod_editors_gtin.bas` | `mod_editors_gtin` | `TGTINEditor` |
| `src/lib/editors/custom/mod_editors_ie.bas` | `mod_editors_ie` | `TIEEditor` |
| `src/lib/editors/custom/mod_editors_renavam.bas` | `mod_editors_renavam` | `TRenavamEditor` |
| `src/lib/editors/custom/mod_editors_suframa.bas` | `mod_editors_suframa` | `TSuframaEditor` |
| `src/Principal.bas` | *(script)* | `Demo1` |

There is no `Make` / `MakeByName` / type catalog. Construct the concrete class.

Import the namespace of the editor you instantiate. `TMemoEditor` in this module is `mod_editors_memo.TMemoEditor` wrapping `MemoTextBox`.

## Construction and layout

Every concrete editor:

```bas
Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
```

Build order:

1. Host `CustomControl` (`Align = alTop`) + label `StaticText` + slot `CustomControl`.
2. `CreateControl()` — native/composite control inside the slot.
3. Bind `LabelFont` / `EditorFont`; wrap native events.
4. `Caption = pCaption`; `OnBuilt()`; relayout.
5. If `pProps <> Null`, `Apply(pProps)`.

Host default height comes from `EditorHeight` (27) plus 14 when the label is `Top` or `Bottom`. `Hidden` hides the label and uses `EditorHeight` only.

```bas
Enun TLabelPlacement
   Left = "Left"       ' default; caption right-justified, width = LabelWidth
   Top = "Top"
   Right = "Right"
   Bottom = "Bottom"
   Hidden = "Hidden"   ' label Visible=False
End Enun
```

Left/Right: if `Caption.Length <= 20`, label `Margins.Top = 3`. Slot margins: Top 1, Bottom 4. Spacing is `LabelSpacing` (default 6) on the label side.

There is no factory. Stack editors by creating them in order on the same parent.

## Core (`mod_editors`)

### `CharCaseFromCode`

```bas
Function CharCaseFromCode(pCode As String) As TCharacterCasing
' "U" → ccUpper, "L" → ccLower, anything else (including "") → ccNormal
```

### `TFontFace`

Value object for label or editor font. After `Bind`, gets/sets go to the live control. Unbound gets return stored fields.

| Member | Default | Notes |
|---|---|---|
| `Name` | `""` | empty is stored; `Apply` skips empty |
| `Size` | `0` | `Apply` skips `<= 0` |
| `Color` | `-1` | `Apply` skips `< 0` |
| `Bold` / `Italic` / `Underline` | False | `Apply` always writes these three |

```bas
Sub Bind(pHost As TLabeledEditorBase, pKindLabel As Boolean)
' pKindLabel True = label font, False = editor font

Sub Apply(pName As String = "", pSize As Integer = 0, pBold As Boolean = False, pItalic As Boolean = False, pColor As Integer = -1, pUnderline As Boolean = False)
' 1. optional Name/Size/Color as above
' 2. Bold/Italic/Underline always set to the arguments (defaults False)
' 3. flush to host if bound
```

`Apply("Segoe UI")` also forces Bold/Italic/Underline to False.

Editor font is written only when the native control inherits `TcxCustomEdit`. Label font always maps to `StaticText.Font`. Non-cx editors (`Imagem`, `CheckBox`, image chrome) keep stored editor-font fields and do not paint them.

### `TEditorProps`

Optional constructor bag. `Apply` ignores `Null`. Sentinels mean “leave the editor default”:

| Field | Default | Applied when |
|---|---|---|
| `Caption` | `""` | `<> ""` |
| `FieldName` | `""` | `<> ""` → `Name` |
| `Placement` | `TLabelPlacement.Left()` | `Assigned` |
| `LabelWidth` | `80` | `> 0` |
| `LabelSpacing` | `6` | always |
| `EditorHeight` | `0` | `> 0` |
| `Align` | `alTop` | always |
| `Width` / `Height` | `0` | `> 0` |
| `Left` / `Top` | `-1` | `>= 0` |
| `Enabled` / `Visible` / `TabStop` | True | always |
| `TabOrder` | `-1` | `>= 0` |
| `Required` | False | always (after label color) |
| `RequiredColor` | `-1` | `>= 0` |
| `Hint` / `Ajuda` / `TextHint` | `""` | `<> ""` |
| `OnlyRead` | False | always |
| `MaxLength` | `0` | `> 0` |
| `Mask` | `""` | `<> ""` (mask / button / docs `OnApply`) |
| `CharCase` | `ccNormal` | `<> ccNormal` |
| `LabelName` / `EditorName` | `""` | `<> ""` |
| `LabelSize` / `EditorSize` | `0` | `> 0` |
| `LabelBold` / `LabelItalic` / `EditorBold` / `EditorItalic` / `EditorUnderline` | False | always |
| `LabelColor` / `EditorColor` / `EditorBackColor` | `-1` | `>= 0` (`EditorBackColor` → `EditorColor`) |
| `EditorAlignment` | `""` | copied to the editor field; not pushed to the native control |
| `DecimalPlaces` | `-1` | `>= 0` (`TValueEditor`) |
| `DisplayFormat` | `""` | `<> ""` (`TValueEditor`) |
| `ListaOpcoes` | `""` | `<> ""` (`TComboEditor`) |
| `CodPesquisa` | `0` | `> 0` (`TSearchEditor`) |
| `TipoPesquisa` | `""` | `<> ""` — stored on `TSearchEditor`, not written to `Control` |
| `PesquisaIncremental` | False | stored on `TSearchEditor`, not written to `Control` |
| `ExpressaoFiltro` | `""` | `<> ""` (`TSearchEditor`) |
| `ShowTime` / `TimeOnly` | False | **not read** by any current `Apply` / `OnApply` |

`FieldName` is also a public field on `TLabeledEditorBase` (copied even when empty).

### `TLabeledEditorBase`

Must-inherit shell. Consumers use `TLabeledEditor<T>` or a concrete editor.

```bas
Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)

Property Host As CustomControl          ' Get only
Property Label As StaticText            ' Get only
Property Slot As CustomControl          ' Get only
Property LabelFont As TFontFace         ' Get only, already bound
Property EditorFont As TFontFace        ' Get only, already bound
Property IsFocused As Boolean           ' Get only

FieldName As String
EditorAlignment As String

OnExit As TNotifyEvent                  ' native sender
OnEnter As TNotifyEvent
OnValidate As TNotifyEvent              ' sender is the editor (`me`), on Exit when ShouldRunValidate
OnKeyPress As TKeyPressEvent
OnClick As TNotifyEvent
OnDblClick As TNotifyEvent              ' wired only for TcxCustomTextEdit
OnChange As TNotifyEvent
OnFocusChanged As TNotifyEvent

Sub Apply(pProps As TEditorProps)       ' Null → no-op
Sub Clear()                             ' SetText("")
Sub SetFocus()                          ' no-op on the base; generic focuses TWinControl

Function Place(pPlacement As TLabelPlacement) As TLabeledEditorBase
Function WithLabelWidth(pWidth As Integer) As TLabeledEditorBase
Function WithFonts(pLabelSize As Integer, pEditorSize As Integer, pLabelBold As Boolean = False) As TLabeledEditorBase
```

| Property | Default | Notes |
|---|---|---|
| `Caption` | constructor `pCaption` | required prefix uses `RequiredColor`, not extra caption text |
| `Required` | False | True: snapshot idle label color, set `LabelFont.Color = RequiredColor` |
| `RequiredColor` | `RGB(0, 0, 255)` | |
| `LabelPlacement` | `Left` | relayout |
| `LabelWidth` | `80` | |
| `LabelSpacing` | `6` | |
| `EditorHeight` | `27` | host height follows placement rules |
| `Align` | `alTop` | host |
| `AlignWithMargins` | host default | |
| `Left` / `Top` / `Width` / `Height` | host | |
| `Visible` | True | host |
| `Enabled` | True | host; subclasses may also disable inner chrome |
| `Hint` | `""` | host + label + `SetControlHint`; `ShowHint = True` |
| `Name` | `""` | control name; host becomes `pValue & "_host"` |
| `TabStop` | False until subclass | |
| `TabOrder` | `-1` until subclass | |
| `Text` / `AsString` | `GetBoundText` → `GetText` | same string pipeline |
| `OnlyRead` | False | |
| `Ajuda` | `""` | TcxCustomTextEdit only; else Get `""`, Set no-op |
| `Modified` | False | TcxCustomEdit `EditModified` |
| `EditorColor` | `0` | control `Color` |
| `TextHint` | `""` | TcxCustomTextEdit: maps to control `Hint` (same native slot as `Hint`) |
| `MaxLength` | `0` | `TextBox` only in the generic |
| `CharCase` | `ccNormal` | `TextBox` only in the generic |
| `SelStart` / `SelLength` | `0` | TcxCustomTextEdit |

`OnValidate` default `ShouldRunValidate` is True. KeyPress: subclass `OnControlKeyPress` runs first; if `Asc(pKey) = 0`, native and consumer handlers are skipped.

Overridable hooks (no bodies here): `CreateControl` (must), `OnBuilt`, `OnApply`, `ShouldRunValidate`, `OnControlKeyPress`, mapped font Read/Write, Get/Set for enabled/hint/name/tab/text/readonly/ajuda/modified/focus/color/texthint/maxlength/charcase/sel, `SetFocus`, `_relayout`, `_bindNativeEvents`, `_bindEditValueEvents`.

### `TLabeledEditor<T>`

Generic labeled wrapper. Default `CreateControl`: `New T(_slot)` with `Align = alClient`. `Control As T` is the native instance.

Fluent `Place` / `WithLabelWidth` / `WithFonts` return `TLabeledEditor<T>`.

`GetText` / `SetText` by `T`:

| `T` | Get | Set |
|---|---|---|
| `MemoTextBox` | `Lines.Text` | `Lines.Text` |
| `NumberTextBox` | `CStr(Value)` | `Value = CDbl(pValue)` |
| `ValueTextBox` | `DecimalPlaces = 0` → `CStr(AsInteger)`, else `CStr(AsFloat)` | matching `AsInteger` / `AsFloat` |
| `TcxCustomTextEdit` | `Text` | `Text` |
| other | `""` | no-op |

Native `OnExit` / `OnEnter` / `OnKeyPress` / `OnDblClick` / `OnChange` / `OnFocusChanged` are wrapped only when `T` inherits `TcxCustomTextEdit`. `OnClick` is always wrapped.

## Base editors

All of these use the shared constructor. Extra members only.

### `TTextEditor` (`TextBox`)

No extra members. `MaxLength` and `CharCase` work.

### `TPasswordEditor` (`PasswordTextBox`)

No extra members.

### `TMaskEditor` (`MaskTextBox`)

```bas
Property Mascara As String   ' native Control.Mascara
Property Mask As String      ' alias of Mascara
```

`OnApply`: `pProps.Mask <> ""` → `Mascara`. Example: `"999.999.999-99"`.

### `TMemoEditor` (`MemoTextBox`)

`OnBuilt` sets `EditorHeight = 70` (then `Apply` may raise it if `EditorHeight > 0`).

| Member | Notes |
|---|---|
| `Lines As TStrings` | Get only, native `Control.Lines` |
| `WordWrap As Boolean` | native |

`Text` is `Lines.Text`. Import `mod_editors_memo`.

### `TValueEditor` (`ValueTextBox`) / `TIntegerEditor`

```bas
Property DecimalPlaces As Integer
Property DisplayFormat As String          ' e.g. ",0.00"
Property AsInteger As Integer
Property AsDouble As Extended             ' native AsFloat
```

`SetText("")` → `AsFloat = 0`. `OnApply`: `DecimalPlaces >= 0`, `DisplayFormat <> ""`.

`TIntegerEditor` sets `DecimalPlaces = 0` **after** `Apply`, so a props value cannot keep non-zero decimals on this class.

### `TNumberEditor` (`NumberTextBox`)

Calculator-style native. `AsDouble As Extended` is `CDbl(Text)` / `Text = CStr(pValue)`. `SetText` writes `Control.Value = CDbl(pValue)` (empty/non-numeric raises from `CDbl`).

### `TComboEditor` (`HComboBox`)

```bas
Property ListaOpcoes As String            ' e.g. "A=Ativo,I=Inativo"
Property ValueList As TStringList         ' Set copies .Text into native ValueList
Property ValueSelect As String
Property SelectedItem As Integer
Property ItemIndex As Integer
Property Items As TStrings
Property NameSelect As String             ' Get only: Items.Strings(SelectedItem) when in range; else ""
```

`Text` is `ValueSelect`. `OnApply` writes `ListaOpcoes` when non-empty.

### `TCheckEditor` (`CheckBox`)

Control `Align = alLeft`, `Width = 21` (not client-stretched).

```bas
Property Checked As Boolean               ' alias of AsBoolean
Property AsBoolean As Boolean             ' Control.Checked
Property AsInteger As Integer             ' CInt(AsBoolean) / CBool(pValue)
Sub Toggle()
```

`Text` Get: `"S"` / `"N"`. Set (case-insensitive trim): `TRUE`, `S`, `SIM`, `Y`, `YES`, `1` → True; anything else → False.

`Ajuda` / `OnDblClick` are not wired (`CheckBox` is not `TcxCustomTextEdit`).

### `TSearchEditor` (`SearchTextBox` + description `MemoTextBox`)

Composite: lookup `Align = alLeft`, width **58** after construct (CreateControl uses 90, constructor overwrites). Description is `ReadOnly`, `TabStop = False`, assigned to `Control.EditorDescricao`.

```bas
Property CodPesquisa As Integer
Property ExpressaoFiltro As String
Property Descricao As String              ' description Lines.Text
Property AsInteger As Integer
Property EditorDescricao As MemoTextBox   ' Get only
PesquisaIncremental As Boolean            ' stored only
TipoPesquisa As String                    ' stored only

Function Validate() As Boolean            ' calls Control.Valida(); return value is not assigned
```

`Text` is `Control.AsString`. Example: `CodPesquisa = Data7.PesquisaPadrao("ItemProdutoVendido", "CodProduto")`.

### Date and time

`TDateTimeEditor` (`DateTextBox`) keeps clock when present (`KeepTime = True`). `TDateEditor` overrides `KeepTime` to False (date only). `TTimeEditor` is a **mask** editor, not a `DateTextBox`.

```bas
Property AsDateTime As TDateTime
Property AsDate As TDateTime              ' date part; Unassigned if blank/time-only
Property AsTime As TDateTime              ' clock part; Unassigned if none. Set is no-op when KeepTime=False
```

Blank sentinels: `0`, `Unassigned`, native empty `EditValue`, mask placeholders containing `DD`/`YY`/`HH`/`NN`/`SS`, and OLE epoch `1899-12-30`.

`Text` / `AsString` format:

- blank → `""`
- time-only → `HH:MM:SS`
- date-only (`IsDate`) → `DD/MM/YYYY`
- date+time → `DD/MM/YYYY HH:MM:SS`

Parse order for `SetText` / `AsString`:

1. Trim; `T` → space; collapse spaces.
2. `""`, `"0"`, or mask placeholder → clear (`Unassigned`).
3. ISO `YYYY-MM-DD[ HH:MM[:SS[.mmm]]]`.
4. BR `DD/MM/YYYY` (also `-` when the first `-` is not at index 5, or `.`). Two-digit year: `< 50` → 2000+, else 1900+.
5. Clock-only `HH:MM[:SS[.mmm]]` (no `/`).
6. Compact digits: length 8 (`YYYYMMDD`), 14 (`YYYYMMDDHHMMSS`), 17 (+msec).
7. Else → clear.

Valid calendar: year 1900..9999. Invalid parts → clear, not an exception. Epoch date with non-zero clock stores time-only; epoch with zero clock clears.

`TDateEditor`: time-only input is discarded; `AsTime` Set is a no-op; stored value is date-only.

`TTimeEditor` (`TMaskEditor`):

| Member | Default |
|---|---|
| `Mascara` | `"99:99:99"` (forced again in `OnApply`, so props `Mask` cannot stick) |
| `MaxLength` | `8` |
| `TextHint` | `"HH:MM:SS (H = hora atual)"` |

```bas
Sub FillNow()                             ' DateTime().ToString("HH:mm:ss")
Property AsTime As TDateTime              ' invalid / not 6 digits → EncodeTime(0,0,0,0)
```

Keys `H` / `h` (ASCII 72 / 104) call `FillNow` and swallow the key.

`TEditorProps.ShowTime` / `TimeOnly` do not change these editors. Native `ShowTime` is not set (the assignment is commented out); `KeepTime` only changes value semantics.

## Image (`TImageEditor`)

`TLabeledEditor<Imagem>` with a footer of `CommandButton`s. Payload is **raw Base64** (no `data:` prefix). `Text` / `AsString` read/write that payload via `GetBoundText` / `SetBoundText` → `LoadFromBase64`.

Constructor sets `EditorHeight = 400` **after** `OnBuilt` (which sets 250) **after** `Apply`, so `TEditorProps.EditorHeight` does not stick; set `EditorHeight` after `New`.

Footer (left to right, width 90): `Capturar`, `Abrir`, `Salvar`, `Copiar`, `Colar`, `Limpar`. Image `Stretch` / `Proportional` / `Center` = True. Empty payload hides `Control`.

`OnlyRead` True disables Abrir/Capturar/Colar/Limpar. `Enabled` False disables all six. Salvar/Copiar stay enabled when the host is enabled even if readonly.

```bas
Property HasImage As Boolean              ' Trim(payload) <> ""

Sub Open()                                ' TDialogs.OpenFile; cancelled / readonly → no-op
Sub CaptureFromCamera()                   ' TCamera.Capture; empty → no-op
Sub Save()                                ' empty payload → no-op
Sub Copy()                                ' empty payload → no-op
Sub Paste()                               ' readonly or no clipboard image → no-op
Sub Clear()                               ' readonly → no-op; hides image; fires OnChange
Sub LoadFromFile(pPath As String)         ' empty path → clear payload and hide
Sub LoadFromBase64(pBase64 As String)
```

`Open` / `CaptureFromCamera` / `Paste` / `Clear` fire `OnChange` with sender `me`. `Save` / `Copy` / `LoadFrom*` do not.

`CaptureFromCamera`: if `TCamera.Capture()` returns an existing file path, load then `TFile.Delete`; otherwise treat the return as Base64.

Open/Save filter (literal):

```
Imagens (*.bmp; *.jpg; *.png; *.gif; *.ico; *.webp)|*.bmp;*.jpg;*.jpeg;*.png;*.gif;*.ico;*.webp|Bitmap (*.bmp)|*.bmp|JPEG (*.jpg; *.jpeg)|*.jpg;*.jpeg|PNG (*.png)|*.png|GIF (*.gif)|*.gif|Ícone (*.ico)|*.ico|WebP (*.webp)|*.webp|SVG (*.svg)|*.svg|Todos os arquivos (*.*)|*.*
```

Save default extension from Base64 magic prefix (fallback `*.png`):

| Prefix | Filter |
|---|---|
| `iVBORw0KGgo` | `*.png` |
| `/9j/` | `*.jpg` |
| `R0lGOD` | `*.gif` |
| `UklGR` | `*.webp` |
| `PHN2Zy` | `*.svg` |
| `AAABAA` | `*.ico` |
| `Qk` | `*.bmp` |

`TLabeledEditorBase.Clear` (`SetText("")`) does **not** clear the image payload. Call `TImageEditor.Clear`.

## Button chrome

### `ButtonedTextBox`

Composite used by `TButtonEditor`: `PageControl` container + `TextBox` + `Imagem` button (right, 20px). Not a `TLabeledEditor`.

```bas
Sub New(pOwner As TWinControl)

ReadOnly Container As PageControl
ReadOnly TextEditor As TextBox
ReadOnly ButtonEditor As Imagem

Property Updating As Boolean              ' Get only
Property InChange As Boolean              ' Get only
Property Align As TAlign
Property Text As String                   ' Set applies Mask
Property Mask As String
Property OnlyRead As Boolean
Property Enabled As Boolean
Property ButtonVisible As Boolean         ' False: editor right margin -1

Sub LoadFromFile(pPath As String)
Sub LoadFromBase64(pBase64 As String)

OnKeyPress As TKeyPressEvent              ' declared; chrome key path uses OnPreviewKeyPress
OnPreviewKeyPress As TKeyPressEvent
OnBeforeChange As TNotifyEvent
OnChange As TNotifyEvent
OnButtonClick As TNotifyEvent
```

Mask tokens: `9` = digit, `A` = A–Z, `C` = digit or A–Z. Other characters are literals, inserted only after at least one raw character. Empty mask → identity. Printable keys are swallowed when `SelLength = 0` and `Len(Text) >= Len(Mask)`.

Visual defaults: focused border `RGB(0, 120, 215)`, normal border `RGB(160, 160, 160)`, focused edit `RGB(255, 255, 215)`, readonly `RGB(229, 229, 229)`, disabled `RGB(240, 240, 240)`.

### `TButtonEditor`

`TLabeledEditor<TextBox>` whose `Control` is `Chrome.TextEditor`.

```bas
Property Button As Imagem                 ' Get only
Property Chrome As ButtonedTextBox        ' Get only
Property ImageBase64 As String            ' Get always ""; Set → LoadFromBase64
Property ImagePath As String              ' Get always ""; Set → LoadFromFile
Property ButtonHint As String
Property ButtonVisible As Boolean
Property Mascara As String                ' alias Mask; non-empty forces MaxLength 255
OnButtonClick As TNotifyEvent

Function OnlyDigits() As String           ' Trim, strip . - / space ( )
```

`Text` goes through chrome (mask applied). `Enabled` sets host and chrome. `OnApply` writes `Mask`.

Validate also runs on KeyDown `Tab` (9) and `Enter` (13). If `_rejectLeave` is True after `OnValidate`, the key is swallowed (`pKey = 0`). Exit-validate is skipped while `Chrome.Updating` or `Chrome.InChange`, and skipped once after a KeyDown validate (`_justValidated`).

Overridable: `OnEditorBeforeMask`, `OnEditorKeyPress`.

## Document editors

`TDocEditor` (`MustInherit`, `TButtonEditor`): `ButtonVisible = False`, `OnValidate` assigned to the internal checker in the constructor.

```bas
Protected Overridable Function AllowEmpty() As Boolean
' default: Not Required. If True and Trim(Text)="", validation is skipped

Protected MustOverride Function ValidateValue() As String
' "" = ok; non-empty = error message
```

On error: `MessageBox.Show(err)`, `_rejectLeave = True`, `SetFocus`. Re-entrancy (`_validateBusy`) and chrome Updating/InChange are ignored.

Assigning `OnValidate` after construction **replaces** this checker. Use subclass `ValidateValue` instead.

All concrete docs inherit `TDocEditor` unless noted. Validation uses `mod_validators` (`TDocs`, `TText`, `TEmail`, `TUrl`). Empty is allowed unless `Required = True`.

| Class | Mask / limits | Validator | Error string |
|---|---|---|---|
| `TCPFEditor` | `"999.999.999-99"`, MaxLength 14 | `TDocs.IsValidCPF` | `CPF inválido. Informe 11 dígitos com dígitos verificadores corretos.` |
| `TCNHEditor` | `"99999999999"`, 11 | `TDocs.IsValidCNH` | `CNH inválida. Informe 11 dígitos com dígitos verificadores corretos.` |
| `TRenavamEditor` | `"99999999999"`, 11 | `TDocs.IsValidRenavam` | `RENAVAM inválido. Informe 9 ou 11 dígitos com verificador módulo 11.` |
| `TSuframaEditor` | `"99999999-9"`, 10 | `TDocs.IsValidSuframa` | `Inscrição SUFRAMA inválida. Informe 9 dígitos com verificador módulo 11.` |
| `TGTINEditor` | `"99999999999999"`, 14, hint `8, 12, 13 ou 14 dígitos` | `TDocs.IsValidGTIN` | `GTIN inválido. Informe 8, 12, 13 ou 14 dígitos com verificador módulo 10.` |
| `TPlacaEditor` | `"AAA-CCCC"`, 8, upper, hint `ABC-1234 ou ABC-1D23` | `TDocs.IsValidPlaca` | `Placa inválida. Use o padrão antigo (ABC-1234) ou Mercosul (ABC1D23).` |
| `TEmailEditor` | MaxLength 1024, lower, hint `nome@dominio.com; outro@dominio.com`, font blue underline | `TEmail.IsValid` | `E-mail inválido. Informe um ou mais endereços separados por ; no formato nome@dominio.com.` |
| `TSiteEditor` | MaxLength 2048, lower, hint `https://www.exemplo.com.br`, font blue underline | `TUrl.IsValid` | `Site inválido. Informe um domínio válido, com ou sem http(s)://.` |
| `TIEEditor` | `"CCCCCCCCCCCCCC"`, 14, upper, hint `Informe a UF antes de validar` | `TDocs.IsValidIE(Text, UF)` | see below |

### `TIEEditor`

```bas
Property UF As String                     ' stored UCase(Trim)
```

Empty `UF` → `"Informe a UF para validar a Inscrição Estadual."` Invalid → `"Inscrição Estadual inválida para a UF " + UF + "."` Example: `.UF = "SP"`.

### `TCEPEditor`

Button visible; mask `"99.999-999"`; default glyph; hint `Buscar o endereço nos correios (Logradouro, Bairro, Município e UF)`. Button click calls `Consultar`. Assigning `OnButtonClick` replaces that.

```bas
Data As TCEPEditorData
OnLoadData As TNotifyEvent                ' after a successful fill; sender is the editor

Function Consultar() As Boolean           ' False if invalid CEP or HTTP error (MessageBox)
Shared Function LookupIbge(pCep As String) As String
' invalid / HTTP / missing ibge → ""
```

`TCEPEditorData` fields: `CEP`, `Logradouro`, `Complemento`, `Unidade`, `Bairro`, `Localidade`, `UF`, `Estado`, `Regiao`, `IBGE`, `DDD`, `Siafi`. Source: `GET https://viacep.com.br/ws/{digits}/json/` (TLS 1.2). Invalid CEP message: `CEP inválido, o CEP deve conter 8 dígitos.`

### `TCNPJEditor`

Button visible; mask `"CC.CCC.CCC/CCCC-99"`; MaxLength 18; `CharCase` upper; default glyph; hint `Consultar dados do CNPJ`.

```bas
Data As TCNPJData
OnLoadData As TNotifyEvent                ' after successful lookup; sender is the editor

Protected Function CheckDocument() As String
' "" or "CNPJ inválido. Informe 14 caracteres (numérico ou alfanumérico) com dígitos verificadores corretos."
```

`ValidateValue` delegates to `CheckDocument`. Button click: `TText.OnlyAlphaNum(Text)` must be a valid CNPJ or MessageBox + `SetFocus`. Lookup waterfall (first success wins):

1. Data7 CNPJ HTTP API
2. `https://brasilapi.com.br/api/cnpj/v1/{cnpj}`
3. `https://www.receitaws.com.br/v1/cnpj/{cnpj}` (JSON `status=ERROR` → that `message`)

All fail → MessageBox, `Data.Loaded = False`. Success → `Data.Loaded = True`, then `OnLoadData`. Assigning `OnButtonClick` replaces lookup; consume `OnLoadData`.

`TCNPJData`: `CNPJ`, `RazaoSocial`, `NomeFantasia`, `Logradouro`, `Numero`, `Complemento`, `CEP`, `Bairro`, `Municipio`, `UF`, `Email`, `Telefone`, `Situacao`, `DataAbertura`, `Tipo`, `Porte`, `NaturezaJuridica`, `DataSituacao`, `DataHoraInclusao`, `DataHoraUltimaAtualizacao`, `OrigemDados`, `Loaded`.

### `TCPFCnpjEditor` (`TCNPJEditor`)

Starts in CPF mode (`ButtonVisible = False`, mask `"999.999.999-99"`, MaxLength 14).

```bas
Property PersonType As String
' in: "F"/"FISICA", "J"/"JURIDICA"; other non-empty → first char; else ""
' stored only "F", "J", or ""
' "J" → CNPJ chrome; "F" → CPF chrome; "" → infer from value

Function DocumentError() As String        ' CheckDocument()
```

`SetBoundText` / keypress / before-mask retarget the mask. Auto CNPJ when a typed character is a letter, `Len(OnlyAlphaNum) >= 11`, raw length `> 11`, or digits length ≠ alphanum length.

`CheckDocument`: empty → `""`. Forced F/J uses CPF or CNPJ messages. Auto: `TDocs.IsValidCPFCnpj` or `CPF/CNPJ inválido. Use 11 dígitos (CPF) ou 14 caracteres (CNPJ, inclusive alfanumérico) com verificadores corretos.`

## Extending (Consumer Project)

Construct a native-backed editor:

```bas
Class TMyTextEditor
   Inherits TLabeledEditor<TextBox>

   Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
      MyBase.New(pParent, pCaption, pProps)
   End Sub

   Protected Overrides Sub OnBuilt()
      ' after CreateControl and event bind; before Apply
   End Sub

   Protected Overrides Sub OnApply(pProps As TEditorProps)
      ' extra TEditorProps fields
   End Sub
End Class
```

Composite (own `CreateControl`, assign `me._control`): follow `TSearchEditor` / `TButtonEditor` / `TImageEditor`.

Document field:

```bas
Class TMyDocEditor
   Inherits TDocEditor

   Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
      MyBase.New(pParent, pCaption, pProps)
      me.Mascara = "999999"
   End Sub

   Protected Overrides Function AllowEmpty() As Boolean
      AllowEmpty = True
   End Function

   Protected Overrides Function ValidateValue() As String
      ' return "" or a MessageBox string
   End Function
End Class
```

Date-only vs date-time: inherit `TDateTimeEditor` and override `KeepTime` (`True` keep clock, `False` strip / reject time-only).

CNPJ lookup extras: override `CheckDocument`. Do not replace `OnValidate` / `OnButtonClick` if you still want the built-in wiring.

There is nothing to register. Import your namespace and `New` the class on a `TWinControl`.

## Module Notes

- Editors do not own the parent. Host `Align = alTop`; create them in visual order. `Free` on `TFontFace` unbinds; `TButtonEditor.Free` frees `Chrome`; `TImageEditor.Free` frees an internal `Clipboard` only if `Assigned` (it is never assigned in this module).
- `Text` and `AsString` are the same pipeline except `TImageEditor`, where they are the Base64 payload, not native `Imagem` text.
- `TDocEditor` and `TCNPJEditor` / `TCEPEditor` steal `OnValidate` / `OnButtonClick` in `New`. Replacing those properties drops built-in validation or lookup. Use `ValidateValue`, `OnLoadData`, and `_rejectLeave`.
- `TIntegerEditor` forces `DecimalPlaces = 0` after `Apply`. `TImageEditor` forces `EditorHeight = 400` after `Apply`. `TTimeEditor` forces mask `"99:99:99"` in `OnApply`. `TSearchEditor` forces lookup width 58 after `CreateControl`.
- `TMemoEditor` lives in `mod_editors_memo`. Import that namespace so the name does not bind to the native `MemoTextBox` alias.
- `TCheckEditor.Text` is the `"S"` / `"N"` contract. `TComboEditor.Text` is `ValueSelect` (the key in `A=Ativo,I=Inativo`), not the caption; `NameSelect` is the caption.
- `TSearchEditor.PesquisaIncremental` and `TipoPesquisa` are public fields filled from `TEditorProps` and never copied onto `Control` here. `TEditorProps.ShowTime` / `TimeOnly` / `EditorAlignment` are unused or storage-only.
- `src/Principal.bas` is a visual demo (`Demo1()` then `_form.Show()`). There is no `TXxxTests.RunAll` in this project.
