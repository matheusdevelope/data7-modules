' data7:disable unreachable-declaration
Imports Forms
Imports mod_tlist
Imports mod_editors
Imports mod_register_config

Namespace mod_register_layout

   Class TRegisterFieldRow
      Items[] As TRegisterField

      Sub New()
         MyBase.New()
         me.Items = []
         me.Items.OwnsObjects = False
      End Sub

      Sub Free()
         If Assigned(me.Items) Then
            me.Items.OwnsObjects = False
            me.Items.Free()
            me.Items = Null
         End If
         MyBase.Free()
      End Sub
   End Class

   Class TRegisterLayout

      LabelWidth As Integer
      LabelSpacing As Integer
      FullRowChars As Integer
      CharWidth As Integer
      RowHeight As Integer
      Gutter As Integer
      MinFieldWidth As Integer
      LayoutWidth As Integer
      SearchWidth As Integer
      TabHeaderHeight As Integer
      ContentMargin As Integer

      Sub New(pConfig As TRegisterFormConfig)
         MyBase.New()
         me.LabelWidth = 110
         me.LabelSpacing = 5
         me.FullRowChars = 40
         me.CharWidth = 6
         me.RowHeight = 27
         me.Gutter = 8
         me.MinFieldWidth = 48
         me.LayoutWidth = 808
         me.SearchWidth = 366
         me.TabHeaderHeight = 26
         me.ContentMargin = 6
         If Assigned(pConfig) Then
            If pConfig.LabelWidth > 0 Then
               me.LabelWidth = pConfig.LabelWidth
            End If
            If pConfig.LabelSpacing > 0 Then
               me.LabelSpacing = pConfig.LabelSpacing
            End If
            If pConfig.FullRowChars > 0 Then
               me.FullRowChars = pConfig.FullRowChars
            End If
            If pConfig.CharWidth > 0 Then
               me.CharWidth = pConfig.CharWidth
            End If
            If pConfig.RowHeight > 0 Then
               me.RowHeight = pConfig.RowHeight
            End If
            If pConfig.Gutter > 0 Then
               me.Gutter = pConfig.Gutter
            End If
            If pConfig.LayoutWidth > 0 Then
               me.LayoutWidth = pConfig.LayoutWidth
            End If
            If pConfig.ContentMargin > 0 Then
               me.ContentMargin = pConfig.ContentMargin
            End If
         End If
      End Sub

      Function AvailableWidth(pParent As TWinControl) As Integer
         Dim hostW As Integer = me._resolvedWidth(pParent)
         Dim pad As Integer = me.ContentMargin * 2
         If hostW > pad Then
            hostW = hostW - pad
         End If
         If hostW < 100 Then
            hostW = 100
         End If
         AvailableWidth = hostW
      End Function

      Private Function _resolvedWidth(pParent As TWinControl) As Integer
         Dim node As TWinControl = pParent
         Dim inset As Integer = 0
         While Assigned(node)
            Dim w As Integer = node.ClientWidth
            If w <= 0 Then
               w = node.Width
            End If
            If w > inset Then
               _resolvedWidth = w - inset
               Exit Function
            End If
            If node.AlignWithMargins Then
               inset = inset + node.Margins.Left + node.Margins.Right
            End If
            node = node.Parent
         Wend
         Dim fallback As Integer = me.LayoutWidth
         If fallback > inset Then
            fallback = fallback - inset
         End If
         _resolvedWidth = fallback
      End Function

      Function OccupiesFullRow(pField As TRegisterField, pAvailable As Integer) As Boolean
         If pField.SpanRow Then
            OccupiesFullRow = True
            Exit Function
         End If
         Dim kind As String = UCase(pField.KindKey())
         If (kind = "MEMO") Or (kind = "TEXTO") Or (kind = "IMAGE") Or (kind = "IMAGEM") Or (kind = "FOTO") Then
            OccupiesFullRow = True
            Exit Function
         End If
         If pField.MaxLength >= 200 Then
            OccupiesFullRow = True
            Exit Function
         End If
         Dim half As Integer = me._half(pAvailable)
         If (pField.Width > 0) And (pField.Width > half) Then
            OccupiesFullRow = True
            Exit Function
         End If
         OccupiesFullRow = False
      End Function

      Function EditorWidth(pField As TRegisterField, pMax As Integer) As Integer
         Dim w As Integer
         If me._isSearch(pField) Then
            w = me.SearchWidth
         ElseIf pField.Width > 0 Then
            w = me._labelPart(pField) + pField.Width
         Else
            Dim inner As Integer = (me._charsOf(pField) * me.CharWidth) + me._kindExtra(pField)
            If inner < me.MinFieldWidth Then
               inner = me.MinFieldWidth
            End If
            w = me._labelPart(pField) + inner
         End If
         If (pMax > 0) And (w > pMax) Then
            w = pMax
         End If
         EditorWidth = w
      End Function

      Function Place(pParent As TWinControl, pFields As TTList<TRegisterField>, pCreate As TRegisterEditorCreate) As Integer
         Dim total As Integer = 0
         If (Not Assigned(pFields)) Or (pCreate = Null) Then
            Place = 0
            Exit Function
         End If
         Dim available As Integer = me.AvailableWidth(pParent)
         Dim packed[] As TRegisterFieldRow = []
         packed.OwnsObjects = True
         Dim pending As TRegisterField = Null
         Dim list As TTList<TRegisterField> = TRegisterFormConfig.SortFields(pFields)
         Dim i As Integer
         Dim n As Integer = list.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = list.Take(i)
            If me.OccupiesFullRow(field, available) Then
               If pending <> Null Then
                  packed.Push(me._rowOf(pending, Null))
                  pending = Null
               End If
               packed.Push(me._rowOf(field, Null))
            ElseIf pending <> Null Then
               packed.Push(me._rowOf(pending, field))
               pending = Null
            Else
               pending = field
            End If
         Next
         If pending <> Null Then
            packed.Push(me._rowOf(pending, Null))
         End If
         Dim r As Integer = packed.Length - 1
         While r >= 0
            Dim packItem As TRegisterFieldRow = packed.Take(r)
            total = total + me._flushRow(pParent, packItem.Items, available, pCreate)
            r = r - 1
         Wend
         packed.Free()
         If Assigned(list) Then
            list.OwnsObjects = False
            list.Free()
         End If
         Place = total
      End Function

      Private Function _half(pAvailable As Integer) As Integer
         _half = CInt(pAvailable / 2)
      End Function

      Private Function _labelPart(pField As TRegisterField) As Integer
         Dim lab As Integer = pField.LabelWidth
         If lab <= 0 Then
            lab = me.LabelWidth
         End If
         Dim gap As Integer = pField.LabelSpacing
         If gap <= 0 Then
            gap = me.LabelSpacing
         End If
         _labelPart = lab + gap
      End Function

      Private Function _isSearch(pField As TRegisterField) As Boolean
         Dim kind As String = UCase(pField.KindKey())
         _isSearch = CBool((kind = "SEARCH") Or (kind = "LOOKUP") Or (kind = "PESQUISA"))
      End Function

      Private Function _charsOf(pField As TRegisterField) As Integer
         Dim n As Integer = pField.MaxLength
         Dim kind As String = UCase(pField.KindKey())
         If (kind = "COMBO") Or (kind = "LISTA") Or (kind = "COMBOBOX") Then
            Dim opt As Integer = me._longestOption(pField.ListaOpcoes)
            If opt > n Then
               n = opt
            End If
         End If
         If n <= 0 Then
            If (kind = "DATE") Or (kind = "DATA") Or (kind = "DATETIME") Or (kind = "DATAHORA") Then
               n = 10
            ElseIf (kind = "COMBO") Or (kind = "LISTA") Or (kind = "COMBOBOX") Then
               n = 8
            Else
               n = 12
            End If
         End If
         _charsOf = n
      End Function

      Private Function _kindExtra(pField As TRegisterField) As Integer
         Dim kind As String = UCase(pField.KindKey())
         If (kind = "COMBO") Or (kind = "LISTA") Or (kind = "COMBOBOX") Then
            _kindExtra = 22
         ElseIf (kind = "DATE") Or (kind = "DATA") Or (kind = "DATETIME") Or (kind = "DATAHORA") Then
            _kindExtra = 24
         ElseIf (kind = "MASK") Or (kind = "MASCARA") Then
            _kindExtra = 10
         Else
            _kindExtra = 8
         End If
      End Function

      Private Function _longestOption(pLista As String) As Integer
         Dim best As Integer = 0
         Dim raw As String = Trim(pLista)
         If raw = "" Then
            _longestOption = 0
            Exit Function
         End If
         Dim startAt As Integer = 1
         Dim i As Integer
         Dim n As Integer = Len(raw)
         For i = 1 To n
            If Mid(raw, i, 1) = ";" Then
               Dim piece As String = Mid(raw, startAt, i - startAt)
               Dim pieceLen As Integer = me._captionLen(piece)
               If pieceLen > best Then
                  best = pieceLen
               End If
               startAt = i + 1
            End If
         Next
         Dim tail As String = Mid(raw, startAt, n - startAt + 1)
         Dim tailLen As Integer = me._captionLen(tail)
         If tailLen > best Then
            best = tailLen
         End If
         _longestOption = best
      End Function

      Private Function _captionLen(pItem As String) As Integer
         Dim s As String = Trim(pItem)
         s = s.Replace("""", "")
         s = s.Replace("'", "")
         s = Trim(s)
         Dim eq As Integer = InStr(s, "=")
         If eq > 0 Then
            s = Trim(Left(s, eq - 1))
         End If
         _captionLen = Len(s)
      End Function

      Private Function _rowOf(pLeft As TRegisterField, pRight As TRegisterField) As TRegisterFieldRow
         Dim pack As New TRegisterFieldRow()
         pack.Items.Push(pLeft)
         If pRight <> Null Then
            pack.Items.Push(pRight)
         End If
         _rowOf = pack
      End Function

      Private Sub _applyVisible(pEditor As TLabeledEditorBase, pField As TRegisterField)
         pEditor.Visible = pField.Visible
      End Sub

      Private Function _isMemo(pField As TRegisterField) As Boolean
         Dim kind As String = UCase(pField.KindKey())
         _isMemo = CBool((kind = "MEMO") Or (kind = "TEXTO"))
      End Function

      Private Function _isImage(pField As TRegisterField) As Boolean
         Dim kind As String = UCase(pField.KindKey())
         _isImage = CBool((kind = "IMAGE") Or (kind = "IMAGEM") Or (kind = "FOTO"))
      End Function

      Private Function _rowHeightFor(pFields As TTList<TRegisterField>) As Integer
         Dim h As Integer = me.RowHeight
         Dim i As Integer
         Dim n As Integer = pFields.Length - 1
         For i = 0 To n
            Dim field As TRegisterField = pFields.Take(i)
            Dim fieldH As Integer = field.Height
            If fieldH <= 0 Then
               If me._isMemo(field) Then
                  fieldH = 70
               ElseIf me._isImage(field) Then
                  fieldH = 400
               End If
            End If
            If fieldH > h Then
               h = fieldH
            End If
         Next
         _rowHeightFor = h
      End Function

      Private Function _flushRow(pParent As TWinControl, pFields As TTList<TRegisterField>, pAvailable As Integer, pCreate As TRegisterEditorCreate) As Integer
         If pFields.Length <= 0 Then
            _flushRow = 0
            Exit Function
         End If
         Dim row As PageControl = New PageControl(pParent)
         row.Align = alTop
         row.ShowCardFrame = False
         row.ShowShadow = False
         row.TabStop = False
         If me.ContentMargin > 0 Then
            row.AlignWithMargins = True
            row.Margins.Left = me.ContentMargin
            row.Margins.Right = me.ContentMargin
            row.Margins.Top = 0
            row.Margins.Bottom = 0
         End If
         Dim rowHeight As Integer = me._rowHeightFor(pFields)
         row.Height = rowHeight
         row.TabOrder = 0
         Dim innerW As Integer = row.ClientWidth
         If innerW <= 0 Then
            innerW = pAvailable
         End If
         If innerW <= 0 Then
            innerW = me.AvailableWidth(row)
         End If
         Dim half As Integer = me._half(innerW)
         If pFields.Length = 1 Then
            Dim onlyField As TRegisterField = pFields.Take(0)
            Dim onlyEditor As TLabeledEditorBase = pCreate(row, onlyField)
            If me.OccupiesFullRow(onlyField, innerW) Then
               If onlyField.Visible Then
                  me._applyHost(onlyEditor, alClient, 0, 0)
               Else
                  me._applyHost(onlyEditor, alNone, 0, innerW)
               End If
            Else
               me._applyHost(onlyEditor, alNone, 0, me.EditorWidth(onlyField, half))
            End If
            me._applyVisible(onlyEditor, onlyField)
            me._applyTab(onlyEditor, 0)
         Else
            Dim leftField As TRegisterField = pFields.Take(0)
            Dim leftEditor As TLabeledEditorBase = pCreate(row, leftField)
            me._applyHost(leftEditor, alNone, 0, me.EditorWidth(leftField, half))
            me._applyVisible(leftEditor, leftField)
            me._applyTab(leftEditor, 0)
            Dim rightField As TRegisterField = pFields.Take(1)
            Dim rightEditor As TLabeledEditorBase = pCreate(row, rightField)
            Dim rightMax As Integer = innerW - half
            If rightMax < 0 Then
               rightMax = 0
            End If
            me._applyHost(rightEditor, alNone, half, me.EditorWidth(rightField, rightMax))
            me._applyVisible(rightEditor, rightField)
            me._applyTab(rightEditor, 1)
         End If
         row.Height = rowHeight
         _flushRow = rowHeight
      End Function

      Private Sub _applyHost(pEditor As TLabeledEditorBase, pAlign As TAlign, pLeft As Integer, pWidth As Integer)
         pEditor.Align = pAlign
         If pAlign = alNone Then
            pEditor.Left = pLeft
            pEditor.Top = 0
         End If
         If pWidth > 0 Then
            pEditor.Width = pWidth
         End If
      End Sub

      Private Sub _applyTab(pEditor As TLabeledEditorBase, pIndex As Integer)
         If Not Assigned(pEditor) Then
            Exit Sub
         End If
         Dim hostBox As CustomControl = pEditor.Host
         If Assigned(hostBox) Then
            hostBox.TabStop = False
            hostBox.TabOrder = pIndex
         End If
         pEditor.TabOrder = pIndex
         pEditor.TabStop = pEditor.Visible
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
