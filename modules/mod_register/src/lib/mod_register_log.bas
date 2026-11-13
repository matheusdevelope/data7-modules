' data7:disable qualified-private-shared-access
Imports Collections
Imports ambient_context
Imports mod_log
Imports mod_log_batch
Imports mod_log_type
Imports mod_register_config
Imports mod_register_form
Imports mod_register_store
Imports table_processotabela

Namespace mod_register_log

   Class TRegisterLog

      Shared Sub Save(pMode As String, pForm As TRegisterForm, pLoaded As StringList)
         Dim entry As Logg = TRegisterLog._header(pMode)
         TRegisterLog._items(entry, pMode, pForm, pLoaded)
         LogBatch.SaveOne(entry)
         entry.Free()
      End Sub

      Private Shared Function _header(pMode As String) As Logg
         Dim defTable As configurador_tabela.Tabela = Ambient.Tabela()
         Dim ctx As TContext = Ambient.Current()
         Dim entry As New Logg()
         entry.CodEmpresa = ctx.CodEmpresa
         entry.CodFilial = ctx.CodFilial
         entry.CodUsuario = ctx.CodUsuario
         entry.CodTabela = defTable.CodTabela
         entry.Nome = Trim(defTable.Nome)
         entry.NomeSchema = Trim(defTable.NomeSchema)
         entry.NomeUsuario = Trim(Ambient.Usuario().NomeLegivel)
         entry.NomeComputador = Trim(ctx.StationName)
         entry.UsuarioWindows = Trim(ctx.StationUser)
         entry.NomeSistema = Trim(Ambient.Sistema().NomeComercialPAF)
         entry.VersaoSistema = Trim(Ambient.Sistema().Version)
         entry.CodPeriodoCaixa = Ambient.Periodo().CodPeriodoCaixa
         entry.NomeRotina = "Cadastro"
         entry.SetType(TRegisterLog._typeOf(pMode))
         Dim note As String = "Projeto Register Developer - " & TRegisterLog._action(pMode)
         If pMode = "COPIAR" Then
            note = note & ". Cópia do registro " & TRegisterStore.IdentityWhere()
         End If
         entry.Observacao = note
         If (pMode = "ALTERAR") Or (pMode = "EXCLUIR") Then
            entry.ClausulaWhere = TRegisterStore.IdentityWhere()
         End If
         _header = entry
      End Function

      Private Shared Sub _items(pEntry As Logg, pMode As String, pForm As TRegisterForm, pLoaded As StringList)
         Dim i As Integer
         Dim last As Integer = pForm.Config.Fields.Length - 1
         For i = 0 To last
            Dim field As TRegisterField = pForm.Config.Fields.Take(i)
            Dim fieldName As String = field.Name
            Dim currentText As String
            Select UCase(field.Tipo)
               Case "I", "N", "L"
                  currentText = pForm.Value(fieldName)
               Case Else
                  currentText = "'" & pForm.Value(fieldName) & "'"
            End Select
            Dim previousText As String = TRegisterLog._previous(pLoaded, fieldName)
            If pMode = "EXCLUIR" Then
               If Trim(previousText) <> "" Then
                  pEntry.AddItem(fieldName, TRegisterLog._clip(previousText), "", "")
               End If
            ElseIf pMode = "ALTERAR" Then
               If Trim(currentText) <> Trim(previousText) Then
                  pEntry.AddItem(fieldName, TRegisterLog._clip(previousText), TRegisterLog._clip(currentText), "")
               ElseIf field.IsKey And (Trim(previousText) <> "") Then
                  pEntry.AddItem(fieldName, TRegisterLog._clip(previousText), "", "")
               End If
            ElseIf Trim(currentText) <> "" Then
               Dim oldText As String = ""
               If (pMode = "COPIAR") And (Trim(currentText) <> Trim(previousText)) Then
                  oldText = previousText
               End If
               pEntry.AddItem(fieldName, TRegisterLog._clip(oldText), TRegisterLog._clip(currentText), "")
            End If
         Next
      End Sub

      Private Shared Function _typeOf(pMode As String) As TLogType
         If pMode = "ALTERAR" Then
            _typeOf = TLogType.ltUpdate()
         ElseIf pMode = "EXCLUIR" Then
            _typeOf = TLogType.ltDelete()
         Else
            _typeOf = TLogType.ltInsert()
         End If
      End Function

      Private Shared Function _action(pMode As String) As String
         If pMode = "COPIAR" Then
            _action = "Copiar"
         ElseIf pMode = "ALTERAR" Then
            _action = "Alterar"
         ElseIf pMode = "EXCLUIR" Then
            _action = "Excluir"
         Else
            _action = "Incluir"
         End If
      End Function

      Private Shared Function _previous(pLoaded As StringList, pName As String) As String
         _previous = ""
         If Not Assigned(pLoaded) Then
            Exit Function
         End If
         Dim key As String = UCase(Trim(pName))
         Dim i As Integer
         Dim last As Integer = pLoaded.Count - 1
         For i = 0 To last
            Dim packed As String = pLoaded.Strings(i)
            Dim cut As Integer = packed.Pos(Chr(1))
            If cut > 0 Then
               If UCase(packed.Left(cut - 1)) = key Then
                  _previous = packed.Right(packed.Length - cut)
                  Exit Function
               End If
            End If
         Next
      End Function

      Private Shared Function _clip(pValue As String) As String
         If pValue.Length <= 2000 Then
            _clip = pValue
         Else
            _clip = pValue.Left(2000)
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
