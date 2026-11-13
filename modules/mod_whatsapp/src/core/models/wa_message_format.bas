Imports Collections
Imports mod_tobject
Imports mod_tenum
Imports mod_wa_attachment

Namespace mod_wa_message

   Enun WaTextPart
      Subject = "Subject"
      Content = "Content"
      Signature = "Signature"
      Blank = "Blank"
   End Enun

   Enun WaAttachmentTextMode
      SeparateBefore = "SeparateBefore"
      SeparateAfter = "SeparateAfter"
      CaptionFirst = "CaptionFirst"
      CaptionLast = "CaptionLast"
      CaptionEach = "CaptionEach"
   End Enun

   Delegate Function WaFormatTextDelegate(pMessage As WaMessage) As String
   Delegate Function WaBuildPlanDelegate(pMessage As WaMessage) As WaSendPlan

   Class WaMessageLayout
      Inherits TTObject

      Private _parts As StringList

      AttachmentTextMode As WaAttachmentTextMode
      SendCaption As Boolean
      AttachmentsReversed As Boolean
      IncludeEmptyParts As Boolean

      Sub New()
         MyBase.New()
         me._parts = New StringList()
         me.AttachmentTextMode = WaAttachmentTextMode.CaptionLast()
         me.SendCaption = True
         me.IncludeEmptyParts = True
         me.UseDefaultParts()
      End Sub

      Shared Function CreateDefault() As WaMessageLayout
         CreateDefault = New WaMessageLayout()
      End Function

      Function UseDefaultParts() As WaMessageLayout
         me._parts.Clear()
         me._parts.Add(WaTextPart.Subject().AsString)
         me._parts.Add(WaTextPart.Content().AsString)
         me._parts.Add(WaTextPart.Blank().AsString)
         me._parts.Add(WaTextPart.Blank().AsString)
         me._parts.Add(WaTextPart.Signature().AsString)
         UseDefaultParts = me
      End Function

      Function ClearParts() As WaMessageLayout
         me._parts.Clear()
         ClearParts = me
      End Function

      Function AddPart(pPart As WaTextPart) As WaMessageLayout
         me._parts.Add(pPart.AsString)
         AddPart = me
      End Function

      Function AddSubject() As WaMessageLayout
         AddSubject = me.AddPart(WaTextPart.Subject())
      End Function

      Function AddContent() As WaMessageLayout
         AddContent = me.AddPart(WaTextPart.Content())
      End Function

      Function AddSignature() As WaMessageLayout
         AddSignature = me.AddPart(WaTextPart.Signature())
      End Function

      Function AddBlank(pCount As Integer = 1) As WaMessageLayout
         Dim i As Integer
         Dim _n As Integer = pCount
         If _n < 1 Then
            _n = 1
         End If
         For i = 1 To _n
            me._parts.Add(WaTextPart.Blank().AsString)
         Next
         AddBlank = me
      End Function

      Function SeparateTextBefore() As WaMessageLayout
         me.AttachmentTextMode = WaAttachmentTextMode.SeparateBefore()
         SeparateTextBefore = me
      End Function

      Function SeparateTextAfter() As WaMessageLayout
         me.AttachmentTextMode = WaAttachmentTextMode.SeparateAfter()
         SeparateTextAfter = me
      End Function

      Function CaptionOnFirst() As WaMessageLayout
         me.AttachmentTextMode = WaAttachmentTextMode.CaptionFirst()
         CaptionOnFirst = me
      End Function

      Function CaptionOnLast() As WaMessageLayout
         me.AttachmentTextMode = WaAttachmentTextMode.CaptionLast()
         CaptionOnLast = me
      End Function

      Function CaptionOnEach() As WaMessageLayout
         me.AttachmentTextMode = WaAttachmentTextMode.CaptionEach()
         CaptionOnEach = me
      End Function

      Function WithSendCaption(pValue As Boolean) As WaMessageLayout
         me.SendCaption = pValue
         WithSendCaption = me
      End Function

      Function ReverseAttachments() As WaMessageLayout
         me.AttachmentsReversed = True
         ReverseAttachments = me
      End Function

      Function KeepEmptyParts(pValue As Boolean) As WaMessageLayout
         me.IncludeEmptyParts = pValue
         KeepEmptyParts = me
      End Function

      Function IsCaptionLast() As Boolean
         IsCaptionLast = me.ModeName() = "CaptionLast"
      End Function

      Function ModeName() As String
         If Assigned(me.AttachmentTextMode) Then
            ModeName = me.AttachmentTextMode.AsString
         Else
            ModeName = "CaptionLast"
         End If
      End Function

      Function EffectiveModeName() As String
         Dim _mode As String = me.ModeName()
         If Not me.SendCaption Then
            If _mode = "CaptionFirst" Or _mode = "CaptionLast" Or _mode = "CaptionEach" Then
               EffectiveModeName = "SeparateBefore"
               Exit Function
            End If
         End If
         EffectiveModeName = _mode
      End Function

      Function PartCount() As Integer
         PartCount = me._parts.Count
      End Function

      Function PartAt(pIndex As Integer) As String
         PartAt = me._parts.Strings(pIndex)
      End Function

      Function Render(pMessage As WaMessage) As String
         Dim _lines As New StringList()
         Dim i As Integer
         For i = 0 To me.PartCount() - 1
            Dim _part As String = me.PartAt(i)
            If _part = "Blank" Then
               _lines.Add("")
            ElseIf _part = "Subject" Then
               me.AddPartLine(_lines, pMessage.Subject)
            ElseIf _part = "Content" Then
               me.AddPartLine(_lines, pMessage.Content)
            ElseIf _part = "Signature" Then
               me.AddPartLine(_lines, pMessage.Signature)
            End If
         Next
         Render = _lines.Text.Trim()
         _lines.Free()
      End Function

      Private Sub AddPartLine(pLines As StringList, pValue As String)
         If me.IncludeEmptyParts Or pValue.Trim() <> "" Then
            pLines.Add(pValue)
         End If
      End Sub

      Overrides Function ToString() As String
         With me.BuildLogger("WaMessageLayout")
            .Prop("Mode", me.ModeName())
            .Prop("SendCaption", me.SendCaption)
            .Prop("AttachmentsReversed", me.AttachmentsReversed)
            .Prop("IncludeEmptyParts", me.IncludeEmptyParts)
            .Prop("Parts", me._parts.Text)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If Assigned(me._parts) Then
            me._parts.Free()
            me._parts = NULL
         End If
         me.AttachmentTextMode = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendStep
      Inherits TTObject

      IsMedia As Boolean
      Text As String
      Attachment As WaAttachment

      Sub New()
         MyBase.New()
      End Sub

      Shared Function TextStep(pText As String) As WaSendStep
         Dim _step As New WaSendStep()
         _step.IsMedia = False
         _step.Text = pText
         TextStep = _step
      End Function

      Shared Function MediaStep(pAttachment As WaAttachment, pCaption As String) As WaSendStep
         Dim _step As New WaSendStep()
         _step.IsMedia = True
         _step.Attachment = pAttachment
         _step.Text = pCaption
         MediaStep = _step
      End Function

      Overrides Sub Dispose()
         me.Attachment = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaSendPlan
      Inherits TTObject

      Private _list As TTObjectList

      Sub New()
         MyBase.New()
         me._list = New TTObjectList("WaSendPlan", True)
      End Sub

      Sub AddText(pText As String)
         If pText.Trim() = "" Then
            Exit Sub
         End If
         me._list.Push(WaSendStep.TextStep(pText))
      End Sub

      Sub AddMedia(pAttachment As WaAttachment, pCaption As String)
         me._list.Push(WaSendStep.MediaStep(pAttachment, pCaption))
      End Sub

      Function Take(pIndex As Integer) As WaSendStep
         Take = WaSendStep(me._list.Take(pIndex))
      End Function

      Function Count() As Integer
         Count = me._list.Length()
      End Function

      Overrides Sub Dispose()
         If Assigned(me._list) Then
            me._list.Free()
            me._list = NULL
         End If
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

   Class WaMessageFormatter
      Inherits TTObject

      Private _layout As WaMessageLayout
      Private _ownsLayout As Boolean

      OnFormatText As WaFormatTextDelegate
      OnBuildPlan As WaBuildPlanDelegate

      Sub New()
         MyBase.New()
         me._layout = New WaMessageLayout()
         me._ownsLayout = True
      End Sub

      Sub New(pLayout As WaMessageLayout, pOwnsLayout As Boolean = False)
         MyBase.New()
         me._layout = pLayout
         me._ownsLayout = pOwnsLayout
         If me._layout = NULL Then
            me._layout = New WaMessageLayout()
            me._ownsLayout = True
         End If
      End Sub

      Shared Function CreateDefault() As WaMessageFormatter
         CreateDefault = New WaMessageFormatter()
      End Function

      Property Layout As WaMessageLayout
         Get
            Layout = me._layout
         End Get
         Set(pValue As WaMessageLayout)
            If me._ownsLayout And Assigned(me._layout) And me._layout <> pValue Then
               me._layout.Free()
            End If
            me._layout = pValue
            me._ownsLayout = False
            If me._layout = NULL Then
               me._layout = New WaMessageLayout()
               me._ownsLayout = True
            End If
         End Set
      End Property

      Function InterceptText(pHandler As WaFormatTextDelegate) As WaMessageFormatter
         me.OnFormatText = pHandler
         InterceptText = me
      End Function

      Function InterceptPlan(pHandler As WaBuildPlanDelegate) As WaMessageFormatter
         me.OnBuildPlan = pHandler
         InterceptPlan = me
      End Function

      Function FormatText(pMessage As WaMessage) As String
         Dim _text As String
         If me.OnFormatText <> NULL Then
            _text = me.OnFormatText(pMessage)
         Else
            _text = me.BuildText(pMessage)
         End If
         FormatText = _text.Trim()
      End Function

      Function BuildText(pMessage As WaMessage) As String
         BuildText = me._layout.Render(pMessage)
      End Function

      Function BuildPlan(pMessage As WaMessage) As WaSendPlan
         If me.OnBuildPlan <> NULL Then
            Dim _custom As WaSendPlan = me.OnBuildPlan(pMessage)
            If Assigned(_custom) Then
               BuildPlan = _custom
               Exit Function
            End If
         End If
         BuildPlan = me.BuildDefaultPlan(pMessage)
      End Function

      Private Function BuildDefaultPlan(pMessage As WaMessage) As WaSendPlan
         Dim _plan As New WaSendPlan()
         Dim _text As String = me.FormatText(pMessage)
         Dim _count As Integer = 0
         If Assigned(pMessage.Attachments) Then
            _count = pMessage.Attachments.Count()
         End If

         If _count = 0 Then
            _plan.AddText(_text)
            BuildDefaultPlan = _plan
            Exit Function
         End If

         Dim _mode As String = me._layout.EffectiveModeName()
         If _mode = "SeparateBefore" Then
            _plan.AddText(_text)
         End If

         Dim i As Integer
         For i = 0 To _count - 1
            Dim _idx As Integer = i
            If me._layout.AttachmentsReversed Then
               _idx = _count - 1 - i
            End If
            Dim _att As WaAttachment = pMessage.Attachments.Take(_idx)
            Dim _caption As String = ""
            If me._layout.SendCaption Then
               _caption = _att.Caption
            End If
            Dim _useFormatted As Boolean = False
            If _mode = "CaptionEach" Then
               _useFormatted = True
            ElseIf _mode = "CaptionFirst" And i = 0 Then
               _useFormatted = True
            ElseIf _mode = "CaptionLast" And i = _count - 1 Then
               _useFormatted = True
            End If
            If _useFormatted And _text <> "" Then
               _caption = _text
            End If
            _plan.AddMedia(_att, _caption)
         Next

         If _mode = "SeparateAfter" Then
            _plan.AddText(_text)
         End If
         BuildDefaultPlan = _plan
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("WaMessageFormatter")
            If Assigned(me._layout) Then
               .Prop("Layout", me._layout.ToString())
            End If
            .Prop("HasTextIntercept", me.OnFormatText <> NULL)
            .Prop("HasPlanIntercept", me.OnBuildPlan <> NULL)
            ToString = .Text()
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         If me._ownsLayout And Assigned(me._layout) Then
            me._layout.Free()
         End If
         me._layout = NULL
         me.OnFormatText = NULL
         me.OnBuildPlan = NULL
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
