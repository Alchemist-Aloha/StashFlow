# Scene details layout and metadata edit access

## Scope

Refactor the scene-details header hierarchy and remove the preference that
conditionally hides metadata editing. The result applies metadata-edit access
consistently to scenes, performers, and studios.

## Layout

`SceneDetailsPage` will no longer build a `Scaffold` AppBar. The video player
remains the first content element. Its inline video-controls overlay will own a
back action that follows the same visibility and auto-hide behavior as the
existing playback controls.

The five former AppBar actions remain unchanged in behavior and order:

1. Add marker
2. Scene information
3. Download (non-web only)
4. Edit metadata
5. Delete scene

They move to the existing main-information action row immediately after the
rating-star controls and O-counter. The row uses wrapping so constrained
widths retain access to every action without overflow.

## Metadata edit availability

The shared scrape-enabled preference and the Interface Settings control that
updates it will be removed. Scene, performer, and studio detail/edit surfaces
will no longer gate metadata-edit affordances or related edit behavior on that
preference. Edit is visible by default and always usable subject only to the
existing route and repository error handling.

## Component boundaries

- `SceneDetailsPage` owns scene-level action handlers and presents them beside
  rating and O-counter controls.
- `SceneVideoPlayer` / its inline control overlay owns the video-attached back
  affordance and delegates navigation through the current router context.
- Interface settings removes the obsolete preference UI and provider use.
- Performer and studio pages remove their use of the same obsolete gate.

## Error handling and behavior preservation

Existing marker, info, download, edit, and delete handlers are retained. Their
existing dialogs, navigation, platform condition for download, loading states,
and error SnackBars remain intact. The back button uses normal router pop
semantics and is only displayed while the inline playback controls are shown.

## Verification

Widget coverage will demonstrate that scene details has no AppBar action panel,
the five actions are available with the rating/O action row, and a back control
is rendered by the inline video UI. Settings coverage will demonstrate the
obsolete preference is absent. Existing scene-detail, player, performer, and
studio tests will be run alongside focused new regression tests.
