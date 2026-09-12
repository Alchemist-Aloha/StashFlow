# Settings Reference

This page documents every settings page in StashFlow and what each option does.

Open **Settings** from the gear icon in the top app bar. The hub lists:

| Page | Availability |
|------|--------------|
| **Server** | All platforms |
| **Playback** | All platforms |
| **Keyboard** | Desktop and Web only (hidden on Android) |
| **Appearance** | All platforms |
| **Interface** | All platforms |
| **Security** | All platforms |
| **Storage & Cache** | All platforms |
| **Support** | All platforms |
| **Develop** | All platforms |

> Settings are stored per app install. Use **Storage & Cache → Save configuration** to move them
> between devices or back them up.

---

## Server

Manage one or more Stash servers as **profiles**. Each profile stores a name, URL, and credentials,
and the active profile is used for every request, image load, download, and video stream.

### Adding or editing a profile

Open **Server → Add Profile** (or tap an existing profile). The editor contains:

| Field | Notes |
|-------|-------|
| **Profile Name** | A label for this server |
| **Stash URL** | Base address, e.g. `http://192.168.1.100:9999` |
| **Authentication Method** | One of the four modes below |

By default, only **API Key** and **Username + Password** are shown. Tap **Show more** to reveal
**Basic Auth** and **Bearer Token**.

| Auth method | What it sends | When to use |
|-------------|---------------|-------------|
| **API Key** | A static API key issued by Stash | Simplest setup; works everywhere including web |
| **Username + Password** | A Stash login session (recommended) | Full features and session refresh |
| **Basic Auth** | `Authorization: Basic <base64(user:pass)>` header | Reverse proxies / static setups |
| **Bearer Token** | `Authorization: Bearer <token>` header | Custom gateways |

Use **Test Connection** to verify credentials before saving. Credentials are stored in the platform's
secure storage (SharedPreferences holds only non-secret profile metadata).

### Switching profiles

Selecting a different active profile flushes caches, stops the player, and re-initializes the
GraphQL client and session so no data leaks between servers. The page also shows a live
**Connection Status** (`Connected (Stash <version>)`, `Checking connection…`, or `Failed: …`) and
the current **Authentication status**.

---

## Playback

### Playback behavior

| Setting | Default | Description |
|---------|---------|-------------|
| **Start Feed from random position** | Off | In Feed mode, begin each scene at a random point between 0% and 90% |
| **Play End Behavior** | Stop | What happens when a scene ends: `Stop`, `Loop current scene`, or `Play next scene` |
| **Background Playback** | Off | Keep audio playing when the app is backgrounded (Android) |
| **Native Picture-in-Picture** | Off | Show the Android PiP button and auto-enter PiP on background |
| **Open scenes in fullscreen** | Off | Open playback directly in fullscreen |
| **Gravity-controlled orientation** | On | Rotate with the device sensor during playback |
| **Resume from last playing position** | On | Continue from where you left off |

### Subtitles

| Setting | Options / range | Default |
|---------|-----------------|---------|
| **Default Subtitle Language** | `None (Disabled)`, `Auto (If only one)`, English, Chinese, German, French, Spanish, Italian, Japanese, Korean | Auto |
| **Subtitle Font Size** | 12–32 px | 18 |
| **Subtitle Vertical Position** | 5%–40% from the bottom | 15% |
| **Subtitle Text Alignment** | Left / Center / Right | Center |

### Seek interaction

| Mode | Behavior |
|------|----------|
| **Drag** (default) | Drag horizontally anywhere on the player to seek; distance maps to time skipped |
| **Double-tap** | Double-tap the left half to seek back 10s, the right half to seek forward 10s |

### MPV settings (native builds only)

Hidden on web. Controls the underlying mpv player used by media-kit. Selecting a value changes
newly created controllers; restart the app to apply it everywhere.

| Setting | Android | Desktop (Windows/macOS/Linux) |
|---------|---------|-------------------------------|
| **mpv vo** (video output) | `default`, `gpu`, `mediacodec_embed` | `default`, `libmpv` |
| **mpv hwdec** (hardware decoding) | `default`, `no`, `auto`, `auto-safe`, `auto-copy`, `mediacodec`, `mediacodec-copy` | `default`, `no`, `auto`, `auto-safe`, `auto-copy` |

> Choosing **`mediacodec_embed`** for `vo` forces hardware decoding to `mediacodec`. Use
> **`hwdec = no`** (software decoding) if a device has trouble with HEVC hardware decoders.

---

## Keyboard

See **[Desktop Usage & Key Bindings](Desktop-Usage-Key-Bindings)** for the complete shortcut list,
customization, and conflict rules. This page is only shown on desktop and web.

---

## Appearance

| Setting | Options | Notes |
|---------|---------|-------|
| **Theme Mode** | System / Light / Dark | Follows the OS by default |
| **True Black (AMOLED)** | On / Off | Uses pure black surfaces in dark mode on OLED screens |
| **Primary Color** | Teal, Blue, Purple, Orange, Red, Green, or a custom hex | Seeds the Material 3 palette |
| **Global UI Scale** | 80%–150% (slider) | Scales typography and spacing across the whole app |

Custom colors accept an 8-digit ARGB hex code. Theme changes apply immediately without a restart.

---

## Interface

### Language

Choose **System Default** or one of ten languages: English, Español, 简体中文, 繁體中文, 日本語,
한국어, Français, Italiano, Deutsch, Русский.

### Navigation

| Setting | Default | Description |
|---------|---------|-------------|
| **Show Random Navigation Buttons** | On | Floating "casino" buttons for random navigation on lists and details |
| **Hide top app bar while scrolling** | Off | Collapse the app bar when scrolling down, reveal it when scrolling up |
| **Hide scene metadata by default** | On | Show technical scene metadata only after tapping **Show metadata** |
| **Respect active filters for random scene** | On | Random scene navigation uses the current scene filters |
| **Entity image filtering** | Direct entity | `Direct entity` or `Related galleries` for entity detail image grids |
| **Gravity-controlled orientation (main pages)** | On | Let main pages rotate with the device sensor |
| **Use actual scene video in miniplayer** | On | Show live video in the mini-player instead of a screenshot |
| **Customize Tabs** | — | Opens the tab reordering page (see below) |

### Customize Tabs

Reorder the visible top-level destinations and toggle each one on or off. Available tabs:

- Scenes
- Performers
- Studios
- Tags
- Galleries
- Groups **(hidden by default)**

At least one tab must remain visible. The order here determines the numbered keyboard shortcuts
(`Ctrl+1` … `Ctrl+9`) on desktop and web.

### Layouts

Layout settings are grouped per media type:

- **Scenes Layout** — `List`, `Grid`, or `Feed` (TikTok-style), grid column count, performer avatars
  (on/off, max count, size), and card title font size.
- **Galleries Layout** — `List` or `Grid`, plus grid column count.
- **Image Viewer** — fullscreen swipe direction (`Vertical` or `Horizontal`) and waterfall grid columns.
- **Groups** — media layout (`List`/`Grid`) and grid columns.
- **Markers** — default layout (`List`/`Grid`) and grid columns.
- **Entity Layouts** — consolidated Performer, Studio, and Tag layout settings (media layout,
  galleries layout, and grid columns).

---

## Security

Protect the app with a passcode.

| Setting | Description |
|---------|-------------|
| **Passcode** | Set, change, or remove a 4–8 digit numeric passcode |
| **Enable app lock** | Require the passcode on resume or launch |
| **Lock on app launch** | Ask immediately when the app opens (requires app lock + passcode) |
| **Background lock timer** | Delay before locking after backgrounding: `Immediately`, 5s, 10s, 30s, 1 min, 2 min, 5 min |

The passcode is stored in secure storage and is never exported unless you explicitly opt in to
including credentials in a configuration backup.

---

## Storage & Cache

### App configuration

| Action | Description |
|--------|-------------|
| **Save configuration** | Export settings and server profiles to `stashflow-config-<date>.json`. Optionally include credentials. |
| **Import configuration** | Replace the current configuration from a backup file, after a preview and confirmation. |

> ⚠️ **Credentials are excluded by default.** Enabling *Include credentials unencrypted* writes server
> credentials and the app-lock passcode as **plain text** in the exported file — anyone with the file
> can read them. Importing replaces all current settings and profiles. A restart applies every setting.

### Storage usage

Shows the size of each cache with an individual **Clear** action:

- **Images**
- **Videos**
- **Database**

### Limits

| Setting | Options |
|---------|---------|
| **Max Image Cache** | 100 MB, 500 MB, 1 GB, Unlimited |
| **Max Video Cache** | 500 MB, 1 GB, 2 GB, Unlimited |

Cache operations run in the background and never touch unrelated settings or active playback media.

---

## Support

| Item | Description |
|------|-------------|
| **Update Available** | Appears when a newer release exists; opens the GitHub release page |
| **Version** | Installed version (e.g. `StashFlow 1.33.0`) |
| **GitHub Repository** | Opens the source repository |
| **Report an Issue** | Opens the issue tracker |

---

## Develop

Diagnostic tools for troubleshooting:

| Setting | Description |
|---------|-------------|
| **Show Video Debug Info** | Overlay technical playback details on the video player |
| **Enable Debug Logging** | Record app logs for troubleshooting |
| **Debug Log Viewer** | Open the in-app log viewer |

These options are intended for debugging and can be left off during normal use.
