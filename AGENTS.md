# Docs Index — Agent Reference

Short, action-oriented guidance for agents working in this repository.

## Worktree preference

Use the current `dev` branch directly by default. Do not create an isolated
worktree unless the user explicitly requests one for a task.

## Quick Rules

- **Localization:** Never ship plain strings; use ARB keys and run `flutter gen-l10n` after edits.
- **Docs:** Add docstrings for new providers, widgets, and public APIs.
- **Verify:** Run `flutter build apk --split-per-abi` or project tests after UI/logic changes.
- **Design:** Follow Material 3 expressive patterns (consistent spacing, soft shapes, readable type).
- **branch** Work in dev branch, not main or worktree branches.

## Release Notes

- When drafting `docs/update/updateNNNN.md`, start from the real tag diff between the target release tag and `HEAD`.
- Use `git diff --stat <tag>..HEAD` first, then inspect targeted file diffs for the biggest user-facing areas.
- Group entries by user-visible behavior, not by commit list or raw file churn.
- Match the existing update-note style in `docs/update/`:
  - short release title
  - sectioned markdown
  - concise bullets
  - plain language
- Prefer concrete outcomes and feature names the user can recognize in the app.
- Avoid dumping full diff output, commit hashes, or implementation trivia unless it directly explains a user-facing change.

## Localization (l10n) — Essentials

- Files: [lib/l10n/](lib/l10n/)
- Target locales: de, es, fr, it, ja, ko, ru, zh, zh_Hans, zh_Hant.
- Preserve placeholders (e.g., {count}, {error}) exactly.
- Use `scripts/apply_translations.py` and `scripts/check_translations.py` to help validation.

## Design Specifications

- **Single source of truth:** [SPECS.md](SPECS.md) — all design specs in one categorized file.
- **No individual spec files:** The old `docs/superpowers/specs/` directory has been removed.
- **Finding a spec:** Browse the category index at the top of `SPECS.md`; the file describes current contracts, while implementation history belongs in Git.
- **Updating specs:** Edit the owning category instead of adding a dated duplicate. Keep goals, invariants, ownership, and verification guidance; put migration plans and change narratives in issues or pull requests.

## Dynamic UI Scaling — Standards

- **Core Rule:** NEVER use hardcoded spacing (e.g., `EdgeInsets.all(16)`) or static `AppTheme` constants for layout dimensions.
- **Access:** Use `context.dimensions.spacingSmall/Medium/Large` for all padding, margins, and gaps.
- **Scaling:** All dimensions must scale with `context.dimensions.fontSizeFactor` (controlled by the global UI size slider).
- **Component Sizes:** Use `context.dimensions.buttonHeight` and scale manual icon sizes by multiplying with `context.dimensions.fontSizeFactor`.
- **Implementation:** When adding new UI, ensure `AppDimensions` is supported and the widget tree is responsive to theme changes.

## Actionable Checklist for Implementers/Agents

- Update ARB keys and run `flutter gen-l10n`.
- Replace remaining dropdowns in settings pages with bottom sheets / sliders / menu anchors.
- Run `flutter build apk --split-per-abi` and relevant tests; fix layout/localization regressions.

References: [`SPECS.md`](SPECS.md) (combined spec document).
