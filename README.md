# 📱 StashFlow
### Your Stash library, everywhere.

A native Android mobile client for your **Stash** server. Designed for seamless browsing, effortless discovery, and high-quality playback on the go.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.4.3-green.svg)](pubspec.yaml)

## 📸 Screenshots

<p align="center">
	<img src="asset/scenes.jpg" alt="Scenes feed" width="280" />
	<img src="asset/scene_details.jpg" alt="Scene details playback" width="280" />
</p>

## ✨ Key Features

- 📱 **Adaptive UI:** Fully optimized for both phones and tablets. Features a side **Navigation Rail** and expanded grid layouts (up to 5 columns) on larger screens.
- 🎬 **Seamless Playback:** Integrated video player with support for multiple streaming strategies, startup diagnostics, and **Autoplay Next**.
- 🎵 **System Integration:** Full support for `audio_service` (media notifications/lock screen controls) and **Picture-in-Picture (PiP)** mode.
- 👤 **Rich Browsing:** Explore Scenes, Performers, Studios, Tags, Galleries, and Groups with native-feel pagination and fast search.
- 📱 **Flexible Layouts:** Choose between a classic **Grid/List** view or a modern **TikTok-style** vertical scroll layout for discovery.
- 🎲 **Discovery Tools:** Floating "Random" actions and "Surprise Me" entries to find hidden gems in your library.
- 🔍 **Advanced Filtering:** Powerful menu-based sorting (Date, Rating, Play Count, Random) and multi-filter sheets.
- 🛠️ **Native Customization:** Configure your server connection, UI preferences, and streaming quality in one place.
-  **Scene Details Editor** Metadata editing & scraping.

> [!IMPORTANT]
> **TikTok Layout (WIP):** The vertical scroll (TikTok-style) layout is currently in active development. You may encounter stability issues with scene ratings or entering/exiting fullscreen playback directly from this view. Refinements are ongoing.

## 🚀 Getting Started

1. **Download:** Grab the latest APK from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. **Connect:** Open the app ➔ Settings ➔ Enter your **Server URL** and **API Key**.
3. **Browse:** Your library will automatically sync and be ready for action.

### ⚙️ Runtime Settings
Tailor your experience in the app settings:
- `server_base_url` & `server_api_key`: Connection details.
- `prefer_scene_streams`: Toggle between direct file paths and scene-specific stream resolution.
- `scene_layout_mode`: Switch between **Grid** and **TikTok** view.
- `autoplay_next`: Enable continuous playback in details and TikTok views.
- `video_background_playback`: Continue audio when app is minimized.
- `video_native_pip`: Enable auto-PiP on Android.

---

## 🤓 For Developers

### Tech Stack
- **Flutter** & **GoRouter**
- **Riverpod** & **Hooks** (State Management)
- **GraphQL** (`graphql_flutter` + `codegen`)
- **Video Player** + **Audio Service** (Native-feel playback)

### Project Structure
- `lib/core` shared infrastructure (theme, logs, providers)
- `lib/features/*` feature modules (domain/data/presentation)
- `graphql/` schema and GraphQL documents for code generation

### Development
```bash
# Get dependencies
flutter pub get

# Regenerate code (GraphQL & Notifiers)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

### Build
```bash
flutter build apk
```


## 📚 Internal Docs
For architecture, known issues, and onboarding, see:
- [Documentation Index](docs/GEMINI.md)
- [Developer Guide](docs/DEVELOPER_GUIDE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Roadmap](docs/ROADMAP.md)
- [Hosted documentation (Live)](https://alchemist-aloha.github.io/StashFlow/) — Official hosted docs and API reference.
