# StashFlow v1.35.0

## 🎬 Scene Navigation

- Swipe the scene title left or right on touch to preview and open the next or previous scene in the active queue. StashFlow gives a brief hint once per launch when an adjacent scene is available, and respects reduced-motion settings.
- The inline video Back button stays in the top-left corner while playback is starting and when the player is inactive.

## 🔐 Self-Signed HTTPS Servers

- Server profiles can now opt into self-signed HTTPS certificates for their configured server host and port. The option is off by default, included in configuration backups, and applies on native platforms; browsers continue to use their own certificate validation.

## 🧹 Scene Deduplication

- When scenes are selected for deletion in the deduplication tool, a floating action button shows the selected count and opens the existing confirmation step.

## 🔧 Maintenance

- Updated Skeletonizer and development tooling dependencies.
