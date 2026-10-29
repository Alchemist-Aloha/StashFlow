# StashFlow v1.41.0

## 📐 Interface and Mini-player

- Added an optional **Settings → Interface → Mini-player bottom spacer** to keep the mini-player and floating controls clear of system taskbars that cover them.
- Adjust the bottom offset from 0–200 logical pixels, with a default of 64. The spacer is off by default, stays independent of interface scaling, and remembers your chosen offset when disabled.
- The extra clearance also keeps random buttons and filter/sort panels above the taskbar, even without active playback. Fullscreen remains unaffected.
- Both spacer settings are saved between sessions and included in configuration backups.
