# Design Spec: Multi-Language Localization Support

## 1. Overview
StashFlow currently has hardcoded English strings throughout the UI. This project adds full localization support using Flutter's recommended `gen-l10n` tool, supporting 10 languages/variants: English, Spanish, Simplified Chinese, Traditional Chinese, Japanese, Korean, French, Italian, German, and Russian.

## 2. Architecture & Configuration

### Dependencies
- `flutter_localizations` (Flutter SDK)
- `intl` (for date/number/plural formatting)

### Project Setup
- `pubspec.yaml`: Set `generate: true` under `flutter:`.
- `l10n.yaml`: Root configuration file.
    ```yaml
    arb-dir: lib/l10n
    template-arb-file: app_en.arb
    output-localization-file: app_localizations.dart
    ```

### Supported Locales
1.  **English (en)** - Base template
2.  **Spanish (es)**
3.  **Chinese - Simplified (zh_Hans)**
4.  **Chinese - Traditional (zh_Hant)**
5.  **Japanese (ja)**
6.  **Korean (ko)**
7.  **French (fr)**
8.  **Italian (it)**
9.  **German (de)**
10. **Russian (ru)**

## 3. Implementation Details

### Resource Management
- All strings will be moved to `lib/l10n/app_en.arb`.
- Descriptive keys will be used (e.g., `features_tags_title`).
- ICU syntax will be used for plurals and placeholders.

### Integration
- **MaterialApp.router** update:
    ```dart
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    ```
- **Context Extension**: A helper extension in `lib/core/utils/l10n_extensions.dart` (or similar) will allow concise access:
    ```dart
    extension L10nX on BuildContext {
      AppLocalizations get l10n => AppLocalizations.of(this)!;
    }
    ```
- **Usage**: `context.l10n.keyName`

## 4. Migration Strategy

### Extraction
- Systematic scan of `lib/` for hardcoded strings.
- Automated and manual replacement with `context.l10n.<key>`.

### Translation
- AI-generated translations for all 9 additional locales based on the English template.
- Respecting context-specific meanings for technical terms (e.g., "Scenes", "Performers").

## 5. Testing & Validation
- Run `flutter gen-l10n` to verify ARB syntax.
- Verify UI rendering for long strings (e.g., German, Russian).
- Ensure script-specific fonts/layouts are respected for CJK languages.
