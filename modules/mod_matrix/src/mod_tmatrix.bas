Imports Collections
Imports mod_tobject

Namespace mod_tmatrix

    Delegate Sub OnActionMatrixRowDel(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
    Delegate Sub OnActionMatrixColDel(pMatrix As TMatrix, pColID As String, pIndex As Integer)
    Delegate Sub OnActionMatrixCellDel(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOldValue As TTObject, pNewValue As TTObject)
    Delegate Sub OnActionMatrixBasicDel(pMatrix As TMatrix)
    Delegate Function TMatrixSortRowDel(pRow As TMatrixRow, pIndex As Integer, pExtra As Variant) As String
    Delegate Function TMatrixSortColDel(pCol As TMatrixCol, pIndex As Integer, pExtra As Variant) As String
    Class TMatrixCol
        Inherits TTObject

        ID As String
        Cells As StringList
        Private _matrix As TMatrix
        Private _cachedIndex As Integer
        Private _cachedVersion As Integer

        Sub New(pID As String)
            MyBase.New()
            me.ID = pID
            me.Cells = New StringList()
            me.Cells.OwnsObjects = False
            me._cachedIndex = -1
            me._cachedVersion = -1
        End Sub

        Sub BindMatrix(pMatrix As TMatrix)
            me._matrix = pMatrix
        End Sub

        Overrides Function GetID() As String
            GetID = me.ID
        End Function

        Property Index As Integer
            Get
                If me._cachedVersion <> me._matrix.StructureVersion Then
                    me._cachedIndex = me._matrix.GetColIndex(me.ID)
                    me._cachedVersion = me._matrix.StructureVersion
                End If
                Index = me._cachedIndex
            End Get
        End Property
        Property Matrix As TMatrix
            Get
                Matrix = me._matrix
            End Get
        End Property

        Function GetValue(pRowID As String) As TTObject
            Dim rIdx As Integer = me._matrix.GetRowIndex(pRowID)
            If rIdx <> -1 Then
                GetValue = me.GetValue(rIdx)
            Else
                GetValue = Null
            End If
        End Function

        Function GetValueFromID(pRowID As String) As TTObject
            GetValueFromID = me.GetValue(pRowID)
        End Function

        Function GetValue(pRowIndex As Integer) As TTObject
            GetValue = CType(me.Cells.Objects(pRowIndex), TTObject)
        End Function

        Sub SetValue(pRowIndex As Integer, pValue As TTObject)
            me._matrix.SetValue(pRowIndex, me.Index, pValue)
        End Sub

        Sub SetValue(pRowID As String, pValue As TTObject)
            Dim rIdx As Integer = me._matrix.GetRowIndex(pRowID)
            If rIdx <> -1 Then
                me.SetValue(rIdx, pValue)
            End If
        End Sub

        Sub SetValueFromID(pRowID As String, pValue As TTObject)
            me.SetValue(pRowID, pValue)
        End Sub

        Overrides Function Clone() As TTObject
            Dim newCol As New TMatrixCol(me.ID)
            Clone = newCol
        End Function

        Overrides Sub Dispose()
            If Assigned(me.Cells) Then
                me.Cells.Free()
            End If
        End Sub

        Overrides Function ToString() As String
            With me.BuildLogger(me.ClassName)
                .Prop("ID", me.ID)
                .Prop("Index", me.Index)
                ToString = .Text()
                .Free()
            End With
        End Function

        Sub Free()
            MyBase.Free()
        End Sub
    End Class

    Class TMatrixRow
        Inherits TTObject

        ID As String
        Private _matrix As TMatrix
        Private _cachedIndex As Integer
        Private _cachedVersion As Integer

        Sub New(pID As String)
            MyBase.New()
            me.ID = pID
            me._cachedIndex = -1
            me._cachedVersion = -1
        End Sub

        Sub BindMatrix(pMatrix As TMatrix)
            me._matrix = pMatrix
        End Sub

        Overrides Function GetID() As String
            GetID = me.ID
        End Function

        Property Index As Integer
            Get
                If me._cachedVersion <> me._matrix.StructureVersion Then
                    me._cachedIndex = me._matrix.GetRowIndex(me.ID)
                    me._cachedVersion = me._matrix.StructureVersion
                End If
                Index = me._cachedIndex
            End Get
        End Property

        Property Matrix As TMatrix
            Get
                Matrix = me._matrix
            End Get
        End Property

        Function GetValue(pColID As String) As TTObject
            Dim cIdx As Integer = me._matrix.GetColIndex(pColID)
            If cIdx <> -1 Then
                GetValue = me.GetValue(cIdx)
            Else
                GetValue = Null
            End If
        End Function

        Function GetValueFromID(pRowID As String) As TTObject
            GetValueFromID = me.GetValue(pRowID)
        End Function

        Function GetValue(pColIndex As Integer) As TTObject
            Dim rIdx As Integer = me.Index
            If rIdx <> -1 Then
                GetValue = me._matrix.GetValue(rIdx, pColIndex)
            Else
                GetValue = Null
            End If
        End Function

        Sub SetValue(pColIndex As Integer, pValue As TTObject)
            Dim rIdx As Integer = me.Index
            If rIdx <> -1 Then
                me._matrix.SetValue(rIdx, pColIndex, pValue)
            End If
        End Sub

        Sub SetValue(pColID As String, pValue As TTObject)
            Dim cIdx As Integer = me._matrix.GetColIndex(pColID)
            If cIdx <> -1 Then
                me.SetValue(cIdx, pValue)
            End If
        End Sub

        Sub SetValueFromID(pRowID As String, pValue As TTObject)
            me.SetValue(pRowID, pValue)
        End Sub

        Overrides Function Clone() As TTObject
            Dim newRow As New TMatrixRow(me.ID)
            Clone = newRow
        End Function

        Overrides Sub Dispose()
        End Sub

        Overrides Function ToString() As String
            With me.BuildLogger(me.ClassName)
                .Prop("ID", me.ID)
                .Prop("Index", me.Index)
                ToString = .Text()
                .Free()
            End With
        End Function

        Sub Free()
            MyBase.Free()
        End Sub
    End Class

    Class TMatrix
        Inherits TTObject

        Name As String
        DisableEvents As Boolean = False
        StructureVersion As Integer

        Private _rows As TTObjectList
        Private _cols As TTObjectList
        Private _ownsObjects As Boolean
        Private _disposed As Boolean
        Private _updateCount As Integer

        OnBeforeAddRow As OnActionMatrixRowDel
        OnAfterAddRow As OnActionMatrixRowDel
        OnBeforeDeleteRow As OnActionMatrixRowDel
        OnAfterDeleteRow As OnActionMatrixRowDel

        OnBeforeAddCol As OnActionMatrixColDel
        OnAfterAddCol As OnActionMatrixColDel
        OnBeforeDeleteCol As OnActionMatrixColDel
        OnAfterDeleteCol As OnActionMatrixColDel

        OnBeforeChange As OnActionMatrixCellDel
        OnAfterChange As OnActionMatrixCellDel

        OnBeforeClean As OnActionMatrixBasicDel
        OnAfterClean As OnActionMatrixBasicDel
        OnBeforeDispose As OnActionMatrixBasicDel
        OnAfterDispose As OnActionMatrixBasicDel

        Sub New(pName As String = "TMatrix", pOwnsObjects As Boolean = True, pDisableEvents As Boolean = False)
            MyBase.New()
            me.Name = pName
            me._ownsObjects = pOwnsObjects
            me.DisableEvents = pDisableEvents
            me._updateCount = 0

            me._rows = New TTObjectList(pName + "_Rows", False, True)
            me._cols = New TTObjectList(pName + "_Cols", False, True)
            me._disposed = False
        End Sub

        Sub BeginUpdate()
            me._updateCount = me._updateCount + 1
        End Sub

        Sub EndUpdate()
            If me._updateCount > 0 Then
                me._updateCount = me._updateCount - 1
            End If
        End Sub

        Function IsEventsEnabled() As Boolean
            IsEventsEnabled = (Not me.DisableEvents) And (me._updateCount = 0)
        End Function

        Property OwnsObjects As Boolean
            Get
                OwnsObjects = me._ownsObjects
            End Get
            Set(pValue As Boolean)
                me._ownsObjects = pValue
            End Set
        End Property

        Property RowCount As Integer
            Get
                RowCount = me._rows.Length()
            End Get
        End Property

        Property ColCount As Integer
            Get
                ColCount = me._cols.Length()
            End Get
        End Property

        Function GetRowIndex(pRowID As String) As Integer
            GetRowIndex = me._rows.IndexOf(pRowID)
        End Function

        Function GetColIndex(pColID As String) As Integer
            GetColIndex = me._cols.IndexOf(pColID)
        End Function

        Function RowFromID(pRowID As String) As TMatrixRow
            RowFromID = CType(me._rows.Take(pRowID), TMatrixRow)
        End Function

        Function Row(pRowID As String) As TMatrixRow
            Row = CType(me._rows.Take(pRowID), TMatrixRow)
        End Function

        Function Row(pIndex As Integer) As TMatrixRow
            Row = CType(me._rows.Take(pIndex), TMatrixRow)
        End Function

        Function ColFromID(pColID As String) As TMatrixCol
            ColFromID = CType(me._cols.Take(pColID), TMatrixCol)
        End Function

        Function Col(pColID As String) As TMatrixCol
            Col = CType(me._cols.Take(pColID), TMatrixCol)
        End Function

        Function Col(pIndex As Integer) As TMatrixCol
            Col = CType(me._cols.Take(pIndex), TMatrixCol)
        End Function

        Sub AddColumn(pID As String)
            me.AddColumn(pID, New TMatrixCol(pID))
        End Sub

        Sub AddColumn(pCol As TMatrixCol)
            me.AddColumn(pCol.ID, pCol)
        End Sub

        Sub AddColumn(pColID As String, pCol As TMatrixCol)
            me.StructureVersion += 1
            If me._cols.Includes(pColID) Then
                Throw New Exception("Coluna já existe: " + pColID)
            End If

            Dim newColIndex As Integer = me._cols.Length()
            If me.IsEventsEnabled() Then
                me.DispatchBeforeAddCol(me, pColID, newColIndex)
            End If

            Dim newCol As TMatrixCol = pCol
            newCol.BindMatrix(me)

            Dim i As Integer
            Dim count As Integer = me._rows.Length() - 1
            For i = 0 To count
                newCol.Cells.AddObject("", Null)
            Next

            me._cols.Push(pColID, newCol)

            If me.IsEventsEnabled() Then
                me.DispatchAfterAddCol(me, pColID, newColIndex)
            End If
        End Sub

        Sub DeleteColFromID(pColID As String)
            me.StructureVersion += 1
            Dim cIdx As Integer = me._cols.IndexOf(pColID)
            If cIdx = -1 Then
                Exit Sub
            End If

            If me.IsEventsEnabled() Then
                me.DispatchBeforeDeleteCol(me, pColID, cIdx)
            End If

            Dim colObj As TMatrixCol = me.Col(cIdx)

            If me._ownsObjects Then
                Dim r As Integer
                For r = 0 To me._rows.Length() - 1
                    Dim cellObj As TTObject = CType(colObj.Cells.Objects(r), TTObject)
                    If cellObj <> Null AndAlso Not cellObj.Disposed Then
                        cellObj.Dispose()
                        cellObj.Disposed = True
                        cellObj.Free()
                    End If
                Next
            End If

            me._cols.Delete(cIdx)
            If colObj <> Null Then
                colObj.Free()
            End If

            If me.IsEventsEnabled() Then
                me.DispatchAfterDeleteCol(me, pColID, cIdx)
            End If
        End Sub

        Sub DeleteCol(pIndex As Integer)
            If pIndex < 0 Or pIndex >= me._cols.Length() Then
                Exit Sub
            End If
            Dim colObj As TMatrixCol = me.Col(pIndex)
            If colObj = Null Then
                Exit Sub
            End If
            me.DeleteColFromID(colObj.ID)
        End Sub

        Sub MoveCol(pColID As String, pToIndex As Integer)
            me.StructureVersion += 1
            Dim fromIdx As Integer = me._cols.IndexOf(pColID)
            If fromIdx <> -1 And fromIdx <> pToIndex Then
                me._cols.Move(fromIdx, pToIndex)
            End If
        End Sub

        Sub AddRow(pID As String)
            me.AddRow(pID, New TMatrixRow(pID))
        End Sub

        Sub AddRow(pRow As TMatrixRow)
            me.AddRow(pRow.ID, pRow)
        End Sub

        Sub AddRow(pRowID As String, pRow As TMatrixRow)
            me.StructureVersion += 1
            If me._rows.Includes(pRowID) Then
                Throw New Exception("Linha já existe: " + pRowID)
            End If

            Dim newRowIndex As Integer = me._rows.Length()
            If me.IsEventsEnabled() Then
                me.DispatchBeforeAddRow(me, pRowID, newRowIndex)
            End If

            Dim newRow As TMatrixRow = pRow
            newRow.BindMatrix(me)

            Dim c As Integer
            Dim count As Integer = me._cols.Length() - 1
            For c = 0 To count
                Dim col As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                col.Cells.AddObject("", Null)
            Next

            me._rows.Push(pRowID, newRow)

            If me.IsEventsEnabled() Then
                me.DispatchAfterAddRow(me, pRowID, newRowIndex)
            End If
        End Sub

        Sub DeleteRowFromID(pRowID As String)
            me.StructureVersion += 1
            Dim rIdx As Integer = me._rows.IndexOf(pRowID)
            If rIdx = -1 Then
                Exit Sub
            End If

            If me.IsEventsEnabled() Then
                me.DispatchBeforeDeleteRow(me, pRowID, rIdx)
            End If

            Dim rowObj As TMatrixRow = me.Row(rIdx)
            me._rows.Delete(rIdx)

            Dim c As Integer
            For c = 0 To me._cols.Length() - 1
                Dim col As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                Dim cellObj As TTObject = CType(col.Cells.Objects(rIdx), TTObject)

                If me._ownsObjects And cellObj <> Null Then
                    If Not cellObj.Disposed Then
                        cellObj.Dispose()
                        cellObj.Disposed = True
                        cellObj.Free()
                    End If
                End If

                col.Cells.Delete(rIdx)
            Next

            If rowObj <> Null Then
                rowObj.Free()
            End If

            If me.IsEventsEnabled() Then
                me.DispatchAfterDeleteRow(me, pRowID, rIdx)
            End If
        End Sub

        Sub DeleteRow(pIndex As Integer)
            If pIndex < 0 Or pIndex >= me._rows.Length() Then
                Exit Sub
            End If
            Dim rowObj As TMatrixRow = me.Row(pIndex)
            If rowObj = Null Then
                Exit Sub
            End If
            me.DeleteRowFromID(rowObj.ID)
        End Sub

        Sub MoveRow(pRowID As String, pToIndex As Integer)
            me.StructureVersion += 1
            Dim fromIdx As Integer = me._rows.IndexOf(pRowID)
            If fromIdx = -1 Or fromIdx = pToIndex Then
                Exit Sub
            End If

            me._rows.Move(fromIdx, pToIndex)

            Dim c As Integer
            For c = 0 To me._cols.Length() - 1
                Dim col As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                col.Cells.Move(fromIdx, pToIndex)
            Next
        End Sub

        Function GetValue(pRowIndex As Integer, pColIndex As Integer) As TTObject
            Dim col As TMatrixCol = CType(me._cols.Take(pColIndex), TMatrixCol)
            GetValue = CType(col.Cells.Objects(pRowIndex), TTObject)
        End Function

        Function GetValue(pRowID As String, pColID As String) As TTObject
            Dim rIdx As Integer = me.GetRowIndex(pRowID)
            Dim cIdx As Integer = me.GetColIndex(pColID)
            If rIdx <> -1 And cIdx <> -1 Then
                GetValue = me.GetValue(rIdx, cIdx)
            Else
                GetValue = Null
            End If
        End Function

        Function GetValueFromID(pRowID As String, pColID As String) As TTObject
            GetValueFromID = me.GetValue(pRowID, pColID)
        End Function

        Sub SetValue(pRowIndex As Integer, pColIndex As Integer, pValue As TTObject)
            Dim col As TMatrixCol = CType(me._cols.Take(pColIndex), TMatrixCol)
            Dim oldObj As TTObject = CType(col.Cells.Objects(pRowIndex), TTObject)

            If oldObj <> pValue Then
                If me.IsEventsEnabled() Then
                    me.DispatchBeforeChange(me, pRowIndex, pColIndex, oldObj, pValue)
                End If

                If me._ownsObjects And oldObj <> Null Then
                    If Not oldObj.Disposed Then
                        oldObj.Dispose()
                        oldObj.Disposed = True
                        oldObj.Free()
                    End If
                End If

                col.Cells.Objects(pRowIndex) = pValue

                If me.IsEventsEnabled() Then
                    me.DispatchAfterChange(me, pRowIndex, pColIndex, oldObj, pValue)
                End If
            End If
        End Sub

        Sub SetValue(pRowID As String, pColID As String, pValue As TTObject)
            Dim rIdx As Integer = me.GetRowIndex(pRowID)
            Dim cIdx As Integer = me.GetColIndex(pColID)
            If rIdx <> -1 And cIdx <> -1 Then
                me.SetValue(rIdx, cIdx, pValue)
            End If
        End Sub

        Sub SetValueFromID(pRowID As String, pColID As String, pValue As TTObject)
            me.SetValue(pRowID, pColID, pValue)
        End Sub

        Sub ApplyRowOrder(pSortedList As StringList, pAsc As Boolean)
            If me.IsEventsEnabled() Then
                me.DispatchBeforeClean(me)
            End If

            Dim rCount As Integer = me.RowCount
            Dim cCount As Integer = me.ColCount
            Dim c As Integer
            Dim r As Integer

            ' 1. Reconstrói as células de todas as colunas fisicamente
            For c = 0 To cCount - 1
                Dim curCol As TMatrixCol = me.Col(c)
                Dim newCells As New StringList()
                newCells.OwnsObjects = False

                For r = 0 To rCount - 1
                    Dim actualIndex As Integer = r
                    If Not pAsc Then
                        actualIndex = rCount - 1 - r
                    End If

                    Dim rowObj As TMatrixRow = CType(pSortedList.Objects(actualIndex), TMatrixRow)
                    Dim oldRowIdx As Integer = me.GetRowIndex(rowObj.ID)
                    newCells.AddObject("", curCol.Cells.Objects(oldRowIdx))
                Next
                curCol.Cells.Free()
                curCol.Cells = newCells
            Next

            ' 2. Reconstrói a lista central de linhas
            Dim newRows As New TTObjectList(me.Name + "_Rows", False, True)
            For r = 0 To rCount - 1
                Dim actualIndex1 As Integer = r
                If Not pAsc Then
                    actualIndex1 = rCount - 1 - r
                End If
                Dim rowObj1 As TMatrixRow = CType(pSortedList.Objects(actualIndex1), TMatrixRow)
                newRows.Push(rowObj1.ID, rowObj1)
            Next

            Dim tempOwns As Boolean = me._rows.OwnsObjects
            me._rows.OwnsObjects = False
            me._rows.Clean(False)
            me._rows = newRows
            me._rows.OwnsObjects = tempOwns

            me.StructureVersion += 1
            If me.IsEventsEnabled() Then
                me.DispatchAfterClean(me)
            End If
        End Sub

        Sub ApplyColOrder(pSortedList As StringList, pAsc As Boolean)
            If me.IsEventsEnabled() Then
                me.DispatchBeforeClean(me)
            End If

            Dim cCount As Integer = me.ColCount
            Dim newCols As New TTObjectList(me.Name + "_Cols", False, True)
            Dim c As Integer

            ' Reconstrói apenas a lista de colunas (as células acompanham juntas)
            For c = 0 To cCount - 1
                Dim actualIndex As Integer = c
                If Not pAsc Then
                    actualIndex = cCount - 1 - c
                End If

                Dim colObj As TMatrixCol = CType(pSortedList.Objects(actualIndex), TMatrixCol)
                newCols.Push(colObj.ID, colObj)
            Next

            Dim tempOwns As Boolean = me._cols.OwnsObjects
            me._cols.OwnsObjects = False
            me._cols.Clean(False)
            me._cols = newCols
            me._cols.OwnsObjects = tempOwns

            me.StructureVersion += 1
            If me.IsEventsEnabled() Then
                me.DispatchAfterClean(me)
            End If
        End Sub

        Sub SortRows(pHandler As TMatrixSortRowDel, pAsc As Boolean = True)
            me.SortRows(pHandler, pAsc, Unassigned)
        End Sub

        Sub SortRows(pHandler As TMatrixSortRowDel, pAsc As Boolean = True, pExtra As Variant)
            If pHandler = Null Or me.RowCount <= 1 Then
                Exit Sub
            End If

            Dim sortList As New StringList()
            Dim r As Integer
            For r = 0 To me.RowCount - 1
                Dim rowObj As TMatrixRow = me.Row(r)
                Dim sortKey As String = pHandler(rowObj, r, pExtra)
                sortList.AddObject(sortKey, rowObj)
            Next

            sortList.Sorted = True
            me.ApplyRowOrder(sortList, pAsc)
            sortList.Free()
        End Sub

        Sub SortCols(pHandler As TMatrixSortColDel, pAsc As Boolean = True)
            me.SortCols(pHandler, pAsc, Unassigned)
        End Sub

        Sub SortCols(pHandler As TMatrixSortColDel, pAsc As Boolean = True, pExtra As Variant)
            If pHandler = Null Or me.ColCount <= 1 Then
                Exit Sub
            End If

            Dim sortList As New StringList()
            Dim c As Integer
            For c = 0 To me.ColCount - 1
                Dim colObj As TMatrixCol = me.Col(c)
                Dim sortKey As String = pHandler(colObj, c, pExtra)
                sortList.AddObject(sortKey, colObj)
            Next

            sortList.Sorted = True
            me.ApplyColOrder(sortList, pAsc)
            sortList.Free()
        End Sub

        ' Sub SortByCol(pColID As String, pAsc As Boolean)
        '     Dim cIdx As Integer = me.GetColIndex(pColID)
        '     If cIdx = -1 Or me.RowCount <= 1 Then
        '         Exit Sub
        '     End If

        '     If me.IsEventsEnabled() Then
        '         me.DispatchBeforeClean(me)
        '     End If

        '     Dim sortList As New StringList()
        '     Dim r As Integer
        '     Dim rCount As Integer = me.RowCount
        '     Dim colObj As TMatrixCol = me.Col(cIdx)

        '     ' 1. Cria lista espelhando o valor da célula e o Objeto da Linha
        '     For r = 0 To rCount - 1
        '         Dim cellObj As TTObject = CType(colObj.Cells.Objects(r), TTObject)
        '         Dim sortKey As String = ""
        '         If cellObj <> Null Then
        '             sortKey = cellObj.ToString()
        '         End If

        '         Dim rowObj As TMatrixRow = me.Row(r)
        '         sortList.AddObject(sortKey, rowObj)
        '     Next

        '     ' 2. Ordenação C++ Nativa
        '     sortList.Sorted = True

        '     ' 3. Reconstrói fisicamente as células de todas as colunas
        '     Dim c As Integer
        '     Dim cCount As Integer = me.ColCount
        '     For c = 0 To cCount - 1
        '         Dim curCol As TMatrixCol = me.Col(c)
        '         Dim newCells As New StringList()
        '         newCells.OwnsObjects = False

        '         For r = 0 To rCount - 1
        '             Dim actualIndex1 As Integer = r
        '             If Not pAsc Then
        '                 actualIndex1 = rCount - 1 - r
        '             End If

        '             Dim rowObj1 As TMatrixRow = CType(sortList.Objects(actualIndex1), TMatrixRow)
        '             Dim oldRowIdx As Integer = me.GetRowIndex(rowObj1.ID)
        '             newCells.AddObject("", curCol.Cells.Objects(oldRowIdx))
        '         Next

        '         curCol.Cells.Free()
        '         curCol.Cells = newCells
        '     Next

        '     ' 4. Reconstrói a lista principal de linhas
        '     Dim newRows As New TTObjectList(me.Name + "_Rows", False, True)
        '     For r = 0 To rCount - 1
        '         Dim actualIndex As Integer = r
        '         If Not pAsc Then
        '             actualIndex = rCount - 1 - r
        '         End If
        '         Dim rowObj2 As TMatrixRow = CType(sortList.Objects(actualIndex), TMatrixRow)
        '         newRows.Push(rowObj2.ID, rowObj2)
        '     Next

        '     Dim tempOwns As Boolean = me._rows.OwnsObjects
        '     me._rows.OwnsObjects = False
        '     me._rows.Free(False)
        '     me._rows = newRows
        '     me._rows.OwnsObjects = tempOwns

        '     sortList.Free()
        '     me.StructureVersion += 1

        '     If me.IsEventsEnabled() Then
        '         me.DispatchAfterClean(me)
        '     End If
        ' End Sub

        ' Sub SortByRow(pRowID As String, pAsc As Boolean)
        '     Dim rIdx As Integer = me.GetRowIndex(pRowID)
        '     If rIdx = -1 Or me.ColCount <= 1 Then
        '         Exit Sub
        '     End If

        '     If me.IsEventsEnabled() Then
        '         me.DispatchBeforeClean(me)
        '     End If

        '     Dim sortList As New StringList()
        '     Dim c As Integer
        '     Dim cCount As Integer = me.ColCount

        '     ' 1. Cria lista espelhando o valor e o Objeto da Coluna
        '     For c = 0 To cCount - 1
        '         Dim colObj1 As TMatrixCol = me.Col(c)
        '         Dim cellObj As TTObject = CType(colObj1.Cells.Objects(rIdx), TTObject)
        '         Dim sortKey As String = ""
        '         If cellObj <> Null Then
        '             sortKey = cellObj.ToString()
        '         End If

        '         sortList.AddObject(sortKey, colObj1)
        '     Next

        '     ' 2. Ordenação C++ Nativa
        '     sortList.Sorted = True

        '     ' 3. Reconstrói apenas a lista de colunas (os dados acompanham fisicamente!)
        '     Dim newCols As New TTObjectList(me.Name + "_Cols", False, True)
        '     For c = 0 To cCount - 1
        '         Dim actualIndex As Integer = c
        '         If Not pAsc Then
        '             actualIndex = cCount - 1 - c
        '         End If

        '         Dim colObj As TMatrixCol = CType(sortList.Objects(actualIndex), TMatrixCol)
        '         newCols.Push(colObj.ID, colObj)
        '     Next

        '     Dim tempOwns As Boolean = me._cols.OwnsObjects
        '     me._cols.OwnsObjects = False
        '     me._cols.Free(False)
        '     me._cols = newCols
        '     me._cols.OwnsObjects = tempOwns

        '     sortList.Free()
        '     me.StructureVersion += 1

        '     If me.IsEventsEnabled() Then
        '         me.DispatchAfterClean(me)
        '     End If
        ' End Sub

        Overrides Function Clone() As TTObject
            Dim _newMat As New TMatrix(me.Name + "_Clone", me.OwnsObjects, me.DisableEvents)

            Dim c As Integer
            For c = 0 To me._cols.Length() - 1
                Dim col As TMatrixCol = CType(me._cols.Take(c).Clone(), TMatrixCol)
                _newMat.AddColumn(col.ID, col)
            Next

            Dim r As Integer
            For r = 0 To me._rows.Length() - 1
                Dim row As TMatrixRow = CType(me._rows.Take(r).Clone(), TMatrixRow)
                _newMat.AddRow(row.ID, row)

                For c = 0 To me._cols.Length() - 1
                    Dim oldVal As TTObject = me.GetValue(r, c)
                    If oldVal <> Null Then
                        If me.OwnsObjects Then
                            _newMat.SetValue(r, c, CType(oldVal.Clone(), TTObject))
                        Else
                            _newMat.SetValue(r, c, oldVal)
                        End If
                    End If
                Next
            Next

            Clone = _newMat
        End Function

        Overrides Function ToString() As String
            With New TTObjectPrinter(me.Name)
                .Prop("OwnsObjects: " + me.OwnsObjects.ToString())
                .Prop("DisableEvents: " + me.DisableEvents.ToString())
                .Prop("ColCount", me.ColCount)
                .Prop("RowCount", me.RowCount)
                .Prop("CellCount", me.ColCount * me.RowCount)
                .Prop("Columns", me._cols.ToString())
                .Prop("Rows", me._rows.ToString())
                .Close()
                ToString = .Text
                .Free()
            End With
        End Function

        Overrides Sub Dispose()
            If Not me._disposed Then
                If me.IsEventsEnabled() Then
                    me.DispatchBeforeDispose(me)
                End If

                If me._ownsObjects Then
                    Dim c As Integer
                    Dim r As Integer
                    For c = 0 To me._cols.Length() - 1
                        Dim col As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                        For r = 0 To me._rows.Length() - 1
                            Dim cellObj As TTObject = CType(col.Cells.Objects(r), TTObject)
                            If cellObj <> Null AndAlso Not cellObj.Disposed Then
                                cellObj.Dispose()
                                cellObj.Disposed = True
                                cellObj.Free()
                            End If
                        Next
                    Next
                End If

                me._disposed = True
                If me.IsEventsEnabled() Then
                    me.DispatchAfterDispose(me)
                End If
            End If
        End Sub

        Private Sub DisposeOwnedCells()
            If Not me._ownsObjects Then
                Exit Sub
            End If
            Dim c As Integer
            Dim r As Integer
            For c = 0 To me._cols.Length() - 1
                Dim col As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                If col <> Null Then
                    For r = 0 To me._rows.Length() - 1
                        Dim cellObj As TTObject = CType(col.Cells.Objects(r), TTObject)
                        If cellObj <> Null AndAlso Not cellObj.Disposed Then
                            cellObj.Dispose()
                            cellObj.Disposed = True
                            cellObj.Free()
                        End If
                    Next
                End If
            Next
        End Sub

        Sub CleanRows(pDispose As Boolean = True)
            me.StructureVersion += 1
            If me.IsEventsEnabled() Then
                me.DispatchBeforeClean(me)
            End If

            If pDispose Then
                me.DisposeOwnedCells()
            End If

            Dim c As Integer
            For c = 0 To me._cols.Length() - 1
                Dim colObj As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                If colObj <> Null Then
                    colObj.Cells.Clear()
                End If
            Next

            Dim r As Integer
            For r = 0 To me._rows.Length() - 1
                Dim rowObj As TMatrixRow = CType(me._rows.Take(r), TMatrixRow)
                If rowObj <> Null Then
                    rowObj.Free()
                End If
            Next
            me._rows.Clean(False)

            If me.IsEventsEnabled() Then
                me.DispatchAfterClean(me)
            End If
        End Sub

        Sub CleanCols(pDispose As Boolean = True)
            me.StructureVersion += 1
            If me.IsEventsEnabled() Then
                me.DispatchBeforeClean(me)
            End If

            If pDispose Then
                me.DisposeOwnedCells()
            End If

            Dim c As Integer
            For c = 0 To me._cols.Length() - 1
                Dim colObj As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                If colObj <> Null Then
                    colObj.Cells.Clear()
                    colObj.Free()
                End If
            Next
            me._cols.Clean(False)

            If me.IsEventsEnabled() Then
                me.DispatchAfterClean(me)
            End If
        End Sub

        Sub Clean(pDispose As Boolean = True)
            If me.IsEventsEnabled() Then
                me.DispatchBeforeClean(me)
            End If

            If pDispose Then
                me.Dispose()
                me._disposed = False
            End If

            Dim c As Integer
            For c = 0 To me._cols.Length() - 1
                Dim colObj As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                If colObj <> Null Then
                    colObj.Cells.Clear()
                    colObj.Free()
                End If
            Next

            Dim r As Integer
            For r = 0 To me._rows.Length() - 1
                Dim rowObj As TMatrixRow = CType(me._rows.Take(r), TMatrixRow)
                If rowObj <> Null Then
                    rowObj.Free()
                End If
            Next

            me._cols.Clean(False)
            me._rows.Clean(False)

            If me.IsEventsEnabled() Then
                me.DispatchAfterClean(me)
            End If
        End Sub

        Sub Free(pDispose As Boolean = True)
            If pDispose Then
                me.Dispose()
            End If

            If Assigned(me._rows) Then
                Dim r As Integer
                For r = 0 To me._rows.Length() - 1
                    Dim rowObj As TMatrixRow = CType(me._rows.Take(r), TMatrixRow)
                    If rowObj <> Null Then
                        rowObj.Free()
                    End If
                Next
                me._rows.Free()
            End If

            If Assigned(me._cols) Then
                Dim c As Integer
                For c = 0 To me._cols.Length() - 1
                    Dim colObj As TMatrixCol = CType(me._cols.Take(c), TMatrixCol)
                    If colObj <> Null Then
                        colObj.Free()
                    End If
                Next
                me._cols.Free()
            End If

            MyBase.Free()
        End Sub

        Private Sub DispatchBeforeAddRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            me.BeforeAddRow(pMatrix, pRowID, pIndex)
            If me.OnBeforeAddRow <> Null Then
                me.OnBeforeAddRow(pMatrix, pRowID, pIndex)
            End If
        End Sub
        Protected Overridable Sub BeforeAddRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchAfterAddRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            me.AfterAddRow(pMatrix, pRowID, pIndex)
            If me.OnAfterAddRow <> Null Then
                me.OnAfterAddRow(pMatrix, pRowID, pIndex)
            End If
        End Sub
        Protected Overridable Sub AfterAddRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchBeforeDeleteRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            me.BeforeDeleteRow(pMatrix, pRowID, pIndex)
            If me.OnBeforeDeleteRow <> Null Then
                me.OnBeforeDeleteRow(pMatrix, pRowID, pIndex)
            End If
        End Sub
        Protected Overridable Sub BeforeDeleteRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchAfterDeleteRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            me.AfterDeleteRow(pMatrix, pRowID, pIndex)
            If me.OnAfterDeleteRow <> Null Then
                me.OnAfterDeleteRow(pMatrix, pRowID, pIndex)
            End If
        End Sub
        Protected Overridable Sub AfterDeleteRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchBeforeAddCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            me.BeforeAddCol(pMatrix, pColID, pIndex)
            If me.OnBeforeAddCol <> Null Then
                me.OnBeforeAddCol(pMatrix, pColID, pIndex)
            End If
        End Sub
        Protected Overridable Sub BeforeAddCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchAfterAddCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            me.AfterAddCol(pMatrix, pColID, pIndex)
            If me.OnAfterAddCol <> Null Then
                me.OnAfterAddCol(pMatrix, pColID, pIndex)
            End If
        End Sub
        Protected Overridable Sub AfterAddCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchBeforeDeleteCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            me.BeforeDeleteCol(pMatrix, pColID, pIndex)
            If me.OnBeforeDeleteCol <> Null Then
                me.OnBeforeDeleteCol(pMatrix, pColID, pIndex)
            End If
        End Sub
        Protected Overridable Sub BeforeDeleteCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchAfterDeleteCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            me.AfterDeleteCol(pMatrix, pColID, pIndex)
            If me.OnAfterDeleteCol <> Null Then
                me.OnAfterDeleteCol(pMatrix, pColID, pIndex)
            End If
        End Sub
        Protected Overridable Sub AfterDeleteCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
        End Sub

        Private Sub DispatchBeforeChange(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOld As TTObject, pNew As TTObject)
            me.BeforeChange(pMatrix, pRowIndex, pColIndex, pOld, pNew)
            If me.OnBeforeChange <> Null Then
                me.OnBeforeChange(pMatrix, pRowIndex, pColIndex, pOld, pNew)
            End If
        End Sub
        Protected Overridable Sub BeforeChange(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOld As TTObject, pNew As TTObject)
        End Sub

        Private Sub DispatchAfterChange(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOld As TTObject, pNew As TTObject)
            me.AfterChange(pMatrix, pRowIndex, pColIndex, pOld, pNew)
            If me.OnAfterChange <> Null Then
                me.OnAfterChange(pMatrix, pRowIndex, pColIndex, pOld, pNew)
            End If
        End Sub
        Protected Overridable Sub AfterChange(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOld As TTObject, pNew As TTObject)
        End Sub

        Private Sub DispatchBeforeClean(pMatrix As TMatrix)
            me.BeforeClean(pMatrix)
            If me.OnBeforeClean <> Null Then
                me.OnBeforeClean(pMatrix)
            End If
        End Sub
        Protected Overridable Sub BeforeClean(pMatrix As TMatrix)
        End Sub

        Private Sub DispatchAfterClean(pMatrix As TMatrix)
            me.AfterClean(pMatrix)
            If me.OnAfterClean <> Null Then
                me.OnAfterClean(pMatrix)
            End If
        End Sub
        Protected Overridable Sub AfterClean(pMatrix As TMatrix)
        End Sub

        Private Sub DispatchBeforeDispose(pMatrix As TMatrix)
            me.BeforeDispose(pMatrix)
            If me.OnBeforeDispose <> Null Then
                me.OnBeforeDispose(pMatrix)
            End If
        End Sub
        Protected Overridable Sub BeforeDispose(pMatrix As TMatrix)
        End Sub

        Private Sub DispatchAfterDispose(pMatrix As TMatrix)
            me.AfterDispose(pMatrix)
            If me.OnAfterDispose <> Null Then
                me.OnAfterDispose(pMatrix)
            End If
        End Sub
        Protected Overridable Sub AfterDispose(pMatrix As TMatrix)
        End Sub

    End Class
End Namespace