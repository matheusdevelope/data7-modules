# mod_winapi

Thin Win32 wrappers for Data7: shell execute, Unicode case conversion, GDI text measure, window find/focus/move/show, mouse, work-area/monitor geometry, and OS version. It does not own UI, does not enumerate every monitor’s real bounds, and does not decide which window, file, or click the consumer wants.

Version: `1.0.0.0`. Dependencies (`data7.json`): none.

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## Quick Start (Minimal)

```bas
Imports mod_winapi

Dim _text As String = "Hello World, Teste Com Acentuação"
Print(WinAPI.CharUpper(_text))                          ' Unicode uppercase (user32 CharUpperBuffW)
Print(WinAPI.CharLower(_text))                          ' Unicode lowercase (user32 CharLowerBuffW)
Print(WinAPI.MeasureText(_text, "Arial", 12, True).X)   ' GDI width; bold Arial height 12; X is scaled * 1.2

Dim hwnd As Long = WinAPI.Window.GetForeground()        ' current foreground HWND (0 if none)
If hwnd <> 0 Then
   Print(WinAPI.Window.GetTitle(hwnd))                  ' caption, or "" if empty
   WinAPI.Window.Focus(hwnd, True)                      ' ShowWindow(SW_RESTORE) then SetForeground
End If

Dim work As TMonitor = WinAPI.Screen.CurrentMonitor()   ' SPI work area; ID=0, Primary=True
Print(work.WorkAreaWidth)
Print(work.CenterLeft(800))                             ' left to center an 800px-wide window in the work area
work.Free()

Print(WinAPI.OS.GetVersion().ToString())                ' "Major.Minor.Build" from RtlGetVersion
Print(WinAPI.OS.IsWindows11())

WinAPI.Execute("notepad.exe", "", False, SW_SHOWNORMAL) ' ShellExecute; no elevation; shown (default show is SW_HIDE)
```

HWND miss sentinel: `0`. Empty caption: `""`. `WinAPI.OS.IsWindows*()` is `False` when version lookup fails.

---

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_winapi.bas` | `mod_winapi` | `WinAPI`, `WinAPI.Window`, `WinAPI.Mouse`, `WinAPI.Screen`, `WinAPI.OS`, `TMonitor`; consts `SW_*` |

`src/Principal.bas` declares no namespace: smoke of `CharUpper` / `CharLower` / `MeasureText` / `Window.GetForeground` / `OS.GetVersion` / `IsWindows10` / `IsWindows11`. There is no `TXxxTests.RunAll`.

The `.bas` unit `Imports Forms` because `MeasureText` accepts `FontConfig` / `TFont` and `TMonitor.ToString(True)` calls `Forms.ProcessMessages()`.

---

## Show commands

Public namespace constants for `WinAPI.Execute` / `WinAPI.Window.Show` / `WinAPI.Window.Focus` (`SW_RESTORE`). `WinAPI.Execute` defaults to `SW_HIDE`.

```bas
Const SW_HIDE = 0
Const SW_SHOWNORMAL = 1
Const SW_NORMAL = 1
Const SW_SHOWMINIMIZED = 2
Const SW_SHOWMAXIMIZED = 3
Const SW_MAXIMIZE = 3
Const SW_SHOWNOACTIVATE = 4
Const SW_SHOW = 5
Const SW_MINIMIZE = 6
Const SW_SHOWMINNOACTIVE = 7
Const SW_SHOWNA = 8
Const SW_RESTORE = 9
Const SW_SHOWDEFAULT = 10
Const SW_FORCEMINIMIZE = 11
```

`SM_*` system-metric indexes and `MOUSEEVENTF_*` flags are **not** exported. Pass raw Win32 integers to `GetMetric` / `Mouse.Dispatch`.

---

## Shell and input (`WinAPI`)

Shared façade. Do not instantiate `WinAPI` for these calls.

```bas
Shared Function Execute(pFile As String, pParameters As String, pRunAsAdm As Boolean = False, pShowWindow As Long = SW_HIDE) As Long
   ' in: pFile = path or documented name (e.g. "notepad.exe"); pParameters = args or ""
   ' in: pRunAsAdm True → verb "runas"; False → verb "" (ShellExecute default)
   ' in: hwnd=0, directory=""
   ' out: ShellExecuteW return (Win32: >32 success)
End Function

Shared Function Execute(pHwnd As Long, pOperation As String, pFile As String, pParameters As String, pDirectory As String, pShowWindow As Long) As Long
   ' raw ShellExecuteW passthrough
End Function

Shared Function GetMetric(pIndex As Long) As Long
   ' in: Win32 SM_* index as Long (this module does not export SM_* names)
   ' out: GetSystemMetrics
End Function

Shared Sub SendKeys(pKeys As String, pWait As Boolean = False)
   ' WScript.Shell.SendKeys; pWait default False
   ' CreateObject("WScript.Shell") — runtime error if COM fails
End Sub
```

Does not throw on a failed `ShellExecute` (inspect the `Long`). No `NULL`.

---

## Text (`WinAPI`)

`CharUpper` / `CharLower` use Unicode (`CharUpperBuffW` / `CharLowerBuffW`). `MeasureText` uses ANSI GDI (`CreateFontA`, `GetTextExtentPoint32A`).

Return type `TPoint`: `.X` / `.Y` as `Integer`. `FontConfig` inherits `TFont`; both overloads read `Name`, `Height`, `Bold`, `Italic`, `Underline`, `Orientation`, `Charset`, `Quality`, `Pitch`.

```bas
Shared Function CharUpper(pText As String) As String
   ' out: Unicode upper of pText (Win32 converts the buffer)
End Function

Shared Function CharLower(pText As String) As String
   ' out: Unicode lower of pText
End Function

Shared Function MeasureText(pHwnd As Long, pText As String) As TPoint
   ' uses the window DC font; no 1.2 scale
   ' GetDC=0 → (0,0)
End Function

Shared Function MeasureText(pText As String, pFont As FontConfig, pHwnd As Long = 0) As TPoint
Shared Function MeasureText(pText As String, pFont As TFont, pHwnd As Long = 0) As TPoint
   ' delegates to the Long overload; applies X * 1.2
End Function

Shared Function MeasureText(pText As String, pName As String, pHeight As Long, pBold As Boolean = False, pItalic As Boolean = False, pUnderline As Boolean = False, pOrientation As Long = 0, pCharSet As Long = 0, pQuality As Long = 0, pPitch As Long = 0, pHwnd As Long = 0) As TPoint
   ' in: pName = face (e.g. "Arial"); pHeight = CreateFont height
   ' in: pBold False → weight 400; True → 700
   ' in: pHwnd 0 → CreateCompatibleDC(0); else GetDC(pHwnd)
   ' out: size; X is CLng(rawX * 1.2)
End Function
```

`pQuality` / `pPitch` when passed as `Long` (same mapping used from `TFont` / `FontConfig`):

| `pQuality` | Meaning |
|---|---|
| `0` | default (also unknown) |
| `1` | draft |
| `2` | proof |
| `3` | non-antialiased |
| `4` | antialiased |
| `5` | ClearType |
| `6` | ClearType natural |

| `pPitch` | Meaning |
|---|---|
| `0` | default (also unknown) |
| `1` | variable |
| `2` | fixed |

No-op / empty: measuring `""` still calls GDI (width typically 0). Does not return `NULL`.

---

## Window (`WinAPI.Window`)

HWND helpers. Miss / empty-needle sentinel is `0`. Title miss is `""`.

```bas
Shared Function GetForeground() As Long
   ' out: foreground HWND, or 0
End Function

Shared Function SetForeground(pHwnd As Long) As Long
   ' out: SetForegroundWindow
End Function

Shared Function Find(pClassName As String, pWindowName As String) As Long
   ' FindWindowW(class, title); 0 if not found
End Function

Shared Function FindByTitle(pWindowName As String) As Long
   ' FindWindowW(NULL class, title); 0 if not found
End Function

Shared Function FindContains(pPart As String) As Long
   ' 1. Trim; "" → 0 (no walk)
   ' 2. UCase needle
   ' 3. desktop first child, then GW_HWNDNEXT, at most 4096
   ' 4. skip invisible; match InStr(UCase(title), needle)
   ' out: first visible HWND whose title contains pPart, else 0
End Function

Shared Function GetTitle(pHwnd As Long) As String
   ' buffer 512; n<=0 → ""
End Function

Shared Function IsVisible(pHwnd As Long) As Boolean
   ' IsWindowVisible <> 0
End Function

Shared Function Move(pHwnd As Long, pX As Long, pY As Long, pWidth As Long, pHeight As Long, pRepaint As Boolean) As Long
   ' MoveWindow; pRepaint required (no default)
End Function

Shared Function Show(pHwnd As Long, pCmdShow As Long) As Long
   ' ShowWindow; pCmdShow = SW_* above
End Function

Shared Function Focus(pHwnd As Long, pRestore As Boolean = False) As Boolean
   ' pRestore True → ShowWindow(SW_RESTORE) first
   ' then SetForegroundWindow
   ' out: GetForegroundWindow() = pHwnd
End Function

Shared Function GetRect(pHwnd As Long) As TRect
   ' GetWindowRect → TRect (Left, Top, Right, Bottom)
End Function
```

`FindContains` ignores hidden windows and titles that do not contain the trimmed substring. It does not search owned popups beyond the desktop Z-order walk.

---

## Mouse (`WinAPI.Mouse`)

Screen coordinates. Clicks with `pX`/`pY` / `TPoint` call `SetPos`, `Sleep(50)`, then the button pair. `LeftClick()` / `RightClick()` / `MiddleClick()` / `DoubleClick()` fire at the **current** cursor (no move, no 50 ms sleep except `DoubleClick`’s 100 ms gap).

```bas
Shared Function GetPos() As TPoint
Shared Sub SetPos(pPoint As TPoint)
Shared Sub SetPos(pX As Long, pY As Long)

Shared Sub LeftClick()
Shared Sub LeftClick(pPoint As TPoint)
Shared Sub LeftClick(pX As Long, pY As Long)     ' SetPos + Sleep(50) + down/up

Shared Sub RightClick()
Shared Sub RightClick(pPoint As TPoint)
Shared Sub RightClick(pX As Long, pY As Long)

Shared Sub MiddleClick()                         ' current position only

Shared Sub DoubleClick()                         ' LeftClick + Sleep(100) + LeftClick

Shared Sub ScrollVertical(pAmount As Long)
   ' mouse_event wheel; pAmount is dwData as-is (Win32 often 120 per notch)
End Sub

Shared Sub Dispatch(pFlags As Long, pX As Long, pY As Long, pButtons As Long, pExtra As Long)
   ' raw mouse_event; built-in clicks use flags 2+4 (left), 8+16 (right), 32+64 (middle), 2048 (wheel)
End Sub
```

No HWND targeting. No `NULL`. `Dispatch` does not validate flags.

---

## Screen (`WinAPI.Screen`)

Work-area oriented. `Height` / `Width` / `WorkAreaHeight` / `WorkAreaWidth` are the SPI work rectangle size (taskbar excluded), not the full display.

```bas
Shared Function CurrentWindow() As Integer
   ' CInt(Window.GetForeground())
End Function

Shared Function Height() As Integer              ' work-area height
Shared Function Width() As Integer               ' work-area width
Shared Function WorkAreaHeight() As Integer      ' alias of Height
Shared Function WorkAreaWidth() As Integer       ' alias of Width

Shared Sub FillWorkArea(ByRef pLeft As Integer, ByRef pTop As Integer, ByRef pWidth As Integer, ByRef pHeight As Integer)
   ' out: work rect; width/height clamped to minimum 1
End Sub

Shared Function VirtualHeight() As Integer
Shared Function VirtualWidth() As Integer
   ' VirtualMonitor().Height / .Width
End Function

Shared Function CurrentMonitor() As TMonitor     ' = FromWorkArea()
Shared Function PrimaryMonitor() As TMonitor     ' = FromWorkArea()
Shared Function FromWorkArea() As TMonitor
   ' ID=0, Primary=True, Bounds=WorkArea=SPI work rect
End Function

Shared Function VirtualMonitor() As TMonitor
   ' ID=0, Primary=False, origin (0,0), size SM_CXVIRTUALSCREEN × SM_CYVIRTUALSCREEN
End Function

Shared Function MonitorFromPoint(pPoint As TPoint) As TMonitor
Shared Function MonitorFromWindow(pHandle As Long) As TMonitor
Shared Function MonitorFromRect(pRect As TRect) As TMonitor
   ' ID = monitor handle (nearest; hwnd 0 → primary flag)
   ' geometry is still the SPI work area; Primary=True
End Function
```

### Work-area resolution

1. `SystemParametersInfo(SPI_GETWORKAREA)`.
2. If that returns 0: origin `SM_XVIRTUALSCREEN` / `SM_YVIRTUALSCREEN`, size `SM_CXSCREEN` / `SM_CYSCREEN`.
3. If width/height still empty: fall back to `SM_CXVIRTUALSCREEN` / `SM_CYVIRTUALSCREEN`.

`MonitorFromPoint` / `MonitorFromWindow` / `MonitorFromRect` resolve a monitor **handle** (nearest, or primary when `pHandle = 0`) but fill `TMonitor` bounds from the same work-area box, not that monitor’s pixel rectangle. Consumer owns every `TMonitor` the Screen API returns.

---

## Monitor (`TMonitor`)

Readonly layout helper built from an id, primary flag, and a rectangle. Constructor copies that rectangle into both bounds and work area.

```bas
Sub New(pId As Long, pPrimary As Boolean, pLeft As Integer, pTop As Integer, pRight As Integer, pBottom As Integer)
   ' work Left/Top/Right/Bottom start equal to bounds
End Sub
```

| Member | In/Out | Notes |
|---|---|---|
| `ID As Long` | out | `0` for work-area / virtual factory; monitor handle after `MonitorFrom*` |
| `Primary As Boolean` | out | `True` for `FromWorkArea` and `MonitorFrom*`; `False` for `VirtualMonitor` |
| `WorkLeft` / `WorkTop` | out | same as bounds left/top in this module |
| `Bounds As TRect` | out | constructor left/top/right/bottom |
| `WorkArea As TRect` | out | same rectangle as `Bounds` in this module |
| `Width` / `Height` | out | `right-left` / `bottom-top` |
| `WorkAreaWidth` / `WorkAreaHeight` | out | work right-left / bottom-top |

```bas
Function SafeWidth(pMarginPercent As Integer) As Integer
   ' CInt(WorkAreaWidth * (1 - pMarginPercent/100))  e.g. 10 → 90% of work width
End Function

Function SafeHeight(pMarginPercent As Integer) As Integer
   ' same for WorkAreaHeight
End Function

Function CenterLeft(pWidth As Integer) As Integer
   ' WorkLeft + (WorkAreaWidth - pWidth) / 2
End Function

Function CenterTop(pHeight As Integer) As Integer
   ' WorkTop + (WorkAreaHeight - pHeight) / 2
End Function

Function ToString(pPrint As Boolean = False) As String
   ' lines: ID, Primary, Bounds [L,T - R,B], WorkArea [L,T - R,B], Width, Height, WorkAreaWidth, WorkAreaHeight
   ' pPrint True → Print + Forms.ProcessMessages
End Function
```

`ToString` is the only special `ToString` in this module (`pPrint`). No setters. No `NULL`. Factory methods always `New TMonitor(...)`.

---

## OS (`WinAPI.OS`)

`RtlGetVersion` into a private record. Consume the return of `GetVersion()` (do not declare the private type). `ToString` is `Major & "." & Minor & "." & Build` (e.g. `"10.0.22621"`).

| Field | Notes |
|---|---|
| `Major` / `Minor` / `Build` | `Long`; stay `0` when lookup fails |
| `Success` | `True` only if `RtlGetVersion` returns `0` |
| `ToString()` | `"Major.Minor.Build"` even when `Success` is `False` (`"0.0.0"`) |

```bas
Shared Function GetVersion()
   ' out: Major, Minor, Build, Success, ToString(); type name is not public
   ' Success=False → keep zeros
End Function

Shared Function IsWindows11() As Boolean
   ' Success and Major=10 and Minor=0 and Build>=22000; else False
End Function

Shared Function IsWindows10() As Boolean
   ' Success and Major=10 and Minor=0 and Build<22000; else False
End Function

Shared Function IsWindows8Or81() As Boolean
   ' Success and Major=6 and Minor in (2, 3); else False
End Function

Shared Function IsWindows7() As Boolean
   ' Success and Major=6 and Minor=1; else False
End Function
```

No throw. Failed lookup → all `IsWindows*` are `False`.

---

## Extending (Consumer Project)

There is no `Add` / `Make` / `MakeByName` catalog and no overridable hooks. Call `WinAPI.*`, `WinAPI.Window.*`, `WinAPI.Mouse.*`, `WinAPI.Screen.*`, and `WinAPI.OS.*` as Shared methods.

Inherit `TMonitor` only if the consumer needs extra layout helpers on the same rectangle. Nested `WinAPI` classes have no virtual members to override.

This module has no Data7 forms. Choosing a target HWND, elevation, click coordinates, and `SW_*` stays in the consuming project.

---

## Module Notes

- Useful APIs are Shared; `New WinAPI` / `New WinAPI.Window` (and Mouse/Screen/OS) is unnecessary.
- HWND miss = `0`; `GetTitle` miss = `""`; `FindContains` on `Trim(pPart) = ""` returns `0` without walking.
- Font `MeasureText` multiplies `.X` by `1.2`; the HWND-only overload does not. GDI calls are `*A` (ANSI); titles / execute / case conversion are `*W`.
- `CurrentMonitor` and `PrimaryMonitor` are both `FromWorkArea()`. `MonitorFrom*` IDs are handles; bounds are still the SPI work area.
- `Execute` default show is `SW_HIDE`; default verb is `""` unless `pRunAsAdm` sets `"runas"`.
- Coordinate `LeftClick` / `RightClick` `Sleep(50)` after `SetPos`; `DoubleClick` `Sleep(100)` between clicks. `SendKeys` uses `WScript.Shell`.
- Consumer owns every `TMonitor` instance. Canonical smoke: `src/Principal.bas`. There is no `TXxxTests.RunAll` suite.
