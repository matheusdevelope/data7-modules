' =============================================================================
' mod_grid — Biblioteca de abstração sobre Grid
' =============================================================================
'
' Fonte da verdade: TGridData (TTMatrix<TGridCol, TGridRow, Variant>).
' Native Grid é viewport virtual: texto/cor via OnGetDisplText / OnGetCellColor.
' Defina colunas, linhas e options na matrix; depois chame Prepare() para montar o nativo.
'
'   Dim _grid As New TGridView(_form)
'   _grid.Options.Selection.Enabled = True
'   _grid.Options.Item.Enabled = True
'   Dim _col As TGridCol = TGridCol.AsSearch("Código", "codigo")
'   _col.Options.Search.CodPesquisa = Data7.PesquisaPadrao("ProdutoVendido", "CodCondicaoPagamento")
'   _col.Options.Search.DescriptionColumnId = "descricao"
'   _grid.AddColumn(_col)
'   _grid.AddColumn(TGridCol.AsCheckbox("Ativo", "Ativo").SetDefault("S"))
'   _grid.AddColumn(TGridCol.AsImage("Status", "status").AddImage("S", pngOk).AddImage("N", pngNo))
'   Dim _row As TGridRow = _grid.AddRow()
'   _row.SetValue("codigo", "001")
'   Sem AddRow, Prepare() cria uma linha vazia (TMS sempre mostra header + 1 slot).
'   _row.Selected = True
'   _row.Editable = False
'   _col.Font.Bold = True
'   _col.Alignment = taRightJustify
'   _row.Font.Italic = True
'   _grid.Events.OnCanEditCell = me._canEdit
'   _grid.Prepare()
'
' Configuração em _grid.Options:
'   Selection.Enabled / Index / Column
'                           -1 = padrão; -2 = última (TGridOptions.LastColumnIndex()).
'   Item.Enabled / Index / Size / AutoUpdate / Column
'                           Size 3 → 001. Cresce sozinho se RowCount passar disso.
'                           AutoUpdate True (padrão) — o item acompanha a ordem atual
'                           (move/sort/insert/delete). False — o valor original da
'                           linha é mantido; clique no header da coluna Item ordena.
'   Layout.FixedCols / FixedRows / AutoSize / StretchLastColumn
'   Interaction.OnlyRead / AllowMarkForDelete / AddRowOnDown
'                           OnBeforeInsertNewRow (pCanInsert / pMessage)
'                           ColMoving / ColSizing / RowMoving / RowSizing
'   Color.Text / Color.Back
'   Color.Header.Text / Back / Required / RequiredBack
'   Color.Fixed.Back
'                           -1 herda o nativo.
'                           Dados: row Color.Back → col Color.Back → Color.Fixed.Back (FixedCols) → Color.Back.
'                           Headers: col Color.Header.Back → Header.RequiredBack → Header.Back
'                           → Fixed.Back → Color.Back.
'
' Configuração em _col.Options:
'   Layout.Width / Hidden
'   DefaultValue / SetDefault(value)
'                           Preenche a célula ao criar uma row nova (AddRow,
'                           seta pra baixo com AddRowOnDown, etc.). Só aplica
'                           se a célula estiver vazia. IsEmpty(value) = sem padrão.
'                           Zero numérico é valor válido (IsEmpty(0) = False).
'                           Coluna de item (row number) ignora o default.
'   OnGetDefault / SetOnGetDefault(handler)
'                           Delegate Function(pRow, pCol) As Variant, calculado
'                           na hora do insert. Vence DefaultValue; se o handler
'                           devolver Empty, cai no DefaultValue estático.
'                           col.Options.OnGetDefault = me._hoje
'                           ou .SetOnGetDefault(me._hoje).
'   Interaction.OnlyRead / Required / CanEdit / CanMove / CanResize
'                           CanMove False impede arrastar a coluna (e impedir
'                           que outras colunas a desloquem). Padrão True.
'                           CanResize False impede mudar a largura no nativo.
'                           Padrão True. Seleção e Item já nascem CanMove = False.
'   Color.Text / Back / Header.Text / Header.Back
'   Search.CodPesquisa / DescriptionColumnId / ApplyDescriptionOnSet
'                           ApplyDescriptionOnSet False (padrão) — SetValue só grava
'                           a célula. True + DescriptionColumnId — SetValue também
'                           dispara TGridEffects.SearchDescription (lookup da pesquisa)
'                           e preenche a coluna vinculada. Edição em tela já aplica
'                           a descrição sem essa flag. Data.SetCell não dispara.
'   Sort.Numeric / CanSort — Number e Value já vêm Numeric True.
'                           CanSort False (ou .SetCanSort(False)) veta o clique
'                           no header. Search/Text/Mask: ligar Numeric para
'                           ordenar 1, 2, 10 (não 1, 10, 2). Ou .SetNumericSort().
'   Format.Mask / Decimals
'                           Value: Mask entra no ValueTextBox (DisplayFormat) e
'                           no display via factory.FormatValue (Double.ToString).
'                           Sem Mask, o display continua CStr. Number não usa
'                           essa Mask (fica inteiro). Mask (CEP etc.) é outro Kind.
'   Combo.Add(key, value) / SetLista / ShowDescription
'                           ListaOpcoes: "Item A=A";Item_B=B;"Item C=C"
'                           Formato descricao=chave. Aspas no bloco quando há espaço.
'                           Matrix sempre grava a chave. ShowDescription True
'                           (padrão) — a célula nativa mostra o valor. False —
'                           mostra a chave. Edição usa Forms.HComboBox; ao abrir
'                           seleciona pela chave da matrix; ao sair persiste a chave.
'   Image.Add(key, base64) / AddImage(key, base64)
'                           Matrix grava a chave. Nunca é editável (IsEditable,
'                           CanEditCell e inplace editor ficam bloqueados).
'                           No Prepare o nativo liga EnableHTML só se existir
'                           coluna Image (parser HTML no nativo é caro). Cada
'                           imagem é gravada uma vez em C:\Windows\Temp\mod_grid_img
'                           via Base64ToFile; o HTML <img src="file://path"> fica
'                           cacheado na definição. OnGetDisplText resolve a
'                           TGridEditorFactory do Kind e chama FormatValue —
'                           o default é CStr; Combo (ShowDescription) e Image
'                           fazem override. Edição usa FormatEditValue (chave/cru).
'                           Sem chave, célula vazia.
'                           SetCell / SetValue por código continuam livres.
'   Checkbox.CheckedValue / UncheckedValue / ToggleOnDblClick / ActivationKeys
'   System.IsRowNumber / IsSelection
'   Effects.CascadeClearColumnId
'   Drawer
'   Font                  — TFont da coluna (Name, Size, Color, Bold, Italic,
'                           Underline, ...). Acessar cria o objeto.
'                           HasFont diz se foi definido. Aplicado em OnGetCellColor.
'   Alignment / SetAlignment(taLeftJustify | taCenter | taRightJustify)
'                           HasAlignment diz se foi definido. Gravado no nativo
'                           com ColAlignment no Prepare e de novo no move de
'                           coluna. Sem isso, vale o DefaultAlignment nativo.
'
' Configuração em _row.Options:
'   Color.Text / Back — vence a coluna nos dados. Selected/Deleted/IsNew/Dirty/
'                           Editable continuam no próprio TGridRow (estado da linha).
'   Editable              — False bloqueia a linha inteira: células, checkbox,
'                           seleção, ContextPopup e marca de exclusão. Padrão True.
'                           SetCell / SetValue por código continuam livres.
'   CanMove               — False impede arrastar a linha (e impedir que outras
'                           linhas a desloquem). Padrão True.
'   CanResize             — False impede mudar a altura da linha. Padrão True.
'   Font                  — TFont da linha. Vence a fonte da coluna. Color.Text
'                           ainda vence Font.Color quando <> -1.
'
'   Interaction.OnlyRead  — RowSelect nativo; edição desligada. Com Selection.Enabled,
'                           DblClick na linha alterna o checkbox de seleção.
'   Espaço                — toggle só em coluna checkbox, ou em OnlyRead (coluna de
'                           seleção, qualquer célula). Depois desce uma linha
'                           (na última linha só faz o toggle).
'
' ContextPopup:
'   Coluna checkbox       — Marcar / Desmarcar (célula), Marcar Todos /
'                           Tirar Marcação de Todos / Inverter Marcação.
'                           Tudo opera só na coluna clicada.
'                           Na coluna de seleção o invert vira Inverter Seleção
'                           e aí sim atualiza TGridRow.Selected.
'   Demais colunas        — ContextPopup nativo do Grid (pHandled = False).
'
' Eventos em _grid.Events (mesmo nome do Grid nativo):
'   OnCanEditCell / OnGetInplaceEditor / OnGetDisplText / OnGetEditText
'   OnSetEditText / OnCellValidate / OnGetCellColor / OnDrawCell
'   OnDblClickCell / OnKeyPress / OnKeyDown / OnRowMoved / OnColumnMoved
'   OnRowMove / OnColumnMove / OnRowSize / OnColumnSize (ByRef pAllow)
'   OnClickSort / OnCanSort / OnContextPopup / OnResize / OnMarcaDesmarcaLinhaParaExclusao
'                           O EventHub processa primeiro; o delegate do usuário
'                           roda no fim e recebe ByRef já calculado (pode
'                           sobrescrever pCanEdit, pValue, pFont, pHandled, etc.).
'
' Checkbox (modelos prontos em mod_grid_drawer_checkbox):
'   TCheckboxDrawerModel1 / Model2 / Model3 / Model4
'
' =============================================================================
Namespace mod_grid
End Namespace
