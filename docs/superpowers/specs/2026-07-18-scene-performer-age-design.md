# Scene Performer Age Design

## Goal

On the scene details page, display each performer's age during the scene's
calendar year immediately after the performer name. The age uses the simple
calculation `scene year - birth year`; it does not adjust for whether the
performer's birthday had occurred by the scene date.

## Data Flow

Extend the existing scene GraphQL performer selection with `birthdate`. Map the
returned values into a `performerBirthdates` list on `Scene`, preserving the
same ordering as `performerIds`, `performerNames`, and
`performerImagePaths`. This keeps scene loading to one request and avoids a
broader refactor to full performer objects.

Existing `Scene` construction sites remain source-compatible by giving the new
list an empty default. Repository mappings populate it when GraphQL performer
data is available.

## Age Calculation and Rendering

Add a small, independently testable helper that parses the birthdate year and
returns `scene.year - birthYear`. It returns no age when the birthdate is
missing or invalid, or when the result would be negative.

In each performer row on `SceneDetailsPage`, render the existing performer name
followed by ` (age)` when an age is available. The performer name retains its
current body text style. The age suffix uses the same typography with the
theme's less-saturated `onSurfaceVariant` color. When no valid age is
available, render only the performer name and preserve the row's existing
navigation behavior.

## Testing

- Unit coverage verifies the year-only calculation, including that it does not
  adjust for month/day.
- Unit coverage verifies missing, invalid, and future birthdates omit the age.
- Widget coverage verifies the name and age appear together and that the age
  suffix uses the muted theme color.
- Existing scene repository and page tests must continue to pass after GraphQL
  and model generation.

## Scope

This change affects only performer rows on the scene details page. It does not
add age to scene cards, the scene information sheet, performer pages, or other
entity views, and it does not introduce additional performer fetches.
