
Namespace mod_pix_enums

   Enun PixBanco
      Memory = "0"
      BBrasil = "1"
      Bradesco = "237"
      Itau = "341"
      Santander = "033"
      Sicoob = "756"
      Sicredi = "748"
   End Enun

   Enun PixStatusCobranca
      Ativa = "ATIVA"
      Concluida = "CONCLUIDA"
      RemovidaPeloUsuario = "REMOVIDA_PELO_USUARIO_RECEBEDOR"
      RemovidaPeloPsp = "REMOVIDA_PELO_PSP"
   End Enun

   Enun PixStatusDevolucao
      EmProcessamento = "EM_PROCESSAMENTO"
      Devolvido = "DEVOLVIDO"
      NaoRealizado = "NAO_REALIZADO"
   End Enun

   Enun PixModalidadeAlteracao
      Nao = "NAO"
      Sim = "SIM"
   End Enun

End Namespace
