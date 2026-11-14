Imports Forms
Imports mod_editors
Imports mod_editors_docs
Imports mod_validators

Namespace mod_editors_cnpj

   Structure TCNPJData
      CNPJ As String
      RazaoSocial As String
      NomeFantasia As String
      Logradouro As String
      Numero As String
      Complemento As String
      CEP As String
      Bairro As String
      Municipio As String
      UF As String
      Email As String
      Telefone As String
      Situacao As String
      DataAbertura As TDateTime
      Tipo As String
      Porte As String
      NaturezaJuridica As String
      DataSituacao As TDateTime
      DataHoraInclusao As TDateTime
      DataHoraUltimaAtualizacao As TDateTime
      OrigemDados As String
      Loaded As Boolean
   End Structure

   Class TCNPJEditor
      Inherits TDocEditor

      Data As TCNPJData
      OnLoadData As TNotifyEvent

      Sub New(pParent As TWinControl, pCaption As String, pProps As TEditorProps = Null)
         MyBase.New(pParent, pCaption, pProps)
         me.ImageBase64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAARCAYAAADUryzEAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAIASURBVHjapJQ9axRRFIbv7OZjDZEQULGw8hf4Wwa2ME0IIVgEqyWNH90ScLnEZhGRxSZsExiLhRWNWYsIE0GYRYUFP1gLiwGLzAtbXCTFY7H3LgMxVYrDqZ73vO+cc8cA5jJlJK1KqklakhRJqvi6k56M6fRG2IOMzmFOtzfG7tnPgDk9Pa0CkZF0TdIVSVVJRtINSdGbtz//OKA4g+wMBgWkE+gOHU+evnOSqsHBsp9u/OTVo8H3L+mPAgcUbgonv6D/GwYTSL46Gjttjo+PTYDmfY8kmf6HnMzBaAIDD6UO0jPfHTSf9VnfWH8eBBYCLGlh/yh3mYNBPp2eASNg7GsEtF9lbN/fJghUJS36fnX/KP+buant1E2BHCh8HwOdXkZcjyk7qM0ivM9JJ9DPp7bHHpaE8wL2ZX8mEJXsX5dUyYZ50f1UkPrs5wQKx+bGw1kE462HTZhHD7rfbCshGbpZhJA/LxzN3Q5xPcbuWYykudLxRAwtHMbYlqWxY2m+GNDuZSQnOd3XIxo7dgZLmg8OjCQT4GxvjebjDraVIOn21r2tSVyPiesxmxubAV6SZP4L21bC2t01SuI1Sbck3ZS04uG5mQAfG9kFcPi4K6VDq5bOPjJZ78LJlZJIpeQmbG1O0qJJDpIpvHvOdtjOsn9s4cGF01+StGgu+z/4NwBmUTfl1IyMOAAAAABJRU5ErkJggg=="
         me.ButtonVisible = True
         me.CharCase = CharCaseFromCode("U")
         me.Mascara = "CC.CCC.CCC/CCCC-99"
         me.MaxLength = 18
         me.ButtonHint = "Consultar dados do CNPJ"
         me.OnButtonClick = me._handleOnButtonClick
      End Sub

      Protected Overridable Function CheckDocument() As String
         If TDocs.IsValidCNPJ(me.Text) Then
            CheckDocument = ""
         Else
            CheckDocument = "CNPJ inválido. Informe 14 caracteres (numérico ou alfanumérico) com dígitos verificadores corretos."
         End If
      End Function

      Protected Overridable Overrides Function ValidateValue() As String
         ValidateValue = me.CheckDocument()
      End Function

      Private Sub _handleOnButtonClick(pSender As TObject)
         Dim cnpj As String = TText.OnlyAlphaNum(me.Text)
         If Not TDocs.IsValidCNPJ(cnpj) Then
            Forms.MessageBox.Show("CNPJ inválido. Informe 14 caracteres (numérico ou alfanumérico) com dígitos verificadores corretos.")
            me.SetFocus()
            Exit Sub
         End If
         Try
            Dim msg As String = Char(13)
            Try
               me._loadFromData7API(cnpj)
            Catch ex1 As Exception
               msg += $"Consulta 1: {ex1._GetMessage()}{Char(13)}{Char(13)}"
               Try
                  me._loadFromBrasilAPI(cnpj)
               Catch ex2 As Exception
                  msg += $"Consulta 2: {ex2._GetMessage()}{Char(13)}{Char(13)}"
                  Try
                     me._loadFromReceitaAPI(cnpj)
                  Catch ex3 As Exception
                     msg += $"Consulta 3: {ex3._GetMessage()}{Char(13)}{Char(13)}"
                     Throw New Exception(msg)
                  End Try
               End Try
            End Try
            me.Data.Loaded = True
            If me.OnLoadData <> Null Then
               me.OnLoadData(me)
            End If
         Catch ex As Exception
            Forms.MessageBox.Show($"Erro ao obter dados do CNPJ [{cnpj}]:{Char(13)}{ex._GetMessage()}")
            me.Data.Loaded = False
         End Try
      End Sub

      Private Function _jsonString(pJson As TJSONObject, pKey As String) As String
         If pJson.Has(pKey) Then
            _jsonString = pJson.GetString(pKey)
         End If
      End Function

      Private Function _jsonIsoDate(pJson As TJSONObject, pKey As String) As TDateTime
         If pJson.Has(pKey) Then
            Dim raw As String = Trim(pJson.GetString(pKey))
            If raw <> "" Then
               Dim dt As TDateTime = DateTime()
               _jsonIsoDate = dt.FromISOString(raw)
            End If
         End If
      End Function

      Private Function _jsonBrDate(pJson As TJSONObject, pKey As String) As TDateTime
         If pJson.Has(pKey) Then
            Dim raw As String = Trim(pJson.GetString(pKey))
            If raw <> "" Then
               _jsonBrDate = StrToDate(raw)
            End If
         End If
      End Function

      Private Function _httpGet(pUrl As String, pHeader As String = "") As String
         Dim http As THttp
         Try
            http = New THttp()
            http.Accept = "application/json"
            http.ContentType = "application/json"
            http.SslVersion = TLSv1_2
            If pHeader <> "" Then
               http.AddCustomHeader(pHeader)
            End If
            Dim body As String = http.Get(pUrl)
            If http.ResponseCode <> 200 Then
               Throw New Exception($"Status: {CStr(http.ResponseCode)} - {http.ResponseText}")
            End If
            _httpGet = body
         Catch ex As Exception
            Throw
         End Try
         If http <> Null Then
            http.Free()
         End If
      End Function

      Private Sub _loadFromData7API(pCNPJ As String)
         Try
            Dim body As String = me._httpGet($"http://se7ews.se7esistemas.com.br/cnpj/?digitos={pCNPJ}&forcarAtualizacao=Nao&aplicacao=Data7", "Authorization: Bearer MjAyNTEwMjVUMTAyNzE1OTkzXzFiODNiZDk2OTVjZjcwNTIxMGNlM2JkOWM3ZGM3MzJhMTI1MjA5ZTliMzAxNDVjNTQyNWUyNjU5OGZlNWMxNWI=")
            me._fillData7(New TJSONObject(body))
         Catch ex As Exception
            Throw New Exception($"Erro ao obter dados do CNPJ [{pCNPJ}] - Data7 API:{Char(13)}{ex._GetMessage()}")
         End Try
      End Sub

      Private Sub _fillData7(pJson As TJSONObject)
         me.Data.CNPJ = me._jsonString(pJson, "cnpj")
         me.Data.RazaoSocial = me._jsonString(pJson, "razaoSocial")
         me.Data.NomeFantasia = me._jsonString(pJson, "nomeFantasia")
         me.Data.Logradouro = me._jsonString(pJson, "logradouro")
         me.Data.Numero = me._jsonString(pJson, "numero")
         me.Data.Complemento = me._jsonString(pJson, "complemento")
         me.Data.CEP = me._jsonString(pJson, "cep")
         me.Data.Bairro = me._jsonString(pJson, "bairro")
         me.Data.Municipio = me._jsonString(pJson, "municipio")
         me.Data.UF = me._jsonString(pJson, "uf")
         me.Data.Email = me._jsonString(pJson, "email")
         me.Data.Telefone = me._jsonString(pJson, "telefone")
         me.Data.Situacao = me._jsonString(pJson, "situacao")
         me.Data.DataAbertura = me._jsonIsoDate(pJson, "dataAbertura")
         me.Data.Tipo = me._jsonString(pJson, "tipo")
         me.Data.Porte = me._jsonString(pJson, "porte")
         me.Data.NaturezaJuridica = me._jsonString(pJson, "naturezaJuridica")
         me.Data.DataSituacao = me._jsonIsoDate(pJson, "dataSituacao")
         me.Data.DataHoraInclusao = me._jsonIsoDate(pJson, "dataHoraInclusao")
         me.Data.DataHoraUltimaAtualizacao = me._jsonIsoDate(pJson, "dataHoraUltimaAtualizacao")
         me.Data.OrigemDados = me._jsonString(pJson, "origemDados")
         pJson.Free()
      End Sub

      Private Sub _loadFromBrasilAPI(pCNPJ As String)
         Try
            Dim body As String = me._httpGet($"https://brasilapi.com.br/api/cnpj/v1/{pCNPJ}")
            me._fillBrasil(New TJSONObject(body))
         Catch ex As Exception
            Throw New Exception($"Erro ao obter dados do CNPJ [{pCNPJ}] - Brasil API:{Char(13)}{ex._GetMessage()}")
         End Try
      End Sub

      Private Sub _fillBrasil(pJson As TJSONObject)
         me.Data.CNPJ = me._jsonString(pJson, "cnpj")
         me.Data.RazaoSocial = me._jsonString(pJson, "razao_social")
         me.Data.NomeFantasia = me._jsonString(pJson, "nome_fantasia")
         me.Data.Logradouro = me._jsonString(pJson, "logradouro")
         me.Data.Numero = me._jsonString(pJson, "numero")
         me.Data.Complemento = me._jsonString(pJson, "complemento")
         me.Data.CEP = me._jsonString(pJson, "cep")
         me.Data.Bairro = me._jsonString(pJson, "bairro")
         me.Data.Municipio = me._jsonString(pJson, "municipio")
         me.Data.UF = me._jsonString(pJson, "uf")
         me.Data.Email = me._jsonString(pJson, "email")
         me.Data.Telefone = me._jsonString(pJson, "telefone")
         me.Data.Situacao = me._jsonString(pJson, "descricao_situacao_cadastral")
         me.Data.DataAbertura = me._jsonIsoDate(pJson, "data_inicio_atividade")
         me.Data.Tipo = me._jsonString(pJson, "descricao_identificador_matriz_filial")
         me.Data.Porte = me._jsonString(pJson, "porte")
         me.Data.NaturezaJuridica = me._jsonString(pJson, "natureza_juridica")
         me.Data.DataSituacao = me._jsonIsoDate(pJson, "data_situacao_cadastral")
         me.Data.DataHoraInclusao = me.Data.DataSituacao
         me.Data.DataHoraUltimaAtualizacao = me.Data.DataSituacao
         me.Data.OrigemDados = "BrasilAPI"
         pJson.Free()
      End Sub

      Private Sub _loadFromReceitaAPI(pCNPJ As String)
         Try
            Dim body As String = me._httpGet($"https://www.receitaws.com.br/v1/cnpj/{pCNPJ}")
            me._fillReceita(New TJSONObject(body))
         Catch ex As Exception
            Throw New Exception($"Erro ao obter dados do CNPJ [{pCNPJ}] - Receita API:{Char(13)}{ex._GetMessage()}")
         End Try
      End Sub

      Private Sub _fillReceita(pJson As TJSONObject)
         If pJson.Has("status") Then
            If UCase(pJson.GetString("status")) = "ERROR" Then
               Dim errMsg As String = pJson.GetString("message")
               pJson.Free()
               Throw New Exception(errMsg)
            End If
         End If
         me.Data.CNPJ = me._jsonString(pJson, "cnpj")
         me.Data.RazaoSocial = me._jsonString(pJson, "nome")
         me.Data.NomeFantasia = me._jsonString(pJson, "fantasia")
         me.Data.Logradouro = me._jsonString(pJson, "logradouro")
         me.Data.Numero = me._jsonString(pJson, "numero")
         me.Data.Complemento = me._jsonString(pJson, "complemento")
         me.Data.CEP = me._jsonString(pJson, "cep")
         me.Data.Bairro = me._jsonString(pJson, "bairro")
         me.Data.Municipio = me._jsonString(pJson, "municipio")
         me.Data.UF = me._jsonString(pJson, "uf")
         me.Data.Email = me._jsonString(pJson, "email")
         me.Data.Telefone = me._jsonString(pJson, "telefone")
         me.Data.Situacao = me._jsonString(pJson, "situacao")
         me.Data.DataAbertura = me._jsonBrDate(pJson, "abertura")
         me.Data.Tipo = me._jsonString(pJson, "tipo")
         me.Data.Porte = me._jsonString(pJson, "porte")
         me.Data.NaturezaJuridica = me._jsonString(pJson, "natureza_juridica")
         me.Data.DataSituacao = me._jsonBrDate(pJson, "data_situacao")
         me.Data.DataHoraInclusao = me.Data.DataSituacao
         me.Data.DataHoraUltimaAtualizacao = me.Data.DataSituacao
         me.Data.OrigemDados = "Receita"
         pJson.Free()
      End Sub

      Overrides Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
