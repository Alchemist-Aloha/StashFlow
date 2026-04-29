# Remove Video Middle Layer Design

## Overview
The goal of this project is to remove the `video_player` to `media_kit` conversion middle layer step by step, without breaking the UI and video-related logic. The app currently uses an adapter pattern (`AppVideoController` and `MediaKitVideoControllerAdapter`) to expose `media_kit` via a `ValueListenable` interface that mimics `video_player`. We will migrate the UI to use `media_kit`'s native reactive stream APIs.

## Architecture & Components
The middle layer consists of:
1. `AppVideoController`, `AppVideoValue`, and `MediaKitVideoControllerAdapter` (in `app_video_controller.dart`).
2. `AppVideoSurface` (in `app_video_surface.dart`).

These will be entirely removed. 

The replacement involves:
- **`GlobalPlayerState`**: Replacing `AppVideoController? videoPlayerController` with `Player? player` and `VideoController? videoController` from `media_kit`.
- **`PlayerState` Provider**: Changing initialization logic to instantiate `Player` and `VideoController` natively, and updating the stream listeners inside the provider to rely on `media_kit` events.
- **UI Components** (`SceneVideoPlayer`, `NativeVideoControls`, `TransformableVideoSurface`, `VideoPlaybackControls`, `SceneSubtitleOverlay`): These will accept `Player` and/or `VideoController` instead of the adapter interface. They will use direct `StreamSubscription` or `StreamBuilder` logic in `initState` and `build` to respond to state changes such as `position`, `playing`, `duration`, `buffer`, and `subtitle`.
- **Surface**: Using the native `media_kit_video` `Video(controller: videoController)` widget directly instead of `AppVideoSurface`.

## Data Flow
- The `PlayerState` provider handles video initialization and provides `Player` and `VideoController` instances to the UI tree.
- UI widgets will listen to `player.stream.*` (`player.stream.position`, `player.stream.playing`, `player.stream.duration`, `player.stream.buffer`, `player.stream.subtitle`, `player.stream.rate`, `player.stream.videoParams`) to rebuild themselves selectively. This replaces the monolithic `ValueListenableBuilder<AppVideoValue>` approach.

## Error Handling & Testing
- Errors during stream resolution or initialization will continue to be caught in the `PlayerState` provider. The widget lifecycle will remain unchanged (i.e. loading spinners while `controller.player.state.width == null`).
- Tests that mock `AppVideoController` will be updated to mock `Player` or stub its streams to simulate the same behaviors.

## Implementation Steps
1. Refactor `GlobalPlayerState` and `PlayerState` to expose `Player` and `VideoController`.
2. Refactor child UI components (`NativeVideoControls`, `TransformableVideoSurface`, etc.) to consume `Player`/`VideoController` and direct streams.
3. Remove `app_video_controller.dart` and `app_video_surface.dart`.
4. Fix and verify existing unit tests related to video playback.
5. Manually verify video playback and controls locally.
