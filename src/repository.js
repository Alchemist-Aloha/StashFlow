const api = 'https://api.github.com/repos/Alchemist-Aloha/StashFlow'
const platforms = { android: 'Android', windows: 'Windows', macos: 'macOS', linux: 'Linux', web: 'Web' }
const architectures = { 'arm64-v8a': 'ARM64', 'armeabi-v7a': 'ARMv7', arm64: 'ARM64', armv7: 'ARMv7' }
const formats = { apk: 'APK', exe: 'EXE', zip: 'ZIP', deb: 'Deb', rpm: 'RPM', dmg: 'DMG', pkg: 'PKG', msi: 'MSI', msix: 'MSIX', AppImage: 'AppImage', 'pkg.tar.zst': 'Pacman', 'tar.gz': 'tar.gz', 'tar.xz': 'tar.xz' }
const validText = value => typeof value === 'string' && value.trim() && value.length <= 100

/** Group actual published assets; unsafe URLs and unrecognized filenames are omitted. */
export function parseRelease(data) {
  if (!validText(data?.tag_name) || !Array.isArray(data.assets)) return null
  const groups = Object.entries(platforms).map(([id, name]) => ({ id, name, packages: [] }))
  for (const asset of data.assets) {
    if (asset?.state !== 'uploaded' || typeof asset.name !== 'string') continue
    const match = asset.name.match(/^StashFlow-.+-(android|windows|macos|linux|web)(?:-([a-z0-9_-]+))?\.([a-zA-Z0-9.]+)$/)
    if (!match) continue
    try {
      const url = new URL(asset.browser_download_url)
      if (url.origin !== 'https://github.com' || url.username || url.password ||
          url.search || url.hash ||
          url.pathname !== `/Alchemist-Aloha/StashFlow/releases/download/${encodeURIComponent(data.tag_name.trim())}/${encodeURIComponent(asset.name)}`) continue
      const [, platform, architecture = '', format] = match
      if (!Object.hasOwn(formats, format) || (platform !== 'web' && !architecture)) continue
      groups.find(group => group.id === platform).packages.push({
        architecture: architectures[architecture] || architecture,
        format: formats[format] || format,
        file: asset.name,
        url: url.href,
      })
    } catch {
      // Ignore malformed asset URLs without losing the rest of the release.
    }
  }
  return { tag: data.tag_name.trim(), platforms: groups.filter(group => group.packages.length) }
}

/** Return [repository name, latest release with assets]; either request may fail independently. */
export async function loadRepositoryInfo(signal) {
  return Promise.all(['', '/releases/latest'].map(async path => {
    try {
      const response = await fetch(`${api}${path}`, { signal })
      if (!response.ok) return null
      const data = await response.json()
      return path ? parseRelease(data) : validText(data?.name) ? data.name.trim() : null
    } catch {
      return null
    }
  }))
}
