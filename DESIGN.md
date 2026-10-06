# Introduction website design

Scope: the standalone website. Mode: Persuade. This branch contains no native
application or Flutter demo code. Vue 3 pre-renders and hydrates the page while
preserving native radios and disclosure interactions.

## Direction contract

**THESIS:** Let the library's actual interface introduce StashFlow, not invented
metrics or a wall of feature cards. The user-pinned reference is Apple's product
introduction style.

**OWN-WORLD:** Screenshot-led palette: blush white (#f8f4f8), plum ink
(#241b27), plum-black showcase (#171117), and soft orchid (#eab5ec) actions
with dark plum labels. Muted mauve copy and lavender-tinted tool surfaces connect
the light sections to the app captures. The hero commits to plum-black with
orchid display type and an enlarged laptop/phone composition. The light mobile
showcase provides a deliberate release from that opening. The download finale
lets the existing orchid accent own a full section, with plum type and an organized
download directory. Flat platform groups use hairline separators, architecture
and format labels, and drawn download arrows rather than a wall of cards. The
published version and releases link stay visible, with the web package separated
from native builds. Self-hosted variable Manrope
honors the requested font, with system fallback for unsupported scripts. Fluid
38–96px hero type at weight 800, 36–68px section type (up to 96px for the
control showcase and download finale), and 18–23px supporting copy. Pill actions with defined borders and quiet press feedback, plum-tinted device
frames, hairline separators, and offset soft device shadows. The control showcase
uses the hero's plum-black and orchid language: large unboxed screenshots lead,
with quieter captions below rather than pale image cards.

**STORY:** Understand that StashFlow connects to an existing Stash server, explore
mobile browsing/playback/editing, see desktop support, then download a native
release. Explain web-demo limitations and the lack of an iOS target.

**FIRST VIEWPORT:** Centered orchid two-line headline on plum-black, short
supporting copy, download and exploration actions, then a wider desktop library
composition beside a larger mobile screen.
The desktop section shows real scene playback and details. Filter and sort
screenshots show concrete library controls, including saved sort defaults.
Screen frames follow
the original, uncropped image proportions rather than stretching content to a fixed ratio.

**FORM:** Device-led product introduction. Brief-pinned Apple direction overrides
the concept roll (seed 8b7e4bf4); no alternative app identity is implied.

**FINISH:** Desktop/mobile captures inspected, static and browser checks complete,
website design recorded, raster provenance in README. Independent delegated
review was not run; implementation and visual verification were performed in-thread.

## Interaction and adaptation

The focal entrance assembles the same library across devices: a brief headline
shutter introduces the composition, the laptop turns from a foreshortened view,
and the phone travels out from its companion screen into place. The bounded
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
Screenshot browsing uses native radio inputs within one fieldset. Browse, Play,
and Refine form an equal-width segmented capsule on the lavender surface, with
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
The control section is a full-width dark interlude with orchid display type.
Larger filter/sort screenshots lead their captions, staggered on wide layouts
to break the equal-card rhythm; small screens restore a straight reading sequence. Tool screenshots and the
mobile showcase preserve full source framing. Responsive verification covers 320, 390, 768, and 1440px across every locale.
Chromium captures are local verification artifacts, not physical-device screenshots.

Device borders represent hardware chrome, not decorated content cards.
