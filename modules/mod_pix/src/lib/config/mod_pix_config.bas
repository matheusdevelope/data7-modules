Imports mod_tobject
Imports mod_pix_enums
Imports mod_pix_credentials
Imports mod_pix_certificate
Imports mod_pix_psp

Namespace mod_pix_config

   Class PixConfig
      Inherits TTObject

      CodEmpresa As Integer
      CodFilial As Integer
      CodContaFinanceira As String
      Banco As PixBanco
      Credentials As PixCredentials
      Certificate As PixCertificate
      ChavePix As String
      Sandbox As Boolean
      Timeout As Integer
      Version As Integer
      Psp As PixPsp
      TimeZoneHours As Integer

      Sub New()
         MyBase.New()
         me.Credentials = New PixCredentials()
         me.Certificate = New PixCertificate()
         me.Sandbox = False
         me.Timeout = 10 * 1000
         me.TimeZoneHours = 0
      End Sub

      Sub New(pBanco As PixBanco, pVersion As Integer = 0)
         MyBase.New()
         me.Credentials = New PixCredentials()
         me.Certificate = New PixCertificate()
         me.Sandbox = False
         me.Timeout = 10 * 1000
         me.TimeZoneHours = 0
         me.Banco = pBanco
         me.Version = pVersion
      End Sub

      Shared Function Memory(pChavePix As String = "teste-chave-pix") As PixConfig
         Dim config As New PixConfig(PixBanco.Memory(), 1)
         config.ChavePix = pChavePix
         config.TimeZoneHours = 0
         config.Sandbox = True
         Memory = config
      End Function

      Sub Assign(pValue As PixConfig)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.CodEmpresa = pValue.CodEmpresa
         me.CodFilial = pValue.CodFilial
         me.CodContaFinanceira = pValue.CodContaFinanceira
         me.Banco = pValue.Banco
         If Assigned(me.Credentials) Then
            me.Credentials.Free()
         End If
         me.Credentials = pValue.Credentials.Clone()
         If Assigned(me.Certificate) Then
            me.Certificate.Free()
         End If
         me.Certificate = pValue.Certificate.Clone()
         me.ChavePix = pValue.ChavePix
         me.Sandbox = pValue.Sandbox
         me.Timeout = pValue.Timeout
         me.Version = pValue.Version
         If Assigned(me.Psp) Then
            me.Psp.Free()
         End If
         If Assigned(pValue.Psp) Then
            me.Psp = pValue.Psp.Clone()
         End If
         me.TimeZoneHours = pValue.TimeZoneHours
      End Sub

      Overrides Function Clone() As PixConfig
         Dim copy As New PixConfig()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("PixConfig")
            If Assigned(me.Banco) Then
               .Prop("Banco", me.Banco.AsString)
            End If
            .Prop("ChavePix", me.ChavePix)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Credentials) Then
            me.Credentials.Free()
            me.Credentials = Null
         End If
         If Assigned(me.Certificate) Then
            me.Certificate.Free()
            me.Certificate = Null
         End If
         If Assigned(me.Psp) Then
            me.Psp.Free()
            me.Psp = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
