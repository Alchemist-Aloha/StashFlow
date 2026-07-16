# App Configuration Backup Design

## Goal

Let users export and fully restore StashFlow's user-facing settings and server profiles on Android, iOS, Linux, macOS, Windows, and web. Credentials are excluded by default and may optionally be included as unencrypted plain text after an explicit warning.

## Scope

The backup includes:

- user-facing settings managed by an explicit typed registry;
- server profiles and the active profile selection;
- API key, username, password, and cookie header for each profile, plus the app-lock passcode, only when the user enables credential export.

The backup excludes caches, cached metadata, logs, cookies outside the profile credential fields, search history, generated state, and other transient or internal preferences.

Import performs a full replacement of the managed configuration. Unmanaged and transient data is left untouched.

## Backup Format

Backups use UTF-8 JSON with a `.stashflow-config.json` suffix. The root object contains:

- `format`: the constant `stashflow-app-config`;
- `schemaVersion`: an integer format version;
- `createdAt`: an ISO-8601 UTC timestamp;
- `appVersion`: the exporting application version;
- `settings`: typed, explicitly supported user-facing settings;
- `serverProfiles`: serialized server profiles;
- `activeServerProfileId`: a profile ID or null;
- `credentials`: omitted unless credential export is enabled; when present it contains a `profiles` object and may contain `appLockPasscode`.

Profile credential entries are keyed by profile ID and may contain `apiKey`, `username`, `password`, and `cookieHeader`. Empty credential values are omitted. The schema never infers credential inclusion from secure-storage contents. When credentials are excluded, imported app-lock settings are normalized to disabled so a restored configuration cannot lock the user out without its passcode.

Unknown fields in a supported schema version are ignored for forward-compatible additions. Missing required fields, wrong value types, duplicate profile IDs, invalid profile URLs, references to missing profiles, invalid active-profile IDs, and unsupported future schema versions are rejected before storage is modified. Older supported versions pass through explicit migrations into the current immutable model.

## Settings Registry

An application configuration registry explicitly declares every exportable preference key, its value type, validation rule, and default/removal behavior. Supported scalar types are boolean, integer, double, string, and string list. Structured user-facing settings receive dedicated codecs instead of being treated as arbitrary strings.

Raw SharedPreferences enumeration and denylist filtering are prohibited. This prevents caches, fallback secure-storage values, newly introduced internal keys, and transient state from entering backups accidentally. A registry coverage test documents the user-facing providers included in the feature and must be updated when a new persisted setting is added.

Server profiles and credentials use their existing typed storage APIs rather than registry entries.

## Services and Boundaries

`AppConfigBackupCodec` owns deterministic JSON encoding, decoding, validation, and schema migration. It has no Flutter UI or storage dependencies.

`AppConfigService` coordinates export and replacement. It depends on SharedPreferences, `AppSecureStorage`, package-version metadata, a clock, and the settings registry through injectable interfaces. It does not open platform dialogs.

`AppConfigDocumentAdapter` transfers bytes to and from the user. Import uses Flutter's endorsed `file_selector`, which supports opening a file on Android, iOS, Linux, macOS, Windows, and web. Export uses a desktop save location on Linux, macOS, and Windows; Android and iOS use the system share/document flow; web uses byte download/share fallback. Platform-specific code is isolated behind conditional implementations so the domain and storage layers never import `dart:io` on web.

The macOS application receives the user-selected read/write file entitlement required by the endorsed selector implementation.

## Export Flow

1. The Storage settings page opens an export options sheet.
2. `Include credentials` is off by default.
3. Enabling it displays a prominent warning that the file contains readable secrets and anyone with the file can access configured servers.
4. The service reads only registry settings, typed profiles, active profile ID, and optionally the known credential keys for those profiles and the app-lock passcode.
5. The codec validates the in-memory model and creates complete UTF-8 bytes before any platform transfer begins.
6. The document adapter saves, shares, or downloads a timestamped file. User cancellation returns a distinct cancelled result and displays no error.

No backup file is written into application storage as an intermediate. Adapters that require a temporary file must use the platform temporary directory and remove the file in a `finally` block.

## Import Flow and Atomicity

1. The document adapter selects one file and enforces a conservative byte-size limit before decoding.
2. The codec parses, migrates, and validates the entire backup without touching storage.
3. The UI previews the creation time, source app version, setting count, profile count, and whether plain-text credentials are present.
4. The user confirms that all managed settings and profiles will be replaced. A backup containing credentials adds an explicit secret-import warning.
5. The service snapshots all current managed settings, profiles, active profile ID, and known profile credentials in memory.
6. It removes managed preference keys, writes imported settings and profiles, removes credentials for all replaced profiles, and then writes imported credentials when present.
7. If any mutation fails, the service restores the complete snapshot. A rollback failure is reported separately and never presented as a successful import.
8. On success, affected Riverpod providers are invalidated from a single coordinator. The UI reports whether an application restart is required for settings that cannot safely refresh live.

Credentials absent from a backup are deleted as part of full replacement. This includes the app-lock passcode; app lock is disabled when no passcode is restored. Unknown secure-storage keys are not enumerated or deleted.

## User Interface

Storage settings gains an `App configuration` section using existing responsive settings components and dynamic dimensions. It provides `Export configuration` and `Import configuration` actions.

Operations use modal sheets consistent with the current settings design. Actions are disabled while work is in progress. Import preview and both credential warnings require explicit confirmation. Messages distinguish invalid JSON, unsupported version, validation failure, file too large, read/write failure, replacement failure with successful rollback, and replacement failure with failed rollback. Picker cancellation is silent.

All new user-visible strings are added to ARB localization files for English, German, Spanish, French, Italian, Japanese, Korean, Russian, and Chinese variants. Generated localization outputs are regenerated through Flutter tooling.

## Security and Privacy

- Credential export is always opt-in and defaults off for every export.
- The UI and backup metadata clearly label included credentials as unencrypted plain text.
- Backup content and credentials are never logged.
- Parse errors do not echo file contents or secrets.
- File size and structural limits prevent unreasonable memory use or deeply nested input.
- Import never accepts arbitrary SharedPreferences or secure-storage keys.
- Temporary files are deleted after the platform handoff where temporary files are unavoidable.

Encryption and cloud synchronization are outside this feature's scope.

## Testing

Codec unit tests cover deterministic round trips, credential omission/inclusion, all supported setting types, malformed JSON, invalid values, duplicate IDs, invalid profile references, old-version migration, unknown future versions, unknown fields, size limits, and secret-safe errors.

Service tests use in-memory preference and secure-storage fakes. They cover export allowlisting, full replacement, removal of absent credentials, write failure at each mutation stage, successful rollback, rollback failure reporting, and provider refresh signaling.

Widget tests cover the default-off credential switch, plain-text warning, export cancellation, import preview, replacement confirmation, credential warning, progress state, success state, and each error category.

Document-adapter contract tests cover byte preservation, filename/MIME metadata, cancellation, desktop save, mobile share, web download, temporary-file cleanup, and operation without `dart:io` on web.

Final verification runs code generation, formatting, analysis, the full Flutter test suite, Android host tests, and Android, Linux, and web release builds available on the current host. Other platform adapters are verified through contract tests and their native project configuration is inspected.
