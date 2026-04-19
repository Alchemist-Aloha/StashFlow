## Stage
- team-verify

## Goal / Non-goals
### Goals
- Implement `AuthMode.basic` (Basic Auth) and `AuthMode.bearer` (Bearer Token). [VERIFIED]
- Add a developer setting to enable/disable these "Proxy Auth" modes. [VERIFIED]
- Inject appropriate `Authorization` headers into all Stash backend communications (GraphQL and Media). [VERIFIED]
- Ensure credentials are saved securely using existing secure storage infrastructure. [VERIFIED]
- Update `ServerSettingsPage` to support configuration of these new modes. [VERIFIED]
- Add unit tests for `AuthProvider`, `GraphqlClient`, and `MediaHeadersProvider`. [VERIFIED]

### Non-goals
- Change existing `password` or `apiKey` logic.
- Implement any backend-side auth logic (it's handled by a proxy).
- Support cookies for these new modes.

## Task Graph
| Task ID | Priority | Task | Owner | Dependency | Path Type | Worktree | Baseline | Lane Notes | Validation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T1 | p1 | Update `AuthMode` enum to include `basic` and `bearer` | omg-executor | - | sequential | - | HEAD | - | VERIFIED |
| T2 | p1 | Add `enable_proxy_auth_modes` to `SharedPreferences` and UI in `DeveloperSettingsPage` | omg-executor | - | sidecar | - | HEAD | - | VERIFIED |
| T3 | p1 | Add localization strings for new auth modes and dev setting | omg-executor | - | sidecar | - | HEAD | - | VERIFIED |
| T4 | p1 | Update `GraphqlClient` to inject `Authorization` headers for `basic` and `bearer` modes | omg-executor | T1 | sequential | - | HEAD | - | VERIFIED |
| T5 | p1 | Update `mediaHeadersProvider` and `mediaPlaybackHeadersProvider` to inject `Authorization` headers | omg-executor | T1 | sequential | - | HEAD | - | VERIFIED |
| T6 | p1 | Update `ServerSettingsPage` to display and configure new auth modes | omg-executor | T1, T2, T3 | sequential | - | HEAD | - | VERIFIED |
| T7 | p1 | Add `AuthProvider` tests for basic/bearer hydration and mode setting | omg-executor | - | sidecar | - | HEAD | - | VERIFIED |
| T8 | p1 | Add `GraphqlClient` tests for `Authorization` header injection | omg-executor | - | sidecar | - | HEAD | - | VERIFIED |
| T9 | p1 | Create `media_headers_provider_test.dart` and add tests for header injection | omg-executor | - | sidecar | - | HEAD | - | VERIFIED |

## Critical Files
- `lib/core/data/auth/auth_mode.dart`
- `lib/core/data/graphql/graphql_client.dart`
- `lib/core/data/graphql/media_headers_provider.dart`
- `lib/features/setup/presentation/pages/settings/developer_settings_page.dart`
- `lib/features/setup/presentation/pages/settings/server_settings_page.dart`
- `lib/l10n/app_en.arb`
- `test/core/data/auth/auth_provider_test.dart`
- `test/core/data/graphql/graphql_client_test.dart`
- `test/core/data/graphql/media_headers_provider_test.dart`

## Risks
- **Header conflicts:** Ensure `Authorization` header doesn't conflict with other potential headers. [MITIGATED]
- **Web limitations:** Basic auth headers might be restricted in some browser environments if not handled carefully. [OBSERVED]
- **Media headers:** Some video players or image loading libraries might need special handling for custom headers. [IMPLEMENTED]

## Taskboard Sync
- Verification completed for implementation and unit tests. All criteria met.

## Ready For team-prd
- Yes.
