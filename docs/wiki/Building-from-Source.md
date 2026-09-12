# Building from Source

This guide explains how to build StashFlow from source for any supported platform.

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | stable channel | Bundles the Dart SDK |
| Dart SDK | `^3.11.0` | Declared in `pubspec.yaml` |
| [Android Studio](https://developer.android.com/studio) | latest | Android SDK; StashFlow targets API 24+ |
| [Xcode](https://developer.apple.com/xcode/) | latest | macOS builds only |
| [Git](https://git-scm.com/) | any | |

Verify your toolchain:

```bash
flutter doctor -v
```

All components for your target platform must show a green checkmark.

### Linux build dependencies

Linux desktop builds additionally need GTK and media libraries. On Debian/Ubuntu:

```bash
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev libsecret-1-dev libmpv-dev \
  libavcodec-dev libavformat-dev libavutil-dev libswresample-dev
```

Packaging `.deb`, `.AppImage`, and `.pkg.tar.zst` also needs `libarchive-tools`, `fakeroot`, and `zstd`.

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

While actively editing generated sources you can let it watch and rebuild:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Regenerating localizations

User-visible strings live in `lib/l10n/*.arb`. Regenerate the `AppLocalizations` classes after any ARB change:

```bash
flutter gen-l10n
```

Validate translations before committing:

```bash
python3 scripts/check_translations.py
python3 scripts/analyze_translations.py
```

See [Localization](#localization) below for the full workflow.

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
flutter build apk --release --split-per-abi
# Output: build/app/outputs/flutter-apk/app-<abi>-release.apk
#         (arm64-v8a, armeabi-v7a, x86_64)
```

The project's convention is `flutter build apk --split-per-abi` for release verification.

### Android App Bundle

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

> **Signing:** Release builds read credentials from `android/key.properties` and a keystore. See the
> [Flutter deployment guide](https://docs.flutter.dev/deployment/android) for setup.

### Windows

```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/StashFlow.exe (+ DLLs and data/)
```

Zip the entire `Release/` folder for a portable build.

### macOS

```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/StashFlow.app
```

Zip the `.app` bundle for distribution. The build is unsigned by default.

### Linux

```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/StashFlow (+ lib/ and data/)
```

Zip the `bundle/` directory for a portable build.

### Web

```bash
flutter build web --release --base-href /StashFlow/
# Output: build/web/
```

Deploy `build/web/` to any static host. The `--base-href` must match the path the app is served from
(GitHub Pages uses `/StashFlow/`; use `/` for a domain root).

---

## Packaging Native Installers

Release artifacts are produced from the release build output:

| Platform | Command / tool | Output |
|----------|----------------|--------|
| Windows | `fastforge package --platform windows --targets exe` (Inno Setup) | `StashFlow-<version>-windows-x64.exe` |
| Linux | `fastforge package --platform linux --targets deb,appimage` | `.deb`, `.AppImage` |
| Arch Linux | `scripts/build_linux_pacman.sh <version> <output-dir>` | `.pkg.tar.zst` |
| RPM | `scripts/build_linux_rpm.sh` | `dist/<version>/StashFlow-<version>-linux.rpm` |
| Windows Store | `dart run msix:create` (uses `msix_config` in `pubspec.yaml`) | `.msix` |

The RPM script builds the package directly with `rpmbuild` and rewrites `rpath`s to `$ORIGIN` with
`patchelf`, because `flutter_distributor`'s RPM maker is incompatible with RPM 6.

---

## Continuous Integration

GitHub Actions under `.github/workflows/` build and publish every platform:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `release.yml` | Tag push `v*` | Stable GitHub Release |
| `release-candidate.yml` | Push to `main` | Prerelease under the rolling `release-candidate` tag |
| `nightly-release.yml` | Push to `dev` | Nightly prerelease under the rolling `nightly` tag |
| `reusable-release.yml` | Called by the above | Build matrix: android, windows, linux, macos, web |

The matrix builds Android (split-per-ABI APKs), Windows (`.zip` + `.exe`), Linux (`.zip` + `.deb` +
`.AppImage` + `.pkg.tar.zst`), macOS (`.zip`), and Web (`.zip`, also deployed to GitHub Pages).
Artifacts follow the `StashFlow-<version>-<platform>[-<arch>].<ext>` naming convention.

---

## Localization

- ARB sources: `lib/l10n/app_<locale>.arb` (template: `app_en.arb`).
- Supported locales: `de, en, es, fr, it, ja, ko, ru, zh, zh_Hans, zh_Hant`.
- Configuration: `l10n.yaml`.

Workflow:

1. Add or edit keys in `app_en.arb`, preserving placeholders such as `{count}`.
2. Mirror the keys in every other ARB file.
3. Run `flutter gen-l10n`.
4. Validate with `python3 scripts/check_translations.py` and `python3 scripts/analyze_translations.py`.

Untranslated keys are reported to `l10n_untranslated.json`.

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
│   ├── main.dart
│   ├── core/           # Cross-feature infrastructure: theme, auth, data services, providers, utils
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── utils/
│   ├── features/       # Feature modules (domain / data / presentation layers)
│   │   ├── scenes/     # Scenes, player, markers, deduplication, tagger, editing
│   │   ├── images/     # Image lists and fullscreen viewer
│   │   ├── galleries/  # Gallery lists and details
│   │   ├── performers/ # Performer lists, details, editing
│   │   ├── studios/    # Studio lists, details, editing
│   │   ├── tags/       # Tag lists and details
│   │   ├── groups/     # Group lists and details
│   │   ├── navigation/ # Shell, router, mini-player
│   │   ├── setup/      # Server profiles, auth, settings pages
│   │   └── tools/      # Scene Deduplication and Scene Tagger entry points
│   └── l10n/           # ARB files and generated localizations
├── graphql/            # GraphQL schema and query documents
├── test/               # Unit, widget, and integration tests
├── scripts/            # Localization checks and Linux packaging scripts
├── docs/               # SPECS.md, performance audit, update notes, wiki sources
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

Linting rules are defined in `analysis_options.yaml`. Generated files (`*.g.dart`, `*.freezed.dart`,
`*.graphql.dart`, `lib/l10n/app_localizations*.dart`) are excluded from analysis.
