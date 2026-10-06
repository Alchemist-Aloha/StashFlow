import assert from 'node:assert/strict'
import { test } from 'node:test'
import { pageHtml, pageProps } from './site.js'
import { loadRepositoryInfo, parseRelease } from './src/repository.js'
import { readFileSync } from 'node:fs'

test('localized HTML escapes copy and hydration data without changing its values', () => {
  const props = pageProps('de')
  props.copy.description = '<tag title="quoted">& __TITLE__'
  props.copy.pageTitle = '</script><script>alert(1)</script>'
  const template = '<html lang="__LANG__"><meta content="__DESCRIPTION__"><title>__TITLE__</title>' +
    '<script id="site-data" type="application/json">__SITE_DATA__</script>' +
    '<link href="./assets/app.css"><div id="app"></div></html>'
  const html = pageHtml(template, props, '<main>Rendered content</main>')
  assert.ok(html.includes('lang="de"'))
  assert.ok(html.includes('&lt;tag title=&quot;quoted&quot;&gt;&amp; __TITLE__'))
  assert.ok(html.includes('href="../assets/app.css"'))
  assert.ok(html.includes('<div id="app"><main>Rendered content</main></div>'))
  const data = html.split('type="application/json">')[1].split('</script>')[0]
  assert.ok(!data.includes('<'))
  assert.deepEqual(JSON.parse(data), props)
  assert.ok(!html.includes('<script>alert(1)</script>'))
})

test('repository metadata validates responses and degrades independently', async t => {
  const signal = new AbortController().signal
  let replies
  const requests = []
  t.mock.method(globalThis, 'fetch', async (url, options) => {
    requests.push(url)
    assert.equal(options.signal, signal)
    const reply = replies.shift()
    if (reply instanceof Error) throw reply
    return { ok: reply.ok !== false, json: async () => reply.body }
  })
  for (const [responses, expected] of [
    [[{ body: { name: ' RenamedRepo ' } }, { body: { tag_name: 'v2.0.0', assets: [] } }], ['RenamedRepo', { tag: 'v2.0.0', platforms: [] }]],
    [[{ ok: false }, { body: { tag_name: 'v2.0.0', assets: [] } }], [null, { tag: 'v2.0.0', platforms: [] }]],
    [[{ body: { name: 'StashFlow' } }, new Error('offline')], ['StashFlow', null]],
    [[{ body: { name: 42 } }, { body: { tag_name: ' '.repeat(101) } }], [null, null]],
    [[{ body: null }, { body: { tag_name: 'x'.repeat(101) } }], [null, null]],
  ]) {
    replies = [...responses]
    assert.deepEqual(await loadRepositoryInfo(signal), expected)
  }
  assert.equal(requests[0], 'https://api.github.com/repos/Alchemist-Aloha/StashFlow')
  assert.equal(requests[1], 'https://api.github.com/repos/Alchemist-Aloha/StashFlow/releases/latest')
})

test('latest downloads use uploaded assets, replacing removed builds and rejecting unsafe links', () => {
  const snapshot = JSON.parse(readFileSync(new URL('./downloads.json', import.meta.url)))
  const assets = snapshot.platforms.flatMap(platform => platform.packages.map(pkg => ({
    name: pkg.file, state: 'uploaded',
    browser_download_url: `https://github.com/Alchemist-Aloha/StashFlow/releases/download/v${snapshot.version}/${pkg.file}`,
  })))
  const parsed = parseRelease({ tag_name: `v${snapshot.version}`, assets })
  assert.deepEqual(parsed.platforms, snapshot.platforms.map(platform => ({
    ...platform, packages: platform.packages.map(pkg => ({
      ...pkg, url: assets.find(asset => asset.name === pkg.file).browser_download_url,
    })),
  })))
  const file = 'StashFlow-2.0.0-windows-arm64.zip'
  const asset = { name: file, state: 'uploaded', browser_download_url: `https://github.com/Alchemist-Aloha/StashFlow/releases/download/v2.0.0/${file}` }
  const latest = parseRelease({ tag_name: 'v2.0.0', assets: [asset] })
  assert.equal(latest.tag, 'v2.0.0')
  assert.deepEqual(latest.platforms.map(platform => platform.id), ['windows'])
  assert.equal(latest.platforms[0].packages[0].architecture, 'ARM64')
  assert.equal(latest.platforms[0].packages[0].url, asset.browser_download_url)
  for (const invalid of [
    { ...asset, state: 'new' },
    { ...asset, browser_download_url: 'javascript:alert(1)' },
    { ...asset, browser_download_url: asset.browser_download_url.replace('github.com', 'example.com') },
    { ...asset, browser_download_url: asset.browser_download_url.replace('v2.0.0', 'v1.0.0') },
    { ...asset, name: file + '.sha256', browser_download_url: asset.browser_download_url + '.sha256' },
  ]) {
    assert.deepEqual(parseRelease({ tag_name: 'v2.0.0', assets: [invalid] }).platforms, [])
  }
  assert.equal(parseRelease({ tag_name: 'v2.0.0' }), null)
})
