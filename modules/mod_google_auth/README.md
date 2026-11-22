# mod_google_auth

Google OAuth 2.0 authentication for Data7: user consent, authorization-code exchange with PKCE, access-token refresh/rotation, revocation, and a Bearer interceptor for any Google API. It does **not** call Drive, Gmail, or other product APIs, and it does **not** implement Service Account JWT or a SQL token store — those stay in the consumer or a later version.

Version **1.0.0.1**. Dependencies (`data7.json`): `mod_http` `2.1.3.0`, `mod_winapi` `1.0.0.0`, `mod_certificate` `1.0.0.0` (`mod_io` also comes transitively with `mod_http`). PKCE SHA-256 uses `TCertUtil.HashFile`.

This file is the module contract. Consumers must be able to assemble, extend, and call the API from this README alone. Open a `.bas` file only to confirm a detail that is not stated here. Never edit files under `data7_modules/`.

## Quick Start (Minimal)

```basic
Imports google_auth
Imports google_auth_config
Imports google_auth_connect
Imports google_auth_store
Imports google_auth_stores

Dim cfg As GoogleAuthConfig = GoogleAuthConfig.FromFile("google-oauth.json")
cfg.Scopes.Add("https://www.googleapis.com/auth/drive")

Dim tokenStore As GoogleTokenStore = GoogleTokenStores.Json("google-tokens.json")
Dim auth As GoogleAuthService = GoogleAuthConnect.Run(cfg, tokenStore)

Dim accessToken As String = auth.GetAccessToken()
httpClient.Use(auth.CreateBearerInterceptor())
```

`GoogleAuthConnect.Run` is the uniform entry for any `GoogleTokenStore` (JSON, memory, or a consumer SQL store). If the store already has tokens it loads silently; if Client ID/secret are present it opens a **locked** form; if credentials are missing it opens the **editable** setup form. Tokens are saved into the injected store.

`Load` throws if `pStore` is unassigned. `GetAccessToken()` returns a valid access token, refreshing or running the browser consent flow when needed.

## Namespace Map

| File | Namespace | Types |
| --- | --- | --- |
| `src/lib/core/google_auth_enums.bas` | `google_auth_enums` | `GoogleAuthApiVersion`, `GoogleAuthGrantType`, `GoogleAuthConsentKind`, `GoogleAuthTokenType`, `GoogleAuthUiMode` |
| `src/lib/core/google_auth_errors.bas` | `google_auth_errors` | `GoogleAuthErrors` |
| `src/lib/core/google_auth_capabilities.bas` | `google_auth_capabilities` | `GoogleAuthCapabilities` |
| `src/lib/core/google_auth_client.bas` | `google_auth_client` | `GoogleAuthClient` |
| `src/lib/config/google_auth_config.bas` | `google_auth_config` | `GoogleAuthConfig` |
| `src/lib/models/google_auth_credentials.bas` | `google_auth_credentials` | `GoogleAuthCredentials` |
| `src/lib/models/google_auth_scopes.bas` | `google_auth_scopes` | `GoogleAuthScopes` |
| `src/lib/models/google_auth_token_set.bas` | `google_auth_token_set` | `GoogleTokenSet` |
| `src/lib/models/google_auth_session_result.bas` | `google_auth_session_result` | `GoogleAuthSessionResult` |
| `src/lib/models/google_auth_code.bas` | `google_auth_code` | `GoogleAuthCode` |
| `src/lib/models/google_auth_state.bas` | `google_auth_state` | `GoogleAuthState` |
| `src/lib/endpoints/google_auth_endpoints.bas` | `google_auth_endpoints` | `GoogleOAuthEndpoints` |
| `src/lib/endpoints/google_auth_endpoints_v2.bas` | `google_auth_endpoints_v2` | `GoogleOAuthEndpointsV2`, `GoogleOAuthEndpointCatalog` |
| `src/lib/http/google_auth_http.bas` | `google_auth_http` | `GoogleAuthHttp` |
| `src/lib/crypto/google_auth_crypto.bas` | `google_auth_crypto` | `RandomUnreserved`, `Sha256Base64Url`, `ToBase64Url` |
| `src/lib/crypto/google_auth_pkce.bas` | `google_auth_pkce` | `GoogleAuthPkce` |
| `src/lib/grants/google_auth_grant.bas` | `google_auth_grant` | `GoogleAuthGrantContext`, `GoogleAuthGrant` |
| `src/lib/grants/google_auth_grant_code.bas` | `google_auth_grant_code` | `GoogleAuthGrantAuthorizationCode` |
| `src/lib/grants/google_auth_grant_refresh.bas` | `google_auth_grant_refresh` | `GoogleAuthGrantRefreshToken` |
| `src/lib/grants/google_auth_grant_service.bas` | `google_auth_grant_service` | `GoogleAuthGrantServiceAccount` (slot; throws) |
| `src/lib/stores/google_auth_store.bas` | `google_auth_store` | `GoogleTokenStore` |
| `src/lib/stores/google_auth_store_memory.bas` | `google_auth_store_memory` | `GoogleTokenStoreMemory` |
| `src/lib/stores/google_auth_store_json.bas` | `google_auth_store_json` | `GoogleTokenStoreJson` |
| `src/lib/stores/google_auth_store_encrypted.bas` | `google_auth_store_encrypted` | `GoogleTokenStoreEncrypted` |
| `src/lib/stores/google_auth_stores.bas` | `google_auth_stores` | `GoogleTokenStores` |
| `src/lib/consent/google_auth_consent.bas` | `google_auth_consent` | `GoogleConsentHandler` |
| `src/lib/consent/google_auth_consent_loopback.bas` | `google_auth_consent_loopback` | `GoogleConsentLoopback` |
| `src/lib/consent/google_auth_consent_manual.bas` | `google_auth_consent_manual` | `GoogleConsentManual` |
| `src/lib/interceptors/google_auth_bearer.bas` | `google_auth_bearer` | `GoogleBearerInterceptor` |
| `src/lib/runtime/google_auth.bas` | `google_auth` | `GoogleAuthService` |
| `src/lib/runtime/google_auth_connect.bas` | `google_auth_connect` | `GoogleAuthConnect` |
| `src/lib/validation/google_auth_validation.bas` | `google_auth_validation` | `GoogleAuthValidator` |
| `src/forms/google_auth_form.bas` | `google_auth_form` | `GoogleAuthForm` |
| `src/tests/google_auth_tests.bas` | `google_auth_tests` | `GoogleAuthTests`, `GoogleAuthConsentFake` |

HTTP types (`HttpClient`, `HttpInterceptor`, `HttpCallback`, `Http.Mock`) come from `mod_http`. Browser launch uses `WinAPI.Execute` from `mod_winapi`.

## Enums

```basic
Enun GoogleAuthApiVersion
   V2 = "V2"
End Enun

Enun GoogleAuthGrantType
   AuthorizationCode = "authorization_code"
   RefreshToken = "refresh_token"
   ServiceAccount = "service_account"
End Enun

Enun GoogleAuthConsentKind
   Loopback = "loopback"
   Manual = "manual"
End Enun

Enun GoogleAuthTokenType
   Bearer = "Bearer"
End Enun

Enun GoogleAuthUiMode
   Headless = "headless"
   Locked = "locked"
   Editable = "editable"
End Enun
```

## Facade (`GoogleAuthService`)

```basic
Shared Function Load(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pOwnsStore As Boolean = True) As GoogleAuthService
   ' throws GoogleAuthErrors.ConfigRequired / StoreRequired
   ' throws if GrantType is ServiceAccount
   ' wires DefaultTransport HTTP, OAuth V2 endpoints, loopback or manual consent

Sub New(pConfig, pStore, pHttp, pConsent, pOwnsStore = True, pOwnsHttp = True, pOwnsConsent = True)
   ' injection constructor for tests (Http.Mock, memory store, fake consent)
```

| Method | Behavior |
| --- | --- |
| `GetAccessToken()` | Load store → valid access token, else refresh, else `Authorize()` |
| `Authorize()` | PKCE + state, open browser, wait for loopback, exchange `code`, persist |
| `StartAuthorization()` | Generates PKCE/state and returns the Google auth URL without waiting |
| `CompleteFromRedirectUrl(url)` | Exchanges `code` from a pasted redirect URL using the pending PKCE |
| `CancelConsent()` | Stops the loopback listener (or manual prompt) after confirmation in the form |
| `RefreshTokens()` | `grant_type=refresh_token`; persists rotated refresh when Google returns one |
| `Revoke()` | POST revoke, then `store.Clear` |
| `IsAuthorized()` | Store has access or refresh token |
| `CreateBearerInterceptor()` | `HttpInterceptor` that sets `Authorization: Bearer {GetAccessToken()}` |
| `CurrentTokens()` | Clone from store or `Null` |

Expiry uses `GoogleAuthConfig.ExpirySkewSeconds` (default `60`).

**Ownership:** `Free()` frees HTTP, consent, grants, and the store when `pOwnsStore` is True. It does **not** free the config passed to `Load`.

## Connect (`GoogleAuthConnect`)

```basic
Shared Function Run(pConfig As GoogleAuthConfig, pStore As GoogleTokenStore, pOwnsStore As Boolean = True, pInteractive As Boolean = True, pTitle As String = "Autenticação Google") As GoogleAuthService
```

| Situation | Behavior |
| --- | --- |
| Store already has access or refresh token for `cfg.StoreKey()` | `GoogleAuthService.Load` (no form) |
| `cfg` has Client ID and secret, no tokens, `pInteractive = True` | `GoogleAuthForm.ForConsent(cfg, pStore)` (locked) |
| Same, `pInteractive = False` | `GoogleAuthForm.RunHeadless(cfg, pStore)` (browser only) |
| Missing Client ID/secret, `pInteractive = True` | `GoogleAuthForm.ForSetup(title, pStore)` (editable; JSON pre-fill if present) |
| Missing Client ID/secret, `pInteractive = False` | throws `ClientIdRequired` |

The form is given `pOwnsStore = False` so the returned `GoogleAuthService` can own the store. Cancelled consent throws `ConsentCancelled`. Scopes stay on `cfg` — add Drive/Gmail/etc. **before** `Run`.

Any store that inherits `GoogleTokenStore` works the same way:

```basic
Dim tokenStore As GoogleTokenStore = GoogleDriveSqlStores.Open(cfg)
Dim auth As GoogleAuthService = GoogleAuthConnect.Run(cfg, tokenStore)
```

## UI modes (`GoogleAuthForm`)

The setup screen is optional. Authorization itself always opens the Google browser; “headless” means **no Data7 form**.

| Mode | Factory | Behavior |
| --- | --- | --- |
| **Headless** | `GoogleAuthForm.RunHeadless(config, store)` | No form. Opens the browser, waits on loopback, returns `GoogleAuthSessionResult`. Same as `GoogleAuthService.Load` + `Authorize()`. |
| **Locked** | `GoogleAuthForm.ForConsent(config, store)` or `ForConsent(config, storePath)` | Form opens with Client ID, secret and scopes filled and **disabled**. User only clicks Autorizar / Extrair. On success the form **closes** and `Execute()` returns the result. Prefer the store overload so tokens go to SQL/memory/JSON without a file path. |
| **Editable** | `New GoogleAuthForm()` / `ForSetup(title)` / `ForSetup(title, store)` | Setup UI: user types credentials, window stays open. With an injected store, tokens are saved there and `google-oauth.json` is **not** written. |

```basic
Imports google_auth_form
Imports google_auth_session_result

' Caller already has client id, secret and scopes; tokens go to the injected store:
Dim consentForm As GoogleAuthForm = GoogleAuthForm.ForConsent(cfg, tokenStore)
Dim sessionResult As GoogleAuthSessionResult = consentForm.Execute()
If sessionResult.Succeeded Then
   print(sessionResult.Email)
End If
consentForm.Free()
sessionResult.Free()

' No form at all:
Dim silentResult As GoogleAuthSessionResult = GoogleAuthForm.RunHeadless(cfg, tokenStore)
```

`GoogleAuthSessionResult`: `Succeeded`, `Cancelled`, `Email`, `Name`, `ErrorMessage`, `Tokens()` (clone; caller must `Free`). Locked/headless, and editable with an injected store, do **not** write `google-oauth.json`; tokens go to the injected store (or to `google-tokens.json` when `ForConsent` is called with a path).

## Token stores (required injection)

```basic
MustInherit Class GoogleTokenStore
   Overridable Function Load(pKey As String) As GoogleTokenSet   ' Null if missing
   Overridable Sub Save(pKey As String, pTokens As GoogleTokenSet)
   Overridable Sub Clear(pKey As String)
   Overridable Function Exists(pKey As String) As Boolean
End Class
```

`pKey` is `GoogleAuthConfig.StoreKey()` = `ClientId & "|" & AccountId`.

Catalog:

```basic
GoogleTokenStores.Memory()           ' process lifetime; no encryption
GoogleTokenStores.Json(path)         ' file via TFile; wrapped in GoogleTokenStoreEncrypted
```

`GoogleTokenStoreEncrypted` encrypts `access_token`, `refresh_token`, and `id_token` with `Data7.Criptografar` / `Descriptografar`.

SQL is **not** implemented. Inherit `GoogleTokenStore` and pass the instance into `Load`:

```basic
Class MyErpTokenStore
   Inherits GoogleTokenStore
   Overrides Function Load(pKey As String) As GoogleTokenSet
      ' future: SELECT
   End Function
End Class

Dim auth As GoogleAuthService = GoogleAuthService.Load(cfg, New MyErpTokenStore())
```

## OAuth user flow

- Authorization: `https://accounts.google.com/o/oauth2/v2/auth`
- Token / revoke: `https://oauth2.googleapis.com/token`, `https://oauth2.googleapis.com/revoke`
- Catalog: `GoogleOAuthEndpointCatalog.Make(GoogleAuthApiVersion.V2())` / `MakeByName("V2")`
- PKCE `S256` (RFC 7636). SHA-256 via `certutil -hashfile`.
- Loopback: `WinAPI.Execute` then `HttpCallback.Start(port)` on `http://localhost:{CallbackPort}/`. `CancelConsent()` calls `HttpCallback.Stopp()` to terminate the PowerShell listener.
- If the listener fails, paste the redirect URL (`http://localhost:.../?code=...`) and call `CompleteFromRedirectUrl` — the setup form exposes this as **Extrair token da URL**.
- Manual consent: paste redirect URL or raw code
- Token POST body is `application/x-www-form-urlencoded` through `mod_http` (`HttpClient.Post`)
- `access_type=offline` and `prompt=consent` by default so a refresh token is issued

## Config file

`GoogleAuthConfig.FromFile` accepts this module's JSON and Google Desktop `installed` / `web` client-secret files.

```json
{
  "client_id": "...apps.googleusercontent.com",
  "client_secret": "...",
  "scopes": "https://www.googleapis.com/auth/drive",
  "callback_port": 8085,
  "account_id": "",
  "api_version": "V2"
}
```

`ToFile` writes `client_secret` encrypted.

## Service Account slot

`GoogleAuthGrantServiceAccount.Exchange` and `GoogleAuthValidator.Validate` throw `Service Account grant is not supported in this version.` JWT implementation belongs in that grant file later.

## Tests

`google_auth_tests.GoogleAuthTests.RunAll()` uses `Http.Mock` only — no live Google network. Coverage: enums, auth URL, token JSON, expiry skew, PKCE RFC 7636 vector, code extract, memory/JSON stores, refresh rotation, authorize exchange, complete from pasted redirect URL, custom store injection, null store, invalid callback state, service-account slot, Bearer interceptor, session result, `GoogleAuthConnect` silent reuse and missing credentials.

## Module Notes

- All live HTTP goes through `data7_modules/mod_http`. Do not use native `THTTP`, WinHttp COM, or PowerShell for token calls.
- Do not log access tokens, refresh tokens, or client secrets.
- `GoogleAuthForm` is a Portuguese UI with three modes (`Headless` / `Locked` / `Editable`). Autorizar becomes Parar autorização while waiting; Extrair token da URL exchanges a pasted redirect URL. The library itself is English.
- Future SQL store must implement `GoogleTokenStore` and stay out of `GoogleTokenStores` until that version.
