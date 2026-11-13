Imports mod_tobject

Namespace mod_wa_devstudio_options

   ' Options mínimas — DevStudio não usa HTTP/auth.
   Class WaDevStudioOptions
      Inherits TTObject

      Sub New()
         MyBase.New()
      End Sub

      Sub Validate()
      End Sub

      Overrides Sub Dispose()
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub

   End Class

End Namespace
