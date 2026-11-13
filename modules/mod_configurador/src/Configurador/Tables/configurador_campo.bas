Imports configurador_sql
Imports configurador_tcfgbase

Namespace configurador_campo

   Class Campo
      Inherits TCfgBase

      CodTabela As Integer
      CodCampo As Integer
      Tipo As String
      CondicaoObrigatorio As String
      CondicaoVisivelGrade As String
      Titulo As String
      TituloGrade As String
      TituloRelatorio As String
      TituloPesquisa As String
      TituloEdicao As String
      Tamanho As Integer
      CasasDecimal As Integer
      CondicaoVisivelEdicao As String
      OrdemEdicao As Integer
      OrdemGrade As Integer
      MascaraEdicao As String
      MascaraGrade As String
      Contexto As String
      CodPasta As Integer
      FormulaValorPadrao As String
      ListaOpcao As String
      CondicaoEditarInclusao As String
      CondicaoEditarAlteracao As String
      CodPesquisaPadrao As Integer
      OrdemPesquisa As Integer
      CondicaoVisivelPesquisa As String
      ValidacaoUsuario As String
      CodMensagemValidacaoUsuario As String
      ValidacaoSistema As String
      CodMensagemValidacaoSistema As String
      Proprietario As String
      Observacao As String
      LarguraGrade As Integer
      LarguraEdicao As Integer
      LarguraPesquisa As Integer
      PosicaoX As Integer
      PosicaoY As Integer
      AlturaEdicao As Integer
      FormulaCalculoValor As String
      ScriptOnExit As String
      Chave As Boolean
      TipoPesquisa As String
      VisivelRelatorio As Boolean
      VisivelParametroRelatorio As Boolean
      TituloInicialParametroRelatorio As String
      TituloFinalParametroRelatorio As String
      ExibirResumo As String
      Nome As String
      ExibirNoRodapePesquisa As Boolean
      ExibirNoRodapeGrade As Boolean
      Caractere As String
      TipoCaractere As String
      CharCase As String
      ScriptOnEnter As String
      AlinhamentoEdicao As String
      NomeFonteEdicao As String
      TamanhoFonteEdicao As Integer
      CorFonteEdicao As Integer
      FonteNegritoEdicao As Boolean
      FonteItalicoEdicao As Boolean
      FonteSublinhadoEdicao As Boolean
      FonteRiscadoEdicao As Boolean
      CondicaoPadrao As Integer
      PesquisaIncremental As Boolean
      Coluna As Integer
      TipoValorPadrao As String
      ManterConteudo As Boolean
      CondicaoPesquisaEspecifica As String
      Especifico As String
      Duplicidade As String

      Pasta As configurador_pasta.Pasta
      Pesquisa As configurador_pesquisa.Pesquisa
      Exists As Boolean = False
      Extra As Boolean = False

      Private _editarInclusaoPronto As Boolean
      Private _editarInclusao As Boolean
      Private _editarAlteracaoPronto As Boolean
      Private _editarAlteracao As Boolean
      Private _obrigatorioPronto As Boolean
      Private _obrigatorio As Boolean
      Private _valorPadraoPronto As Boolean
      Private _valorPadrao As String
      Private _valorPronto As Boolean
      Private _valor As String
      Private _valorQuery As String

      Sub New()
         MyBase.New("Campo")
      End Sub

      Overrides Sub Fill(pJson As TJSONObject)
         me.CodTabela = TCfgRow.AsInteger(pJson.GetString("codtabela"))
         me.CodCampo = TCfgRow.AsInteger(pJson.GetString("codcampo"))
         me.Tipo = TCfgRow.AsString(pJson.GetString("tipo"))
         me.CondicaoObrigatorio = TCfgRow.AsString(pJson.GetString("condicaoobrigatorio"))
         me.CondicaoVisivelGrade = TCfgRow.AsString(pJson.GetString("condicaovisivelgrade"))
         me.Titulo = TCfgRow.AsString(pJson.GetString("titulo"))
         me.TituloGrade = TCfgRow.AsString(pJson.GetString("titulograde"))
         me.TituloRelatorio = TCfgRow.AsString(pJson.GetString("titulorelatorio"))
         me.TituloPesquisa = TCfgRow.AsString(pJson.GetString("titulopesquisa"))
         me.TituloEdicao = TCfgRow.AsString(pJson.GetString("tituloedicao"))
         me.Tamanho = TCfgRow.AsInteger(pJson.GetString("tamanho"))
         me.CasasDecimal = TCfgRow.AsInteger(pJson.GetString("casasdecimal"))
         me.CondicaoVisivelEdicao = TCfgRow.AsString(pJson.GetString("condicaovisiveledicao"))
         me.OrdemEdicao = TCfgRow.AsInteger(pJson.GetString("ordemedicao"))
         me.OrdemGrade = TCfgRow.AsInteger(pJson.GetString("ordemgrade"))
         me.MascaraEdicao = TCfgRow.AsString(pJson.GetString("mascaraedicao"))
         me.MascaraGrade = TCfgRow.AsString(pJson.GetString("mascaragrade"))
         me.Contexto = TCfgRow.AsString(pJson.GetString("contexto"))
         me.CodPasta = TCfgRow.AsInteger(pJson.GetString("codpasta"))
         me.FormulaValorPadrao = TCfgRow.AsString(pJson.GetString("formulavalorpadrao"))
         me.ListaOpcao = TCfgRow.AsString(pJson.GetString("listaopcao"))
         me.CondicaoEditarInclusao = TCfgRow.AsString(pJson.GetString("condicaoeditarinclusao"))
         me.CondicaoEditarAlteracao = TCfgRow.AsString(pJson.GetString("condicaoeditaralteracao"))
         me.CodPesquisaPadrao = TCfgRow.AsInteger(pJson.GetString("codpesquisapadrao"))
         me.OrdemPesquisa = TCfgRow.AsInteger(pJson.GetString("ordempesquisa"))
         me.CondicaoVisivelPesquisa = TCfgRow.AsString(pJson.GetString("condicaovisivelpesquisa"))
         me.ValidacaoUsuario = TCfgRow.AsString(pJson.GetString("validacaousuario"))
         me.CodMensagemValidacaoUsuario = TCfgRow.AsString(pJson.GetString("codmensagemvalidacaousuario"))
         me.ValidacaoSistema = TCfgRow.AsString(pJson.GetString("validacaosistema"))
         me.CodMensagemValidacaoSistema = TCfgRow.AsString(pJson.GetString("codmensagemvalidacaosistema"))
         me.Proprietario = TCfgRow.AsString(pJson.GetString("proprietario"))
         me.Observacao = TCfgRow.AsString(pJson.GetString("observacao"))
         me.LarguraGrade = TCfgRow.AsInteger(pJson.GetString("larguragrade"))
         me.LarguraEdicao = TCfgRow.AsInteger(pJson.GetString("larguraedicao"))
         me.LarguraPesquisa = TCfgRow.AsInteger(pJson.GetString("largurapesquisa"))
         me.PosicaoX = TCfgRow.AsInteger(pJson.GetString("posicaox"))
         me.PosicaoY = TCfgRow.AsInteger(pJson.GetString("posicaoy"))
         me.AlturaEdicao = TCfgRow.AsInteger(pJson.GetString("alturaedicao"))
         me.FormulaCalculoValor = TCfgRow.AsString(pJson.GetString("formulacalculovalor"))
         me.ScriptOnExit = TCfgRow.AsString(pJson.GetString("scriptonexit"))
         me.Chave = me.GetFlagAsBoolean(pJson.GetString("chave"))
         me.TipoPesquisa = TCfgRow.AsString(pJson.GetString("tipopesquisa"))
         me.VisivelRelatorio = me.GetFlagAsBoolean(pJson.GetString("visivelrelatorio"))
         me.VisivelParametroRelatorio = me.GetFlagAsBoolean(pJson.GetString("visivelparametrorelatorio"))
         me.TituloInicialParametroRelatorio = TCfgRow.AsString(pJson.GetString("tituloinicialparametrorelatorio"))
         me.TituloFinalParametroRelatorio = TCfgRow.AsString(pJson.GetString("titulofinalparametrorelatorio"))
         me.ExibirResumo = TCfgRow.AsString(pJson.GetString("exibirresumo"))
         me.Nome = TCfgRow.AsString(pJson.GetString("nome"))
         me.ExibirNoRodapePesquisa = me.GetFlagAsBoolean(pJson.GetString("exibirnorodapepesquisa"))
         me.ExibirNoRodapeGrade = me.GetFlagAsBoolean(pJson.GetString("exibirnorodapegrade"))
         me.Caractere = TCfgRow.AsString(pJson.GetString("caractere"))
         me.TipoCaractere = TCfgRow.AsString(pJson.GetString("tipocaractere"))
         me.CharCase = TCfgRow.AsString(pJson.GetString("charcase"))
         me.ScriptOnEnter = TCfgRow.AsString(pJson.GetString("scriptonenter"))
         me.AlinhamentoEdicao = TCfgRow.AsString(pJson.GetString("alinhamentoedicao"))
         me.NomeFonteEdicao = TCfgRow.AsString(pJson.GetString("nomefonteedicao"))
         me.TamanhoFonteEdicao = TCfgRow.AsInteger(pJson.GetString("tamanhofonteedicao"))
         me.CorFonteEdicao = TCfgRow.AsInteger(pJson.GetString("corfonteedicao"))
         me.FonteNegritoEdicao = me.GetFlagAsBoolean(pJson.GetString("fontenegritoedicao"))
         me.FonteItalicoEdicao = me.GetFlagAsBoolean(pJson.GetString("fonteitalicoedicao"))
         me.FonteSublinhadoEdicao = me.GetFlagAsBoolean(pJson.GetString("fontesublinhadoedicao"))
         me.FonteRiscadoEdicao = me.GetFlagAsBoolean(pJson.GetString("fonteriscadoedicao"))
         me.CondicaoPadrao = TCfgRow.AsInteger(pJson.GetString("condicaopadrao"))
         me.PesquisaIncremental = me.GetFlagAsBoolean(pJson.GetString("pesquisaincremental"))
         me.Coluna = TCfgRow.AsInteger(pJson.GetString("coluna"))
         me.TipoValorPadrao = TCfgRow.AsString(pJson.GetString("tipovalorpadrao"))
         me.ManterConteudo = (UCase(Trim(pJson.GetString("manterconteudo"))) = "SIM")
         me.CondicaoPesquisaEspecifica = TCfgRow.AsString(pJson.GetString("condicaopesquisaespecifica"))
         me.Especifico = TCfgRow.AsString(pJson.GetString("especifico"))
         me.Duplicidade = TCfgRow.AsString(pJson.GetString("duplicidade"))
      End Sub

      Overrides Sub Fill(pQuery As SQL.Command)
         me.CodTabela = pQuery.Field("codtabela").AsInteger
         me.CodCampo = pQuery.Field("codcampo").AsInteger
         me.Tipo = pQuery.Field("tipo").AsString
         me.CondicaoObrigatorio = pQuery.Field("condicaoobrigatorio").AsString
         me.CondicaoVisivelGrade = pQuery.Field("condicaovisivelgrade").AsString
         me.Titulo = pQuery.Field("titulo").AsString
         me.TituloGrade = pQuery.Field("titulograde").AsString
         me.TituloRelatorio = pQuery.Field("titulorelatorio").AsString
         me.TituloPesquisa = pQuery.Field("titulopesquisa").AsString
         me.TituloEdicao = pQuery.Field("tituloedicao").AsString
         me.Tamanho = pQuery.Field("tamanho").AsInteger
         me.CasasDecimal = pQuery.Field("casasdecimal").AsInteger
         me.CondicaoVisivelEdicao = pQuery.Field("condicaovisiveledicao").AsString
         me.OrdemEdicao = pQuery.Field("ordemedicao").AsInteger
         me.OrdemGrade = pQuery.Field("ordemgrade").AsInteger
         me.MascaraEdicao = pQuery.Field("mascaraedicao").AsString
         me.MascaraGrade = pQuery.Field("mascaragrade").AsString
         me.Contexto = pQuery.Field("contexto").AsString
         me.CodPasta = pQuery.Field("codpasta").AsInteger
         me.FormulaValorPadrao = pQuery.Field("formulavalorpadrao").AsString
         me.ListaOpcao = pQuery.Field("listaopcao").AsString
         me.CondicaoEditarInclusao = pQuery.Field("condicaoeditarinclusao").AsString
         me.CondicaoEditarAlteracao = pQuery.Field("condicaoeditaralteracao").AsString
         me.CodPesquisaPadrao = pQuery.Field("codpesquisapadrao").AsInteger
         me.OrdemPesquisa = pQuery.Field("ordempesquisa").AsInteger
         me.CondicaoVisivelPesquisa = pQuery.Field("condicaovisivelpesquisa").AsString
         me.ValidacaoUsuario = pQuery.Field("validacaousuario").AsString
         me.CodMensagemValidacaoUsuario = pQuery.Field("codmensagemvalidacaousuario").AsString
         me.ValidacaoSistema = pQuery.Field("validacaosistema").AsString
         me.CodMensagemValidacaoSistema = pQuery.Field("codmensagemvalidacaosistema").AsString
         me.Proprietario = pQuery.Field("proprietario").AsString
         me.Observacao = pQuery.Field("observacao").AsString
         me.LarguraGrade = pQuery.Field("larguragrade").AsInteger
         me.LarguraEdicao = pQuery.Field("larguraedicao").AsInteger
         me.LarguraPesquisa = pQuery.Field("largurapesquisa").AsInteger
         me.PosicaoX = pQuery.Field("posicaox").AsInteger
         me.PosicaoY = pQuery.Field("posicaoy").AsInteger
         me.AlturaEdicao = pQuery.Field("alturaedicao").AsInteger
         me.FormulaCalculoValor = pQuery.Field("formulacalculovalor").AsString
         me.ScriptOnExit = pQuery.Field("scriptonexit").AsString
         me.Chave = me.GetFlagAsBoolean(pQuery.Field("chave").AsString)
         me.TipoPesquisa = pQuery.Field("tipopesquisa").AsString
         me.VisivelRelatorio = me.GetFlagAsBoolean(pQuery.Field("visivelrelatorio").AsString)
         me.VisivelParametroRelatorio = me.GetFlagAsBoolean(pQuery.Field("visivelparametrorelatorio").AsString)
         me.TituloInicialParametroRelatorio = pQuery.Field("tituloinicialparametrorelatorio").AsString
         me.TituloFinalParametroRelatorio = pQuery.Field("titulofinalparametrorelatorio").AsString
         me.ExibirResumo = pQuery.Field("exibirresumo").AsString
         me.Nome = pQuery.Field("nome").AsString
         me.ExibirNoRodapePesquisa = me.GetFlagAsBoolean(pQuery.Field("exibirnorodapepesquisa").AsString)
         me.ExibirNoRodapeGrade = me.GetFlagAsBoolean(pQuery.Field("exibirnorodapegrade").AsString)
         me.Caractere = pQuery.Field("caractere").AsString
         me.TipoCaractere = pQuery.Field("tipocaractere").AsString
         me.CharCase = pQuery.Field("charcase").AsString
         me.ScriptOnEnter = pQuery.Field("scriptonenter").AsString
         me.AlinhamentoEdicao = pQuery.Field("alinhamentoedicao").AsString
         me.NomeFonteEdicao = pQuery.Field("nomefonteedicao").AsString
         me.TamanhoFonteEdicao = pQuery.Field("tamanhofonteedicao").AsInteger
         me.CorFonteEdicao = pQuery.Field("corfonteedicao").AsInteger
         me.FonteNegritoEdicao = me.GetFlagAsBoolean(pQuery.Field("fontenegritoedicao").AsString)
         me.FonteItalicoEdicao = me.GetFlagAsBoolean(pQuery.Field("fonteitalicoedicao").AsString)
         me.FonteSublinhadoEdicao = me.GetFlagAsBoolean(pQuery.Field("fontesublinhadoedicao").AsString)
         me.FonteRiscadoEdicao = me.GetFlagAsBoolean(pQuery.Field("fonteriscadoedicao").AsString)
         me.CondicaoPadrao = pQuery.Field("condicaopadrao").AsInteger
         me.PesquisaIncremental = me.GetFlagAsBoolean(pQuery.Field("pesquisaincremental").AsString)
         me.Coluna = pQuery.Field("coluna").AsInteger
         me.TipoValorPadrao = pQuery.Field("tipovalorpadrao").AsString
         me.ManterConteudo = (UCase(Trim(pQuery.Field("manterconteudo").AsString)) = "SIM")
         me.CondicaoPesquisaEspecifica = pQuery.Field("condicaopesquisaespecifica").AsString
         me.Especifico = pQuery.Field("especifico").AsString
         me.Duplicidade = pQuery.Field("duplicidade").AsString
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger(me.ClassName())
            .Prop("CodTabela", me.CodTabela)
            .Prop("CodCampo", me.CodCampo)
            .Prop("Tipo", me.Tipo)
            .Prop("CondicaoObrigatorio", me.CondicaoObrigatorio)
            .Prop("CondicaoVisivelGrade", me.CondicaoVisivelGrade)
            .Prop("Titulo", me.Titulo)
            .Prop("TituloGrade", me.TituloGrade)
            .Prop("TituloRelatorio", me.TituloRelatorio)
            .Prop("TituloPesquisa", me.TituloPesquisa)
            .Prop("TituloEdicao", me.TituloEdicao)
            .Prop("Tamanho", me.Tamanho)
            .Prop("CasasDecimal", me.CasasDecimal)
            .Prop("CondicaoVisivelEdicao", me.CondicaoVisivelEdicao)
            .Prop("OrdemEdicao", me.OrdemEdicao)
            .Prop("OrdemGrade", me.OrdemGrade)
            .Prop("MascaraEdicao", me.MascaraEdicao)
            .Prop("MascaraGrade", me.MascaraGrade)
            .Prop("Contexto", me.Contexto)
            .Prop("CodPasta", me.CodPasta)
            .Prop("FormulaValorPadrao", me.FormulaValorPadrao)
            .Prop("ListaOpcao", me.ListaOpcao)
            .Prop("CondicaoEditarInclusao", me.CondicaoEditarInclusao)
            .Prop("CondicaoEditarAlteracao", me.CondicaoEditarAlteracao)
            .Prop("CodPesquisaPadrao", me.CodPesquisaPadrao)
            .Prop("OrdemPesquisa", me.OrdemPesquisa)
            .Prop("CondicaoVisivelPesquisa", me.CondicaoVisivelPesquisa)
            .Prop("ValidacaoUsuario", me.ValidacaoUsuario)
            .Prop("CodMensagemValidacaoUsuario", me.CodMensagemValidacaoUsuario)
            .Prop("ValidacaoSistema", me.ValidacaoSistema)
            .Prop("CodMensagemValidacaoSistema", me.CodMensagemValidacaoSistema)
            .Prop("Proprietario", me.Proprietario)
            .Prop("Observacao", me.Observacao)
            .Prop("LarguraGrade", me.LarguraGrade)
            .Prop("LarguraEdicao", me.LarguraEdicao)
            .Prop("LarguraPesquisa", me.LarguraPesquisa)
            .Prop("PosicaoX", me.PosicaoX)
            .Prop("PosicaoY", me.PosicaoY)
            .Prop("AlturaEdicao", me.AlturaEdicao)
            .Prop("FormulaCalculoValor", me.FormulaCalculoValor)
            .Prop("ScriptOnExit", me.ScriptOnExit)
            .Prop("Chave", me.Chave)
            .Prop("TipoPesquisa", me.TipoPesquisa)
            .Prop("VisivelRelatorio", me.VisivelRelatorio)
            .Prop("VisivelParametroRelatorio", me.VisivelParametroRelatorio)
            .Prop("TituloInicialParametroRelatorio", me.TituloInicialParametroRelatorio)
            .Prop("TituloFinalParametroRelatorio", me.TituloFinalParametroRelatorio)
            .Prop("ExibirResumo", me.ExibirResumo)
            .Prop("Nome", me.Nome)
            .Prop("ExibirNoRodapePesquisa", me.ExibirNoRodapePesquisa)
            .Prop("ExibirNoRodapeGrade", me.ExibirNoRodapeGrade)
            .Prop("Caractere", me.Caractere)
            .Prop("TipoCaractere", me.TipoCaractere)
            .Prop("CharCase", me.CharCase)
            .Prop("ScriptOnEnter", me.ScriptOnEnter)
            .Prop("AlinhamentoEdicao", me.AlinhamentoEdicao)
            .Prop("NomeFonteEdicao", me.NomeFonteEdicao)
            .Prop("TamanhoFonteEdicao", me.TamanhoFonteEdicao)
            .Prop("CorFonteEdicao", me.CorFonteEdicao)
            .Prop("FonteNegritoEdicao", me.FonteNegritoEdicao)
            .Prop("FonteItalicoEdicao", me.FonteItalicoEdicao)
            .Prop("FonteSublinhadoEdicao", me.FonteSublinhadoEdicao)
            .Prop("FonteRiscadoEdicao", me.FonteRiscadoEdicao)
            .Prop("CondicaoPadrao", me.CondicaoPadrao)
            .Prop("PesquisaIncremental", me.PesquisaIncremental)
            .Prop("Coluna", me.Coluna)
            .Prop("TipoValorPadrao", me.TipoValorPadrao)
            .Prop("ManterConteudo", me.ManterConteudo)
            .Prop("CondicaoPesquisaEspecifica", me.CondicaoPesquisaEspecifica)
            .Prop("Especifico", me.Especifico)
            .Prop("Duplicidade", me.Duplicidade)
            ToString = .Text
            .Free()
         End With
      End Function

      Property EditarInclusao As Boolean
         Get
            If Not me._editarInclusaoPronto Then
               me._editarInclusao = TCfgSql.AvaliarCondicao(me.CondicaoEditarInclusao, True)
               me._editarInclusaoPronto = True
            End If
            EditarInclusao = me._editarInclusao
         End Get
      End Property

      Property EditarAlteracao As Boolean
         Get
            If Not me._editarAlteracaoPronto Then
               me._editarAlteracao = TCfgSql.AvaliarCondicao(me.CondicaoEditarAlteracao, True)
               me._editarAlteracaoPronto = True
            End If
            EditarAlteracao = me._editarAlteracao
         End Get
      End Property

      Property Obrigatorio As Boolean
         Get
            If Not me._obrigatorioPronto Then
               me._obrigatorio = TCfgSql.AvaliarCondicao(me.CondicaoObrigatorio)
               me._obrigatorioPronto = True
            End If
            Obrigatorio = me._obrigatorio
         End Get
      End Property

      Property ValorPadrao As String
         Get
            If Not me._valorPadraoPronto Then
               me._valorPadrao = TCfgSql.AvaliarValorPadrao(me.TipoValorPadrao, me.FormulaValorPadrao)
               me._valorPadraoPronto = True
            End If
            ValorPadrao = me._valorPadrao
         End Get
      End Property

      Function Valor(pQueryBase As String = "") As String
         Dim chaveValor As String = Trim(pQueryBase)
         If (Not me._valorPronto) Or (me._valorQuery <> chaveValor) Then
            me._valor = TCfgSql.AvaliarValor(me.Contexto, me.FormulaCalculoValor, me.Nome, chaveValor)
            me._valorQuery = chaveValor
            me._valorPronto = True
         End If
         Valor = me._valor
      End Function

      Function TemPesquisa() As Boolean
         TemPesquisa = me.CodPesquisaPadrao <> 0
      End Function

      Shared Function Fetch(pWhere As String, pOrder As String = "ORDER BY codpasta, ordemedicao, codcampo") As TTList<Campo>
         Dim query As SQL.Command = TCfgDb.Abrir("", "Campo", pWhere, pOrder)
         Dim lista[] As Campo = []
         While Not query.Eof
            Dim item As New Campo()
            item.Fill(query)
            lista.Push(item)
            query.Next()
         End While
         query.Close()
         query.Free()
         Fetch = lista
      End Function

      Shared Function FetchByTabela(pCodTabela As Integer) As TTList<Campo>
         FetchByTabela = Campo.Fetch(TCfgSql.Tabela(pCodTabela))
      End Function

      Shared Function Find(pCodTabela As Integer, pCodCampo As Integer) As Campo
         Dim whereTexto As String = TCfgSql.AndInt(TCfgSql.Tabela(pCodTabela), "codcampo", pCodCampo)
         Dim query As SQL.Command = TCfgDb.Abrir("", "Campo", whereTexto, "")
         If query.Eof Then
            query.Close()
            query.Free()
            Find = Null
         Else
            Dim item As New Campo()
            item.Fill(query)
            query.Close()
            query.Free()
            Find = item
         End If
      End Function

      Shared Function FindPorNome(pCodTabela As Integer, pNome As String) As Campo
         Dim whereTexto As String = TCfgSql.Tabela(pCodTabela) & " AND " & TCfgSql.EqStrCI("nome", pNome)
         Dim query As SQL.Command = TCfgDb.Abrir("", "Campo", whereTexto, "")
         If query.Eof Then
            query.Close()
            query.Free()
            FindPorNome = Null
         Else
            Dim item As New Campo()
            item.Fill(query)
            query.Close()
            query.Free()
            FindPorNome = item
         End If
      End Function

      Overrides Function GetID() As String
         GetID = me.Nome
      End Function

      Overrides Sub Dispose()
         me.Pasta = Null
         me.Pesquisa = Null
         MyBase.Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
