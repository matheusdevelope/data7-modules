Imports mod_tobject
Imports table_sistema
Imports table_estacao
Imports table_empresa
Imports table_filial
Imports table_usuario
Imports table_sessaoconexao
Imports table_periodocaixa
Imports table_menu
Imports table_processotabela
Imports ambient_campo
Imports ambient_campos
Imports ambient_database
Imports TablesSql
Imports configurador_sql
Imports configurador_campo
Imports configurador_tabela
Imports mod_cache

Namespace ambient_context

   Structure TPlace
      Codigo As Integer
      Nome As String
      UF As String
   End Structure

   Class TContext
      Inherits TTObject

      CodEmpresa As Integer
      CodFilial As Integer
      CodUsuario As Integer
      CodTabela As Integer
      CodProcessoTabela As Integer
      TituloProcessoTabela As String
      SchemaTabela As String
      NomeTabela As String
      RecordWhere As String
      StationName As String
      StationUser As String
      LogSeconds As Integer
      IsReady As Boolean
      Cached As Boolean
      FromCache As Boolean
      UseCache As Boolean
      LoadAmbient As Boolean
      LoadDefinicao As Boolean
      TabelaCacheKey As String
      ModeData7 As Boolean
      ModeDev As Boolean
      ModeExecutor As Boolean
      UsuarioExpiresOn As TDateTime

      Sistema As TSistema
      Estacao As TEstacao
      Empresa As TEmpresa
      Filial As TFilial
      Usuario As TUsuario
      Sessao As TSessaoConexao
      Periodo As TPeriodoCaixa
      Menu As TMenu
      MenuPai As TMenu
      Processo As TProcessoTabela
      Definicao As configurador_tabela.Tabela
      CampoChave As TCampoValue
      Campos As TCampoList
      Database As TDatabase
      Modulo As TPlace

      Sub New()
         MyBase.New()
         me.IsReady = False
         me.Alloc()
      End Sub

      Sub Prepare(pCodEmpresa As Integer, pCodFilial As Integer, pCodUsuario As Integer, pCodTabela As Integer, pStationName As String, pStationUser As String, pSchemaTabela As String, pNomeTabela As String, pCodProcessoTabela As Integer, pTituloProcessoTabela As String, pWhere As String, pLogSeconds As Integer)
         me.CodTabela = pCodTabela
         me.CodProcessoTabela = pCodProcessoTabela
         me.TituloProcessoTabela = pTituloProcessoTabela
         me.SchemaTabela = pSchemaTabela
         me.NomeTabela = pNomeTabela
         me.RecordWhere = Trim(pWhere)
         me.LogSeconds = pLogSeconds
         If me.LogSeconds <= 0 Then
            me.LogSeconds = 3
         End If
         If Not me.HasAmbientCache() Then
            me.CodEmpresa = pCodEmpresa
            me.CodFilial = pCodFilial
            me.CodUsuario = pCodUsuario
            me.StationName = pStationName
            me.StationUser = pStationUser
            me.UsuarioExpiresOn = 0
         End If
         me.IsReady = False
      End Sub

      Sub SetMode(pData7 As Boolean, pDev As Boolean, pExecutor As Boolean)
         me.ModeData7 = pData7
         me.ModeDev = pDev
         me.ModeExecutor = pExecutor
      End Sub

      Sub LoadDefinition()
         If (me.CodTabela = 0) And (Trim(me.NomeTabela) = "") And Assigned(me.Processo) Then
            If me.Processo.CodTabela > 0 Then
               me.CodTabela = me.Processo.CodTabela
            End If
         End If
         If (me.CodTabela = 0) And (Trim(me.SchemaTabela) = "") And (Trim(me.NomeTabela) <> "") Then
            me.SchemaTabela = TSql.Dialect().DefaultSchema()
         End If
         me.TakeDefinicao()
      End Sub

      Sub Finish()
         If me.LoadAmbient Then
            me.DecryptUsuario()
         Else
            me.ApplyUsuarioExpiry()
         End If
         If Trim(me.Estacao.Nome) = "" Then
            me.Estacao.Nome = me.StationName
         End If
         me.Modulo.Codigo = me.Sessao.CodModulo
         me.Modulo.Nome = me.Sessao.NomeModulo
         me.Campos.Ready = True
         me.Campos.AppliedWhere = me.RecordWhere
         me.StoreCaches()
         me.Cached = me.UseCache
         me.FromCache = me.UseCache And (Not me.LoadAmbient) And (Not me.LoadDefinicao)
         me.IsReady = True
      End Sub

      Function FullTableName() As String
         If (Trim(me.SchemaTabela) <> "") And (Trim(me.NomeTabela) <> "") Then
            FullTableName = me.SchemaTabela & "." & me.NomeTabela
         Else
            FullTableName = me.NomeTabela
         End If
      End Function

      Function FullVersion() As String
         FullVersion = me.Sistema.Version
      End Function

      Function IsPeriodoOpen() As Boolean
         IsPeriodoOpen = me.Periodo.DataAbertura <> 0
      End Function

      Function IsPeriodoClosed() As Boolean
         IsPeriodoClosed = me.Periodo.DataFechamento <> 0
      End Function

      Function IsUsuarioGroup() As Boolean
         IsUsuarioGroup = TCfgFlag.Sim(me.Usuario.Grupo)
      End Function

      Function IsUsuarioBlocked() As Boolean
         IsUsuarioBlocked = TCfgFlag.Sim(me.Usuario.Bloqueado)
      End Function

      Function IsUsuarioExpired() As Boolean
         IsUsuarioExpired = (me.UsuarioExpiresOn <> 0) And (me.UsuarioExpiresOn < DateTime())
      End Function

      Overrides Function ToString() As String
         If Not Assigned(me.CampoChave) Then
            me.BindCampoChave()
         End If
         With me.BuildLogger("Ambient")
            .Prop("CodEmpresa", me.CodEmpresa)
            .Prop("CodFilial", me.CodFilial)
            .Prop("CodUsuario", me.CodUsuario)
            .Prop("CodProcessoTabela", me.CodProcessoTabela)
            .Prop("TituloProcessoTabela", me.TituloProcessoTabela)
            .Prop("InternalWhere", me.Campos.AppliedWhere)
            .Prop("Ready", me.IsReady)
            .Prop("Cached", me.Cached)
            .Prop("FromCache", me.FromCache)
            .Prop("Data7Mode", me.ModeData7)
            .Prop("DevMode", me.ModeDev)
            .Prop("ExecutorMode", me.ModeExecutor)
            .Prop("Version", me.FullVersion())
            .Prop("Database", me.Database.ToString())
            .Prop("Sistema", me.Sistema.ToString())
            .Prop("Empresa", me.Empresa.ToString())
            .Prop("Filial", me.Filial.ToString())
            .Prop("Usuario", me.Usuario.ToString())
            .Prop("Sessao", me.Sessao.ToString())
            .Prop("Periodo", me.Periodo.ToString())
            .Prop("Estacao", me.Estacao.ToString())
            .Prop("Menu", me.Menu.ToString())
            .Prop("MenuPai", me.MenuPai.ToString())
            .Prop("Processo", me.Processo.ToString())
            If Assigned(me.Definicao) Then
               .Prop("Tabela", me.Definicao.ToString())
               If Assigned(me.Definicao.Grupo) Then
                  .Prop("GrupoTabela", me.Definicao.Grupo.ToString())
               End If
            End If
            .Prop("Campos", "Total: " & CStr(me.Campos.Length))
            ' .Prop("Campos", me.Campos.ToString())
            .Prop("CamposChave", "Total: " & CStr(me.Campos.CountKeys()))
            If Assigned(me.CampoChave) Then
               .Prop("CampoChave", me.CampoChave.ToString())
            End If
            ToString = .Text
            .Free()
         End With
      End Function

      Sub OpenCaches()
         me.LoadAmbient = me.TakeAmbient()
         me.LoadDefinicao = False
         me.DropOwned(me.Menu)
         me.Menu = New TMenu()
         me.DropOwned(me.MenuPai)
         me.MenuPai = New TMenu()
         me.DropOwned(me.Processo)
         me.Processo = New TProcessoTabela()
      End Sub

      Private Sub TakeDefinicao()
         me.CampoChave = Null
         me.TabelaCacheKey = me.KeyTabela()
         Dim tableKey As String = me.TabelaCacheKey
         Dim cachedTable As configurador_tabela.Tabela
         Dim cachedFields As TCampoList = Null
         If me.UseCache Then
            cachedTable = Cache.Find<configurador_tabela.Tabela>(me.PoolTabela(), tableKey)
            cachedFields = Cache.Find<TCampoList>(me.PoolCampos(), tableKey)
         End If
         If Assigned(cachedTable) And Assigned(cachedFields) Then
            me.ReleaseIfOwned(me.PoolTabela(), me.Definicao)
            me.Definicao = cachedTable
            me.ReleaseIfOwned(me.PoolCampos(), me.Campos)
            me.Campos = cachedFields
            me.LoadDefinicao = False
            me.PublishCampos()
            me.BindCampoChave()
            Exit Sub
         End If
         me.ReleaseIfOwned(me.PoolTabela(), me.Definicao)
         me.Definicao = Null
         me.ReleaseIfOwned(me.PoolCampos(), me.Campos)
         me.Campos = New TCampoList()
         me.LoadDefinicao = True
         me.LoadTabela()
         me.PublishCampos()
         me.BindCampoChave()
      End Sub

      Private Sub LoadTabela()
         If me.CodTabela > 0 Then
            me.Definicao = New configurador_tabela.Tabela(me.CodTabela)
         ElseIf Trim(me.NomeTabela) <> "" Then
            Try
               me.Definicao = New configurador_tabela.Tabela(me.NomeTabela, me.SchemaTabela)
            Catch ex As Exception
               If Assigned(me.Definicao) Then
                  me.Definicao.Free()
                  me.Definicao = Null
               End If
            End Try
         End If
         If Assigned(me.Definicao) Then
            Dim tableCode As Integer = me.Definicao.CodTabela
            If tableCode > 0 Then
               me.CodTabela = tableCode
            End If
            If Trim(me.Definicao.Nome) <> "" Then
               me.NomeTabela = me.Definicao.Nome
            End If
            If Trim(me.Definicao.NomeSchema) <> "" Then
               me.SchemaTabela = me.Definicao.NomeSchema
            End If
            If me.CodUsuario > 0 Then
               me.Definicao.CarregarAcessos(me.CodUsuario)
            End If
            me.Definicao.VerificarCamposFisicos(True)
            me.Campos.Build(me.Definicao)
         Else
            me.Campos.BuildPhysical(me.SchemaTabela, me.NomeTabela)
         End If
      End Sub

      Sub BindCampoChave()
         me.CampoChave = Null
         If Not Assigned(me.Campos) Then
            Exit Sub
         End If
         If Assigned(me.Definicao) Then
            Dim _auto As Campo = me.Definicao.CampoAutoIncremento()
            If Assigned(_auto) Then
               me.CampoChave = me.Campos.FindByNameCI(_auto.Nome)
               If Assigned(me.CampoChave) Then
                  Exit Sub
               End If
            End If
         End If
         Dim tname As String = UCase(Trim(me.NomeTabela))
         Dim i As Integer
         Dim last As Integer = me.Campos.Length - 1
         For i = 0 To last
            Dim item As TCampoValue = me.Campos.Take(i)
            If item.IsPrimaryKey Then
               Dim cname As String = UCase(Trim(item.Nome))
               Dim skipEmpresa As Boolean = (cname = "CODEMPRESA") And (tname <> "EMPRESA")
               Dim skipFilial As Boolean = (cname = "CODFILIAL") And (tname <> "FILIAL")
               If (Not skipEmpresa) And (Not skipFilial) Then
                  me.CampoChave = item
                  Exit Sub
               End If
            End If
         Next
         me.CampoChave = Null
      End Sub

      Private Sub PublishCampos()
         Dim tableCode As Integer = me.CodTabela
         If tableCode <= 0 Then
            tableCode = me.Campos.CodTabela
         End If
         Dim companyCode As Integer = me.CodEmpresa
         Dim branchCode As Integer = me.CodFilial
         Dim schemaName As String = me.SchemaTabela
         Dim tableName As String = me.NomeTabela
         If Trim(schemaName) = "" Then
            schemaName = me.Campos.SchemaTabela
         End If
         If Trim(tableName) = "" Then
            tableName = me.Campos.NomeTabela
         End If
         me.CodTabela = tableCode
         me.SchemaTabela = schemaName
         me.NomeTabela = tableName
         me.Campos.CodEmpresa = companyCode
         me.Campos.CodFilial = branchCode
         me.Campos.CodTabela = tableCode
         me.Campos.SchemaTabela = schemaName
         me.Campos.NomeTabela = tableName
      End Sub

      Private Sub DecryptUsuario()
         me.Usuario.NomeCompleto = me.Decrypt(me.Usuario.NomeCompleto)
         me.Usuario.Senha = me.Decrypt(me.Usuario.Senha)
         me.Usuario.Bloqueado = me.Decrypt(me.Usuario.Bloqueado)
         me.Usuario.DataValidade = Trim(me.Decrypt(me.Usuario.DataValidade))
         me.ApplyUsuarioExpiry()
      End Sub

      Private Sub ApplyUsuarioExpiry()
         me.UsuarioExpiresOn = 0
         If Not Assigned(me.Usuario) Then
            Exit Sub
         End If
         Dim expiresText As String = Trim(me.Usuario.DataValidade)
         If expiresText <> "" And expiresText <> "00/00/0000" Then
            me.UsuarioExpiresOn = StrToDate(expiresText)
         End If
      End Sub

      Private Function Decrypt(pValue As String) As String
         Dim raw As String = Trim(pValue)
         If raw = "" Then
            Decrypt = ""
            Exit Function
         End If
         Dim result As String
         Try
            result = Data7.Descriptografar(raw)
         Catch ex As Exception
            result = raw
         End Try
         Decrypt = result
      End Function

      Private Sub Alloc()
         me.FreeObjects()
         me.Sistema = New TSistema()
         me.Estacao = New TEstacao()
         me.Empresa = New TEmpresa()
         me.Filial = New TFilial()
         me.Usuario = New TUsuario()
         me.Sessao = New TSessaoConexao()
         me.Periodo = New TPeriodoCaixa()
         me.Menu = New TMenu()
         me.MenuPai = New TMenu()
         me.Processo = New TProcessoTabela()
         me.Definicao = Null
         me.CampoChave = Null
         me.Campos = New TCampoList()
         me.Database = New TDatabase()
      End Sub

      Private Function PoolSistema() As String
         PoolSistema = "Ambient.Sistema"
      End Function

      Private Function PoolEmpresa() As String
         PoolEmpresa = "Ambient.Empresa"
      End Function

      Private Function PoolFilial() As String
         PoolFilial = "Ambient.Filial"
      End Function

      Private Function PoolUsuario() As String
         PoolUsuario = "Ambient.Usuario"
      End Function

      Private Function PoolSessao() As String
         PoolSessao = "Ambient.Sessao"
      End Function

      Private Function PoolPeriodo() As String
         PoolPeriodo = "Ambient.Periodo"
      End Function

      Private Function PoolEstacao() As String
         PoolEstacao = "Ambient.Estacao"
      End Function

      Private Function PoolDatabase() As String
         PoolDatabase = "Ambient.Database"
      End Function

      Private Function PoolTabela() As String
         PoolTabela = "Ambient.Tabela"
      End Function

      Private Function PoolCampos() As String
         PoolCampos = "Ambient.Campos"
      End Function

      Private Function KeyAmbient() As String
         KeyAmbient = "Ambient"
      End Function

      Private Function KeyTabela() As String
         KeyTabela = CStr(me.CodTabela) & ";" & UCase(Trim(me.SchemaTabela)) & ";" & UCase(Trim(me.NomeTabela))
      End Function

      Private Function HasAmbientCache() As Boolean
         If Not me.UseCache Then
            HasAmbientCache = False
            Exit Function
         End If
         Dim ambientKey As String = me.KeyAmbient()
         HasAmbientCache = Assigned(Cache.Find<TSistema>(me.PoolSistema(), ambientKey)) And Assigned(Cache.Find<TEmpresa>(me.PoolEmpresa(), ambientKey)) And Assigned(Cache.Find<TFilial>(me.PoolFilial(), ambientKey)) And Assigned(Cache.Find<TUsuario>(me.PoolUsuario(), ambientKey)) And Assigned(Cache.Find<TSessaoConexao>(me.PoolSessao(), ambientKey)) And Assigned(Cache.Find<TPeriodoCaixa>(me.PoolPeriodo(), ambientKey)) And Assigned(Cache.Find<TEstacao>(me.PoolEstacao(), ambientKey)) And Assigned(Cache.Find<TDatabase>(me.PoolDatabase(), ambientKey))
      End Function

      Private Function TakeAmbient() As Boolean
         If me.HasAmbientCache() Then
            Dim ambientKey As String = me.KeyAmbient()
            me.ReleaseIfOwned(me.PoolSistema(), me.Sistema)
            me.Sistema = Cache.Find<TSistema>(me.PoolSistema(), ambientKey)
            me.ReleaseIfOwned(me.PoolEmpresa(), me.Empresa)
            me.Empresa = Cache.Find<TEmpresa>(me.PoolEmpresa(), ambientKey)
            me.ReleaseIfOwned(me.PoolFilial(), me.Filial)
            me.Filial = Cache.Find<TFilial>(me.PoolFilial(), ambientKey)
            me.ReleaseIfOwned(me.PoolUsuario(), me.Usuario)
            me.Usuario = Cache.Find<TUsuario>(me.PoolUsuario(), ambientKey)
            me.ReleaseIfOwned(me.PoolSessao(), me.Sessao)
            me.Sessao = Cache.Find<TSessaoConexao>(me.PoolSessao(), ambientKey)
            me.ReleaseIfOwned(me.PoolPeriodo(), me.Periodo)
            me.Periodo = Cache.Find<TPeriodoCaixa>(me.PoolPeriodo(), ambientKey)
            me.ReleaseIfOwned(me.PoolEstacao(), me.Estacao)
            me.Estacao = Cache.Find<TEstacao>(me.PoolEstacao(), ambientKey)
            me.ReleaseIfOwned(me.PoolDatabase(), me.Database)
            me.Database = Cache.Find<TDatabase>(me.PoolDatabase(), ambientKey)
            TakeAmbient = False
            Exit Function
         End If
         me.ReleaseIfOwned(me.PoolSistema(), me.Sistema)
         me.Sistema = New TSistema()
         me.ReleaseIfOwned(me.PoolEmpresa(), me.Empresa)
         me.Empresa = New TEmpresa()
         me.ReleaseIfOwned(me.PoolFilial(), me.Filial)
         me.Filial = New TFilial()
         me.ReleaseIfOwned(me.PoolUsuario(), me.Usuario)
         me.Usuario = New TUsuario()
         me.ReleaseIfOwned(me.PoolSessao(), me.Sessao)
         me.Sessao = New TSessaoConexao()
         me.ReleaseIfOwned(me.PoolPeriodo(), me.Periodo)
         me.Periodo = New TPeriodoCaixa()
         me.ReleaseIfOwned(me.PoolEstacao(), me.Estacao)
         me.Estacao = New TEstacao()
         me.ReleaseIfOwned(me.PoolDatabase(), me.Database)
         me.Database = New TDatabase()
         TakeAmbient = True
      End Function

      Private Sub StoreCaches()
         If Not me.UseCache Then
            Exit Sub
         End If
         If me.LoadAmbient Then
            Dim ambientKey As String = me.KeyAmbient()
            If Assigned(me.Sistema) Then
               Cache.Put(me.PoolSistema(), ambientKey, me.Sistema)
            End If
            If Assigned(me.Empresa) Then
               Cache.Put(me.PoolEmpresa(), ambientKey, me.Empresa)
            End If
            If Assigned(me.Filial) Then
               Cache.Put(me.PoolFilial(), ambientKey, me.Filial)
            End If
            If Assigned(me.Usuario) Then
               Cache.Put(me.PoolUsuario(), ambientKey, me.Usuario)
            End If
            If Assigned(me.Sessao) Then
               Cache.Put(me.PoolSessao(), ambientKey, me.Sessao)
            End If
            If Assigned(me.Periodo) Then
               Cache.Put(me.PoolPeriodo(), ambientKey, me.Periodo)
            End If
            If Assigned(me.Estacao) Then
               Cache.Put(me.PoolEstacao(), ambientKey, me.Estacao)
            End If
            If Assigned(me.Database) Then
               Cache.Put(me.PoolDatabase(), ambientKey, me.Database)
            End If
         End If
         If me.LoadDefinicao And Assigned(me.Definicao) Then
            Cache.Put(me.PoolTabela(), me.TabelaCacheKey, me.Definicao)
         End If
         If me.LoadDefinicao And Assigned(me.Campos) Then
            Cache.Put(me.PoolCampos(), me.TabelaCacheKey, me.Campos)
         End If
      End Sub

      Shared Sub ClearPools()
         Cache.ClearPool(me.PoolSistema())
         Cache.ClearPool(me.PoolEmpresa())
         Cache.ClearPool(me.PoolFilial())
         Cache.ClearPool(me.PoolUsuario())
         Cache.ClearPool(me.PoolSessao())
         Cache.ClearPool(me.PoolPeriodo())
         Cache.ClearPool(me.PoolEstacao())
         Cache.ClearPool(me.PoolDatabase())
         Cache.ClearPool(me.PoolTabela())
         Cache.ClearPool(me.PoolCampos())
      End Sub

      Private Sub ReleaseIfOwned(pPool As String, pObject As TObject)
         If Not Assigned(pObject) Then
            Exit Sub
         End If
         If me.UseCache And Cache.ContainsObject(pPool, pObject) Then
            Exit Sub
         End If
         pObject.Free()
      End Sub

      Private Sub DropOwned(pObject As TObject)
         If Assigned(pObject) Then
            pObject.Free()
         End If
      End Sub

      Private Sub FreeObjects()
         me.ReleaseIfOwned(me.PoolSistema(), me.Sistema)
         me.Sistema = Null
         me.ReleaseIfOwned(me.PoolEmpresa(), me.Empresa)
         me.Empresa = Null
         me.ReleaseIfOwned(me.PoolFilial(), me.Filial)
         me.Filial = Null
         me.ReleaseIfOwned(me.PoolUsuario(), me.Usuario)
         me.Usuario = Null
         me.ReleaseIfOwned(me.PoolSessao(), me.Sessao)
         me.Sessao = Null
         me.ReleaseIfOwned(me.PoolPeriodo(), me.Periodo)
         me.Periodo = Null
         me.ReleaseIfOwned(me.PoolEstacao(), me.Estacao)
         me.Estacao = Null
         me.DropOwned(me.Menu)
         me.Menu = Null
         me.DropOwned(me.MenuPai)
         me.MenuPai = Null
         me.DropOwned(me.Processo)
         me.Processo = Null
         me.ReleaseIfOwned(me.PoolTabela(), me.Definicao)
         me.Definicao = Null
         me.CampoChave = Null
         me.ReleaseIfOwned(me.PoolCampos(), me.Campos)
         me.Campos = Null
         me.ReleaseIfOwned(me.PoolDatabase(), me.Database)
         me.Database = Null
      End Sub

      Overrides Sub Dispose()
         me.FreeObjects()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
