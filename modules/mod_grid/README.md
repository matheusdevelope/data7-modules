# mod_grid

`mod_grid` is a typed wrapper over the native `Forms.Grid`. The source of truth is `TGridData` (`TTMatrix<TGridCol, TGridRow, Variant>`). The native grid is a virtual viewport: display text and colors come from `OnGetDisplText` / `OnGetCellColor`, not from filling every `Cells()` slot yourself.

This module does **not** own the parent form, persistence, queries, or business rules. The consumer creates the `TWinControl` parent, builds columns/rows, calls `Prepare()`, and reacts through `Events` / validators / side effects.

Version: **1.0.0.2** (`data7.json`). Dependencies: `mod_logger` 1.0.0.0, `mod_tenum` 1.0.0.0, `mod_tobject` 1.0.0.0, `mod_tlist` 1.0.0.0, `mod_matrix` 1.0.0.3.

This file is the module contract. Use the API from here. Do not open `.bas` files to consume the module. Open implementation only to confirm a detail that is not stated below.

## Quick Start (Minimal)

```bas
Imports Forms
Imports mod_grid_view
Imports mod_grid_col
Imports mod_grid_row

Dim _form As New Form()
' parent is any TWinControl; Grid is created Align=alClient inside it
Dim _grid As New TGridView(_form)

' optional system columns (IDs "_selection" and "_item")
_grid.Options.Selection.Enabled = True
_grid.Options.Item.Enabled = True
_grid.Options.Item.Size = 3

' Search column: matrix stores the key; DescriptionColumnId is filled on inplace edit
Dim _col As TGridCol = TGridCol.AsSearch("Código", "codigo")
_col.Options.Search.CodPesquisa = Data7.PesquisaPadrao("ProdutoVendido", "CodCondicaoPagamento")
_col.Options.Search.DescriptionColumnId = "descricao"
_grid.AddColumn(_col)

' Checkbox default "S" only applied when the cell is empty on insert
_grid.AddColumn(TGridCol.AsCheckbox("Ativo", "Ativo").SetDefault("S"))

' Image: matrix stores the key; never opens an inplace editor (values are base64)
_grid.AddColumn(TGridCol.AsImage("Status", "status").AddImage("S", "iVBORw0KGgo=").AddImage("N", "iVBORw0KGgo="))

' description column for the Search lookup
_grid.AddColumn(TGridCol.AsReadOnly("Descrição", "descricao").SetWidth(220))

Dim _row As TGridRow = _grid.AddRow()
_grid.SetValue(_row.Index, "codigo", "001")
_row.Selected = True

_grid.Prepare()
_form.Show()
```

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_grid/mod_grid.bas` | `mod_grid` | *(empty marker namespace)* |
| `src/mod_grid/core/mod_grid_view.bas` | `mod_grid_view` | `TGridView` |
| `src/mod_grid/core/mod_grid_options.bas` | `mod_grid_options` | `TTGridOptions`, `TGridSelectionOptions`, `TGridItemOptions`, `TGridLayoutOptions`, `TGridInteractionOptions`, `TGridColorOptions`, `TGridHeaderColorOptions`, `TGridFixedColorOptions` |
| `src/mod_grid/core/mod_grid_config.bas` | `mod_grid_config` | `TGridConfig`, `TGridOptionsConfig` and nested `*Config` classes, `TGridBeforeInsertNewRowDel` |
| `src/mod_grid/core/mod_grid_context.bas` | `mod_grid_context` | `TGridContext` |
| `src/mod_grid/core/mod_grid_presenter.bas` | `mod_grid_presenter` | `TGridPresenter` |
| `src/mod_grid/adapters/mod_grid_native_adapter.bas` | `mod_grid_native_adapter` | `TNativeGridAdapter` |
| `src/mod_grid/data/mod_grid_col.bas` | `mod_grid_col` | `TGridCol`, `TGridColOptions` and nested option classes, combo/image items, column delegates |
| `src/mod_grid/data/mod_grid_row.bas` | `mod_grid_row` | `TGridRow`, `TGridRowOptions`, `TGridRowColorOptions`, `TGridRowStateChangedDel` |
| `src/mod_grid/data/mod_grid_data.bas` | `mod_grid_data` | `TGridData`, `TGridRowStateDel`, `TGridSortRowDel` |
| `src/mod_grid/columns/mod_grid_column_kind.bas` | `mod_grid_column_kind` | `TGridColumnKind` |
| `src/mod_grid/columns/mod_grid_column_checkbox.bas` | `mod_grid_column_checkbox` | `TGridCheckboxSupport` |
| `src/mod_grid/events/mod_grid_event_hub.bas` | `mod_grid_event_hub` | `TGridEventHub`, `TGridAllowIndexEvent`, `TGridSetEditTextEvent` |
| `src/mod_grid/validation/mod_grid_validator.bas` | `mod_grid_validator` | `TGridCellValidator`, `TGridValidatorChain` |
| `src/mod_grid/validation/mod_grid_validators_builtin.bas` | `mod_grid_validators_builtin` | `TGridValidators` |
| `src/mod_grid/effects/mod_grid_side_effect.bas` | `mod_grid_side_effect` | `TGridSideEffect`, `TGridSideEffectChain` |
| `src/mod_grid/effects/mod_grid_effects_builtin.bas` | `mod_grid_effects_builtin` | `TGridEffects` |
| `src/mod_grid/editors/mod_grid_editor_contract.bas` | `mod_grid_editor_contract` | `TGridCellDrawer`, `TGridEditorHandle`, `TGridEditorFactory` |
| `src/mod_grid/editors/mod_grid_editor_registry.bas` | `mod_grid_editor_registry` | `TGridEditorRegistry` |
| `src/mod_grid/editors/mod_grid_editor_pool.bas` | `mod_grid_editor_pool` | `TGridEditorPool` |
| `src/mod_grid/editors/factories/mod_editor_text.bas` | `mod_grid_editor_text` | `TTextEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_date.bas` | `mod_grid_editor_date` | `TDateEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_value.bas` | `mod_grid_editor_value` | `TValueEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_number.bas` | `mod_grid_editor_number` | `TNumberEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_mask.bas` | `mod_grid_editor_mask` | `TMaskEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_search.bas` | `mod_grid_editor_search` | `TSearchEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_combo.bas` | `mod_grid_editor_combo` | `TComboEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_image.bas` | `mod_grid_editor_image` | `TImageEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_checkbox.bas` | `mod_grid_editor_checkbox` | `TCheckboxEditorFactory` |
| `src/mod_grid/editors/factories/mod_editor_readonly.bas` | `mod_grid_editor_readonly` | `TReadOnlyEditorFactory` |
| `src/mod_grid/editors/drawers/mod_drawer_checkbox.bas` | `mod_grid_drawer_checkbox` | `TCheckboxDrawer`, `TDefaultCheckboxDrawer` |
| `src/mod_grid/popup/mod_grid_popup.bas` | `mod_grid_popup` | `TGridPopup`, `TGridPopupItem`, `TGridPopupSeparator`, `TGridPopupActionDel` |
| `src/mod_grid/popup/mod_grid_popup_checkbox.bas` | `mod_grid_popup_checkbox` | `TGridCheckboxPopup` |
| `src/mod_grid/utils/mod_tmasktextbox.bas` | `mod_tmasktextbox` | `TMaskTextBox`, `TMaskTextBoxPosition` *(Mask inplace editor)* |
| `src/mod_grid_stress.bas` | `mod_grid_stress` | `TGridStressRun` |
| `src/Principal.bas` | *(script)* | stress entry |

## Lifecycle

1. Construct `TGridView(pParent)` or `TGridView(pParent, pConfig)`.
2. Set `_grid.Options.*` and add columns (`AddColumn`) / rows (`AddRow` or `Data.PushRow`).
3. Call `Prepare()`:
   1. `EnsureSystemColumns()` — create/remove `_selection` / `_item` to match `Options.Selection.Enabled` / `Options.Item.Enabled`.
   2. If `Data.RowCount = 0` and grid `Interaction.OnlyRead` is False, insert one empty row (native Grid always shows header + one slot).
   3. `Presenter.Prepare()` — first call `Mount()`s the native `Grid`; then `SyncStructure()`.
   4. `Events.Wire()` — native events go to the hub; consumer delegates run last.
4. After `Prepare()`, option setters that matter visually call `SyncIfPrepared` / `ApplyOptions` / `InvalidateIfPrepared`. `TGridView.Refresh()` is `Prepare()` again, not a paint-only refresh.

Native `Mount()` always sets `Align = alClient`, `AlignWithMargins = True`, `ColMoving/RowMoving/ColSizing/RowSizing = False`, `FixedColClick/FixedRowClick = True`, `VirtualEdit = False`, `EnableHTML = True`. There is no `Options` wrapper for FixedCols / ColMoving.

## View

`TGridView` is the consumer entry point. It owns `TGridContext` (data, adapter, presenter, event hub, editor pool).

```bas
Sub New(pParent As TWinControl)
Sub New(pParent As TWinControl, pConfig As TGridConfig)

Property Native As Grid                 ' native Forms.Grid
Property Context As TGridContext
Property Config As TGridConfig
Property Data As TGridData
Property Options As TTGridOptions       ' live facade over Config.Options
Property Events As TGridEventHub

Function AddColumn(pCol As TGridCol) As TGridCol
' in: column definition. If Kind=Search, DescriptionColumnId <> "" and SideEffectCount=0,
'     attaches TGridEffects.SearchDescription. Resolves Factory, PushColumn, ReorderSystemColumns.
' out: same pCol (or Null if pCol was Null)

Function AddRow() As TGridRow           ' auto ID "r1", "r2", ...
Function AddRow(pID As String) As TGridRow
' empty pID falls back to auto ID. New row IsNew=True. Defaults applied unless Data.FastFill.

Sub SetValue(pRowIndex As Integer, pColID As String, pValue As Variant)
' writes Data.SetCell. If Search.ApplyDescriptionOnSet, also runs lookup and pokes the description cell.
Sub SetValue(pRowID As String, pColID As String, pValue As Variant)
' Data.SetCell only — does not run ApplyDescriptionOnSet.

Function GetValue(pRowIndex As Integer, pColID As String) As Variant
Function GetValue(pRowID As String, pColID As String) As Variant
' missing cell → Empty

Sub Prepare()
Sub Refresh()                           ' = Prepare()
```

`AddColumn` / `AddRow` with Null column/row: no-op, return Null.

## Grid options (`_grid.Options`)

Live facade. Writes go to `TGridConfig.Options` and, when already prepared, sync the native grid.

`TTGridOptions.DefaultColumnIndex()` = `-1`. `TTGridOptions.LastColumnIndex()` = `-2`.

### `Selection`

| Member | Default | Notes |
|---|---|---|
| `Enabled` | False | True creates `TGridCol.AsSelection()` (`ID="_selection"`). False deletes it. |
| `Index` | -1 | -1 = fallback 0; -2 = last visible data column. |
| `Column` | Null | Read-only handle of the system selection column. |

### `Item`

| Member | Default | Notes |
|---|---|---|
| `Enabled` | False | True creates `TGridCol.AsItemNumber()` (`ID="_item"`, caption `"Item"`). |
| `Index` | -1 | Fallback 0, or 1 if selection column exists. -2 = last. |
| `Size` | 1 | Pad width for item numbers (`3` → `001`). Values `< 1` are forced to `1`. Grows with `RowCount` if larger. |
| `AutoUpdate` | True | True: item numbers follow current order after move/sort/insert/delete. False: keep original `ItemNumber`; header click on Item sorts. Switching True→False calls `RenumberItems()`. |
| `Column` | Null | Read-only handle of the item column. |

### `Layout`

| Member | Default | Notes |
|---|---|---|
| `AutoSize` | False | Applied after Prepare. |
| `StretchLastColumn` | False | If True with AutoSize, AutoSize is turned off so the last visible column can stretch. |

### `Interaction`

| Member | Default | Notes |
|---|---|---|
| `OnlyRead` | False | Native `RowSelect`. Blocks inplace editors, AddRowOnDown, and SetEditText persist. DblClick toggles selection if `Selection.Enabled`. Space toggles selection column. `Prepare` does **not** insert a starter row. |
| `AllowMarkForDelete` | False | Native `PermiteMarcarExclusao`. |
| `AddRowOnDown` | False | Down arrow on the last data row inserts a new row (see insert flow). |
| `OnBeforeInsertNewRow` | Null | `TGridBeforeInsertNewRowDel(pRow, ByRef pCanInsert, ByRef pMessage)`. |

Insert on Down (last row only, grid not OnlyRead):

1. Required columns (`Interaction.Required`) on the current row must be non-empty (`Trim(CStr(cell)) <> ""`).
2. `OnBeforeInsertNewRow` may set `pCanInsert` / `pMessage`.
3. Empty required cells always veto, even if the handler allows. Default message: `"Antes de inserir uma nova linha, informe os dados obrigatórios na linha atual."`
4. Veto shows `MessageBox.Show(pMessage)` when message is non-blank.
5. Success: `PushRow`, focus first non-hidden editable cell.

### `Color`

Sentinel `-1` = inherit native. Header required default is `RGB(0, 0, 255)` (not -1).

| Path | Default |
|---|---|
| `Color.Text` / `Color.Back` | -1 |
| `Color.Header.Text` / `Back` / `RequiredBack` | -1 |
| `Color.Header.Required` | `RGB(0, 0, 255)` |
| `Color.Fixed.Back` | -1 |

Paint resolution (first match wins):

- Data font: row `Color.Text` → col `Color.Text` → grid `Color.Text` → -1.
- Data back: row `Color.Back` → col `Color.Back` → grid `Color.Fixed.Back` (native col `< FixedCols`) → grid `Color.Back` → -1.
- Header font: col header text → required header color if col Required → grid header text → grid text → -1.
- Header back: col header back → required header back if col Required → grid header back → grid fixed back → grid back → -1.

Row `Color.Text` still wins over `Font.Color` when `<> -1`. Changing row color notifies state; `InvalidateDisplay()` on the adapter is currently a **no-op**, so other cells of the row may keep the previous paint until they are poked or the native control is refreshed by the consumer.

## Config

Use `TGridConfig` when you need global validators, side effects, or a custom editor registry before constructing the view.

```bas
Sub New()
' Options = TGridOptionsConfig.Defaultt()
' GlobalValidators / GlobalSideEffects empty chains
' EditorRegistry with RegisterDefaults()

' fields
Options As TGridOptionsConfig
GlobalValidators As TGridValidatorChain
GlobalSideEffects As TGridSideEffectChain
EditorRegistry As TGridEditorRegistry
```

`TGridView.New(pParent)` constructs `New TGridConfig()` internally.

## Columns

### Kind

```bas
Enun TGridColumnKind
   Text, Date, Value, Number, Mask, Search, OnlyRead, Checkbox, Combo, Image
End Enun
```

Call as `TGridColumnKind.Text()`, etc.

| Factory | Kind | Inplace | Native control | Extra defaults |
|---|---|---|---|---|
| `AsText` | Text | TextBox | yes | Width 80 |
| `AsDate` | Date | DateTextBox | yes | |
| `AsValue` | Value | ValueTextBox | yes | `Sort.Numeric = True` |
| `AsNumber` | Number | ValueTextBox integers | yes | `Sort.Numeric = True` |
| `AsMask` | Mask | `TMaskTextBox` | yes | uses `Format.Mask` |
| `AsSearch` | Search | SearchTextBox | yes | pool key includes `CodPesquisa` |
| `AsReadOnly` | OnlyRead | TextBox | yes, only if `AllowCopy` | `OnlyRead = True` |
| `AsCheckbox` | Checkbox | none (drawer) | no | Width 30 |
| `AsCombo` | Combo | HComboBox | yes | pool key includes col ID |
| `AsImage` | Image | none | no | `OnlyRead = True`, Width 36 |
| `AsSelection` | Checkbox | none | no | ID `"_selection"`, `IsSelection`, `CanMove=False` |
| `AsItemNumber` | OnlyRead | none unless AllowCopy | | ID `"_item"`, `IsRowNumber`, Width 50, Numeric sort, `CanMove=False` |

### `TGridCol`

```bas
Sub New(pCaption As String, pId As String, pKind As TGridColumnKind)
' TTMatrixCol ID = pId. Caption/Kind/Options set. Image also OnlyRead.

Caption As String
Kind As TGridColumnKind
Options As TGridColOptions
Factory As TGridEditorFactory          ' resolved on AddColumn / Acquire

Function SetWidth(pWidth As Integer) As TGridCol
Function SetDefault(pValue As Variant) As TGridCol
Function SetOnGetDefault(pHandler As TGridDefaultValueDel) As TGridCol
Function SetAlignment(pValue As TAlignment) As TGridCol
Function SetNumericSort() As TGridCol
Function SetAllowCopy() As TGridCol
Function SetAllowCopy(pValue As Boolean) As TGridCol
Function AddComboOption(pKey As String, pValue As String) As TGridCol
Function AddImage(pKey As String, pBase64 As String) As TGridCol
Function AsRowNumber() As TGridCol     ' flags current col as item number
Function HasDefault() As Boolean       ' OnGetDefault <> Null or DefaultValue not Empty
Function ResolveDefault(pRow As TGridRow) As Variant
' 1) OnGetDefault(pRow, col) if assigned
' 2) if Empty, DefaultValue
Property Font As TFont                 ' getter creates TFont
Function HasFont() As Boolean          ' True only if Font was accessed or assigned
Property Alignment As TAlignment
Function HasAlignment() As Boolean
Shared Sub ApplyFont(pTarget As TFont, pSource As TFont)
Sub SetDrawer(pDrawer As TGridCellDrawer)
Sub AddValidator(ByRef pValidator As TGridCellValidator)   ' Null ignored
Sub AddSideEffect(ByRef pEffect As TGridSideEffect)        ' Null ignored
Sub SetRequired()                      ' Required=True + TGridValidators.Required
Sub SetCascadeClear(pColumnId As String)
Function IsEditable(pRow As TGridRow) As Boolean
Function CanOpenEditor(pRow As TGridRow) As Boolean
Function Validate(pRow As Integer, pCol As Integer, pValue As String, ByRef pMessage As String) As Boolean
Sub ApplySideEffects(pData As TObject, pRow As TGridRow, ByRef pValue As Variant, ByRef pValid As Boolean, pNative As Grid)
Function ValidatorCount() As Integer
Function SideEffectCount() As Integer
Function SortKey(pValue As Variant) As String
```

`IsEditable` is False when: Kind Image, Kind Checkbox, Kind OnlyRead, `IsRowNumber`, `Interaction.OnlyRead`, `pRow` assigned and `pRow.Editable = False`, or `CanEdit` returns False (`CanEdit` with Null row → False). Otherwise True.

`CanOpenEditor` is False for Image and Checkbox. Else True if `IsEditable`, else `AllowCopy`.

Defaults apply on insert only if the cell is Empty or `Trim(CStr(raw)) = ""`. Numeric `0` is a real default (`IsEmpty(0) = False`). Item-number columns skip defaults.

### Column options (`col.Options`)

**Layout:** `Width = 80`, `Hidden = False`. Hidden columns are `HideColumn` after ColCount sync (iterate last→first).

**Interaction**

| Field | Default | Behavior |
|---|---|---|
| `OnlyRead` | False | No inplace editor (`IsEditable` False). `SetCell` / `SetValue` still write. |
| `AllowCopy` | False | If not editable, still open inplace with `ReadOnly=True`. Persist is skipped (`IsEditable` gate). Image/Checkbox ignore. Grid `OnlyRead` still blocks all editors. |
| `Required` | False | Header uses required colors; AddRowOnDown checks non-empty. `SetRequired()` also adds the Required validator. |
| `CanMove` | True | Native `OnColumnMove` `pAllow`. Selection/Item start False. |
| `CanResize` | True | Native `OnColumnSize` `pAllow`. |
| `CanEdit` | Null | Extra `IsEditable` predicate. |

**Color:** `Text/Back/Header.Text/Header.Back` all `-1`.

**Search:** `CodPesquisa = 0`, `DescriptionColumnId = ""`, `ApplyDescriptionOnSet = False`. Inplace edit always runs `SearchDescription` when DescriptionColumnId is set (via `AddColumn` auto side effect). `Data.SetCell` never runs it. `TGridView.SetValue(index, …)` runs it only if `ApplyDescriptionOnSet`.

**Combo**

```bas
Function Add(pKey As String, pValue As String) As TGridColComboOptions
Function SetLista(pLista As String) As TGridColComboOptions
Function AsListaOpcoes() As String          ' description=key, quoted if space
Function LookupValue(pKey As String) As String   ' "" if missing
Function LookupKey(pValue As String) As String   ' first case-insensitive Value match, else ""
ShowDescription As Boolean = True           ' True: cell shows description; False: shows key
```

`ListaOpcoes` literal (description=key, `;` separators, quotes when a token has space):

```
"Item A=A";Item_B=B;"Item C=C"
```

`SetLista` parses that string. Pair without `=` uses the token as both key and value. Matrix always stores the **key**. Edit opens `HComboBox` on the key; commit writes the key.

**Image:** `Add(pKey, pBase64)` materializes once under `C:\Windows\Temp\mod_grid_img` via `Base64ToFile`. Display HTML: `<img src="file://path">`. Empty/unknown key → empty cell. Extension from payload: `/9j/` → `.jpg`, `R0lGOD` → `.gif`, else `.png`. Data-URL prefix `data:...,` is stripped. Same key replaces base64 and rematerializes.

**Format:** `Mask = ""`, `Decimals = 2`. Value Kind: Mask is `ValueTextBox.DisplayFormat` and `Double.ToString(Mask)` for display. Without Mask, display is `CStr`. Number Kind ignores this Mask (integer). Mask Kind uses `Format.Mask` on `TMaskTextBox.Mascara`.

**Checkbox:** `CheckedValue = "S"`, `UncheckedValue = "N"`, `ToggleOnDblClick = True`, `ActivationKeys = " "` (space). Optional `ToggleValidate`, `CanToggle`. Compare is `UCase(Trim(...))`.

**System:** `IsRowNumber = False`, `IsSelection = False`.

**Effects:** `CascadeClearColumnId = ""`. `SetCascadeClear` also registers `TGridEffects.CascadeClear` (clears target cell when this value becomes empty).

**Sort:** `Numeric = False` (Number/Value constructors set True), `CanSort = True`. There is no `SetCanSort` method — assign `Options.Sort.CanSort`. Selection columns never sort. Item column with `Item.AutoUpdate` also cannot sort. `SortKey`: Empty → `""`; non-numeric → `CStr`; numeric pads 18 integer + 6 fraction digits, negatives via nine's complement (`"0"…` vs `"1"…`).

**DefaultValue** (`Variant`, Empty = none) and **OnGetDefault** (`TGridDefaultValueDel`).

**Drawer** (`TGridCellDrawer`): if Null, factory drawer is used (checkbox has `TDefaultCheckboxDrawer`).

Delegates:

```bas
Delegate Function TGridCanEditDel(pRow As TGridRow, pCol As TGridCol) As Boolean
Delegate Function TGridDefaultValueDel(pRow As TGridRow, pCol As TGridCol) As Variant
Delegate Function TGridCheckboxToggleValidateDel(pRow As TGridRow, pCol As TGridCol, pCurrentValue As String, pNewValue As String, ByRef pMessage As String) As Boolean
Delegate Function TGridCheckboxCanToggleDel(pRow As TGridRow, pCol As TGridCol) As Boolean
```

## Rows

`TGridRow` is a matrix row plus grid state.

| Member | Default | Notes |
|---|---|---|
| `Selected` | False | Setting it notifies state. Selection column `SetCell` maps CheckedValue → True. |
| `Deleted` | False | No notify. |
| `IsNew` | False | `PushRow` sets True. |
| `Dirty` | False | Set True on successful inplace commit / checkbox apply. |
| `Editable` | True | False blocks cells, checkbox toggle, selection toggle, checkbox popup apply, mark-for-delete. `SetCell` still writes. Notifies state. |
| `CanMove` | True | Native `OnRowMove`. |
| `CanResize` | True | Native `OnRowSize`. |
| `ItemNumber` | 0 | `< 1` on insert → next sequence. |
| `Font` | created on get | `HasFont`. Wins over column font. |
| `Options.Color.Text/Back` | -1 | Wins over column colors. Setter notifies state. |
| `Tag` | Null | Consumer payload. |
| `OnStateChanged` | wired by `TGridData` | Do not replace if you need presenter invalidate. |
| `NotifyState()` | | Fires `OnStateChanged` if assigned. |

Auto IDs: `"r"` + sequence (`r1`, `r2`, …).

## Data

`TGridData` is the matrix. Prefer `TGridView.SetValue` / `GetValue` unless you need indexes or `FastFill`.

```bas
ItemNumberSize As Integer = 1
FastFill As Boolean = False             ' True: PushRow skips column defaults (bulk load)
EditorRegistry As TGridEditorRegistry
OnRowStateChanged As TGridRowStateDel

Function ColAt(pIndex As Integer) As TGridCol          ' out of range → Null
Function ColAt(pColID As String) As TGridCol
Function RowAt(pIndex As Integer) As TGridRow
Function RowAt(pRowID As String) As TGridRow
Function GetColIndex(pColID As String) As Integer      ' missing → -1
Function HasCol(pColID As String) As Boolean

Sub MoveCol(pColID As String, pToIndex As Integer)
Sub DeleteCol(pColID As String)                        ' DeleteColFromID
Sub DeleteCol(pIndex As Integer)
Sub DeleteRow(pRowID As String)
Sub DeleteRow(pIndex As Integer)

Function PushColumn(pCol As TGridCol) As TGridCol      ' Null in → Null out
Function PushRow() As TGridRow
Function PushRow(pID As String) As TGridRow
Function PushRow(pRow As TGridRow) As TGridRow

Sub RenumberItems()                                    ' ItemNumber = index+1

Sub SetCell(pRowIndex, pColIndex, pValue)
Sub SetCell(pRowIndex, pColID, pValue)                 ' unknown col → no-op
Sub SetCell(pRowID, pColID, pValue)

Function GetCell(...) As Variant                       ' OOB → Empty
Function CellRaw(pRowIndex, pColIndex | pCol) As Variant
Function CellText(pRowIndex, pColIndex | pColID) As String
' display text via factory.FormatValue (Combo description, Image HTML, else CStr)

Sub SortGridRows(pHandler As TGridSortRowDel, pAsc As Boolean, pExtra As Variant)
```

`SetCell` on a selection column does not store the variant; it sets `row.Selected`. `SetCell` on a row-number column is a no-op.

`CellRaw` for selection returns Checked/Unchecked from `row.Selected`. For row-number it returns the padded `ItemNumber` (or index+1).

`ColCount` / `RowCount` / `Index` / `ID` come from `TTMatrix` / row-col bases (`mod_matrix`).

## Events

`_grid.Events` is `TGridEventHub`. Hub handlers run first; consumer fields run last and may overwrite `ByRef` results (`pCanEdit`, `pValue`, `pValid`, `pAllow`, `pHandled`, `pFont`, `pBrush`).

```bas
Delegate Sub TGridAllowIndexEvent(pSender As TObject, pIndex As Integer, ByRef pAllow As Boolean)
Delegate Sub TGridSetEditTextEvent(pSender As TObject, pCol As Integer, pRow As Integer, ByRef pValue As String)

OnCanEditCell As TCanEditCellEvent
OnGetInplaceEditor As TGridGetInplaceEditorEvent
OnGetDisplText As TGetDisplTextEvent
OnGetEditText As TGetEditEvent
OnSetEditText As TGridSetEditTextEvent
OnCellValidate As TCellValidateEvent
OnGetCellColor As TGridColorEvent
OnDrawCell As TDrawCellEvent
OnDblClickCell As TDblClickCellEvent
OnKeyPress As TKeyPressEvent
OnKeyDown As TKeyEvent
OnRowMoved / OnColumnMoved As TMovedEvent
OnRowMove / OnColumnMove / OnRowSize / OnColumnSize As TGridAllowIndexEvent
OnClickSort As TClickSortEvent
OnCanSort As TCanSortEvent
OnMarcaDesmarcaLinhaParaExclusao As TMarcaDesmarcaLinhaParaExclusaoEvent
OnResize As TNotifyEvent
OnContextPopup As TContextPopupEvent

Sub Wire()   ' called by Prepare
```

Event coordinates are **native** (`pRow` includes fixed header rows). Data index = `Presenter.ToDataIndex(pNativeRow)` (`-1` if header or OOB).

Hub behavior:

- `OnCanEditCell` / inplace: `CanOpenEditor`, not `IsEditable`. Grid OnlyRead or header → no editor.
- Commit (`OnSetEditText`): skipped while poking, syncing, committing, grid OnlyRead, or `Not col.IsEditable(row)`. Sets `Dirty`, runs column then global side effects, `PokeDataCell`.
- `OnCellValidate`: same `IsEditable` gate; Search `Valida()` is not called in copy-only mode.
- Checkbox: dblclick toggles if `ToggleOnDblClick`; space (or `ActivationKeys`) toggles then moves one row down if a next data row exists.
- Grid OnlyRead + selection: dblclick or space toggles `Selected`.
- Header click sort: `CanSort` and not selection; Item+AutoUpdate blocked. Then `SortGridRows` by `SortKey`.
- `OnColumnMove` / `OnRowMove` / size: `pAllow` from `CanMove` / `CanResize`.
- `OnResize`: `ApplyColumnLayoutOnResize` (stretch last column).
- ContextPopup on checkbox: `TGridCheckboxPopup` (see Popup). Other columns: `pHandled = False` (native menu).
- Mark-for-delete: blocked when `row.Editable = False`.

## Validation and side effects

```bas
Delegate Function TGridCellValidator(pRow As Integer, pCol As Integer, pValue As String, ByRef pMessage As String) As Boolean
' return False to reject; set pMessage

TGridValidatorChain.Add(ByRef pValidator)
TGridValidatorChain.Validate(...) As Boolean   ' stops at first False

Shared Function TGridValidators.Required(...) As Boolean
' Trim(pValue)="" → False, pMessage="Campo obrigatório."
Shared Function TGridValidators.Custom(pHandler As TGridCellValidator) As TGridCellValidator
' returns the same handler

Delegate Sub TGridSideEffect(pData As TObject, pRow As TGridRow, pCol As TGridCol, ByRef pValue As Variant, ByRef pValid As Boolean, pNative As Grid)

TGridSideEffectChain.Add / Apply

Shared Sub TGridEffects.SearchDescription(...)     ' inplace SearchTextBox → key + description col
Shared Sub TGridEffects.ApplySearchDescriptionFromControl(...)
Shared Sub TGridEffects.ApplySearchDescription(...)
Shared Sub TGridEffects.CascadeClear(...)          ' empty value → SetCell(CascadeClearColumnId, "")
```

Column validators run before `Config.GlobalValidators`. Column side effects run before `Config.GlobalSideEffects`. `pData` is the `TGridData` instance.

Invalid search lookup: clears key and description, `pValid` True if the search control is empty.

## Editors

Registry maps Kind → factory. `Registerr` (that spelling) replaces an existing Kind.

| Kind | Factory | `UsesInplaceEditor` | `FormatValue` override |
|---|---|---|---|
| Text | `TTextEditorFactory` | True | CStr |
| Date | `TDateEditorFactory` | True | CStr |
| Value | `TValueEditorFactory` | True | Mask / `Double.ToString` |
| Number | `TNumberEditorFactory` | True | CStr of integer |
| Mask | `TMaskEditorFactory` | True | CStr |
| Search | `TSearchEditorFactory` | True | CStr |
| Combo | `TComboEditorFactory` | True | description if `ShowDescription` |
| Image | `TImageEditorFactory` | False | HTML img |
| Checkbox | `TCheckboxEditorFactory` | False | drawer |
| OnlyRead | `TReadOnlyEditorFactory` | True (TextBox) | CStr |

`TGridEditorFactory` overridable hooks (no bodies required of consumers except the ones you replace):

| Hook | Purpose |
|---|---|
| `Kind()` | registry id; default throws |
| `UsesInplaceEditor()` | default True |
| `Build` | create hidden control; default throws |
| `Configure` | re-apply col options on pool reuse |
| `ApplyReadOnly` | set `ReadOnly` on TextBox / SearchTextBox / HComboBox / ValueTextBox / DateTextBox |
| `Validate` | default True; Search calls `Valida`/`IsValid` |
| `GetValue` / `ApplyValue` | string round-trip |
| `PoolKey` | default `Kind.AsString` |
| `FormatValue` | display (`OnGetDisplText`) |
| `FormatEditValue` | editor (`OnGetEditText`); default CStr (combo still uses key) |
| `Draw` | delegates to `Drawer` if assigned |
| `SetDrawer` | replace drawer |

`TGridEditorPool.Acquire` resets `ReadOnly=False` (shared controls). `AcquireForEdit(..., pReadOnly)` applies value then ReadOnly.

`TGridCellDrawer.Draw(...)` default empty. `PaintBackColor` is set by the hub for the current cell (`-1` after draw).

### Checkbox drawing

`TCheckboxDrawer` (base) and `TDefaultCheckboxDrawer` (factory default: box `RGB(131,132,134)`, check `RGB(0,255,0)`, `BoxSize=14`).

| Field | Default |
|---|---|
| `Margin` | 2 |
| `BoxSize` | -1 (derived from rect) |
| `BorderWidth` / `CheckWidth` | 1 / 2 |
| `CellColor` | -1 (use grid/fixed/row color) |
| `BoxColor` | white |
| `BorderColor` | `RGB(192,192,192)` |
| `CheckColor` | black |
| `HasBorder` | True |
| `OffsetX` / `OffsetY` | 2 |

Overridable: `Paint(pGrid, pRect, pChecked)`. Shared helpers: `FillCell`, `DrawBox`, `DrawShadow`, `DrawCross`.

`TGridCheckboxSupport`: `ValueAsString`, `IsChecked`, `ToggleValue`, `AcceptsActivationKey`, `CanToggle`, `ReadValue`, `TryApply`, `TryToggle`.

## Popup

Used by the hub on checkbox `OnContextPopup`. Public if the consumer wants a similar menu.

```bas
Delegate Sub TGridPopupActionDel(pItem As TGridPopupItem)

TGridPopupItem.Key / Title / Action
Sub New(pKey, pTitle, pAction)
Sub New(pTitle, pAction)                ' Key = Title
Overridable Function ItemHeight() As Integer   ' 22
Overridable Sub Build / BuildContainer / BuildItem

TGridPopupSeparator                     ' non-clickable divider

TGridPopup.ExecuteActionOnClose = True
Sub Add(pItem As TGridPopupItem)
Function Show() As TGridPopupItem       ' at cursor; Null if dismissed
Sub Close()
```

`TGridCheckboxPopup.Show(pIsSelectionColumn)` keys:

| Key | Title |
|---|---|
| `check-current` | Marcar |
| `uncheck-current` | Desmarcar |
| `check-all` | Marcar Todos |
| `uncheck-all` | Tirar Marcação de Todos |
| `invert-all` | Inverter Marcação, or **Inverter Seleção** if selection column |

Operations apply only to the clicked column. Invert on selection updates `TGridRow.Selected`. `row.Editable = False` rows are skipped by apply.

## Context / presenter / adapter

Reach via `_grid.Context` when you need native row mapping or a cell poke.

```bas
' TGridContext
Config, Data, Adapter, EditorPool, EventHub, Presenter
Property SelectionColumn / ItemColumn As TGridCol
Sub EnsureSystemColumns()
Sub ReorderSystemColumns()

' TGridPresenter
Property Prepared / Syncing As Boolean
Sub Prepare / Refresh / SyncIfPrepared / SyncStructure
Sub InvalidateIfPrepared()              ' calls adapter.InvalidateDisplay (currently empty)
Sub PokeDataCell(pDataCol, pDataIndex)  ' writes Cells(native) = CellText
Function ToNativeRow(pDataIndex) As Integer    ' + FixedRows
Function ToDataIndex(pNativeRow) As Integer    ' -1 if not a data row
Function ResolveDataFontColor / ResolveHeaderFontColor / ResolveDataBackColor / ResolveHeaderBackColor

' TNativeGridAdapter
Property Native As Grid
Sub Mount / BeginUpdate / EndUpdate
Sub InvalidateDisplay()                 ' empty
Sub PokeCell(pNativeCol, pNativeRow, pText)
Function ToNativeCol / ToDataCol / ToNativeRow / ToDataRow
Function IsHeaderRow(pNativeRow) As Boolean
```

`PokeDataCell` out of range: no-op.

## Extending (Consumer Project)

- **Custom Kind editor:** subclass `TGridEditorFactory`, implement `Kind` / `Build` / `GetValue` / `ApplyValue`. `config.EditorRegistry.Registerr(kind, factory)` before `TGridView.New(parent, config)`, or assign `col.Factory`.
- **Custom checkbox look:** subclass `TCheckboxDrawer`, override `Paint`, `col.SetDrawer(drawer)` (or `col.Options.Drawer`).
- **Per-cell edit lock:** `col.Options.Interaction.CanEdit = me._canEdit`.
- **Computed default:** `col.SetOnGetDefault(me._hoje)` or `col.Options.OnGetDefault`.
- **Validation:** `col.AddValidator(TGridValidators.Required)` / `TGridValidators.Custom(handler)`, or `config.GlobalValidators.Add`.
- **Post-commit:** `col.AddSideEffect` / `SetCascadeClear` / `config.GlobalSideEffects.Add`.
- **Native hooks:** `_grid.Events.On*` after hub logic.
- Do not subclass `TGridView` solely to change Mount flags; those live in `TNativeGridAdapter.Mount`.

## Tests

`src/Principal.bas` constructs `TGridStressRun` and calls `Execute()`, then `RunTest()` (shows the form). There is no `RunAll`.

`TGridStressRun.Execute()` covers: column add, DB fill, `Prepare`, `EnableHTML` with Image, hidden column survival, Mask/Image display, sort ASC/DESC, row ID/item integrity after sort, selection count. It is a manual/stress harness, not an assert-only suite.

## Module Notes

- Native Grid is virtual: keep values in `TGridData`. `PokeDataCell` is only a paint kick for one cell.
- `TGridView.Refresh` remounts structure (`Prepare`). `InvalidateDisplay` does not repaint.
- `AddColumn` auto-attaches `SearchDescription` once (`SideEffectCount = 0`). Extra calls do not duplicate if a side effect is already present.
- `SetValue(rowID, …)` never runs `ApplyDescriptionOnSet`; only the index overload does.
- `FastFill = True` during bulk `PushRow` skips defaults; turn it off afterwards if later inserts need them.
- Image files are written under `C:\Windows\Temp\mod_grid_img` and not deleted by `Free`.
- Selection state lives on `TGridRow.Selected`, not in the matrix cell. Item numbers live on `TGridRow.ItemNumber`.
- Consumer `Events` run last and may override hub `ByRef` results; they cannot skip hub side effects already executed in `OnSetEditText`.
