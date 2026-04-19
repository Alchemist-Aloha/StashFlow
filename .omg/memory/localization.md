# Localization (l10n) Process

## Goal
Ensure Flutter app's `.arb` files (under `lib/l10n/`) cover all UI text by automatically translating entries that match the English source.

## Instructions & Decisions
- **Target Locales**: `de`, `es`, `fr`, `it`, `ja`, `ko`, `ru`, `zh`, `zh_Hans`, `zh_Hant`.
- **Exclusions**: `appTitle`, `ID`, and `URL` fields should remain UNCHANGED.
- **Web UI (Out-of-Scope)**: Do not touch `stash/ui/v2.5/src/locales/` unless explicitly requested.
- **Preservation**: Always keep placeholders like `{error}`, `{count}`, `{message}` exactly as they appear in the English source.

## Files & Directories
- **Source**: `lib/l10n/app_en.arb`
- **Targets**: `lib/l10n/app_<locale>.arb`
- **Configuration**: `l10n.yaml`
- **Generated Code**: `lib/l10n/app_localizations*.dart` (Must be regenerated after `.arb` changes via `flutter gen-l10n`).

## Helper Tools
- `scripts/apply_translations.py`: Automated tool for inserting translations into ARB files.
- `scripts/check_translations.py`: Verifies coverage and consistency against English source.
- `l10n_untranslated.json`: Tracks missing or mismatching keys for batch translation.
