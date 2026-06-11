# Scene Info Media Section Design

## Goal

Add a media section near the top of the scene information bottom sheet that
lets users view the scene cover or a short preview video without affecting the
app's global scene player.

## Placement

The media section appears directly below the sheet header and before scene
metadata chips, studio information, performers, tags, and technical details.

## Availability Rules

The section derives two independent capabilities from the scene:

- Cover is available when `scene.paths.screenshot` is non-empty.
- Preview is available when `scene.paths.preview` is non-empty.

The rendered state is:

| Cover | Preview | Result |
| --- | --- | --- |
| Yes | Yes | Show a Cover/Preview toggle and default to Cover. |
| Yes | No | Show the cover without a toggle. |
| No | Yes | Show the preview player paused without a toggle. |
| No | No | Hide the entire media section. |

## Cover Mode

Cover mode renders the authenticated scene screenshot in a clipped 16:9 black
media surface using `StashImage` and `BoxFit.contain`. It does not initialize a
video player.

## Preview Mode

Preview mode owns an isolated `media_kit` `Player` and `VideoController`. It
resolves relative preview URLs against the configured GraphQL endpoint and
uses the existing media playback authentication behavior, including the web
URL fallback.

Preview-only scenes open with `play: true` and start automatically. When the
user switches from Cover to Preview, the player also opens with `play: true`.
The `Video` widget uses media_kit's Material controls, providing play/pause,
progress seeking, and fullscreen.

The preview player is initialized lazily when Preview mode first becomes
visible. Switching back to Cover removes and disposes the preview player. The
player and error subscription are also disposed when the media widget leaves
the tree or changes to a different scene or preview URL.

Initialization and playback errors are shown over the black media surface
without removing the mode toggle.

## Component Boundary

Create a public `SceneInfoMediaSection` widget alongside the existing scene
presentation widgets. It accepts a `Scene`, owns display mode and preview
player lifecycle, and renders nothing when neither media asset exists.

`SceneInfoPage` only places this widget below its header. This keeps player
state and authentication details out of the already substantial information
page and prevents the preview from taking ownership of the global playback
session.

## Testing

Widget tests cover:

- both assets show the toggle and default to the cover;
- selecting Preview replaces the cover with the preview surface;
- cover-only scenes show no toggle;
- preview-only scenes show the preview surface without a toggle;
- scenes with neither asset hide the section;
- returning to Cover pauses an initialized preview player through the widget's
  injected player boundary.

Tests use an injectable player/controller factory so media lifecycle behavior
can be verified without loading native media backends.
