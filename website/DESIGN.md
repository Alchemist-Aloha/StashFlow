# Introduction website design

Scope: the standalone website only. Mode: Persuade. The Flutter application
retains its existing Material 3 design and demo deployment. Vue 3 renders and
hydrates the existing page composition; the port preserves its CSS, imagery,
copy, native radios, and disclosure interactions.

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
lets the existing orchid accent own a full section, with plum type and a dark
primary action. Self-hosted variable Manrope
honors the requested font, with system fallback for unsupported scripts. Fluid
38–96px hero type at weight 800, 36–68px section type (up to 96px for the
download finale), and 18–23px supporting copy. Pill actions with defined borders and quiet press feedback, plum-tinted device
frames, hairline separators, and offset soft device shadows. Tool imagery sits
on softly rounded lavender stages rather than feature cards.

**STORY:** Understand that StashFlow connects to an existing Stash server, explore
mobile browsing/playback/editing, see desktop support, then download a native
release. Explain web-demo limitations and the lack of an iOS target.

**FIRST VIEWPORT:** Centered orchid two-line headline on plum-black, short
supporting copy, release and exploration actions, then a wider desktop library
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

The focal entrance assembles the same library across devices: the laptop settles
into a front-on view as the phone moves into its companion position, within 900ms.
The desktop laptop expands into its reading position with native CSS scroll-driven
animation where supported; other browsers show the steady final composition.
Screenshot changes use a short screen-mask transition and a quiet caption fade.
Actions give press feedback and exploration arrows move toward their destination.
No loops, scroll listeners, or animation dependencies are used. Reduced motion
removes spatial effects while retaining immediate selection and color feedback.
Screenshot browsing uses native radio inputs:
keyboard arrows choose a panel, visible labels work by touch and pointer.
The header pairs a compact 44px outlined GitHub logo link with the primary download
action; its accessible name and tooltip reuse localized source-link copy. Narrow navigation
wraps without hiding links. The footer uses native disclosure for language links, a drawn chevron that
reflects its open state, and comfortably padded menu rows. Directional links
use consistent stroke SVG arrows rather than font-dependent glyphs. Controls have visible
focus, 44px minimum target heights, and no dependency on JavaScript.

Large layouts pair a larger phone with feature copy; narrow layouts stack them.
Tool screenshots are staggered on wide layouts to break the equal-card rhythm;
small screens restore a straight reading sequence. Tool screenshots and the
mobile showcase preserve full source framing. Responsive verification covers 320, 390, 768, and 1440px across every locale.
Chromium captures are local verification artifacts, not physical-device screenshots.

Detector findings about the root app's palette/type/radius scale do not apply
to this separate website. The thick rounded border finding describes laptop
hardware chrome, not a decorated card. The former HTML template's unresolved
stylesheet path caused a spurious flat-type warning; the rendered hierarchy was
checked in the browser. No generated HTML carries this development contract.
