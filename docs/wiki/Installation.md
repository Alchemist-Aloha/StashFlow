# Installation

This page covers how to install StashFlow on each supported platform.  
No Stash server? See the [Stash project](https://github.com/stashapp/stash) first — StashFlow is a client app only.

---

## Prerequisites

Before launching StashFlow you need:

- A running **Stash server** (v0.25 or later recommended).
- The server's **base URL** (e.g. `http://192.168.1.100:9999`).
- An **API key** — generate one in Stash → Settings → Security → API Keys.

---

## Android

### Minimum requirements
- Android 5.0 (API 21) or later.

### Steps

1. Open the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page and download the latest `StashFlow-*.apk`.
2. On your device, go to **Settings → Apps → Special app access → Install unknown apps** and allow your browser or file manager.
3. Open the downloaded APK and tap **Install**.
4. Launch **StashFlow** → tap **Settings** (gear icon) → enter your **Server URL** and **API Key** → tap **Save**.

> **Tip:** If your Stash server is on your local network, make sure your phone is connected to the same Wi-Fi network.

---

## Desktop — Windows

1. Download `StashFlow-windows-*.zip` from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. Extract the archive to any folder (e.g. `C:\Program Files\StashFlow`).
3. Run `stash_app_flutter.exe`.
4. Open **Settings** → enter your **Server URL** and **API Key** → click **Save**.

---

## Desktop — macOS

1. Download `StashFlow-macos-*.dmg` (or `.zip`) from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. Open the DMG and drag **StashFlow** to your Applications folder.
3. On first launch, macOS may show a security warning. Go to **System Preferences → Security & Privacy → General** and click **Open Anyway**.
4. Open **Settings** → enter your **Server URL** and **API Key** → click **Save**.

---

## Desktop — Linux

1. Download `StashFlow-linux-*.tar.gz` from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. Extract:
   ```bash
   tar -xzf StashFlow-linux-*.tar.gz
   cd StashFlow
   ./stash_app_flutter
   ```
3. Open **Settings** → enter your **Server URL** and **API Key** → click **Save**.

> **Optional:** Create a `.desktop` file or symlink to launch from your application menu.

---

## Web

1. Visit the [Live Web App](https://alchemist-aloha.github.io/StashFlow/).
2. Your browser will prompt for server connection details on the first visit.
3. Enter your **Server URL** and **API Key** and click **Connect**.

> **CORS note:** Your Stash server must allow requests from the web app origin. In Stash → Settings → Security, add the web app URL to the allowed origins list (or set it to `*` for local use).

### Self-hosting the web build

See [Building from Source](Building-from-Source) for instructions on producing a `flutter build web` output you can deploy to any static host.

---

## Runtime Settings

After connecting, you can configure the following in **Settings**:

| Setting | Description |
|---------|-------------|
| `server_base_url` | Full URL to your Stash server |
| `server_api_key` | API key for authentication |
| `prefer_scene_streams` | Use `sceneStreams` endpoint (on) or direct file path (off) |
| `scene_layout_mode` | Scene list view: **List**, **Grid**, or **TikTok** |
| `autoplay_next` | Automatically play the next scene when playback ends |
| `video_background_playback` | Continue audio when the app is minimised (Android) |
| `video_native_pip` | Auto-enter Picture-in-Picture when backgrounded (Android) |
| `default_subtitle_language` | Auto-load subtitles in this language when available |
| `subtitle_font_size` | Subtitle text size in pixels (12–32) |
| `subtitle_position_bottom_ratio` | Subtitle distance from bottom (5%–40%) |
| `image_fullscreen_vertical_swipe` | Swipe direction to advance images in fullscreen |
