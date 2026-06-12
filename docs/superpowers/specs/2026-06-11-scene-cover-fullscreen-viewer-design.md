# Scene Cover Fullscreen Viewer Design

## Goal

Allow users to tap the scene cover in the scene information sheet and inspect
it in a simple full-screen zoomable viewer.

## Presentation

The cover opens as an opaque black full-screen dialog on the root navigator.
The scene information bottom sheet remains mounted underneath and is revealed
unchanged when the viewer closes.

The viewer does not enter immersive system UI mode. It does not modify status
bar, navigation bar, desktop window fullscreen state, or orientation.

## Image

The viewer displays the same authenticated screenshot URL as the media section
using `StashImage` with `BoxFit.contain`. The image fills the available dialog
area without cropping.

Only cover mode opens the viewer. Preview mode remains controlled exclusively
by the preview player's gestures and native controls.

## Zoom And Pan

The image is wrapped in an `InteractiveViewer` with:

- minimum scale `1.0`;
- maximum scale `4.0`;
- panning enabled while enlarged;
- pinch-to-zoom enabled.

A `TransformationController` owns zoom state. Double-tapping at scale `1.0`
zooms to `2.5` around the tap position. Double-tapping while enlarged restores
the identity transform.

## Exit

A safe-area-aware exit-fullscreen icon button is pinned at the top right. It
uses the existing `common_exit_fullscreen` localization and closes only the
dialog. Android back, desktop escape/back navigation, and the exit button all
return to the scene information sheet.

## Components

Create `SceneCoverFullscreenViewer`, a focused stateful widget responsible for
the zoom controller, double-tap behavior, image display, and exit control.

`SceneInfoMediaSection` wraps only the cover surface in a semantic Material
tap target and calls a helper that presents the viewer through
`showGeneralDialog` with the root navigator.

## Testing

Widget tests verify:

- tapping cover mode opens the full-screen viewer;
- the exit button closes the viewer while leaving the media section mounted;
- double-tap changes the `InteractiveViewer` transform to an enlarged scale;
- a second double-tap restores the identity transform;
- pinch zoom remains enabled with the specified scale bounds;
- tapping the preview surface does not open the cover viewer.
