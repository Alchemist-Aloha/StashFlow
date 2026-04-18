# Validation

## Commands
- **L10n**: `flutter gen-l10n`
- **Analyze**: `flutter analyze`
- **Tests**: `flutter test`
- **Build Runner**: `dart run build_runner build --delete-conflicting-outputs`

## Constraints
- **Null Safety**: All code must be sound null-safe.
- **Key Parity**: ARB files must maintain key parity with `app_en.arb`.
- **Formatting**: Adhere to `flutter_lints` and `analysis_options.yaml`.
- **Codegen**: Generated files should not be committed (per `.gitignore`).
