# mod_table_filter_builder

Constrói um filtro SQL interativo: o consumidor entrega o catálogo de campos (`TFilterTable`), o builder hospeda a UI num controle pai e devolve o predicado (`ToSql` / `ToWhere`) e a definição persistível (`ToJson` / `FromJson`).

Não consulta Ambient, configurador nem o banco. Montar `TFilterTable` a partir da tabela real, aplicar o SQL gerado e guardar o `.7json` (além da UI de diálogo) são responsabilidade do consumidor.

Versão `1.0.0.0`. Dependências em `data7.json`: `mod_table` `1.0.0.6`, `mod_io` `1.0.0.0`.

Este arquivo é o contrato do módulo. Quem consome não precisa abrir os `.bas` para usar a API.

## Como usar (mínimo)

```basic
Imports table_filter_builder
Imports table_filter_table

' Catálogo: schema/tabela + campos (tipo, pesquisa, combo, fórmula opcional).
Dim filterTable As New TFilterTable()
filterTable.Schema = "dbo"
filterTable.Nome = "CLIENTES"
filterTable.AddField("NOME", "Nome", "C")
filterTable.AddField("VALOR", "Valor", "N", 0, "", 2)
filterTable.AddField("CODCLIENTE", "Cliente", "I", 1)
filterTable.AddField("STATUS", "Status", "C", 0, "Ativo=A".Quoted() & ";" & "Inativo=I".Quoted())
filterTable.AddField("ANO", "Ano", "I", 0, "", 0, "YEAR(DATA)")

' UI no parent; False = ações horizontais e valores de intervalo lado a lado.
' 5º parâmetro (default True) liga Importar/Exportar .7json.
Dim builder As New TTableFilterBuilder(parent, filterTable, False, False)
filterTable.Free() ' o builder já clonou o catálogo

' Predicado sem a palavra WHERE, ou com WHERE se houver itens.
Dim sqlText As String = builder.ToSql()
Dim whereText As String = builder.ToWhere()

' Persistência programática (os botões da UI usam a mesma API + diálogo de arquivo).
Dim jsonText As String = builder.ToJson()
Dim ok As Boolean = builder.FromJson(jsonText)

builder.Free()
```

## Mapa de namespaces

| Arquivo | Namespace | Tipos |
|---|---|---|
| `src/lib/table_filter_builder.bas` | `table_filter_builder` | `TTableFilterBuilder` |
| `src/lib/table_filter_table.bas` | `table_filter_table` | `TFilterTable` |
| `src/lib/table_filter_field.bas` | `table_filter_field` | `TFilterField` |
| `src/lib/table_filter_item.bas` | `table_filter_item` | `TFilterItem` |
| `src/lib/table_filter_ops.bas` | `table_filter_ops` | `TFilterOps` |
| `src/lib/table_filter_sql.bas` | `table_filter_sql` | `TFilterSql` |
| `src/lib/table_filter_json.bas` | `table_filter_json` | `TFilterJson` |
| `src/lib/table_filter_value.bas` | `table_filter_value` | `TFilterValueHost` |

`src/Principal.bas` é o demo do módulo (form + `MockFilterTable`). Não há suíte de testes.

## Catálogo

O builder não descobre campos sozinho. O consumidor preenche `TFilterTable` e passa no construtor.

### `TFilterTable`

Papel: schema, nome físico da tabela e lista de `TFilterField`.

| Membro | Tipo | Default | Notas |
|---|---|---|---|
| `Schema` | `String` | `""` | Usado em `QuoteTable` quando `QualifyWithTable` é True. |
| `Nome` | `String` | `""` | Nome da tabela; vira prefixo das colunas e o nome default do `.7json`. |
| `Campos` | lista de `TFilterField` | `[]` | Posse do objeto. |

```basic
Function AddField(pNome As String, pTitulo As String, pTipo As String, pCodPesquisa As Integer = 0, pListaOpcoes As String = "", pDecimalPlaces As Integer = 0, pFormula As String = "") As TFilterField
   ' in: Nome físico, título (se vazio, usa pNome), tipo, pesquisa, combo, casas, expressão SQL.
   ' out: o campo já empilhado em Campos.

Function FindByName(pNome As String) As TFilterField
   ' in: nome físico, comparação sem acento de caixa.
   ' out: campo ou Null (nome vazio ou inexistente).

Function FieldListaOpcoes() As String
   ' out: ListaOpcoes do combo de campos, títulos em ordem alfabética.
   ' formato: "Título=NOME".Quoted() separados por ";".
```

`Clone` copia schema, nome e cada campo. O construtor de `TTableFilterBuilder` clona o catálogo recebido; o original pode ser liberado em seguida.

### `TFilterField`

Papel: um campo filtrável e o editor que ele pede.

| Membro | Tipo | Default | Notas |
|---|---|---|---|
| `Nome` | `String` | `""` | Identificador físico / `GetID`. |
| `Titulo` | `String` | `""` | Rótulo na UI. |
| `Tipo` | `String` | `""` | Código de tipo (ver `Kind`). |
| `CodPesquisa` | `Integer` | `0` | `> 0` força editor de pesquisa. |
| `ListaOpcoes` | `String` | `""` | Não vazio força combo. Formato Data7: `"Ativo=A".Quoted() & ";" & "Inativo=I".Quoted()`. |
| `DecimalPlaces` | `Integer` | `0` | Casas do editor numérico. |
| `Formula` | `String` | `""` | Se preenchida, o SQL usa `(formula)` no lugar do identificador. |

```basic
Function Kind() As String
   ' out: search | combo | date | datetime | time | check | integer | number | memo | text
   ' 1) CodPesquisa > 0 → search
   ' 2) ListaOpcoes não vazia → combo
   ' 3) senão mapeia Tipo (caixa alta):

Function IsNumericKind() As Boolean
   ' out: True se Kind é integer, number ou search.

Function IsDateKind() As Boolean
   ' out: True se Kind é date, datetime ou time.
```

Mapa de `Tipo` → `Kind` (após `search`/`combo`):

| `Tipo` (UCase) | `Kind` |
|---|---|
| `D`, `DATE`, `DATA` | `date` |
| `DT`, `DATETIME`, `TIMESTAMP` | `datetime` |
| `T`, `H`, `TIME`, `HORA` | `time` |
| `L`, `BOOL`, `BOOLEAN`, `LOGICO` | `check` |
| `I`, `INT`, `INTEGER`, `INTEIRO` | `integer` |
| `N`, `F`, `FLOAT`, `NUMERIC`, `NUMERICO`, `VALOR`, `MOEDA`, `DECIMAL` | `number` |
| `M`, `MEMO` | `memo` |
| qualquer outro | `text` |

## Condições

### `TFilterOps`

Papel: códigos de condição, rótulos do combo e predicados de UI/SQL. Só métodos `Shared`.

```basic
Function Equal() As String              ' "EQ"
Function NotEqual() As String           ' "NE"
Function Empty() As String              ' "NL"  → IS NULL
Function NotEmpty() As String           ' "NN"  → IS NOT NULL
Function InList() As String             ' "IN"
Function NotInList() As String          ' "NIN"
Function Less() As String               ' "LT"
Function LessEqual() As String          ' "LE"
Function Greater() As String            ' "GT"
Function GreaterEqual() As String       ' "GE"
Function Between() As String            ' "BW"
Function NotBetween() As String         ' "NBW"
Function StartsWith() As String         ' "SW"
Function NotStartsWith() As String      ' "NSW"
Function Contains() As String           ' "CT"
Function NotContains() As String        ' "NCT"
Function SqlQuery() As String           ' "SQL"

Function AllowsSqlQuery() As Boolean
   ' out: True somente se Data7.NomeUsuario().ToUpper() = "ADMINISTRADOR".

Function ListaOpcoes() As String
   ' out: combo da condição. Inclui "SQL Query=SQL" só se AllowsSqlQuery.

Function TitleOf(pOp As String) As String
   ' in: código; out: rótulo PT. Código desconhecido devolve pOp.

Function IsList(pOp As String) As Boolean     ' IN, NIN
Function IsRange(pOp As String) As Boolean    ' BW, NBW
Function IsLike(pOp As String) As Boolean     ' SW, NSW, CT, NCT
Function IsEmpty(pOp As String) As Boolean    ' NL, NN
Function IsSql(pOp As String) As Boolean      ' "SQL" e AllowsSqlQuery
Function AllowsBlankValue(pOp As String) As Boolean
   ' out: True se não é NL/NN e não é SQL (admin).
Function Arity(pOp As String) As Integer
   ' out: -1 lista, 2 intervalo, 0 vazio/NULL, 1 demais.
```

`ListaOpcoes` literal (sem SQL Query):

```
"Igual a=EQ";"não igual a=NE";"seja vazio=NL";"não seja vazio=NN";"seja um entre=IN";"não seja um entre=NIN";"seja menor que=LT";"seja menor que ou igual a=LE";"seja maior que=GT";"seja maior que ou igual a=GE";"esteja entre=BW";"não esteja entre=NBW";"inicie com=SW";"não inicie com=NSW";"contenha=CT";"não Contenha=NCT"
```

NL/NN não pedem valor e geram só `IS NULL` / `IS NOT NULL` (não misturam com `''`).

## Item de filtro

### `TFilterItem`

Papel: uma cláusula montada (operador lógico + campo + condição + valores).

| Membro | Tipo | Default | Notas |
|---|---|---|---|
| `LogicalOp` | `String` | `"AND"` | `AND` ou `OR`. Import JSON: outro valor vira `AND`. |
| `FieldName` | `String` | `""` | Nome físico. |
| `FieldTitle` | `String` | `""` | Rótulo. |
| `FieldTipo` | `String` | `""` | Eco do catálogo. |
| `FieldKind` | `String` | `""` | Eco de `Kind()`. |
| `Condition` | `String` | `"EQ"` | Código `TFilterOps`. |
| `ConditionTitle` | `String` | `""` | Rótulo da condição. |
| `Values` | lista de `String` | `[]` | Operandos. NL/NN ficam vazios. |
| `DisplayValue` | `String` | `""` | Texto da coluna Valor. Vazio de igualdade vira `''`. |

```basic
Sub SetID(pID As String)
   ' in: id persistido. GetID usa _id se não vazio; senão FieldName & ":" & Condition.
```

O primeiro item entra no SQL sem prefixo lógico; a partir do segundo, o `LogicalOp` do **item atual** é intercalado (` AND ` / ` OR `).

## Builder (UI)

### `TTableFilterBuilder`

Papel: monta a UI no parent, guarda os itens e expõe SQL/JSON.

```basic
Sub New(pParent As TWinControl, pTabela As TFilterTable, pActionsVertical As Boolean = True, pRangeValuesVertical As Boolean = True, pJsonActionsEnabled As Boolean = True)
   ' in: parent visual; catálogo (clonado).
   ' lança Exception se pTabela não Assigned: "TTableFilterBuilder requer um objeto TFilterTable."
```

| Membro | Tipo | Default | Notas |
|---|---|---|---|
| `QualifyWithTable` | `Boolean` | `True` | Coluna como `schema.tabela.campo`. `FromJson` pode sobrescrever. |
| `ActionsVertical` | `Boolean` | parâmetro (`True`) | True: Adicionar/Excluir/Limpar empilhados à direita do header. False: na horizontal. |
| `RangeValuesVertical` | `Boolean` | parâmetro (`True`) | True: dois valores de intervalo um abaixo do outro (rótulo `e`). |
| `JsonActionsEnabled` | `Boolean` | parâmetro (`True`) | Mostra/esconde a coluna Importar/Exportar à direita da grade. |
| `Host` | `PageControl` (só Get) | — | Raiz visual. |
| `Tabela` | `TFilterTable` (só Get) | clone | Catálogo interno. |

```basic
Function Count() As Integer
   ' out: quantidade de TFilterItem.

Function ItemAt(pIndex As Integer) As TFilterItem
   ' out: item ou Null se índice fora de 0..Count-1.

Function ToSql() As String
   ' out: predicado concatenado, sem WHERE. "" se não há cláusulas válidas.

Function ToWhere() As String
   ' out: "WHERE " & ToSql(), ou "" se ToSql vazio.

Function ToJson() As String
   ' out: documento JSON (versão 1).

Function FromJson(pJson As String) As Boolean
   ' in: texto JSON. Substitui os itens e redesenha a grade.
   ' out: True se parseou; False se texto vazio.
   ' lança Exception com a mensagem original se o JSON for inválido.
```

Botões da UI (não são API): Adicionar, Excluir, Limpar; Inserir/Remover (só condição lista); Importar/Exportar (`.7json`).

Adicionar:

1. Condição não-SQL exige campo selecionado.
2. NL/NN não exigem valor.
3. Intervalo exige 2 valores.
4. Demais: se o valor está vazio ou é zero numérico, pede confirmação (`Forms.MessageBox.Confirmation`). Cancelar não inclui o item.

Importar/Exportar: `TDialogs.OpenFile` / `SaveFile` com filtro `Filtros Data7 (*.7json)|*.7json`, extensão `7json`, nome default `NomeDaTabela.7json` (ou `filtro.7json`). Erro de I/O ou parse mostra a exceção.

IDs internos na inclusão/importação: `f1`, `f2`, … (`_seq`).

## SQL

### `TFilterSql`

Papel: traduz itens em SQL. Usável sem UI.

```basic
Shared Function Build(pTabela As TFilterTable, pItems[] As TFilterItem, pQualify As Boolean = True) As String
   ' out: predicado. "" se tabela ou lista não Assigned, ou nenhum predicado válido.

Shared Function BuildWhere(pTabela As TFilterTable, pItems[] As TFilterItem, pQualify As Boolean = True) As String
   ' out: "WHERE " + Build, ou "".

Shared Function Predicate(pTabela As TFilterTable, pItem As TFilterItem, pQualify As Boolean) As String
   ' out: uma cláusula entre parênteses, ou "".
```

Coluna:

1. Campo com `Formula` não vazia → `(formula)`.
2. Senão identificador citado; se `pQualify` e `Nome` da tabela preenchido → `QuoteTable(Schema, Nome).QuoteIdent(campo)`.
3. `FieldName` vazio → predicado `""` (no-op).

Operadores gerados:

| Código | SQL |
|---|---|
| `EQ` | `col = lit` |
| `NE` | `col <> lit` |
| `LT` / `LE` / `GT` / `GE` | `<` `<=` `>` `>=` |
| `NL` | `col IS NULL` |
| `NN` | `col IS NOT NULL` |
| `IN` / `NIN` | `IN` / `NOT IN` |
| `BW` / `NBW` | `BETWEEN` / `NOT BETWEEN` |
| `SW` | `LIKE 'v%'` |
| `NSW` | `NOT LIKE 'v%'` |
| `CT` | `LIKE '%v%'` |
| `NCT` | `NOT LIKE '%v%'` |
| `SQL` (só admin) | `(texto cru do valor)` |

Literais: data/hora via `TField` + `TSql`; número cru se parseável; `search` como número; `check` → `'S'` se `S`/`SIM`/`TRUE`/`1`/`Y`, senão `'N'`; demais quoted (`'` duplicado). Sem campo, quoted ou número.

`IsSql` falso (não-admin) faz um item `SQL` cair no ramo de comparação, não no fragmento cru.

## JSON

### `TFilterJson`

Papel: serializar/carregar a lista de itens (não o catálogo).

```basic
Shared Function Build(pTabela As TFilterTable, pItems As TTList<TFilterItem>, pQualify As Boolean) As String
   ' out: JSON. Tabela não Assigned → schema/table vazios. Items não Assigned → array vazio.

Shared Function TryLoad(pJson As String, pTabela As TFilterTable, pItems As TTList<TFilterItem>, ByRef pQualify As Boolean) As Boolean
   ' in/out: pItems é limpo e preenchido; pQualify só muda se o JSON tiver "qualify".
   ' out: False se pItems Null ou texto vazio.
   ' lança Exception (mensagem original) se o parse falhar — pItems fica limpo.
```

Documento (chaves reais):

```json
{
  "version": 1,
  "schema": "dbo",
  "table": "CLIENTES",
  "qualify": true,
  "items": [
    {
      "id": "f1",
      "logicalOp": "AND",
      "fieldName": "NOME",
      "fieldTitle": "Nome",
      "fieldTipo": "C",
      "fieldKind": "text",
      "condition": "EQ",
      "conditionTitle": "Igual a",
      "displayValue": "João",
      "values": [{ "value": "João" }]
    }
  ]
}
```

Carga de cada item:

1. `condition` vazio → `EQ`.
2. `SQL` sem `AllowsSqlQuery` → item ignorado (`Null`).
3. `logicalOp` só `AND`/`OR`; resto → `AND`.
4. Se `pTabela.FindByName` achar o campo, atualiza título, tipo e `Kind`.
5. `fieldTitle` ainda vazio → `fieldName`.

`FromJson` no builder clona os itens carregados, reatribui `f1..n` e aplica `qualify` do JSON.

## Editor de valor

### `TFilterValueHost`

Papel: editor dinâmico usado pelo builder (lista, intervalo, SQL, único, nenhum). O consumidor típico não instancia; a API pública existe.

```basic
Sub New(pParent As TWinControl, pRangeValuesVertical As Boolean = True)

Property Root As PageControl   ' só Get

Sub Rebuild(pField As TFilterField, pCondition As String)
   ' condição vazia → EQ. NL/NN escondem o editor.

Function ReadValues() As TTList<String>
   ' out: lista nova (o chamador libera). NL/NN → vazia.
   ' SQL: texto do memo se não vazio.
   ' lista: itens inseridos, ou o editor corrente se a lista estiver vazia.
   ' intervalo: dois valores. demais: um valor (pode ser "").

Function ReadDisplay() As String
   ' out: texto da grade. Intervalo: "a e b". Vazio de igualdade: "''".

Function InsertCurrent() As Boolean   ' só IN/NIN; senão False
Function RemoveSelected() As Boolean  ' False se não for lista ou linha inválida
Sub ClearInput()

Function IsList() As Boolean
Function IsRange() As Boolean
Function IsSql() As Boolean
```

Editores por `Kind`: pesquisa (`CodPesquisa`), combo (`ListaOpcoes`), data, datetime, hora, check, inteiro (`DecimalPlaces = 0`), número, memo, texto. LIKE e SQL forçam texto.

## Extensão (projeto consumidor)

Não há hooks `Overridable` específicos nem registro de tipos. O ponto de extensão é o catálogo:

1. Instanciar `TFilterTable`, preencher `Schema`/`Nome`, chamar `AddField` para cada coluna filtrável.
2. Mapear o schema da aplicação (Ambient, dicionário, etc.) **fora** deste módulo.
3. Passar a tabela ao `TTableFilterBuilder` num `TWinControl` do form consumidor.
4. Usar `ToSql`/`ToWhere` na query; `ToJson`/`FromJson` se persistir a definição sem os botões da UI (`JsonActionsEnabled = False`).
5. SQL Query só aparece e só importa se o usuário Data7 for `ADMINISTRADOR`.

`TFilterSql.Build` / `Predicate` permitem gerar SQL a partir de `TFilterItem` montados à mão, sem a UI.

## Notas do módulo

- O construtor **clona** `TFilterTable`; o clone (e os `TFilterItem`) são posse do builder.
- `Campos` e `Values` são listas possuídas; não reutilizar o mesmo `TFilterField` em duas listas.
- `QualifyWithTable` nasce `True` mesmo que o consumidor não passe o flag.
- Combo de campos ordena por **título** (caixa alta); a ordem de `Campos` não muda.
- NL/NN = somente NULL SQL; `''` e `0` entram pelas outras condições, com confirmação na UI.
- Arquivo persistido: extensão `.7json`, filtro de diálogo `Filtros Data7 (*.7json)|*.7json`.
- `Principal.bas` demonstra o happy path com `MockFilterTable`; não há `RunAll` de testes.
