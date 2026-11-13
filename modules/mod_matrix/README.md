# mod_matrix

In-memory row/column grid of object cells. `TMatrix` is the physical engine (IDs, indexes, cell pointers, ownership). `TTMatrix` is the typed facade over that engine (generic columns, rows, and cell values, plus find/filter/sort helpers). It does not persist, paint a grid, or choose business IDs, titles, or cell types — that stays in the consumer.

Version: `1.0.0.3` (`data7.json`). Dependencies (`data7.json`): none. Runtime imports: `Collections`, `mod_tobject`.

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## Quick Start (Minimal)

```bas
Imports mod_tmatrix
Imports mod_ttmatrix

Class TCliCol
   Inherits TTMatrixCol<Variant>
   Sub New(pID As String)
      MyBase.New(pID)
   End Sub
   Sub Free()
      MyBase.Free()
   End Sub
End Class

Class TCliRow
   Inherits TTMatrixRow<Variant>
   Sub New(pID As String)
      MyBase.New(pID)
   End Sub
   Sub Free()
      MyBase.Free()
   End Sub
End Class

Dim grid As New TTMatrix<TCliCol, TCliRow, Variant>("Clientes")  ' owns wrapped cells
grid.AddColumn(New TCliCol("NOME"))                              ' column ID
grid.AddColumn(New TCliCol("SALDO"))
grid.AddRow(New TCliRow("CLI_1"))                                ' row ID
grid.SetValueFromID("CLI_1", "NOME", "Ana")                      ' Variant cell
grid.SetValueFromID("CLI_1", "SALDO", 500)
Dim nome As String = CStr(grid.GetValueFromID("CLI_1", "NOME"))  ' "Ana"
grid.Free()                                                     ' rows, cols, owned cells
```

ID literals used by this project: `"NOME"`, `"SALDO"`, `"ATIVO"`, `"ID"`, `"CLI_1"`, `"NODE_0"`. Lookup is `Trim` + case-insensitive (`"NOME"` = `"nome"`).

---

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/mod_tmatrix.bas` | `mod_tmatrix` | `TMatrixCol`, `TMatrixRow`, `TMatrix`; delegates `OnActionMatrixRowDel`, `OnActionMatrixColDel`, `OnActionMatrixCellDel`, `OnActionMatrixBasicDel`, `TMatrixSortRowDel`, `TMatrixSortColDel` |
| `src/mod_ttmatrix.bas` | `mod_ttmatrix` | `TTMatrixItem<T>`, `TTMatrixCol<T>`, `TTMatrixRow<T>`, `TTMatrix<TypeCol, TypeRow, TypeValue>`; delegates `TTMatrixRowFilterDel`, `TTMatrixColFilterDel`, `TTMatrixSortRowDel`, `TTMatrixSortColDel`, `TTMatrixCellChangeDel`, `TTMatrixIdIndexDel`, `TTMatrixMoveDel`, `TTMatrixNotifyDel` |

`src/Principal.bas` declares no namespace. Entrypoint: `RunCompleteTestSuite()`.

There is no `Add` / `Make` / `MakeByName` catalog.

---

## Physical layout

Each column holds one `StringList` (`TMatrixCol.Cells`) with `OwnsObjects = False`. Row index `i` is `Cells.Objects(i)` on every column. Moving a row moves that index in `_rows` and in every column’s `Cells`. Moving a column moves the column object (its `Cells` travel with it).

New row or column: every new slot is `AddObject("", Null)`.

```text
1. Resolve row/col by ID (Trim, case-insensitive) or by 0-based index
2. Cell pointer lives on the column, not on the row
3. StructureVersion bumps on structural edits; row/col Index caches refresh from it
```

---

## Physical engine (`mod_tmatrix`)

### Delegates

```bas
Delegate Sub OnActionMatrixRowDel(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
Delegate Sub OnActionMatrixColDel(pMatrix As TMatrix, pColID As String, pIndex As Integer)
Delegate Sub OnActionMatrixCellDel(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOldValue As TTObject, pNewValue As TTObject)
Delegate Sub OnActionMatrixBasicDel(pMatrix As TMatrix)
Delegate Function TMatrixSortRowDel(pRow As TMatrixRow, pIndex As Integer, pExtra As Variant) As String
Delegate Function TMatrixSortColDel(pCol As TMatrixCol, pIndex As Integer, pExtra As Variant) As String
```

### `TMatrixCol`

One column: ID, cell bag, cached index. Inherits `TTObject`.

| Member | In/Out | Notes |
|---|---|---|
| `ID As String` | in | list key; do not change after `AddColumn` |
| `Cells As StringList` | out | one entry per row; `OwnsObjects = False`; `Objects(i)` is the cell |
| `Index As Integer` | out | 0-based; `-1` until bound or if `GetColIndex(ID)` misses |
| `Matrix As TMatrix` | out | set by `BindMatrix` / `AddColumn` |

```bas
Sub New(pID As String)
   ' in: column ID; Cells empty; Index cache (-1, version -1)
End Sub

Sub BindMatrix(pMatrix As TMatrix)
   ' in: owner matrix; AddColumn already calls this
End Sub

Function GetValue(pRowIndex As Integer) As TTObject
   ' in: 0-based row index (not bounds-checked here)
   ' out: cell TTObject, which may be Null
End Function

Function GetValue(pRowID As String) As TTObject
   ' out: cell, or Null if the row ID is missing
End Function

Function GetValueFromID(pRowID As String) As TTObject
   ' same as GetValue(pRowID)
End Function

Sub SetValue(pRowIndex As Integer, pValue As TTObject)
   ' routes through TMatrix.SetValue (ownership + change events)
End Sub

Sub SetValue(pRowID As String, pValue As TTObject)
   ' no-op if the row ID is missing
End Sub

Sub SetValueFromID(pRowID As String, pValue As TTObject)
   ' same as SetValue(pRowID, pValue)
End Sub
```

`Clone` copies `ID` only (empty `Cells`, not bound). `Dispose` Frees `Cells`.

### `TMatrixRow`

One row: ID and cached index. Cells are not stored on the row.

| Member | In/Out | Notes |
|---|---|---|
| `ID As String` | in | list key; do not change after `AddRow` |
| `Index As Integer` | out | 0-based; `-1` if unbound or lookup misses |
| `Matrix As TMatrix` | out | set by `BindMatrix` / `AddRow` |

```bas
Sub New(pID As String)
   ' in: row ID; Index cache (-1, version -1)
End Sub

Sub BindMatrix(pMatrix As TMatrix)
   ' AddRow already calls this
End Sub

Function GetValue(pColIndex As Integer) As TTObject
   ' out: cell, or Null if this row's Index is -1
End Function

Function GetValue(pColID As String) As TTObject
   ' out: cell, or Null if the column ID is missing
End Function

Function GetValueFromID(pRowID As String) As TTObject
   ' in: parameter name is pRowID; lookup is a column ID (forwards to GetValue(pColID))
   ' out: cell, or Null if that column ID is missing
End Function

Sub SetValue(pColIndex As Integer, pValue As TTObject)
   ' no-op if this row's Index is -1
End Sub

Sub SetValue(pColID As String, pValue As TTObject)
   ' no-op if the column ID is missing
End Sub

Sub SetValueFromID(pRowID As String, pValue As TTObject)
   ' in: parameter name is pRowID; treated as a column ID
End Sub
```

`Clone` copies `ID` only (not bound). Prefer `TTMatrixRow.GetValue(pColID)` when using the typed facade.

### `TMatrix`

Physical grid. Default name `"TMatrix"`, `OwnsObjects = True`, `DisableEvents = False`, `StructureVersion` starts at `0`. Inner row/col lists do not own their objects (`OwnsObjects = False` on those lists); `TMatrix` Frees row/col wrappers itself.

| Member | In/Out | Notes |
|---|---|---|
| `Name As String` | in | also prefixes inner list names (`Name + "_Rows"` / `"_Cols"`) |
| `DisableEvents As Boolean` | in | default `False`; `True` suppresses hooks and `On*` |
| `StructureVersion As Integer` | out | bumps on add/delete/move/clean-rows/clean-cols/reorder |
| `OwnsObjects As Boolean` | in/out | default `True`: replace/delete/dispose Frees cell `TTObject`s |
| `RowCount As Integer` | out | `0` when empty |
| `ColCount As Integer` | out | `0` when empty |
| `OnBeforeAddRow` / `OnAfterAddRow` | in | `OnActionMatrixRowDel` |
| `OnBeforeDeleteRow` / `OnAfterDeleteRow` | in | `OnActionMatrixRowDel` |
| `OnBeforeAddCol` / `OnAfterAddCol` | in | `OnActionMatrixColDel` |
| `OnBeforeDeleteCol` / `OnAfterDeleteCol` | in | `OnActionMatrixColDel` |
| `OnBeforeChange` / `OnAfterChange` | in | `OnActionMatrixCellDel`; skipped if old and new are the same instance |
| `OnBeforeClean` / `OnAfterClean` | in | `OnActionMatrixBasicDel`; also fired by `ApplyRowOrder` / `ApplyColOrder` |
| `OnBeforeDispose` / `OnAfterDispose` | in | `OnActionMatrixBasicDel` |

```bas
Sub New(pName As String = "TMatrix", pOwnsObjects As Boolean = True, pDisableEvents As Boolean = False)

Sub BeginUpdate()
   ' nested counter; events off while count > 0
End Sub

Sub EndUpdate()
   ' decrement; floors at 0 (extra calls are no-ops on the counter)
End Sub

Function IsEventsEnabled() As Boolean
   ' out: (Not DisableEvents) And (_updateCount = 0)
End Function

Function GetRowIndex(pRowID As String) As Integer
   ' out: 0-based index, or -1
End Function

Function GetColIndex(pColID As String) As Integer
   ' out: 0-based index, or -1
End Function

Function Row(pRowID As String) As TMatrixRow
Function RowFromID(pRowID As String) As TMatrixRow
Function Row(pIndex As Integer) As TMatrixRow
   ' missing ID / bad index is not guarded here (list Take)

Function Col(pColID As String) As TMatrixCol
Function ColFromID(pColID As String) As TMatrixCol
Function Col(pIndex As Integer) As TMatrixCol

Sub AddColumn(pID As String)
   ' constructs New TMatrixCol(pID)
End Sub

Sub AddColumn(pCol As TMatrixCol)
   ' keys the list with pCol.ID
End Sub

Sub AddColumn(pColID As String, pCol As TMatrixCol)
   ' keep pColID equal to pCol.ID (list key vs Index lookup)
   ' throw: "Coluna já existe: " + pColID
   ' 1. bump StructureVersion
   ' 2. BeforeAddCol at the new index
   ' 3. BindMatrix; append Null cell per existing row
   ' 4. AfterAddCol
End Sub

Sub AddRow(pID As String)
Sub AddRow(pRow As TMatrixRow)
Sub AddRow(pRowID As String, pRow As TMatrixRow)
   ' throw: "Linha já existe: " + pRowID
   ' append Null on every column's Cells, then push the row
End Sub

Sub DeleteColFromID(pColID As String)
   ' missing ID: bump StructureVersion, then no-op
   ' OwnsObjects: Dispose+Free each cell, then Free the column
End Sub

Sub DeleteCol(pIndex As Integer)
   ' no-op if pIndex < 0, pIndex >= ColCount, or Col(pIndex) is Null
End Sub

Sub DeleteRowFromID(pRowID As String)
   ' missing ID: bump StructureVersion, then no-op
End Sub

Sub DeleteRow(pIndex As Integer)
   ' no-op if out of range or Row(pIndex) is Null
End Sub

Sub MoveCol(pColID As String, pToIndex As Integer)
   ' always bumps StructureVersion; no-op if ID missing or already at pToIndex
End Sub

Sub MoveRow(pRowID As String, pToIndex As Integer)
   ' always bumps StructureVersion; also Moves each column's Cells
End Sub

Function GetValue(pRowIndex As Integer, pColIndex As Integer) As TTObject
   ' indexes not bounds-checked here
End Function

Function GetValue(pRowID As String, pColID As String) As TTObject
   ' out: cell, or Null if either ID is missing
End Function

Function GetValueFromID(pRowID As String, pColID As String) As TTObject
   ' same as GetValue(pRowID, pColID)
End Function

Sub SetValue(pRowIndex As Integer, pColIndex As Integer, pValue As TTObject)
   ' no-op if old and new are the same instance
   ' OwnsObjects: Dispose+Free the previous cell before replacing
End Sub

Sub SetValue(pRowID As String, pColID As String, pValue As TTObject)
   ' no-op if either ID is missing
End Sub

Sub SetValueFromID(pRowID As String, pColID As String, pValue As TTObject)
   ' same as SetValue(pRowID, pColID, pValue)
End Sub

Sub ApplyRowOrder(pSortedList As StringList, pAsc As Boolean)
   ' in: StringList.Objects are the existing TMatrixRow instances, length = RowCount
   ' pAsc = False walks that list in reverse
   ' fires BeforeClean / AfterClean; bumps StructureVersion
End Sub

Sub ApplyColOrder(pSortedList As StringList, pAsc As Boolean)
   ' in: StringList.Objects are the existing TMatrixCol instances
End Sub

Sub SortRows(pHandler As TMatrixSortRowDel, pAsc As Boolean = True)
Sub SortRows(pHandler As TMatrixSortRowDel, pAsc As Boolean = True, pExtra As Variant)
   ' no-op if pHandler is Null or RowCount <= 1
   ' 1. key = pHandler(row, index, pExtra)  ' pExtra defaults to Unassigned
   ' 2. StringList.Sorted = True
   ' 3. ApplyRowOrder(list, pAsc)
End Sub

Sub SortCols(pHandler As TMatrixSortColDel, pAsc As Boolean = True)
Sub SortCols(pHandler As TMatrixSortColDel, pAsc As Boolean = True, pExtra As Variant)
   ' no-op if pHandler is Null or ColCount <= 1
End Sub

Sub CleanRows(pDispose As Boolean = True)
   ' drops all rows; columns remain (Cells.Clear)
   ' pDispose: Dispose owned cells first
End Sub

Sub CleanCols(pDispose As Boolean = True)
   ' drops all columns; rows remain
End Sub

Sub Clean(pDispose As Boolean = True)
   ' drops rows and columns
   ' pDispose: Dispose (owned cells + dispose events), then _disposed = False so the instance can be reused
End Sub

Overrides Function Clone() As TTObject
   ' out: New TMatrix(Name + "_Clone", OwnsObjects, DisableEvents)
   ' copies column IDs, then row IDs; OwnsObjects → Clone each cell, else alias the same TTObject
   ' does not copy On* handlers
End Function

Overrides Sub Dispose()
   ' once-only (_disposed); OwnsObjects → Dispose+Free cells; does not Free row/col wrappers
End Sub

Sub Free(pDispose As Boolean = True)
   ' pDispose → Dispose; then Free every row, every col, inner lists, MyBase.Free
End Sub
```

**Throws**

| Call | Message |
|---|---|
| duplicate `AddColumn` | `"Coluna já existe: " + pColID` |
| duplicate `AddRow` | `"Linha já existe: " + pRowID` |

**Null / no-op**

| Situation | Result |
|---|---|
| `GetRowIndex` / `GetColIndex` miss | `-1` |
| ID-based `GetValue` miss | `Null` |
| ID-based `SetValue` miss | no-op |
| `Delete*` missing ID or bad index | no-op |
| `Move*` missing ID or same index | no-op (version still bumps) |
| `Sort*` Null handler or count `<= 1` | no-op |
| `SetValue` same instance | no-op (no events, no Free) |
| empty cell | `Null` |

Index-based `GetValue` / `SetValue` / `Row` / `Col` are not range-checked in this module.

#### Overridable hooks (`TMatrix`)

Called only when `IsEventsEnabled()` is True, **before** the matching `On*` field (if assigned):

| Hook | Purpose |
|---|---|
| `BeforeAddRow` / `AfterAddRow` | row insert |
| `BeforeDeleteRow` / `AfterDeleteRow` | row delete |
| `BeforeAddCol` / `AfterAddCol` | column insert |
| `BeforeDeleteCol` / `AfterDeleteCol` | column delete |
| `BeforeChange` / `AfterChange` | cell replace |
| `BeforeClean` / `AfterClean` | `Clean*` and `Apply*Order` |
| `BeforeDispose` / `AfterDispose` | `Dispose` |

---

## Typed facade (`mod_ttmatrix`)

`TTMatrix` holds a private `TMatrix` and forwards structure/cell calls. Column type must inherit `TMatrixCol`; row type must inherit `TMatrixRow`. Cell type `TypeValue` is stored as-is when it inherits `TTObject`; otherwise each cell is a `TTMatrixItem<TypeValue>`.

### Delegates

```bas
Delegate Function TTMatrixRowFilterDel<TypeRow>(pRow As TypeRow, pIndex As Integer, pExtra As Variant) As Boolean
Delegate Function TTMatrixColFilterDel<TypeCol>(pCol As TypeCol, pIndex As Integer, pExtra As Variant) As Boolean
Delegate Function TTMatrixSortRowDel<TypeRow>(pRow As TypeRow, pIndex As Integer, pExtra As Variant) As String
Delegate Function TTMatrixSortColDel<TypeCol>(pCol As TypeCol, pIndex As Integer, pExtra As Variant) As String
Delegate Sub TTMatrixCellChangeDel<TypeValue>(pRowIndex As Integer, pColIndex As Integer, pOldValue As TypeValue, pNewValue As TypeValue)
Delegate Sub TTMatrixIdIndexDel(pID As String, pIndex As Integer)
Delegate Sub TTMatrixMoveDel(pID As String, pFromIndex As Integer, pToIndex As Integer)
Delegate Sub TTMatrixNotifyDel(pAny As Variant)
```

Notify delegates receive `Unassigned`. There are no overridable hooks on `TTMatrix` (events only).

### `TTMatrixItem<T>`

Compiled only when `T` does **not** inherit `TTObject`. Wraps a non-`TTObject` cell so the physical grid can store it.

| Member | In/Out | Notes |
|---|---|---|
| `ID As String` | out | read-only; `""` when constructed without an ID (`Trim` if non-empty) |
| `Value As T` | in/out | payload |

```bas
Sub New(pValue As T)
   ' ID = ""
End Sub

Sub New(pID As String, pValue As T)
   ' ID = Trim(pID) when pID <> "", else ""
End Sub

Sub New(pValue As TTMatrixItem<T>)
   ' Assign; no-op if pValue is not Assigned
End Sub

Sub Assign(pValue As TTMatrixItem<T>)
   ' copies ID and Value; no-op if pValue is not Assigned
End Sub

Overrides Function GetID() As String
   ' out: ID if <> "", else MyBase.GetID()
End Function
```

`Clone` is `New TTMatrixItem<T>(me)`. `Dispose`: `ID` unassigned; delegate `T` → `Value = Null`; `T` inheriting `TObject` → `Value.Free()`; else `Value = Unassigned`. The facade always `Wrap`s with `pID = ""`.

### `TTMatrixCol<T>`

Typed column over `TMatrixCol`. `GetValue` / `SetValue` wrap and unwrap `T`.

```bas
Sub New(pID As String)

Function GetValue(pRowIndex As Integer) As T
Function GetValue(pRowID As String) As T
   ' missing row ID: Unwrap(Null) → Null if T inherits TTObject, else Unassigned

Sub SetValue(pRowID As String, pValue As T)
Sub SetValue(pRowIndex As Integer, pValue As T)
```

`Clone` copies `ID` only.

### `TTMatrixRow<T>`

Typed row over `TMatrixRow`.

```bas
Sub New(pID As String)

Function GetValue(pColIndex As Integer) As T
Function GetValue(pColID As String) As T
   ' pColID is a column ID (typed row does not reuse the physical GetValueFromID name)

Sub SetValue(pColID As String, pValue As T)
Sub SetValue(pColIndex As Integer, pValue As T)
```

### `TTMatrix<TypeCol As TMatrixCol, TypeRow As TMatrixRow, TypeValue>`

Typed grid. Default name `"TTMatrix"`. Does not expose `Name`, `OwnsObjects`, `DisableEvents`, or `StructureVersion` (those live on the inner `TMatrix`). `AddColumn` / `AddRow` require constructed `TypeCol` / `TypeRow` instances — there is no `AddColumn("NOME")` overload here.

| Member | In/Out | Notes |
|---|---|---|
| `RowCount` / `ColCount` | out | forwarded |
| `OnBeforeAddRow` … `OnAfterDeleteCol` | in | `TTMatrixIdIndexDel` (`pID`, `pIndex`) |
| `OnBeforeChange` / `OnAfterChange` | in | unwrapped `TypeValue`; Null/Disposed cells → `Unassigned` |
| `OnBeforeClean` / `OnAfterClean` | in | `TTMatrixNotifyDel` (`Unassigned`) |
| `OnBeforeDispose` / `OnAfterDispose` | in | `TTMatrixNotifyDel` (`Unassigned`) |
| `OnAfterMoveRow` / `OnAfterMoveCol` | in | `TTMatrixMoveDel`; **not** gated by `IsEventsEnabled` |
| `OnAfterEndUpdate` | in | `TTMatrixNotifyDel`; fires when `EndUpdate` leaves events enabled |

```bas
Sub New(pName As String = "TTMatrix", pOwnsObjects As Boolean = True, pDisableEvents As Boolean = False)
   ' constructs inner TMatrix and binds forwarders to its On* fields

Function IsEventsEnabled() As Boolean
Function GetRowIndex(pRowID As String) As Integer
Function GetColIndex(pColID As String) As Integer

Sub BeginUpdate()
Sub EndUpdate()
   ' then OnAfterEndUpdate(Unassigned) if events are enabled

Sub AddColumn(pCol As TypeCol)
Sub AddRow(pRow As TypeRow)

Function Col(pColID As String) As TypeCol
Function ColFromID(pColID As String) As TypeCol
Function Col(pIndex As Integer) As TypeCol
Function Row(pRowID As String) As TypeRow
Function RowFromID(pRowID As String) As TypeRow
Function Row(pIndex As Integer) As TypeRow

Sub DeleteCol(pIndex As Integer)
Sub DeleteColFromID(pColID As String)
Sub DeleteRow(pIndex As Integer)
Sub DeleteRowFromID(pRowID As String)

Sub MoveCol(pColID As String, pToIndex As Integer)
   ' OnAfterMoveCol only if the ID existed and the index changed
End Sub

Sub MoveRow(pRowID As String, pToIndex As Integer)
   ' OnAfterMoveRow only if the ID existed and the index changed
End Sub

Function GetValue(pRowIndex As Integer, pColIndex As Integer) As TypeValue
Function GetValueFromID(pRowID As String, pColID As String) As TypeValue
   ' missing ID → Unwrap(Null)

Function GetValueWithID(pRowIndex As Integer, pColID As String) As TypeValue
Function GetValueWithID(pRowID As String, pColIndex As Integer) As TypeValue
   ' missing ID → index -1, then unguarded GetValue (do not use for unknown IDs)

Sub SetValue(pRowIndex As Integer, pColIndex As Integer, pValue As TypeValue)
Sub SetValueFromID(pRowID As String, pColID As String, pValue As TypeValue)
   ' missing ID: no-op

Sub SetValueWithID(pRowIndex As Integer, pColID As String, pValue As TypeValue)
Sub SetValueWithID(pRowID As String, pColIndex As Integer, pValue As TypeValue)
   ' no-op if the ID side is missing (-1)

Sub SortRows(pHandler As TTMatrixSortRowDel<TypeRow>, pAsc As Boolean = True)
Sub SortRows(pHandler As TTMatrixSortRowDel<TypeRow>, pAsc As Boolean = True, pExtra As Variant)
   ' no-op if pHandler is Null or RowCount <= 1; then _base.ApplyRowOrder
End Sub

Sub SortCols(pHandler As TTMatrixSortColDel<TypeCol>, pAsc As Boolean = True)
Sub SortCols(pHandler As TTMatrixSortColDel<TypeCol>, pAsc As Boolean = True, pExtra As Variant)

Function FindRow(pHandler As TTMatrixRowFilterDel<TypeRow>, pExtra As Variant) As TypeRow
   ' first True; else Null. pHandler is not Null-checked
End Function

Function FilterRows(pHandler As TTMatrixRowFilterDel<TypeRow>, pExtra As Variant) As TTList<TypeRow>
   ' new list of live row references (same instances). Empty list if none match
End Function

Function FindCol(pHandler As TTMatrixColFilterDel<TypeCol>, pExtra As Variant) As TypeCol
   ' first True; else Null
End Function

Function FilterCols(pHandler As TTMatrixColFilterDel<TypeCol>, pExtra As Variant) As TTList<TypeCol>
   ' live column references
End Function

Sub Clean(pDispose As Boolean = True)
Sub CleanRows(pDispose As Boolean = True)
Sub CleanCols(pDispose As Boolean = True)

Overrides Sub Dispose()
   ' empty; does not dispose the inner TMatrix
End Sub

Sub Free(pDispose As Boolean = True)
   ' _base.Free(pDispose), unbind forwarders, MyBase.Free
End Sub
```

Filter example from tests (handler, not a string): `CBool(pRow.GetValue("ATIVO"))` keeps rows whose `"ATIVO"` cell is True. Column filter: `pCol.Width >= 150`. Sort key example: `saldo.ToString("000000000.00")` with `pAsc = False` for descending.

**Wrap / unwrap**

| `TypeValue` | Store | Empty `GetValue` | Change-event Null/Disposed |
|---|---|---|---|
| inherits `TTObject` | the object itself | `Null` | `Unassigned` |
| otherwise | `New TTMatrixItem<TypeValue>("", value)` | `Unassigned` | `Unassigned` |

Every typed `SetValue` builds a new wrapper when `TypeValue` is not a `TTObject`, so it is never “the same instance” as the previous cell — replace always Frees the old wrapper when `OwnsObjects` is True.

---

## Events, batches, and reorder

```text
1. IsEventsEnabled = (Not DisableEvents) And (BeginUpdate count = 0)
2. TMatrix Dispatch: overridable hook, then On* field if not Null
3. TTMatrix replaces inner On* with private forwarders; assign TTMatrix.On*, not the inner TMatrix
4. ApplyRowOrder / ApplyColOrder fire Clean events, not move events
5. TTMatrix.OnAfterMove* fire even when events are disabled, if the move actually happened
6. TTMatrix.EndUpdate fires OnAfterEndUpdate when, after decrement, events are enabled
   (an extra EndUpdate at count 0 still fires it)
```

`SortRows` / `SortCols` rebuild order through `Apply*Order`. There is no `SortByCol` / `SortByRow` in the current API.

---

## Extending (Consumer Project)

No UI in this module. No registration API.

Inherit `TTMatrixCol<T>` / `TTMatrixRow<T>` (or `TMatrixCol` / `TMatrixRow`) and put those types on `TTMatrix`:

```bas
Imports mod_tmatrix
Imports mod_ttmatrix

Class MyGridCol
   Inherits TTMatrixCol<Variant>
   Title As String
   Width As Integer
   Sub New(pID As String)
      MyBase.New(pID)
      me.Title = ""
      me.Width = 100
   End Sub
End Class

Class MyGridRow
   Inherits TTMatrixRow<Variant>
   IsSelected As Boolean
   Sub New(pID As String)
      MyBase.New(pID)
      me.IsSelected = False
   End Sub
End Class

Dim grid As New TTMatrix<MyGridCol, MyGridRow, Variant>("DB_Misto")
grid.AddColumn(New MyGridCol("NOME"))
grid.AddRow(New MyGridRow("CLI_1"))
```

To intercept structure changes without delegates, inherit `TMatrix` and override the hooks above. `TTMatrix` does not expose the inner `TMatrix` and has no protected hooks.

Cell type is the consumer’s: `Variant`, a `TTObject` subclass, or another `T`. `TMatrix.AddColumn("NOME")` always constructs a bare `TMatrixCol` — pass `New YourCol("NOME")` when you subclass.

---

## Module Notes

- `OwnsObjects = True` (default): replacing, deleting, `Clean*(True)`, and `Dispose` `Dispose`+`Free` cell objects. Row/col wrappers are always Freed by `TMatrix` even though the inner lists use `OwnsObjects = False`. Column `Cells` never own the pointers (`OwnsObjects = False`).
- `FilterRows` / `FilterCols` return a new `TTList` of **live** row/col instances still owned by the matrix. Do not `Free` that list unless you cloned the items; tests leave it un-Freed.
- IDs are `Trim`’d and compared case-insensitively. Duplicate `"NOME"` / `"nome"` throws. Missing ID: lookup `-1`, ID-based get `Null`/`Unassigned`, ID-based set/delete no-op. Index-based get/set/`Row`/`Col` are unguarded.
- `BeginUpdate`/`EndUpdate` nest. Hooks and `On*` (except `TTMatrix.OnAfterMove*` / `OnAfterEndUpdate` as noted) do not run inside a batch or when `DisableEvents` is True.
- In-memory only: nothing writes on `Close`; there is no file, schema, or catalog.
- `TMatrix.Clone` deep-copies cells when `OwnsObjects`, aliases them when not. `TTMatrix.Dispose` is a no-op; always `Free`. `TMatrix.Clean(True)` Disposes then clears `_disposed` so the same instance can be filled again.
- Canonical tests: `RunCompleteTestSuite()` in `src/Principal.bas` — Phase 1 `TMatrix` 50k insert, `MoveRow`/`MoveCol`, ID/index get, `DeleteRowFromID`; Phase 2 `TTMatrix` 50k, `SortRows` descending; Phase 3 `FilterRows` / `FilterCols`; Phase 4 delete by index/ID, invalid-index no-op, `CleanRows` / `CleanCols` / `Clean` and reinsert.
