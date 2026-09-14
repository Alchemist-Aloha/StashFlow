# StashFlow Agent Guide

Repository-specific instructions for agents working in this checkout.

## Scope and Precedence

- This file applies to the repository root and all nested paths unless a closer
  `AGENTS.md` or `AGENTS.override.md` provides more specific guidance.
- Explicit user instructions take precedence over this file and any skill.
- Parent/global agent instructions still apply; this file adds StashFlow-specific
  rules.
- [`docs/SPECS.md`](docs/SPECS.md) is the source of truth for current product,
  architecture, design, and verification contracts. Current code wins when a
  path or symbol has moved; intentional behavior changes must update the owning
  specification section.
- Release notes and audits are historical evidence, not current requirements.

## Working Agreement

- Proceed with reversible, in-scope work without unnecessary clarification. Ask
  only when a missing choice would materially change behavior, scope, or risk.
- Before editing, inspect `git status`, the relevant specification section, the
  real code path, its callers, and nearby tests.
- Preserve unrelated worktree changes. Never discard, overwrite, or reformat
  unrelated files.
- Use the current `dev` checkout directly. Do not create another worktree unless
  the user explicitly requests one.
- Prefer the smallest repository-native change that fixes the shared root cause.
  Reuse existing helpers and dependencies before adding abstractions or packages.
- Keep backlog items, migration narratives, and one-off investigations in issues
  or pull requests, not in this file or `docs/SPECS.md`.
- The ignored `stash/` directory contains the official Stash project for
  reference. Do not edit it.

## Authored and Generated Files

- Do not hand-edit generated Dart files, including `*.g.dart`, `*.freezed.dart`,
  `*.graphql.dart`, `*.mocks.dart`, or `lib/l10n/app_localizations*.dart`.
- After GraphQL, Freezed, Riverpod generator, serialization, or mock changes, run:

  ```bash
  rtk dart run build_runner build --delete-conflicting-outputs
  ```

- After ARB changes, run `rtk flutter gen-l10n` and inspect all generated and
  authored changes before continuing.

## Repository Contracts

- Localize every user-visible string through ARB files under `lib/l10n/`.
  Maintain de, es, fr, it, ja, ko, ru, zh_Hans, and zh_Hant; keep the base
  `app_zh.arb` fallback aligned, and preserve placeholders exactly.
- Run `rtk python3 scripts/analyze_translations.py` and
  `rtk python3 scripts/check_translations.py` after localization changes; review
  their output because these scripts report findings without failing the command.
- Follow the Material 3, responsive-layout, dynamic-scaling, and accessibility
  contracts in `docs/SPECS.md`. Use `context.dimensions` for scalable layout
  values and verify supported scale extremes.
- Document new public APIs and non-obvious ownership or lifecycle contracts.
  Avoid comments that merely restate the code.

## Verification

Match verification to the change, run focused checks first, and do not repeat
broad checks unless later edits or failures justify it.

- Documentation-only changes: verify touched links and paths, then run
  `rtk git diff --check`.
- Dart changes: run `rtk dart format <changed-dart-files>`, the narrowest relevant
  test, `rtk flutter analyze`, and `rtk git diff --check`.
- Shared state, navigation, playback, persistence, or cross-feature changes: run
  the full `rtk flutter test` suite after focused tests pass.
- Localization changes: also run generation and both translation checks above.
- Platform-specific changes: run the relevant host tests or manual acceptance
  pass when the current host supports them.
- Android, native-player, Gradle, manifest, dependency-packaging, and release
  changes require `rtk flutter build apk --split-per-abi`; verify all three APKs
  exist.
- If an applicable check cannot run, report the exact gap. A successful build
  does not prove device, browser, remote-CI, or native runtime behavior.

## Release Notes

- Name the file for the target version, for example `update1330.md` for
  `v1.33.0`, and use `# StashFlow vX.Y.Z` as the title.
- Before drafting, inspect `git status`, the nearest existing update notes, and
  the actual previous-release-tag-to-`HEAD` range. Do not infer the release from
  only the latest commits or from uncommitted worktree changes.
- Start with `rtk git diff --stat <previous-tag>..HEAD` and
  `rtk git log --no-merges <previous-tag>..HEAD`, then inspect targeted diffs for
  the largest user-facing areas.
- Group changes by user-visible outcome under short `##` sections with relevant
  emoji, following the newest notes in `docs/update/`. Omit empty categories.
- Write concise bullets in plain language. Cover meaningful features, fixes,
  compatibility, performance, and packaging changes a user would recognize.
  Combine related commits into one outcome.
- Exclude commit hashes, commit-by-commit narration, raw file churn, internal
  refactors without user impact, speculative claims, and verification that did
  not run.
- Unless requested, edit only the update-note file; do not change package
  versions, locks, tags, or release configuration.
- Documentation-only release-note work does not require an application build.
  Verify the selected range, changed-file scope, final Markdown, and
  `rtk git diff --check`.

## Reviews and Handoffs

- For reviews, report actionable findings first, ordered by severity, with file
  and line references. Prioritize correctness, security, data loss, regressions,
  and missing meaningful coverage.
- If no findings remain, say so and identify any unverified runtime or platform
  risk.
- Final handoffs must state what changed, which checks passed, and what remains
  unverified. Do not imply that an unrun check passed.
