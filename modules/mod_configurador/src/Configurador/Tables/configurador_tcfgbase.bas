Imports mod_tobject

Namespace configurador_tcfgbase
   Private Declare Function CharUpperBuffW Lib "user32" (ByVal lpsz As String, ByVal cchLength As Long) As Long

   Function FoldBoolToken(pText As String) As String
      pText = pText
      CharUpperBuffW(pText, Len(pText))
      FoldBoolToken = pText
   End Function

   MustInherit Class TCfgBase
      Inherits TTObject

      Protected _name As String
      Protected _boolTrue As String
      Protected _boolFalse As String
      Protected _loaded As Boolean = False

      Sub New(pName As String, pBoolTrue As String = "S", pBoolFalse As String = "N")
         MyBase.New()
         me._name = pName
         me._boolTrue = FoldBoolToken(Trim(pBoolTrue))
         me._boolFalse = FoldBoolToken(Trim(pBoolFalse))
      End Sub

      Overridable Function GetFlagAsBoolean(pValue As String) As Boolean
         GetFlagAsBoolean = (FoldBoolToken(Trim(pValue)) = me._boolTrue)
      End Function

      Overridable Function GetFlagAsString(pValue As Boolean) As String
         If pValue Then
            GetFlagAsString = me._boolTrue
         Else
            GetFlagAsString = me._boolFalse
         End If
      End Function

      MustOverride Overridable Sub Fill(pJson As TJSONObject)
      End Sub

      MustOverride Overridable Sub Fill(pQuery As SQL.Command)
      End Sub

      ' MustOverride Overridable Function ToJson() As TJSONObject
      ' End Function

      ' MustOverride Overridable Function ToQuery() As SQL.Command
      ' End Function

      Overridable Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class
End Namespace