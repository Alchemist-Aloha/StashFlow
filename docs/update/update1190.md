# Update 1.19.0

## Security & App Lock

- Added a new **Security** settings page with app lock controls:
  - Enable/disable app lock
  - Set/change/remove passcode
  - Lock on launch toggle
  - Background lock timer options
- Introduced persisted app lock settings provider and secure passcode storage flow.
- Added lock overlay integration at app root with lifecycle-based lock behavior.
- Improved lock UX:
  - Auto-focus passcode input on lock open
  - Explicit keyboard open request for faster unlock entry

## Background Playback Robustness (Android)

- Hardened playback provider lifecycle handling for background transitions.
- Reworked media session callback behavior to avoid ambiguous toggle races.
- Added background keep-alive recovery attempts when background playback is enabled.
- Added safeguards to preserve user intent (e.g. not fighting explicit pause actions).

## Navigation & Back Behavior

- Fixed Android back behavior conflicts introduced by lock integration.
- Ensured settings and routed pages correctly return to previous routes instead of exiting unexpectedly in nested navigation scenarios.

## Settings UI & Performance

- Added security entry in Settings Hub and corresponding router integration.
- Improved settings page rendering behavior with repaint isolation in common settings containers/cards.
- Optimized interface language picker list rendering with lazy list building.
- Applied focused settings-shell refinements for smoother interaction and scrolling.

## Scenes & Player UX

- Updated mini player behavior and related player surface/control rendering paths.
- Refined native video controls interactions and playback control surface behavior.

## Android Platform Changes

- Updated `MainActivity` to extend `AudioServiceActivity` for improved media session integration.
- Added Android recents screenshot policy handling.
- Added/updated PiP channel integration and tests around activity behavior.
- Updated Android build configuration for platform compatibility changes.

## Localization & Strings

- Added new localization keys and generated localization updates across supported locales.
- Synced localization outputs with new settings/security and playback-related UI text.

## Release/CI & Project Metadata

- Updated release workflow files.
- Updated dependency metadata and lockfile (including app lock dependency integration).
