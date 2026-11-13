Imports mod_tobject
Imports mod_wa_instance
Imports mod_wa_api_result
Imports mod_wa_dto_instance

Namespace mod_wa_service

   ' wa.Instance.*
   Class WaInstanceResource
      Inherits WaResource

      Sub New(pService As WaService)
         MyBase.New(pService)
      End Sub

      Function All() As WaInstanceList
         me.EnsureCapability(me.Caps().CanManageInstances, "listar instâncias")
         All = me.Client().InstanceAll()
      End Function

      Function Info(pId As String) As WaInstance
         me.EnsureCapability(me.Caps().CanManageInstances, "obter instância")
         Info = me.Client().InstanceInfo(pId)
      End Function

      Function Status(pId As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageInstances, "status da instância")
         Status = me.Client().InstanceStatus(pId)
      End Function

      Function Online() As Boolean
         me.EnsureReady()
         Online = me.Client().Online()
      End Function

      Function Add(pReq As WaInstanceCreateRequest) As WaApiResult
         me.EnsureCapability(me.Caps().CanManageInstances, "criar instância")
         Add = me.Client().InstanceCreate(pReq)
      End Function

      Function Connect(pId As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageInstances, "conectar instância")
         Connect = me.Client().InstanceConnect(pId)
      End Function

      Function Restart(pId As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageInstances, "reiniciar instância")
         Restart = me.Client().InstanceRestart(pId)
      End Function

      Function Logout(pId As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageInstances, "logout da instância")
         Logout = me.Client().InstanceLogout(pId)
      End Function

      Function Delete(pId As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageInstances, "excluir instância")
         Delete = me.Client().InstanceDelete(pId)
      End Function

      Function Qr(pId As String = "") As WaApiResult
         me.EnsureCapability(me.Caps().CanManageInstances, "QR Code da instância")
         Qr = me.Client().InstanceQr(pId)
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
