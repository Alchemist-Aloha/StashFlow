# Spec: Server Profiles

Allow users to save and switch between multiple server configurations (profiles) within the application.

## 1. Data Model

### `ServerProfile` (Model)
```dart
class ServerProfile {
  final String id;
  final String? name;
  final String baseUrl;
  final AuthMode authMode;
  final bool allowWebPasswordLogin;

  ServerProfile({
    required this.id,
    this.name,
    required this.baseUrl,
    required this.authMode,
    this.allowWebPasswordLogin = false,
  });
}
```

## 2. Persistence Strategy

### SharedPreferences (Metadata)
- `server_profiles`: JSON-encoded list of `ServerProfile` objects (excluding credentials).
- `active_server_profile_id`: String ID of the currently selected profile.

### SecureStorage (Credentials)
Credentials will be stored per-profile to ensure isolation:
- `profile_{id}_api_key`
- `profile_{id}_username`
- `profile_{id}_password`

## 3. Migration (v1.12.x -> v1.13.0+)

1. On startup, check for `server_base_url` in legacy `SharedPreferences`.
2. If it exists and no profiles are defined:
   - Generate a new UUID.
   - Create a profile named "Default".
   - Copy legacy credentials from `SecureStorage` (keys: `server_api_key`, `server_username`, `server_password`) to the new profile-scoped keys.
   - Save the "Default" profile and set it as active.
   - (Optional) Clean up legacy keys after successful migration.

## 4. UI/UX (Approach 1: Profile List with Edit Drawer)

### ServerSettingsPage (Main)
- **ListView**: Vertical list of profile cards.
- **Profile Card**:
    - Title: `profile.name ?? profile.baseUrl`
    - Subtitle: `profile.baseUrl` (if name is present)
    - Leading: Active indicator (Radio button or Check icon).
    - Trailing: Connection status icon (Green check / Red error) + "Edit" button.
    - Tap Behavior: Switch active profile and trigger global refresh.
- **FAB**: Floating Action Button `(+)` to open the "Add Profile" drawer.

### Profile Edit Drawer (ModalBottomSheet)
- **Form Fields**:
    - Profile Name (Optional)
    - Server URL
    - Auth Method (Dropdown)
    - Credentials (API Key, Username/Password based on Auth Method)
- **Actions**:
    - **Test Connection**: Attempts a GraphQL `GetVersion` query using current form values.
    - **Delete**: Remove the profile (if not the only one).
    - **Save**: Update SharedPreferences and SecureStorage.

## 5. Technical Implementation Details

### Providers
- `serverProfilesProvider`: StateNotifier managing the list.
- `activeProfileProvider`: Watches the active ID and returns the corresponding profile.
- `serverUrlProvider` / `authProvider`: Updated to read from the `activeProfileProvider`.

### Cache Flushing
The existing `_flushRuntimeCachesAfterServerChange` logic will be invoked whenever the `active_server_profile_id` changes to ensure the app state matches the new server context.
