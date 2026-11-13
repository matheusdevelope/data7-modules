' data7:disable qualified-private-shared-access
Imports mod_register_form
Imports mod_register_record
Imports TablesField
Imports TablesSequence

Namespace mod_register_store

   Class TRegisterStore

      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

      Shared Function CacheKey() As String
         Dim defTable As configurador_tabela.Tabela = Ambient.Tabela()
         CacheKey = UCase(Trim(defTable.NomeSchema) & "." & Trim(defTable.Nome))
      End Function

      Shared Function OpenRecord() As TRegisterRecord
         OpenRecord = New TRegisterRecord(TRegisterStore.CacheKey())
      End Function

      Shared Function Locate(pRecord As TRegisterRecord) As Boolean
         Locate = pRecord.Load(TRegisterStore.IdentityWhere())
      End Function

      Shared Sub Push(pForm As TRegisterForm, pRecord As TRegisterRecord)
         TRegisterStore._pushOne(pForm, pRecord, "TipoPessoa")
         Dim i As Integer
         Dim last As Integer = pRecord.Fields.Count - 1
         For i = 0 To last
            Dim item As TField = pRecord.GetField(i)
            Dim uname As String = UCase(Trim(item.Name))
            If (uname <> "TIPOPESSOA") And (uname <> "CNPJ_CPF") Then
               If Assigned(pForm.Editor(item.Name)) Then
                  pForm.SetValue(item.Name, item.AsString)
               End If
            End If
         Next
         pForm.SyncPersonType()
         TRegisterStore._pushOne(pForm, pRecord, "CNPJ_CPF")
      End Sub

      Private Shared Sub _pushOne(pForm As TRegisterForm, pRecord As TRegisterRecord, pName As String)
         If Not pRecord.HasField(pName) Then
            Exit Sub
         End If
         If Not Assigned(pForm.Editor(pName)) Then
            Exit Sub
         End If
         pForm.SetValue(pName, pRecord.GetField(pName).AsString)
      End Sub

      Shared Sub Pull(pForm As TRegisterForm, pRecord As TRegisterRecord)
         pRecord.BeginBind()
         Dim i As Integer
         Dim last As Integer = pForm.Config.Fields.Length - 1
         For i = 0 To last
            Dim fieldName As String = pForm.Config.Fields.Take(i).Name
            If pRecord.HasField(fieldName) Then
               pRecord.GetField(fieldName).AsString = pForm.Value(fieldName)
               pRecord.Mark(fieldName)
            End If
         Next
         TRegisterStore._fillContext(pRecord, "CodEmpresa", Ambient.CodEmpresa())
         TRegisterStore._fillContext(pRecord, "CodFilial", Ambient.CodFilial())
      End Sub

      Shared Function Reserve(pRecord As TRegisterRecord) As Integer
         Dim fieldName As String = pRecord.AutoFieldName()
         If fieldName = "" Then
            Reserve = 0
            Exit Function
         End If
         Dim seq As TSequence = TRegisterStore._sequence()
         Dim code As Integer = seq.NextValue()
         seq.Free()
         pRecord.AssignAutoCode(code)
         pRecord.Mark(fieldName)
         Reserve = code
      End Function

      Shared Sub Release(pCode As Integer)
         If pCode <= 0 Then
            Exit Sub
         End If
         Dim seq As TSequence = TRegisterStore._sequence()
         seq.RestartWith(pCode)
         seq.Free()
      End Sub

      Shared Sub InsertRow(pRecord As TRegisterRecord)
         Dim rows As Integer = pRecord.Insert()
      End Sub

      Shared Sub UpdateRow(pRecord As TRegisterRecord)
         Dim rows As Integer = pRecord.UpdateWhere(TRegisterStore.IdentityWhere())
      End Sub

      Shared Sub DeleteRow(pRecord As TRegisterRecord)
         Dim rows As Integer = pRecord.DeleteWhere(TRegisterStore.IdentityWhere())
      End Sub

      Shared Function IdentityWhere() As String
         Dim whereText As String = Ambient.InternalWhere()
         If Trim(whereText) = "" Then
            Throw New Exception("Não foi possível montar a chave do registro.")
         End If
         IdentityWhere = whereText
      End Function

      Private Shared Function _sequence() As TSequence
         Dim defTable As configurador_tabela.Tabela = Ambient.Tabela()
         Dim emp As Integer = 0
         If Ambient.Campos.Has("CodEmpresa") AndAlso Ambient.Campos.Take("CodEmpresa").IsPrimaryKey Then
            emp = Ambient.CodEmpresa()
         End If
         _sequence = New TSequence(defTable.Nome, defTable.NomeSchema, emp)
      End Function

      Private Shared Sub _fillContext(pRecord As TRegisterRecord, pName As String, pValue As Integer)
         If Not pRecord.HasField(pName) Then
            Exit Sub
         End If
         Dim item As TField = pRecord.GetField(pName)
         If Not IsEmpty(item.Value) Then
            Exit Sub
         End If
         If pValue = 0 Then
            Exit Sub
         End If
         item.AsInteger = pValue
         pRecord.Mark(pName)
      End Sub
   End Class

End Namespace
