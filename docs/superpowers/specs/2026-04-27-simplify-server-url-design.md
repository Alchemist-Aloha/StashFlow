# Spec: Simplify Server URL Input

## Background
Currently, the application requires (or strongly suggests) that users include the `/graphql` suffix in the server URL input. While the internal logic (`normalizeGraphqlServerUrl`) is already capable of appending this suffix automatically if it is missing, the UI hints and localization examples still show the full endpoint.

## Goals
- Update the UI to encourage entering only the base URL (e.g., `http://localhost:9999`).
- Ensure a seamless transition for existing users who already have the full URL saved.
- Update all localization files to reflect this change.

## Design
### 1. Localization Changes
Update the following keys in `lib/l10n/app_en.arb`:
- `settings_server_url_helper`: Change from "Example format: http(s)://host:port/graphql." to "Example format: http(s)://host:port."
- `settings_server_url_example`: Change from "http://192.168.1.100:9999/graphql" to "http://192.168.1.100:9999"

These changes will be propagated to all other language files using existing project scripts or manual updates.

### 2. UI Changes
In `lib/features/setup/presentation/widgets/server_profile_drawer.dart`:
- Replace the hardcoded `hintText: 'http://localhost:9999/graphql'` with `l10n.settings_server_url_example`.
- Ensure the `hintText` for the URL input is derived from localization.

### 3. Data Compatibility
No changes are required for `normalizeGraphqlServerUrl` in `lib/core/data/graphql/graphql_client.dart` as it already handles:
- Appending `/graphql` if missing.
- Keeping it if already present.

## Verification Plan
1. **Manual Test**: Create a new server profile using only the base URL (e.g., `http://localhost:9999`) and verify it connects successfully.
2. **Regression Test**: Ensure existing profiles with `/graphql` still function correctly.
3. **Build Verification**: Run `flutter build apk --split-per-abi` to ensure no compilation errors.
