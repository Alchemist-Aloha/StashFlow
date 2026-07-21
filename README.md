# 📱 StashFlow

## Your Stash library, everywhere

A modern, multi-platform client for your [**Stash server**](https://github.com/stashapp/stash). Built for fast browsing, playback, and library management across **Android**, **Desktop** (Windows, macOS, Linux), and the [**Web**](https://alchemist-aloha.github.io/StashFlow/).

The app is primarily tested on Android and Windows. The web build is best treated as a demo because browser restrictions limit authentication and playback behavior. For the full experience, use a native build.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.26.0-green.svg)](pubspec.yaml)

## 📸 Screenshots

<p align="center">
   <img src="asset/scenes.jpg" alt="Scenes feed" width="220" />
   <img src="asset/scene_details.jpg" alt="Scene details playback" width="220" />
   <img src="asset/edit_scene.jpg" alt="Scene details editor" width="220" />

</p>
<p align="center">
   <img src="asset/scene_filter.jpg" alt="Scenes filter" width="220" />
   <img src="asset/scene_sort.jpg" alt="Scenes sort" width="220" />
   <img src="asset/library_stats.jpg" alt="Library stats" width="220" />
</p>

## ✨ Key Features

- 📱 **Cross-platform** support for Android, desktop, and web.
- 🧭 **Flexible navigation** with customizable primary tabs and responsive layouts.
- 🎬 **Playback tools** including queue continuity, autoplay next, PiP, background audio, cast support, and subtitle controls.
- 🖼️ **Media browsing** for scenes, markers, images, galleries, performers, studios, tags, and groups.
- 🔎 **Filtering and sorting** with saved per-page defaults and server-side presets.
- 🛠️ **Editing and scraping** for scene metadata, entity associations, and match merging.
- ⚙️ **Settings coverage** for server profiles, interface, playback, storage, security, keybinds, and developer options.
- 🌐 **Localized UI** with multiple supported languages.

## 🚀 Getting Started

### 📱 Android

1. **Download:** Grab the latest APK from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. **Connect:** Open the app ➔ Settings ➔ Enter your credentials.

### 💻 Desktop (Windows, macOS, Linux)

1. **Download:** Download the appropriate installer for your OS from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. **Setup:** Install and launch ➔ Enter your credentials in Settings.

### 🌐 Web

1. **Access:** Visit the [Live Web App Demo](https://alchemist-aloha.github.io/StashFlow/) or host your own build.
2. **Note on Limitations:** The web version serves primarily as a **demo**.
   - **Authentication:** Only **API Key** login is supported due to browser CORS restrictions.
   - **Playback:** Video playback is limited by browser codec support.
   - **Recommendation:** Use the **Android** or **Desktop** versions for the complete feature set and optimal performance.

---

## 🤓 For Developers

### Build

Use the provided build script to check dependencies, generate code, and build for all available platforms:

```bash
./build.sh
# or on windows run:
./build.ps1
```

Or you can build the project manually for a specific platform:

```bash
# Get dependencies
flutter pub get

# Regenerate code (GraphQL & Notifiers)
dart run build_runner build

# Build flutter app
flutter build apk --debug --split-per-abi
flutter build windows --debug
flutter build linux --debug
```

## 📚 Internal Docs

For more info, see:

- [Project wiki page](https://github.com/Alchemist-Aloha/StashFlow/wiki)

## Star History

[![Star History Chart](https://api.star-history.com/chart?repos=Alchemist-Aloha/StashFlow&type=date&legend=top-left&sealed_token=-dM9LAAxJfmmhjKbl6dn9cJ3ez3GPvSQDOpcgDH7o2hb6TfhoVlEW-h9rPlJAkdrEI9-kWn9c-Z-fZ-5BtvxHJRvyti_DNHquqvrLqRAB4MI2MM4jpw3bQ)](https://www.star-history.com/?repos=Alchemist-Aloha%2FStashFlow&type=date&legend=top-left)
