# mod_google_drive_store_sql

SQL `GoogleTokenStore` for Google Drive / Google Auth on the client ERP database. It maps rows in `Customizado.ConfiguracaoGoogleDrive` to OAuth credentials and tokens, migrates the table with `mod_table`, and rebuilds `GoogleAuthConfig` so later sessions do not need `google-oauth.json`.

Version **1.0.0.1**. Dependencies (`data7.json`): `mod_google_drive` `1.0.0.0`, `mod_google_auth` `1.0.0.2`, `mod_table` `1.0.0.8`.

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Open a `.bas` file only to confirm a detail that is not stated here. Never edit files under `data7_modules/`.

`client_id` and `client_secret` are **required on every refresh**, not only on the first consent. This store persists both (secret encrypted) together with the refresh token.

Each Google account is a row. `Load` / `Save` / `Clear` honor `pKey` (`ClientId|AccountId`, email, or numeric PK). `Open(..., pInsertNew=True)` and `Add()` insert a new row without replacing tokens of an existing connection. `Titulo` is a display name; `Email` / `Nome` identify the connected Google account.

## Quick Start (Minimal)

```basic
Imports google_auth
Imports google_auth_config
Imports google_drive
Imports google_drive_sql_stores
Imports configuracao_google_drive

GoogleDriveSqlStores.Migrate()

Dim rows[] As TConfiguracaoGoogleDrive = GoogleDriveSqlStores.ListConnections()
' Combo: rows[i].AccountCaption() & "=" & rows[i].AccountKey()  ' AccountKey = CodConfiguracaoGoogleDrive
rows.Free()

' Existing account (silent when that row has tokens).
Dim auth As GoogleAuthService = GoogleDriveSqlStores.ConnectKey(row.CodConfiguracaoGoogleDrive)
Dim driveService As GoogleDriveService = GoogleDriveService.Load(auth)

' New account: inserts a row, then OAuth. Does not clear other rows.
Dim authNew As GoogleAuthService = GoogleDriveSqlStores.Add("Google Drive")
```

`Connect()` without a key still resolves the first configuration row (or `google-oauth.json`) and is the compatibility entry. Prefer `ConnectKey` / `Add` when the UI lists accounts.

Do not name variables `store` or `drive`.

## Namespace Map

| File | Namespace | Types |
| --- | --- | --- |
| `src/tables/configuracao_google_drive.bas` | `configuracao_google_drive` | `TConfiguracaoGoogleDrive` |
| `src/mapping/google_drive_token_mapper.bas` | `google_drive_token_mapper` | `GoogleDriveTokenMapper` |
| `src/stores/google_drive_token_store_sql.bas` | `google_drive_token_store_sql` | `GoogleDriveTokenStoreSql` |
| `src/stores/google_drive_sql_stores.bas` | `google_drive_sql_stores` | `GoogleDriveSqlStores` |
| `src/migrations/google_drive_sql_migrations.bas` | `google_drive_sql_migrations` | `GoogleDriveSqlMigrations` |
| `src/tests/google_drive_store_sql_tests.bas` | `google_drive_store_sql_tests` | `GoogleDriveStoreSqlTests` |
| `src/tests/google_drive_store_sql_live.bas` | `google_drive_store_sql_live` | `GoogleDriveStoreSqlLive` |

`src/Principal.bas` runs `GoogleDriveStoreSqlTests.RunAll()` then `GoogleDriveStoreSqlLive.Run()`. It is not a consumer API.

## Facade (`GoogleDriveSqlStores`)

```basic
Shared Function Migrate() As Integer
   ' configuracao_google_drive_customizado_01 = drop legacy Customizado.GoogleDriveConnection if present,
   '   then table + sequence Customizado.ConfiguracaoGoogleDrive
   ' returns count of newly applied migrations

Shared Function ListConnections() As TTList<TConfiguracaoGoogleDrive>
   ' Fetch of every configuration row, ordered by Titulo
   ' consume as Dim rows[] As TConfiguracaoGoogleDrive
   ' combo value: row.AccountKey() = CodConfiguracaoGoogleDrive
   ' combo caption: row.AccountCaption() ("Titulo (Email)")

Shared Function Connect(pTitulo As String = "Google Drive", pInteractive As Boolean = True) As GoogleAuthService
   ' ResolveConfig (first SQL row, else google-oauth.json, else empty) + Drive scope
   ' Open(cfg, titulo) + GoogleAuthConnect.Run

Shared Function ConnectKey(pCod As Integer, pTitulo As String = "", pInteractive As Boolean = True) As GoogleAuthService
   ' ConfigOfKey(pCod) + Open + GoogleAuthConnect.Run

Shared Function Add(pTitulo As String = "Google Drive", pInteractive As Boolean = True) As GoogleAuthService
   ' copies ClientId/secret from ResolveConfig, AccountId empty, Open(..., pInsertNew=True)
   ' does not Clear or Update an existing account row

Shared Function Open(pConfig As GoogleAuthConfig = Null, pTitulo As String = "", pInsertNew As Boolean = False) As GoogleTokenStore
   ' no config: unbound store (Load/Save/Clear use pKey; missing key returns Null)
   ' with config, pInsertNew False: FindByStoreKey then update, or insert if missing
   ' with config, pInsertNew True: always insert a new row and bind the store to that PK

Shared Function ConfigOf() As GoogleAuthConfig
   ' first row (CurrentRow); throws if missing or ClientId empty

Shared Function ConfigOfKey(pCod As Integer) As GoogleAuthConfig
   ' FindByKey(pCod); throws if missing or ClientId empty

Shared Sub ApplyProfile(pEmail As String, pName As String, pCod As Integer = 0)
   ' FindByKey(pCod), else FindByEmail, else CurrentRow; writes Email/Nome and StoreKey = ClientId|Email
```

`ConnectKey` is the consumer entry for a selected combo value. `Add` is the consumer entry for "Nova conexão". After `auth.Free()`, call `GoogleDriveSqlStores.DropConfig(auth.Config())` only if you kept the `cfg` reference **before** `Free` (Load does not own the config).

`TConfiguracaoGoogleDrive.FindByKey(pCod)` loads by `CodConfiguracaoGoogleDrive` only. `AccountKey` is that PK as string for combo values; pass `ConnectKey(CInt(comboValue))`. OAuth `ClientId|AccountId` lookups use `FindByStoreKey`.

## Token store (`GoogleDriveTokenStoreSql`)

Inherits `GoogleTokenStore`. `Open` with a config binds the instance to that row's PK (`BoundCod`) so OAuth `Save` stays on the new row while `StoreKey` is still `ClientId|` (email unknown). An unbound store (`Open()` with no config) looks up by `pKey` on every call.

| Method | Behavior |
| --- | --- |
| `Load` | bound PK via `FindByKey`, else `FindByStoreKey`; `Null` when missing or no access/refresh token |
| `Save` | bound PK via `FindByKey`, else `FindByStoreKey`; **inserts** a new row when missing; copies config credentials when `ClientId` is still empty; fills `Email`/`Nome` from `id_token` JWT when those columns are empty |
| `Clear` | zeros token/expiry columns on the resolved row; keeps `Titulo` and OAuth app credentials |
| `Exists` | True when access or refresh token is present on the resolved row |
| `ApplyProfile` | writes `Email` / `Nome` and syncs `StoreKey` to `ClientId\|Email` |

`FindByKey(pCod As Integer)` filters `CodConfiguracaoGoogleDrive = pCod` (`Null` when `pCod <= 0`). `FindByStoreKey` / `FindByEmail` are separate lookups.

## Table `Customizado.ConfiguracaoGoogleDrive`

Global table (no `CodEmpresa`) in schema `Customizado`. Sequence `Customizado.ConfiguracaoGoogleDrive_Sequencia`. One row per Google account.

| Column | Kind | Notes |
| --- | --- | --- |
| `CodConfiguracaoGoogleDrive` | Integer PK AutoCode | |
| `Titulo` | String(150) | required; display name only |
| `Email` | String(255) | |
| `Nome` | String(200) | account display name |
| `Ativo` | Boolean | `S`/`N`, default true |
| `ClientId` | String(200) | |
| `ClientSecret` | String(500) | encrypted at rest |
| `Scopes` | String(1000) | space-separated |
| `CallbackPort` | Integer | default 8085 |
| `StoreKey` | String(250) | `ClientId\|` or `ClientId\|Email` |
| `AccessToken` | String(4000) | encrypted at rest |
| `RefreshToken` | String(4000) | encrypted at rest |
| `IdToken` | String(4000) | encrypted at rest |
| `TokenType` | String(50) | |
| `ExpiresIn` | Integer | |
| `CreatedAt` | DateTime | |
| `ExpiresAt` | DateTime | |

`CurrentRow` / `HasRow` remain for compatibility (first row / any row). Prefer `FindByKey(cod)` / `ListConnections`. In-memory properties are plaintext; `BindField` encrypts and `ReadField` decrypts `ClientSecret`, `AccessToken`, `RefreshToken`, and `IdToken` with `Data7.Criptografar` / `Descriptografar`.

## Ownership

`GoogleAuthService.Load(cfg, tokenStore)` defaults `pOwnsStore = True`. `auth.Free()` frees HTTP, consent, grants, and the token store. It does **not** free `cfg`. After that, do not `tokenStore.Free()` (double-free).

## Module Notes

- Call `Migrate()` once at ERP startup. History is `_developer_table_migrations`.
- Do not log access tokens, refresh tokens, or client secrets.
- Do not wrap this store in `GoogleTokenStoreEncrypted`.
- There is no UI in this module. `Connect` / `ConnectKey` / `Add` delegate consent to `mod_google_auth` `GoogleAuthConnect.Run`.
- Live: `GoogleDriveStoreSqlLive.Run()` migrates, then `GoogleDriveSqlStores.Connect()` (silent when the first SQL row has tokens; locked form when JSON/SQL has Client ID+secret; editable otherwise). Then it lists files in Drive folder `mod_google_drive`. Optional `google-drive-live.json`: `connection_title`, `folder_name`, `folder_id`.
