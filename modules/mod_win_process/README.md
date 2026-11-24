# mod_win_process

Windows child-process engine for Data7. Starts a command line, optionally hidden, and exposes stdin / stdout / stderr, live poll (including `\r` progress), working directory, and UAC elevation.

This module does **not** install, download, unzip, or embed executables. Pass a full command line. Payload materialization belongs in a consumer such as `mod_portable_exe`.

Version `1.0.0.0`. No extra Data7 module dependencies (`data7.json`).

This file is the module contract. Do not open `.bas` files to use the API.

## Quick Start (Minimal)

```basic
Imports mod_win_process

Dim job As New TWinProcess()
Dim linhas As StringList = job.CaptureLines("cmd.exe /c echo hello")
' ... use linhas ...
linhas.Free()
job.Free()
```

Live `\r` progress (hidden console scrape):

```basic
Imports mod_win_process

Dim job As New TWinProcess()
If job.Start("""C:\tool\tool.exe"" -args") Then
   While job.IsRunning()
      Dim line As String = job.PullStdOutLine()
      If Trim(line) <> "" Then
         ' UI
      End If
   Wend
End If
job.Free()
```

## Namespace Map

| File | Namespace | Types |
| --- | --- | --- |
| `src/mod_win_process.bas` | `mod_win_process` | `TWinProcess` |
| `src/tests/mod_win_process_tests.bas` | `mod_win_process_tests` | `TWinProcessSuite` |

## `TWinProcess`

One instance, one child at a time. `Start` / `Run` / `CaptureLines` take a **full command line** (quote the exe path with `String.Quoted()` when it contains spaces). Default is hidden (`Visible=False`). `Dispose` (via `Free`) calls `StopProcess(True)`. Leaving a process running after `Free` is not supported.

### Properties

| Member | Type | Default | Notes |
| --- | --- | --- | --- |
| `UseConsole` | `Boolean` | `True` | Live console scrape (`\r` progress). `False` = anonymous pipes (IPC, split stderr, GUI). **Not** “show a window”. |
| `MergeStdErr` | `Boolean` | `True` | `False` is only honored with `UseConsole=False`. |
| `Visible` | `Boolean` | `False` | `True` shows the child window. |
| `WorkingDir` | `String` | `""` | Inherit the parent current directory when empty. |
| `RunAsAdmin` | `Boolean` | `False` | UAC `"runas"` when the parent is not elevated. |

### Execute API

```basic
Overridable Function Start(pCommand As String = "") As Boolean
   ' full command line (quote the exe path)
   ' if RunAsAdmin and parent is not elevated: ShellExecuteEx "runas" (UAC)
   ' else: if UseConsole and not Visible then pty (not WOW64);
   '       if UseConsole then console (CREATE_NEW_CONSOLE);
   '       then pipes (CREATE_NO_WINDOW unless Visible)

Function Run(pCommand As String = "") As Integer
   ' UseConsole=False for the spawn; drain while WaitExit; ExitCode
   ' out: process exit code (1 if Start failed)

Function CaptureLines(pCommand As String = "") As StringList
   ' UseConsole=False for the spawn; collect non-blank PullStdOutLine until exit
   ' out: new StringList — caller Free()s it

Function PullStdOut() / PullStdOutLine() As String
   ' stdout (console/pty: merged stdout+stderr of the console)

Function PullStdErr() / PullStdErrLine() As String
   ' pipes + MergeStdErr=False only; else ""

Function WriteStdin(pText As String) As Boolean
   ' pipes/pty: WriteFile on the stdin pipe
   ' console: AttachConsole + CONIN$

Function WriteLine(pText As String) As Boolean
   ' WriteStdin(pText & CR LF)

Function WaitLine() As String
   ' blocking PullStdOutLine until a line or exit

Function WaitOutput(pSuccessToken As String, pErrorToken As String = "") As String
   ' blocking until a stdout line contains a token, or the child exits

Function WaitExit(pTimeoutMs As Long = -1) As Boolean
   ' WaitForSingleObject; -1 = infinite
   ' out: True if the child has exited

Function ProcessKind() As String
   ' backend actually used: "console" | "pty" | "pipes" | "runas" | ""
   ' kept after exit / StopProcess until the next Start
   ' diagnostic; not required for the common Start/PullStdOut loop

Function ProcessId() As Long
   ' Windows PID; 0 if Start failed or was never called
   ' kept after exit until the next Start

Function CommandLine() As String
   ' last pCommand passed to Start / Run / CaptureLines

Function LastError() As Long
   ' Win32 code of the last failed CreateProcess / ShellExecuteEx in Start
   ' 0 after a successful Start; 1223 = user cancelled UAC

Function LastErrorText() As String
   ' short English reason after a failed Start; "" after success

Function IsRunning() As Boolean
Function ExitCode() As Integer
   ' -1 = not started / still running / unknown; else the child exit code
Sub StopProcess(pKill As Boolean = True)
```

### Use cases

| Use case | How |
| --- | --- |
| Fire and wait | `Run(...)` |
| Capture stdout lines | `CaptureLines(...)` then `Free` the list |
| Live `\r` progress (`dbbackup`, `Rar.exe`) | default `UseConsole=True`, `Visible=False`, `Start(...)`, loop `PullStdOutLine` |
| Line IPC (stdin/stdout) | `UseConsole=False`, `Start()`, `WaitOutput` / `WriteLine` |
| Split stderr | `UseConsole=False`, `MergeStdErr=False`, `PullStdErr` / `PullStdErrLine` |
| Visible GUI (`notepad`, installer) | `Visible=True`, `UseConsole=False`, `Start(...)` |
| Visible console the user can watch | `Visible=True`, `UseConsole=True`, `Start(...)` |
| Working directory | `WorkingDir = "C:\data"` before `Start` |
| Run as administrator | `RunAsAdmin=True` before `Start` (UAC if the parent is not elevated) |

### Backends

| Backend | Live `\r` progress | stdin | stderr separate |
| --- | --- | --- | --- |
| `console` (32-bit Data7 default when `UseConsole=True`) | yes (screen buffer) | CONIN$ | no (mixed in `PullStdOut`) |
| `pty` | yes | pty input pipe | no (terminal mix) |
| `pipes` (`UseConsole=False`, or fallback) | only if the child flushes | stdin pipe | yes when `MergeStdErr=False` |
| `runas` (`RunAsAdmin=True`, parent not elevated) | no | no | no |

Keep `UseConsole=True` (default) for console tools that rewrite one line (`dbbackup`, `Rar.exe`). Set `UseConsole=False` and `MergeStdErr=False` when the caller must split stderr or speak a stdin/stdout line protocol.

`Visible=True` skips ConPTY (no window) and does not `SW_HIDE` the console. GUI programs should also set `UseConsole=False` so CreateProcess does not allocate an extra console. A console-subsystem exe with pipes (`UseConsole=False`) may still not open a console because stdout is redirected — use `UseConsole=True` when the user must see the console.

`RunAsAdmin=True`: if this process is already elevated, `CreateProcess` is used (pipes/console I/O work). If not, Windows shows UAC (`ShellExecuteEx` verb `runas`). Cancel → `Start` returns False, `LastError` 1223. Across a UAC boundary, `PullStdOut` / `WriteStdin` are empty/false (integrity isolation). `WaitExit` / `ExitCode` / `IsRunning` still work. `StopProcess(True)` may fail to kill an elevated child from a non-elevated parent. Typical installer: `RunAsAdmin=True`, `Visible=True`, `UseConsole=False`.

```basic
If job.Start("""C:\Program Files\WinRAR\Rar.exe"" -ibck -ep1 archive.rar source") Then
   While job.IsRunning()
      Dim chunk As String = job.PullStdOut()
      If chunk <> "" Then
         ' update UI from chunk
      End If
   Wend
   Dim tail As String = job.PullStdOut()
   Dim code As Integer = job.ExitCode()
End If
```

`IsRunning` is `GetExitCodeProcess` = `STILL_ACTIVE`. After the child exits, keep calling `PullStdOut` once more to drain.

## Tests

`src/Principal.bas` runs `TWinProcessSuite.Run()`. Fixtures use `cmd.exe` (no embedded payload):

- default property values
- `CaptureLines` of `cmd.exe /c echo …` (`ProcessKind` = `pipes`)
- `Run("cmd.exe /c exit 7")` exit code
- `ProcessId` / `CommandLine` after a completed run
- `WorkingDir = "C:\Windows"` with `cmd.exe /c cd`
- failed `Start` of a missing exe (`LastError` / `LastErrorText`)
- `Start` of a long `ping` then `StopProcess(True)`

Does not click through UAC (`RunAsAdmin`) and does not open a visible window (`Visible=True`).

## Module Notes

- `CaptureLines` returns a new `StringList`; the caller must `Free` it. Blank lines are dropped.
- `StopProcess` does not wait for the child to exit; it may TerminateProcess and close handles. It does not zero `ProcessId` or `ProcessKind`.
- `PullStdOut` does not block; call it from the consumer loop (or a timer). This module does not call `ProcessMessages` / `Sleep`.
- Tools that buffer stdout until exit still will not stream; `PullStdOut` only sees what the child actually writes. Prefer the CLI that writes progress to stdout/stderr (e.g. `Rar.exe`, not `WinRAR.exe`). `UseConsole=True` is required for `\r` progress from 32-bit Data7.
- ConPTY is skipped on WOW64 (32-bit Data7 parent + 64-bit child → `STATUS_DLL_INIT_FAILED`). Hidden live progress then uses the console-scrape backend.
- Quote paths with spaces: `exePath.Quoted() & " " & args`.
