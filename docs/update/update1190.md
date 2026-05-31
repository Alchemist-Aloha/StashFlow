# Update 1.19.0

## Security & App Lock

- Added a dedicated **Security** settings page.
- Added app lock controls:
  - Enable/disable app lock
  - Set/change/remove passcode
  - Lock-on-launch toggle
  - Background lock timer options
- Added persisted app lock settings and secure passcode storage integration.
- Added root-level lock gate behavior with lifecycle-aware lock/relock handling.
- Improved unlock input UX with focus and keyboard behavior refinements.

## Casting Improvements

- Improved cast connection flow for Chromecast and AirPlay.
- Added media load confirmation and retry handling for Chromecast startup reliability.
- Added local-to-remote handoff support for resume position and playback state.
- Added remote position/state tracking in cast service state.
- Improved cast pairing/connect error handling and user feedback.
- Added/updated cast service tests.

## Playback, PiP & Background Reliability

- Expanded player lifecycle handling with `WidgetsBindingObserver` integration.
- Added guarded PiP entry requests and improved PiP exit state restoration.
- Improved Android background playback resilience with recovery attempts during lifecycle/audio-focus races.
- Refined media-session callbacks to use explicit play/pause handling.
- Added protections against transient pause commands during background transitions.

## Player UI & Navigation

- Refined mini player visuals and interaction feedback.
- Updated native video controls and playback control widgets for better behavior consistency.
- Improved navigation/back behavior in lock-related and nested route scenarios.

## App Update Flow (Android)

- Enhanced update check model to support architecture-specific Android APK links.
- Added Android-only update dialog action to open the matching APK download in browser when available.
- Renamed update dialog release action label from **Update Now** to **Release Details**.

## Android Platform

- `MainActivity` now includes:
  - Audio service activity integration
  - Recents screenshot policy handling
  - PiP method channel enhancements
  - Device ABI method-channel support for update asset matching
- Updated Android build configuration for compatibility updates.
- Added/updated Android activity tests.

## Localization

- Added/synced localization keys for new settings, security, playback, casting, and update flow text.
- Updated update-dialog action text across supported locales.

## CI, Metadata & Docs

- Updated release workflow actions.
