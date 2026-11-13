Imports mod_tobject
Imports mod_log_type
Imports mod_log_item

Namespace mod_log

   ' One complete log (header + items).
   '
   '   Dim entry As New Logg()
   '   entry.Nome = "Produto"
   '   entry.SetType(TLogType.ltInsert())
   '   entry.NomeRotina = "Cadastro"
   '   entry.CodTabela = 35
   '   entry.AddItem("PrecoVenda", "1.00", "2.00")
   '   LogBatch.SaveOne(entry)
   '
   ' For many logs in a row, use LogBatch: one AllocateBlock and one
   ' session/version read for the whole batch.
   '
   '   Dim batch As New LogBatch()
   '   Dim entry As Logg = batch.NewLog()
   '   entry.Nome = "Produto"
   '   entry.SetType(TLogType.ltUpdate())
   '   entry.NomeRotina = "Cadastro"
   '   entry.AddItem("PrecoVenda", "1.00", "2.00")
   '   batch.Save()
   '
   ' Company, branch, user, machine, version and period are filled in
   ' when the field is empty. CodLogSistema is assigned on save.
   Class Logg
      Inherits TTObject

      CodLogSistema As Integer
      CodEmpresa As Integer
      CodFilial As Integer
      CodUsuario As Integer
      CodPeriodoCaixa As Integer
      CodTabela As Integer
      Nome As String
      TipoLog As String
      NomeRotina As String
      Observacao As String
      ClausulaWhere As String
      NomeUsuario As String
      NomeComputador As String
      UsuarioWindows As String
      NomeSistema As String
      VersaoSistema As String
      NomeSchema As String
      Hora As String
      Items[] As LogItem

      Private _data As TDateTime
      Private _hasDate As Boolean
      Private _saved As Boolean
      Private _generatedCode As Boolean

      Sub New()
         MyBase.New()
         me.CodLogSistema = 0
         me.CodEmpresa = 0
         me.CodFilial = 0
         me.CodUsuario = 0
         me.CodPeriodoCaixa = 0
         me.CodTabela = 0
         me.Nome = ""
         me.TipoLog = ""
         me.NomeRotina = ""
         me.Observacao = ""
         me.ClausulaWhere = ""
         me.NomeUsuario = ""
         me.NomeComputador = ""
         me.UsuarioWindows = ""
         me.NomeSistema = ""
         me.VersaoSistema = ""
         me.NomeSchema = ""
         me.Hora = ""
         me.Items = []
         me.Items.OwnsObjects = True
         me._data = Date()
         me._hasDate = False
         me._saved = False
         me._generatedCode = False
      End Sub

      Property Data As TDateTime
         Get
            Data = me._data
         End Get
         Set(pValue As TDateTime)
            me._data = pValue
            me._hasDate = True
         End Set
      End Property

      Function HasDate() As Boolean
         HasDate = me._hasDate
      End Function

      Function IsSaved() As Boolean
         IsSaved = me._saved
      End Function

      Function IsGeneratedCode() As Boolean
         IsGeneratedCode = me._generatedCode
      End Function

      Sub SetType(pType As TLogType)
         me.TipoLog = pType.AsString
      End Sub

      Function AddItem(pNome As String, pValorAntigo As String, pValor As String, pObservacao As String = "") As LogItem
         Dim item As New LogItem()
         item.Sequencia = me.Items.Length + 1
         item.Nome = pNome
         item.ValorAntigo = pValorAntigo
         item.Valor = pValor
         item.Observacao = pObservacao
         me.Items.Push(item)
         AddItem = item
      End Function

      Sub AssignCode(pCode As Integer, pGenerated As Boolean)
         me.CodLogSistema = pCode
         me._generatedCode = pGenerated
      End Sub

      Sub MarkSaved()
         me._saved = True
         me._generatedCode = False
      End Sub

      Sub RevertCode()
         If me._generatedCode Then
            me.CodLogSistema = 0
            me._generatedCode = False
         End If
      End Sub

      Function Copy() As Logg
         Dim _copy As New Logg()
         _copy.CodEmpresa = me.CodEmpresa
         _copy.CodFilial = me.CodFilial
         _copy.CodUsuario = me.CodUsuario
         _copy.CodPeriodoCaixa = me.CodPeriodoCaixa
         _copy.CodTabela = me.CodTabela
         _copy.Nome = me.Nome
         _copy.TipoLog = me.TipoLog
         _copy.NomeRotina = me.NomeRotina
         _copy.Observacao = me.Observacao
         _copy.ClausulaWhere = me.ClausulaWhere
         _copy.NomeUsuario = me.NomeUsuario
         _copy.NomeComputador = me.NomeComputador
         _copy.UsuarioWindows = me.UsuarioWindows
         _copy.NomeSistema = me.NomeSistema
         _copy.VersaoSistema = me.VersaoSistema
         _copy.NomeSchema = me.NomeSchema
         _copy.Hora = me.Hora
         If me._hasDate Then
            _copy.Data = me._data
         End If
         Dim i As Integer
         Dim total As Integer = me.Items.Length
         For i = 0 To total - 1
            Dim source As LogItem = me.Items.Take(i)
            _copy.AddItem(source.Nome, source.ValorAntigo, source.Valor, source.Observacao)
         Next
         Copy = _copy
      End Function

      Overrides Function Clone() As Logg
         Clone = me.Copy()
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Items) Then
            me.Items.Free()
            me.Items = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
