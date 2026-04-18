## For agents

Don't use plain string in UI. Generate i10n key instead for multi language support.
Generate detailed docstring with the code.
run flutter build apk --release split-per-abi after each job to verify no error in the code.
Keep UI modern Material 3 style
---
## Goal
Ensure the Flutter app’s localization (lib/l10n/*.arb) covers all UI text by automatically translating entries that are still in English (per the user's preference), and prepare those changes so they can be applied, verified, and committed.
## Instructions
- User choices to honor:
  - Work only on Flutter ARB files under lib/l10n (do not touch web UI JSON locales under stash/ui/v2.5 unless later requested).
  - Skip translating appTitle, ID and URL fields (leave product name, identifiers, and URL tokens unchanged).
  - Use automatic (machine) translation for entries whose values exactly match the English source.
  - After generating translations, update the ARB files and present diffs for review.
- Plan/spec:
  1. Detect keys where locale value == English value (candidates for auto-translation).
  2. Replace those values with machine translations per language (preserve placeholders like {error}, {count}, etc).
  3. Prepare an applyable patch with the updated ARB files (do not commit until verified).
  4. Verify with formatting, analyzer/linter, and the Flutter localization generator.
  5. Run quick tests / spot-checks and then commit.
## Discoveries
- Locale sources:
  - Flutter ARB files live under lib/l10n (app_en.arb, app_fr.arb, app_de.arb, app_it.arb, app_ja.arb, app_ko.arb, app_ru.arb, app_zh.arb, app_zh_Hans.arb, app_zh_Hant.arb, app_es.arb, etc).
  - There are generated localization files in lib/l10n (app_localizations_*.dart) present in the tree — the project uses Flutter-style localization generation.
  - Web UI locales are under stash/ui/v2.5/src/locales (many JSONs). These were scanned but user opted out of changing them.
- Reports found:
  - l10n_key_diff_report.json and l10n_duplicates_report.json exist; an earlier report showed missing keys, but after re-checking the ARB files they currently all share the same set of keys (the ARB key set is consistent).
- Candidate keys:
  - A focused set of keys were selected to translate when their values matched English. These include (full list):
    nav_studios, nav_tags, sort_name, common_pause, common_version, common_details, common_name, details_tags, details_links, studios_title, settings_server, settings_support, settings_appearance_theme_system, settings_interface_navigation, settings_interface_swipe_horizontal, settings_support_title, settings_support_version, common_error, settings_interface_swipe_vertical, settings_interface_swipe_horizontal, common_direction, common_date, details_synopsis, details_media, settings_server_password.
- Languages targeted for auto-translation:
  - de, es, fr, it, ja, ko, ru, zh, zh_Hans, zh_Hant (the code prepared translations for these).
- Work done so far (intermediate):
  - Wrote a small script to detect English-equal keys and built a translation mapping (values chosen programmatically).
  - Built an apply-style patch (saved as /tmp/patch.txt) containing intended updates for 10 ARB files (one per targeted locale). The patch file includes "Update File: lib/l10n/app_<lang>.arb" sections with the new content. The patch is prepared but NOT yet applied to the repository.
  - There was an earlier attempt that hit a NameError while trying to apply a patch; that was fixed and a patch was generated successfully and saved to /tmp/patch.txt.
- Important verification note:
  - Placeholders like {message}, {error}, {count} were intended to be preserved; the translation script used mapping by English source strings to ensure placeholders were retained in the translated strings. Still, spot-check placeholders after applying patch.
## Accomplished
- Completed:
  - Scanned repository and identified localization files and supporting reports.
  - Verified that Flutter ARB files contain the full key set (no missing keys vs app_en.arb).
  - Produced machine translations for the candidate keys for 10 target locales.
  - Prepared an on-disk patch at /tmp/patch.txt containing updates for the ARB files (10 files).
- Not yet done / remaining:
  1. Apply the prepared patch to the repo (the changes are prepared but not applied).
  2. Run formatting and static checks (dart/Flutter format & analyzer).
  3. Run Flutter localization codegen (flutter gen-l10n or the repo’s configured generator) so generated Dart localization sources are up to date.
  4. Smoke-test / run a small subset of the app (or unit tests) to ensure no runtime issues due to changed strings.
  5. Human review of translations (recommended) — machine translations are useful but should be reviewed for domain accuracy and context.
  6. Commit the changes with a clear commit message and push to a branch, then create a PR for human review.
## Relevant files / directories
- Workarea (Flutter localization)
  - lib/l10n/ (primary)
    - app_en.arb (master English)
    - app_de.arb, app_es.arb, app_fr.arb, app_it.arb, app_ja.arb, app_ko.arb, app_ru.arb, app_zh.arb, app_zh_Hans.arb, app_zh_Hant.arb, ... (locale ARB files)
    - app_localizations.dart and app_localizations_*.dart (generated localization Dart sources; regenerate after ARB changes)
  - l10n.yaml (project l10n config — used by Flutter gen-l10n if configured)
  - pubspec.yaml (root; run flutter pub get here)
- Reports and helper files
  - l10n_key_diff_report.json (report generated earlier — out of date but useful history)
  - l10n_duplicates_report.json (duplicate key report)
- Prepared patch
  - /tmp/patch.txt — contains the prepared apply-style patch (Update File: lib/l10n/app_*.arb sections). This file was generated by the assistant and contains the intended updated ARB contents (10 files). It has not been applied yet.
- Larger but out-of-scope for this pass
  - stash/ui/v2.5/src/locales/ (web UI locale JSON files — many). These are large and were intentionally not modified per the user’s instruction.
## Exact "next steps" for the agent continuing this work (actionable checklist)
1. Review /tmp/patch.txt contents (open and inspect the Update sections). If anything looks wrong in translations or placeholder placement, edit the relevant ARB manually.
2. Apply the patch:
   - Preferred: Use the repo’s apply_patch helper (the environment’s apply_patch function) with the prepared patch content.
   - Alternative manual approach:
     - For each updated file in /tmp/patch.txt, replace its counterpart under lib/l10n with the prepared content.
3. Run repo formatting & dependency steps:
   - flutter pub get
   - dart format . (or flutter format .)
4. Regenerate localization code:
   - If the repo uses Flutter’s built-in gen-l10n: flutter gen-l10n
   - If the repo uses another flow, inspect l10n.yaml or build scripts to run the correct command. (Confirm which generator is configured before running.)
5. Static checks and quick tests:
   - dart analyze (or flutter analyze)
   - flutter test (or run a small subset of tests to sanity-check)
6. Manual verification:
   - Open a small localized screen or run the app in a locale to confirm translations render properly and placeholders remain intact.
7. Commit & PR:
   - git add lib/l10n/*.arb and any generated Dart localization files that are tracked (if generator produces new files tracked by repo).
   - git commit -m "l10n: auto-translate English-equal ARB strings for <languages>; skip appTitle/ID/URL"
   - Push to branch and open PR for human translation review.
8. (Optional follow-up) If the team wants web locale JSONs updated as well, prepare a separate plan and target small batches; those JSON files are large and follow different structure — do not bulk-apply translations without a review step.
## Gotchas / Things an agent would likely miss
- There are two distinct localization surfaces: Flutter ARB files (lib/l10n) and web JSON locales (stash/ui/v2.5/src/locales). The user explicitly asked to only modify the Flutter ARB files — do not touch the web JSONs unless given permission.
- appTitle, IDs and URL tokens should remain unchanged — they are intentionally skipped even when they match English.
- Always preserve placeholders (curly-brace tokens) exactly; translation code attempted to do so, but human review is still required.
- The generated Dart localization files need regeneration after ARB edits (forgetting this leaves build/test failures).
- A prepared patch exists at /tmp/patch.txt but was not applied — do not assume the repo was mutated.