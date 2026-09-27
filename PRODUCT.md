# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

People who run a personal Stash server and use StashFlow to browse, play, and
manage their media library across devices.

## Product Purpose

StashFlow is a client for a user's Stash server. It makes the same library
available for discovery, playback, and management on different device sizes and
input methods.

## Positioning

The product is a multi-platform Stash client with native playback and library
management. The web build is a limited demo because browser authentication and
codec support constrain it.

## Operating Context

- Users connect to their own Stash server and can switch between saved server
  profiles.
- Current application targets are Android and desktop (Windows, macOS, Linux).
  The web build is available as a demo. This checkout has no iOS app target.
- Touch, mouse, keyboard, and available screen width affect navigation and
  controls. Designs must work across the current device classes rather than
  assume one screen size or input method.

## Capabilities and Constraints

- Library browsing covers scenes, markers, images, galleries, performers,
  studios, tags, and groups, with search, filters, sorting, and saved defaults.
- Playback includes contextual queues, subtitles, background audio, PiP, and
  casting where the platform supports them.
- Users can edit metadata and entity associations, manage server profiles, and
  configure appearance, playback, storage, security, and navigation.
- Server credentials and app-lock secrets belong in secure storage. Switching
  profiles must not expose data from another server.
- The interface is localized through ARB files. Current behavior and
  verification contracts are documented in `docs/SPECS.md`.

## Brand Commitments

The product name is StashFlow. Existing logo and screenshots are under `asset/`.

## Evidence on Hand

`README.md` describes supported platforms and user-facing features;
`docs/SPECS.md` defines current product and accessibility contracts. Screenshots
of core flows are in `asset/`.

## Product Principles

- Keep the Stash library usable across supported devices and input methods.
- Preserve list, filter, and playback context as users move through the library.
- Protect server-bound data and credentials when profiles change.
- Make controls understandable through localization, accessible states, and
  responsive behavior.

## Accessibility & Inclusion

The interface must support dynamic scaling, readable contrast, keyboard focus,
screen-reader labels, and touch targets at supported scale extremes. Every
user-visible string must use the supported localization files.
