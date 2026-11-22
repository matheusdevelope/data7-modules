Imports mod_tobject

Namespace google_drive_list_options

   Class GoogleDriveListOptions
      Inherits TTObject

      Query As String
      PageSize As Integer
      PageToken As String
      OrderBy As String
      Fields As String
      Corpora As String
      DriveId As String

      Sub New()
         MyBase.New()
         me.PageSize = 100
      End Sub

      Sub Assign(pValue As GoogleDriveListOptions)
         If Not Assigned(pValue) Then
            Exit Sub
         End If
         me.Query = pValue.Query
         me.PageSize = pValue.PageSize
         me.PageToken = pValue.PageToken
         me.OrderBy = pValue.OrderBy
         me.Fields = pValue.Fields
         me.Corpora = pValue.Corpora
         me.DriveId = pValue.DriveId
      End Sub

      Overrides Function Clone() As GoogleDriveListOptions
         Dim copy As New GoogleDriveListOptions()
         copy.Assign(me)
         Clone = copy
      End Function

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
