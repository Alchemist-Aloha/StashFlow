# Interaction-Driven VTT Loading Design

## Problem

Stash always returns constructed `paths.vtt` and `paths.sprite` URLs. Their
presence does not prove that the generated files exist. `SceneCard` currently
fetches and parses every VTT while cards are created, producing avoidable
network and rebuild work during scrolling.

## Design

- Treat a non-empty VTT URL and positive scene duration as a scrubbing
  capability hint.
- Do not fetch VTT data while building or initializing a scene card.
- Start loading only when the user first hovers or horizontally drags a card.
- Let the VTT response and parsed cues determine actual availability.
- Stop requiring `paths.sprite`; each VTT cue contains the authoritative sprite
  image URL.
- Cache completed requests and deduplicate concurrent requests in `VttService`.
- Disable further scrubbing for the card after an empty or unavailable VTT is
  returned.

## Verification

- Building a card with a VTT URL performs zero VTT requests.
- First interaction performs one request.
- A VTT URL works without a separate sprite path.
- Concurrent requests for the same URL share one HTTP request.
- Missing VTT data disables subsequent scrubbing attempts.
