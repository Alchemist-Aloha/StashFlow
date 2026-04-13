# Building from Source

This guide explains how to build StashFlow from source for any supported platform.

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | ≥ 3.11.0 | Includes Dart SDK |
| [Android Studio](https://developer.android.com/studio) or Xcode | latest | Required for Android / macOS / iOS builds |
| [Git](https://git-scm.com/) | any | |

Verify your Flutter setup with:

```bash
flutter doctor
```

All required components must show a green checkmark for the platform you are targeting.

---

## Clone the Repository

```bash
git clone https://github.com/Alchemist-Aloha/StashFlow.git
cd StashFlow
```

---

## Install Dependencies

```bash
flutter pub get
```

---

## Code Generation

StashFlow uses `build_runner` to generate GraphQL query classes, Riverpod providers, and Freezed data classes.  
Run this once after cloning, and again whenever you change `.graphql`, `.dart` model, or provider files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Run in Development

```bash
# Default device (connected phone or emulator / desktop window)
flutter run

# Explicit platform
flutter run -d android
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run -d chrome        # Web (debug mode)
```

---

## Build for Release

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

For a split-per-ABI build (smaller file sizes):

```bash
flutter build apk --split-per-abi --release
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

> **Signing:** To publish a signed build you need a keystore. See the [Flutter deployment guide](https://docs.flutter.dev/deployment/android) for instructions.

### Windows

```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

Zip the entire `Release/` folder for distribution.

### macOS

```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/stash_app_flutter.app
```

### Linux

```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

Tar the `bundle/` directory for distribution.

### Web

```bash
flutter build web --release
# Output: build/web/
```

Deploy the `build/web/` directory to any static web host (GitHub Pages, Netlify, etc.).

---

## Regenerating the App Icon

The launcher icon is generated from `asset/stashfluttericon.png`:

```bash
dart run flutter_launcher_icons
```

---

## Project Structure

```
StashFlow/
├── lib/
│   ├── core/           # Shared infrastructure (theme, logging, providers)
│   └── features/       # Feature modules
│       ├── scenes/     # Video browsing & playback
│       ├── images/     # Image viewer & galleries
│       ├── performers/ # Performer pages
│       ├── studios/    # Studio pages
│       ├── tags/       # Tag pages
│       ├── groups/     # Group pages
│       ├── navigation/ # Shell, router, mini-player
│       └── setup/      # Settings & server configuration
├── graphql/            # GraphQL schema and query documents
├── test/               # Unit tests
├── android/            # Android host project
├── windows/            # Windows host project
├── macos/              # macOS host project
├── linux/              # Linux host project
└── web/                # Web host project
```

---

## Running Tests

```bash
flutter test
```

---

## Linting

```bash
flutter analyze
```

Linting rules are defined in `analysis_options.yaml`. Generated files (`*.g.dart`, `*.freezed.dart`, `*.graphql.dart`) are excluded from analysis.
