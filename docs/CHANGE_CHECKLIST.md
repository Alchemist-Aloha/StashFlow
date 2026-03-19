# Change Checklist

Use this before closing a task.

## Code changes

- [ ] Minimal scope; no unrelated refactors.
- [ ] New behavior is behind existing patterns or settings when appropriate.
- [ ] SharedPreferences keys are stable and documented if added.
- [ ] List-page random actions use floating buttons (not app bar icons).
- [ ] Sort/filter changes follow bottom-sheet control pattern.

## Validation

- [ ] `flutter analyze` passes.
- [ ] Relevant tests pass.
- [ ] `flutter build apk` run for release-impacting changes.

## Documentation

- [ ] Known issues updated if problem remains unresolved.
- [ ] New runtime toggles are reflected in docs.
- [ ] Debugging notes updated for newly learned failure modes.
- [ ] `README.md` and `docs/README.md` updated when UX/flow changes are user-visible.

## Handoff quality

- [ ] Root cause or best-known hypothesis stated.
- [ ] Trade-offs and limits are explicit.
- [ ] Next action is clear and testable.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [UIGUIDELINE.md](UIGUIDELINE.md) for current UI standards.
