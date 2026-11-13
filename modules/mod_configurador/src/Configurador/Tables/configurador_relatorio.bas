Imports configurador_sql
Imports configurador_tcfgbase


Namespace configurador_relatorio

   Class LayoutRelatorio
      Inherits TCfgBase
      CodRelatorio As Integer
      Item As String
      Titulo As String
      Ordem As Integer
      Ajuda As String
      Exemplo As String
      Ativo As String
      Arquivo As String
      NumeroCopia As Integer
      ImpressoraPadrao As String
      Orientacao As String
      TamanhoPapel As Integer
      Largura As Integer
      Altura As Integer
      Selecionado As String
      Solicitar As String
      Aviso As String
      Acao As String
      NomeArquivo As String
      CodUsuario As Integer
      CodEstacao As Integer
      CodEmpresa As Integer
      CodFilial As Integer
      ArquivoFisico As String
      CodGrupoLayoutRelatorio As Integer
      Repx As String
      SalvarAutomaticamenteEmDisco As String
      PastaSalvarAutomaticamenteEmDisco As String
      CodProjeto As Integer
      ImprimirCapa As String
      ExibirParametroCapaVazio As String
      Obrigatorio As String

      Sub New()
         MyBase.New("LayoutRelatorio")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodRelatorio = TCfgRow.AsInteger(pJson.GetString("codrelatorio"))
         me.Item = TCfgRow.AsString(pJson.GetString("item"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.Ordem = TCfgRow.AsInteger(pJson.GetString("ordem"))
         me.Ajuda = TCfgRow.AsString(pJson.GetString("ajuda"))
         me.Exemplo = TCfgRow.AsString(pJson.GetString("exemplo"))
         me.Ativo = TCfgRow.AsString(pJson.GetString("ativo"))
         me.Arquivo = TCfgRow.AsString(pJson.GetString("arquivo"))
         me.NumeroCopia = TCfgRow.AsInteger(pJson.GetString("numerocopia"))
         me.ImpressoraPadrao = TCfgRow.AsString(pJson.GetString("impressorapadrao"))
         me.Orientacao = TCfgRow.AsString(pJson.GetString("orientacao"))
         me.TamanhoPapel = TCfgRow.AsInteger(pJson.GetString("tamanhopapel"))
         me.Largura = TCfgRow.AsInteger(pJson.GetString("largura"))
         me.Altura = TCfgRow.AsInteger(pJson.GetString("altura"))
         me.Selecionado = TCfgRow.AsString(pJson.GetString("selecionado"))
         me.Solicitar = TCfgRow.AsString(pJson.GetString("solicitar"))
         me.Aviso = TCfgRow.AsString(pJson.GetString("aviso"))
         me.Acao = TCfgRow.AsString(pJson.GetString("acao"))
         me.NomeArquivo = TCfgRow.AsString(pJson.GetString("nomearquivo"))
         me.CodUsuario = TCfgRow.AsInteger(pJson.GetString("codusuario"))
         me.CodEstacao = TCfgRow.AsInteger(pJson.GetString("codestacao"))
         me.CodEmpresa = TCfgRow.AsInteger(pJson.GetString("codempresa"))
         me.CodFilial = TCfgRow.AsInteger(pJson.GetString("codfilial"))
         me.ArquivoFisico = TCfgRow.AsString(pJson.GetString("arquivofisico"))
         me.CodGrupoLayoutRelatorio = TCfgRow.AsInteger(pJson.GetString("codgrupolayoutrelatorio"))
         me.Repx = TCfgRow.AsString(pJson.GetString("repx"))
         me.SalvarAutomaticamenteEmDisco = TCfgRow.AsString(pJson.GetString("salvarautomaticamenteemdisco"))
         me.PastaSalvarAutomaticamenteEmDisco = TCfgRow.AsString(pJson.GetString("pastasalvarautomaticamenteemdisco"))
         me.CodProjeto = TCfgRow.AsInteger(pJson.GetString("codprojeto"))
         me.ImprimirCapa = TCfgRow.AsString(pJson.GetString("imprimircapa"))
         me.ExibirParametroCapaVazio = TCfgRow.AsString(pJson.GetString("exibirparametrocapavazio"))
         me.Obrigatorio = TCfgRow.AsString(pJson.GetString("obrigatorio"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodRelatorio = pQuery.Field("codrelatorio").AsInteger
         me.Item = pQuery.Field("item").AsString
         me.Titulo = pQuery.Field("titulo").AsString
         me.Ordem = pQuery.Field("ordem").AsInteger
         me.Ajuda = pQuery.Field("ajuda").AsString
         me.Exemplo = pQuery.Field("exemplo").AsString
         me.Ativo = pQuery.Field("ativo").AsString
         me.Arquivo = pQuery.Field("arquivo").AsString
         me.NumeroCopia = pQuery.Field("numerocopia").AsInteger
         me.ImpressoraPadrao = pQuery.Field("impressorapadrao").AsString
         me.Orientacao = pQuery.Field("orientacao").AsString
         me.TamanhoPapel = pQuery.Field("tamanhopapel").AsInteger
         me.Largura = pQuery.Field("largura").AsInteger
         me.Altura = pQuery.Field("altura").AsInteger
         me.Selecionado = pQuery.Field("selecionado").AsString
         me.Solicitar = pQuery.Field("solicitar").AsString
         me.Aviso = pQuery.Field("aviso").AsString
         me.Acao = pQuery.Field("acao").AsString
         me.NomeArquivo = pQuery.Field("nomearquivo").AsString
         me.CodUsuario = pQuery.Field("codusuario").AsInteger
         me.CodEstacao = pQuery.Field("codestacao").AsInteger
         me.CodEmpresa = pQuery.Field("codempresa").AsInteger
         me.CodFilial = pQuery.Field("codfilial").AsInteger
         me.ArquivoFisico = pQuery.Field("arquivofisico").AsString
         me.CodGrupoLayoutRelatorio = pQuery.Field("codgrupolayoutrelatorio").AsInteger
         me.Repx = pQuery.Field("repx").AsString
         me.SalvarAutomaticamenteEmDisco = pQuery.Field("salvarautomaticamenteemdisco").AsString
         me.PastaSalvarAutomaticamenteEmDisco = pQuery.Field("pastasalvarautomaticamenteemdisco").AsString
         me.CodProjeto = pQuery.Field("codprojeto").AsInteger
         me.ImprimirCapa = pQuery.Field("imprimircapa").AsString
         me.ExibirParametroCapaVazio = pQuery.Field("exibirparametrocapavazio").AsString
         me.Obrigatorio = pQuery.Field("obrigatorio").AsString
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodRelatorio", me.CodRelatorio)
            .Prop("Item", me.Item)
            .Prop("Titulo", me.Titulo)
            .Prop("Ordem", me.Ordem)
            .Prop("Ajuda", me.Ajuda)
            .Prop("Exemplo", me.Exemplo)
            .Prop("Ativo", me.Ativo)
            .Prop("Arquivo", me.Arquivo)
            .Prop("NumeroCopia", me.NumeroCopia)
            .Prop("ImpressoraPadrao", me.ImpressoraPadrao)
            .Prop("Orientacao", me.Orientacao)
            .Prop("TamanhoPapel", me.TamanhoPapel)
            .Prop("Largura", me.Largura)
            .Prop("Altura", me.Altura)
            .Prop("Selecionado", me.Selecionado)
            .Prop("Solicitar", me.Solicitar)
            .Prop("Aviso", me.Aviso)
            .Prop("Acao", me.Acao)
            .Prop("NomeArquivo", me.NomeArquivo)
            .Prop("CodUsuario", me.CodUsuario)
            .Prop("CodEstacao", me.CodEstacao)
            .Prop("CodEmpresa", me.CodEmpresa)
            .Prop("CodFilial", me.CodFilial)
            .Prop("ArquivoFisico", me.ArquivoFisico)
            .Prop("CodGrupoLayoutRelatorio", me.CodGrupoLayoutRelatorio)
            .Prop("Repx", me.Repx)
            .Prop("SalvarAutomaticamenteEmDisco", me.SalvarAutomaticamenteEmDisco)
            .Prop("PastaSalvarAutomaticamenteEmDisco", me.PastaSalvarAutomaticamenteEmDisco)
            .Prop("CodProjeto", me.CodProjeto)
            .Prop("ImprimirCapa", me.ImprimirCapa)
            .Prop("ExibirParametroCapaVazio", me.ExibirParametroCapaVazio)
            .Prop("Obrigatorio", me.Obrigatorio)
            ToString = .Text
            .Free()
         End With
      End Function


      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, item") As TTList<LayoutRelatorio>
         Dim query As SQL.Command = TCfgDb.Abrir("", "LayoutRelatorio", pWhere, pOrder)
         Dim lista[] As LayoutRelatorio = []
         While Not query.Eof
            Dim item As New LayoutRelatorio()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class GrupoLayoutRelatorio
      Inherits TCfgBase
      CodRelatorio As Integer
      CodGrupoLayoutRelatorio As Integer
      Descricao As String
      CodGrupoLayoutRelatorioInferior As Integer
      Ordem As Integer

      Sub New()
         MyBase.New("GrupoLayoutRelatorio")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodRelatorio = TCfgRow.AsInteger(pJson.GetString("codrelatorio"))
         me.CodGrupoLayoutRelatorio = TCfgRow.AsInteger(pJson.GetString("codgrupolayoutrelatorio"))
         me.Descricao = TCfgRow.AsString(pJson.GetString("descricao"))
         me.CodGrupoLayoutRelatorioInferior = TCfgRow.AsInteger(pJson.GetString("codgrupolayoutrelatorioinferior"))
         me.Ordem = TCfgRow.AsInteger(pJson.GetString("ordem"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodRelatorio = pQuery.Field("codrelatorio").AsInteger
         me.CodGrupoLayoutRelatorio = pQuery.Field("codgrupolayoutrelatorio").AsInteger
         me.Descricao = pQuery.Field("descricao").AsString
         me.CodGrupoLayoutRelatorioInferior = pQuery.Field("codgrupolayoutrelatorioinferior").AsInteger
         me.Ordem = pQuery.Field("ordem").AsInteger
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodRelatorio", me.CodRelatorio)
            .Prop("CodGrupoLayoutRelatorio", me.CodGrupoLayoutRelatorio)
            .Prop("Descricao", me.Descricao)
            .Prop("CodGrupoLayoutRelatorioInferior", me.CodGrupoLayoutRelatorioInferior)
            .Prop("Ordem", me.Ordem)
            ToString = .Text
            .Free()
         End With
      End Function


      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY ordem, descricao") As TTList<GrupoLayoutRelatorio>
         Dim query As SQL.Command = TCfgDb.Abrir("Dicionario", "GrupoLayoutRelatorio", pWhere, pOrder)
         Dim lista[] As GrupoLayoutRelatorio = []
         While Not query.Eof
            Dim item As New GrupoLayoutRelatorio()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class EnvioEmailLayout
      Inherits TCfgBase
      CodRelatorio As Integer
      Item As String
      Destinatario As String
      Assunto As String
      Conteudo As String
      TipoValores As String
      FormaEnvio As String

      Sub New()
         MyBase.New("EnvioEmailLayout")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodRelatorio = TCfgRow.AsInteger(pJson.GetString("codrelatorio"))
         me.Item = TCfgRow.AsString(pJson.GetString("item"))
         me.Destinatario = TCfgRow.AsString(pJson.GetString("destinatario"))
         me.Assunto = TCfgRow.AsString(pJson.GetString("assunto"))
         me.Conteudo = TCfgRow.AsString(pJson.GetString("conteudo"))
         me.TipoValores = TCfgRow.AsString(pJson.GetString("tipovalores"))
         me.FormaEnvio = TCfgRow.AsString(pJson.GetString("formaenvio"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodRelatorio = pQuery.Field("codrelatorio").AsInteger
         me.Item = pQuery.Field("item").AsString
         me.Destinatario = pQuery.Field("destinatario").AsString
         me.Assunto = pQuery.Field("assunto").AsString
         me.Conteudo = pQuery.Field("conteudo").AsString
         me.TipoValores = pQuery.Field("tipovalores").AsString
         me.FormaEnvio = pQuery.Field("formaenvio").AsString
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodRelatorio", me.CodRelatorio)
            .Prop("Item", me.Item)
            .Prop("Destinatario", me.Destinatario)
            .Prop("Assunto", me.Assunto)
            .Prop("Conteudo", me.Conteudo)
            .Prop("TipoValores", me.TipoValores)
            .Prop("FormaEnvio", me.FormaEnvio)
            ToString = .Text
            .Free()
         End With
      End Function


      Shared Function Fetch(pWhere As String, pOrder As String = "") As TTList<EnvioEmailLayout>
         Dim query As SQL.Command = TCfgDb.Abrir("", "EnvioEmailLayoutRelatorio", pWhere, pOrder)
         Dim lista[] As EnvioEmailLayout = []
         While Not query.Eof
            Dim item As New EnvioEmailLayout()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class GrupoRelatorio
      Inherits TCfgBase
      CodGrupoRelatorio As Integer
      Descricao As String
      Ordem As Integer
      CodGrupoRelatorioInferior As Integer

      Sub New()
         MyBase.New("GrupoRelatorio")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodGrupoRelatorio = TCfgRow.AsInteger(pJson.GetString("codgruporelatorio"))
         me.Descricao = TCfgRow.AsString(pJson.GetString("descricao"))
         me.Ordem = TCfgRow.AsInteger(pJson.GetString("ordem"))
         me.CodGrupoRelatorioInferior = TCfgRow.AsInteger(pJson.GetString("codgruporelatorioinferior"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodGrupoRelatorio = pQuery.Field("codgruporelatorio").AsInteger
         me.Descricao = pQuery.Field("descricao").AsString
         me.Ordem = pQuery.Field("ordem").AsInteger
         me.CodGrupoRelatorioInferior = pQuery.Field("codgruporelatorioinferior").AsInteger
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodGrupoRelatorio", me.CodGrupoRelatorio)
            .Prop("Descricao", me.Descricao)
            .Prop("Ordem", me.Ordem)
            .Prop("CodGrupoRelatorioInferior", me.CodGrupoRelatorioInferior)
            ToString = .Text
            .Free()
         End With
      End Function


      Shared Function Find(pCodGrupoRelatorio As Integer) As GrupoRelatorio
         Dim query As SQL.Command = TCfgDb.Abrir("Dicionario", "GrupoRelatorio", TCfgSql.EqInt("codgruporelatorio", pCodGrupoRelatorio), "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New GrupoRelatorio()
            item.Fill(query)
            query.Close()
            query.Free()
            Find = item
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class WhatsAppEnvio
      Inherits TCfgBase
      CodWhatsAppConfiguracoesEnvio As Integer
      Descricao As String
      ExibirFormularioEnvio As String
      OrigemContatoPadrao As String
      ValorContatoPadrao As String
      OrigemListaContatos As String
      ValorListaContatos As String
      OrigemAssunto As String
      ValorAssunto As String
      OrigemCorpoMensagem As String
      ValorCorpoMensagem As String
      OrigemAssinatura As String
      ValorAssinatura As String
      Observacoes As String
      Teste_CodTabela As Integer
      Teste_CodRelatorio As Integer
      Teste_FiltroSQL As String

      Sub New()
         MyBase.New("WhatsAppEnvio")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodWhatsAppConfiguracoesEnvio = TCfgRow.AsInteger(pJson.GetString("codwhatsappconfiguracoesenvio"))
         me.Descricao = TCfgRow.AsString(pJson.GetString("descricao"))
         me.ExibirFormularioEnvio = TCfgRow.AsString(pJson.GetString("exibirformularioenvio"))
         me.OrigemContatoPadrao = TCfgRow.AsString(pJson.GetString("origemcontatopadrao"))
         me.ValorContatoPadrao = TCfgRow.AsString(pJson.GetString("valorcontatopadrao"))
         me.OrigemListaContatos = TCfgRow.AsString(pJson.GetString("origemlistacontatos"))
         me.ValorListaContatos = TCfgRow.AsString(pJson.GetString("valorlistacontatos"))
         me.OrigemAssunto = TCfgRow.AsString(pJson.GetString("origemassunto"))
         me.ValorAssunto = TCfgRow.AsString(pJson.GetString("valorassunto"))
         me.OrigemCorpoMensagem = TCfgRow.AsString(pJson.GetString("origemcorpomensagem"))
         me.ValorCorpoMensagem = TCfgRow.AsString(pJson.GetString("valorcorpomensagem"))
         me.OrigemAssinatura = TCfgRow.AsString(pJson.GetString("origemassinatura"))
         me.ValorAssinatura = TCfgRow.AsString(pJson.GetString("valorassinatura"))
         me.Observacoes = TCfgRow.AsString(pJson.GetString("observacoes"))
         me.Teste_CodTabela = TCfgRow.AsInteger(pJson.GetString("teste_codtabela"))
         me.Teste_CodRelatorio = TCfgRow.AsInteger(pJson.GetString("teste_codrelatorio"))
         me.Teste_FiltroSQL = TCfgRow.AsString(pJson.GetString("teste_filtrosql"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodWhatsAppConfiguracoesEnvio = pQuery.Field("codwhatsappconfiguracoesenvio").AsInteger
         me.Descricao = pQuery.Field("descricao").AsString
         me.ExibirFormularioEnvio = pQuery.Field("exibirformularioenvio").AsString
         me.OrigemContatoPadrao = pQuery.Field("origemcontatopadrao").AsString
         me.ValorContatoPadrao = pQuery.Field("valorcontatopadrao").AsString
         me.OrigemListaContatos = pQuery.Field("origemlistacontatos").AsString
         me.ValorListaContatos = pQuery.Field("valorlistacontatos").AsString
         me.OrigemAssunto = pQuery.Field("origemassunto").AsString
         me.ValorAssunto = pQuery.Field("valorassunto").AsString
         me.OrigemCorpoMensagem = pQuery.Field("origemcorpomensagem").AsString
         me.ValorCorpoMensagem = pQuery.Field("valorcorpomensagem").AsString
         me.OrigemAssinatura = pQuery.Field("origemassinatura").AsString
         me.ValorAssinatura = pQuery.Field("valorassinatura").AsString
         me.Observacoes = pQuery.Field("observacoes").AsString
         me.Teste_CodTabela = pQuery.Field("teste_codtabela").AsInteger
         me.Teste_CodRelatorio = pQuery.Field("teste_codrelatorio").AsInteger
         me.Teste_FiltroSQL = pQuery.Field("teste_filtrosql").AsString
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodWhatsAppConfiguracoesEnvio", me.CodWhatsAppConfiguracoesEnvio)
            .Prop("Descricao", me.Descricao)
            .Prop("ExibirFormularioEnvio", me.ExibirFormularioEnvio)
            .Prop("OrigemContatoPadrao", me.OrigemContatoPadrao)
            .Prop("ValorContatoPadrao", me.ValorContatoPadrao)
            .Prop("OrigemListaContatos", me.OrigemListaContatos)
            .Prop("ValorListaContatos", me.ValorListaContatos)
            .Prop("OrigemAssunto", me.OrigemAssunto)
            .Prop("ValorAssunto", me.ValorAssunto)
            .Prop("OrigemCorpoMensagem", me.OrigemCorpoMensagem)
            .Prop("ValorCorpoMensagem", me.ValorCorpoMensagem)
            .Prop("OrigemAssinatura", me.OrigemAssinatura)
            .Prop("ValorAssinatura", me.ValorAssinatura)
            .Prop("Observacoes", me.Observacoes)
            .Prop("Teste_CodTabela", me.Teste_CodTabela)
            .Prop("Teste_CodRelatorio", me.Teste_CodRelatorio)
            .Prop("Teste_FiltroSQL", me.Teste_FiltroSQL)
            ToString = .Text
            .Free()
         End With
      End Function


      Shared Function Find(pCod As Integer) As WhatsAppEnvio
         Dim query As SQL.Command = TCfgDb.Abrir("Dicionario", "WhatsAppConfiguracoesEnvio", TCfgSql.EqInt("codwhatsappconfiguracoesenvio", pCod), "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New WhatsAppEnvio()
            item.Fill(query)
            query.Close()
            query.Free()
            Find = item
         End If
      End Function

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

   Class Relatorio
      Inherits TCfgBase
      CodRelatorio As Integer
      Titulo As String
      CodGrupoRelatorio As Integer
      CodWhatsAppConfiguracoesEnvio As Integer
      Layouts[] As LayoutRelatorio
      GruposLayout[] As GrupoLayoutRelatorio
      EnviosEmail[] As EnvioEmailLayout
      Grupo As GrupoRelatorio
      WhatsApp As WhatsAppEnvio

      Sub New()
         MyBase.New("Relatorio")
         me.InitColecoes()
      End Sub

      Sub New(pCodRelatorio As Integer)
         MyBase.New("Relatorio")
         me.InitColecoes()
         If Not me.LerPorCodigo(pCodRelatorio) Then
            Throw New Exception("Relatório não encontrado: codrelatorio=" & CStr(pCodRelatorio))
         End If
         me.CarregarRelacionados()
      End Sub

      Private Sub InitColecoes()
         me.Layouts = []
         me.GruposLayout = []
         me.EnviosEmail = []
         me.Grupo = Null
         me.WhatsApp = Null
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodRelatorio = TCfgRow.AsInteger(pJson.GetString("codrelatorio"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.CodGrupoRelatorio = TCfgRow.AsInteger(pJson.GetString("codgruporelatorio"))
         me.CodWhatsAppConfiguracoesEnvio = TCfgRow.AsInteger(pJson.GetString("codwhatsappconfiguracoesenvio"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodRelatorio = pQuery.Field("codrelatorio").AsInteger
         me.Titulo = pQuery.Field("titulo").AsString
         me.CodGrupoRelatorio = pQuery.Field("codgruporelatorio").AsInteger
         me.CodWhatsAppConfiguracoesEnvio = pQuery.Field("codwhatsappconfiguracoesenvio").AsInteger
      End Sub

      Overridable Overrides Function GetID() As String
         GetID = CStr(me.CodRelatorio)
      End Function       

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodRelatorio", me.CodRelatorio)
            .Prop("Titulo", me.Titulo)
            .Prop("CodGrupoRelatorio", me.CodGrupoRelatorio)
            .Prop("CodWhatsAppConfiguracoesEnvio", me.CodWhatsAppConfiguracoesEnvio)
            ToString = .Text
            .Free()
         End With
      End Function


      Private Function LerPorCodigo(pCodRelatorio As Integer) As Boolean
         Dim query As SQL.Command = TCfgDb.Abrir("", "Relatorio", TCfgSql.EqInt("codrelatorio", pCodRelatorio), "")
         If query.Eof Then
            query.Close()
            query.Free()
            LerPorCodigo = False
         Else
            me.Fill(query)
            query.Close()
            query.Free()
            LerPorCodigo = True
         End If
      End Function

      Sub CarregarRelacionados()
         Dim cod As Integer = me.CodRelatorio
         me.Layouts.Free()
         me.Layouts = LayoutRelatorio.Fetch(TCfgSql.EqInt("codrelatorio", cod), "ORDER BY ordem, item")
         me.GruposLayout.Free()
         me.GruposLayout = GrupoLayoutRelatorio.Fetch(TCfgSql.EqInt("codrelatorio", cod), "ORDER BY ordem, descricao")
         me.EnviosEmail.Free()
         me.EnviosEmail = EnvioEmailLayout.Fetch(TCfgSql.EqInt("codrelatorio", cod))
         If me.CodGrupoRelatorio <> 0 Then
            me.Grupo = GrupoRelatorio.Find(me.CodGrupoRelatorio)
         End If
         If me.CodWhatsAppConfiguracoesEnvio <> 0 Then
            me.WhatsApp = WhatsAppEnvio.Find(me.CodWhatsAppConfiguracoesEnvio)
         End If
      End Sub

      Shared Function Carregar(pCodRelatorio As Integer) As Relatorio
         Dim item As New Relatorio()
         If Not item.LerPorCodigo(pCodRelatorio) Then
            item.Free()
            Carregar = Null
         Else
            item.CarregarRelacionados()
            Carregar = item
         End If
      End Function

      Shared Function Fetch(pWhere As String = "", pOrder As String = "ORDER BY titulo") As TTList<Relatorio>
         Dim query As SQL.Command = TCfgDb.Abrir("", "Relatorio", pWhere, pOrder)
         Dim lista[] As Relatorio = []
         While Not query.Eof
            Dim item As New Relatorio()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Layouts) Then
            me.Layouts.Free()
            me.Layouts = Null
         End If
         If Assigned(me.GruposLayout) Then
            me.GruposLayout.Free()
            me.GruposLayout = Null
         End If
         If Assigned(me.EnviosEmail) Then
            me.EnviosEmail.Free()
            me.EnviosEmail = Null
         End If
         If Assigned(me.Grupo) Then
            me.Grupo.Free()
            me.Grupo = Null
         End If
         If Assigned(me.WhatsApp) Then
            me.WhatsApp.Free()
            me.WhatsApp = Null
         End If
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
