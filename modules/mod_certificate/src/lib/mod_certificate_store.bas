Imports Collections
Imports IO
Imports mod_cert_enums
Imports mod_certificate
Imports mod_certificates
Imports mod_certutil
Imports mod_tobject

Namespace mod_certificate_store

   Class TCertificateStore
      Inherits TTObject

      Private _location As TCertLocation
      Private _name As TCertStoreName

      Sub New()
         MyBase.New()
         me._location = TCertLocation.CurrentUser()
         me._name = TCertStoreName.My()
      End Sub

      Sub New(pLocation As TCertLocation, pStore As TCertStoreName)
         MyBase.New()
         me._location = pLocation
         me._name = pStore
         If Not Assigned(me._location) Then
            me._location = TCertLocation.CurrentUser()
         End If
         If Not Assigned(me._name) Then
            me._name = TCertStoreName.My()
         End If
      End Sub

      Shared Function Personal() As TCertificateStore
         Personal = New TCertificateStore(TCertLocation.CurrentUser(), TCertStoreName.My())
      End Function

      Shared Function Machine() As TCertificateStore
         Machine = New TCertificateStore(TCertLocation.LocalMachine(), TCertStoreName.My())
      End Function

      Shared Function Roots(pLocation As TCertLocation) As TCertificateStore
         Roots = New TCertificateStore(pLocation, TCertStoreName.Root())
      End Function

      Property Location As TCertLocation
         Get
            Location = me._location
         End Get
         Set(pValue As TCertLocation)
            me._location = pValue
         End Set
      End Property

      Property Name As TCertStoreName
         Get
            Name = me._name
         End Get
         Set(pValue As TCertStoreName)
            me._name = pValue
         End Set
      End Property

      Function List(pCertId As String = "") As TCertificates
         Dim args As String = "-store " & me._name.AsString
         If Trim(pCertId) <> "" Then
            args = args & " " & Trim(pCertId).Quoted()
         End If
         Dim lines As StringList = TCertUtil.Instance().Exec(TCertUtil.Instance().Prefix(me._location, args))
         Dim certs As TCertificates = TCertificates.FromDump(lines, me._location, me._name)
         lines.Free()
         List = certs
      End Function

      Function Find(pCertId As String) As TCertificate
         Dim certs As TCertificates = me.List(pCertId)
         If certs.Length = 0 Then
            certs.Free()
            Find = Null
            Exit Function
         End If
         Dim found As TCertificate = certs.Take(0).Copy()
         certs.Free()
         Find = found
      End Function

      Function FindByThumbprint(pHash As String) As TCertificate
         FindByThumbprint = me.Find(TCertificate.NormalizeHash(pHash))
      End Function

      Function FindByName(pName As String) As TCertificate
         FindByName = me.Find(pName)
      End Function

      Function FindBySerial(pSerial As String) As TCertificate
         FindBySerial = me.Find(pSerial)
      End Function

      Function Expired() As TCertificates
         Dim all As TCertificates = me.List()
         Dim filtered As TCertificates = all.Expired()
         all.Free()
         Expired = filtered
      End Function

      Function Valid() As TCertificates
         Dim all As TCertificates = me.List()
         Dim filtered As TCertificates = all.Valid()
         all.Free()
         Valid = filtered
      End Function

      Function WithPrivateKey() As TCertificates
         Dim all As TCertificates = me.List()
         Dim filtered As TCertificates = all.WithPrivateKey()
         all.Free()
         WithPrivateKey = filtered
      End Function

      Function ExpiringWithin(pDays As Integer) As TCertificates
         Dim all As TCertificates = me.List()
         Dim filtered As TCertificates = all.ExpiringWithin(pDays)
         all.Free()
         ExpiringWithin = filtered
      End Function

      Function Search(pQuery As String) As TCertificates
         Dim all As TCertificates = me.List()
         Dim filtered As TCertificates = all.Search(pQuery)
         all.Free()
         Search = filtered
      End Function

      Shared Function EnumStores(pLocation As TCertLocation) As StringList
         Dim lines As StringList = TCertUtil.Instance().Exec(TCertUtil.Instance().Prefix(pLocation, "-enumstore"))
         Dim stores As New StringList()
         stores.NameValueSeparator = "="
         Dim i As Integer
         For i = 0 To lines.Count - 1
            Dim line As String = Trim(lines.Strings(i))
            If (line <> "") And (Left(line, 1) <> "(") And (InStr(UCase(line), "CERTUTIL") = 0) And (Right(line, 1) <> ":") Then
               Dim q As Integer = InStr(line, """")
               Dim storeName As String = ""
               Dim caption As String = ""
               If q > 0 Then
                  storeName = Trim(Left(line, q - 1))
                  caption = Trim(Mid(line, q)).Dequoted()
               Else
                  storeName = line
               End If
               If (storeName <> "") And (InStr(storeName, " ") = 0) Then
                  Dim token As String = UCase(Replace(storeName, "_", ""))
                  If (token <> "LOCALMACHINE") And (token <> "CURRENTUSER") And (token <> "ENTERPRISE") And (token <> "GROUPPOLICY") And (token <> "SERVICE") Then
                     If caption <> "" Then
                        stores.Add(storeName & "=" & caption)
                     Else
                        stores.Add(storeName)
                     End If
                  End If
               End If
            End If
         Next
         lines.Free()
         EnumStores = stores
      End Function

      Function ImportPfx(pPath As String, pPass As String, pModifiers As String = "NoRoot") As TCertificate
         Dim cert As New TCertificate()
         cert.CleanOnFree = False
         cert.Load(pPath, pPass)
         cert.Location = me._location
         cert.Store = me._name
         cert.Install(pModifiers)
         ImportPfx = cert
      End Function

      Function Add(pFile As String) As TCertificateStore
         If Not IO.File.Exists(pFile) Then
            Throw New Exception("Arquivo nao encontrado: " & pFile)
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-f -addstore " & me._name.AsString & " " & pFile.Quoted())
         TCertUtil.Instance().ExecChecked(args, "Falha ao adicionar certificado no store " & me._name.AsString)
         Add = me
      End Function

      Sub Delete(pCertId As String)
         If Trim(pCertId) = "" Then
            Throw New Exception("Informe o CertId (thumbprint, CN ou serial) para excluir.")
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-delstore " & me._name.AsString & " " & Trim(pCertId).Quoted())
         TCertUtil.Instance().ExecChecked(args, "Falha ao excluir certificado: " & pCertId)
      End Sub

      Function ExportPfx(pCertId As String, pOutFile As String, pPass As String, pModifiers As String = "NoRoot") As TCertificateStore
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-f -p " & pPass.Quoted() & " -exportPFX " & me._name.AsString & " " & Trim(pCertId).Quoted() & " " & pOutFile.Quoted())
         If Trim(pModifiers) <> "" Then
            args = args & " " & Trim(pModifiers)
         End If
         TCertUtil.Instance().ExecChecked(args, "Falha ao exportar PFX: " & pOutFile)
         ExportPfx = me
      End Function

      Function SaveCert(pCertId As String, pOutFile As String) As TCertificateStore
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-store " & me._name.AsString & " " & Trim(pCertId).Quoted() & " " & pOutFile.Quoted())
         TCertUtil.Instance().ExecChecked(args, "Falha ao salvar certificado: " & pOutFile)
         SaveCert = me
      End Function

      Function Verify(pCertId As String = "") As StringList
         Dim args As String = "-verifystore " & me._name.AsString
         If Trim(pCertId) <> "" Then
            args = args & " " & Trim(pCertId).Quoted()
         End If
         Verify = TCertUtil.Instance().Exec(TCertUtil.Instance().Prefix(me._location, args))
      End Function

      Function Repair(pCertId As String) As Integer
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-repairstore " & me._name.AsString & " " & Trim(pCertId).Quoted())
         Repair = TCertUtil.Instance().ExecChecked(args, "Falha ao reparar certificado: " & pCertId)
      End Function

      Function Dump(pCertId As String = "") As StringList
         Dim args As String = "-store " & me._name.AsString
         If Trim(pCertId) <> "" Then
            args = args & " " & Trim(pCertId).Quoted()
         End If
         Dump = TCertUtil.Instance().Exec(TCertUtil.Instance().Prefix(me._location, args))
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("CertificateStore")
            .Prop("Location", me.Location.AsString)
            .Prop("Name", me.Name.AsString)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
