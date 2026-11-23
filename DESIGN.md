# Introduction website design

Scope: the standalone website. Mode: Persuade. This branch contains no native
application or Flutter demo code. Vue 3 pre-renders and hydrates the page while
preserving native radios and disclosure interactions.

## Direction contract

**THESIS:** Let the library's actual interface introduce StashFlow, not invented
metrics or a wall of feature cards. The user-pinned reference is Apple's product
introduction style.

**OWN-WORLD:** Screenshot-led palette tuned for vibrant contrast: warm blush paper
(#faf4fd), deep plum ink (#1b0d24), deep obsidian-plum showcases (#110818) with
directional violet studio lighting, electric orchid (#f59eff) display type and
actions with deep plum labels (#1d0826), and royal violet (#7a26c1) active
controls and light-section accents. Plum-tinted secondary copy (#584366 on light,
#d6c5e3 on dark) and an unboxed lavender studio stage (#efe0fa to #f9effc) connect
the light sections to the app captures. The hero commits to obsidian-plum with
directional amethyst lighting behind the Android Feed capture, orchid display type,
and crisp white-lavender lead copy. The vertical video interface, not desktop
hardware, leads the page. The light mobile showcase provides a deliberate release
from that opening, with a royal-violet selected segment and a clean tinted stage.
The download finale lets the orchid-to-lavender gradient own a full section, with
deep plum type, subtle format pills, and an organized download directory. Flat
platform groups use crisp structural rules, architecture and pill format labels,
and drawn download arrows rather than a wall of cards. The published version and
releases link stay visible, with the web package separated from native builds.
Self-hosted variable Manrope honors the requested font, with system fallback for
unsupported scripts. Fluid 38–96px hero type at weight 800, 36–68px section type
(up to 92px for the control showcase and download finale), and 18–22px supporting
copy. Pill actions with crisp borders and quiet press feedback, sculpted
plum-tinted device frames, clean metallic-plum laptop bases, hairline separators,
and grounded offset device shadows. The control showcase uses the hero's
obsidian-plum and orchid language: large unboxed screenshots lead, with vibrant
violet top rules and high-contrast captions below rather than pale image cards.

**STORY:** Understand that StashFlow connects to an existing Stash server, explore
mobile Feed/browsing/playback/editing, see desktop support, then download a native
release (including the unsigned iOS IPA). Explain web-demo limitations.

**FIRST VIEWPORT:** Orchid headline and concise server-connection copy on the
left; a large, upright Feed screenshot on the right. Download and exploration
links sit directly below the copy. The phone preserves the complete Android
capture, including navigation and feed metadata. On mobile the same hierarchy
stacks, with the feed still the only hero device.
The desktop section pairs Linux library browsing with real playback and details. Filter and sort
screenshots show concrete library controls, including saved sort defaults.
Screen frames follow
the original, uncropped image proportions rather than stretching content to a fixed ratio.

**FORM:** Device-led product introduction. Brief-pinned Apple direction overrides
the concept roll (seed 8b7e4bf4); no alternative app identity is implied.

**FINISH:** Desktop/mobile captures inspected, static and browser checks complete,
website design recorded, raster provenance in README. Independent delegated
review was not run; implementation and visual verification were performed in-thread.

## Interaction and adaptation

The focal entrance introduces vertical Feed mode: a brief headline shutter and
an upright phone rising 32px into its final position. The bounded
sequence finishes within 920ms; copy and actions never wait for it.
The desktop laptop opens into its front-on reading position with native CSS
scroll-driven perspective. Tool screenshots similarly turn toward the reader
as their controls enter view, finishing with full, uncropped framing. Browsers
without scroll-animation support show the steady final compositions.
Screenshot selection triggers a 400ms directional screen wipe and a quiet
240ms caption fade. Rapid keyboard selection interrupts the old panel immediately.
Actions give press feedback; pointer hover lifts primary actions by only 2px,
while exploration/external arrows follow their actual direction.
No loops, scroll listeners, permanent compositor hints, or animation dependencies
are used. Perspective transforms and bounded clip masks carry the motion without
animating layout or large-area blur. Reduced motion removes spatial effects while
retaining immediate selection and color feedback.
Screenshot browsing uses native radio inputs within one fieldset. Feed, Browse,
Play, and Refine form equal-width segments on the lavender surface, with Feed
selected by default and
an orchid selected segment, stable label weight, and a distinct focus ring.
Keyboard arrows choose a panel; visible labels work by touch and pointer, even
without JavaScript. Controls, phone, and caption use a tighter shared measure
and balanced spacing without changing the screenshot framing or wipe motion.
The solid plum-black sticky header has just three destinations: home, GitHub,
and download. Duplicate mobile/desktop section links are removed; the hero
exploration action and normal page scrolling still introduce those sections.
The unboxed GitHub icon and compact two-line repository name/release tag are
secondary to the single orchid download action. Metadata refreshes from GitHub
on arrival, updating the download version and actual asset links from the same
release response. Unavailable responses retain the bundled snapshot; a valid
release without downloadable packages shows a localized message. Long names/tags truncate
visually without changing the header's height or losing their accessible names.
No header blur or button shadow competes with the product imagery. Navigation
stays on one row; narrow screens show the brand mark without the wordmark while
retaining its accessible name. Every target is at least 44px with orchid focus
rings; the GitHub name and tooltip reuse localized source-link copy. The footer uses native disclosure for language links, a drawn chevron that
reflects its open state, and comfortably padded menu rows. Directional links
use consistent stroke SVG arrows rather than font-dependent glyphs. Controls have visible
focus, 44px minimum target heights, and no dependency on JavaScript.

Large layouts pair a larger phone with feature copy; narrow layouts stack them.
The two desktop captures sit side by side at wide widths and stack below 700px.
All eight shipped captures come from the same test library and purple app preset.
The control section is a full-width dark interlude with orchid display type.
Larger filter/sort screenshots lead their captions, staggered on wide layouts
to break the equal-card rhythm; small screens restore a straight reading sequence. Tool screenshots and the
mobile showcase preserve full source framing. Responsive verification covers 320, 390, 768, and 1440px across every locale.
Chromium captures are local verification artifacts, not physical-device screenshots.

Device borders represent hardware chrome, not decorated content cards.
