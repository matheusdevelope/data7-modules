# mod_cache

In-session object cache: a global list of named pools, each a `key → TObject` map. The cache owns every stored object (`Remove`, `ClearPool`, and `Clear` call `Free`). It does not persist to disk, expire entries, isolate threads, or decide pool names, keys, or object lifetime policy — that stays in the consumer.

Version: `1.0.0.0`. Dependencies (`data7.json`): none.

This file is the contract for agents. Do not open the `.bas` files to use the module; open implementation only to fix an internal bug.

---

## Quick Start (Minimal)

```bas
Imports mod_cache

Dim _key As String = "main-1"                                         ' item key inside the pool
Dim _form As Forms.Form = Cache.Find<Forms.Form>("Form", _key)         ' pool "Form"; miss → Null
If Not Assigned(_form) Then
   _form = New Forms.Form()
   Cache.Put("Form", _key, _form)                                     ' cache takes ownership of _form
End If
_form.Show()                                                          ' reuse the same instance on later calls
```

Pool names and keys are free strings. Stored form: `UCase(Trim(...))`. `"Form"` / `"form"` / `" FORM "` are the same pool; `"main-1"` / `"MAIN-1"` are the same key.

---

## Namespace Map

| File | Namespace | Types |
|---|---|---|
| `src/lib/mod_cache.bas` | `mod_cache` | `Cache` |
| `src/test/test_cache.bas` | `test_cache` | `TCacheTest` (`Run`, `Execute`) |

`src/Principal.bas` declares no namespace.

---

## Cache

Session-scoped store. `Cache` is a Shared-only facade: call `Cache.Put` / `Cache.Find`; do not instantiate.

### Lookup and ownership

```text
1. Normalize pool name and key: UCase(Trim(name))
2. Locate the pool in the global list; missing / blank name → miss
3. Locate the key in that pool; missing / blank key → miss
4. Hit returns the same TObject instance that was Put
```

`Put` of a new pool name creates the pool. `Remove` of the last item in a pool drops that pool. `Clear` Frees every object and every pool, then empties the global list (the list itself stays for the session).

### Sentinels

| Situation | Value |
|---|---|
| `Find` miss (unknown pool/key, blank name/key, never initialized) | `Null` |
| `Contains` / `ContainsObject` miss | `False` |
| `Count` on a missing or dropped pool | `0` |
| `PoolCount` before any `Put`, or after `Clear` | `0` |
| `NameAt` out of range, negative, or before init | `""` |
| `Put` of `Null`, blank key, or blank pool name | no-op (no pool created for `Null`) |
| `Remove` / `ClearPool` on a missing pool or key | no-op |
| `Clear` before any `Put` | no-op |

Nothing in this module throws on a miss. `Find<T>` on a hit of the wrong runtime type is a cast of the stored `TObject` to `T`.

Pool / key literals used by this project:

```text
"Form" / "SAMPLE" / "OTHER"     ' pool names (stored uppercase)
"main-1"                        ' item key (Execute: "main-" & CodTabela)
"A" / "B"                       ' item keys in TCacheTest.Run
```

### `Cache`

```bas
Shared Sub Put(pObjectName As String, pKey As String, pObject As TObject)
   ' in: pool name, item key, instance to store
   ' no-op if pObject is Null, or Trim(pKey)/Trim(pObjectName) is ""
   ' 1. ensure pool (create on first use)
   ' 2. if the key already exists: Free the previous object unless it is this same instance
   ' 3. store pObject under the normalized key — cache owns it from here
End Sub

Shared Function Find<T As TObject>(pObjectName As String, pKey As String) As T
   ' out: the instance from Put, or Null
   ' does not take ownership away from the cache
End Function

Shared Function Contains(pObjectName As String, pKey As String) As Boolean
   ' out: True iff Find would return an assigned object
End Function

Shared Function ContainsObject(pObjectName As String, pObject As TObject) As Boolean
   ' in: pool name + instance identity (not a key)
   ' out: True iff that instance is stored in the named pool
End Function

Shared Function PoolCount() As Integer
   ' out: number of pools in the global list
End Function

Shared Function Count(pObjectName As String) As Integer
   ' out: items in that pool, or 0 if the pool does not exist
End Function

Shared Function NameAt(pIndex As Integer) As String
   ' in: 0-based index in insertion order of pools
   ' out: stored pool name (already uppercase), or ""
End Function

Shared Sub Remove(pObjectName As String, pKey As String)
   ' delete the key, then Free the object
   ' if the pool is empty afterwards, drop the pool (PoolCount decreases)
End Sub

Shared Sub ClearPool(pObjectName As String)
   ' Free every object in the pool, Free the pool, remove it from the global list
End Sub

Shared Sub Clear()
   ' Free every object and every pool; global list Count becomes 0
End Sub
```

There are no instance members, no properties, no overridable hooks, and no `Add` / `Make` / `MakeByName` catalog.

---

## Extending (Consumer Project)

There is no type to inherit and no registration API. Import `mod_cache` and `Put` your own `TObject` instances under pool names you choose:

```bas
Imports mod_cache

Cache.Put("Pedido", CStr(pCod), pPedido)                 ' consumer type, consumer key
Dim found As TPedido = Cache.Find<TPedido>("Pedido", CStr(pCod))
```

No UI in this module. Eviction policy, per-user vs global keys, and whether a `Forms.Form` is shown after `Find` stay in the consuming project.

---

## Module Notes

- The cache owns stored objects. Do not `Free` an instance that is still in a pool; after `Remove` / `ClearPool` / `Clear` it is already `Free`d. `Find` returns a live reference still owned by the cache.
- `Put` of the same instance on the same key does not `Free` it (delete + re-add). `Put` of a different instance on the same key `Free`s the previous one.
- Do not store the same instance under two keys in one pool: `Remove` of one key `Free`s the object while the other key still holds it.
- Pool names and keys are `UCase(Trim(...))`. `NameAt` returns that stored form (`"SAMPLE"`, not `"Sample"`). Pools keep first-`Put` insertion order.
- Removing the last item drops the pool. `Clear` empties the global list but keeps it for the session; there is no disk file.
- `Put` of `Null` or a blank name/key is a silent no-op and does not create a pool. Misses return `Null` / `False` / `0` / `""`, never an exception from this module.
- Canonical tests: `TCacheTest.Run` (case-insensitive find, `Contains` / `ContainsObject`, `PoolCount` / `Count` / `NameAt`, replace, `Remove`, `ClearPool`, `Clear`, `Put` after `Clear`). `TCacheTest.Execute(pCodTabela)` is the form-reuse demo (`Find`/`Put` pool `"Form"`, key `"main-" & pCodTabela`).
