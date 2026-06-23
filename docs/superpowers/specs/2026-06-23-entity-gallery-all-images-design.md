# Entity gallery all-images action

## Goal

Allow users browsing an entity's complete gallery list to open the existing
Images page filtered to that entity. The action applies to performer, studio,
and tag gallery pages.

## UI

`EntityGalleryGrid` will add an image action to its existing floating bottom
pill. It uses the same `Icons.image` icon and `galleries_all_images` tooltip
as the top-level Galleries page, preserving the current gallery-list visual
language.

## Navigation and filter state

Tapping the action resets the global image browsing filter, then applies the
current entity relation to `ImageFilter` and navigates to the existing
`/galleries/images` route:

- performer gallery pages set `ImageFilter.performers`.
- studio gallery pages set `ImageFilter.studios`.
- tag gallery pages set `ImageFilter.tags`.

Resetting the image filter first deliberately removes a previously selected
single gallery or unrelated image filter, so the destination lists all images
for the selected entity. Tapping an individual gallery card remains unchanged
and continues to open that gallery's images.

## Testing

Add focused coverage for the entity-to-image-filter mapping and widget/action
behavior. Verify each gallery-page kind creates the expected criterion and
does not retain a gallery ID or unrelated image filter state.
