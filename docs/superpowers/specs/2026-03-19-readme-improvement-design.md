# Spec: StashAppFlutter README Improvement

Improve the project's `README.md` to be more appealing to end-users by focusing on features, visuals, and ease of use.

## Goals
-   Shift the focus from "technical manifest" to "user-centric product guide."
-   Highlight the "Stash experience on the go."
-   Clearly communicate key features through scannable icons and lists.
-   Provide a clear "Getting Started" path for users.

## Section 1: Hero & Vision
-   **Title:** StashAppFlutter - Your Stash library, everywhere.
-   **Pitch:** A mobile-first Flutter client for your Stash server, designed for seamless browsing and high-quality playback on the go.
-   **Visuals:** Use a Markdown image tag placeholder for a "Feature Showcase" screenshot (e.g., `![StashAppFlutter Showcase](docs/assets/showcase.png)`).

## Section 2: Key Features (The "Why")
-   🎬 **Seamless Playback:** Integrated video player with support for multiple streaming strategies and startup diagnostics.
-   👤 **Rich Browsing:** Explore Scenes, Performers, Studios, and Tags with native-feel pagination and fast search.
-   🎲 **Discovery Tools:** Floating "Random" actions to find hidden gems in your library across all categories.
-   🔍 **Advanced Filtering:** Powerful menu-based sorting and filtering to find exactly what you're looking for.
-   🛠️ **Native Customization:** Configure your server connection, UI preferences (Grid/List layouts), and streaming quality in one place.

## Section 3: Getting Started (The "How")
-   **Step 1: Download:** Point to the GitHub Releases page for APK/IPA downloads.
-   **Step 2: Connect:** Open the app, go to Settings, and enter your `Server URL` and `API Key`.
-   **Step 3: Browse:** Your library will automatically sync and be ready for browsing.
-   **Runtime Settings:** Clearly list the available settings in the app:
    -   `server_base_url`
    -   `server_api_key`
    -   `prefer_scene_streams`
    -   `scene_grid_layout`

## Section 4: Advanced/Technical (The "For Nerds")
-   **Tech Stack:** Flutter, Riverpod, GraphQL (Codegen), GoRouter.
-   **Developer Commands:**
    -   `flutter pub get`
    -   `dart run build_runner build --delete-conflicting-outputs`
    -   `flutter run`
-   **Build:** `flutter build apk`
-   **Project Structure:** Brief overview of `lib/core`, `lib/features`, and `graphql/`.

## Section 5: Project Documentation
-   Maintain links to detailed internal documentation:
    -   `docs/README.md`
    -   `docs/AGENT_START_HERE.md`
    -   `docs/ARCHITECTURE_MAP.md`
    -   `docs/DEBUGGING_PLAYBOOK.md`
    -   `docs/KNOWNISSUES.md`

## Success Criteria
-   The README leads with a high-impact value proposition.
-   Features are easily scannable and visually appealing.
-   The "Quick Start" guide is clear and non-technical for end-users.
-   Technical details are present but secondary to the user experience.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
