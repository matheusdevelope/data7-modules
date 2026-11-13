' data7:disable chained-global-function-assignment
' data7:disable duplicate-declaration
'
' Ambient
' Fachada do contexto da aplicacao. A consulta do ambiente, o JSON e a
' definicao da tabela ficam em namespaces proprios. Este modulo so
' orquestra a inicializacao e expoe a instancia unica.
'
' Uso:
'   Ambient.EnableCache()
'   Ambient.Initialize(codEmpresa, codFilial, codUsuario, codTabela, estacaoTrabalho, usuarioWindows, schemaTabela, nomeTabela, codigoProcessoTabela, tituloProcessoTabela, where)
'   Sistema, empresa, filial, usuario, sessao, periodo, estacao e banco
'   compartilham a key "ambient" e carregam so no primeiro Initialize.
'   A definicao recarrega quando CodTabela, schema ou nome mudam.
'   Processo usa CodTabela + CodigoProcessoTabela. Menu e MenuPai sao lidos em toda execucao.
'   Ambient.InternalWhere()
'   Ambient.Campos.LoadValues()
'
Imports ambient_query
Imports ambient_context
Imports ambient_database
Imports ambient_campo
Imports ambient_campos
Imports configurador_tabela
Imports configurador_grupotabela
Imports table_menu
Imports table_filial
Imports table_empresa
Imports table_usuario
Imports table_estacao
Imports table_sistema
Imports table_periodocaixa
Imports table_sessaoconexao
Imports table_processotabela

Namespace Ambient

   Private Dim _useCache As Boolean

   Private Dim _instance As TContext
   Private Dim _initializedMode As Boolean
   Private Dim _devMode As Boolean
   Private Dim _executorMode As Boolean
   Private Dim _logSecondsReady As Boolean

   Dim LogSeconds As Integer

   Sub EnableCache()
      _useCache = True
   End Sub

   Private Sub _EnsureLogSeconds()
      If _logSecondsReady Then
         Exit Sub
      End If
      If LogSeconds <= 0 Then
         LogSeconds = 3
      End If
      _logSecondsReady = True
   End Sub

   Sub ClearCache()
      If Assigned(_instance) Then
         _instance.Free()
         _instance = Null
      End If
      TContext.ClearPools()
   End Sub

   Private Function _Acquire() As TContext
      If Not Assigned(_instance) Then
         _instance = New TContext()
      End If
      _Acquire = _instance
   End Function

   Function Current() As TContext
      If Not Assigned(_instance) Then
         _instance = New TContext()
      End If
      Current = _instance
   End Function

   Function Instance() As TContext
      Instance = Current()
   End Function

   Function Data7Mode() As Boolean
      _EnsureMode()
      Data7Mode = Not _devMode And Not _executorMode
   End Function

   Function DevMode() As Boolean
      _EnsureMode()
      DevMode = _devMode
   End Function

   Function ExecutorMode() As Boolean
      _EnsureMode()
      ExecutorMode = _executorMode
   End Function

   Function CodEmpresa() As Integer
      _EnsureReady()
      CodEmpresa = Current().CodEmpresa
   End Function

   Function CodFilial() As Integer
      _EnsureReady()
      CodFilial = Current().CodFilial
   End Function

   Function CodUsuario() As Integer
      _EnsureReady()
      CodUsuario = Current().CodUsuario
   End Function

   Function InternalWhere(pWhere As String = "") As String
      _EnsureReady()
      If Trim(pWhere) <> "" Then
         InternalWhere = Current().Campos.ApplyWhere(pWhere)
      Else
         InternalWhere = Current().Campos.AppliedWhere
      End If
   End Function

   Function CodProcessoTabela() As Integer
      _EnsureReady()
      CodProcessoTabela = Current().CodProcessoTabela
   End Function

   Function TituloProcessoTabela() As String
      _EnsureReady()
      TituloProcessoTabela = Current().TituloProcessoTabela
   End Function

   Function Sistema() As TSistema
      _EnsureReady()
      Sistema = Current().Sistema
   End Function

   Function Estacao() As TEstacao
      _EnsureReady()
      Estacao = Current().Estacao
   End Function

   Function Empresa() As TEmpresa
      _EnsureReady()
      Empresa = Current().Empresa
   End Function

   Function Filial() As TFilial
      _EnsureReady()
      Filial = Current().Filial
   End Function

   Function Usuario() As TUsuario
      _EnsureReady()
      Usuario = Current().Usuario
   End Function

   Function Sessao() As TSessaoConexao
      _EnsureReady()
      Sessao = Current().Sessao
   End Function

   Function Periodo() As TPeriodoCaixa
      _EnsureReady()
      Periodo = Current().Periodo
   End Function

   Function Menu() As TMenu
      _EnsureReady()
      Menu = Current().Menu
   End Function

   Function MenuPai() As TMenu
      _EnsureReady()
      MenuPai = Current().MenuPai
   End Function

   Function Processo() As TProcessoTabela
      _EnsureReady()
      Processo = Current().Processo
   End Function

   Function Tabela() As configurador_tabela.Tabela
      _EnsureReady()
      Tabela = Current().Definicao
   End Function

   Function GrupoTabela() As configurador_grupotabela.GrupoTabela
      _EnsureReady()
      If Assigned(Current().Definicao) Then
         GrupoTabela = Current().Definicao.Grupo
      Else
         GrupoTabela = Null
      End If
   End Function

   Function CampoChave() As TCampoValue
      _EnsureReady()
      If Not Assigned(Current().CampoChave) Then
         Current().BindCampoChave()
      End If
      CampoChave = Current().CampoChave
   End Function

   Function Campos() As TCampoList
      _EnsureReady()
      Campos = Current().Campos
   End Function

   Function Database() As TDatabase
      _EnsureReady()
      Database = Current().Database
   End Function

   Function Definicao() As configurador_tabela.Tabela
      _EnsureReady()
      Definicao = Current().Definicao
   End Function

   Sub Initialize(pCodEmpresa As Integer, pCodFilial As Integer, pCodUsuario As Integer, pCodTabela As Integer, pStationName As String, pStationUser As String, pSchemaTabela As String = "", pNomeTabela As String = "", pCodProcessoTabela As Integer = 0, pTituloProcessoTabela As String = "", pWhere As String = "")
      _EnsureLogSeconds()
      Dim ctx As TContext = _Acquire()
      ctx.UseCache = _useCache
      ctx.Prepare(pCodEmpresa, pCodFilial, pCodUsuario, pCodTabela, pStationName, pStationUser, pSchemaTabela, pNomeTabela, pCodProcessoTabela, pTituloProcessoTabela, pWhere, LogSeconds)
      ctx.SetMode(Data7Mode(), DevMode(), ExecutorMode())
      ctx.OpenCaches()
      TAmbientQuery.Load(ctx)
      ctx.LoadDefinition()
      ctx.Finish()
   End Sub

   Function IsCached() As Boolean
      _EnsureReady()
      IsCached = Current().Cached
   End Function

   Function IsFromCache() As Boolean
      _EnsureReady()
      IsFromCache = Current().FromCache
   End Function

   Function ToString() As String
      _EnsureReady()
      ToString = Current().ToString()
   End Function

   Private Sub _EnsureReady()
      If Assigned(_instance) Then
         If _instance.IsReady Then
            Exit Sub
         End If
      End If
      Initialize(Data7.CodEmpresa(), Data7.CodFilial(), Data7.CodUsuario(), 0, Environment.MachineName(), Environment.UserName())
   End Sub

   Private Sub _EnsureMode()
      If _initializedMode Then
         Exit Sub
      End If
      Dim executable As String = UCase(Data7.NomeArquivoExecutavel)
      _devMode = executable.Contains("DEVSTUDIO")
      _executorMode = executable.Contains("EXECUTOR")
      _initializedMode = True
   End Sub

End Namespace
