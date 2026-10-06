#!/usr/bin/env python3
"""Build the standalone introduction site from its ARB catalogs; no packages needed."""

import json
import shutil
from html import escape
from pathlib import Path
from string import Template

ROOT = Path(__file__).resolve().parent
CATALOGS = ROOT.parent / "lib" / "l10n" / "website"
DIST = ROOT / "dist"
LOCALES = {
    "en": "English", "de": "Deutsch", "es": "Español", "fr": "Français",
    "it": "Italiano", "ja": "日本語", "ko": "한국어", "ru": "Русский",
    "zh": "中文", "zh_Hans": "简体中文", "zh_Hant": "繁體中文",
}


def build():
    """Write locale pages sharing one stylesheet and one set of image assets."""
    template = Template((ROOT / "index.template.html").read_text(encoding="utf-8"))
    english = json.loads((CATALOGS / "site_en.arb").read_text(encoding="utf-8"))
    expected = {key for key in english if not key.startswith("@")}
    DIST.mkdir(exist_ok=True)
    shutil.copyfile(ROOT / "styles.css", DIST / "styles.css")
    shutil.copytree(ROOT / "assets", DIST / "assets", dirs_exist_ok=True)

    for locale in LOCALES:
        catalog = json.loads((CATALOGS / f"site_{locale}.arb").read_text(encoding="utf-8"))
        actual = {key for key in catalog if not key.startswith("@")}
        if actual != expected or any(not isinstance(catalog[key], str) or not catalog[key].strip() for key in actual):
            raise ValueError(f"Invalid translation catalog: {locale}")
        prefix = "." if locale == "en" else ".."
        links = []
        for target, label in LOCALES.items():
            href = f"{prefix}/index.html" if target == "en" else f"{prefix}/{target}/index.html"
            current = ' aria-current="page"' if target == locale else ""
            lang = target.replace("_", "-")
            links.append(f'<a href="{href}" lang="{lang}" hreflang="{lang}"{current}>{label}</a>')
        values = {key: escape(catalog[key], quote=True) for key in actual}
        values.update(lang=locale.replace("_", "-"), assetPrefix=prefix, languageLinks="".join(links))
        output = DIST if locale == "en" else DIST / locale
        output.mkdir(exist_ok=True)
        (output / "index.html").write_text(template.substitute(values), encoding="utf-8")
    print(f"Built {len(LOCALES)} localized pages in {DIST}")


if __name__ == "__main__":
    build()
