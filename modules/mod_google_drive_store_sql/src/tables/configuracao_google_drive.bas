Imports Data7
Imports TablesSchema
Imports TablesTable
Imports TablesSql
Imports TablesField

Namespace configuracao_google_drive

   Class TConfiguracaoGoogleDrive
      Inherits TTableOf<TConfiguracaoGoogleDrive>

      Sub New()
         MyBase.New("TConfiguracaoGoogleDrive")
      End Sub

      Overrides Sub DefineSchema(pSchema As TTableSchema)
         pSchema.SchemaName = "Customizado"
         pSchema.TableName = "ConfiguracaoGoogleDrive"
         pSchema.Sequence = "Customizado.ConfiguracaoGoogleDrive_Sequencia"
         pSchema.Field("CodConfiguracaoGoogleDrive").AsInteger().AutoCodeField().WithSequence("Customizado.ConfiguracaoGoogleDrive_Sequencia")
         pSchema.Field("Titulo").AsString().MaxLen(150).RequiredField()
         pSchema.Field("Email").AsString().MaxLen(255)
         pSchema.Field("Nome").AsString().MaxLen(200)
         pSchema.Field("Ativo").AsBoolean().DefaultVal(True)
         pSchema.Field("ClientId").AsString().MaxLen(200)
         pSchema.Field("ClientSecret").AsString().MaxLen(500)
         pSchema.Field("Scopes").AsString().MaxLen(1000)
         pSchema.Field("CallbackPort").AsInteger().DefaultVal(8085)
         pSchema.Field("StoreKey").AsString().MaxLen(250)
         pSchema.Field("AccessToken").AsString().MaxLen(4000)
         pSchema.Field("RefreshToken").AsString().MaxLen(4000)
         pSchema.Field("IdToken").AsString().MaxLen(4000)
         pSchema.Field("TokenType").AsString().MaxLen(50)
         pSchema.Field("ExpiresIn").AsInteger()
         pSchema.Field("CreatedAt").AsDateTime()
         pSchema.Field("ExpiresAt").AsDateTime()
      End Sub

      Shared Function CurrentRow() As TConfiguracaoGoogleDrive
         CurrentRow = TConfiguracaoGoogleDrive.Find("")
      End Function

      Shared Function HasRow() As Boolean
         HasRow = TConfiguracaoGoogleDrive.Exists("")
      End Function

      Shared Function SqlQuote(pValue As String) As String
         Dim text As String = pValue
         Dim outText As String = ""
         Dim i As Integer
         Dim ch As String
         For i = 1 To Len(text)
            ch = Mid(text, i, 1)
            If ch = "'" Then
               outText = outText & "''"
            Else
               outText = outText & ch
            End If
         Next
         SqlQuote = outText
      End Function

      Shared Function FindByStoreKey(pKey As String) As TConfiguracaoGoogleDrive
         Dim key As String = Trim(pKey)
         If key = "" Then
            FindByStoreKey = Null
            Exit Function
         End If
         FindByStoreKey = TConfiguracaoGoogleDrive.Find("StoreKey = '" & TConfiguracaoGoogleDrive.SqlQuote(key) & "'")
      End Function

      Shared Function FindByEmail(pEmail As String) As TConfiguracaoGoogleDrive
         Dim emailText As String = Trim(pEmail)
         If emailText = "" Then
            FindByEmail = Null
            Exit Function
         End If
         FindByEmail = TConfiguracaoGoogleDrive.Find("Email = '" & TConfiguracaoGoogleDrive.SqlQuote(emailText) & "'")
      End Function

      Shared Function FindByKey(pCod As Integer) As TConfiguracaoGoogleDrive
         If pCod <= 0 Then
            FindByKey = Null
            Exit Function
         End If
         FindByKey = TConfiguracaoGoogleDrive.Find("CodConfiguracaoGoogleDrive = " & CStr(pCod))
      End Function

      Shared Function IsSecretName(pName As String) As Boolean
         Dim n As String = UCase(Trim(pName))
         IsSecretName = (n = "CLIENTSECRET") Or (n = "ACCESSTOKEN") Or (n = "REFRESHTOKEN") Or (n = "IDTOKEN")
      End Function

      Shared Function EncryptValue(pValue As String) As String
         Dim secretValue As String = Trim(pValue)
         If secretValue = "" Then
            EncryptValue = ""
            Exit Function
         End If
         Dim encrypted As String
         encrypted = Data7.Criptografar(secretValue)
         EncryptValue = encrypted
      End Function

      Shared Function DecryptValue(pValue As String) As String
         Dim raw As String = Trim(pValue)
         If raw = "" Then
            DecryptValue = ""
            Exit Function
         End If
         Try
            raw = Data7.Descriptografar(raw)
         Catch ex As Exception
            raw = Trim(pValue)
         End Try
         DecryptValue = raw
      End Function

      Overrides Sub BindField(pCmd As SQL.Command, pField As TField)
         If Not TConfiguracaoGoogleDrive.IsSecretName(pField.Def.Name) Then
            MyBase.BindField(pCmd, pField)
            Exit Sub
         End If
         Try
            pField.NormalizeDate()
            Dim prm As SQL.TFDParam = pCmd.Param(pField.Def.ParamName)
            If pField.IsNull() Then
               prm.Value = Unassigned
               Exit Sub
            End If
            Dim plain As String = pField.AsString
            prm.AsString = TConfiguracaoGoogleDrive.EncryptValue(plain)
         Catch ex As Exception
            Throw New Exception(pField.WrapTypeError(ex))
         End Try
      End Sub

      Overrides Sub ReadField(pField As TField, pSrc As SQL.TField)
         MyBase.ReadField(pField, pSrc)
         If Not TConfiguracaoGoogleDrive.IsSecretName(pField.Def.Name) Then
            Exit Sub
         End If
         If pField.IsNull() Then
            Exit Sub
         End If
         Dim decrypted As String = TConfiguracaoGoogleDrive.DecryptValue(pField.AsString)
         If Trim(decrypted) = "" Then
            pField.Value = Unassigned
         Else
            pField.Value = decrypted
         End If
      End Sub

      Overrides Function GetID() As String
         GetID = CStr(me.CodConfiguracaoGoogleDrive)
      End Function

      Property CodConfiguracaoGoogleDrive As Integer
         Get
            CodConfiguracaoGoogleDrive = me.GetInteger("CodConfiguracaoGoogleDrive")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CodConfiguracaoGoogleDrive", pValue)
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

      Property Email As String
         Get
            Email = me.GetString("Email")
         End Get
         Set(pValue As String)
            me.SetString("Email", pValue)
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

      Property Ativo As Boolean
         Get
            Ativo = me.GetBoolean("Ativo")
         End Get
         Set(pValue As Boolean)
            me.SetBoolean("Ativo", pValue)
         End Set
      End Property

      Property ClientId As String
         Get
            ClientId = me.GetString("ClientId")
         End Get
         Set(pValue As String)
            me.SetString("ClientId", pValue)
         End Set
      End Property

      Property ClientSecret As String
         Get
            ClientSecret = me.GetString("ClientSecret")
         End Get
         Set(pValue As String)
            me.SetString("ClientSecret", pValue)
         End Set
      End Property

      Property Scopes As String
         Get
            Scopes = me.GetString("Scopes")
         End Get
         Set(pValue As String)
            me.SetString("Scopes", pValue)
         End Set
      End Property

      Property CallbackPort As Integer
         Get
            CallbackPort = me.GetInteger("CallbackPort")
         End Get
         Set(pValue As Integer)
            me.SetInteger("CallbackPort", pValue)
         End Set
      End Property

      Property StoreKey As String
         Get
            StoreKey = me.GetString("StoreKey")
         End Get
         Set(pValue As String)
            me.SetString("StoreKey", pValue)
         End Set
      End Property

      Property AccessToken As String
         Get
            AccessToken = me.GetString("AccessToken")
         End Get
         Set(pValue As String)
            me.SetString("AccessToken", pValue)
         End Set
      End Property

      Property RefreshToken As String
         Get
            RefreshToken = me.GetString("RefreshToken")
         End Get
         Set(pValue As String)
            me.SetString("RefreshToken", pValue)
         End Set
      End Property

      Property IdToken As String
         Get
            IdToken = me.GetString("IdToken")
         End Get
         Set(pValue As String)
            me.SetString("IdToken", pValue)
         End Set
      End Property

      Property TokenType As String
         Get
            TokenType = me.GetString("TokenType")
         End Get
         Set(pValue As String)
            me.SetString("TokenType", pValue)
         End Set
      End Property

      Property ExpiresIn As Integer
         Get
            ExpiresIn = me.GetInteger("ExpiresIn")
         End Get
         Set(pValue As Integer)
            me.SetInteger("ExpiresIn", pValue)
         End Set
      End Property

      Property CreatedAt As TDateTime
         Get
            CreatedAt = me.GetDateTime("CreatedAt")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("CreatedAt", pValue)
         End Set
      End Property

      Property ExpiresAt As TDateTime
         Get
            ExpiresAt = me.GetDateTime("ExpiresAt")
         End Get
         Set(pValue As TDateTime)
            me.SetDateTime("ExpiresAt", pValue)
         End Set
      End Property

      Function AccountKey() As String
         AccountKey = CStr(me.CodConfiguracaoGoogleDrive)
      End Function

      Function AccountCaption() As String
         Dim titleText As String
         titleText = Trim(me.Titulo)
         If titleText = "" Then
            titleText = "Google Drive"
         End If
         If Trim(me.Email) <> "" Then
            AccountCaption = titleText & " (" & Trim(me.Email) & ")"
            Exit Function
         End If
         AccountCaption = titleText
      End Function

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
