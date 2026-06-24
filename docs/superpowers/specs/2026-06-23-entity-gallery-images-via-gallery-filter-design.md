# Entity gallery images via gallery filter

## Goal

Make the existing Images page show images that belong to galleries related to
the selected performer, studio, or tag, even when the images themselves have
no corresponding metadata.

## Data flow

The entity-gallery bottom-pill action will continue to reset the shared image
filter and open `/galleries/images`. Instead of writing performer, studio, or
tag criteria onto `ImageFilter` directly, it will set a nested gallery filter:

- performer pages use `galleries_filter.performers`.
- studio pages use `galleries_filter.studios`.
- tag pages use `galleries_filter.tags`.

This uses Stash's server-side `ImageFilterType.galleries_filter` relationship
query, so it covers every matching gallery rather than only galleries loaded
in the current grid page.

## Implementation boundary

`ImageFilter` will gain an optional `GalleryFilter galleriesFilter` field.
`GraphQLImageRepository` will serialize that field as the generated
`Input$ImageFilterType.galleries_filter` input. The existing entity-gallery
filter-scope helper will construct the nested filter for the selected entity.
No new route, image page, or gallery-ID prefetch is needed.

## Testing

Add focused tests that verify each entity kind produces the expected nested
gallery filter, and that the image repository emits the matching GraphQL
`galleries_filter` payload. The existing widget regression will continue to
verify navigation and reset of stale image state.
