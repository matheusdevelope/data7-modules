# mod_google_drive_store_sql

SQL `GoogleTokenStore` for Google Drive / Google Auth on the client ERP database. It maps the single configuration row in `Customizado.ConfiguracaoGoogleDrive` to OAuth credentials and tokens, migrates the table with `mod_table`, and rebuilds `GoogleAuthConfig` so later sessions do not need `google-oauth.json`.

Version **1.0.0.0**. Dependencies (`data7.json`): `mod_google_drive` `1.0.0.0`, `mod_google_auth` `1.0.0.1`, `mod_table` `1.0.0.7`.

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Open a `.bas` file only to confirm a detail that is not stated here. Never edit files under `data7_modules/`.

`client_id` and `client_secret` are **required on every refresh**, not only on the first consent. This store persists both (secret encrypted) together with the refresh token.

There is one configuration per database. There is no `Codigo`: `Titulo` is only a display name, and `Email` / `Nome` identify the connected Google account.

## Quick Start (Minimal)

```basic
Imports google_auth
Imports google_auth_config
Imports google_drive
Imports google_drive_sql_stores

GoogleDriveSqlStores.Migrate()

' First run: locked form if google-oauth.json / SQL has Client ID+secret; editable otherwise.
' Later runs: silent (SQL refresh token).
Dim auth As GoogleAuthService = GoogleDriveSqlStores.Connect()
Dim driveService As GoogleDriveService = GoogleDriveService.Load(auth)
Dim cfg As GoogleAuthConfig = auth.Config()
' auth.Free() also frees the SQL token store. Then DropConfig(cfg).
```

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

Shared Function Connect(pTitulo As String = "Google Drive", pInteractive As Boolean = True) As GoogleAuthService
   ' ResolveConfig (SQL row, else google-oauth.json, else empty) + Drive scope
   ' Open(cfg, titulo) + GoogleAuthConnect.Run (any store, form only when needed)

Shared Function Open(pConfig As GoogleAuthConfig = Null, pTitulo As String = "") As GoogleTokenStore
   ' no config: the configuration row must already exist
   ' with config: upsert the single row, copy client_id/secret/scopes/callback port

Shared Function ConfigOf() As GoogleAuthConfig
   ' rebuilds credentials, scopes, callback port; AccountId = Email when filled

Shared Sub ApplyProfile(pEmail As String, pName As String)
   ' optional; fills Email/Nome after userinfo
```

`Connect` is the consumer entry. `Open` without a config throws if the row is missing. `ConfigOf` throws if the row is missing or has no `ClientId`. After `auth.Free()`, call `GoogleDriveSqlStores.DropConfig(auth.Config())` only if you kept the `cfg` reference **before** `Free` (Load does not own the config).

## Token store (`GoogleDriveTokenStoreSql`)

Inherits `GoogleTokenStore`. Bound to the single configuration row. `Load` / `Save` / `Clear` / `Exists` ignore `pKey` for lookup and persist it in `StoreKey`.

| Method | Behavior |
| --- | --- |
| `Load` | `Null` when the row is missing or has no access/refresh token |
| `Save` | upserts token columns; copies config credentials when `ClientId` is still empty; fills `Email`/`Nome` from `id_token` JWT when those columns are empty |
| `Clear` | zeros token/expiry columns; keeps `Titulo` and OAuth app credentials |
| `Exists` | True when access or refresh token is present |
| `ApplyProfile` | writes `Email` / `Nome` on the configuration row |

## Table `Customizado.ConfiguracaoGoogleDrive`

Global table (no `CodEmpresa`) in schema `Customizado`. Sequence `Customizado.ConfiguracaoGoogleDrive_Sequencia`. One row per database.

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

`CurrentRow` / `HasRow` live on `TConfiguracaoGoogleDrive`. In-memory properties are plaintext; `BindField` encrypts and `ReadField` decrypts `ClientSecret`, `AccessToken`, `RefreshToken`, and `IdToken` with `Data7.Criptografar` / `Descriptografar`.

## Ownership

`GoogleAuthService.Load(cfg, tokenStore)` defaults `pOwnsStore = True`. `auth.Free()` frees HTTP, consent, grants, and the token store. It does **not** free `cfg`. After that, do not `tokenStore.Free()` (double-free).

## Module Notes

- Call `Migrate()` once at ERP startup. History is `_developer_table_migrations`.
- Do not log access tokens, refresh tokens, or client secrets.
- Do not wrap this store in `GoogleTokenStoreEncrypted`.
- There is no UI in this module. `Connect` delegates consent to `mod_google_auth` `GoogleAuthConnect.Run`.
- Live: `GoogleDriveStoreSqlLive.Run()` migrates, then `GoogleDriveSqlStores.Connect()` (silent when the SQL row has tokens; locked form when JSON/SQL has Client ID+secret; editable otherwise). Then it lists files in Drive folder `mod_google_drive`. Optional `google-drive-live.json`: `connection_title`, `folder_name`, `folder_id`.
