# UI Guideline

## Purpose
This document defines practical UI standards for the StashAppFlutter project.
Use these rules for new UI work and when refactoring existing screens.

## Core Principles
- Keep interactions fast, predictable, and touch friendly.
- Prefer clarity over visual density.
- Use Material 3 components and tokens by default.
- Keep behavior consistent across scenes, performers, studios, tags, and settings.

## Theming
- Respect app theme mode: `system`, `light`, and `dark`.
- Never hardcode light-only or dark-only text colors for primary content.
- Prefer theme tokens from `ThemeData` and `AppColors` extensions.
- Ensure contrast is readable in both light and dark themes.

## Layout
- Use consistent spacing from `AppTheme` constants.
- Use responsive layouts that work on narrow phones and wider screens.
- Avoid fixed-width assumptions unless required by a specific component.
- For media surfaces, prefer dynamic aspect ratio from metadata/controller values.

## Typography
- Use `context.textTheme` styles as the base.
- Reserve bold weights for headings and key values.
- Limit long text with sensible truncation and fallback states.
- Provide title fallback for scene-derived content when upstream titles are missing.

## Components
- Prefer Material 3 widgets when available.
- Use cards, chips, list tiles, segmented controls, and FAB patterns consistently.
- Keep reusable UI in widgets/providers instead of duplicating logic.
- Avoid custom controls unless default controls cannot meet UX requirements.

## Motion and Gestures
- Support intuitive gestures where they add value.
- Keep gesture behavior explicit to avoid accidental actions.
- For video controls:
  - keep drag-to-seek enabled,
  - support double-tap seek where appropriate,
  - avoid accidental resume/play from generic tap areas.

## Media and Playback UX
- Ensure portrait media is not forced into landscape framing.
- Keep mini player state, detail player state, and queue behavior in sync.
- Keep screen awake while video is actively playing.
- Expose debugging overlays only behind explicit settings toggles.

## Accessibility
- Maintain readable text size and color contrast.
- Ensure touch targets are large enough for mobile use.
- Avoid icon-only actions without a tooltip/semantic meaning.
- Keep navigation and section structure clear and screen-reader friendly.

## Empty, Loading, and Error States
- Always provide explicit loading and empty states.
- Show actionable error messages and recovery options when possible.
- Never leave major content regions blank without context.

## Documentation Rule
When adding or changing UI behavior:
- update the relevant docs in `docs/`,
- note theme and accessibility implications,
- include any new interaction patterns.
