# Docs Index

This folder contains agent-focused project documentation.

## Start Here

- [Agent Start Guide](./AGENT_START_HERE.md)
- [Architecture Map](./ARCHITECTURE_MAP.md)
- [Commands](./COMMANDS.md)
- [Debugging Playbook](./DEBUGGING_PLAYBOOK.md)
- [Change Checklist](./CHANGE_CHECKLIST.md)
- [Known Issues](./KNOWNISSUES.md)

## Current Implementation Notes (2026-03-19)

- Scenes/Performers/Studios/Tags use bottom-sheet sort and filter menus.
- Random discovery uses small floating action buttons on all four list pages.
- Scenes "Organized only" filter lives in the filter panel.
- Scenes grid/list layout is controlled from Settings (`scene_grid_layout`).
- Video seek interaction mode is configurable in Settings (`Drag` vs `Double-tap`) and works in inline and fullscreen player.
- Player controls now auto-hide while playing and reappear on interaction.
- Stream prewarm runs in the background and no longer blocks playback startup.
- Mini-player navigation back to scene details preserves current playback session (no intentional restart).
- Native PiP is enabled as an optional setting; PiP entry prefers fullscreen player context for video-only surface.
- Startup diagnostics include stream resolver and player startup logs; provider lifecycle race is still being monitored.
- GraphQL codegen maps to `graphql/combined_schema.graphql` and feature documents.

## Purpose

Use these docs to reduce exploration time, avoid repeated mistakes, and keep changes verifiable.

## Historical Design/Plan Docs

- `docs/superpowers/plans/*` and `docs/superpowers/specs/*` are historical planning artifacts.
- They are retained for context and may not exactly match current implementation.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [UIGUIDELINE.md](UIGUIDELINE.md) for current UI standards.
