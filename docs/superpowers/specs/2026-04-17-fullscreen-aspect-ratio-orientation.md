# Design: Fullscreen Aspect Ratio Orientation Support

This design implements automatic orientation matching based on video aspect ratio in the fullscreen player, with a setting to toggle gravity-controlled (sensor-based) rotation.

## 1. Objectives

- Ensure the fullscreen video player automatically selects the orientation that best fits the video's aspect ratio (landscape for landscape videos, portrait for portrait videos).
- Provide a user setting to toggle whether the device sensor (gravity) can rotate the video between matching orientations (e.g., flipping between landscape left and landscape right).
- Maintain backward compatibility and a clean settings interface.

## 2. Technical Design

### 2.1 State & Preferences

Add `videoGravityOrientation` to the global player state to track the user preference.

- **File:** `lib/features/scenes/presentation/providers/video_player_provider.dart`
- **Class:** `GlobalPlayerState`
- **Field:** `final bool videoGravityOrientation;`
- **Default:** `true`
- **SharedPreferences Key:** `video_gravity_orientation`

Update `PlayerState` notifier to include:
- `setVideoGravityOrientation(bool value)`: Updates the state and persists to `SharedPreferences`.
- Initialization of `videoGravityOrientation` from `SharedPreferences` in `build()`.

### 2.2 Orientation Logic

Modify the orientation selection logic in the fullscreen player.

- **File:** `lib/features/scenes/presentation/widgets/scene_video_player.dart`
- **Component:** `FullscreenPlayerPage`
- **Method:** `_enterFullScreen()`

**Logic:**
1. Retrieve `videoPlayerController` from state.
2. Get `aspectRatio` from `controller.value.aspectRatio`.
3. Retrieve `videoGravityOrientation` from `playerState`.
4. Determine allowed orientations:
   - **If `aspectRatio > 1.0` (Landscape):**
     - If `videoGravityOrientation` is `true`: `[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]`
     - Else: `[DeviceOrientation.landscapeLeft]`
   - **If `aspectRatio <= 1.0` (Portrait/Square):**
     - If `videoGravityOrientation` is `true`: `[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]`
     - Else: `[DeviceOrientation.portraitUp]`
5. Call `SystemChrome.setPreferredOrientations(orientations)`.

### 2.3 Settings UI

Add a new toggle in the playback settings.

- **File:** `lib/features/setup/presentation/pages/settings/playback_settings_page.dart`
- **Section:** Playback Behavior
- **Widget:** `SwitchListTile.adaptive`
- **Label:** `context.l10n.settings_playback_gravity_orientation`
- **Subtitle:** `context.l10n.settings_playback_gravity_orientation_subtitle`

### 2.4 Localization

Update the English ARB file with new keys.

- **File:** `lib/l10n/app_en.arb`
- **Keys:**
  - `settings_playback_gravity_orientation`: "Gravity-controlled orientation"
  - `settings_playback_gravity_orientation_subtitle`: "Allow rotating between matching orientations using the device sensor (e.g. flipping landscape left/right)."

## 3. Testing Strategy

### 3.1 Manual Verification
1. Open a landscape video and enter fullscreen. Verify it enters landscape mode.
2. If gravity control is ON, verify flipping the device 180° rotates the video.
3. If gravity control is OFF, verify it stays in one landscape orientation.
4. Repeat with a portrait video. Verify it enters portrait mode.
5. Verify square videos are treated as portrait (only allowing portrait orientations, even if gravity control is ON).

### 3.2 Automated Tests
- Add a widget test for `PlaybackSettingsPage` to verify the toggle exists and updates the provider.
- Add a unit test for `PlayerState` to verify the new preference is correctly saved and loaded.
