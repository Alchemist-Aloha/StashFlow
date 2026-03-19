# Commands

## Daily development

```bash
flutter pub get
flutter analyze
flutter test
```

## Build APK

```bash
flutter build apk
```

## Fast smoke flow after UI/data changes

```bash
flutter analyze
flutter test
flutter build apk
```

## Regenerate code (when GraphQL/provider/model sources change)

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Helpful focused checks

```bash
flutter test test/scenes_page_mock_repo_test.dart
flutter test integration_test/core_flow_test.dart
```

## Optional cleanup and refresh

```bash
flutter clean
flutter pub get
```

## Suggested verification order for risky fixes

1. `flutter analyze`
2. Targeted tests if available
3. Full `flutter test`
4. `flutter build apk` for release-path validation

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [UIGUIDELINE.md](UIGUIDELINE.md) for current UI standards.
