_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashAppFlutter MVP Design Specification

## 1. Overview
StashAppFlutter is a mobile-first Flutter client for the Stash media server. The MVP focuses on a "YouTube-style" experience for browsing and playing video scenes, built on a foundation that allows for future expansion into images, galleries, and full metadata management.

## 2. Architecture
The application follows a **Per-Feature Clean Architecture** pattern.

### 2.1 Layers
- **Domain Layer**: Contains pure Dart entities (`Scene`, `Performer`, `Studio`, `Tag`) defined with `freezed`. It defines repository interfaces that the presentation layer depends on.
- **Data Layer**: Implements the repository interfaces using `graphql_flutter`. It handles the mapping between Stash's GraphQL fragments and domain entities.
- **Presentation Layer**: Uses `flutter_riverpod` for state management. `GoRouter` manages deep-linkable navigation.

### 2.2 Core State Management
- `sharedPreferencesProvider`: Provides access to local settings (Server URL, API Key, UI preferences).
- `graphqlClientProvider`: Rebuilds automatically when server settings change.
- `sceneListProvider`: An `AsyncNotifier` that manages pagination, searching, and refreshing of the main scene feed.
- `playerStateProvider`: Manages the "Active Scene" to synchronize playback between the detail page and the persistent mini-player.

## 3. UI/UX Design

### 3.1 Home Page (Scenes Feed)
- **Layout**: A vertical list of `SceneCard` widgets.
- **Adaptive SceneCard**:
    - **List Mode (Current)**: Full-width aspect ratio (16:9) thumbnail, avatar, title, studio, and date displayed prominently.
    - **Grid Mode (Future)**: Compact version showing only the thumbnail and title, hiding secondary metadata to fit 2 columns.
- **Features**: Pull-to-refresh, infinite scroll (pagination), and basic keyword search in the AppBar.

### 3.2 Scene Detail Page
- **Video Player**: Fixed at the top using `video_player` + `chewie`.
- **Primary Metadata**: Immediately visible below the player: Title, Studio (clickable), Date, and a horizontal/scrollable list of Performers.
- **Expandable Section**: A "Description/Details" section that contains:
    - User-provided scene details.
    - Tag list.
    - Technical metadata (Resolution, Codec, Bitrate).
- **Behavior**: Controlled by a user setting "Auto-expand details".

### 3.3 Persistent Mini-Player
- A standard 60dp height bar above the bottom navigation.
- Shows the current thumbnail, title, and a play/pause toggle.
- Tapping the mini-player navigates the user back to the Scene Detail page without interrupting playback.

## 4. Features & Settings
- **Connection Management**: A dedicated Settings page to configure the Stash server URL and API key.
- **UI Toggles**:
    - "Auto-expand scene details": Boolean (defaults to false).
    - "Layout Mode": Reserved for future (1-column vs 2-column).

## 5. Data Integration (GraphQL)
The MVP will utilize existing Stash fragments:
- `SceneData` for full details.
- `SlimSceneData` for the feed to optimize bandwidth.
- `sceneStreams` query to retrieve the primary playback URL.

## 6. Testing Plan
- **Mock Repositories**: Test UI states (Loading, Error, Empty) using a mock data layer.
- **Entity Validation**: Unit tests to ensure the domain entities correctly handle missing or null fields from the API.
- **Navigation Flow**: Verify that the mini-player state is preserved during routing.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
