# Installation

This page covers how to install StashFlow on each supported platform.  
No Stash server? See the [Stash project](https://github.com/stashapp/stash) first — StashFlow is a client app only.

---

## Prerequisites

Before launching StashFlow you need:

- A running **Stash server** (keep it up to date for the newest filter and sort features).
- The server's **base URL** (e.g. `http://192.168.1.100:9999`).
- Credentials for one of the supported **authentication methods**:
  - **API Key** — generate one in Stash → Settings → Security → API Keys.
  - **Username + Password** — your Stash login; recommended when available, since it uses a session.
  - **Basic Auth** — sends an `Authorization: Basic <base64(user:pass)>` header.
  - **Bearer Token** — sends an `Authorization: Bearer <token>` header.

You can store credentials for multiple servers as profiles and switch between them. See the
[Settings Reference](Settings-Reference) for details.

---

## Android

### Requirements
- **Android 7.0 (API 24)** or later.
- Your phone on the same network as your Stash server if you use a local address.

### Steps

1. Open the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page and download the APK that matches your device's CPU:
   - `StashFlow-<version>-android-arm64-v8a.apk` (most modern phones)
   - `StashFlow-<version>-android-armeabi-v7a.apk` (older 32-bit devices)
   - `StashFlow-<version>-android-x86_64.apk` (emulators / x86 devices)
2. Allow installs from your browser or file manager: **Settings → Apps → Special app access → Install unknown apps**.
3. Open the downloaded APK and tap **Install**.
4. Launch **StashFlow** → **Settings → Server → Add Profile** → enter a profile name, your **Stash URL**, and credentials → **Test Connection** → **Save**. The profile becomes active immediately.

> **Tip:** If your Stash server is on your local network, make sure your phone is connected to the same Wi-Fi network.

---

## Desktop — Windows

Choose one of the two downloads from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page:

- **`StashFlow-<version>-windows-x64.exe`** — installer. Run it, follow the prompts, then launch **StashFlow** from the Start menu.
- **`StashFlow-<version>-windows-x64.zip`** — portable build. Extract anywhere and run `StashFlow.exe`.

Then open **Settings → Server → Add Profile**, enter your **Stash URL** and credentials, and click **Save**.

---

## Desktop — macOS

1. Download `StashFlow-<version>-macos-<arch>.zip` (Apple Silicon `arm64` or Intel `x86_64`) from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. Unzip and drag **StashFlow.app** to your Applications folder.
3. On first launch, macOS may show a security warning. Open **System Settings → Privacy & Security → General** and click **Open Anyway**.
4. Open **Settings → Server → Add Profile**, enter your **Stash URL** and credentials, and click **Save**.

> The macOS build is unsigned, so Gatekeeper will warn on first launch. This is expected.

---

## Desktop — Linux

Pick the package that matches your distribution from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page:

| File | Distribution |
|------|--------------|
| `StashFlow-<version>-linux-x64.AppImage` | Any distro — mark executable and run |
| `StashFlow-<version>-linux-x64.deb` | Debian, Ubuntu, and derivatives |
| `StashFlow-<version>-linux-x64.pkg.tar.zst` | Arch Linux and derivatives |
| `StashFlow-<version>-linux-x64.zip` | Portable bundle — extract and run `StashFlow` |

Example for the portable bundle:

```bash
unzip StashFlow-*-linux-x64.zip -d StashFlow
cd StashFlow
./StashFlow
```

Arch users can install with `sudo pacman -U StashFlow-<version>-linux-x64.pkg.tar.zst`, which installs to `/opt/StashFlow` and adds a `stashflow` launcher.

> **RPM packages** are not published in Releases. Build one locally with `scripts/build_linux_rpm.sh` — see [Building from Source](Building-from-Source).

Then open **Settings → Server → Add Profile**, enter your **Stash URL** and credentials, and click **Save**.

---

## Web

1. Visit the [Live Web App](https://alchemist-aloha.github.io/StashFlow/).
2. Add a server profile on first visit.
3. Enter your **Stash URL** and **API Key** and connect.

> **Web is a demo.** Browser security rules (CORS) restrict the web build to **API-key authentication
> only**, and video playback depends on which codecs your browser supports. Use the Android or
> desktop builds for the full feature set.

> **CORS note:** Your Stash server must allow requests from the web app origin. In Stash →
> Settings → Security, add the web app URL to the allowed origins list (or set it to `*` for local use).

### Self-hosting the web build

See [Building from Source](Building-from-Source) for instructions on producing a `flutter build web`
output you can deploy to any static host. Remember to build with the correct base href for your host path.

---

## Next steps

After connecting, open **Settings** to configure appearance, interface, playback, subtitles, storage
and cache, security, and (on desktop/web) keyboard shortcuts.

→ Full details: **[Settings Reference](Settings-Reference)**
