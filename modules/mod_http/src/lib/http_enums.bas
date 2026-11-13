Imports mod_tenum

Namespace http_enums

   Enun HttpMethod
      Gett = "GET"
      Post = "POST"
      Put = "PUT"
      Patch = "PATCH"
      Delete = "DELETE"
      Head = "HEAD"
      Options = "OPTIONS"
   End Enun

   Enun HttpClientKind
      WinHttp = "WINHTTP"
      Curl = "CURL"
      DevStudio = "DevStudio"
      Mock = "MOCK"
   End Enun

End Namespace
