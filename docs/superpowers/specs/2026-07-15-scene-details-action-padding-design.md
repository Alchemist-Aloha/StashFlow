# Scene Details Action Padding

## Goal

Make the scene details rating/action card use equal upper and lower padding.

## Design

Remove the metadata-dependent padding override from `SceneDetailsPage` so the
existing section-container default, `EdgeInsets.all(AppTheme.spacingMedium)`,
applies on every side. Keep the current spacing between the identity block and
the card, action layout, and metadata behavior unchanged.

## Verification

Add one widget assertion that the controls have equal top and bottom inset
inside `scene_header_section`, then run the focused scene player UI test.
