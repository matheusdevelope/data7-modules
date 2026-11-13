Imports TablesSchema
Imports TablesTable

Namespace table_campo

   Class TCampo
      Inherits TTableOf<TCampo>

      Sub New()
         MyBase.New("TCampo")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.TableName = "Campo"
         pSchema.Field("CodTabela").AsInteger().PrimaryKeyField()
         pSchema.Field("CodCampo").AsInteger().PrimaryKeyField()
         pSchema.Field("Tipo").AsString().MaxLen(3)
         pSchema.Field("CondicaoObrigatorio").AsString().MaxLen(8000)
         pSchema.Field("CondicaoVisivelGrade").AsString().MaxLen(8000).RequiredField()
         pSchema.Field("Titulo").AsString().MaxLen(51)
         pSchema.Field("TituloGrade").AsString().MaxLen(51)
         pSchema.Field("TituloRelatorio").AsString().MaxLen(51)
         pSchema.Field("TituloPesquisa").AsString().MaxLen(51)
         pSchema.Field("TituloEdicao").AsString().MaxLen(51)
         pSchema.Field("Tamanho").AsInteger()
         pSchema.Field("CasasDecimal").AsInteger()
         pSchema.Field("CondicaoVisivelEdicao").AsString().MaxLen(8000).RequiredField()
         pSchema.Field("OrdemEdicao").AsInteger()
         pSchema.Field("OrdemGrade").AsInteger()
         pSchema.Field("MascaraEdicao").AsString().MaxLen(201)
         pSchema.Field("MascaraGrade").AsString().MaxLen(201)
         pSchema.Field("Contexto").AsString().MaxLen(2)
         pSchema.Field("CodPasta").AsInteger()
         pSchema.Field("FormulaValorPadrao").AsString().MaxLen(8000)
         pSchema.Field("ListaOpcao").AsString().MaxLen(8000)
         pSchema.Field("CondicaoEditarInclusao").AsString().MaxLen(8000)
         pSchema.Field("CondicaoEditarAlteracao").AsString().MaxLen(8000)
         pSchema.Field("CodPesquisaPadrao").AsInteger()
         pSchema.Field("OrdemPesquisa").AsInteger()
         pSchema.Field("CondicaoVisivelPesquisa").AsString().MaxLen(8000).RequiredField()
         pSchema.Field("ValidacaoUsuario").AsString().MaxLen(8000)
         pSchema.Field("CodMensagemValidacaoUsuario").AsString().MaxLen(101)
         pSchema.Field("ValidacaoSistema").AsString().MaxLen(8000)
         pSchema.Field("CodMensagemValidacaoSistema").AsString().MaxLen(101)
         pSchema.Field("proprietario").AsString().MaxLen(2)
         pSchema.Field("observacao").AsString().MaxLen(8000)
         pSchema.Field("LarguraGrade").AsInteger()
         pSchema.Field("LarguraEdicao").AsInteger()
         pSchema.Field("LarguraPesquisa").AsInteger()
         pSchema.Field("PosicaoX").AsInteger()
         pSchema.Field("PosicaoY").AsInteger()
         pSchema.Field("AlturaEdicao").AsInteger()
         pSchema.Field("FormulaCalculoValor").AsString().MaxLen(8000)
         pSchema.Field("ScriptOnExit").AsString().MaxLen(8000)
         pSchema.Field("Chave").AsBoolean()
         pSchema.Field("TipoPesquisa").AsString().MaxLen(2)
         pSchema.Field("VisivelRelatorio").AsBoolean()
         pSchema.Field("VisivelParametroRelatorio").AsBoolean()
         pSchema.Field("TituloInicialParametroRelatorio").AsString().MaxLen(51)
         pSchema.Field("TituloFinalParametroRelatorio").AsString().MaxLen(51)
         pSchema.Field("ExibirResumo").AsString().MaxLen(3)
         pSchema.Field("Nome").AsString().MaxLen(51)
         pSchema.Field("ExibirNoRodapePesquisa").AsBoolean()
         pSchema.Field("ExibirNoRodapeGrade").AsBoolean()
         pSchema.Field("Caractere").AsString().MaxLen(251)
         pSchema.Field("TipoCaractere").AsString().MaxLen(2)
         pSchema.Field("CharCase").AsString().MaxLen(2)
         pSchema.Field("ScriptOnEnter").AsString().MaxLen(8000)
         pSchema.Field("AlinhamentoEdicao").AsString().MaxLen(2)
         pSchema.Field("NomeFonteEdicao").AsString().MaxLen(2)
         pSchema.Field("TamanhoFonteEdicao").AsInteger()
         pSchema.Field("CorFonteEdicao").AsInteger()
         pSchema.Field("FonteNegritoEdicao").AsBoolean()
         pSchema.Field("FonteItalicoEdicao").AsBoolean()
         pSchema.Field("FonteSublinhadoEdicao").AsBoolean()
         pSchema.Field("FonteRiscadoEdicao").AsBoolean()
         pSchema.Field("CondicaoPadrao").AsInteger()
         pSchema.Field("PesquisaIncremental").AsBoolean()
         pSchema.Field("Coluna").AsInteger()
         pSchema.Field("TipoValorPadrao").AsString().MaxLen(10)
         pSchema.Field("ManterConteudo").AsBoolean().TrueValue("Sim").FalseValue("Nao").RequiredField()
         pSchema.Field("CondicaoPesquisaEspecifica").AsString().MaxLen(2000)
         pSchema.Field("Especifico").AsString().MaxLen(20)
         pSchema.Field("Duplicidade").AsString().MaxLen(20)
      End Sub

      Overrides Function GetID() As String
         'GetID = CStr(me.CodTabela) & "|" & CStr(me.CodCampo)
         GetID = me.Nome
      End Function

      Property CodTabela As Integer
         Get
            CodTabela = me.GetInteger("CodTabela")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodTabela", pValue)
         End Set
      End Property

      Property CodCampo As Integer
         Get
            CodCampo = me.GetInteger("CodCampo")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodCampo", pValue)
         End Set
      End Property

      Property Tipo As String
         Get
            Tipo = me.GetString("Tipo")
         End Get
         Set(pValue As String)
            me.SetString("Tipo", pValue)
         End Set
      End Property

      Property CondicaoObrigatorio As String
         Get
            CondicaoObrigatorio = me.GetString("CondicaoObrigatorio")
         End Get
         Set(pValue As String)
            me.SetString("CondicaoObrigatorio", pValue)
         End Set
      End Property

      Property CondicaoVisivelGrade As String
         Get
            CondicaoVisivelGrade = me.GetString("CondicaoVisivelGrade")
         End Get
         Set(pValue As String)
            me.SetString("CondicaoVisivelGrade", pValue)
         End Set
      End Property

      Property Titulo As String
         Get
            Titulo = me.GetString("Titulo")
         End Get
         Set(pValue As String)
            me.SetString("Titulo", pValue)
         End Set
      End Property

      Property TituloGrade As String
         Get
            TituloGrade = me.GetString("TituloGrade")
         End Get
         Set(pValue As String)
            me.SetString("TituloGrade", pValue)
         End Set
      End Property

      Property TituloRelatorio As String
         Get
            TituloRelatorio = me.GetString("TituloRelatorio")
         End Get
         Set(pValue As String)
            me.SetString("TituloRelatorio", pValue)
         End Set
      End Property

      Property TituloPesquisa As String
         Get
            TituloPesquisa = me.GetString("TituloPesquisa")
         End Get
         Set(pValue As String)
            me.SetString("TituloPesquisa", pValue)
         End Set
      End Property

      Property TituloEdicao As String
         Get
            TituloEdicao = me.GetString("TituloEdicao")
         End Get
         Set(pValue As String)
            me.SetString("TituloEdicao", pValue)
         End Set
      End Property

      Property Tamanho As Integer
         Get
            Tamanho = me.GetInteger("Tamanho")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Tamanho", pValue)
         End Set
      End Property

      Property CasasDecimal As Integer
         Get
            CasasDecimal = me.GetInteger("CasasDecimal")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CasasDecimal", pValue)
         End Set
      End Property

      Property CondicaoVisivelEdicao As String
         Get
            CondicaoVisivelEdicao = me.GetString("CondicaoVisivelEdicao")
         End Get
         Set(pValue As String)
            me.SetString("CondicaoVisivelEdicao", pValue)
         End Set
      End Property

      Property OrdemEdicao As Integer
         Get
            OrdemEdicao = me.GetInteger("OrdemEdicao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("OrdemEdicao", pValue)
         End Set
      End Property

      Property OrdemGrade As Integer
         Get
            OrdemGrade = me.GetInteger("OrdemGrade")
         End Get
         Set(pValue As Integer)
            me.SetInteger("OrdemGrade", pValue)
         End Set
      End Property

      Property MascaraEdicao As String
         Get
            MascaraEdicao = me.GetString("MascaraEdicao")
         End Get
         Set(pValue As String)
            me.SetString("MascaraEdicao", pValue)
         End Set
      End Property

      Property MascaraGrade As String
         Get
            MascaraGrade = me.GetString("MascaraGrade")
         End Get
         Set(pValue As String)
            me.SetString("MascaraGrade", pValue)
         End Set
      End Property

      Property Contexto As String
         Get
            Contexto = me.GetString("Contexto")
         End Get
         Set(pValue As String)
            me.SetString("Contexto", pValue)
         End Set
      End Property

      Property CodPasta As Integer
         Get
            CodPasta = me.GetInteger("CodPasta")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPasta", pValue)
         End Set
      End Property

      Property FormulaValorPadrao As String
         Get
            FormulaValorPadrao = me.GetString("FormulaValorPadrao")
         End Get
         Set(pValue As String)
            me.SetString("FormulaValorPadrao", pValue)
         End Set
      End Property

      Property ListaOpcao As String
         Get
            ListaOpcao = me.GetString("ListaOpcao")
         End Get
         Set(pValue As String)
            me.SetString("ListaOpcao", pValue)
         End Set
      End Property

      Property CondicaoEditarInclusao As String
         Get
            CondicaoEditarInclusao = me.GetString("CondicaoEditarInclusao")
         End Get
         Set(pValue As String)
            me.SetString("CondicaoEditarInclusao", pValue)
         End Set
      End Property

      Property CondicaoEditarAlteracao As String
         Get
            CondicaoEditarAlteracao = me.GetString("CondicaoEditarAlteracao")
         End Get
         Set(pValue As String)
            me.SetString("CondicaoEditarAlteracao", pValue)
         End Set
      End Property

      Property CodPesquisaPadrao As Integer
         Get
            CodPesquisaPadrao = me.GetInteger("CodPesquisaPadrao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodPesquisaPadrao", pValue)
         End Set
      End Property

      Property OrdemPesquisa As Integer
         Get
            OrdemPesquisa = me.GetInteger("OrdemPesquisa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("OrdemPesquisa", pValue)
         End Set
      End Property

      Property CondicaoVisivelPesquisa As String
         Get
            CondicaoVisivelPesquisa = me.GetString("CondicaoVisivelPesquisa")
         End Get
         Set(pValue As String)
            me.SetString("CondicaoVisivelPesquisa", pValue)
         End Set
      End Property

      Property ValidacaoUsuario As String
         Get
            ValidacaoUsuario = me.GetString("ValidacaoUsuario")
         End Get
         Set(pValue As String)
            me.SetString("ValidacaoUsuario", pValue)
         End Set
      End Property

      Property CodMensagemValidacaoUsuario As String
         Get
            CodMensagemValidacaoUsuario = me.GetString("CodMensagemValidacaoUsuario")
         End Get
         Set(pValue As String)
            me.SetString("CodMensagemValidacaoUsuario", pValue)
         End Set
      End Property

      Property ValidacaoSistema As String
         Get
            ValidacaoSistema = me.GetString("ValidacaoSistema")
         End Get
         Set(pValue As String)
            me.SetString("ValidacaoSistema", pValue)
         End Set
      End Property

      Property CodMensagemValidacaoSistema As String
         Get
            CodMensagemValidacaoSistema = me.GetString("CodMensagemValidacaoSistema")
         End Get
         Set(pValue As String)
            me.SetString("CodMensagemValidacaoSistema", pValue)
         End Set
      End Property

      Property proprietario As String
         Get
            proprietario = me.GetString("proprietario")
         End Get
         Set(pValue As String)
            me.SetString("proprietario", pValue)
         End Set
      End Property

      Property observacao As String
         Get
            observacao = me.GetString("observacao")
         End Get
         Set(pValue As String)
            me.SetString("observacao", pValue)
         End Set
      End Property

      Property LarguraGrade As Integer
         Get
            LarguraGrade = me.GetInteger("LarguraGrade")
         End Get
         Set(pValue As Integer)
            me.SetInteger("LarguraGrade", pValue)
         End Set
      End Property

      Property LarguraEdicao As Integer
         Get
            LarguraEdicao = me.GetInteger("LarguraEdicao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("LarguraEdicao", pValue)
         End Set
      End Property

      Property LarguraPesquisa As Integer
         Get
            LarguraPesquisa = me.GetInteger("LarguraPesquisa")
         End Get
         Set(pValue As Integer)
            me.SetInteger("LarguraPesquisa", pValue)
         End Set
      End Property

      Property PosicaoX As Integer
         Get
            PosicaoX = me.GetInteger("PosicaoX")
         End Get
         Set(pValue As Integer)
            me.SetInteger("PosicaoX", pValue)
         End Set
      End Property

      Property PosicaoY As Integer
         Get
            PosicaoY = me.GetInteger("PosicaoY")
         End Get
         Set(pValue As Integer)
            me.SetInteger("PosicaoY", pValue)
         End Set
      End Property

      Property AlturaEdicao As Integer
         Get
            AlturaEdicao = me.GetInteger("AlturaEdicao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("AlturaEdicao", pValue)
         End Set
      End Property

      Property FormulaCalculoValor As String
         Get
            FormulaCalculoValor = me.GetString("FormulaCalculoValor")
         End Get
         Set(pValue As String)
            me.SetString("FormulaCalculoValor", pValue)
         End Set
      End Property

      Property ScriptOnExit As String
         Get
            ScriptOnExit = me.GetString("ScriptOnExit")
         End Get
         Set(pValue As String)
            me.SetString("ScriptOnExit", pValue)
         End Set
      End Property

      Property Chave As Boolean
         Get
            Chave = me.GetBoolean("Chave")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("Chave", pValue)
         End Set
      End Property

      Property TipoPesquisa As String
         Get
            TipoPesquisa = me.GetString("TipoPesquisa")
         End Get
         Set(pValue As String)
            me.SetString("TipoPesquisa", pValue)
         End Set
      End Property

      Property VisivelRelatorio As Boolean
         Get
            VisivelRelatorio = me.GetBoolean("VisivelRelatorio")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("VisivelRelatorio", pValue)
         End Set
      End Property

      Property VisivelParametroRelatorio As Boolean
         Get
            VisivelParametroRelatorio = me.GetBoolean("VisivelParametroRelatorio")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("VisivelParametroRelatorio", pValue)
         End Set
      End Property

      Property TituloInicialParametroRelatorio As String
         Get
            TituloInicialParametroRelatorio = me.GetString("TituloInicialParametroRelatorio")
         End Get
         Set(pValue As String)
            me.SetString("TituloInicialParametroRelatorio", pValue)
         End Set
      End Property

      Property TituloFinalParametroRelatorio As String
         Get
            TituloFinalParametroRelatorio = me.GetString("TituloFinalParametroRelatorio")
         End Get
         Set(pValue As String)
            me.SetString("TituloFinalParametroRelatorio", pValue)
         End Set
      End Property

      Property ExibirResumo As String
         Get
            ExibirResumo = me.GetString("ExibirResumo")
         End Get
         Set(pValue As String)
            me.SetString("ExibirResumo", pValue)
         End Set
      End Property

      Property Nome As String
         Get
            Nome = me.GetString("Nome")
         End Get
         Set(pValue As String)
            me.SetString("Nome", pValue)
         End Set
      End Property

      Property ExibirNoRodapePesquisa As Boolean
         Get
            ExibirNoRodapePesquisa = me.GetBoolean("ExibirNoRodapePesquisa")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("ExibirNoRodapePesquisa", pValue)
         End Set
      End Property

      Property ExibirNoRodapeGrade As Boolean
         Get
            ExibirNoRodapeGrade = me.GetBoolean("ExibirNoRodapeGrade")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("ExibirNoRodapeGrade", pValue)
         End Set
      End Property

      Property Caractere As String
         Get
            Caractere = me.GetString("Caractere")
         End Get
         Set(pValue As String)
            me.SetString("Caractere", pValue)
         End Set
      End Property

      Property TipoCaractere As String
         Get
            TipoCaractere = me.GetString("TipoCaractere")
         End Get
         Set(pValue As String)
            me.SetString("TipoCaractere", pValue)
         End Set
      End Property

      Property CharCase As String
         Get
            CharCase = me.GetString("CharCase")
         End Get
         Set(pValue As String)
            me.SetString("CharCase", pValue)
         End Set
      End Property

      Property ScriptOnEnter As String
         Get
            ScriptOnEnter = me.GetString("ScriptOnEnter")
         End Get
         Set(pValue As String)
            me.SetString("ScriptOnEnter", pValue)
         End Set
      End Property

      Property AlinhamentoEdicao As String
         Get
            AlinhamentoEdicao = me.GetString("AlinhamentoEdicao")
         End Get
         Set(pValue As String)
            me.SetString("AlinhamentoEdicao", pValue)
         End Set
      End Property

      Property NomeFonteEdicao As String
         Get
            NomeFonteEdicao = me.GetString("NomeFonteEdicao")
         End Get
         Set(pValue As String)
            me.SetString("NomeFonteEdicao", pValue)
         End Set
      End Property

      Property TamanhoFonteEdicao As Integer
         Get
            TamanhoFonteEdicao = me.GetInteger("TamanhoFonteEdicao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("TamanhoFonteEdicao", pValue)
         End Set
      End Property

      Property CorFonteEdicao As Integer
         Get
            CorFonteEdicao = me.GetInteger("CorFonteEdicao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CorFonteEdicao", pValue)
         End Set
      End Property

      Property FonteNegritoEdicao As Boolean
         Get
            FonteNegritoEdicao = me.GetBoolean("FonteNegritoEdicao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("FonteNegritoEdicao", pValue)
         End Set
      End Property

      Property FonteItalicoEdicao As Boolean
         Get
            FonteItalicoEdicao = me.GetBoolean("FonteItalicoEdicao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("FonteItalicoEdicao", pValue)
         End Set
      End Property

      Property FonteSublinhadoEdicao As Boolean
         Get
            FonteSublinhadoEdicao = me.GetBoolean("FonteSublinhadoEdicao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("FonteSublinhadoEdicao", pValue)
         End Set
      End Property

      Property FonteRiscadoEdicao As Boolean
         Get
            FonteRiscadoEdicao = me.GetBoolean("FonteRiscadoEdicao")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("FonteRiscadoEdicao", pValue)
         End Set
      End Property

      Property CondicaoPadrao As Integer
         Get
            CondicaoPadrao = me.GetInteger("CondicaoPadrao")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CondicaoPadrao", pValue)
         End Set
      End Property

      Property PesquisaIncremental As Boolean
         Get
            PesquisaIncremental = me.GetBoolean("PesquisaIncremental")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("PesquisaIncremental", pValue)
         End Set
      End Property

      Property Coluna As Integer
         Get
            Coluna = me.GetInteger("Coluna")
         End Get
         Set(pValue As Integer)
            me.SetInteger("Coluna", pValue)
         End Set
      End Property

      Property TipoValorPadrao As String
         Get
            TipoValorPadrao = me.GetString("TipoValorPadrao")
         End Get
         Set(pValue As String)
            me.SetString("TipoValorPadrao", pValue)
         End Set
      End Property

      Property ManterConteudo As Boolean
         Get
            ManterConteudo = me.GetBoolean("ManterConteudo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("ManterConteudo", pValue)
         End Set
      End Property

      Property CondicaoPesquisaEspecifica As String
         Get
            CondicaoPesquisaEspecifica = me.GetString("CondicaoPesquisaEspecifica")
         End Get
         Set(pValue As String)
            me.SetString("CondicaoPesquisaEspecifica", pValue)
         End Set
      End Property

      Property Especifico As String
         Get
            Especifico = me.GetString("Especifico")
         End Get
         Set(pValue As String)
            me.SetString("Especifico", pValue)
         End Set
      End Property

      Property Duplicidade As String
         Get
            Duplicidade = me.GetString("Duplicidade")
         End Get
         Set(pValue As String)
            me.SetString("Duplicidade", pValue)
         End Set
      End Property

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
