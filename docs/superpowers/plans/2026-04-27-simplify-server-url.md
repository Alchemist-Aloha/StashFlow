# Simplify Server URL Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Simplify server URL input by removing the need for a `/graphql` suffix while maintaining full backward compatibility.

**Architecture:** Update UI hints and localization strings to encourage base URLs. The existing `normalizeGraphqlServerUrl` logic already handles both base URLs (by appending `/graphql`) and full endpoint URLs (by leaving them as-is), ensuring seamless migration.

**Tech Stack:** Flutter, Riverpod, Dart.

---

### Task 1: Verify URL Normalization Logic

**Files:**
- Modify: `lib/core/data/graphql/graphql_client.dart` (Self-review and test logic)
- Test: `test/url_normalization_test.dart` (Create new test file)

- [ ] **Step 1: Write normalization tests**
Create `test/url_normalization_test.dart` to verify current behavior and ensure it handles migration cases (URLs with and without `/graphql`).

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';

void main() {
  group('normalizeGraphqlServerUrl', () {
    test('appends /graphql if missing', () {
      expect(normalizeGraphqlServerUrl('http://localhost:9999'), 'http://localhost:9999/graphql');
      expect(normalizeGraphqlServerUrl('192.168.1.100'), 'https://192.168.1.100/graphql');
    });

    test('preserves /graphql if already present (backward compatibility)', () {
      expect(normalizeGraphqlServerUrl('http://localhost:9999/graphql'), 'http://localhost:9999/graphql');
      expect(normalizeGraphqlServerUrl('http://localhost:9999/graphql/'), 'http://localhost:9999/graphql/');
    });

    test('handles path with trailing slash by appending graphql', () {
       expect(normalizeGraphqlServerUrl('http://localhost:9999/'), 'http://localhost:9999/graphql');
    });
  });
}
```

- [ ] **Step 2: Run tests to verify logic**
Run: `flutter test test/url_normalization_test.dart`
Expected: PASS (The logic in `lib/core/data/graphql/graphql_client.dart` should already support this).

- [ ] **Step 3: Commit**
```bash
git add test/url_normalization_test.dart
git commit -m "test: verify URL normalization logic for base and full URLs"
```

### Task 2: Update Localization Examples

**Files:**
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Update English localization**
Modify `lib/l10n/app_en.arb` to show base URL examples.

```json
  "settings_server_url_helper": "Example format: http(s)://host:port.",
  "settings_server_url_example": "http://192.168.1.100:9999",
```

- [ ] **Step 2: Commit**
```bash
git add lib/l10n/app_en.arb
git commit -m "docs(l10n): update server URL helper and example to use base URL"
```

### Task 3: Propagate Localization Changes

**Files:**
- Modify: All `lib/l10n/app_*.arb` files

- [ ] **Step 1: Run translation application script**
Run the existing project script to propagate changes from `app_en.arb` to other locales. If automated propagation fails for these specific strings, manually update them.

Run: `python3 scripts/apply_translations.py` (Assuming this script handles propagation/auto-translation).

- [ ] **Step 2: Verify and regenerate localizations**
Run: `flutter gen-l10n`
Expected: Success.

- [ ] **Step 3: Commit**
```bash
git add lib/l10n/
git commit -m "docs(l10n): propagate server URL example changes to all locales"
```

### Task 4: Update UI Drawer

**Files:**
- Modify: `lib/features/setup/presentation/widgets/server_profile_drawer.dart`

- [ ] **Step 1: Use localized hint text**
Replace hardcoded hint with the localized example.

```dart
// lib/features/setup/presentation/widgets/server_profile_drawer.dart:187
TextFormField(
  controller: _urlController,
  decoration: InputDecoration(
    labelText: l10n.common_url,
    hintText: l10n.settings_server_url_example, // Changed from hardcoded 'http://localhost:9999/graphql'
    border: const OutlineInputBorder(),
  ),
  // ...
),
```

- [ ] **Step 2: Commit**
```bash
git add lib/features/setup/presentation/widgets/server_profile_drawer.dart
git commit -m "style(ui): use localized server URL hint in profile drawer"
```

### Task 5: Final Verification

- [ ] **Step 1: Build check**
Run: `flutter build apk --split-per-abi`
Expected: Success.

- [ ] **Step 2: Manual validation**
Verify that existing profiles (with `/graphql`) still connect and that new profiles work with just the base URL.
