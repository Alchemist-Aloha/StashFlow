# Docs Index — Agent Reference

Short, action-oriented guidance for agents working in this repository.

## Quick Rules

- **Localization:** Never ship plain strings; use ARB keys and run `flutter gen-l10n` after edits.
- **Docs:** Add docstrings for new providers, widgets, and public APIs.
- **Verify:** Run `flutter build apk --split-per-abi` or project tests after UI/logic changes.
- **Design:** Follow Material 3 expressive patterns (consistent spacing, soft shapes, readable type).

## Localization (l10n) — Essentials

- Files: [lib/l10n/](lib/l10n/)
- Target locales: de, es, fr, it, ja, ko, ru, zh, zh_Hans, zh_Hant.
- Preserve placeholders (e.g., {count}, {error}) exactly.
- Use `scripts/apply_translations.py` and `scripts/check_translations.py` to help validation.

## Recent Design Briefs (high priority)

- Settings UI (Material 3 Expressive): replace `DropdownButton` with bottom sheets, sliders, and `MenuAnchor` status-pills; increase radii and spacing; add subtle press animation. See: [lib/features/setup/presentation/widgets/settings_page_shell.dart](lib/features/setup/presentation/widgets/settings_page_shell.dart#L1).
- Simplify server URL input: prefer base URL (no `/graphql`) — update ARB keys and `server_profile_drawer.dart` hint text. See: [lib/features/setup/presentation/widgets/server_profile_drawer.dart](lib/features/setup/presentation/widgets/server_profile_drawer.dart#L1).
- SceneCard enhancements: add thumbnail metadata overlay, desktop hover scrubbing, and configurable performer-avatar row (`maxPerformerAvatars`). See: [lib/features/scenes/presentation/widgets/scene_card.dart](lib/features/scenes/presentation/widgets/scene_card.dart#L1).

## Actionable Checklist for Implementers/Agents

- Update ARB keys and run `flutter gen-l10n`.
- Replace remaining dropdowns in settings pages with bottom sheets / sliders / menu anchors.
- Add `maxPerformerAvatars` provider and implement avatar row + hover scrubbing with platform checks.
- Run `flutter build` and relevant tests; fix layout/localization regressions.

References: `docs/superpowers/specs/` (2026-04-25 → 2026-04-28).
