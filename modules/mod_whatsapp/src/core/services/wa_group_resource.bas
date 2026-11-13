Imports mod_tobject
Imports mod_wa_api_result
Imports mod_wa_dto_group

Namespace mod_wa_service

   ' wa.Group.*
   Class WaGroupResource
      Inherits WaResource

      Sub New(pService As WaService)
         MyBase.New(pService)
      End Sub

      Function Add(pReq As WaGroupCreateRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "criar grupo")
         Add = me.Client().GroupCreate(pReq)
      End Function

      Function All(pInstance As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "listar grupos")
         All = me.Client().GroupList(pInstance)
      End Function

      Function Info(pReq As WaGroupInfoRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "info do grupo")
         Info = me.Client().GroupInfo(pReq)
      End Function

      Function Participants(pReq As WaGroupInfoRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "participantes do grupo")
         Participants = me.Client().GroupParticipants(pReq)
      End Function

      Function UpdateParticipant(pReq As WaGroupParticipantRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "atualizar participante")
         UpdateParticipant = me.Client().GroupUpdateParticipant(pReq)
      End Function

      Function InviteLink(pReq As WaGroupInviteRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "link de convite")
         InviteLink = me.Client().GroupInviteLink(pReq)
      End Function

      Function Leave(pReq As WaGroupInfoRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "sair do grupo")
         Leave = me.Client().GroupLeave(pReq)
      End Function

      Function UpdateSubject(pReq As WaGroupUpdateTextRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "atualizar assunto do grupo")
         UpdateSubject = me.Client().GroupUpdateSubject(pReq)
      End Function

      Function UpdateDescription(pReq As WaGroupUpdateTextRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageGroups, "atualizar descrição do grupo")
         UpdateDescription = me.Client().GroupUpdateDescription(pReq)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
