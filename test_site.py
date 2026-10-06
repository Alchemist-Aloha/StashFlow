"""Dependency-free checks for generated pages, locale coverage, and local URLs."""

import json
import subprocess
import unittest
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent
CATALOGS = ROOT / "l10n"
DIST = ROOT / "dist"
LOCALES = [path.stem.removeprefix("site_") for path in sorted(CATALOGS.glob("site_*.arb"))]


class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = set()
        self.urls = []
        self.lang = None
        self.radios = 0

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if tag == "html":
            self.lang = attrs.get("lang")
        if "id" in attrs:
            if attrs["id"] in self.ids:
                raise AssertionError(f"Duplicate id: {attrs['id']}")
            self.ids.add(attrs["id"])
        for name in ("href", "src"):
            if name in attrs:
                self.urls.append(attrs[name])
        if tag == "img":
            assert "alt" in attrs, "Image missing alt attribute"
            assert "width" in attrs and "height" in attrs, "Image missing dimensions"
        if tag == "input" and attrs.get("type") == "radio":
            self.radios += 1


class SiteTest(unittest.TestCase):
    def test_all_locales_and_local_links(self):
        subprocess.run(["npm", "run", "build"], cwd=ROOT, check=True)
        for locale in LOCALES:
            with self.subTest(locale=locale):
                path = DIST / "index.html" if locale == "en" else DIST / locale / "index.html"
                source = path.read_text(encoding="utf-8")
                page = Page()
                page.feed(source)
                self.assertEqual(page.lang, locale.replace("_", "-"))
                self.assertEqual(page.radios, 3)
                self.assertIn('class="showcase-controls"', source)
                for choice in ("browse", "play", "refine"):
                    self.assertIn(f'for="{choice}"', source)
                self.assertIn('id="app"', source)
                data = source.split('<script id="site-data" type="application/json">', 1)[1].split("</script>", 1)[0]
                props = json.loads(data)
                self.assertEqual(props["locale"], locale)
                catalog = json.loads((CATALOGS / f"site_{locale}.arb").read_text(encoding="utf-8"))
                self.assertEqual(props["copy"]["heroTitle"], catalog["heroTitle"])
                self.assertNotIn("__SITE_DATA__", source)
                self.assertNotIn("__TITLE__", source)
                self.assertIn('type="module"', source)
                self.assertIn("/assets/scenes_desktop.webp", source)
                self.assertIn("/assets/scene_details_desktop.webp", source)
                self.assertIn("/assets/scene_sort.webp", source)
                self.assertNotIn("library_stats.webp", source)
                self.assertRegex(source, r'rel="preload" href="[^"]*/assets/Manrope-[^"]+\.ttf"')
                self.assertNotIn('class="placeholder"', source)
                self.assertIn('aria-current="page"', source)
                self.assertIn("https://github.com/Alchemist-Aloha/StashFlow/releases/latest", source)
                hero = source.split('class="hero"', 1)[1].split("</section>", 1)[0]
                self.assertIn('class="button" href="#download"', hero)
                self.assertNotIn("/releases/latest", hero)
                release = json.loads((ROOT / "downloads.json").read_text())
                self.assertEqual([p["id"] for p in release["platforms"]],
                                 ["android", "windows", "macos", "linux", "web"])
                self.assertEqual(sum(len(p["packages"]) for p in release["platforms"]), 11)
                for platform in release["platforms"]:
                    self.assertIn(f'id="download-{platform["id"]}"', source)
                    for package in platform["packages"]:
                        filename = package["file"]
                        self.assertTrue(filename.startswith(f'StashFlow-{release["version"]}-{platform["id"]}'))
                        self.assertIn(f'https://github.com/Alchemist-Aloha/StashFlow/releases/download/v{release["version"]}/{filename}', page.urls)
                header = source.split("</header>", 1)[0]
                self.assertIn('class="repo-link"', header)
                self.assertNotIn('class="nav-links"', header)
                self.assertIn('href="#download"', header)
                self.assertIn('aria-label="StashFlow"', header)
                self.assertIn('href="https://github.com/Alchemist-Aloha/StashFlow"', header)
                repo_button = header.split('class="repo-link"', 1)[1].split('</a>', 1)[0]
                self.assertIn('aria-label="', repo_button)
                self.assertIn('title="', repo_button)
                self.assertIn('<svg ', repo_button)
                self.assertIn('aria-hidden="true"', repo_button)
                for url in page.urls:
                    parsed = urlsplit(url)
                    if parsed.scheme or parsed.netloc:
                        self.assertEqual(parsed.scheme, "https")
                        continue
                    target = (path.parent / unquote(parsed.path)).resolve() if parsed.path else path
                    self.assertTrue(target.is_relative_to(DIST.resolve()), url)
                    self.assertTrue(target.is_file(), url)
                    if parsed.fragment:
                        target_page = page
                        if target != path:
                            target_page = Page()
                            target_page.feed(target.read_text(encoding="utf-8"))
                        self.assertIn(parsed.fragment, target_page.ids)

        fallback = json.loads((CATALOGS / "site_zh.arb").read_text(encoding="utf-8"))
        simplified = json.loads((CATALOGS / "site_zh_Hans.arb").read_text(encoding="utf-8"))
        fallback.pop("@@locale")
        simplified.pop("@@locale")
        self.assertEqual(fallback, simplified)


if __name__ == "__main__":
    unittest.main()
