import { cp, mkdir, readFile, rm, writeFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { build } from 'vite'
import { locales, pageHtml, pageProps, root } from './site.js'

const dist = new URL('./dist/', root)
const server = new URL('./.ssr/', root)
const configFile = fileURLToPath(new URL('vite.config.js', root))
// Validate every locale before Vite replaces the previous output.
const pages = Object.keys(locales).map(pageProps)

try {
  await build({ root: fileURLToPath(root), configFile })
  await build({
    root: fileURLToPath(root), configFile,
    build: { ssr: 'src/entry-server.js', outDir: fileURLToPath(server) },
  })
  const { render } = await import(new URL('entry-server.js', server))
  const template = await readFile(new URL('index.html', dist), 'utf8')
  await cp(new URL('assets/', root), new URL('assets/', dist), { recursive: true })
  for (const props of pages) {
    const output = props.locale === 'en' ? dist : new URL(`${props.locale}/`, dist)
    await mkdir(output, { recursive: true })
    await writeFile(new URL('index.html', output), pageHtml(template, props, await render(props)))
  }
  console.log(`Built ${Object.keys(locales).length} localized Vue pages in ${fileURLToPath(dist)}`)
} finally {
  await rm(server, { recursive: true, force: true })
}
