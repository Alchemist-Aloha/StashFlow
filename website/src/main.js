import { createSSRApp, createApp } from 'vue'
import App from './App.vue'
import '../styles.css'

const props = JSON.parse(document.getElementById('site-data').textContent)
const app = document.getElementById('app')
// Static production pages hydrate; Vite's dev shell mounts the same component.
;(app.hasChildNodes() ? createSSRApp : createApp)(App, props).mount(app)
