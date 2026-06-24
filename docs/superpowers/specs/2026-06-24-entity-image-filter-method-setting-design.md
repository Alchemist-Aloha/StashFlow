# Entity image filter method setting

## Goal

Let users choose how the existing entity-gallery All Images action scopes the
reused Images page. The default remains direct image metadata filtering.

## Interface

Add an Interface settings entry named `Entity image filtering` with a
single-choice segmented control:

- `Direct entity` is the default. Performer, studio, and tag pages filter
  images by the matching direct image relationship.
- `Related galleries` filters images through galleries that have the matching
  performer, studio, or tag relationship.

The labels describe the behavior consistently for all entity kinds rather
than implying that studio and tag pages use performer metadata.

## State and navigation

Persist an enum preference in SharedPreferences. A provider in the entity
gallery filter scope reads the stored value and exposes an update method.
When the bottom-pill action is tapped, it reads that provider and constructs
either the current direct `ImageFilter` criteria or the nested
`galleries_filter` criteria. Existing Images routes and UI stay unchanged.

## Testing

Cover the default and persisted setting values, interaction with the Interface
settings control, and both filter outputs for performer, studio, and tag
actions.
