<script setup>
defineProps({
  copy: { type: Object, required: true },
  locale: { type: String, required: true },
  locales: { type: Object, required: true },
  assetPrefix: { type: String, required: true },
})
</script>

<template>
  <a class="skip-link" href="#main">{{ copy.skip }}</a>
  <header class="site-header">
    <nav class="navigation" :aria-label="copy.overview">
      <a class="brand" href="#main"><img :src="`${assetPrefix}/assets/icon.png`" width="30" height="30" alt="">StashFlow</a>
      <div class="nav-links"><a href="#mobile">{{ copy.mobile }}</a><a href="#desktop">{{ copy.desktop }}</a><a class="button small repo-button" href="https://github.com/Alchemist-Aloha/StashFlow" :aria-label="copy.source" :title="copy.source"><svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true" focusable="false"><path d="M6.766 11.328c-2.063-.25-3.516-1.734-3.516-3.656 0-.781.281-1.625.75-2.188-.203-.515-.172-1.609.063-2.062.625-.078 1.468.25 1.968.703.594-.187 1.219-.281 1.985-.281.765 0 1.39.094 1.953.265.484-.437 1.344-.765 1.969-.687.218.422.25 1.515.046 2.047.5.593.766 1.39.766 2.203 0 1.922-1.453 3.375-3.547 3.64.531.344.89 1.094.89 1.954v1.625c0 .468.391.734.86.547C13.781 14.359 16 11.53 16 8.03 16 3.61 12.406 0 7.984 0 3.563 0 0 3.61 0 8.031a7.88 7.88 0 0 0 5.172 7.422c.422.156.828-.125.828-.547v-1.25c-.219.094-.5.156-.75.156-1.031 0-1.64-.562-2.078-1.609-.172-.422-.36-.672-.719-.719-.187-.015-.25-.093-.25-.187 0-.188.313-.328.625-.328.453 0 .844.281 1.25.86.313.452.64.655 1.031.655s.641-.14 1-.5c.266-.265.47-.5.657-.656"/></svg></a><a class="button small" href="#download">{{ copy.download }}</a></div>
    </nav>
  </header>
  <main id="main">
    <section class="hero" aria-labelledby="hero-title">
      <h1 id="hero-title">{{ copy.heroTitle }}</h1>
      <p class="hero-lead">{{ copy.heroLead }}</p>
      <div class="actions"><a class="button" href="https://github.com/Alchemist-Aloha/StashFlow/releases/latest">{{ copy.download }}</a><a class="text-link" href="#mobile">{{ copy.explore }} <svg class="link-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M5 12h14m-6-6 6 6-6 6"/></svg></a></div>
      <div class="hero-devices">
        <div class="laptop">
          <div class="laptop-screen"><img :src="`${assetPrefix}/assets/scenes_desktop.webp`" width="1918" height="1046" :alt="copy.desktopBrowse" fetchpriority="high"></div>
          <div class="laptop-base"></div>
        </div>
        <div class="phone hero-phone"><img :src="`${assetPrefix}/assets/scenes.webp`" width="540" height="1170" :alt="copy.browse" fetchpriority="high"></div>
      </div>
      <p class="device-note">{{ copy.heroNote }}</p>
    </section>

    <section class="mobile-showcase" id="mobile" aria-labelledby="mobile-title">
      <div class="section-heading"><h2 id="mobile-title">{{ copy.mobileTitle }}</h2><p>{{ copy.mobileLead }}</p></div>
      <fieldset class="showcase"><legend class="sr-only">{{ copy.mobile }}</legend>
        <input type="radio" name="showcase" id="browse" checked><label for="browse">{{ copy.browse }}</label>
        <input type="radio" name="showcase" id="play"><label for="play">{{ copy.play }}</label>
        <input type="radio" name="showcase" id="refine"><label for="refine">{{ copy.refine }}</label>
        <div class="showcase-panels">
          <figure class="showcase-panel browse-panel"><div class="phone"><img :src="`${assetPrefix}/assets/scenes.webp`" width="540" height="1170" :alt="copy.browse" loading="lazy"></div><figcaption><h3>{{ copy.browse }}</h3><p>{{ copy.browseCopy }}</p></figcaption></figure>
          <figure class="showcase-panel play-panel"><div class="phone"><img :src="`${assetPrefix}/assets/scene_details.webp`" width="438" height="947" :alt="copy.play" loading="lazy"></div><figcaption><h3>{{ copy.play }}</h3><p>{{ copy.playCopy }}</p></figcaption></figure>
          <figure class="showcase-panel refine-panel"><div class="phone"><img :src="`${assetPrefix}/assets/edit_scene.webp`" width="540" height="1170" :alt="copy.refine" loading="lazy"></div><figcaption><h3>{{ copy.refine }}</h3><p>{{ copy.refineCopy }}</p></figcaption></figure>
        </div>
      </fieldset>
      <p class="screenshot-note">{{ copy.heroNote }}</p>
    </section>

    <section class="desktop-showcase" id="desktop" aria-labelledby="desktop-title">
      <div class="section-heading"><h2 id="desktop-title">{{ copy.desktopTitle }}</h2><p>{{ copy.desktopLead }}</p></div>
      <div class="laptop"><div class="laptop-screen"><img :src="`${assetPrefix}/assets/scene_details_desktop.webp`" width="1919" height="1044" :alt="copy.desktopPlay" loading="lazy"></div><div class="laptop-base"></div></div>
    </section>

    <section class="tools" aria-labelledby="tools-title">
      <h2 id="tools-title">{{ copy.toolsTitle }}</h2>
      <div class="tool-grid">
        <article class="tool"><div class="tool-copy"><h3>{{ copy.filterTitle }}</h3><p>{{ copy.filterCopy }}</p></div><div class="screenshot-crop"><img :src="`${assetPrefix}/assets/scene_filter.webp`" width="540" height="1170" :alt="copy.filterTitle" loading="lazy"></div></article>
        <article class="tool"><div class="tool-copy"><h3>{{ copy.sortTitle }}</h3><p>{{ copy.sortCopy }}</p></div><div class="screenshot-crop"><img :src="`${assetPrefix}/assets/scene_sort.webp`" width="540" height="1170" :alt="copy.sortTitle" loading="lazy"></div></article>
      </div>
    </section>

    <section class="download-section" id="download" aria-labelledby="download-title">
      <img class="download-icon" :src="`${assetPrefix}/assets/icon.png`" width="88" height="88" alt="" loading="lazy">
      <h2 id="download-title">{{ copy.startTitle }}</h2><p>{{ copy.startCopy }}</p>
      <div class="actions"><a class="button" href="https://github.com/Alchemist-Aloha/StashFlow/releases/latest">{{ copy.releases }}</a><a class="text-link" href="https://alchemist-aloha.github.io/StashFlow/">{{ copy.demo }} <svg class="link-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M7 17 17 7M7 7h10v10"/></svg></a></div>
      <p class="availability">Android · Windows · macOS · Linux</p>
      <p class="download-note">{{ copy.serverNote }}<br>{{ copy.demoNote }}</p>
    </section>
  </main>
  <footer><div class="footer-top"><a class="brand" href="#main">StashFlow</a><a href="https://github.com/Alchemist-Aloha/StashFlow">{{ copy.source }} <svg class="link-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M7 17 17 7M7 7h10v10"/></svg></a><details class="languages"><summary>{{ copy.language }} <svg class="language-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="m6 9 6 6 6-6"/></svg></summary><nav :aria-label="copy.language"><a v-for="(label, target) in locales" :key="target" :href="target === 'en' ? `${assetPrefix}/index.html` : `${assetPrefix}/${target}/index.html`" :lang="target.replaceAll('_', '-')" :hreflang="target.replaceAll('_', '-')" :aria-current="target === locale ? 'page' : undefined">{{ label }}</a></nav></details></div><p>StashFlow · GPL-3.0</p></footer>
</template>
