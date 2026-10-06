# StashFlow introduction website

A standalone, Apple-inspired product page. It does not replace the Flutter web
demo or change the application's design system. No npm packages or build tools
are required; Python 3 builds the static HTML.

## Preview

From the repository root:

```sh
python3 website/build.py
python3 -m http.server 8080 --directory website/dist
```

Open http://localhost:8080. Deploy the **contents of `website/dist/`** to any
static host, including a subdirectory. No deployment workflow is changed here.

## Content and screenshots

- Edit copy in `lib/l10n/website/site_*.arb`, not in generated HTML.
- English is the default. The footer links to all supported localized pages.
- The site's isolated ARB catalogs do not add marketing copy to the Flutter app.
- The hero shows desktop library browsing; the desktop section shows scene
  playback and details. Both use full, uncropped screenshots with localized alt text.
- Original desktop PNGs are preserved in `asset/`. Their WebP copies retain
  the original dimensions and framing, including window chrome and controls.
- Mobile images show existing screenshots, not claims about the current theme.
- Existing screenshots contain sample media artwork; verify its publication
  rights before deploying publicly.

### Raster provenance

All shipped assets are derived from existing repository assets; no stock or
generated imagery is used. `assets/icon.png` is a 128px resize of
`asset/stashfluttericon.png`. Mobile WebPs retain their source framing:

| Website asset | Source |
| --- | --- |
| `scenes.webp` | `asset/scenes.jpg` |
| `scene_details.webp` | `asset/scene_details.jpg` |
| `edit_scene.webp` | `asset/edit_scene.jpg` |
| `scene_filter.webp` | `asset/scene_filter.jpg` |
| `scene_sort.webp` | `asset/scene_sort.jpg` |
| `scenes_desktop.webp` | `asset/stashflow_scenes_desktop.png` |
| `scene_details_desktop.webp` | `asset/stashflow_scene_details_desktop.png` |

Mobile conversions use ImageMagick at a maximum width of 540px and WebP
quality 85. Convert desktop screenshots without cropping or resizing:

```sh
magick asset/stashflow_scenes_desktop.png -quality 88 website/assets/scenes_desktop.webp
magick asset/stashflow_scene_details_desktop.png -quality 88 website/assets/scene_details_desktop.webp
```

CSS device frames display the full images at their original aspect ratios. Original source screenshots are not modified.

Manrope is self-hosted from `asset/fonts/manrope/Manrope.ttf`, with its SIL Open
Font License included in `assets/fonts/OFL.txt`. System fonts handle scripts
outside its character coverage. No third-party font request is needed.

The header's GitHub mark is the inline SVG from
[Primer Octicons](https://github.com/primer/octicons/blob/main/icons/mark-github-16.svg).
Its MIT license is included in `assets/octicons-LICENSE.txt`.

## Checks

```sh
python3 -m unittest discover -s website -p 'test_*.py'
```

The check builds every locale, checks local links/assets and translation
coverage, and verifies the Chinese fallback. Browser checks should cover phone
and desktop widths, keyboard navigation of the screenshot radios and language
menu, and reduced-motion preferences.
