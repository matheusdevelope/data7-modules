Imports mod_tobject
Imports mod_wa_attachment
Imports Collections

Namespace mod_wa_message

   Class WaMessage
      Inherits TTObject

      Recipient As String
      Sender As String
      Subject As String
      Content As String
      Signature As String
      Attachments As WaAttachmentList
      Formatter As WaMessageFormatter

      Sub New()
         MyBase.New()
         me.Attachments = New WaAttachmentList()
      End Sub

      Function HasText() As Boolean
         HasText = me.Subject.Trim() <> "" Or me.Content.Trim() <> "" Or me.Signature.Trim() <> ""
      End Function

      Function AsText() As String
         If Assigned(me.Formatter) Then
            AsText = me.Formatter.FormatText(me)
            Exit Function
         End If
         Dim _layout As New WaMessageLayout()
         AsText = _layout.Render(me)
         _layout.Free()
      End Function

      Overrides Function GetID() As String
         GetID = me.Recipient + "|" + me.Sender
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaMessage")
            .Prop("Recipient", me.Recipient)
            .Prop("Sender", me.Sender)
            .Prop("Subject", me.Subject)
            .Prop("Content", me.Content)
            .Prop("Signature", me.Signature)
            .Prop("Attachments", me.Attachments.Count())
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me.Attachments) Then
            me.Attachments.Free()
            me.Attachments = Null
         End If
         me.Formatter = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaMessageList
      Inherits TTObject

      Private _list As TTObjectList

      Sub New()
         MyBase.New()
         me._list = New TTObjectList("WaMessageList", True)
      End Sub

      Sub Add(pMessage As WaMessage)
         me._list.Push(pMessage)
      End Sub

      Function Take(pIndex As Integer) As WaMessage
         Take = WaMessage(me._list.Take(pIndex))
      End Function

      Function Count() As Integer
         Count = me._list.Length()
      End Function

      Overrides Sub Dispose()
         If Assigned(me._list) Then
            me._list.Free()
            me._list = Null
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
