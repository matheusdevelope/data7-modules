Imports mod_tobject

Namespace ambient_campo

   Class TCampoValue
      Inherits TTObject

      CodTabela As Integer
      CodCampo As Integer
      Nome As String
      Titulo As String
      Tipo As String
      TipoDB As String
      Contexto As String
      FormulaCalculoValor As String
      OrdemGrade As Integer
      CondicaoVisivelGrade As String
      IsPhysical As Boolean
      IsPrimaryKey As Boolean
      Value As Variant

      Sub New()
         MyBase.New()
         me.IsPhysical = False
         me.IsPrimaryKey = False
         me.TipoDB = ""
         me.Contexto = ""
         me.FormulaCalculoValor = ""
         me.CondicaoVisivelGrade = "O"
         me.Value = Unassigned
      End Sub

      Overrides Function GetID() As String
         GetID = me.Nome
      End Function

      Function IsVisible() As Boolean
         IsVisible = UCase(Trim(me.CondicaoVisivelGrade)) <> "N"
      End Function

      Function IsCalculated() As Boolean
         IsCalculated = (UCase(Trim(me.Contexto)) <> "R") And (Trim(me.FormulaCalculoValor) <> "")
      End Function

      Overrides Function ToString() As String
         With me.BuildLogger("Campo")
            .Prop("CodCampo", me.CodCampo)
            .Prop("Nome", me.Nome)
            .Prop("Titulo", me.Titulo)
            .Prop("Tipo", me.Tipo)
            .Prop("TipoDB", me.TipoDB)
            .Prop("Contexto", me.Contexto)
            .Prop("Formula", me.FormulaCalculoValor)
            .Prop("OrdemGrade", me.OrdemGrade)
            .Prop("Visible", me.IsVisible())
            .Prop("Physical", me.IsPhysical)
            .Prop("PrimaryKey", me.IsPrimaryKey)
            .Prop("Value", CStr(me.Value))
            ToString = .Text
            .Free()
         End With
      End Function

      Overrides Sub Dispose()
         me.Value = Unassigned
      End Sub

      Sub Free()
         MyBase.Free()
      End Sub
   End Class

End Namespace
