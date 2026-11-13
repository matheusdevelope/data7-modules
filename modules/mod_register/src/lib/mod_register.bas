'
' mod_register
' Formulário de cadastro dinâmico, independente do Configurador.
'
' O Configurador (Tabela/Campo/Pasta) só entra se você quiser popular o
' TRegisterFormConfig. O form aceita a mesma configuração montada à mão,
' inclusive com campos extras, factories próprias e pastas aninhadas.
'
' ---------------------------------------------------------------------------
' Namespaces
' ---------------------------------------------------------------------------
'   mod_register_config    TRegisterMode, TRegisterFieldKind,
'                          TRegisterField, TRegisterFolder, TRegisterFormConfig
'   mod_register_factory   TRegisterFactory (editors padrão + Register)
'   mod_register_layout    TRegisterLayout (linhas 1..N campos)
'   mod_register_form      TRegisterForm (TFormsForm)
'   mod_register_tabela    TRegisterTabela.FromTabela (opcional)
'   mod_register_record    TRegisterRecord (TTable da tabela do ambiente)
'   mod_register_store     carga, gravação e sequência
'   mod_register_events    TRegisterContext e ganchos do fluxo
'   mod_register_session   TRegisterSession (orquestra form, eventos e dados)
'   mod_register_log       log de inclusão, cópia, alteração e exclusão
'   mod_register_validation ValidacaoSistema / ValidacaoUsuario no OK
'
' ---------------------------------------------------------------------------
' Configuração
' ---------------------------------------------------------------------------
'   Dim cfg As New TRegisterFormConfig()
'   cfg.Title = "Cliente"
'   cfg.AddField("Ativo", "Ativo:").UseCombo("Sim=S;Não=N")
'   cfg.AddField("Codigo", "Código:").UseInteger().Lock()
'   cfg.AddField("NomeFantasia", "Nome Fantasia:").UseText().MaxLen(80)
'   cfg.AddFolder("01", "Endereço")
'   cfg.AddField("Endereco", "Endereço:").UseText().MaxLen(60).InFolder("01")
'   cfg.AddField("Numero", "Número:").UseText().MaxLen(10).InFolder("01")
'   cfg.AddFolder("01.01", "Cobrança/Entrega")
'
'   Dim form As New TRegisterForm(cfg, TRegisterMode.Incluir())
'   form.Show()
'
' Pastas manuais usam estrutura 01 / 02 / 01.01 ou concatenada 0106 / 010601.
' Do Configurador, o id é CodPasta. Estrutura só define hierarquia e ordem:
' o pai é a pasta visível cuja estrutura é o maior prefixo da filha
' (02 → 02.01, 0106 → 010601). Pasta inativa não entra.
' Campos sem pasta ficam no cabeçalho, acima das abas.
'
' Linhas: no máximo 2 editores. Memo, imagem, Tamanho >= 200 ou largura maior
' que a metade ocupam a linha inteira. Dois pequenos começam em 0 e na metade;
' a largura de cada um vem de LarguraEdicao, Tamanho/tipo ou 366 se for pesquisa.
'
' ---------------------------------------------------------------------------
' Do Configurador
' ---------------------------------------------------------------------------
'   Dim t As New Tabela("Cliente")
'   Dim cfg As TRegisterFormConfig = TRegisterTabela.FromTabela(t)
'   cfg.AddField("ObservacaoExtra", "Obs.:").UseMemo().InFolder("01")
'   Dim form As New TRegisterForm(cfg, TRegisterMode.Alterar())
'
' ---------------------------------------------------------------------------
' Extensão
' ---------------------------------------------------------------------------
'   TRegisterFactory.RegisterKind("MeuTipo", AddressOf MinhaFactory)
'   field.WithFactory(AddressOf MinhaFactory)
'   Herde TRegisterForm e sobrescreva CreateEditor / BuildSubCadastro /
'   ValidateField / AfterBuild.
'

Namespace mod_register

   Class TRegister
      Sub New()
         MyBase.New()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
