Imports mod_tlist
Imports mod_tobject
Imports table_filter_field

Namespace table_filter_table

   Class TFilterTable
      Inherits TTObject

      Schema As String
      Nome As String
      Campos[] As TFilterField = []

      Sub New()
         MyBase.New()
         me.Schema = ""
         me.Nome = ""
         me.Campos = []
      End Sub

      Overrides Function GetID() As String
         GetID = me.Nome
      End Function

      Function AddField(pNome As String, pTitulo As String, pTipo As String, pCodPesquisa As Integer = 0, pListaOpcoes As String = "", pDecimalPlaces As Integer = 0, pFormula As String = "") As TFilterField
         Dim field As New TFilterField()
         field.Nome = pNome
         field.Titulo = Trim(pTitulo)
         If field.Titulo = "" Then
            field.Titulo = pNome
         End If
         field.Tipo = pTipo
         field.CodPesquisa = pCodPesquisa
         field.ListaOpcoes = pListaOpcoes
         field.DecimalPlaces = pDecimalPlaces
         field.Formula = Trim(pFormula)
         me.Campos.Push(field)
         AddField = field
      End Function

      Function FindByName(pNome As String) As TFilterField
         Dim target As String = UCase(Trim(pNome))
         If target = "" Then
            FindByName = Null
            Exit Function
         End If
         Dim i As Integer
         Dim last As Integer = me.Campos.Length - 1
         For i = 0 To last
            Dim field As TFilterField = me.Campos.Take(i)
            If UCase(Trim(field.Nome)) = target Then
               FindByName = field
               Exit Function
            End If
         Next
         FindByName = Null
      End Function

      Overrides Function Clone() As TFilterTable
         Dim copy As New TFilterTable()
         copy.Schema = me.Schema
         copy.Nome = me.Nome
         Dim i As Integer
         Dim last As Integer = me.Campos.Length - 1
         For i = 0 To last
            copy.Campos.Push(me.Campos.Take(i).Clone())
         Next
         Clone = copy
      End Function

      Function FieldListaOpcoes() As String
         Dim titles[] As String = []
         Dim names[] As String = []
         Dim i As Integer
         Dim last As Integer = me.Campos.Length - 1
         For i = 0 To last
            Dim field As TFilterField = me.Campos.Take(i)
            Dim titulo As String = Trim(field.Titulo)
            If titulo = "" Then
               titulo = field.Nome
            End If
            me._insertOptionSorted(titles, names, titulo, field.Nome)
         Next
         Dim list As String = ""
         last = titles.Length - 1
         For i = 0 To last
            Dim item As String = titles.Take(i) & "=" & names.Take(i)
            If i > 0 Then
               list = list & ";"
            End If
            list = list & item.Quoted()
         Next
         titles.Free()
         names.Free()
         FieldListaOpcoes = list
      End Function

      Private Sub _insertOptionSorted(pTitles As TTList<String>, pNames As TTList<String>, pTitulo As String, pNome As String)
         Dim key As String = UCase(pTitulo)
         Dim i As Integer
         Dim last As Integer = pTitles.Length - 1
         For i = 0 To last
            If key < UCase(pTitles.Take(i)) Then
               pTitles.Unshift(i, pTitulo)
               pNames.Unshift(i, pNome)
               Exit Sub
            End If
         Next
         pTitles.Push(pTitulo)
         pNames.Push(pNome)
      End Sub

      Overrides Sub Dispose()
         If Assigned(me.Campos) Then
            me.Campos.Free()
            me.Campos = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
