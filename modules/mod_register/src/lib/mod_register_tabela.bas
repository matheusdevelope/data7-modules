' data7:disable qualified-private-shared-access
Imports mod_tlist
Imports configurador_tabela
Imports configurador_campo
Imports mod_register_config
Imports configurador_pasta

Namespace mod_register_tabela

   Class TRegisterTabela

      Shared Function FromTabela(pTabela As Tabela) As TRegisterFormConfig
         Dim cfg As New TRegisterFormConfig()
         If Not Assigned(pTabela) Then
            FromTabela = cfg
            Exit Function
         End If
         cfg.Title = Trim(pTabela.Titulo)
         If cfg.Title = "" Then
            cfg.Title = Trim(pTabela.Nome)
         End If
         If pTabela.MargemEditor > 0 Then
            cfg.ContentMargin = pTabela.MargemEditor
         End If
         TRegisterTabela._mapFolders(cfg, pTabela.Pastas)
         TRegisterTabela._mapFields(cfg, pTabela.CodCampoAutoIncremento, pTabela)
         FromTabela = cfg
      End Function

      Private Shared Sub _mapFolders(pCfg As TRegisterFormConfig, pPastas As TTList<Pasta>)
         If Not Assigned(pPastas) Then
            Exit Sub
         End If
         Dim visiveis[] As Pasta = TRegisterTabela._pastasVisiveis(pPastas)
         Dim i As Integer
         Dim n As Integer = visiveis.Length
         For i = 0 To n - 1
            Dim pastaItem As Pasta = visiveis.Take(i)
            Dim id As String = CStr(pastaItem.CodPasta)
            Dim parentId As String = ""
            Dim pastaPai As Pasta = TRegisterTabela._pastaPai(visiveis, pastaItem)
            If Assigned(pastaPai) Then
               parentId = CStr(pastaPai.CodPasta)
            End If
            Dim folder As TRegisterFolder = pCfg.AddFolder(id, Trim(pastaItem.Titulo), parentId)
            folder.Estrutura = Trim(pastaItem.Estrutura)
            folder.SubCadastro = pastaItem.EhSubcadastro()
            If pastaItem.MargemEditor > 0 Then
               folder.Margin = pastaItem.MargemEditor
            End If
            folder.Visible = True
         Next
         visiveis.OwnsObjects = False
         visiveis.Free()
      End Sub

      Private Shared Sub _mapFields(pCfg As TRegisterFormConfig, pCodAutoIncremento As Integer, pTabela As Tabela)
         If Not Assigned(pTabela) Then
            Exit Sub
         End If
         Dim i As Integer
         Dim n As Integer = pTabela.Campos.Length
         If n <= 0 Then
            Exit Sub
         End If
         For i = 0 To n - 1
            Dim campoItem As Campo = pTabela.Campos.Take(i)
            If Assigned(campoItem) And (Not campoItem.Extra) And TRegisterTabela._tipoAceito(campoItem.Tipo) Then
               Dim pastaItem As Pasta = TRegisterTabela._pastaPorCodigo(pTabela.Pastas, campoItem.CodPasta)
               Dim vis As String = TRegisterTabela._visibilidadeEdicao(campoItem)
               If (vis <> "N") And (Not TRegisterTabela._ehCalculado(campoItem)) And TRegisterTabela._pastaCampoVisivel(pastaItem, campoItem.CodPasta) Then
                  Dim _field As TRegisterField = pCfg.AddField(campoItem.Nome, TRegisterTabela._caption(campoItem))
                  _field.Order = campoItem.OrdemEdicao
                  _field.MaxLength = campoItem.Tamanho
                  _field.Width = campoItem.LarguraEdicao
                  _field.Height = campoItem.AlturaEdicao
                  _field.Column = campoItem.Coluna
                  _field.Required = False
                  _field.CanEditInsert = True
                  _field.CanEditUpdate = True
                  _field.IsKey = campoItem.Chave
                  _field.AutoIncrement = CBool(campoItem.CodCampo = pCodAutoIncremento)
                  _field.KeepContent = campoItem.ManterConteudo
                  _field.TipoValorPadrao = campoItem.TipoValorPadrao
                  _field.FormulaValorPadrao = campoItem.FormulaValorPadrao
                  _field.CondicaoEditarInclusao = campoItem.CondicaoEditarInclusao
                  _field.CondicaoEditarAlteracao = campoItem.CondicaoEditarAlteracao
                  _field.CondicaoObrigatorio = campoItem.CondicaoObrigatorio
                  _field.ListaOpcoes = campoItem.ListaOpcao
                  _field.CodPesquisa = campoItem.CodPesquisaPadrao
                  _field.TipoPesquisa = campoItem.TipoPesquisa
                  _field.PesquisaIncremental = campoItem.PesquisaIncremental
                  _field.Mask = campoItem.MascaraEdicao
                  _field.DecimalPlaces = campoItem.CasasDecimal
                  _field.CharCase = campoItem.CharCase
                  _field.Alignment = campoItem.AlinhamentoEdicao
                  _field.FontName = campoItem.NomeFonteEdicao
                  _field.FontSize = campoItem.TamanhoFonteEdicao
                  _field.FontColor = campoItem.CorFonteEdicao
                  _field.FontBold = campoItem.FonteNegritoEdicao
                  _field.FontItalic = campoItem.FonteItalicoEdicao
                  _field.FontUnderline = campoItem.FonteSublinhadoEdicao
                  _field.Hint = campoItem.observacao
                  _field.Tipo = campoItem.Tipo
                  _field.ValidacaoSistema = campoItem.ValidacaoSistema
                  _field.ValidacaoUsuario = campoItem.ValidacaoUsuario
                  If vis = "O" Then
                     _field.Hide()
                  End If
                  TRegisterTabela._applyKind(_field, campoItem)
                  If Not TRegisterTabela._ehMemo(_field) Then
                     _field.Height = 0
                  End If
                  If Assigned(pastaItem) Then
                     _field.InFolder(CStr(pastaItem.CodPasta), pastaItem.Titulo)
                  End If
               End If
            End If
         Next
      End Sub

      Private Shared Function _pastasVisiveis(pPastas As TTList<Pasta>) As TTList<Pasta>
         Dim lista[] As Pasta = []
         lista.OwnsObjects = False
         Dim i As Integer
         Dim n As Integer = pPastas.Length
         For i = 0 To n - 1
            Dim pastaItem As Pasta = pPastas.Take(i)
            If Assigned(pastaItem) Then
               If TRegisterTabela._pastaVisivel(pastaItem) Then
                  lista.Push(pastaItem)
               End If
            End If
         Next
         Dim a As Integer
         Dim b As Integer
         Dim last As Integer = lista.Length - 1
         For a = 0 To last
            For b = a + 1 To last
               Dim leftItem As Pasta = lista.Take(a)
               Dim rightItem As Pasta = lista.Take(b)
               Dim leftKey As String = Trim(leftItem.Estrutura)
               Dim rightKey As String = Trim(rightItem.Estrutura)
               If leftKey = "" Then
                  leftKey = CStr(leftItem.CodPasta)
               End If
               If rightKey = "" Then
                  rightKey = CStr(rightItem.CodPasta)
               End If
               If (rightKey < leftKey) Or ((rightKey = leftKey) And (rightItem.CodPasta < leftItem.CodPasta)) Then
                  lista.SetItem(a, rightItem)
                  lista.SetItem(b, leftItem)
               End If
            Next
         Next
         _pastasVisiveis = lista
      End Function

      Private Shared Function _pastaPai(pPastas As TTList<Pasta>, pPasta As Pasta) As Pasta
         If (Not Assigned(pPastas)) Or (Not Assigned(pPasta)) Then
            _pastaPai = Null
            Exit Function
         End If
         Dim childEst As String = Trim(pPasta.Estrutura)
         If childEst = "" Then
            _pastaPai = Null
            Exit Function
         End If
         Dim best As Pasta = Null
         Dim bestLen As Integer = 0
         Dim i As Integer
         Dim n As Integer = pPastas.Length
         For i = 0 To n - 1
            Dim pastaItem As Pasta = pPastas.Take(i)
            If Assigned(pastaItem) And (pastaItem.CodPasta <> pPasta.CodPasta) Then
               Dim parentEst As String = Trim(pastaItem.Estrutura)
               If TRegisterFormConfig.IsEstruturaPrefix(parentEst, childEst) Then
                  Dim parentLen As Integer = Len(parentEst)
                  If (Not Assigned(best)) Or (parentLen > bestLen) Then
                     best = pastaItem
                     bestLen = parentLen
                  ElseIf (parentLen = bestLen) And Assigned(best) Then
                     If pastaItem.CodPasta < best.CodPasta Then
                        best = pastaItem
                     End If
                  End If
               End If
            End If
         Next
         _pastaPai = best
      End Function

      Private Shared Function _pastaCampoVisivel(pPasta As Pasta, pCodPasta As Integer) As Boolean
         If pCodPasta = 0 Then
            _pastaCampoVisivel = True
         ElseIf Not Assigned(pPasta) Then
            _pastaCampoVisivel = True
         Else
            _pastaCampoVisivel = TRegisterTabela._pastaVisivel(pPasta)
         End If
      End Function

      Private Shared Function _pastaPorCodigo(pPastas As TTList<Pasta>, pCodPasta As Integer) As Pasta
         If (Not Assigned(pPastas)) Or (pCodPasta = 0) Then
            _pastaPorCodigo = Null
            Exit Function
         End If
         Dim i As Integer
         Dim n As Integer = pPastas.Length
         For i = 0 To n - 1
            Dim pastaItem As Pasta = pPastas.Take(i)
            If Assigned(pastaItem) Then
               If pastaItem.CodPasta = pCodPasta Then
                  _pastaPorCodigo = pastaItem
                  Exit Function
               End If
            End If
         Next
         _pastaPorCodigo = Null
      End Function

      Private Shared Function _tipoAceito(pTipo As String) As Boolean
         Select Case UCase(Trim(pTipo))
            Case "V", "I", "N", "D", "T", "DT", "IM", "M", "L"
               _tipoAceito = True
            Case Else
               _tipoAceito = False
         End Select
      End Function

      Private Shared Sub _applyKind(pField As TRegisterField, pCampo As Campo)
         If TRegisterTabela._applyEspecifico(pField, UCase(Trim(pCampo.Especifico))) Then
            Exit Sub
         End If
         If pCampo.CodPesquisaPadrao > 0 Then
            pField.UseSearch(pCampo.CodPesquisaPadrao)
            Exit Sub
         End If
         If Trim(pCampo.ListaOpcao) <> "" Then
            pField.UseCombo(pCampo.ListaOpcao)
            Exit Sub
         End If
         Select Case UCase(Trim(pCampo.Tipo))
            Case "V"
               pField.UseText()
            Case "I", "L"
               pField.UseInteger()
            Case "N"
               pField.UseValue(pCampo.CasasDecimal)
            Case "D"
               pField.UseDate()
            Case "T"
               pField.UseTime()
            Case "DT"
               pField.UseDateTime()
            Case "IM"
               pField.UseImage()
            Case "M"
               pField.UseMemo()
         End Select
      End Sub

      Private Shared Function _applyEspecifico(pField As TRegisterField, pEspecifico As String) As Boolean
         If pEspecifico = "" Then
            _applyEspecifico = False
            Exit Function
         End If
         Select Case pEspecifico
            Case "CEP"
               pField.UseCEP()
            Case "CPF"
               pField.UseCPF()
            Case "CNPJ"
               pField.UseCNPJ()
            Case "CPFCNPJ", "CPF_CNPJ", "CPF/CNPJ", "CPF-CNPJ"
               pField.UseCpfCnpj()
            Case "EMAIL", "E-MAIL"
               pField.UseEmail()
            Case "SITE", "URL"
               pField.UseSite()
            Case "IE", "INSCRICAO"
               pField.UseIE()
            Case "PLACA"
               pField.UsePlaca()
            Case "GTIN", "EAN"
               pField.UseGtin()
            Case "CNH"
               pField.UseCnh()
            Case "RENAVAM"
               pField.UseRenavam()
            Case "SUFRAMA"
               pField.UseSuframa()
            Case Else
               _applyEspecifico = False
               Exit Function
         End Select
         _applyEspecifico = True
      End Function

      Private Shared Function _caption(pCampo As Campo) As String
         Dim t As String = Trim(pCampo.TituloEdicao)
         If t = "" Then
            t = Trim(pCampo.Titulo)
         End If
         If t = "" Then
            t = pCampo.Nome
         End If
         If t <> "" Then
            If Right(t, 1) <> ":" Then
               t = t & ":"
            End If
         End If
         _caption = t
      End Function

      Private Shared Function _ehCalculado(pCampo As Campo) As Boolean
         _ehCalculado = CBool(UCase(Trim(pCampo.Contexto)) = "C")
      End Function

      Private Shared Function _ehMemo(pField As TRegisterField) As Boolean
         Dim kind As String = UCase(pField.KindKey())
         _ehMemo = CBool((kind = "MEMO") Or (kind = "TEXTO"))
      End Function

      Private Shared Function _visibilidadeEdicao(pCampo As Campo) As String
         Dim v As String = UCase(Trim(pCampo.CondicaoVisivelEdicao))
         If (v = "O") Or (v = "OCULTO") Then
            _visibilidadeEdicao = "O"
         ElseIf (v = "S") Or (v = "SIM") Then
            _visibilidadeEdicao = "S"
         Else
            _visibilidadeEdicao = "N"
         End If
      End Function

      Private Shared Function _pastaVisivel(pPasta As Pasta) As Boolean
         Dim st As String = UCase(Trim(pPasta.Status))
         If (st = "N") Or (st = "I") Or (st = "0") Or (st = "INATIVO") Then
            _pastaVisivel = False
         Else
            _pastaVisivel = True
         End If
      End Function

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
