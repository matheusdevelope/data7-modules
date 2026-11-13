Imports Collections

Namespace http_callback

   Class HttpCallback

      Private _timer As Forms.Timer
      Private _proc As Variant
      Private _active As Boolean
      Private _output As String
      Private _port As Integer

      OnFinish As TNotifyEvent

      Property Active As Boolean
         Get
            Active = me._active
         End Get
      End Property

      Property Output As String
         Get
            Output = me._output
         End Get
      End Property

      Property OutputAsJson As TJSONObject
         Get
            OutputAsJson = New TJSONObject(me._output)
         End Get
      End Property

      Sub New()
         MyBase.New()
      End Sub

      Private Function _buildScript(pPort As Integer) As String
         With New StringList()
            .Add("Add-Type -AssemblyName System.Web")
            .Add("Add-Type -AssemblyName System.Web.Extensions")
            .Add("$l=[System.Net.HttpListener]::new()")
            .Add("$l.Prefixes.Add('http://localhost:" & CStr(pPort) & "/')")
            .Add("$l.Start()")
            .Add("$x=$l.GetContext()")
            .Add("$r=$x.Request;$s=$x.Response")
            .Add("$reader = New-Object IO.StreamReader($r.InputStream)")
            .Add("$body = $reader.ReadToEnd()")
            .Add("$headers = @{}; foreach($h in $r.Headers.AllKeys){ $headers[$h] = $r.Headers[$h] }")
            .Add("$q=[System.Web.HttpUtility]::ParseQueryString($r.Url.Query)")
            .Add("$qs=@{}; foreach($k in $q.Keys){ $qs[$k] = $q[$k] }")
            .Add("$data = @{ method = $r.HttpMethod; url = $r.Url.AbsoluteUri; path = $r.Url.AbsolutePath; query = $qs; headers = $headers; body = $body }")
            .Add("$json = (New-Object Web.Script.Serialization.JavaScriptSerializer).Serialize($data)")
            .Add("$resp = '<html><head><title>Processo Concluído</title><style> body { font-family: Arial; text-align: center; padding: 40px; background: #f5f5f5; color: #333; display:flex; align-items:center; justify-content:center; height:100vh} .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 2px 6px rgba(0,0,0,.1); display: inline-block; } h1 { color: #0078D7; } p { font-size: 14px; color: #666; }</style></head><body><div class=''card''> <h1>Processo concluído com sucesso!</h1><p>Você já pode fechar esta janela.</p></div></body></html>'")
            .Add("$b=[System.Text.Encoding]::UTF8.GetBytes($resp)")
            .Add("$s.ContentType='text/html; charset=utf-8'")
            .Add("$s.ContentEncoding=[System.Text.Encoding]::UTF8")
            .Add("$s.ContentLength64=$b.Length")
            .Add("$s.OutputStream.Write($b,0,$b.Length)")
            .Add("$s.OutputStream.Close()")
            .Add("$l.Stop()")
            .Add("Write-Output $json")
            _buildScript = .Text.Replace(.LineBreak, ";")
            .Free()
         End With
      End Function

      Sub Start(pPort As Integer, pAsync As Boolean)
         If Not pAsync Then
            Dim ps As String = me._buildScript(pPort)
            Dim cmd As String = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command """ & ps & """"
            Dim sh As Variant = CreateObject("WScript.Shell")
            me._proc = sh.Exec(cmd)
            me._active = True
            Do While me._proc.Status = 0
               Forms.ProcessMessages()
               Sleep(10)
            Loop
            me._output = me._proc.StdOut.ReadAll
            me._active = False
            If me.OnFinish <> NULL Then
               me.OnFinish(me)
            End If
            me.Stopp()
         Else
            me._port = pPort
            me._timer = New Forms.Timer(NULL)
            me._timer.Interval = 50
            me._timer.OnTimer = me._dispatchStart
            me._timer.Enabled = True
         End If
      End Sub

      Private Sub _dispatchStart(pSender As TObject)
         me._timer.Enabled = False
         me._timer.Free()
         me.Start(me._port, False)
      End Sub

      Sub Stopp()
         If me._active Then
            me._proc.Terminate()
         End If
      End Sub

      Shared Function Listen(pPort As Integer, pAsync As Boolean) As HttpCallback
         Listen = HttpCallback.Listen(pPort, pAsync, NULL)
      End Function

      Shared Function Listen(pPort As Integer, pAsync As Boolean, pOnFinish As TNotifyEvent) As HttpCallback
         Dim server As New HttpCallback()
         server.OnFinish = pOnFinish
         server.Start(pPort, pAsync)
         Listen = server
      End Function

      Sub Free()
         me.Stopp()
         MyBase.Free()
      End Sub

   End Class

End Namespace
