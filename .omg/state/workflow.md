# Collaboration Protocol

## Classification
- **Critical Path**: Final UI smoke test, Version check, Commit readiness.
- **Sidecar**: Documentation cleanup (e.g., README.md screenshots).

## Execution Ordering
- **p0**: Ensure ARB translation passes `flutter gen-l10n`.
- **p1**: Verify app compiles without errors.
- **p2**: Review uncommitted changes and draft a release commit.
- **p3**: Update CHANGELOG or ROADMAP.

## Anti-Slop Gate
All strings must use `context.l10n` rather than hardcoded text in UI components before the commit is created.

## Fallback Path
If `flutter test` fails, `omg-debugger` will isolate the failing widget test and apply fixes via `omg-executor`.
