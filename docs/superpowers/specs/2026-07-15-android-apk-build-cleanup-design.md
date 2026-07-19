# Android APK Build Cleanup

## Goal

Improve Android release correctness and shrinking without changing application features.

## Changes

1. Remove the English-only Android resource configuration. Android and plugin resources will retain every locale supplied by their dependencies, avoiding a manually maintained locale list that can drift from Flutter's supported locales.
2. Remove `WRITE_EXTERNAL_STORAGE` and `requestLegacyExternalStorage`. Gallery writes will continue through the existing `gal` package and modern Android media APIs.
3. Remove the broad ProGuard rules that retain all Flutter plugin and AudioService classes. Manifest entry points and dependency consumer rules will remain responsible for preserving required native classes. Source/line metadata and Kotlin metadata rules will remain.

## Validation

- Add a focused repository test that asserts the obsolete resource filter, storage declarations, and broad keep rules are absent.
- Demonstrate that the test fails against the current configuration before applying production changes.
- Run the focused test after the changes.
- Run Android unit tests and build split release APKs.
- Inspect the merged release manifest to confirm the legacy storage declarations are absent.
- Verify APK signing and 16 KB ZIP alignment.
- Compare release APK sizes with the existing 39 MB arm64, 36 MB armeabi-v7a, and 44 MB x86_64 baselines.

## Scope

The change does not alter cleartext networking, `WRITE_SETTINGS`, media playback dependencies, ABI support, signing credentials, or distribution formats.
