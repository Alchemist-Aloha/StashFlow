# StashFlow v1.41.0

## 💬 On-device Subtitles

- Added opt-in speech transcription with optional translation during native playback, including scenes without server subtitles. Open **Transcribe** from the subtitle menu to get started; generation is unavailable on web or while casting.
- Manage compatible speech and translation models in **Settings → Playback**, or search and download them directly in the transcription dialog. Downloads support progress and cancellation; installed models can be reused offline, with speech and text processed on-device rather than sent to a cloud service.
- Choose automatic language detection with supported speech models or a fixed source language, select an output language, and optionally show both original and translated text. Translation requires a downloaded model for the matching language pair.
- Fine-tune processing threads, audio-window length, speech detection, and subtitle delay. Applied model and tuning preferences are remembered between sessions; cancelling leaves them unchanged.
- Generated captions follow playback across inline, fullscreen, feed, and PiP views and use your subtitle appearance preferences. Selecting **None** or a server subtitle track stops generation. Speed and accuracy depend on your hardware and chosen models.

## 🎬 Subtitle Appearance

- Server and generated subtitles now share consistent font sizing, alignment, and positioning. Removed the extra fourfold font-size multiplier from server subtitles so the configured size follows interface scaling consistently.

## 📐 Interface and Mini-player

- Added an optional **Settings → Interface → Mini-player bottom spacer** to keep the mini-player and floating controls clear of system taskbars that cover them.
- Adjust the bottom offset from 0–200 logical pixels, with a default of 64. The spacer is off by default, stays independent of interface scaling, and remembers your chosen offset when disabled.
- The extra clearance also keeps random buttons and filter/sort panels above the taskbar, even without active playback. Fullscreen remains unaffected.
- Both spacer settings are saved between sessions and included in configuration backups.
