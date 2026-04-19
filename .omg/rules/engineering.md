---
description: General Flutter engineering and UI standards for StashFlow.
alwaysApply: true
---

# Engineering Standards

- **Localization**: NEVER use plain strings in UI. ALWAYS generate/use an i10n key in ARB files for multi-language support.
- **Documentation**: Generate detailed docstrings for all new code, especially providers, widgets, and data models.
- **Verification**: Run `flutter build apk --release --split-per-abi` after each significant job to ensure no compilation or tree-shaking errors.
- **UI/UX**: Adhere strictly to modern **Material 3** design principles (consistent spacing, color palettes, and component usage).
