import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { locales, pageHtml, pageProps } from './site.js'

export default defineConfig({
  base: './',
  publicDir: false,
  plugins: [
    vue(),
    {
      name: 'localized-dev-pages',
      apply: 'serve',
      transformIndexHtml(html, context) {
        const candidate = (context.originalUrl ?? context.path).split('?')[0].split('/')[1]
        const locale = Object.hasOwn(locales, candidate) ? candidate : 'en'
        return pageHtml(html, pageProps(locale))
      },
    },
  ],
})
