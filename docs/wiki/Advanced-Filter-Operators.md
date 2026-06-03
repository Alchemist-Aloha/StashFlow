# Advanced Filter Operators

StashFlow supports advanced operators anywhere a filter field shows a **Modifier** dropdown.

This page explains the **in-app UI usage only**. It does not cover GraphQL or saved-filter JSON syntax.

## Where you will see operators

Operator dropdowns appear on filter fields such as:

- Text fields like title, details, path, URL, codecs, and aliases
- Number fields like rating, counts, age, duration, bitrate, and O-counter
- Date fields like scene date, created date, updated date, and last played date
- Entity pickers like performers, tags, studios, groups, and galleries

Some filters use chips or toggles instead of operator dropdowns:

- Boolean filters such as **Yes / No / Any**
- Preset chip filters such as ratings, orientations, and some resolution pickers

## How to use an operator

1. Open a filter panel.
2. Find the field you want to filter on.
3. Change the **Modifier** dropdown.
4. Enter one or two values if the operator requires them.
5. Tap **Apply Filters**.

## Text field operators

These are used for fields like title, details, path, URL, or codec names.

| Operator | What it does | Value needed |
| --- | --- | --- |
| `Equals` | Exact text match | 1 value |
| `Not Equals` | Exact text does not match | 1 value |
| `Includes` | Text contains the value | 1 value |
| `Excludes` | Text does not contain the value | 1 value |
| `Matches Regex` | Text matches a regular expression | 1 value |
| `Does Not Match Regex` | Text does not match a regular expression | 1 value |
| `Is Null` | Field has no value | No value |
| `Not Null` | Field has any value | No value |

### Text examples

- `Path` + `Includes` + `/VR/`
- `Title` + `Matches Regex` + `^Scene [0-9]+$`
- `URL` + `Is Null`

## Number field operators

These are used for fields like rating, counts, age, duration, bitrate, and similar numeric filters.

| Operator | What it does | Value needed |
| --- | --- | --- |
| `Equals` | Number matches exactly | 1 value |
| `Not Equals` | Number does not match exactly | 1 value |
| `Greater Than` | Number is above the value | 1 value |
| `Less Than` | Number is below the value | 1 value |
| `Between` | Number is inside a range | 2 values |
| `Not Between` | Number is outside a range | 2 values |
| `Is Null` | Field has no value | No value |
| `Not Null` | Field has any value | No value |

### Number examples

- `Performer Count` + `Greater Than` + `3`
- `O-Counter` + `Equals` + `0`
- `Rating` + `Between` + `60` and `100`

When you choose `Between` or `Not Between`, StashFlow shows a **second value box**.

## Date field operators

Date fields work like number fields, but values should be typed as dates.

Recommended format:

- `YYYY-MM-DD`

Supported date operators:

- `Equals`
- `Not Equals`
- `Greater Than`
- `Less Than`
- `Between`
- `Not Between`
- `Is Null`
- `Not Null`

### Date examples

- `Date` + `Equals` + `2025-01-01`
- `Created At` + `Greater Than` + `2024-01-01`
- `Last Played` + `Between` + `2025-01-01` and `2025-03-31`

## Entity picker operators

These are used for filters like performers, tags, studios, groups, and galleries.

| Operator | What it does |
| --- | --- |
| `Includes` | Match items that contain any selected entity |
| `Excludes` | Match items that do not contain the selected entity |
| `Includes All` | Match items that contain every selected entity |
| `Is Null` | Match items with no value for that relation |
| `Not Null` | Match items where that relation exists |

### Entity examples

- `Tags` + `Includes` + pick `Anal`
- `Performers` + `Includes All` + pick `Alice` and `Bob`
- `Studios` + `Is Null`

When you choose `Is Null` or `Not Null`, the picker button disappears because no selected entity values are needed.

## Practical tips

- Use `Is Null` to find missing metadata.
  Examples: no URL, no date, no performers, no studio.
- Use `Not Null` to find items where a field exists, even if you do not care about the exact value.
- Use `Between` when you know both ends of the range.
- Use `Matches Regex` only if you are comfortable with regular expressions; otherwise start with `Includes`.
- If a field does not show a **Modifier** dropdown, that field uses a simpler chip/toggle interaction instead of advanced operator syntax.

## Suggested workflows

### Find scenes with missing metadata

- `Studio` → `Is Null`
- `Date` → `Is Null`
- `URL` → `Is Null`

### Find strong matches by text and rating

- `Title` → `Includes` → `Interview`
- `Rating` → `Greater Than` → `80`

### Find media in a date or size band

- `Created At` → `Between` → `2024-01-01` and `2024-12-31`
- `Performer Count` → `Between` → `2` and `5`
