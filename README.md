# 📱 StashAppFlutter
### Your Stash library, everywhere.

A mobile-first Flutter client for your **Stash** server. Designed for seamless browsing, effortless discovery, and high-quality playback on the go.

![StashAppFlutter Showcase](docs/assets/showcase.png)
*(Screenshot coming soon)*

## ✨ Key Features

- 🎬 **Seamless Playback:** Integrated video player with support for multiple streaming strategies and startup diagnostics.
- 👤 **Rich Browsing:** Explore Scenes, Performers, Studios, and Tags with native-feel pagination and fast search.
- 🎲 **Discovery Tools:** Floating "Random" actions to find hidden gems in your library across all categories.
- 🔍 **Advanced Filtering:** Powerful menu-based sorting and filtering to find exactly what you're looking for.
- 🛠️ **Native Customization:** Configure your server connection, UI preferences (Grid/List layouts), and streaming quality in one place.

## Tech Stack

- Flutter
- Riverpod (providers + generated notifiers)
- GoRouter
- GraphQL (`graphql_flutter` + `graphql_codegen` generated classes)
- SharedPreferences

## 🚀 Getting Started

1. **Download:** Grab the latest APK from the [Releases](https://github.com/Alchemist-Aloha/StashAppFlutter/releases) page.
2. **Connect:** Open the app ➔ Settings ➔ Enter your **Server URL** and **API Key**.
3. **Browse:** Your library will automatically sync and be ready for action.

### ⚙️ Runtime Settings
Tailor your experience in the app settings:
- `server_base_url` & `server_api_key`
- `prefer_scene_streams` (Toggle stream strategies)
- `scene_grid_layout` (Switch between Grid/List)

## Project Structure

- `lib/core` shared infrastructure
- `lib/features/*` feature modules (domain/data/presentation)
- `graphql/` schema and GraphQL documents
- `docs/` internal runbooks and architecture notes

## Documentation

- `docs/README.md` docs index
- `docs/AGENT_START_HERE.md` quick onboarding checklist
- `docs/ARCHITECTURE_MAP.md` architecture and data-flow overview
- `docs/DEBUGGING_PLAYBOOK.md` troubleshooting patterns
- `docs/KNOWNISSUES.md` actively tracked issues
