# StashFlow introduction website

A standalone Vue 3 product website for StashFlow. This branch contains the
website only; the application and its web demo are separate projects.
Vite builds and pre-renders every locale, then Vue hydrates the pages in the
browser. Content, screenshot radios, and language links work without JavaScript.

Requires Node.js 20.19+ or 22.12+, npm, and Python 3 for static checks.

## Development and deployment

From the repository root:

```sh
npm ci
npm run dev
# Preview the production output:
npm run build
npm run preview
```

Development: http://localhost:5173. Production preview: http://localhost:4173.
English is the default; localized pages keep paths such as `/de/index.html`.
Deploy the **contents of `dist/`** to any static host, including a subdirectory.
This branch has no application release or deployment workflows.

## Source files

- `src/App.vue`: page composition and native controls.
- `styles.css`: responsive layout, screenshot-matched palette, and CSS motion.
- `l10n/site_*.arb`: copy for all 11 locales; Chinese fallback matches Simplified Chinese.
- `assets/`: shipped screenshots, icon, self-hosted font, and asset licenses.
- [DESIGN.md](DESIGN.md): visual direction.
- [docs/SPECS.md](docs/SPECS.md): behavior and deployment contracts.

The hero features Android's vertical Feed mode. The mobile showcase starts with
Feed, alongside Browse, Play, and Refine; the desktop section pairs Linux browsing
with playback and details. All captures use the test library at
`http://192.168.88.225:29999` and the Purple preset in dark mode.
Device frames preserve full screenshot proportions.
Screenshots contain sample media artwork; verify publication rights before
deploying publicly.

## Asset provenance

Shipped images derive from original StashFlow application assets, not stock or
generated imagery. The original files are not included in this website-only
branch. The filenames below record their source in the application repository:

| Shipped asset under `assets/` | Original application asset |
| --- | --- |
| `icon.png` | `asset/stashfluttericon.png`, resized to 128px |
| `scenes.webp` | `asset/scenes.jpg` |
| `scene_details.webp` | `asset/scene_details.jpg` |
| `edit_scene.webp` | `asset/edit_scene.jpg` |
| `scene_filter.webp` | `asset/scene_filter.jpg` |
| `scene_sort.webp` | `asset/scene_sort.jpg` |
| `scroll_feed.webp` | `asset/scroll_feed.jpg` |
| `scenes_desktop.webp` | `asset/linux/scenes.jpg` |
| `scene_details_desktop.webp` | `asset/linux/scene_details.jpg` |

Sources were imported from application commit `8f0525cab8ed5a04f1f73a3c85f58a7c6e9b6b4a`.
Mobile conversions use a width of 540px (720px for the featured feed) and WebP
quality 88. Desktop conversions use WebP quality 88 at the original 1440×900.
Images are never cropped.

Manrope is self-hosted in `assets/fonts/Manrope.ttf`, with its SIL Open Font
License in `assets/fonts/OFL.txt`. System fonts cover unsupported scripts.
The header's GitHub mark comes from
[Primer Octicons](https://github.com/primer/octicons/blob/main/icons/mark-github-16.svg);
its MIT license is in `assets/octicons-LICENSE.txt`.
The website's license is [GPL-3.0](LICENSE).

## Verification

```sh
npm test
git diff --check
```

Tests build all locales and check catalog coverage, hydration payload escaping,
local links/assets, and the Chinese fallback. Browser verification should cover
phone and desktop widths, localized expansion, keyboard navigation, contrast,
zoom, reduced motion, and deployment under a subpath.
