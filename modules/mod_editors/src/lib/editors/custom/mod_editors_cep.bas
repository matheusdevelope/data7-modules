Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_cep

   Structure TCEPEditorData
      CEP As String
      Logradouro As String
      Complemento As String
      Unidade As String
      Bairro As String
      Localidade As String
      UF As String
      Estado As String
      Regiao As String
      IBGE As String
      DDD As String
      Siafi As String
   End Structure

   Class TCEPEditor
      Inherits TDocEditor

      Data As TCEPEditorData
      OnLoadData As TNotifyEvent

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.ImageBase64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAIdUAACHVAQSctJ0AAAH8SURBVDhPzZBLbExhGIaf/z+XaWempMak1GDiliZ1mbAQtFoLiSBi4VZBYiMhsWiEjYiFldSuNm0TscFCWNhKNamFa0UvGWGjhNGitHM7M+ecf36LiVZHwpIneRffl7xv3u+Df42oXMxi85GTaLGGogOeC8rD2nO84GV1J1cPvuWvARvbVmJXP8F3a3GLCK0wjp3BV8EkL0Y2ceNo2qj0zOLjyDfqG5OY9gEE0mzeiR9vgHA4SsBeTm/s7p8DAD4MvWHxWmmsWN2qViVACLAtCIUaSUSy0yc8u8b6ujquSIu5pgWmDaYFeZf+Jfeu31LGnEc6VCMJhZnWZPa+AdDXxfz6CL22TcIyWWhZZSEoXXq44+zjLw13tBC1CAFSlFtoncKf2iW7TmBFg9zUmqXKA+WX5XsURlNVhzsHWy/rfC5OwYGiAwUHnLzL+Ls2Tjel5JatXDRgu/LA90F5ZU1McW5dz6kWncu2UMw7FPIOTt7ByWWYHG/nwu5+ADMSI5j7DL5bbiYEZL4K/eqlmeN1sptFTgff4zNPzQYUA93ez1HoPsyxEg/SYzQDoATvByVGlS5OuLJpf4f/fMb9O1Jsw09lOFQT5VNJCUYHTJQP0iCwIKJu97Qzr9L0KxJgw15SrsE+IXmaTRtDbskcLipzWAsjsyxWfb7S9H/xA6G5xpy7A9gvAAAAAElFTkSuQmCC"
         me.ButtonVisible = True
         me.Mascara = "99.999-999"
         me.ButtonHint = "Buscar o endereço nos correios (Logradouro, Bairro, Município e UF)"
         me.OnButtonClick = me._handleOnButtonClick
      End Sub

      Protected Overrides Function ValidateValue() As String
         If TDocs.IsValidCEP(me.Text) Then
            ValidateValue = ""
         Else
            ValidateValue = "CEP inválido, o CEP deve conter 8 dígitos."
         End If
      End Function

      Private Sub _handleOnButtonClick(pSender As TObject)
         me.Consultar()
      End Sub

      Function Consultar() As Boolean
         Dim cep As String = me.OnlyDigits()
         Dim _consultar As Boolean = False
         If Not TDocs.IsValidCEP(cep) Then
            Forms.MessageBox.Show("CEP inválido, o CEP deve conter 8 dígitos.")
            me.SetFocus()
            Consultar = False
            Exit Function
         End If
         Dim http As THttp
         Try
            http = New THttp()
            http.Accept = "application/json"
            http.ContentType = "application/json"
            http.SslVersion = TLSv1_2
            Dim response As String = http.Get($"https://viacep.com.br/ws/{cep}/json/")
            If http.ResponseCode <> 200 Then
               Throw New Exception($"Status: {CStr(http.ResponseCode)} - {http.ResponseText}")
            End If
            me._fill(New TJSONObject(response))
            If me.OnLoadData <> Null Then
               me.OnLoadData(me)
            End If
            _consultar =  True
         Catch ex As Exception
            Forms.MessageBox.Show($"Erro ao obter dados do CEP [{cep}]:{Char(13)}{ex._GetMessage()}")
            _consultar = False
         End Try
         If http <> Null Then
            http.Free()
         End If
         Consultar = _consultar
      End Function

      Shared Function LookupIbge(pCep As String) As String
         Dim cep As String = TText.OnlyDigits(pCep)
         Dim ibge As String = ""
         If Not TDocs.IsValidCEP(cep) Then
            LookupIbge = ""
            Exit Function
         End If
         Dim http As THttp
         Try
            http = New THttp()
            http.Accept = "application/json"
            http.ContentType = "application/json"
            http.SslVersion = TLSv1_2
            Dim response As String = http.Get($"https://viacep.com.br/ws/{cep}/json/")
            If http.ResponseCode <> 200 Then
               Throw New Exception($"Status: {CStr(http.ResponseCode)} - {http.ResponseText}")
            End If
            Dim json As TJSONObject = New TJSONObject(response)
            If json.Has("ibge") Then
               ibge = json.GetString("ibge")
            Else
               ibge = ""
            End If
            json.Free()
         Catch ex As Exception
            ibge = ""
         End Try
         If http <> Null Then
            http.Free()
         End If
         LookupIbge = ibge
      End Function

      Private Function _jsonString(pJson As TJSONObject, pKey As String) As String
         If pJson.Has(pKey) Then
            _jsonString = pJson.GetString(pKey)
         End If
      End Function

      Private Sub _fill(pJson As TJSONObject)
         me.Data.CEP = me._jsonString(pJson, "cep")
         me.Data.Logradouro = me._jsonString(pJson, "logradouro")
         me.Data.Complemento = me._jsonString(pJson, "complemento")
         me.Data.Unidade = me._jsonString(pJson, "unidade")
         me.Data.Bairro = me._jsonString(pJson, "bairro")
         me.Data.Localidade = me._jsonString(pJson, "localidade")
         me.Data.UF = me._jsonString(pJson, "uf")
         me.Data.Estado = me._jsonString(pJson, "estado")
         me.Data.Regiao = me._jsonString(pJson, "regiao")
         me.Data.IBGE = me._jsonString(pJson, "ibge")
         me.Data.DDD = me._jsonString(pJson, "ddd")
         me.Data.Siafi = me._jsonString(pJson, "siafi")
         pJson.Free()
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
