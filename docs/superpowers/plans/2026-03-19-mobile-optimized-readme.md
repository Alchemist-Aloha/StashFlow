# Mobile-Optimized README Improvement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the README into a high-impact, mobile-optimized landing page for end-users that highlights the Stash experience on the go.

**Architecture:** A flat Markdown structure using visual hierarchy (emojis, bold headers, and concise lists) to ensure readability on small screens.

**Tech Stack:** Markdown, GitHub-Flavored Markdown (GFM).

---

### Task 1: Rewrite Hero and Vision Section

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace existing title and description with high-impact "Mobile-First" messaging.**

```markdown
# 📱 StashFlow
### Your Stash library, everywhere.

A mobile-first Flutter client for your **Stash** server. Designed for seamless browsing, effortless discovery, and high-quality playback on the go.

![StashFlow Showcase](docs/assets/showcase.png)
*(Screenshot coming soon)*
```

- [ ] **Step 2: Verify formatting looks correct in a Markdown preview.**

- [ ] **Step 3: Commit.**

```bash
git add README.md
git commit -m "docs: update README hero section for mobile-first appeal"
```

### Task 2: Implement Feature Showcase with Emojis

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace "Current Highlights" with a scannable "Features" section using emojis for visual anchors.**

```markdown
## ✨ Key Features

- 🎬 **Seamless Playback:** Integrated video player with support for multiple streaming strategies and startup diagnostics.
- 👤 **Rich Browsing:** Explore Scenes, Performers, Studios, and Tags with native-feel pagination and fast search.
- 🎲 **Discovery Tools:** Floating "Random" actions to find hidden gems in your library across all categories.
- 🔍 **Advanced Filtering:** Powerful menu-based sorting and filtering to find exactly what you're looking for.
- 🛠️ **Native Customization:** Configure your server connection, UI preferences (Grid/List layouts), and streaming quality in one place.
```

- [ ] **Step 2: Commit.**

```bash
git add README.md
git commit -m "docs: add scannable features section to README"
```

### Task 3: Streamline "Getting Started" for End-Users

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Create a simplified 3-step guide for users to connect their app.**

```markdown
## 🚀 Getting Started

1. **Download:** Grab the latest APK from the [Releases](https://github.com/Alchemist-Aloha/StashFlow/releases) page.
2. **Connect:** Open the app ➔ Settings ➔ Enter your **Server URL** and **API Key**.
3. **Browse:** Your library will automatically sync and be ready for action.

### ⚙️ Runtime Settings
Tailor your experience in the app settings:
- `server_base_url` & `server_api_key`
- `prefer_scene_streams` (Toggle stream strategies)
- `scene_grid_layout` (Switch between Grid/List)
```

- [ ] **Step 2: Commit.**

```bash
git add README.md
git commit -m "docs: simplify getting started guide in README"
```

### Task 4: Move Technical Details to "Advanced" Section

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Consolidate build instructions, tech stack, and dev commands at the bottom.**

```markdown
---

## 🤓 For Developers

### Tech Stack
- **Flutter** & **GoRouter**
- **Riverpod** (State Management)
- **GraphQL** (`graphql_flutter` + `codegen`)

### Project Structure
- `lib/core` shared infrastructure
- `lib/features/*` feature modules (domain/data/presentation)
- `graphql/` schema and GraphQL documents

### Development
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Build
```bash
flutter build apk
```
```

- [ ] **Step 2: Commit.**

```bash
git add README.md
git commit -m "docs: move technical details to advanced section in README"
```

### Task 5: Preserve Internal Documentation Links

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Ensure links to the `docs/` folder are maintained for deep dives.**

```markdown
## 📚 Internal Docs
For architecture, known issues, and onboarding, see:
- [Documentation Index](docs/README.md)
- [Architecture Map](docs/ARCHITECTURE_MAP.md)
- [Debugging Playbook](docs/DEBUGGING_PLAYBOOK.md)
- [Known Issues](docs/KNOWNISSUES.md)
- [Agent Start Here](docs/AGENT_START_HERE.md)
```

- [ ] **Step 2: Perform a final read-through of the entire README to ensure flow and tone consistency.**

- [ ] **Step 3: Commit.**

```bash
git add README.md
git commit -m "docs: final README structure refinement"
```

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
