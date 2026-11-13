Imports Forms
Imports mod_tobject
Imports mod_forms
Imports mod_editors
Imports mod_editors_combo
Imports mod_editors_value
Imports mod_editors_text
Imports mod_pix_utils
Imports mod_pix_cobranca_completa
Imports mod_pix_recebimento

Namespace mod_pix_app_refund

   Class PixAppRefundDialog
      Inherits TFormsDialog

      Private _cob As PixCobrancaCompleta
      Private _e2e As TComboEditor
      Private _valor As TValueEditor
      Private _id As TTextEditor

      Accepted As Boolean
      TxId As String
      EndToEndId As String
      Valor As Currency
      IdDevolucao As String

      Sub New(pCobranca As PixCobrancaCompleta)
         MyBase.New("Registrar devolução")
         me._cob = pCobranca
         If Assigned(pCobranca) Then
            me.TxId = pCobranca.TxId
         End If
         me.CloseOnOk = False
         me.SizeWidth = 42
         me.SizeHeight = 38
         me._fillE2e()
         me._valor.AsDouble = me._defaultValor()
         me._id.Text = GenerateIDDevolucao()
      End Sub

      Sub New(pPix As PixRecebimento)
         MyBase.New("Registrar devolução")
         me._cob = Null
         If Assigned(pPix) Then
            me.TxId = pPix.TxId
         End If
         me.CloseOnOk = False
         me.SizeWidth = 42
         me.SizeHeight = 38
         me._fillFromPix(pPix)
         me._id.Text = GenerateIDDevolucao()
      End Sub

      Protected Overrides Sub Build()
         me._e2e = New TComboEditor(me.Content, "Recebimento")
         me._e2e.Align = alTop
         me._e2e.LabelPlacement = TLabelPlacement.Top()

         me._valor = New TValueEditor(me.Content, "Valor")
         me._valor.Align = alTop
         me._valor.LabelPlacement = TLabelPlacement.Top()
         me._valor.DecimalPlaces = 2
         me._valor.DisplayFormat = "0.00"

         me._id = New TTextEditor(me.Content, "Id da devolução")
         me._id.Align = alTop
         me._id.LabelPlacement = TLabelPlacement.Top()
      End Sub

      Private Sub _fillE2e()
         Dim lista As String = ""
         If Assigned(me._cob) Then
            If Assigned(me._cob.Recebimentos) Then
               Dim i As Integer
               Dim n As Integer = me._cob.Recebimentos.Length - 1
               For i = 0 To n
                  Dim pix As PixRecebimento = me._cob.Recebimentos.Take(i)
                  If lista <> "" Then
                     lista = lista & ";"
                  End If
                  lista = lista & pix.E2eId & "=" & pix.E2eId
               Next
            End If
         End If
         me._e2e.ListaOpcoes = lista
         If Assigned(me._cob) Then
            If Assigned(me._cob.Recebimentos) Then
               If me._cob.Recebimentos.Length > 0 Then
                  me._e2e.ValueSelect = me._cob.Recebimentos.Take(0).E2eId
               End If
            End If
         End If
      End Sub

      Private Sub _fillFromPix(pPix As PixRecebimento)
         If Not Assigned(pPix) Then
            Exit Sub
         End If
         me._e2e.ListaOpcoes = pPix.E2eId & "=" & pPix.E2eId
         me._e2e.ValueSelect = pPix.E2eId
         me._valor.AsDouble = pPix.Valor - pPix.ValorDevolvido
      End Sub

      Private Function _defaultValor() As Double
         If Assigned(me._cob) Then
            If Assigned(me._cob.Recebimentos) Then
               If me._cob.Recebimentos.Length > 0 Then
                  Dim pix As PixRecebimento = me._cob.Recebimentos.Take(0)
                  _defaultValor = pix.Valor - pix.ValorDevolvido
                  Exit Function
               End If
            End If
            _defaultValor = me._cob.Valor.Original
         Else
            _defaultValor = 0
         End If
      End Function

      Protected Overrides Sub HandleOk(pSender As TObject)
         me.EndToEndId = Trim(me._e2e.ValueSelect)
         me.Valor = me._valor.AsDouble
         me.IdDevolucao = Trim(me._id.Text)
         If me.EndToEndId = "" Then
            Forms.MessageBox.Show("Selecione o recebimento que será devolvido.")
            me.Accepted = False
            Exit Sub
         End If
         If me.Valor <= 0 Then
            Forms.MessageBox.Show("Informe um valor maior que zero para a devolução.")
            me.Accepted = False
            Exit Sub
         End If
         If me.IdDevolucao = "" Then
            me.IdDevolucao = GenerateIDDevolucao()
         End If
         me.Accepted = True
         me.Close(True)
      End Sub

      Sub Free()
         If Assigned(me._e2e) Then
            me._e2e.Free()
         End If
         If Assigned(me._valor) Then
            me._valor.Free()
         End If
         If Assigned(me._id) Then
            me._id.Free()
         End If
         me._cob = Null
         MyBase.Free()
      End Sub

   End Class

End Namespace
