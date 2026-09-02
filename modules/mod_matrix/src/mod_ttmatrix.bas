
Imports mod_tobject
Imports mod_tmatrix
Imports Collections

Namespace mod_ttmatrix

    Delegate Function TTMatrixRowFilterDel<TypeRow>(pRow As TypeRow, pIndex As Integer, pExtra As Variant) As Boolean
    Delegate Function TTMatrixColFilterDel<TypeCol>(pCol As TypeCol, pIndex As Integer, pExtra As Variant) As Boolean
    Delegate Function TTMatrixSortRowDel<TypeRow>(pRow As TypeRow, pIndex As Integer, pExtra As Variant) As String
    Delegate Function TTMatrixSortColDel<TypeCol>(pCol As TypeCol, pIndex As Integer, pExtra As Variant) As String
    Delegate Sub TTMatrixCellChangeDel<TypeValue>(pRowIndex As Integer, pColIndex As Integer, pOldValue As TypeValue, pNewValue As TypeValue)
    Delegate Sub TTMatrixIdIndexDel(pID As String, pIndex As Integer)
    Delegate Sub TTMatrixMoveDel(pID As String, pFromIndex As Integer, pToIndex As Integer)
    Delegate Sub TTMatrixNotifyDel(pAny As Variant)
    <# If Not TypeSystem.InheritsFrom(T, "TTObject") Then #>
    Class TTMatrixItem<T>
        Inherits TTObject

        Private _id As String
        Value As T

        Property ID As String
            Get
                ID = me._id
            End Get
        End Property

        Sub New(pValue As T)
            MyBase.New()
            me._init("", pValue)
        End Sub

        Sub New(pID As String, pValue As T)
            MyBase.New()
            me._init(pID, pValue)
        End Sub

        Sub New(pValue As TTMatrixItem<T>)
            MyBase.New()
            me.Assign(pValue)
        End Sub

        Private Sub _init(pID As String, pValue As T)
            If pID <> "" Then
                me._id = pID.Trim()
            Else
                me._id = ""
            End If
            me.Value = pValue
        End Sub

        Sub Assign(pValue As TTMatrixItem<T>)
            If Assigned(pValue) Then
                me._id = pValue.ID
                me.Value = pValue.Value
            End If
        End Sub

        Overrides Function Clone() As TTMatrixItem<T>
            Clone = New TTMatrixItem<T>(me)
        End Function

        Overrides Function GetID() As String
            If me._id <> "" Then
                GetID = me._id
            Else
                GetID = MyBase.GetID()
            End If
        End Function

        Overrides Function ToString() As String
            With me.BuildLogger(me.Classname)
                .Prop("ID", me._id)
                <# If TypeSystem.IsDelegate(T) Then #>
                .Prop("Value IS NULL", me.Value = Null)
                Dim _type As String = "Delegate"
                .Prop("Type", _type)
                <# End If #>
                <# If TypeSystem.IsClass(T) Then #>
                .Prop("Value", me.Value.ToString())
                .Prop("Type", TypeName(me.Value))
                <# End If #>
                <# If TypeSystem.IsPrimitive(T) Then #>
                .Prop("Value", CStr(me.Value))
                .Prop("Type", TypeName(me.Value))
                <# End If #>
                ToString = .Text
            End With
        End Function

        Overrides Sub Dispose()
            me._id = Unassigned
            <# If TypeSystem.IsDelegate(T) Then #>
            me.Value = Null
            <# Else #>
            <# If TypeSystem.InheritsFrom(T, "TObject") Then #>
            If Assigned(me.Value) Then
                me.Value.Free()
                me.Value = Null
            End If
            <# Else #>
            me.Value = Unassigned
            <# End If #>
            <# End If #>
        End Sub

        Sub Free()
            MyBase.Free()
        End Sub

    End Class
    <# End If #>

    Class TTMatrixCol<T>
        Inherits TMatrixCol

        Sub New(pID As String)
            MyBase.New(pID)
        End Sub

        Private Function Wrap(pID As String, pValue As T) As TTObject
            <# If TypeSystem.InheritsFrom(T, "TTObject") Then #>
            Wrap = pValue
            <# Else #>
            Wrap = New TTMatrixItem<T>(pID, pValue)
            <# End If #>
        End Function

        Private Function Unwrap(pObj As TTObject) As T
            <# If TypeSystem.InheritsFrom(T, "TTObject") Then #>
            Unwrap = T(pObj)
            <# Else #>
            If pObj = Null Then
                Unwrap = Unassigned
            Else
                Unwrap = TTMatrixItem<T>(pObj).Value
            End If
            <# End If #>
        End Function

        Function GetValue(pRowIndex As Integer) As T
            GetValue = me.Unwrap(MyBase.GetValue(pRowIndex))
        End Function

        Function GetValue(pRowID As String) As T
            GetValue = me.Unwrap(MyBase.GetValueFromID(pRowID))
        End Function

        Sub SetValue(pRowID As String, pValue As T)
            MyBase.SetValue(pRowID, me.Wrap("", pValue))
        End Sub

        Sub SetValue(pRowIndex As Integer, pValue As T)
            MyBase.SetValue(pRowIndex, me.Wrap("", pValue))
        End Sub

        Overrides Function Clone() As TTObject
            Dim newCol As New TTMatrixCol<T>(me.ID)
            Clone = newCol
        End Function

        Overrides Sub Dispose()
            MyBase.Dispose()
        End Sub

        Sub Free()
            MyBase.Free()
        End Sub

    End Class

    Class TTMatrixRow<T>
        Inherits TMatrixRow

        Sub New(pID As String)
            MyBase.New(pID)
        End Sub

        Private Function Wrap(pID As String, pValue As T) As TTObject
            <# If TypeSystem.InheritsFrom(T, "TTObject") Then #>
            Wrap = pValue
            <# Else #>
            Wrap = New TTMatrixItem<T>(pID, pValue)
            <# End If #>
        End Function

        Private Function Unwrap(pObj As TTObject) As T
            <# If TypeSystem.InheritsFrom(T, "TTObject") Then #>
            Unwrap = T(pObj)
            <# Else #>
            If pObj = Null Then
                Unwrap = Unassigned
            Else
                Unwrap = TTMatrixItem<T>(pObj).Value
            End If
            <# End If #>
        End Function

        Function GetValue(pColIndex As Integer) As T
            GetValue = me.Unwrap(MyBase.GetValue(pColIndex))
        End Function

        Function GetValue(pColID As String) As T
            GetValue = me.Unwrap(MyBase.GetValueFromID(pColID))
        End Function

        Sub SetValue(pColID As String, pValue As T)
            MyBase.SetValue(pColID, me.Wrap("", pValue))
        End Sub

        Sub SetValue(pColIndex As Integer, pValue As T)
            MyBase.SetValue(pColIndex, me.Wrap("", pValue))
        End Sub

        Overrides Function Clone() As TTObject
            Dim newRow As New TTMatrixRow<T>(me.ID)
            Clone = newRow
        End Function

        Overrides Sub Dispose()
            MyBase.Dispose()
        End Sub

        Sub Free()
            MyBase.Free()
        End Sub

    End Class

    Class TTMatrix<TypeCol As TMatrixCol, TypeRow As TMatrixRow, TypeValue>
        Inherits TTObject

        Private _base As TMatrix

        OnBeforeAddRow As TTMatrixIdIndexDel
        OnAfterAddRow As TTMatrixIdIndexDel
        OnBeforeDeleteRow As TTMatrixIdIndexDel
        OnAfterDeleteRow As TTMatrixIdIndexDel

        OnBeforeAddCol As TTMatrixIdIndexDel
        OnAfterAddCol As TTMatrixIdIndexDel
        OnBeforeDeleteCol As TTMatrixIdIndexDel
        OnAfterDeleteCol As TTMatrixIdIndexDel

        OnBeforeChange As TTMatrixCellChangeDel<TypeValue>
        OnAfterChange As TTMatrixCellChangeDel<TypeValue>

        OnBeforeClean As TTMatrixNotifyDel
        OnAfterClean As TTMatrixNotifyDel
        OnBeforeDispose As TTMatrixNotifyDel
        OnAfterDispose As TTMatrixNotifyDel

        OnAfterMoveRow As TTMatrixMoveDel
        OnAfterMoveCol As TTMatrixMoveDel
        OnAfterEndUpdate As TTMatrixNotifyDel

        Sub New(pName As String = "TTMatrix", pOwnsObjects As Boolean = True, pDisableEvents As Boolean = False)
            MyBase.New()
            me._base = New TMatrix(pName, pOwnsObjects, pDisableEvents)
            me._bindBaseEvents()
        End Sub

        Private Sub _bindBaseEvents()
            me._base.OnBeforeAddRow = me._forwardBeforeAddRow
            me._base.OnAfterAddRow = me._forwardAfterAddRow
            me._base.OnBeforeDeleteRow = me._forwardBeforeDeleteRow
            me._base.OnAfterDeleteRow = me._forwardAfterDeleteRow
            me._base.OnBeforeAddCol = me._forwardBeforeAddCol
            me._base.OnAfterAddCol = me._forwardAfterAddCol
            me._base.OnBeforeDeleteCol = me._forwardBeforeDeleteCol
            me._base.OnAfterDeleteCol = me._forwardAfterDeleteCol
            me._base.OnBeforeChange = me._forwardBeforeChange
            me._base.OnAfterChange = me._forwardAfterChange
            me._base.OnBeforeClean = me._forwardBeforeClean
            me._base.OnAfterClean = me._forwardAfterClean
            me._base.OnBeforeDispose = me._forwardBeforeDispose
            me._base.OnAfterDispose = me._forwardAfterDispose
        End Sub

        Private Sub _unbindBaseEvents()
            If Not Assigned(me._base) Then
                Exit Sub
            End If
            me._base.OnBeforeAddRow = Null
            me._base.OnAfterAddRow = Null
            me._base.OnBeforeDeleteRow = Null
            me._base.OnAfterDeleteRow = Null
            me._base.OnBeforeAddCol = Null
            me._base.OnAfterAddCol = Null
            me._base.OnBeforeDeleteCol = Null
            me._base.OnAfterDeleteCol = Null
            me._base.OnBeforeChange = Null
            me._base.OnAfterChange = Null
            me._base.OnBeforeClean = Null
            me._base.OnAfterClean = Null
            me._base.OnBeforeDispose = Null
            me._base.OnAfterDispose = Null
        End Sub

        Private Function SafeUnwrap(pObj As TTObject) As TypeValue
            If pObj = Null Then
                SafeUnwrap = Unassigned
                Exit Function
            End If
            If pObj.Disposed Then
                SafeUnwrap = Unassigned
                Exit Function
            End If
            SafeUnwrap = me.Unwrap(pObj)
        End Function

        Private Sub _forwardBeforeAddRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            If me.OnBeforeAddRow <> Null Then
                me.OnBeforeAddRow(pRowID, pIndex)
            End If
        End Sub

        Private Sub _forwardAfterAddRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            If me.OnAfterAddRow <> Null Then
                me.OnAfterAddRow(pRowID, pIndex)
            End If
        End Sub

        Private Sub _forwardBeforeDeleteRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            If me.OnBeforeDeleteRow <> Null Then
                me.OnBeforeDeleteRow(pRowID, pIndex)
            End If
        End Sub

        Private Sub _forwardAfterDeleteRow(pMatrix As TMatrix, pRowID As String, pIndex As Integer)
            If me.OnAfterDeleteRow <> Null Then
                me.OnAfterDeleteRow(pRowID, pIndex)
            End If
        End Sub

        Private Sub _forwardBeforeAddCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            If me.OnBeforeAddCol <> Null Then
                me.OnBeforeAddCol(pColID, pIndex)
            End If
        End Sub

        Private Sub _forwardAfterAddCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            If me.OnAfterAddCol <> Null Then
                me.OnAfterAddCol(pColID, pIndex)
            End If
        End Sub

        Private Sub _forwardBeforeDeleteCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            If me.OnBeforeDeleteCol <> Null Then
                me.OnBeforeDeleteCol(pColID, pIndex)
            End If
        End Sub

        Private Sub _forwardAfterDeleteCol(pMatrix As TMatrix, pColID As String, pIndex As Integer)
            If me.OnAfterDeleteCol <> Null Then
                me.OnAfterDeleteCol(pColID, pIndex)
            End If
        End Sub

        Private Sub _forwardBeforeChange(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOldValue As TTObject, pNewValue As TTObject)
            If me.OnBeforeChange <> Null Then
                me.OnBeforeChange(pRowIndex, pColIndex, me.SafeUnwrap(pOldValue), me.SafeUnwrap(pNewValue))
            End If
        End Sub

        Private Sub _forwardAfterChange(pMatrix As TMatrix, pRowIndex As Integer, pColIndex As Integer, pOldValue As TTObject, pNewValue As TTObject)
            If me.OnAfterChange <> Null Then
                me.OnAfterChange(pRowIndex, pColIndex, me.SafeUnwrap(pOldValue), me.SafeUnwrap(pNewValue))
            End If
        End Sub

        Private Sub _forwardBeforeClean(pMatrix As TMatrix)
            If me.OnBeforeClean <> Null Then
                me.OnBeforeClean(Unassigned)
            End If
        End Sub

        Private Sub _forwardAfterClean(pMatrix As TMatrix)
            If me.OnAfterClean <> Null Then
                me.OnAfterClean(Unassigned)
            End If
        End Sub

        Private Sub _forwardBeforeDispose(pMatrix As TMatrix)
            If me.OnBeforeDispose <> Null Then
                me.OnBeforeDispose(Unassigned)
            End If
        End Sub

        Private Sub _forwardAfterDispose(pMatrix As TMatrix)
            If me.OnAfterDispose <> Null Then
                me.OnAfterDispose(Unassigned)
            End If
        End Sub

        Function IsEventsEnabled() As Boolean
            IsEventsEnabled = me._base.IsEventsEnabled()
        End Function

        Function GetRowIndex(pRowID As String) As Integer
            GetRowIndex = me._base.GetRowIndex(pRowID)
        End Function

        Function GetColIndex(pColID As String) As Integer
            GetColIndex = me._base.GetColIndex(pColID)
        End Function

        Private Function Wrap(pID As String, pValue As TypeValue) As TTObject
            <# If TypeSystem.InheritsFrom(TypeValue, "TTObject") Then #>
            ' data7:disable-next-line type-mismatch
            Wrap = pValue
            <# Else #>
            ' data7:disable-next-line type-mismatch
            Wrap = New TTMatrixItem<TypeValue>(pID, pValue)
            <# End If #>
        End Function

        Private Function Unwrap(pObj As TTObject) As TypeValue
            <# If TypeSystem.InheritsFrom(TypeValue, "TTObject") Then #>
            Unwrap = TypeValue(pObj)
            <# Else #>
            If pObj = Null Then
                Unwrap = Unassigned
            Else
                Unwrap = TTMatrixItem<TypeValue>(pObj).Value
            End If
            <# End If #>
        End Function

        Property RowCount As Integer
            Get
                RowCount = me._base.RowCount
            End Get
        End Property

        Property ColCount As Integer
            Get
                ColCount = me._base.ColCount
            End Get
        End Property

        Sub BeginUpdate()
            me._base.BeginUpdate()
        End Sub

        Sub EndUpdate()
            me._base.EndUpdate()
            If me._base.IsEventsEnabled() Then
                If me.OnAfterEndUpdate <> Null Then
                    me.OnAfterEndUpdate(Unassigned)
                End If
            End If
        End Sub

        Sub AddColumn(pCol As TypeCol)
            me._base.AddColumn(pCol)
        End Sub

        Sub AddRow(pRow As TypeRow)
            me._base.AddRow(pRow)
        End Sub

        Function ColFromID(pColID As String) As TypeCol
            ColFromID = TypeCol(me._base.ColFromID(pColID))
        End Function

        Function Col(pColID As String) As TypeCol
            Col = TypeCol(me._base.Col(pColID))
        End Function

        Function Col(pIndex As Integer) As TypeCol
            Col = TypeCol(me._base.Col(pIndex))
        End Function

        Function RowFromID(pRowID As String) As TypeRow
            RowFromID = TypeRow(me._base.RowFromID(pRowID))
        End Function

        Function Row(pRowID As String) As TypeRow
            Row = TypeRow(me._base.Row(pRowID))
        End Function

        Function Row(pIndex As Integer) As TypeRow
            Row = TypeRow(me._base.Row(pIndex))
        End Function

        Sub DeleteCol(pIndex As Integer)
            me._base.DeleteCol(pIndex)
        End Sub

        Sub DeleteColFromID(pColID As String)
            me._base.DeleteColFromID(pColID)
        End Sub


        Sub MoveCol(pColID As String, pToIndex As Integer)
            Dim fromIdx As Integer = me._base.GetColIndex(pColID)
            me._base.MoveCol(pColID, pToIndex)
            If fromIdx <> -1 And fromIdx <> pToIndex Then
                If me.OnAfterMoveCol <> Null Then
                    me.OnAfterMoveCol(pColID, fromIdx, pToIndex)
                End If
            End If
        End Sub

        Sub DeleteRow(pIndex As Integer)
            me._base.DeleteRow(pIndex)
        End Sub

        Sub DeleteRowFromID(pRowID As String)
            me._base.DeleteRowFromID(pRowID)
        End Sub

        Sub MoveRow(pRowID As String, pToIndex As Integer)
            Dim fromIdx As Integer = me._base.GetRowIndex(pRowID)
            me._base.MoveRow(pRowID, pToIndex)
            If fromIdx <> -1 And fromIdx <> pToIndex Then
                If me.OnAfterMoveRow <> Null Then
                    me.OnAfterMoveRow(pRowID, fromIdx, pToIndex)
                End If
            End If
        End Sub

        Function GetValue(pRowIndex As Integer, pColIndex As Integer) As TypeValue
            GetValue = me.Unwrap(me._base.GetValue(pRowIndex, pColIndex))
        End Function

        Function GetValueFromID(pRowID As String, pColID As String) As TypeValue
            GetValueFromID = me.Unwrap(me._base.GetValueFromID(pRowID, pColID))
        End Function

        Function GetValueWithID(pRowIndex As Integer, pColID As String) As TypeValue
            Dim cIdx As Integer = me._base.GetColIndex(pColID)
            GetValueWithID = me.GetValue(pRowIndex, cIdx)
        End Function

        Function GetValueWithID(pRowID As String, pColIndex As Integer) As TypeValue
            Dim rIdx As Integer = me._base.GetRowIndex(pRowID)
            GetValueWithID = me.GetValue(rIdx, pColIndex)
        End Function

        Sub SetValue(pRowIndex As Integer, pColIndex As Integer, pValue As TypeValue)
            me._base.SetValue(pRowIndex, pColIndex, me.Wrap("", pValue))
        End Sub

        Sub SetValueFromID(pRowID As String, pColID As String, pValue As TypeValue)
            me._base.SetValueFromID(pRowID, pColID, me.Wrap("", pValue))
        End Sub

        Sub SetValueWithID(pRowIndex As Integer, pColID As String, pValue As TypeValue)
            Dim cIdx As Integer = me._base.GetColIndex(pColID)
            If cIdx <> -1 Then
                me._base.SetValue(pRowIndex, cIdx, me.Wrap("", pValue))
            End If
        End Sub

        Sub SetValueWithID(pRowID As String, pColIndex As Integer, pValue As TypeValue)
            Dim rIdx As Integer = me._base.GetRowIndex(pRowID)
            If rIdx <> -1 Then
                me._base.SetValue(rIdx, pColIndex, me.Wrap("", pValue))
            End If
        End Sub

        ' Sub SortByCol(pColID As String, pAsc As Boolean)
        '     me._base.SortByCol(pColID, pAsc)
        ' End Sub

        ' Sub SortByRow(pRowID As String, pAsc As Boolean)
        '     me._base.SortByRow(pRowID, pAsc)
        ' End Sub

        Sub SortRows(pHandler As TTMatrixSortRowDel<TypeRow>, pAsc As Boolean = True)
            me.SortRows(pHandler, pAsc, Unassigned)
        End Sub

        Sub SortRows(pHandler As TTMatrixSortRowDel<TypeRow>, pAsc As Boolean = True, pExtra As Variant)
            If pHandler = Null Or me.RowCount <= 1 Then
                Exit Sub
            End If

            Dim sortList As New StringList()
            Dim r As Integer
            Dim rCount As Integer = me.RowCount

            For r = 0 To rCount - 1
                Dim rowObj As TypeRow = me.Row(r)

                Dim sortKey As String = pHandler(rowObj, r, pExtra)


                sortList.AddObject(sortKey, rowObj)
            Next

            sortList.Sorted = True
            me._base.ApplyRowOrder(sortList, pAsc)
            sortList.Free()
        End Sub

        Sub SortCols(pHandler As TTMatrixSortColDel<TypeCol>, pAsc As Boolean = True)
            me.SortCols(pHandler, pAsc, Unassigned)
        End Sub

        Sub SortCols(pHandler As TTMatrixSortColDel<TypeCol>, pAsc As Boolean = True, pExtra As Variant)
            If pHandler = Null Or me.ColCount <= 1 Then
                Exit Sub
            End If

            Dim sortList As New StringList()
            Dim c As Integer
            Dim cCount As Integer = me.ColCount

            For c = 0 To cCount - 1
                Dim colObj As TypeCol = me.Col(c)
                Dim sortKey As String = pHandler(colObj, c, pExtra)
                sortList.AddObject(sortKey, colObj)
            Next

            sortList.Sorted = True
            me._base.ApplyColOrder(sortList, pAsc)
            sortList.Free()
        End Sub

        Function FindRow(pHandler As TTMatrixRowFilterDel<TypeRow>, pExtra As Variant) As TypeRow
            Dim r As Integer
            Dim rCount As Integer = me.RowCount
            For r = 0 To rCount - 1
                Dim rowObj As TypeRow = me.Row(r)
                If pHandler(rowObj, r, pExtra) Then
                    FindRow = rowObj
                    Exit Function
                End If
            Next
            FindRow = Null
        End Function

        Function FilterRows(pHandler As TTMatrixRowFilterDel<TypeRow>, pExtra As Variant) As TTList<TypeRow>
            Dim result[] As TypeRow = []
            Dim r As Integer
            Dim rCount As Integer = me.RowCount
            For r = 0 To rCount - 1
                Dim rowObj As TypeRow = me.Row(r)
                If pHandler(rowObj, r, pExtra) Then
                    result.Push(rowObj.ID, rowObj)
                End If
            Next
            FilterRows = result
        End Function

        Function FindCol(pHandler As TTMatrixColFilterDel<TypeCol>, pExtra As Variant) As TypeCol
            Dim c As Integer
            Dim cCount As Integer = me.ColCount
            For c = 0 To cCount - 1
                Dim colObj As TypeCol = me.Col(c)
                If pHandler(colObj, c, pExtra) Then
                    FindCol = colObj
                    Exit Function
                End If
            Next
            FindCol = Null
        End Function

        Function FilterCols(pHandler As TTMatrixColFilterDel<TypeCol>, pExtra As Variant) As TTList<TypeCol>
            Dim result[] As TypeCol = []
            Dim c As Integer
            Dim cCount As Integer = me.ColCount
            For c = 0 To cCount - 1
                Dim colObj As TypeCol = me.Col(c)
                If pHandler(colObj, c, pExtra) Then
                    result.Push(colObj.ID, colObj)
                End If
            Next
            FilterCols = result
        End Function

        Overrides Function ToString() As String
            ToString = me._base.ToString()
        End Function

        Sub Clean(pDispose As Boolean = True)
            me._base.Clean(pDispose)
        End Sub

        Sub CleanRows(pDispose As Boolean = True)
            me._base.CleanRows(pDispose)
        End Sub

        Sub CleanCols(pDispose As Boolean = True)
            me._base.CleanCols(pDispose)
        End Sub

        Overrides Sub Dispose()
        End Sub

        Sub Free(pDispose As Boolean = True)
            If Assigned(me._base) Then
                me._base.Free(pDispose)
            End If
            me._unbindBaseEvents()
            MyBase.Free()
        End Sub

    End Class

End Namespace