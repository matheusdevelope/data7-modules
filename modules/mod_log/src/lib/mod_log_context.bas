Imports mod_tobject
Imports TablesSql
Imports table_logsistema

Namespace mod_log_context

   Private Dim _currentContext As LogContext

   ' Session data and the system version, read once and reused by every
   ' log in the process. CodPeriodoCaixa and VersaoSistema hit the database
   ' only the first time some log needs them.
   Class LogContext
      Inherits TTObject

      CodEmpresa As Integer
      CodFilial As Integer
      CodUsuario As Integer
      CodPeriodoCaixa As Integer
      NomeUsuario As String
      NomeComputador As String
      UsuarioWindows As String
      NomeSistema As String
      VersaoSistema As String
      NomeSchema As String

      Private _versionLoaded As Boolean
      Private _periodLoaded As Boolean

      Sub New()
         MyBase.New()
         me.CodEmpresa = 0
         me.CodFilial = 0
         me.CodUsuario = 0
         me.CodPeriodoCaixa = 0
         me.NomeUsuario = ""
         me.NomeComputador = ""
         me.UsuarioWindows = ""
         me.NomeSistema = ""
         me.VersaoSistema = ""
         me.NomeSchema = ""
         me._versionLoaded = False
         me._periodLoaded = False
      End Sub

      Shared Function Current() As LogContext
         If Not Assigned(_currentContext) Then
            _currentContext = New LogContext()
         End If
         Current = _currentContext
      End Function

      Shared Sub Invalidate()
         If Assigned(_currentContext) Then
            _currentContext.Free()
            _currentContext = NULL
         End If
      End Sub

      ' Company, branch, user and machine come from ERP memory.
      ' Called on each save so the session stays current without a query.
      Sub Capture()
         me.CodEmpresa = Data7.CodEmpresa
         me.CodFilial = Data7.CodFilial
         me.CodUsuario = Data7.CodUsuario
         me.NomeUsuario = Data7.NomeUsuario
         me.NomeComputador = Environment.MachineName
         me.UsuarioWindows = Environment.UserName
         If Trim(me.NomeSistema) = "" Then
            me.NomeSistema = "Data7"
         End If
         If Trim(me.NomeSchema) = "" Then
            me.NomeSchema = TSql.Dialect().DefaultSchema()
         End If
      End Sub

      Function Version() As String
         If Not me._versionLoaded Then
            If Trim(me.VersaoSistema) = "" Then
               Dim probe As New TLogSistema()
               Dim expr As String = Trim(probe.Schema.Field("VersaoSistema").InsertExpr)
               probe.Free()
               If expr <> "" Then
                  me.VersaoSistema = TSql.ExecSelect(expr)
               End If
            End If
            me._versionLoaded = True
         End If
         Version = me.VersaoSistema
      End Function

      Function Period() As Integer
         If Not me._periodLoaded Then
            If me.CodPeriodoCaixa <= 0 Then
               me.CodPeriodoCaixa = Data7.CodPeriodoCaixa()
            End If
            me._periodLoaded = True
         End If
         Period = me.CodPeriodoCaixa
      End Function

      Overrides Function Clone() As TTObject
         Dim copy As New LogContext()
         copy.CodEmpresa = me.CodEmpresa
         copy.CodFilial = me.CodFilial
         copy.CodUsuario = me.CodUsuario
         copy.CodPeriodoCaixa = me.CodPeriodoCaixa
         copy.NomeUsuario = me.NomeUsuario
         copy.NomeComputador = me.NomeComputador
         copy.UsuarioWindows = me.UsuarioWindows
         copy.NomeSistema = me.NomeSistema
         copy.VersaoSistema = me.VersaoSistema
         copy.NomeSchema = me.NomeSchema
         copy._versionLoaded = me._versionLoaded
         copy._periodLoaded = me._periodLoaded
         Clone = copy
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
