Imports Collections
Imports IO
Imports mod_cert_dump
Imports mod_cert_enums
Imports mod_certutil
Imports mod_tobject

Namespace mod_certificate

   Class TCertificate
      Inherits TTObject

      Private _path As String
      Private _pass As String
      Private _serie As String
      Private _name As String
      Private _thumbprint As String
      Private _datestart As TDateTime
      Private _dateend As TDateTime
      Private _locator As String
      Private _installed As Boolean
      Private _cleaned As Boolean
      Private _location As TCertLocation
      Private _store As TCertStoreName
      Private _subject As String
      Private _issuer As String
      Private _issuerName As String
      Private _friendlyName As String
      Private _hasPrivateKey As Boolean
      Private _isRoot As Boolean

      Use As Boolean = True
      CleanOnFree As Boolean = True

      Sub New()
         MyBase.New()
         me.ResetFields()
         me._location = TCertLocation.CurrentUser()
         me._store = TCertStoreName.My()
      End Sub

      Sub New(pPath As String, pPass As String)
         MyBase.New()
         me.ResetFields()
         me._location = TCertLocation.CurrentUser()
         me._store = TCertStoreName.My()
         me.Load(pPath, pPass)
      End Sub

      Private Sub ResetFields()
         me._path = ""
         me._pass = ""
         me._serie = ""
         me._name = ""
         me._thumbprint = ""
         me._datestart = 0
         me._dateend = 0
         me._locator = ""
         me._installed = False
         me._cleaned = False
         me._subject = ""
         me._issuer = ""
         me._issuerName = ""
         me._friendlyName = ""
         me._hasPrivateKey = False
         me._isRoot = False
      End Sub

      Function Load(pPath As String, pPass As String = "") As TCertificate
         If Not IO.File.Exists(pPath) Then
            Throw New Exception("O path do certificado informado e invalido.")
         End If
         me.ResetFields()
         me._path = pPath
         me._pass = pPass
         me._location = TCertLocation.CurrentUser()
         me._store = TCertStoreName.My()

         Dim dumpLines As StringList = TCertUtil.Instance().DumpFile(pPath, pPass)
         Try
            me.ParseLeafDump(dumpLines)
         Catch ex As Exception
            dumpLines.Free()
            Throw New Exception("Erro ao ler certificado: " & ex._GetMessage())
         End Try
         dumpLines.Free()

         If me._name = "" And me._thumbprint = "" Then
            Throw New Exception("Nao foi possivel ler o certificado digital.")
         End If
         me._locator = me.BuildLocator()
         Load = me
      End Function

      Function Install(pModifiers As String = "") As TCertificate
         If me._path = "" Then
            Throw New Exception("Nenhum arquivo PFX carregado para instalar.")
         End If
         If me._installed Then
            Install = me
            Exit Function
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-f -p " & me._pass.Quoted() & " -importpfx " & me._store.AsString & " " & me._path.Quoted())
         If Trim(pModifiers) <> "" Then
            args = args & " " & Trim(pModifiers)
         End If
         TCertUtil.Instance().ExecChecked(args, "Nao foi possivel importar o certificado no store do Windows.")
         me._installed = True
         me._cleaned = False
         me._locator = me.BuildLocator()
         Install = me
      End Function

      Sub ApplyDump(pLines As StringList)
         me._subject = TCertDump.FirstDumpField(pLines, "Requerente", "Subject")
         me._name = TCertDump.ExtractCN(me._subject)
         me._issuer = TCertDump.FirstDumpField(pLines, "Emissor", "Issuer")
         me._issuerName = TCertDump.ExtractCN(me._issuer)
         me._serie = TCertDump.FirstDumpField(pLines, "Numero de Serie", "Serial Number")
         If me._serie = "" Then
            me._serie = TCertDump.FirstDumpField(pLines, "Número de Série", "")
         End If
         me._thumbprint = TCertDump.NormalizeHash(TCertDump.FirstDumpField(pLines, "Hash Cert(sha1)", "Cert Hash(sha1)"))
         me._datestart = TCertDump.ParseDumpDate(TCertDump.FirstDumpField(pLines, "NotBefore", " NotBefore"))
         me._dateend = TCertDump.ParseDumpDate(TCertDump.FirstDumpField(pLines, "NotAfter", " NotAfter"))
         me._friendlyName = TCertDump.FirstDumpField(pLines, "Nome amigavel", "Friendly Name")
         If me._friendlyName = "" Then
            me._friendlyName = TCertDump.FirstDumpField(pLines, "Nome amigável", "")
         End If
         me._hasPrivateKey = Not TCertDump.BlockMissingPrivateKey(pLines)
         me._isRoot = TCertDump.BlockContains(pLines, "Certificado raiz") Or TCertDump.BlockContains(pLines, "Root Certificate")
         If Not Assigned(me._location) Then
            me._location = TCertLocation.CurrentUser()
         End If
         If Not Assigned(me._store) Then
            me._store = TCertStoreName.My()
         End If
         me._locator = me.BuildLocator()
      End Sub

      Private Sub ParseLeafDump(pLines As StringList)
         Dim leaf As StringList = TCertDump.ExtractLeafCert(pLines)
         me.ApplyDump(leaf)
         leaf.Free()
      End Sub

      Shared Function NormalizeHash(pValue As String) As String
         NormalizeHash = TCertDump.NormalizeHash(pValue)
      End Function

      Sub MarkInstalled()
         me._installed = True
         me._cleaned = False
      End Sub

      Property Locator As String
         Get
            Locator = me._locator
         End Get
         Set(pValue As String)
            me._locator = pValue
         End Set
      End Property

      Property Path As String
         Get
            Path = me._path
         End Get
      End Property

      Property Pass As String
         Get
            Pass = me._pass
         End Get
      End Property

      Property Name As String
         Get
            Name = me._name
         End Get
      End Property

      Property Serie As String
         Get
            Serie = me._serie
         End Get
      End Property

      Property Thumbprint As String
         Get
            Thumbprint = me._thumbprint
         End Get
      End Property

      Property DateStart As TDateTime
         Get
            DateStart = me._datestart
         End Get
      End Property

      Property DateEnd As TDateTime
         Get
            DateEnd = me._dateend
         End Get
      End Property

      Property Installed As Boolean
         Get
            Installed = me._installed
         End Get
      End Property

      Property Cleaned As Boolean
         Get
            Cleaned = me._cleaned
         End Get
      End Property

      Property Location As TCertLocation
         Get
            Location = me._location
         End Get
         Set(pValue As TCertLocation)
            me._location = pValue
            me._locator = me.BuildLocator()
         End Set
      End Property

      Property Store As TCertStoreName
         Get
            Store = me._store
         End Get
         Set(pValue As TCertStoreName)
            me._store = pValue
            me._locator = me.BuildLocator()
         End Set
      End Property

      Property Subject As String
         Get
            Subject = me._subject
         End Get
      End Property

      Property Issuer As String
         Get
            Issuer = me._issuer
         End Get
      End Property

      Property IssuerName As String
         Get
            IssuerName = me._issuerName
         End Get
      End Property

      Property FriendlyName As String
         Get
            FriendlyName = me._friendlyName
         End Get
      End Property

      Property HasPrivateKey As Boolean
         Get
            HasPrivateKey = me._hasPrivateKey
         End Get
      End Property

      Property IsRoot As Boolean
         Get
            IsRoot = me._isRoot
         End Get
      End Property

      Property IsExpired As Boolean
         Get
            If me._dateend = 0 Then
               IsExpired = False
            Else
               IsExpired = (me._dateend < DateTime())
            End If
         End Get
      End Property

      Property IsNotYetValid As Boolean
         Get
            If me._datestart = 0 Then
               IsNotYetValid = False
            Else
               IsNotYetValid = (me._datestart > DateTime())
            End If
         End Get
      End Property

      Property IsValid As Boolean
         Get
            IsValid = (Not me.IsExpired) And (Not me.IsNotYetValid) And (me._dateend <> 0)
         End Get
      End Property

      Function DaysToExpire() As Integer
         If me._dateend = 0 Then
            DaysToExpire = 0
            Exit Function
         End If
         Dim days As Double = me._dateend.DaySpan(DateTime())
         If me._dateend < DateTime() Then
            DaysToExpire = -CInt(days)
         Else
            DaysToExpire = CInt(days)
         End If
      End Function

      Function Matches(pQuery As String) As Boolean
         Dim q As String = UCase(Trim(pQuery))
         If q = "" Then
            Matches = True
            Exit Function
         End If
         If InStr(UCase(me._name), q) > 0 Then
            Matches = True
            Exit Function
         End If
         If InStr(UCase(me._thumbprint), q) > 0 Then
            Matches = True
            Exit Function
         End If
         If InStr(UCase(me._serie), q) > 0 Then
            Matches = True
            Exit Function
         End If
         If InStr(UCase(me._subject), q) > 0 Then
            Matches = True
            Exit Function
         End If
         If InStr(UCase(me._issuer), q) > 0 Then
            Matches = True
            Exit Function
         End If
         If InStr(UCase(me._friendlyName), q) > 0 Then
            Matches = True
            Exit Function
         End If
         If InStr(UCase(me._locator), q) > 0 Then
            Matches = True
            Exit Function
         End If
         Matches = False
      End Function

      Sub Clean()
         If Not me._installed Then
            me._cleaned = True
            Exit Sub
         End If
         If me._thumbprint = "" Then
            Exit Sub
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-delstore " & me._store.AsString & " " & me._thumbprint.Quoted())
         TCertUtil.Instance().ExecChecked(args, "Erro ao remover o certificado: " & me._name & " [" & me._thumbprint & "]")
         me._installed = False
         me._cleaned = True
      End Sub

      Sub Delete()
         me.Clean()
      End Sub

      Function ExportPfx(pOutFile As String, pPass As String, pModifiers As String = "NoRoot") As TCertificate
         If me._thumbprint = "" Then
            Throw New Exception("Certificado sem thumbprint para exportar.")
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-f -p " & pPass.Quoted() & " -exportPFX " & me._store.AsString & " " & me._thumbprint.Quoted() & " " & pOutFile.Quoted())
         If Trim(pModifiers) <> "" Then
            args = args & " " & Trim(pModifiers)
         End If
         TCertUtil.Instance().ExecChecked(args, "Falha ao exportar PFX: " & pOutFile)
         ExportPfx = me
      End Function

      Function Save(pOutFile As String) As TCertificate
         If me._thumbprint = "" Then
            Throw New Exception("Certificado sem thumbprint para salvar.")
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-store " & me._store.AsString & " " & me._thumbprint.Quoted() & " " & pOutFile.Quoted())
         TCertUtil.Instance().ExecChecked(args, "Falha ao salvar certificado: " & pOutFile)
         Save = me
      End Function

      Function Verify() As StringList
         If me._path <> "" Then
            If IO.File.Exists(me._path) Then
               Verify = TCertUtil.Instance().Exec("-verify " & me._path.Quoted())
               Exit Function
            End If
         End If
         If me._thumbprint = "" Then
            Throw New Exception("Nao ha arquivo nem thumbprint para verificar o certificado.")
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-verifystore " & me._store.AsString & " " & me._thumbprint.Quoted())
         Verify = TCertUtil.Instance().Exec(args)
      End Function

      Function Dump() As StringList
         If me._path <> "" Then
            If IO.File.Exists(me._path) Then
               Dump = TCertUtil.Instance().DumpFile(me._path, me._pass)
               Exit Function
            End If
         End If
         If me._thumbprint = "" Then
            Throw New Exception("Nao ha arquivo nem thumbprint para despejar o certificado.")
         End If
         Dim args As String = TCertUtil.Instance().Prefix(me._location, "-store " & me._store.AsString & " " & me._thumbprint.Quoted())
         Dump = TCertUtil.Instance().Exec(args)
      End Function

      Function Copy() As TCertificate
         Dim clone As New TCertificate()
         clone.Assign(me)
         clone.CleanOnFree = False
         Copy = clone
      End Function

      Function Clone() As TCertificate
         Clone = me.Copy()
      End Function

      Sub Assign(pSource As TCertificate)
         If Not Assigned(pSource) Then
            Exit Sub
         End If
         me._path = pSource._path
         me._pass = pSource._pass
         me._serie = pSource._serie
         me._name = pSource._name
         me._thumbprint = pSource._thumbprint
         me._datestart = pSource._datestart
         me._dateend = pSource._dateend
         me._locator = pSource._locator
         me._installed = pSource._installed
         me._cleaned = pSource._cleaned
         me._location = pSource._location
         me._store = pSource._store
         me._subject = pSource._subject
         me._issuer = pSource._issuer
         me._issuerName = pSource._issuerName
         me._friendlyName = pSource._friendlyName
         me._hasPrivateKey = pSource._hasPrivateKey
         me._isRoot = pSource._isRoot
         me.Use = pSource.Use
      End Sub

      Function WinHttpLocators() As StringList
         Dim list As New StringList()
         me.AddLocatorCandidate(list, me._locator)
         me.AddLocatorCandidate(list, me._name)
         me.AddLocatorCandidate(list, me._location.AsString & "\" & UCase(me._store.AsString) & "\" & me._name)
         me.AddLocatorCandidate(list, me._thumbprint)
         me.AddLocatorCandidate(list, me._location.AsString & "\" & UCase(me._store.AsString) & "\" & me._thumbprint)
         WinHttpLocators = list
      End Function

      Private Sub AddLocatorCandidate(pList As StringList, pValue As String)
         Dim value As String = Trim(pValue)
         If value = "" Then
            Exit Sub
         End If
         If pList.IndexOf(value) >= 0 Then
            Exit Sub
         End If
         pList.Add(value)
      End Sub

      Private Function BuildLocator() As String
         Dim loc As String = me._location.AsString
         If loc = "" Then
            loc = TCertLocation.CurrentUser().AsString
         End If
         Dim store As String = me._store.AsString
         If store = "" Then
            store = TCertStoreName.My().AsString
         End If
         store = UCase(store)
         If me._name <> "" Then
            BuildLocator = loc & "\" & store & "\" & me._name
            Exit Function
         End If
         If me._thumbprint <> "" Then
            BuildLocator = loc & "\" & store & "\" & me._thumbprint
            Exit Function
         End If
         BuildLocator = ""
      End Function

      Overrides Function GetID() As String
         If me._thumbprint <> "" Then
            GetID = me._thumbprint
            Exit Function
         End If
         If me._name <> "" Then
            GetID = me._name
            Exit Function
         End If
         GetID = MyBase.GetID()
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("Certificate")
            .Prop("Locator", me.Locator)
            .Prop("Location", me.Location.AsString)
            .Prop("Store", me.Store.AsString)
            .Prop("Path", me.Path)
            .Prop("Name", me.Name)
            .Prop("FriendlyName", me.FriendlyName)
            .Prop("Serie", me.Serie)
            .Prop("Thumbprint", me.Thumbprint)
            .Prop("IssuerName", me.IssuerName)
            .Prop("DateStart", me.DateStart.ToString())
            .Prop("DateEnd", me.DateEnd.ToString())
            .Prop("IsValid", me.IsValid)
            .Prop("IsExpired", me.IsExpired)
            .Prop("DaysToExpire", me.DaysToExpire())
            .Prop("HasPrivateKey", me.HasPrivateKey)
            .Prop("IsRoot", me.IsRoot)
            .Prop("Installed", me.Installed)
            .Prop("Cleaned", me.Cleaned)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If me.CleanOnFree Then
            me.Clean()
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
