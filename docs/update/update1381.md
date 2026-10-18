# StashFlow v1.38.1

## 🔀 Sorting

- Sort panels show common choices first, with less-used fields in expandable advanced options. The selected advanced sort stays visible when the section is collapsed.
- Scene and gallery sorting options are now consistent between library pages and performer, studio, tag, and group pages.
- Sort panels keep a stable height while options scroll, improving access to controls on smaller screens and at larger text scales.

## 📜 Browsing

- Lists reserve space for floating action controls above the mini-player so the last item can scroll fully into view, including after interface scale changes.

## 📱 Android Launch Fix

- Fixed a launch bug in optimized Android release builds by preserving Kotlin types required by the Dart JNI bridge when loading app preferences.
