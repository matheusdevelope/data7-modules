Imports mod_tenum

Namespace mod_data7_utils_stream_enums

   ' Enun AsInteger is the cache ordinal (0, 1, 2, ...). Leading Unspecified = "0"
   ' keeps that ordinal equal to the COM integer. Create/Open are reserved names.

   Enun TUtilsStreamKind
      Unspecified = "0"
      Binary = "1"
      Text = "2"
   End Enun

   Enun TUtilsCharset
      Unspecified = "0"
      UTF8 = "1"
      ASCII = "2"
      Utf16 = "3"
      Latin1 = "4"
      Base64 = "5"
   End Enun

   Enun TUtilsFileMode
      Unspecified = "0"
      CreateNew = "1"
      CreateFile = "2"
      OpenFile = "3"
      OpenOrCreate = "4"
      Truncate = "5"
      Append = "6"
   End Enun

   Enun TUtilsFileAccess
      Unspecified = "0"
      Read = "1"
      Write = "2"
      ReadWrite = "3"
   End Enun

   Enun TUtilsSeekOrigin
      Begin = "0"
      Current = "1"
      Endd = "2"
   End Enun

End Namespace
