**Update 1.14.0**

**Release Summary**

- **Scope**: Major features including Server Profile management, background video playback, activity tracking, along with UI optimizations, UI language fixes, and removal of unused features.

**Highlights**

- **Server Profiles**: Added support for managing multiple server profiles. The login process, `AuthProvider`, and GraphQL providers are now profile-aware, enabling users to seamlessly switch between different Stash servers.
- **Background Video Playback**: Enabled background playback for videos, including the ability to mix audio with other apps.
- **Scene Activity Tracking**: Added tracking for scene activity and periodic saves, introducing `play_duration` to scene data.
- **Enhanced Settings UI**: Added toggles for showing/hiding credentials and folding advanced authentication methods. Added options for showing performer avatars and adjusting their size. The "Shake to Discover" feature and its related settings were removed.
- **Language Preference Fix**: Resolved an issue where the selected language was not correctly displayed in the settings interface due to a type mismatch.
- **Optimizations**: Improved the Bolt VTT parsing loop and optimized `ServerProfileDrawer` rebuilds by utilizing `viewInsetsOf`.

**Notable Fixes**

- Streamlined language preference handling in the settings page to accurately reflect the user's choice.
- Optimized credential fetching and simplified the server URL input and normalization logic for base and full URLs.
- Resolved compilation errors, cleaned up unused code, and optimized imports across multiple files.
- Added helpful tooltips to the Scene Info close button and password visibility toggles.

**Internal / Developer Changes**

- Updated scene fetching logic to use the `cacheAndNetwork` policy and added refresh functionality.
- Implemented the `ServerProfile` model along with migration scripts for the new provider architecture.
- Added Material 3 Expressive settings UI design spec and implementation plans to the documentation.
- Ignored `.worktrees` directory in `.gitignore`.
- Updated `.arb` localization files to account for removed strings and updated server URL helper text.

**Files changed (key items)**

- **Profiles / Setup:** `lib/features/setup/` (ServerProfile models and providers, auth refactors)
- **Settings UI:** `lib/features/setup/presentation/pages/settings/interface_settings_page.dart` (Language fix, removal of shake gesture)
- **Video Player / Playback:** `lib/features/scenes/` (Activity tracking, play duration additions, background playback enablement)
- **Navigation:** `lib/features/navigation/presentation/shell_page.dart` (Removal of ShakeGesture functionality)
- **Documentation:** `docs/` (Server profiles design spec, Material 3 UI design specs, Server URL simplification plans)
