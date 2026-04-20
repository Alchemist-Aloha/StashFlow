# Deep Init Summary

## Objective
Translate and synchronize all ARB files for StashFlow v1.11.0.

## Architecture Boundaries
- **Core**: Shared utilities, domain models, and presentation helpers.
- **Features**: Feature-sliced architecture (Scenes, Performers, Studios, etc.).
- **L10n**: Centralized in `lib/l10n/` using `flutter_localizations`.

## High-Risk Zones
- **Generated Code**: `*.g.dart`, `*.freezed.dart`, `*.graphql.dart` are excluded from analysis but critical for runtime.
- **L10n Desync**: Manual edits to ARB files must be followed by `flutter gen-l10n`.
- **GraphQL Integration**: Codegen for combined schema and feature-specific documents.

## Build & Test Infrastructure
- **Build Runner**: Essential for Riverpod, Freezed, and JSON serialization.
- **L10n**: `flutter gen-l10n` driven by `l10n.yaml`.
- **Tests**: Mixed unit, widget, and integration tests in `test/`.
