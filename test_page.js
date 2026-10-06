import assert from 'node:assert/strict'
import { test } from 'node:test'
import { pageHtml, pageProps } from './site.js'

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
