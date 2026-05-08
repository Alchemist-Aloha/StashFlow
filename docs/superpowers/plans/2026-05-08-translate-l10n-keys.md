# Translate L10n Keys Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Translate 12 missing keys across 10 target languages in `scripts/apply_translations.py` and apply them to the project's `.arb` files.

**Architecture:** Update the `translations` dictionary in `scripts/apply_translations.py` with the new keys and their translations, then run the script to propagate the changes.

**Tech Stack:** Python, JSON, ARB (Flutter Localization)

---

### Task 1: Update `scripts/apply_translations.py`

**Files:**
- Modify: `scripts/apply_translations.py`

- [ ] **Step 1: Add new translations to the `translations` dictionary**

Update the `translations` object for each language (`de`, `es`, `fr`, `it`, `ja`, `ko`, `ru`, `zh`) with the following keys:
- `filter_group_general`
- `filter_group_performer`
- `filter_group_library`
- `filter_group_metadata`
- `filter_group_media_info`
- `filter_group_usage`
- `filter_group_system`
- `filter_group_physical`
- `settings_storage`
- `settings_storage_usage`
- `settings_storage_usage_subtitle`
- `settings_storage_subtitle`

- [ ] **Step 2: Commit changes to the script**

```bash
git add scripts/apply_translations.py
git commit -m "chore: add missing translations to apply_translations.py"
```

### Task 2: Apply Translations

**Files:**
- Modify: `lib/l10n/*.arb` (multiple files)
- Modify: `l10n_untranslated.json`

- [ ] **Step 1: Run the translation application script**

Run: `python3 scripts/apply_translations.py`
Expected: Output showing updates for `app_de.arb`, `app_es.arb`, etc.

- [ ] **Step 2: Verify `.arb` files are updated**

Check one or two `.arb` files (e.g., `lib/l10n/app_de.arb`) to ensure the new keys are present.

- [ ] **Step 3: Clear `l10n_untranslated.json`**

Since all reported keys are now translated, reset `l10n_untranslated.json` to an empty object or remove the translated keys.

- [ ] **Step 4: Commit changes to `.arb` files**

```bash
git add lib/l10n/*.arb l10n_untranslated.json
git commit -m "l10n: apply missing translations to all locales"
```

### Task 3: Final Verification

- [ ] **Step 1: Run the check script**

Run: `cd scripts && python3 find_untranslated_arbs.py`
Expected: `build/untranslated_report.json` should show no missing keys for the updated locales.

- [ ] **Step 2: Final commit if any report files changed**
