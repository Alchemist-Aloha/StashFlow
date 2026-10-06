import { readFileSync } from 'node:fs'

export const locales = {
  en: 'English', de: 'Deutsch', es: 'Español', fr: 'Français',
  it: 'Italiano', ja: '日本語', ko: '한국어', ru: 'Русский',
  zh: '中文', zh_Hans: '简体中文', zh_Hant: '繁體中文',
}
export const root = new URL('./', import.meta.url)
const catalogs = new URL('../lib/l10n/website/', root)
const english = JSON.parse(readFileSync(new URL('site_en.arb', catalogs), 'utf8'))
const expected = Object.keys(english).filter(key => !key.startsWith('@')).sort()

/** Validate isolated ARB catalogs before producing static pages or dev previews. */
export function pageProps(locale) {
  const catalog = JSON.parse(readFileSync(new URL(`site_${locale}.arb`, catalogs), 'utf8'))
  const actual = Object.keys(catalog).filter(key => !key.startsWith('@')).sort()
  if (JSON.stringify(actual) !== JSON.stringify(expected) ||
      actual.some(key => typeof catalog[key] !== 'string' || !catalog[key].trim())) {
    throw new Error(`Invalid translation catalog: ${locale}`)
  }
  const copy = Object.fromEntries(actual.map(key => [key, catalog[key]]))
  return { copy, locale, locales, assetPrefix: locale === 'en' ? '.' : '..' }
}

const escape = value => value.replaceAll('&', '&amp;').replaceAll('"', '&quot;')
  .replaceAll('<', '&lt;').replaceAll('>', '&gt;')

/** Relative URLs and escaped hydration data keep pages safe at any hosting subpath. */
export function pageHtml(template, props, app = '') {
  const replacements = {
    __LANG__: props.locale.replaceAll('_', '-'),
    __DESCRIPTION__: escape(props.copy.description),
    __TITLE__: escape(props.copy.pageTitle),
    __SITE_DATA__: JSON.stringify(props).replaceAll('<', '\\u003c'),
    '<div id="app"></div>': `<div id="app">${app}</div>`,
  }
  return template.replaceAll('./assets/', `${props.assetPrefix}/assets/`)
    .replace(/__LANG__|__DESCRIPTION__|__TITLE__|__SITE_DATA__|<div id="app"><\/div>/g,
      token => replacements[token])
}
