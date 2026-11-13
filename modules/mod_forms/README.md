# mod_forms

`mod_forms` is a Data7 form shell: a wrapped `Form` with a top bar, header/content/footer chrome, percent-of-work-area sizing, and keyboard shortcuts. Version **1.0.0.0**. Declared dependency in `data7.json`: `mod_winapi` **1.0.0.0**. Source also imports `Forms`, `Collections`, `mod_tenum`, and `mod_tlist`.

It does **not** build domain screens, bind data, persist layout, or pick a monitor. The consumer owns captions, child controls, validation, and click handlers. Subscribe to events on `TFormsForm` / `TFormsAction`; do not assign `Host.OnResize`, `Host.OnKeyDown`, `Host.OnKeyUp`, `Host.OnShow`, `Host.OnCloseQuery`, or `Host.OnCanResize`.

This file is the module contract. Use the API from here. Do not open `.bas` files unless a detail is missing from this document.

## Quick Start (Minimal)

```bas
Imports Forms
Imports mod_forms
Imports mod_forms_topbar

Class TMyForm
   Inherits TFormsWorkspace

   Sub New()
      MyBase.New("Caption")   ' Workspace kind, top bar visible
      me.Width.Value = 800    ' pixel width axis
      me.Height.Value = 600   ' pixel height axis
      me.Size.Min = 40        ' min percent of work area (1-100)
      me.Size.Max = 95        ' max percent of work area (1-100)
      me.MaximizeOnF11 = True ' assign F11 toggle on the form hotkeys
   End Sub

   Protected Overrides Sub Build()
      ' extra top-bar button; -1 = append order; shortcut registered on Show
      Dim action As TFormsAction = me.TopBar.AddAction("hello", "Hello", "", "Hint", -1, "Ctrl+H")
      action.OnClick = me._onHello

      Dim memo As MemoTextBox = New MemoTextBox(me.Content)
      memo.Align = alClient
   End Sub

   Private Sub _onHello(pSender As TObject)
      Forms.MessageBox.Show("clicked")
   End Sub
End Class

Using _form As New TMyForm()
   _form.Show()
End Using
```

Demo entrypoint: `src/Principal.bas` (`TDemoForm`). There is no `TXxxxTests.RunAll`.

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_forms.bas` | `mod_forms` | `TFormsKind`, `TFormsForm`, `TFormsSimple`, `TFormsDialog`, `TFormsWorkspace` |
| `src/lib/mod_forms_chrome.bas` | `mod_forms_chrome` | `TFormsChrome` |
| `src/lib/mod_forms_topbar.bas` | `mod_forms_topbar` | `TFormsActionNotify`, `TFormsActionKind`, `TFormsAction`, `TFormsTopBar` |
| `src/lib/mod_forms_metrics.bas` | `mod_forms_metrics` | `TFormsAxisNotify`, `TFormsAxis`, `TFormsSize`, `TFormsMetrics` |
| `src/lib/mod_forms_screen.bas` | `mod_forms_screen` | `TFormsDisplay`, `TFormsMonitor` |
| `src/lib/mod_forms_shortcut.bas` | `mod_forms_shortcut` | `TFormsHotkey`, `TFormsHotkeys` |
| `src/lib/mod_forms_icons.bas` | `mod_forms_icons` | `TFormsGlyph` |

## Form shell

Kind and host wrapper. `TFormsForm` owns the VCL `Form`, `TFormsTopBar`, `TFormsChrome`, `TFormsHotkeys`, and `TFormsMetrics`.

### `TFormsKind`

```bas
TFormsKind.Content()     ' "Content"
TFormsKind.Dialog()      ' "Dialog"
TFormsKind.Workspace()   ' "Workspace"
```

`ApplyKind` / `Kind`:

1. Unassigned `pKind` becomes `TFormsKind.Workspace()`.
2. `"Workspace"` → `Chrome.ShowWorkspace()`; anything else → `Chrome.ShowContentOnly()`.
3. Top bar visible iff kind is not `"Content"`.

| Kind | Chrome | Top bar |
|---|---|---|
| `Workspace` | header + content + footer | visible |
| `Dialog` | content only | visible |
| `Content` | content only | hidden |

### `TFormsForm`

Host form with chrome, top bar, metrics, and hotkeys. Default kind `Workspace`. `KeyPreview = True`, `TabStop = False`, `CanResize = True`. F11 hotkey exists but is assigned only when `MaximizeOnF11 = True` (default `False`).

```bas
Sub New(pCaption As String = "")
Sub New(pCaption As String, pKind As TFormsKind)
Function Show() As Boolean                          ' False if show vetoed; else Not cancelled
Sub Close(pForce As Boolean = False)                ' pForce=True skips CanClose / confirm
Sub ApplyKind(pKind As TFormsKind)
```

**Overridable hooks** (empty / `True` unless noted):

| Hook | Purpose |
|---|---|
| `Build()` | called at the end of construction; put child controls here |
| `AfterShow()` | after metrics apply and top-bar hotkeys bind, before `OnShowEvent` |
| `CanShow() As Boolean` | default `True`; AND-combined with `OnCanShowEvent` |
| `CanClose() As Boolean` | default `True`; AND-combined with `OnCanCloseEvent` then confirm |
| `HandleOk(pSender As TObject)` | Ok click, before `OnOkEvent` |
| `HandleCancel(pSender As TObject)` | cancel close path, before `OnCancelEvent` |

**Lifecycle**

1. `Show`: `_cancelled = False` → `CanShow` → `OnCanShowEvent(me, allow)` → if not allow, return `False` and do not show → `_form.Show()` → return `Not _cancelled`.
2. Host `OnShow`: `RefreshMonitor` → `EnsureWorkAreaMax` → `ApplyPercent` → `TopBar.BindHotkeys(Hotkeys)` → `AfterShow` → `OnShowEvent(me)`.
3. Ok (`TopBar.Ok` click): `_cancelled = False` → `HandleOk` → `OnOkEvent` → if `CloseOnOk` then `Close(True)`.
4. Cancel (`TopBar.Cancel` click): `_cancelled = True` → `Close()` (not forced).
5. Close query: if `_forceClose`, allow and clear the flag; else `CanClose` → `OnCanCloseEvent` → if still allowed and `ConfirmCloseMessage <> ""`, `Forms.MessageBox.Confirmation`. If not allowed, stop. If `_cancelled`, `HandleCancel` then `OnCancelEvent`. Always if allowed: `OnCloseEvent`.

Do not assign events on `Host`. Use the fields/properties below. Sender for the re-exposed form events is `TFormsForm` (`me`), not the VCL form.

| Member | Type | In / out |
|---|---|---|
| `CloseOnOk` | `Boolean` | default `True`. After Ok, `Close(True)`. |
| `ConfirmCloseMessage` | `String` | default empty = skip confirm. Non-empty → confirmation dialog. |
| `OnCanShowEvent` | `TCloseQueryEvent` | `(sender, ByRef allow)`. After `CanShow`. |
| `OnCanCloseEvent` | `TCloseQueryEvent` | `(sender, ByRef allow)`. After `CanClose`, only if still allowed. |
| `OnShowEvent` | `TNotifyEvent` | after `AfterShow`. |
| `OnCloseEvent` | `TNotifyEvent` | after a close that was allowed. |
| `OnOkEvent` | `TNotifyEvent` | after `HandleOk`. |
| `OnCancelEvent` | `TNotifyEvent` | cancel path only, after `HandleCancel`. |
| `OnCanResize` | `TCanResizeEvent` | after internal clamp; then clamp is applied again. |
| `OnResize` | `TNotifyEvent` | after `Metrics.SyncFromForm`. |
| `OnKeyDown` | `TKeyEvent` | same slot as `Hotkeys.OnKeyDown`. |
| `OnKeyUp` | `TKeyEvent` | same slot as `Hotkeys.OnKeyUp`. |
| `Host` | `Form` | read-only wrapped form. |
| `Caption` | `String` | host caption. |
| `TopBar` | `TFormsTopBar` | owned top bar. |
| `Chrome` | `TFormsChrome` | owned chrome. |
| `Header` / `Content` / `Footer` | `PageControl` | aliases of `Chrome` regions. |
| `Hotkeys` | `TFormsHotkeys` | owned shortcut table. |
| `Metrics` | `TFormsMetrics` | owned size engine. |
| `Monitor` | `TFormsMonitor` | `Metrics.Monitor`. |
| `Width` / `Height` | `TFormsAxis` | pixel axes. |
| `CanResize` | `Boolean` | default `True`. Maps to both axes `CanGrow`. |
| `Margin` | `Integer` | **set-only**. Writes both margin percents `0-100`. |
| `MarginWidth` / `MarginHeight` | `Integer` | default `5`. Safe-area inset percent. |
| `Size` | `TFormsSize` | percent-of-work-area (`1-100`). |
| `SizeWidth` / `SizeHeight` | `Integer` | `Size.Width.Value` / `Size.Height.Value`. Throws if not `1-100`. |
| `Maximized` | `Boolean` | toggles restore vs 100% work area, centered. |
| `MaximizeOnF11` | `Boolean` | default `False`. `True` assigns parsed `"F11"`; `False` unassigns it. |
| `Kind` | `TFormsKind` | setter calls `ApplyKind`. |

**Resize (internal then consumer)**

1. If `CanResize`: clamp proposed width/height, `pCan = True`; else `pCan = False`.
2. Fire `OnCanResize(me, pWidth, pHeight, pCan)`.
3. If still `pCan` and `CanResize`, clamp again; otherwise `pCan = False`.
4. On resize: `SyncFromForm`, then `OnResize(me)`.

`Show` returns `False` only when show is vetoed. It does not return `False` because the user later cancelled; that is `Not _cancelled` after `_form.Show()` returns.

`Close(True)` is used after Ok. `Close()` / `Close(False)` still runs the close-query gate.

### `TFormsSimple`

`TFormsForm` with kind `Content` (no top bar, content-only chrome).

```bas
Sub New(pCaption As String = "")
```

### `TFormsDialog`

`TFormsForm` with kind `Dialog` (top bar visible, content-only chrome).

```bas
Sub New(pCaption As String = "")
```

### `TFormsWorkspace`

`TFormsForm` with kind `Workspace`, then `TopBar.Visible = pShowTopBar`.

```bas
Sub New(pCaption As String = "", pShowTopBar As Boolean = True)
```

## Chrome

### `TFormsChrome`

Three `PageControl` bands plus 2px gray dividers on a client-aligned host.

```bas
Sub New(pForm As Form)          ' starts as ShowContentOnly
Sub ShowContentOnly()           ' header/footer (and lines) hidden; content visible
Sub ShowWorkspace()             ' header, content, footer all visible
```

| Member | Type | Notes |
|---|---|---|
| `Host` | `PageControl` | `alClient` on the form. |
| `Header` | `PageControl` | `alTop`, height `40`. |
| `HeaderLine` | `Line` | `alTop`, height `2`, RGB `(192,192,192)`. |
| `Content` | `PageControl` | `alClient`. Created last. |
| `FooterLine` | `Line` | `alBottom`, height `2`. |
| `Footer` | `PageControl` | `alBottom`, height `20`. |

No-op: none. Does not throw. Consumer places controls on `Header` / `Content` / `Footer`.

## Top bar

### `TFormsActionKind`

```bas
TFormsActionKind.Button()    ' "Button"
TFormsActionKind.Divider()   ' "Divider"
```

### `TFormsActionNotify`

```bas
Delegate Sub TFormsActionNotify(pSender As TObject, pAction As TFormsAction)
```

### `TFormsAction`

One top-bar item. Prefer `Button` / `Divider` factories. `New` is valid but does not set caption/image.

```bas
Sub New(pId As String, pKind As TFormsActionKind, pOrder As Integer)  ' kind default Button if unassigned
Shared Function Button(pId As String, pCaption As String, pImage As String = "", pHint As String = "", pOrder As Integer = -1, pShortcut As String = "") As TFormsAction
Shared Function Divider(pId As String, pOrder As Integer = -1) As TFormsAction
Sub BindNotifier(pAction As TNotifyEvent)   ' extra notify after OnClick; TopBar.Add sets this
Sub Place(pLeft As Integer)                 ' sets Control.Left when mounted
Sub Mount(pParent As TWinControl)           ' Button → FlatButton; Divider → Line
```

| Member | Type | Notes |
|---|---|---|
| `Id` | `String` | read-only. Lookup is case-insensitive. |
| `Kind` | `TFormsActionKind` | read-only. |
| `Caption` / `Image` / `Hint` | `String` | refresh the button after `Mount`. |
| `Order` | `Integer` | sort key. `-1` on `TopBar.Add` becomes current list length. |
| `Shortcut` | `String` | `Hotkey.Text`, e.g. `"Ctrl+O"`, `"ESC"`, `"Ctrl+H"`. |
| `Hotkey` | `TFormsHotkey` | owned. `Action` is always `_dispatch`. |
| `Control` | `TControl` | `NULL` until `Mount`. |
| `OnClick` | `TNotifyEvent` | sender is the **action** (`me`), not the button. |
| `Visible` | `Boolean` | `False` if not mounted. |
| `Enabled` | `Boolean` | `False` if not mounted. |
| `Width` | `Integer` | `0` if not mounted. Seeded calc button is `70`; other buttons start at `60`. |

Click dispatch: `OnClick` then `BindNotifier`. Hint becomes `"hint (Ctrl+O)"` when a shortcut text is set; otherwise just `Hint`.

`Mount` / property sets that touch `Control` are no-ops until mounted (`Visible`/`Enabled`/`Width`/`Place`). `_refresh` is a no-op before `Mount`.

Do not assign `TopBar.Ok.OnClick` or `TopBar.Cancel.OnClick` on a `TFormsForm`: the shell already binds them. Use `OnOkEvent` / `OnCancelEvent` / `HandleOk` / `HandleCancel`. Other actions: set `OnClick` after `AddAction`.

### `TFormsTopBar`

`alTop` strip, height `58`, hidden until `TFormsForm.ApplyKind` shows it (non-Content). Seeds built-in items, then `Visible = False`.

```bas
Sub New(pParent As TWinControl)
Function Find(pId As String) As TFormsAction          ' case-insensitive Id; NULL if missing
Function Add(pAction As TFormsAction) As TFormsAction
Function AddAction(pId As String, pCaption As String, pImage As String = "", pHint As String = "", pOrder As Integer = -1, pShortcut As String = "") As TFormsAction
Function AddDivider(pId As String, pOrder As Integer = -1) As TFormsAction
Sub Realign()                                         ' Place(slot * 100) by Order, then insert index
Sub BindHotkeys(pHotkeys As TFormsHotkeys)            ' Assign every action.Hotkey
```

| Member | Type | Notes |
|---|---|---|
| `AutoRealign` | `Boolean` | default `True`. `Add` calls `Realign`. |
| `ShowActionDivider` | `Boolean` | default `True`. `Add` shows `divider.actions`. |
| `OnItemClick` | `TFormsActionNotify` | after built-in calc/HP12C handling. |
| `Host` | `PageControl` | outer strip. |
| `Items` | `TTList<TFormsAction>` | owned list. |
| `Height` | `Integer` | default `58`. |
| `Visible` | `Boolean` | |
| `Item(pId)` | `TFormsAction` | `Find`. |
| `Ok` | `TFormsAction` | `Find("ok")`. |
| `Cancel` | `TFormsAction` | `Find("cancel")`. |

**Seeded ids** (literals):

| Id | Kind | Order | Shortcut | Notes |
|---|---|---|---|---|
| `hp12c` | Button | `-10` | | caption `"HP 12C"` |
| `calc` | Button | `-9` | | caption `"Calculadora"`, width `70` |
| `divider.tools` | Divider | `-8` | | |
| `divider.actions` | Divider | `997` | | seeded `Visible = False`; shown on later `Add` if `ShowActionDivider` |
| `ok` | Button | `998` | `"Ctrl+O"` | caption `"&Ok"` |
| `cancel` | Button | `999` | `"ESC"` | caption `"&Cancelar"` |

**Built-in clicks** (`UCase(Id)`):

- `"CALC"` → `Environment.Execute("calc", "", True)`, `Sleep(500)`, `TFormsDisplay.SendKeys("%1")`
- `"HP12C"` → same execute/sleep, then `SendKeys("%2")`

`Find` / `Ok` / `Cancel` return `NULL` if that id is missing. `Add` with `Order < 0` sets `Order = Items.Length` then mounts and pushes.

## Metrics

Pixel axes (`Width`/`Height`) vs percent size (`Size`, `1-100` of the safe work area). Sentinel `-1` on an axis `Value`/`Min`/`Max` means unset. Clamp ignores min/max while they are `< 0`.

### `TFormsAxisNotify`

```bas
Delegate Sub TFormsAxisNotify(pAxis As TFormsAxis, pField As String)
```

`pField` literals: `"Value"`, `"Min"`, `"Max"`, `"CanGrow"`.

### `TFormsAxis`

Named integer axis. Default `Value`/`Min`/`Max` = `-1`, `CanGrow` = `True`.

```bas
Sub New(pName As String)
Sub Suspend()                          ' OnChange suppressed
Sub Resumee()                          ' spelling is Resumee
Function Clamp(pLast As Integer, pValue As Integer) As Integer
```

| Member | Type | Notes |
|---|---|---|
| `Name` | `String` | `"Width"`, `"Height"`, `"SizeWidth"`, `"SizeHeight"`. |
| `Value` / `Min` / `Max` | `Integer` | `-1` unset. Setting fires `OnChange` unless suspended. |
| `CanGrow` | `Boolean` | default `True`. `Clamp` returns `pLast` when `False`. |
| `OnChange` | `TFormsAxisNotify` | |

`Clamp`: if not `CanGrow` → `pLast`; else raise to `Min` if `Min >= 0`; lower to `Max` if `Max >= 0`.

### `TFormsSize`

Pair of percent axes named `"SizeWidth"` / `"SizeHeight"`. Setting `Value`/`Min`/`Max`/`CanGrow` writes **both** axes.

```bas
Sub New()
Function ClampedWidth() As Integer     ' 0 if Value < 1 (percent not applied)
Function ClampedHeight() As Integer
```

| Member | Type | Notes |
|---|---|---|
| `Width` / `Height` | `TFormsAxis` | |
| `Value` | `Integer` | reads `Width.Value`; writes both. Throws if not `1-100`. |
| `Min` / `Max` | `Integer` | both axes. Throws if not `1-100`. |
| `CanGrow` | `Boolean` | AND of both; setter writes both. |
| `OnChange` | `TFormsAxisNotify` | |

Throws: `Exception("Size percent must be 1-100, got " & CStr(pValue))`.

`ClampedWidth`/`ClampedHeight`: `Value < 1` → `0`; else clamp to axis min/max when those are `>= 1`, then cap at `100`.

### `TFormsMetrics`

Binds to a `Form`. Constructed with axes named `"Width"` / `"Height"`, last size = current form size, then `RefreshMonitor`.

```bas
Sub New(pForm As Form)
Sub RefreshMonitor()                   ' Free old TFormsMonitor; New TFormsMonitor()
Sub EnsureWorkAreaMax()                ' no-op if Monitor is NULL; cap Max to safe size
Function ClampWidth(pValue As Integer) As Integer
Function ClampHeight(pValue As Integer) As Integer
Sub Apply(pWidth As Integer, pHeight As Integer)     ' writes form Width/Height after clamp
Sub SyncFromForm()                     ' last + axis Value from form; no OnChange
Sub ToggleMaximized()
Sub ApplyPercent()                     ' Apply from Size percents; keep form size if percent is 0 or Monitor is NULL
```

| Member | Type | Notes |
|---|---|---|
| `Width` / `Height` | `TFormsAxis` | pixels. Changing `Value` applies to the form. `Min`/`Max` also call `EnsureWorkAreaMax`. |
| `Monitor` | `TFormsMonitor` | |
| `CanResize` | `Boolean` | both axes `CanGrow`. |
| `Margin` | `Integer` | **set-only**. Both percents. Throws if not `0-100`. Then `EnsureWorkAreaMax` + `ApplyPercent`. |
| `MarginWidth` / `MarginHeight` | `Integer` | default `5`. |
| `Size` | `TFormsSize` | any `OnChange` → `ApplyPercent`. |
| `SizeWidth` / `SizeHeight` | `Integer` | throws if not `1-100`. |
| `Maximized` | `Boolean` | setter no-op if unchanged; else `ToggleMaximized`. |

Throws:

- Size percent: `"Size percent must be 1-100, got "`
- Margin: `"Safe-area margin must be 0-100, got "`

`ToggleMaximized`: if already maximized, restore stored left/top/width/height. Else snapshot geometry, `RefreshMonitor`, `EnsureWorkAreaMax`, `Size.Value = 100`, center in work area.

`EnsureWorkAreaMax`: if axis `Max < 0` or `Max >` safe work area, set `Max` to `SafeWidth(MarginWidth)` / `SafeHeight(MarginHeight)` without notifying.

## Screen

Always the primary work area from `WinAPI.Screen.FillWorkArea`. `MonitorFromWindow` / `CurrentMonitor` / `PrimaryMonitor` all `New TFormsMonitor()` — `pHandle` is ignored.

### `TFormsDisplay`

```bas
Shared Function ForegroundWindow() As Long
Shared Function MonitorFromWindow(pHandle As Long) As TFormsMonitor
Shared Function CurrentMonitor() As TFormsMonitor
Shared Function PrimaryMonitor() As TFormsMonitor
Shared Sub SendKeys(pKeys As String, pWait As Boolean = False)
```

`SendKeys` examples used by the top bar: `"%1"`, `"%2"`.

### `TFormsMonitor`

```bas
Sub New()   ' Id=0, Primary=True, rectangle = work area
Sub New(pId As Long, pPrimary As Boolean, pLeft As Integer, pTop As Integer, pWidth As Integer, pHeight As Integer)
Function SafeWidth(pMarginPercent As Integer) As Integer    ' Width * (1 - percent/100)
Function SafeHeight(pMarginPercent As Integer) As Integer
Function CenterLeft(pWidth As Integer) As Integer           ' Left + (Width - pWidth) / 2
Function CenterTop(pHeight As Integer) As Integer
```

| Member | Type | Notes |
|---|---|---|
| `Id` | `Long` | default `0`. |
| `Primary` | `Boolean` | default `True`. |
| `Width` / `Height` | `Integer` | work-area size. |
| `WorkAreaWidth` / `WorkAreaHeight` | `Integer` | same as `Width` / `Height`. |

## Hotkeys

Shortcut text is `+`-separated, case-insensitive. Last token is the key. Examples: `"F11"`, `"ESC"`, `"Ctrl+O"`, `"Ctrl+H"`, `"Shift+Alt+K"`.

Named keys: `F1`–`F12`, `CTRL`, `SHIFT`, `ALT`, `ESC`, `TAB`, `ENTER`/`RETURN`, `SPACE`, `DEL`/`DELETE`, `HOME`, `END`, `PGUP`/`PAGEUP`, `PGDN`/`PAGEDOWN`, `INS`/`INSERT`, `LEFT`, `UP`, `RIGHT`, `DOWN`, `WIN`. One-character tokens use `Asc`. Unknown name → key `0`.

Encode flags added to the virtual-key: Ctrl `16384`, Shift `8192`, Alt `32768`, Win `4096`.

### `TFormsHotkey`

```bas
Sub New()
Sub New(pShortcut As String)
Sub New(pCode As Long)
Sub New(pSource As TFormsHotkey)                 ' no-op copy if pSource is NULL
Shared Function Parse(pShortcut As String) As TFormsHotkey
Shared Function Encode(pKey As Integer, pCtrl As Boolean, pShift As Boolean, pAlt As Boolean, pWin As Boolean) As Long
Function Clone() As TFormsHotkey                 ' New TFormsHotkey(me): copies Code + Action
Function IsBound() As Boolean                    ' Code > 0
```

| Member | Type | Notes |
|---|---|---|
| `Key` | `Integer` | virtual-key. |
| `Ctrl` / `Shift` / `Alt` / `Win` | `Boolean` | |
| `Text` | `String` | canonical `"Ctrl+O"` style after parse/rebuild. |
| `Code` | `Long` | encoded key + modifiers. |
| `Action` | `TNotifyEvent` | sender is the **hotkey** when fired from `TFormsHotkeys`. |

`Free` sets `Action = NULL`.

### `TFormsHotkeys`

In-memory table. `Assign` **clones** the hotkey; later edits to the original object are ignored. Match/unassign by `Code`.

```bas
Sub New()
Sub Assign(pHotkey As TFormsHotkey)                              ' no-op if NULL or not IsBound
Sub Assign(pHotkey As TFormsHotkey, pAction As TNotifyEvent)     ' no-op if NULL; sets Action then Assign
Sub Assign(pShortcut As String, pAction As TNotifyEvent)
Sub Unassign(pHotkey As TFormsHotkey)                            ' no-op if NULL; no-op if Code not found
Sub HandleKeyDown(pSender As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
Sub HandleKeyUp(pSender As TObject, ByRef pKey As Word, pShift As Forms.TShiftState)
```

| Member | Type | Notes |
|---|---|---|
| `Ctrl` / `Shift` / `Alt` / `Win` / `Esc` | `Boolean` | live modifier flags (read-only). |
| `OnKeyDown` | `TKeyEvent` | after match (or immediately for modifiers). |
| `OnKeyUp` | `TKeyEvent` | after tracking key-up. |
| `OnAction` | `TNotifyEvent` | after a bound hotkey `Action`; sender is the cloned hotkey. |

**Key matching**

1. Track modifiers: `17` Ctrl, `16` Shift, `18` Alt, `27` Esc, `91`/`92` Win.
2. If key is modifier (`16`,`17`,`18`,`91`,`92`): fire `OnKeyDown` only, no action lookup. `ESC` is **not** a modifier and can match `"ESC"`.
3. Encode `(pKey, Ctrl, Shift, Alt, Win)` and find by `Code`.
4. If hit: `hit.Action(hit)` then `OnAction(hit)`.
5. Fire `OnKeyDown`.

`TFormsForm` binds host `OnKeyDown`/`OnKeyUp` to these handlers. Re-expose via `TFormsForm.OnKeyDown` / `OnKeyUp` (aliases of these fields).

## Glyphs

### `TFormsGlyph`

Embedded BMP payloads for `TFormsAction.Image` / `FlatButton.Image`.

```bas
Shared Function HP12C() As String
Shared Function CALC() As String
Shared Function OK() As String
Shared Function CANCEL() As String
```

## Extending (Consumer Project)

Inherit a shell, override `Build` (and optionally the other hooks), put controls on `Header` / `Content` / `Footer`.

```bas
Imports Forms
Imports mod_forms
Imports mod_forms_topbar

Class TInvoiceForm
   Inherits TFormsDialog

   Sub New()
      MyBase.New("Invoice")
      me.Size.Value = 70
      me.OnResize = me._onLayout
      me.OnCanCloseEvent = me._onCanClose
   End Sub

   Protected Overrides Sub Build()
      me.TopBar.AddAction("save", "Save", "", "Save", -1, "Ctrl+S").OnClick = me._onSave
   End Sub

   Protected Overrides Function CanClose() As Boolean
      CanClose = True
   End Function

   Protected Overrides Sub HandleOk(pSender As TObject)
   End Sub

   Private Sub _onLayout(pSender As TObject)
   End Sub

   Private Sub _onCanClose(pSender As TObject, ByRef pCanClose As Boolean)
   End Sub

   Private Sub _onSave(pSender As TObject)
   End Sub
End Class
```

| Base | Use |
|---|---|
| `TFormsWorkspace` | header/content/footer + top bar (`pShowTopBar` to hide) |
| `TFormsDialog` | top bar + content only |
| `TFormsSimple` | content only, no top bar |
| `TFormsForm` | pick `TFormsKind` in `New` |

There is no type catalog / `MakeByName` in this module.

## Module Notes

- `TFormsForm.Free` frees hotkeys, the F11 hotkey, metrics, top bar, chrome, then the host `Form`. The consumer does not free those children separately.
- `TFormsHotkeys.Assign` stores a **clone**. `TopBar.BindHotkeys` runs on every show and re-`Assign`s each action hotkey.
- Axis `-1` is unset; percent APIs throw outside `1-100`; margins throw outside `0-100`. `TFormsSize` percent `< 1` means “do not apply percent” (`ClampedWidth`/`ClampedHeight` return `0`, `ApplyPercent` keeps the current form size).
- Host VCL events are owned by the shell. Consumer slots: `OnResize`, `OnCanResize`, `OnKeyDown`, `OnKeyUp`, `OnShowEvent`, `OnCloseEvent`, `OnOkEvent`, `OnCancelEvent`, `OnCanShowEvent`, `OnCanCloseEvent`. `OnKeyDown`/`OnKeyUp` on the form are the same fields as `Hotkeys.OnKeyDown`/`OnKeyUp`.
- Top-bar `Find` is case-insensitive. Built-in ids: `"hp12c"`, `"calc"`, `"divider.tools"`, `"divider.actions"`, `"ok"`, `"cancel"`. Overwriting `Ok.OnClick` / `Cancel.OnClick` drops the shell Ok/Cancel close path.
- `TFormsDisplay` monitor helpers always return the primary work area (`Id = 0`, `Primary = True`). This module does not persist geometry.
- `Resumee` is the real method name on `TFormsAxis`. Demo: `src/Principal.bas` (`TDemoForm`); no automated test runner.
